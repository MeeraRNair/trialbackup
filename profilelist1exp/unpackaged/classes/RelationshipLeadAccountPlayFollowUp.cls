/***********************************************************
* Name          : RelationshipLeadAccountPlayFollowUp 
* Description   : Relationship Lead / Account Play Follow-Up functionality
* ---------------------------------------------------------
* Revision  Name    Date        Release Description
* 1.0       MenMee  17.09.2009          CR 1871 Relationship Lead Follow-Up functionality
                                        CR 1874 Acocunt Play Follow-Up functionality
* 1.1       MenMee  05.10.2009          Change object and field API name
* 1.2       MenMee  06.10.2009          Remove Account Executive field for Account Play Object  
* 1.3       Meera   10.12.2009          Updated as part of CR 2234 Task Creation        
* 1.4       MenMee  30.12.2009          CR 2279 Skip creating new RL when run test
* 1.5       Meera   31.12.2009          Updated as part of CR 2043 Update Logic for Auto Email Notifications sent to Sales for Campaign Members Requiring Follow-up
* 1.6       MenMee  09.02.2010          CR 2400 Adding Account Owner as a Follow-up Role in Campaign
* 1.7       MenMee  10.02.2010          CR 2394 ISM, RSM and AVP need to be mapped to Relationship Lead when it is created from Campaign Member.
* 1.8       MenMee  20.04.2010  11.3    Defect 57776: CR 2371 Ability to differentiate/identify AP/RL records that had Account
*                                       add new isTriggerFireBefore flag to avoid trigger fire twice that caused by a "RL - Update Rel. Lead Close Date" workflow
* 2.0       MenMee  15.06.2010  11.7    CR 2728 Add AE field to Account Play record
* 3.0       JP      21.04.2011  12.5    CR 5571 Improve logic to assign owner to a RL-AP
* 4.0       MenMee  21.06.2011  12.7    CR 6343 Lead Form ID,Omniture Visitor ID,LiveBall Respondent ID,Dell Visitor ID need to be mapped to Relationship Lead when it is created from Campaign Member.
* 4.1       MenMee  28.06.2011  12.7    CR 6340 Lead-CM-RL conversion
* 5.0       MenMee  04.08.2011  12.10   CR 6505 Populate Next Steps and Supporting Info from Campaign to RL
* 5.1       MenMee  09.08.2011  12.10   CR 6256 Populate Eloqua Id from Lead to CM/RL or from CM to RL
* 6.0       Jessie  19.10.2011  13.1    CR 6449 Populate Solution ID to RL from Campaign Member
* 6.1       Jagadeesan 20.05.2012 13.7  CR 7168 Byassignment Logic if Account Executive or Inside Sales Rep or Relationship Lead Owner has got values from CM upload file
* 6.2       Jagadeesan 23.05.2012 13.7  CR 7178 Populate the SalesComments,Marketing Comments  Lead To RL while creating RL
* 6.3       Jagadeesan 13.07.2012 13.7  CR 7171 Populate Eloqua Lead score from Lead ->RL and CM -> RL
* 6.4       Jagadeesan 04.12.2013 14.2  CR 7701 Populate form URL and Form Referrer fields from CM -> RL
* 7.0       Anamika    04.12.2013 14.5  CR 8204 Added if-else condition to create RL.
* 8.0       Meghana     09.05.2014 15.07 CR 9437 Give preference to Account Owner while assigning RL/AP Owner
* 8.1       Meghana     16.05.2014 15.07 CR 9445 Auto-Populate Lead Score for Lead Qualification
* 8.2       Meghana     26.05.2014       CR 9445 Correct picklist value in if condition since picklist value was modified as part of CR 8353
* 9.0       Impana      27.05.2014 15.07 CR 9533 Added the functionality of Territory User Assignment for RL/AP owner assignment
* 9.1       Impana      27.05.2014       CR 9533 Populate Territory_sales_user_assignment field in RL/AP     
* 10.0      Meghana     11-Sep-2014      CR 10086 Replace Lead_Capture_Date with new datetime field
* 11.0      Shahiruni   12-Jan-2015      CR 10608 Assign AP/RL Owner by Secondary Role if Follow-Up Role is empty    
* 12.0      Impana      19-Jan-2015      CR 10831  Check for Account type and search in Channel Roles for assignment if it's an Channel Account
* 13.0      Anwar       28-Aug-2015      CR 11851  Assign AP/RL Owner correctly From Account team roles and Campaign follow up role
* 14.0      Ananth      07-Sep-2015      CR 11926  Assign AP/RL owner based on the Badge number in descending order.
************************************************************/

public class RelationshipLeadAccountPlayFollowUp {
     
    public static boolean isBeforeException = false;
    public static boolean isAfterException = false;
    public static boolean disableRLAutoCreation = false; //Rev 1.3
    public static boolean isTriggerFireBefore = false;   //Rev 1.8
    /*public static Map<ID , List<ID>> AccidtoTSAid = new Map<ID ,List<ID>>();
    public static Map<ID, territory_sales_user_Assignment__c> TSAmap = new map<ID , Territory_sales_user_assignment__c>();*/

    
    // called by Relationship Lead Trigger
   /* public static void populateOwnerAndSpecifiedRoleField(Set<id> CampaignIdSet, Set<id> ContactIdSet, List<Relationship_Lead__c> relationshipLeadList){
        populateOwnerAndSpecifiedRoleField(CampaignIdSet, ContactIdSet, relationshipLeadList, new Map<id,List<SObject>>());
    }   
        
    // called by Account Play Trigger
    public static void populateOwnerAndSpecifiedRoleField(Set<id> CampaignIdSet, Map<id,List<Account_Play__c>> accIdToRelationshipLeadOrAccountPlayListMap){
        populateOwnerAndSpecifiedRoleField(CampaignIdSet, new Set<id>(), new List<Relationship_Lead__c>(), accIdToRelationshipLeadOrAccountPlayListMap);
    }
        
    // Populate Campaign's 'Follow-Up Role' to Owner field and populate ISR and AE team member to ISR and AE field
    public static void populateOwnerAndSpecifiedRoleField(Set<id> CampaignIdSet, Set<id> ContactIdSet, List<Relationship_Lead__c> relationshipLeadList, Map<id, List<SObject>> accIdToRelationshipLeadOrAccountPlayListMap){
         
                                            
        system.debug('## Inside Method populateOwnerAndSpecifiedRoleField  ##');
        throwTestException(isBeforeException);
         
        //rev 12.0 
        Schema.DescribeSObjectResult d = Schema.SObjectType.Account;
        Map<Id,Schema.RecordTypeInfo> ACCRTMAP = d.getRecordTypeInfosById();
        Map<Id, String> AccIdToRTIdMap = new Map<ID,String>(); 
        // rev 12.0 end
        
        //Rev 3.0 - declare a New Map
        Map<String,Map<String,Id>> accIdToRLorAPListMap = new Map<String,Map<String,Id>>(); 
        
        Map<String,String> campIdToFollowUpRoleMap = new Map<String,String>();      
        Map<String,Id> roleToUserIdMap = new Map<String,Id>();          
        Id accountIdOfContact, currentAccountId1;
        
        // collects the required roles in to a set for using in SOQL query      
        Set<String> requiredRoleSet = new Set<String> {'Account Executive' ,'Inside Sales Rep'};
        Set<String> RequiredGeoRoleSet = new Set<String>();
         //rev 12.0 
        Map<Id, String> ATMtoRoleMap = new Map<Id, String>(); 
        Set<String> ChannelRoleset = new set<String>{'Partner Development Manager','Inside Channel Account Manager'};
        //rev 12.0 end 
        //11.0 To map Campaign Id to Secondary Role
        Map<String,String> campIdToSecondaryRoleMap = new Map<String,String>();  
        
        Map<Id, Id> AccIdToAccOwnerMap = new Map<ID, ID>(); //rev 8.0
         
        
        // Makes a contact Id => Contact Map
        if (ContactIdSet.size() > 0) {
            Map<Id,Contact> contactMap = new Map<Id,Contact>([SELECT Id,AccountId , Account.OwnerId, Account.ShippingState, Account.RecordtypeId
                                                          FROM Contact 
                                                          WHERE Id IN :ContactIdSet]);
                       system.debug('IN if');
            // Adds the Campaign Member records from contactCampaignMemberList to accIdToRelationshipLeadListMap
            for(Relationship_Lead__c relationshipLeadItem: relationshipLeadList) { 
                accountIdOfContact = contactMap.get(relationshipLeadItem.Contact__c).AccountId;
system.debug('in for');
                //rev 8.0 - create a map of Account to Account Owner
                if (AccIdToAccOwnerMap.get(contactMap.get(relationshipLeadItem.Contact__c).AccountId) == null)
                    AccIdToAccOwnerMap.put(contactMap.get(relationshipLeadItem.Contact__c).AccountId, contactMap.get(relationshipLeadItem.Contact__c).Account.OwnerId);
                //rev 8.0 - end
                
                //rev 12.0 - Create a map of AccountID to Recordtype Name
                If(AccIdToRTIdMap.get(contactMap.get(relationshipLeadItem.Contact__c).AccountId) == NULL)
                    AccIdToRTIdMap.put(contactMap.get(relationshipLeadItem.Contact__c).AccountId, ACCRTMAP.get(contactMap.get(relationshipLeadItem.Contact__c).Account.RecordtypeId).getname());
                //rev 12.0 - end
                
                
                if(accIdToRelationshipLeadOrAccountPlayListMap.get(accountIdOfContact)== null)
                    accIdToRelationshipLeadOrAccountPlayListMap.put(accountIdOfContact, new List<Relationship_Lead__c>{relationshipLeadItem}); 
                else{ 
                    accIdToRelationshipLeadOrAccountPlayListMap.get(accountIdOfContact).add(relationshipLeadItem);
                }  
                system.debug('end for');        
            }   
            system.debug('## accIdToCampMembListMap.size()=' + accIdToRelationshipLeadOrAccountPlayListMap.size());             
           
        }
         
        // Makes a map of Campaign Id=> Follow-up role
        /*
        for(Campaign campaignItem: [SELECT Id,Follow_Up_Role__c
                                    FROM Campaign 
                                    WHERE Id IN :campaignIdSet
                                    AND Follow_Up_Role__c!=null]) {
                                     
            system.debug('## campaignItem.Id=' + campaignItem.Id + ', Follow_Up_Role__c=' + campaignItem.Follow_Up_Role__c);    
            campIdToFollowUpRoleMap.put(String.valueOf(campaignItem.Id), campaignItem.Follow_Up_Role__c);   
                            
            requiredRoleSet.add(campaignItem.Follow_Up_Role__c);     
            RequiredGeoRoleSet.add(campaignItem.Follow_Up_Role__c);       
        }
        */
        
