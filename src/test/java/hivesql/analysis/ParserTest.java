package hivesql.analysis;

import hivesql.analysis.parse.HiveSQLLexer;
import hivesql.analysis.parse.HiveSQLParser;

import java.io.IOException;

import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.ParserRuleContext;
import org.apache.commons.collections4.MapIterator;
import org.apache.commons.collections4.keyvalue.MultiKey;
import org.apache.commons.collections4.map.MultiKeyMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.testng.annotations.Test;

public class ParserTest {
	private static final Logger LOGGER = LoggerFactory.getLogger(ParserTest.class);
	@Test
	public void testSqlA() {
		try {
			HiveSQLLexer lexer = new HiveSQLLexer(new ANTLRInputStream(getClass().
					getResourceAsStream("/auto_hmart_finance.cux_busn_data_int_all.mis3.sql")));
			HiveSQLParser parser = new HiveSQLParser(new CommonTokenStream(lexer));
			parser.addErrorListener(new HiveErrorListener(parser));
			ParserRuleContext topCtx = parser.stat();
			MultiKeyMap mm = SelectClauseSegregator.segregate(topCtx);
			
			MapIterator it = mm.mapIterator();
			 while (it.hasNext()) {
			   MultiKey key = (MultiKey)it.next();
			   ParserRuleContext value = (ParserRuleContext)it.getValue();
			   
			   LOGGER.info("event_name=show_select_clause level_number={} order_num_in_same_level={} rule_name={} last_token={}",
						key.getKey(0),
						key.getKey(1),
						HiveSQLParser.ruleNames[value.getRuleIndex()],
						value.getStop());
			 }
			
		} catch (IOException e) {

		}
	}
}
