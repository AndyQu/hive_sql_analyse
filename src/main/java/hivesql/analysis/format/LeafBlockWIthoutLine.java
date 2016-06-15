package hivesql.analysis.format;

public class LeafBlockWIthoutLine extends Block {
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
	
	public static LeafBlockWIthoutLine build(int spaceCount, String line){
		LeafBlockWIthoutLine b = new LeafBlockWIthoutLine();
		b.setSpaceCount(spaceCount);
		b.setContent(line);
		return b;
	}

	@Override
	public String show() {
		return content;
	}
}
