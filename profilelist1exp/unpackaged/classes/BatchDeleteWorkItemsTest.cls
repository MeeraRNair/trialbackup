/*
Author: Azwanti Zuber
History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0      25-NOV-2010   Azwanti         Created for CR4117, R12.1
/* 
* Revision   Release No       Modified By               Description
* --------   ---------        -----------               ------------               
*            0202             Venugopalachary k         Implement Test Data Factory                               
*/ 
@isTest
private class BatchDeleteWorkItemsTest {
    //Define variables
    //static Account testAcc;
    //static User userRecord1, userRecord2;
    //static List<User> userRecordList = new List<User>();
    //static List<Contact> testContactList = new List<Contact>();
    @testSetup static void setUpConversionTestData() {
        //Account Record INSERTION    
        /*   Account newAccount = new Account(Name = 'Dell Internal_01');
insert newAccount;

//User Record INSERTION
Profile userProfile= [select id,name from profile where name like '%GBL Sales Rep%' order by name limit 1 ];
User user = new User( Username='TestLeadConversion' +System.currentTimeMillis() + '@test.com',
Alias = 'TstLd'+056,
Email='test'+ 012 +'@dell.com',
FirstName='Tfirst'+0,
LastName='TestLeadConversion'+100,
ProfileId = userProfile.Id,
LanguageLocaleKey='en_US',
LocaleSidKey='en_US',
EmailEncodingKey='UTF-8',
TimeZoneSidKey='America/Los_Angeles',
Badge_Number__c='TstLeadCon123456789' );
insert user;

//Test Data for CONTACT
ContactTestData.iNumberOfContacts = 1;
ContactTestData.createContact();
list<Contact> lstContacts = ContactTestData.lstContacts;
lstContacts[0].LastName = 'TestLeadConversion-Contact 1';
lstContacts[0].Accountid = newAccount.id;
update lstContacts;

//TEST data for Opportunity
Id oppRecordTypeId= IdLookupUtils.getRecordTypeId('Standard Opportunity','Opportunity',true);
Opportunity opp=new Opportunity (name='TestLeadConversion-Opp 1', Total_Expected_Dell_Revenue__c=5000,CloseDate=System.Today(),Description='Test Desc',StageName='Plan - 1%',RecordtypeId = oppRecordTypeId);
insert opp;

//TestData for SALES CHANNEL
Sales_Channel_Group__c testSalesChannelRecord = new Sales_Channel_Group__c
(Name='TestLeadConversion-SC Record 1',
Group_ID__c=''+System.currentTimeMillis()
);
insert TestSalesChannelRecord;

//TestData for COUNTRY
country__c country = new Country__c (Name = 'TestLeadConversion-Contry 1',code__c='TST',region__c = 'EMEA',Is_Active_in_Affinity__c = true);
insert country;

LeadTestData.iNumberOfLeads = 1;
LeadTestData.createDirectLead2();
list<Lead> lstLeads = LeadTestData.lstLeads;
lstLeads[0].LastName='TestLeadConversion';
lstLeads[0].ownerid = user.id;

update lstLeads;
*/
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
        listAccTdf[0].Name='Dell Internal_01';
        insert listAccTdf;
        Work_Items__c wor = new Work_Items__c(Account__c = listAccTdf[0].Id, Object_Type__c = 'Account', Status__c = 'Completed');
        insert wor;
        list<Contact> listConTdf=TestDataFactory.createNContacts(2);
        listConTdf[0].Accountid=listAccTdf[0].id;
        listConTdf[1].Accountid=listAccTdf[0].id;
        insert listConTdf;
        List<Profile> listUserProfile= [select id,name from profile where name like '%Sales Rep%' order by name limit 2 ];        
        list<User> listUserTdf=TestDataFactory.createNGenralUsers(2);
        listUserTdf[0].ProfileID=listUserProfile[0].id;
        listUserTdf[1].ProfileID=listUserProfile[1].id;
        insert listUserTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    static testMethod void testDeleteLast2WeekWorkItem() {
        system.debug('======= Start : Test_DeleteLast2WeekWorkItem =======');
        //Expected Result : able to delete Work Item created last 2 week
        // TestDataCreation();
        // Work_Items__c WI = new Work_Items__c(Account__c = testAcc.Id, Object_Type__c = 'Account', Status__c = 'Completed');
        //insert WI;
        //system.debug('====== WI: ' + WI);
        Work_Items__c wi=[select id,Account__c,Object_Type__c,Status__c from Work_Items__c where Status__c='Completed' Limit 1];
        BatchDeleteWorkItems bdWorkItem = new BatchDeleteWorkItems();
        bdWorkItem.queryOldWorkItem = 'Select Id, Status__c, CreatedDate from Work_Items__c where Id = \''+wi.Id+'\' AND (Status__c = \'Auto-Complete\' OR Status__c = \'Completed\' OR Status__c = \'Closed-Duplicate\')';
        
        Test.startTest();
        Database.executeBatch(bdWorkItem,500); 
        Test.stopTest();
        
        //check result
        Integer intnewWI = [SELECT count() FROM Work_Items__c where Id =: wi.Id];
        system.assertEquals(0, intnewWI);
        system.debug('====== newWI : ' + intnewWI);
    }
    
    /*  //==================================================== TestDataCreation ===============================================================
static void TestDataCreation() {
//create Account
testAcc = new Account(
name='Test1 CR4117',
Account_Country_Code__c = 'AI',
Account_Country__c = 'ANGUILIA',            
Account_ID__c = ''+System.currentTimeMillis()
);
insert testAcc;        

//Contact Creation
testContactList.clear();
for (integer i = 0; i < 2; i++) {

Contact testContact = new Contact(Status__c='Active', AccountId=testAcc.Id, EMEA_Decision_Making_Role__c='Influencer', 
Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact'+i);
testContactList.add(testContact);
}                                            
insert testContactList;

//Create User
List<Profile> userProfile= [select id,name from profile where name like '%Sales Rep%' order by name limit 2 ];        
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
}*/
}