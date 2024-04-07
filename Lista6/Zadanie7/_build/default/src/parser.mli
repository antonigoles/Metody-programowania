
(* The type of tokens. *)

type token = 
  | TRUE
  | TIMES
  | THEN
  | RPAREN
  | PLUS
  | NEQ
  | MINUS
  | LPAREN
  | LEQ
  | LE
  | INT of (int)
  | IF
  | GR
  | GEQ
  | FALSE
  | EQ
  | EOF
  | ELSE
  | DIV

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val prog: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Ast.expr)
