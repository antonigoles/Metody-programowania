type 'a symbol =
  | T of string (* symbol terminalny *)
  | N of 'a (* symbol nieterminalny *)

type 'a grammar = ('a * ('a symbol list ) list ) list;;

let expr : unit grammar =
[
  ((), 
  [
    [ N (); T "+" ; N ()];
    [ N (); T "*" ; N ()];
    [ T "(" ; N (); T ")" ];
    [ T "1" ];
    [ T "2" ]
  ]);
];;

let randomelement ls = let n = (Random.int (List.length ls)) in List.nth ls n;; 

let rec join seperator = function
  | [] -> ""
  | x :: xs -> x ^ seperator ^ (join seperator xs) 

let rec generate (gram: 'a grammar) (a: 'a) = 
  let os = (List.assoc a gram) in 
  let rule = randomelement os
  in (join "" (List.map 
  (fun x -> 
    match x with 
    | N b -> (generate gram b)
    | T b -> b
  ) 
  rule));;


generate expr ();;
generate expr ();;
generate expr ();;
generate expr ();;
generate expr ();;

let pol : string grammar =
  [ "zdanie" , [[ N "grupa-podmiotu" ; N "grupa-orzeczenia" ]]
  ; "grupa-podmiotu" , [[ N "przydawka" ; N "podmiot" ]]
  ; "grupa-orzeczenia" , [[ N "orzeczenie" ; N "dopelnienie" ]]
  ; "przydawka" , [[ T "Piekny " ];
                  [ T "Bogaty " ];
                  [ T "Wesoly " ]]
  ; "podmiot" , [[ T "policjant " ];
                [ T "student " ];
                [ T "piekarz " ]]
  ; "orzeczenie" , [[ T "zjadl " ];
                    [ T "pokochal " ];
                    [ T "zobaczyl " ]]
  ; "dopelnienie" , [[ T "zupe." ];
                    [ T "studentke." ];
                    [ T "sam siebie." ];
                    [ T "instytut informatyki." ]]
];;

generate pol "zdanie";;
generate pol "zdanie";;
generate pol "zdanie";;
generate pol "zdanie";;
