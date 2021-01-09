/*

 * Revision   Date            Modified By     Description
 * --------   -----------     ------------    -----------
 * 1.0        1-Dec-2019      Urvish          Created class for Opportunity Split
 
*/

public class OpportunitySplitHandlerBU implements BeforeUpdate{

    public void handleBeforeUpdate(List<sObject> listNew, Map<Id, sObject> mapOld){
    
        system.debug('OpportunitySplitHandlerBU :');
        Set<String> setOpportunityId = new Set<String>();
        List<Opportunitysplit> lstOppSplit = new List<OpportunitySplit>();
        Map<String,String> mapOppIdtoClass = new Map<String,String>();
        List<OpportunityTeamMember> otm = new List<OpportunityTeamMember>();
        
        for(sObject obj : Trigger.new)
        {
            OpportunitySplit objOppSplit =  (OpportunitySplit)obj;
            setOpportunityId.add(objOppSplit.OpportunityId);
        }
        
        otm = [select id, teammemberrole from OpportunityTeamMember where opportunityid =: setOpportunityId];
        
        if(otm.size() != null && otm.size() <> 1){
            for(Opportunity  objOpp : [SELECT id,Account_Classification__c from Opportunity where Id IN :setOpportunityId]){
                mapOppIdtoClass.put(objOpp.Id,objOpp.Account_Classification__c);
            }
            
            for(sObject obj : Trigger.new)
            {
                OpportunitySplit objOppSplit =  (OpportunitySplit)obj;
                if(mapOppIdtoClass.get(objOppSplit.OpportunityId) != 'Commercial')
                {
                    lstOppSplit.add(objOppSplit);
                }
            }
            if(lstOppSplit.size() > 0)
            {
                system.debug('lstOppSplit :'+ lstOppSplit);
                OpportunitySplitValidator.validateOppSplit(Trigger.new);
                OpportunitySplitValidator.validateForecastGroup(Trigger.new);
                OpportunitySplitValidator.validateSplitPercent(Trigger.new,(map<Id, OpportunitySplit>)Trigger.oldMap);
            }
        }
      OpportunitySplitManualCalculation.splitManualCalculation(Trigger.new, false);
    }
}