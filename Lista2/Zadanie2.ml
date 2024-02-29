let matrix_id = (1,0,0,1);;

let matrix_mult m n = 
  let (a1, a2, a3, a4) = m in 
  let (b1, b2, b3, b4) = n in
  (
    a1*b1+a2*b3, a1*b2+a2*b4, 
    a3*b1+a4*b3, a3*b2+a4*b4
  );;

let rec __matrix_expt m a k = 
  if k <= 1 
    then m 
  else (__matrix_expt (matrix_mult m a) a (k-1) );; 

let rec matrix_expt m k = __matrix_expt m m k;;

let rec fib_matrix n = let (_, a, _, _) = (matrix_expt (1,1,1,0) n) in a;;

matrix_mult matrix_id matrix_id;;
matrix_mult (2, 3, 4, 5) matrix_id;;
matrix_mult (2, 3, 4, 5) (2, 3, 4, 5);;
matrix_expt (2, 3, 4, 5) 3;;
fib_matrix 41;;