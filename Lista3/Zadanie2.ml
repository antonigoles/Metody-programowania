let compose f g = fun x -> f (g x);;
let square x = x * x;;
let inc x = x + 1;;

compose square inc 5;;
compose inc square 5;;
