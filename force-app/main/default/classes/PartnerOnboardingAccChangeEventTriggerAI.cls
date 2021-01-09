public class PartnerOnboardingAccChangeEventTriggerAI implements AfterInsert{

    public void handleAfterInsert(List<sObject> listNew){
        PartnerOnboardingUpdateAccount.updateUDAValuesOnAccount (Trigger.new);
    }
    
}