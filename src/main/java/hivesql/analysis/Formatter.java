package hivesql.analysis;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.collections4.keyvalue.MultiKey;
import org.apache.commons.collections4.map.LinkedMap;
import org.apache.commons.collections4.map.MultiKeyMap;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import hivesql.analysis.node.AstNodeType;
import hivesql.analysis.node.MyAstNode;
import hivesql.analysis.node.ReferenceNode;

public class Formatter {
	private static final Logger LOGGER = LoggerFactory.getLogger(Formatter.class);
	private static final Gson gson = new GsonBuilder().setPrettyPrinting().create();
	private static final int Indent_Space_Count = 2;

	public static MultiKeyMap<Integer, String> format(MultiKeyMap<Integer, MyAstNode> astM) {
		MultiKeyMap<Integer, String> resultM = MultiKeyMap.multiKeyMap(new LinkedMap<>());

		astM.entrySet().stream().forEach(entry->{
			MultiKey<? extends Integer> key = entry.getKey();
			MyAstNode value = entry.getValue();
			resultM.put(key.getKey(0), key.getKey(1), format(value));
		});
		
		return resultM;
	}

	public static String format(MyAstNode node) {
		return subFormat(Indent_Space_Count, node);
	}

	private static String subFormat(int spaceCount, MyAstNode node) {
		StringBuilder result = new StringBuilder();
		switch (node.getNodeType()) {
		case Reference:
			ReferenceNode rn = (ReferenceNode) node;
			result.append(String.format("%s(%d,%d)", buildSpaces(spaceCount), rn.getLeveNum(),
					rn.getOrderNumInSameLevel()));
			break;
		case Invalid:
			LOGGER.error("event_name=invalid_node value={}", gson.toJson(node));
			break;
		case Error:
		default:
			if(node.getTopSingleBranchName()==null){
				LOGGER.info("event_name=no_top_single_branch_name node={}", gson.toJson(node));
				result.append(node.getToken().getText());
			}else{
				SubFormatter sFormatter = subFormatterM.get(node.getTopSingleBranchName());
				if (sFormatter != null)
					sFormatter.process(spaceCount, node, result);
				else {
					LOGGER.error("event_name=no_formater_found_for_node node={}", gson.toJson(node.getTopSingleBranchName()));
				}
			}
			break;
//		case Error:
//		case Terminal:
//			LOGGER.error("event_name=skip_node value={}", gson.toJson(node));
//			break;
		
		}
		return result.toString();
	}

	private static String buildSpaces(int spaceCount) {
		StringBuilder result = new StringBuilder();
		for (int i = 0; i < spaceCount; i++) {
			result.append(" ");
		}
		return result.toString();
	}
	
	private static class SubFormatter{
		public void process(int spaceCount, MyAstNode node, StringBuilder result){
			if(node.getChildCount()<=0){
				processNode(spaceCount, node, result);
			}else{
				processChilds(spaceCount, node, result);
			}
		}
		protected  void processNode(int spaceCount, MyAstNode node, StringBuilder result){
			LOGGER.info("event_name=terminal_node_using_default_formating node={}", gson.toJson(node));
			result.append(buildSpaces(spaceCount));
			result.append(node.getToken().getText());
		}
		protected  void processChilds(int spaceCount, MyAstNode node, StringBuilder result){
			LOGGER.error("event_name=non_terminal_node_skipped node={}", gson.toJson(node));
		}
	}
	
	private static final SubFormatter AliasFormatter=new SubFormatter() {
		
		@Override
		protected  void processNode(int spaceCount, MyAstNode node, StringBuilder result){
			result.append(buildSpaces(1));
			result.append(node.getToken().getText());
		}
		
		@Override
		public void processChilds(int spaceCount, MyAstNode node, StringBuilder result) {
			result.append(buildSpaces(spaceCount));
			for (int i = 0; i < node.getChildren().size(); i++) {
				MyAstNode child = (MyAstNode) node.getChildren().get(i);
				if (child.getNodeType() == AstNodeType.Terminal && child.getToken().getText().equals("as")) {
					// as关键字前面、后面加一个空格
					result.append(String.format(" %s ", child.getToken().getText()));
				} else {
					// 其他不加空格
					result.append(subFormat(1, child));
				}
			}
		}
	};
	
