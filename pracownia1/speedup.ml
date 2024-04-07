let ( let* ) xs ys = List.concat_map ys xs

let rec choose m n =
  if m > n then [] else m :: choose (m+1) n;;

let rec fill t n = if n <= 0 then [] else t :: (fill t (n-1));;

let rec choose_fill bn n = 
  let* a = choose 0 (n-bn) in
  [(fill false a) @ (fill true bn) @ (fill false ((n-bn)-a))];;

let rec half_fill f t = (fill false f) @ (fill true t)

let rec min_required_space = function
  | [] -> 0
  | x :: [] -> x
  | x :: xs -> x + 1 + (min_required_space xs);;

let rec compare_int_lists xs ys = 
  match xs,ys with
  | [], [] -> 0
  | [], y :: ys -> 1
  | x :: xs, [] -> -1
  | x :: xs, y :: ys -> 
    if x > y then -1
    else if x < y then 1
    else compare_int_lists xs ys;; 

let rec build_row_with_repetitions ps n = 
  match ps with 
  | [] -> [fill false n]
  | x :: [] -> (let* a = choose_fill x n in [a])
  | x :: xs ->
    let mrs = min_required_space xs in 
    let* a = choose x (n-mrs) in
    let* b = choose_fill x a in
    let* c = build_row_with_repetitions xs (n-a-1) in
    [b @ [false] @ c];;

let rec build_row ps n = List.sort_uniq compare_int_lists (build_row_with_repetitions ps n);;

(* build_row [2;2] 6;; *)

let rec build_candidate pss n = 
  match pss with 
  | [] -> []
  | x :: [] -> let* a = build_row x n in [[a]]
  | x :: xs -> 
    let* a = build_row x n in
    let* b = build_candidate xs n in
    [a :: b];;


let rec cound_trues = function 
  | [] -> 0
  | x :: xs -> if x then 1 + cound_trues xs else cound_trues xs;;

let rec count_true_blocks xs = 
  let rec __count_true_blocks acc facc = function
    | [] -> if acc > 0 then facc @ [acc] else facc
    | x :: xs -> 
      if x then __count_true_blocks (acc+1) facc xs 
      else 
        if acc > 0 then __count_true_blocks 0 (facc@[acc]) xs
        else __count_true_blocks 0 facc xs
  in __count_true_blocks 0 [] xs;;

let verify_row ps xs = (ps = (count_true_blocks xs))

let rec verify_rows pss xss = 
  match pss with 
  | [] -> true
  | ps :: pss -> 
    match xss with
    | [] -> true
    | xs :: xss -> (verify_row ps xs) && (verify_rows pss xss);;
    

let rec list_remove_first = function
  | [] -> []
  | xs -> List.tl xs;;

let rec remove_first_column = function 
  | [] -> []
  | xs :: xss -> 
    match xs with
    | [] -> []
    | xs :: [] -> [] 
    | xs -> (list_remove_first xs) :: remove_first_column xss;;

let rec first_column = function 
  | [] -> []
  | xs :: xss -> (List.hd xs) :: first_column xss;;

let rec transpose = function 
  | [] -> []
  | xss -> (first_column xss) :: (xss |> remove_first_column |> transpose);;


type nonogram_spec = {rows: int list list; cols: int list list}


let solve_nonogram nono =
  build_candidate (nono.rows) (List.length (nono.cols))
  |> List.filter (fun xss -> transpose xss |> verify_rows nono.cols)


let example_1 = {
  rows = [[2];[1];[1]];
  cols = [[1;1];[2]]
}


let example_2 = {
  rows = [[2];[2;1];[1;1];[2]];
  cols = [[2];[2;1];[1;1];[2]]
}

let big_example = {
  rows = [[1;2];[2];[1];[1];[2];[2;4];[2;6];[8];[1;1];[2;2]];
  cols = [[2];[3];[1];[2;1];[5];[4];[1;4;1];[1;5];[2;2];[2;1]]
};;

let mid_example = {
  rows = [[1];[1];[1];[1];[1];[1];[1];[1];[1]];
  cols = [[1];[1];[1];[1];[1];[1];[1];[1];[1]]
};;

let rec string_of_row = function
  | [] -> ""
  | x :: xs -> (if x then "X" else " ") ^ (string_of_row xs);;

let rec string_of_candidate = function 
  | [] -> ""
  | x :: xs -> (string_of_row x) ^ "\n" ^ (string_of_candidate xs);;


let test_cases = [
  (* Simple 5x5 nonogram *)
  {rows = [[1]; [3]; [5]; [3]; [1]];
   cols = [[1]; [3]; [5]; [3]; [1]]};

  (* Larger 10x10 nonogram *)
  {rows = [[2;2]; [1;1]; [3]; [2]; [2]; [4]; [2]; [2]; [1;1]; [2;2]];
   cols = [[1;1]; [3]; [5]; [1;1]; [1;1]; [5]; [2]; [2]; [3]; [1;1]]};

  (* Nonogram with a hole in the middle *)
  {rows = [[1]; [1]; [3]; [1]; [1]];
   cols = [[1]; [1]; [3]; [1]; [1]]};

  (* Nonogram with larger numbers *)
  {rows = [[5]; [4]; [3;1]; [2;1]; [2;1]; [3;1]; [4]; [5]];
   cols = [[5]; [4]; [3;1]; [2;1]; [2;1]; [3;1]; [4]; [5]]};

  (* Nonogram with varying row and column lengths *)
  {rows = [[2;1]; [3]; [4]; [3]; [2;1]; [3]; [4]; [3]; [2;1]];
   cols = [[1]; [2;1]; [3]; [4]; [3]; [2;1]; [3]; [4]; [3]]}
];;

let build_only nono =
  build_candidate (nono.rows) (List.length (nono.cols));;

(* build_only (List.nth test_cases 4);; *)
(* solve_nonogram (List.nth test_cases 4);; *)



let rec generate_n_sized_nonogram n = 
    let join_nonogram na nb = ({ 
    rows = (na.rows @ nb.rows); 
    cols = (na.cols @ nb.cols)
  }) in
  if n < 1 then { rows = [[n]]; cols = [[n]] } 
  else join_nonogram ({ rows = [[n]]; cols = [[n]] }) (generate_n_sized_nonogram (n-1));;

(* solve_nonogram { 
  rows = [[1];[2];[3]];
  cols = [[1];[2];[3]];
};; *)

(* (generate_n_sized_nonogram 5);; *)

let time f x =
  let t = Sys.time() in
  let fx = f x in
  Printf.printf "Execution time: %fs\n" (Sys.time() -. t);
  fx;;

(* time solve_nonogram (generate_n_sized_nonogram 1);;
time solve_nonogram (generate_n_sized_nonogram 2);;
time solve_nonogram (generate_n_sized_nonogram 3);; *)
(* time solve_nonogram (generate_n_sized_nonogram 4);;
time solve_nonogram (generate_n_sized_nonogram 5);;
time solve_nonogram (generate_n_sized_nonogram 6);;
time solve_nonogram (generate_n_sized_nonogram 7);;
time solve_nonogram (generate_n_sized_nonogram 8);; 
time generate_n_sized_nonogram 9;; *)

(* time solve_nonogram { 
  rows = [[1]; [5]; [2]; [5]; [2;1]; [2] ]; 
  cols = [[2; 1]; [1; 3]; [1; 2]; [3]; [4]; [1]] 
};; *)


(* 
List.sort_uniq (fun a -> fun b -> (compare_lists a b)) (solve_nonogram example_1);; *)