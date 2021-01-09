public class LimitUtils{
	public static Integer getAllowableQueryRows(){
		return (Limits.getLimitQueryrows() - Limits.getQueryRows());
	}
	public static Integer getAllowableQueries(){
		return (Limits.getLimitQueries() - Limits.getQueries());
	}
	public static Integer getAllowableDMLRows(){
		return (Limits.getLimitDMLRows() - Limits.getDMLRows());
	}
	public static Integer getAllowableDMLStatements(){
		return (Limits.getLimitDMLStatements() - Limits.getDMLStatements());
	}
}