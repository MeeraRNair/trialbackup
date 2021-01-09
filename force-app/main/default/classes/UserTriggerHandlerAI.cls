/*
 * Author   : Men Mee
 * Purpose  : Gives abstract view of all the business logics / functionality implemented on User.
 * 
 * Revision CR Number   Release No  	Date            Modified By     Description
 * -------- ---------   ----------  	-----------     ------------    -----------
 * 1.0      CR12402     17.02       	30-11-2015      Men Mee         Created for implementing "Centralized by Org" trigger architecture - Best practices
 * 2.0      CR15073     FY18-DCS-0102	01-11-2017		Gan				Fixed error during user termination
 * 3.0                  FY19-DCS-0502   10-05-2018      Rahul Mishra    comment out UserUtilities.SSOVendorAssociation logic since it is not in use now
 * 4.0      CR17552     FY20-0702       26-May-2019     Fenny           UserTriggerHandler obsolete. Above histories and below methods calls are copied from UserTriggerHandler
 */

public class UserTriggerHandlerAI implements AfterInsert{
    UserTriggerHandler trigHandler = new UserTriggerHandler();
    
    public void handleAfterInsert(List<sObject> listNew){
        System.debug('Entered User handleAfterInsert');
        trigHandler.run();
        
        UserUtilities.assignSalesConsole((Map<Id, User>) Trigger.newMap, null, trigHandler.trigEvent);
        
        UserUtilities.CMAPLeadSuperUserPermission (trigHandler.usrRecordSelector.userMap, trigHandler.usrRecordSelector.gpMap, trigHandler.trigEvent);
        
        EntitySubscriptionUtils.followUserAndGroup(trigHandler.usrRecordSelector.chatterUserIDList);        
        
        UserUtilities.ViperMDFProgramSharing(Trigger.new, null);
        //2.0
        if(!System.isBatch() && (trigHandler.usrRecordSelector.leadmgmntenabledIds.size()>0 || trigHandler.usrRecordSelector.leadmgmntdisabledIds.size()>0)){
          CMAP_Helper.enable_DisableLeadAccess(trigHandler.usrRecordSelector.leadmgmntenabledIds, trigHandler.usrRecordSelector.leadmgmntdisabledIds);
        }
        UserUtilities.grantRevokeAccess((Map<Id, User>) Trigger.newMap,null);
    }
}