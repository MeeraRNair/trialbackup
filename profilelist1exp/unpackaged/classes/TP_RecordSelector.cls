/*
* Author   : Harsha
* Purpose  : Centralize the record selection process for Territory Plan.
*          Defines the methods which iterate and segregate the Territory Plan records for further use.
* 
* Revision CR Number   	Release No      Date            Modified By     Description
* -------- ---------   	----------      -----------     ------------    -----------
* 1.0      CR15172    	FY18-DCS-0102   27-Nov-2017     Harsha          Created for implementing "Centralized by Org" trigger architecture - Best practices
*/
public class TP_RecordSelector extends RecordSelector{
    
    private TriggerHandler tpTrigHandler;
    public list<Territory_plan__c> tpToshareWithManager = new list<Territory_plan__c>();
	public map<id, Territory_Plan__c> mapOldTPAll = new map<id, Territory_Plan__c>();    
    public list<Territory_plan__c> tpNewAllList = new list<Territory_plan__c>();
    public TP_RecordSelector(list<sObject> listTP, map<Id, sObject> mapOldTP, TriggerHandler tpTrigHandler) {
        this.tpTrigHandler = tpTrigHandler;
        
        this.getRecords(listTP, mapOldTP);
        
        if(listTP != null) {
            this.getRelatedRecords(listTP);
        }
        else if(mapOldTP != null) {
            this.getRelatedRecords(mapOldTP.values());
        }
    }
    
    protected override void getRecords(list<sObject> listTP, map<Id, sObject> mapOldTP) {
        
        if(listTP != null){
            for(Territory_Plan__c tp : (list<Territory_Plan__c>)listTP){
                Territory_plan__c oldTP;
                tpNewAllList.add(tp);
                if(mapOldTP != null && !mapOldTP.isEmpty()){
                    mapOldTPAll.put(tp.Id, (Territory_plan__c)mapOldTP.get(tp.Id));
                    oldTP = (Territory_plan__c)mapOldTP.get(tp.Id);
                    if(tp.Manager_Approver__c != oldTP.Manager_Approver__c){
                        tpToshareWithManager.add(tp);
                	}
                }
            }
        }
        
        removeNulls();
    }
    
    protected override void getRelatedRecords(list<sObject> listTP) {
        
    }
    
     // Remove nulls from the Set / List / Map.
    private void removeNulls() {
        
    }
}