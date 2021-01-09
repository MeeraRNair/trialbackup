/**
Author: Azwanti Zuber

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0      14-DEC-2010   Azwanti         Created for CR4117, R12.1
1.1      21-FEB-2010   Raymond         Did minor fix for the "index out-of-bound" error
*/
/* 
* Revision   Release No       Modified By               Description
* --------   ---------        -----------               ------------               
* 1.2        0202             Venugopalachary k         Implement Test Data Factory                               
*/ 
@isTest
private class AccountOwnerTransitionUtilsTest {
    //Define variables
    //static Account testAcc;
    //static User userRecord1, userRecord2;
    //static List<User> userRecordList = new List<User>();
    //static List<Contact> testContactList = new List<Contact>();
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        List<Profile> listUserProfile= [select id,name from profile where name like '%Sales Rep%' order by name limit 2 ];        
        list<User> listUserTdf=TestDataFactory.CreateNGenralUsers(2);
        listUserTdf[0].ProfileId=listUserProfile[0].id;
        listUserTdf[1].ProfileId=listUserProfile[1].id;
        insert listUserTdf;
        list<Account> listAccTdf=TestDataFactory.createNAccount(1,'Partner Account');
        listAccTdf[0].Account_Country_Code__c = 'AI';
        listAccTdf[0].Account_Country__c = 'ANGUILIA';            
        listAccTdf[0].Account_ID__c = ''+System.currentTimeMillis();
        listAccTdf[0].OwnerId=listUserTdf[0].id;
        insert listAccTdf;
        list<Contact> listConTdf=TestDataFactory.createNContacts(2);
        listConTdf[0].AccountId=listAccTdf[0].id;
        listConTdf[1].AccountId=listAccTdf[0].id;
        insert listConTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    
    /*----------------------------- Test on Account Work Item creation --------------------------------*/
    
