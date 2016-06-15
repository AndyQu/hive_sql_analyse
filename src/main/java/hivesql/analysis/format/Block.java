package hivesql.analysis.format;

public abstract class Block {
	private int spaceCount;

	public int getSpaceCount() {
		return spaceCount;
	}

	public void setSpaceCount(int spaceCount) {
		this.spaceCount = spaceCount;
	}
	
	public abstract String show();
}
