package hivesql.analysis;

import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.RuleContext;
import org.apache.commons.collections4.map.LinkedMap;
import org.apache.commons.collections4.map.MultiKeyMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import hivesql.analysis.parse.HiveSQLParser.Select_clauseContext;
import hivesql.analysis.parse.HiveSQLParser.StatContext;

public class SelectClauseSegregator {
	private static final Logger LOGGER = LoggerFactory.getLogger(SelectClauseSegregator.class);

	

	/**
	 * 将Parse树中的select/stat语句剥离开，每一个层次的select语句都有一个层号number、同一层次内的排序number。
	 * 例如，对于一个包含union all的stat语句，
	 * 1. 它的层次number是1，排序number是1。每一个被union的select语句，层次number都是2，排序number由上到下开始从1数。
	 * 2. stat语句中的每一个select语句，都会被一个SelectIDNode结点代替。这个SelectIDNode结点中包含原select语句的层次number、排序number。
	 * @param topContext
	 * @return map key: level number
	 */
	
	public static MultiKeyMap<Integer, RuleContext> segregate(ParserRuleContext topContext) {
		return subSegregate(topContext, 1, 1, 0);
	}

	private static MultiKeyMap<Integer, RuleContext> subSegregate(ParserRuleContext ctx, int levelNum, int childIndex, int orderNumInSameLevelOfThisNode) {
		MultiKeyMap<Integer, RuleContext> m = MultiKeyMap.multiKeyMap(new LinkedMap<>());
		if (ctx instanceof StatContext || ctx instanceof Select_clauseContext) {

			m.put(levelNum, orderNumInSameLevelOfThisNode, ctx);

			//Replace with SelectIDNode
			if(ctx.getParent()!=null){
				ctx.getParent().children.set(childIndex, new SelectIDNode(levelNum, orderNumInSameLevelOfThisNode));
			}

			levelNum++;
		} 
		
		int orderNumInSameLevel=0;
		for (int i = 0; i < ctx.children.size(); i++) {
			if(ctx.getChild(i) instanceof ParserRuleContext){
				ParserRuleContext subCtx = (ParserRuleContext) ctx.getChild(i);
				m.putAll(subSegregate((ParserRuleContext) subCtx, levelNum, i, orderNumInSameLevel));
				orderNumInSameLevel++;
			}else{
				LOGGER.debug("event_name=skip_node value={}", ctx.getChild(i).getText());
			}
		}
		return m;
	}

}
