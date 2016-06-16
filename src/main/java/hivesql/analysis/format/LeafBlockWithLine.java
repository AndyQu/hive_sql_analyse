package hivesql.analysis.format;

import java.util.ArrayList;
import java.util.List;

public class LeafBlockWithLine extends Block {
	private List<String> lines;

	public List<String> getLines() {
		return lines;
	}

	public void setLines(List<String> lines) {
		this.lines = lines;
	}

	public void addLine(String line) {
		if (lines == null) {
			lines = new ArrayList<String>();
		}
		lines.add(line);
	}
	
	public static LeafBlockWithLine build(int spaceCount, String line){
		LeafBlockWithLine b = new LeafBlockWithLine();
		b.setSpaceCount(spaceCount);
		b.addLine(line);
		return b;
	}

	@Override
	public String show() {
		StringBuilder ret = new StringBuilder();
		lines.stream().forEach(
				line->ret.append(String.format("%s\n", line))
				);
		return ret.toString();
	}
}
