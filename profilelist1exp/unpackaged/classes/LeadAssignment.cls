/*
 * Author   : Ragu
 * Purpose  : To handle all Lead assignment logics for Lead 2.0.
 *        
 * Revision Ref Number  Release No      Date            Modified By     Description
 * -------- ----------  ----------      -----------     ------------    -----------
 * 1.0      CR 11967    16.10           15-Sep-2015     Ragu            LM2_1_33-Ability to assign lead owner by following campaign automation
 * 1.1      CR 11976    16.10           18-Sep-2015     Josie           LM2_1_32-Ability to trigger lead owner assignment with campaign assignment logic
 * 1.2      TFS 199072  16.10           18-Sep-2015     Ragu            Follow-up section updated not properly when account is changed.
 * 1.3      TFS 204993  16.10           26-Oct-2015     Ragu            E2E Regression : Account Executive/PDM is populated even if the DL 2.0 is not associated with an account
 * 1.4      TFS 210953  16.12           26-Nov-2015     Nagendra Singh  Batch Class Error:LM2_1_34: Lead owner recalculation does not work -->Because of 'Assign Leads based on Geo' logic
 * 1.5      CR 12494    16.12           21-Dec-2015     Nagendra Singh  LM2_17_8-Enhance in direct Lead 2.0 the field Lead owner's role
 * 1.6      CR 12505    16.12           01-Jan-2016     Niveda          LM2_12_3- Add option to use only follow up role and skip default assignment
 * 1.7      CR 12505    16.12           18-Jan-2016     Ragu            Code added to set Lead Owner System Auto-Populated when skiping the lead assignment logics based on setting in Campaign.  
 * 2.0      CR 12985    FY17-DCS-0502   29-Mar-2016     Gan             Lead Assignment to Account Owner and priority given to account owner during the lead assignment
 * 2.1      TFS 1702132 FY17-DCS-0502   15-Apr-2016     Gan             LM2_12: Batch reassignment job removes auto-populated checkbox, but not user
 * 3.0      CR 13693    FY17-DCS-0103   10-Dec-2016     Sajith          LM2 New calculation for number days sales to follow up 
 * 4.0      CR 14776    FY18-DCS-1001   15-AUG-2017     Ashok           Enhance lead assignment logic + GCCS lead assignment logic 
 * 4.1      CR 14777    FY18-DCS-1001   15-AUG-2017     Ashok           User Field configuration on Lead from new assignment logic
 * 5.0      CR 14998    FY18-DCS-1101   10-OCT-2017     Ashok           Lead Owner Role population when Assignment logic triggred
 * 6.0      CR 18002    FY20-1002       27-AUG-2019     Kokila          Logic to resrict Master Account on Direct Lead
 * 7.0      CR 18166    FY20-DCS-1101   01-OCT-2019     Kokila          To display Lead Owner Role as 'N/A' when no role applies
*/

public class LeadAssignment {

    // Start: Variables for Lead Assignment Process
    private static Boolean bForcePopulate = false;
    public static String LEAD_TYPE_OUTBOUND = 'Outbound';
    public static void setForcePopulateFields(Boolean bForce) {
        bForcePopulate = bForce;
    }

    private static map<Id, list<Id>> mapAccountIdTerritoryIds;
    public static void setAccountIdTerritoryIds(map<Id, list<Id>> accountIdTerritoryIds) {
        mapAccountIdTerritoryIds = accountIdTerritoryIds;
    }

    private static map<Id, map<String, list<Territory_Sales_User_Assignment__c>>> mapTerritoryIdRoleTSUAs;
    public static void setTerritoryIdRoleTSUAs(map<Id, map<String, list<Territory_Sales_User_Assignment__c>>> territoryIdRoleTSUAs) {
        mapTerritoryIdRoleTSUAs = territoryIdRoleTSUAs;
    }
    // End: Variables for Lead Assignment Process

    // v1.0 - Recalculate the tracking fields to set whether Dell Lead Follow-Up section fields are manually specified or system populated
    public static void evaluateTrackingFields(list<Lead> lstLeads, map<Id, Lead> mapOldLeads) {
        map<String, list<String>> mapTrackingFields = LeadAssignmentHelper.getTrackingFields();
        for(Lead leadIterator: lstLeads) {
            Lead oldLead = mapOldLeads.get(leadIterator.Id);

            for(String strField: mapTrackingFields.keySet()) {
                if(leadIterator.get(strField) != oldLead.get(strField)) {
                    for(String strTrackingField: mapTrackingFields.get(strField)) {
                        leadIterator.put(strTrackingField, false);
                    }
                }
            }
        }
    }

