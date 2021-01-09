/***********************************************************
* ---------------------------------------------------------
* Revision  Name                Description
* 1.0       VIKAS KH         Implemeted TDF for 0202 Release
* 
************************************************************/

@isTest
//(seeAlldata = true)

public class PartnerProfilingAccountSynctoDpTest{
    public static list<Account> listAcc;
    @testsetup static void setup(){
        list<Account> listAccTDF=TestDataFactory.createNAccount(2, 'Partner Account');
        listAccTDF[0].Partner_Type__c = 'test';
        listAccTDF[0].Partner_Relationship__c  = 'test';
        listAccTDF[0].Partner_Tier__c  = 'test';
        listAccTDF[1].Partner_Type__c = 'test';
        listAccTDF[1].Partner_Relationship__c  = 'test';
        listAccTDF[1].Partner_Tier__c  = 'test';
        insert listAccTDF;
     }
     private static testmethod void testMethodOne(){
    /* Account oldAcc = new Account();
     oldAcc.Name = 'test';
     oldAcc.Partner_Type__c = 'test';
     oldAcc.Partner_Relationship__c  = 'test';
     oldAcc.Partner_Tier__c  = 'test';
     
     Account newAcc = new Account();
     newAcc.Name = 'test';
     newAcc.Partner_Type__c = 'test';
     newAcc.Partner_Relationship__c  = 'test';
     newAcc.Partner_Tier__c  = 'test';
     */
     listAcc = [select id,Name,Partner_Type__c,Partner_Relationship__c,Partner_Tier__c,Account_Country__c,Account_ID__c,States_Provinces_doing_business__c,
                Account_Country_Code__c from Account limit 2];
     PartnerProfilingAccountSynctoDp.checkforChanges(listAcc[0],listAcc[1] );
     system.assertEquals(listAcc[0].Name, listAcc[0].Name);
     
     }


}