        //11.0 
        // Makes a map of Campaign Id=> Follow-up role & Secondary Role
       /* for(Campaign campaignItem: [SELECT Id,Follow_Up_Role__c,Secondary_Role__c 
                                    FROM Campaign 
                                    WHERE Id IN :campaignIdSet
                                    AND Follow_Up_Role__c!=null]) {
                                     
            system.debug('## campaignItem.Id=' + campaignItem.Id + ', Follow_Up_Role__c=' + campaignItem.Follow_Up_Role__c);    
            campIdToFollowUpRoleMap.put(String.valueOf(campaignItem.Id), campaignItem.Follow_Up_Role__c);
            
            requiredRoleSet.add(campaignItem.Follow_Up_Role__c);
            ChannelRoleset.add(campaignItem.Follow_Up_Role__c); // Rev 13.0        
            RequiredGeoRoleSet.add(campaignItem.Follow_Up_Role__c);       
            
            //11.0 
            if(campaignItem.Secondary_Role__c != null){
                campIdToSecondaryRoleMap.put(String.valueOf(campaignItem.Id), campaignItem.Secondary_Role__c); 
                requiredRoleSet.add(campaignItem.Secondary_Role__c);
                ChannelRoleset.add(campaignItem.Secondary_Role__c); // Rev 13.0
            }
        }
        
        
        system.debug('## requiredRoleSet =' + requiredRoleSet); 
            
        // currentAccountId keeps the AccountID that is being processed
        currentAccountId1 = null;
        
        //rev 8.0
        //Get Account Owners for Account Plays
        //if ContactIdSet & relationshipLeadList are empty i.e. if method called from Account Play trigger and not from RL trigger
        if (ContactIdSet.size() == 0 && relationshipLeadList.size() ==0 ) {
            for (Account acc : [Select id, OwnerId,RecordtypeId from Account Where id in :accIdToRelationshipLeadOrAccountPlayListMap.keySet()]){
                if (AccIdToAccOwnerMap.get(acc.Id) == null)
                    AccIdToAccOwnerMap.put(acc.Id, acc.OwnerId);
                
                //rev 12.0    
                If(AccIdToRTIdMap.get(acc.Id) == NULL)
                    AccIdToRTIdMap.put(acc.id, ACCRTMAP.get(acc.RecordtypeId).getname());    
                //rev 12.0     
            }           
        }
        //rev 8.0 -- end
        
       
        
        // SOQL query teakes the AccTeamMembs in order of AccountId,TeamMemberRole and LastModifiedDate
        for (AccountTeamMember  accountTeamMemberItem : [SELECT Id, User.Id,User.Badge_Number__c, AccountId, TeamMemberRole
                                                         FROM AccountTeamMember
                                                         WHERE AccountId IN :accIdToRelationshipLeadOrAccountPlayListMap.keySet()                                                                                                            
                                                         AND (TeamMemberRole IN :requiredRoleSet OR TeamMemberRole IN :ChannelRoleset)
                                                         AND User.IsActive = True      
                                                         ORDER BY User.Badge_Number__c ASC]) {// Rev 13.0
                                                         
                    
                    system.debug('Accounttemmemberitem ##' + accountTeamMemberItem );
                    
                   //rev 12.0 
                   IF(ATMtoRoleMap.get(accountTeamMemberItem.Id) == NULL)
                       ATMtoRoleMap.put(accountTeamMemberItem.Id , accountTeamMemberItem.TeamMemberRole);
                   
                   System.debug('ATMtoRoleMap###########'+ATMtoRoleMap);
                   //rev 12.0 end
                   
                    
                   // AccTeamMember.add(accountTeamMemberItem.User.Id);
                   // AccTeamMemberRole.add(accountTeamMemberItem.TeammemberRole);
                    
                    //Rev 3.0 - If no AccountId found, Create new map of AccountID, TeamMemberRole => UserId    
                    if(accIdToRLorAPListMap.get(accountTeamMemberItem.AccountId) == null){
                        
                        //rev 12.0 update accIdToRLorAPListMap based on the recordtype of the Account
                        IF((AccIdToRTIdMap.get(accountTeamMemberItem.AccountId) == 'End-User Account' && RequiredRoleSet.CONTAINS(ATMtoRoleMap.get(accountteammemberitem.id))) || (AccIdToRTIdMap.get(accountTeamMemberItem.AccountId) == 'Partner Account' && ChannelRoleset.CONTAINS(ATMtoRoleMap.get(accountteammemberitem.id)))){
                                  system.debug('before main Map');
                           accIdToRLorAPListMap.put(accountTeamMemberItem.AccountId, new Map<String,Id>{accountTeamMemberItem.TeamMemberRole=>accountTeamMemberItem.User.Id}); 
                         }
                        //rev 12.0 end
                        
                        //accIdToRLorAPListMap.put(accountTeamMemberItem.AccountId, new Map<String,Id>{accountTeamMemberItem.TeamMemberRole=>accountTeamMemberItem.User.Id}); 
                    }
                    else
                    {
                        //rev 8.0 - Give preference to Account Owner
                        
                        /*Id assignedAccTeamMember;
                        if(accIdToRLorAPListMap.get(accountTeamMemberItem.AccountId).get(accountTeamMemberItem.TeamMemberRole) != null){
                            assignedAccTeamMember = accIdToRLorAPListMap.get(accountTeamMemberItem.AccountId).get(accountTeamMemberItem.TeamMemberRole);
                        }

                        if (assignedAccTeamMember == null || assignedAccTeamMember != AccIdToAccOwnerMap.get(accountTeamMemberItem.AccountId)){
                            //Rev 3.0 - Adding TeamMemberRole => UserId into map
                            accIdToRLorAPListMap.get(accountTeamMemberItem.AccountId).put(accountTeamMemberItem.TeamMemberRole,accountTeamMemberItem.User.Id);
                        }
                        */
                        
