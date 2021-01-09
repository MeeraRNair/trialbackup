global class Batch_TRTUpdateonPT implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext bc){
        String strquery = 'select id,Partner_Track_Name_Country__c,Partner_Track_Primary_Partner_Track_ID__c,Partner_Track_Program_Group_Name__c,Error__c,Allow_for_manual_Audi_Track_Calculation__c,Name,Master_Group_Affinity_Id__c,Track_Name__c,Partner_Track__c,Primary_Sales_Motion_Affinity_ID__c from Partner_Track__c where Allow_for_manual_Audi_Track_Calculation__c = false and Status__c = true';
        return Database.getQueryLocator(strquery);
    }
	global void execute(Database.BatchableContext bc,List<Partner_Track__c> listpt){
        PartnerTrack_Handler pthandler = new PartnerTrack_Handler();
            pthandler.populatePrimaryPartnerTrackIdBatch(listpt);
    }
    global void finish(Database.BatchableContext bc){
        
    }
}