/*
 * Purpose  : Test class for QueryUtils.
 * 
 */

public with sharing class QueryUtilsTest {
	
  	public static testMethod void TEST_QueryUtils() { 
	    Account testAcc1 = new Account(Name = 'test1');
	    insert testAcc1;
	    
	    Account testAcc2 = new Account(Name = 'test2');
	    insert testAcc2;
	    
	    Map<id, id> test = new Map<id, id>();
	    test.put(testAcc1.id,testAcc2.id);
	    QueryUtils obj = new QueryUtils();
	    String str = QueryUtils.getWhereClauseFromInput(test, '122', '122');
	}
	
	public static testMethod void testFormQuery() { 
	    QueryUtils.formQuery('Account', new set<String>{'Id', 'Name'});
	}
	
}