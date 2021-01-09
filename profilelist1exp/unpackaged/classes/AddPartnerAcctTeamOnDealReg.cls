/*CR 11447:  Class to Automate the Partner Account Team Addition on Deal Registration Page
  Created By : Bikram
  
  Revision CR Number   Release No   Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
  1.0       CR 11701    R16.07                      Devika         To allow only active users to be added to the sales team
  2.0       CR12020     R16.10      05-Oct-2015     Azwanti         Add Parent OpportunityTeamMember to the child DSG OpportunityTeamMember
  3.0       CR 13964                01-Feb-2017     Vasavi.M        Comment AddPartnerAcctOnInsert method as it is related to DSG                                                                   
*/

public class AddPartnerAcctTeamOnDealReg {
 public static Boolean testdata = false;

 //CR12020 
 /* v3.0 - comment DSG related code - SEAHAWK  
 public static void AddPartnerAcctOnInsert(List<Opportunity> oppList){
     // Map to store Parent Opportunity and its corresponding child opportunities
     Map<ID,List<Opportunity>> MapParentOppIdToChildOppList= new Map<ID,List<Opportunity>>();
     
     // List to store the Opportunity Team Members
     List<OpportunityTeamMember> oppTeamList = new List<OpportunityTeamMember>();
     
     // List to store the Opportunity Share  
     List<OpportunityShare> oppShareList = new List<OpportunityShare>();
     
     List<Id> OppListId = new List<Id>();
     for(Opportunity o :oppList)
     {     
         OppListId.add(o.Id);   
     }
     
     List<Opportunity> childDSGOppList = [SELECT Id, CreatedBy.Profile_Name__c, Type, Related_Parent_Opportunity__c FROM Opportunity WHERE Id IN : OppListId];
     System.Debug('childDSGOppList##'+childDSGOppList);
     
     // logic to store Opportunities for PartnerAccount in a map 
     for(Opportunity o :childDSGOppList)
     {   
         //if CreatedBy Cast Iron profile && Type = 'Deal/Bid - Indirect' 
         if(o.CreatedBy.Profile_Name__c.Contains('Cast Iron Integration API only') &&  o.Type == 'Deal/Bid - Indirect' || testdata)
         {
             List<Opportunity> ListOpp = new List<Opportunity>();
             if(MapParentOppIdToChildOppList.get(o.Related_Parent_Opportunity__c) == null){
                 ListOpp.add(o);
             }else{
                 ListOpp = MapParentOppIdToChildOppList.get(o.Related_Parent_Opportunity__c);
                 ListOpp.add(o);
             }
             MapParentOppIdToChildOppList.put(o.Related_Parent_Opportunity__c, ListOpp);
         }
         
      }   
    // }
     System.Debug('MapParentOppIdToChildOppList##'+MapParentOppIdToChildOppList);
    
     
     //logic to copy Parent OpportunityTeamMember to child OpportunityTeamMember with the same access level.
     for(OpportunityTeamMember parentOppTeam : [SELECT OpportunityId,UserID,User.IsActive,TeamMemberRole,OpportunityAccessLevel from OpportunityTeamMember where OpportunityId IN: MapParentOppIdToChildOppList.keySet() AND User.IsActive = true]){//v1.0
         for(Opportunity DealOpp : childDSGOppList){
             OpportunityTeamMember oppTeam = new OpportunityTeamMember();
             oppTeam.OpportunityId = DealOpp.Id;
             oppTeam.UserId = parentOppTeam.UserId;
             oppTeam.TeamMemberRole = parentOppTeam.TeamMemberRole;
             oppTeamList.add(oppTeam);
             
             OpportunityShare oppShare = new OpportunityShare();
             oppShare.OpportunityId= DealOpp.Id; 
             oppShare.OpportunityAccessLevel= parentOppTeam.OpportunityAccessLevel; 
             oppShare.UserOrGroupId= parentOppTeam.UserId; 
             oppShareList.add(oppShare); 
         }
     }
     
     System.Debug('oppTeamList##'+oppTeamList);
     // inserting Opportunity Team Members
     if(oppTeamList.size() > 0)
     insert oppTeamList;
     // inserting Opportnity Share Access level
     if(oppShareList.size() > 0)
     insert oppShareList;    
    
 }
 v3.0 End*/

