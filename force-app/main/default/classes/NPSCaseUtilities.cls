/*
 * Purpose  : Utility class to hold simple and reusable functionalities which are related to NPS Cases.
 *
 */

public with sharing class NPSCaseUtilities {

    /* 
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    1.0         CR 10637                                Mohammad Ghouse Create Case Team from Account Team.
    2.0         CR 10751    16.03       30-Dec-2014     Ragu            This logic is separated from AfterInsertCreateNPSCaseTrigger trigger and rewritten as part of trigger redesign.
    */
    public static void copyAccountTeamToCase(list<Case> lstCases) {
        Id npsRTId = StaticFactory.getRecordTypeIdByName('Case', 'NPS Cases'); 
        set<Id> setAccountIds = new set<Id>();
        for(Case newCase : lstCases) {
            if(newCase.RecordTypeId == npsRTId && newCase.AccountId != null) {
                setAccountIds.add(newCase.AccountId);              
            }
        }
            
        if(!setAccountIds.isEmpty()) {
            map<Id, list<AccountTeamMember>> mapAccIdTeamMembers = new map<Id, list<AccountTeamMember>>();
            for(AccountTeamMember accTeamMember : [select Id, AccountId, UserId from AccountTeamMember where AccountId in :setAccountIds AND User.IsActive = TRUE]) {
                if(mapAccIdTeamMembers.get(accTeamMember.AccountId) == null) {
                    mapAccIdTeamMembers.put(accTeamMember.AccountId, new list<AccountTeamMember>{accTeamMember});
                }
                else {
                    mapAccIdTeamMembers.get(accTeamMember.AccountId).add(accTeamMember);
                }
            }
            
            CaseTeamRole npsCaseTeamRole = [select Id from CaseTeamRole where Name = 'NPS Case Owners'];
            
            list<CaseTeamMember> lstCaseTeamMembers = new list<CaseTeamMember>();
            for(Case newCase : lstCases) {
                if(newCase.RecordTypeId == npsRTId && newCase.AccountId != null) {
                    list<AccountTeamMember> lstAccountTeamMembers = mapAccIdTeamMembers.get(newCase.AccountId);
                    if(lstAccountTeamMembers != null && !lstAccountTeamMembers.isEmpty()) {
                        for(AccountTeamMember accTeamMember : lstAccountTeamMembers) {
                            CaseTeamMember casTeamMember = new CaseTeamMember();
                            casTeamMember.ParentId = newCase.Id;
                            casTeamMember.MemberId = accTeamMember.UserId;
                            casTeamMember.TeamRoleId = npsCaseTeamRole.Id;
                            lstCaseTeamMembers.add(casTeamMember);
                      
                        }
                    }
                }
            }
            if(!lstCaseTeamMembers.isEmpty()) {
                insert lstCaseTeamMembers;
            }
        }
    }

    public static void populateOwnerIdForNPSCases(list<Case> lstNewCases) {
        Id defaultOwnerId;
        list<User> lstUsers = [select Id from User where Badge_Number__c = '879475'];
        if(lstUsers != null && !lstUsers.isEmpty()) {
            defaultOwnerId = lstUsers[0].Id;
        }
        
        list<Id> lstCaseIds = new list<Id>();
        list<String> lstBadgeIds = new list<String>();
        for(Case newCase : lstNewCases) {
            if(newCase.Owner_Id__c != null) {
                lstBadgeIds.add(newCase.Owner_Id__c);
            }
            lstCaseIds.add(newCase.Id);
        }
        
        // Fetching respective Owner Ids based on Badge Id from User Obj
        map<String, Id> mapUserBadgeNumberId = new map<String, Id>();
        if(!lstBadgeIds.isEmpty()) {
            for(User userIterator : [select Id, Badge_Number__c from User where Badge_Number__c in :lstBadgeIds And IsActive = true]) {
                mapUserBadgeNumberId.put(userIterator.Badge_Number__c, userIterator.Id);
            }
        }
        list<Case> lstCasesToUpdate = new list<Case>();
        for(Case caseIterator : [select Id, Owner_Id__c, OwnerId, RecordType.Name from Case where Id in: lstCaseIds and RecordType.Name = 'NPS Cases' and MaritzCX__Survey_Response_Id__c = null]) {
            Id ownerId = mapUserBadgeNumberId.get(caseIterator.Owner_Id__c);
            if(caseIterator.Owner_Id__c != null && ownerId != null) {
                caseIterator.OwnerId = ownerId;
            }
            else {
                caseIterator.OwnerId = defaultOwnerId;
            }
            lstCasesToUpdate.add(caseIterator);
        }
        if(!lstCasesToUpdate.isEmpty()) {
            update lstCasesToUpdate;
        }
    }

    /* 
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    1.0         CR 9025                 22-Jan-2014     Rakesh Muppiri      If any mathes found from NSS Category Ranges, it will Create task and the task will be assigned to respective owners from Cross functiona matrix.
    2.0         CR 10751    16.03       30-Dec-2014     Ragu                This logic is separated from AfterInsertCreateNPSCaseTrigger trigger and rewritten as part of trigger redesign.
    3.0         CR13222     0801        01-Jul-2016     Shue                Story 1557818:Update NPS case record categories and comments, new 5 categories
    */
    public static void createTaskForNPSCases(list<Case> lstNewCases) {
        // Fetching NSS Ranges and mapping with respective NSS category, used while created task based on rages matches from this range
        map<String, set<Integer>> mapCategoryNameRanges = new map<String, set<Integer>>();
        for(NSS_Category_Ranges__c nssCategory : [select Id, NSS_Category_Ranges__c, NSS_Category__r.Name from NSS_Category_Ranges__c order by NSS_Category__r.Name]) {
            set<Integer> setNSSRanges = new set<Integer>();
            String[] arrRanges = (nssCategory.NSS_Category_Ranges__c).split(';');
            for(String strRange : arrRanges) {
                setNSSRanges.add(Integer.valueOf(strRange));
            }
            mapCategoryNameRanges.put(nssCategory.NSS_Category__r.Name, new set<Integer>(setNSSRanges));
        }
        set<Integer> setClientSolutionRanges = mapCategoryNameRanges.get('CLIENTSOLUTIONS'); 
        set<Integer> setEnterpriseSolutionRanges = mapCategoryNameRanges.get('ENTERPRISESOLUTIONS');
        //3.0
        //set<Integer> setOnlineRanges = mapCategoryNameRanges.get('ONLINE');
        set<Integer> setOnlineRanges = mapCategoryNameRanges.get('ONLINE/ PARTNER PORTAL');
        set<Integer> setOrderSupportRanges = mapCategoryNameRanges.get('ORDERMANAGEMENT');
        set<Integer> setS_P_Ranges = mapCategoryNameRanges.get('PERIPHERALS');
        set<Integer> setServicesRanges = mapCategoryNameRanges.get('SERVICES');
        set<Integer> setSoftwareRanges = mapCategoryNameRanges.get('SOFTWARE');
        set<Integer> setTechSupportRanges = mapCategoryNameRanges.get('SUPPORT');
        
        //3.0
        set<Integer> setMktSupportRanges = mapCategoryNameRanges.get('MARKETINGSUPPORT');
        set<Integer> setTrainingCertRanges = mapCategoryNameRanges.get('TRAINING&CERTIFICATION');
        set<Integer> setProgMgtRanges = mapCategoryNameRanges.get('PROGRAMMANAGEMENT');
        set<Integer> setSolutionROIRanges = mapCategoryNameRanges.get('SOLUTIONROI');
        set<Integer> setCustomizationSvcRanges = mapCategoryNameRanges.get('CUSTOMIZATIONSERVICES');
        
        // Mapping All root cause with NSS category, these will be used while creating Tasks
        map<String, list<String>> mapCategoryNamePrimaryCauses = new map<String, list<String>>();
        map<String, list<String>> mapCategoryNameSecondaryCauses = new map<String, list<String>>();
        for(Root_Cause_Table__c rootCause : [select Id, NSS_Category__r.Name, Primary_Root_Cause__c, Secondary_Root_Cause__c from Root_Cause_Table__c]) {
            if(mapCategoryNamePrimaryCauses.get(rootCause.NSS_Category__r.Name) != null) {
                mapCategoryNamePrimaryCauses.get(rootCause.NSS_Category__r.Name).add(rootCause.Primary_Root_Cause__c);
            }
            else {
                mapCategoryNamePrimaryCauses.put(rootCause.NSS_Category__r.Name, new list<String>{ rootCause.Primary_Root_Cause__c });
            }
            
            if(mapCategoryNameSecondaryCauses.get(rootCause.NSS_Category__r.Name) != null) {
                mapCategoryNameSecondaryCauses.get(rootCause.NSS_Category__r.Name).add(rootCause.Secondary_Root_Cause__c);
            }
            else {
                mapCategoryNameSecondaryCauses.put(rootCause.NSS_Category__r.Name, new list<String>{ rootCause.Secondary_Root_Cause__c });
            }
        }
        
        boolean bCreateClientSolution = false;
        boolean bCreateEnterprise = false;
        boolean bCreateOnline = false;
        boolean bCreateOrderSupport = false;
        boolean bCreateS_P = false;
        boolean bCreateServices = false;
        boolean bCreateSoftware = false;
        boolean bCreateTechSupport = false;
        
        //3.0
        boolean bCreateMktSupport = false;
        boolean bCreateTrainingCert = false;
        boolean bCreateProgMgt = false;
        boolean bCreateSolutionROI = false;
        boolean bCreateCustomizationSvc = false;
        
        Id npsRTId = StaticFactory.getRecordTypeIdByName('Case', 'NPS Cases');
        list<Task> lstTasks = new list<Task>();
        list<Cross_Functional_Matrix__c> lstCrossFunMatrix = new list<Cross_Functional_Matrix__c>([select Id, Country__c, Segment__c, Sub_Segment__c,Owner__c, NSS_Category__r.Name, Functional_Call_To_Action__c from Cross_Functional_Matrix__c]);
        for(Case newCase : lstNewCases) {
            if(newCase.RecordTypeId == npsRTId) {
                if(newCase.Client_Solution__c != null && setClientSolutionRanges != null && !newCase.Client_Solution__c.equalsIgnoreCase(Label.NPSCaseNA)) {
                    if(setClientSolutionRanges.contains(Integer.valueOf(newCase.Client_Solution__c))) {
                        bCreateClientSolution = true;
                    }    
                }
                if(newCase.Enterprise_Solution__c != null && setEnterpriseSolutionRanges != null && !newCase.Enterprise_Solution__c.equalsIgnoreCase(Label.NPSCaseNA)) {
                    if(setEnterpriseSolutionRanges.contains(Integer.valueOf(newCase.Enterprise_Solution__c))) {
                        bCreateEnterprise = true;
                    }
                }
                if(newCase.Online__c != null && setOnlineRanges != null && !newCase.Online__c.equalsIgnoreCase(Label.NPSCaseNA)) {
                    if(setOnlineRanges.contains(Integer.valueOf(newCase.Online__c))) {
                        bCreateOnline = true;
                    }
                }
                if(newCase.Order_support__c != null && setOrderSupportRanges != null && !newCase.Order_support__c.equalsIgnoreCase(Label.NPSCaseNA)) {
                    if(setOrderSupportRanges.contains(Integer.valueOf(newCase.Order_support__c))) {
                        bCreateOrderSupport = true;
                    }
                }
                if(newCase.S_P__c != null && setS_P_Ranges != null && !newCase.S_P__c.equalsIgnoreCase(Label.NPSCaseNA)) {
                    if(setS_P_Ranges.contains(Integer.valueOf(newCase.S_P__c))) {
                        bCreateS_P = true;
                    }
                }
                if(newCase.Services__c != null && setServicesRanges != null && !newCase.Services__c.equalsIgnoreCase(Label.NPSCaseNA)) {
                    if(setServicesRanges.contains(Integer.valueOf(newCase.Services__c))) {
                        bCreateServices = true;
                    }
                }
                if(newCase.Software__c != null && setSoftwareRanges != null && !newCase.Software__c.equalsIgnoreCase(Label.NPSCaseNA)) {
                    if(setSoftwareRanges.contains(Integer.valueOf(newCase.Software__c))) {
                        bCreateSoftware = true;
                    }
                }
                if(newCase.Tech_Support__c != null && setTechSupportRanges != null && !newCase.Tech_Support__c.equalsIgnoreCase(Label.NPSCaseNA)) {
                    if(setTechSupportRanges.contains(Integer.valueOf(newCase.Tech_Support__c))) {
                        bCreateTechSupport = true;
                    }
                }
                
                //3.0
                if(newCase.Marketing_Support__c != null && setMktSupportRanges != null && !newCase.Marketing_Support__c.equalsIgnoreCase(Label.NPSCaseNA)) {
                    if(setMktSupportRanges.contains(Integer.valueOf(newCase.Marketing_Support__c))) {
                        bCreateMktSupport = true;
                    }
                }
                if(newCase.Training_Certification__c != null && setTrainingCertRanges != null && !newCase.Training_Certification__c.equalsIgnoreCase(Label.NPSCaseNA)) {
                    if(setTrainingCertRanges.contains(Integer.valueOf(newCase.Training_Certification__c))) {
                        bCreateTrainingCert = true;
                    }
                }
                if(newCase.Program_Management__c != null && setProgMgtRanges != null && !newCase.Program_Management__c.equalsIgnoreCase(Label.NPSCaseNA)) {
                    if(setProgMgtRanges.contains(Integer.valueOf(newCase.Program_Management__c))) {
                        bCreateProgMgt = true;
                    }
                }
                if(newCase.Solution_ROI__c != null && setSolutionROIRanges != null && !newCase.Solution_ROI__c.equalsIgnoreCase(Label.NPSCaseNA)) {
                    if(setSolutionROIRanges.contains(Integer.valueOf(newCase.Solution_ROI__c))) {
                        bCreateSolutionROI = true;
                    }
                }
                if(newCase.Customization_Services__c != null && setCustomizationSvcRanges != null && !newCase.Customization_Services__c.equalsIgnoreCase(Label.NPSCaseNA)) {
                    if(setCustomizationSvcRanges.contains(Integer.valueOf(newCase.Customization_Services__c))) {
                        bCreateCustomizationSvc = true;
                    }
                }
                
                
                for(Cross_Functional_Matrix__c cfMatrix : lstCrossFunMatrix) {
                    if(cfMatrix.Country__c == newCase.Country__c && cfMatrix.Segment__c == newCase.Segment__c && (cfMatrix.Sub_Segment__c == newCase.Sub_Segment__c || cfMatrix.Sub_Segment__c == null)) {
                        if(bCreateClientSolution && cfMatrix.NSS_Category__r.Name == 'CLIENTSOLUTIONS') {
                            lstTasks.add(createTask(cfMatrix.Owner__c, newCase.subject, newCase.Id, 'CLIENTSOLUTIONS', cfMatrix.Functional_Call_To_Action__c, getRootCauseValue(mapCategoryNamePrimaryCauses, 'CLIENTSOLUTIONS'), getRootCauseValue(mapCategoryNameSecondaryCauses, 'CLIENTSOLUTIONS')));
                            bCreateClientSolution = false;
                        }
                        if(bCreateEnterprise && cfMatrix.NSS_Category__r.Name == 'ENTERPRISESOLUTIONS') {
                            lstTasks.add(createTask(cfMatrix.Owner__c, newCase.subject, newCase.Id, 'ENTERPRISESOLUTIONS', cfMatrix.Functional_Call_To_Action__c, getRootCauseValue(mapCategoryNamePrimaryCauses, 'ENTERPRISESOLUTIONS'), getRootCauseValue(mapCategoryNameSecondaryCauses, 'ENTERPRISESOLUTIONS')));
                            bCreateEnterprise = false;
                        }
                        //3.0
                        /*
                        if(bCreateOnline && cfMatrix.NSS_Category__r.Name == 'ONLINE') {
                            lstTasks.add(createTask(cfMatrix.Owner__c, newCase.subject, newCase.Id, 'ONLINE', cfMatrix.Functional_Call_To_Action__c, getRootCauseValue(mapCategoryNamePrimaryCauses, 'ONLINE'), getRootCauseValue(mapCategoryNameSecondaryCauses, 'ONLINE')));
                            bCreateOnline = false;
                        }
                        */
                        if(bCreateOnline && cfMatrix.NSS_Category__r.Name == 'ONLINE/ PARTNER PORTAL') {
                            lstTasks.add(createTask(cfMatrix.Owner__c, newCase.subject, newCase.Id, 'ONLINE/ PARTNER PORTAL', cfMatrix.Functional_Call_To_Action__c, getRootCauseValue(mapCategoryNamePrimaryCauses, 'ONLINE/ PARTNER PORTAL'), getRootCauseValue(mapCategoryNameSecondaryCauses, 'ONLINE/ PARTNER PORTAL')));
                            bCreateOnline = false;
                        }
                        
                        if(bCreateOrderSupport && cfMatrix.NSS_Category__r.Name == 'ORDERMANAGEMENT') {
                            lstTasks.add(createTask(cfMatrix.Owner__c, newCase.subject, newCase.Id, 'ORDERMANAGEMENT', cfMatrix.Functional_Call_To_Action__c, getRootCauseValue(mapCategoryNamePrimaryCauses, 'ORDERMANAGEMENT'), getRootCauseValue(mapCategoryNameSecondaryCauses, 'ORDERMANAGEMENT')));
                            bCreateOrderSupport = false;
                        }
                        if(bCreateS_P && cfMatrix.NSS_Category__r.Name == 'PERIPHERALS') {
                            lstTasks.add(createTask(cfMatrix.Owner__c, newCase.subject, newCase.Id, 'PERIPHERALS', cfMatrix.Functional_Call_To_Action__c, getRootCauseValue(mapCategoryNamePrimaryCauses, 'PERIPHERALS'), getRootCauseValue(mapCategoryNameSecondaryCauses, 'PERIPHERALS')));
                            bCreateS_P = false;
                        }
                        if(bCreateServices && cfMatrix.NSS_Category__r.Name == 'SERVICES') {
                            lstTasks.add(createTask(cfMatrix.Owner__c, newCase.subject, newCase.Id, 'SERVICES', cfMatrix.Functional_Call_To_Action__c, getRootCauseValue(mapCategoryNamePrimaryCauses, 'SERVICES'), getRootCauseValue(mapCategoryNameSecondaryCauses, 'SERVICES')));
                            bCreateServices = false;
                        }
                        if(bCreateSoftware && cfMatrix.NSS_Category__r.Name == 'SOFTWARE') {
                            lstTasks.add(createTask(cfMatrix.Owner__c, newCase.subject, newCase.Id, 'SOFTWARE', cfMatrix.Functional_Call_To_Action__c, getRootCauseValue(mapCategoryNamePrimaryCauses, 'SOFTWARE'), getRootCauseValue(mapCategoryNameSecondaryCauses, 'SOFTWARE')));
                            bCreateSoftware = false;
                        }
                        if(bCreateTechSupport && cfMatrix.NSS_Category__r.Name == 'SUPPORT') {
                            lstTasks.add(createTask(cfMatrix.Owner__c, newCase.subject, newCase.Id, 'SUPPORT', cfMatrix.Functional_Call_To_Action__c, getRootCauseValue(mapCategoryNamePrimaryCauses, 'SUPPORT'), getRootCauseValue(mapCategoryNameSecondaryCauses, 'SUPPORT')));
                            bCreateTechSupport = false;
                        }
                        
                        //3.0
                        if(bCreateMktSupport && cfMatrix.NSS_Category__r.Name == 'MARKETINGSUPPORT') {
                            lstTasks.add(createTask(cfMatrix.Owner__c, newCase.subject, newCase.Id, 'MARKETINGSUPPORT', cfMatrix.Functional_Call_To_Action__c, getRootCauseValue(mapCategoryNamePrimaryCauses, 'MARKETINGSUPPORT'), getRootCauseValue(mapCategoryNameSecondaryCauses, 'MARKETINGSUPPORT')));
                            bCreateMktSupport = false;
                        }
                        if(bCreateTrainingCert && cfMatrix.NSS_Category__r.Name == 'TRAINING&CERTIFICATION') {
                            lstTasks.add(createTask(cfMatrix.Owner__c, newCase.subject, newCase.Id, 'TRAINING&CERTIFICATION', cfMatrix.Functional_Call_To_Action__c, getRootCauseValue(mapCategoryNamePrimaryCauses, 'TRAINING&CERTIFICATION'), getRootCauseValue(mapCategoryNameSecondaryCauses, 'TRAINING&CERTIFICATION')));
                            bCreateTrainingCert = false;
                        }
                        if(bCreateProgMgt && cfMatrix.NSS_Category__r.Name == 'PROGRAMMANAGEMENT') {
                            lstTasks.add(createTask(cfMatrix.Owner__c, newCase.subject, newCase.Id, 'PROGRAMMANAGEMENT', cfMatrix.Functional_Call_To_Action__c, getRootCauseValue(mapCategoryNamePrimaryCauses, 'PROGRAMMANAGEMENT'), getRootCauseValue(mapCategoryNameSecondaryCauses, 'PROGRAMMANAGEMENT')));
                            bCreateProgMgt = false;
                        }
                        if(bCreateSolutionROI && cfMatrix.NSS_Category__r.Name == 'SOLUTIONROI') {
                            lstTasks.add(createTask(cfMatrix.Owner__c, newCase.subject, newCase.Id, 'SOLUTIONROI', cfMatrix.Functional_Call_To_Action__c, getRootCauseValue(mapCategoryNamePrimaryCauses, 'SOLUTIONROI'), getRootCauseValue(mapCategoryNameSecondaryCauses, 'SOLUTIONROI')));
                            bCreateSolutionROI = false;
                        }
                        if(bCreateCustomizationSvc && cfMatrix.NSS_Category__r.Name == 'CUSTOMIZATIONSERVICES') {
                            lstTasks.add(createTask(cfMatrix.Owner__c, newCase.subject, newCase.Id, 'CUSTOMIZATIONSERVICES', cfMatrix.Functional_Call_To_Action__c, getRootCauseValue(mapCategoryNamePrimaryCauses, 'CUSTOMIZATIONSERVICES'), getRootCauseValue(mapCategoryNameSecondaryCauses, 'CUSTOMIZATIONSERVICES')));
                            bCreateCustomizationSvc = false;
                        }
                    }
                }
                //3.0
                //bCreateClientSolution = bCreateEnterprise = bCreateOnline = bCreateOrderSupport = bCreateS_P = bCreateServices = bCreateSoftware = bCreateTechSupport = false;
                bCreateClientSolution = bCreateEnterprise = bCreateOnline = bCreateOrderSupport = bCreateS_P = bCreateServices = bCreateSoftware = bCreateTechSupport = bCreateMktSupport = bCreateTrainingCert = bCreateProgMgt = bCreateSolutionROI = bCreateCustomizationSvc = false;
            }
        }
        if(!lstTasks.isEmpty()) {
            insert lstTasks;
        }
    }

    private static String getRootCauseValue(map<String, list<String>> mapCategoryNameCauses, String strNSSCategory) {
        String strRootCause = '';
        if(mapCategoryNameCauses != null) {
            list<String> lstRootCauses = mapCategoryNameCauses.get(strNSSCategory);
            if(lstRootCauses != null) {
                for(String rootCause : lstRootCauses) {
                    if(rootCause != null) {
                        strRootCause = strRootCause + ';' + rootCause;
                    }
                }
            }
        }

        return strRootCause;
    }
    
    private static Task createTask(Id owner_Id, String strSubject, Id whatId, String strNSSCategory, String strFunctionalCallToAction, String primaryField, String secondaryField) {
        Task taskInstance = new Task();
        taskInstance.OwnerId = owner_Id;
        taskInstance.Subject = strSubject;
        taskInstance.Status = 'Not Started';
        taskInstance.ActivityDate = Date.newInstance(System.now().year(), System.now().month(), System.now().day()) + 14; // Due Date as Today Date + 14 days
        taskInstance.WhatId = whatId;
        taskInstance.IsReminderSet = true;
        taskInstance.ReminderDateTime = System.now().addDays(7);
        taskInstance.NSS_Category__c = strNSSCategory;
        taskInstance.Description = strFunctionalCallToAction;
        taskInstance.Primary_Root_Causes__c = primaryField;
        taskInstance.Secondary_Root_Causes__c = secondaryField;
        taskInstance.RecordTypeId = StaticFactory.getRecordTypeIdByName('Task', 'NPS Task');
        return taskInstance;
    }
    
}