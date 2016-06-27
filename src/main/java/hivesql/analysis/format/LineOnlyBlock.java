package hivesql.analysis.format;

import antlr4.extension.StringExt;

public final class LineOnlyBlock extends Block {
	
	private static final LineOnlyBlock One_Line = build(0,1);
	
	private int lineCount;

	public int getLineCount() {
		return lineCount;
	}
	public void setLineCount(int lineCount) {
		this.lineCount = lineCount;
	}
	public static LineOnlyBlock buildOne(int sc){
		return build(sc, 1);
	}
	public static LineOnlyBlock build(int sc, int lc){
		LineOnlyBlock b = new LineOnlyBlock();
		b.setSpaceCount(sc);
		b.setLineCount(lc);
		return b;
	}
	
	public static LineOnlyBlock build(){
		return One_Line;
	}
	
	
	@Override
	public String show() {
		StringBuilder ret = new StringBuilder();
		String spaces = StringExt.buildSpaces(getSpaceCount());
		for(int i=0;i<getLineCount();i++){
			ret.append(spaces+"\n");
		}
		return ret.toString();
	}
	
	@Override
	public boolean isStartedWithLine() {
		return true;
	}
	
	@Override
	public boolean isEndedWithLine() {
		return true;
	}

}
