@isTest
private class AccountPlanUtilitiesTest { 
    
    @testSetup static void createTestData(){
    
      Account actObj = new Account(Name='Test Account', Type = 'End User', Focus_Account__c = 'Direct Account Plan');
      insert actObj;
      
      List<SFDC_Acct_Plan__c> listAP = new List<SFDC_Acct_Plan__c>();
      SFDC_Acct_Plan__c apFY19 = new SFDC_Acct_Plan__c(Name='Test AP FY19', Account__c=actObj.id, Plan_Starting_Fiscal_Year__c = 'FY19');
      SFDC_Acct_Plan__c apFY20 = new SFDC_Acct_Plan__c(Name='Test AP FY20', Account__c=actObj.id, Plan_Starting_Fiscal_Year__c = 'FY20');
      SFDC_Acct_Plan__c apFY21 = new SFDC_Acct_Plan__c(Name='Test AP FY21', Account__c=actObj.id, Plan_Starting_Fiscal_Year__c = 'FY21');
      SFDC_Acct_Plan__c apFY22 = new SFDC_Acct_Plan__c(Name='Test AP FY22', Account__c=actObj.id, Plan_Starting_Fiscal_Year__c = 'FY22');
      SFDC_Acct_Plan__c apFY23 = new SFDC_Acct_Plan__c(Name='Test AP FY23', Account__c=actObj.id, Plan_Starting_Fiscal_Year__c = 'FY23');
      listAP.add(apFY19);
      listAP.add(apFY20);
      listAP.add(apFY21);
      listAP.add(apFY22);
      listAP.add(apFY23);
      insert listAP; 
    } 
    
     static testmethod void updateAccountFromNONAGLtoAGL(){
         
       Account actObj = [Select Id, Focus_Account__c from Account limit 1];
       actObj.Focus_Account__c = 'Account Growth Lab'; 

       Test.startTest();
         update actObj;
      Test.stopTest();  
         
      Account accCheck = [select id, name, Focus_Account__c from Account where id = :actObj.id];
      System.assertEquals('Account Growth Lab', accCheck.Focus_Account__c); 
        
    }
    
    
    static testmethod void updateAccountFromAGLtoNONAGL(){
        
       Account actObj = [Select Id, Focus_Account__c from Account limit 1];
       actObj.Focus_Account__c = 'Account Plan Lite';
        
       Test.startTest();
      		 update actObj; 
       Test.stopTest();
        
       Account accCheck = [select id, name, Focus_Account__c from Account where id = :actObj.id];
       System.assertEquals('Account Plan Lite', actObj.Focus_Account__c);
       System.debug('sazleen display actObj.Focus_Account__c ################################################ '+actObj.Focus_Account__c);
    }


    } // end class