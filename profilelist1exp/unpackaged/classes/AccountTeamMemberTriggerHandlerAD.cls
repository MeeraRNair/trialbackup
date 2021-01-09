public class AccountTeamMemberTriggerHandlerAD implements AfterDelete{
    public void handleAfterDelete(List<sObject> listOld){
        AccountTemmemberUtils.revokeAccountShareForMasterGroup((List<AccountTeamMember>)Trigger.Old);
    }
}