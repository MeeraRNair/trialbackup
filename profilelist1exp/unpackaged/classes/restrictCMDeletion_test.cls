@IsTest
private class restrictCMDeletion_test 
{
    private static testMethod void testDeleteLeadCM()
    {
        Campaign testCampaign = new Campaign(Name='Test Campaign123',
                                    Campaign_Objective__c = 'LOB Conversion',
                                    Type='DM',
                                    Segment_Business_Unit__c='PUB',                                 
                                    StartDate=System.Today() - 10,
                                    EndDate=System.Today(),
                                    Description='This is Test Campaign',
                                    Parent_Vehicle__c='Events',
                                    IsActive=true,
                                    Lead_Routing__c = 'Not Applicable'); 
            insert testCampaign;
        
        Id directLeadRT = IdLookupUtils.getRecordTypeId('Direct Lead 2.0', 'Lead', true);
        Lead testLead = new Lead(FirstName = 'test123',
                            LastName = 'Test Lead1',
                            Company = 'Test Company',
                            Status = 'Open',
                            Email = 'no_reply@dell.com',
                            Campaign__c = testCampaign.id,
                            RecordTypeId = directLeadRT,                             
                            LeadSource = 'Other',
                            Lead_Type__c = 'Inbound',
                            Country_code__c='US',
                            Lead_Capture_DateTime__c = System.now()); 
            insert testLead;
        
        CampaignMember testCampaignMember = [select id from CampaignMember where leadId =:testLead.Id limit 1];                                              
        
        test.starttest();
        delete testCampaignMember;
        test.stoptest();       
                                                                               
    }
    
    private static testMethod void testDeleteContactCM()
    {
        Campaign testCampaign = new Campaign(Name='Test Campaign123',
                                    Campaign_Objective__c = 'LOB Conversion',
                                    Type='DM',
                                    Segment_Business_Unit__c='PUB',                                 
                                    StartDate=System.Today() - 10,
                                    EndDate=System.Today(),
                                    Description='This is Test Campaign',
                                    Parent_Vehicle__c='Events',
                                    IsActive=true,
                                    Lead_Routing__c = 'Not Applicable'); 
        insert testCampaign;
        
        Account testAccount  = new Account(Name='Test Account');
        insert testAccount;
        
        Contact testContact = new Contact(AccountId=testAccount.Id,
                                    Email='testCon@dell.com',
                                    FirstName = 'Test', 
                                    LastName = 'Contact',
                                    Title='VP',
                                    MailingStreet='123 Main',
                                    MailingCity='Peoria',
                                    MailingState='IL',
                                    MailingPostalCode='33333',
                                    Phone='3213213211',
                                    MobilePhone='3213213211',
                                    Fax='3213123211');
           insert testContact;
         
        
        CampaignMember testCampaignMember = new CampaignMember(CampaignId = testCampaign.Id,ContactId = testContact.Id,CM_Status__c = 'Requires Follow-Up'); 
        
            insert testCampaignMember;                                                 
        
        test.starttest();
        delete testCampaignMember;
        test.stoptest();       
                                                                               
    }
}