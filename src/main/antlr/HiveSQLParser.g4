parser grammar HiveSQLParser;

@header {
    package hivesql.analysis.parse;
}

options
   { tokenVocab = HiveSQLLexer; }

stat
   : select_clause+
   ;



select_clause
   : SELECT selected_column_list ( FROM table_references )? ( where_clause )? (group_by_clause)? SEMI_COLON?
   ;

schema_name
   : ID
   ;

table_name
   : (schema_name DOT)? ID
   ;

table_alias
   : AS? ID
   ;

column_name
   : 
   ( table_name DOT )?  ID 
   | ( table_name DOT )? BACK_QUOTE ID BACK_QUOTE
   ;

column_name_alias
   : AS? ID
   ;

selected_column
   : 
   (STRING | INT | DOUBLE | func_call | column_name) (column_name_alias)? 
   ;

selected_column_list
   : selected_column (COMMA selected_column)*
   ;

index_name
   : ID
   ;

column_list
   : column_name ( COMMA column_name )*
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
   : WHERE top_logic_expr
   ;

group_by_clause
	: GROUP BY column_list
	;

/*
 */

basic_logic_expr
   : expr relational_op expr | expr BETWEEN expr AND expr | expr is_or_is_not NULL
   ;

logic_expr
	: basic_logic_expr (logic_op basic_logic_expr)+
	;

logic_expr_with_paren
	: basic_logic_expr | LPAREN basic_logic_expr RPAREN
	;

top_logic_expr
	: logic_expr_with_paren (logic_op logic_expr_with_paren)*
	;

/*
 * inner_expr: 代表不带括号的 表达式（包括算术表达式、函数调用、table column名称、整型数值、字符串数值）
 * expr：代表 带括号的 表达式
 * 
 * 注意：expr不代表逻辑表达式。
 * 
 */
non_arith_expr
	: column_name | DOUBLE | INT | STRING | func_call
	;
	

/* 这里注意排序，因为影响parse优先级 */
arith_binary_op
	: POWER_OP | DIVIDE | MOD | ASTERISK | PLUS | MINUS
	;
	
/*
 * 基础算术表达式，这里只写了 双操作符的情况
 */
basic_arith_expr
	: non_arith_expr (arith_binary_op non_arith_expr)+
	;

basic_arith_expr_with_paren
	: basic_arith_expr | LPAREN basic_arith_expr RPAREN
	;

arith_expr
	: basic_arith_expr_with_paren 	(arith_binary_op basic_arith_expr)*
	;

inner_expr
	:  non_arith_expr | arith_expr
	;
	
expr
	: LPAREN inner_expr RPAREN | inner_expr
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

logic_op
	: AND | OR
	;

expr_op
   : AND | XOR | OR | NOT
   ;

is_or_is_not
   : IS | IS NOT
   ;



table_references
   : table_atom ( ( COMMA table_atom ) | join_clause )*
   ;

table_atom
   : ( table_name ( partition_clause )? ( table_alias )? ( index_hint_list )? ) 
   | ( subquery subquery_alias ) 
   | ( LPAREN table_references RPAREN ) 
//   | ( OJ table_reference LEFT OUTER JOIN table_reference ON logic_expr )
//oj: http://dev.mysql.com/doc/refman/5.7/en/join.html
   ;

join_clause
   : 
	( ( LEFT | RIGHT | FULL) ( OUTER )? )? JOIN table_atom ( join_condition )?
	| CROSS JOIN table_atom (join_condition)?
   ;

join_condition
   :  ON top_logic_expr  
   |  USING LPAREN column_list RPAREN
   ;

index_hint_list
   : index_hint ( COMMA index_hint )*
   ;

index_options
   : ( INDEX | KEY ) ( FOR ( ( JOIN ) | ( ORDER BY ) | ( GROUP BY ) ) )?
   ;

index_hint
   : USE index_options LPAREN ( index_list )? RPAREN 
   | IGNORE index_options LPAREN index_list RPAREN
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
   : AS? ID
   ;

subquery
   : LPAREN select_clause RPAREN
   ;


