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
   		$block = LeafBlockWithoutLine.build(0, "");
   		try{
   			$block.addContent(getTokenText($AS)+" ");
   		}catch(Exception e){}
   		$block.addContent(getTokenText($ID));
   }

;

selected_column returns [NonLeafBlock block]
:
{ $block = new NonLeafBlock(); }
	(
		STRING
			{ 
				$block.addChild(
					LeafBlockWithLine.build(0, getTokenText($STRING))
				);
			}
		| INT
			{
				$block.addChild(
					LeafBlockWithLine.build(0, getTokenText($INT))
				);
			}
		| DOUBLE
			{
				$block.addChild(
					LeafBlockWithLine.build(0, getTokenText($DOUBLE))
				);
			}
		|
		(
			func_call
				{
					$block.addChild($func_call.block);
				}
			(over_clause
				{
					$over_clause.block.setSpaceCount(1);
					$block.addChild($over_clause.block);
				}
			)?
		)
		| top_arith_expr
			{
				$block.addChild($top_arith_expr.block);
			}
	)
	(
		column_name_alias
			{
				$column_name_alias.block.setSpaceCount(1);
				$block.addChild($column_name_alias.block);
			}
	)?
;

selected_column_list returns [NonLeafBlock block]
:
{ $block = new NonLeafBlock(); }
	selected_column
		{
			$block.addChild($selected_column.block);
		}
	(
		COMMA selected_column
			{
				$block.addChild(
					LeafBlockWithLine.build(0, getTokenText($COMMA))
				);
				$block.addChild($selected_column.block);
			}
	)*
{ $block.addChild(
	LeafBlockWithLine.build(0,"");
	); 
}
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
			$block.addChild($full_column_name.block);
			
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

group_by_clause returns [NonLeafBlock block]
:
	column_name_list
	{
		$block = $column_name_list.block
	}
;

/*
 */
basic_logic_expr returns [NonLeafBlock block]
:
{ $block = new NonLeafBlock(); }
	top_arith_expr
		{$block.addChild($top_arith_expr.block);} 
	relational_op top_arith_expr
		{
			$relational_op.block.setSpaceCount(1);
			$block.addChild($relational_op.block);
			
			$top_arith_expr.block.setSpaceCount(1);
			$block.addChild($top_arith_expr.block);
		}
	| 
	top_arith_expr 
		{$block.addChild($top_arith_expr.block);}
	BETWEEN top_arith_expr 
		{
			Block b1 = LeafBlockWithoutLine.build(1, getTokenText($BETWEEN));
			$block.addChild(b1);
			
			$top_arith_expr.block.setSpaceCount(1);
			$block.addChild($top_arith_expr.block);
		}
	AND top_arith_expr
		{
			Block b1 = LeafBlockWithoutLine.build(1, getTokenText($AND));
			$block.addChild(b1);
			
			$top_arith_expr.block.setSpaceCount(1);
			$block.addChild($top_arith_expr.block);
		}
	| 
	top_arith_expr is_or_is_not NULL
		{
			$block.addChild($top_arith_expr.block);
			
			$is_or_is_not.block.setSpaceCount(1);
			$block.addChild($is_or_is_not.block);
			
			Block b1 = LeafBlockWithoutLine.build(1, getTokenText($NULL));
			$block.addChild(b1);
		}
	| 
	case_clause
		{ $block=$case_clause.block;}
;

top_logic_expr returns [NonLeafBlock block]
:
{ $block = new NonLeafBlock(); }
	top_logic_expr
		{
			$block.addChild($top_logic_expr.block);
		}
	(
		logic_op top_logic_expr
			{
				$logic_op.block.setSpaceCount(1);
				$block.addChild($logic_op.block);
				$top_logic_expr.block.setSpaceCount(1);
				$block.addChild($top_logic_expr.block);
			}
	)+
	| 
	LPAREN top_logic_expr
		{
			$block.addChild(LeafBlockWithoutLine.build(0, getTokenText($LPAREN)));
			$top_logic_expr.block.setSpaceCount(1);
			$block.addChild($top_logic_expr.block);
		}
	(
		logic_op top_logic_expr
			{
				$logic_op.block.setSpaceCount(1);
				$block.addChild($logic_op.block);
				$top_logic_expr.block.setSpaceCount(1);
				$block.addChild($top_logic_expr.block);
			}
	)+ RPAREN
		{
			$block.addChild(LeafBlockWithoutLine.build(1, getTokenText($RPAREN)));
		}
	| 
	basic_logic_expr
		{
			$block.addChild($basic_logic_expr.block);
		}
;

