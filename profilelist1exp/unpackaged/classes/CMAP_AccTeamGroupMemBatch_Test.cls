/************************************************************
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------------
1.0     08-Nov-2013     Jiji            Test Class for CMAP_AccTeamGroupMemBatch

*************************************************************/
@isTest
private class CMAP_AccTeamGroupMemBatch_Test {
    static list<Account> listAcc;
    static list<user> listuser;
    @testSetup static void setup(){
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'Partner Account');
        listAccTDF[0].Type = 'Partner';
        TriggerExecutionController.setSkipAccountTriggers(True);
        insert listAccTDF;
        list<user> listuserTDF = TestDataFactory.CreateNGenralUsers(2);
        insert listuserTDF;
    }
    static testMethod void myUnitTest() {
        Test.startTest();
        /*       List<User> testUserList = new List<User>();
List<Account_Team__c> listtestatm = new List<Account_Team__c>();
Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
Account accountObj = new Account(name='Test-001',
RecordtypeId= accRTId, 
Type = 'Partner');
insert accountObj;*/
        listAcc = [select id from Account limit 1];
        listuser = [select id,Badge_Number__c from user limit 2];
        
        /*Profile userProfile= [select id,name from profile where name like '%Sales Rep%' order by name limit 1 ];
for(integer i=0; i<2; i++){
User testuser = new User( Username='test'+i+ System.currentTimeMillis() + '@test.com',
Alias = 'cmap11'+i, 
Email='test.'+i+'cmap11@dell.com', 
FirstName='Tfirst11'+i, 
LastName='TLast11'+i,
ProfileId = userProfile.Id, 
LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', 
EmailEncodingKey='UTF-8', 
TimeZoneSidKey='America/Los_Angeles',
Badge_Number__c='camp11'+i);
testUserList.add(testUser);   
}
insert testUserList ;
*/
        /*       List<User> UserRec= [select id,name, Badge_Number__c from User 
where Profile.Name like '%Sales Rep%' 
AND isActive = TRUE
order by name limit 2 ]; */
        List<Account_Team__c> listtestatm = new List<Account_Team__c>();
        Group groupRec = new Group(Name='CMAP:AT:'+listAcc[0].Id,DoesIncludeBosses = false);
        insert groupRec;
        List<AccountTeamMember> listatmember = new List<AccountTeamMember> ();
        for(integer inti=0; inti<2; inti++){
            AccountTeamMember atm01=new AccountTeamMember(
                userId=listuser[inti].Id,
                TeamMemberRole='OEM Account Executive',
                accountId = listAcc[0].id);
            listatmember.add(atm01);
            system.assertEquals(listAcc[0].id, atm01.accountId);
        }
        // insert listatmember;
        try{        
            insert listatmember; 
        }
        catch (exception e){
        }
        
        for(integer inti=0; inti<2; inti++){
            Account_Team__c acntTeam = new Account_Team__c(
                Account__c = listAcc[0].Id,
                Is_Processed__c = TRUE,
                User__c = listuser[inti].id,
                Badge_Number__c = listuser[inti].Badge_Number__c ,
                Account_User_ID__c = listAcc[0].Id+':'+listuser[inti].Id+':prg',
                Account_Id__c = listAcc[0].Id,
                Team_Member_Role__c = 'OEM Account Executive',
                Status__c = 'Active'                                        
                
            );
            listtestatm.add(acntTeam);
        }
        try{
            insert listtestatm;
            listtestatm[1].Status__c = 'InActive';
            update listtestatm[1];
        }
        catch (exception e){
        }
        CMAP_Account_Team_Roles__c customsettingrecord = new CMAP_Account_Team_Roles__c(Name = 'OEM Account Executive', 
                                                                                        OEM_Role__c = TRUE,
                                                                                        partner_Role__c = TRUE);
        insert customsettingrecord;
        /*
CMAP_AccTeamGroupMemBatch batchObjectTest = new CMAP_AccTeamGroupMemBatch();
if(Test.isRunningTest()){
batchObjectTest.query = 'SELECT Account__c, Account_ID__c, '+
' Sales_Channel_Name__c, '+
' Account_Type__c, Badge_Number__c, '+
' Team_Member_Role__c,Status__c, '+
' Account_User_ID__c, Is_Processed__c '+
' FROM Account_Team__c '+ 
' WHERE Is_Processed__c = TRUE Limit 100';  
}
else{
batchObjectTest.query = 'SELECT Account__c, Account_ID__c, '+
' Sales_Channel_Name__c, '+
' Account_Type__c, Badge_Number__c, '+
' Team_Member_Role__c,Status__c, '+
' Account_User_ID__c, Is_Processed__c '+
' FROM Account_Team__c '+ 
' WHERE Is_Processed__c = TRUE';
}

Id batchprocessesidTest = database.executebatch(batchObjectTest,200);*/
        datetime dtsystime = datetime.now();
        string strschTime = AccountOwnerTransitionUtils.BatchJobScheduleTime(dtsystime);
        CMAP_AccTeamGroupMemScheduler u = new CMAP_AccTeamGroupMemScheduler (); 
        u.isTest=True;
        system.schedule('CMAP_AccTeamGroupMemScheduler' + string.valueof(dtsystime), strschTime, u);
        Test.stopTest();
        /*List<Account_Team__c> att = [select Id, Is_Processed__c, Account_User_ID__c  From Account_team__c where Id IN :listtestatm.Id];
List <GroupMember> gpmem = [select Id from GroupMember where GroupId = :groupRec.id AND  UserorGroupId IN :listtestatm.Id];
//System.AssertEquals(att.Is_Processed__c , TRUE);
//System.AssertEquals(att.Account_User_ID__c , accountObj.Id+':'+testUser.Id+':prg');
*/
    }
    /*
static testMethod void CMAP_AccTeamGroupMemScheduler_Test() {
Test.startTest();
String CRON_EXP = '0 0 0 * * ?';
CMAP_AccTeamGroupMemScheduler sch = new CMAP_AccTeamGroupMemScheduler();
String jobId = System.schedule('TestScheduledApex',CRON_EXP,sch);
CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
//Verify the expressions are the same
System.assertEquals(CRON_EXP,ct.CronExpression);

// Verify the job has not run
System.assertEquals(0, ct.TimesTriggered);
System.abortJob(jobId);
test.stopTest();
}*/
}