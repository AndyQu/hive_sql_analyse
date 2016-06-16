package hivesql.analysis.format;

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

	@Override
	public String show() {
		return content;
	}
}