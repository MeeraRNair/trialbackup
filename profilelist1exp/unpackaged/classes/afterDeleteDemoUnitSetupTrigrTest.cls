@isTest
private class afterDeleteDemoUnitSetupTrigrTest {

    private static testmethod void afterDeleteDemoUnitSetupTrigger(){
    
        // Account account = new Account(name='CertTest',account_country_code__c='US');
        // insert account;
        
        
        Demo_Unit_Setup__c DemoURec = new Demo_Unit_Setup__c();
        // certTrackRec.Account_Id__c = account.id;
        insert DemoURec;
        List <Demo_Unit_Setup__c>  DemoUTest = [Select Name, Id from Demo_Unit_Setup__c where Id = : DemoURec.id];
        delete DemoURec;
        
        Test.startTest();
            
        List <Partner_Hub_Record_Deleted__c>  PartnerHubRecTest = [Select Key_Identifier__c, Record_GUID__c, Type__c from Partner_Hub_Record_Deleted__c where Record_GUID__c = : DemoUTest[0].id];
        
        PartnerHubRecTest[0].Key_Identifier__c = DemoUTest[0].Name ;
        PartnerHubRecTest[0].Record_GUID__c = DemoUTest[0].Id ;
        PartnerHubRecTest[0].Type__c = 'Demo Unit Setup' ;
                
        Test.stopTest();
        
	}
}