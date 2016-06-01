package hivesql.analysis;

import hivesql.analysis.parse.HiveSQLLexer;
import hivesql.analysis.parse.HiveSQLParser;

import java.io.IOException;

import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.BaseErrorListener;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.RecognitionException;
import org.antlr.v4.runtime.Recognizer;
import org.testng.annotations.Test;

public class ParserTest {
	@Test
	public void testSqlA(){
		try{
			HiveSQLLexer l = new HiveSQLLexer(new ANTLRInputStream(getClass().getResourceAsStream("/a_test.sql")));
		    HiveSQLParser p = new HiveSQLParser(new CommonTokenStream(l));
		    p.addErrorListener(new BaseErrorListener() {
		        @Override
		        public void syntaxError(Recognizer<?, ?> recognizer, Object offendingSymbol, int line, int charPositionInLine, String msg, RecognitionException e) {
		            throw new IllegalStateException("failed to parse at line " + line + " due to " + msg, e);
		        }
		    });
		    p.stat();
		}catch(IOException e){
			
		}
	}
}
