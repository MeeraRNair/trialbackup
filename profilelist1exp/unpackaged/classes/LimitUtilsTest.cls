@isTest
private class LimitUtilsTest{
	private static testmethod void testAllowableQueryRows(){
		Integer queryRows=Limits.getLimitQueryrows() - Limits.getQueryRows();
		Integer intQueryRow= LimitUtils.getAllowableQueryRows();
		System.assertEquals(queryRows,intQueryRow);
	}
	public static testmethod void testAllowableQueries(){
		Integer queries=Limits.getLimitQueries() - Limits.getQueries();
		Integer intQueries= LimitUtils.getAllowableQueries();
		System.assertEquals(queries,intQueries);
	}
	public static testmethod void testAllowableDMLRows(){
		Integer DMLrows=Limits.getLimitDMLRows() - Limits.getDMLRows();
		Integer intDMLrows= LimitUtils.getAllowableDMLRows();
		System.assertEquals(DMLrows,intDMLrows);
	}
	public static testmethod void testAllowableDMLStatements(){
		Integer DMLstatements=Limits.getLimitDMLStatements() - Limits.getDMLStatements();
		Integer intDMLstatements= LimitUtils.getAllowableDMLStatements();
		System.assertEquals(DMLstatements,intDMLstatements);
	}
}