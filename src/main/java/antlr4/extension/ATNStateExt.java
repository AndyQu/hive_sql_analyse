package antlr4.extension;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

import org.antlr.v4.runtime.atn.ATNState;
import org.antlr.v4.runtime.atn.Transition;
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
	
	public static Set<Transition> getNonEpsilonTransitions(ATNState curState, Logger logger){
		Set<ATNState> visitedStates=new HashSet<ATNState>();
		Set<Transition> s = new HashSet<Transition>();
		Arrays.asList(curState.getTransitions()).forEach(
				t->s.addAll(getNextNonEpsilonTransitions(visitedStates, t, logger))
		);
		return s;
	}
	
	public static Set<Transition> getNextNonEpsilonTransitions(Set<ATNState>visitedStates, Transition t, Logger logger){
		Set<Transition> s = new HashSet<Transition>();
		logger.debug("event_name=check_state state_number={}", t.target.stateNumber);
		if(t.isEpsilon()==false){
			if(!visitedStates.contains(t.target)){
				visitedStates.add(t.target);
				logger.debug("event_name=add_state state_number={}", t.target.stateNumber);
				s.add(t);
			}else{
				logger.debug("event_name=already_visited_state state_number={}", t.target.stateNumber);
			}
		}else{
			logger.debug("event_name=check_sub_states");
			Arrays.asList(t.target.getTransitions()).stream().forEach(
					t1->{
						s.addAll(getNextNonEpsilonTransitions(visitedStates, t1, logger));
					}
			);
		}
		return s;
	}
	
}
