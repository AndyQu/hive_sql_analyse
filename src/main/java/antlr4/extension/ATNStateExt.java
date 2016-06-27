package antlr4.extension;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Optional;
import java.util.Set;

import org.antlr.v4.runtime.Recognizer;
import org.antlr.v4.runtime.Vocabulary;
import org.antlr.v4.runtime.atn.ATNState;
import org.antlr.v4.runtime.atn.Transition;
import org.slf4j.Logger;

import hivesql.analysis.parse.HiveSQLParser;

public class ATNStateExt {
	public static void showTransitions(ATNState atnS, Logger logger, int level, boolean filterEpsilon, Vocabulary voc) {
		if (atnS == null || level == 0)
			return;
		Arrays.asList(atnS.getTransitions()).stream().forEach(transition -> {
			boolean shouldLog = filterEpsilon == false || (filterEpsilon && transition.isEpsilon() == false);
			if (shouldLog) {
				logger.info(
						"event_name=transition_desc isEpsilon={} label={}  source_atn_state={} target_atn_state={} target_rule={}",
						transition.isEpsilon(),
						IntervalExt.toTokens(transition.label(), voc).stream().reduce((a, b) -> a + " , " + b),
						atnS.stateNumber, 
						transition.target.stateNumber,
						HiveSQLParser.ruleNames[transition.target.ruleIndex]);
			}
			showTransitions(transition.target, logger, level - 1, filterEpsilon, voc);
		});
	}

	public static Set<Transition> getNonEpsilonTransitions(ATNState curState, Recognizer<?, ?> recognizer, Logger logger) {
		Set<ATNState> visitedStates = new HashSet<ATNState>();
		visitedStates.add(curState);
		Set<Transition> s = new HashSet<Transition>();
		Arrays.asList(curState.getTransitions())
				.forEach(t -> s.addAll(getNextNonEpsilonTransitions(visitedStates, t, recognizer, logger, 1)));
		return s;
	}

	public static Set<Transition> getNextNonEpsilonTransitions(Set<ATNState> visitedStates, Transition t, Recognizer<?, ?> recognizer,
			Logger logger, int level) {
		String spaces = StringExt.buildSpaces(level*2);
		// 加入visited states
		logger.debug( spaces + "access state {}", t.target.stateNumber);
		if (!visitedStates.contains(t.target)) {
			visitedStates.add(t.target);
			logger.debug( spaces + "state {} not visited yet, add it", t.target.stateNumber);
		} else {
			logger.debug( spaces + "state {} already visitedstate_number", t.target.stateNumber);
		}

		Set<Transition> s = new HashSet<Transition>();
		if (t.isEpsilon()) {
			logger.debug( spaces + "state {} is non-terminal state. Access its children recursively", t.target.stateNumber);
			Arrays.asList(t.target.getTransitions()).stream().forEach(t1 -> {
				s.addAll(getNextNonEpsilonTransitions(visitedStates, t1, recognizer, logger, level+1));
			});
		} else {
			Optional<String> text = IntervalExt.toTokens(t.label(), recognizer.getVocabulary()).stream().reduce((String a, String b) -> a + " , " + b);
			logger.debug( spaces + "state {} is terminal state. add this transition {}", t.target.stateNumber, text);
			// 如果 消耗字符，则加入到 transition set中
			s.add(t);
		}
		return s;
	}

}
