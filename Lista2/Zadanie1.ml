let rec fib x = if x <= 1 then x else (fib (x-1)) + (fib (x-2));;
let rec __fib_iter n a b = if n <= 0 then b else (__fib_iter (n-1) (a+b) a);;
let rec fib_iter n = (__fib_iter n 1 0);;

fib 1;;
fib 2;;
fib_iter 723213;;