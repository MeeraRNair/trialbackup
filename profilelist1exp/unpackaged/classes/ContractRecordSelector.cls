/*
 * Author   : Men Mee
 * Purpose  : Centralize the record selection process for Contract.
 *          Defines the methods which iterate and segregate the Contract records for further use.
 * 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      11722       16.07       23-Jun-2015     Men Mee         Created for implementing "Centralized by Org" trigger architecture - Best practices
 * 
 * 
 */
 
public class ContractRecordSelector extends RecordSelector {

    private TriggerHandler contractTrigHandler;
    
    public set<Id> setSupportReqIds = new set<Id>();
    public list<Contract> lstCSMBContracts = new list<Contract>();
    
    public ContractRecordSelector(list<sObject> lstContracts, map<Id, sObject> mapOldContracts, TriggerHandler contractTrigHandler) {
        this.contractTrigHandler = contractTrigHandler;
        
        this.getRecords(lstContracts, mapOldContracts);
        
        this.getRelatedRecords(lstContracts);
        
        removeNulls();
    }
    
    protected override void getRecords(list<sObject> lstContracts, map<Id, sObject> mapOldContracts) {

        if(lstContracts != null) {
            for(Contract newContract:(list<Contract>)lstContracts) {
                Contract oldContract;
                if(mapOldContracts != null && !mapOldContracts.isEmpty()) {
                    oldContract =(Contract) mapOldContracts.get(newContract.Id);
                }
                
                if(contractTrigHandler != null) {
                    if(contractTrigHandler.trigType == TriggerHandler.TriggerType.ISBEFORE) {
                        if(contractTrigHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                            if(newContract.No_Approval_Required__c == false) {
                                lstCSMBContracts.add(newContract);
                            }
                        } 
                        else if(contractTrigHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                            if(newContract.No_Approval_Required__c == false &&(newContract.No_Approval_Required__c != oldContract.No_Approval_Required__c || CSMBUtilClass.isValueChanged(oldContract, newContract))) {
                                lstCSMBContracts.add(newContract);
                            }
                        }
                    }
                    else if(contractTrigHandler.trigType == TriggerHandler.TriggerType.ISAFTER) {
                        if(contractTrigHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                            if(newContract.Status != oldContract.Status) {
                                setSupportReqIds.add(newContract.CSMB_Support_Request__c);
                            }
                        }
                    }               
                }
            }                       
        }
        
    }
    
    protected override void getRelatedRecords(list<sObject> lstContracts) {
        
    }
        
    private void removeNulls() {
    	setSupportReqIds.remove(null);
    }
    
}