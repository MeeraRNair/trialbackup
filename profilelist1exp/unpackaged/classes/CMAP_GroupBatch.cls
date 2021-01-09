/*
Version Date            Modified By     Release No        Description     
--------------------------------------------------------------------------------------------------------------
1.0     18-Jan-2013     Sandhya                           CR 7832 - Lead visibility to Partner Lead Super User   
                                                          Batch pex for creating group,group member
2.0     05-Nov-2013     Jiji                              CR235: R15.3
3.0     7- July-2018    Michael         FY19-DCS-0802     CR# 16142 Unused variables and commented codes are removed, Story# 5100128
4.0     13-Mar-2019     Ankur           FY20-0402         Story 6098770: Channel: [PAM-Technical] Lead Share            
*/
global class CMAP_GroupBatch implements Database.Batchable<sObject> {
    public String query;
    global database.querylocator start(Database.BatchableContext BC){
        DBUtils.flushOutTheJobsQueue();
        return Database.getQueryLocator(query);
    }
    
   global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<GroupMember> groupMemberListToInsert = new List<GroupMember>();
        List<GroupMember> groupMemberListToDelete = new List<GroupMember>();
        
        set<Id> accountSet = new set<Id>();
        
        Map<String,Group>groupInsertMap = new Map<String,Group>();
        set<Id> groupIdSet = new set<Id>();
        set<Id> userIdSet = new set<Id>();
        set<String> uniqueKeySet = new set<String>();  
        //Ver 2.0:Code Start
        Set<Id> accountIdSet = new Set<Id> ();
        Map<String, String> MapOfOEMRole = new Map<String, String>();
        Map<String, String> MapOfpartnerRole = new Map<String, String>();
        //Ver 2.0: Code End
        Id PartnerAccountRTId = IdLookupUtils.getRecordTypeId('Partner Account', 'Account', true);
        Id EndUserRTId= IdLookupUtils.getRecordTypeId('End-User Account', 'Account', true);
        try{
            for(sObject obj :scope){
                CMAP_ProcessQueue__c groupQueueRec = (CMAP_ProcessQueue__c)obj;
                if(groupQueueRec.operation__c == 'Insert' && groupQueueRec.Type__c =='Group'){
                    accountSet.add(groupQueueRec.Partner_Account__c);
                    Group groupItem = new Group( Name = 'CMAP:'+groupQueueRec.Partner_Account__c, DoesIncludeBosses = false);
                    groupInsertMap.put(groupItem.Name,groupItem);
                }
                else if(groupQueueRec.Type__c =='GroupMember' && groupQueueRec.operation__c == 'Insert'){
                    GroupMember groupMemberItem = new GroupMember(GroupId = groupQueueRec.GroupId__c, UserOrGroupId= groupQueueRec.Super_User_Id__c);
                    groupMemberListToInsert.add(groupMemberItem);
                }
                else if(groupQueueRec.Type__c =='GroupMember' && groupQueueRec.operation__c == 'Delete'){
                    groupIdSet.add(groupQueueRec.GroupId__c);
                    userIdSet.add(groupQueueRec.Super_User_Id__c);
                    uniqueKeySet.add(groupQueueRec.GroupId__c+ ':' + groupQueueRec.Super_User_Id__c);
                }
                //Ver 2.0: Start
                else if(groupQueueRec.Type__c =='TeamGroup' && groupQueueRec.operation__c == 'Insert'){
                    accountIdSet.add(groupQueueRec.Partner_Account__c);
                    //GroupName is given as CMAP:AT:ACCOUNT GUID
                    Group groupItem = new Group( Name = 'CMAP:AT:'+groupQueueRec.Partner_Account__c, DoesIncludeBosses = false);
                    groupInsertMap.put(groupItem.Name,groupItem);
                }
                //Ver 2.0: End
            }
            database.SaveResult[] insertResults;//Inserting groups

            if(groupInsertMap.size() > 0){
                insertResults = database.insert(groupInsertMap.values(), false);
            }           
            if(groupIdSet.size()>0){//Scenario where directly delete group member based on CMAP Process queue rec
                for(GroupMember groupMemberItem :[SELECT Id,GroupId,UserOrGroupId FROM GroupMember 
                                                  WHERE GroupId IN :groupIdSet
                                                  AND UserOrGroupId IN :userIdSet]){
                    String uniqueKey = groupMemberItem.GroupId + ':' + groupMemberItem.UserOrGroupId;
                    if(uniqueKeySet.contains(uniqueKey)){
                        groupMemberListToDelete.add(groupMemberItem);
                    }
                }               
            } 
           //Create group members for which group created now
           //Retrive Lead super users
           
           //4.0
            Map<ID,List<user>> mapUserIdSalesMotion = new Map<id,list<user>>();
            if(!accountSet.isempty())
            {
                mapUserIdSalesMotion = PamCMAPutilityClass.getUserssUnderSalesMotionList(accountSet); 
            }
            
            Map<String,String> mapUserToGroup = new Map<String,String>();
            if(!mapUserIdSalesMotion.isempty())
            {
                for(String strIdSm : mapUserIdSalesMotion.keyset()) {
                    for(user usrId: mapUserIdSalesMotion.get(strIdSm)) {
                        String strUniqueUserKey = 'CMAP:'+strIdSm+ '@' + usrId.id;
                        mapUserToGroup.put(strUniqueUserKey,usrId.id);          
                    }
                }
            }

           /*
                for(User usrObj : [SELECT Id, Name ,Enable_As_Partner_Lead_Super_User__c,accountid
                                   FROM User
                                   WHERE AccountId IN :accountSet AND Enable_As_Partner_Lead_Super_User__c = true AND isActive = true]){
                       
                   String uniqueUserKey = 'CMAP:'+usrObj.AccountId + '@' + usrObj.Id;
                    mapUserToGroup.put(uniqueUserKey,usrObj.Id);
                    
                    
            }*/
           
           for(String  userRec : mapUserToGroup.keySet()){
                String[] str1 = userRec.split('@');
                Id groupId = groupInsertMap.get(str1[0]).Id;
                GroupMember groupMemberItem = new GroupMember(GroupId = groupId, UserOrGroupId= mapUserToGroup.get(userRec));
                groupMemberListToInsert.add(groupMemberItem);
           }
           
           //Ver 2.0: Add existing account team members as group member:
            List<CMAP_Account_Team_Roles__c> mcs = CMAP_Account_Team_Roles__c.getall().values();
            for(CMAP_Account_Team_Roles__c  roleSettingLst :mcs){
                system.debug('----roleSettingLst ---'+roleSettingLst );
                If(roleSettingLst.OEM_Role__c == true) {
                     MapOfOEMRole.put(roleSettingLst.Name, roleSettingLst.Name);
                }
                if(roleSettingLst.partner_Role__c == true){
                    MapOfpartnerRole.put(roleSettingLst.Name, roleSettingLst.Name);
                }
            }
            //Select account details
            
            Map<Id, Account> accMap = new Map <Id, Account>();
            for(Account a :[select Id, Type, RecordTypeId, Sales_Channel__r.Name From Account where Id In :accountIdSet]){
                accMap.put(a.Id, a);            
            }
            // select account team members.
            // check the role and type of account and sales channel name. add to group member insert list.
            system.debug('Line no 133******accMap'+accMap);
            for(AccountTeamMember at :[select Id,UserId, TeamMemberRole, AccountId
                                       From AccountTeamMember 
                                       where AccountId In :accountIdSet]){
              system.debug('Inside For*******accMap.get(at.AccountId)'+accMap.get(at.AccountId));
                if( accMap.get(at.AccountId) != NULL ){
                    
                   if((((accMap.get(at.AccountId).Type == 'Partner' || 
                       accMap.get(at.AccountId).Type == 'OEM') &&
                       accMap.get(at.AccountId).RecordTypeId == PartnerAccountRTId 
                         ) &&
                       mapOfpartnerRole.get(at.TeamMemberRole) != null )  ||
                       (((accMap.get(at.AccountId).Type == 'End User' || 
                       accMap.get(at.AccountId).Type == 'OEM') &&
                       accMap.get(at.AccountId).RecordTypeId == EndUserRTId 
                         )&& 
                       accMap.get(at.AccountId).Sales_channel__c != Null &&
                        accMap.get(at.AccountId).Sales_channel__r.Name.contains('OEM')&&
                        mapOfOEMRole.get(at.TeamMemberRole) != null) 
                    
                     ){
                            Id groupId = groupInsertMap.get('CMAP:AT:'+at.AccountId).Id;
                            GroupMember groupMemberItem = new GroupMember(GroupId = groupId, UserOrGroupId= at.UserId);
                            groupMemberListToInsert.add(groupMemberItem);       
                        }
                    }
                
            }
            
            
            //ver 2.0: End
            database.SaveResult[] insertGMResults;
            database.Deleteresult[] deleteGMResults;
            if(groupMemberListToInsert.size() > 0){
                insertGMResults = database.insert(groupMemberListToInsert, false);
            }
            if(groupMemberListToDelete.size() > 0){
                deleteGMResults = database.delete(groupMemberListToDelete, false);
            }
         
        }catch (Exception e){
            system.debug('----Exception Occured--'+e);
        }   
    }// end of execute method
    global void finish(Database.BatchableContext BC){
           if(!Test.isRunningTest()) {
            CMAP_LeadShareScheduler schJob = new CMAP_LeadShareScheduler();   
            datetime TodayDate = datetime.now();
            string schTime = AccountOwnerTransitionUtils.BatchJobScheduleTime(TodayDate);
            system.schedule('CMAP_LeadShareBatch' +String.valueOf(TodayDate), schTime, schJob);
        }
  }
    
}