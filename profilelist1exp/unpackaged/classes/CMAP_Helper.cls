/****************************************
Version 1: Meera:CMAP Helpser Class
Version 2: CR16130 FY19-DCS-0802 11-July-2018  Deleted and modified duplicated code as part of code cleanup 

****************************************/
public with sharing class CMAP_Helper {
    //Variable to support test execution
    public static boolean skipinsert = false;
    //Method to insert/delete leadhsare records for partners
    @future
    public static void enable_DisableLeadAccess(set<String> leadmgmntenabledIds, set<String> leadmgmntdisabledIds){
        List<PermissionSet> permSet = [SELECT Id FROM PermissionSet WHERE Name = 'CMAP_Lead_MLUR_Access_for_Partners'];  //v2.0
        if(leadmgmntenabledIds.size()>0){            
            if((permSet != null) && (permSet.size() > 0)){
                List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
                for(String leadId : leadmgmntenabledIds){
                    PermissionSetAssignment assi = new PermissionSetAssignment(AssigneeId = leadId, PermissionSetId = permSet[0].Id);   //v2.0
                    assignments.add(assi);
                }
                if(!skipinsert)
                insert assignments;
            }
        }
        if(leadmgmntdisabledIds.size()>0){
            if((permSet != null) && (permSet.size() > 0)){
                List<PermissionSetAssignment> assignments = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId IN :leadmgmntdisabledIds and PermissionSetId =:permSet[0].Id]; //v2.0
                delete assignments;
            }
        }
    }
}