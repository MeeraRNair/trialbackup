/* 
Author: Raymond Yip

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0     26-OCT-2010   	Raymond Yip     Created for CR4435
*/
global class BatchDeleteAccountTeamMember implements Database.Batchable<sObject>, Database.Stateful{
	public string queryString;
		
	global Database.QueryLocator Start(Database.BatchableContext BC){
		//AccountOwnerTransitionUtils.flushOutTheJobsQueue();
		System.debug('###DEBUG### BatchDeleteAccountTeamMember Job Start');
		system.debug('###DEBUG### BatchDeleteAccountTeamMember queryString : ' + queryString);

		return Database.getQueryLocator(queryString);
	}	
	
	global void Execute(Database.BatchableContext BC, List<sObject> scope){		
		System.debug('###DEBUG### BatchDeleteAccountTeamMember Job Executing');
		List<AccountTeamMember> actToDeleteList = new List<AccountTeamMember>();
		System.debug('###DEBUG### BatchDeleteAccountTeamMember Scope Size = ' + scope.size());
		for(sObject sobj : scope) {
			AccountTeamMember tempACT = (AccountTeamMember)sobj;
			
			if((tempACT.Account.Type == 'OEM' && !StringUtils.contains(tempACT.User.Title, 'OEM')) ||
				(tempACT.Account.Type == 'MSG' && !StringUtils.contains(tempACT.User.Title, 'MSG'))) {
			
				System.debug('###DEBUG### BatchDeleteAccountTeamMember Adding = ' + tempACT.Id + '--' + tempACT.User.Title + '--' + tempACT.TeamMemberRole);
				actToDeleteList.add(tempACT);
			}
		}
		
		System.debug('###DEBUG### BatchDeleteAccountTeamMember Deletion Size = ' + actToDeleteList.size());
		
		if(actToDeleteList.size() > 0) {			

			//DELETE THE LIST
			//CLEAR THE LIST
			Database.DeleteResult[] resultList = Database.delete(actToDeleteList,false);
        	//processOpptyEOL(scope);
 
	        for(Database.DeleteResult dr : resultList){ 
	            if (!dr.isSuccess()) { 
	                System.debug('###DEBUG### Error - ' + dr.getId() + ' -- '+ dr.getErrors()[0].getMessage());
	            }
	        } 
		}
	}

	global void Finish(Database.BatchableContext BC){
		System.debug('###DEBUG### BatchDeleteAccountTeamMember Job Ended');
	}

}