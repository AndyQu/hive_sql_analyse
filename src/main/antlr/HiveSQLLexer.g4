lexer grammar HiveSQLLexer;
@ header { 
	package hivesql.analysis.parse;
 }

SELECT
   : 'select'
   ;


FROM
   : 'from'
   ;


WHERE
   : 'where'
   ;


AND
   : 'and' | '&&'
   ;


OR
   : 'or' | '||'
   ;


XOR
   : 'xor'
   ;


IS
   : 'is'
   ;


NULL
   : 'null'
   ;


LIKE
   : 'like'
   ;


IN
   : 'in'
   ;


EXISTS
   : 'exists'
   ;


ALL
   : 'all'
   ;


ANY
   : 'any'
   ;


TRUE
   : 'true'
   ;


FALSE
   : 'false'
   ;


DIVIDE
   : 'div' | '/'
   ;


MOD
   : 'mod' | '%'
   ;


BETWEEN
   : 'between'
   ;


REGEXP
   : 'regexp'
   ;


PLUS
   : '+'
   ;


MINUS
   : '-'
   ;


NEGATION
   : '~'
   ;


VERTBAR
   : '|'
   ;


BITAND
   : '&'
   ;


POWER_OP
   : '^'
   ;


BINARY
   : 'binary'
   ;


SHIFT_LEFT
   : '<<'
   ;


SHIFT_RIGHT
   : '>>'
   ;


ESCAPE
   : 'escape'
   ;


ASTERISK
   : '*'
   ;


RPAREN
   : ')'
   ;


LPAREN
   : '('
   ;


RBRACK
   : ']'
   ;


LBRACK
   : '['
   ;


COLON
   : ':'
   ;


ALL_FIELDS
   : '.*'
   ;

DOUBLE_EQ
	: '=='
	;

EQ
   : '='
   ;


LTH
   : '<'
   ;


GTH
   : '>'
   ;


NOT_EQ
   : '!='
   ;


NOT
   : 'not'
   ;


LET
   : '<='
   ;


GET
   : '>='
   ;


SEMI_COLON
   : ';'
   ;


COMMA
   : ','
   ;


DOT
   : '.'
   ;

SINGLE_QUOTE
	:'\''
	;
	
BACK_QUOTE
	:'`'
	;
	

COLLATE
   : 'collate'
   ;


INNER
   : 'inner'
   ;


OUTER
   : 'outer'
   ;


JOIN
   : 'join'
   ;


CROSS
   : 'cross'
   ;


USING
   : 'using'
   ;


INDEX
   : 'index'
   ;


KEY
   : 'key'
   ;


ORDER
   : 'order'
   ;


GROUP
   : 'group'
   ;


BY
   : 'by'
   ;


FOR
   : 'for'
   ;


USE
   : 'use'
   ;


IGNORE
   : 'ignore'
   ;


PARTITION
   : 'partition'
   ;


STRAIGHT_JOIN
   : 'straight_join'
   ;


NATURAL
   : 'natural'
   ;


LEFT
   : 'left'
   ;


RIGHT
   : 'right'
   ;
   
FULL
	: 'full'
	;


//OJ
//   : 'oj'
//   ;


ON
   : 'on'
   ;


AS
   : 'as'|'AS'
   ;

DISTINCT
	: 'distinct'
	;


ID
   : ('a' .. 'z' | 'A' .. 'Z' | '_') ( 'a' .. 'z' | 'A' .. 'Z' | '_' | '0' .. '9')*
   ;


INT
   : '0' .. '9'+
   ;

DOUBLE
   : '0' .. '9'+ DOT '0' .. '9'+
   ;


NEWLINE
   : '\r'? '\n' -> skip
   ;


WS
   : ( ' ' | '\t' | '\n' | '\r' )+ -> skip
   ;


USER_VAR
   : '@' ( USER_VAR_SUBFIX1 | USER_VAR_SUBFIX2 | USER_VAR_SUBFIX3 | USER_VAR_SUBFIX4 )
   ;


fragment USER_VAR_SUBFIX1
   : ( '`' ( ~ '`' )+ '`' )
   ;


fragment USER_VAR_SUBFIX2
   : ( '\'' ( ~ '\'' )+ '\'' )
   ;


fragment USER_VAR_SUBFIX3
   : ( '\"' ( ~ '\"' )+ '\"' )
   ;


fragment USER_VAR_SUBFIX4
   : ( 'A' .. 'Z' | 'a' .. 'z' | '_' | '$' | '0' .. '9' | DOT )+
   ;

/*
TODO: should support all characters
*/
STRING
   : SINGLE_QUOTE ('A' .. 'Z' | 'a' .. 'z' | '_' | '0' .. '9' | ' ' | ':' | '-')* SINGLE_QUOTE
   ;
