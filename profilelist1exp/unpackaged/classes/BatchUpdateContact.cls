/*
Author: Azwanti Zuber

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0      11-OCT-2010   Azwanti         Created for CR4117, R11.10
2.0      19-Oct-2010   Carmen          Delete old jobs in start method
3.0      21-Jun-2017   Sajith          CR14459 - Modify APEX transition batch ápex job to exclude RL & AP
*/
global class BatchUpdateContact implements Database.Batchable<sObject>{
    global string queryContact;
    Integer CONTACT_BATCH_SIZE = 1000;
    //For test method
    public boolean isTest = false;
    
    global Database.QueryLocator Start(Database.BatchableContext BC){
        DBUtils.flushOutTheJobsQueue();
        //1. Get all the Contacts associated to the “Pending” Account-WorkItems.
        return Database.getQueryLocator(queryContact);
    }   
    
    global void Execute(Database.BatchableContext BC, List<sObject> scope){     
    //2. Create new “Pending” Contact-WorkItem records corresponding to all those contacts, populating Old owner and new owner. 
        Map<ID,Work_Items__c> accountWorkItemMap = new Map<ID,Work_Items__c>(); 
        List<Work_Items__c> listofContactWorkItem = new List<Work_Items__c>();
        Set<Id> AcctIDSet = new set<Id>(); 
        
        Work_Items__c workItem; 
        Contact contactScope;
        Id ScopeId;
        
        for(sobject s : scope){
            contactScope = (Contact)s;
            AcctIDSet.add(contactScope.AccountId);
        }
        // Now build a map of Work_Items__c keyed by accountID
        for (Work_Items__c W : [SELECT Account__c, Previous_Owner__c, New_Owner__c
                               FROM Work_Items__c
                               WHERE Account__c in :AcctIDSet AND Status__c = 'In Progress' AND Object_Type__c = 'Account']) {                
            accountWorkItemMap.put(W.Account__c,W);
        }

        // Now create the contact workitem in the scope
        for(sobject s : scope){
            contactScope = (Contact)s;  
            workItem = accountWorkItemMap.get(contactScope.AccountId);
            //1. Create Contact-WorkItems with Status = Pending and populating Previous and New Owner    
            if(workItem!= null){
            
                Work_Items__c ContactWorkItem = new Work_Items__c(Contact__c = contactScope.Id, Status__c = 'Pending', 
                                                                Previous_Owner__c = workItem.Previous_Owner__c, 
                                                                New_Owner__c = workItem.New_Owner__c, Object_Type__c = 'Contact');
                listofContactWorkItem.add(ContactWorkItem); 
            }
        }       
        if(listofContactWorkItem.size() > 0){   
            Database.insert(listofContactWorkItem,false);    
        }
    
    }
    
    global void Finish(Database.BatchableContext BC){
    	if(isTest != true){
            //4.0 Commenting below code as part of modify APEX transition batch ápex job to exclude RL & AP
	        //1. schedule next apex job : Open Tasks related to RL  
	        //BatchUpdRelationshipLeadExecute buRLexec = new BatchUpdRelationshipLeadExecute();   
	        //datetime TodayDate = datetime.now();
	        //string schTime = AccountOwnerTransitionUtils.BatchJobScheduleTime(TodayDate);
	        //system.schedule('6. Batch Update Relationship Lead ISR Transition' +String.valueOf(TodayDate), schTime, buRLexec); 
            
            //1. schedule next apex job : AP tasks
	        BatchUpdateOpptyTaskExecute buOpptyTask = new BatchUpdateOpptyTaskExecute();
	        datetime TodayDate = datetime.now();
	        string schTime = AccountOwnerTransitionUtils.BatchJobScheduleTime(TodayDate);
	        system.schedule('6. Batch Update Opportunity Task Owner Transition' +String.valueOf(TodayDate), schTime, buOpptyTask);  
    	}
    }
}