/*
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 *  1.0     17789       FY20-0802   16-Jul-2019     Fenny           Trigger refactoring. Method calls copied from legacy DellEMCKeyContactTriggerHandler
 *
 * NOTE: Strictly NO business logics inside this trigger.
 */
public class PartnerSvcDellEMCKeyContactTriggerAU implements AfterUpdate{
    
    public void handleAfterUpdate(List<sObject> listNew, Map<Id, sObject> mapOld){
        // After successfully updation
        System.debug('Entered DellEMCKeyContactTrigger handle AfterUpdate ');
    	
        PartnerServiceUtilities.updateEMCOperationDEllEMCKeyContacts((List<DellEMC_Key_Contacts__c>)listNew);
    }
    
}