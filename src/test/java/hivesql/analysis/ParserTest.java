package hivesql.analysis;

import hivesql.analysis.node.MyAstNode;
import hivesql.analysis.parse.HiveSQLLexer;
import hivesql.analysis.parse.HiveSQLParser;
import hivesql.analysis.parse.HiveSQLParser.StatContext;

import java.io.IOException;
//import java.util.Arrays;

import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.RuleContext;
import org.apache.commons.collections4.keyvalue.MultiKey;
import org.apache.commons.collections4.map.MultiKeyMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

//import com.google.gson.ExclusionStrategy;
//import com.google.gson.FieldAttributes;
//import com.google.gson.Gson;
//import com.google.gson.GsonBuilder;

public class ParserTest {
	private static final Logger LOGGER = LoggerFactory.getLogger(ParserTest.class);
	private static final Gson gson = new GsonBuilder().setPrettyPrinting().create();
	
	@DataProvider(name = "basic_sqls")
	   public static Object[][] primeNumbers() {
	      return new Object[][] {
	    	  {"/basic_sqls/logic_expr.sql"}
//	    	  , 
//	    	  {"/basic_sqls/simple_logic_expr.sql"}
	      };
	   }
	
	@Test(dataProvider = "basic_sqls")
	public void testSqlA(String sqlFile) {
//		Gson gson =  new GsonBuilder().setExclusionStrategies(new ExclusionStrategy(){
//
//			@Override
//			public boolean shouldSkipField(FieldAttributes f) {
//				if(f.getName().equals("parent")){
//					LOGGER.info("skip parent");
//					return f.getName().equals("parent");
//				}else{
//					LOGGER.info("do not skip {} {}.{}", f.getDeclaredClass().getName(), f.getDeclaringClass().getName(), f.getName());
//					return false;
//				}
//						//&& (f.getDeclaredClass()==RuleContext.class||f.getDeclaredClass()==ParserRuleContext.class);
//			}
//
//			@Override
//			public boolean shouldSkipClass(Class<?> clazz) {
//				return false;
//			}
//			
//		}).create();
		
		try {
			HiveSQLLexer lexer = new HiveSQLLexer(new ANTLRInputStream(getClass().getResourceAsStream(sqlFile)));
			HiveSQLParser parser = new HiveSQLParser(new CommonTokenStream(lexer));
//			parser.addErrorListener(new HiveErrorListener(parser));
			StatContext statCtx = (StatContext)parser.stat();
			
			LOGGER.warn("\n{}", statCtx.block.show());
			
//			MultiKeyMap<Integer, RuleContext> mm = SelectClauseSegregator.segregate(topCtx);
//			showSegregatedClauses(mm);
			
			
//			MultiKeyMap<Integer, MyAstNode> astM = ParseTreeToAstNodeTransformer.transform(mm, HiveSQLParser.ruleNames, parser.getInputStream());
//			
//			MultiKeyMap<Integer, MyAstNode> compressedAstM = SingleBranchCompressor.compress(astM);
//			showCompressedNodes(compressedAstM);
			
		} catch (IOException e) {

		}
	}
	
	private void showCompressedNodes(MultiKeyMap<Integer, MyAstNode> compressedAstM){
		compressedAstM.entrySet().stream().forEach(entry->{
			MultiKey<? extends Integer> key = entry.getKey();
			MyAstNode value =  entry.getValue();
			LOGGER.debug("event_name=show_compressed_ast_node level_number={} order_num_in_same_level={} value=\n{}",
					key.getKey(0),
					key.getKey(1),
					gson.toJson(value));
		});
	}
	
	private void showSegregatedClauses(MultiKeyMap<Integer, RuleContext> mm) {
		mm.entrySet().stream().forEach(entry -> {
			MultiKey<? extends Integer> key = entry.getKey();
			RuleContext value = entry.getValue();

			LOGGER.info(
					"event_name=show_select_clause level_number={} order_num_in_same_level={} rule_name={} last_token={}",
					key.getKey(0), key.getKey(1), HiveSQLParser.ruleNames[value.getRuleIndex()],
					((ParserRuleContext) value).getStop());

		});
	}
}
