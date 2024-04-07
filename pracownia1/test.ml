#use "speedup.ml";;

let println str = print_string (str ^ "\n");;

let rec string_of_int_list = function
  | [] -> ""
  | x :: xs -> (string_of_int x) ^ ", " ^ (string_of_int_list xs);;

let rec string_of_bool_list = function
  | [] -> ""
  | x :: xs -> (string_of_bool x) ^ ", " ^ (string_of_bool_list xs);;

let rec string_of_int_list_list = function 
  | [] -> ""
  | x :: xs -> " [ " ^ (string_of_int_list x) ^ " ], \n" ^ (string_of_int_list_list xs);;

let rec string_of_bool_list_list = function 
  | [] -> ""
  | x :: xs -> " [ " ^ (string_of_bool_list x) ^ " ], \n" ^ (string_of_bool_list_list xs);;

let rec string_of_bool_list_list_list = function 
  | [] -> ""
  | x :: xs -> "[ " ^ (string_of_bool_list_list x) ^ " ], \n" ^ (string_of_bool_list_list_list xs);;

println "* Section 1";;
println (string_of_int_list (choose 0 5));;
println (string_of_int_list (fill 0 5));;


println "* Section 2";;
println (string_of_int (min_required_space [2;3]));;
(* Example solution: XXOXXX so the minimum space should be 6 *)
println (string_of_int (min_required_space [2]));;
(* Example solution: XX so the minimum space should be 2 *)
println (string_of_int (min_required_space [2;3;1]));;
(* Example solution: XXOXXXOX so the minimum space should be 8 *)

println "* Section 3";;
println (string_of_bool_list_list (choose_fill 2 3));;
println (string_of_bool_list_list (choose_fill 1 4));; 
(* works *)

println "* Section 4";;
println ("1)\n" ^ (string_of_bool_list_list (build_row [2; 1] 4)));;
println ("2)\n" ^ (string_of_bool_list_list (build_row [2; 1] 5)));;
(* The rows repeat for some reason; if no other problems will be found I should fix that *)

(* println "* Section 5";;
println (string_of_bool_list_list_list (build_candidate [[2; 1];[1];[1]] 5));;
(* This of course will have the same issue as build_row function *)

println "* Section 6";;
println (string_of_int (cound_trues [true;false;true]));;
println (string_of_int (cound_trues [true;false;true]));;
println (string_of_int (cound_trues [false;false;false]));;
println (string_of_int (cound_trues [false]));;
println (string_of_int (cound_trues [true]));;
println (string_of_int (cound_trues []));;
(* Works exactly as expected *)

println "* Section 7";;
println (string_of_int_list (count_true_blocks [true;false;true;true;false]));;
(* [1;2] *)
println (string_of_int_list (count_true_blocks []));;
(* [] *)
println (string_of_int_list (count_true_blocks [false;false;false]));;
(* [] *)
println (string_of_int_list (count_true_blocks [true;true;true;true]));;
(* [4] *)

println "* Section 8";;
println (string_of_bool (verify_row [1;2] [true;false;true;true;false]));;
(* true *)
println (string_of_bool (verify_row [] [true;false;true;true;false]));;
(* false *)
println (string_of_bool (verify_row [8] [true;true;true;true;false;false;false;false;true]));;
(* false *)

println "* Section 9";;
println (string_of_int_list_list (transpose [[1;2;3];[4;5;6];[7;8;9];[10;11;12]]));;
println (string_of_int_list_list (transpose [[1;2;3];[4;5;6];[7;8;9]]));;
println (string_of_int_list_list (transpose [[1;2;3];[4;5;6];]));;
println (string_of_int_list_list [[1;2;3];[4;5;6]]);;
println (string_of_int_list_list (transpose [[];[]]));;
works *)


(* println "* Section 10";;
solve_nonogram  *)
