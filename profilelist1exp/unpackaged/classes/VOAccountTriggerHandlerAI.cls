public class VOAccountTriggerHandlerAI implements AfterInsert{
    public void handleAfterInsert(List<sObject> listNew){
        VOAccountTriggerHandler.afterInsertHandler((List<Account>)trigger.new, (Map<Id,Account>)trigger.newMap);
    }
}