/***********************************************************
* Name          : BatchConvertAccount
* Description   : Convert End User Account to Partner Account and Partner Account to End User if Partner Users > 15
* ---------------------------------------------------------
* Revision     Name    Date            Description
* 1.0         Bikram   19.07.2016      Convert End User Account to Partner Account and Partner Account to End User if Partner Users > 15 using Batch Apex
***********************************************************/
 
global class BatchConvertAccountPAtoEA implements Database.Batchable<sObject>, Database.Stateful {                      
   
    global Database.QueryLocator Start(Database.BatchableContext BC){       
    TriggerExecutionController.setSkipActivateAccount(true);        
        String queryString ='SELECT Id, OwnerId, Owner_Update__c, Type, RecordTypeID,IsPartner FROM Account where (IsPartner = TRUE AND Type = ' + '\'' + 'End User' + '\') OR (IsPartner = FALSE AND Type = ' + '\'' + 'Partner' + '\')';
        //String queryString ='SELECT Id, OwnerId, Owner_Update__c, Type, RecordTypeID,IsPartner FROM Account where (IsPartner = TRUE AND Type = ' + '\'' + 'End User' + '\') OR (IsPartner = FALSE AND Type = ' + '\'' + 'Partner' + '\')';
       // String queryString ='SELECT Id, OwnerId, Owner_Update__c, Type, RecordTypeID,IsPartner FROM Account where IsPartner = TRUE';
        return Database.getQueryLocator(queryString);
    }   
    global void execute (Database.Batchablecontext BC, List<Account> scope) {  
        Id PARecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();
        Id EUARecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End-User Account').getRecordTypeId();
        Map<Id,List<Contact>> mapContactCount = new Map<Id,List<Contact>>();      
        for(Contact obj : [Select Id,AccountId,Name,Partner_User__c,Partner_User_Active__c from Contact WHERE AccountId IN : scope]){
            if(!mapContactCount.containsKey(obj.AccountId)){
                mapContactCount.put(obj.AccountId,new List<Contact>());
            }else{
                mapContactCount.get(obj.AccountId).add(obj);
            }
        }
        
        for (Account acc : scope) {
            if(mapContactCount.containsKey(acc.Id) && mapContactCount.get(acc.Id).size() > 15){ 
                if(acc.Type == 'End User' && acc.IsPartner == true){
                    acc.IsPartner = false;
                    acc.RecordTypeID = EUARecordTypeId; 
                }else if(acc.Type == 'Partner' && acc.IsPartner == false){
                    acc.IsPartner = true;
                   // acc.RecordTypeID = '012A0000000TR6Y';
                   acc.RecordTypeID = PARecordTypeId; 
                }
            }  
        } 
        database.Update( scope,false);
    }
    global void finish (Database.Batchablecontext BC) { 
    TriggerExecutionController.setSkipActivateAccount(false);                                                         
    }     
}