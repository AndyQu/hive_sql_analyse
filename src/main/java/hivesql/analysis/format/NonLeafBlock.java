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
	
	public void addChild(List<Block> blocks){
		blocks.stream().forEach(block->addChild(block));;
	}
	
	@Override
	public boolean isStartedWithLine(){
		if(childs==null||childs.size()<0)
			return false;
		Block first = childs.get(0);
		if(first instanceof NonLeafBlock){
			return ((NonLeafBlock) first).isStartedWithLine();
		}else if(first instanceof LeafBlockWithoutLine){
			return false;
		}else if(first instanceof LineOnlyBlock){
			return true;
		}else{
			throw new RuntimeException(
					String.format("event_name=unexpected-Block-Type value=%s", first.getClass().getName())
					);
		}
	}
	
	@Override
	public boolean isEndedWithLine(){
		if(childs==null||childs.size()<0)
			return false;
		Block last = childs.get(childs.size()-1);
		if(last instanceof LineOnlyBlock){
			return true;
		}else if(last instanceof LeafBlockWithoutLine){
			return false;
		}else if(last instanceof NonLeafBlock){
			return ((NonLeafBlock) last).isEndedWithLine();
		}else{
			throw new RuntimeException(
					String.format("event_name=unexpected-Block-Type value=%s", last.getClass().getName())
					);
		}
	}

	@Override
	public String show() {
		if (childs != null) {
			StringBuilder ret = new StringBuilder();
			LOGGER.debug("event_name=showNonLeafBlock block_name={}", getName());
			childs.stream().forEach(child -> ret.append(child.show()));
			return addSpaces(getSpaceCount(), ret.toString());
		} else {
			LOGGER.warn("event_name=NonLeafBlock_has_no_child block_name={}", getName());
			return "";
		}
	}
}
