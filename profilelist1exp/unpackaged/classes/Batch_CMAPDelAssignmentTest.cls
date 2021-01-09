/* 
Author: Manju Thomas
History:
Version      Date           Modified By     Description     
1.0          24-Jun-2014    Jiji            Test class for Batch_CMAPDelAssignment
2.0      15-March-2016  Azwanti      replace Campaign RT from 'Channel Campaign' to 'Campaign 2.0'.
3.0      24-Aug-2016    Azwanti      LM2_6-Fix Test Class Impacted on Campaign RT Deactivated (Part 10)
*/
/* 
* Revision   Release No       Modified By               Description
* --------   ---------        -----------               ------------               
*            0202             Venugopalachary k         Implement Test Data Factory                               
*/ 
//@isTest(SeeAllData=true)
@isTest
private class Batch_CMAPDelAssignmentTest{
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        
        final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and Name like '%PRM%' order by CreatedDate desc limit 1];
        list<Account> listAccTdf=TestDataFactory.createNAccount(1,'Partner Account');
        insert listAccTdf;
        
        list<Contact> listConTdf=TestDataFactory.createNContacts(1);
        listConTdf[0].AccountId=listAccTdf[0].id;
        insert listConTdf; 
        
        list<User> listUserTdf=TestDataFactory.CreateNGenralUsers(1);
        listUserTdf[0].ProfileId=partnerProfiles.get(0).Id;
        listUserTdf[0].ContactID=listConTdf[0].id;
        insert listUserTdf;
        
        list<Campaign> listComTdf=TestDataFactory.createNCampaign(1,'Channel Partner Communications');
        listComTdf[0].Partner_Campaign_Contact__c=listUserTdf[0].id;
        insert listComTdf;
        
        list<Account_Play__c> listAccPlay=TestDataFactory.createNAccountPlay(1,'GBL_Account_Play_RT_R10.10');
        listAccPlay[0].Account__c = listAccTdf[0].Id;
        listAccPlay[0].Campaign__c = listComTdf[0].Id;
        listAccPlay[0].Primary_Contact__c = listConTdf[0].Id;
        listAccPlay[0].Account_Executive__c = userinfo.getUserId();
        insert listAccPlay;
        TriggerExecutionController.setSkipAllTriggers(false);
        
    }
    
    static testMethod void batchCMAPDelAssignmentTest1() {
        TriggerExecutionController.setSkipAllTriggers(true);
        
        /* Id apRTId= IdLookupUtils.getRecordTypeId('GBL_Account_Play_RT_R10.10','Account_Play__c',true);
Id CampRTId= IdLookupUtils.getRecordTypeId('Channel Partner Communications','Campaign',true); //v3.0
Id leadcleansingRTId = IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete', 'Lead', true);
Lead leadObj1;
Campaign CMAP_Channel_camp;
Date dt = System.Today();
Profile AdminProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE 'System Administrator' LIMIT 1];
User AdminUser = new User(FirstName='Channel Lead Batch user', 
LastName='Test Admin', 
Title='CEO', 
UserName='CMAP_ChannelLeadTestAdminuser@test.com',
Email='CMAP_ChannelLeadTestAdminuser@dell.com', Alias='cmapcla', 
CommunityNickName='batchuser', 
ProfileId = AdminProfile.Id,
LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', 
EmailEncodingKey='UTF-8', 
TimeZoneSidKey='Asia/Kuala_Lumpur',
Badge_Number__c='cmapbatch');
insert AdminUser;

Account newCMAPAcc = new Account(name='MyTestAccountCMAP');
insert newCMAPAcc;
CMAP_Helper.skipinsert = true;       
Contact newCMAPCont = new Contact(Salutation = 'Mr.',
FirstName='MyTestContactCMAP',
LastName='MyTestContactCMAP',
Title = 'Test Title',
accountId=newCMAPAcc.Id,
Email='MyTestCMAPContactEmail_3@ust-global.com',
fax='9876543',
phone = '99888778',
MobilePhone='536389097',
Status__c = 'Marketing Suspect',
Last_Operation_Performed__c = 'testing',
MailingCountry = 'US', 
MailingCity='City Test',
MailingState = 'Test State',
MailingStreet = 'Test Street',
MailingPostalCode = '683520'
);
insert newCMAPCont;

final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and Name like '%PRM%' order by CreatedDate desc limit 1];

User partnerUser = new User(
Username='MyTest2' + System.currentTimeMillis() + '@dell.com',
Alias = 'tt2', 
Email='MyTest009@dell.com', 
FirstName='MyTestUser09', 
LastName='MyTestUser09',  
ProfileId = partnerProfiles.get(0).Id, 
LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', 
EmailEncodingKey='UTF-8', 
TimeZoneSidKey='America/Los_Angeles',
Badge_Number__c='909', 
isActive = TRUE,
Enable_Partner_Deal_Registration__c = TRUE, 
Enable_Partner_Lead_Management__c = TRUE, 
Enable_As_Partner_Lead_Super_User__c = TRUE,
ContactId = newCMAPCont.id
);
insert partnerUser;
Campaign CMAP_dirAP_camp= new Campaign(Name='TestCampaign_Direct',
RecordTypeId = CampRTId, //v3.0
Campaign_Objective__c='Acquisition/Site Development',
Vertical__c ='Consulting',
StartDate=system.today(),
EndDate=system.today(),
Segment_Business_Unit__c='Channel',
Business_Unit__c = 'LE - G500',
Region__c='ABU',
Follow_Up_Role__c='Account Executive',
Solution__c = 'IS - Integrated Security',
Account_Play__c = TRUE,
Account_Play_Expiry_Date__c = System.Today()+360,
Is_this_Account_Play_Campaign__c = TRUE,
Type='Advisory Councils',
Description='Test',
status='In Progress',
Country_Code__c = 'BR - Brazil',
Partner_Event_or_Campaign__c = TRUE,
IsActive = true,
Total_Campaign_Targets_Planned__c = 1,
Total_Value_Won_Opportunities_Planned__c = 1,
Total_Value_Opportunities_Planned__c = 1,
Partner_Campaign_Contact__c = partnerUser.Id, //v2.0 - added since its required field
Partner_Campaign_Contact_Email__c = 'test@test.com', //v2.0 - added since its required field
Lead_Routing__c = 'Not Applicable'); //v3.0
insert  CMAP_dirAP_camp;

Account_Play__c apRecord = new Account_Play__c( recordTypeId = apRTId,
Status__c = 'Requires Follow-Up',
Account__c = newCMAPAcc.Id,
Campaign__c = CMAP_dirAP_camp.Id,
Primary_Contact__c = newCMAPCont .Id,
Customer_Consents_to_Engage_Dell_Partner__c= TRUE,
What_is_their_implementation_deadline__c = System.Today(),
Roadblocks__c  = 'No Road Bloack',
Desired_Outcome__c = 'OutCome',
Estimated_Budget__c = 10922,
Do_they_have_access_to_approved_funds__c = 'Yes', 
Interested_in_DFS_funding__c='No',                                     
Account_Executive__c = u                                     
);
insert apRecord;
*/
        CMAP_Helper.skipinsert = true;       
        Account_Play__c apRecord=[select id,Status__c,Account__c,Campaign__c,Primary_Contact__c,Account_Executive__c from Account_Play__c where Status__c='Requires Follow-Up' limit 1];
        Test.startTest();
        PageReference pref = new PageReference('/apex/CMAP_RouteAccountPlay?APId='+apRecord.Id);
        Test.setCurrentPage(pref);
        CMAP_APRoutingController leadapRoutingCntrlr = new CMAP_APRoutingController (new ApexPages.StandardController(new Account_Play__c()));
        leadapRoutingCntrlr.addToPermissionset();
        leadapRoutingCntrlr.apObj = apRecord ;
        leadapRoutingCntrlr.APId = apRecord.Id;
        leadapRoutingCntrlr.saveButton();
        TriggerExecutionController.setSkipAllTriggers(false);
        system.assertNotEquals(apRecord.id, null);
        // System.runAs(AdminUser){
        
        /*Batch_CMAPDelAssignment batchDelAssignment = new Batch_CMAPDelAssignment();
if(Test.isRunningTest()){

batchDelAssignment.query= 'SELECT Id, AssigneeId,PermissionSetId,SystemModstamp  '+
' FROM PermissionSetAssignment '+
' WHERE (PermissionSet.Name LIKE \'Channel_Permission_Set_for_R2C\' OR PermissionSet.Name LIKE  \'Channel_R2S_Access\' ) ';

Id batchprocessid = database.executebatch(batchDelAssignment,200);
}
*/
        datetime dtsystime = datetime.now();
        string strschTime = AccountOwnerTransitionUtils.BatchJobScheduleTime(dtsystime);
        Batch_CMAPDelAssignmentScheduler ubatch = new Batch_CMAPDelAssignmentScheduler (); 
        system.schedule('Batch_CMAPDelAssignmentScheduler' + string.valueof(dtsystime), strschTime, ubatch);
        Test.stopTest();
    }
}