                        //if no user added to Map for given role Or if current Account Team Member is Account Owner
                        //Get latest user assigned to the specified role
                       /* if(accIdToRLorAPListMap.get(accountTeamMemberItem.AccountId).get(accountTeamMemberItem.TeamMemberRole) == null
                           || AccIdToAccOwnerMap.get(accountTeamMemberItem.AccountId) == accountTeamMemberItem.User.Id){
                           
                           //rev 12.0
                           String temp = accountTeamMemberItem.AccountId;
                           system.debug('before main Map 000');
                           system.debug('EndUserRoleset'+RequiredRoleSet+ '' + ATMtoRoleMap.get(accountteammemberitem.id) );
                           system.debug('ChannelRoleset'+ChannelRoleset);
                               
                           IF((AccIdToRTIdMap.get(accountTeamMemberItem.AccountId) == 'End-User Account' && RequiredRoleSet.CONTAINS(ATMtoRoleMap.get(accountteammemberitem.id))) || (AccIdToRTIdMap.get(accountTeamMemberItem.AccountId) == 'Partner Account' && ChannelRoleset.CONTAINS(ATMtoRoleMap.get(accountteammemberitem.id)))){
                                  system.debug('before main Map');
                            //rev 12.0 end                                    
                           
                                //Rev 3.0 - Adding TeamMemberRole => UserId into map
                                accIdToRLorAPListMap.get(accountTeamMemberItem.AccountId).put(accountTeamMemberItem.TeamMemberRole,accountTeamMemberItem.User.Id);                            
                           }
                        }
                        
                        //rev 8.0-end
                    }                                       
                    
        }
        system.debug('accIdToRLorAPListMap '+accIdToRLorAPListMap);       
        
        //Rev 9.0
        // Geo- assignment process
        
           Set<String> AccSet = new Set<String>(); 
           Map<Id, String> AccidtoPostalCodeMap = new map<Id, String>();
           Map<Id, String> AccidtoStateMap = new map<Id, String>();
           Map<Id, String> AccidtoCountryMap = new map<Id, String>();
           
           // Query those records for postalcode, state and account country fields
           Map<Id,Account> AccidToAccMap = new Map<Id,Account>([SELECT id, shippingstate, Account_Country__c,shippingcountry, ShippingPostalCode, RecordTypeId, RecordType.Name
                                                                 FROM Account 
                                                                 WHERE Id IN :accIdToRelationshipLeadOrAccountPlayListMap.keyset()]); 
           
           // Add postal code, state and account_country field to a Set if they are present in the Account  
           For(ID ID : AccidToAccMap.keyset()){
            IF(AccidToAccMap.get(ID).Shippingpostalcode != NULL){
              Accset.add(AccidToAccMap.get(ID).Shippingpostalcode);
            }
            IF(AccidToAccMap.get(ID).ShippingState != NULL){  
              Accset.add(AccidToAccMap.get(ID).ShippingState);
            }
            IF(AccidToAccMap.get(ID).Account_Country__c != NULL){ 
              Accset.add(AccidToAccMap.get(ID).Account_Country__c);
            }
           } 
               
            system.debug('accset'+accset);
            
                       
        List<ID> geoidlist = new list<ID>();
        Set<String> GeonameSet = new Set<String>();
        Map<ID, boolean> GeoIdToAccCountryCheckMap = new Map<ID , boolean>();
        
        // Query Geography object for records where Geography name in the Account.postalcode or state ot account country
        Map<Id , Geography__c> GeoIdToGeoMap =  new Map<Id,Geography__c>([Select id,name from Geography__c where Name IN :Accset]);
       
        for(ID geoid: GeoIdToGeoMap.keyset()){
            GeonameSet.add(GeoIdToGeoMap.get(geoid).name.touppercase());
        }
              
        system.debug('geomap'+GeoIdToGeoMap );
        
        // If the AccountCountry is present in the Geography, proceed to add the postalcode,state and account country to the list       
        IF(GeoIdToGeoMap != NULL){
            for(ID accid : AccidToAccMap.keyset()){
                for(ID geoid: GeoidtoGeoMap.keyset()){
                    if (AccidToAccMap.get(Accid).Account_Country__c != null){
                        if(GeonameSet.contains(AccidToAccMap.get(Accid).Account_Country__c.toUpperCase())){        
                                                       
                            if(GeoIdToGeoMap.get(geoid).name == AccIdToAccMap.get(accid).ShippingPostalCode){                           
                                geoidlist.add(geoid);                             
                            }
                            else if(GeoIdToGeoMap.get(geoid).name == AccIdToAccMap.get(accid).ShippingState){                           
                                 geoidlist.add(geoid);                             
                            }
                            else if(GeoIdToGeoMap.get(geoid).name == AccIdToAccMap.get(accid).Account_Country__c){                           
                                 geoidlist.add(geoid);                             
                            }                       
                        }
                    }   
                }
            }                            
           
        }
        system.debug('geoidlist'+geoidlist);
        Map<Id, list<ID>> GeoidToListOfTerritoryIDsMap = new Map<Id,List<ID>>();
        Map<Id, list<ID>> testmap = new Map<Id,List<ID>>();
        Set<ID> FinalTerritorySet = new set<ID>();
        Map<ID , ID> RoleIdtoUserIdMap = new Map<ID,ID>();
        
        // Query for Territories which are associated to the queries Geography names
        // Map those Territories which are associated to a Geography: GeographyId => list of Territories
        for(Territory_Geo_Assignment__c TGA: [Select Territory__r.Id, geography__r.Id from Territory_Geo_Assignment__c where geography__r.Id IN :Geoidlist]){
                       
              FinalTerritorySet.add(TGA.Territory__r.Id); 
              
              IF(GeoidToListOfTerritoryIDsMap.get(tga.geography__r.Id) == NULL){
                  GeoidToListOfTerritoryIDsMap.put(tga.geography__r.Id , new list<ID>{TGA.territory__r.Id});
              }
              else{                  
                  GeoidToListOfTerritoryIDsMap.get(tga.geography__r.Id).add(tga.territory__r.Id);
              }
             
        }
        
       system.debug('finalterr set'+FinalTerritorySet );
       system.debug('geoid to terrlist'+ GeoidToListOfTerritoryIDsMap);
       system.debug ('Requiredgeoroleset ---12'+RequiredGeoRoleSet);
       
       // Get the User from Territory Sales User Assignment which is associated to the Campaign follow-up role and to the list of territories
       // Query only for the active records - Role, Territory, user and Territory sales User Assignment.
       TSAMap = new Map<ID, Territory_Sales_user_Assignment__c>([Select name,role__r.id,role__r.name,Is_Active__c, territory__r.id,territory__r.Geography_type__c, User__r.Id, Role__r.Is_Active__c, Territory__r.Is_Active__c, User__r.IsActive 
                                                                    from territory_sales_user_Assignment__c where 
                                                                    territory__r.id IN: FinalTerritorySet AND role__r.Name IN :RequiredGeoRoleSet AND Is_Active__c = true 
                                                                    AND role__r.Is_Active__c = true AND Territory__r.Is_Active__c = true AND User__r.IsActive = true]);    

        Set<ID> StringOfTerritories;
        Map<ID , list<id>> AccidtolistofTerritoryIdsMap = new map<ID, list<id>>();
        List<ID> tempIDlist;
       // Map the territories with the Account: Account=> List of territories
       for(ID accid : AccidtoAccMap.keyset()){
            for(ID geoid : GeoidToListOfTerritoryIDsMap.keyset()){              
                                
                If(GeoIdToGeoMap.get(geoid).name == AccidtoAccMap.get(accid).ShippingPostalCode || 
                    GeoIdToGeoMap.get(geoid).name == AccidtoAccMap.get(accid).ShippingState ||
                    GeoIdToGeoMap.get(geoid).name == AccidtoAccMap.get(accid).Account_Country__c){
                   // TerritoryidlisttoAccidMap.put(GeoidToListOfTerritoryIDsMap.get(geoid) , accid);
                      
                   If(AccidtolistofTerritoryIdsMap.get(accid) == NULL){
                       tempIDlist = new list<ID>();
                       tempidlist.addall(GeoidToListOfTerritoryIDsMap.get(geoid));                      
                   }
                   else{
                       tempidlist.addall(GeoidToListOfTerritoryIDsMap.get(geoid));                      
                   }
                    AccidtolistofTerritoryIdsMap.put(accid, tempidlist);
                    system.debug('AccidtolistofTerritoryIdsMap map---- '+ AccidtolistofTerritoryIdsMap);
                }               
            }            
        }
      
        
        //Map only those Territories to the respective Account which are presnt in the Territory sales Usre Assignment.    
        for(ID accid : AccidtoAccMap.keyset()){
            StringOfTerritories = new Set<ID>();
           
            if (AccidtolistofTerritoryIdsMap.get(accid) != NULL){
                StringOfTerritories.addall(AccidtolistofTerritoryIdsMap.get(accid)); 
            
                for(ID tsaid : TSAmap.keyset()){
                    if(StringOfTerritories.CONTAINS(TSAmap.get(tsaid).Territory__r.Id)){
                        if (AccidtoTSAid.get(accid) == null)
                            AccidtoTSAid.put(accid , new list<Id>{tsaid});
                        else
                            AccidtoTSAid.get(accid).add(tsaid);
                    }
                }
            }
        }
      
              // Rev 9.0 end
        
        
        //Rev 3.0 - Looping through List of accountId
        for (Account currentAccountobj : AccidToAccMap.Values()){
            //system.debug('accid' + currentAccountobj);
            //system.debug('AccidtoTSAid' + AccidtoTSAid.get(currentAccountobj));
            //system.debug('role to user' + accIdToRLorAPListMap.get(currentAccountobj));
            //system.debug('Looping Inside accIdToRelationshipLeadOrAccountPlayListMap & Calling assignUserToOwnerAndSpecifiedRoleFields method');
            //11.0 Pass campIdToSecondaryRoleMap
            //assignUserToOwnerAndSpecifiedRoleFields(accIdToRelationshipLeadOrAccountPlayListMap,acctId,accIdToRLorAPListMap.get(acctId),campIdToFollowUpRoleMap);
            assignUserToOwnerAndSpecifiedRoleFields(accIdToRelationshipLeadOrAccountPlayListMap,currentAccountobj,accIdToRLorAPListMap.get(currentAccountobj.Id),campIdToFollowUpRoleMap,campIdToSecondaryRoleMap);
        }
    }*/
    
    // Create task to ISR for Bad Contact Info Relationship Lead / Account Play record
  /*  public static void assignRejectionTaskToISR(List<SObject> rejectRelationshipLeadOrAccountPlayList) {
        System.debug('## Inside Method assignRejectionTaskToISR  ##');
        System.debug('## rejectRelationshipLeadOrAccountPlayList'+rejectRelationshipLeadOrAccountPlayList);         
        throwTestException(isAfterException);
        final string relanshipLeadPrefix = Relationship_Lead__c.sObjectType.getDescribe().getKeyPrefix();
        final string accountPlayPrefix = Account_Play__c.sObjectType.getDescribe().getKeyPrefix();
        String subject;
        String objId;                       
        List<Task> taskList = new List<Task>();
        RecordType rectype=[Select Name, Id From RecordType where Name='Standard Task'];
        for (SObject rejectItem : rejectRelationshipLeadOrAccountPlayList) {
            objId = rejectItem.id;
            if(objId.startsWith(relanshipLeadPrefix)){
                subject = 'Bad Contact Info - Please Update';
            }
            else{
                subject = 'No Contact Info - Please Update';
            }           
            task taskItem = new task(RecordTypeId = rectype.Id,
                                    OwnerId = (Id) rejectItem.get('Inside_Sales_Rep__c'),
                                    WhatId = rejectItem.Id,
                                    Subject = subject,
                                    Type = 'Campaign Follow-Up',                                    
                                    ActivityDate = Date.today() + 3);   
            System.debug('taskItem'+taskItem);                  
            taskList.add(taskItem);
        }
        insert taskList;
    }*/
    /*public static void assignFollowupTaskToOwner(List<SObject> followUptRelationshipLeadOrAccountPlayList){
        String owner;
        Date followupDate;
        String objId = followUptRelationshipLeadOrAccountPlayList[0].id;    
        final string relanshipLeadPrefix = Relationship_Lead__c.sObjectType.getDescribe().getKeyPrefix();
        final string accountPlayPrefix = Account_Play__c.sObjectType.getDescribe().getKeyPrefix();                  
        List<Task> taskList = new List<Task>();
        Task taskItem;  
        if(objId.startsWith(relanshipLeadPrefix)){
                owner = 'Relationship_Lead_Owner__c';
            }
            else{
                owner = 'Account_Play_Owner__c';
            }       
        RecordType rectype=[Select Name, Id From RecordType where Name='Standard Task'];
        System.debug('Shue objId ---- '+objId);
        System.debug('Shue followUptRelationshipLeadOrAccountPlayList ---- '+followUptRelationshipLeadOrAccountPlayList);
        for (SObject followUpItem : followUptRelationshipLeadOrAccountPlayList) {
             
             taskItem = new task(RecordTypeId = rectype.Id,
                                OwnerId = (Id) followUpItem.get(owner),
                                WhatId = followUpItem.Id,
                                Subject = 'Please Follow-Up on Lead',
                                Type = 'Campaign Follow-Up',                                
                                ActivityDate =(Date) followUpItem.get('Follow_Up_Date__c'),
                                Priority = 'Normal',
                                Status = 'Not Started'
                                );  
            System.debug('taskItem'+taskItem);                  
            taskList.add(taskItem);
        }
        insert taskList;
    }*/
    
