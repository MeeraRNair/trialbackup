public class AccountTeamMemberTriggerHandlerBI implements BeforeInsert {

    public void handleBeforeInsert(List<sObject> listNew){
        system.debug('>>>>IN BeforeInsert:::');
        system.debug('>>>>IN BeforeInsert listNew:::'+listNew);
        AccountTemmemberUtils.checkOpportunityAccessLevel(Trigger.New);  
        
    }
}