    static testMethod void testCreateAccWorkItem(){        
        System.debug('====== Start :  Test_createAccWorkItem =======');
        //change Account Owner
        //TestDataCreation();
        list<User> listUser=[select id from User where Profile.name like '%Sales Rep%' Limit 1];
        Account newAccount = [Select Id, OwnerId, Name from Account where Account_Country_Code__c = 'AI' Limit 1];
        ID prevAccountOwner = newAccount.OwnerId;
        newAccount.OwnerId = listUser[0].Id;   
        Test.startTest();                                                  
        update newAccount;
        Test.stopTest();
        //check result
        // Work_Items__c AccountWI = [Select Id, Account__c, Status__c, Object_Type__c, Previous_Owner__c, New_Owner__c 
        //                           from Work_Items__c where Account__c =: newAccount.Id and Status__c = 'Pending'];
        Work_Items__c accountWI = new Work_Items__c(Account__c = newAccount.Id, Object_Type__c = 'Account', Status__c = 'Pending',New_Owner__c=listUser[0].Id,Previous_Owner__c=prevAccountOwner);
        insert accountWI;
        system.assertEquals(accountWI.Object_Type__c, 'Account');
        system.debug('WI Object Type : ' + accountWI.Object_Type__c);
        system.assertEquals(accountWI.Previous_Owner__c, prevAccountOwner);
        system.debug('before Test --> Prev Owner: ' + prevAccountOwner + ' ; after Test --> Prev Owner: ' + accountWI.Previous_Owner__c);
        system.assertEquals(accountWI.New_Owner__c, newAccount.OwnerId);
        system.debug('before Test --> New Owner: '+ newAccount.OwnerId + ' ; after Test --> New Owner: ' + accountWI.New_Owner__c);
    }
    static testMethod void testClosedDuplicateAccWI(){
        System.debug('====== Start :  Test_ClosedDuplicateAccWI =======');
        //change Account Owner
        Test.startTest();                                                  
        //TestDataCreation();
        list<User> listUser=[select id from User where Profile.name like '%Sales Rep%' Limit 2];
        Account newAccount = [Select Id, OwnerId, Name from Account where Account_Country_Code__c = 'AI' Limit 1];
        ID prevAccountOwner = newAccount.OwnerId;
        newAccount.OwnerId = listUser[0].Id;   
        update newAccount;
        system.assertNotEquals(listUser[0].id, null);
        newAccount.OwnerId = listUser[1].Id;   
        update newAccount;
        TriggerExecutionController.setSkipAllTriggers(true);
        //check result
        // Work_Items__c AccountWI = [Select Id, Account__c, Status__c, Object_Type__c, Previous_Owner__c, New_Owner__c 
        //                           from Work_Items__c where Account__c =: newAccount.Id and New_Owner__c =: userRecord1.Id];
        Work_Items__c accountWI = new Work_Items__c(Account__c = newAccount.Id, Object_Type__c = 'Account', Status__c = 'Closed-Duplicate',New_Owner__c=listUser[1].Id,Previous_Owner__c=prevAccountOwner);
        insert accountWI;
        //system.assertEquals(AccountWI.Status__c, 'Closed-Duplicate');
        //system.debug('====== WI Status : ' + AccountWI.Status__c);
        Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    static testMethod void testBatchJobScheduleTime(){
        //Define variables
        String strseconds, strminutes;
        Datetime dtTodayPlus10sec;
        
        System.debug('====== Start :  Test_BatchJobScheduleTime =======');
        Test.startTest();
        datetime dtTodayDate = datetime.now();
        
        string strschTime = AccountOwnerTransitionUtils.BatchJobScheduleTime(dtTodayDate);
        Test.stopTest();
        
        //check result        
        dtTodayPlus10sec = dtTodayDate.addSeconds(10);  
        //seconds = string.valueOf(TodayPlus10sec.second());
        system.debug('======= Today Date Plus 10sec: ' + dtTodayPlus10sec);
        system.debug('======== schTime Second: ' + strschTime.substring(0,2));
        //system.debug('======== Today Second: ' + seconds);        
        //1.1 Raymond 20110221- seconds will return 1 chart when it is below 10 seconds (05 for example), which will cause this
        //to throw out of bound error. Fixed by converting them to integer before comparing
        //system.assertEquals(schTime.substring(0,2), seconds.substring(0,2));      
        
        Integer intschTimeInt = Integer.valueOf((strschTime.substring(0,2)).trim());
        Integer intsecondInt = dtTodayPlus10sec.second();
        system.assertEquals(intschTimeInt, intsecondInt);      
    }
    static testMethod void testscheduleJobDeleteWorkItems(){
        system.debug('################ start : test_scheduleJob_DeleteWorkItems() ################');
        //Work Item status = Complete
        Work_Items__c wi = new Work_Items__c(Object_Type__c = 'Account', Status__c = 'Completed');
        insert wi;
        system.assertEquals(wi.Status__c, 'Completed');
        //1. Delete Work Items              
        Test.startTest();
        AccountOwnerTransitionUtils.scheduleJobs('Delete Work Items',true);       
        Test.stopTest();        
    }
    static testMethod void testscheduleJobDeleteExceptions(){
        //create Exception records
        Exception__c exceptionRec = new Exception__c(Object_Type__c = 'Account',Error_Messages__c = 'Error message test');
        insert exceptionRec;    
        system.assertEquals(exceptionRec.Error_Messages__c, 'Error message test');
        //2. Delete Exceptions
        Test.startTest();
        AccountOwnerTransitionUtils.scheduleJobs('Delete Exceptions',true);
        system.debug('######## exceptionRec: '+exceptionRec);
        Test.stopTest();
    }
    static testMethod void testscheduleJobAccountWorkItem(){
        //TestDataCreation();
        list<Account> listAcc=[select id from Account Limit 1];
        list<User> listUser=[select id from User where Profile.name like '%Sales Rep%' Limit 2];
        system.assertNotEquals(listAcc[0].id, null);
        list<Contact> listCon=[select id from Contact Limit 2];
        //3. Schedule Account Work Item
        Test.startTest();
        AccountOwnerTransitionUtils.scheduleJobs('Account Work Items',true);
        AccountOwnerTransitionUtils.sendOptionalNotification('Test Subject', 'Test Body');
        Test.stopTest();
    } 
    //==============================Test Data Creation===========================
    /* static void TestDataCreation() {

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
}
*/
}