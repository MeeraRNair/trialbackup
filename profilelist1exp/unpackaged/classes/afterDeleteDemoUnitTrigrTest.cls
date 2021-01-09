@isTest
private class afterDeleteDemoUnitTrigrTest {

    private static testmethod void afterDeleteDemoUnitTrigger(){
    
        Account account = new Account(name='HubTest',account_country_code__c='US');
        insert account;
        
        
        Demo_Unit__c DemoURec = new Demo_Unit__c();
        DemoURec.Partner_Account_Name__c = account.id;
        insert DemoURec;
        List <Demo_Unit__c>  DemoUTest = [Select Name, Id from Demo_Unit__c where Id = : DemoURec.id];
        delete DemoUTest;
        
        Test.startTest();
            
        List <Partner_Hub_Record_Deleted__c>  PartnerHubRecTest = [Select Key_Identifier__c, Record_GUID__c, Type__c from Partner_Hub_Record_Deleted__c where Record_GUID__c = : DemoURec.id];
        
        PartnerHubRecTest[0].Key_Identifier__c = DemoUTest[0].Name ;
        PartnerHubRecTest[0].Record_GUID__c = DemoUTest[0].Id ;
        PartnerHubRecTest[0].Type__c = 'Demo Unit' ;
                
        Test.stopTest();
        delete account;
		
    }
}