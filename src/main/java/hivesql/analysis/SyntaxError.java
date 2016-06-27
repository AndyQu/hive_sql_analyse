package hivesql.analysis;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.Set;

import org.antlr.v4.runtime.InputMismatchException;
import org.antlr.v4.runtime.Parser;
import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.RecognitionException;
import org.antlr.v4.runtime.Recognizer;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.atn.ATN;
import org.antlr.v4.runtime.atn.ATNState;
import org.antlr.v4.runtime.atn.Transition;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import antlr4.extension.ATNStateExt;
import antlr4.extension.IntervalExt;

import org.apache.commons.lang3.tuple.Pair;

public class SyntaxError {
	private static final Logger LOGGER = LoggerFactory.getLogger(SyntaxError.class);
	
	private Object offendingSymbol;
	private int line;
	private int charPositionInLine;
	private String msg;
	private RecognitionException e;
	
	private Set<Transition> nonEpsilonTransitions;
	private List<Pair<Token, String>> errorList = new ArrayList<Pair<Token, String>>();

	public SyntaxError(Parser parser, Recognizer<?, ?> recognizer, Object offendingSymbol, int line, int charPositionInLine,
			String msg, RecognitionException e) {
		this.offendingSymbol = offendingSymbol;
		this.line = line;
		this.charPositionInLine = charPositionInLine;
		this.msg = msg;
		this.e = e;
		
		List<String> stack = ((Parser)recognizer).getRuleInvocationStack(); 
		Collections.reverse(stack);
		LOGGER.error("\nevent_name=syntax_error line={} char_position={} msg={} token={} rule_stack={}",
				line, 
				charPositionInLine, 
				msg, 
				offendingSymbol,
				stack
		);
		
		if(e==null || !(e instanceof InputMismatchException)){
			LOGGER.error("event_name=RecognitionException_is_null");
			return;
		}
		
		this.ruleCtx = (ParserRuleContext)e.getCtx();
		
		ATN atn = parser.getATN();
		this.curState = atn.states.get(e.getOffendingState());
		LOGGER.info("atn_state={} offending_state={}",curState.stateNumber, e.getOffendingState());
		
		
		List<String> expectedTokens = IntervalExt.toTokens(e.getExpectedTokens(), recognizer.getVocabulary());
		LOGGER.error("event_name=syntax_error expectedTokens={}",
				expectedTokens.stream().reduce((String a, String b) -> a + " , " + b)
		);
		
		this.nonEpsilonTransitions = ATNStateExt.getNonEpsilonTransitions(curState, recognizer, LOGGER);
		nonEpsilonTransitions.stream().forEach(
				transition->{
					Optional<String> text = IntervalExt.toTokens(transition.label(), recognizer.getVocabulary()).stream().reduce((String a, String b) -> a + " , " + b);
					LOGGER.warn("event_name=expected_token value={} target_rule={}",
							text, 
							parser.getRuleNames()[transition.target.ruleIndex]
					);
				}
		);
	}

	private ParserRuleContext ruleCtx;
	private ATNState curState;

	public Object getOffendingSymbol() {
		return offendingSymbol;
	}
	public void setOffendingSymbol(Object offendingSymbol) {
		this.offendingSymbol = offendingSymbol;
	}
	public int getLine() {
		return line;
	}
	public void setLine(int line) {
		this.line = line;
	}
	public int getCharPositionInLine() {
		return charPositionInLine;
	}
	public void setCharPositionInLine(int charPositionInLine) {
		this.charPositionInLine = charPositionInLine;
	}
	public String getMsg() {
		return msg;
	}
	public void setMsg(String msg) {
		this.msg = msg;
	}
	public RecognitionException getE() {
		return e;
	}
	public void setE(RecognitionException e) {
		this.e = e;
	}
	public ParserRuleContext getRuleCtx() {
		return ruleCtx;
	}
	public void setRuleCtx(ParserRuleContext ruleCtx) {
		this.ruleCtx = ruleCtx;
	}
	public ATNState getCurState() {
		return curState;
	}
	public void setCurState(ATNState curState) {
		this.curState = curState;
	}
	public List<Pair<Token, String>> getErrorList() {
		return errorList;
	}
}
