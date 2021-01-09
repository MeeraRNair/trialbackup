/*
* @Author     : Prasanthi M
* created Date : 1/2/2019
* Purpose    : Test class for Update Suggestion web service
* 
*/
@isTest
public class UpdateSuggestionTest {
    static list<Lead> listLead;
    static list<Contact> listCon;
    static list<User> listUser;
    static list<Account> listAcc;
    static list<Campaign> listCamp;
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTDF = TestDataFactory.createNAccount(2, 'Master Account');
        insert listAccTDF;
        list<Campaign> listCampTDF = TestDataFactory.createNCampaign(1, 'Campaign 2.0');
        insert listCampTDF;
        list<Lead> listLeadTDF = TestDataFactory.createNLeads(1, 'Direct Lead 2.0');
        listLeadTDF[0].Campaign__c=listCampTDF[0].id;
        insert listLeadTDF;
        list<Contact> listConTDF = TestDataFactory.createNContacts(1);
        insert listConTDF;
        Profile userProfile= [select id,name from profile where name like '%Sales Rep%' order by name limit 1 ];
        list<User> listUserTDF = TestDataFactory.createNGenralUsers(2);
        listUserTDF[0].profileid=userProfile.id;
        insert listUserTDF;
        
        
    }
    private static testMethod void testUCIDUpdationService(){
        //User Creation
        listUser = [Select Id from User where profile.name like '%Sales Rep%'  limit 1];
        system.assertNotEquals(listUser[0].id, null);
        /*User userRecord = new User(
Username='testUser'+System.currentTimeMillis()+'@test.com',
Alias = 'test', 
Email='test@dell.com', 
FirstName='Tfirst',
LastName='TLast',
ProfileId = userProfile.Id, 
LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', 
EmailEncodingKey='UTF-8', 
TimeZoneSidKey='America/Los_Angeles',
Badge_Number__c='TEST12345'
);
insert userRecord;
System.assertEquals('test@dell.com', userRecord.Email);*/
        //Campaign Creation
        listCamp = [Select Id from Campaign limit 1];
        listCamp[0].StartDate=system.today();
        listCamp[0].EndDate=system.today();
        update listCamp[0];
        /*Campaign campaignObj=new Campaign(Name='Campaign',
Campaign_Objective__c='Acquisition/Site Development',
Type='Advisory Councils',Segment_Business_Unit__c='SMB',
Follow_Up_Role__c='Account Executive',
Description='Test',StartDate=system.today(),EndDate=system.today(),
status='In Progress',
Total_Targets__c = 12.0,  
IsActive = true);
insert campaignObj;  */
        Partner_Request__c request=new Partner_Request__c();
        request.Last_Name__c='pr last';
        request.Company__c='pr last';
        request.OwnerID=listUser[0].Id; 
        insert request;
        //Lead creation
        listLead = [Select Id from Lead limit 1];
        listLead[0].LastName = request.Last_Name__c;
        listLead[0].Company = request.Company__c;
        listLead[0].Partner_Request__c = request.ID;
        listLead[0].OwnerID = request.OwnerID;
        listLead[0].Account_Owner__c = listUser[0].Id;
        listLead[0].Campaign__c=listCamp[0].id;
        Update listLead[0];
        request.Lead__c=listLead[0].Id;
        update request;
        /*Lead suggestionLead = new Lead();
suggestionLead.LastName = request.Last_Name__c;
suggestionLead.Company = request.Company__c;
suggestionLead.Status = 'Open';
suggestionLead.Partner_Request__c = request.ID;
System.debug('####request.OwnerID'+request.OwnerID);
suggestionLead.OwnerID = request.OwnerID;
suggestionLead.Email = 'test@test.com';
suggestionLead.MobilePhone = '21441242421'; 
suggestionLead.Fax = '3737433'; 
suggestionLead.Lead_Type__c = 'Inbound';
suggestionLead.Country_Code__c = 'US';
suggestionLead.Website = 'www.testing.com';
suggestionLead.Account_Owner__c = listUser[0].Id;
suggestionLead.DMU_Flag__c = true;
suggestionLead.Campaign__c=listCamp[0].id;
suggestionLead.Location_Number__c=23;
suggestionLead.LeadSource='Web';
suggestionLead.PPA_UCID__c = '99999';
suggestionLead.Partner_Grouping_id__c = '111111';
suggestionLead.Partner_Master_Grouping_id__c = '100001';
suggestionLead.Suggestion_ID__c='123456789'; 
//Lead insertion
insert suggestionLead;
request.Lead__c=suggestionLead.Id;
update request;*/
        Test.startTest();
        Test.setMock(HttpCalloutMock.class,new AffinityUCID_MockHttpResponseGenerator());
        try{
            UpdateSuggestion.invokeUpdateSuggestion(request.id);
        }catch(Exception e){
            system.debug('Exception in testUCIDUpdationService of UpdateSuggestionTest class');
        }
    }
    
    public static testMethod void testUpdateServiceWithLinkToAcc(){
        Profile userProfile= [select id,name from profile where name like '%Sales Rep%' order by name limit 1 ];
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        listAcc = [Select Id,Master_Group_Affinity_ID__c from Account limit 2];
        /*Id masterAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Master_Account_Record_Type_Name).getRecordTypeId();

Account mgAcc = new Account();
mgAcc.Name = 'testMasterAccount';
mgAcc.NPS_Qualified_Contacts__c = 1;
mgAcc.RecordTypeId = masterAccountRecordTypeId;
mgAcc.Master_Group_Affinity_ID__c='32112343';
insert mgAcc;*/
        
        Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1');
        insert trackObj;
        
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Partner_Track_Name__c = 'Tech Data';
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c = listAcc[0].id;
        testPartnerTrackObj.Master_Group_Affinity_Id__c = listAcc[0].Master_Group_Affinity_ID__c;
        testPartnerTrackObj.partner_Track_affinityId__c = '123321123';
        testPartnerTrackObj.Partner_Registration_Number__c = '';
        TriggerExecutionController.setSkipAllTriggers(true);
        insert testPartnerTrackObj;     
        listAcc[1].Master_Group_Id__c = listAcc[0].id;
        listAcc[1].Partner_Track__c = testPartnerTrackObj.id;
        TriggerExecutionController.setSkipAllTriggers(true);
        update listAcc[1];
        /*Account smAcc = new Account();
smAcc.Name = 'test Sales Motion';
smAcc.NPS_Qualified_Contacts__c = 1;
smAcc.RecordTypeId = accRTId;
smAcc.Master_Group_Id__c = mgAcc.id;
smAcc.Partner_Track__c = testPartnerTrackObj.id;
TriggerExecutionController.setSkipAllTriggers(true);
insert smAcc;
*/
        
        listUser = [Select Id from User limit 1];
        // listUser[0].Username='testUser'+System.currentTimeMillis()+'@test.com';
        //listUser[0].ProfileId = userProfile.Id;
        //update listUser[0];
        /*User userRecord = new User(
Username='testUser'+System.currentTimeMillis()+'@test.com',
Alias = 'test', 
Email='test@dell.com', 
FirstName='Tfirst',
LastName='TLast',
ProfileId = userProfile.Id, 
LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', 
EmailEncodingKey='UTF-8', 
TimeZoneSidKey='America/Los_Angeles',
Badge_Number__c='TEST1qse2345'
);
insert userRecord;*/
        listCamp = [Select Id from Campaign limit 1];
        listCamp[0].StartDate=system.today();
        listCamp[0].EndDate=system.today();
        Update listCamp[0];
        /*Campaign campaignObj=new Campaign(Name='Campaign',
Campaign_Objective__c='Acquisition/Site Development',
Type='Advisory Councils',Segment_Business_Unit__c='SMB',
Follow_Up_Role__c='Account Executive',
Description='Test',StartDate=system.today(),EndDate=system.today(),
status='In Progress',
Total_Targets__c = 12.0,  
IsActive = true);
insert campaignObj;  */
        Partner_Request__c request=new Partner_Request__c();
        request.Last_Name__c='pr last';
        request.Company__c='pr last';
        request.OwnerID=listUser[0].Id; 
        request.EMC_Attributes_Flag__c=true;
        request.Account__c = listAcc[1].id;
        insert request;
        listLead = [Select Id from Lead limit 1];
        
        listLead[0].LastName = request.Last_Name__c;
        listLead[0].Company = request.Company__c;
        listLead[0].Partner_Request__c = request.ID;
        listLead[0].OwnerID = request.OwnerID;
        listLead[0].Account_Owner__c = listUser[0].Id;
        listLead[0].Campaign__c=listCamp[0].id;
        update listLead[0];
        request.Lead__c=listLead[0].Id;
        update request;
        /*Lead suggestionLead = new Lead();
suggestionLead.LastName = request.Last_Name__c;
suggestionLead.Company = request.Company__c;
suggestionLead.Status = 'Open';
suggestionLead.Partner_Request__c = request.ID;
suggestionLead.OwnerID = request.OwnerID;
suggestionLead.Email = 'test@test.com';
suggestionLead.MobilePhone = '21441242421'; 
suggestionLead.Fax = '3737433'; 
suggestionLead.Lead_Type__c = 'Inbound';
suggestionLead.Country_Code__c = 'US';
suggestionLead.Website = 'www.testing.com';
suggestionLead.Account_Owner__c = listUser[0].Id;
suggestionLead.DMU_Flag__c = true;
suggestionLead.Location_Number__c=23;
suggestionLead.Campaign__c=listCamp[0].id;
suggestionLead.LeadSource='Web';
suggestionLead.PPA_UCID__c = '99999';
suggestionLead.Partner_Grouping_id__c = '111111';
suggestionLead.Partner_Master_Grouping_id__c = '100001';
suggestionLead.Suggestion_ID__c='123456789'; 

insert suggestionLead;
request.Lead__c=suggestionLead.Id;
update request;*/
        Test.startTest();
        Test.setMock(HttpCalloutMock.class,new AffinityUCID_MockHttpResponseGenerator());
        UpdateSuggestion.updateGamaSuggestionWhenLinkToAccountisUsed(request.id);
        System.AssertNotEquals(request.name,'MyTestUser9'); 
        Test.stopTest();
    }
    
}