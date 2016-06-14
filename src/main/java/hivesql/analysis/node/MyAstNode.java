package hivesql.analysis.node;

import org.antlr.v4.runtime.Token;

import common.ast.AstNode;

public class MyAstNode extends AstNode {
	private AstNodeType nodeType;
	private transient Token token;
	
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
	
	public Token getToken() {
		return token;
	}

	public void setToken(Token token) {
		this.token = token;
	}

	@Override
	public String toString(){
		return String.format("{node_type:%s, name:%s, source_interval:%s}", getNodeType(), getName(), getSourceInterval());
	}
}
