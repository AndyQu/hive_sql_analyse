package hivesql.analysis;

import java.util.ArrayList;
import java.util.List;

import org.antlr.v4.runtime.BaseErrorListener;
import org.antlr.v4.runtime.RecognitionException;
import org.antlr.v4.runtime.Recognizer;

import hivesql.analysis.parse.HiveSQLParser;

public class HiveErrorListener extends BaseErrorListener {
	
//	private static final Logger LOGGER = LoggerFactory.getLogger(HiveErrorListener.class);

	private HiveSQLParser parser;
	
	public HiveErrorListener(HiveSQLParser parser){
		this.parser=parser;
	}
	
	private List<SyntaxError> syntaxErrors = new ArrayList<SyntaxError>();
	
	@Override
	public void syntaxError(Recognizer<?, ?> recognizer, 
			Object offendingSymbol, 
			int line,
			int charPositionInLine, 
			String msg, 
			RecognitionException e) {

		syntaxErrors.add(new SyntaxError(parser, recognizer, offendingSymbol, line, charPositionInLine, msg, e));
	}
}
