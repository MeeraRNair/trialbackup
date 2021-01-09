/*
 * Author   : Gan
 * Purpose  : Gives abstract view of all the business logics / functionalities implemented on Lead.
 * 
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      14068		FY18-DCS-0502   14-Mar-2017     Gan            Created for implementing "Centralized by Org" trigger architecture - Best practices
 * 2.0      CR17930     FY20-1002       13-Aug-2019     Fenny           Refactoring trigger framework
 */

public class GDMRequestTriggerHandler extends TriggerHandler {
	
    public GDMRequestRecordSelector gdmReqRecSelector;
    public override void getRecordSelector() {
        gdmReqRecSelector = new GDMRequestRecordSelector(Trigger.new, Trigger.oldMap, this);
    }
    /*
    public override void onBeforeUpdate() {
        system.debug('#####onBeforeUpdate Block##########');
        if(!gdmReqRecSelector.mapBuddyAccessToUpdateComments.isEmpty()) {
			GDMRequestFieldPopulator.populateBuddyAccessApprovedRejectedComments(gdmReqRecSelector.mapBuddyAccessToUpdateComments);   
        }
    }
    */
}