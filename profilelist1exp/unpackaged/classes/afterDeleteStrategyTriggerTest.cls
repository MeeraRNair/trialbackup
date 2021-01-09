@isTest
private class afterDeleteStrategyTriggerTest {

    private static testmethod void afterDeleteStrategyTrigger (){
         //Create a user with Standard User profile       
         Profile profile = [select id from profile where Name = 'System Administrator' limit 1];
         User userRecord = new User(Username='testvaliduser2'+ System.currentTimeMillis()+'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test212'+'@dell.com',            
                                    LastName='Test22',
                                    Title='GCC Program Manager', 
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Country='US',
                                    Badge_Number__c='Test');
        insert userRecord;
        System.runAs(userRecord){
        Account testEUAccount = new Account(Name='Test EU Account for Account Plan Test',Type = 'End User',
                                                Participating_in_LOB_Program__c = true,
                                                OwnerId = userRecord.Id);
        insert testEUAccount;
          
        SFDC_Acct_Plan__c APRec = new SFDC_Acct_Plan__c(name='TestPlan01',Account__c= testEUAccount.Id,Plan_Starting_Fiscal_Year__c='FY12', Sales_Manager__c = userRecord.Id);
        // certTrackRec.Account_Id__c = account.id;
        insert APRec;
        
        
        SFDC_Strategy__c StrategyRec = new SFDC_Strategy__c(
            SFDC_Acct_Plan__c = APRec.id,
            When_do_you_plan_to_realize_Strategy__c = 'FY12',
            Potential_Strategy_Value__c = 1.00
        );
        // certTrackRec.Account_Id__c = account.id;
        insert StrategyRec ;
        List <SFDC_Strategy__c>  StrategyTest = [Select Name, Id from SFDC_Strategy__c where Id = : StrategyRec.id];
        delete StrategyRec;
        
        Test.startTest();
            
        List <Partner_Hub_Record_Deleted__c>  PartnerHubRecTest = [Select Key_Identifier__c, Record_GUID__c, Type__c from Partner_Hub_Record_Deleted__c where Record_GUID__c = :StrategyTest[0].id];
        
        PartnerHubRecTest[0].Key_Identifier__c =  StrategyTest[0].Name; 
        PartnerHubRecTest[0].Record_GUID__c = StrategyTest[0].Id ;
        PartnerHubRecTest[0].Type__c = 'Strategy' ;
                
        Test.stopTest();
        }
    }
}