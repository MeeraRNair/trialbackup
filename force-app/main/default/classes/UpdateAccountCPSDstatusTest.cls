@isTest
Public class UpdateAccountCPSDstatusTest{
    static testmethod void cpsdafterAccountupdate(){
        TriggerExecutionController.setSkipAllTriggers(true);
         List<Account> listacc=new List<Account>();
        Account testAccount = new Account(Name='testOpportunityPlanRedirectPage Test Account',Phone='',CPSD_Account_ID__c='Ab123456',CPSD_Integration_Status__c='Completed');  
        listacc.add(testAccount);
        insert listacc;
        TriggerExecutionController.setSkipAllTriggers(false);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
        Test.startTest();
        listacc[0].phone='55555';
        Update listacc;
        Test.stopTest();
       system.assertEquals('55555',listacc[0].Phone ); 
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
    }
}