 public static void AddPartnerAcctOnUpdate(List < Opportunity > Lopp, Map < Id, Opportunity > OldMapTrigger) {

  //Fetching RecordType ID for Deal Registration - Submitted
  Id SubmittedOppRecordTypeID = IdLookupUtils.getRecordTypeId('Deal Registration-Submitted', 'Opportunity', TRUE);
  //Id SubmittedOppRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal Registration-Submitted').getRecordTypeId();

  // Storing the Submission Status value 
  String s = 'Thank you! The status can be tracked in the Approval Inbox on the \'Home\' tab.';

  // Map to store PartnerAccountID and its corresponding opportunities
  Map < ID, List < Opportunity >> MapAccIDListOpp = new Map < ID, List < Opportunity >> ();

  // Map to store PartnerAccountId and its corresponding Account Team Members
  Map < Id, List < AccountTeamMember >> acc2TMMap = new Map < Id, List < AccountTeamMember >> ();

  // List to store the Opportunity Team Members
  List < OpportunityTeamMember > oppTeamList = new List < OpportunityTeamMember > ();

  // List to store the Opportunity Share  
  List < OpportunityShare > oppShareList = new List < OpportunityShare > ();
  Set < Id > setPartnerAccountID = new Set < Id > ();
  Set < Id > setAccountID = new Set < Id > ();
  List < string > listatmRole = system.label.Partner_New_Role.split(',');
  List < Opportunity > listOpps = new List < Opportunity > ();
  // logic to store Opportunities for PartnerAccount in a map 
  for (Opportunity o: Lopp) {
   if (o.RecordTypeId == SubmittedOppRecordTypeID && o.Deal_Registration_Status__c == 'submitted' && o.Submission_Status_2__c == s && o.Submission_Status_3__c == s && (OldMapTrigger.get(o.id).RecordTypeId != SubmittedOppRecordTypeID || OldMapTrigger.get(o.id).Deal_Registration_Status__c == 'Rejected' || OldMapTrigger.get(o.id).Deal_Registration_Status__c == 'Recalled' || testdata || OldMapTrigger.get(o.id).AccountID <> o.AccountID))
   // || (o.Engage_Channel_Opportunity__c == TRUE &&(o.Deal_Registration_Status__c == 'submitted' || o.Deal_Registration_Status__c == 'approved')))
   {
    List < Opportunity > ListOpp = new List < Opportunity > ();
    if (MapAccIDListOpp.get(o.PartnerAccountID) == null) {
     ListOpp.add(o);

    } else {
     ListOpp = MapAccIDListOpp.get(o.PartnerAccountID);
     ListOpp.add(o);
    }
    setPartnerAccountID.add(o.PartnerAccountID);

    MapAccIDListOpp.put(o.PartnerAccountID, ListOpp);
    if (mapAccIDListOpp.get(o.AccountID) == null) {
     listOpps.add(o);

    } else {
     listOpps = mapAccIDListOpp.get(o.AccountID);
     listOpps.add(o);
    }
    setAccountID.add(o.AccountID);
    mapAccIDListOpp.put(o.AccountID, listOpps);
   }
   System.debug('++++1' + MapAccIDListOpp);
  }
  if (setPartnerAccountID.size() > 0 || setAccountID.size() > 0 ) {

   //logic to add AccountTeamMember to Opportunity Team from  Partner Account & Opportunity Share Access Level 
   for (AccountTeamMember accTeam: [SELECT AccountID, UserID, User.IsActive, TeamMemberRole from AccountTeamMember where(AccountID IN: setPartnerAccountID OR(AccountID IN: setAccountID and TeamMemberRole IN: listatmRole)) /* v 1.0 */ AND User.IsActive = true]) {
    for (Opportunity DealOpp: MapAccIDListOpp.get(accTeam.AccountID)) {
     System.debug('++++2' + DealOpp);
     OpportunityTeamMember oppTeam = new OpportunityTeamMember();
     oppTeam.OpportunityId = DealOpp.Id;
     oppTeam.UserId = accTeam.UserId;
     oppTeam.Partner_Account_Member__c = True;
     oppTeam.TeamMemberRole = accTeam.TeamMemberRole;
     oppTeamList.add(oppTeam);

     OpportunityShare oppShare = new OpportunityShare();
     oppShare.OpportunityId = DealOpp.Id;
     oppShare.OpportunityAccessLevel = 'Edit';
     oppShare.UserOrGroupId = accTeam.UserId;
     oppShareList.add(oppShare);
    }
   }
   // inserting Opportunity Team Members
   if (oppTeamList.size() > 0)
    insert oppTeamList;
   // inserting Opportnity Share Access level
   if (oppShareList.size() > 0)
    insert oppShareList;

  }
 }

