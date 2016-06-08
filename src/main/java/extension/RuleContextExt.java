package extension;

import java.util.ArrayList;
import java.util.List;

import org.antlr.v4.runtime.RuleContext;

public class RuleContextExt {
	public static List<RuleContext> getRuleContextChainBottomUp(RuleContext ruleCtx) {
		List<RuleContext> lst = new ArrayList<RuleContext>();
		while (ruleCtx != null) {
			lst.add(ruleCtx);
			ruleCtx = ruleCtx.getParent();
		}
		return lst;
	}
}
