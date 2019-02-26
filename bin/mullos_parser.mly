(* Copyright (C) 2018-2019 Takezoe,Tomoaki <tomoaki@res.ac>
 *
 * SPDX-Identifier: LGPL-3.0-or-later
 *)
%{

open Mullos_aux
open Mullos_syntax

%}

%token AMPERSAND
%token AND
%token ASTERISK
%token AT
%token BIGBIG_COLON
%token BIG_AMPERSAND
%token BIG_COLON
%token BIG_DOT
%token BIG_EQ
%token BIG_GREATER
%token BIG_HYPHEN
%token BIG_LESS
%token BIG_PLUS
%token BIG_VERTICAL
%token <bool> BOOL
%token CASE
%token CATCH
%token CIRCUMFLEX
%token CLASS
%token COLON
%token COLON_EQ
%token COLON_HYPHEN
%token COLON_HYPHEN_COLON
%token COLON_PLUS
%token COLON_PLUS_COLON
%token COMMA
%token DEF
%token DERIVING
%token DOLLAR
%token DOT
%token EFFECT
%token ELSE
%token END
%token EOF
%token EQ
%token EQ_GREATER
%token EXCEPTION
%token EXCLAMATION
%token EXCLAMATION_EQ
%token EXTERNAL
%token FN
%token GREATER
%token HYPHEN
%token HYPHEN_COLON
%token HYPHEN_EQ
%token HYPHEN_GREATER
%token <string> IDENTIFIER
%token IF
%token INSTANCE
%token INTERNAL
%token LAZY
%token LCBRACKET
%token LBRACKET
%token LBRACKET_VERTICAL
%token LESS
%token LET
%token LOWLINE
%token LPAREN
%token MATCH
%token MODULE
%token MUTABLE
%token NL
%token <Mullos_syntax.number> NUMBER
%token NUMBERSIGN
%token NUMBERSIGN_EXCLAMATION_LBRACKET
%token NUMBERSIGN_LBRACKET
%token PERCENT
%token PLUS
%token PLUS_COLON
%token PLUS_EQ
%token QUESTION
%token RAISE
%token RBRACKET
%token RCBRACKET
%token REC
%token RPAREN
%token SEMI
%token SINGLETON
%token SOLIDUS
%token <string> TEXT
%token THEN
%token TILDE
%token TRAIT
%token TYPE
%token UNSAFE
%token VAL
%token VERTICAL
%token VERTICAL_GREATER
%token VERTICAL_RBRACKET
%token WHEN
%token WHERE
%token WITH

%start<unit> compilation_unit

%%

compilation_unit: definition_list  EOF { () }

%inline
semi:
  | NL { () }
  | SEMI { () }

long_id:
  IDENTIFIER BIG_COLON long_id { $1 :: $3 }
  | IDENTIFIER { [$1] }

seq:
  | expression semi seq { $1 :: $3 }
  | expression { [$1] }

%inline
bin_op:
   | PLUS { `Add }
   | HYPHEN { `Substract }
   | ASTERISK { `Multiply }
   | SOLIDUS  { `Division }
   | CIRCUMFLEX  { `Xor }
   | PERCENT { `Reminder }
   | BIG_LESS { `BitwiseLeftShift }
   | BIG_GREATER { `BitwiseRightShift }
   | LESS { `Less }
   | GREATER { `Greater }
   | EXCLAMATION_EQ { `NotEqual }
   | AMPERSAND { `BitwiseAnd }
   | BIG_AMPERSAND { `And }
   | VERTICAL { `BitwiseOr }
   | BIG_VERTICAL { `Or }
   | BIG_EQ { `Equal }
   | PLUS_EQ { `AddAsign }
   | HYPHEN_EQ { `SubstractAsign }
   | COLON_EQ { `Asign }
   | BIG_PLUS { `Combine }
   | BIG_HYPHEN { `Remove }
   | BIG_COLON { `Cons }

