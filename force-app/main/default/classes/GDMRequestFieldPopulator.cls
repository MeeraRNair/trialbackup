/*
 * Author   : Gan
 * Purpose  : Gives abstract view of all the business logics / functionality implemented
 *       
 * Revision CR Number   Release No  	Date            Modified By     Description
 * -------- ---------   ----------  	-----------     ------------    -----------
 * 1.0      14068		FY18-DCS-0502   14-Mar-2017     Gan           	Populate the approval/rejection comments into custom field
*/

public class GDMRequestFieldPopulator {

    public static void populateBuddyAccessApprovedRejectedComments(map<id, GDM_Request__c> mapGDMReq) {
    
        list<GDM_Request__c> listGdmReq = [Select id, (Select id, processinstanceid, targetobjectid, comments, createddate 
                                           from processSteps 
                                           where comments != null order by createddate desc) 
                                           from gdm_request__c where id in :mapGDMReq.keySet()];

        if(!listGdmReq.isEmpty()) {
        	for(GDM_Request__c objGDMReq : listGDMReq) {
                GDM_Request__c objDMRequestToUpdate = mapGDMReq.get(objGDMReq.id);
                if(!objGDMReq.ProcessSteps.isEmpty() && objGDMReq.ProcessSteps[0].comments != null) {
            		objDMRequestToUpdate.Approval_Rejection_Comments__c = objGDMReq.ProcessSteps[0].comments; 
				}
        	}
        }
    }
}