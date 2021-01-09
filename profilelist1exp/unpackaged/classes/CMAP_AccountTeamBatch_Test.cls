/************************************************************
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------------
1.0     08-Nov-2013     Jiji            Test Class for CMAP_AccTeamGroupMemBatch
2.0     04-Dec-2019     Vikas KH        Implemented TDF
*************************************************************/

//@isTest(SeeAllData=true)
@isTest
private class CMAP_AccountTeamBatch_Test {
    static list<Account> listAcc;
    @testSetup static void setup(){
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'Partner Account');
        listAccTDF[0].Type = 'Partner';
        insert listAccTDF;
    }
    static testMethod void testCMAPAccountTeamScheduler() {
        Test.startTest();
        /*        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
Account accountObj = new Account(name='Test',
RecordtypeId= accRTId, 
Type = 'Partner');
insert accountObj; */
        listAcc = [select id, Type from Account limit 1];
        system.assertNotEquals(null, listAcc[0].Type);
        /*Profile userProfile= [select id,name from profile where name like '%Sales Rep%' order by name limit 1 ];
User testuser = new User( Username='testi'+ System.currentTimeMillis() + '@test.com',
Alias = 'cmapi', 
Email='test.icmap@dell.com', 
FirstName='Tfirsti', 
LastName='TLasti',
ProfileId = userProfile.Id, 
LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', 
EmailEncodingKey='UTF-8', 
TimeZoneSidKey='America/Los_Angeles',
Badge_Number__c='campi');

insert testuser ;
*/
        User userRec= [select id,name, Badge_Number__c from User where Profile.Name like '%Sales Rep%' AND isActive = TRUE order by name limit 1 ];
        Group groupRec = new Group(Name='CMAP:AT:'+listAcc[0].Id,DoesIncludeBosses = false);
        insert groupRec;
        List<AccountTeamMember> listatmember = new List<AccountTeamMember> ();
        AccountTeamMember atm01=new AccountTeamMember(
            userId=UserRec.Id,
            TeamMemberRole='OEM Account Executive',
            accountId = listAcc[0].id);
        listatmember.add(atm01);
        Account_Team__c acntTeam = new Account_Team__c(
            Account__c = listAcc[0].Id,
            User__c = UserRec.Id,
            Badge_Number__c = UserRec.Badge_Number__c ,
            Account_User_ID__c = listAcc[0].Id+':'+UserRec.Id,
            Account_Id__c = listAcc[0].Id,
            Team_Member_Role__c = 'OEM Account Executive',
            Status__c = 'A'                                        
            
        );
        insert acntTeam;
        /*
CMAP_AccountTeamBatch batchObjectTest = new CMAP_AccountTeamBatch();
if(Test.isRunningTest()){
batchObjectTest.query = 'SELECT Account__c, Account_ID__c, '+
' Sales_Channel_Name__c, '+
' Account_Type__c, Badge_Number__c, '+
' Team_Member_Role__c, Status__c, '+
' Account_User_ID__c, '+
' Is_Processed__c '+
' FROM Account_Team__c '+ 
//'LIMIT 200'; 
' Where Id =\''+acnt_Team.Id+'\'';

}
else{
batchObjectTest.query = 'SELECT Account__c, Account_ID__c, '+
' Sales_Channel_Name__c, '+
' Account_Type__c, Badge_Number__c, '+
' Team_Member_Role__c, Status__c, '+
' Account_User_ID__c, '+
' Is_Processed__c '+
' FROM Account_Team__c '+ 
'LIMIT 10000'; 
}
Id batchprocessesidTest = database.executebatch(batchObjectTest,200);*/
        datetime dtsystime = datetime.now();
        string strschTime = AccountOwnerTransitionUtils.BatchJobScheduleTime(dtsystime);
        CMAP_AccountTeamScheduler u = new CMAP_AccountTeamScheduler (); 
        u.isTest=True;
        String strscheduledJobID = system.schedule('CMAP_AccountTeamScheduler' + string.valueof(dtsystime), strschTime, u);
        Test.stopTest();
        /*Account_Team__c att = [select Id, Is_Processed__c, Account_User_ID__c  From Account_team__c where Id = :acnt_Team.Id];
System.AssertEquals(att.Is_Processed__c , TRUE);
System.AssertEquals(att.Account_User_ID__c , accountObj.Id+':'+UserRec.Id+':prg');*/
    }
}