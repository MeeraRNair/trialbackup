/* Revision Ref Number  Release No      Date            Modified By     Description
* -------- ----------  ----------      -----------     ------------    -----------
* 1.0      CR 13504    FY17-DCS-1102   19-Sep-2016     Sajith          LM2_Enhancement for reassignment logic to stick to campaign follow up role
*/
@isTest
Private class Batch_RecalculateLeadOwner_Test
{
    static testMethod void testRecalculateLeadOwnerATM() {
        Id directLead2RTId = StaticFactory.getRecordTypeIdByName('Lead', 'Direct Lead 2.0');
        //1.0
        TriggerExecutionController.setSkipAllTriggers(true);
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        test.starttest();
        
        User objUser1 = new User(Alias = 'st0901', Email='st0901@dell.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, Badge_Number__c='AAAAAA',
                           TimeZoneSidKey='America/Los_Angeles', UserName='st0901@dell.com');
        insert objUser1;
        
        User objUser2 = new User(Alias = 'st0902', Email='st0902@dell.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, Badge_Number__c='ZZZZZZ',
                           TimeZoneSidKey='America/Los_Angeles', UserName='st0902@dell.com');
        insert objUser2;
        //1.0
        
        LeadAssignment_TestHelper.createAccounts();
        Account objAccountEU = LeadAssignment_TestHelper.endUserAccount;
       
        //1.0
        AccountTeamMember objAccTeammember1=new AccountTeamMember();
        objAccTeammember1.AccountId=objAccountEU.id;
        objAccTeammember1.UserId=objUser1.id;
        objAccTeammember1.TeamMemberRole = 'Affiliates Technical Sales Rep';
        Insert objAccTeammember1;
        
        Campaign objCampaign = new Campaign(Name='Campaign_CMAP',
                                               Follow_Up_Role__c='Account Executive',
                                               Secondary_Role__c='Affiliates Technical Sales Rep',
                                               Description='Test',StartDate=system.today(),EndDate=system.today(),
                                               status='In Progress',
                                               IsActive = true,
                                               Total_Campaign_Targets_Planned__c = 1,
                                               Lead_Routing__c = 'Not Applicable');
        insert objCampaign;
        //1.0
        
        list<Lead> listLeads = new list<Lead>();
        Datetime dlastOwnerAssignment = system.today();
        
        
        LeadTestData.bCreate = true;
        LeadTestData.iNumberOfLeads = 5;
        LeadTestData.createDirectLead2();
        listLeads = LeadTestData.lstLeads ;
        Lead objLead = listLeads[0];
        
        List<contact> listContacts;
        ContactTestData.iNumberOfContacts = 1;
        ContactTestData.bCreate = false;
        ContactTestData.createContact();
        listContacts = ContactTestData.lstContacts;
        listContacts[0].accountid= objAccountEU.id;
        //TriggerExecutionController.setSkipContactTriggers(true);
        insert listContacts;
        //TriggerExecutionController.setSkipContactTriggers(false);
        
        objLead.contact__c = listContacts[0].id;
        objLead.Account__c =objAccountEU.id;
        objLead.Campaign__c = objCampaign.Id;
        objLead.Status ='New';
        objLead.OwnerId = objUser1.id;
        objLead.Lead_Owner_System_Auto_Populated__c  =true;
        objLead.Last_Owner_Reassignment_Date__c   = system.today();
        //TriggerExecutionController.setSkipLeadTriggers(false);
        update objLead;
        //1.0
        objLead.Lead_Owner_System_Auto_Populated__c = true;
        update objLead;
        //TriggerExecutionController.setSkipLeadTriggers(false);
        
        AccountTeamMember objAccTeammember2=new AccountTeamMember();
        objAccTeammember2.AccountId=objAccountEU.id;
        objAccTeammember2.UserId=objUser2.id;
        objAccTeammember2.TeamMemberRole = 'Account Executive';
        Insert objAccTeammember2;
        //1.0
        
        Date StartDate = System.now().date()-2;
        Date EndDate = System.now().date()+2;  
                  
        Batch_RecalculateLeadOwner batch = new Batch_RecalculateLeadOwner(StartDate,EndDate);
        Database.executeBatch(batch,1);
        Test.stoptest();
        TriggerExecutionController.setSkipAllTriggers(false);
        system.assertEquals(objUser1.Id, objLead.OwnerId);
    }
    
    //1.0 New method to test a Non ATM lead owner
    static testMethod void testRecalculateLeadOwnerNonATM() {
        TriggerExecutionController.setSkipAllTriggers(true);
        Id directLead2RTId = StaticFactory.getRecordTypeIdByName('Lead', 'Direct Lead 2.0');
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        User objUser1 = new User(Alias = 'TestU1', Email='TestU1@dell.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, Badge_Number__c='XXXXXX',
                           TimeZoneSidKey='America/Los_Angeles', UserName='TestU1@dell.com');
        
        
        User objUser2 = new User(Alias = 'TestU2', Email='TestU2@dell.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, Badge_Number__c='YYYYYY',
                           TimeZoneSidKey='America/Los_Angeles', UserName='TestU2@dell.com');
        
        
        User objUser3 = new User(Alias = 'TestU3', Email='TestU3@dell.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, Badge_Number__c='ZZZZZZ',
                           TimeZoneSidKey='America/Los_Angeles', UserName='TestU3@dell.com');
        try{
            insert objUser1;
            insert objUser2;
            insert objUser3;
        }
        catch(Exception e){
            system.debug('Mixed DML Exception');
        }
        LeadAssignment_TestHelper.createAccounts();
        Account objAccountEU = LeadAssignment_TestHelper.endUserAccount;
        
        AccountTeamMember objAccTeammember1=new AccountTeamMember();
        objAccTeammember1.AccountId=objAccountEU.id;
        objAccTeammember1.UserId=objUser1.id;
        objAccTeammember1.TeamMemberRole = 'Inside Sales Rep';
        Insert objAccTeammember1;
        
        Campaign objCampaign = new Campaign(Name='Campaign_CMAP',
                                               Follow_Up_Role__c='Account Executive',
                                               Secondary_Role__c='Affiliates Technical Sales Rep',
                                               Description='Test',StartDate=system.today(),EndDate=system.today(),
                                               status='In Progress',
                                               IsActive = true,
                                               Total_Campaign_Targets_Planned__c = 1,
                                               Lead_Routing__c = 'Not Applicable');
        insert objCampaign;
        
        list<Lead> listLeads = new list<Lead>();
        Datetime dlastOwnerAssignment = system.today();
        
        test.starttest();
        LeadTestData.bCreate = true;
        LeadTestData.iNumberOfLeads = 5;
        LeadTestData.createDirectLead2();
        listLeads = LeadTestData.lstLeads ;
        Lead objLead = listLeads[0];
        
        List<contact> listContacts;
        ContactTestData.iNumberOfContacts = 1;
        ContactTestData.bCreate = false;
        ContactTestData.createContact();
        listContacts = ContactTestData.lstContacts;
        listContacts[0].accountid= objAccountEU.id;
        //TriggerExecutionController.setSkipContactTriggers(true);
        insert listContacts;
        //TriggerExecutionController.setSkipContactTriggers(false);
        
        objLead.contact__c = listContacts[0].id;
        objLead.Account__c =objAccountEU.id;
        objLead.Campaign__c = objCampaign.Id;
        objLead.Status ='New';
        objLead.OwnerId = objUser1.id;
        objLead.Lead_Owner_System_Auto_Populated__c  =true;
        objLead.Last_Owner_Reassignment_Date__c   = system.today();
        //TriggerExecutionController.setSkipLeadTriggers(true);
        update objLead;  
        
        objLead.Lead_Owner_System_Auto_Populated__c = true;
        update objLead;
        //TriggerExecutionController.setSkipLeadTriggers(false);
        
        AccountTeamMember objAccTeammember2=new AccountTeamMember();
        objAccTeammember2.AccountId=objAccountEU.id;
        objAccTeammember2.UserId=objUser3.id;
        objAccTeammember2.TeamMemberRole = 'Affiliates Technical Sales Rep';
        Insert objAccTeammember2;
        
        Date StartDate = System.now().date()-2;
        Date EndDate = System.now().date()+2; 
              
        Batch_RecalculateLeadOwner batch = new Batch_RecalculateLeadOwner(StartDate,EndDate);
        Database.executeBatch(batch,1);
        Test.stoptest();
        TriggerExecutionController.setSkipAllTriggers(false);
        system.assertEquals(objUser1.Id, objLead.OwnerId);
    }
    
    Static testMethod void Test_BatchRecalcSchedular(){
       
       Test.StartTest();
                  
       Batch_RecalculateLeadOwner_Schedule sh1 = new Batch_RecalculateLeadOwner_Schedule();
       String sch = '0 0 8 * * ?'; 
       system.schedule('Test BatchRecalculate 2_30_days', sch, sh1); 
       
       Batch_RecalculateLeadOwner_Schedule1 sh2 = new Batch_RecalculateLeadOwner_Schedule1();
       String sch1 = '0 0 16 * * ?'; 
       system.schedule('Test BatchRecalculate 31_90 days', sch1, sh2); 
       
       Test.StopTest();
    }
    
}