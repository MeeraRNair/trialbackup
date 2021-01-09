/*
Author: Carmen

History:
Version  Date          Modified By     Description     
--------------------------------------------------------------------------------------
1.0      19-Nov-2010   Carmen          Created for CR4460
2.0      02-Dec-2010   Carmen          Added Send Account Suggestion flag
*/

public with sharing class BatchLinkAccountTest {
 
 static void TestBatchLinkAccountExecute(String leadId) {
    BatchLinkAccount bLinkAccount = new BatchLinkAccount();
        String query = 'SELECT l.Status, l.Account__c, l.Suggestion_ID__c, l.RecordType.Name, l.Partner_Request__r.Account__c, l.Partner_Request__r.Send_Account_Suggestion_Is_Complete_Flag__c, l.Partner_Request__r.Link_to_Account_Record_Is_Complete_Flag__c, l.Partner_Request__r.Status__c';
        query += ' FROM Lead l WHERE';
        query += ' Id = \'' + leadId + '\' AND';
        //query += System.Label.Query_All != 'True' ? ' l.LastModifiedDate > LAST_N_DAYS:2 AND' : ''; 
        query += ' (((l.Partner_Request__r.Status__c = \'Account Suggestion Submitted\' OR l.Partner_Request__r.Status__c = \'Lead Draft\') AND (l.Status = \'Account Suggestion Submitted\' OR l.Status = \'Account Suggestion Completed\'))';
        query += ' OR';
        query += ' (l.Suggestion_ID__c = null AND (l.RecordType.Name = \'Account Suggestion\' OR l.RecordType.Name = \'Account Suggestion Locked\') AND (l.Account__c != null OR l.Partner_Request__r.Account__c != null)))';
        bLinkAccount.query = query; 
        system.debug('Query :'+query);
        Test.startTest();                   
        Database.executeBatch(bLinkAccount,200);
        Test.stopTest();
 }
 
 static testMethod void PRLeadNotLinkedToAccount() { 
   
       
    Partner_Request__c testPartnerRequest = new Partner_Request__c(
        Status__c = 'Account Suggestion Submitted');    
    insert testPartnerRequest;
    Campaign objCampaign = new Campaign(Name='Campaign_CMAP',
                                               Follow_Up_Role__c='Account Executive',
                                               Secondary_Role__c='Affiliates Technical Sales Rep',
                                               Description='Test',StartDate=system.today(),EndDate=system.today(),
                                               status='In Progress',
                                               IsActive = true,
                                               //MDF_Partner_ID__c='1122334477',
                                               //MDF_Partner_ID__c=lstAccount[0].Account_ID__c,
                                               Total_Campaign_Targets_Planned__c = 1,
                                               Aprimo_Activity_Id__c ='123457777777',
                                               Lead_Routing__c = 'Not Applicable');
        insert objCampaign;
    Lead objLead = new Lead(LastName = 'TestLeadLName',
            Lead_Type__c = 'Inbound',
            Email = 'testcmap@cmaptest.com',
            Status = 'Cancelled',
            Phone = '88967544',
            Country = 'US',
            Partner_Request__c = testPartnerRequest.Id,
            Campaign__c = objCampaign.Id,
            Company = 'Test Company',
            LeadSource='Partner',
            Lead_Score__c = 'High Priority (Extremely hot leads; SLA = 48 hours)',
            Country_Code__c = 'US');
            
        TriggerExecutionController.setSkipLeadTriggers(true);
            insert objLead;
        TriggerExecutionController.setSkipLeadTriggers(false);
    /*Lead testLead = new Lead (
        RecordTypeId = GlobalVariables.ACCOUNT_SUGGESTION_LEAD_RECTYPE,
        Status = 'Account Suggestion Submitted',
        Suggestion_Id__c = '123456',
        LastName = 'test',
        Company = 'TestIssue1',
        Legal_Local_Address_1__c='addr1',
        Legal_Local_City__c='city1',
        Legal_Local_Country__c='us',
        Legal_Local_Postal_Code__c='233323',
        Partner_Request__c = testPartnerRequest.Id);
    insert testLead;*/
    Account a=new Account(Name ='Master Acc');
    insert a;
    Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1');
        insert trackObj;
        
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Partner_Track_Name__c = 'Tech Data';
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c = a.id;
        testPartnerTrackObj.Partner_Track_AffinityId__c='1234';
        testPartnerTrackObj.Primary_Sales_Motion_Affinity_ID__c='22222';
        insert testPartnerTrackObj;
    Account testAccount = new Account(
        Name = 'TestIssue1',
        Master_Group_Id__c=a.id,
        Partner_Track__c=testPartnerTrackObj.id,
        Legacy_Id__c = 'SFDC_'+objLead.Id);
    insert testAccount;
    
    //TestBatchLinkAccountExecute(objLead.Id); 
     string query='SELECT l.Status, l.Account__c, l.Suggestion_ID__c, l.RecordType.Name, l.Partner_Request__r.Account__c, l.Partner_Request__r.Send_Account_Suggestion_Is_Complete_Flag__c, l.Partner_Request__r.Link_to_Account_Record_Is_Complete_Flag__c, l.Partner_Request__r.Status__c FROM Lead l WHERE Id =\''+objLead.Id+'\'';
    system.debug('* Query *** :'+query);
    BatchLinkAccount bLinkAccount = new BatchLinkAccount();
    bLinkAccount.query = query; 
        Test.startTest();                   
        Database.executeBatch(bLinkAccount,200);
        Test.stopTest();
    Lead resultLead = [Select Account__c, Status, RecordType.Name from Lead where Id = :objLead.Id];
   // System.assert(resultLead.Account__c != null);
   // System.assertEquals(resultLead.Status, 'Account Suggestion Completed');
    //System.assertEquals(resultLead.RecordType.Name, 'Account Suggestion Locked');
    
    Partner_Request__c resultPartnerRequest = [Select Account__c, Send_Account_Suggestion_Is_Complete_Flag__c, Link_to_Account_Record_Is_Complete_Flag__c, Status__c from Partner_Request__c where Id = :testPartnerRequest.Id];
    /*System.assert(resultPartnerRequest.Account__c != null);
    System.assertEquals(resultPartnerRequest.Send_Account_Suggestion_Is_Complete_Flag__c, true);
    System.assertEquals(resultPartnerRequest.Link_to_Account_Record_Is_Complete_Flag__c, true);
    System.assertEquals(resultPartnerRequest.Status__c, 'Account Suggestion Completed');*/
 }
 
 static testMethod void PRLeadLinkedWithPartialUpdate() {
 
    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
    User u = new User(alias = 'jsmith', email='jsmith@dell.com.training', Badge_Number__c = 'badgenum',Title = 'title', emailencodingkey='UTF-8', lastname='Smith', languagelocalekey='en_US', localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', username='jsmith@dell.com.training');
    insert u;
    
    Partner_Request__c testPartnerRequest = new Partner_Request__c(
    Status__c = 'Account Suggestion Submitted');    
    insert testPartnerRequest;
   
    RecordType rt = new RecordType();
    rt = [select Name from RecordType where Name !='Account Suggestion' AND sObjectType ='Lead' limit 1];
  
    Lead testLead = new Lead (
        //RecordTypeId = GlobalVariables.ACCOUNT_SUGGESTION_LEAD_RECTYPE,   
        RecordTypeId = rt.Id,      
        Status = 'Account Suggestion Submitted',
        Suggestion_Id__c = '123456',
        LastName = 'test',
        Company = 'TestIssue2',
        Partner_Request__c = testPartnerRequest.Id);
        insert testLead;
    
    Account testAccount = new Account(
        Name = 'TestIssue2',
        Legacy_Id__c = 'SFDC_'+testLead.Id);
    insert testAccount;
    
    testPartnerRequest.Account__c = testAccount.Id;
    update testPartnerRequest;
    
    user u1 = [select id,Title,badge_Number__c from user where Id =:u.Id];
   
    testLead.Account__c = testAccount.Id;
    testLead.Status = 'Account Suggestion Completed';   
    testLead.Account_Owner__c = u1.Id;
    update testLead;
    
    TestBatchLinkAccountExecute(testLead.Id); 
        
    Partner_Request__c resultPartnerRequest = [Select Account__c, Send_Account_Suggestion_Is_Complete_Flag__c, Link_to_Account_Record_Is_Complete_Flag__c, Status__c from Partner_Request__c where Id = :testPartnerRequest.Id];
    System.assert(resultPartnerRequest.Account__c != null);
   // System.assertEquals(resultPartnerRequest.Send_Account_Suggestion_Is_Complete_Flag__c, true);
    System.assertEquals(resultPartnerRequest.Link_to_Account_Record_Is_Complete_Flag__c, false);
    System.assertEquals(resultPartnerRequest.Status__c, 'Account Suggestion Submitted');
 }
 
 static testMethod void PRorLeadLinkedToAccountPartialUpdate() {  
    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
    User u = new User(alias = 'jsmith', email='jsmith@dell.com.training', Badge_Number__c = 'badgenum',Title = 'title', emailencodingkey='UTF-8', lastname='Smith', languagelocalekey='en_US', localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', username='jsmith@dell.com.training');
    insert u;
    
    Partner_Request__c testPartnerRequest = new Partner_Request__c(
        Status__c = 'Account Suggestion Submitted');    
    insert testPartnerRequest;
    
    RecordType rt = new RecordType();
    rt = [select Name from RecordType where Name !='Account Suggestion' AND sObjectType ='Lead' limit 1];
   
    Lead testLead = new Lead (
        //RecordTypeId = GlobalVariables.ACCOUNT_SUGGESTION_LEAD_RECTYPE,        
        RecordTypeId = rt.Id,
        Status = 'Account Suggestion Submitted',
        Suggestion_Id__c = null,
        LastName = 'test',
        Company = 'TestIssue3',
        Partner_Request__c = testPartnerRequest.Id);
    insert testLead;
    
    Account testAccount = new Account(
        Name = 'TestIssue3',
        Legacy_Id__c = 'SFDC_'+testLead.Id);
    insert testAccount;
    
    user u1 = [select id,Title,badge_Number__c from user where Id =:u.Id];
    
    testLead.Account__c = testAccount.Id; 
    testLead.Account_Owner__c = u1.Id;  
    update testLead;
    
    TestBatchLinkAccountExecute(testLead.Id); 
    
    Lead resultLead = [Select Account__c, Status, RecordType.Name from Lead where Id = :testLead.Id];
    System.assert(resultLead.Account__c != null);
    System.assertEquals(resultLead.Status, 'Account Suggestion Completed');
    System.assertEquals(resultLead.RecordType.Name, 'Account Suggestion Locked');
    
    Partner_Request__c resultPartnerRequest = [Select Account__c, Link_to_Account_Record_Is_Complete_Flag__c, Status__c from Partner_Request__c where Id = :testPartnerRequest.Id];
    System.assert(resultPartnerRequest.Account__c != null);
    System.assertEquals(resultPartnerRequest.Link_to_Account_Record_Is_Complete_Flag__c, true);
    System.assertEquals(resultPartnerRequest.Status__c, 'Account Suggestion Completed');
 }
 
 static testMethod void scheduletest()
 {
 Test.StartTest();
  BatchLinkAccountExecute sh1 = new BatchLinkAccountExecute();
  String sch = '0 0 23 * * ?'; 
  system.schedule('Test Territory Check', sch, sh1); 
  Test.stopTest(); 
 
 }
}