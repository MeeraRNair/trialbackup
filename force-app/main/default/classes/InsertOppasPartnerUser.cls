/*        
 * Revision Ref Number         Release No  Date            Modified By     Description
 * -------- ----------         ----------  -----------     ------------    -----------
 * 1.0      N/A                N/A         N/A             N/A             N/A 
 * 2.0      CR 16970           FY20-0202   08-01-2019      Emily           Removed virtualization__c
*/

@istest
private class InsertOppasPartnerUser{

    //Added custom settings to populate StageName values.
    @testSetup static void setup() {
        // Create common test OWD settings
        OWD__c owdSetting = new OWD__c();
        owdSetting.Oppty_Stage1__c = 'Plan - 1%';
        owdSetting.Oppty_Stage10__c = 'Discover - 10%';
        owdSetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdSetting.Oppty_Stage60__c = 'Propose - 60%';
        owdSetting.Oppty_Stage90__c = 'Commit - 90%';
        owdSetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdSetting.Oppty_Stage100__c = 'Win - 100%';
        owdSetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        Insert owdSetting;
    }
    
    public static testMethod void createData() {

        profile profileRec = [select id from profile where name like '%PRM Portal%' Limit 1];
        UserRole userRoleRec = [Select PortalAccountId, Name, Id From UserRole where name like '%WW_Exec' Limit 1];
        RecordType recType = [SELECT Name, Id, SobjectType FROM RecordType WHERE Name = 'Deal Registration for Existing End Customer' AND SobjectType = 'Opportunity'];
            
        Account partnerAccount = new Account();
        partnerAccount.Name = 'PartnerAccount';
        partnerAccount.Account_Country_Code__c = 'AI';
        partnerAccount.Account_Country__c = 'ANGUILLA';
        partnerAccount.Type = 'Partner';
        
        TriggerExecutionController.setSkipAllTriggers(true); 
        insert partnerAccount;        
        
        partnerAccount.IsPartner = true;
        partnerAccount.RecordTypeId = System.Label.RecType_Partner_Account;
        update partnerAccount;
        
        TriggerExecutionController.setSkipAllTriggers(false); 
        
        Contact partnerContact = new Contact(); 
        partnerContact.AccountId = partnerAccount.id;
        partnerContact.Email = 'John.Doe@dell.com';
        partnerContact.FirstName = 'John';
        partnerContact.LastName = 'Doe';
        partnerContact.Title = 'VP';
        partnerContact.MailingStreet = '123 Main';
        partnerContact.MailingCity = 'Peoria';
        partnerContact.MailingState = 'IL';
        partnerContact.MailingPostalCode = '33333';
        partnerContact.Phone = '3213213211';
        partnerContact.MobilePhone = '3213213211';
        partnerContact.Fax = '3213123211';
        
        TriggerExecutionController.setSkipAllTriggers(true); 
        insert partnerContact;               
        TriggerExecutionController.setSkipAllTriggers(false); 
            
        User userRec = new User();
        userRec.Username = 'XXYYZZ@dell.com';
        userRec.Alias = 'test';
        userRec.Email = 'testuser@test.com';
        userRec.FirstName = 'John';
        userRec.LastName = 'Doe';
        userRec.ProfileId = profileRec.Id;
        userRec.LanguageLocaleKey = 'en_US';
        userRec.LocaleSidKey = 'en_US';
        userRec.EmailEncodingKey = 'UTF-8';
        userRec.TimeZoneSidKey = 'America/Los_Angeles';
        userRec.Badge_Number__c = null;
        userRec.ContactId = partnerContact.id;
        
        TriggerExecutionController.setSkipAllTriggers(true); 
        insert userRec;
        TriggerExecutionController.setSkipAllTriggers(false); 
    
        test.startTest();
        
        System.runAs(userRec) {
            Opportunity customerOppty = new Opportunity();
            customerOppty.Name = 'Test2';
            customerOppty.Total_Expected_Dell_Revenue__c = 1000;
            customerOppty.CloseDate = System.today() + 100;
            customerOppty.Engagement_Type__c = 'Public Tender';
            customerOppty.OS_Type__c = 'Other';
            customerOppty.Solution_Scope__c = 'Hardware and support only';
            customerOppty.Justification_Statement__c = 'adaddaf';
            //2.0 customerOppty.virtualization__c = 'None';
            customerOppty.GTM_Message__c = 'xxxxxxx';
            customerOppty.StageName = 'Plan - 1%';
            customerOppty.recordtypeId = recType.Id;
            TriggerExecutionController.setSkipOpportunityTriggers(true);
            List<Opportunity> Opplist = new List<Opportunity>();
            Opplist.add(customerOppty);
            
            insert Opplist;
            TriggerExecutionController.setSkipOpportunityTriggers(false);
                        
            Opplist = [Select Id, PartnerAccountId from Opportunity where Id =: customerOppty.id];
            AutoPopulateCustomerNumber NewObj = new AutoPopulateCustomerNumber();
            NewObj.updatePartnerAccountEmail(Opplist);
                       
        }
        
        test.stopTest();
    }
}