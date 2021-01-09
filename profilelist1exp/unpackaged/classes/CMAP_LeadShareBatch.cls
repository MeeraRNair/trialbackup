/*
Version CR Number   Release No  Date            Modified By     Description     
--------------------------------------------------------------------------------------------
1.0    							18-Jan-2013     Sandhya         CR 7832 - Lead visibility to Partner Lead Super User   
                                        						Batch apex for Lead share creation
2.0     						05-Nov-2013     Jiji            CR 235: R15.3      
3.0     						20-Nov-2013     Annie           CR 8837:R15.3
4.0     						13-Jan-2014     Annie           CR 8837:CRQ 0870 MLUR Share for Lead Super Users - RW    
5.0     CR16090		FY19-0802	04-July-2018    Venkat Sharan   Removed comments as part of code Reduce for the story 5121711                                                               
*/
global class CMAP_LeadShareBatch implements Database.Batchable<sObject> {
    public String query;
    global database.querylocator start(Database.BatchableContext BC){
        DBUtils.flushOutTheJobsQueue();
        return Database.getQueryLocator(query);
    }
    
   global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<LeadShare> leadShareInsertList = new List<LeadShare>();
        List<LeadShare> leadShareDeleteList = new List<LeadShare>();
        Map<String,group>existingGroupMap = new Map<String,group>();
        List<CMAP_ProcessQueue__c>batchProcessList = new List<CMAP_ProcessQueue__c>();
        Set<String> groupNameSet = new Set<String>();
        set<Id>channelLeadIdSet = new Set<Id>();
        set<Id>groupIdSet = new Set<Id>();
        //ver 2.0: Code Start
        List<CMAP_ProcessQueue__c>teamBatchList = new List<CMAP_ProcessQueue__c>();
        //Ver 2.0 : Code End
        //ver 3.0: Code Start     
        List<CMAP_ProcessQueue__c>mlurBatchList = new List<CMAP_ProcessQueue__c>();
        List<Mass_Upload_Lead_Request__Share> mlurShareInsertList = new List<Mass_Upload_Lead_Request__Share>();
        //Ver 3.0 : Code End
        try{
            
            for(sObject obj :scope){
                CMAP_ProcessQueue__c batchRec = (CMAP_ProcessQueue__c)obj;
                if(batchRec.operation__c == 'Insert' && batchRec.Type__c =='Share'){
                    groupNameSet.add('CMAP:'+batchRec.Partner_Account__c);
                    batchProcessList.add(batchRec);
                }
                //Ver 2.0: Code Start
                else if(batchRec.operation__c == 'Insert' && batchRec.Type__c =='TeamShare'){
                    groupNameSet.add('CMAP:AT:'+batchRec.Partner_Account__c);
                    teamBatchList.add(batchRec);
                }
                //ver 2.0: code end
                //ver 3.0: Code Start
                else if(batchRec.operation__c == 'Insert' && batchRec.Type__c =='MLUR Share'){
                    groupNameSet.add('CMAP:'+batchRec.Partner_Account__c);
                    mlurBatchList.add(batchRec);
                }
                //ver 3.0: Code End
            }
            for(Group gp : [Select Id ,Name from Group where name IN: groupNameSet]){
                existingGroupMap.put(gp.Name,gp);
            }
            for(CMAP_ProcessQueue__c cp : batchProcessList){
                if(existingGroupMap.ContainsKey('CMAP:'+cp.Partner_Account__c)){
                    LeadShare leadShareRec = new LeadShare(LeadId =cp.Channel_Lead__c,UserOrGroupId =existingGroupMap.get('CMAP:'+cp.Partner_Account__c).Id,LeadAccessLevel ='edit');
                    leadShareInsertList.add(leadShareRec);  
                }
            }
            //Ver 2.0: Code Start
            for(CMAP_ProcessQueue__c cp : teamBatchList){
                if(existingGroupMap.ContainsKey('CMAP:AT:'+cp.Partner_Account__c)){
                    LeadShare leadShareRec = new LeadShare(LeadId =cp.Channel_Lead__c,UserOrGroupId =existingGroupMap.get('CMAP:AT:'+cp.Partner_Account__c).Id,LeadAccessLevel ='Read');
                    leadShareInsertList.add(leadShareRec);  
                }
            }
            //ver 2.0 : COde end
            //ver 3.0 : Code start
            for(CMAP_ProcessQueue__c cp : mlurBatchList){
                if(existingGroupMap.ContainsKey('CMAP:'+cp.Partner_Account__c)){
                    //Ver 4.0 : Code start
                    Mass_Upload_Lead_Request__Share mlurShareRec = new Mass_Upload_Lead_Request__Share(ParentID = cp.Mass_Lead_Upload_Request__c,UserOrGroupId = existingGroupMap.get('CMAP:'+cp.Partner_Account__c).Id,AccessLevel = 'Edit');                    
                    //Ver 4.0 : Code end
                    mlurShareInsertList.add(mlurShareRec);  
                }
            }
            //ver 3.0 : Code end
            if(groupIdSet.size() >0 && channelLeadIdSet.size() >0){
                leadShareDeleteList = [Select Id ,LeadId,UserOrGroupId from LeadShare 
                                    where LeadId IN: channelLeadIdSet AND UserOrGroupId IN: groupIdSet];
            }
            database.Saveresult[] saveLeadShareResults;
            database.Deleteresult[] deleteLeadShareResults;
            //ver 3.0 : Code start
            database.Saveresult[] saveMLURShareResults;
            //ver 3.0 : Code end
            if(leadShareInsertList.size() > 0){
                saveLeadShareResults = database.insert(leadShareInsertList, false);
            }
            if(leadShareDeleteList.size() > 0){
                deleteLeadShareResults = database.delete(leadShareDeleteList, false);
            }
            //ver 3.0 : Code start
            if(mlurShareInsertList.size() > 0){
                saveMLURShareResults = database.insert(mlurShareInsertList, false);
            }
            //ver 3.0 : Code end
        }
        catch (Exception e){
        }  
    }// end of execute method
    
    global void finish(Database.BatchableContext BC){        
        CMAP_CleanUpScheduler schJob = new CMAP_CleanUpScheduler();   
        datetime TodayDate = datetime.now();
        string schTime = AccountOwnerTransitionUtils.BatchJobScheduleTime(TodayDate);
        system.schedule('CMAP_CleanUpBatch' +String.valueOf(TodayDate), schTime, schJob);                
    }
}