    // v1.0 - Retrieve all related Campaigns and then calls assignDirectLeads2() for actual assignment
    public static void assignDirectLeads2(list<Lead> lstLeads) {
        set<Id> setCampaignIds = new set<Id>();
        for(Lead newLead: lstLeads) {
            setCampaignIds.add(newLead.Campaign__c);
        }
        setCampaignIds.remove(null);
        if(!setCampaignIds.isEmpty()) {
            assignDirectLeads2(lstLeads, new map<Id, Campaign>([select Id, Name, Follow_Up_Role__c, Secondary_Role__c, Force_Follow_Up_Rule_for_Outbound_Leads__c from Campaign where Id in : setCampaignIds]));
        }
    }

    // v1.0 - Check whether Lead is eligible for auto assignment and calls assignDirectLeads2() for actual assignment
    public static void triggerLeadAssignment(list<Lead> lstNewLeads, map<Id, Lead> mapOldLeads, map<Id, Campaign> mapRelatedCampaigns) {
        Id currentUserId = UserInfo.getUserId();
        Id directLeadRTId = StaticFactory.getRecordTypeIdByName('Lead', 'Direct Lead 2.0');
        set<Id> setEligibleCLRTIds = StaticFactory.getRecordTypeIdsByNames('Lead', new set<String> {'Channel Lead - Cleansing & Scoring Complete', 'Channel Lead - Assignment Complete'});
        list<Lead> lstLeadsToProcess = new list<Lead>();
        
        //v6.0 Start - To Avoid Master Group Account
        map<Id,Id> mapLeadAccRecType = new map<Id,Id>();
            Set<Id> setAccId = new set<Id>();
            Id masterGrpAccRTId = StaticFactory.getRecordTypeIdByName('Account', 'Master Account');
            
            for(Lead leadAcc : lstNewLeads){
                setAccId.add(leadAcc.Account__c); 
            }
            
            for(Account acc : [SELECT Id,RecordTypeId FROM Account where id IN :setAccId]){
                mapLeadAccRecType.put(acc.Id, acc.RecordTypeId);
            }
        //v6.0 End - To Avoid Master Group Account

        for(Lead newLead: lstNewLeads) {
            Lead oldLead;
            if(mapOldLeads != null) {
                oldLead = mapOldLeads.get(newLead.Id);
            }
            //system.debug('ZY => newLead.OwnerId :' + newLead.OwnerId);
            if(oldLead == null && newLead.Account__c != null && newLead.OwnerId == currentUserId && (newLead.RecordTypeId != directLeadRTId || (newLead.RecordTypeId == directLeadRTId && mapLeadAccRecType.get(newLead.Account__c) != masterGrpAccRTId))) { 
            //v6.0 Added condition to Avoid Master Group Account
                lstLeadsToProcess.add(newLead);
            }
            // v1.1 - Added newLead.Trigger_Lead_Assignment__c == true in below else part
            else if(oldLead != null && newLead.Account__c != null &&(newLead.Trigger_Lead_Assignment__c == true ||(newLead.RecordTypeId == directLeadRTId && setEligibleCLRTIds.contains(oldLead.RecordTypeId)))) {
                lstLeadsToProcess.add(newLead);
                bForcePopulate = true; // v1.2
            }
            newLead.Trigger_Lead_Assignment__c = false; // v1.1
        }

        // v1.3 - Added below !lstLeadsToProcess.isEmpty() condition
        if(!lstLeadsToProcess.isEmpty()) {
            assignDirectLeads2(lstLeadsToProcess, mapRelatedCampaigns);

            // Below line is necessary until logics from CMAP_BeforeInsertUpdateLeadTrigger trigger is moved to CBO architecture
            LeadFieldPopulator.populateLeadOwnerDetails(lstLeadsToProcess);
            LeadFieldPopulator.populateSalesAssignedDate(lstLeadsToProcess, mapOldLeads);//3.0
        }
    }

