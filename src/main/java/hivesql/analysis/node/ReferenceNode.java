package hivesql.analysis.node;

public class ReferenceNode extends MyAstNode {
	private int leveNum;
	private int orderNumInSameLevel;

	public int getLeveNum() {
		return leveNum;
	}

	public void setLeveNum(int leveNum) {
		this.leveNum = leveNum;
	}

	public int getOrderNumInSameLevel() {
		return orderNumInSameLevel;
	}

	public void setOrderNumInSameLevel(int orderNumInSameLevel) {
		this.orderNumInSameLevel = orderNumInSameLevel;
	}
}
