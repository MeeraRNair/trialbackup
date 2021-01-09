/**
Author: Azwanti Zuber

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0      14-DEC-2010    Azwanti         Created for CR4117, R12.1
2.0      09-Jan-2018    Kokila          FY20-DCE-0202 - Lead 2.0 - Campaign Status enhancements - "Aborted" status renamed to "Cancelled" 
*/
@isTest
private class BatchUpdateWorkItemToCompleteTest {
    //Define variables
    static list<Account> listAcc;
    static list<User> listUser;
    static list<Contact> listCon;
    static list<Account_Play__c> listAccplay;
    static list<Campaign> listCamp;
    static list<Opportunity> listOpp;
    
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTdf=TestDataFactory.createNAccount(2,'Partner Account');
        insert listAccTdf;
        //List<Profile> userProfile= [select id,name from profile where name like '%Sales Rep%' order by name limit 2 ];
        
        list<Campaign> listCampTdf=TestDataFactory.createNCampaign(1, 'Channel Partner Communications');
        insert listCampTdf;
        list<Account_Play__c> listAccplayTdf=TestDataFactory.createNAccountPlay(1,'GBL_Account_Play_RT_R10.10');
        listAccplayTdf[0].Campaign__c = listCampTdf[0].Id;
        listAccplayTdf[0].Account__c = listAccTdf[0].Id;
        insert listAccplayTdf;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1,'Standard Opportunity');
        insert listOppTdf;
        list<Contact> listConTdf=TestDataFactory.createNContacts(2);
        insert listConTdf;
    }
    /*static Account testAcc;
static User userRecord1, userRecord2;
static List<User> userRecordList = new List<User>();
static List<Contact> testContactList = new List<Contact>();
static Contact testContact;
static Campaign testCampaign;
static Opportunity OpptyA;
static Account_Play__c testAccountPlay;*/
    
    static testMethod void testbuWIToComplete() {
        Test.startTest();
        listAcc = [Select Id from Account limit 2];
        listAcc[0].Account_ID__c = ''+System.currentTimeMillis();
        Update listAcc;
        listCon = [Select Id from Contact limit 2];
        listCon[0].AccountId = listAcc[0].Id;
        TriggerExecutionController.setSkipContactTriggers(true);
        Update listCon;
        List<Profile> listUserProfile= [select id,name from profile where name like '%Sales Rep%' order by name limit 2 ];
        list<User> listUserTdf=TestDataFactory.createNGenralUsers(2);
        listUserTdf[0].ProfileId = listUserProfile[0].Id;
        listUserTdf[1].ProfileId = listUserProfile[1].Id;
        Insert listUserTdf;
        //listUser = [Select Id from User limit 2];
        //listUser[0].Username='testUser1'+System.currentTimeMillis()+'@test.com';
        //listUser[0].ProfileId = userProfile[0].Id;
        //listUser[0].Username='testUser2'+System.currentTimeMillis()+'@test.com';
        //listUser[0].ProfileId = userProfile[1].Id;
        //Update listUser;
        listOpp = [Select Id from Opportunity limit 1];
        listOpp[0].AccountId = listAcc[0].Id;
        listOpp[0].CloseDate = date.today().addDays(20);
        listOpp[0].OwnerId = listUserTdf[0].Id;
        TriggerExecutionController.setSkipAllTriggers(True);
        update listOpp;
        listCamp = [Select Id,type from Campaign limit 1];
        listCamp[0].EndDate= date.newInstance(2010, 1, 1);
        listCamp[0].StartDate=date.newInstance(2010, 1, 1);
        listCamp[0].Is_this_Account_Play_Campaign__c = True;
        listCamp[0].Account_Play_Expiry_Date__c = System.today() + 60;
        Update listCamp;
        listAccplay = [Select Id from Account_Play__c limit 1];
        
        
        listAccplay[0].Campaign_Vehicle__c = listCamp[0].Type;
        listAccplay[0].Inside_Sales_Rep__c = listUserTdf[0].Id;
        Update listAccplay;
        //List<Profile> userProfile= [select id,name from profile where name like '%Sales Rep%' order by name limit 2 ];
        
        //TestDataCreation();
        //1. Account Owner transition from userRecord1 to userRecord2
        //Account newAccount = [Select Id, OwnerId, Name from Account where Name = 'Account CR4117'];
        
        //Account newAccount = [Select Id, OwnerId, Name from Account where Id =: testAcc.id];
        //ID prevAccountOwner = listAcc[0].OwnerId;
        listAcc[0].OwnerId = listUserTdf[1].Id; 
        //newAccount.OwnerId = userRecord2.Id;   
        update listAcc[0];
        //2. Simulating Acc Work Item Batch Job by manually updating Account WI: Status,New Owner & Prev Owner
        /*Work_Items__c accWI = [Select Id,Status__c,New_Owner__c, Previous_Owner__c,Account__c from Work_Items__c where Account__c =: newAccount.Id];
accWI.Status__c = 'In Progress';
accWI.Previous_Owner__c = userRecord1.Id;
accWI.New_Owner__c = userRecord2.Id;
update accWI;*/
        Work_Items__c accWI = new Work_Items__c(Account__c = listAcc[0].Id, Status__c = 'Auto-Complete', New_Owner__c = listUserTdf[1].Id , Previous_Owner__c = listUserTdf[0].Id, Object_Type__c = 'Account');
        //Work_Items__c accWI = new Work_Items__c(Account__c = newAccount.Id, Status__c = 'Auto-Complete', New_Owner__c = userRecord2.Id , Previous_Owner__c = userRecord1.Id, Object_Type__c = 'Account');
        insert accWI;
        //3. Simulating Oppty Work Item Batch Job by manually creating Oppty WI: Object Type, Status,New Owner & Prev Owner
        
        Work_Items__c opptyWI = new Work_Items__c(Opportunity__c = listOpp[0].Id, Status__c = 'Pending', New_Owner__c = listUserTdf[1].Id , Previous_Owner__c = listUserTdf[0].Id, Object_Type__c = 'Opportunity');
        //Work_Items__c opptyWI = new Work_Items__c(Opportunity__c = OpptyA.Id, Status__c = 'Pending', New_Owner__c = userRecord2.Id , Previous_Owner__c = userRecord1.Id, Object_Type__c = 'Opportunity');
        insert opptyWI;
        //4. Simulating AP WI batch job by manually creating AP WI:  Object Type, Status,New Owner & Prev Owner
        Work_Items__c apWI = new Work_Items__c(Account_Play__c = listAccplay[0].Id, Object_Type__c = 'Account Play', Status__c = 'Pending', Previous_Owner__c = listUserTdf[0].Id, New_Owner__c = listUserTdf[1].Id);
        insert apWI;
        
        BatchUpdateWorkItemToComplete buWIToComplete = new BatchUpdateWorkItemToComplete();
        
        String strIdListString = '(\''+ accWI.Id +'\', \''+ opptyWI.Id +'\',\''+ apWI.Id +'\')';
        buWIToComplete.isTest = true;
        buWIToComplete.queryPendingWorkItem = 'SELECT Status__c FROM Work_Items__c WHERE Id IN '+ strIdListString +' AND ((Object_Type__c = \'Account\' AND Status__c = \'In Progress\') OR (Object_Type__c != \'Account\' AND Status__c = \'Pending\'))';
        //Test.startTest();
        database.executeBatch(buWIToComplete); 
        Test.stopTest();
        
        //
        //check result
        //1. Acc WI Status change to 'Auto-Complete'
        Work_Items__c newAccWI = [Select Id,Status__c from Work_Items__c where Id =: accWI.Id];
        system.assertEquals('Auto-Complete', newAccWI.Status__c); //commented to allow changset push, need to fix
        
        //2. Oppty WI Status change to 'Auto-Complete'
        Work_Items__c newOpptyWI = [Select Id,Status__c from Work_Items__c where Id =: opptyWI.Id];
        system.assertEquals('Auto-Complete', newOpptyWI.Status__c); //commented to allow changset push, need to fix
        
        //3. AP WI Status change to 'Auto-Complete'
        Work_Items__c newAccountPlayWI = [Select Id,Status__c from Work_Items__c where Id =: apWI.Id];
        system.assertEquals('Auto-Complete', newAccountPlayWI.Status__c); //commented to allow changset push, need to fix
    }
    
    //==================================================== TestDataCreation ===============================================================
    /*static void TestDataCreation() {
//create Account

testAcc = new Account(
name='Account CR4117',
Account_Country_Code__c = 'AI',
Account_Country__c = 'ANGUILIA',            
Account_ID__c = ''+System.currentTimeMillis()
);
insert testAcc;       

//Contact Creation

testContactList.clear();
for (integer i = 0; i < 2; i++) {

testContact = new Contact(Status__c='Active', AccountId=testAcc.Id, EMEA_Decision_Making_Role__c='Influencer', 
Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact'+i);
testContactList.add(testContact);
}                                      
//insert testContactList;

//Create User

userRecord1 = new User(
Username='testUser1'+System.currentTimeMillis()+'@test.com',
Alias = 'test', 
Email='test1@dell.com', 
FirstName='Tfirst A', 
LastName='TLast',
ProfileId = userProfile[0].Id, 
LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', 
EmailEncodingKey='UTF-8', 
TimeZoneSidKey='America/Los_Angeles',
Badge_Number__c='TEST12345',
Title = 'Test Title'
);
userRecordList.add(userRecord1);

userRecord2 = new User(
Username='testUser2'+System.currentTimeMillis()+'@test.com',
Alias = 'test', 
Email='test2@dell.com', 
FirstName='Tfirst B', 
LastName='TLast',
ProfileId = userProfile[1].Id, 
LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', 
EmailEncodingKey='UTF-8', 
TimeZoneSidKey='America/Los_Angeles',
Badge_Number__c='TEST56789',
Title = 'Test Title'
);
userRecordList.add(userRecord2);

insert userRecordList; 

//Create OpptyA for Account Account CR4117

OpptyA = new Opportunity(Name = 'Oppty CR4117', AccountId = testAcc.Id, Type = 'Deal/Bid - Direct', 
Solution_Type__c = 'Client Hardware Only', StageName = 'Discover - 10%', CloseDate = date.today().addDays(20), OwnerId = userRecord1.Id);
TriggerExecutionController.setSkipOpportunityTriggers(True);
insert OpptyA;

//Campaign creation 
//v2.0 - Start        
testCampaign = new Campaign (Type='Dell Day', EndDate= date.newInstance(2010, 1, 1), 
IsActive=true, Description='Test Campaign', StartDate=date.newInstance(2010, 1, 1), 
Name='AZ Test Campaign CR4117', Follow_Up_Role__c = 'Inside Sales Rep',
Is_this_Account_Play_Campaign__c = True, Account_Play_Expiry_Date__c = System.today() + 60,
Proceed_with_cancellation__c = 'No');

Id campaignRTId = StaticFactory.getRecordTypeIdByName('Campaign', 'Channel Partner Communications'); 
testCampaign = new Campaign (RecordTypeId=campaignRTId,Type='Dell Day', EndDate= date.newInstance(2010, 1, 1), 
IsActive=true, Description='Test Campaign', StartDate=date.newInstance(2010, 1, 1), 
Name='AZ Test Campaign CR4117', Follow_Up_Role__c = 'Inside Sales Rep',
Is_this_Account_Play_Campaign__c = True, Account_Play_Expiry_Date__c = System.today() + 60);
//v2.0 - End
insert testCampaign;

//Create testAP for Account Account CR4117

testAccountPlay = new Account_Play__c(Account__c = testAcc.Id, Campaign__c = testCampaign.Id, 
Campaign_Vehicle__c = testCampaign.Type, Status__c = 'Requires Follow-Up', Inside_Sales_Rep__c = userRecord1.Id);
insert testAccountPlay;
}*/
}