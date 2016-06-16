package hivesql.analysis.format;

import java.util.Arrays;

import com.sun.management.VMOption.Origin;

public abstract class Block {
	private int spaceCount;

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
}
