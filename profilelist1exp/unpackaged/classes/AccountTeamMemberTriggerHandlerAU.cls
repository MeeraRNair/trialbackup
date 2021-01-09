public class AccountTeamMemberTriggerHandlerAU implements AfterUpdate{
    public void handleAfterUpdate(List<sObject> listNew,  Map<Id, sObject> mapOld){
        List<AccountTeamMember> listUpdatedATM = new List<AccountTeamMember>();
        List<AccountTeamMember> listNewATM = (List<AccountTeamMember>)listNew;
        Map<Id, AccountTeamMember> mapOldRecords = (map<Id, AccountTeamMember>)Trigger.OldMap;
        for(AccountTeamMember atm : listNewATM){
            if(atm.AccountAccessLevel != mapOldRecords.get(atm.Id).AccountAccessLevel){
                listUpdatedATM.add(atm);
            }
        } 
        if(!listUpdatedATM.isEmpty()){
            AccountTemmemberUtils.publishAccountShareForMasterGroup((List<AccountTeamMember>)listUpdatedATM,null);
        }
    }
}