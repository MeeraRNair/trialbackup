/*
 * Author   : Ragu
 * Purpose  : Helper class for Lead assignment logics.
 *        
 * Revision Ref Number  Release No      Date            Modified By     Description
 * -------- ----------  ----------      -----------     ------------    -----------
 * 1.0      CR 11967    16.10           15-Sep-2015     Ragu            LM2_1_33-Ability to assign lead owner by following campaign automation
 * 1.1      TFS 198612  16.10           22-Sep-2015     Ragu            LM2_1_33: Channel ISM user not added to Lead Follow-up list from Partner Account team
 * 1.2      CR12661     csm0203         16-Feb-2015     Josie           LM2_2-Fix default assignment logic so it follows ISR/AE/account owner. For Partner Account ICAM first then PDM
 * 2.0      CR12985     FY17-DCS-0502   29-Mar-2016     Gan             create a method to return a map with Account owner role in Account Team
 * 2.1      TFS 1700383 FY17-DCS-0502   13-Apr-2016     Gan             Fix the sorting on text field badge number
 * 2.2      CR12985     FY17-DCS-0502   09-May-2016     Gan             Fix when badge number is null     
 * 3.0      CR 14776    FY18-DCS-1001   15-AUG-2017     Ashok           Enhance lead assignment logic + GCCS lead assignment logic 
 * 3.1      CR 14777    FY18-DCS-1001   15-AUG-2017     Ashok           User Field configuration on Lead from new assignment logic
 * 4.0      CR 14998    FY18-DCS-1101   10-OCT-2017     Ashok           Lead Owner Role population when Assignment logic triggred

 
*/
 
public class LeadAssignmentHelper {
   
   
    // v1.0 - Returns the Accounts which are related with the Leads
    public static map<Id, Account> queryAccounts(list<Lead> lstLeads) {
        map<Id, Account> mapRelatedAccounts = new map<Id, Account>();
        set<Id> setAccountIds = new set<Id>();
        for(Lead leadIterator : lstLeads) {
            setAccountIds.add(leadIterator.Account__c);
        }
        setAccountIds.remove(null);
        
        if(!setAccountIds.isEmpty()) {
            //mapRelatedAccounts = new map<Id, Account>([select Id, Name, OwnerId, ShippingState, ShippingCountry, ShippingPostalCode, Account_Country__c, RecordTypeId, RecordType.Name,Account_ClassificationSCG__c from Account where Id in :setAccountIds]);
            mapRelatedAccounts = new map<Id, Account>([select Id, Name, OwnerId, Owner.Resource_Manager_Role__c, ShippingState, ShippingCountry, ShippingPostalCode, Account_Country__c, RecordTypeId, RecordType.Name,Account_Classification__c from Account where Id in :setAccountIds]);
        }
        return mapRelatedAccounts;
    }
    
    // v1.0 - Returns the Campaign's primary and secondary follow-up roles
    public static set<String> getCampaignRoles(list<Lead> lstLeads, map<Id, Campaign> mapRelatedCampaigns) {
        set<String> setCampaignRoles = new set<String>();
        for(Lead leadIterator : lstLeads) {
            Campaign campaignIterator = mapRelatedCampaigns.get(leadIterator.Campaign__c);
            if(campaignIterator != null) {
                setCampaignRoles.add(campaignIterator.Follow_Up_Role__c);
                setCampaignRoles.add(campaignIterator.Secondary_Role__c);
            }
        }
        setCampaignRoles.remove(null);
        return setCampaignRoles;
    }
    
    // v1.0 - Returns the Campaign's primary follow-up roles
    public static set<String> getCampaignPrimaryRoles(list<Lead> lstLeads, map<Id, Campaign> mapRelatedCampaigns) {
        set<String> setCampaignPrimaryRoles = new set<String>();
        for(Lead leadIterator : lstLeads) {
            Campaign campaignIterator = mapRelatedCampaigns.get(leadIterator.Campaign__c);
            if(campaignIterator != null) {
                setCampaignPrimaryRoles.add(campaignIterator.Follow_Up_Role__c);
            }
        }
        setCampaignPrimaryRoles.remove(null);
        return setCampaignPrimaryRoles;
    }
    
