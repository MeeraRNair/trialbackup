/* 
Author: Raymond Yip

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0     26-OCT-2010     Raymond Yip     Created for CR4435
*/
global class BatchDeleteOpportunityTeamMember implements Database.Batchable<sObject>, Database.Stateful{
    public string queryString;
        
    global Database.QueryLocator Start(Database.BatchableContext BC){
        //AccountOwnerTransitionUtils.flushOutTheJobsQueue();
        System.debug('###DEBUG### BatchDeleteOpportunityTeamMember Job Start');
        system.debug('###DEBUG### BatchDeleteOpportunityTeamMember queryString : ' + queryString);

        return Database.getQueryLocator(queryString);
    }   
    
    global void Execute(Database.BatchableContext BC, List<sObject> scope){     
        System.debug('###DEBUG### BatchDeleteOpportunityTeamMember Job Executing');
        List<OpportunityTeamMember > otmToDeleteList = new List<OpportunityTeamMember >();
        System.debug('###DEBUG### BatchDeleteOpportunityTeamMember Scope Size = ' + scope.size());
        for(sObject sobj : scope) {
            OpportunityTeamMember  tempACT = (OpportunityTeamMember )sobj;
            
            if((tempACT.Opportunity.Account.Type == 'OEM' && !StringUtils.contains(tempACT.User.Title, 'OEM')) ||
                (tempACT.Opportunity.Account.Type == 'MSG' && !StringUtils.contains(tempACT.User.Title, 'MSG'))) {
            
                System.debug('###DEBUG### BatchDeleteOpportunityTeamMember Adding = ' + tempACT.Id + '--' + tempACT.User.Title + '--' + tempACT.TeamMemberRole);
                otmToDeleteList .add(tempACT);
            }
        }
        
        System.debug('###DEBUG### BatchDeleteOpportunityTeamMember Deletion Size = ' + otmToDeleteList.size());
        
        if(otmToDeleteList .size() > 0) {            

            //DELETE THE LIST
            //CLEAR THE LIST
            Database.DeleteResult[] resultList = Database.delete(otmToDeleteList ,false);
            //processOpptyEOL(scope);
 
            for(Database.DeleteResult dr : resultList){ 
                if (!dr.isSuccess()) { 
                    System.debug('###DEBUG### Error - ' + dr.getId() + ' -- '+ dr.getErrors()[0].getMessage());
                }
            } 
        }
    }

    global void Finish(Database.BatchableContext BC){
		System.debug('###DEBUG### BatchDeleteOpportunityTeamMember Job Ended');
    }

}