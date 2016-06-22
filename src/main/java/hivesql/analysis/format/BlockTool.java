package hivesql.analysis.format;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class BlockTool {
	private static final Logger LOGGER = LoggerFactory.getLogger(BlockTool.class);

	public static NonLeafBlock cutOutRedundantLines(NonLeafBlock block) {
		if (block.getChilds() != null) {

			if (block.getChilds().size() >= 2) {
				List<Block> childs = new ArrayList<Block>();

				Block pre = block.getChilds().get(0);
				childs.add(pre);

				Block cur = block.getChilds().get(1);
				for (int i = 1; i < block.getChilds().size();i++) {
					cur = block.getChilds().get(i);
					if (pre.isEndedWithLine() && cur.isStartedWithLine()) {
						if (cur instanceof LineOnlyBlock) {
							// 不添加cur到childs中

							// iterate
							// pre保持不变
						} else if (cur instanceof NonLeafBlock) {
							// 添加cur到childs中
							removeFirstLine((NonLeafBlock) cur);
							childs.add(cur);

							// iterate
							pre = cur;
						} else {
							throw new RuntimeException(
									String.format("event_name=unexpected_branch current_block_type=%s block_name=%s",
											cur.getClass().getName(), 
											cur.getName()));
						}
					} else {
						// 添加cur到childs中
						childs.add(cur);
						// iterate
						pre = cur;
					}
				}
				block.setChilds(childs);
			}
			block.getChilds().stream().forEach(child -> {
				if (child instanceof NonLeafBlock) {
					cutOutRedundantLines((NonLeafBlock) child);
				}
			});
		}
		return block;
	}

	public static List<Block> buildLine(int spaces, String content) {
		return Arrays.asList(new Block[] { LeafBlockWithoutLine.build(spaces, content), LineOnlyBlock.build() });
	}

	public static void removeFirstLine(NonLeafBlock block) {
		Block child = block.getChilds().get(0);
		if (child instanceof LineOnlyBlock) {
			block.getChilds().remove(0);
		} else if (child instanceof NonLeafBlock) {
			removeFirstLine((NonLeafBlock) child);
		} else {
			LOGGER.error("event_name=unexpected_child_block_type type={} block_name={}", 
					child.getClass().getName(),
					child.getName());
		}
	}
	
	
}
