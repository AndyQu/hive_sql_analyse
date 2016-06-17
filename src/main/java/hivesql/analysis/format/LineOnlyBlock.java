package hivesql.analysis.format;

public final class LineOnlyBlock extends Block {
	
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
	
	@Override
	public String show() {
		StringBuilder ret = new StringBuilder();
		String spaces = buildSpaces(getSpaceCount());
		for(int i=0;i<getLineCount();i++){
			ret.append(spaces+"\n");
		}
		return ret.toString();
	}

}
