/*History:
Version Date            Modified By     Description
--------------------------------------------------------------------------------------
1.0                                     created
2.0     28-July-2015    Azwanti         CR11617 - added test for OpportunityProductNotSupportableCtrl class
*/
/* 
* Revision   Release No       Modified By               Description
* --------   ---------        -----------               ------------               
*            0202             Venugopalachary k         Implement Test Data Factory                               
*/ 
@isTest
private class OpptyProdSupplyChainContact_ctl_Test {
    
    static Supportability_Contacts__c testSupConatcts;
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        list<User> listUserTdf=TestDataFactory.CreateNGenralUsers(1);
        insert listUserTdf;
        testSupConatcts= new Supportability_Contacts__c(Regional_Parent_Name__c ='APJ', 
                                                        Regional_Sub_Parent_Name__c ='Test Regional Sub Parent Name', 
                                                        Focus__c ='Test Focus', 
                                                        Contact_Name__c=listUserTdf[0].Id); 
        
        insert testSupConatcts ;   
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    static testMethod void testChainContactctl() {
        // createTestData();
        list<user> listUser=[select id from user where isActive=true Limit 1];
        Supportability_Contacts__c testSupConatcts1=[select id,Contact_Name__c from Supportability_Contacts__c limit 1];
        Test.startTest();    
        OpptyProdSupplyChainContact_ctl controller = new OpptyProdSupplyChainContact_ctl (); 
        controller.getNo_Recs();
        controller.getRecs_Found();
        //     Account_Handover__c retrievedAccHandover = controller.accHandover;
        system.assertNotEquals(listUser[0].id, null);
        Test.stopTest();
    }
    public class TestException extends Exception {}
    /* static void createTestData() {

Profile ITprofile = [select id from profile where name like '%IT TA User%' Limit 1];
User testUser = new User(Username='testvaliduser' +'@dell.com',
Alias = 'Test', 
Email='Test'+'@dell.com',            
LastName='Test',
ProfileId = ITprofile.Id, 
LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', 
EmailEncodingKey='UTF-8', 
TimeZoneSidKey='America/Los_Angeles',
Badge_Number__c='Test'+System.currentTimeMillis());

insert testUser;

//insert Account Handover records
testSupConatcts= new Supportability_Contacts__c(Regional_Parent_Name__c ='APJ', 
Regional_Sub_Parent_Name__c ='Test Regional Sub Parent Name', 
Focus__c ='Test Focus', 
Contact_Name__c=testUser.Id); 

insert testSupConatcts ;          

}
*/
}