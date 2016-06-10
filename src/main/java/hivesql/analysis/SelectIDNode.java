package hivesql.analysis;

import org.antlr.v4.runtime.RuleContext;

public class SelectIDNode extends RuleContext {
	private int leveNum;
	private int orderNumInSameLevel;

	public SelectIDNode(int leveNum, int orderNumInSameLevel) {
		this.leveNum = leveNum;
		this.orderNumInSameLevel = orderNumInSameLevel;
	}

	@Override
	public String getText() {
		return " {SelectIDNode: level_num=" + leveNum + " order_num_in_same_level=" + orderNumInSameLevel + "} ";
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
	
	@Override
	public String toString(){
		return getText();
	}
}
