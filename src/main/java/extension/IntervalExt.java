package extension;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.Set;
import java.util.stream.Stream;

import org.antlr.v4.runtime.misc.Interval;
import org.antlr.v4.runtime.misc.IntervalSet;

public class IntervalExt {
	public static Set<Integer> toSet(Interval interval) {
		Set<Integer> lst = new HashSet<Integer>();
		for (int i = interval.a; i <= interval.b; i++) {
			lst.add(i);
		}
		return lst;
	}
	
	public static Set<Integer> toSet(IntervalSet iset){
		Set<Integer> s=new HashSet<Integer>();
		iset.getIntervals().stream().
			map(interval->toSet(interval)).
			flatMap((Set<Integer> integerSet)->integerSet.stream()).forEach(i->s.add(i));
		return s;
	}

	public static Stream<Integer> toStream(IntervalSet iset) {
		if (iset == null)
			return new ArrayList<Integer>().stream();
		return iset.getIntervals().stream().map(interval -> IntervalExt.toSet(interval)).flatMap(lst -> lst.stream());
	}
	
	public static Stream<String> toTokens(IntervalSet iset, String[] tokenNames){
		if(iset==null)
			return new ArrayList<String>().stream();
		return iset.getIntervals().stream().
				map(
						interval -> IntervalExt.toSet(interval)).flatMap(lst -> lst.stream()
				).map(
						index->{
							if(index>=0 && index<tokenNames.length){
								return tokenNames[index];
							}else{
								return "";
							}
						}
				);

	}
}
