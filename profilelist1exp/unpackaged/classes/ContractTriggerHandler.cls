/*
 * Author   : Men Mee
 * Purpose  : Gives abstract view of all the business logics / functionality implemented on Contract.
 * 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      11722       16.07       23-Jun-2015     Men Mee         Created for implementing "Centralized by Org" trigger architecture - Best practices
 * 2.0      17738       FY20-0802   09-Jul-2019     Fenny           Trigger refactoring
 * 
 */
 
public class ContractTriggerHandler extends TriggerHandler {
    
    public ContractRecordSelector contractRecSelector;
    public override void getRecordSelector() {
        contractRecSelector = new ContractRecordSelector(Trigger.new, Trigger.oldMap, this);
    }
     /*
    public override void onBeforeInsert() {
    	if(!contractRecSelector.lstCSMBContracts.isEmpty()) {
        	ContractFieldPopulator.populateFieldsOnBeforeInsertUpdate(contractRecSelector.lstCSMBContracts);
    	}
    }
    
    public override void onBeforeUpdate() {
    	if(!contractRecSelector.lstCSMBContracts.isEmpty()) {
        	ContractFieldPopulator.populateFieldsOnBeforeInsertUpdate(contractRecSelector.lstCSMBContracts);
    	}
    }
    
    public override void onAfterInsert() {
        
    }
    
    public override void onAfterUpdate() {
    	if(!contractRecSelector.setSupportReqIds.isEmpty()) {
        	ContractFieldPopulator.updateSupportRequestStatus(contractRecSelector.setSupportReqIds);
    	}       
    }*/
}