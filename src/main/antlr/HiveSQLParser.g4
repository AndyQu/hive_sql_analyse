parser grammar HiveSQLParser;

@header {
    package hivesql.analysis.parse;
    import hivesql.analysis.format.*;

    import org.slf4j.Logger;
    import org.slf4j.LoggerFactory;
}

options
   {
	tokenVocab = HiveSQLLexer;
}

@members {
    private static Logger LOGGER = LoggerFactory.getLogger(HiveSQLParser.class);
	public static final int Indent_Space_Count=2;
	public String getTokenText(Token t) {
		return getTokenStream().getText(new Interval(t.getTokenIndex(), t.getTokenIndex()));
	}
}

stat returns [NonLeafBlock block]
@init
{ 
	$block = new NonLeafBlock(); 
	Boolean hasUnion = false;
}
:
	select_clause
	{ $block.addChild( $select_clause.block);    		}

	(
		UNION
		{ 
			hasUnion=true;
			$block.addChild( LineOnlyBlock.buildOne(0));
			$block.addChild(LeafBlockWithoutLine.build(0, getTokenText($UNION)));
		}

		(
			ALL
			{ $block.addChild(LeafBlockWithoutLine.build(1, getTokenText($ALL))); }

			| DISTINCT
			{ $block.addChild(LeafBlockWithoutLine.build(1, getTokenText($DISTINCT))); }

		)?
		{ 
			$block.addChild( LineOnlyBlock.build(0,2) );
		}

		select_clause
		{ 
			$select_clause.block.setSpaceCount(Indent_Space_Count);
			$block.addChild( $select_clause.block);
		}
	)*
	{
		if(hasUnion){
			$block.getChilds().get(0).setSpaceCount(Indent_Space_Count);
		}
	}
;

