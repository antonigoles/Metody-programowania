let empty_set = (fun a -> false);;

let singleton a = (fun x -> x = a );;

let in_set a s = s a;;

let union s t = (fun a -> (s a) || (t a) );;

let intersect s t = (fun a -> (s a) && (t a) );;

intersect (singleton 2) (singleton 3) 2;;
union (singleton 2) (singleton 3) 2;;
intersect (singleton 3) (singleton 3) 2;;