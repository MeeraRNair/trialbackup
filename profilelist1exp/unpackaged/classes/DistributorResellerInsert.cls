/**************************************************************************************************************************************************************
 * 
 * Name          : DistributorResellerInsert
 * Description   : controller class to 
 * ---------------------------------------------------------------------------------------
 * Revision  Name            Date                 CR                                         Description
 * 1.0      JVSANTOSH      22.07.2017          14647                                  Deal Reg: Distribution Strategy: Deal Reg Visibility for all Distributor/Reseller users.
 ***************************************************************************************************************************************************************/

public class DistributorResellerInsert {

 public static void DistributorResellerInserts(List < Opportunity > newopplist, map < Id, Opportunity > mapOldOpportunities) {

   List < User > UserList = new List < User > ();
   List < Group > GroupList = new List < Group > ();
   List < OpportunityShare > OppShareList = new List < OpportunityShare > ();
   list < opportunityshare > tobedeleted = new list < opportunityshare > ();
   Map < id, id > OppDistiAccMap = new Map < id, id > ();
   Map < id, id > oldOppDistiAccMap = new Map < id, id > ();
   Set < id > AccSet = new Set < id > ();
   Map < id, id > RoleUserMap = new Map < id, id > ();
   Set < id > roleset = new Set < id > ();
   Map < id, id > GroupRoleMap = new Map < id, id > ();
   Set < id > oldaccids = new Set < id > ();
   Set < id > oldroleset = new Set < id > ();
   Map < id, id > oldRoleUserMap = new Map < id, id > ();
   Map < id, id > oldGroupRoleMap = new Map < id, id > ();

   for (Opportunity opp: newopplist) {
    if (mapOldOpportunities == null) {
     if (opp.Distributor_Reseller_Name__c != null && opp.deal_reg_oppty__c == 'Yes') {
      AccSet.add(Opp.Distributor_Reseller_Name__c);
      OppDistiAccMap.Put(Opp.id, Opp.Distributor_Reseller_Name__c);
     }
    }
     
     if ((mapOldOpportunities != null && opp.Distributor_Reseller_Name__c != mapOldOpportunities.get(opp.Id).Distributor_Reseller_Name__c && opp.deal_reg_oppty__c == 'Yes')) {
       if(opp.Distributor_Reseller_Name__c != null){
           OppDistiAccMap.Put(Opp.id, Opp.Distributor_Reseller_Name__c);
           AccSet.add(Opp.Distributor_Reseller_Name__c);
        if(mapOldOpportunities.get(opp.Id).Distributor_Reseller_Name__c != null){
           oldaccids.add(mapOldOpportunities.get(opp.Id).Distributor_Reseller_Name__c); 
           oldOppDistiAccMap .Put(Opp.id, mapOldOpportunities.get(opp.Id).Distributor_Reseller_Name__c);      
        }
       }else{
           oldaccids.add(mapOldOpportunities.get(opp.Id).Distributor_Reseller_Name__c);
           oldOppDistiAccMap.Put(Opp.id, mapOldOpportunities.get(opp.Id).Distributor_Reseller_Name__c);      

       }              
     }
     
     system.debug('$$$$$$$$$ Accounts' + OppDistiAccMap);
     system.debug('$$$$$$$$$ Old Accounts' + oldaccids);
   }
   
   try{
   
   if (AccSet.Size() > 0 || oldaccids.Size() > 0) {             
    UserList = [select id, userroleid, UserRole.Name, AccountID from user where(AccountID IN: AccSet OR AccountID IN: oldaccids) and UserRole.Name like '%Partner User'];
    for (User usr: UserList) {
     if (oldaccids.size() > 0 && oldaccids.contains(usr.AccountID)) {
      oldroleset.add(usr.userroleid);
      oldRoleUserMap.put(usr.AccountID, usr.userroleid);
     } else {
      RoleUserMap.put(usr.AccountID, usr.userroleid); 
      roleset.add(usr.userroleid); 
     }
    }
     system.debug('$$$$$$$$$ Role Map' + RoleUserMap);
     system.debug('$$$$$$$$$ Old Role Map' + oldRoleUserMap);
   }
   
   if (RoleUserMap.size() > 0 || oldRoleUserMap.size() > 0) {
    GroupList = [select id, RelatedId, Type FROM Group where (RelatedId IN: roleset OR RelatedId IN: oldroleset) And Type = 'Role'];
    for (Group Gp: GroupList) {
     if (oldroleset.size() > 0 && oldroleset.contains(Gp.RelatedId)) {
      oldGroupRoleMap.put(Gp.RelatedId, Gp.id);
     } else {
      GroupRoleMap.put(Gp.RelatedId, Gp.id);
     }
    }
   }
   
   if (GroupRoleMap.size() > 0){
        system.debug('$$$$$$$$$ Group Map' + GroupRoleMap);

    for (ID oppid: OppDistiAccMap.keyset()){
     OpportunityShare os = new OpportunityShare();
     os.OpportunityAccessLevel = 'Read';
     os.OpportunityId = oppid;
     os.UserOrGroupId = GroupRoleMap.get(RoleUserMap.get(OppDistiAccMap.get(oppid)));
     OppShareList.add(os);
    }
   }
   // Inserting Opportunity Share
   if (OppShareList != null) {
    Database.SaveResult[] srList = Database.insert(OppShareList, false);
    }
   
   if (oldGroupRoleMap.size() > 0  ) {
        system.debug('$$$$$$$$$ Old Group Map' + oldGroupRoleMap);
    List < OpportunityShare > OsdeleteList = [select id, OpportunityId, OpportunityAccessLevel, UserOrGroupId, RowCause from OpportunityShare where UserOrGroupId in : oldGroupRoleMap.values() and OpportunityId in :oldOppDistiAccMap.keyset() And RowCause = 'Manual'
     And OpportunityAccessLevel = 'Read'];

    
      // Deleting  Opportunity Share 
   if (OsdeleteList .size() > 0) {
    system.debug('******' +OsdeleteList );
    Database.DeleteResult[] drList = Database.delete(OsdeleteList , false);
    }
   }
   
   }catch(exception ex)
   {
       System.debug('----------Exception Occured in DistributorResellerInsert------' +ex);
   }
 }

}