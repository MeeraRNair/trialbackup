/*
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      17738       FY20-0802   09-Jul-2019     Fenny           Trigger refactoring. Below methods calls copied from legacy ContractTriggerHandler
 * 
 */

public class CSMBContractTriggerHandlerAU implements AfterUpdate {
    ContractTriggerHandler trigHandler = new ContractTriggerHandler();
    public void handleAfterUpdate(List<sObject> listNew, Map<Id, sObject> mapOld){
        system.debug('Entered ContractTrigger handleAfterUpdate');
 		trigHandler.run();
        if(!trigHandler.contractRecSelector.setSupportReqIds.isEmpty()) {
            ContractFieldPopulator.updateSupportRequestStatus(trigHandler.contractRecSelector.setSupportReqIds);
        }  
    }
}