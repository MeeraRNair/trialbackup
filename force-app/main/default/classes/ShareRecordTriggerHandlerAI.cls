public class ShareRecordTriggerHandlerAI implements AfterInsert{
    public void handleAfterInsert(List<sObject> listNew){
        AccountTemmemberUtils.createMGAccountShare((List<Share_Records__e>)Trigger.new);
        AccountTemmemberUtils.revokeAccountShareForMasterGroup((List<Share_Records__e>)Trigger.new);
    }
}