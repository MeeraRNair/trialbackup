/*====================================================================================================================+
|  HISTORY |                                                                 
|                                                                           
| DATE         DEVELOPER              Story           DESCRIPTION                               
| ===========  =========           =========          =========== 
| 30-Aug-2018  Rajesh Ch             5377640           Initial creation.
| 06-Dec-2019  Venu K 				  0102			   Implemented TDF
+====================================================================================================================*/
@isTest
private class DFS_CreateLeadServices_test{
    @testSetup static void setup() {
        OWD__c owdsetting = new OWD__c();
        owdsetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        owdsetting.Oppty_Stage10__c = 'Discover - 10%';
        owdsetting.Oppty_Stage100__c = 'Win - 100%';
        owdsetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdsetting.Oppty_Stage60__c = 'Propose - 60%';
        owdsetting.Oppty_Stage90__c = 'Commit - 90%';
        owdsetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdsetting.Oppty_Stage1__c = 'Plan - 1%';
        insert owdsetting;
        list<Account> listAccTdf=TestDataFactory.createNAccount(1,'Partner Account');
        insert listAccTdf;
    }   
    static testMethod void testcallDFS(){
        TriggerExecutionController.setSkipAllTriggers(true);
        //TriggerExecutionController.setSkipOpportunityTriggers(true);
        Test.startTest();
        ProcessFlowTriggerController.isTest = true;    
        list<Account> listAcc=[select id from Account Limit 1];
        AccountTeamMember acctmem = new AccountTeamMember();
        acctmem.AccountId = listAcc[0].Id;
        acctmem.UserId = UserInfo.getUserId();
        acctmem.TeamMemberRole = 'Account Services Executive';
        insert acctmem;
        list<id> listIds=new list<id>();
        list<Opportunity> listOpp=TestDataFactory.createNOpportunities(1,'Standard Opportunity');
        listOpp[0].accountId=listAcc[0].id;
        listOpp[0].DFS_Engaged__c = True;
        insert listOpp;   
        listIds.add(listOpp[0].id);
        system.assertEquals(listOpp[0].accountId, listAcc[0].id);
        TriggerExecutionController.setSkipAllTriggers(false);
        DFS_CreateLeadServices.callDFS(listIds);
        Test.stopTest();
    }    
}