 //Automate -"Add Account Team" - MAJ S-03 CR 11522 
 public static void AddAcctTeamOnUpdate(List < Opportunity > Lopp, Map < Id, Opportunity > OldMapTrigger) {

  //Fetching Channel Opportunity Record Type ID 
  Id ChannleOppRecordTypeID = IdLookupUtils.getRecordTypeId('Channel Opportunity', 'Opportunity', TRUE);
  //Id ChannleOppRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Channel Opportunity').getRecordTypeId();

  //Fetching RecordType ID for Deal Registration - Submitted
  Id SubmittedOppRecordTypeID = IdLookupUtils.getRecordTypeId('Deal Registration-Submitted', 'Opportunity', TRUE);
  //Id SubmittedOppRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal Registration-Submitted').getRecordTypeId();
  System.debug('--- Opportunity ID ---' + Lopp);

  // Map to store AccountID and its corresponding opportunities
  Map < ID, List < Opportunity >> MapAccIDListOpp = new Map < ID, List < Opportunity >> ();

  // Map to store AccountId and its corresponding Account Team Members
  Map < Id, List < AccountTeamMember >> acc2TMMap = new Map < Id, List < AccountTeamMember >> ();

  // List to store the Opportunity Team Members
  List < OpportunityTeamMember > oppTeamList = new List < OpportunityTeamMember > ();

  // List to store the Opportunity Share  
  List < OpportunityShare > oppShareList = new List < OpportunityShare > ();

  // logic to store Opportunities for End User Account in a map 
  for (Opportunity o: Lopp) {
   if (o.RecordTypeId == ChannleOppRecordTypeID && o.Deal_Registration_Status__c == 'Approved' && (OldMapTrigger.get(o.id).RecordTypeId != ChannleOppRecordTypeID || testdata) && (OldMapTrigger.get(o.id).RecordTypeId == SubmittedOppRecordTypeID)) {
    List < Opportunity > ListOpp = new List < Opportunity > ();
    if (MapAccIDListOpp.get(o.AccountID) == null) {
     ListOpp.add(o);

    } else {
     ListOpp = MapAccIDListOpp.get(o.AccountID);
     ListOpp.add(o);
    }
    MapAccIDListOpp.put(o.AccountID, ListOpp);
   }
   System.debug('++++1' + MapAccIDListOpp);
  }

  if (MapAccIDListOpp.keyset().size() > 0) {
   //logic to add AccountTeamMember to Opportunity Team from  End User Account & Opportunity Share Access Level 
   for (AccountTeamMember accTeam: [SELECT AccountID, USerID, TeamMemberRole from AccountTeamMember where AccountID IN: MapAccIDListOpp.keySet() /* v 1.0 */ AND User.IsActive = true]) {
    for (Opportunity DealOpp: MapAccIDListOpp.get(accTeam.AccountID)) {
     System.debug('++++2' + DealOpp);
     OpportunityTeamMember oppTeam = new OpportunityTeamMember();
     oppTeam.OpportunityId = DealOpp.Id;
     oppTeam.UserId = accTeam.UserId;
     oppTeam.TeamMemberRole = accTeam.TeamMemberRole;
     oppTeam.End_User_Acct_Member__c = true;
     oppTeamList.add(oppTeam);

     OpportunityShare oppShare = new OpportunityShare();
     oppShare.OpportunityId = DealOpp.Id;
     oppShare.OpportunityAccessLevel = 'Edit';
     oppShare.UserOrGroupId = accTeam.UserId;
     oppShareList.add(oppShare);
    }
   }
   // inserting Opportunity Team Members
   if (oppTeamList.size() > 0) {
       TriggerExecutionController.setskipOpportunityTeamTriggers(true); 
       insert oppTeamList;
       TriggerExecutionController.setskipOpportunityTeamTriggers(false); 
   }

   // inserting Opportnity Share Access level
   if (oppShareList.size() > 0)
    insert oppShareList;

  }
 }
 // Zeus