    private static void assignDirectLeads2(list<Lead> lstLeads, map<Id, Campaign> mapRelatedCampaigns) {
        // Code Block Start: Data Preparation
        // Get Accounts
        map<Id, Account> mapRelatedAccounts = LeadAssignmentHelper.queryAccounts(lstLeads);
        System.debug('**In assignDirectLeads2 1'+lstLeads);

        // Get Campaign Roles
        set<String> setCampaignRoles = LeadAssignmentHelper.getCampaignRoles(lstLeads, mapRelatedCampaigns);
        setCampaignRoles.addAll(LeadAssignmentHelper.getAdditionalRoles());

        // Get Account Team Members
        map<Id, map<String, list<Id>>> mapAccoutRoleUserIds = LeadAssignmentHelper.getAccountIdRoleTeamMemberMap(mapRelatedAccounts.keySet(), setCampaignRoles);

        // Get Territory Details
        LeadAssignmentHelper.prepareTerritoryDetails(lstLeads, mapRelatedCampaigns, mapRelatedAccounts);

        map<string,map<String, list<String>>> mapDefaultRoles = LeadAssignmentHelper.getDefaultRoles();
       // map<String, map<String, String>> mapOwnerFieldConfiguration = LeadAssignmentHelper.getOwnerFieldConfiguration(); //4.0
        map<string,map<String, map<String, list<String>>>> mapUserFieldConfiguration = LeadAssignmentHelper.getUserFieldConfiguration();//4.1
        map<String, list<String>> mapTrackingFields = LeadAssignmentHelper.getTrackingFields();
        
        //2.0
        map<Id, set<String>> mapAccIdOwnerRolesInTeam = LeadAssignmentHelper.getAccIdOwnerRolesInTeamMap(mapRelatedAccounts, mapAccoutRoleUserIds);
        initializeTrackingFields(lstLeads);
        // Code Block End: Data Preparation
         
        //Map Users to populate lead owners role if the lead owner is a createdByID --5.0
        set<Id> setOwnerIds = new set<Id>();
        Id currentUserId = UserInfo.getUserId();
        for(Lead lI: lstLeads){
           if(lI.Lead_Type__c == LEAD_TYPE_OUTBOUND && !setOwnerIds.Contains(CurrentUserId))
           setOwnerIds.add(currentUserId);
        }
        
        //5.0
        //map<Id, set<String>> mapAccIdOwnerRole;// = LeadAssignmentHelper.getAccIdOwnerRolesInTeamMap1(mapRelatedAccounts,setOwnerIds);
        map<Id, Map<Id,String>> mapAccIdOwnerRole = LeadAssignmentHelper.getAccIdOwnerRolesInTeamMap1(mapRelatedAccounts,setOwnerIds);
        
        map<Id, User> mapUsers = (!setOwnerIds.isEmpty())?new map<Id,User>([Select id,Resource_Manager_Role__c from user where id in :setOwnerIds and IsActive = TRUE]):new map<Id,User>(); //8.0             
        //5.0 -END
        for(Lead leadIterator: lstLeads) {
            Campaign campaignIterator = mapRelatedCampaigns.get(leadIterator.Campaign__c);
            Account accountIterator = mapRelatedAccounts.get(leadIterator.Account__c);

            // v1.4 - Added "accountIterator != null" condition check
            if(accountIterator != null) {
                map<String, list<Id>> mapRoleUserIds = mapAccoutRoleUserIds.get(leadIterator.Account__c);
                system.debug(LOGGINGLEVEL.INFO,'-=-=-=-=-=-=-=-='+mapRoleUserIds);
                //2.1
                //Get the Account Classification Type : If it is Enterprise return Enterprise else Return COMMERCIAL/OTHER.
                //string AccClassification = (accountIterator.Account_ClassificationSCG__c!='' && accountIterator.Account_ClassificationSCG__c!=null)?accountIterator.Account_ClassificationSCG__c.toUpperCase():'COMMERCIAL/OTHER';
                string AccClassification = (accountIterator.Account_Classification__c!='' && accountIterator.Account_Classification__c!=null && accountIterator.Account_Classification__c.equalsIgnoreCase('ENTERPRISE'))?accountIterator.Account_Classification__c.toUpperCase():'OTHER'; //4.0 & 4.1
                map<String, list<String>> mapFields = mapUserFieldConfiguration.get(AccClassification).get(AccountIterator.RecordType.Name); //4.1
                system.debug(LoggingLevel.INFO,'///////////////////////'+mapFields);
                cleanUpUserFields(leadIterator, mapFields);
                
                // Populate User fields in Lead
                if(mapRoleUserIds != null && !mapRoleUserIds.isEmpty()) {
                    System.debug('Populate User fields in Dell Lead Follow-Up section');
                    // 2.1
                    //map<String, list<String>> mapFields = mapUserFieldConfiguration.get(accountIterator.RecordType.Name);
                    //2.0
                    populateUserFields(leadIterator, mapFields, mapRoleUserIds, mapTrackingFields, accountIterator, mapAccIdOwnerRolesInTeam);
                }
                
                
                // 1. Assign Leads based on Campaign Follow_Up_Role__c & Secondary_Role__c
                System.debug('1. Assign Leads based on Campaign Follow_Up_Role__c & Secondary_Role__c');
                /*Commented AlternateRoles as part of 4.0 changes
                map<String, String> mapAlternateRoles = mapOwnerFieldConfiguration.get(accountIterator.RecordType.Name);
                String strPrimaryRole =(mapAlternateRoles.containsKey(campaignIterator.Follow_Up_Role__c) ? mapAlternateRoles.get(campaignIterator.Follow_Up_Role__c) : campaignIterator.Follow_Up_Role__c);
                String strSecondaryRole =(mapAlternateRoles.containsKey(campaignIterator.Secondary_Role__c) ? mapAlternateRoles.get(campaignIterator.Secondary_Role__c) : campaignIterator.Secondary_Role__c);
                */
                //4.0 start
                String strPrimaryRole = campaignIterator.Follow_Up_Role__c;
                String strSecondaryRole = campaignIterator.Secondary_Role__c;
                // Introduced FollowUp Role Configuration
                map<string,set<string>> mapFollowUpRoles = leadAssignmentHelper.getFollowUpRoleConfiguration();
                set<string> FPRoles = mapFollowUpRoles.containsKey(strPrimaryRole)?mapFollowUpRoles.get(strPrimaryRole):new set<string>();
                set<string> FSRoles = mapFollowUpRoles.containsKey(strSecondaryRole)?mapFollowUpRoles.get(strSecondaryRole):new set<string>();
                   //For suppose if primary role is Inside sales Rep, as per the new flow the order of the team members to be picked
                   //it first have to search for 'Inside Sales Rep' ->if the role user doesnt exist in the account that is mapped then it goes searching
                   // 'Client & Compute Inside Sales Rep' if CCSE doesnt exist then it search for 'Inside Channel Account Manager.. if not so then it populate Account owner as lead owner
                   if(!FPRoles.isEmpty()){
                        for(string s:FPRoles){
                         if(mapRoleUserIds != null && !mapRoleUserIds.isEmpty() && mapRoleUserIds.containsKey(s)){
                           strPrimaryRole = s;
                           break;
                         }
                       }
                   }
                                      
                   if(!FSRoles.isEmpty()){
                      system.debug(LOGGINGLEVEL.INFO,'-=-=-=-=-=-=-=-=-=-=-=-=-BREAK'+strSecondaryRole);
                      for(String s1:FSRoles){
                         if(mapRoleUserIds != null && !mapRoleUserIds.isEmpty() && mapRoleUserIds.containsKey(s1)){
                           strSecondaryRole = s1;
                           break;
                         }
                       }
                  }
                 //4.0 End
                 system.debug(LOGGINGLEVEL.INFO,'@@@@@@@@@@@@@@@@@@@@@@@@'+strPrimaryRole+' '+strSecondaryRole);
                //2.0    
                if(strPrimaryRole == 'Account Owner') {
                    if(accountIterator.OwnerId != null) {
                        leadIterator.OwnerId = accountIterator.OwnerId;
                            
                        leadIterator.Lead_Owner_System_Auto_Populated__c = true;
                        leadIterator.Lead_Found_Designated_Follow_Up_Role__c = true;
                            
                        // v1.5 Populate correct lead owner from account team
                        leadIterator.Lead_Owner_Role__c = strPrimaryRole;
                        System.debug('Assigned primary Account Owner ');
                        continue;
                    }
                }
                else if(mapRoleUserIds != null && !mapRoleUserIds.isEmpty() && mapRoleUserIds.get(strPrimaryRole) != null) {
                    
                    system.debug(LoggingLevel.INFO,''+mapRoleUserIds+' &&&&&&&&& '+mapAccIdOwnerRolesInTeam);

                    if(mapAccIdOwnerRolesInTeam.get(accountIterator.Id) != null && mapAccIdOwnerRolesInTeam.get(accountIterator.Id).contains(strPrimaryRole)) {
                        leadIterator.OwnerId = accountIterator.OwnerId;
                    }
                    else {
                        leadIterator.OwnerId = mapRoleUserIds.get(strPrimaryRole)[0];//LeadAssignmentHelper.ownerFieldPopulate(AccClassification,strPrimaryRole,mapRoleUserIds);//mapRoleUserIds.get(strPrimaryRole)[0]; //do changes to fetch on account 
                        system.debug(LOGGINGLEVEL.INFO,'------------OwnerId:'+leadIterator.OwnerId);
                    }
                            
                    leadIterator.Lead_Owner_System_Auto_Populated__c = true;
                    leadIterator.Lead_Found_Designated_Follow_Up_Role__c = true;
                      
                    // v1.5 Populate correct lead owner from account team
                    leadIterator.Lead_Owner_Role__c = strPrimaryRole;
                    System.debug('Assigned primary Role ');      
                    continue;
                }
                     
                if(strSecondaryRole == 'Account Owner') {
                    if(accountIterator.OwnerId != null) {
                        leadIterator.OwnerId = accountIterator.OwnerId;
                        leadIterator.Lead_Owner_System_Auto_Populated__c = true;
                        leadIterator.Lead_Found_Designated_Follow_Up_Role__c = true;
                        
                        // v1.5 Populate correct lead owner from account team
                        leadIterator.Lead_Owner_Role__c = strSecondaryRole;
                        System.debug('Assigned Secondary Account Owner ');      
                        continue;
                    }
                }
                else if(mapRoleUserIds != null && !mapRoleUserIds.isEmpty() && mapRoleUserIds.get(strSecondaryRole) != null) {
                    //2.0
                        
                    if(mapAccIdOwnerRolesInTeam.get(accountIterator.Id) != null && mapAccIdOwnerRolesInTeam.get(accountIterator.Id).contains(strSecondaryRole)) {
                        leadIterator.OwnerId = accountIterator.OwnerId;
                    }
                    else {
                        leadIterator.OwnerId = mapRoleUserIds.get(strSecondaryRole)[0];//LeadAssignmentHelper.ownerFieldPopulate(AccClassification,strSecondaryRole,mapRoleUserIds);///mapRoleUserIds.get(strSecondaryRole)[0];
                    }
                        
                    leadIterator.Lead_Owner_System_Auto_Populated__c = true;
                    leadIterator.Lead_Found_Designated_Follow_Up_Role__c = true;
                        
                    // v1.5 Populate correct lead owner from account team
                    leadIterator.Lead_Owner_Role__c = strSecondaryRole;
                    System.debug('Assigned secondary Role ');      
                    continue;
                }
                
                // v1.6, v1.7 - If Force_Follow_Up_Rule_for_Outbound_Leads__c is true for Outbound leads then below assignment logics(2, 3 & 4) should not be fired.  
                if(leadIterator.Lead_Type__c == LEAD_TYPE_OUTBOUND && campaignIterator.Force_Follow_Up_Rule_for_Outbound_Leads__c) {
                    //2.0 make sure the creator will be the lead owner if creator is not null
                    if(leadIterator.CreatedById != null)
                    {
                        leadIterator.OwnerId = leadIterator.CreatedById;
                    }
                    
                                        
                    //Check whether the Lead Owner Id exist in Account team member or not.
                    if(mapAccIdOwnerRole.get(accountIterator.Id) != null && mapAccIdOwnerRole.get(accountIterator.Id).containsKey(LeadIterator.OwnerId)){
                        leadIterator.Lead_Owner_Role__c = mapAccIdOwnerRole.get(accountIterator.Id).get(LeadIterator.OwnerId);
                    } //if Lead Owner is not in Account Team Members then next priority to search for Owners Resource Manager Role
                    else if(!mapUsers.isEmpty() && mapUsers.containsKey(LeadIterator.OwnerId) && mapUsers.get(LeadIterator.OwnerId).Resource_Manager_Role__c != null){
                        leadIterator.Lead_Owner_Role__c = mapUsers.get(LeadIterator.OwnerId).Resource_Manager_Role__c;
                    }//if Resource manager Role is blank - check if account Owner and Lead Owner are same?
                    else if(accountIterator.OwnerId == LeadIterator.OwnerId){
                        leadIterator.Lead_Owner_Role__c = 'Account Owner';
                    }else{
                        leadIterator.Lead_Owner_Role__c = 'N/A'; //5.0
                    }
                    
                    system.debug('-=-=-=-=-=-=->'+LeadIterator.OwnerId);
                    
                    // Set the Lead_Owner_System_Auto_Populated__c field to true so that this Lead can be fetched by Batch_RecalculateLeadOwner for auto assignment.
                    leadIterator.Lead_Owner_System_Auto_Populated__c = true;
                    System.debug('Assigned Lead Creator ');    
                    continue;
                }
                
                
                // 2. Assign Leads based on Geo
                // v1.4 - Added "&& mapAccountIdTerritoryIds.containsKey(accountIterator.Id)" condition check
                if(mapAccountIdTerritoryIds != null && mapTerritoryIdRoleTSUAs != null && !mapAccountIdTerritoryIds.isEmpty() && !mapTerritoryIdRoleTSUAs.isEmpty() && mapAccountIdTerritoryIds.containsKey(accountIterator.Id)) {
                    System.debug('2. Assign Leads based on Geo');
                    for(Id territoryId: mapAccountIdTerritoryIds.get(accountIterator.Id)) {
                        map<String, list<Territory_Sales_User_Assignment__c>> mapRoleTSUAs = mapTerritoryIdRoleTSUAs.get(territoryId);
                        if(mapRoleTSUAs != null && mapRoleTSUAs.containsKey(campaignIterator.Follow_Up_Role__c)) {
                            Territory_Sales_User_Assignment__c territorySUA = mapRoleTSUAs.get(campaignIterator.Follow_Up_Role__c)[0];
                            leadIterator.OwnerId = territorySUA.User__c;
                            leadIterator.Lead_Owner_System_Auto_Populated__c = true;
                            leadIterator.Geo_Populated__c = true;
                            
                            // v1.5 Populate correct lead owner from account team
                            leadIterator.Lead_Owner_Role__c = territorySUA.Role__r.Name;
                            System.debug('Assigned Geo');      
                            break;
                        }
                    }
                    if(leadIterator.Lead_Owner_System_Auto_Populated__c) {
                        continue;
                    }
                }


                // 3. Assign Leads based on default roles(mentioned in the list lstDefaultRole)
                if(mapRoleUserIds != null && !mapRoleUserIds.isEmpty()) {
                    System.debug('3. Assign Leads based on default roles(mentioned in the list lstDefaultRole)');
                    
                      //4.0 -> Default role logic is pulled based on Type of Account i.e., ENTERPRISE and OTHER(COMMERCIAL/...)
                      for(String strRole: mapDefaultRoles.get(AccClassification).get(accountIterator.RecordType.Name)) {
                        //2.0
                        if(mapAccIdOwnerRolesInTeam.get(accountIterator.Id) != null && mapAccIdOwnerRolesInTeam.get(accountIterator.Id).contains(strRole)) {
                            leadIterator.OwnerId = accountIterator.OwnerId;
                            leadIterator.Lead_Owner_System_Auto_Populated__c = true;
                            
                            // v1.5 Populate correct lead owner from account team
                            leadIterator.Lead_Owner_Role__c = strRole;
                            System.debug('Assigned Default Account Owner Role ');      
                            break;
                        }
                        else if(mapRoleUserIds.get(strRole) != null) {
                            leadIterator.OwnerId = mapRoleUserIds.get(strRole)[0];
                            leadIterator.Lead_Owner_System_Auto_Populated__c = true;
                            
                            // v1.5 Populate correct lead owner from account team
                            leadIterator.Lead_Owner_Role__c = strRole;
                            System.debug('Assigned Default Role ');      
                            break;
                        }
                    }
                    if(leadIterator.Lead_Owner_System_Auto_Populated__c) {
                        continue;
                    }
                }
                
                
                // 4. Assign Leads to Account Owner if nothing above worked
                System.debug('4. Assign Leads to Account Owner if nothing above worked');
                leadIterator.OwnerId = accountIterator.OwnerId;
                leadIterator.Lead_Owner_System_Auto_Populated__c = true;
                System.debug('Assigned Last resource Account Owner Role ');      
                // v1.5 - Populate correct lead owner from account team
                system.debug('mapAccIdOwnerRole :'+mapAccIdOwnerRole);
                //5.0
                
                //Check whether the Lead Owner Id exist in Account team member or not.
                if(mapAccIdOwnerRole.get(accountIterator.Id) != null && mapAccIdOwnerRole.get(accountIterator.Id).containsKey(LeadIterator.OwnerId)){
                    //list<string> listStrRoles = new list<string>(mapAccIdOwnerRole.get(accountIterator.Id));
                    leadIterator.Lead_Owner_Role__c = mapAccIdOwnerRole.get(accountIterator.Id).get(LeadIterator.OwnerId);
                } //if Lead Owner is not in Account Team Members then next priority to search for Owners Resource Manager Role
                else if(accountIterator.Owner.Resource_Manager_Role__c != '' && accountIterator.Owner.Resource_Manager_Role__c!=null){
                    leadIterator.Lead_Owner_Role__c = accountIterator.Owner.Resource_Manager_Role__c;
                }//if Resource manager Role is blank - Update the Lead Owner Role as Account Owner
                else if(accountIterator.OwnerId == LeadIterator.OwnerId){ //v7.0 - Added condition for 'Account Owner' role and populate 'N/A' if no role 
                    leadIterator.Lead_Owner_Role__c = 'Account Owner';
                }else{
                    leadIterator.Lead_Owner_Role__c = 'N/A'; 
                }
                
            }
        }
    }

