package hivesql.analysis;

import hivesql.analysis.parse.HiveSQLLexer;
import hivesql.analysis.parse.HiveSQLParser;

import java.io.IOException;

import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.CommonTokenStream;
import org.testng.annotations.Test;

public class ParserTest {
//	private static final Logger LOGGER = LoggerFactory.getLogger(ParserTest.class);
	@Test
	public void testSqlA() {
		try {
			HiveSQLLexer lexer = new HiveSQLLexer(new ANTLRInputStream(getClass().getResourceAsStream("/error.sql")));
			HiveSQLParser parser = new HiveSQLParser(new CommonTokenStream(lexer));
			parser.addErrorListener(new HiveErrorListener(parser));
			parser.stat();
		} catch (IOException e) {

		}
	}
}
