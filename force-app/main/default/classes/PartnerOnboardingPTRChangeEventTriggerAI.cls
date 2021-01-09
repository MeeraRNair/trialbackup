/***********************************************************
* Name          : Partner Track Relationship Change Event
*  
* ---------------------------------------------------------
* Revision  Name            Date                Description
* 1.0                                           created

************************************************************/
public class PartnerOnboardingPTRChangeEventTriggerAI implements AfterInsert {
    
   public void handleAfterInsert(List<sObject> listNew){
        
        PartnerOnboardingPTRUtility.createAccountShare((List<Partner_Track_Relationship__ChangeEvent>)Trigger.new);
   }
   
    

}