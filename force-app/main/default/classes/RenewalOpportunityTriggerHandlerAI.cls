public class RenewalOpportunityTriggerHandlerAI implements AfterInsert{
    public void handleAfterInsert(List<sObject> listNew){
    
        //Sharath:check if any oppty's probability grater than 60
        system.debug(UserInfo.getfirstName());
    system.debug(UserInfo.getLastName());
    
    if(UserInfo.getfirstName() == 'Renewals Core' && UserInfo.getLastName() == 'Integration User')
    {
        //RenewalOpportunityTriggerHandler.validateEmcOppNumberRenewalInsert(Trigger.new);
     } 
      
     }
     }