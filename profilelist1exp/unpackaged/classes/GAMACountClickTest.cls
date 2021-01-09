/*
REVISION HISTORY
================
Version    Author          Date               Description
-------    ------          ----               -------------        
1.0        venu           20-Nov-2019          Implimented TestDataFactory        
*/
@isTest
private class GAMACountClickTest {
    
    static PageReference gAMAPref;
    //Added custom settings to populate StageName values. - SinLin
    @testSetup static void setup() {
        // Create common test OWD settings
        OWD__c owdSetting = new OWD__c();
        owdSetting.Oppty_Stage1__c = 'Plan - 1%';
        owdSetting.Oppty_Stage10__c = 'Discover - 10%';
        owdSetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdSetting.Oppty_Stage60__c = 'Propose - 60%';
        owdSetting.Oppty_Stage90__c = 'Commit - 90%';
        owdSetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdSetting.Oppty_Stage100__c = 'Win - 100%';
        owdSetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        Insert owdSetting;
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTdf;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        listOppTdf[0].Accountid=listAccTdf[0].id;
        insert listOppTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    //end
    
    private static testMethod void testSearchOpportunityRegion(){
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAcc=[Select id from Account Limit 1];
        Contact newcon = new Contact(FirstName='Test Contact', LastName='Lastname1', AccountId=listAcc[0].Id, Phone='12345',Decision_Making_Role__c='Influencer', Job_Function__c='IT',Purchaser_Influence_over_Merged__c='Client-Desktops');
        insert newcon;
        
        list<Opportunity> listOpp=[Select id from Opportunity Limit 1];
        system.assertEquals(newcon.AccountId, listAcc[0].Id);
        Test.startTest();
        
        gAMAPref=Page.GAMA_Home;
        gAMAPref.getParameters().put('id',listOpp[0].id);
        gAMAPref.getParameters().put('obj','Opportunity');
        Test.SetCurrentPage(gAMAPref);
        
        GAMACountClick myGAMATest = new GAMACountClick();
        myGAMATest.getOpportunityRegion();
        myGAMATest.generateLink();
        myGAMATest.countClick();
        gAMAPref=Page.GAMA_Home;
        gAMAPref.getParameters().put('id',listAcc[0].id);
        gAMAPref.getParameters().put('obj','Account');
        Test.SetCurrentPage(gAMAPref);
        
        GAMACountClick myGAMATest1 = new GAMACountClick();
        myGAMATest1.getAccountRegion();
        myGAMATest1.generateLink();
        myGAMATest1.countClick();
        gAMAPref=Page.GAMA_Home;
        gAMAPref.getParameters().put('obj','Homepage');
        Test.SetCurrentPage(gAMAPref);
        
        GAMACountClick myGAMATest2 = new GAMACountClick();
        myGAMATest2.generateLink();
        myGAMATest2.redirectGAMA();
        TriggerExecutionController.setSkipAllTriggers(false);
        Test.stopTest();               
    } 
}