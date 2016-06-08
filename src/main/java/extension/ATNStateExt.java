package extension;

import java.util.Arrays;
import org.antlr.v4.runtime.atn.ATNState;
import org.slf4j.Logger;

import hivesql.analysis.parse.HiveSQLLexer;
import hivesql.analysis.parse.HiveSQLParser;

public class ATNStateExt {
	public static void showTransitions(ATNState atnS, Logger logger, int level, boolean filterEpsilon) {
		if(atnS==null || level==0) 
			return;
		Arrays.asList(atnS.getTransitions()).stream().forEach(
				transition -> {
					boolean shouldLog = filterEpsilon==false || (filterEpsilon && transition.isEpsilon()==false);
					if(shouldLog){
						logger.info("event_name=transition_desc isEpsilon={} label={}  source_atn_state={} target_atn_state={} target_rule={}",
								transition.isEpsilon(),
								IntervalExt.toTokens(transition.label(), HiveSQLLexer.tokenNames).reduce((a, b) -> a + " , " + b),
								atnS.stateNumber,
								transition.target.stateNumber, HiveSQLParser.ruleNames[transition.target.ruleIndex]
						);
					}
					showTransitions(transition.target, logger, level-1, filterEpsilon);
				}
		);
	}
	
}
