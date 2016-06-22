parser grammar HiveSQLParser;

@header {
package hivesql.analysis.parse;

import java.util.*;

import hivesql.analysis.format.*;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
    
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
}

options
 {
	tokenVocab = HiveSQLLexer;
}

@members {
    private static Logger LOGGER = LoggerFactory.getLogger(HiveSQLParser.class);
    private static Gson gson = new GsonBuilder().setPrettyPrinting().create();
	public static final int Indent_Space_Count=2;
	public String getTokenText(Token t) {
		
		return getTokenStream().getText(new Interval(t.getTokenIndex(), t.getTokenIndex()));
	}
	
	public Block buildFromToken(int spaces, Token t){
			String tokenText = getTokenText(t);
			String comment = getComment(t);
			if(comment==null||comment.equals("")){
				return LeafBlockWithoutLine.build(spaces, tokenText);
			}else{
				NonLeafBlock block = new NonLeafBlock("token-comment");
				block.addChild(BlockTool.buildLine(spaces, tokenText+" "+comment));
				return block;
			}
		}
	
	public String getComment(Token t){
			BufferedTokenStream ts = (BufferedTokenStream)getTokenStream();
			List<Token> tl = ts.getHiddenTokensToRight(t.getTokenIndex(), HiveSQLLexer.Channel_Comment);
			if(tl!=null && tl.size()>0){
				return getTokenText(tl.get(0));
			}else{
				return null;
			}
		}
	
	public Map<String, Boolean> existContext(RuleContext ctx, String[] contexes){
		Map<String, Boolean> ret = new HashMap<String, Boolean>();
		Set<String> ctxSet = new HashSet<String>();
		ctxSet.addAll(Arrays.asList(contexes));
		while(ctx!=null){
			if(ctxSet.contains(ruleNames[ctx.getRuleIndex()])){
				ret.put(ruleNames[ctx.getRuleIndex()], Boolean.TRUE);
			}
			ctx = ctx.getParent();
		}
		return ret;
	}
}

