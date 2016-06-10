package hivesql.analysis;

import java.util.UUID;

import org.antlr.v4.runtime.ParserRuleContext;
import org.apache.commons.collections4.map.LinkedMap;
import org.apache.commons.collections4.map.MultiKeyMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import hivesql.analysis.parse.HiveSQLParser.Select_clauseContext;
import hivesql.analysis.parse.HiveSQLParser.StatContext;

@SuppressWarnings("rawtypes")
public class SelectClauseSegregator {
	private static final Logger LOGGER = LoggerFactory.getLogger(SelectClauseSegregator.class);

	
	private static UUID uuid;

	/**
	 * @param topContext
	 * @return map key: level number
	 */
	
	public static MultiKeyMap segregate(ParserRuleContext topContext) {
		uuid = UUID.randomUUID();
		return subSegregate(topContext, 1, 1, 0);
	}

	@SuppressWarnings("unchecked")
	private static MultiKeyMap subSegregate(ParserRuleContext ctx, int levelNum, int childIndex, int orderNumInSameLevelOfThisNode) {
		MultiKeyMap m = MultiKeyMap.multiKeyMap(new LinkedMap());
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

	public static UUID getUuid() {
		return uuid;
	}

	public static void setUuid(UUID uuid) {
		SelectClauseSegregator.uuid = uuid;
	}
}
