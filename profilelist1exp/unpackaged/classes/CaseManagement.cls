/*
 * Revision CR Number   Release No  Date            Modified By         Description
 * -------- ---------   ----------  -----------     ------------        -----------
 * 1.0      CR 7478     13.10       29-Aug-2012     Hilary Glenn Huele  For Case Management
 * 2.0      CR 7913     14.2        18-Jan-2013     Anupama Pradeep     For Case Management LINES 57 TO 67, 138 TO 160
 * 3.0      CR 8201     14.5        10-Apr-2013     Krishnamoorthi      Maintenance  -- comment out some lines   
 * 4.0                  15.3        16-JAN-2013     Rakesh Muppiri      NPS -- Added one more if condition at line # 325  
 * 4.0                  15.3        20-FEB-2014     Rakesh Muppiri      NPS -- Added one more if condition at line #342 for fixing defect 96714both
 * 4.0                  15.3        11-MAR-2014     Rakesh Muppiri      NPS -- Added 3 more if condition at line #215
 * 4.0                  15.3        11-MAR-2014     Rakesh Muppiri      NPS -- Added 3 more if condition at line #195  defect #98451
 * 5.0                  15.07       23-APR-2014     Annie Koshy         FR 5.6 For LATAM, Assign the case to Account owner
 * 6.0      CR 9391     15.07       16-JUN-2014     Rakesh Muppiri      CMAP - CRQ 0931 Allow Case Owners to update the Case status regardless of the Case Type, commneted out lines of code #341 to #346
 * 7.0      CR 10753    16.03       22-Dec-2014     Ragu                Changes to EMEA Lead Management Case Ownership (Commented the code which assigns EMEA LM Case to Account Owner)
 * 8.0      CR 10751    16.03       02-Jan-2015     Ragu                Created for implementing "Centralized by Org" trigger architecture - Best practices
 * 9.0      CR 11999    16.10       29-Sep-2015     Dipin Raju          Added logic to exclude Global Lead Management Intake cases from various validation checks that are not required for this RT
 * 9.1      CR 11999    16.10       30-Sep-2015     Dipin Raju          Added logic to auto populate Lead Name from Lead ID and Original Requestor from Created BY for Global LM Intake cases
 *10.0      CR 14384    0602        24-May-2017     Srikanth.B          Skip the alternate phone mandatory check for order support & skip the validation to check case manager is associated with acct
 *11.0      CR 14696    1001        1-Aug-2017      Jaisimha R          Skip the alternate phone mandatory check for Deal Registration & skip the validation to check case manager is associated with acct 
 *11.1                  1101        15-Sep-2017     Naresh B            Skip the alternate phone mandatory check for On Boarding & skip the validation to check case manager is associated with acct
 *11.2                  1101        26-March-2018   Rahul Mishra        Fixed the issue which throws the error message when Account and COntact are null on case update
*11.3                   1001        9-Aug-2019      Meenu and Subha     Added CSH recordtypes and bypassed mandatory contactID validation for CSH Internal Cases
*11.4                   1002        28-Aug -2019    Hari A              Added Condtion for CSH types to fix the defect 7238638
 */     

public class CaseManagement {