select_clause returns [NonLeafBlock block]
@init
{ $block = new NonLeafBlock(); }
:
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
			
			Block b1 = $table_references.block;
			b1.setSpaceCount(Indent_Space_Count);
			$block.addChild(b1);
			
			$block.addChild( LineOnlyBlock.buildOne(0) );
		}
	)?
	(
		WHERE top_expr
		{
			$block.addChild(LeafBlockWithLine.build(0, getTokenText($WHERE)));
			$top_expr.block.setSpaceCount(Indent_Space_Count);
			$block.addChild($top_expr.block);
			
			$block.addChild( LineOnlyBlock.buildOne(0) );
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
@init
{ $block = new NonLeafBlock(); }
:
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
@init
{ $block = new NonLeafBlock(); }
:
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
@init
{ $block = new NonLeafBlock(); }
:
	(
		STRING
			{ 
				$block.addChild(
					LeafBlockWithoutLine.build(0, getTokenText($STRING))
				);
			}
		| INT
			{
				$block.addChild(
					LeafBlockWithoutLine.build(0, getTokenText($INT))
				);
			}
		| DOUBLE
			{
				$block.addChild(
					LeafBlockWithoutLine.build(0, getTokenText($DOUBLE))
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
		| top_expr
			{
				$block.addChild($top_expr.block);
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
@init
{ $block = new NonLeafBlock(); }
:
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
	LeafBlockWithLine.build(0,"")
	); 
}
;

column_name_list returns [NonLeafBlock block]
@init
{ $block = new NonLeafBlock(); }
:
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


group_by_clause returns [NonLeafBlock block]
:
	column_name_list
	{
		$block = $column_name_list.block;
	}
;


/* 这里注意排序，因为影响parse优先级 */
arith_binary_op returns [LeafBlockWithoutLine block]
:
	POWER_OP
		{ $block = LeafBlockWithoutLine.build(0, getTokenText($POWER_OP)); }
	| DIVIDE
		{ $block = LeafBlockWithoutLine.build(0, getTokenText($DIVIDE)); }
	| MOD
		{ $block = LeafBlockWithoutLine.build(0, getTokenText($MOD)); }
	| ASTERISK
		{ $block = LeafBlockWithoutLine.build(0, getTokenText($ASTERISK)); }
	| PLUS
		{ $block = LeafBlockWithoutLine.build(0, getTokenText($PLUS)); }
	| MINUS
		{ $block = LeafBlockWithoutLine.build(0, getTokenText($MINUS)); }
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

top_expr returns [NonLeafBlock block]
@init
{ $block = new NonLeafBlock(); }
:
		LPAREN top_expr
			{
				$block.addChild(LeafBlockWithoutLine.build(0, getTokenText($LPAREN)));
				
				_localctx.top_expr.block.setSpaceCount(1);
				$block.addChild(_localctx.top_expr.block);
			}
		(
			binary_op top_expr
				{
					$binary_op.block.setSpaceCount(1);
					$block.addChild($binary_op.block);
					
					_localctx.top_expr.block.setSpaceCount(1);
					$block.addChild(_localctx.top_expr.block);
				}
		)+ RPAREN
			{
				$block.addChild(LeafBlockWithoutLine.build(1, getTokenText($RPAREN)));
			}
	| 
	top_expr
		{
		    /*
		    加这一句是为了让antlr4生成
		        ((Top_exprContext)_localctx).top_expr = top_expr(0);
		    否则, antlr4 只会生成
		        top_expr(0);
		    */
		    $top_expr.block=null;

            Top_exprContext ctx =(Top_exprContext) getContext().getChild(0);
            if($block==null) $block = new NonLeafBlock();
			$block.addChild( ctx.block );
		}
	(
		binary_op top_expr
			{
				$binary_op.block.setSpaceCount(1);
				$block.addChild($binary_op.block);
				
				_localctx.top_expr.block.setSpaceCount(1);
				$block.addChild(_localctx.top_expr.block);
			}
	)+

	
	| 
	top_expr 
		{
            Top_exprContext ctx =(Top_exprContext) getContext().getChild(0);
            if($block==null) $block = new NonLeafBlock();
        	$block.addChild( ctx.block );
        }
	BETWEEN top_expr 
		{
			$block.addChild( LeafBlockWithoutLine.build(1, getTokenText($BETWEEN)) );
			
			_localctx.top_expr.block.setSpaceCount(1);
			$block.addChild(_localctx.top_expr.block);
		}
	AND top_expr
		{
			$block.addChild( LeafBlockWithoutLine.build(1, getTokenText($AND)) );
			
			_localctx.top_expr.block.setSpaceCount(1);
			$block.addChild(_localctx.top_expr.block);
		}
	| 
	top_expr is_or_is_not NULL
		{
			Top_exprContext ctx =(Top_exprContext) getContext().getChild(0);
            if($block==null) $block = new NonLeafBlock();
            $block.addChild( ctx.block );
			
			$is_or_is_not.block.setSpaceCount(1);
			$block.addChild($is_or_is_not.block);
			
			Block b1 = LeafBlockWithoutLine.build(1, getTokenText($NULL));
			$block.addChild(b1);
		}
	| 
	case_clause
		{ $block=$case_clause.block;}
	| non_arith_expr
		{ $block.addChild($non_arith_expr.block); }
;


/*
 * 函数调用
 */
func_call returns [NonLeafBlock block]
@init
{ $block = new NonLeafBlock(); }
:
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
@init
{ $block = new NonLeafBlock(); }
:
	func_para
		{
			$block.addChild( $func_para.block);
		}
	(
		COMMA func_para
			{
				$block.addChild( LeafBlockWithoutLine.build(0, getTokenText($COMMA)) ) ;
				$func_para.block.setSpaceCount(1);
				$block.addChild( $func_para.block );
			}
	)*
;

binary_op returns [Block block]
:
relational_op {$block=$relational_op.block;}
|logic_op 
	{
		$block = new NonLeafBlock();
		
		NonLeafBlock b = (NonLeafBlock)$block;
		
		b.addChild( LineOnlyBlock.buildOne(0) );
		
		b.addChild( $logic_op.block );
		
		b.addChild( LineOnlyBlock.buildOne(0) );
	}
|arith_binary_op {$block=$arith_binary_op.block;}
;

relational_op returns [LeafBlockWithoutLine block]
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

is_or_is_not returns [LeafBlockWithoutLine block]
:
	IS
		{ $block = LeafBlockWithoutLine.build(0, getTokenText($IS)); }
	| IS NOT
		{ $block = LeafBlockWithoutLine.build(0, getTokenText($IS)+" "+getTokenText($NOT)); }
;

table_references returns [NonLeafBlock block]
@init
{ $block = new NonLeafBlock(); }
:
	table_atom
		{ $block.addChild( $table_atom.block ); }
	(
		(
			COMMA table_atom
				{
					$block.addChild( LeafBlockWithLine.build(0, getTokenText($COMMA)) );
					$block.addChild( $table_atom.block );
				}
		)
		| 
		join_clause
			{
				$block.addChild( LeafBlockWithLine.build(0, "" ));
				$block.addChild( $join_clause.block );
			}
	)*
;

table_atom returns [NonLeafBlock block]
@init
{ $block = new NonLeafBlock(); }
:
	(
		table_name
			{ $block.addChild( $table_name.block ); }
		(
			partition_clause
				{
					$partition_clause.block.setSpaceCount(1);
					$block.addChild($partition_clause.block);
				}
		)?
		(
			table_name_alias
				{
					$table_name_alias.block.setSpaceCount(1);
					$block.addChild( $table_name_alias.block );
				}
		)?
	)
	|
	(
		subquery subquery_alias
		{
			$block.addChild( $subquery.block );
			
			$subquery_alias.block.setSpaceCount(Indent_Space_Count);
			$block.addChild( $subquery_alias.block );
		}
	)
	//   | ( LPAREN table_references RPAREN ) 
	//   | ( OJ table_reference LEFT OUTER JOIN table_reference ON logic_expr )
	//oj: http://dev.mysql.com/doc/refman/5.7/en/join.html

;

join_clause returns [NonLeafBlock block]
@init
{ $block = new NonLeafBlock(); }
:
	(
		(
			LEFT
				{ $block.addChild( LeafBlockWithoutLine.build(0, getTokenText($LEFT)) ); }
			| RIGHT
				{ $block.addChild( LeafBlockWithoutLine.build(0, getTokenText($RIGHT)) ); }
			| FULL
				{ $block.addChild( LeafBlockWithoutLine.build(0, getTokenText($FULL)) ); }
		)
		(
			OUTER
				{ $block.addChild( LeafBlockWithoutLine.build(1, getTokenText($OUTER)) ); }
		)?
	)? JOIN table_atom
			{
				$block.addChild( LeafBlockWithoutLine.build(1, getTokenText($JOIN)) );
				
				$table_atom.block.setSpaceCount(1);
				$block.addChild( $table_atom.block); 
				
				$block.addChild( LeafBlockWithLine.build(0,"") );
			}
	(
		join_condition
			{
				$block.addChild( $join_condition.block );
			}
	)?
	| CROSS JOIN table_atom
		{
			$block.addChild( LeafBlockWithoutLine.build(0, getTokenText($CROSS)) );
			$block.addChild( LeafBlockWithoutLine.build(1, getTokenText($JOIN)) );
			
			$table_atom.block.setSpaceCount(1);
			$block.addChild( $table_atom.block); 
				
			$block.addChild( LeafBlockWithLine.build(0,"") );
		}
	(
		join_condition
			{
				$block.addChild( $join_condition.block );
			}
	)?
;

join_condition returns [NonLeafBlock block]
@init
{ $block = new NonLeafBlock(); }
:
	ON top_expr
		{
			$block.addChild( LeafBlockWithoutLine.build(0, getTokenText($ON)) );
			$top_expr.block.setSpaceCount(1);
			$block.addChild($top_expr.block);
		}
	| 
	USING LPAREN column_name_list RPAREN
		{
			$block.addChild( LeafBlockWithoutLine.build(0, getTokenText($USING)) );
			$block.addChild( LeafBlockWithoutLine.build(1, getTokenText($LPAREN)) );
			
			$column_name_list.block.setSpaceCount(1);
			$block.addChild($column_name_list.block);
			
			$block.addChild( LeafBlockWithoutLine.build(1, getTokenText($RPAREN)) );
		}
;

partition_clause returns [NonLeafBlock block]
:
	PARTITION LPAREN partition_names RPAREN
		{
			$block = new NonLeafBlock();
			$block.addChild( LeafBlockWithoutLine.build(0, getTokenText($PARTITION)) );
			$block.addChild( LeafBlockWithoutLine.build(1, getTokenText($LPAREN)) );
			
			$partition_names.block.setSpaceCount(1);
			$block.addChild( $partition_names.block );
			
			$block.addChild( LeafBlockWithoutLine.build(1, getTokenText($RPAREN)) );
		}
;

partition_names returns [NonLeafBlock block]
@init
{ $block = new NonLeafBlock(); }
:
	partition_name
		{
			$block.addChild( $partition_name.block );
		}
	(
		COMMA partition_name
			{
				$block.addChild( LeafBlockWithoutLine.build(0, getTokenText($COMMA)) );		
				$partition_name.block.setSpaceCount(1);
				$block.addChild( $partition_name.block );		
			}
	)*
;

partition_name returns [LeafBlockWithoutLine block]
:
	ID
	{ $block = LeafBlockWithoutLine.build(0, getTokenText($ID));  }

;

subquery returns [NonLeafBlock block]
@init{
	$block=new NonLeafBlock();
}
:
	LPAREN stat RPAREN
	{
		$block.addChild( LeafBlockWithLine.build(0, getTokenText($LPAREN)) );
		
		$stat.block.setSpaceCount(Indent_Space_Count);
		$block.addChild( $stat.block );
		$block.addChild( LineOnlyBlock.buildOne(0) );
		
		$block.addChild( LeafBlockWithoutLine.build(0, getTokenText($RPAREN)) );
	}
;

//TODO
//windows字句暂不支持
//TODO
//row_number() over 支持 distribute by，但是在Hive语法手册中找不到官方正式定义

over_clause returns [NonLeafBlock block]
@init
{ $block = new NonLeafBlock(); }
:
	OVER LPAREN PARTITION BY column_name_list
		{
			$block.addChild( LeafBlockWithoutLine.build(0, getTokenText($OVER)) );
			$block.addChild( LeafBlockWithLine.build(1, getTokenText($LPAREN)) );
			
			$block.addChild( LeafBlockWithoutLine.build(Indent_Space_Count, getTokenText($PARTITION)) );
			$block.addChild( LeafBlockWithLine.build(1, getTokenText($BY)) );
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
		$block.addChild( LeafBlockWithLine.build(0, getTokenText($RPAREN)) );
	}
;
/**
 * case_clause既可以作算术表达式，又可以做逻辑表达式放到where里面
 */
case_clause returns [NonLeafBlock block]
@init
{ $block = new NonLeafBlock(); }
:
	CASE
		{ $block.addChild( LeafBlockWithLine.build(0, getTokenText($CASE)) ); }
	(
		WHEN top_expr THEN top_expr
			{
				$block.addChild( LeafBlockWithoutLine.build(Indent_Space_Count, getTokenText($WHEN)) );
				
				$top_expr.block.setSpaceCount(Indent_Space_Count);
				$block.addChild($top_expr.block);
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
@init
{ $block = new NonLeafBlock(); }
:
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
						LeafBlockWithLine.build(0, getTokenText($COMMA))
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