package hivesql.analysis;

import hivesql.analysis.parse.HiveSQLLexer;
import hivesql.analysis.parse.HiveSQLParser;

import java.io.IOException;
import java.util.Set;
import java.util.stream.Stream;

import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.BaseErrorListener;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.RecognitionException;
import org.antlr.v4.runtime.Recognizer;
import org.antlr.v4.runtime.atn.ATN;
import org.antlr.v4.runtime.atn.ATNState;
import org.antlr.v4.runtime.atn.Transition;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.testng.annotations.Test;

import extension.ATNStateExt;
import extension.IntervalExt;
import extension.RuleContextExt;

public class ParserTest {
	private static final Logger LOGGER = LoggerFactory.getLogger(ParserTest.class);

	@Test
	public void testSqlA() {
		try {
			HiveSQLLexer lexer = new HiveSQLLexer(new ANTLRInputStream(getClass().getResourceAsStream("/error.sql")));
			HiveSQLParser parser = new HiveSQLParser(new CommonTokenStream(lexer));
			parser.addErrorListener(new BaseErrorListener() {
				@Override
				public void syntaxError(Recognizer<?, ?> recognizer, 
						Object offendingSymbol, 
						int line,
						int charPositionInLine, 
						String msg, 
						RecognitionException e) {

					ParserRuleContext ruleCtx = (ParserRuleContext)e.getCtx();
					Stream<String> ruleNameChain = RuleContextExt.getRuleContextChainBottomUp(ruleCtx).stream().map(
							rctx->HiveSQLParser.ruleNames[rctx.getRuleIndex()]
							);
					LOGGER.info("rule_chain={}",
							ruleNameChain.reduce((a,b)->a+" , "+b)
							);
					
					ATN atn = parser.getATN();
					ATNState curState = atn.states.get(e.getOffendingState());
					LOGGER.info("atn_state={} offending_state={}",curState.stateNumber, e.getOffendingState());
					
					Stream<String> expectedTokens = IntervalExt.toTokens(e.getExpectedTokens(), HiveSQLLexer.tokenNames);
					LOGGER.error("event_name=syntax_error line={} char_position={} msg={} token={} expectedTokens={}",
							line, 
							charPositionInLine, 
							msg, 
							e.getOffendingToken().getText(),
							expectedTokens.reduce((String a, String b) -> a + " , " + b)
					);
					
					Set<Transition> nonEpsilonTransitions = ATNStateExt.getNonEpsilonTransitions(curState, LOGGER);
					nonEpsilonTransitions.stream().forEach(
							t->IntervalExt.toTokens(t.label(), HiveSQLLexer.tokenNames).forEach(
									token->
										LOGGER.info("event_name=expected_token value={} target_rule={}",token, HiveSQLParser.ruleNames[t.target.ruleIndex])
							)
					);
				}
			});
			parser.stat();
		} catch (IOException e) {

		}
	}
}