 public static void AddDistiResellerAccTeam(List < Opportunity > Lopp, Map < Id, Opportunity > OldMapTrigger) {
  //Fetching RecordType ID for Deal Registration - Submitted
  Id SubmittedOppRecordTypeID = IdLookupUtils.getRecordTypeId('Deal Registration-Submitted', 'Opportunity', TRUE);
  Id ChannelOppRecordTypeID = IdLookupUtils.getRecordTypeId('Channel Opportunity', 'Opportunity', TRUE);

  //Id ChannelOppRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Channel Opportunity').getRecordTypeId();
  //Id SubmittedOppRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal Registration-Submitted').getRecordTypeId();      

  // Map to store AccountID and its corresponding opportunities
  Map < ID, List < Opportunity >> MapAccIDListOpp = new Map < ID, List < Opportunity >> ();

  // Map to store AccountId and its corresponding Account Team Members
  Map < Id, List < AccountTeamMember >> acc2TMMap = new Map < Id, List < AccountTeamMember >> ();

  // List to store the Opportunity Team Members
  List < OpportunityTeamMember > oppTeamList = new List < OpportunityTeamMember > ();

  // List to store the Opportunity Share  
  List < OpportunityShare > oppShareList = new List < OpportunityShare > ();

  // logic to store Opportunities for Secondary Distributor/Reseller Account in a map 
  for (Opportunity o: Lopp) {
   // if(o.RecordTypeId == SubmittedOppRecordTypeID && o.Distributor_Reseller_Name__c != null &&o.Distributor_Reseller_Name__c != OldMapTrigger.get(o.Id).Distributor_Reseller_Name__c && o.Deal_Registration_Status__c == 'submitted' && (OldMapTrigger.get(o.id).RecordTypeId != SubmittedOppRecordTypeID || OldMapTrigger.get(o.id).Deal_Registration_Status__c == 'Rejected' || OldMapTrigger.get(o.id).Deal_Registration_Status__c == 'Recalled' || testdata))  
   // if (o.Distributor_Reseller_Name__c != OldMapTrigger.get(o.Id).Distributor_Reseller_Name__c && o.Distributor_Reseller_Name__c != NULL && (o.RecordTypeId == SubmittedOppRecordTypeID || o.RecordTypeId == ChannelOppRecordTypeID) )            
   //Added by Rajashekar Kura to Add Secondary Account team member to Opportunity team when Opportunity is Submitted for Approval
   if (o.Distributor_Reseller_Name__c != NULL &&
    ((o.RecordTypeId == SubmittedOppRecordTypeID && o.Deal_Registration_Status__c == 'submitted' && (OldMapTrigger.get(o.id).RecordTypeId != SubmittedOppRecordTypeID || OldMapTrigger.get(o.id).Deal_Registration_Status__c != 'submitted')) || (o.Distributor_Reseller_Name__c != OldMapTrigger.get(o.Id).Distributor_Reseller_Name__c && (o.RecordTypeId == SubmittedOppRecordTypeID || o.RecordTypeId == ChannelOppRecordTypeID)))) {
    List < Opportunity > ListOpp = new List < Opportunity > ();
    if (MapAccIDListOpp.get(o.Distributor_Reseller_Name__c) == null) {
     ListOpp.add(o);

    } else {
     ListOpp = MapAccIDListOpp.get(o.Distributor_Reseller_Name__c);
     ListOpp.add(o);
    }
    MapAccIDListOpp.put(o.Distributor_Reseller_Name__c, ListOpp);
   }
   System.debug('++++1' + MapAccIDListOpp);
  }

  if (MapAccIDListOpp.keyset().size() > 0) {

   //logic to add AccountTeamMember to Opportunity Team from  Secondary Distributor/Reseller Account & Opportunity Share Access Level 
   for (AccountTeamMember accTeam: [SELECT AccountID, USerID, TeamMemberRole from AccountTeamMember where AccountID IN: MapAccIDListOpp.keySet() /* v 1.0 */ AND User.IsActive = true]) {
    for (Opportunity DealOpp: MapAccIDListOpp.get(accTeam.AccountID)) {
     System.debug('++++2' + DealOpp);
     OpportunityTeamMember oppTeam = new OpportunityTeamMember();
     oppTeam.OpportunityId = DealOpp.Id;
     oppTeam.UserId = accTeam.UserId;
     oppTeam.TeamMemberRole = accTeam.TeamMemberRole;
     oppTeamList.add(oppTeam);

     OpportunityShare oppShare = new OpportunityShare();
     oppShare.OpportunityId = DealOpp.Id;
     oppShare.OpportunityAccessLevel = 'Edit';
     oppShare.UserOrGroupId = accTeam.UserId;
     oppShareList.add(oppShare);
    }
   }
   // inserting Opportunity Team Members
   if (oppTeamList.size() > 0)
    insert oppTeamList;
   // inserting Opportnity Share Access level
   if (oppShareList.size() > 0)
    insert oppShareList;
  }
 }

