/*
 * Author   : Men Mee
 * Purpose  : Utility class to hold simple and reusable functionalities for auto populating User fields. 
 *        
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR12402     17.02       30-11-2015      Men Mee           Created for implementing "Centralized by Org" trigger architecture - Best practices
 * -------- ---------   ----------  -----------     ------------    -----------------------------------------------------------------------------------
 * Please DO NOT add revision history in the class level, instead add it in the corresponding methods. 
 */

public class UserFieldPopulator {

    /* 
    Revision    CR Number   Release No      Date            Modified By     Description
    --------    ---------   ----------      -----------     ------------    -----------
    1.1         CR6077      12.10                                           Reminder Email are not being sent to Partner and Account Owner 10 days prior to Deal Expiration Date; as part of CR 3404 implementation.
    1.2         CR6245      12.10                           Fenny           Domain Duplicate Check
    1.3         CR6750      13.7
    1.4                     14.2            07-12-2012      Bianca Huit     CMAP - User Language Translation
    2.0         CR12402     17.02           30-11-2015      Men Mee         This logic is separated from  afterUpdateUserTrigger and beforeUserModification trigger and rewritten as part of trigger redesign.
    3.0         CR12723     CSM0403         29-03-2016      Kenny           Update Language to Release Comms Language custom field when conditions are met    
    4.0                                     27-04-2016      Afiq            Refactor CR12723 logic
    5.0                                     08-Nov-2016     Krishnakumar    Resolve email address loophole in RM notification
    6.0         CR14186                     18-Apr-2017     Manvendra       Identify the users if they have SSO Enabled permission or under SSO profile and then updating the Is_SSO_User__c field to true.
    */
    public static void populateFieldsOnBeforeInsertUpdate(list<User> LstUsers, Map<Id,User> mapOldUsers, Map<Id, Contact> contactMap) {

        String email = null;
        PartnerLanguage pl = new PartnerLanguage(true);
        
        Map<Id, Boolean> userIdtoRM = new Map<Id, Boolean>();
        Map<Id, String> badgeIdMap = new Map<Id, String>();
        
        for(User usrProfileInfo:LstUsers) {
            if(usrProfileInfo.Badge_Number__c != null){
                badgeIdMap.put(usrProfileInfo.id, usrProfileInfo.Badge_Number__c);
            }
        }        
        
        //6.0 Start 
        //To find userId that is assignee of SSO Permission Set
        Set<Id> setPermissionSetAssignee = new Set<Id>();
        
        for(PermissionSetAssignment psa : [SELECT Id,AssigneeId,PermissionSetId  FROM PermissionSetAssignment  WHERE AssigneeId IN : LstUsers AND PermissionSet.Name =: Label.SSOPermissionSet]){
            setPermissionSetAssignee.add(psa.assigneeId);
        }        
        //6.0 End
        
        //To find Integrated_User__c from PeopleSoft_User_View__c and set Is_Integrated_User__c in User
        if(badgeIdMap.size() > 0){
            for(PeopleSoft_User_View__c pps: [Select Integrated_User__c, Badge_Number__c from PeopleSoft_User_View__c WHERE Badge_Number__c IN :badgeIdMap.values()]){
                for (Id id : badgeIdMap.keySet()) {
                    if(badgeIdMap.get(id) == pps.Badge_Number__c){
                        if(pps.Integrated_User__c == 'Yes'){
                            userIdtoRM.put(id,true);
                        }else{
                            userIdtoRM.put(id,false);
                        }
                    }
                }
            }
        }
               
        for(User usr: LstUsers ) {
            //1.1
            if(usr.LanguageLocaleKey != null){
                usr.Submitter_Partner_Language__c = pl.returnMatchValue(usr.LanguageLocaleKey);
            }

            //1.2 the new version of user record is a partner user if the associated account is a partner account
            if (contactMap != null && contactMap.get(usr.ContactId) != null && contactMap.get(usr.ContactId).Account.IsPartner){
                email = usr.Email;
                if ((email != null) && (email.trim().length() > 0)) {
                    email = email.trim();
                    usr.Partner_Domain_Name__c = email.substring(email.indexOf('@') + 1);
                }
            }
            //1.2-end 
            
            //1.3
            if(Test.isRunningTest() || usr.ISM__c == '00530000000nY2dAAE'){
                    usr.ISM__c = null;
            }
            if(Test.isRunningTest() || usr.RSM__c == '00530000000nY2dAAE'){
                usr.RSM__c = null;
            }
            if(Test.isRunningTest() || usr.Director__c == '00530000000nY2dAAE'){
                usr.Director__c = null;
            }
            //1.3-end
               
            //1.4
            if (mapOldUsers == null ||
                 (mapOldUsers != null && usr.LanguageLocaleKey != null && usr.LanguageLocaleKey != mapOldUsers.get(usr.Id).LanguageLocaleKey)) {
                usr.Language_code__c = usr.LanguageLocaleKey;
            }

            usr.Is_Admin_for_Partner_Finder_Profile__c = usr.Enable_Partner_Admin__c;
                                           
            if(mapOldUsers != null && usr.EmpStatus__c == 'T' && usr.IsActive == true && (usr.ProfileId == '00eA0000000hLlP'|| usr.ProfileId == '00eA0000000hLlPIAU')){
                usr.IsActive = false;
                usr.Email = usr.Email + '.terminated';
                usr.Username = usr.Username + '.terminated';
            }  
            
            //14.2 SSO Changes for Vendr System Synch
            if (mapOldUsers != null) {
                //if the user's contact is synched with vendor system check whether isActive or languagelocalekey is modified
                if(contactMap.get(usr.ContactId) != null && contactMap.get(usr.ContactId).Vendor_Update_Datetime__c != null &&
                    (usr.IsActive != mapOldUsers.get(usr.id).IsActive)|| usr.LanguageLocaleKey != mapOldUsers.get(usr.id).LanguageLocaleKey
                    ||(usr.Is_Vendor_Update_Required__c == true && usr.Is_Vendor_Updated__c == false && usr.Last_Operation_Performed__c == 'SFDC Updated')){//already marked for BOOMI to pick up and something else is getting updated
                        usr.Is_Vendor_Update_Required__c = true;
                        usr.Is_Vendor_Updated__c = false;
                        usr.Last_Operation_Performed__c = 'SFDC Updated';
                        usr.Operation_for_Boomi__c = 'UPDATE_USER';
                }               
                else{
                    usr.Is_Vendor_Update_Required__c = false;                    
                    usr.Operation_for_Boomi__c = null;
                }
                //5.0 - Start
                if(mapOldUsers.containsKey(usr.id)){
                    User oldUser = mapOldUsers.get(usr.id);
                    if(oldUser.Email != null && usr.Email != oldUser.Email){
                        usr.Old_Email__c = oldUser.Email;
                        //To find Integrated_User__c from PeopleSoft_User_View__c and set Is_Integrated_User__c in User
                        if(userIdtoRM.size() > 0){
                            if(userIdtoRM.get(usr.id) != null && usr.Is_Integrated_User__c != userIdtoRM.get(usr.id)){
                                usr.Is_Integrated_User__c = userIdtoRM.get(usr.id);
                            }
                        }                        
                        
                        System.debug('@@@@@@@@@ license used : ' + usr.License_Used__c);
                        System.debug('@@@@@@@@@ assigned permission? : ' + setPermissionSetAssignee.contains(usr.Id));
                        System.debug('@@@@@@@@@ contains SSO profile? : ' + Label.SSOProfiles.contains(usr.ProfileId));
                        //6.0 Start 
                        //To flag Is_SSO_User__c for 'User Email & Username Changes Notification for SSO Users' Rule if there's changes in email
                        usr.is_SSO_User__c = ( (usr.License_Used__c == 'Salesforce' || usr.License_Used__c == 'Chatter Only') && (setPermissionSetAssignee.contains(usr.Id) || Label.SSOProfiles.contains(usr.ProfileId)));
                        //6.0 End
                        
                    } 
                }
                //5.0 - End
            }
            
            //3.0 - Start
            //4.0 - Refactor the code logic to check custom settings
            String UsrRCL  = '1:' + usr.LanguageLocaleKey;
            String UsrRCL2 = '2:' + usr.HR_Location_Country_Desc__c;
            String UsrRCL3 = '3:' + usr.LocaleSIDKey;
            String UsrRCL4 = '4:' + usr.Country;
            system.debug('Country!!!!'+UsrRCL);
            system.debug('Country!!!!'+UsrRCL2);
            system.debug('Country!!!!'+UsrRCL3);
            system.debug('Country!!!!'+UsrRCL4);
        /*    User_Release_Comms_Language__c URCL = User_Release_Comms_Language__c.getInstance(UsrRCL);
            User_Release_Comms_Language__c URCL2 = User_Release_Comms_Language__c.getInstance(UsrRCL2);
            User_Release_Comms_Language__c URCL3 = User_Release_Comms_Language__c.getInstance(UsrRCL3);
            User_Release_Comms_Language__c URCL4 = User_Release_Comms_Language__c.getInstance(UsrRCL4);   
                      
            if(usr.IsActive == false || (usr.UserType != 'Standard' && usr.UserType != null) || (usr.License_Used__c != 'Salesforce' &&
                usr.License_Used__c != 'Chatter Only' && usr.License_Used__c != null)  ){
                    usr.Release_Comms_Language__c = 'None';
            } 
            else if( URCL != null){
                usr.Release_Comms_Language__c = URCL.Release_Comms_Language__c;
            }
            else if(URCL2 != null){
                usr.Release_Comms_Language__c = URCL2.Release_Comms_Language__c;
            }
            else if(URCL3 != null){
                usr.Release_Comms_Language__c = URCL3.Release_Comms_Language__c;
            }
            else if(URCL4 != null){
                usr.Release_Comms_Language__c = URCL4.Release_Comms_Language__c;
            } 
            else {
                usr.Release_Comms_Language__c = 'English';
            }   */  
                        list<User_Release_Comms_Languages__mdt> listURCL = [Select Release_Comms_Language__c from User_Release_Comms_Languages__mdt where Country_Name__c=:UsrRCL];
            list<User_Release_Comms_Languages__mdt> listURCL2 = [Select Release_Comms_Language__c from User_Release_Comms_Languages__mdt where Country_Name__c=:UsrRCL2];
            list<User_Release_Comms_Languages__mdt> listURCL3 = [Select Release_Comms_Language__c from User_Release_Comms_Languages__mdt where Country_Name__c=:UsrRCL3];
            list<User_Release_Comms_Languages__mdt> listURCL4 = [Select Release_Comms_Language__c from User_Release_Comms_Languages__mdt where Country_Name__c=:UsrRCL4];
            
            
            if(usr.IsActive == false || (usr.UserType != 'Standard' && usr.UserType != null) || (usr.License_Used__c != 'Salesforce' &&
                usr.License_Used__c != 'Chatter Only' && usr.License_Used__c != null)  ){
                    usr.Release_Comms_Language__c = 'None';
            } 
            else if(listURCL.size() > 0 && listURCL[0].Release_Comms_Language__c != null){
                usr.Release_Comms_Language__c = listURCL[0].Release_Comms_Language__c;
            }
            else if(listURCL2.size() >0 && listURCL2[0].Release_Comms_Language__c != null){
                usr.Release_Comms_Language__c = listURCL2[0].Release_Comms_Language__c;
            }
            else if(listURCL3.size() >0 && listURCL3[0].Release_Comms_Language__c != null){
                usr.Release_Comms_Language__c = listURCL3[0].Release_Comms_Language__c;
            }
            else if(listURCL4.Size()>0 && listURCL4[0].Release_Comms_Language__c != null){
                usr.Release_Comms_Language__c = listURCL4[0].Release_Comms_Language__c;
            } 
            else {
                usr.Release_Comms_Language__c = 'English';
            }     
            //3.0 - End 
            //4.0 - End         
        }
    }    
}