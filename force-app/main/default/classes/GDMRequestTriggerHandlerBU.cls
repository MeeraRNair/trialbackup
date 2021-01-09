/*
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      CR17930     FY20-1002       13-Aug-2019     Fenny           Refactoring trigger framework. Following method calls are copied from GDMRequetTriggerHandler
 */

public class GDMRequestTriggerHandlerBU implements BeforeUpdate{
    GDMRequestTriggerHandler trigHandler = new GDMRequestTriggerHandler();
     
    public void handleBeforeUpdate(List<sObject> listNew, Map<Id, sObject> mapOld){
        System.debug('Entered GDMRequest handleBeforeUpdate');
        trigHandler.run();
        
        if(!trigHandler.gdmReqRecSelector.mapBuddyAccessToUpdateComments.isEmpty()) {
			GDMRequestFieldPopulator.populateBuddyAccessApprovedRejectedComments(trigHandler.gdmReqRecSelector.mapBuddyAccessToUpdateComments);   
        }
       
    }
}