parser grammar HiveSQLParser;

@header {
    package hivesql.analysis.parse;
    import hivesql.analysis.format.*;
}

options
   {
	tokenVocab = HiveSQLLexer;
}

@members {
	public static final Indent_Space_Count=2;
	public String getTokenText(Token t) {
		return getTokenStream().getText(new Interval(t.getTokenIndex(), t.getTokenIndex()));
	}
}

stat returns [NonLeafBlock block]
:
	{ $block = new NonLeafBlock(); }

	select_clause
	{ $block.addChild( $select_clause.block);    		}

	(
		UNION
		{ $block.addChild(LeafBlockWithoutLine.build(0, getTokenText($UNION))); }

		(
			ALL
			{ $block.addChild(LeafBlockWithoutLine.build(1, getTokenText($ALL))); }

			| DISTINCT
			{ $block.addChild(LeafBlockWithoutLine.build(1, getTokenText($DISTINCT))); }

		)?
		{ $block.addChild(LeafBlockWithLine.build(0, "")); }

		select_clause
		{ $block.addChild( $select_clause.block); }
	)*
;

select_clause returns [NonLeafBlock block]
:
{ $block = new NonLeafBlock(); }
	SELECT selected_column_list
		{ 
			$block.addChild(LeafBlockWithLine.build(0, getTokenText($SELECT)));
			Block b = $selected_column_list.block;
			b.setSpaceCount(Indent_Space_Count);
			$block.addChild(b);
		}
	(
		FROM table_references
		{
			$block.addChild(LeafBlockWithLine.build(0, getTokenText($FROM)));
			Block b = $table_references.block;
			b.setSpaceCount(Indent_Space_Count);
			$block.addChild(Indent_Space_Count);
		}
	)?
	(
		WHERE top_logic_expr
		{
			$block.addChild(LeafBlockWithLine.build(0, getTokenText($WHERE)));
			$top_logic_expr.block.setSpaceCount(Indent_Space_Count);
			$block.addChild($top_logic_expr.block);
		}
	)?
	(
		GROUP BY group_by_clause
		{
			$block.addChild(LeafBlockWithLine.build(0, getTokenText($GROUP)+" "+getTokenText($BY)));
			$group_by_clause.block.setSpaceCount(Indent_Space_Count);
			$block.addChild($group_by_clause.block);
		}
	)?
	(
		CLUSTER BY cluster_clause
		{
			$block.addChild(LeafBlockWithLine.build(0, getTokenText($CLUSTER)+" "+getTokenText($BY)));
			$cluster_clause.block.setSpaceCount(Indent_Space_Count);
			$block.addChild($cluster_clause.block);
		}
	)?
	(
		DISTRIBUTE BY distribute_clause
		{
			$block.addChild(LeafBlockWithLine.build(0, getTokenText($DISTRIBUTE)+" "+getTokenText($BY)));
			$distribute_clause.block.setSpaceCount(Indent_Space_Count);
			$block.addChild($distribute_clause.block);
		}
	)?
	(
		SORT BY sort_clause
		{
			$block.addChild(LeafBlockWithLine.build(0, getTokenText($SORT)+" "+getTokenText($BY)));
			$sort_clause.block.setSpaceCount(Indent_Space_Count);
			$block.addChild($sort_clause.block);
		}
	)? SEMI_COLON?
;

schema_name returns [LeafBlockWithoutLine block]
:
	ID
	{
   	$block = LeafBlockWithoutLine.build(1, getTokenText($ID));
   }

;

table_name returns [NonLeafBlock block]
:
	{$block = new NonLeafBlock();}

	(
		schema_name DOT
		{
   		$block.addChild($schema_name.block);
   		$block.addChild(LeafBlockWithoutLine.build(0, getTokenText($DOT)));
   	}

	)? ID
	{
   		$block.addChild(LeafBlockWithoutLine.build(0, getTokenText($ID)));
   }

;

//TODO
/**
 * 1. 这里暂时把distinct关键字放在这里，实际上是不对的。column_name从概念上讲不应该包括“distinct”这样的修饰符
 * 2. '*' 也暂时放在这里
 */
