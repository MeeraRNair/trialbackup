/***********************************************************
    * Name          : BatchAccntNpsResultCalculation 
    * Description   : The batch apex class to calculate the Previous NPS Results/Current NPS Results At Account
    * ---------------------------------------------------------
    * Revision  Name             Date         Description
    * 1.0       Jessie Tan       24-Apr-2014  CR 9548  - Created to calculate the Previous NPS Results/Current NPS Results at
                                                         Account 
    * 2.0       Harsha           09-Apr-2018  CR15436  - Focus_account__c fieldtype change
************************************************************/

global class BatchAccntNpsResultCalculation implements Database.Batchable<sObject> {
  
    //public String query;
    //public Boolean isTest = false;
    TempDataHolderAndCalculator accntPrevAvgNpsCalculator = new AccntPrevAvgNpsScoreCalculator();
    TempDataHolderAndCalculator accntCurrAvgNpsCalculator = new AccntCurrAvgNpsScoreCalculator();
    
    global database.querylocator start(Database.BatchableContext BC){
        //return Database.getQueryLocator('SELECT Id, Previous_NPS_Results__c, Current_NPS_Results__c FROM Account where Focus_Account__c = true');
        return Database.getQueryLocator('SELECT Id, Previous_NPS_Results__c, Current_NPS_Results__c FROM Account where Focus_Account__c != null'); //v2.0
    }
    
    global void execute(Database.BatchableContext BC, List<Account> accounts){
        
        system.debug('## Start Execute method');    
         
        try{ 
        
            Set<Id> accountIdSet = new Set<Id>();
            
            for (Account account: accounts){
                accountIdSet.add(account.Id);        
            }
              
            accntPrevAvgNpsCalculator.storeSourceData(accountIdSet);
            accntCurrAvgNpsCalculator.storeSourceData(accountIdSet);
           
            for (Account account: accounts){
                account.Previous_NPS_Results__c = (Double)accntPrevAvgNpsCalculator.calculateResult(account.Id);
                account.Current_NPS_Results__c = (Double)accntCurrAvgNpsCalculator.calculateResult(account.Id);
            }
           
            Database.update(accounts, false);
            
        }catch(Exception e){
           System.debug('### error : ' + e.getStackTraceString());
           System.debug('### error message: ' + e.getMessage());       
        }
       
        system.debug('## End Execute method');    
        
    }
    
    global void finish(Database.BatchableContext BC){        
        system.debug('## Inside finish method');         
    }
      
}