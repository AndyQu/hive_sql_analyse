package hivesql.analysis;

import java.util.List;

import org.antlr.v4.runtime.Parser;
import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.RecognitionException;
import org.antlr.v4.runtime.Recognizer;
import org.antlr.v4.runtime.atn.ATNState;
import org.antlr.v4.runtime.misc.IntervalSet;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import antlr4.extension.IntervalExt;


public class SyntaxError {
	private static final Logger LOGGER = LoggerFactory.getLogger(SyntaxError.class);
	
	private Object offendingSymbol;
	private int line;
	private int charPositionInLine;
	private String msg;
	private RecognitionException e;

	private IntervalSet expectedTokens;
	private List<String> expectedTokenStrings;
	private String ruleName;
	
//	private Set<Transition> nonEpsilonTransitions;

	public SyntaxError(Parser parser, Recognizer<?, ?> recognizer, Object offendingSymbol, int line, int charPositionInLine,
			String msg, RecognitionException e) {
		this.offendingSymbol = offendingSymbol;
		this.line = line;
		this.charPositionInLine = charPositionInLine;
		this.msg = msg;
		this.e = e;
		
		List<String> stack = ((Parser)recognizer).getRuleInvocationStack();
		//stack is like: [stat, select_clause, selected_column_list, selected_column, function_over_clause, order_clause, ordered_column_name_list]
		LOGGER.error("\nevent_name=syntax_error line={} char_position={} msg={} token={} rule_stack={}",
				line, 
				charPositionInLine, 
				msg, 
				offendingSymbol,
				stack
		);
		
		if(e==null 
				//|| !(e instanceof InputMismatchException)
				){
			LOGGER.error("event_name=RecognitionException_is_null");
			return;
		}
		
		this.ruleCtx = (ParserRuleContext)e.getCtx();

		
		this.offendingState = parser.getATN().states.get(e.getOffendingState());
		LOGGER.info("atn_state={} offending_state={}", offendingState.stateNumber, e.getOffendingState());

		this.expectedTokens=recognizer.getATN().getExpectedTokens(this.offendingState.stateNumber, e.getCtx());
		this.expectedTokenStrings = IntervalExt.toTokens(this.expectedTokens, recognizer.getVocabulary());
		this.ruleName=parser.getRuleNames()[e.getCtx().getRuleIndex()];
		LOGGER.error("event_name=syntax_error expectedTokens={} rule_name={}",
				expectedTokens.toString(recognizer.getVocabulary()),
				this.ruleName
		);

		
		/*
		List<String> expectedTokens = IntervalExt.toTokens(e.getExpectedTokens(), recognizer.getVocabulary());
		LOGGER.error("event_name=syntax_error expectedTokens={}",
				expectedTokens.stream().reduce((String a, String b) -> a + " , " + b)
		);
		
		this.nonEpsilonTransitions = ATNStateExt.getNonEpsilonTransitions(offendingState, recognizer, LOGGER);
		nonEpsilonTransitions.stream().forEach(
				transition->{
					Optional<String> text = IntervalExt.toTokens(transition.label(), recognizer.getVocabulary()).stream().reduce((String a, String b) -> a + " , " + b);
					LOGGER.warn("event_name=expected_token value={} target_rule={}",
							text, 
							parser.getRuleNames()[transition.target.ruleIndex]
					);
				}
		);
		*/
	}

	private ParserRuleContext ruleCtx;
	private ATNState offendingState;

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
	public ATNState getOffendingState() {
		return offendingState;
	}
	public void setOffendingState(ATNState offendingState) {
		this.offendingState = offendingState;
	}
	public String getRuleName() {
		return ruleName;
	}
	public List<String> getExpectedTokenStrings() {
		return expectedTokenStrings;
	}
}
