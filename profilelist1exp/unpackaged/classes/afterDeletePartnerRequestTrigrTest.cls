@isTest
private class afterDeletePartnerRequestTrigrTest {

    private static testmethod void afterDeletePartnerRequestTrigger (){
    
        // Account account = new Account(name='HubTest',account_country_code__c='US');
        // insert account;
        
        
        Partner_Request__c PRURec = new Partner_Request__c();
        // certTrackRec.Account_Id__c = account.id;
        insert PRURec;
        List <Partner_Request__c>  PRTest = [Select Name, Id from Partner_Request__c where Id = : PRURec.id];
        delete PRURec;
        
        Test.startTest();
            
        List <Partner_Hub_Record_Deleted__c>  PartnerHubRecTest = [Select Key_Identifier__c, Record_GUID__c, Type__c from Partner_Hub_Record_Deleted__c where Record_GUID__c = : PRTest[0].id];
        
        PartnerHubRecTest[0].Key_Identifier__c = PRTest[0].Name ;
        PartnerHubRecTest[0].Record_GUID__c = PRTest[0].Id ;
        PartnerHubRecTest[0].Type__c = 'Partner Request' ;
                
        Test.stopTest();
        
    }
}