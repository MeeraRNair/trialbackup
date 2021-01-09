/*
Author: Azwanti Zuber

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0      13-Oct-2010   Azwanti         Created for CR4117, R11.10
2.0      19-Oct-2010   Carmen          Delete old jobs in start method
*/
global class BatchUpdateAccountWorkItem implements Database.Batchable<sObject>{
    global string queryAccWorkItem; 
       
    //For test method
    public boolean isTest = false;
    
    global Database.Querylocator Start(Database.BatchableContext bc){
        DBUtils.flushOutTheJobsQueue();
        system.debug('### LALA inside: ' + Database.getQueryLocator(queryAccWorkItem));
        return Database.getQueryLocator(queryAccWorkItem);        
    }
    
    global void Execute(Database.BatchableContext bc, List<sObject> scope){
        List<Work_Items__c> workItemList = new List<Work_Items__c>();
        for(sObject s : scope){
            Work_Items__c workItem = (Work_Items__c)s;
            workItem.Status__c = 'In Progress'; 
            workItemList.add(workItem);
        }
        
        if(workItemList.size() > 0){
            // MM
            try{
                Database.update(workItemList,false);
            }catch(DmlException dmlExcep){
                system.debug('Dml Exception Error Message: '+ dmlExcep.getMessage());
            }catch(Exception e){
                system.debug('Exception Error Message: '+ e.getMessage());
            }
        }
    }
    
    global void Finish(Database.BatchableContext bc){
        if(isTest != true){
            //schedule next job : Opportunities transition & create new Oppty workItem       
         /*   BatchUpdateOpportunityExecute buOpptyExec = new BatchUpdateOpportunityExecute();        
            datetime TodayDate = datetime.now();
            string schTime = AccountOwnerTransitionUtils.BatchJobScheduleTime(TodayDate);
            system.schedule('2. Batch Update Opportunity Owner Transition ' + String.valueOf(TodayDate), schTime, buOpptyExec);  */
        }
    }
}