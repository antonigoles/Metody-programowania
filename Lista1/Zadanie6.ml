let rec f () = f ();;

let test x y = if x = 0 then 0 else y;;


(*

Dowód na to że używa gorliwych:
po odpaleniu kod zatrzymuje się w miejscu, 
czyli rekurencja f() idzie w nieskończność

*)

test 0 (f ());;