/* 这里注意排序，因为影响parse优先级 */
arith_binary_op returns [LeafBlockWithoutLine block]
:
	POWER_OP
		{ $block = LeafBlockWithoutLine.build(0, getTokenText(POWER_OP)); }
	| DIVIDE
		{ $block = LeafBlockWithoutLine.build(0, getTokenText(DIVIDE)); }
	| MOD
		{ $block = LeafBlockWithoutLine.build(0, getTokenText(MOD)); }
	| ASTERISK
		{ $block = LeafBlockWithoutLine.build(0, getTokenText(ASTERISK)); }
	| PLUS
		{ $block = LeafBlockWithoutLine.build(0, getTokenText(PLUS)); }
	| MINUS
		{ $block = LeafBlockWithoutLine.build(0, getTokenText(MINUS)); }
;

non_arith_expr returns [Block block]
:
	func_call
		{ $block = $func_call.block; }
	| full_column_name
		{ $block = $full_column_name.block; }
	| DOUBLE
		{ $block = LeafBlockWithoutLine.build(0, getTokenText($DOUBLE)); }
	| INT
		{ $block = LeafBlockWithoutLine.build(0, getTokenText($INT)); }
	| STRING
		{ $block = LeafBlockWithoutLine.build(0, getTokenText($STRING)); }
;

top_arith_expr returns [NonLeafBlock block]
:
{ block = new NonLeafBlock(); }
	top_arith_expr
		{ $block.addChild($top_arith_expr.block); }
	(
		arith_binary_op top_arith_expr
			{
				$arith_binary_op.block.setSpaceCount(1);
				$block.addChild($arith_binary_op.block);
				
				$top_arith_expr.block.setSpaceCount(1);
				$block.addChild($top_arith_expr.block);
			}
	)+
	| LPAREN top_arith_expr
		{
			$block.addChild( LeafBlockWithoutLine.build(0, getTokenText($LPAREN)) );
			
			$top_arith_expr.block.setSpaceCount(1);
			$block.addChild($top_arith_expr.block);
		}
	(
		arith_binary_op top_arith_expr
			{
				$arith_binary_op.block.setSpaceCount(1);
				$block.addChild($arith_binary_op.block);
				
				$top_arith_expr.block.setSpaceCount(1);
				$block.addChild($top_arith_expr.block);
			}
	)+ RPAREN
		{
			$block.addChild( LeafBlockWithoutLine.build(0, getTokenText($RPAREN)) );
		}
	| non_arith_expr
		{ $block.add($non_arith_expr.block); }
	| case_clause
		{ $block.add($case_clause.block); }
;

top_expr returns [NonLeafBlock block]
:
	top_arith_expr
		{ $block=$top_arith_expr.block; }
	| top_logic_expr
		{ $block=$top_logic_expr.block; }
;

/*
 * 函数调用
 */
func_call returns [NonLeafBlock block]
:
{ $block = new NonLeafBlock(); }
	func_name LPAREN 
		{
			$block.addChild($func_name.block);
			$block.addChild( LeafBlockWithoutLine.build(0, getTokenText($LPAREN)) );
		}
	(func_para_list
		{
			$block.addChild( $func_para_list.block );
		}
	)? 
	RPAREN
		{
			$block.addChild( LeafBlockWithoutLine.build(0, getTokenText($RPAREN)) );
		}
;

func_name returns [LeafBlockWithoutLine block]
:
	ID { $block = LeafBlockWithoutLine.build(0, getTokenText($ID)); }
;

func_para returns [NonLeafBlock block]
:
	top_expr { $block = $top_expr.block; }
;

func_para_list returns [NonLeafBlock block]
:
{ $block = new NonLeafBlock(); }
	func_para
		{
			$block.addChild( $func_para.block);
		}
	(
		COMMA func_para
			{
				$block.addChild( $block.addChild( LeafBlockWithoutLine.build(0, getTokenText($COMMA)) ) );
				$func_para.block.setSpaceCount(1);
				$block.addChild( $func_para.block );
			}
	)*
;

relational_op returns [LeafBlockWithLine block]
:
	DOUBLE_EQ
		{ $block = LeafBlockWithoutLine.build(0, getTokenText($DOUBLE_EQ)); }
	| EQ
		{ $block = LeafBlockWithoutLine.build(0, getTokenText($EQ)); }
	| LTH
		{ $block = LeafBlockWithoutLine.build(0, getTokenText($LTH)); }
	| GTH
		{ $block = LeafBlockWithoutLine.build(0, getTokenText($GTH)); }
	| NOT_EQ
		{ $block = LeafBlockWithoutLine.build(0, getTokenText($NOT_EQ)); }
	| LET
		{ $block = LeafBlockWithoutLine.build(0, getTokenText($LET)); }
	| GET
		{ $block = LeafBlockWithoutLine.build(0, getTokenText($GET)); }
