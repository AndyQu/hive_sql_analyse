package antlr4.extension;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

import org.antlr.v4.runtime.Vocabulary;
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

	public static Set<Integer> toSet(IntervalSet iset) {
		Set<Integer> s = new HashSet<Integer>();
		iset.getIntervals().stream().map(interval -> toSet(interval))
				.flatMap((Set<Integer> integerSet) -> integerSet.stream()).forEach(i -> s.add(i));
		return s;
	}

	public static List<Integer> toList(IntervalSet iset) {
		if (iset == null)
			return new ArrayList<Integer>();
		return iset.getIntervals().stream().map(interval -> IntervalExt.toSet(interval)).flatMap(lst -> lst.stream())
				.collect(Collectors.toList());
	}

	public static List<String> toTokens(IntervalSet iset, Vocabulary vac) {
		return toList(iset).stream().map(index -> {
			String literal = vac.getLiteralName(index);
			if (literal == null)
				literal = "";
			return literal;
		}).collect(Collectors.toList());
	}
}
