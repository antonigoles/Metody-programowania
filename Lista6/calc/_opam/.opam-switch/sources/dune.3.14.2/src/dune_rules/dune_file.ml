open Import

type t =
  { dir : Path.Source.t
  ; project : Dune_project.t
  ; stanzas : Stanza.t list Memo.Lazy.t
  ; static_stanzas : Stanza.t list
  }

let dir t = t.dir
let stanzas t = Memo.Lazy.force t.stanzas
let static_stanzas t = t.static_stanzas
let project t = t.project

module Mask = struct
  type 'a t =
    | True
    | Fun of ('a -> bool)

  let combine x y =
    match x, y with
    | True, x -> x
    | x, True -> x
    | Fun f, Fun g -> Fun (fun x -> f x && g x)
  ;;

  type keep_stanza =
    | Keep
    | Drop
    | Convert of Stanza.t

  let keep_stanza t stanza =
    match t with
    | True -> Keep
    | Fun f ->
      if f stanza
      then Keep
      else (
        match Stanza.repr stanza with
        | Library.T l ->
          (match Library_redirect.Local.of_private_lib l with
           | None -> Drop
           | Some p -> Convert (Library_redirect.Local.make_stanza p))
        | _ -> Drop)
  ;;

  let of_only_packages_mask mask =
    match mask with
    | None -> True
    | Some visible_pkgs ->
      Fun
        (fun stanza ->
          match Stanzas.stanza_package stanza with
          | None -> true
          | Some package ->
            let name = Package.name package in
            Package.Name.Map.mem visible_pkgs name)
  ;;

  let is_promoted_rule =
    let is_promoted_mode version = function
      | Rule.Mode.Promote { only = None; lifetime; _ } ->
        if version >= (3, 5)
        then (
          match lifetime with
          | Unlimited -> true
          | Until_clean -> false)
        else true
      | _ -> false
    in
    fun version rule ->
      match Stanza.repr rule with
      | Rule_conf.T { mode; _ } | Menhir_stanza.T { mode; _ } ->
        is_promoted_mode version mode
      | _ -> false
  ;;

  let ignore_promote project =
    match !Clflags.ignore_promoted_rules with
    | false -> True
    | true ->
      let version = Dune_project.dune_version project in
      Fun (fun stanza -> not (is_promoted_rule version stanza))
  ;;
end

(* XXX this is needed for evaluating includes generated by dune files written
   in OCaml syntax.*)
let rec parse_file_includes ~stanza_parser ~context sexps =
  List.concat_map sexps ~f:(Dune_lang.Decoder.parse stanza_parser Univ_map.empty)
  |> Memo.List.concat_map ~f:(fun stanza ->
    match Stanza.repr stanza with
    | Stanzas.Include.T (loc, fn) ->
      let open Memo.O in
      let* sexps, context = Include_stanza.load_sexps ~context (loc, fn) in
      parse_file_includes ~stanza_parser ~context sexps
    | _ -> Memo.return [ stanza ])
;;

type eval =
  { project : Dune_project.t
  ; dir : Path.Source.t
  ; mask : Stanza.t Mask.t
  }

let parse_stanzas ~file ~(eval : eval) sexps =
  let warnings = Warning_emit.Bag.create () in
  let open Memo.O in
  let* stanzas =
    let context =
      Include_stanza.in_src_file
      @@
      match file with
      | Some f -> f
      | None ->
        (* TODO this is wrong *)
        Path.Source.relative eval.dir Dune_file0.fname
    in
    let stanza_parser =
      Dune_project.stanza_parser eval.project |> Warning_emit.Bag.set warnings
    in
    parse_file_includes ~stanza_parser ~context sexps
  in
  let rec loop stanzas dynamic_includes env = function
    | [] -> List.rev stanzas, dynamic_includes
    | stanza :: rest ->
      (match Stanza.repr stanza with
       | Dune_env.T e ->
         if env
         then
           User_error.raise
             ~loc:e.loc
             [ Pp.text "The 'env' stanza cannot appear more than once" ]
         else loop (stanza :: stanzas) dynamic_includes true rest
       | Stanzas.Dynamic_include.T (loc, fn) ->
         loop stanzas ((loc, fn) :: dynamic_includes) env rest
       | _ ->
         (match Mask.keep_stanza eval.mask stanza with
          | Keep -> loop (stanza :: stanzas) dynamic_includes env rest
          | Drop -> loop stanzas dynamic_includes env rest
          | Convert stanza -> loop (stanza :: stanzas) dynamic_includes env rest))
  in
  let stanzas, dynamic_includes = loop [] [] false stanzas in
  let+ () = Warning_emit.Bag.emit_all warnings in
  stanzas, dynamic_includes
;;

let parse sexps ~file ~(eval : eval) =
  let open Memo.O in
  let+ stanzas, dynamic_includes = parse_stanzas sexps ~file ~eval in
  ( { dir = eval.dir
    ; project = eval.project
    ; static_stanzas = stanzas
    ; stanzas = Memo.Lazy.of_val stanzas
    }
  , dynamic_includes )
;;

module Make_fold (M : Monad.S) = struct
  open M.O

  let rec fold_static_stanzas l ~init ~f =
    match l with
    | [] -> M.return init
    | t :: l -> inner_fold t t.static_stanzas l ~init ~f

  and inner_fold t inner_list l ~init ~f =
    match inner_list with
    | [] -> fold_static_stanzas l ~init ~f
    | x :: inner_list ->
      let* init = f t x init in
      inner_fold t inner_list l ~init ~f
  ;;
end

module Memo_fold = Make_fold (Memo)
module Id_fold = Make_fold (Monad.Id)

let fold_static_stanzas t ~init ~f = Id_fold.fold_static_stanzas t ~init ~f
let to_dyn = Dyn.opaque

let find_stanzas t key =
  let open Memo.O in
  let+ stanzas = Memo.Lazy.force t.stanzas in
  (* CR-rgrinberg: save a map to represent the stanzas to make this fast. *)
  List.filter_map stanzas ~f:(Stanza.Key.get key)
;;

module Jbuild_plugin : sig
  val create_plugin_wrapper
    :  Context_name.t
    -> Ocaml_config.t
    -> exec_dir:Path.t
    -> plugin:Path.Outside_build_dir.t
    -> wrapper:Path.Build.t
    -> target:Path.Build.t
    -> unit Memo.t
end = struct
  let replace_in_template =
    let template =
      lazy
        (let marker name =
           let open Re in
           [ str "(*$"; rep space; str name; rep space; str "$*)" ] |> seq |> Re.mark
         in
         let mark_start, marker_start = marker "begin_vars" in
         let mark_end, marker_end = marker "end_vars" in
         let markers = Re.alt [ marker_start; marker_end ] in
         let invalid_template stage =
           Code_error.raise
             "Jbuild_plugin.replace_in_template: invalid template"
             [ "stage", Dyn.string stage ]
         in
         let rec parse1 = function
           | `Text s :: xs -> parse2 s xs
           | xs -> parse2 "" xs
         and parse2 prefix = function
           | `Delim ds :: `Text _ :: `Delim de :: xs
             when Re.Mark.test ds mark_start && Re.Mark.test de mark_end ->
             parse3 prefix xs
           | _ -> invalid_template "parse2"
         and parse3 prefix = function
           | [] -> prefix, ""
           | [ `Text suffix ] -> prefix, suffix
           | _ -> invalid_template "parse3"
         in
         let tokens = Re.split_full (Re.compile markers) Assets.jbuild_plugin_ml in
         parse1 tokens)
    in
    fun t ->
      let prefix, suffix = Lazy.force template in
      sprintf "%s%s%s" prefix t suffix
  ;;

  let write
    oc
    ~(context : Context_name.t)
    ~ocaml_config
    ~target
    ~exec_dir
    ~plugin
    ~plugin_contents
    =
    let ocamlc_config =
      let vars =
        Ocaml_config.to_list ocaml_config
        |> List.map ~f:(fun (k, v) -> k, Ocaml_config.Value.to_string v)
      in
      let longest = String.longest_map vars ~f:fst in
      List.map vars ~f:(fun (k, v) -> sprintf "%-*S , %S" (longest + 2) k v)
      |> String.concat ~sep:"\n      ; "
    in
    let vars =
      Printf.sprintf
        {|let context = %S
        let ocaml_version = %S
        let send_target = %S
        let ocamlc_config = [ %s ]
        |}
        (Context_name.to_string context)
        (Ocaml_config.version_string ocaml_config)
        (Path.reach ~from:exec_dir (Path.build target))
        ocamlc_config
    in
    Printf.fprintf
      oc
      "module Jbuild_plugin : sig\n%s\nend = struct\n%s\nend\n# 1 %S\n%s"
      Assets.jbuild_plugin_mli
      (replace_in_template vars)
      (Path.Outside_build_dir.to_string plugin)
      plugin_contents
  ;;

  let check_no_requires path str =
    List.iteri (String.split str ~on:'\n') ~f:(fun n line ->
      match Scanf.sscanf line "#require %S" Fun.id with
      | Error () -> ()
      | Ok (_ : string) ->
        let loc : Loc.t =
          let start : Lexing.position =
            { pos_fname = Path.to_string path; pos_lnum = n; pos_cnum = 0; pos_bol = 0 }
          in
          Loc.create ~start ~stop:{ start with pos_cnum = String.length line }
        in
        User_error.raise
          ~loc
          [ Pp.text "#require is no longer supported in dune files."
          ; Pp.text
              "You can use the following function instead of Unix.open_process_in:\n\n\
              \  (** Execute a command and read it's output *)\n\
              \  val run_and_read_lines : string -> string list"
          ])
  ;;

  let create_plugin_wrapper context ocaml_config ~exec_dir ~plugin ~wrapper ~target =
    let open Memo.O in
    let+ plugin_contents = Fs_memo.file_contents plugin in
    Io.with_file_out (Path.build wrapper) ~f:(fun oc ->
      write oc ~context ~ocaml_config ~target ~exec_dir ~plugin ~plugin_contents);
    check_no_requires (Path.outside_build_dir plugin) plugin_contents
  ;;
end

module Script = struct
  open Memo.O

  type t =
    { file : Path.Source.t
    ; eval : eval
    ; from_parent : Dune_lang.Ast.t list
    }

  (* CR-rgrinberg: context handling code should be aware of this special
     directory *)
  let generated_dune_files_dir = Path.Build.relative Path.Build.root ".dune"

  let eval_one ~context { file; from_parent; eval } =
    let generated_dune_file =
      Path.Build.append_source
        (Path.Build.relative generated_dune_files_dir (Context_name.to_string context))
        file
    in
    let wrapper = Path.Build.extend_basename generated_dune_file ~suffix:".ml" in
    generated_dune_file |> Path.build |> Path.parent |> Option.iter ~f:Path.mkdir_p;
    let* context = Context.DB.get context in
    let* ocaml = Context.ocaml context in
    let* () =
      Jbuild_plugin.create_plugin_wrapper
        (Context.name context)
        ocaml.ocaml_config
        ~exec_dir:(Path.source eval.dir)
        ~plugin:(In_source_dir file)
        ~wrapper
        ~target:generated_dune_file
    in
    let* () =
      let* env = Context.host context >>| Context.installed_env in
      let ocaml = Action.Prog.ok_exn ocaml.ocaml in
      let args =
        [ "-I"; "+compiler-libs"; Path.to_absolute_filename (Path.build wrapper) ]
      in
      Process.run Strict ~display:Quiet ~dir:(Path.source eval.dir) ~env ocaml args
      |> Memo.of_reproducible_fiber
    in
    if not (Path.Untracked.exists (Path.build generated_dune_file))
    then
      User_error.raise
        ~loc:(Loc.in_file (Path.source file))
        [ Pp.textf
            "%s failed to produce a valid dune file."
            (Path.Source.to_string_maybe_quoted file)
        ; Pp.textf "Did you forgot to call [Jbuild_plugin.V*.send]?"
        ];
    Path.build generated_dune_file
    |> Io.Untracked.with_lexbuf_from_file ~f:(Dune_lang.Parser.parse ~mode:Many)
    |> List.rev_append from_parent
    |> parse ~file:(Some file) ~eval
  ;;
end

let check_dynamic_stanza =
  (* CR-rgrinberg: unfortunately this needs to kept in sync with the rules
     manually *)
  let err = [ Pp.text "This stanza cannot be generated dynamically" ] in
  fun stanza ->
    match Stanza.repr stanza with
    | Install_conf.T { section = loc, Section Bin; _ } ->
      User_error.raise ~loc [ Pp.text "binary section cannot be generated dynamically" ]
    | Coq_stanza.Theory.T { buildable = { Coq_stanza.Buildable.loc; _ }; _ }
    | Library.T { buildable = { loc; _ }; _ }
    | Install_conf.T { section = _, Site { loc; _ }; _ }
    | Executables.T
        { buildable = { loc; _ }; install_conf = Some { section = _, Section Bin; _ }; _ }
    | Deprecated_library_name.T { Library_redirect.loc; _ }
    | Plugin.T { site = loc, (_, _); _ } -> User_error.raise ~loc err
    | _ -> ()
;;

module Eval = struct
  type script =
    | Literal of eval * t * (Loc.t * string) list
    | Script of Script.t

  open Memo.O

  let context_independent ~eval dune_file =
    let file = Dune_file0.path dune_file in
    let static = Dune_file0.get_static_sexp dune_file in
    match Dune_file0.kind dune_file with
    | Plain ->
      let+ dune_file, dynamic_includes = parse static ~file ~eval in
      Literal (eval, dune_file, dynamic_includes)
    | Ocaml_script ->
      Memo.return
        (Script
           { eval
           ; file =
               (* we can't introduce ocaml syntax with [(sudir ..)] *)
               Option.value_exn file
           ; from_parent = static
           })
  ;;

  let rec collect_dynamic_includes (eval : eval) include_context origin dynamic_includes =
    Memo.List.concat_map dynamic_includes ~f:(fun (loc, include_file) ->
      Memo.push_stack_frame
        ~human_readable_description:(fun () ->
          Pp.textf
            "dynamic_include %s in directroy %s"
            (Include_stanza.file_path include_context loc include_file
             |> Path.build
             |> Path.drop_optional_build_context
             |> Path.to_string_maybe_quoted)
            (Path.Source.to_string_maybe_quoted eval.dir))
        (fun () ->
          let* ast, include_context =
            Include_stanza.load_sexps ~context:include_context (loc, include_file)
          in
          let* stanzas, dynamic_includes = parse_stanzas ast ~file:None ~eval in
          let+ dynamic =
            collect_dynamic_includes eval include_context origin dynamic_includes
          in
          List.rev_append stanzas dynamic))
  ;;

  let set_dynamic_stanzas t ~context ~eval ~dynamic_includes =
    let stanzas =
      match dynamic_includes with
      | [] -> Memo.Lazy.of_val t.static_stanzas
      | _ :: _ ->
        Memo.lazy_
        @@ fun () ->
        let+ stanzas =
          let origin =
            Path.Build.append_source
              (Context_name.build_dir context)
              (Path.Source.relative eval.dir Dune_file0.fname)
          in
          let include_context = Include_stanza.in_build_file origin in
          collect_dynamic_includes eval include_context origin dynamic_includes
        in
        List.iter stanzas ~f:check_dynamic_stanza;
        t.static_stanzas @ stanzas
    in
    { t with stanzas }
  ;;

  let eval dune_files mask =
    let mask = Mask.of_only_packages_mask mask in
    (* CR-rgrinberg: all this evaluation complexity is to share
       some work in multi context builds. Is it worth it? *)
    let+ dune_syntax, ocaml_syntax =
      Appendable_list.to_list dune_files
      |> Memo.parallel_map ~f:(fun (dir, project, dune_file) ->
        let mask = Mask.combine mask (Mask.ignore_promote project) in
        let eval = { dir; project; mask } in
        context_independent ~eval dune_file)
      >>| List.partition_map ~f:(function
        | Literal (eval, t, dynamic_includes) -> Left (eval, t, dynamic_includes)
        | Script s -> Right s)
    in
    fun context ->
      let set_dynamic_stanzas = set_dynamic_stanzas ~context in
      let+ ocaml_syntax =
        Memo.parallel_map ocaml_syntax ~f:(fun script ->
          let+ dune_file, dynamic_includes = Script.eval_one ~context script in
          set_dynamic_stanzas dune_file ~eval:script.eval ~dynamic_includes)
      in
      let dune_syntax =
        List.map dune_syntax ~f:(fun (eval, t, dynamic_includes) ->
          set_dynamic_stanzas t ~eval ~dynamic_includes)
      in
      dune_syntax @ ocaml_syntax
  ;;
end

let eval = Eval.eval