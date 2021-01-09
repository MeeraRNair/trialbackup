/*****************************************************************************
*CreatedBy : Shubham Bhatt
*Story: created for 7754350
*Purpose: To move all the complex manipulations which can be waited for a while as it is async. 
*Date : 10th Dec 2019 
*******************************************************************************/
public without sharing class RenewalOpportunityChangeEventHandlerAI implements AfterInsert{
    public void handleAfterInsert(List<sObject> listNew){
         
        //Added by Shubham Bhatt(Rubicon) STORY - 7754350 calling for creating proactive opty case creation
        RenewalOpportunityTriggerHandler.createRenewalQuotingCase((list<OpportunityChangeEvent>)trigger.new, (map<id,OpportunityChangeEvent>)trigger.newMap);
         
    }
}