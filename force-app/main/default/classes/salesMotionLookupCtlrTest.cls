@isTest
private class salesMotionLookupCtlrTest{
 static testMethod void loookupCtlrTestMethod() 
    {
        string recordTypeId=[select id from RecordType where sobjectType='Sales_Motion__c' and name='Generic Sales'].Id;
        Sales_Motion__c salesMtn=new Sales_Motion__c(name='test1', Sales_Motion_Use_Case__c='tests2',
                                    Solution_Description__c='test desc',SalesEdge_Category__c='test categ');
        insert salesMtn;
        System.currentPageReference().getParameters().put('searchSM', 'test1');
        salesMotionLookupCtlr  lookupCtlrObj=new salesMotionLookupCtlr ();
        lookupCtlrObj.searchText='test1';
        lookupCtlrObj.go();
        lookupCtlrObj.previous();
        lookupCtlrObj.next();
        lookupCtlrObj.last();
        lookupCtlrObj.first();
    
    }
}