expression:
  | IF expression THEN expression ELSE expression { IfThenElse ($2, $4, Some $6) }
  | IF expression THEN expression END { IfThenElse ($2, $4, None) }
  | MATCH lhs=expression WITH rhs=pattern_clause+ END { Match (lhs, rhs) }
  | FN pattern HYPHEN_GREATER expression { Lambda ($2, $4) }
  | LET simple_pattern EQ expression semi expression { Let ($2, [], $4, $6) }
  | LET REC simple_pattern EQ expression list(AND simple_pattern EQ expression{ failwith "not implemented" }) semi expression { failwith "not implemented" }
  | assignment_expression { $1 }
  | LBRACKET separated_list(SEMI, expression) RBRACKET { failwith "not implemented" }
  | LBRACKET_VERTICAL separated_list(SEMI, expression) VERTICAL_RBRACKET { failwith "not implemented" }
  | MUTABLE LBRACKET_VERTICAL separated_list(SEMI, expression) VERTICAL_RBRACKET { failwith "not implemented" }

assignment_expression: assignment_expression binop_assignment pipeline_expression { failwith "not implemented" } | pipeline_expression { $1 }
%inline
binop_assignment:
  | PLUS_EQ { `AddAsign }
  | HYPHEN_EQ { `SubstractAsign }
  | COLON_EQ { `Asign }

pipeline_expression: dollar_expression VERTICAL_GREATER pipeline_expression { failwith "not implemented" } | dollar_expression { $1 }

dollar_expression: dollar_expression DOLLAR tuple_expression { failwith "not implemented" } | tuple_expression { $1 }

tuple_expression: lor_expression nonempty_list(COMMA lor_expression { failwith "not implemented" }) { failwith "not implemented" } | lor_expression { $1 }

lor_expression: lor_expression BIG_VERTICAL land_expression { failwith "not implemented" } | land_expression { $1 }

land_expression: land_expression BIG_AMPERSAND bitwise_or_expression { failwith "not implemented" } | bitwise_or_expression { $1 }

bitwise_or_expression: bitwise_or_expression VERTICAL xor_expression { failwith "not implemented" } | xor_expression { $1 }

xor_expression: xor_expression CIRCUMFLEX bitwise_and_expression { failwith "not implemented" } | bitwise_and_expression { $1 }

bitwise_and_expression: bitwise_and_expression AMPERSAND equal_expression { failwith "not implemented" } | equal_expression { $1 }

equal_expression: equal_expression binop_equal greater_expression { failwith "not implemented" } | greater_expression { $1 }
%inline
binop_equal:
  | EXCLAMATION_EQ { `NotEqual }
  | BIG_EQ { `Equal }

greater_expression: greater_expression binop_greater shift_expression { failwith "not implemented" } | shift_expression { $1 }
%inline
binop_greater:
  | LESS { `Less }
  | GREATER { `Greater }

shift_expression: shift_expression binop_shift cons_expression { failwith "not implemented" } | cons_expression { $1 }
%inline
binop_shift:
  | BIG_LESS { `BitwiseLeftShift }
  | BIG_GREATER { `BitwiseRightShift }

cons_expression: add_expression binop_cons cons_expression { failwith "not implemented" } | add_expression { $1 }
%inline
binop_cons:
   | COLON_PLUS { failwith "not implemented" }
   | COLON_HYPHEN { failwith "not implemented" }
   | COLON_PLUS_COLON { failwith "not implemented" }
   | COLON_HYPHEN_COLON { failwith "not implemented" }

add_expression: add_expression binop_add multiply_expression { failwith "not implemented" } | multiply_expression { $1 }
%inline
binop_add:
  | PLUS { `Add }
  | HYPHEN { `Substract }
  | PLUS_COLON { failwith "not implemented" }
  | HYPHEN_COLON { failwith "not implemented" }

multiply_expression: multiply_expression binop_multiply prefix_expression { failwith "not implemented" } | prefix_expression { $1 }
%inline
binop_multiply:
  | ASTERISK { `Multiply }
  | SOLIDUS  { `Division }
  | PERCENT { `Reminder }

