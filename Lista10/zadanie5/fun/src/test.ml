open Main;;

let program = "let next = let x = ref 0 in fun y -> x := ! x + 1; ! x in (next 0) + (next 0)";;
let test_1_result = parse program;;

(* let data1 = Fun.Ast.Let ("next",
 Fun.Ast.Let ("x", Fun.Ast.Ref (Fun.Ast.Int 0),
  Fun.Ast.Fun ("y",
   Fun.Ast.RefAssignDeRef (Fun.Ast.Var "x",
    Fun.Ast.DeRef (Fun.Ast.Binop (Fun.Ast.Add, Fun.Ast.Var "x", Fun.Ast.Int 1)),
    Fun.Ast.DeRef (Fun.Ast.Var "x")))),
 Fun.Ast.Binop (Fun.Ast.Add, Fun.Ast.App (Fun.Ast.Var "next", Fun.Ast.Int 0),
  Fun.Ast.App (Fun.Ast.Var "next", Fun.Ast.Int 0)));; *)
(*   
Fun.Ast.Let ("next",
  Fun.Ast.Let ("x", Fun.Ast.Ref (Fun.Ast.Int 0),
   Fun.Ast.Fun ("y",
    Fun.Ast.RefAssignDeRef (Fun.Ast.Var "x",
     Fun.Ast.Binop (Fun.Ast.Add, Fun.Ast.DeRef (Fun.Ast.Var "x"), Fun.Ast.Int 1),
     Fun.Ast.DeRef (Fun.Ast.Var "x")))),
  Fun.Ast.Binop (Fun.Ast.Add, Fun.Ast.App (Fun.Ast.Var "next", Fun.Ast.Int 0),
   Fun.Ast.App (Fun.Ast.Var "next", Fun.Ast.Int 0))) *)


let test_2_result = interp program;;