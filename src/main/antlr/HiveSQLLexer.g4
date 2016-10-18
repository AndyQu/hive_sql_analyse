lexer grammar HiveSQLLexer;
@ header { 
	package hivesql.analysis.parse;
 }
@members {
    public static final int Channel_Comment = 1;
    public static final int Channel_Other = 2;
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
DOUBLE_QUOTE
	:'"'
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
/**
 * 优先级：OVER必须放在ID前面。否则 'over'会被优先识别为ID，而不是OVER。
 */
OVER
	: 'over'
	;

DESC
	: 'desc'
	;

ASC
	: 'asc'
	;

AS
   : 'as'|'AS'
   ;

DISTINCT
	: 'distinct'
	;

CASE
	: 'case'
	;
WHEN
	: 'when'
	;
THEN
	: 'then'
	;
ELSE
	: 'else'
	;
END
	: 'end'
	;

UNION
	: 'union'
	;

CLUSTER
	: 'cluster'
	;

DISTRIBUTE
	: 'distribute'
	;

SORT
	: 'sort'
	;

INT
   : '0' .. '9'+
   ;

DOUBLE
   : '0' .. '9'+ DOT '0' .. '9'+
   ;
   
COMMENT
	:'--' (~[\r\n])* -> channel(Channel_Comment)
	;

NEWLINE
   : '\r'? '\n' -> channel(Channel_Other)
   ;

WS
   : ( ' ' | '\t' | '\n' | '\r' )+ -> channel(3)
   ;

/**
 * ID 必须放在所有关键字后面，否则，关键字会被优先识别为ID
 */
ID 
   : ('a' .. 'z' | 'A' .. 'Z' | '_') ( 'a' .. 'z' | 'A' .. 'Z' | '_' | '0' .. '9')*
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

//TODO
/*
should support all characters
*/
//STRING
//   : SINGLE_QUOTE ('A' .. 'Z' | 'a' .. 'z' | '_' | '0' .. '9' | ' ' | ':' | '-' | '.' | '$' | '(' | ')'|COMMA)* SINGLE_QUOTE
//   ;
STRING
	:SINGLE_QUOTE_STRING|DOUBLE_QUOTE_STRING
	;
fragment
SINGLE_QUOTE_STRING
	:SINGLE_QUOTE(NameStartChar NameChar*)SINGLE_QUOTE
	;
DOUBLE_QUOTE_STRING
	:DOUBLE_QUOTE(NameStartChar NameChar*)DOUBLE_QUOTE
	;

fragment
NameChar
    :   NameStartChar
    |   '0'..'9'
    |   '_'
    |   '\u00B7'
    |   '\u0300'..'\u036F'
    |   '\u203F'..'\u2040'
    ;

fragment
NameStartChar
    :   'A'..'Z'
    |   'a'..'z'
    |   '\u00C0'..'\u00D6'
    |   '\u00D8'..'\u00F6'
    |   '\u00F8'..'\u02FF'
    |   '\u0370'..'\u037D'
    |   '\u037F'..'\u1FFF'
    |   '\u200C'..'\u200D'
    |   '\u2070'..'\u218F'
    |   '\u2C00'..'\u2FEF'
    |   '\u3001'..'\uD7FF'
    |   '\uF900'..'\uFDCF'
    |   '\uFDF0'..'\uFFFD'
    ; // ignores | ['\u10000-'\uEFFFF] ;
 
