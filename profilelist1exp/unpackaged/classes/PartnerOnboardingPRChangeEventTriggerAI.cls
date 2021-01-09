public class PartnerOnboardingPRChangeEventTriggerAI implements AfterInsert{
    
    public void handleAfterInsert(List<sObject> listNew){
        PartnerOnboardingPRUtility.sendConfirmationFlagSet((List<Partner_Request__ChangeEvent>)Trigger.new);
    }
    

}