    // Rev 1.6 - Don't overwrite RL/AP owner, AE and ISR field if already contain value
    //11.0 Pass campIdToSecondaryRoleMap
    /*
    private static void assignUserToOwnerAndSpecifiedRoleFields(Map<id,List<SObject>> accIdToRelationshipLeadOrAccountPlayListMap,
                                                            Id currentAccountId,
                                                            Map<String,String> roleToUserIdMap,
                                                            Map<String,String> campIdToFollowUpRoleMap){
    */
    /*private static void assignUserToOwnerAndSpecifiedRoleFields(Map<id,List<SObject>> accIdToRelationshipLeadOrAccountPlayListMap,
                                                            Account currentAccountRecord,
                                                            Map<String,String> roleToUserIdMap,
                                                            Map<String,String> campIdToFollowUpRoleMap,
                                                            Map<String,String> campIdToSecondaryRoleMap){
                                            
        system.debug('## Inside method :assignUserToOwnerAndSpecifiedRoleFields ');
        // takes the list of Relationship Lead records curresponding to CurrentAccountId
        List<SObject> tempList = accIdToRelationshipLeadOrAccountPlayListMap.get(currentAccountRecord.Id);

        for(SObject item : tempList){   
            String salesId = (String)item.get('Account_Sales_Channel_Id__c');
                         
            // Assigns the User Id from the role=> User Id map to each Relationship Lead record
            if (item.getSObjectType() == Relationship_Lead__c.sObjectType) { 
                
                //Rev 3.0
                if (roleToUserIdMap != null )
                {
                    system.debug('## roleToUserIdMap '+ roleToUserIdMap );                           
                    //check for Account team member with role = Campaign's Follow-up role
                    /*
                    if (item.get('Relationship_Lead_Owner__c') == null) {
                        item.put('System_Auto_Populated_RL_Owner__c', true);    //Rev 1.8
                        item.put('Relationship_Lead_Owner__c', roleToUserIdMap.get(campIdToFollowUpRoleMap.get(String.valueOf(item.get('Campaign__c')))));
                        //11.0 If Relationship Lead Owner has not been assigned based on Follow-Up Role, take Secondary Role
                        if(item.get('Relationship_Lead_Owner__c') == null){
                            item.put('Relationship_Lead_Owner__c', roleToUserIdMap.get(campIdToSecondaryRoleMap.get(String.valueOf(item.get('Campaign__c')))));                    
                        }
                    } 
                    */
                    //Start Rev 13.0
                   /* if (item.get('Relationship_Lead_Owner__c') == null && currentAccountRecord.RecordType.Name =='End-User Account' && campIdToFollowUpRoleMap.get(String.valueOf(item.get('Campaign__c'))) == 'Partner Development Manager') {
                        item.put('System_Auto_Populated_RL_Owner__c', true);    //Rev 1.8
                        item.put('Relationship_Lead_Owner__c', roleToUserIdMap.get('Account Executive'));
                    }  
                    
                    if (item.get('Relationship_Lead_Owner__c') == null && currentAccountRecord.RecordType.Name =='Partner Account' && campIdToFollowUpRoleMap.get(String.valueOf(item.get('Campaign__c'))) == 'Partner Development Manager') {
                        item.put('System_Auto_Populated_RL_Owner__c', true);    //Rev 1.8
                        item.put('Relationship_Lead_Owner__c', roleToUserIdMap.get('Partner Development Manager'));
                    }
                    
                    if (item.get('Relationship_Lead_Owner__c') == null && currentAccountRecord.RecordType.Name =='End-User Account' && campIdToFollowUpRoleMap.get(String.valueOf(item.get('Campaign__c'))) == 'Inside Channel Account Manager') {
                        item.put('System_Auto_Populated_RL_Owner__c', true);    //Rev 1.8
                        item.put('Relationship_Lead_Owner__c', roleToUserIdMap.get('Inside Sales Rep')); 
                    } 
                    
                    if (item.get('Relationship_Lead_Owner__c') == null && currentAccountRecord.RecordType.Name =='Partner Account' && campIdToFollowUpRoleMap.get(String.valueOf(item.get('Campaign__c'))) == 'Inside Channel Account Manager') {
                        item.put('System_Auto_Populated_RL_Owner__c', true);    //Rev 1.8
                        item.put('Relationship_Lead_Owner__c', roleToUserIdMap.get('Inside Channel Account Manager')); 
                    } 
                    
                    if (item.get('Relationship_Lead_Owner__c') == null && currentAccountRecord.RecordType.Name =='Partner Account' && campIdToFollowUpRoleMap.get(String.valueOf(item.get('Campaign__c'))) == 'Account Executive') {
                        item.put('System_Auto_Populated_RL_Owner__c', true);    //Rev 1.8
                        item.put('Relationship_Lead_Owner__c', roleToUserIdMap.get('Partner Development Manager'));                    
                    }
                    
                    if (item.get('Relationship_Lead_Owner__c') == null && currentAccountRecord.RecordType.Name =='End-User Account' && campIdToFollowUpRoleMap.get(String.valueOf(item.get('Campaign__c'))) == 'Account Executive') {
                        item.put('System_Auto_Populated_RL_Owner__c', true);    //Rev 1.8
                        item.put('Relationship_Lead_Owner__c', roleToUserIdMap.get('Account Executive'));                    
                    } 
                    
                    if (item.get('Relationship_Lead_Owner__c') == null && currentAccountRecord.RecordType.Name =='Partner Account' && campIdToFollowUpRoleMap.get(String.valueOf(item.get('Campaign__c'))) == 'Inside Sales Rep') {
                        item.put('System_Auto_Populated_RL_Owner__c', true);    //Rev 1.8
                        item.put('Relationship_Lead_Owner__c', roleToUserIdMap.get('Inside Channel Account Manager'));                    
                    } 
                    
                    if (item.get('Relationship_Lead_Owner__c') == null && currentAccountRecord.RecordType.Name =='End-User Account' && campIdToFollowUpRoleMap.get(String.valueOf(item.get('Campaign__c'))) == 'Inside Sales Rep') {
                        item.put('System_Auto_Populated_RL_Owner__c', true);    //Rev 1.8
                        item.put('Relationship_Lead_Owner__c', roleToUserIdMap.get('Inside Sales Rep'));                    
                    } 
                        
                        //11.0 If Relationship Lead Owner has not been assigned based on Follow-Up Role, find Account Team Member from Secondary Role
                       if(item.get('Relationship_Lead_Owner__c') == null && currentAccountRecord.RecordType.Name =='End-User Account' && campIdToSecondaryRoleMap.get(String.valueOf(item.get('Campaign__c'))) == 'Partner Development Manager'){
                         item.put('System_Auto_Populated_RL_Owner__c', true);    //Rev 1.8
                         item.put('Relationship_Lead_Owner__c', roleToUserIdMap.get('Account Executive'));
                        }
                        
                        if(item.get('Relationship_Lead_Owner__c') == null && currentAccountRecord.RecordType.Name =='Partner Account' && campIdToSecondaryRoleMap.get(String.valueOf(item.get('Campaign__c'))) == 'Partner Development Manager'){
                         item.put('System_Auto_Populated_RL_Owner__c', true);    //Rev 1.8
                         item.put('Relationship_Lead_Owner__c', roleToUserIdMap.get('Partner Development Manager'));
                        }
                    
                        if(item.get('Relationship_Lead_Owner__c') == null && currentAccountRecord.RecordType.Name =='End-User Account' && campIdToSecondaryRoleMap.get(String.valueOf(item.get('Campaign__c'))) == 'Inside Channel Account Manager'){
                           item.put('System_Auto_Populated_RL_Owner__c', true);    //Rev 1.8
                           item.put('Relationship_Lead_Owner__c', roleToUserIdMap.get('Inside Sales Rep'));
                        }
                    
                        if(item.get('Relationship_Lead_Owner__c') == null && currentAccountRecord.RecordType.Name =='Partner Account' && campIdToSecondaryRoleMap.get(String.valueOf(item.get('Campaign__c'))) == 'Inside Channel Account Manager'){
                           item.put('System_Auto_Populated_RL_Owner__c', true);    //Rev 1.8
                           item.put('Relationship_Lead_Owner__c', roleToUserIdMap.get('Inside Channel Account Manager'));
                        }
                    
                        if(item.get('Relationship_Lead_Owner__c') == null && currentAccountRecord.RecordType.Name =='Partner Account' && campIdToSecondaryRoleMap.get(String.valueOf(item.get('Campaign__c'))) == 'Account Executive'){
                          item.put('System_Auto_Populated_RL_Owner__c', true);    //Rev 1.8
                          item.put('Relationship_Lead_Owner__c', roleToUserIdMap.get('Partner Development Manager')); 
                        }
                    
                        if(item.get('Relationship_Lead_Owner__c') == null && currentAccountRecord.RecordType.Name =='End-User Account' && campIdToSecondaryRoleMap.get(String.valueOf(item.get('Campaign__c'))) == 'Account Executive'){
                          item.put('System_Auto_Populated_RL_Owner__c', true);    //Rev 1.8
                          item.put('Relationship_Lead_Owner__c', roleToUserIdMap.get('Account Executive')); 
                        }
                    
                        if(item.get('Relationship_Lead_Owner__c') == null && currentAccountRecord.RecordType.Name =='Partner Account' && campIdToSecondaryRoleMap.get(String.valueOf(item.get('Campaign__c'))) == 'Inside Sales Rep'){
                         item.put('System_Auto_Populated_RL_Owner__c', true);    //Rev 1.8
                         item.put('Relationship_Lead_Owner__c', roleToUserIdMap.get('Inside Channel Account Manager')); 
                        }
                    
                        if(item.get('Relationship_Lead_Owner__c') == null && currentAccountRecord.RecordType.Name =='End-User Account' && campIdToSecondaryRoleMap.get(String.valueOf(item.get('Campaign__c'))) == 'Inside Sales Rep'){
                         item.put('System_Auto_Populated_RL_Owner__c', true);    //Rev 1.8
                         item.put('Relationship_Lead_Owner__c', roleToUserIdMap.get('Inside Sales Rep')); 
                        }
                    
                    if (item.get('Relationship_Lead_Owner__c') == null && campIdToFollowUpRoleMap.get(String.valueOf(item.get('Campaign__c'))) <> 'Partner Development Manager' &&  campIdToFollowUpRoleMap.get(String.valueOf(item.get('Campaign__c'))) <> 'Inside Channel Account Manager' && campIdToFollowUpRoleMap.get(String.valueOf(item.get('Campaign__c'))) <> 'Account Executive' && campIdToFollowUpRoleMap.get(String.valueOf(item.get('Campaign__c'))) <> 'Inside Sales Rep') {
                        item.put('System_Auto_Populated_RL_Owner__c', true);    //Rev 1.8
                        system.debug('campIdToFollowUpRoleMap' +campIdToFollowUpRoleMap);
                        item.put('Relationship_Lead_Owner__c', roleToUserIdMap.get(campIdToFollowUpRoleMap.get(String.valueOf(item.get('Campaign__c')))));     
                      
                        //11.0 If Relationship Lead Owner has not been assigned based on Follow-Up Role, find Account Team Member from Secondary Role
                        if(item.get('Relationship_Lead_Owner__c') == null && campIdToSecondaryRoleMap.get(String.valueOf(item.get('Campaign__c'))) <> 'Partner Development Manager' &&  campIdToSecondaryRoleMap.get(String.valueOf(item.get('Campaign__c'))) <> 'Inside Channel Account Manager' && campIdToSecondaryRoleMap.get(String.valueOf(item.get('Campaign__c'))) <> 'Account Executive' && campIdToSecondaryRoleMap.get(String.valueOf(item.get('Campaign__c'))) <> 'Inside Sales Rep'){
                            item.put('Relationship_Lead_Owner__c', roleToUserIdMap.get(campIdToSecondaryRoleMap.get(String.valueOf(item.get('Campaign__c')))));                    
                        }
                    }
                    
                    //End Rev 13.0
                    
                    // Rev 9.1 -- If no account team member with same role as Campaign's Follow-up role then check for Geo-based assignment
                    if (item.get('Relationship_Lead_Owner__c') == null && AccidtoTSAid.get(currentAccountRecord.Id) != null){  
                    
                        //for(ID TSAID: TSAMAP.keyset()){
                        system.debug('$$Debug: AccidtoTSAid.get(currentAccountId)'  +AccidtoTSAid.get(currentAccountRecord.Id));
                        for (id TSAID : AccidtoTSAid.get(currentAccountRecord.Id)){
                             system.debug('$$Debug: TSAMAP.get(TSAID)'  +TSAMAP.get(TSAID));
                            if (TSAMAP.get(TSAID) != null){
                                if(campIdToFollowUpRoleMap.get(String.valueOf(item.get('Campaign__c'))) == TSAMAP.get(TSAID).role__r.name){                                   
                                     system.debug('geo - populate is true');
                                     item.put('Geo_populated__c' , true); 
                                     item.put('Territory_Sales_User_Assignment__c' , TSAID);
                                     item.put('System_Auto_Populated_RL_Owner__c', true);    
                                     
                                     IF(TSAmap.get(tsaid).Territory__r.Geography_Type__c == 'Zipcode'){
                                         item.put('Relationship_Lead_Owner__c', TSAmap.get(TSAID).User__r.id);    
                                     }Else if(item.get('Relationship_Lead_Owner__c') == null && TSAmap.get(tsaid).Territory__r.Geography_Type__c == 'State'){
                                         item.put('Relationship_Lead_Owner__c', TSAmap.get(TSAID).User__r.id);   
                                     }Else if(item.get('Relationship_Lead_Owner__c') == null && TSAmap.get(tsaid).Territory__r.Geography_Type__c == 'Country'){
                                         item.put('Relationship_Lead_Owner__c', TSAmap.get(TSAID).User__r.id);   
                                     }
                                     
                                }
                            }
                        }                 
                    }
                     // Rev 9.1 end 
                  //Start Rev 13.0                   
                    if (item.get('Relationship_Lead_Owner__c') == null && currentAccountRecord.RecordType.Name =='End-User Account') item.put('Relationship_Lead_Owner__c', roleToUserIdMap.get('Inside Sales Rep'));
                    if (item.get('Relationship_Lead_Owner__c') == null && currentAccountRecord.RecordType.Name =='End-User Account') item.put('Relationship_Lead_Owner__c', roleToUserIdMap.get('Account Executive'));
                    if (item.get('Relationship_Lead_Owner__c') == null && currentAccountRecord.RecordType.Name =='Partner Account') item.put('Relationship_Lead_Owner__c', roleToUserIdMap.get('Inside Channel Account Manager')); 
                    if (item.get('Relationship_Lead_Owner__c') == null && currentAccountRecord.RecordType.Name =='Partner Account') item.put('Relationship_Lead_Owner__c', roleToUserIdMap.get('Partner Development Manager'));  
                    
                    if (item.get('Account_Executive__c') == null && currentAccountRecord.RecordType.Name =='End-User Account'){ //&& item.get('Geo_Populated__c') == false) {
                        item.put('System_Auto_Populated_AE__c', true);          //Rev 1.8 
                        item.put('Account_Executive__c', roleToUserIdMap.get('Account Executive'));
                    }
                    IF(item.get('Account_Executive__c') == NULL && currentAccountRecord.RecordType.Name =='Partner Account'){                    
                        item.put('System_Auto_Populated_AE__c', true);
                        item.put('Account_Executive__c', roleToUserIdMap.get('Partner Development Manager'));    
                        system.debug(' PDM user rl' + roleToUserIdMap.get('Partner Development Manager'));
                        system.debug('ROLE MAP rl'+ roleToUserIdMap);
                    }
                    if (item.get('Inside_Sales_Rep__c') == null && currentAccountRecord.RecordType.Name =='End-User Account'){ // && item.get('Geo_Populated__c') == false ) {
                        item.put('System_Auto_Populated_ISR__c', true);             //Rev 3.0           
                        item.put('Inside_Sales_Rep__c', roleToUserIdMap.get('Inside Sales Rep'));
                    }
                    IF(item.get('Inside_Sales_Rep__c') == NULL && currentAccountRecord.RecordType.Name =='Partner Account'){
                        item.put('System_Auto_Populated_AE__c', true);
                        item.put('Inside_Sales_Rep__c',roleToUserIdMap.get('Inside Channel Account Manager'));   
                    }
                }
                //End Rev 13.0  
                else{
                    system.debug('$$ else ');
                    // Rev 9.1                    
                    if (item.get('Relationship_Lead_Owner__c') == null && AccidtoTSAid.get(currentAccountRecord.Id) != null){  
                            for (id TSAID : AccidtoTSAid.get(currentAccountRecord.Id)){
                                if (TSAMAP.get(TSAID) != null){
                                    if(campIdToFollowUpRoleMap.get(String.valueOf(item.get('Campaign__c'))) == TSAMAP.get(TSAID).role__r.name){
                                         system.debug('geo - populate is true');
                                         item.put('Geo_populated__c' , true); 
                                         item.put('Territory_Sales_User_Assignment__c' , TSAID);
                                         item.put('System_Auto_Populated_RL_Owner__c', true);   
                                     
                                         IF(TSAmap.get(tsaid).Territory__r.Geography_Type__c == 'Zipcode'){
                                             item.put('Relationship_Lead_Owner__c', TSAmap.get(TSAID).User__r.id);    
                                         }Else if(item.get('Relationship_Lead_Owner__c') == null && TSAmap.get(tsaid).Territory__r.Geography_Type__c == 'State'){
                                             item.put('Relationship_Lead_Owner__c', TSAmap.get(TSAID).User__r.id);   
                                         }Else if(item.get('Relationship_Lead_Owner__c') == null && TSAmap.get(tsaid).Territory__r.Geography_Type__c == 'Country'){
                                             item.put('Relationship_Lead_Owner__c', TSAmap.get(TSAID).User__r.id);   
                                         }  
                                            
                                    }
                                }
                            }                 
                    }
                    
                    // Rev 9.1 end  
                }
                if (item.get('Relationship_Lead_Owner__c') == null) {
                    item.put('Relationship_Lead_Owner__c', item.get('Account_Owner__c'));   //Rev 3.0        
                }
            }               
            else if (item.getSObjectType() == Account_Play__c.sObjectType) {
                
                //Rev3.0
                //Start Rev 13.0    
                if (roleToUserIdMap != null ){
                    if (item.get('Account_Play_Owner__c') == null && currentAccountRecord.RecordType.Name =='End-User Account' && campIdToFollowUpRoleMap.get(String.valueOf(item.get('Campaign__c'))) == 'Partner Development Manager') {
                        item.put('System_Auto_Populated_AP_Owner__c', true);    //Rev 1.8
                        item.put('Account_Play_Owner__c', roleToUserIdMap.get('Account Executive'));
                    }  
                    
                    if (item.get('Account_Play_Owner__c') == null && currentAccountRecord.RecordType.Name =='Partner Account' && campIdToFollowUpRoleMap.get(String.valueOf(item.get('Campaign__c'))) == 'Partner Development Manager') {
                        item.put('System_Auto_Populated_AP_Owner__c', true);    //Rev 1.8
                        item.put('Account_Play_Owner__c', roleToUserIdMap.get('Partner Development Manager'));
                    } 
                    
                    if (item.get('Account_Play_Owner__c') == null && currentAccountRecord.RecordType.Name =='End-User Account' && campIdToFollowUpRoleMap.get(String.valueOf(item.get('Campaign__c'))) == 'Inside Channel Account Manager') {
                        item.put('System_Auto_Populated_AP_Owner__c', true);    //Rev 1.8
                        item.put('Account_Play_Owner__c', roleToUserIdMap.get('Inside Sales Rep')); 
                    }
                    
                    if (item.get('Account_Play_Owner__c') == null && currentAccountRecord.RecordType.Name =='Partner Account' && campIdToFollowUpRoleMap.get(String.valueOf(item.get('Campaign__c'))) == 'Inside Channel Account Manager') {
                        item.put('System_Auto_Populated_AP_Owner__c', true);    //Rev 1.8
                        item.put('Account_Play_Owner__c', roleToUserIdMap.get('Inside Channel Account Manager')); 
                    } 
                    
                    if (item.get('Account_Play_Owner__c') == null && currentAccountRecord.RecordType.Name =='Partner Account' && campIdToFollowUpRoleMap.get(String.valueOf(item.get('Campaign__c'))) == 'Account Executive') {
                        item.put('System_Auto_Populated_AP_Owner__c', true);    //Rev 1.8
                        item.put('Account_Play_Owner__c', roleToUserIdMap.get('Partner Development Manager'));                    
                    } 
                    
                    if (item.get('Account_Play_Owner__c') == null && currentAccountRecord.RecordType.Name =='End-User Account' && campIdToFollowUpRoleMap.get(String.valueOf(item.get('Campaign__c'))) == 'Account Executive') {
                        item.put('System_Auto_Populated_AP_Owner__c', true);    //Rev 1.8
                        item.put('Account_Play_Owner__c', roleToUserIdMap.get('Account Executive'));                    
                    }
                    
                    if (item.get('Account_Play_Owner__c') == null && currentAccountRecord.RecordType.Name =='Partner Account' && campIdToFollowUpRoleMap.get(String.valueOf(item.get('Campaign__c'))) == 'Inside Sales Rep') {
                        item.put('System_Auto_Populated_AP_Owner__c', true);    //Rev 1.8
                        item.put('Account_Play_Owner__c', roleToUserIdMap.get('Inside Channel Account Manager'));                    
                    }
                    
                    if (item.get('Account_Play_Owner__c') == null && currentAccountRecord.RecordType.Name =='End-User Account' && campIdToFollowUpRoleMap.get(String.valueOf(item.get('Campaign__c'))) == 'Inside Sales Rep') {
                        item.put('System_Auto_Populated_AP_Owner__c', true);    //Rev 1.8
                        item.put('Account_Play_Owner__c', roleToUserIdMap.get('Inside Sales Rep'));                    
                    } 
                    
                    //11.0 If Account Play Owner has not been assigned based on Follow-Up Role, find Account Team Member from Secondary Role
                        if(item.get('Account_Play_Owner__c') == null && currentAccountRecord.RecordType.Name =='End-User Account' && campIdToSecondaryRoleMap.get(String.valueOf(item.get('Campaign__c'))) == 'Partner Development Manager'){
                         item.put('System_Auto_Populated_AP_Owner__c', true);    //Rev 1.8
                         item.put('Account_Play_Owner__c', roleToUserIdMap.get('Account Executive'));
                        }
                    
                        if(item.get('Account_Play_Owner__c') == null && currentAccountRecord.RecordType.Name =='Partner Account' && campIdToSecondaryRoleMap.get(String.valueOf(item.get('Campaign__c'))) == 'Partner Development Manager'){
                         item.put('System_Auto_Populated_AP_Owner__c', true);    //Rev 1.8
                         item.put('Account_Play_Owner__c', roleToUserIdMap.get('Partner Development Manager'));
                        }
                    
                        if(item.get('Account_Play_Owner__c') == null && currentAccountRecord.RecordType.Name =='End-User Account' && campIdToSecondaryRoleMap.get(String.valueOf(item.get('Campaign__c'))) == 'Inside Channel Account Manager'){
                           item.put('System_Auto_Populated_AP_Owner__c', true);    //Rev 1.8
                           item.put('Account_Play_Owner__c', roleToUserIdMap.get('Inside Sales Rep'));
                        }
                    
                        if(item.get('Account_Play_Owner__c') == null && currentAccountRecord.RecordType.Name =='Partner Account' && campIdToSecondaryRoleMap.get(String.valueOf(item.get('Campaign__c'))) == 'Inside Channel Account Manager'){
                           item.put('System_Auto_Populated_AP_Owner__c', true);    //Rev 1.8
                           item.put('Account_Play_Owner__c', roleToUserIdMap.get('Inside Channel Account Manager'));
                        }
                    
                        if(item.get('Account_Play_Owner__c') == null && currentAccountRecord.RecordType.Name =='Partner Account' && campIdToSecondaryRoleMap.get(String.valueOf(item.get('Campaign__c'))) == 'Account Executive'){
                          item.put('System_Auto_Populated_AP_Owner__c', true);    //Rev 1.8
                          item.put('Account_Play_Owner__c', roleToUserIdMap.get('Partner Development Manager')); 
                        }
                    
                        if(item.get('Account_Play_Owner__c') == null && currentAccountRecord.RecordType.Name =='End-User Account' && campIdToSecondaryRoleMap.get(String.valueOf(item.get('Campaign__c'))) == 'Account Executive'){
                          item.put('System_Auto_Populated_AP_Owner__c', true);    //Rev 1.8
                          item.put('Account_Play_Owner__c', roleToUserIdMap.get('Account Executive')); 
                        }
                    
                        if(item.get('Account_Play_Owner__c') == null && currentAccountRecord.RecordType.Name =='Partner Account' && campIdToSecondaryRoleMap.get(String.valueOf(item.get('Campaign__c'))) == 'Inside Sales Rep'){
                         item.put('System_Auto_Populated_AP_Owner__c', true);    //Rev 1.8
                         item.put('Account_Play_Owner__c', roleToUserIdMap.get('Inside Channel Account Manager')); 
                        }
                    
                        if(item.get('Account_Play_Owner__c') == null && currentAccountRecord.RecordType.Name =='End-User Account' && campIdToSecondaryRoleMap.get(String.valueOf(item.get('Campaign__c'))) == 'Inside Sales Rep'){
                         item.put('System_Auto_Populated_AP_Owner__c', true);    //Rev 1.8
                         item.put('Account_Play_Owner__c', roleToUserIdMap.get('Inside Sales Rep')); 
                        }
                    
                    system.debug('String.valueOf(item.get(Campaign__c)' +String.valueOf(item.get('Campaign__c')));
                    if (item.get('Account_Play_Owner__c') == null && campIdToFollowUpRoleMap.get(String.valueOf(item.get('Campaign__c'))) <> 'Partner Development Manager' &&  campIdToFollowUpRoleMap.get(String.valueOf(item.get('Campaign__c'))) <> 'Inside Channel Account Manager' && campIdToFollowUpRoleMap.get(String.valueOf(item.get('Campaign__c'))) <> 'Account Executive' && campIdToFollowUpRoleMap.get(String.valueOf(item.get('Campaign__c'))) <> 'Inside Sales Rep') {
                        item.put('System_Auto_Populated_AP_Owner__c', true);    //Rev 1.8
                        system.debug('campIdToFollowUpRoleMap' +campIdToFollowUpRoleMap);
                        item.put('Account_Play_Owner__c', roleToUserIdMap.get(campIdToFollowUpRoleMap.get(String.valueOf(item.get('Campaign__c')))));     
                        system.debug('campIdToFollowUpRoleMap' +roleToUserIdMap.get(campIdToFollowUpRoleMap.get(String.valueOf(item.get('Campaign__c')))));
                        //11.0 If Account Play Owner has not been assigned based on Follow-Up Role, find Account Team Member from Secondary Role
                        if(item.get('Account_Play_Owner__c') == null && campIdToSecondaryRoleMap.get(String.valueOf(item.get('Campaign__c'))) <> 'Partner Development Manager' &&  campIdToSecondaryRoleMap.get(String.valueOf(item.get('Campaign__c'))) <> 'Inside Channel Account Manager' && campIdToSecondaryRoleMap.get(String.valueOf(item.get('Campaign__c'))) <> 'Account Executive' && campIdToSecondaryRoleMap.get(String.valueOf(item.get('Campaign__c'))) <> 'Inside Sales Rep'){
                            item.put('Account_Play_Owner__c', roleToUserIdMap.get(campIdToSecondaryRoleMap.get(String.valueOf(item.get('Campaign__c')))));                    
                        }
                    }
                    //End Rev 13.0  
                     // Rev 9.1 -- If no account team member with same role as Campaign's Follow-up role then check for Geo-based assignment
                    if (item.get('Account_Play_Owner__c') == null && AccidtoTSAid.get(currentAccountRecord.Id) != null){  
                        for (id TSAID : AccidtoTSAid.get(currentAccountRecord.Id)){
                            system.debug('$$DEBUG: ' + TSAmap.get(TSAID));
                            if (TSAMAP.get(TSAID) != null){
                                if(campIdToFollowUpRoleMap.get(String.valueOf(item.get('Campaign__c'))) == TSAMAP.get(TSAID).role__r.name){                                     
                                     system.debug('geo - populate is true');
                                     item.put('Geo_populated__c' , true); 
                                     item.put('Territory_Sales_User_Assignment__c' , TSAID);
                                     item.put('System_Auto_Populated_AP_Owner__c', true);    
                                     system.debug('$$DEBUG: TSAID' + TSAID);                                     
                                     system.debug('$$DEBUG: TSAmap.get(TSAID).User__r.id' + TSAmap.get(TSAID).User__r.id);
                                     
                                     IF(TSAmap.get(tsaid).Territory__r.Geography_Type__c == 'Zipcode'){
                                         item.put('Account_Play_Owner__c', TSAmap.get(TSAID).User__r.id); 
                                     }Else if(item.get('Account_Play_Owner__c') == null && TSAmap.get(tsaid).Territory__r.Geography_Type__c == 'State'){
                                         item.put('Account_Play_Owner__c', TSAmap.get(TSAID).User__r.id);
                                     }Else if(item.get('Account_Play_Owner__c') == null && TSAmap.get(tsaid).Territory__r.Geography_Type__c == 'Country'){
                                         item.put('Account_Play_Owner__c', TSAmap.get(TSAID).User__r.id);
                                     }        
                                }
                            }
                        }                 
                    }
                    // Rev 9.1 end 
                    //Start Rev 13.0        
                    if (item.get('Account_Play_Owner__c') == null && currentAccountRecord.RecordType.Name =='End-User Account') item.put('Account_Play_Owner__c', roleToUserIdMap.get('Inside Sales Rep'));
                    if (item.get('Account_Play_Owner__c') == null && currentAccountRecord.RecordType.Name =='End-User Account') item.put('Account_Play_Owner__c', roleToUserIdMap.get('Account Executive'));
                    if (item.get('Account_Play_Owner__c') == null && currentAccountRecord.RecordType.Name =='Partner Account') item.put('Account_Play_Owner__c', roleToUserIdMap.get('Inside Channel Account Manager')); //Rev 13.0
                    if (item.get('Account_Play_Owner__c') == null && currentAccountRecord.RecordType.Name =='Partner Account') item.put('Account_Play_Owner__c', roleToUserIdMap.get('Partner Development Manager'));  //Rev 13.0
                
                    //Rev 1.2 item.put('Account_Executive_del__c', roleToUserIdMap.get('Account Executive'));               
                    //Rev 2.0
                    if (item.get('Account_Executive__c') == null && currentAccountRecord.RecordType.Name =='End-User Account'){ // && item.get('Geo_Populated__c') == false ) {                        
                        item.put('System_Auto_Populated_AE__c', true); 
                        item.put('Account_Executive__c', roleToUserIdMap.get('Account Executive'));                                        
                    } 
                    IF(item.get('Account_Executive__c') == NULL && currentAccountRecord.RecordType.Name =='Partner Account'){                    
                        item.put('System_Auto_Populated_AE__c', true);
                        item.put('Account_Executive__c',roleToUserIdMap.get('Partner Development Manager'));    
                        system.debug(' PDM user' + roleToUserIdMap.get('Partner Development Manager'));
                        system.debug('ROLE MAP '+ roleToUserIdMap);
                    }  
                    system.debug('oooooo' + item.get('Account_Executive__c'));
                    if (item.get('Inside_Sales_Rep__c') == null && currentAccountRecord.RecordType.Name =='End-User Account'){ //  && item.get('Geo_Populated__c') == false ) {
                        item.put('System_Auto_Populated_ISR__c', true);             //Rev 1.8           
                        item.put('Inside_Sales_Rep__c', roleToUserIdMap.get('Inside Sales Rep'));
                    }
                    IF(item.get('Inside_Sales_Rep__c') == NULL && currentAccountRecord.RecordType.Name =='Partner Account'){
                        item.put('System_Auto_Populated_AE__c', true);
                        item.put('Inside_Sales_Rep__c',roleToUserIdMap.get('Inside Channel Account Manager'));   
                    }
                //Rev 2.0-end                           
                }
                //End Rev 13.0  
                else{
                     // Rev 9.1 -- If no account team member with same role as Campaign's Follow-up role then check for Geo-based assignment
                    if (item.get('Account_Play_Owner__c') == null && AccidtoTSAid.get(currentAccountRecord.Id) != null){  
                        for (id TSAID : AccidtoTSAid.get(currentAccountRecord.Id)){
                            if (TSAMAP.get(TSAID) != null){
                               if(campIdToFollowUpRoleMap.get(String.valueOf(item.get('Campaign__c'))) == TSAMAP.get(TSAID).role__r.name){                                    
                                     system.debug('geo - populate is true');
                                     item.put('Geo_populated__c' , true); 
                                     item.put('Territory_Sales_User_Assignment__c' , TSAID);
                                     item.put('System_Auto_Populated_AP_Owner__c', true);
                                     IF(TSAmap.get(tsaid).Territory__r.Geography_Type__c == 'Zipcode'){
                                         item.put('Account_Play_Owner__c', TSAmap.get(TSAID).User__r.id); 
                                     }Else if(item.get('Account_Play_Owner__c') == null && TSAmap.get(tsaid).Territory__r.Geography_Type__c == 'State'){
                                         item.put('Account_Play_Owner__c', TSAmap.get(TSAID).User__r.id);
                                     }Else if(item.get('Account_Play_Owner__c') == null && TSAmap.get(tsaid).Territory__r.Geography_Type__c == 'Country'){
                                         item.put('Account_Play_Owner__c', TSAmap.get(TSAID).User__r.id);
                                     }  
                                    // item.put('Account_Play_Owner__c', TSAmap.get(TSAID).User__r.id); 
                                }
                            }
                        }                 
                    }
                    // Rev 9.1 end                 
                }
                if (item.get('Account_Play_Owner__c') == null) {
                    item.put('Account_Play_Owner__c', item.get('Account_Owner__c'));    //Rev 3.0        
                }
            }                                             
        }       
    }*/
    // Rev 1.6 - Don't overwrite RL/AP owner, AE and ISR field if already contain value
    //Method to populate Account Owner to RL/AP Owner
    /*public static void assignAccountOwnerToRL_APOwner(List<Sobject> rLAPList){
        for(Sobject item : rLAPList){
            System.debug('## Inside assignAccountOwnerToRL_APOwner method');            
            if (item.getSObjectType() == Relationship_Lead__c.sObjectType) {                
                if (item.get('Relationship_Lead_Owner__c') == null) {
                    item.put('System_Auto_Populated_RL_Owner__c', true);    //Rev 1.8
                    item.put('Relationship_Lead_Owner__c', item.get('Account_Owner__c'));
                }
            }
            else if (item.getSObjectType() == Account_Play__c.sObjectType){
                if (item.get('Account_Play_Owner__c') == null) {
                    item.put('System_Auto_Populated_AP_Owner__c', true);    //Rev 1.8
                    item.put('Account_Play_Owner__c', item.get('Account_Owner__c'));
                }                   
            }
        }
    }*/
    
