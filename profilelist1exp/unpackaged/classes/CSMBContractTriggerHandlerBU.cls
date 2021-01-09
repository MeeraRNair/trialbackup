/*
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      17738       FY20-0802   09-Jul-2019     Fenny           Trigger refactoring. Below methods calls copied from legacy ContractTriggerHandler
 * 
 */

public class CSMBContractTriggerHandlerBU implements BeforeUpdate{
    ContractTriggerHandler trigHandler = new ContractTriggerHandler();
    public void handleBeforeUpdate(List<sObject> listNew,Map<Id, sObject> mapOld){
        system.debug('Entered ContractTrigger handleBeforeUpdate');
        trigHandler.run();
        if(!trigHandler.contractRecSelector.lstCSMBContracts.isEmpty()) {
            ContractFieldPopulator.populateFieldsOnBeforeInsertUpdate(trigHandler.contractRecSelector.lstCSMBContracts);
        }
    }
    
}