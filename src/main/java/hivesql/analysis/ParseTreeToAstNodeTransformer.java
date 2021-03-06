package hivesql.analysis;

import java.util.ArrayList;
import java.util.List;

import org.antlr.v4.runtime.CommonToken;
import org.antlr.v4.runtime.InterpreterRuleContext;
import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.RuleContext;
import org.antlr.v4.runtime.TokenStream;
import org.antlr.v4.runtime.tree.ErrorNodeImpl;
import org.antlr.v4.runtime.tree.ParseTree;
import org.antlr.v4.runtime.tree.TerminalNodeImpl;
import org.apache.commons.collections4.keyvalue.MultiKey;
import org.apache.commons.collections4.map.LinkedMap;
import org.apache.commons.collections4.map.MultiKeyMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import common.ast.AstNode;
import common.ast.Interval;
import hivesql.analysis.node.AstNodeType;
import hivesql.analysis.node.MyAstNode;
import hivesql.analysis.node.ReferenceNode;

public class ParseTreeToAstNodeTransformer {
	private static final Logger LOGGER = LoggerFactory.getLogger(ParseTreeToAstNodeTransformer.class);
	private static final Gson gson = new GsonBuilder().setPrettyPrinting().create();


	public static MultiKeyMap<Integer, MyAstNode> transform(MultiKeyMap<Integer, RuleContext> mm, String[] ruleNames,TokenStream tokenStream) {
		MultiKeyMap<Integer, MyAstNode> resultM = MultiKeyMap.multiKeyMap(new LinkedMap<>());

		mm.entrySet().stream().forEach(entry->{
			MultiKey<? extends Integer> key = entry.getKey();
			ParserRuleContext value = (ParserRuleContext) entry.getValue();
			resultM.put(key.getKey(0), key.getKey(1), transform(value, ruleNames, tokenStream));
		});
		
		return resultM;
	}
	
	public static MyAstNode transform(ParseTree ctx, String[] ruleNames, TokenStream tokenStream) {
		return subTransform(ctx, null, ruleNames, tokenStream);
	}

	private static MyAstNode subTransform(ParseTree ctx, AstNode parent, String[] ruleNames, TokenStream tokenStream) {
		MyAstNode resultNode = new MyAstNode();
		resultNode.setParent(parent);
		resultNode.setSourceInterval(new Interval(ctx.getSourceInterval().a, ctx.getSourceInterval().b));
		if (ctx instanceof ErrorNodeImpl) {
			resultNode.setNodeType(AstNodeType.Error);
			CommonToken t = (CommonToken)((ErrorNodeImpl)ctx).getPayload();
			t.setText(tokenStream.getText(ctx.getSourceInterval()));
			resultNode.setToken(t);
		} else if (ctx instanceof TerminalNodeImpl) {
			resultNode.setNodeType(AstNodeType.Terminal);
			CommonToken t = (CommonToken)((TerminalNodeImpl)ctx).getPayload();
			t.setText(tokenStream.getText(ctx.getSourceInterval()));
			resultNode.setToken(t);
		} else if(ctx instanceof SelectIDNode){
			SelectIDNode snode=(SelectIDNode)ctx;
			resultNode = new ReferenceNode();
			resultNode.setParent(parent);
			resultNode.setNodeType(AstNodeType.Reference);
			((ReferenceNode)resultNode).setLeveNum(snode.getLeveNum());
			((ReferenceNode)resultNode).setOrderNumInSameLevel(snode.getOrderNumInSameLevel());
			
		} else if (ctx instanceof InterpreterRuleContext 
//				|| ctx instanceof RuleContextWithAltNum
				|| ctx instanceof ParserRuleContext || ctx instanceof RuleContext) {
			RuleContext pctx = (RuleContext) ctx;
			resultNode.setNodeType(AstNodeType.Non_Terminal);
			resultNode.setName(ruleNames[pctx.getRuleIndex()]);
			//construct child nodes
			List<AstNode> childs = new ArrayList<AstNode>();
			for(int i=0;i<pctx.getChildCount();i++){
				ParseTree child=pctx.getChild(i);
				childs.add(subTransform(child, resultNode, ruleNames, tokenStream));
			}
			resultNode.setChildren(childs);
		} 
		LOGGER.debug("event_name=transform_node_done node_json=\n{}", gson.toJson(resultNode));
		return resultNode;
	}
}
