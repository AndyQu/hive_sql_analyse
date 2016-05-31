parser grammar HiveSQLParser;

options
   { tokenVocab = HiveSQLLexer; }

stat
   : select_clause+
   ;

schema_name
   : ID
   ;

select_clause
   //: SELECT column_list_clause ( FROM table_references )? ( where_clause )?
   : SELECT selected_column_list ( FROM table_references )? ( where_clause )?
   ;

table_name
   : (schema_name DOT)? ID
   ;

table_alias
   : ID
   ;

column_name
   : ( ( schema_name DOT )? ID DOT )? ID ( column_name_alias )? | ( table_alias DOT )? ID | USER_VAR ( column_name_alias )?
   ;

column_name_alias
   : ID
   ;

selected_column
   : func_call ((AS)? column_name_alias)? | column_name
   ;

selected_column_list
   : selected_column (COMMA selected_column)*
   ;

index_name
   : ID
   ;

column_list
   : LPAREN column_name ( COMMA column_name )* RPAREN
   ;
/**
column_list_clause
   //: column_name ( COMMA column_name )*
   : func_call ((AS)? column_name_alias)? (COMMA func_call)*
   ;
*/

from_clause
   : FROM table_name ( COMMA table_name )*
   ;

select_key
   : SELECT
   ;

where_clause
   : WHERE logic_expr
   ;


/*
 * inner_logic_expr: 代表 不带括号 的逻辑表达式
 * inner_logic_expr: 代表 带括号   的逻辑表达式
 * logic_expr: 代表 最高层次的逻辑表达式
 */

inner_logic_expr
   : expr (relational_op expr)+ | expr BETWEEN expr AND expr | expr is_or_is_not NULL
   ;

inner_logic_expr_with_paren
	: inner_logic_expr | LPAREN inner_logic_expr RPAREN
	;

logic_expr
	: inner_logic_expr_with_paren (relational_op inner_logic_expr_with_paren)+
	;

/*
 * inner_expr: 代表不带括号的 表达式（包括算术表达式、函数调用、table column名称、整型数值、字符串数值）
 * expr：代表 带括号的 表达式
 * 
 * 注意：expr不代表逻辑表达式。
 * 
 */
inner_expr
	:  column_name | DOUBLE | INT | STRING | func_call | arithmetic_expr
	;
	
expr
	: LPAREN inner_expr RPAREN | inner_expr
	;
   
/* 这里注意排序，因为影响parse优先级 */
arithmetic_binary_op
	: POWER_OP | DIVIDE | MOD | ASTERISK | PLUS | MINUS
	;

/*
 * 算术表达式，这里只写了 双操作符的情况
 */
arithmetic_expr
	: expr arithmetic_binary_op expr
	;

/*
 * 函数调用
 */
func_call
   : func_name LPAREN func_para_list RPAREN
   ;

func_name
   : ID
   ;

func_para
   : expr
   ;

func_para_list
   : expr ? (COMMA expr)* 
   ;
   

relational_op
   : EQ | LTH | GTH | NOT_EQ | LET | GET
   ;

expr_op
   : AND | XOR | OR | NOT
   ;

is_or_is_not
   : IS | IS NOT
   ;



table_references
   : table_reference ( ( COMMA table_reference ) | join_clause )*
   ;

table_reference
   : table_factor1 | table_atom
   ;

table_factor1
   : table_factor2 ( ( INNER | CROSS )? JOIN table_atom ( join_condition )? )?
   ;

table_factor2
   : table_factor3 ( STRAIGHT_JOIN table_atom ( ON logic_expr )? )?
   ;

table_factor3
   : table_factor4 ( ( LEFT | RIGHT ) ( OUTER )? JOIN table_factor4 join_condition )?
   ;

table_factor4
   : table_atom ( NATURAL ( ( LEFT | RIGHT ) ( OUTER )? )? JOIN table_atom )?
   ;

table_atom
   : ( table_name ( partition_clause )? ( table_alias )? ( index_hint_list )? ) | ( subquery subquery_alias ) | ( LPAREN table_references RPAREN ) | ( OJ table_reference LEFT OUTER JOIN table_reference ON logic_expr )
   ;

join_clause
   : ( ( INNER | CROSS )? JOIN table_atom ( join_condition )? ) | ( STRAIGHT_JOIN table_atom ( ON logic_expr )? ) | ( ( LEFT | RIGHT ) ( OUTER )? JOIN table_factor4 join_condition ) | ( NATURAL ( ( LEFT | RIGHT ) ( OUTER )? )? JOIN table_atom )
   ;

join_condition
   : ( ON logic_expr ( expr_op logic_expr )* ) | ( USING column_list )
   ;

index_hint_list
   : index_hint ( COMMA index_hint )*
   ;

index_options
   : ( INDEX | KEY ) ( FOR ( ( JOIN ) | ( ORDER BY ) | ( GROUP BY ) ) )?
   ;

index_hint
   : USE index_options LPAREN ( index_list )? RPAREN | IGNORE index_options LPAREN index_list RPAREN
   ;

index_list
   : index_name ( COMMA index_name )*
   ;

partition_clause
   : PARTITION LPAREN partition_names RPAREN
   ;

partition_names
   : partition_name ( COMMA partition_name )*
   ;

partition_name
   : ID
   ;

subquery_alias
   : ID
   ;

subquery
   : LPAREN select_clause RPAREN
   ;