	private static Map<String, SubFormatter> subFormatterM = new HashMap<String, SubFormatter>();
	static{
		subFormatterM.put("select_clause", new SubFormatter() {
			
			@Override
			public void processChilds(int spaceCount, MyAstNode node, StringBuilder result) {
				int step=1;
				for (int i = 0; i < node.getChildren().size(); i+=step) {
					MyAstNode child = (MyAstNode)node.getChildren().get(i);
					if(child.getNodeType()==AstNodeType.Terminal){ 
						String text=child.getToken().getText();
						if(text.equals("select")
							||	text.equals("from")
							||  text.equals("where")
							|| text.equals(";")){
							result.append(String.format("%s%s\n", buildSpaces(spaceCount), child.getToken().getText()));
							step=1;
						}else if(text.equals("group")||text.equals("cluster")||text.equals("distribute")||text.equals("sort")){
							result.append(String.format("%s%s by\n", buildSpaces(spaceCount), child.getToken().getText()));
							step=2;
						}else {
							LOGGER.error("event_name=unknown_terminal value={}", text);
							step=1;
						}
					}else{
						result.append(String.format("%s\n", subFormat(spaceCount+2, child)));
					}
				}
			}
		});
		
		subFormatterM.put("selected_column_list", new SubFormatter(){

			@Override
			public void processChilds(int spaceCount, MyAstNode node, StringBuilder result) {
				for (int i = 0; i < node.getChildren().size(); i++) {
					MyAstNode child = (MyAstNode)node.getChildren().get(i);
					if(child.getNodeType()==AstNodeType.Terminal && child.getToken().getText().equals(",")){
						result.append(String.format("%s\n", child.getToken().getText()));
					}else{
						result.append(subFormat(spaceCount, child));
					}
				}
				result.append("\n");
			}
			
		});
		
		subFormatterM.put("selected_column", new SubFormatter() {
			
			@Override
			public void processChilds(int spaceCount, MyAstNode node, StringBuilder result) {
				result.append(buildSpaces(spaceCount));
				for (int i = 0; i < node.getChildren().size(); i++) {
					result.append(subFormat(0, (MyAstNode) node.getChildren().get(i)));
				}
			}
		});
		
		subFormatterM.put("column_name", new SubFormatter() {
			
			@Override
			public void processChilds(int spaceCount, MyAstNode node, StringBuilder result) {
				result.append(buildSpaces(spaceCount));
				for (int i = 0; i < node.getChildren().size(); i++) {
					MyAstNode child = (MyAstNode)node.getChildren().get(i);
					if(child.getNodeType()==AstNodeType.Terminal && child.getToken().getText().equals("distinct")){
						//distinct关键字后面加一个空格
						result.append(String.format("%s ", child.getToken().getText()));
					}else{
						//其他不加空格
						result.append(subFormat(0, child));
					}
				}
			}
		});
		
		subFormatterM.put("table_name", new SubFormatter() {
			
			@Override
			public void processChilds(int spaceCount, MyAstNode node, StringBuilder result) {
				result.append(buildSpaces(spaceCount));
				for (int i = 0; i < node.getChildren().size(); i++) {
					MyAstNode child = (MyAstNode)node.getChildren().get(i);
					result.append(subFormat(0, child));
				}
			}
		});
		
		subFormatterM.put("schema_name", new SubFormatter() {
			
			@Override
			protected  void processNode(int spaceCount, MyAstNode node, StringBuilder result){
				result.append(buildSpaces(spaceCount));
				result.append(node.getToken().getText());
			}
			
		});
		
		subFormatterM.put("column_name_alias", AliasFormatter);
		subFormatterM.put("subquery_alias", AliasFormatter);
		

		subFormatterM.put("top_arith_expr",  new SubFormatter(){
			
			@Override
			protected  void processChilds(int spaceCount, MyAstNode node, StringBuilder result){
				result.append(buildSpaces(spaceCount));
				for (int i = 0; i < node.getChildren().size(); i++) {
					result.append(subFormat(spaceCount, (MyAstNode) node.getChildren().get(i)));
				}
			}
		});
		
		subFormatterM.put("subquery",  new SubFormatter(){
			
			@Override
			protected  void processChilds(int spaceCount, MyAstNode node, StringBuilder result){
				result.append(buildSpaces(spaceCount));
				for (int i = 0; i < node.getChildren().size(); i++) {
					MyAstNode child=(MyAstNode) node.getChildren().get(i);
					if(child.getNodeType()==AstNodeType.Terminal){
						if(child.getToken().getText().equals("(")){
							result.append("(\n");
						}else if(child.getToken().getText().equals(")")){
							result.append(String.format("\n%s)", buildSpaces(spaceCount)));
						}
					} else{
						result.append(subFormat(spaceCount+2, (MyAstNode) node.getChildren().get(i)));
					}
				}
			}
		});
		
		subFormatterM.put("top_logic_expr",  new SubFormatter(){
			
			@Override
			protected  void processChilds(int spaceCount, MyAstNode node, StringBuilder result){
				result.append(buildSpaces(spaceCount));
				List<String> lst = new ArrayList<String>();
				for (int i = 0; i < node.getChildren().size(); i++) {
					MyAstNode child=(MyAstNode) node.getChildren().get(i);
					if(child.getNodeType()==AstNodeType.Terminal){
						if(child.getToken().getText().equals("(")){
							result.append("(\n");
							result.append(buildSpaces(spaceCount+Indent_Space_Count));
						}else if(child.getToken().getText().equals(")")){
							result.append(String.format("\n%s)", buildSpaces(spaceCount)));
						}else {
							lst.add(child.getToken().getText());
						}
					}else{
						lst.add(subFormat(0, child));
					}
				}
				result.append(StringUtils.join(lst, buildSpaces(Indent_Space_Count)));
			}
		});
		
		subFormatterM.put("table_references", new SubFormatter() {
			
			@Override
			public void process(int spaceCount, MyAstNode node, StringBuilder result) {
				for (int i = 0; i < node.getChildren().size(); i++) {
					result.append(subFormat(spaceCount, (MyAstNode) node.getChildren().get(i)));
				}
				result.append("\n");
			}
		});
		
	}
}
