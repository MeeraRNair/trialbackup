/*
 * Author   : Syidah
 * Purpose  : Test class for CaseRecordSelector. 
 *
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR 12450    16.12       05-Jan-2016     Syidah          LM2_16_1- Sharing new cases with requestor before changing case owner
 * 1.0                   0102       18-10-2019      venu            Implimented TestDataFactory        
 */
 @isTest
 private class CaseRecordSelectorTest{
 static testMethod void testgetRecords() {
    list<case> listCase=TestDataFactory.createNCases(1);
     insert listCase;
     system.assertNotEquals(listCase[0].id, null);
    User newOwner = [select Id from User where IsActive = true and Id != :UserInfo.getUserId() and License_Used__c = 'Salesforce' limit 1];
    }
 }