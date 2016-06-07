package hivesql.analysis;

import hivesql.analysis.parse.HiveSQLLexer;
import hivesql.analysis.parse.HiveSQLParser;

import java.io.IOException;

import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.BaseErrorListener;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.RecognitionException;
import org.antlr.v4.runtime.Recognizer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.testng.annotations.Test;

public class ParserTest {
	private static final Logger LOGGER = LoggerFactory.getLogger(ParserTest.class);
	
	@Test
	public void testSqlA(){
		try{
			HiveSQLLexer lexer = new HiveSQLLexer(new ANTLRInputStream(getClass().getResourceAsStream("/error.sql")));
		    HiveSQLParser parser = new HiveSQLParser(new CommonTokenStream(lexer));
		    parser.addErrorListener(new BaseErrorListener() {
		        @Override
		        public void syntaxError(Recognizer<?, ?> recognizer, Object offendingSymbol, int line, int charPositionInLine, String msg, RecognitionException e) {
//		            throw new IllegalStateException("failed to parse at line " + line + " due to " + msg, e);
		            LOGGER.error("event_name=syntax_error line={} char_position={} msg={} token={} expectedTokens={}", 
		            		line, charPositionInLine, msg, e.getOffendingToken().getText(), 
		            		e.getExpectedTokens().getIntervals().stream().map(interval->interval.toString()).reduce(new String(), (acc,b)->acc+","+b));
		        }
		    });
		    parser.stat();
		}catch(IOException e){
			
		}
	}
}