 //CR 12741 -  Remove Opportunity team members if distributor/reseller name is changed
 public static void deleteOldOppTeamsOnDistiNameUpdate(List < Opportunity > oppList, Map < Id, Opportunity > oldOpportunityMap) {

  Set < Id > distiAccountIds = new Set < Id > ();
  Set < Id > OpportunityIds = new Set < Id > ();
  set < Id > accTeamUserIdSet = new set < Id > ();
  Set < String > teamMembRoles = new Set < String > {
   'Distributor Contact',
   'Reseller Contact'
  };

  List < OpportunityTeamMember > otmtoDELETE = new List < OpportunityTeamMember > ();

  map < Id, Id > oppDistiMap = new map < Id, Id > ();
  map < Id, Set < Id >> distiToUserIdMap = new map < Id, Set < Id >> ();


  for (Opportunity newOpportunity: oppList) {
   If(newOpportunity.Distributor_Reseller_Name__c != oldOpportunityMap.get(newOpportunity.Id).Distributor_Reseller_Name__c && oldOpportunityMap.get(newOpportunity.Id).Distributor_Reseller_Name__c != null) {
    OpportunityIds.add(newOpportunity.Id);
    distiAccountIds.add(oldOpportunityMap.get(newOpportunity.Id).Distributor_Reseller_Name__c);
    system.debug('@@@ Accids' + distiAccountIds);

    oppDistiMap.put(newOpportunity.Id, oldOpportunityMap.get(newOpportunity.Id).Distributor_Reseller_Name__c);
    system.debug('###oppDistiMap' + oppDistiMap);
   }
  }

  if(distiAccountIds.size() > 0){
  for (AccountTeamMember accTeamMemb: [SELECT AccountID, USerID, TeamMemberRole from AccountTeamMember where AccountID IN: distiAccountIds]) {
   accTeamUserIdSet.add(accTeamMemb.UserId);
   Set < Id > accTeamUserIds = new Set < Id > ();
   if (distiToUserIdMap.get(accTeamMemb.AccountId) == null) {
    accTeamUserIds.add(accTeamMemb.UserID);
   } else {
    accTeamUserIds = distiToUserIdMap.get(accTeamMemb.AccountId);
    accTeamUserIds.add(accTeamMemb.UserID);
   }
   distiToUserIdMap.put(accTeamMemb.AccountId, accTeamUserIds);
  }

  List < OpportunityTeamMember > oppTeamList = new List < OpportunityTeamMember > ();
  oppTeamList = [Select Id, OpportunityId, UserId, User.contact.AccountId, TeamMemberRole from OpportunityTeamMember where(OpportunityId IN: OpportunityIds)
   AND(UserId IN: accTeamUserIdSet OR TeamMemberRole IN: teamMembRoles)
  ];
  system.debug('$$$oppteamList' + oppTeamList);

  for (OpportunityTeamMember oppTeam: oppTeamList) {
   String accId = oppDistiMap.get(oppTeam.OpportunityId);
   If((distiToUserIdMap.get(accId) != NULL && distiToUserIdMap.get(accId).contains(oppTeam.UserId)) || (oppTeam.TeamMemberRole == 'Distributor Contact' || oppTeam.TeamMemberRole == 'Reseller Contact')) {
    otmtoDELETE.add(oppTeam);
   }
  }
  If(otmtoDELETE.size() > 0) {
   delete otmtoDELETE;
  }
 }
 }

