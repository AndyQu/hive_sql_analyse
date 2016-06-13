package hivesql.analysis.node;

import common.ast.AstNode;

public class MyAstNode extends AstNode {
	private AstNodeType nodeType;
	
	public MyAstNode(){
	}
	
	public MyAstNode(AstNodeType nodeType){
		this.nodeType=nodeType;
	}

	public AstNodeType getNodeType() {
		return nodeType;
	}

	public void setNodeType(AstNodeType nodeType) {
		this.nodeType = nodeType;
	}
}
