public class AccountTeamMemberTriggerHandlerBD implements BeforeDelete{
    public void handleBeforeDelete(List<sObject> listOld){
        AccountTemmemberUtils.publishRequestForRevokeAccountShareForMasterGroup((List<AccountTeamMember>)Trigger.Old);
    }

}