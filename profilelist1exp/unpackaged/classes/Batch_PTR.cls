global class Batch_PTR implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc){
        String strquery = 'select id,Key__c,Sales_Motion_Account_AffinityId__c,Master_Group_AffinityId__c,Partner_Track_AffinityId__c from Partner_Track_Relationship__c where Is_Processed__c = false';
        return Database.getQueryLocator(strquery);
    }
    global void execute(Database.BatchableContext bc,List<Partner_Track_Relationship__c> listptrList){
        PTRUtility nu=new PTRUtility();
        list<Partner_Track_Relationship__c> listPtrProcessed = nu.InsertPTR(listptrList,'batch');
        if(listPtrProcessed.size() > 0){
            Database.update(listPtrProcessed, false);                
        }
    } 
    global void finish(Database.BatchableContext bc){
        
    }
    
}