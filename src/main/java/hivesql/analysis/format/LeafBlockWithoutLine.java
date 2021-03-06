package hivesql.analysis.format;

import antlr4.extension.StringExt;

public class LeafBlockWithoutLine extends Block {
	private String content;

	public String getContent() {
		return content;
	}

	public void setContent(String content) {
		this.content = content;
	}
	
	public void addContent(String c){
		if(this.content==null)
			this.content=c;
		else
			this.content=this.content+c;
	}
	
	public static LeafBlockWithoutLine build(int spaceCount, String line){
		LeafBlockWithoutLine b = new LeafBlockWithoutLine();
		b.setSpaceCount(spaceCount);
		b.setContent(line);
		return b;
	}
	
	public static LeafBlockWithoutLine build(int spaceCount){
		return build(spaceCount, "");
	}

	@Override
	public String show() {
		return String.format("%s%s", StringExt.buildSpaces(getSpaceCount()), content);
	}
	
	@Override
	public String toString(){
		return show();
	}

	@Override
	public boolean isStartedWithLine() {
		return false;
	}

	@Override
	public boolean isEndedWithLine() {
		return false;
	}
}