;

logic_op returns [LeafBlockWithoutLine block]
:
	AND
		{ $block = LeafBlockWithoutLine.build(0, getTokenText($AND)); }
	| 
	OR
		{ $block = LeafBlockWithoutLine.build(0, getTokenText($OR)); }
;

expr_op
:
	AND
	| XOR
	| OR
	| NOT
;

is_or_is_not returns [LeafBlockWithoutLine block]
:
	IS
		{ $block = LeafBlockWithoutLine.build(0, getTokenText(IS)); }
	| IS NOT
		{ $block = LeafBlockWithoutLine.build(0, getTokenText(IS_NOT)); }
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

over_clause returns [NonLeafBlock block]
:
{ $block = NonLeafBlock(); }
	OVER LPAREN PARTITION BY column_name_list
		{
			$block.addChild( LeafBlockWithoutLine(0, getTokenText($OVER)) );
			$block.addChild( LeafBlockWithLine(1, getTokenText($LPAREN)) );
			
			$block.addChild( LeafBlockWithoutLine(Indent_Space_Count, getTokenText($PARTITION)) );
			$block.addChild( LeafBlockWithLine(1, getTokenText($BY)) );
			$column_name_list.block.setSpaceCount(Indent_Space_Count*2);
			$block.addChild( $column_name_list.block );
		}
	(
		order_clause
		{
			$order_clause.block.setSpaceCount(Indent_Space_Count);
			$block.addChild($order_clause.block);
		}
	)? 
	RPAREN
	{
		$block.addChild( LeafBlockWithLine(0, getTokenText($RPAREN)) );
	}
;
/**
 * case_clause既可以作算术表达式，又可以做逻辑表达式放到where里面
 */
case_clause returns [NonLeafBlock block]
:
{ $block = new NonLeafBlock(); }
	CASE
		{ $block.addChild( LeafBlockWithLine.build(0, getTokenText($CASE)) ); }
	(
		WHEN top_logic_expr THEN top_expr
			{
				$block.addChild( LeafBlockWithoutLine.build(Indent_Space_Count, getTokenText($WHEN)) );
				
				$top_logic_expr.block.setSpaceCount(Indent_Space_Count);
				$block.addChild($top_logic_expr.block);
				$block.addChild( LeafBlockWithLine.build(0,"") );
				
				
				$block.addChild( LeafBlockWithoutLine.build(Indent_Space_Count*2, getTokenText($THEN)) );
				
				$top_expr.block.setSpaceCount(Indent_Space_Count);
				$block.addChild($top_expr.block);
				$block.addChild( LeafBlockWithLine.build(0,"") );
			}
	)+ ELSE top_expr END
		{
			$block.addChild( LeafBlockWithoutLine.build(Indent_Space_Count, getTokenText($ELSE)) );
			
			$top_expr.block.setSpaceCount(Indent_Space_Count);
			$block.addChild($top_expr.block);
			
			$block.addChild( LeafBlockWithLine.build(Indent_Space_Count, getTokenText($END)) );
		}
;

order_clause returns [NonLeafBlock block]
:
ordered_column_name_list { $block=$ordered_column_name_list.block; }
;

cluster_clause returns [NonLeafBlock block]
:
	column_name_list { $block= $column_name_list.block; }
;

distribute_clause returns [NonLeafBlock block]
:
	column_name_list { $block= $column_name_list.block; }
;

sort_clause returns [NonLeafBlock block]
:
ordered_column_name_list { $block=$ordered_column_name_list.block; }
;
ordered_column_name_list returns [NonLeafBlock block]
:
{ $block=new NonLeafBlock(); }
	full_column_name
		{ $block.addChild($full_column_name.block); }
	(
		DESC
			{ $block.addChild(
					LeafBlockWithoutLine.build(1, getTokenText($DESC))
				); 
			}
		| 
		ASC
			{ $block.addChild(
					LeafBlockWithoutLine.build(1, getTokenText($ASC))
				); 
			}
	)?
	(
		(
			COMMA full_column_name
				{
					$block.addChild(
						LeafBlockWitLine.build(0, getTokenText($COMMA))
					); 
					$block.addChild($full_column_name.block);
				}
			(
				DESC
					{
						$block.addChild(
							LeafBlockWithoutLine.build(1, getTokenText($DESC))
						);
					} 
				| 
				ASC
					{ 
						$block.addChild(
							LeafBlockWithoutLine.build(1, getTokenText($ASC))
						); 
					}
			)?
		)
	)*
;