    /*private static void throwTestException(boolean bool){
        if(bool){
            throw new dellUtil.DellException('TESTMETHOD EXCEPTION TESTING.');
        }       
    }*/
    
    //Rev 6.0 - start         
    /* This is utility method for creating new RL curresond to CM with "Requires Followup" status (CR# 2279)*/
   /* public static void createNewRLsForCampMembers(List<CampaignMember> campMembListToBeProcessed, Set<Id> leadIds){
        System.debug('### Inside Method createNewRLsForCampMembers  ###');
        
        System.debug('### LeadId Set [' + leadIds + ']');
        List<Relationship_Lead__c> newRLInstanceList =  new List<Relationship_Lead__c>();
        
        //String LEAD_QUALIFICATION_RECORDTYPEID = IdLookupUtils.getRecordTypeId('Lead Qualification', 'Lead', true); 
        Set<Id> recTypeIds = new Set<Id>();
        Id leadQualificationRT = IdLookupUtils.getRecordTypeId('Lead Qualification', 'Lead', true);
        recTypeIds.add(leadQualificationRT);
        Id talkToDellRT = IdLookupUtils.getRecordTypeId('Talk To Dell', 'Lead', true); 
        recTypeIds.add(talkToDellRT);
        Id externalLead = IdLookupUtils.getRecordTypeId('External Lead', 'Lead', true);
        recTypeIds.add(externalLead);
        Map<Id, Lead> leadMap = new Map<Id, Lead>([Select l.Id,l.contact__c, l.RecordTypeId from Lead l where l.RecordTypeId in:recTypeIds and l.Id IN :leadIds]);
        
        if(leadMap !=null)
            System.debug('### The leadMap size is ' + leadMap.size());
                        
        if (!disableRLAutoCreation) {               
            for(CampaignMember campMembItem: campMembListToBeProcessed){
                //Rev 4.0
                //Rev 1.7
                //Creates new RL
                //Account_Executive_PDM_ID__c, ISR_ICAM_ID__c
                
                                
                            
                Relationship_Lead__c  newRLInstance =  new Relationship_Lead__c(//Campaign_Vehicle__c = campMembItem.Campaign_Vehicle__c, 
                                Marketing_Comments__c = campMembItem.Marketing_Comments__c, /*Due_Date__c = campMembItem.Due_Date__c,*/ 
                 /*               Data_Center_Optimization__c = campMembItem.Data_Center_Optimization__c, End_user_Productivity__c = campMembItem.End_user_Productivity__c,
                                IT_Process_Simplification__c = campMembItem.IT_Process_Simplification__c, 
                                Dell_can_contact_me_in_the_future__c = campMembItem.Dell_can_contact_me_in_the_future__c, Decision_Making_Role__c = campMembItem.Decision_Making_Role__c, 
                                Employee__c = campMembItem.Employee__c,/*Relationship_Lead_Score__c  = campMembItem.Score__c,*/
                   /*             Dell_Existing_Customer__c = campMembItem.Dell_Existing_Customer__c, 
                                Purchase_Timeframe__c = campMembItem.Purchase_Timeframe__c, Purchase_Influence_Over__c = campMembItem.Purchase_Influence_Over__c, 
                                 CM_Source__c = campMembItem.Id,
                                  Contact__c = campMembItem.ContactId, Campaign__c = campMembItem.CampaignId,  
                                  Questions_Comments__c = campMembItem.Questions_Comments__c,
                                // Rev 1.7 Inside_Sales_Rep__c = campMembItem.ISM__c, RSM__c = campMembItem.RSM__c, AVP__c = campMembItem.AVP__c
                                Lead_Form_ID__c = campMembItem.Lead_Form_ID__c, Omniture_Visitor_ID__c = campMembItem.Omniture_Visitor_ID__c, 
                                LiveBall_Respondent_ID__c = campMembItem.LiveBall_Respondent_ID__c, Dell_Visitor_ID__c = campMembItem.Dell_Visitor_ID__c,
                                Lead_ID_Do_Not_Edit__c = campMembItem.Custom_Lead__c,  //Rev 4.1 
                                Relationship_Lead_Owner__c=campMembItem.Relationship_Lead_Owner_bypass__c, //R6.1 
                               // Inside_Sales_Rep__c=campMembItem.Inside_Sales_Rep_bypass__c, //R6.1
                                //Account_Executive__c=campMembItem.Account_Executive_bypass__c,    //R6.1 
                                Inside_Sales_Rep__c=campMembItem.ISR_ICAM_ID__c,
                                Account_Executive__c=campMembItem.Account_Executive_PDM_ID__c,
                                Eloqua_lead_score__c=campMembItem.Eloqua_lead_score__c, //R6.3
                                form_url__c=campMembItem.form_url__c,form_referrer__c=campMembItem.form_referrer__c,    //R6.4        
                                //rev 10.0 Lead_Capture_Date__c = campMembItem.Lead_Capture_Date__c);    //Manikandan
                                Lead_Capture_DateTime__c = campMembItem.Lead_Capture_DateTime__c);
                                
                                system.debug('status-----'+campMembItem.CM_Status__c );
                //7.0
                //Defect 66866 
                //if(campMembItem.status__c == 'Requires Follow-Up') 
                if(campMembItem.CM_Status__c == 'Requires Follow-Up')             
                {
                    system.debug('score-------'+campMembItem.Score__c);
                    if(campMembItem.score__c=='High Priority (Extremely hot Leads; SLA = 48 hours)' )
                    {
                        newRLInstance.relationship_lead_score__c=campMembItem.Score__c;
                        newRLInstance.due_date__c=system.today()+2;
                    }      
                    else if(campMembItem.score__c=='TeleQualified Lead (Potential Opportunity; SLA = 48 hours)')
                    {
                        newRLInstance.relationship_lead_score__c=campMembItem.Score__c;
                        newRLInstance.due_date__c=system.today()+2;

                    }
                    else if(campMembItem.score__c=='Priority (Contact participated in Marketing program; SLA = 1 Week)' ) //rev 8.2 'Priority (Contact requested follow up; SLA = 1 Week)')
                    {
                        newRLInstance.relationship_lead_score__c=campMembItem.Score__c;
                        newRLInstance.due_date__c=system.today()+7;

                    }
        
                }    //7.0
                          
                If(newRLInstance.contact__c==null){
                    if(campMembItem.LeadId!=null){
                        Lead leadObj = leadMap.get(campMembItem.LeadId);
                        if(leadObj.contact__c!=null)
                        newRLInstance.contact__c=leadObj.contact__c;
                    }
                }
                
                Id leadId = campMembItem.LeadId;
                                
                if(leadId==null)
                    leadId = campMembItem.Custom_Lead__c;
                
                System.debug('### test whether solution id should be populated?');
                System.debug('### leadId :' + leadId);    
                if(leadId==null || (leadId!=null && !leadMap.containsKey(leadId))){
                    newRLInstance.Solution_ID__c = campMembItem.Solution_ID__c;
                    System.debug('### populate the solution id from CM -> RL###');
                }
                
                newRLInstanceList.add(newRLInstance);           
            }
            if (newRLInstanceList.size() > 0){
                System.debug('### Inserting the new RLs ###');
                insert newRLInstanceList;
            }
        }       
    }//end of method   
    //Rev 6.0 - end
    */
    
