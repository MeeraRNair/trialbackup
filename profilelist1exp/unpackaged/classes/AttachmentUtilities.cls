/*
 * Author   : Krishnamoorthi
 * Purpose  : Utility class to hold simple and reusable functionalities which are related to Attachment object. 
 *          Please create separate classes and use it for complex logics.
 * 
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      CR11835     16.10           19-Aug-2015     Krishnamoorthi  Created 
 * -------- ---------   ----------      -----------     ------------    -----------
 * Please DO NOT add revision history in the class level, instead add it in the corresponding methods. 
 */
 
 public class AttachmentUtilities {
 
    /*
    Revision    CR Number   Release No      Date            Modified By     Description
    --------    ---------   ----------      -----------     ------------    -----------
    1.0         CR11835     16.10           19-Aug-2015     Krishnamoorthi  Created this method to update the field "Attachment Count" in Support Request
                Story 187282                                                whenever an Attachment is added or deleted. So that the Last Modified date will be changed in SR and 
                                                                            Boomi will update the SR details in Change point.            
    */
    
    public static void updateSRAttachmentCount(List<Attachment> attachmentList, String triggerEvent) {
        
    String srObjPrefix = Support_Request__c.sObjectType.getDescribe().getKeyPrefix(); //Get Id prefix of Support Request object
    String CSS_RECORDTYPEID = IdLookupUtils.getRecordTypeId('Request Custom Service Support', 'Support_Request__c', true); //Get CSS Record Type Id
    List<Support_Request__c> srUpdateList = new List<Support_Request__c>();
    String attachParentId;
    Map<Id,Integer> attachSRMap = new Map<Id,Integer>();
    
    for(Attachment a : attachmentList) {
        attachParentId = a.parentId;
        if(attachParentId.startsWith(srObjPrefix)) { //Check if Attachment parent is Support Request
            //Check the count of attachments for single Support Request
            if(attachSRMap.get(a.parentid) == null) {
                attachSRMap.put(a.parentid, 1);
            }   
            else{
                Integer i = attachSRMap.get(a.parentid);
                attachSRMap.put(a.parentid, (i+1));
             }
            }
        }

    if(attachSRMap.size() > 0){
        for(Support_Request__c sr : [SELECT Id, Attachment_Count__c, Solution_Architect__c, RecordTypeId FROM Support_Request__c WHERE Id IN: attachSRMap.keyset() AND Solution_Architect__c = 'Yes' AND RecordTypeId =: CSS_RECORDTYPEID]){
            
            //Increment the Attachment_Count__c during Attachment insert
            if(triggerEvent == 'Insert') {
                if(sr.Attachment_Count__c > 0) {
                    sr.Attachment_Count__c = sr.Attachment_Count__c + (Integer)attachSRMap.get(sr.Id);
                }
                else {
                    sr.Attachment_Count__c = (Integer)attachSRMap.get(sr.Id);
                }
            }
            
            //Decrement the Attachment_Count__c during Attachment delete
            if(triggerEvent == 'Delete') {
                if(sr.Attachment_Count__c > 0) {
                    sr.Attachment_Count__c = sr.Attachment_Count__c - (Integer)attachSRMap.get(sr.Id);
                }   
            }
            
            srUpdateList.add(sr);
        }
    }
    
    try {
        if(!srUpdateList.isEmpty()){
            update srUpdateList;
        }
    }
    
    catch(Exception e) {
        System.debug('Exception occurred during update of Support Request Attachment Count.' + e);
    }

    }   
    
 }