let matrix_mult m n = 
  let (a1, a2, a3, a4) = m in 
  let (b1, b2, b3, b4) = n in
  (
    a1*b1+a2*b3, a1*b2+a2*b4, 
    a3*b1+a4*b3, a3*b2+a4*b4
  );;

let rec matrix_expt_fast m k = 
  if k == 1
    then m
  else if k == 2
    then matrix_mult m m 
  else matrix_mult (matrix_expt_fast m (k/2)) (matrix_expt_fast m (k-(k/2)));;

matrix_expt_fast (1,1,1,0) 123232;;