stat returns [NonLeafBlock block]
@init
{ 
	$block = new NonLeafBlock("stat"); 
	Boolean hasUnion = false;
}
:
	select_clause
	{ $block.addChild( $select_clause.block);    		}

	(
		UNION
		{ 
			hasUnion=true;
			$block.addChild( LineOnlyBlock.build());
			$block.addChild(buildFromToken(0,($UNION)));
		}

		(
			ALL
			{ $block.addChild(buildFromToken(1,($ALL))); }

			| DISTINCT
			{ $block.addChild(buildFromToken(1,($DISTINCT))); }

		)?
		{ 
			$block.addChild( LineOnlyBlock.build(0,1) );
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
{ $block = new NonLeafBlock("select_clause"); }
:
	SELECT selected_column_list
		{ 
			$block.addChild(buildFromToken(0, ($SELECT)));
			$block.addChild( LineOnlyBlock.build() );
			
			$selected_column_list.block.setSpaceCount(Indent_Space_Count);
			$block.addChild($selected_column_list.block);
			
			$block.addChild( LineOnlyBlock.build() );
		}
	(
		FROM table_references
		{
			$block.addChild(buildFromToken(0, ($FROM)));
			$block.addChild( LineOnlyBlock.build() );
			
			Block b1 = $table_references.block;
			b1.setSpaceCount(Indent_Space_Count);
			$block.addChild(b1);
		}
	)?
	(
		where_clause
		{
			$block.addChild( LineOnlyBlock.build() );
			$block.addChild( $where_clause.block );
		}
	)?
	(
		GROUP BY group_by_clause
		{
			$block.addChild( LineOnlyBlock.build() );
			$block.addChild(buildFromToken(0, $GROUP));
			$block.addChild(buildFromToken(1, $BY));
			$block.addChild( LineOnlyBlock.build() );
			
			$group_by_clause.block.setSpaceCount(Indent_Space_Count);
			$block.addChild($group_by_clause.block);
		}
	)?
	(
		CLUSTER BY cluster_clause
		{
			$block.addChild( LineOnlyBlock.build() );
			$block.addChild(buildFromToken(0, $CLUSTER));
			$block.addChild(buildFromToken(1, $BY));
			$block.addChild( LineOnlyBlock.build() );
			
			$cluster_clause.block.setSpaceCount(Indent_Space_Count);
			$block.addChild($cluster_clause.block);
		}
	)?
	(
		DISTRIBUTE BY distribute_clause
		{
			$block.addChild( LineOnlyBlock.build() );
			
			$block.addChild(buildFromToken(0, $DISTRIBUTE));
			$block.addChild(buildFromToken(1, $BY));
			$block.addChild( LineOnlyBlock.build() );
			
			$distribute_clause.block.setSpaceCount(Indent_Space_Count);
			$block.addChild($distribute_clause.block);
		}
	)?
	(
		SORT BY sort_clause
		{
			$block.addChild( LineOnlyBlock.build() );
			$block.addChild(buildFromToken(0, $SORT));
			$block.addChild(buildFromToken(1, $BY));
			$block.addChild( LineOnlyBlock.build() );
			
			$sort_clause.block.setSpaceCount(Indent_Space_Count);
			$block.addChild($sort_clause.block);
		}
	)? SEMI_COLON?
;

where_clause returns [NonLeafBlock block]
@init
{ $block = new NonLeafBlock("where_clause"); }
:
WHERE logic_expr
		{
			$block.addChild(buildFromToken(0, ($WHERE)));
			$block.addChild( LineOnlyBlock.build() );
			
			$logic_expr.block.setSpaceCount(Indent_Space_Count);
			$block.addChild($logic_expr.block);
		}
;

schema_name returns [Block block]
:
	ID
	{
   	$block = buildFromToken(0,$ID);
   }

;

table_name returns [NonLeafBlock block]
@init
{ $block = new NonLeafBlock("table_name"); }
:
	(
		schema_name DOT
		{
   		$block.addChild($schema_name.block);
   		$block.addChild(buildFromToken(0,($DOT)));
   	}

	)? ID
	{
   		$block.addChild(buildFromToken(0,($ID)));
   }

;

//TODO
/**
 * 1. 这里暂时把distinct关键字放在这里，实际上是不对的。column_name从概念上讲不应该包括“distinct”这样的修饰符
 * 2. '*' 也暂时放在这里
 */
full_column_name returns [NonLeafBlock block]
@init
{ $block = new NonLeafBlock("full_column_name"); }
:
	(
		DISTINCT
		{
			$block.addChild(buildFromToken(0,($DISTINCT)));
			$block.addChild(LeafBlockWithoutLine.build(1));
		}

	)?
	(
		table_name DOT
		{
   			$block.addChild($table_name.block);
   			$block.addChild(buildFromToken(0,($DOT)));
   		}

	)? simple_column_name
	{
   		$block.addChild($simple_column_name.block);
    }

;

simple_column_name returns [Block block]
:
	ID
	{	
		//LOGGER.info("event_name=simple_column_name value={}", ($ID) );
		$block=buildFromToken(0,($ID));
	}

	| ASTERISK
	{	$block=buildFromToken(0,($ASTERISK));}

	| BACK_QUOTE ID BACK_QUOTE
		{	
			$block=new NonLeafBlock("simple_column_name");
			((NonLeafBlock)$block).addChild( 
				LeafBlockWithoutLine.build(
					0, 
					String.format("%s%s", 
						getTokenText($BACK_QUOTE), 
						getTokenText($ID) 
					)
				)
			);
			((NonLeafBlock)$block).addChild( buildFromToken(0, $BACK_QUOTE) );
		}

	| BACK_QUOTE ASTERISK BACK_QUOTE
		{	
			$block=new NonLeafBlock("simple_column_name");
			((NonLeafBlock)$block).addChild( 
				LeafBlockWithoutLine.build(
					0, 
					String.format("%s%s", 
						getTokenText($BACK_QUOTE), 
						getTokenText($ASTERISK) 
					)
				)
			);
			((NonLeafBlock)$block).addChild( buildFromToken(0, $BACK_QUOTE) );
		}

;

subquery_alias returns [NonLeafBlock block]
:
	common_alias
	{$block=$common_alias.block;}

;

table_name_alias returns [NonLeafBlock block]
:
	common_alias
	{$block=$common_alias.block;}

;

column_name_alias returns [NonLeafBlock block]
:
	common_alias
	{$block=$common_alias.block;}

;

common_alias returns [NonLeafBlock block]
@init{ $block = new NonLeafBlock("common_alias"); }
:
	(AS
		{ $block.addChild( buildFromToken(0, $AS) ); }
	)
	? ID
	{
   		$block.addChild( buildFromToken(1, $ID) );
   }

;

selected_column returns [NonLeafBlock block]
@init
{ $block = new NonLeafBlock("selected_column"); }
:
	(
		element_operand
			{
				$block.addChild( $element_operand.block );
			}
		| arith_expr
			{
				$block=$arith_expr.block;
			}
		|
		(
			func_call
				{
					$block.addChild($func_call.block);
				}
			(function_over_clause
				{
					$block.addChild($function_over_clause.block);
				}
			)?
		)
		
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
{ $block = new NonLeafBlock("selected_column_list"); }
:
selected_column
		{
			$block.addChild($selected_column.block);
		}
(
	COMMA selected_column
			{
				$block.addChild(
					buildFromToken(0, ($COMMA))
				);
				$block.addChild( LineOnlyBlock.build() );
				$block.addChild($selected_column.block);
			}
)*
;

column_name_list returns [NonLeafBlock block]
@init
{ $block = new NonLeafBlock("column_name_list"); }
:
	full_column_name
		{ 
			$block.addChild($full_column_name.block);
			
		}
	(
		COMMA full_column_name
			{	
				$block.addChild(buildFromToken(0, ($COMMA)));
				$block.addChild( LineOnlyBlock.build() );
				
				$block.addChild( $full_column_name.block);
			}
	)*
	{
   		$block.addChild( LineOnlyBlock.build() );
   }

;






element_operand returns [Block block]
:
	full_column_name
		{ 
			$block = $full_column_name.block;
			//LOGGER.info("event_name=non_arith_expr value={}", gson.toJson($block) );
		}
	| DOUBLE
		{ $block = buildFromToken(0,($DOUBLE)); }
	| INT
		{ $block = buildFromToken(0,($INT)); }
	| STRING
		{ $block = buildFromToken(0,($STRING)); }
;

//======================================逻辑表达式==========================================

logic_operand returns [NonLeafBlock block]
:
relation_expr { $block = $relation_expr.block; }
|
func_call { $block=$func_call.block; }
;

logic_component returns [NonLeafBlock block]
:
logic_operand
	{ $block=$logic_operand.block; }
;

/**
 * logic_expr 这里特指带有逻辑运算符(and or not)的表达式
 */
logic_expr returns [NonLeafBlock block]
@init
{ $block = new NonLeafBlock("logic_expr"); }
:
	logic_component
		{ $block=$logic_component.block; }
	|
	LPAREN logic_expr RPAREN
		{
			$block.addChild( buildFromToken(0, ($LPAREN)) );
			
			_localctx.logic_expr.block.setSpaceCount( Indent_Space_Count );
			$block.addChild( _localctx.logic_expr.block );
			
			$block.addChild( buildFromToken(0,($RPAREN)) );
		}
	|
	logic_expr
		{
			/*
			    加这一句是为了让antlr4生成
			        ((Top_exprContext)_localctx).top_expr = top_expr(0);
			    否则, antlr4 只会生成
			        top_expr(0);
			*/
			    
			Logic_exprContext ctx =(Logic_exprContext) getContext().getChild(0);
	        if($block==null) 
	        	$block = new NonLeafBlock("logic_expr");
			$block.addChild( ctx.block );
			$block.addChild( LineOnlyBlock.build() );
		}
	logic_op logic_expr
		{
			$block.addChild( $logic_op.block );
			$block.addChild( LineOnlyBlock.build() );
			
			$block.addChild( _localctx.logic_expr.block );
			$block.addChild( LineOnlyBlock.build() );
		}
	|
	NOT logic_expr
		{
			$block.addChild( buildFromToken(0,($NOT)) );
			
			$logic_expr.block.setSpaceCount(Indent_Space_Count);
			$block.addChild( ((Logic_exprContext)_localctx).logic_expr.block );
		}
	
;

//==================================算术表达式========================================================
arith_operand returns [Block block]

:
	func_call
		{ $block=$func_call.block ; }
	|
	element_operand
		{
			$block=$element_operand.block;
		}
;

arith_component returns [Block block]
:
arith_operand 
	{ $block = $arith_operand.block; }
;

arith_expr returns [NonLeafBlock block]
@init{
	$block = new NonLeafBlock("arith_expr");
}
:
	arith_component 
		{ $block.addChild( $arith_component.block ); }
	|
	LPAREN arith_expr RPAREN
		{
			if($arith_expr.block==null){
				$arith_expr.block = new NonLeafBlock("arith_expr");
			}
			
			$block.addChild( buildFromToken(1,($LPAREN)) );
			$block.addChild( _localctx.arith_expr.block );
			$block.addChild( buildFromToken(1,($RPAREN)) );
		}
	|
	arith_expr
		{
			Arith_exprContext ctx =(Arith_exprContext) getContext().getChild(0);
	        if($block==null) 
	        	$block = new NonLeafBlock("arith_expr");
			$block.addChild( ctx.block );
		}
	arith_binary_op 	arith_expr
		{
			$arith_binary_op.block.setSpaceCount(1);
			$block.addChild( $arith_binary_op.block  );
				
			_localctx.arith_expr.block.setSpaceCount(1);
			$block.addChild( _localctx.arith_expr.block );
		}
;

//=========================================关系表达式=================================================

relation_operand returns [Block block]

:
	arith_expr
		{ $block= $arith_expr.block; }
	|
	func_call
		{ $block=$func_call.block ; }
	|
	element_operand
		{
			$block=$element_operand.block;
		}
;

relation_expr returns [NonLeafBlock block]
@init{
	$block = new NonLeafBlock("relation_expr");
}
:
relation_operand 
	{ $block.addChild( $relation_operand.block ); }
relational_op 
	{ 
		$relational_op.block.setSpaceCount(1);
		$block.addChild( $relational_op.block );
	}
relation_operand
	{ 
		$relation_operand.block.setSpaceCount(1);
		$block.addChild( $relation_operand.block );
	}
|
relation_operand
		{
        	$block.addChild( $relation_operand.block );
        }
	BETWEEN relation_operand
		{
			$block.addChild( buildFromToken(1,($BETWEEN)) );
			
			$relation_operand.block.setSpaceCount(1);
			$block.addChild($relation_operand.block);
		}
	AND relation_operand
		{
			$block.addChild( buildFromToken(1,($AND)) );
			
			$relation_operand.block.setSpaceCount(1);
			$block.addChild($relation_operand.block);
		}
|
relation_operand is_or_is_not NULL
		{
            $block.addChild( $relation_operand.block );
			
			$is_or_is_not.block.setSpaceCount(1);
			$block.addChild($is_or_is_not.block);
			
			$block.addChild( buildFromToken(1,($NULL)) );
		}
;

//=========================================函数=================================================
func_call returns [NonLeafBlock block]
@init
{ $block = new NonLeafBlock("func_call"); }
:
func_name LPAREN 
		{
			$block.addChild($func_name.block);
			$block.addChild( buildFromToken(0,($LPAREN)) );
		}
(func_para_list
		{
			$block.addChild( $func_para_list.block );
		}
)? 
RPAREN
		{
			$block.addChild( buildFromToken(0,($RPAREN)) );
		}
|
	case_clause
		{ 
			Map<String, Boolean> ret = existContext(getRuleContext(), new String[]{"func_para"});
			/**
			 * where语句中可能存在一个函数调用x(),x的参数是case_clause，这个时候要加一个空行。因此，不能通过判断父context是否存在where_clause来决定；而是根据父context是否存在func_para来决定。
			 */
			if(ret.containsKey("func_para")){
				$block.addChild( LineOnlyBlock.build() );
			}
			$case_clause.block.setSpaceCount(Indent_Space_Count);
			$block.addChild( $case_clause.block );
		}
;



func_name returns [Block block]
:
	ID { $block = buildFromToken(0,$ID); }
;

//函数参数可以是任意表达式：关系表达式、逻辑表达式、算术表达式、函数调用
func_para returns [NonLeafBlock block]
:
	top_expr { $block = $top_expr.block; }
;

func_para_list returns [NonLeafBlock block]
@init
{ $block = new NonLeafBlock("func_para_list"); }
:
	func_para
		{
			$block.addChild( $func_para.block);
		}
	(
		COMMA func_para
			{
				$block.addChild( buildFromToken(0,($COMMA)) ) ;
				$func_para.block.setSpaceCount(1);
				$block.addChild( $func_para.block );
			}
	)*
;

//=========================================最高层的抽象表达式=================================================


top_expr returns [NonLeafBlock block]
@init{ $block = new NonLeafBlock("top_expr"); }
:
logic_expr { $block = $logic_expr.block; }
|
arith_expr { $block = $arith_expr.block; }
|
func_call { $block = $func_call.block; }
|
relation_expr { $block= $relation_expr.block; }
|
element_operand { $block.addChild( $element_operand.block ); }
;

//=========================================运算符=================================================

/* 这里注意排序，因为影响parse优先级 */
arith_binary_op returns [Block block]
:
	POWER_OP
		{ $block = buildFromToken(0,($POWER_OP)); }
	| DIVIDE
		{ $block = buildFromToken(0,($DIVIDE)); }
	| MOD
		{ $block = buildFromToken(0,($MOD)); }
	| ASTERISK
		{ $block = buildFromToken(0,($ASTERISK)); }
	| PLUS
		{ $block = buildFromToken(0,($PLUS)); }
	| MINUS
		{ $block = buildFromToken(0,($MINUS)); }
;

relational_op returns [Block block]
:
	DOUBLE_EQ
		{ $block = buildFromToken(0,($DOUBLE_EQ)); }
	| EQ
		{ $block = buildFromToken(0,($EQ)); }
	| LTH
		{ $block = buildFromToken(0,($LTH)); }
	| GTH
		{ $block = buildFromToken(0,($GTH)); }
	| NOT_EQ
		{ $block = buildFromToken(0,($NOT_EQ)); }
	| LET
		{ $block = buildFromToken(0,($LET)); }
	| GET
		{ $block = buildFromToken(0,($GET)); }
;



logic_op returns [Block block]
:
	AND
		{ $block = buildFromToken(0,($AND)); }
	| 
	OR
		{ $block = buildFromToken(0,($OR)); }
;

is_or_is_not returns [NonLeafBlock block]
@init{ $block = new NonLeafBlock("is_or_is_not"); }
:
	IS
		{ $block.addChild( buildFromToken(0, $IS)); }
	| IS NOT
		{ 
			$block.addChild( buildFromToken(0,$IS ) );
			$block.addChild( buildFromToken(1,$NOT ) );
		}
;

//=========================================表达式 结束=================================================

table_references returns [NonLeafBlock block]
@init
{ $block = new NonLeafBlock("table_references"); }
:
	table_atom
		{ $block.addChild( $table_atom.block ); }
	(
		(
			COMMA table_atom
				{
					$block.addChild( buildFromToken(0, ($COMMA)) );
					$block.addChild( $table_atom.block );
				}
		)
		| 
		join_clause
			{
				$block.addChild( LineOnlyBlock.build());
				$block.addChild( $join_clause.block );
			}
	)*
;

table_atom returns [NonLeafBlock block]
@init
{ $block = new NonLeafBlock("table_atom"); }
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
;

join_clause returns [NonLeafBlock block]
@init
{ $block = new NonLeafBlock("join_clause"); }
:
	(
		(
			LEFT
				{ $block.addChild( buildFromToken(0,($LEFT)) ); }
			| RIGHT
				{ $block.addChild( buildFromToken(0,($RIGHT)) ); }
			| FULL
				{ $block.addChild( buildFromToken(0,($FULL)) ); }
		)
		(
			OUTER
				{ $block.addChild( buildFromToken(1,($OUTER)) ); }
		)?
	)? JOIN table_atom
			{
				$block.addChild( buildFromToken(1,($JOIN)) );

				$block.addChild( LineOnlyBlock.build() );				
//				$table_atom.block.setSpaceCount(1);
				$block.addChild( $table_atom.block); 
				
				$block.addChild( LineOnlyBlock.build() );
			}
	(
		join_condition
			{
				$block.addChild( $join_condition.block );
			}
	)?
	| CROSS JOIN table_atom
		{
			$block.addChild( buildFromToken(0,($CROSS)) );
			$block.addChild( buildFromToken(1,($JOIN)) );
			
			$table_atom.block.setSpaceCount(1);
			$block.addChild( $table_atom.block); 
				
			$block.addChild( LineOnlyBlock.build() );
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
{ $block = new NonLeafBlock("join_condition"); }
:
	ON top_expr
		{
			$block.addChild( buildFromToken(0,($ON)) );
			$top_expr.block.setSpaceCount(1);
			$block.addChild($top_expr.block);
		}
	| 
	USING LPAREN column_name_list RPAREN
		{
			$block.addChild( buildFromToken(0,($USING)) );
			$block.addChild( buildFromToken(1,($LPAREN)) );
			
			$column_name_list.block.setSpaceCount(1);
			$block.addChild($column_name_list.block);
			
			$block.addChild( buildFromToken(1,($RPAREN)) );
		}
;

partition_clause returns [NonLeafBlock block]
@init
{ $block = new NonLeafBlock("partition_clause"); }
:
	PARTITION LPAREN partition_names RPAREN
		{
			$block.addChild( buildFromToken(0,($PARTITION)) );
			$block.addChild( buildFromToken(1,($LPAREN)) );
			
			$partition_names.block.setSpaceCount(1);
			$block.addChild( $partition_names.block );
			
			$block.addChild( buildFromToken(1,($RPAREN)) );
		}
;

partition_names returns [NonLeafBlock block]
@init
{ $block = new NonLeafBlock("partition_names"); }
:
	partition_name
		{
			$block.addChild( $partition_name.block );
		}
	(
		COMMA partition_name
			{
				$block.addChild( buildFromToken(0,($COMMA)) );		
				$partition_name.block.setSpaceCount(1);
				$block.addChild( $partition_name.block );		
			}
	)*
;

partition_name returns [Block block]
:
	ID
	{ $block = buildFromToken(0,($ID));  }

;

subquery returns [NonLeafBlock block]
@init{
	$block=new NonLeafBlock("subquery");
}
:
	LPAREN stat RPAREN
	{
		$block.addChild( buildFromToken(0, ($LPAREN)) );
		$block.addChild( LineOnlyBlock.build() );
		
		$stat.block.setSpaceCount(Indent_Space_Count);
		$block.addChild( $stat.block );
		$block.addChild( LineOnlyBlock.build() );
		
		$block.addChild( buildFromToken(0,($RPAREN)) );
	}
;

//TODO
//windows字句暂不支持
//TODO
//row_number() over 支持 distribute by，但是在Hive语法手册中找不到官方正式定义

function_over_clause returns [NonLeafBlock block]
@init
{ $block = new NonLeafBlock("over_clause"); }
:
	OVER LPAREN PARTITION BY column_name_list
		{
			$block.addChild( buildFromToken(0,($OVER)) );
			$block.addChild( buildFromToken(1, ($LPAREN)) );
			$block.addChild( LineOnlyBlock.build()  );
			
			$block.addChild( buildFromToken(Indent_Space_Count, ($PARTITION)) );
			$block.addChild( buildFromToken(1, ($BY)) );
			$block.addChild( LineOnlyBlock.build()  );
			
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
		$block.addChild( LineOnlyBlock.build() );
		$block.addChild( buildFromToken(0,($RPAREN)) );
	}
;
/**
 * case_clause既可以作算术表达式，又可以做逻辑表达式放到where里面
 */
case_clause returns [NonLeafBlock block]
@init
{ $block = new NonLeafBlock("case_clause"); }
:
	CASE
		{ 
			$block.addChild( buildFromToken(0, ($CASE)) );
		}
	(
		WHEN
			{ $block.addChild( buildFromToken(Indent_Space_Count, ($WHEN)) ); } 
		(
		logic_expr
			{ 
				$logic_expr.block.setSpaceCount(Indent_Space_Count*3);
				$block.addChild($logic_expr.block);
			}
			|
		relation_expr
			{
				$relation_expr.block.setSpaceCount(Indent_Space_Count*3);
				$block.addChild($relation_expr.block);
			}
		) THEN top_expr
			{
				$block.addChild( LineOnlyBlock.build() );
				
				
				$block.addChild( buildFromToken(Indent_Space_Count*2, ($THEN)) );
				
				$top_expr.block.setSpaceCount(Indent_Space_Count*3);
				$block.addChild($top_expr.block);
				$block.addChild( LineOnlyBlock.build() );
			}
	)+ ELSE top_expr 
		{
			$block.addChild( buildFromToken(Indent_Space_Count, ($ELSE)) );
			
			$top_expr.block.setSpaceCount(Indent_Space_Count);
			$block.addChild($top_expr.block);
		}
	END
		{
			$block.addChild( LineOnlyBlock.build() );
			$block.addChild( buildFromToken(0, ($END)) );
		}
;

order_clause returns [NonLeafBlock block]
@init
{ $block = new NonLeafBlock("order_clause"); }
:
ORDER BY ordered_column_name_list 
	{ 
		$block.addChild( buildFromToken(0,($ORDER)) );
		$block.addChild( buildFromToken(1,($BY)) );
		
		$block.addChild( LineOnlyBlock.build() );
		
		$ordered_column_name_list.block.setSpaceCount(Indent_Space_Count);
		$block.addChild( $ordered_column_name_list.block );
	}
;

cluster_clause returns [NonLeafBlock block]
:
	column_name_list 
	{ 
		$block = $column_name_list.block;
	}
;

distribute_clause returns [NonLeafBlock block]
:
	column_name_list 
	{
		$block = $column_name_list.block;
	}
;
group_by_clause returns [NonLeafBlock block]
:
	column_name_list
	{
		$block = $column_name_list.block;
	}
;

sort_clause returns [NonLeafBlock block]
:
ordered_column_name_list { $block=$ordered_column_name_list.block; }
;
ordered_column_name_list returns [NonLeafBlock block]
@init
{ $block = new NonLeafBlock("ordered_column_name_list"); }
:
	full_column_name
		{ $block.addChild($full_column_name.block); }
	(
		DESC
			{ $block.addChild(
					buildFromToken(1,($DESC))
				); 
			}
		| 
		ASC
			{ $block.addChild(
					buildFromToken(1,($ASC))
				); 
			}
	)?
	(
		(
			COMMA full_column_name
				{
					$block.addChild(
						buildFromToken(0, ($COMMA))
					); 
					$block.addChild( LineOnlyBlock.build() );
					$block.addChild($full_column_name.block);
				}
			(
				DESC
					{
						$block.addChild(
							buildFromToken(1,($DESC))
						);
					} 
				| 
				ASC
					{ 
						$block.addChild(
							buildFromToken(1,($ASC))
						); 
					}
			)?
		)
	)*
;