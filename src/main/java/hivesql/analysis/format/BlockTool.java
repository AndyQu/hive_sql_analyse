package hivesql.analysis.format;

import java.util.Arrays;
import java.util.List;

public class BlockTool {
	public static NonLeafBlock cutOutRedundantLines(NonLeafBlock block) {
		for (int i = 1; i < block.getChilds().size(); i++) {
			Block pre = block.getChilds().get(i - 1);
			Block cur = block.getChilds().get(i);
		}
		// TODO
		return null;
	}

	public static List<Block> buildLine(int spaces, String content) {
		return Arrays.asList(new Block[] { LeafBlockWithoutLine.build(spaces, content), LineOnlyBlock.build() });
	}
}
