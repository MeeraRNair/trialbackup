public class VOAccountTriggerHandlerAU implements AfterUpdate{
	public void handleAfterUpdate(List<sObject> listNew, Map<Id, sObject> mapOld){
        VOAccountTriggerHandler.afterUpdateHandler((List<Account>)trigger.new, (Map<Id,Account>)trigger.oldMap, (Map<Id,Account>)trigger.newMap);
    }
}