full_column_name returns [NonLeafBlock block]
:
	{ $block = new NonLeafBlock(); }

	(
		DISTINCT
		{$block.addChild(LeafBlockWithoutLine.build(1, getTokenText($DISTINCT)));}

	)?
	(
		table_name DOT
		{
   			$block.addChild($table_name.block);
   			$block.addChild(LeafBlockWithoutLine.build(0, getTokenText($DOT)));
   		}

	)? simple_column_name
	{
   		$block.addChild($simple_column_name.block);
    }

;

simple_column_name returns [LeafBlockWithoutLine block]
:
	ID
	{	$block=LeafBlockWithoutLine.build(0, getTokenText($ID));	}

	| ASTERISK
	{	$block=LeafBlockWithoutLine.build(0, getTokenText($ASTERISK));}

	| BACK_QUOTE ID BACK_QUOTE
	{	$block=LeafBlockWithoutLine.build(
			0, 
			String.format("%s%s%s", 
				getTokenText($BACK_QUOTE), 
				getTokenText($ID), 
				getTokenText($BACK_QUOTE)
			) 
		);
		}

	| BACK_QUOTE ASTERISK BACK_QUOTE
	{	$block=LeafBlockWithoutLine.build(0, 
				String.format("%s%s%s", 
					getTokenText($BACK_QUOTE), 
					getTokenText($ASTERISK), 
					getTokenText($BACK_QUOTE)
				)
			);
		}

;

subquery_alias returns [LeafBlockWithoutLine block]
:
	common_alias
	{$block=$common_alias.block;}

;

table_name_alias returns [LeafBlockWithoutLine block]
:
	common_alias
	{$block=$common_alias.block;}

;

column_name_alias returns [LeafBlockWithoutLine block]
:
	common_alias
	{$block=$common_alias.block;}

;

common_alias returns [LeafBlockWithoutLine block]
:
	AS? ID
	{
   		$block = LeafBlockWithoutLine.build(0, " ");
   		try{
   			$block.addContent(getTokenText($AS)+" ");
   		}catch(Exception e){}
   		$block.addContent(getTokenText($ID));
   }

;

selected_column
:
	(
		STRING
		| INT
		| DOUBLE
		|
		(
			func_call over_clause?
		)
		| top_arith_expr
	)
	(
		column_name_alias
	)?
;

selected_column_list
:
	selected_column
	(
		COMMA selected_column
	)*
;

index_name
:
	ID
;

column_name_list returns [NonLeafBlock block]
:
{ $block = new NonLeafBlock(); }
	full_column_name
		{ 
			$block.addChild($full_column_name);
			
		}
	(
		COMMA full_column_name
			{	
				$block.addChild(LeafBlockWithLine.build(0, getTokenText($COMMA)));
				$block.addChild( $full_column_name.block);
			}
	)*
	{
   		$block.addChild(LeafBlockWithLine.build(0,""));
   }

;
/**
column_list_clause
   //: column_name ( COMMA column_name )*
   : func_call ((AS)? column_name_alias)? (COMMA func_call)*
   ;
*/
from_clause
:
	FROM table_name
	(
		COMMA table_name
	)*
;

select_key
:
	SELECT
;

group_by_clause
:
	column_name_list
;

/*
 */
basic_logic_expr
:
	top_arith_expr relational_op top_arith_expr
	| top_arith_expr BETWEEN top_arith_expr AND top_arith_expr
	| top_arith_expr is_or_is_not NULL
	| case_clause
;

top_logic_expr
:
	top_logic_expr
	(
		logic_op top_logic_expr
	)+
	| LPAREN top_logic_expr
	(
		logic_op top_logic_expr
	)+ RPAREN
	| basic_logic_expr
;

/* 这里注意排序，因为影响parse优先级 */
arith_binary_op
:
	POWER_OP
	| DIVIDE
	| MOD
	| ASTERISK
	| PLUS
	| MINUS
;

non_arith_expr
:
	func_call
	| full_column_name
	| DOUBLE
	| INT
	| STRING