    //2.1
    private static void cleanUpUserFields(Lead leadIterator, map<String, list<String>> mapFields) {
        for(String strField: mapFields.keySet()) {
            if(bForcePopulate) {
                leadIterator.put(strField, null);
            }
        }
    }
    
    // v1.0 - Set all applicable tracking fields as false before auto assignmentinitializeTrackingFields
    private static void initializeTrackingFields(list<Lead> lstLeads) {
        map<String, list<String>> mapTrackingFields = LeadAssignmentHelper.getTrackingFields();
        for(Lead leadIterator: lstLeads) {
            // v1.6 - Below line added
            leadIterator.Lead_Found_Designated_Follow_Up_Role__c = false;
            for(String strField: mapTrackingFields.keySet()) {
                for(String strTrackingField: mapTrackingFields.get(strField)) {
                    leadIterator.put(strTrackingField, false);
                }
            }
        }
    }

    // v1.0 - Populate user fields in the Dell Lead Follow-Up section(Inside_Sales_Rep_ICAM__c, ISM_Channel_ISM__c, Account_Executive_PDM__c & RSM__c)
    private static void populateUserFields(Lead leadIterator, map<String, list<String>> mapFields, map<String, list<Id>> mapRoleUserIds, map<String, list<String>> mapTrackingFields, 
            // 2.0
            Account acc, map<Id, set<String>> mapAccIdOwnerRolesInTeam) {
        
        for(String strField: mapFields.keySet()) {
            // 2.1 remove the clear user fields here and move to the caller

            if(leadIterator.get(strField) == null) {
                for(String strRole: mapFields.get(strField)) {
                    //2.0
                    if(mapAccIdOwnerRolesInTeam.get(acc.Id) != null && mapAccIdOwnerRolesInTeam.get(acc.Id).contains(strRole)) {
                        leadIterator.put(strField, acc.OwnerId);
                        for(String strTrackingField: mapTrackingFields.get(strField)) {
                            leadIterator.put(strTrackingField, true);
                        }
                        break;
                    }
                    else if(mapRoleUserIds.containsKey(strRole)) {
                        leadIterator.put(strField, mapRoleUserIds.get(strRole)[0]);
                        for(String strTrackingField: mapTrackingFields.get(strField)) {
                            leadIterator.put(strTrackingField, true);
                        }
                        break;
                    }
                }
            }
        }
    }

}