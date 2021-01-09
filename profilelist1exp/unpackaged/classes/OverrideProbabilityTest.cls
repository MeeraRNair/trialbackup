@isTest(SeeAllData=true)
private class OverrideProbabilityTest{

    static testMethod void OverrideProbabilityTest_Method1(){
        
        TriggerExecutionController.setSkipAllTriggers(true);
        ProcessFlowTriggerController.isTest = true;
    
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(alias = 'testOP', email='testOP1234@dell.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id, country='United States',            
            timezonesidkey='America/Los_Angeles', username='testOP1234@noemail.com', 
            Badge_Number__c = string.valueof(datetime.now()).replace(':', '').replace('-', '').replace(' ', '') + datetime.now().millisecond());
        insert u;

        Account acc = new Account();
        acc.name = 'Some test Account';        
        acc.status__c = 'Active';
        acc.Account_Country_Code__c='US';              
        insert acc;
        
        TriggerExecutionController.setSkipAllTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(false); // Fenny: Trigger might had been skipped by process flor, so reset to not to skip triggers
        
        List<Opportunity> listOpp = new List<Opportunity>();
        Opportunity testOpp1 = new Opportunity(AccountId = acc.Id, Name = 'testOpportunity', CurrencyIsoCode = 'USD', Type = 'Renewal', CloseDate = system.Today(), Domain__c = 'Non Domain', Solution_Type__c = 'Cloud Integration', Solution_Name__c = 'Boomi Solution', No_times_BookDate_moved__c = 0, StageName = 'Plan - 1%', Override_Probability__c='30%');       
        listOpp.add(testOpp1);
        Opportunity testOpp2 = new Opportunity(AccountId = acc.Id, Name = 'testOpportunity', CurrencyIsoCode = 'USD', Type = 'Renewal', CloseDate = system.Today(), Domain__c = 'Non Domain', Solution_Type__c = 'Cloud Integration', Solution_Name__c = 'Boomi Solution', No_times_BookDate_moved__c = 0, StageName = 'Commit - 90%', Override_Probability__c='90%', Competitor_Lost_To__c = 'Accenture');       
        listOpp.add(testOpp2);
        
        insert listOpp;
        
        system.assertEquals(testOpp1.Override_Probability__c, '30%');
        system.assertEquals(testOpp1.StageName, 'Plan - 1%');
        
        HelperClass.firstRun = true;
        
        system.assertEquals(testOpp2.Override_Probability__c, '90%');
        system.assertEquals(testOpp2.StageName, 'Commit - 90%');
        system.assertEquals(testOpp2.Competitor_Lost_To__c, 'Accenture');

        List<Opportunity> myOp = new List<Opportunity>();
        Opportunity op1 = [select id, StageName, Override_Probability__c, Competitor_Lost_To__c from Opportunity where id =:testOpp1.id limit 1];
        op1.StageName = 'Discover - 10%';
        op1.Competitor_Lost_To__c = 'Accenture';
        op1.Override_Probability__c = '60%';
        
        myOp.add(op1);

        test.startTest();   
        
        system.runas(u){
            update myOp;
            
            system.assertEquals(testOpp1.Competitor_Lost_To__c, null);            
            system.assertEquals(op1.Competitor_Lost_To__c, 'Accenture');
            system.assertEquals(op1.Override_Probability__c, '60%');
            HelperClass.firstRun = false;
        }
        test.stopTest();  
    }                            
}