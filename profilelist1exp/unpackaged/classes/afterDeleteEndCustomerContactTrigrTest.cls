@isTest
private class afterDeleteEndCustomerContactTrigrTest {

    private static testmethod void afterDeleteEndCustomerContactTrigger (){
    
        Account account = new Account(name='HubTest',account_country_code__c='US');
        insert account;
        account.isPartner = true;
        account.Type = 'Partner';
        update account;
        
        
        
        End_Customer__c ECRec = new End_Customer__c();
        ECRec.Partner_Account__c = account.id;
        ECRec.Mailing_city__c = 'Cyberjaya';
        ECRec.Mailing_State__c = 'Selangor';
        insert ECRec ;
		
		List <End_Customer__c>  ECTest = [Select Customer_Id__c, Id from End_Customer__c where Id = : ECRec.id];
		End_Customer_Contact__c PRURec = new End_Customer_Contact__c();
        
		PRURec.End_Customer__c = ECRec.id;
		PRURec.Last_Name__c = 'HubTest';
		PRURec.Email__c = 'NoReply@dell.com';
		
		insert PRURec;
        List <End_Customer_Contact__c>  PRTest = [Select Email__c, Id from End_Customer_Contact__c where Id = : PRURec.id];
        
        delete PRURec;
        
        Test.startTest();
            
        List <Partner_Hub_Record_Deleted__c>  PartnerHubRecTest = [Select Key_Identifier__c, Record_GUID__c, Type__c from Partner_Hub_Record_Deleted__c where Record_GUID__c = : PRTest[0].id];
        
        // PartnerHubRecTest[0].Key_Identifier__c = PRTest[0].Customer_Id__c ;
        PartnerHubRecTest[0].Key_Identifier__c = ECTest[0].Customer_Id__c + ' ' + PRTest[0].Email__c;
        PartnerHubRecTest[0].Record_GUID__c = PRTest[0].Id ;
        PartnerHubRecTest[0].Type__c = 'End Customer Contact' ;
                
        Test.stopTest();
        
		delete ECRec;
		delete account;
    }
}