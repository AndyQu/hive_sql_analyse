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

//TODO
/**
 * 1. 这里暂时把distinct关键字放在这里，实际上是不对的。column_name从概念上讲不应该包括“distinct”这样的修饰符
 * 2. '*' 也暂时放在这里
 */
column_name
   : 
    (DISTINCT)? ( table_name DOT )?  (ID|ASTERISK)
   |  (DISTINCT)? ( table_name DOT )? BACK_QUOTE (ID|ASTERISK) BACK_QUOTE
   ;

column_name_alias
   : AS? ID
   ;

selected_column
   : 
   (STRING | INT | DOUBLE | (func_call over_clause?) | top_arith_expr) (column_name_alias)? 
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
   : top_arith_expr relational_op top_arith_expr 
   | top_arith_expr BETWEEN top_arith_expr AND top_arith_expr 
   | top_arith_expr is_or_is_not NULL 
   | case_clause
   ;

top_logic_expr
	: 
	top_logic_expr (logic_op top_logic_expr)+
	| LPAREN top_logic_expr (logic_op top_logic_expr)+ RPAREN
	| basic_logic_expr
	;


/* 这里注意排序，因为影响parse优先级 */
arith_binary_op
	: POWER_OP | DIVIDE | MOD | ASTERISK | PLUS | MINUS
	;
	
non_arith_expr
	: func_call | column_name | DOUBLE | INT | STRING 
	;
	
top_arith_expr
	:
	top_arith_expr (arith_binary_op top_arith_expr)+
	| LPAREN top_arith_expr (arith_binary_op top_arith_expr)+ RPAREN
	| non_arith_expr
	| case_clause
	;

top_expr
	: top_arith_expr|top_logic_expr
	;
   


/*
 * 函数调用
 */
func_call
   : func_name LPAREN func_para_list? RPAREN
   ;

func_name
   : ID
   ;

func_para
   : top_expr
   ;

func_para_list
   : func_para (COMMA func_para)* 
   ;
   

relational_op
   : DOUBLE_EQ | EQ | LTH | GTH | NOT_EQ | LET | GET
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

//TODO
/**
 * windows字句暂不支持
 */
over_clause
	: OVER LPAREN PARTITION BY ID (COMMA ID)* (ORDER BY ID (COMMA ID)* (DESC|ASC)?)? RPAREN
	;
/**
 * case_clause既可以作算术表达式，又可以做逻辑表达式放到where里面
 */
case_clause
	: CASE (WHEN top_logic_expr THEN top_expr)+ ELSE top_expr END
	;