    public static void validateAndPopulateFields(list<Case> lstNewCases, map<Id, Case> mapOldCases, map<Id, Account> mapRelatedAccounts) {
        set<Id> setAccountIds = new set<Id>();
        set<String> setCountryNames = new set<String>();
        map<Id, Case> mapCases = new map <Id, Case>();
        
        String CaseRTMigrate_strRTIds = CaseManagement.CaseRTMigrate_getRTIDs();//V12
        // v3.0 - Start
        /*
        set<Id> setQueue_Ids = new set<Id>();
        list<GroupMember> lstQueueMembersDtls = new list<GroupMember>();
        list<Group> lstGrpDetials = new list<Group>();
        map<Id, GroupMember> mapGrpMemDetails = new map<Id, GroupMember>();
        map<Id, Group> mapGrpDetials = new map<Id, Group>();
        */
        // v3.0 - End
        
        // v7.0 - Start
        /*
        // v5.0 Code Start
        Map<Id, Account> AccMap; // = new Map<Id, Account>();
        Id caseRTId = IdLookupUtils.getRecordTypeId(Partner Lead Management, 'Case', true);
        set<Id> AccIdSet=new set<Id>();
        // v5.0 Code End
        */
        // v7.0 - End
        
//v9.1 : Start - To auto populate Lead Name from Lead ID and Original Requestor from Created BY for Global LM Intake cases
        Id GLMIntake_CaseRTId = StaticFactory.getRecordTypeIdByName('Case', 'Global Lead Management Intake'); 
        List<Lead> LeadList = new List<Lead>();
//v9.1 : End - To auto populate Lead Name from Lead ID and Original Requestor from Created BY for Global LM Intake cases
        
        for(Case newCase : lstNewCases) {
            if(!CaseRTMigrate_strRTIds.contains(newCase.RecordTypeId)) {//12.0
                mapCases.put(newCase.Id, newCase);
                
                if(newCase.AccountId != null) {
                    setAccountIds.add(newCase.AccountId);
                }
                else if(newCase.Country_Area__c != null) {
                    // v2.0
                    setCountryNames.add(newCase.Country_Area__c);
                }
                else if(newCase.SuppliedEmail == null) {
                    newCase.Region__c = 'NA';
                }
                
                // v2.0
                if(newCase.Case_Category__c == 'Internal') {
                    newCase.IsVisibleInSelfService = false;
                }
                // v2.0
                
    //v9.1 : Start - To auto populate Lead Name from Lead ID and Original Requestor from Created BY for Global LM Intake cases 
                if(newCase.RecordTypeId == GLMIntake_CaseRTId && newCase.Original_Requestor__c == null) {
                    newCase.Original_Requestor__c = newCase.CreatedById;
                }  
                if(newCase.RecordTypeId == GLMIntake_CaseRTId && newCase.Lead_ID__c != null) {
                    LeadList =[Select Id from Lead where Id=:newCase.Lead_ID__c];
                    If(LeadList.Size()==0){
                        newCase.addError('Please enter a valid Lead ID');
                    }
                    else {
                        newCase.Lead_Name__c = newCase.Lead_ID__c;
                    }
                }
    //v9.1 : End - To auto populate Lead Name from Lead ID and Original Requestor from Created BY for Global LM Intake cases 
    
                // v2.0
                // v3.0 - Start
                /*
                if(newCase.Queue_id__c != null) {
                    setQueue_Ids.add(newCase.Queue_id__c);
                }
                */
                // v3.0 - End
                
                // v7.0 - Start
                /*
                //Ver 5.0 Code Start
                if(newCase.AccountId != null  && newCase.RecordTypeId == caseRTId && newCase.Region__c == 'EMEA'){
                    AccIdSet.add(newCase.AccountId);
                }
                //Ver 5.0 Code End
                */
                // v7.0 - End
            }
        }
        
        // v7.0 - Start
        /*
        // v5.0 Code Start
        if(AccIdSet.Size() > 0) {
            AccMap = new Map<Id, Account>([Select Id,OwnerId from Account where Id IN :AccIdSet]);
        }

        for(Id caseId : mapCases.KeySet()) {
            case newCase = mapCases.get(caseId);
            if(trigger.isUpdate && newCase.RecordTypeId == caseRTId && newCase.OwnerId == '00GA0000001IHzE' && newCase.Region__c == 'EMEA'){
                newCase.OwnerId = AccMap.get(newCase.AccountId).OwnerId;            
                System.Debug('@@Region: '+newCase.Region__c);         
                System.Debug('@@AccOwner: '+newCase.OwnerId);
            }
        }
        //Ver 5.0 Code End
        */
        // v7.0 - End
        
        // v3.0 - Start
        /*
        if(setQueue_Ids != null && setQueue_Ids.size() > 0) {
            lstQueueMembersDtls = [select GroupId, UserOrGroupId from GroupMember where GroupId in: setQueue_Ids];   
        }
        if(lstQueueMembersDtls != null && lstQueueMembersDtls.size() > 0) {
            for(GroupMember qm : lstQueueMembersDtls) {
                mapGrpMemDetails.put(qm.UserOrGroupId, qm);
            }
        }
        
        lstGrpDetials = [select id, Type from Group where Type = 'Queue'];
        if(lstGrpDetials != null && lstGrpDetials.size() > 0) {
            for(Group grp : lstGrpDetials) {
                mapGrpDetials.put(grp.Id, grp);
            }
        }
        */
        // v3.0 - End
        
        Integer iATCount = [select count() from AccountTeamMember where UserId = :UserInfo.getUserId() and TeamMemberRole = 'Account Executive' limit 1];
        
        set<Id> setATMAccIds =  new set<Id>();
        if(!setAccountIds.isEmpty()) {
            if(iATCount > 0 ) {
                for(AccountTeamMember atmIterator : [select Id, AccountId from AccountTeamMember where AccountId in :setAccountIds and UserId = :UserInfo.getUserId() and TeamMemberRole = 'Account Executive']) {
                    setATMAccIds.add(atmIterator.AccountId);
                }
            }
            
            for(Id AccountId : setAccountIds) {
                // v2.0
                Account relatedAccount = mapRelatedAccounts.get(AccountId);
                setCountryNames.add(relatedAccount.Account_Country__c);
                system.debug('CountryNames :'+setCountryNames); //SWK
            }
        }
        
        if(!setCountryNames.isEmpty()) {
            map<String, String> mapCountryNameRegion = new map<String, String>();
            for(Country__c country : [select Id, Region__c, Code__c, Name from Country__c where Name in :setCountryNames]) {
                mapCountryNameRegion.put(country.Name, country.Region__c);
                system.debug('CountryNameRegion -->'+mapCountryNameRegion); //SWK
            }
            
            for(Id caseId : mapCases.keySet()) {
                Case newCase = mapCases.get(caseId);
                
                if(newCase.AccountId == null && newCase.SuppliedEmail == null) {
                    newCase.Region__c = mapCountryNameRegion.get(newCase.Country_Area__c);
                }
                else if(!setAccountIds.isEmpty()) {
                    Account relatedAccount = mapRelatedAccounts.get(newCase.AccountId);
                    system.debug('relatedAccount -->'+ relatedAccount); //SWK
                    if(relatedAccount != null) {
                        // v2.0
                        newCase.Region__c = mapCountryNameRegion.get(relatedAccount.Account_Country__c);
                        system.debug('Region__c -->'+newCase.Region__c); //SWK
                    }
                }
            }
        }
        
        // Check Phone and MobilePhone in Contact
        Boolean bCurrentUserDontHaveContactInfo = false;
        set<String> setUsersWithoutContactInfo = new set<String>();
        if(UserInfo.getUserType() == 'PowerPartner' || Test.isRunningTest()) {
            User currentUser = StaticFactory.getCurrentUserDetails();
            if(currentUser.ContactId == null || (currentUser.Contact.Phone == null && currentUser.Contact.MobilePhone == null)) {
                bCurrentUserDontHaveContactInfo = true;
            }
        }
        
                
                
  //v9.0: Start                     
        Id GLM_CaseRTId = StaticFactory.getRecordTypeIdByName('Case', 'Global Lead Management Intake');
        Id orderSupportRTId = StaticFactory.getRecordTypeIdByName('Case', 'Order Support');  // To get Order Support Record type
        Id dealRegRTId = StaticFactory.getRecordTypeIdByName('Case', 'Deal Registration'); //To get Deal Registration record type(1st Aug '17)
        Id OnBoardRTId=StaticFactory.getRecordTypeIdByName('Case', 'On Boarding');////To get On Boarding record type
        Id OnBoardInternalRTId=StaticFactory.getRecordTypeIdByName('Case', 'On Boarding Internal');////To get On Boarding record type
        Id dealRegInternalRTId = StaticFactory.getRecordTypeIdByName('Case', 'Deal Registration - Internal only case types'); //To get Deal Registration Internal record type
        Id DistributionRTId = StaticFactory.getRecordTypeIdByName('Case', 'Distribution'); //To get Distribution record type
        Id PDPRTId = StaticFactory.getRecordTypeIdByName('Case', 'Application Support'); //To get Application Support record type
        Id ASIRTId = StaticFactory.getRecordTypeIdByName('Case', 'Application Support - Internal only case types');//To get Application Suppor - Internal only case type record type
        Id PPRTId = StaticFactory.getRecordTypeIdByName('Case', 'Partner Program');//To get Partner Program record type
        //Added CSH Recordtypes Story : 6757068
        Id idCshRec = StaticFactory.getRecordTypeIdByName('Case', 'Channel Services Helpdesk');//To get CSH record type
        Id idCshIntRec = StaticFactory.getRecordTypeIdByName('Case', 'Channel Services Helpdesk (internal only)');//To get CSH Internal record type
		
  //v9.0: End
        for(Case newCase : lstNewCases) {
            if(!CaseRTMigrate_strRTIds.contains(newCase.RecordTypeId)) {//12.0
                if(UserInfo.getUserType() == 'PowerPartner') {
                     newCase.Sub_Type_Internal_User__c = newCase.Sub_Type_Partner_User__c; 
                }
                else{
                  newCase.Sub_Type_Partner_User__c = newCase.Sub_Type_Internal_User__c;
                }
                //V10 start exclude check for order support
                if(UserInfo.getUserType() == 'PowerPartner' && newCase.Alternate_Phone__c == null && bCurrentUserDontHaveContactInfo && newCase.SuppliedEmail == null 
                    && newCase.NPS_Category__c != 'Detractor' && newCase.NPS_Category__c != 'Promoter' && newCase.NPS_Category__c != 'Passive' && newCase.RecordTypeID != GLM_CaseRTId  && newCase.RecordTypeID != orderSupportRTId && newCase.RecordTypeID != dealRegRTId && newCase.RecordTypeID != OnBoardRTId && newCase.RecordTypeID != OnBoardInternalRTId && newCase.RecordTypeID != dealRegInternalRTId && newCase.RecordTypeID != DistributionRTId && newCase.RecordTypeID != PDPRTId && newCase.RecordTypeID != ASIRTId && newCase.RecordTypeID != PPRTId) { // CR7913  Jan 30 newCase.IsWebtoCase__c != 'true') //// Excluding Order Support Record Type from Phone Validation 
                    newCase.Alternate_Phone__c.addError('Please provide a contact number');
                }
                //V10 end
                
                if(mapOldCases == null || Test.isRunningTest()) {
    
                    if(iATCount > 0 && newCase.SuppliedEmail == null) { // CR7913 Jan30 DP newCase.IsWebtoCase__c != 'true')
                        if(newCase.AccountId == null || newCase.ContactId == null || Test.isRunningTest()) {
                            //newCase.addError('As an account executive you are required to fill in the contact and account details of the partner user for whom you are creating this case');
                        }
    //v9.0 Start: Exclude   Global Lead Management Intake cases from this check  //V10 Start exclude order support   // V11 Start exclude Deal Registration            
                        if(!Test.isRunningTest() && newCase.AccountId != null && newCase.ContactId != null && !setATMAccIds.contains(newCase.AccountId) && newCase.RecordTypeID != GLM_CaseRTId && newCase.RecordTypeID != orderSupportRTId && newCase.RecordTypeID != dealRegRTId && newCase.RecordTypeID != OnBoardRTId && newCase.RecordTypeID != OnBoardInternalRTId && newCase.RecordTypeID != dealRegInternalRTId && newCase.RecordTypeID != DistributionRTId && newCase.RecordTypeID != PDPRTId && newCase.RecordTypeID != ASIRTId && newCase.RecordTypeID != PPRTId && newCase.RecordTypeID != idCshRec && newCase.RecordTypeID != idCshIntRec) { // && newCase.RecordTypeID != CaseRT_Partner_Inquiry_Id (Added Deal Registration Record Type - 1st Aug '17)
    //v9.0 End: Exclude Global Lead Management Intake cases from this check  //V10 End                       
                            newCase.addError('You are not associated to this Account. Please enter the Account that you are associated.');
                        }
                    }
                    
                    if(iATCount == 0 || Test.isRunningTest()) {
                        if(newCase.Accountid == null && newCase.ContactId == null) {
                            
                        }
    //v9.0 Start: Exclude   Global Lead Management Intake cases from this check   
    //Added CSH Internal RecordType condition Story : 6757068
                        else if((newCase.AccountId == null || newCase.ContactId == null) && newCase.SuppliedEmail == null && UserInfo.getUserType() != 'PowerPartner' && newCase.NPS_Category__c != 'Detractor' && newCase.NPS_Category__c != 'Promoter' && newCase.NPS_Category__c != 'Passive' && newCase.RecordTypeId != GLM_CaseRTId && newCase.RecordTypeId != OnBoardInternalRTId && newCase.RecordTypeId != OnBoardRTId && newCase.RecordTypeId != dealRegInternalRTId && newCase.RecordTypeID != DistributionRTId && newCase.RecordTypeID != PDPRTId  && newCase.RecordTypeID != idCshIntRec && newCase.RecordTypeID != ASIRTId && newCase.RecordTypeID != PPRTId) { // && newCase.RecordTypeId != CaseRT_Partner_Inquiry_Id
    //v9.0 End: Exclude   Global Lead Management Intake cases from this check                     
                            // v2.0: Added check && newCase.SuppliedEmail == null in the above else if part
                            // v4.0: Added check && newCase.NPS_Category__c !='Detractor' && newCase.NPS_Category__c !='Passive' && newCase.NPS_Category__c !='Promoter' in the above else if part
                           newCase.addError('Both Account and Contact field needs to filled. One of the field cannot be left blank. If you are creating the case for yourself then please leave both Account and Contact field empty');
                        }
                    }
                }
            }
        }
        
        
        if(mapOldCases != null) {
            set<Id> setUserIds = new set<Id>();
            set<Id> setQueueIds = new set<Id>();
            map<String, set<String>> mapGroupUsers = new map<String, set<String>>();
            Id npsRTId = StaticFactory.getRecordTypeIdByName('Case', 'NPS Cases'); // CMAP 15.10
            
            for(Case newCase : lstNewCases) {
                if(!CaseRTMigrate_strRTIds.contains(newCase.RecordTypeId)) {//12.0
                    Case oldCase = mapOldCases.get(newCase.Id);
                    system.debug('New Case Status is'+newCase.Status);
                    system.debug('Old Case Status is'+oldCase.Status);
                    if(newCase.Status != oldCase.Status || Test.isRunningTest()) {
                        String strOwnerId = oldCase.OwnerId;
                        if(strOwnerId.startsWith('005')) {
                            setUserIds.add(strOwnerId);
                            system.debug('setUserIds is'+setUserIds);
                        }
                        else if(strOwnerId.startsWith('00G')) {
                            setQueueIds.add(strOwnerId);
                            system.debug('setQueueIds is'+setQueueIds);
                        }
                    }
                }
            }
            
            if(!setUserIds.isEmpty()) {
                set<Id> setGroupIds = new set<Id>();
                for(GroupMember grpMember : [select Id, GroupId, UserOrGroupId from GroupMember where UserOrGroupId in :setUserIds]) {
                    setGroupIds.add(grpMember.GroupId);
                }
                for(Case newCase : lstNewCases) {
                    Case oldCase = mapOldCases.get(newCase.Id);
                    
                    if(setGroupIds.contains(oldCase.Queue_Id__c)) {
                        mapGroupUsers.put(oldCase.OwnerId, new set<String>{oldCase.OwnerId});
                    }
                }
            }
            
            if(!setQueueIds.isEmpty() || Test.isRunningTest()) {
                for(GroupMember grpMember : [select Id, GroupId, UserOrGroupId from GroupMember where GroupId in :setQueueIds order by GroupId]) {
                    system.debug('grpMember is'+grpMember);
                    system.debug('mapGroupUsers is'+mapGroupUsers);
                    if(mapGroupUsers.containsKey(grpMember.GroupId)) {
                        mapGroupUsers.get(grpMember.GroupId).add(grpMember.UserOrGroupId);
                    }
                    else {
                        mapGroupUsers.put(grpMember.GroupId, new set<String>{grpMember.UserOrGroupId});
                    }
                }
            }
            
            for(Case newCase : lstNewCases) {
                Case oldCase = mapOldCases.get(newCase.Id);
                
                // v3.0 Changes - Start
                /*
                if(newCase.OwnerId != trigger.oldMap.get(newCase.Id).OwnerId) {
                    Group queueDetails = mapGrpDetials.get(newCase.OwnerId);
                    GroupMember ownerQueuDetails = mapGrpMemDetails.get(newCase.OwnerId);
                    
                    if(queueDetails == null) {
                        if(ownerQueuDetails == null) {
                             newCase.addError('Please select a user who is a member of the the same queue or return the case to the queue');
                        }
                    }
                }
                */
                // v3.0 Changes - End
                
                set<String> setUsers;
                if(!mapGroupUsers.isEmpty()) {
                    setUsers = mapGroupUsers.get(newCase.OwnerId);
                }
                
                if(setUsers != null) {
                    if(oldCase.Status != newCase.Status && (newCase.Status == 'Working' || newCase.Status == 'Hold') && setUsers.contains(UserInfo.getUserId())) {
                        newCase.OwnerId = UserInfo.getUserId();
                    }
                    
                    if(iATCount > 0 && !setUsers.contains(UserInfo.getUserId()) && newCase.SuppliedEmail == null || Test.isRunningTest()) { // CR 30R7913 DP Jan newCase.IsWebtoCase__c != 'true')
                        if(newCase.AccountId == null || newCase.ContactId == null) {
                            //newCase.addError('As an account executive you are required to fill in the contact and account details of the partner user for whom you are creating this case');
                        }
                        //V110 start exclude check for Order support
                        if(!Test.isRunningTest() && newCase.AccountId != null && newCase.ContactId != null && !setATMAccIds.contains(newCase.AccountId) && newCase.RecordTypeId != npsRTId && newCase.RecordTypeID != orderSupportRTId && newCase.RecordTypeID != dealRegRTId && newCase.RecordTypeID != OnBoardRTId && newCase.RecordTypeID != OnBoardInternalRTId && newCase.RecordTypeID != dealRegInternalRTId  && newCase.RecordTypeID != DistributionRTId && newCase.RecordTypeID != PDPRTId && newCase.RecordTypeID != ASIRTId && newCase.RecordTypeID != PPRTId && newCase.RecordTypeID != idCshRec && newCase.RecordTypeID != idCshIntRec ) { // && newCase.RecordTypeID != CaseRT_Partner_Inquiry_Id  
                            newCase.addError('You are not associated to this Account. Please enter the Account that you are associated.');
                        }//V10 end
                    }
                    
                    if(iATCount == 0 && !setUsers.contains(UserInfo.getUserId())) {
                        if(newCase.Accountid == null && newCase.ContactId == null) {
                            
                        }
//v9.0 Start: Exclude   Global Lead Management Intake cases from this check                         
                       else if((newCase.AccountId == null || newCase.ContactId == null) && UserInfo.getUserType() != 'PowerPartner' && newCase.SuppliedEmail == null && newCase.RecordTypeID != GLM_CaseRTId   && newCase.RecordTypeId != OnBoardInternalRTId && newCase.RecordTypeId != OnBoardRTId && newCase.RecordTypeId != dealRegInternalRTId && newCase.RecordTypeID != DistributionRTId && newCase.RecordTypeID != PDPRTId && newCase.RecordTypeID != ASIRTId && newCase.RecordTypeID != PPRTId) { // && newCase.RecordTypeId != CaseRT_Partner_Inquiry_Id
//v9.0 End: Exclude   Global Lead Management Intake cases from this check                         
                            // v2.0: Added check && newCase.SuppliedEmail == null in the above else if part
                            newCase.addError('Both Account and Contact field needs to filled. One of the field cannot be left blank. If you are creating the case for yourself then please leave both Account and Contact field empty');
                        }
                    }
                }
                
                // v6.0 - Start
                /*
                if(oldCase.Status != newCase.Status && !setUsers.contains(UserInfo.getUserId()) && oldCase.Status != 'Open' && newCase.Status != 'Escalated' && oldCase.RecordTypeId != npsRTId){
                    newCase.Status.addError('Changes cannot be made to Status field');
                }
                */
                // v6.0 - End
            }
        }
    }
    //12.0
    public Static String caseRTMigratestrRTIds ; 
    public static string caseRTMigrate_getRTIDs() {
       //String caseRTMigratestrRTIds = '';
       if(String.isBlank(caseRTMigratestrRTIds)){
           List<RecordType> caseRTMigratelstRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND NamespacePrefix =: Label.CaseRTMigrate_Namespace];
           List<Id> caseRTMigratelstRTIds = new List<Id>();
           for(RecordType caseRTMigrateobjRecordType : caseRTMigratelstRecordType) {
                caseRTMigratelstRTIds.add(caseRTMigrateobjRecordType.Id);
           }
       caseRTMigratestrRTIds = string.join(caseRTMigratelstRTIds,';'); 
       }
       
        return caseRTMigratestrRTIds;
    }

}