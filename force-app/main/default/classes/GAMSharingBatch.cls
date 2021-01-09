/* 
Author: Natesh Alagiri

History:
Version Date            Modified By     Description     
-----------------------------------------------------------------------------------------------------------------------------------
1.0     27-Jun-2011     Natesh Alagiri  Created for CR6236 and CR6238
2.0     10-Apr-2012     Krishnamoorthi  Modified for R13.4 Maintenance CR 6573 -- To Give Product Catalog visibility to GAM users     
*/
global class GAMSharingBatch implements Database.Batchable<sObject> {
    public Boolean isTest = False;
    public String query;
    public Map<String,Id> GAMGroupNameToIdMap = new Map<String,Id>();
    public Set<Id> GroupIdSet = new Set<Id>();
    global database.querylocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        try{
            for(sObject obj :scope){
                Account AccountFromBatch = (Account)obj;            
                Id GlobalAccountId = AccountFromBatch.Id; //Root Account
                
                Set<Id> AccountIdSet = new Set<Id>{GlobalAccountId};
                Set<Id> accountIdsOflowestLevel = new Set<Id>{GlobalAccountId};
                Set<Id> lowestLevelAccountIds;
                Map<Id,AccountShare> accIdToAccShareMap = new Map<Id,AccountShare>();
                List<AccountShare> SharesToDelete = new List<AccountShare>();
                Set<Id> GAMuserIdSet = new Set<Id>();
                
                Map<Id,Group_Member_Queue__c> userIdtoMemberQueueMap = new Map<Id,Group_Member_Queue__c>();
                
                Boolean qualifiedDML = FALSE;
                
                //Exception Handling
                List<AccountShare> AccountShareExcepList = new List<AccountShare>();
                List<Database.SaveResult> SaveResultList = new List<Database.SaveResult>();
                
                //get/create global Account group //
    
                Map<Id,Id> AccountToGroupIdMap = getGroupId(AccountFromBatch);
                if(AccountToGroupIdMap==null || AccountToGroupIdMap.size()<=0){
                    return;
                }
                
                Id GlobalAccountGroupId = AccountToGroupIdMap.get(GlobalAccountId);
                            
                if(GlobalAccountGroupId==null){
                    return; // because the group ID was not successfully created.
                }
    
                //add current global account group Id
                GroupIdSet.add(GlobalAccountGroupId);
                
                //create share instance for Global Account
                AccountShare AccountShareRecord = createGAMShare(GlobalAccountId, GlobalAccountGroupId);
                //add the share to the map
                accIdToAccShareMap.put(GlobalAccountId,AccountShareRecord);
                
                //Iteration starts here
                do{
                    lowestLevelAccountIds = new Set<Id>();              
                    if(LimitUtils.getAllowableQueries() > 0){
                        for(Account AccountItem :[SELECT Id,Name,DMU__c,Type,Status__c,Account_Type_Integration__c,
                                                    ParentId,Parent.ParentId,Parent.Parent.ParentId,Parent.Parent.Parent.ParentId,
                                                    Parent.Parent.Parent.Parent.ParentId,Parent.Parent.Parent.Parent.Parent.ParentId
                                                  FROM Account 
                                                  WHERE 
                                                  Status__c IN ('Active','A')
                                                  AND (ParentId IN :accountIdsOflowestLevel
                                                  OR Parent.ParentId IN :accountIdsOflowestLevel
                                                  OR Parent.Parent.ParentId IN :accountIdsOflowestLevel
                                                  OR Parent.Parent.Parent.ParentId IN :accountIdsOflowestLevel
                                                  OR Parent.Parent.Parent.Parent.ParentId IN :accountIdsOflowestLevel
                                                  OR Parent.Parent.Parent.Parent.Parent.ParentId IN :accountIdsOflowestLevel)]){

                            AccountIdSet.add(AccountItem.Id);
                            
                            //System.debug('Account Name - '+AccountItem.Name);
                            if(AccountItem.Parent.Parent.Parent.Parent.Parent.ParentId!=null &&
                                accountIdsOflowestLevel.contains(AccountItem.Parent.Parent.Parent.Parent.Parent.ParentId)){
                                    lowestLevelAccountIds.add(AccountItem.Id);
                                    //System.debug('Lowest Level Account Name - '+AccountItem.Name);
                            }
                            if((AccountItem.Status__c =='Active' || AccountItem.Status__c =='A') &&
                                    AccountItem.type != 'OEM' && 
                                    AccountItem.type != 'MSG' &&
                                    (AccountItem.Account_Type_Integration__c == 'Account' || (AccountItem.Account_Type_Integration__c == 'Sub Account' && AccountItem.DMU__c == TRUE) || AccountItem.Account_Type_Integration__c == 'PAR ACCOUNT')){
                                //create share instance
                                AccountShareRecord = createGAMShare(AccountItem.Id, GlobalAccountGroupId);
                                //add the share to the map
                                accIdToAccShareMap.put(AccountItem.Id,AccountShareRecord);
                            }
                        }
                    }
                    accountIdsOflowestLevel = lowestLevelAccountIds;
                } while(accountIdsOflowestLevel.size()>0);
                System.debug('Total Accounts in the Hierarchy - '+AccountIdSet.Size());
                //Iteration ends here
                
                Set<Id> accountIdsTobeShared = accIdToAccShareMap.keySet();
                GroupIdSet.remove(GlobalAccountGroupId);
                
                //checking existing GAM shares, and arranging into a map and a list
                if(LimitUtils.getAllowableQueries() > 0){
                    try{
                        SharesToDelete = [SELECT Id, AccountID,UserOrGroupId 
                                          FROM AccountShare 
                                          WHERE AccountId IN :AccountIdSet AND UserOrGroupId IN :GroupIdSet];
                    }
                    catch(Exception e){
                        System.debug('####  GAM : Exception on Account Share manipulation job ('+ scope+ '):' + e.getMessage());
                    }
                }
                if(LimitUtils.getAllowableQueries() > 0){
                    for(AccountShare existingGAMShare: [SELECT Id, AccountID,UserOrGroupId 
                                                        FROM AccountShare
                                                        WHERE UserOrGroupId = :GlobalAccountGroupId]){
                        if(!accountIdsTobeShared.contains(existingGAMShare.AccountId)){                           
                            //to delete the forign group shares OR ineligible Accounts' shares. 
                            SharesToDelete.add(existingGAMShare);
                        }
                        else{
                            //dont need to add the share again 
                            accIdToAccShareMap.remove(existingGAMShare.AccountId);
                        }
                    }
                }
                
                //querying for the GAM team member users                 
                Group_Member_Queue__c grpMemberQueue;
                
                if(LimitUtils.getAllowableQueries() > 0){
                    for(AccountTeamMember GAMTeamMember : [SELECT UserId, TeamMemberRole, AccountId 
                                                           FROM AccountTeamMember 
                                                           WHERE AccountId IN :accountIdSet
                                                           AND TeamMemberRole = 'Global Account Manager']){
                        GAMuserIdSet.add(GAMTeamMember.UserId);                 
                        grpMemberQueue = new Group_Member_Queue__c(Group_ID__c = GlobalAccountGroupId,GAM_User__c = GAMTeamMember.UserId,Operation__c = 'Insert'); // to avoid extra loop.
                        userIdtoMemberQueueMap.put(GAMTeamMember.UserId, grpMemberQueue);
                        System.debug('Added Group Member Queue - '+grpMemberQueue);
                        
                    }
                }           
                
                //checking current memebers in the group
                for(GroupMember grpMemberItem : [SELECT GroupId, UserOrGroupId
                                                 FROM GroupMember
                                                 WHERE GroupId = :GlobalAccountGroupId ]){
                    if(!GAMuserIdSet.contains(grpMemberItem.UserOrGroupId)){ //NOT contains
                        //delete the unwanted users from group                  
                        grpMemberQueue = new Group_Member_Queue__c(Group_ID__c = GlobalAccountGroupId,GAM_User__c = grpMemberItem.UserOrGroupId, Operation__c='Delete');        
                        userIdtoMemberQueueMap.put(grpMemberItem.UserOrGroupId, grpMemberQueue);
                    }
                    else{
                        //dont create memebership again.
                        userIdtoMemberQueueMap.remove(grpMemberItem.UserOrGroupId); 
                    }
                }
                
                //insert the new GAM shares for child accounts. The logic ensures that no shares inserted if there is no GAM user.              
                if(accIdToAccShareMap.size() > 0 && GAMuserIdSet.size() > 0){ 
                    //iterate and insert in batches
                    List<AccountShare> AccountShareList =  new List<AccountShare>();
                    for(AccountShare AccountShareItem :accIdToAccShareMap.values()){
                        AccountShareList.add(AccountShareItem);
                        if(AccountShareList.size()==200 ){
                            if(getQualifiedDML(AccountShareList.size())){
                                
                                Database.SaveResult[] rsltUA = database.insert(AccountShareList,false);
                                AccountShareExcepList.addAll(AccountShareList);
                                SaveResultList.addAll(rsltUA);
                            }
                            AccountShareList.clear();       
                            
                        }                   
                    }
                    if(AccountShareList.size()>0){
                        if(getQualifiedDML(AccountShareList.size())){
                            
                            Database.SaveResult[] rsltUA = database.insert(AccountShareList,false);
                            AccountShareExcepList.addAll(AccountShareList);
                            SaveResultList.addAll(rsltUA);
                        }
                        
                    }
                    if(!SaveResultList.isEmpty() && !AccountShareExcepList.isEmpty()){
                        DBUtils.processResult(AccountShareExcepList, SaveResultList, 'AccountShare', 'Insert', 'GAM Sharing Calculation(' + AccountFromBatch.Account_ID__c +')');
                        SaveResultList.clear();
                    }
                }
                
                
                //freeing up the memory
                accIdToAccShareMap.clear();
                SaveResultList.clear();
                AccountShareExcepList.clear();
                
                //to delete the forign group shares.
                if(SharesToDelete.size() > 0 && getQualifiedDML(SharesToDelete.size())){ 
                    //Database.Deleteresult[] deleteResult = database.delete(SharesToDelete,false);                 
                    database.delete(SharesToDelete,false);
                    //DBUtils.processResult(SharesToDelete, deleteResult, 'AccountShare', 'Delete', 'GAM Sharing Calculation');
                }
                
                //insert the new Queue records               
                if(userIdtoMemberQueueMap.size() > 0 && getQualifiedDML(userIdtoMemberQueueMap.size())){    
                    database.insert(userIdtoMemberQueueMap.values(),false);
                }
                
            }
        }catch(Exception e){
            System.debug('####  GAM : Exception on Account Share manipulation job ('+ scope+ '):' + e.getMessage());
            GAMbatchJobUtils.sendOptionalNotification('GAM : Exception on Account Share manipulation job' , 'Exception occurred (' + scope+ '):' + e.getMessage());
        }
    }//end of execute method        
    
    global void finish(Database.BatchableContext BC){       
        
        if(LimitUtils.getAllowableQueries() > 0){
            AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email,
                                CompletedDate,ExtendedStatus,JobType, MethodName                                    
                              FROM AsyncApexJob
                              WHERE Id = :BC.getJobId()];
        
            system.debug('Completed Date = ' + a.CompletedDate);        
            system.debug('Status = ' + a.Status);
            system.debug('Extended Status = ' + a.ExtendedStatus);              
            system.debug('Job Type = ' + a.JobType);        
            system.debug('Method Name = ' + a.MethodName);
            system.debug('Total Job Items = ' + a.TotalJobItems);       
            system.debug('Job Items Processed = ' + a.JobItemsProcessed);       
            system.debug('Number Of Errors = ' + a.NumberOfErrors);
            system.debug('Created By.Email = ' + a.CreatedBy.Email);
        }
        GAMbatchJobUtils.sendOptionalNotification('GAM : Finished Account Share manipulation job',
                                                  'Finished Account Share manipulation job, and now scheduling Group Member manipulation job');
        
        GAMGroupMemberSchedule schJob = new GAMGroupMemberSchedule();   
        datetime TodayDate = datetime.now();
        string schTime = AccountOwnerTransitionUtils.BatchJobScheduleTime(TodayDate);
        if(!isTest){
            system.schedule('GAMGroupMemberBatch' +String.valueOf(TodayDate), schTime, schJob);
        }
    }//end of finish method
    
    
    public Boolean getQualifiedDML(Integer size){
        if(LimitUtils.getAllowableDMLRows() > size && LimitUtils.getAllowableDMLStatements() > 0){
            return TRUE;
        }
        else{
            return FALSE;
        }
    }
    
    public AccountShare createGAMShare(Id AccountId, Id GAMGroupId){
        AccountShare AccountShareRecord = new AccountShare(AccountId = AccountId, UserOrGroupId = GAMGroupId, AccountAccessLevel = 'Edit',CaseAccessLevel = 'Edit', OpportunityAccessLevel = 'Edit');
        return AccountShareRecord;
    }   
    
    public Map<Id,Id> getGroupId(Account GlobalAccount){
        Map<Id,Id> AccountToGroupIdMap = new Map<Id,Id>();
        if(GlobalAccount.Account_ID__c == null || StringUtils.isEmpty(GlobalAccount.Account_ID__c) || !(LimitUtils.getAllowableQueries() > 0)){
            return null;
        }
        String GlobalAccountGroupName = 'GAM:' + GlobalAccount.Account_ID__c;
        
        //If(GAMGroupItem.AccountToGroupIdMap.isEmpty()){
        if(GAMGroupNameToIdMap.containsKey(GlobalAccountGroupName)){
            AccountToGroupIdMap.put(GlobalAccount.Id,GAMGroupNameToIdMap.get(GlobalAccountGroupName));
        }
        else{
            Group GlobalAccountGroup = new Group(Name = 'GAM:' + GlobalAccount.Account_ID__c, DoesIncludeBosses = FALSE);
            if(LimitUtils.getAllowableDMLRows() > 0 && LimitUtils.getAllowableDMLStatements() > 0){ 
                try{
                    //insert GlobalAccountGroup;
                    //V 2.0 Changes -- Start
                    database.insert(GlobalAccountGroup, false);
                    if (GlobalAccountGroup.Id != null){
                        GAMQueueInsert(GlobalAccountGroup.Id);
                    }
                    //V 2.0 changes -- End
                }
                catch(Exception e){
                    return null;
                }
            }
            else{
                return null;
            }
            AccountToGroupIdMap.put(GlobalAccount.Id,GlobalAccountGroup.Id);
        }
        return AccountToGroupIdMap;
    }
    //V 2.0 Changes -- Start
    public void GAMQueueInsert(Id groupId){
    List<Group> parentGrpList = [Select Id from Group where Name='GAM Users Catalog Visibility Public Grp'];
    if(parentGrpList.size()!= 1) return;
    Group_Member_Queue__c grpMemberQCatalog = new Group_Member_Queue__c(Group_ID__c = parentGrpList[0].Id, Child_Group_Id__c = groupId,Operation__c = 'Insert');
    database.insert(grpMemberQCatalog, false);
    //insert grpMemberQCatalog;

}
    //V 2.0 changes -- End   
    
}//end of class