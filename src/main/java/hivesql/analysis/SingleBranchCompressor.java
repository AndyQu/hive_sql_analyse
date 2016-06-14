package hivesql.analysis;

import org.apache.commons.collections4.keyvalue.MultiKey;
import org.apache.commons.collections4.map.LinkedMap;
import org.apache.commons.collections4.map.MultiKeyMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import hivesql.analysis.node.MyAstNode;

public class SingleBranchCompressor {
	private static final Logger LOGGER = LoggerFactory.getLogger(SingleBranchCompressor.class);
	
	public static MultiKeyMap<Integer, MyAstNode> compress(MultiKeyMap<Integer, MyAstNode> astM){
		MultiKeyMap<Integer, MyAstNode> resultM = MultiKeyMap.multiKeyMap(new LinkedMap<>());

		astM.entrySet().stream().forEach(entry->{
			MultiKey<? extends Integer> key = entry.getKey();
			MyAstNode value =  entry.getValue();
			resultM.put(key.getKey(0), key.getKey(1), compress(value));
		});
		
		return resultM;
	}
	
	public static MyAstNode compress(MyAstNode node){
		if(node.getChildCount()==0){
			return node;
		}else if(node.getChildCount()>1){
			for(int i=0;i<node.getChildCount();i++){
				MyAstNode cChild=compress((MyAstNode)node.getChildren().get(i));
				node.getChildren().set(i, cChild);
				cChild.setParent(node);
			}
			return node;
		}else{
			MyAstNode child = compress((MyAstNode)node.getChildren().get(0));
			LOGGER.debug("event_name=compress_single_branch removed_node={} replacing_node={}", node, child);
			
			return child;
		}
	}
}
