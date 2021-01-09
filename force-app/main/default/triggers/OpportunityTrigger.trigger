trigger OpportunityTrigger on Opportunity (before insert,before update, after insert,after update) {
    
    if(Trigger.isInsert&& Trigger.isafter){
        System.debug('Inside Opportunity Trigger');
        OpportunityTriggerUtil.populateOpportunityTeam(Trigger.new);
        
    }

}