    //Rev 5.0, 5.1
   /* public static void populatedValueToRL(List<Relationship_Lead__c> allNewRLList, Set<Id> campaignIdSet, Set<Id> cmIdSet, Set<Id> leadIdSet) {
        Map<Id, Campaign> campaignMap = new Map<Id, Campaign>();
        Map<Id, CampaignMember> campaignMemberMap = new Map<Id, CampaignMember>();
        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        
        for (Campaign camp : [SELECT Id, Next_Steps__c, Supporting_Information__c FROM Campaign WHERE Id IN :campaignIdSet]) {
            campaignMap.put(camp.Id, camp);
        }
        
        if (!cmIdSet.isEmpty()) {
            for (CampaignMember cm : [SELECT Id, Eloqua_Id__c FROM CampaignMember WHERE Id IN :cmIdSet]) {
                campaignMemberMap.put(cm.Id, cm);
            }   
        }
        
        if (!leadIdSet.isEmpty()) {
            for (Lead l : [SELECT Id, Eloqua_Id__c,Sales_Comments__c,Marketing_Comments__c,Eloqua_lead_score__c FROM Lead WHERE Id IN :leadIdSet]) { //R6.2 Added sales comments,Marketing comments and Eloqa Lead Score for CR 7178,CR 7171 -[Jagadeesan 23:05:2012]
                leadMap.put(l.Id, l);
            }
        }       
        
        for(Relationship_Lead__c rl :  allNewRLList) {
            if (rl.Next_Steps__c == null) rl.Next_Steps__c = campaignMap.get(rl.Campaign__c).Next_Steps__c;
            if (rl.Supporting_Information__c == null) rl.Supporting_Information__c = campaignMap.get(rl.Campaign__c).Supporting_Information__c;     
            
            if (campaignMemberMap.containsKey(rl.CM_Source__c)) {
                rl.Eloqua_ID__c = campaignMemberMap.get(rl.CM_Source__c).Eloqua_Id__c;
            }
            else if (leadMap.containsKey(rl.Lead_ID_Do_Not_Edit__c)) {          
                rl.Eloqua_ID__c = leadMap.get(rl.Lead_ID_Do_Not_Edit__c).Eloqua_Id__c;
                if(rl.Sales_Comments__c==null){  //R6.2  Added sales comments and Marketing comments if they are null then populate from Lead
                    rl.Sales_Comments__c=leadMap.get(rl.Lead_ID_Do_Not_Edit__c).Sales_Comments__c;  // for CR 7178 -[Jagadeesan 23:05:2012]
                }else{
                    rl.Sales_Comments__c=leadMap.get(rl.Lead_ID_Do_Not_Edit__c).Sales_Comments__c+'\n\n'+rl.Sales_Comments__c;
                }
                if(rl.Marketing_Comments__c==null){      
                    rl.Marketing_Comments__c=leadMap.get(rl.Lead_ID_Do_Not_Edit__c).Marketing_Comments__c;  
                }else{
                    rl.Marketing_Comments__c=leadMap.get(rl.Lead_ID_Do_Not_Edit__c).Marketing_Comments__c+'\n\n'+rl.Marketing_Comments__c;
                }
                rl.Eloqua_Lead_Score__c=leadMap.get(rl.Lead_ID_Do_Not_Edit__c).Eloqua_Lead_Score__c; // Populating Eloqua Lead score from Lead to RL  for CR 7171 -[Jagadeesan 13:07:2012]
            }           
        }
    }*/
    //Rev 8.1
    public static String getLeadScore_LeadQualification(Boolean leadReqCallFromDell, String Campaign_Vehicle ){        
        if (leadReqCallFromDell == true && Campaign_Vehicle == 'Telemarketing'){
           return 'TeleQualified Lead (Potential Opportunity; SLA = 48 hours)';
        }
        else if (leadReqCallFromDell == true && Campaign_Vehicle !='Telemarketing'){
            return  'High Priority (Extremely hot leads; SLA = 48 hours)';
        }
        else
            return 'Priority (Contact participated in Marketing program; SLA = 1 Week)';
    }
    //Rev 8.1 - end
}//end of class