/*
Author: Azwanti Zuber

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0     28-SEPT-2010   	Azwanti         Created for CR4117, R11.10
2.0     19-Oct-2010    	Carmen          Delete old jobs in start method
3.0		05-Oct-2014		Ragu	 		CR10496 - GlobalVariables.SKIP_ALL_OPP_TRIGGERS is replaced with TriggerExecutionController.setSkipOpportunityTriggers().
4.0     21-Jun-2017     Sajith          CR14459 - Modify APEX transition batch ápex job to exclude RL & AP
*/
global class BatchUpdateOpportunity implements Database.Batchable<sObject>{
    global String QueryForOpp;    
    Integer OPP_BATCH_SIZE  = 100;
    
    //For test method
    public boolean isTest = false;
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        DBUtils.flushOutTheJobsQueue();
        return Database.getQueryLocator(QueryForOpp);
    }   
    
    global void EXECUTE(Database.BatchableContext BC, List<sObject> scope){ 
        List<Opportunity> listOfOppToBeUpdated = new List<Opportunity>();
        List<Work_Items__c> listofOpptyWorkItem = new List<Work_Items__c>();
        Map<ID,Work_Items__c> accWorkItemMap = new Map<ID,Work_Items__c>();
        Work_Items__c workItem;
        String objectType = 'Opportunity';
        String Operation = 'Update';
        String JobName = 'Batch Update Opportunity Owner Transition';
        Map<ID,ID> IdToWorkItemIdMap = new Map<ID,ID>();
        
        // Buid Map to Work_Items__c to get new ownerID
        // First find all the accounts in the current scope of opportunities
        Set<Id> AcctIDSet = new set<Id>(); 
        
        // requery to get the latest Oppty records
        List<Opportunity> tempListOfOppty = (List<Opportunity>)scope;
        List<Opportunity> listOfOppty = [SELECT Id, OwnerId, AccountId FROM Opportunity WHERE Id IN :tempListOfOppty];
        for(Opportunity Oppty : listOfOppty){
             AcctIDSet.add(Oppty.AccountID);
        }
        
        // Now build a map of Work_Items__c keyed by accountID
        for (Work_Items__c W : [SELECT Id, Account__c, Previous_Owner__c, New_Owner__c, Status__c, Object_Type__c
                                FROM Work_Items__c
                                WHERE Account__c in :AcctIDSet AND Status__c = 'In Progress' AND Object_Type__c = 'Account' LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())]) {                
            accWorkItemMap.put(W.Account__c,W); 
        }    
        
        // Now update the opportunities in the scope
        for(Opportunity OpptyScope : listOfOppty){          
            workItem = accWorkItemMap.get(OpptyScope.AccountId);
            
            if(OpptyScope.OwnerId == workItem.Previous_Owner__c) {
                //1. Update ownership of those Opportunities owned by old owner to new owner
                OpptyScope.OwnerId = workItem.New_Owner__c;
                listOfOppToBeUpdated.add(OpptyScope);       
                IdToWorkItemIdMap.put(OpptyScope.Id,workItem.Id);
                
                if(listOfOppToBeUpdated.size() == OPP_BATCH_SIZE) {
                	TriggerExecutionController.setSkipOpportunityTriggers(true);
                    //GlobalVariables.SKIP_ALL_OPP_TRIGGERS = true;
                    Database.SaveResult[] listOfResult = Database.update(listOfOppToBeUpdated,false);
                    TriggerExecutionController.setSkipOpportunityTriggers(false);
                    //GlobalVariables.SKIP_ALL_OPP_TRIGGERS = false;
                    
                    DBUtils.processResult(listOfOppToBeUpdated,listOfResult,objectType,Operation,JobName,IdToWorkItemIdMap);
                    listOfOppToBeUpdated.clear();
                }
            }
            //2. Create opportunity-WorkItems with Status = Pending and populating Previous and New Owner               
            Work_Items__c OpptyWorkItem = new Work_Items__c(Opportunity__c = OpptyScope.Id, Status__c = 'Pending', 
                                                            Previous_Owner__c = workItem.Previous_Owner__c, 
                                                            New_Owner__c = workItem.New_Owner__c, Object_Type__c = 'Opportunity');
            listofOpptyWorkItem.add(OpptyWorkItem);             
        }
        
        if(listOfOppToBeUpdated.size() > 0){
        	TriggerExecutionController.setSkipOpportunityTriggers(true);
        	//GlobalVariables.SKIP_ALL_OPP_TRIGGERS = true;
            Database.SaveResult[] listOfResult = Database.update(listOfOppToBeUpdated,false);
            TriggerExecutionController.setSkipOpportunityTriggers(false);
            //GlobalVariables.SKIP_ALL_OPP_TRIGGERS = false;
            DBUtils.processResult(listOfOppToBeUpdated,listOfResult,objectType,Operation,JobName,IdToWorkItemIdMap);
        }
        
        if(listofOpptyWorkItem.size() > 0){
            Database.insert(listofOpptyWorkItem,false);
        }
    }
    
    global void FINISH(Database.BatchableContext BC){       
        if(isTest != true){  
            //4.0 Commenting below code as part of modify APEX transition batch ápex job to exclude RL & AP
	        //1. schedule next apex job : Account Play     
	        //BatchUpdateAccountPlayExecute buAccPlayExecute = new BatchUpdateAccountPlayExecute();
	        //datetime TodayDate = datetime.now();
	        //string schTime = AccountOwnerTransitionUtils.BatchJobScheduleTime(TodayDate);
	        //system.schedule('3. Batch Update Account Play ISR Transition '+String.valueOf(TodayDate), schTime, buAccPlayExecute);
	        
            //1. schedule next apex job : Account tasks     
	        BatchUpdateAccountTaskExecute buAccTaskExecute  = new BatchUpdateAccountTaskExecute();
	        datetime TodayDate = datetime.now();
	        string schTime = AccountOwnerTransitionUtils.BatchJobScheduleTime(TodayDate);       
	        system.schedule('3. Batch Update Open Account Task Transition' + String.valueOf(TodayDate), schTime, buAccTaskExecute);     
        }
    }
}