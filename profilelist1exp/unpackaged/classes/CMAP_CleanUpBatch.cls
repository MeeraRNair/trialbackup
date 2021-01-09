/*
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------------
1.0     18-Jan-2013    Sandhya      CR 7832 - Lead visibility to Partner Lead Super User   
                    Batch apex for deleting CMAP Proceess queue records once group,groupmember,leadshare created.
2.0     05-Nov-2013     Jiji            CR 235: R15.3
3.0     20-Nov-2013     Annie           CR 8837:R15.3
4.0     11-july-2018    JatinPuri1      CR 16143      Removed comments as part of code Reduce for the story 5100109 
*/
global class CMAP_CleanUpBatch implements Database.Batchable<sObject> {
    public String query;
    global database.querylocator start(Database.BatchableContext BC){
        DBUtils.flushOutTheJobsQueue();
        return Database.getQueryLocator(query); 
    }
    
   global void execute(Database.BatchableContext BC, List<sObject> scope){
       Set<String> groupNameSet = new Set<String>();
       set<Id>channelLeadIdSet = new Set<Id>();
       set<Id>groupIdSet = new Set<Id>();
       set<Id>userIdSet = new Set<Id>();
       Set<String>existingGroupMemberKey= new Set<String>();
       map<String,group>groupMap = new Map<String,Group>();
       List<CMAP_ProcessQueue__c>batchProcessDeleteList = new List<CMAP_ProcessQueue__c>();
       List<CMAP_ProcessQueue__c>groupCheckList = new List<CMAP_ProcessQueue__c>();
       Map<String,CMAP_ProcessQueue__c>batchUniqueInsertKey = new Map<String,CMAP_ProcessQueue__c>();
       Map<String,CMAP_ProcessQueue__c>batchUniqueDeleteKey = new Map<String,CMAP_ProcessQueue__c>();
       Map<String,CMAP_ProcessQueue__c>leadShareUniqueKeyMap = new Map<String,CMAP_ProcessQueue__c>();
       Map<Id, CMAP_ProcessQueue__c> memberQueueMap = new Map<Id, CMAP_ProcessQueue__c>();
       Map<Id, CMAP_ProcessQueue__c> shareQueueMap = new Map<Id, CMAP_ProcessQueue__c>();
       Set<String> gpNameSet = new Set<String>();
       Set<String> gpNameforshareSet = new Set<String>();
       //Ver 3.0 : Code start
       set<Id>mlurIdSet = new Set<Id>();
       Set<String> gpNameforshareSetMlur = new Set<String>();
       Map<Id, CMAP_ProcessQueue__c> shareQueueMapMlur = new Map<Id, CMAP_ProcessQueue__c>();
       Map<String,CMAP_ProcessQueue__c>mlurShareUniqueKeyMap = new Map<String,CMAP_ProcessQueue__c>();
       //Ver 3.0 : Code End
       try{
         for(sObject obj :scope){
           CMAP_ProcessQueue__c batchRec = (CMAP_ProcessQueue__c)obj;
            if(System.today() >= batchRec.createdDate.addDays(10)){
             batchProcessDeleteList.add(batchRec);
           }
           else{
             if(batchRec.Type__c =='Group'){
               groupNameSet.add('CMAP:'+batchRec.Partner_Account__c);
               groupCheckList.add(batchRec);
             }
             if(batchRec.Type__c =='GroupMember'){ 
                gpNameSet.add('CMAP:'+batchRec.Partner_Account__c);
                userIdSet.add(batchRec.Super_User_Id__c);
                memberQueueMap.Put(batchRec.Id, batchRec);
             }
             
             if(batchRec.Type__c =='Share'){
                gpNameforshareSet.add('CMAP:'+batchRec.Partner_Account__c);
                channelLeadIdSet.add(batchRec.Channel_Lead__c);
                shareQueueMap.Put(batchRec.Id, batchRec);
             }
             //Ver 2.0: Start
             if(batchRec.Type__c =='TeamGroup'){
                groupNameSet.add('CMAP:AT:'+batchRec.Partner_Account__c);
                groupCheckList.add(batchRec);
             }
             if(batchRec.Type__c =='TeamShare'){
                gpNameforshareSet.add('CMAP:AT:'+batchRec.Partner_Account__c);
                channelLeadIdSet.add(batchRec.Channel_Lead__c);
                shareQueueMap.Put(batchRec.Id, batchRec);
             }
             //Ver 2.0: End
             //Ver 3.0 : Code start
             if(batchRec.Type__c =='MLUR Share'){
                gpNameforshareSetMlur.add('CMAP:'+batchRec.Partner_Account__c);
                mlurIdSet.add(batchRec.Mass_Lead_Upload_Request__c);
                shareQueueMapMlur.Put(batchRec.Id, batchRec);
             }
             //Ver 3.0 : Code end
           }
         }
         Map<String, Group> gpmemberMap = new Map<String, Group>();
         if(gpNameSet.Size()>0){
            for(Group gp :[Select Id, Name from Group where Name IN :gpNameSet] ){
                gpmemberMap.Put(gp.Name, gp);
            }
         }
         Map<String, Group> gpShareMap = new Map<String, Group>();
         if(gpNameforshareSet.Size()>0){
            for(Group shareGP :[Select Id, Name from Group where Name IN :gpNameforshareSet] ){
                gpShareMap.Put(shareGP.Name, shareGP);
            }
         }
         //Ver 3.0 : Code start         
         Map<String, Group> gpShareMapMlur = new Map<String, Group>();
         if(gpNameforshareSetMlur.Size()>0){
            for(Group shareGP :[Select Id, Name from Group where Name IN :gpNameforshareSetMlur] ){
                gpShareMapMlur.Put(shareGP.Name, shareGP);
            }
         }
         //Ver 3.0 : Code end
         for(CMAP_ProcessQueue__c cpqRecords : memberQueueMap.Values()){
            String GroupIdString = gpmemberMap.get('CMAP:'+cpqRecords.Partner_Account__c).Id;
            if(cpqRecords.operation__c == 'Insert'){
                batchUniqueInsertKey.put(GroupIdString+':'+cpqRecords.Super_User_Id__c,cpqRecords);
            }
            if(cpqRecords.operation__c == 'Delete'){
                batchUniqueDeleteKey.put(GroupIdString+':'+cpqRecords.Super_User_Id__c,cpqRecords);
            }
            groupIdSet.add(gpmemberMap.get('CMAP:'+cpqRecords.Partner_Account__c).Id);
        }
        for(CMAP_ProcessQueue__c cpqRec : shareQueueMap.Values()){
            //Ver 2.0: CR 235: Start
            if( gpShareMap.get('CMAP:'+cpqRec.Partner_Account__c) != NULL ){
            //Ver 2.0: CR 235: End
                String GroupIdString = gpShareMap.get('CMAP:'+cpqRec.Partner_Account__c).Id;
                leadShareUniqueKeyMap.put(cpqRec.Channel_Lead__c+':'+GroupIdString,cpqRec);
            //Ver 2.0: CR 235: Start
            }
            else if( gpShareMap.get('CMAP:AT:'+cpqRec.Partner_Account__c) != NULL ){
                String TeamGroupIdString = gpShareMap.get('CMAP:AT:'+cpqRec.Partner_Account__c).Id;
                leadShareUniqueKeyMap.put(cpqRec.Channel_Lead__c+':'+TeamGroupIdString ,cpqRec);
            } 
            //Ver 2.0:  CR 235: End
        }
        //Ver 3.0 : Code start
        for(CMAP_ProcessQueue__c cpqRcrd : shareQueueMapMlur.Values()){
            if( gpShareMapMlur.get('CMAP:'+cpqRcrd.Partner_Account__c) != NULL ){
                String GroupIdString = gpShareMapMlur.get('CMAP:'+cpqRcrd.Partner_Account__c).Id;
                mlurShareUniqueKeyMap.put(cpqRcrd.Mass_Lead_Upload_Request__c+':'+GroupIdString,cpqRcrd);
            }
        }
        //Ver 3.0 : Code end
         if(groupNameSet.size() >0){
           for(Group gp :[Select Id, name from Group where name IN: groupNameSet]){
             groupMap.put(gp.name , gp);
           }
          //check whether group exists.If yes delete batch process records
           for(CMAP_ProcessQueue__c groupRec : groupCheckList){
             if(groupMap.containsKey('CMAP:'+groupRec.Partner_Account__c)){
               batchProcessDeleteList.add(groupRec);
             }
             //Ver 2.0:  CR 235: Start
             else if(groupMap.containsKey('CMAP:AT:'+groupRec.Partner_Account__c)){
               batchProcessDeleteList.add(groupRec);
             }
           }
         }
         //query for group member
         if(groupIdSet.size() >0 && userIdSet.size()>0){
           for(GroupMember gm :[SELECT Id,GroupId,UserOrGroupId FROM GroupMember
                                   WHERE GroupId IN :groupIdSet and UserOrGroupId IN: userIdSet]){
                 String groupMemberUniqueKey = gm.GroupId+':'+gm.UserOrGroupId;
                 existingGroupMemberKey.add(groupMemberUniqueKey);
                 }
             //If the operation is insert and record exist, then delete the CMAP Process queue record.    
              for(String st : existingGroupMemberKey){
                if(batchUniqueInsertKey.containskey(st)){
                  batchProcessDeleteList.add(batchUniqueInsertKey.get(st)); 
                }
              }
              for(String bu: batchUniqueDeleteKey.keySet()){
               if(!existingGroupMemberKey.contains(bu)){
                  batchProcessDeleteList.add(batchUniqueDeleteKey.get(bu));
                }
              }
         }
         //query for lead share
         if(leadShareUniqueKeyMap.size() >0){
             for(LeadShare ld :[SELECT LeadId,UserOrGroupId FROM LeadShare WHERE LeadId IN :channelLeadIdSet]){
                 String leadShareUniqueKey = ld.LeadId+':'+ld.UserOrGroupId;    
                 if(leadShareUniqueKeyMap.containsKey(leadShareUniqueKey)){
                    batchProcessDeleteList.add(leadShareUniqueKeyMap.get(leadShareUniqueKey));
                 }                         
             }
         }
         //Ver 3.0 : Code start         
         if(mlurShareUniqueKeyMap.size() >0){
           for(Mass_Upload_Lead_Request__Share mld :[SELECT ParentId,UserOrGroupId FROM Mass_Upload_Lead_Request__Share WHERE ParentId IN :mlurIdSet]){
                 String mlurShareUniqueKey = mld.ParentId+':'+mld.UserOrGroupId;                 
                    if(mlurShareUniqueKeyMap.containsKey(mlurShareUniqueKey) ){
                        batchProcessDeleteList.add(mlurShareUniqueKeyMap.get(mlurShareUniqueKey));
                    }                         
              }
         }
         //Ver 3.0 : Code end
         database.Deleteresult[] deleteResults;
         if(batchProcessDeleteList.size() > 0){
                deleteResults = database.delete(batchProcessDeleteList, false);
            }
        }catch (Exception e){
        }  
    }// end of execute method
    
    global void finish(Database.BatchableContext BC){
        if(LimitUtils.getAllowableQueries() > 0){     
            Datetime sysTime = System.now();
            sysTime = sysTime.addHours(2);
            String cmap_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            CMAP_GroupScheduler schJob = new CMAP_GroupScheduler();
            system.schedule('CMAP_GroupBatch' +String.valueOf(sysTime), cmap_exp, schJob);
        }
        
    }
}