    // 2.1 rewrite this method to sort the badge id based on numeric for numeric id and sort badge id based on text for non numeric and return a list of both sorted list
    public static map<Id, map<String, list<Id>>> getAccountIdRoleTeamMemberMap(set<Id> setAccountIds, set<String> setCampaignRoles) {
         map<Id, map<String, list<AccountTeamMemberWrapper>>> mapAccountIdRoleTeamMemberWrapper = new map<Id, map<String, list<AccountTeamMemberWrapper>>>();
         map<Id, map<String, list<Id>>> mapAccountIdRoleTeamMember = new map<Id, map<String, list<Id>>>();
         map<Id, map<String, list<Id>>> mapAccountIdRoleTemaMemberNonNumeric = new map<Id, map<String, list<Id>>>(); 
         long lngBadgeNum;
         for(AccountTeamMember accTeamMember : [select Id, AccountId, TeamMemberRole, User.Badge_Number__c, UserId 
                from AccountTeamMember 
                where AccountId in :setAccountIds and TeamMemberRole in :setCampaignRoles and User.IsActive = true order by AccountId, User.Badge_Number__c asc]) {
            //2.2
            if (accTeamMember.User.Badge_Number__c != null && accTeamMember.User.Badge_Number__c.isNumeric()) {
                lngBadgeNum = long.valueOf(accTeamMember.User.Badge_Number__c);
                if(mapAccountIdRoleTeamMemberWrapper.get(accTeamMember.AccountId) == null) {
                    mapAccountIdRoleTeamMemberWrapper.put(accTeamMember.AccountId, new map<String, list<AccountTeamMemberWrapper>> 
                        {accTeamMember.TeamMemberRole => new list<AccountTeamMemberWrapper> {new AccountTeamMemberWrapper(accTeamMember.UserId, lngBadgeNum )}});
                }
                else {
                    if(mapAccountIdRoleTeamMemberWrapper.get(accTeamMember.AccountId).get(accTeamMember.TeamMemberRole) == null) {
                        mapAccountIdRoleTeamMemberWrapper.get(accTeamMember.AccountId).put(accTeamMember.TeamMemberRole, new list<AccountTeamMemberWrapper> {new AccountTeamMemberWrapper(accTeamMember.UserId, lngBadgeNum )});
                    }
                    else {
                        mapAccountIdRoleTeamMemberWrapper.get(accTeamMember.AccountId).get(accTeamMember.TeamMemberRole).add(new AccountTeamMemberWrapper(accTeamMember.UserId, lngBadgeNum ));
                    }
                }
            }
            else
            {
                if(mapAccountIdRoleTemaMemberNonNumeric.get(accTeamMember.AccountId) == null) {
                    mapAccountIdRoleTemaMemberNonNumeric.put(accTeamMember.AccountId, new map<String, list<Id>> 
                        {accTeamMember.TeamMemberRole => new list<Id> {accTeamMember.UserId}});
                }
                else {
                    if(mapAccountIdRoleTemaMemberNonNumeric.get(accTeamMember.AccountId).get(accTeamMember.TeamMemberRole) == null) {
                        mapAccountIdRoleTemaMemberNonNumeric.get(accTeamMember.AccountId).put(accTeamMember.TeamMemberRole, new list<Id> {accTeamMember.UserId});
                    }
                    else {
                        mapAccountIdRoleTemaMemberNonNumeric.get(accTeamMember.AccountId).get(accTeamMember.TeamMemberRole).add(accTeamMember.UserId);
                    }
                }
                
            }
        }
        //system.debug('ZY => mapAccountIdRoleTeamMemberWrapper: ' + mapAccountIdRoleTeamMemberWrapper);
        //system.debug('ZY => mapAccountIdRoleTemaMemberNonNumeric: ' + mapAccountIdRoleTemaMemberNonNumeric);
        
        if(mapAccountIdRoleTeamMemberWrapper!=null) {
            for (Id accountId : mapAccountIdRoleTeamMemberWrapper.keySet()) {
                map<String, list<AccountTeamMemberWrapper>> mapAccIdAccountTeamMemberWrapper = mapAccountIdRoleTeamMemberWrapper.get(accountId);
                if (mapAccIdAccountTeamMemberWrapper!=null) {
                    for(string role : mapAccIdAccountTeamMemberWrapper.keySet()) {
                        list<AccountTeamMemberWrapper> listAccTeamMemberWraper = mapAccIdAccountTeamMemberWrapper.get(role);
                        if(listAccTeamMemberWraper!= null) {
                            listAccTeamMemberWraper.Sort();
                            for(AccountTeamMemberWrapper accTeamWrapper: listAccTeamMemberWraper) {
                                if(mapAccountIdRoleTeamMember.get(accountId) == null) {
                                    mapAccountIdRoleTeamMember.put(accountId, new map<String, list<Id>> {role => new list<Id> {accTeamWrapper.UserId}});
                                }
                                else {
                                    if(mapAccountIdRoleTeamMember.get(accountId).get(role) == null) {
                                        mapAccountIdRoleTeamMember.get(accountId).put(role, new list<Id> {accTeamWrapper.UserId});
                                    }
                                    else {
                                        mapAccountIdRoleTeamMember.get(accountId).get(role).add(accTeamWrapper.UserId);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        if(mapAccountIdRoleTemaMemberNonNumeric!=null) {
            for (Id accountId : mapAccountIdRoleTemaMemberNonNumeric.keySet()) {
                map<String, list<Id>> mapRoleTemaMemberNonNumeric = mapAccountIdRoleTemaMemberNonNumeric.get(accountId);
                if (mapRoleTemaMemberNonNumeric!=null) {
                    for(string role : mapRoleTemaMemberNonNumeric.keySet()) {
                        list<Id> listTeamMemberNonNumeric = mapRoleTemaMemberNonNumeric.get(role);
                        if(listTeamMemberNonNumeric!= null) {
                            for(Id teamMemberNonNumericId : listTeamMemberNonNumeric) {
                                if(mapAccountIdRoleTeamMember.get(accountId) == null) {
                                    mapAccountIdRoleTeamMember.put(accountId, new map<String, list<Id>> {role => new list<Id> {teamMemberNonNumericId}});
                                }
                                else {
                                    if(mapAccountIdRoleTeamMember.get(accountId).get(role) == null) {
                                        mapAccountIdRoleTeamMember.get(accountId).put(role, new list<Id> {teamMemberNonNumericId});
                                    }
                                    else {
                                        mapAccountIdRoleTeamMember.get(accountId).get(role).add(teamMemberNonNumericId);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        system.debug('ZY => Finally Output mapAccountIdRoleTeamMember: ' + mapAccountIdRoleTeamMember);
        return mapAccountIdRoleTeamMember;
    }
    
    
    public class AccountTeamMemberWrapper implements Comparable{
        public Id userId;
        public long lngBadgeNum;

        public AccountTeamMemberWrapper(Id uId, long lngBadgeId) {
            userId = uId;
            lngBadgeNum = lngBadgeId;
        }
        
        public Integer CompareTo(Object objToCompare) {
            AccountTeamMemberWrapper compareToAccTeamWrapper = (AccountTeamMemberWrapper)objToCompare;
            if(lngBadgeNum == compareToAccTeamWrapper.lngBadgeNum) return 0;
            if(lngBadgeNum > compareToAccTeamWrapper.lngBadgeNum) return 1;
            return -1;
        }
    }
        
        
    // v1.0 - Prepare territory related details for Lead assignment
    public static void prepareTerritoryDetails(list<Lead> lstLeads, map<Id, Campaign> mapRelatedCampaigns, map<Id, Account> mapRelatedAccounts) {
        set<Id> setGeoIds = new set<Id>();
        set<Id> setTerritoryIds = new set<Id>();
        map<Id, list<Id>> mapAccountIdTerritoryIds = new map<Id, list<Id>>();
        map<Id, map<String, list<Territory_Sales_User_Assignment__c>>> mapTerritoryIdRoleTSUAs = new map<Id, map<String, list<Territory_Sales_User_Assignment__c>>>();
        
        // Store all possible Geography entries in Account
        set<String> setGeoNames = new set<String>();
        for(Account accIterator : mapRelatedAccounts.values()) {
            setGeoNames.add(accIterator.ShippingPostalCode);
            setGeoNames.add(accIterator.ShippingState);
            setGeoNames.add(accIterator.Account_Country__c);
        }
        setGeoNames.remove(null);
        
        // Store map of Geography Name and Territory_Geo_Assignment__c which has both Territory and Geography details for the identified Geography entries in Account
        map<String, Territory_Geo_Assignment__c> mapGeoNameTGA = new map<String, Territory_Geo_Assignment__c>();
        for(Territory_Geo_Assignment__c territoryGeoAssignment : [select Id, Name, Geography__c, Geography__r.Name, Territory__c from Territory_Geo_Assignment__c where Geography__r.Name in :setGeoNames]) {
            mapGeoNameTGA.put(territoryGeoAssignment.Geography__r.Name.toUpperCase(), territoryGeoAssignment);
        }
        
        // Prepare map of Account Id and list of Territory Ids
        Territory_Geo_Assignment__c tempTGA;
        for(Account accIterator : mapRelatedAccounts.values()) {
            // Process only if Account Country is present in the Geography
            if(accIterator.Account_Country__c != null && mapGeoNameTGA.containsKey(accIterator.Account_Country__c.toUpperCase())) {
                list<Id> lstTempTerritoryIds = new list<Id>();
                
                // Store details for ShippingPostalCode
                if(accIterator.ShippingPostalCode != null) {
                    tempTGA = mapGeoNameTGA.get(accIterator.ShippingPostalCode.toUpperCase());
                    if(tempTGA != null) {
                        setGeoIds.add(tempTGA.Geography__c);
                        setTerritoryIds.add(tempTGA.Territory__c);
                        lstTempTerritoryIds.add(tempTGA.Territory__c);  
                    }
                }
                
                // Store details for ShippingState
                if(accIterator.ShippingState != null) {
                    tempTGA = mapGeoNameTGA.get(accIterator.ShippingState.toUpperCase());
                    if(tempTGA != null) {
                        setGeoIds.add(tempTGA.Geography__c);
                        setTerritoryIds.add(tempTGA.Territory__c);
                        lstTempTerritoryIds.add(tempTGA.Territory__c);
                    }
                }

                // Store details for Account_Country__c
                tempTGA = mapGeoNameTGA.get(accIterator.Account_Country__c.toUpperCase());
                setGeoIds.add(tempTGA.Geography__c);
                setTerritoryIds.add(tempTGA.Territory__c);
                lstTempTerritoryIds.add(tempTGA.Territory__c);
                
                mapAccountIdTerritoryIds.put(accIterator.Id, lstTempTerritoryIds);
            }
        }
        
        // Prepare map of Account Id and map of Role and Territory Sales User Assignments
        set<String> setGeographyTypes = new set<String> {'Zipcode', 'State', 'Country'};
        set<String> setCampaignPrimaryRoles = getCampaignPrimaryRoles(lstLeads, mapRelatedCampaigns);
        map<String, list<Territory_Sales_User_Assignment__c>> mapRoleTSUAs;
        for(Territory_Sales_User_Assignment__c territorySUAssign : [select Id, Name, Territory__c, Territory__r.Geography_Type__c, User__c, Role__c, Role__r.Name from Territory_Sales_User_Assignment__c 
                                                                    where Territory__c in :setTerritoryIds and Role__r.Name in :setCampaignPrimaryRoles and Territory__r.Geography_Type__c in :setGeographyTypes
                                                                        and Is_Active__c = true and Territory__r.Is_Active__c = true and Role__r.Is_Active__c = true and User__r.IsActive = true order by Territory__r.Geography_Type__c desc]) {
            mapRoleTSUAs = mapTerritoryIdRoleTSUAs.get(territorySUAssign.Territory__c);
            if(mapRoleTSUAs == null) {
                mapTerritoryIdRoleTSUAs.put(territorySUAssign.Territory__c, new map<String, list<Territory_Sales_User_Assignment__c>> {territorySUAssign.Role__r.Name => new list<Territory_Sales_User_Assignment__c> {territorySUAssign}});
            }
            else {
                if(mapRoleTSUAs.get(territorySUAssign.Role__r.Name) == null) {
                    mapRoleTSUAs.put(territorySUAssign.Role__r.Name, new list<Territory_Sales_User_Assignment__c> {territorySUAssign});
                }
                else {
                    mapRoleTSUAs.get(territorySUAssign.Role__r.Name).add(territorySUAssign);
                }
            }
        }
        
        // Store results in the LeadAssignmet variables so that it can be accessed inside LeadAssignment
        LeadAssignment.setAccountIdTerritoryIds(mapAccountIdTerritoryIds);
        LeadAssignment.setTerritoryIdRoleTSUAs(mapTerritoryIdRoleTSUAs);
    }   
    
    // v1.0 - Returns the field configuration for End-User Account and Partner Account
    public static map<String, map<String, String>> getOwnerFieldConfiguration() {
        map<String, map<String, String>> mapOwnerFieldConfiguration = new map<String, map<String, String>>();
        
        // Field Configuration for End-User Account
        map<String, String> mapEndUserConfiguration = new map<String, String>();
        mapEndUserConfiguration.put('Partner Development Manager', 'Account Executive');
        mapEndUserConfiguration.put('Inside Channel Account Manager', 'Inside Sales Rep');
        mapOwnerFieldConfiguration.put('End-User Account', mapEndUserConfiguration);
        
        // Field Configuration for Partner Account
        map<String, String> mapPartnerUserConfiguration = new map<String, String>();
        mapPartnerUserConfiguration.put('Account Executive', 'Partner Development Manager');
        mapPartnerUserConfiguration.put('Inside Sales Rep', 'Inside Channel Account Manager');
        mapOwnerFieldConfiguration.put('Partner Account', mapPartnerUserConfiguration);
        
        return mapOwnerFieldConfiguration;
    }
    
    // v3.1 - Returns the field configuration for Follow up roles
    public static map<String, set<string>> getFollowUpRoleConfiguration() {
        map<String, set<string>> mapFollowUpRoleConfiguration = new map<String, set<string>>();
        
        mapFollowUpRoleConfiguration.put('Inside Sales Rep', new set<String>{'Inside Sales Rep','Client & Compute Inside Sales Rep','Inside Channel Account Manager'});
        mapFollowUpRoleConfiguration.put('Inside Channel Account Manager', new set<String>{'Inside Channel Account Manager','Inside Sales Rep'});
        mapFollowUpRoleConfiguration.put('Account Executive', new set<String>{'Account Executive','Client & Compute Sales Exec','Partner Development Manager'});
        mapFollowUpRoleConfiguration.put('Partner Development Manager', new set<String>{'Partner Development Manager','Account Executive'});
        mapFollowUpRoleConfiguration.put('Client & Compute Inside Sales Rep', new set<String>{'Client & Compute Inside Sales Rep','Inside Sales Rep','Client & Compute Sales Exec','Client & Compute Global Sales Exec'});
        mapFollowUpRoleConfiguration.put('Client & Compute Sales Exec', new set<String>{'Client & Compute Sales Exec','Account Executive','Client & Compute Global Sales Exec','Client & Compute Inside Sales Rep'});
        mapFollowUpRoleConfiguration.put('Client & Compute Global Sales Exec', new set<String>{'Client & Compute Global Sales Exec','Client & Compute Sales Exec','Account Executive','Client & Compute Inside Sales Rep'});
        
               
        return mapFollowUpRoleConfiguration;
    }
    
    // v1.0 - Returns the field configuration for End-User Account and Partner Account
    // v3.0 - Returns the field configuration for Type of Account - ENTERPRISE and OTHER
    public static map<string,map<String, map<String, list<String>>>> getUserFieldConfiguration() {
        map<String, map<string,map<String, list<String>>>> mapUserFieldConfiguration = new map<String, map<string,map<String, list<String>>>>();
        
        // Field Configuration for ENTERPRISE Account
        map<String, list<String>> mapFConfiguration = new map<String, list<String>>();
        map<string,map<String, list<String>>> mapEndUserConfiguration = new map<string,map<String, list<String>>>();
        mapFConfiguration.put('Account_Executive_PDM__c', new list<String>{'Client & Compute Sales Exec','Client & Compute Global Sales Exec','Account Executive'});
        mapFConfiguration.put('Inside_Sales_Rep_ICAM__c', new list<String>{'Client & Compute Inside Sales Rep','Inside Sales Rep'});
        mapFConfiguration.put('ISM_Channel_ISM__c', new list<String>{'Inside Sales Manager'});
        mapFConfiguration.put('RSM__c', new list<String>{'Regional Sales Manager'});
        
        mapEndUserConfiguration.put('End-User Account', mapFConfiguration);
        mapEndUserConfiguration.put('Partner Account',mapFConfiguration);
        
        mapUserFieldConfiguration.put('ENTERPRISE', mapEndUserConfiguration);
        
        // Field Configuration for OTHER Account
        map<String, list<String>> mapFConfiguration1 = new map<String, list<String>>(); //End User Account COnfig
        map<String, list<String>> mapFConfiguration2 = new map<String, list<String>>(); //Partner User Account COnfig
        map<string,map<String, list<String>>> mapPartnerUserConfiguration = new map<string,map<String, list<String>>>();

        mapFConfiguration1.put('Account_Executive_PDM__c', new list<String>{'Account Executive','Partner Development Manager'});
        mapFConfiguration1.put('Inside_Sales_Rep_ICAM__c', new list<String>{'Inside Sales Rep','Inside Channel Account Manager'});
        // v1.1 Start: ISM_Channel_ISM__c should be populated based on Channel Inside Sales Manager for Partner Accounts.
        //mapPartnerUserConfiguration.put('ISM_Channel_ISM__c', new list<String>{'Inside Sales Manager'});
        mapFConfiguration1.put('ISM_Channel_ISM__c', new list<String>{'Channel Inside Sales Manager'});
        // v1.1 End: ISM_Channel_ISM__c should be populated based on Channel Inside Sales Manager for Partner Accounts.
        mapFConfiguration1.put('RSM__c', new list<String>{'Regional Sales Manager'});
        mapPartnerUserConfiguration.put('End-User Account',mapFConfiguration1);
        
        mapFConfiguration2.put('Account_Executive_PDM__c', new list<String>{'Partner Development Manager','Account Executive'});
        mapFConfiguration2.put('Inside_Sales_Rep_ICAM__c', new list<String>{'Inside Channel Account Manager','Inside Sales Rep'});
        // v1.1 Start: ISM_Channel_ISM__c should be populated based on Channel Inside Sales Manager for Partner Accounts.
        //mapPartnerUserConfiguration.put('ISM_Channel_ISM__c', new list<String>{'Inside Sales Manager'});
        mapFConfiguration2.put('ISM_Channel_ISM__c', new list<String>{'Channel Inside Sales Manager'});
        // v1.1 End: ISM_Channel_ISM__c should be populated based on Channel Inside Sales Manager for Partner Accounts.
        mapFConfiguration2.put('RSM__c', new list<String>{'Regional Sales Manager'});
        
        mapPartnerUserConfiguration.put('Partner Account',mapFConfiguration2);
        
        mapUserFieldConfiguration.put('OTHER', mapPartnerUserConfiguration);
        
        return mapUserFieldConfiguration;
    }

    // v1.0 - Returns the field configuration for End-User Account and Partner Account
    public static map<String, list<String>> getTrackingFields() {
        map<String, list<String>> mapTrackingFields = new map<String, list<String>>();
        mapTrackingFields.put('OwnerId', new list<String> {'Lead_Owner_System_Auto_Populated__c', 'Geo_Populated__c'});
        mapTrackingFields.put('Inside_Sales_Rep_ICAM__c', new list<String> {'ISR_System_Auto_Populated__c'});
        mapTrackingFields.put('ISM_Channel_ISM__c', new list<String> {'ISM_System_Auto_Populated__c'});
        mapTrackingFields.put('Account_Executive_PDM__c', new list<String> {'AE_System_Auto_Populated__c'});
        mapTrackingFields.put('RSM__c', new list<String> {'RSM_System_Auto_Populated__c'});
        
        return mapTrackingFields;
    }
    
    // v1.0 - Returns the default Account Team Member Roles for populating Lead Owner
     // v1.2 - 1.2 For End-User Account, The default path should be ISR first then AE. For Partner Account ICAM first then PDM 
    // v3.0 - Returns the default Account team member roles for populatign the lead owner based on Account classification and Account Type.
    public static map<string,map<String, list<String>>> getDefaultRoles() {
        map<string,map<String, list<String>>> mapFieldclassification = new map<string,map<String, list<String>>>();
        map<String, list<String>> mapFieldConfiguration = new map<String, list<String>>();
        mapFieldConfiguration.put('End-User Account', new list<String>{'Client & Compute Inside Sales Rep','Inside Sales Rep','Client & Compute Sales Exec','Client & Compute Global Sales Exec','Account Executive'});
        mapFieldConfiguration.put('Partner Account', new list<String>{'Client & Compute Inside Sales Rep','Inside Sales Rep','Client & Compute Sales Exec','Client & Compute Global Sales Exec','Account Executive'});
        mapFieldclassification.put('ENTERPRISE',mapFieldConfiguration);
                
        map<String, list<String>> mapFieldConfiguration1 = new map<String, list<String>>();
        mapFieldConfiguration1.put('End-User Account', new list<String>{'Inside Sales Rep','Inside Channel Account Manager','Account Executive','Partner Development Manager','Client & Compute Inside Sales Rep'});
        mapFieldConfiguration1.put('Partner Account', new list<String>{'Inside Channel Account Manager','Inside Sales Rep','Partner Development Manager','Account Executive','Client & Compute Inside Sales Rep'});
        mapFieldclassification.put('OTHER',mapFieldConfiguration1);
        
        return mapFieldclassification;
    }
    

   //4.0 - return the set of roles
   public static set<String> getAdditionalRoles() {
        set<String> setAdditionalRoles = new set<String>();
        map<string,map<String, map<String, list<String>>>> mapUserFieldConfiguration = getUserFieldConfiguration();
        for(String strAccountClassfi : mapUserFieldConfiguration.keySet()) {
            map<string,map<String, list<String>>> mapACRoles = mapUserFieldConfiguration.get(strAccountClassfi); 
            for(string strAccountType: mapACRoles.keySet()){
                map<string,list<string>> mapFieldRoles = mapACRoles.get(strAccountType);
                for(String strField : mapFieldRoles.keySet()) {
                    setAdditionalRoles.addAll(mapFieldRoles.get(strField));
                }
            }
        }
        return setAdditionalRoles;
    }
    
    //2.0
    public static map<Id, set<String>> getAccIdOwnerRolesInTeamMap(map<Id, Account> mapRelatedAccounts, map<Id, map<String, list<Id>>> mapAccountIdRoleTeamMember) {
        system.debug('!!!!!!!!'+mapRelatedAccounts);
        system.debug('!!!!!!!!'+mapAccountIdRoleTeamMember);
        map<Id, set<String>> mapOwnerIdRoleInTeam = new map<Id, set<String>>();
        map<String, list<Id>> mapRoleTeamMember = new map<String, list<Id>>();
        list<Id> listId = new list<Id>();
        set<id> setId = new set<Id>();
        //Set<Id> setOwnerId = new set<Id>();
        for(Id accountId : mapRelatedAccounts.keySet()) {
            Account acc = mapRelatedAccounts.get(accountId); 
                
            if (acc.OwnerId != null) {
                mapRoleTeamMember = mapAccountIdRoleTeamMember.get(accountId);
                if(mapRoleTeamMember!=null) {
                    for(String strRole : mapRoleTeamMember.keySet()) {
                        listId = mapRoleTeamMember.get(strRole);
                        if(listId != null) {
                            setId.clear(); 
                            setId.addAll(listId);
                            if (setId.contains(acc.OwnerId)) {
                                if(mapOwnerIdRoleInTeam.get(accountId) == null) {
                                    mapOwnerIdRoleInTeam.put(accountId, new Set<String> {strRole});
                                }
                                else {
                                    mapOwnerIdRoleInTeam.get(accountId).add(strRole);
                                }
                            }
                        }
                    }
                }
            }
        }
        return mapOwnerIdRoleInTeam;
    }
    //4.0
    public static map<Id, map<Id,String>> getAccIdOwnerRolesInTeamMap1(map<Id, Account> mapRelatedAccounts,set<Id> leadCreatedByIds){
        
        map<Id,map<Id,String>> mapOwnerIdRoleInTeam = new map<Id,map<Id,String>>();
        set<Id> AccownerIds = new set<Id>();
        for(Account AccOwnrRoles : mapRelatedAccounts.values()){
           AccOwnerIds.add(AccOwnrRoles.OwnerId);
        }
        
        if(!leadCreatedByIds.IsEmpty()) AccOwnerIds.addAll(leadCreatedByIds);
        
        if(!AccOwnerIds.isEmpty()){
            for(AccountTeamMember accTeamMember : [select Id, AccountId, TeamMemberRole, User.Badge_Number__c, UserId 
                        from AccountTeamMember 
                        where AccountId in :mapRelatedAccounts.keyset() and UserId In :AccOwnerIds and User.IsActive = true order by AccountId, User.Badge_Number__c asc])
                {
                     
                     
                        if(mapOwnerIdRoleInTeam.containskey(accTeamMember.AccountId)){
                           
                           map<Id, string> mapUserIdRole1 = mapOwnerIdRoleInTeam.get(accTeamMember.AccountId);
                           mapUserIdRole1.put(accTeamMember.UserId,accTeamMember.TeamMemberRole);
                           mapOwnerIdRoleInTeam.put(accTeamMember.AccountId, mapUserIdRole1);
                           
                        }else{
                            //mapUserIdRole.put(accTeamMember.UserId,accTeamMember.TeamMemberRole);
                            map<Id,String> mapUserIdRole = new Map<Id,String>{accTeamMember.UserId => accTeamMember.TeamMemberRole};
                            mapOwnerIdRoleInTeam.put(accTeamMember.AccountId, mapUserIdRole);
                        }
                         
                }
        
         }
        
        return mapOwnerIdRoleInTeam;
    }
    
}