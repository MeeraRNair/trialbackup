@isTest
private class afterDeleteEndCustomerTrigrTest {

    private static testmethod void afterDeleteEndCustomerTrigger (){
    
        Account account = new Account(name='HubTest',account_country_code__c='US');
        
        insert account;
        account.isPartner = true;
        account.Type = 'Partner';
        update account;
        
        
        End_Customer__c PRURec = new End_Customer__c();
        PRURec.Partner_Account__c = account.id;
        PRURec.Mailing_city__c = 'Cyberjaya';
        PRURec.Mailing_State__c = 'Selangor';
        insert PRURec;
        List <End_Customer__c>  PRTest = [Select Customer_Id__c, Id from End_Customer__c where Id = : PRURec.id];
        delete PRURec;
        
        Test.startTest();
            
        List <Partner_Hub_Record_Deleted__c>  PartnerHubRecTest = [Select Key_Identifier__c, Record_GUID__c, Type__c from Partner_Hub_Record_Deleted__c where Record_GUID__c = : PRTest[0].id];
        
        PartnerHubRecTest[0].Key_Identifier__c = PRTest[0].Customer_Id__c ;
        PartnerHubRecTest[0].Record_GUID__c = PRTest[0].Id ;
        PartnerHubRecTest[0].Type__c = 'End Customer' ;
                
        Test.stopTest();
		
		delete account;
		
        
    }
}