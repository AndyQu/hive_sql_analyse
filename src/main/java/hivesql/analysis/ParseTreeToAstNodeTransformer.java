package hivesql.analysis;

import java.util.Arrays;

import org.antlr.v4.runtime.InterpreterRuleContext;
import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.RuleContext;
import org.antlr.v4.runtime.RuleContextWithAltNum;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.tree.ErrorNodeImpl;
import org.antlr.v4.runtime.tree.ParseTree;
import org.antlr.v4.runtime.tree.TerminalNodeImpl;

import ch.qos.logback.core.joran.spi.InterpretationContext;
import common.ast.AstNode;
import common.ast.Interval;
import hivesql.analysis.node.AstNodeType;
import hivesql.analysis.node.MyAstNode;

public class ParseTreeToAstNodeTransformer {
	public static AstNode transform(ParseTree ctx){
		return subTransform(ctx, null);
	}
	
	private static AstNode subTransform(ParseTree ctx, AstNode parent){
		MyAstNode resultNode = new MyAstNode();
		resultNode.setParent(parent);
		resultNode.setSourceInterval(
				new Interval(ctx.getSourceInterval().a, ctx.getSourceInterval().b)
		);
		if(ctx instanceof ErrorNodeImpl){
			ErrorNodeImpl eNode = (ErrorNodeImpl)ctx;
			resultNode.setNodeType(AstNodeType.Error);
			resultNode.setTokens(Arrays.asList(new Token[]{eNode.symbol}));
			return resultNode;
		}else if(ctx instanceof TerminalNodeImpl){
			TerminalNodeImpl tNode = (TerminalNodeImpl)ctx;
			resultNode.setNodeType(AstNodeType.Terminal);
			resultNode.setTokens(Arrays.asList(new Token[]{tNode.symbol}));
		}else if(ctx instanceof InterpreterRuleContext){
			
		}else if(ctx instanceof RuleContextWithAltNum){
			
		}else if(ctx instanceof ParserRuleContext){
			
		}else if(ctx instanceof RuleContext){
			
		}
		return null;
	}
}