;

top_arith_expr
:
	top_arith_expr
	(
		arith_binary_op top_arith_expr
	)+
	| LPAREN top_arith_expr
	(
		arith_binary_op top_arith_expr
	)+ RPAREN
	| non_arith_expr
	| case_clause
;

top_expr
:
	top_arith_expr
	| top_logic_expr
;

/*
 * 函数调用
 */
func_call
:
	func_name LPAREN func_para_list? RPAREN
;

func_name
:
	ID
;

func_para
:
	top_expr
;

func_para_list
:
	func_para
	(
		COMMA func_para
	)*
;

relational_op
:
	DOUBLE_EQ
	| EQ
	| LTH
	| GTH
	| NOT_EQ
	| LET
	| GET
;

logic_op
:
	AND
	| OR
;

expr_op
:
	AND
	| XOR
	| OR
	| NOT
;

is_or_is_not
:
	IS
	| IS NOT
;

table_references
:
	table_atom
	(
		(
			COMMA table_atom
		)
		| join_clause
	)*
;

table_atom
:
	(
		table_name
		(
			partition_clause
		)?
		(
			table_name_alias
		)?
		(
			index_hint_list
		)?
	)
	|
	(
		subquery subquery_alias
	)
	//   | ( LPAREN table_references RPAREN ) 
	//   | ( OJ table_reference LEFT OUTER JOIN table_reference ON logic_expr )
	//oj: http://dev.mysql.com/doc/refman/5.7/en/join.html

;

join_clause
:
	(
		(
			LEFT
			| RIGHT
			| FULL
		)
		(
			OUTER
		)?
	)? JOIN table_atom
	(
		join_condition
	)?
	| CROSS JOIN table_atom
	(
		join_condition
	)?
;

join_condition
:
	ON top_logic_expr
	| USING LPAREN column_name_list RPAREN
;

index_hint_list
:
	index_hint
	(
		COMMA index_hint
	)*
;

index_options
:
	(
		INDEX
		| KEY
	)
	(
		FOR
		(
			(
				JOIN
			)
			|
			(
				ORDER BY
			)
			|
			(
				GROUP BY
			)
		)
	)?
;

index_hint
:
	USE index_options LPAREN
	(
		index_list
	)? RPAREN
	| IGNORE index_options LPAREN index_list RPAREN
;

index_list
:
	index_name
	(
		COMMA index_name
	)*
;

partition_clause
:
	PARTITION LPAREN partition_names RPAREN
;

partition_names
:
	partition_name
	(
		COMMA partition_name
	)*
;

partition_name returns [Block block]
:
	ID
	{ 
   	TerminalNodeImpl n = (TerminalNodeImpl)_localctx.getChild(0);
   	String text = getTokenStream().getText(n.getSourceInterval());
   	System.out.println("construct:"+text);
   	$block = LeafBlockWithoutLine.build(1, text);
   }

;

subquery
:
	LPAREN stat RPAREN
;

//TODO
//windows字句暂不支持
//TODO
//row_number() over 支持 distribute by，但是在Hive语法手册中找不到官方正式定义

over_clause
:
	OVER LPAREN PARTITION BY column_name_list
	(
		order_clause
	)? RPAREN
;
/**
 * case_clause既可以作算术表达式，又可以做逻辑表达式放到where里面
 */
case_clause
:
	CASE
	(
		WHEN top_logic_expr THEN top_expr
	)+ ELSE top_expr END
;

order_clause
:
	ORDER BY full_column_name
	(
		DESC
		| ASC
	)?
	(
		(
			COMMA full_column_name
			(
				DESC
				| ASC
			)?
		)
	)*
;

cluster_clause returns [NonLeafBlock block]
:
	column_name_list { $block= $column_name_list.block; }
;

distribute_clause returns [NonLeafBlock block]
:
	column_name_list { $block= $column_name_list.block; }
;

sort_clause
:
	full_column_name
	(
		DESC
		| ASC
	)?
	(
		(
			COMMA full_column_name
			(
				DESC
				| ASC
			)?
		)
	)*
;