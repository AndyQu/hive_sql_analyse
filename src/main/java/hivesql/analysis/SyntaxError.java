package hivesql.analysis;

import java.util.Set;
import java.util.stream.Stream;

import org.antlr.v4.runtime.Parser;
import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.RecognitionException;
import org.antlr.v4.runtime.Recognizer;
import org.antlr.v4.runtime.atn.ATN;
import org.antlr.v4.runtime.atn.ATNState;
import org.antlr.v4.runtime.atn.Transition;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import antlr4.extension.ATNStateExt;
import antlr4.extension.IntervalExt;
import antlr4.extension.RuleContextExt;
import hivesql.analysis.parse.HiveSQLLexer;
import hivesql.analysis.parse.HiveSQLParser;

public class SyntaxError {
	private static final Logger LOGGER = LoggerFactory.getLogger(SyntaxError.class);
	
	private Object offendingSymbol;
	private int line;
	private int charPositionInLine;
	private String msg;
	private RecognitionException e;

	public SyntaxError(Parser parser, Recognizer<?, ?> recognizer, Object offendingSymbol, int line, int charPositionInLine,
			String msg, RecognitionException e) {
		this.offendingSymbol = offendingSymbol;
		this.line = line;
		this.charPositionInLine = charPositionInLine;
		this.msg = msg;
		this.e = e;
		
		this.ruleCtx = (ParserRuleContext)e.getCtx();
		Stream<String> ruleNameChain = RuleContextExt.getRuleContextChainBottomUp(ruleCtx).stream().map(
				rctx->HiveSQLParser.ruleNames[rctx.getRuleIndex()]
				);
		LOGGER.info("rule_chain={}",
				ruleNameChain.reduce((a,b)->a+" , "+b)
				);
		
		ATN atn = parser.getATN();
		this.curState = atn.states.get(e.getOffendingState());
		LOGGER.info("atn_state={} offending_state={}",curState.stateNumber, e.getOffendingState());
		
		Stream<String> expectedTokens = IntervalExt.toTokens(e.getExpectedTokens(), HiveSQLLexer.tokenNames);
		LOGGER.error("event_name=syntax_error line={} char_position={} msg={} token={} expectedTokens={}",
				line, 
				charPositionInLine, 
				msg, 
				e.getOffendingToken().getText(),
				expectedTokens.reduce((String a, String b) -> a + " , " + b)
		);
		
		this.nonEpsilonTransitions = ATNStateExt.getNonEpsilonTransitions(curState, LOGGER);
		nonEpsilonTransitions.stream().forEach(
				t->IntervalExt.toTokens(t.label(), HiveSQLLexer.tokenNames).forEach(
						token->
							LOGGER.info("event_name=expected_token value={} target_rule={}",token, HiveSQLParser.ruleNames[t.target.ruleIndex])
				)
		);
	}

	private ParserRuleContext ruleCtx;
	private ATNState curState;
	/**
	 * 
	 */
	private Set<Transition> nonEpsilonTransitions;

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
	public Set<Transition> getNonEpsilonTransitions() {
		return nonEpsilonTransitions;
	}
	public void setNonEpsilonTransitions(Set<Transition> nonEpsilonTransitions) {
		this.nonEpsilonTransitions = nonEpsilonTransitions;
	}
}
