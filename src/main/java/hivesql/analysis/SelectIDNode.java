package hivesql.analysis;

import org.antlr.v4.runtime.RuleContext;

public class SelectIDNode extends RuleContext {
	private int leveNum;
	private int orderNumInSameLevel;

	public SelectIDNode(int leveNum, int orderNumInSameLevel) {
		this.leveNum = leveNum;
		this.orderNumInSameLevel = orderNumInSameLevel;
	}

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
