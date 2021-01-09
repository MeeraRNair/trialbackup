/*
 * Author   : Men Mee
 * Purpose  : Gives abstract view of all the business logics / functionality implemented on User.
 * 
 * Revision CR Number   Release No  	Date            Modified By     Description
 * -------- ---------   ----------  	-----------     ------------    -----------
 * 1.0      CR12402     17.02       	30-11-2015      Men Mee         Created for implementing "Centralized by Org" trigger architecture - Best practices
 * 2.0      CR15073     FY18-DCS-0102	01-11-2017		Gan				Fixed error during user termination
 * 3.0                  FY19-DCS-0502   10-05-2018      Rahul Mishra    comment out UserUtilities.SSOVendorAssociation logic since it is not in use now
 * 4.0      CR17552     FY20-0702       26-May-2019     Fenny           UserTriggerHandler obsolete
 */

public class UserTriggerHandler extends TriggerHandler {

    public userRecordSelector usrRecordSelector;
    public override void getRecordSelector() {
        usrRecordSelector = new UserRecordSelector(Trigger.new, Trigger.oldMap, this);
    }  
    /*
    public override void onBeforeInsert() {
        UserFieldPopulator.populateFieldsOnBeforeInsertUpdate(Trigger.new, null, usrRecordSelector.contactMap );
        
        //Commented By : Sneha
        //Comment on : 23rd Feb 2019
        //Comment Due to PAM Changes
        //UserValidator.validateForLeadManagementEnabledForOEM ((map<Id, User>) Trigger.newMap, null, usrRecordSelector.LMchangedids);
        
    }
    
    public override void onBeforeUpdate() {
        UserFieldPopulator.populateFieldsOnBeforeInsertUpdate(Trigger.new, (map<Id, User>) Trigger.oldMap, usrRecordSelector.contactMap );
        //Commented By : Sneha
        //Comment on : 23rd Feb 2019
        //Comment Due to PAM Changes
        //UserValidator.validateForLeadManagementEnabledForOEM ((map<Id, User>) Trigger.newMap, (map<Id, User>) Trigger.oldMap, usrRecordSelector.LMchangedids);
    }
    
    public override void onAfterInsert() {
        UserUtilities.assignSalesConsole((Map<Id, User>) Trigger.newMap, null, trigEvent);
        
        UserUtilities.CMAPLeadSuperUserPermission (usrRecordSelector.userMap, usrRecordSelector.gpMap, trigEvent);
        
        EntitySubscriptionUtils.followUserAndGroup(usrRecordSelector.chatterUserIDList);        
        
        UserUtilities.ViperMDFProgramSharing(Trigger.new, null);
        //2.0
        if(!System.isBatch() && (usrRecordSelector.leadmgmntenabledIds.size()>0 || usrRecordSelector.leadmgmntdisabledIds.size()>0)){
        	CMAP_Helper.enable_DisableLeadAccess(usrRecordSelector.leadmgmntenabledIds,usrRecordSelector.leadmgmntdisabledIds);
        }
    	
        UserUtilities.grantRevokeAccess((Map<Id, User>) Trigger.newMap,null);
    }
    
    public override void onAfterUpdate() {
        UserUtilities.updateInactivePartnerUserOrLead (Trigger.new, (map<Id, User>) Trigger.oldMap);
        
        UserUtilities.assignSalesConsole((Map<Id, User>) Trigger.newMap, (map<Id, User>) Trigger.oldMap, trigEvent);
        
        UserUtilities.CMAPLeadSuperUserPermission(usrRecordSelector.userMap, usrRecordSelector.gpMap, trigEvent);
        
        UserUtilities.syncUpdateToCMI(Trigger.new, (map<Id, User>) Trigger.oldMap);
        
        UserUtilities.ViperMDFProgramSharing(Trigger.new, (map<Id, User>) Trigger.oldMap);
        
      //  UserUtilities.SSOVendorAssociation((map<Id, User>) Trigger.newMap, (map<Id, User>) Trigger.oldMap);
        //2.0
        if(!System.isBatch() && (usrRecordSelector.leadmgmntenabledIds.size()>0 || usrRecordSelector.leadmgmntdisabledIds.size()>0)){
        	CMAP_Helper.enable_DisableLeadAccess(usrRecordSelector.leadmgmntenabledIds,usrRecordSelector.leadmgmntdisabledIds);
        }
        
      
    }
*/
}