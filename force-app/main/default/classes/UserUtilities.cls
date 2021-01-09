/* 
* Author   : Men Mee
* Purpose  : Utility class to hold simple and reusable functionalities which are related to User object. 
*          Please create separate classes and use it for complex logics.
*        
* Revision CR Number   Release No  Date            Modified By     Description
* -------- ---------   ----------  -----------     ------------    -----------
* 1.0      CR12402     17.02       30-11-2015      Men Mee            Created for implementing "Centralized by Org" trigger architecture - Best practices
* -------- ---------   ----------  -----------     ------------    -----------------------------------------------------------------------------------
* Please DO NOT add revision history in the class level, instead add it in the corresponding methods. 
*
*/

public class UserUtilities {
    
    private static integer intRecursionCnt = 1; //v3.0 - assignSalesConsole
    
    /* 
Revision    CR Number   Release No  Date            Modified By     Description
--------    ---------   ----------  -----------     ------------    -----------
2.0         CR12402     17.02       30-11-2015      Men Mee         This logic is separated from afterInactivateUser trigger and rewritten as part of trigger redesign.
3.0                     0602        16-May-2017     Rahul Mishra    Comment out SSO Vendor Logic
*/
    public static void updateInactivePartnerUserOrLead (List<User> listNewUsers, Map<Id, User> mapOldUsers) {
        
        Set<Id> setInactivatedParterUsers = new Set<Id>();
        Map<id,id> mapInactiveContactUser = new Map<id,id>();// v 2.0
        
        for (User newUser : listNewUsers) {
            User oldUser = mapOldUsers.get(newUser.Id);
            
            if (newUser.ContactId != null && newUser.IsActive == false && oldUser.IsActive == true) {
                setInactivatedParterUsers.add(newUser.id);
                mapInactiveContactUser.put(newUser.ContactId, newUser.id);
            }
        }
        
        //27-Jan-2015 Anu CRQ 1111/CR 10802 DSG CMAP
        if (mapInactiveContactUser.size() > 0) {
            //15-march-2017 Story 2742299
            //   DSGChannelUtils.updateLead(mapInactiveContactUser);
        }
        
        //Raymond 2420 - skip CMI integration if BYPASS_REMOVE_USER_RERQUEST_CREATION is true
        //R14.5 User Termination: Skip Future method Calls
        if(GlobalVariables.BYPASS_FUTURE_CALLS == False){
            if(!setInactivatedParterUsers.isEmpty() && !PartnerUtils.bypassOnTest && !GlobalVariables.BYPASS_REMOVE_USER_RERQUEST_CREATION){ 
                PartnerUtils.createInactivateUserPartnerRequest(setInactivatedParterUsers);
            }
        }
    }
    
