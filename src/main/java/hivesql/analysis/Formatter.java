package hivesql.analysis;

import org.apache.commons.collections4.keyvalue.MultiKey;
import org.apache.commons.collections4.map.LinkedMap;
import org.apache.commons.collections4.map.MultiKeyMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

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
		case Error:
			result.append(String.format("%s%s\n", buildSpaces(spaceCount), node.getToken().getText()));
			break;
		case Terminal:
			result.append(String.format("%s%s\n", buildSpaces(spaceCount), node.getToken().getText()));
			break;
		case Reference:
			ReferenceNode rn = (ReferenceNode) node;
			result.append(String.format("%s(%d,%d)\n", buildSpaces(spaceCount), rn.getLeveNum(),
					rn.getOrderNumInSameLevel()));
			break;
		case Non_Terminal:
			for (int i = 0; i < node.getChildren().size(); i++) {
				result.append(subFormat(spaceCount + Indent_Space_Count, (MyAstNode) node.getChildren().get(i)));
			}
			break;
		case Invalid:
			LOGGER.error("event_name=invalid_node value={}", gson.toJson(node));
			break;
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
}
