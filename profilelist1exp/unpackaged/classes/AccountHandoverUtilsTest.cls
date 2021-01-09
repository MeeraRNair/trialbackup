/**

* Name          : AccountHandoverUtilsTest
* Description   : Test method for Account handover utility methods.
* ---------------------------------------------------------
* Revision  Name     Date        Description
* 1.0       Krishna  09.01.2010  Creation
* 2.0       Ravali   15.11.2017  CR # 15096 - Comment AccountHandoverUtils Class & Fix test coverage
*/


@isTest
private class AccountHandoverUtilsTest {
    public static list<Account> listAcc;
    @testsetup static void setup(){
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTDF = TestDataFactory.createNAccount(2,'Partner Account');
        insert listAccTDF;
    }
    static testMethod void testcreateFollowUpTasksForAccHandoverswithoutIncomingRep() {
        system.debug('##KP: Start Test_createFollowUpTasksForAccHandovers_withoutIncomingRep');
        integer inti;
        
        //Accounts
        /*List<Account> testAccountList = new List<Account>{new Account(name='testAccount1'), new Account(name='testAccount2')};        
insert testAccountList;*/
        listAcc = [Select Id from Account limit 1];
        //Account Handover records
        List<Account_Handover__c> listaccHandover = new List<Account_Handover__c>();
        Account_Handover__c accHandover;
        for(inti=0; inti<2;inti++){            
            accHandover = new Account_Handover__c(Outgoing_rep__c=Userinfo.getUserId(), 
                                                  Account__c=listAcc[0].Id,Outgoing_Handover_Tasks_Completed__c=true,
                                                  Status__c = 'Pending Follow-up'); 
            listaccHandover.add(accHandover);            
        } 
        insert listaccHandover;  
        
        
        Test.startTest();
        AccountHandoverUtils.createFollowUpTasksForAccHandovers(listaccHandover);
        Test.stopTest();
        
        //Ensures no tasks are created as there is no Incoming Rep for these Account Handovers
        System.assertEquals([SELECT Count() FROM Task WHERE WhatId IN :listaccHandover], 0);    
        
        system.debug('##KP: End Test_createFollowUpTasksForAccHandovers_withoutIncomingRep');
    }
    
    static testMethod void testcreateFollowUpTasksForAccHandoverswithIncomingRep() {
        system.debug('##KP: Start Test_createFollowUpTasksForAccHandovers_withoutIncomingRep');
        integer inti; 
        
        //Accounts
        /*List<Account> testAccountList = new List<Account>{new Account(name='testAccount1'), new Account(name='testAccount2')};        
insert testAccountList;*/
        listAcc = [Select Id from Account limit 2];
        //Account Handover records
        List<Account_Handover__c> listaccHandover = new List<Account_Handover__c>();
        Account_Handover__c accHandover;
        for(inti=0; inti<2;inti++){            
            accHandover = new Account_Handover__c(Incoming_rep__c=Userinfo.getUserId(), 
                                                  Account__c=listAcc[1].Id,Outgoing_Handover_Tasks_Completed__c=true,
                                                  Status__c = 'Pending Follow-up'); 
            listaccHandover.add(accHandover);            
        } 
        insert listaccHandover;
        
        Test.startTest();
        AccountHandoverUtils.createFollowUpTasksForAccHandovers(listaccHandover);
        Test.stopTest();
        
        //Ensures no tasks are created as there is no Incoming Rep for these Account Handovers
        System.assertEquals([SELECT Count() FROM Task WHERE WhatId IN :listaccHandover], 2);    
        
        system.debug('##KP: End Test_createFollowUpTasksForAccHandovers_withIncomingRep');
    }
    
    //2.0 CR # 15096 - Comment AccountHandoverUtils Class
    /*

static testMethod void Test_fullTest() {
system.debug('##KP: Start Test_fullTest');

integer i;

//Account
List<Account> testAccountList = new List<Account>{new Account(name='testAccount1'), new Account(name='testAccount2')};        
insert testAccountList;

//Account Handover records
List<Account_Handover__c> accHandoverList = new List<Account_Handover__c>();
Account_Handover__c accHandover;
for(i=0; i<2;i++){            
accHandover = new Account_Handover__c(Outgoing_rep__c=Userinfo.getUserId(), 
Account__c=testAccountList[i].Id,Outgoing_Handover_Tasks_Completed__c=true,Status__c='Pending Assignment'); 
accHandoverList.add(accHandover);            
} 
insert accHandoverList;  
System.assertEquals([SELECT Status__c FROM Account_Handover__c WHERE Id=:accHandoverList[0].Id].Status__c, 
'Pending Assignment',
'Problem on WF for setting Pending Assignment status');
Profile userProfile= [select id,name from profile where name like '%Sales Rep%' order by name limit 1 ];
List<User> testUserList = new List<User>();
for (i=0; i<2;i++){
User user = new User( Username='test' +i+ System.currentTimeMillis() + '@test.com',
Alias = 'test'+i, 
Email='test'+ i +'@dell.com', 
FirstName='Tfirst'+i, 
LastName='TLast'+i,
ProfileId = userProfile.Id, 
LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', 
EmailEncodingKey='UTF-8', 
TimeZoneSidKey='America/Los_Angeles',
Badge_Number__c='TEST12345'+i );

testUserList.add(user);   
} 
insert testUserList;
List<AccountTeamMember> atmArray=new List<AccountTeamMember>();
for (i=0; i<2;i++){            
AccountTeamMember atm01=new AccountTeamMember(userId=testUserList[i].Id,TeamMemberRole='Inside Sales Rep',accountId = testAccountList[i].id); 
atmArray.add(atm01);            
} 
insert atmArray;

Test.startTest();
AccountHandoverUtils.processAccountHandOversForISRs(atmArray);
Test.stopTest();
System.assertEquals([SELECT Status__c FROM Account_Handover__c WHERE Id=:accHandoverList[0].Id].Status__c, 'Pending Follow-up');
System.assertEquals([SELECT Count() FROM Task WHERE WhatId IN :accHandoverList], 2);    

system.debug('##KP: End Test_fullTest');

}
*/
}