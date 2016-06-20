package hivesql.analysis.format;

import java.util.ArrayList;
import java.util.List;

public class NonLeafBlock extends Block {
	private List<Block> childs;

	public NonLeafBlock() {
	}

	public NonLeafBlock(String name) {
		super(name);
	}

	public NonLeafBlock(List<Block> childs) {
		this.childs = childs;
	}

	public List<Block> getChilds() {
		return childs;
	}

	public void setChilds(List<Block> childs) {
		this.childs = childs;
	}

	public void addChild(Block block) {
		if (childs == null) {
			childs = new ArrayList<Block>();
		}
		childs.add(block);
	}

	@Override
	public String show() {
		if (childs != null) {
			StringBuilder ret = new StringBuilder();
			childs.stream().forEach(child -> ret.append(child.show()));
			return addSpaces(getSpaceCount(), ret.toString());
		} else {
			LOGGER.warn("event_name=NonLeafBlock_has_no_child block_name={}", getName());
			return "";
		}
	}
}
