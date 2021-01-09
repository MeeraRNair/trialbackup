@isTest
private class beforeInsertStdCampaignMemberTest {
    public static testMethod void beforeInsertCMTest(){
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
                                Fax='3213123211',
                                Partner_My_Account_GUID__c='3456');
    insert testContact;
    Campaign testCampaign = new Campaign(Name='Test Campaign',
                                        Campaign_Objective__c = 'LOB Conversion',
                                        Type='DM',
                                        Segment_Business_Unit__c='PUB',
                                        //Region__c='ABU',
                                        StartDate=System.Today() - 10,
                                        EndDate=System.Today(),
                                        Description='This is Test Campaign',                                            
                                        Account_Play_Expiry_Date__c=System.today() + 60,
                                        Nomination_close_Date__c=System.today() + 60,
                                        allow_nomination__c=true,
                                        Is_this_Account_Play_Campaign__c=false,
                                        IsActive=true);
    insert testCampaign;
    
    Profile profile = [select id from profile where name like '%Sales Rep%' order by name limit 1];
    User testUser = new User(Username='testvaliduser' +'@dell.com',
                                Alias = 'Test', 
                                Email='Test'+'@dell.com',            
                                LastName='Test',
                                ProfileId = profile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='Test'+System.currentTimeMillis());
    insert testUser;
    campaignMember testCM = new campaignMember(
                                Inside_Sales_Rep_ID__c=testuser.id,
                                CampaignId=testcampaign.id,
                                Campaign_Vehicle__c='DM',
                                contactId=testContact.Id,
                                CM_status__c='Requires Follow-Up');
    insert testCM;
    campaignMember campMem = [select id,inside_sales_rep_bypass__c from CampaignMember where id=:testCM.id limit 1];
    System.assertequals(campMem.inside_sales_rep_bypass__c,testuser.id);
   }
}