prefix_expression: prefix_op postfix_expression { failwith "not implemented" } | postfix_expression { $1 }
%inline
prefix_op:
  | PLUS { failwith "not implemented" }
  | HYPHEN { failwith "not implemented" }
  | EXCLAMATION { failwith "not implemented" }
  | AMPERSAND { failwith "not implemented" }
  | ASTERISK { failwith "not implemented" }
  | BIG_PLUS { failwith "not implemented" }
  | BIG_HYPHEN { failwith "not implemented" }

postfix_expression: application_expression postfix_op { failwith "not implemented" } | application_expression { $1 }
%inline
postfix_op:
  | BIG_PLUS { failwith "not implemented" }
  | BIG_HYPHEN { failwith "not implemented" }

application_expression: application_expression dot_expression { Apply ($1, $2) } | dot_expression { $1 }

dot_expression: dot_expression DOT simple_expression { BinOp ($1, `Dot, $3, []) } | simple_expression { $1 }

simple_expression:
  | IDENTIFIER { Identifier $1 }
  | LPAREN RPAREN { Unit }
  | LCBRACKET seq RCBRACKET { Seq $2 }
  | TEXT { Text $1 }
  | NUMBER { Number $1 }
  | BOOL { Bool $1 }
  | LPAREN expression RPAREN { $2 }

pattern_clause:
  | CASE pat=pattern_or_clause cond=pattern_condition? EQ_GREATER exp=expression { MatchPat (pat, cond, exp) }
  | CASE EXCEPTION pat=pattern_or_clause cond=pattern_condition? EQ_GREATER exp=expression { MatchException (pat, cond, exp) }
  | CASE EFFECT pat=pattern_or_clause cond=pattern_condition? EQ_GREATER exp=expression { MatchEffect (pat, cond, exp) }

pattern_or_clause:
  | pattern { $1 }
  | pattern VERTICAL pattern_or_clause { POr ($1, $3) }

pattern_condition: WHEN expression { $2 }

%inline
pattern_op:
  | COMMA { `Comma }
  | AT { `At }

pattern:
  | IDENTIFIER pattern { PCtor ($1, $2) }
  | simple_pattern COLON simple_or_paren_type_expression { failwith "not implemented" }
  | simple_pattern pattern_op pattern { failwith "not implemented" }
  | LBRACKET separated_list(SEMI, pattern) RBRACKET { failwith "not implemented" }
  | LBRACKET_VERTICAL separated_list(SEMI, pattern) VERTICAL_RBRACKET { failwith "not implemented" }
  | MUTABLE LBRACKET_VERTICAL separated_list(SEMI, pattern) VERTICAL_RBRACKET { failwith "not implemented" }
  | simple_pattern { $1 }

ident_pattern:
  | IDENTIFIER { PIdent $1 }

simple_pattern:
  | ident_pattern { $1 }
  | LPAREN RPAREN { PUnit }
  | LPAREN pattern RPAREN { $2 }
  | LOWLINE { PWildcard }
  | TEXT { PText $1 }
  | NUMBER { PNumber $1 }
  | BOOL { PBool $1 }
  | LAZY simple_pattern { PLazy $2 }

type_binary_op:
  | COMMA { TComma }
  | HYPHEN_GREATER { TArrow }

type_expression:
  | most_type_expression { $1 }
  | paren_type_expression { $1 }

paren_type_expression:
  | LPAREN type_expression RPAREN { $2 }

 simple_or_paren_type_expression:
  | LPAREN type_expression RPAREN { $2 }
  | simple_type_expression { $1 }

most_type_expression:
  | simple_type_expression { $1 }
  | simple_or_paren_type_expression type_binary_op most_type_expression {
        match $3 with
        | TBinOp (lhs, op, rhs, tail) -> TBinOp ($1, $2, lhs, (op, rhs) :: tail)
        | _ -> TBinOp ($1, $2, $3, [])
      }
  | simple_or_paren_type_expression most_type_expression {
        match $2 with
        | TBinOp (lhs, op, rhs, tail) -> TBinOp ($1, TApply, lhs, (op, rhs) :: tail)
        | _ -> TBinOp ($1, TApply, $2, [])
      }
  | simple_or_paren_type_expression type_binary_op paren_type_expression { TBinOp ($1, $2, $3, []) }
  | simple_or_paren_type_expression paren_type_expression { TBinOp ($1, TApply, $2, []) }
  | simple_or_paren_type_expression LBRACKET effect_expression RBRACKET { TEff ($1, $3) }
  | LAZY type_expression { TLazy $2 }

simple_type_expression:
  | ident_type { $1 }
  | NUMBER { TNumber $1 }
  | TEXT { TText $1 }
  | BOOL { TBool $1 }

ident_type:
  | long_id { TIdent $1 }

effect_expression:
  ident_effect { ETy $1 }
  | LOWLINE { EWildcard }

ident_effect:
  ident_type { [$1] }
  | ident_type BIG_PLUS ident_effect { $1 :: $3 }

type_definition:
  | TYPE name=IDENTIFIER params=IDENTIFIER* deriving=deriving_clause? EQ body=type_definition_body { VariantDef (name, List.map (fun x -> TVar x) params, deriving, body) }

type_definition_body:
  | nonempty_list(VERTICAL variant_constructor { $2 }) { Variant $1 }
  | BIG_DOT { ExtensibleVariant }

variant_constructor:
  | name=IDENTIFIER COLON param=simple_or_paren_type_expression { name, Some param }
  | name=IDENTIFIER { name, None }

deriving_clause: DERIVING deriving_clause_body { $2 : ty list }

deriving_clause_body:
  | long_id { [TIdent $1] }
  | long_id COMMA deriving_clause_body { TIdent $1 :: $3 }

extensible_variant_definition: TYPE name=IDENTIFIER PLUS_EQ ctor=variant_constructor { ExtensibleVariantDef (name, ctor) }

module_parameter:
  | IDENTIFIER { failwith "not implemented" }
  | LPAREN IDENTIFIER COLON IDENTIFIER { failwith "not implemented" }

module_definition: MODULE name=IDENTIFIER separated_list(COMMA, module_parameter)
  impl=impl_clause LBRACKET defs=definition_list RBRACKET { ModuleDef (false, name, impl, defs) }

singleton_definition: SINGLETON name=IDENTIFIER impl=impl_clause LBRACKET defs=definition_list RBRACKET { ModuleDef (true, name, impl, defs) }

trait_definition: TRAIT name=IDENTIFIER params=IDENTIFIER* impl=impl_clause LBRACKET defs=definition_list RBRACKET { TraitDef (name, params, impl, defs) }

impl_clause:
  | { [] }
  | COLON impl { $2 }

impl:
  | ident_type+ { [$1] }
  | ident_type+ COMMA impl { $1 :: $3 }

val_definition: VAL name=IDENTIFIER COLON ty=type_expression { ValDef (name, ty) }

top_level_let_body: IDENTIFIER simple_pattern* EQ expression { failwith "not implemented" }
top_level_let: LET top_level_let_body { failwith "not implemented" }
top_level_letrec: LET REC top_level_let_body top_level_and* { failwith "not implemented" }
top_level_and: AND top_level_let_body { failwith "not implemented" }

definition:
  | val_definition { $1 }
  | type_definition { $1 }
  | extensible_variant_definition { $1 }
  | module_definition { $1 }
  | singleton_definition { $1 }
  | trait_definition { $1 }
  | top_level_let { $1 }
  | top_level_letrec { $1 }

definition_list:
  | definition definition_list { $1 :: $2 }
  | definition { [$1] }

