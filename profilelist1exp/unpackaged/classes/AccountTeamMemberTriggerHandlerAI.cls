public class AccountTeamMemberTriggerHandlerAI implements AfterInsert{
    public void handleAfterInsert(List<sObject> listNew){
        AccountTemmemberUtils.publishAccountShareForMasterGroup((List<AccountTeamMember>)Trigger.New,null);
    }
}