package hivesql.analysis.node;

import java.util.List;

import org.antlr.v4.runtime.Token;

import common.ast.AstNode;

public class MyAstNode extends AstNode {
	private List<Token> tokens;
	private AstNodeType nodeType;
	
	public MyAstNode(){
	}
	
	public MyAstNode(AstNodeType nodeType){
		this.nodeType=nodeType;
	}

	public List<Token> getTokens() {
		return tokens;
	}

	public void setTokens(List<Token> tokens) {
		this.tokens = tokens;
	}

	public AstNodeType getNodeType() {
		return nodeType;
	}

	public void setNodeType(AstNodeType nodeType) {
		this.nodeType = nodeType;
	}

}
