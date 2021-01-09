public class AccountTeamMemberTriggerHandlerBU implements BeforeUpdate {

    public void handleBeforeUpdate(List<sObject> listNew, Map<Id, sObject> mapOld){
     system.debug('>>>>IN BeforeUpdate::');
        AccountTemmemberUtils.checkOpportunityAccessLevel(Trigger.New); 
    }
}