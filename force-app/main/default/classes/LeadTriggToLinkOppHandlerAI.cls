/*
 * Author   : Sonali
 * Purpose  : Gives abstract view of the business logics / functionalities implemented on Lead to link opportunities with Leads.
*/

public class LeadTriggToLinkOppHandlerAI implements AfterInsert{
    
    public void handleAfterInsert(List<sObject> listNew){
        System.debug('Entered Lead handleAfterInsert');
        //trigHandler.run();
    
       if(!LeadTriggerHandler.leadRecSelector.listChannelLeadtoDeal.isEmpty()){
            system.debug('After Insert Calling LeadFieldPopulator ***********');
            system.debug('list of Leads ***********'+LeadTriggerHandler.leadRecSelector.listChannelLeadtoDeal);
            system.debug('Set of Leads ***********'+LeadTriggerHandler.leadRecSelector.setChannelDealIds);
            LeadFieldPopulator.linkChannelLeadToOpportunity(LeadTriggerHandler.leadRecSelector.listChannelLeadtoDeal , LeadTriggerHandler.leadRecSelector.setChannelDealIds);
        }
        
     
    }

}