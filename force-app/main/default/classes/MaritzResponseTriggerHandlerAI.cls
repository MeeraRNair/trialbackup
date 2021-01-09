public class MaritzResponseTriggerHandlerAI implements AfterInsert
{
    public void handleAfterInsert(List<sObject> listNew)
    {
        SurveyResponseTriggerHandlerAI.afterInsert(Trigger.new,Trigger.newMap);
    }
}