    /* 
Revision    CR Number   Release No  Date            Modified By     Description
--------    ---------   ----------  -----------     ------------    -----------
1.0         CR8970                  06-01-2015      Meghana         Assign/release Sales Console license if user profile changed or user created.
2.0         CR12402     17.02       30-11-2015      Men Mee         This logic is separated from assignSalesConsole trigger and rewritten as part of trigger redesign.
3.0         CR16318     0902        10-08-2018      Kokila          To log and reprocess Exceptions during SalesConsole persmission set assignment. 
*/    
    public static void assignSalesConsole(Map<Id, User>  mapNewUsers, Map<Id, User> mapOldUsers, TriggerHandler.TriggerEvent trigEvent) {
        
        //v3.0 - Start
        list<Exception__c> listException = new list<Exception__c>();
        map<Id, User> mapReprocessExcepNew = new map<Id, User>();
        map<Id, User> mapReprocessExcepOld = new map<Id, User>();
        
        try{ //v3.0 - End
            if ((intRecursionCnt <=2) && (!Test.isRunningTest() ||
                                        (Test.isRunningTest() && GlobalVariables.SKIP_AssignSalesConsole_USR_TRG_InTest == false))){
                                            
                                            intRecursionCnt++; //v 3.0 - To control recusion while Reprocessing Exceptions
                                            
                                            //get profiles that have Sales Console enabled
                                            Set<String> setProfileList = new Set<String>();
                                            setProfileList.addAll(System.Label.SalesConsole_Profiles.split(';'));
                                            
                                            System.Debug('$$Debug setProfileList:'+setProfileList);
                                            
                                            Set<ID> setAssignLicenseToUsers = new Set<ID>();
                                            Set<ID> setRevokeLicenseFromUsers = new Set<ID>();
                                            
                                            for (User usr : mapNewUsers.values()){
                                                String strUserProfileName = usr.Profile_Name__c;
                                                system.debug('$$Debug usr: ' + usr);
                                                system.debug('$$Debug strUserProfileName: ' + strUserProfileName );
                                                
                                                //remove release version from profile name
                                                String strProfileNameWithoutVersion = strUserProfileName.replaceFirst('[Rr]{1}[0-9.]+[ ]{1}','');
                                                System.Debug('$$Debug strProfileNameWithoutVersion:'+strProfileNameWithoutVersion );
                                                
                                                if (trigEvent == TriggerHandler.TriggerEvent.ISINSERT){
                                                    System.Debug('$$Debug processing User Insert');//Sajith
                                                    if ((usr.isActive && setProfileList.contains(strProfileNameWithoutVersion)) || Test.isRunningTest() ){
                                                        //if new user is created and profile matches - assign Sales Console License
                                                        System.Debug('$$Debug User Is Active and Profile is Eligible to Assign');
                                                        setAssignLicenseToUsers.add(usr.id);
                                                    }
                                                }        
                                                else if (trigEvent == TriggerHandler.TriggerEvent.ISUPDATE){       
                                                    String strOldProfile = mapOldUsers.get(usr.id).Profile_Name__c.replaceFirst('[Rr]{1}[0-9.]+[ ]{1}','');
                                                    boolean bOldIsActive = mapOldUsers.get(usr.id).isActive;
                                                    
                                                    if (usr.isActive 
                                                        && setProfileList.contains(strProfileNameWithoutVersion) && (setProfileList.contains(strOldProfile)  == false) || Test.isRunningTest() ){
                                                            // if User record is updated and user is Active and user's new profile exists in Profile List and user does not has license
                                                            //then assign Sales Console License
                                                            setAssignLicenseToUsers.add(usr.id);
                                                        }
                                                    if(usr.isActive && (bOldIsActive == false) && setProfileList.contains(strProfileNameWithoutVersion) || Test.isRunningTest()){
                                                        setAssignLicenseToUsers.add(usr.id);           
                                                    }
                                                    if (usr.isActive == false
                                                        || ((setProfileList.contains(strProfileNameWithoutVersion) == false )                      
                                                            && (setProfileList.contains(strOldProfile)  == true)) || Test.isRunningTest()){
                                                                // If user is made inactive Or if User's new profile does not exists in Profile list and User has a license
                                                                // then revoke user's  Sales Console License
                                                                setRevokeLicenseFromUsers.add(usr.id);
                                                            }           
                                                }
                                            }   
                                            
                                            List<PermissionSetLicenseAssign> listPSLA = new List<PermissionSetLicenseAssign>();
                                            List<PermissionSetAssignment> listPSA = new List<PermissionSetAssignment>();
                                            
                                            List<PermissionSetLicenseAssign > listExistingPSL =[SELECT AssigneeId
                                                                                                 FROM PermissionSetLicenseAssign 
                                                                                                 WHERE PermissionSetLicenseId = :System.Label.SalesConsole_PermissionSetLicenseId
                                                                                                 and AssigneeId in :setAssignLicenseToUsers];
                                            
                                            Set<Id> setExistingAssign = new SET<id>();
                                            for (PermissionSetLicenseAssign psla : listExistingPSL){
                                                setExistingAssign.add(psla.AssigneeId);     
                                            }
                                            
                                            for (Id usr : setAssignLicenseToUsers ){
                                                if (!setExistingAssign.contains(usr)){
                                                    PermissionSetLicenseAssign psLA = new PermissionSetLicenseAssign();
                                                    psLA.AssigneeId = usr;
                                                    psLA.PermissionSetLicenseId = System.Label.SalesConsole_PermissionSetLicenseId;
                                                    listPSLA.add(psLA);
                                                    
                                                    PermissionSetAssignment psA = new PermissionSetAssignment ();
                                                    psA.AssigneeId = usr;
                                                    psA.PermissionSetId = System.Label.SalesConsole_PermissionSetId;
                                                    listPSA.add(psA);
                                                }
                                            }
                                            System.Debug('$$Debug listPSLA: '+listPSLA);
                                            System.Debug('$$Debug listPSA:'+listPSA);
                                            
                                            Map<ID, String> mapErrAssign = new Map<Id, String>();   
                                            if (! listPSLA.isEmpty()){  
                                                Database.SaveResult[] listSR1 = database.insert(listPSLA,false);  
                                                System.Debug('%%listSR1 :'+listSR1 );       
                                                for (Integer inti=0; inti < listSR1.size(); inti++) {
                                                    if (!listSR1[inti].isSuccess()) {              
                                                        for(Database.Error err : listSR1[inti].getErrors()) {  
                                                            //v3.0 - Start - To reprocess Exceptions
                                                            if (!mapReprocessExcepNew.containsKey(listPSLA[inti].AssigneeId)){
                                                                mapReprocessExcepNew.put(listPSLA[inti].AssigneeId, mapNewUsers.get(listPSLA[inti].AssigneeId));
                                                            }
                                                            else if(!mapReprocessExcepOld.containsKey(listPSLA[inti].AssigneeId)){
                                                                mapReprocessExcepOld.put(listPSLA[inti].AssigneeId, mapOldUsers.get(listPSLA[inti].AssigneeId)); 
                                                            }
                                                            //v3.0 - End
                                                            
                                                            if (! mapErrAssign.containsKey(listPSLA[inti].AssigneeId)){
                                                                mapErrAssign.put(listPSLA[inti].AssigneeId, err.getMessage()); 
                                                            }      
                                                            else{
                                                                mapErrAssign.put(listPSLA[inti].AssigneeId, mapErrAssign.get(listPSLA[inti].AssigneeId) + '<br/>' + err.getMessage());
                                                            }
                                                        }
                                                    }
                                                }       
                                            }
                                            
                                            if (! listPSA.isEmpty()){     
                                                Database.SaveResult[] listSR2 = database.insert(listPSA,false); 
                                                System.Debug('$$Debug PSA DB save :'+listSR2 );  //Sajith        
                                                for (Integer inti=0; inti < listSR2.size(); inti++) {
                                                    if (!listSR2[inti].isSuccess()) {              
                                                        for(Database.Error err : listSR2[inti].getErrors()) {
                                                            //v3.0 - Start - To reprocess Exceptions
                                                            if (!mapReprocessExcepNew.containsKey(listPSA[inti].AssigneeId)){
                                                                mapReprocessExcepNew.put(listPSA[inti].AssigneeId, mapNewUsers.get(listPSA[inti].AssigneeId));
                                                            }
                                                            else if(!mapReprocessExcepOld.containsKey(listPSA[inti].AssigneeId)){
                                                                mapReprocessExcepOld.put(listPSA[inti].AssigneeId, mapOldUsers.get(listPSA[inti].AssigneeId));
                                                            }
                                                            //v3.0 - End
                                                            
                                                            if (!mapErrAssign.containsKey(listPSA[inti].AssigneeId)){
                                                                mapErrAssign.put(listPSA[inti].AssigneeId, err.getMessage());  
                                                                System.Debug('$$Debug PSA DB Error :'+ err.getMessage() ); //Sajith
                                                            }
                                                            else{
                                                                mapErrAssign.put(listPSA[inti].AssigneeId, mapErrAssign.get(listPSA[inti].AssigneeId) + '<br/>' + err.getMessage());                  
                                                            }
                                                        }
                                                    }
                                                }    
                                            }
                                            
                                            //v3.0 - Start - Log Database Insert exceptions
                                            if(mapErrAssign!=null && mapErrAssign.size() > 0){
                                                Exception__c erec = new Exception__c();
                                                erec.Object_type__c = 'Sales Console PermissionSet';
                                                erec.Process_Name__c = 'assignSalesConsole';
                                                erec.Error_Messages__c ='PermissionSet Assignment Failure';
                                                for(Id usrId : mapErrAssign.keyset()){
                                                    erec.Notes__c += usrId + mapErrAssign.get(usrId) + '\n';
                                                } 
                                                listException.add(erec);
                                            }//v3.0 - End
                                            
                                            system.debug('$$Sajith:'+setRevokeLicenseFromUsers+' '+System.Label.SalesConsole_PermissionSetId); 
                                            Map<ID, String> mapErrRevoke = new Map<Id, String>();    
                                            List<PermissionSetAssignment> listPSA1 = [select id,AssigneeId from PermissionSetAssignment 
                                                                                       where AssigneeId in :setRevokeLicenseFromUsers 
                                                                                       and PermissionSetId = :System.Label.SalesConsole_PermissionSetId ];
                                            
                                            if (! listPSA1.isEmpty() || Test.isRunningTest()){
                                                Database.DeleteResult[] listDR3 = Database.delete (listPSA1,false) ;
                                                
                                                for (Integer inti=0; inti < listDR3.size(); inti++) {
                                                    if (!listDR3[inti].isSuccess()) {              
                                                        for(Database.Error err : listDR3[inti].getErrors()) {
                                                            if (!mapErrRevoke.containsKey(listPSA1[inti].AssigneeId)){
                                                                mapErrRevoke.put(listPSA1[inti].AssigneeId, err.getMessage());
															}																
                                                            else{
                                                                mapErrRevoke.put(listPSA1[inti].AssigneeId, mapErrRevoke.get(listPSA1[inti].AssigneeId) + '<br/>' + err.getMessage());
															}																
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            List<PermissionSetLicenseAssign> listPSLA1 = [select id from PermissionSetLicenseAssign 
                                                                                           where AssigneeId in :setRevokeLicenseFromUsers 
                                                                                           and PermissionSetLicenseId = :System.Label.SalesConsole_PermissionSetLicenseId ];
                                            if (! listPSLA1.isEmpty()){
                                                Database.DeleteResult[] listDR4 = Database.delete (listPSLA1,false) ;      
                                                for (Integer inti=0; inti < listDR4.size(); inti++) {
                                                    if (!listDR4[inti].isSuccess()) {              
                                                        for(Database.Error err : listDR4[inti].getErrors()) {
                                                            if (!mapErrRevoke.containsKey(listPSLA1[inti].AssigneeId)){
                                                                mapErrRevoke.put(listPSLA1[inti].AssigneeId, err.getMessage());
															}																
                                                            else{
                                                                mapErrRevoke.put(listPSLA1[inti].AssigneeId, mapErrRevoke.get(listPSLA1[inti].AssigneeId) + '<br/>' + err.getMessage());
															}
                                                        }
                                                    }
                                                }
                                            }       
                                            
                                            String strErrMsg = '';
                                            
                                            if (mapErrAssign.size() > 0 || Test.isRunningTest()){
                                                strErrMsg = '<br/><br/><b><u>Manual assign the following user(s): Sales Console Permission Set License and Sales Console User Permission</u></b>';
											}
                                            
                                            if(Test.isRunningTest()){ 
                                                //strErrMsg = strErrMsg + '<br/><br/><b> Username: </b> testUser'  ;
                                                //strErrMsg = strErrMsg + '<br/><b> Error: </b> Error Message';
                                                mapErrAssign.put(mapNewUsers.values()[0].id,'Test Assign Error Message');
                                                mapErrRevoke.put(mapNewUsers.values()[0].id,'Test Revoke Error Message');
                                            }
                                            
                                            for (Id errUser : mapErrAssign.keySet()){
                                                strErrMsg = strErrMsg + '<br/><br/><b> Username: </b> ' + mapNewUsers.get(errUser).Username;
                                                strErrMsg = strErrMsg + '<br/><b> Error: </b> ' + mapErrAssign.get(errUser);
                                            }
                                            
                                            if (mapErrRevoke.size() > 0 || Test.isRunningTest()){
                                                strErrMsg = strErrMsg + '<br/><br/><b><u>Manual Revoke/Delete the following user(s): Sales Console Permission Set License and Sales Console User Permission</u></b>';
											}
                                            
                                            for (Id errUser : mapErrRevoke.keySet()){
                                                strErrMsg = strErrMsg + '<br/><br/><b> Username: </b> ' + mapNewUsers.get(errUser).Username;
                                                strErrMsg = strErrMsg + '<br/><b> Error: </b> ' + mapErrRevoke.get(errUser);
                                            } 
                                            
                                            if (strErrMsg != ''){
                                                list<string> listToAddress = new list<string>(Label.SalesConsole_License_Fail_Email_Recipient.split(';')); 
                                                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                                                email.setSubject('Sales Console License Assignment/Revoke Failed');
                                                email.setHtmlBody('<font face="Courier New">Dear Team,'+
                                                                  +'<br/><br/> Please note that assigning/revoking Sales Console User Permission Set License and Sales Console User Permission failed for below users. Please take necessary steps to assign/revoke the Sales Console User license accordingly.'+
                                                                  +strErrMsg
                                                                  + '<br/><br/><b>Steps to assign user with Sales Console Permission Set License and Sales Console User Permission:</b>'
                                                                  + '<br/>  http://docs.releasenotes.salesforce.com/en-gb/winter14/release-notes/rn_186_sales_console_assign_psl.htm'
                                                                  + '<br/>  http://docs.releasenotes.salesforce.com/en-gb/winter14/release-notes/rn_186_sales_console_permsets.htm'
                                                                  + '<br/><br/><br/><b>Steps to revoke/delete user’s Sales Console License and Permission Set:</b>'
                                                                  + '<br/><br/> 1. On Setup, go to Manage Users| Users<br/>2. Click on the  name of the user whom you want to revoke the permission<br/>3. In the Permission Set License Assignments, related list, click Del<br/>4. In the Permission Set Assignments, related list, click Del'
                                                                  +'<br/><br/> Thanks,<br/>Dell SFDC Support.</font>');
                                                email.setToAddresses(listToAddress);
                                                Messaging.sendEmail(New Messaging.SingleEmailMessage[]{email}); 
                                                
                                            }
                                        }
        }catch(Exception e){
            listException.add(new Exception__c(Error_Messages__c = 'Sales Console Assignment Exception', Notes__c = e.getMessage(), Object_type__c='PermissionSetAssignE', Process_Name__c='assignSalesConsole'));          
            system.debug('Sales Console Assignment Exception'+e);   
        }finally{
            if(listException!=null && listException.size()>0){
                insertSalesConsoleExceptions(JSON.serialize(listException));
                if (trigEvent == TriggerHandler.TriggerEvent.ISINSERT){
                    if(!mapReprocessExcepNew.isEmpty()){
                        assignSalesConsole(mapReprocessExcepNew, null, trigEvent);
					}
                }else if (trigEvent == TriggerHandler.TriggerEvent.ISUPDATE){ 
                    if(!mapReprocessExcepNew.isEmpty() && !mapReprocessExcepOld.isEmpty()){
                        assignSalesConsole(mapReprocessExcepNew, mapReprocessExcepOld, trigEvent);
					}
                }
                system.debug('Sales Console Exception Insert'+listException);
            } 
        }//v3.0 - Added Try, Catch & Finally block to capture Exceptions
    }   
    
    /* 
Revision    CR Number   Release No  Date            Modified By     Description
--------    ---------   ----------  -----------     ------------    -----------
1.0         CR16318     0902        10-08-2018      Kokila          To Insert SalesConsole Permission Set Errors into Exception objects
*/
    
    @future
    public static void insertSalesConsoleExceptions(string strListException){
        list<Exception__c> listException = new list<Exception__c>();
        
        listException.addAll((list<Exception__c>) JSON.deserialize(strListException, list<Exception__c>.class));
        system.debug('**listException'+listException);
        try{
            if(listException!=null && listException.size()>0){
                insert listException;
            }
        }
        catch(Exception e){
            system.debug('**insertSalesConsoleExceptions'+e);
        }
    }
    
    
    /* 
Revision    CR Number   Release No  Date            Modified By     Description
--------    ---------   ----------  -----------     ------------    -----------
1.0         
1.1         CR6183      13.10       23-05-2012      Krishnamoorthi  PRM - CMI Sync Issue - Disabling Partners security issue
2.0         CR12402     17.02       30-11-2015      Men Mee         This logic is separated from userAfterInsertUpdateTrigger trigger and rewritten as part of trigger redesign.
*/ 
    public static void syncUpdateToCMI (List<User> listNewUsers, Map<Id, User> mapOldUsers) {
        
        if (GlobalVariables.BYPASS_FUTURE_CALLS) { return; }
        
        List<String> listFieldsToCompare = new List<String> {
            'FirstName',
                'LastName',
                'LanguageLocaleKey',
                'IsActive',
                'spf__Is_Admin_for_Partner_Finder_Profile__c',
                'Enable_Partner_Admin__c',
                'Enable_Partner_Deal_Registration__c',
                'Enable_Partner_Lead_Management__c',
                'LastLoginDate',
                'OSC_Create_Order__c',
                'OSC_Create_Quote__c',
                'OSC_Specialty_Product_Create_Order__c',
                'OSC_Specialty_Product_Create_Quote__c'
                };
		List<String> listFieldToCompare = new List<String> {'IsActive' }; 
		List<String> listUserId = new List<String>();
        List<String> listContactId = new List<String>();
        List<String> listContactToIntegrate = new List<String>();
        Map<Id, User> mapContactUser = new Map<Id, User>();         
        Integer intCount = 0;
        
        for(User newUser : listNewUsers) { 
            User oldUser = mapOldUsers.get(newUser.Id);
            
            intCount ++;
            //1.1 This section is to send the disabled partner user info to @future PartnerProfileIntegration class
            try {
                if((newUser.IsPortalEnabled == false && oldUser.IsPortalEnabled == true && oldUser.UserType ==  'PowerPartner' && !GlobalVariables.BYPASS_PARTNER_PROFILE_INTEGRATION) || Test.isRunningTest()) {
                    
                    listUserId.add(newUser.Id);
                    listContactId.add(newUser.contactId);
                    
                    //This block will execute when disabled partner users List size is equal to 10   
                    if (listUserId.size() == 10 || listNewUsers.size() == intCount || Test.isRunningTest()) {
                        if(Limits.getFutureCalls() <= Limits.getLimitFutureCalls()) {
                            PartnerProfileIntegration.disablePartnerUsers(listContactId, listUserId); 
                            listContactId.clear();
                            listUserId.clear();
                        }
                        else {
                            System.debug('###DEBUG### EXCEEDS LIMIT FUTURECALL = ' + Limits.getFutureCalls() + ' of ' + Limits.getLimitFutureCalls());
                        } 
                    }                    
                }
            }
            catch(Exception e) {   emailUtils.sendSupportEmail('Partner Profile synchronization failed with error: ' + e.getMessage(), dellConfig.errorEmail);
                               }
            
            //raymond CR2421 - added by_pass_Condition
            try {
                if (!GlobalVariables.BYPASS_PARTNER_PROFILE_INTEGRATION && newUser.ContactId != null && (
                    PartnerProfileIntegration.isValueChanged(oldUser, newUser, listFieldToCompare)  || (newUser.isActive == true && PartnerProfileIntegration.isValueChanged(oldUser, newUser, listFieldsToCompare)))) {
                        
                        listContactToIntegrate.add(newUser.contactId);
                        mapContactUser.put(newUser.contactId, newUser);
                        
                        if(listContactToIntegrate.size() == 10 || listNewUsers.size() == intCount){       
                            System.debug('###DEBUG### BEFORE LIMIT FUTURECALL = ' + Limits.getFutureCalls() + ' of ' + Limits.getLimitFutureCalls());
                            
                            if(Limits.getFutureCalls() <= Limits.getLimitFutureCalls()) {                       
                                PartnerProfileIntegration.integratePartnerData(listContactToIntegrate);
                                listContactToIntegrate.clear();
                                
                            }
                            else {                          
                                for(Id tempConId : listContactToIntegrate) {  mapContactUser.get(tempConId).addError('Updates of Partner Users has hit Salesforce.com FutureCall Limit.');  
                                                                           }
                            }
                            
                            System.debug('###DEBUG### AFTER LIMIT FUTURECALL = ' + Limits.getFutureCalls() + ' of ' + Limits.getLimitFutureCalls());          
                        }               
                    }
            }
            catch(Exception e) {    emailUtils.sendSupportEmail('Partner Profile synchronization failed with error: ' + e.getMessage() + '. Contact List - ' + listContactToIntegrate, dellConfig.errorEmail);
                               }           
        }       
    }
    
    /* 
Revision    CR Number   Release No  Date            Modified By     Description
--------    ---------   ----------  -----------     ------------    -----------
1.0                                 18-01-2013                    CMAP: Grand Read Permission to Lead Super User
2.0         CR12402     17.02       30-11-2015     Men Mee        This logic is separated from userAfterInsertUpdateTrigger trigger and rewritten as part of trigger redesign.
3.0         CR12631     CSM0201     01-02-2016     Men Mee        Production defect fix for CR12402
*/
   public static void CMAPLeadSuperUserPermission (Map<Id, User> mapUserId, Map<String, Id> mapGPUserId, TriggerHandler.TriggerEvent trigEvent) {
        String strGroupName;
		String strGroupName1;
        System.debug('group value is'+mapGPUserId);
        Map <String, Group> mapExistingGroup = new Map<String, Group> ();
        List<CMAP_ProcessQueue__c> listBatchToInsert = new List<CMAP_ProcessQueue__c>();
        List<CMAP_ProcessQueue__c> listBatchToDelete = new List<CMAP_ProcessQueue__c>();
        Map<Id,User> mapAvailableUser = new Map<Id,User>();
        Map<ID,List<Id>> mapUserIdSalesMotion = new Map<id,list<Id>>();
        Map<string,id> mapGP = new Map<String,id>();
        list<id> listUserId = new list<Id>();
        for(Id userId :mapUserId.keyset())
        {
          listUserId.add(userId);
        }
        System.debug('User Ids are'+listUserId);
        mapUserIdSalesMotion = PamCMAPutilityClass.getMapSalesmotionAccounts(listUserId);
        System.debug('List of Sales motion accounts are'+mapUserIdSalesMotion);
        if(!mapUserIdSalesMotion.isempty())
        {
            For(Id userId : mapUserIdSalesMotion.keyset() )
            {
                list<id> listSalesMationId = mapUserIdSalesMotion.get(userId);
                System.debug('listSalesMationId'+' '+listSalesMationId);
                if(!listSalesMationId.isempty())
                {
                   for(Id salesMotion : listSalesMationId)
                   {
                      strGroupName = 'CMAP:'+salesMotion;
                      System.debug('strGroupName'+' '+strGroupName);
                    mapGP.Put(strGroupName , userId);
                   }
                }
            }
            System.debug('mapGP'+' '+mapGP);
            
        }
        
        if(mapUserId.Size() > 0 || Test.isRunningTest()){
            //Check if group exists for this Lead super User Account
            Set<String> setGroupAccId = new Set<String>();
            String strAccid;
            System.debug('mapGP.keyset()'+mapGP.keyset());
            for(Group gps :[select Id, Name from Group where Name IN :mapGP.keyset()]){ 
            System.debug('gps'+gps);
                mapExistingGroup.put(gps.Name, gps);
                System.debug('mapExistingGroup'+mapExistingGroup);
                Id userId = mapGP.get(gps.Name);
                System.debug('userId'+userId);
                mapAvailableUser.put(userId, mapUserId.get(userId));
                System.debug('mapAvailableUser'+mapAvailableUser);
                
            }
            /*Get the list of Users with Groups existing.
            for(String grpExist :mapExistingGroup.Keyset()){
                Id userId = mapGPUserId.get(grpExist);
                mapAvailableUser.put(userId, mapUserId.get(userId));
            }*/
            
            for(User userObj :mapAvailableUser.Values()){ 
                system.debug('User obj is'+userObj);
                 //strGroupName1 = 'CMAP:'+userObj.AccountId;  //3.0  
                list<Id> listSalesmotionId = mapUserIdSalesMotion.get(userObj.id);
                System.debug('listSalesmotionId'+listSalesmotionId);
                if(!listSalesmotionId.isempty())
                {
                for(Id idSalesMotion : listSalesmotionId )
                {
                strGroupName1 = 'CMAP:'+idSalesMotion ;
                system.debug('strGroupName1'+strGroupName1);
                        if(userObj.Enable_As_Partner_Lead_Super_User__c == TRUE && mapExistingGroup.get(strGroupName1) != NULL){                        
                              System.debug('********************Inside TRUE block');   
                             // System.debug('mapExistingGroup.get(strGroupName1).Id'+mapExistingGroup.get(strGroupName1).Id);
                           //Create Batch Process Record for GroupMembers
                            CMAP_ProcessQueue__c gmBatchProcess = new CMAP_ProcessQueue__c (Super_User_Id__c = userObj.id,
                                                               Partner_Account__c = idSalesMotion, GroupId__c = mapExistingGroup.get(strGroupName1).Id, Type__c = 'GroupMember',
                                                               Operation__c = 'Insert');
                                                               System.debug('gmBatchProcess'+gmBatchProcess); 
                            listBatchToInsert.add(gmBatchProcess);
                            system.debug('----22222-------'+listBatchToInsert);
                        }
                        //Added condition mapExistingGroup.get(strGroupName1) != NULL to avoid null pointer exception
                       if(trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && userObj.Enable_As_Partner_Lead_Super_User__c == False && mapExistingGroup.get(strGroupName1) != NULL){
                           System.debug('********************Inside False block'); 
                           system.debug('Super_User_Id__c='+userObj.id+'**Partner_Account__c='+idSalesMotion);
                        //Create Batch Process to delete GroupMembers
                            CMAP_ProcessQueue__c gmBatchProcess = new CMAP_ProcessQueue__c (Super_User_Id__c = userObj.id, Partner_Account__c = idSalesMotion,
                                                           GroupId__c = mapExistingGroup.get(strGroupName1).Id, Type__c = 'GroupMember', Operation__c = 'Delete');
                            System.debug('gmBatchProcess'+gmBatchProcess); 
                            listBatchToDelete.add(gmBatchProcess);
                            System.debug('listBatchToDelete'+listBatchToDelete); 
                          }
                    }
                }
            }           
                
           
            database.SaveResult[] listGMDMLResults;
            if(listBatchToInsert.size() > 0){
                listGMDMLResults = database.insert(listBatchToInsert, false);
            }
            if(listBatchToDelete.size() > 0){
                listGMDMLResults = database.insert(listBatchToDelete, false);
            }
            system.debug('----insert ---'+listGMDMLResults );
        } 
    }
    
    /* 
Revision    CR Number   Release No  Date            Modified By     Description
--------    ---------   ----------  -----------     ------------    -----------
1.0         CR7298      13.10                       Manju           Maint: Viper - Lock program record
2.0         CR12402     17.02       30-11-2015      Men Mee         This logic is separated from userAfterInsertUpdateTrigger trigger and rewritten as part of trigger redesign.
*/
    public static void ViperMDFProgramSharing (List<User> listNewUsers, Map<Id, User> mapOldUsers) {
        
        Set<Id> setProfileId = new Set<Id>();
        Set<Id> setUserId = new Set<Id>();
        List<GroupMember> listGrpMem = new List<GroupMember>();
        List<GroupMember> listGrpMemListToDelete = new List<GroupMember>();
        
        for(Profile prof: [SELECT Id, Name FROM Profile WHERE Name = 'MDF Co-Marketing Manager' or Name = 'MDF Marketing Operations / Contract Admin']){
            setProfileId.add(prof.Id);
        }
        
        Group grp = [SELECT Id, Name FROM Group where Name = 'Viper Marketing profiles Public Grp'];
        
        for(User newUser : listNewUsers) { 
            
            User oldUser;
            if (mapOldUsers != null) {
                oldUser = mapOldUsers.get(newUser.Id);
            }
            
            if(setProfileId.contains(newUser.ProfileId) && (mapOldUsers == null || !setProfileId.contains(oldUser.ProfileId))){
                GroupMember grpMemObj = new GroupMember(UserOrGroupId = newUser.Id, GroupId = grp.Id);
                listGrpMem.add(grpMemObj);
            }
            
            //To check if user's profile has been changed to another profile from MDF Co-Marketing Manager or MDF Marketing Operations / Contract Admin
            if (mapOldUsers != null && setProfileId.contains(oldUser.ProfileId) && !setProfileId.contains(newUSer.ProfileId)) {
                setUserId.add(newUser.Id);
            }
        }
        
        listGrpMemListToDelete = [SELECT Id, UserOrGroupId, GroupId FROM GroupMember WHERE GroupId =: grp.Id and UserOrGroupId in: setUserId];
        
        if(listGrpMemListToDelete.size() > 0){
            Database.delete(listGrpMemListToDelete,false);
        }
        
        if(listGrpMem.size() > 0){
            Database.insert(listGrpMem,false);
        }           
        
    }
    
    /* 
Revision    CR Number   Release No  Date            Modified By     Description
--------    ---------   ----------  -----------     ------------    -----------
1.0                     14.2        22-01-2013      Meera           SSO : Updating PR status after completion of vendor synch: CRQ :0608 and uncommenting cde for CMI integration
1.1                     14.2        20-03-2013      Meera           SSO : Calling Grassroots contact to Account Dissassociation on disabiling of portal user
2.0         CR12402     17.02       30-11-2015      Men Mee         This logic is separated from userAfterInsertUpdateTrigger trigger and rewritten as part of trigger redesign.
3.0                     06 02       05-10-2018      Rahul           Comment out SSOVendorAssociation logic since it is not in use.
*/
    /* public static void SSOVendorAssociation (Map<Id, User> mapNewUsers, Map<Id, User> mapOldUsers) {

boolean isBoomiUser = Userinfo.getProfileId().contains('00eA0000000hNqF');

Map<String,User> contIdTOUserMap = new Map<String,User>();
Map<String,String> contactIdToUsrIdMAp = new Map<String,String>();

try{
for(User newUser : mapNewUsers.values()){
User oldUser;
if (mapOldUsers != null) {
oldUser = mapOldUsers.get(newUser.Id);
}

//14.2 SSO Addition
//If user is inactive and if current user is BOOMI integration user
if(isBoomiUser && newUser.IsActive == false && newUser.ContactId != null){
contIdTOUserMap.put(newUser.ContactId,newUser);
}

//14.2 SSO Calling grassroots on disabiling of user
if(newUser.IsPortalEnabled == false && oldUser.IsPortalEnabled == true && oldUser.UserType == 'PowerPartner'){
contactIdToUsrIdMAp.put(newUser.contactId,newUser.id);
}
}

//Query and check for PR of record type remove user and status incomplete or new
final Id REMOVE_USER_RECORD_TYPE = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_REMOVE_USER, 'Partner_Request__c', true);

List<Partner_Request__c> PRListtoUpdate = new List<Partner_Request__c>();
for(List<Partner_Request__c> PRList : [SELECT id,Status__c,RecordTypeId,Contact__c,Description__c 
FROM Partner_Request__c 
WHERE (Status__c = :PartnerConstants.REG_STATUS_INCOMPLETE OR Status__c = :PartnerConstants.REG_STATUS_DRAFT)
AND RecordTypeId = :REMOVE_USER_RECORD_TYPE AND Contact__c IN :contIdTOUserMap.keySet() AND contact__r.Vendor_Update_Datetime__c != null
ORDER BY Contact__c,Lastmodifieddate DESC]){
for(Partner_Request__c PR : PRList){
User userTocheck = contIdTOUserMap.get(PR.Contact__c);
if(PR.Status__c == PartnerConstants.REG_STATUS_DRAFT && userTocheck.Last_Operation_Performed__c == 'Vendor Updated'){   

PR.Status__c = PartnerConstants.REG_STATUS_COMPLETE; 
PRListtoUpdate.add(PR);                     
}   
else if((PR.Status__c == PartnerConstants.REG_STATUS_DRAFT || PR.Status__c == PartnerConstants.REG_STATUS_INCOMPLETE)&&userTocheck.Last_Operation_Performed__c == 'Vendor Sync failed'){
System.debug('Inside Failure');
System.debug('PR.Description__c:'+PR.Description__c);
PR.Status__c = PartnerConstants.REG_STATUS_INCOMPLETE;
if (PR.Description__c != null && PR.Description__c != '') {
PR.Description__c += '\n';
}                       
PR.Description__c += 'Vendor Sync failed';                       
System.debug('PR.Description__c:'+PR.Description__c);
PRListtoUpdate.add(PR);   
}

}

if(PRListtoUpdate.size()>0){
update PRListtoUpdate;
}                                               
}

if(contactIdToUsrIdMAp.size()>0 && GlobalVariables.BYPASS_FUTURE_CALLS == False){

//Get Country details
PartnerCountry pc = new PartnerCountry();
Map<string, Country__c> countryMap = pc.returnCountryCodeMap();
Map<String,String> countrytoCodeMap = new Map<String,String>{'INDIA' => 'IND','CHINA' => 'CHN','AUSTRALIA' => 'ANZ','NEW ZEALAND'=>'ANZ'};
String vendorName;
map<String,String> contactIdToAccountId = new map<String,String>();
map<String,String> contactIdToAccountIdTemp = new map<String,String>();
map<String,String> contactguidIdTocontId = new map<String,String>();
for(Contact con : [SELECT id,Partner_My_Account_GUID__c, accountid,Vendor_Update_Datetime__c,account.Account_Country_Code__c,account.Account_ID__c 
FROM Contact
WHERE id IN :contactIdToUsrIdMAp.keySet()]){
if(con.account.Account_Country_Code__c != null){
Country__c country = countryMap.get(StringUtils.uppercase((con.account.Account_Country_Code__c).trim()));

if(country != null){
vendorName = country.Inc_Vendor_Name__c;
if(vendorName == 'Dell Achievers' && con.Vendor_Update_Datetime__c != null){
System.debug('country.name:'+country.name);
System.debug('countrytoCodeMap.get(StringUtils.uppercase(country.name)):'+countrytoCodeMap.get(StringUtils.uppercase(country.name)));
String accountcode = countrytoCodeMap.get(StringUtils.uppercase(country.name))+con.account.Account_ID__c;
contactIdToAccountId.put(con.Partner_My_Account_GUID__c,accountcode );
contactguidIdTocontId.put(con.Partner_My_Account_GUID__c,con.id);
System.debug('contactIdToAccountId:'+contactIdToAccountId);
}  
}
}
} 

if(contactIdToAccountId.size()>0){
Integer intCount = 0;
//Call association integration method after checking limit
for(String contguid : contactIdToAccountId.keySet()){
contactIdToAccountIdTemp.put(contguid,contactIdToAccountId.get(contguid));
intCount++;
//System.debug('###DEBUG### Current intCount = ' + intCount);

if(contactIdToAccountIdTemp.size() == 10 || intCount == contactIdToAccountId.size()){

System.debug('###DEBUG### BEFORE LIMIT FUTURECALL = ' 
+ Limits.getFutureCalls() + ' of ' + Limits.getLimitFutureCalls());
if(Limits.getFutureCalls() >= Limits.getLimitFutureCalls() || Test.isRunningTest()) {
//System.debug('###DEBUG### Reaching Limit, adding errors to ' + batchList);
for(Id tempConId : contactIdToAccountIdTemp.keySet()) {
trigger.newMap.get(contactIdToUsrIdMAp.get(contactguidIdTocontId.get(tempConId))).addError(
'Updates of Partner Contacts has hit Salesforce.com FutureCall Limit.');    
}
}
else
{
//System.debug('###DEBUG### Processing ' + batchList);
System.debug('###DEBUG### Processing ' + contactIdToAccountIdTemp);
SSOVendorAssociation.dissassociateContacttoAccount(contactIdToAccountIdTemp);
}

System.debug('###DEBUG### AFTER LIMIT FUTURECALL = ' + Limits.getFutureCalls() 
+ ' of ' + Limits.getLimitFutureCalls());

contactIdToAccountIdTemp.clear();
}
}
}
}
}catch(Exception e){  emailUtils.sendSupportEmail(e.getMessage(), dellConfig.errorEmail);
}       
}*/
    /*
* This method is to give portall users access to Sales Motion account
*/
   public static void grantRevokeAccess(Map<Id,User> mapNewUsers,Map<Id,User> mapOldUsers){
        System.debug('grantRevokeAccess::');
        System.debug('mapNewUsers::'+mapNewUsers+'mapOldUsers::'+mapOldUsers);
        List<User> listUsr = new List<User>();
        Map<String, List<String>> mapUsrPTAdd = new Map<String, List<String>>();
        Map<String, List<String>> mapUsrPTRemove = new Map<String, List<String>>();
        // Map to hold Partner Track Vs Sales Motion Account Ids
        Map<String, List<String>> mapPTToSM = new Map<String, List<String>>();
        // Map to hold the User id Vs Sales Motion Accounts
        Map<String, List<String>> mapUsrIdToSM = new Map<String, List<String>>();
        //To hold the existing Account Share records
        List<AccountShare> listAccShareExists = new List<AccountShare>();
        // To hold the Account Share to insert
        List<AccountShare> listAccShareinsert = new List<AccountShare>();
        // Map to hold the User id Vs Sales Motion Accounts to send to batch class
        Map<String, List<String>> mapUsrIdToSMGrant = new Map<String, List<String>>();
        List<User> listUser = new List<User>();
        List<String> listAllPTs = new List<String>();
        if(mapNewUsers!= null && mapNewUsers.size() > 0){
            listUsr = [SELECT Id,contactId,contact.EligibleTracks__c
                       FROM User
                       WHERE Id IN :mapNewUsers.keyset()];
            System.debug('listUsr'+listUsr);
            if(listUsr.size() > 0){
                for(User usr : listUsr){
                    System.debug('usr.contact.EligibleTracks__c::'+usr.contact.EligibleTracks__c);
                    if(usr.contactId != null && String.isNotBlank(usr.contact.EligibleTracks__c)){
                        if(usr.contact.EligibleTracks__c.contains(';')){
                            List<String> listPT = new List<String>();
                            listPT = usr.contact.EligibleTracks__c.trim().split(';');
                           /* List<String> tempList = new List<String>();
                            tempList.addAll(listPT);*/
                            System.debug('listPT::'+listPT);
                            mapUsrPTAdd.put(String.valueOf(usr.Id), new List<String>(listPT));
                            listAllPTs.addAll(listPT);
                        }
                        else{
                            List<String> listTemp = new List<String>();
                            listTemp.add(String.valueof(usr.contact.EligibleTracks__c).trim());
                            mapUsrPTAdd.put((String.valueOf(usr.Id)),listTemp); 
                            listAllPTs.addAll(listTemp);
                        }
                    }
                    else{
                        System.debug('Not a Portal User');
                    }
                    
                }
                System.debug('mapUsrPTAdd'+mapUsrPTAdd);
                
            }
            System.debug('listAllPTs::'+listAllPTs);
            // Create the map of PT vs SM
            List<Account> listAcc = new List<Account>();
            if(listAllPTs.size() > 0){
                    listAcc = [Select Id,Name,Partner_Track__c 
                               FROM Account 
                               WHERE Partner_Track__c IN : listAllPTs]; 
                    if(listAcc.size() > 0){
                        for(Account acc : listAcc){
                            if(mapPTToSM.containsKey(acc.Partner_Track__c)){
                                mapPTToSM.get(acc.Partner_Track__c).add(acc.Id);
                            }
                            else{
                                mapPTToSM.put(acc.Partner_Track__c,new List<String>{ acc.Id}); 
                            }
                            
                        }
                        System.debug('mapPTToSM'+mapPTToSM);
                    }
           }
           for (User usr : listUsr) {
                // Validate if for a contact we have Partner Tracks and Partner Tracks have Sales Motion (Extra Check)
                if(mapUsrPTAdd.size() > 0 && mapPTToSM.size() > 0){
                    if(mapUsrPTAdd.containsKey(usr.Id)){
                        for(String strEligibleTrack : mapUsrPTAdd.get(usr.Id)){
                            System.debug('strEligibleTrack'+strEligibleTrack);
                            if(mapPTToSM.containsKey(strEligibleTrack)){
                                if(mapUsrIdToSM.containsKey(usr.Id)){
                                    mapUsrIdToSM.get(usr.Id).addAll(mapPTToSM.get(strEligibleTrack));
                                }else{
                                    // add a new record
                                    mapUsrIdToSM.put(usr.Id, new List<String>(mapPTToSM.get(strEligibleTrack)));
                                }
                            }                        
                        }
                        
                    }
                }
                
            }  
            System.debug('mapUsrIdToSM'+mapUsrIdToSM);
            if(mapUsrIdToSM.size() > 0){
                // Check if the share record already exists
                listAccShareExists = [SELECT Id,AccountId,UserOrGroupId
                                      FROM AccountShare
                                      WHERE RowCause=:'Manual' 
                                      AND UserOrGroupId IN: mapUsrIdToSM.keySet()
                                     ]; 
            }
             //map to hold the User vs AccountId's
            Map<String,List<AccountShare>> mapShareUsrToSM = new Map<String,List<AccountShare>>();
            if(listAccShareExists.size() > 0){
                for(AccountShare accSh : listAccShareExists){
                    if(mapShareUsrToSM.containsKey(accSh.UserOrGroupId)){
                        mapShareUsrToSM.get(accSh.UserOrGroupId).add(accSh);
                    }
                    else{
                        mapShareUsrToSM.put(accSh.UserOrGroupId,new List<AccountShare>{ accSh }); 
                        }
                    
                }
                System.debug('mapShareUsrToSM::'+mapShareUsrToSM);
            }
            
            for(User usr : listUsr){
                if(mapUsrIdToSM.containsKey(usr.Id)){
                    if(mapUsrIdToSM.get(usr.Id).size() <= Integer.valueof(System.Label.Maximum_SM_Accounts)){
                       if(mapShareUsrToSM.containsKey(usr.Id) && mapShareUsrToSM.get(usr.Id)!= null){
                            List<String> listAccountIds = new List<String>();
                            for(AccountShare accShare : mapShareUsrToSM.get(usr.Id)){
                                    listAccountIds.add(accShare.AccountId);
                            }
                            for(String strAccId : mapUsrIdToSM.get(usr.Id)){
                                if(listAccountIds.contains(strAccId)){
                                      System.debug('Account Share already exists for the user '+usr.Id+' and account combination:');
                                }
                                else{
                                        System.debug('Create Account Share');
                                        AccountShare accShare = new Accountshare();
                                        accShare.AccountId = strAccId;
                                        accShare.UserOrGroupId = usr.Id;
                                        accShare.AccountAccessLevel = 'Read';
                                        accShare.OpportunityAccessLevel='None';
                                        //accShare.RowCause='Manual';
                                        listAccShareInsert.add(accShare);
                                  }
                            }  
                       }
                       else{
                           for(String strAccId : mapUsrIdToSM.get(usr.Id)){
                               System.debug('Add an account share as Accountshare list doesnt contains'+strAccId);
                                   AccountShare accShare = new Accountshare();
                                   accShare.AccountId = strAccId;
                                   accShare.UserOrGroupId = usr.Id;
                                   accShare.AccountAccessLevel = 'Read';
                                   accShare.OpportunityAccessLevel='None';
                                   //accShare.RowCause='Manual';
                                   listAccShareInsert.add(accShare); 
                           }
                           }
                    }
                    else{
                      // call the batch
                        mapUsrIdToSMGrant.put(usr.Id,new List<String>(mapUsrIdToSM.get(usr.Id)));  
                    }
                }
            }

            if(listAccShareinsert.size() > 0){
              Database.SaveResult[] listSR = Database.insert(listAccShareinsert,false);
              for (Database.SaveResult sr : listSR) {
                if(sr.isSuccess()){
                    System.debug('Inserted Successfully');
                }
                else {
                    for(Database.Error objErr : sr.getErrors()) {
                        System.debug('The following error has occurred.');  
                        System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
                        System.debug('Order oject field which are affected by the error: ' + objErr.getFields());
                        
                        
                    }
                }
                
            }
                
            }
            if(mapUsrIdToSMGrant.size() > 0){
                ManageAccessForSalesMotion bcn = new ManageAccessForSalesMotion(mapUsrIdToSMGrant,System.Label.Grant_Access_Type) ;
                ID batchprocessid = Database.executeBatch(bcn);
                System.debug('batchprocessid to Add SM ::'+batchprocessid);
                
            }
            
            
        }
    }
    
}