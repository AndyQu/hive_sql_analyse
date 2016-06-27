package antlr4.extension;

public class StringExt {
	public static String buildSpaces(int count){
		StringBuilder ret=new StringBuilder();
		for(int i=0;i<count;i++){ret.append(" ");}
		return ret.toString();
	}
}
