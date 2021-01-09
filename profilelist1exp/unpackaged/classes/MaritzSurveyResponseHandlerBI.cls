public class MaritzSurveyResponseHandlerBI implements BeforeInsert
{
    public void handleBeforeInsert(List<sObject> listNew)
    {
        SurveyResponseTriggerHandlerBI.beforeInsert(Trigger.new);
    }
}