 //Logic to add Account Team Member to Engage Channel Deals
 public static void AddPartnerAcctOnInserttoEngageChannelDeals(List < Opportunity > Lopp, Map < Id, Opportunity > OldMapTrigger) {

  //Fetching Channel Opportunity Record Type ID 
  Id ChannleOppRecordTypeID = IdLookupUtils.getRecordTypeId('Channel Opportunity', 'Opportunity', TRUE);
  //Fetching RecordType ID for Deal Registration - Submitted
  Id SubmittedOppRecordTypeID = IdLookupUtils.getRecordTypeId('Deal Registration-Submitted', 'Opportunity', TRUE);
  //Id SubmittedOppRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal Registration-Submitted').getRecordTypeId();


  // Map to store PartnerAccountID and its corresponding opportunities
  Map < ID, List < Opportunity >> mapAccIDListOpp = new Map < ID, List < Opportunity >> ();

  // Map to store PartnerAccountId and its corresponding Account Team Members
  Map < Id, List < AccountTeamMember >> acc2TMMap = new Map < Id, List < AccountTeamMember >> ();

  // List to store the Opportunity Team Members
  List < OpportunityTeamMember > oppTeamList = new List < OpportunityTeamMember > ();

  // List to store the Opportunity Share  
  List < OpportunityShare > oppShareList = new List < OpportunityShare > ();
  Set < Id > setPartnerAccountID = new Set < Id > ();
  Set < Id > setAccountID = new Set < Id > ();
  List < string > listatmRole = system.label.Partner_New_Role.split(',');
  // logic to store Opportunities for PartnerAccount in a map 
  for (Opportunity o: Lopp) {
   if (o.Engage_Channel_Opportunity__c == TRUE) {
    List < Opportunity > ListOpp = new List < Opportunity > ();
    List < Opportunity > listOpps = new List < Opportunity > ();
    if (mapAccIDListOpp.get(o.PartnerAccountID) == null) {
     ListOpp.add(o);

    } else {
     ListOpp = mapAccIDListOpp.get(o.PartnerAccountID);
     ListOpp.add(o);
    }
    setPartnerAccountID.add(o.PartnerAccountID);
    mapAccIDListOpp.put(o.PartnerAccountID, ListOpp);
    if (mapAccIDListOpp.get(o.AccountID) == null) {
     listOpps.add(o);

    } else {
     listOpps = mapAccIDListOpp.get(o.AccountID);
     listOpps.add(o);
    }
    setAccountID.add(o.AccountID);
    mapAccIDListOpp.put(o.AccountID, listOpps);
   }
   System.debug('++++1' + mapAccIDListOpp);
  }

  //logic to add AccountTeamMember to Opportunity Team from  Partner Account & Opportunity Share Access Level 
  if (setPartnerAccountID.size() > 0 || setAccountID.size() > 0) {
   for (AccountTeamMember accTeam: [SELECT AccountID, UserID, User.IsActive, TeamMemberRole from AccountTeamMember where(AccountID IN: setPartnerAccountID OR(AccountID IN: setAccountID and TeamMemberRole IN: listatmRole)) AND User.IsActive = true]) {
    for (Opportunity DealOpp: mapAccIDListOpp.get(accTeam.AccountID)) {
     System.debug('++++2' + DealOpp);
     OpportunityTeamMember oppTeam = new OpportunityTeamMember();
     oppTeam.OpportunityId = DealOpp.Id;
     oppTeam.UserId = accTeam.UserId;
     oppTeam.TeamMemberRole = accTeam.TeamMemberRole;
     oppTeamList.add(oppTeam);

     OpportunityShare oppShare = new OpportunityShare();
     oppShare.OpportunityId = DealOpp.Id;
     oppShare.OpportunityAccessLevel = 'Edit';
     oppShare.UserOrGroupId = accTeam.UserId;
     oppShareList.add(oppShare);
    }
   }
   // inserting Opportunity Team Members
   if (oppTeamList.size() > 0)
    insert oppTeamList;
   // inserting Opportnity Share Access level
   if (oppShareList.size() > 0)
    insert oppShareList;

  }
 }
}