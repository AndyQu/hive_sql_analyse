package hivesql.analysis.format;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class Block {
	protected static final Logger LOGGER = LoggerFactory.getLogger(Block.class);
	private int spaceCount;
	
	private String name;
	
	public Block(String name){
		this.name=name;
	}
	
	public Block(){
		
	}

	public int getSpaceCount() {
		return spaceCount;
	}

	public void setSpaceCount(int spaceCount) {
		this.spaceCount = spaceCount;
	}
	
	public abstract String show();

	public static String buildSpaces(int count){
		StringBuilder ret=new StringBuilder();
		for(int i=0;i<count;i++){ret.append(" ");}
		return ret.toString();
	}

	public static String addSpaces(int spaceCount, String orgin){
		StringBuilder r = new StringBuilder();
		String[] arr = orgin.toString().split("\n");
		for(int i=0;i<arr.length;i++){
			String line=arr[i];
			if(i==arr.length-1){
				if(!orgin.endsWith("\n")){
					r.append(String.format("%s%s",buildSpaces(spaceCount),line));
				}else{
					r.append(String.format("%s%s\n",buildSpaces(spaceCount),line));
				}
			}else{
				r.append(String.format("%s%s\n",buildSpaces(spaceCount),line));
			}
		}
		return r.toString();
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}
	
	public abstract boolean isStartedWithLine();
	public abstract boolean isEndedWithLine();
	
	@Override
	public String toString(){
		return getName();
	}
	
}
