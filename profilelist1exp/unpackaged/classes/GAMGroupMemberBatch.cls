/* 
Author: Natesh Alagiri

History:
Version Date            Modified By     Description     
---------------------------------------------------------------------------------------------------------------------------------
1.0     08-Jul-2011     Natesh Alagiri  Created for CR6236 and CR6238
2.0     10-Apr-2012     Krishnamoorthi  Modified for R13.4 Maintenance CR 6573 -- To Give Product Catalog visibility to GAM users
3.0     31-May-2018     Fenny           CR15896 - Remove duplicate codes found in GAMGroupMemberBatch, GAMMemberQueueBatch, and GAMSharingBatch
*/
global class GAMGroupMemberBatch implements Database.Batchable<sObject> {
    public String query;
    global database.querylocator start(Database.BatchableContext BC){
        GAMbatchJobUtils.sendOptionalNotification('GAM : Started Group member manipulation job',
                                                  'Started Group member manipulation job now');
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<GroupMember> groupMemberListToInsert = new List<GroupMember>();
        List<GroupMember> groupMemberListToDelete = new List<GroupMember>();
        set<Id> groupIdSet = new set<Id>();
        set<Id> userIdSet = new set<Id>();
        set<String> uniqueKeySet = new set<String>();
        try{
            
        
            for(sObject obj :scope){
                Group_Member_Queue__c groupMemberQueueRecord = (Group_Member_Queue__c)obj;
                if(groupMemberQueueRecord.Operation__c == 'Insert'){
                    //V 2.0 Changes -- Start
                    //GroupMember groupMemberItem = new GroupMember(GroupId = groupMemberQueueRecord.Group_ID__c, UserOrGroupId= groupMemberQueueRecord.GAM_User__c);
                    GroupMember groupMemberItem = new GroupMember(GroupId = groupMemberQueueRecord.Group_ID__c, UserOrGroupId= groupMemberQueueRecord.Child_Group_Id__c==null?groupMemberQueueRecord.GAM_User__c : groupMemberQueueRecord.Child_Group_Id__c);
                   //V 2.0 Changes -- End
                    groupMemberListToInsert.add(groupMemberItem);
                }
                else{
                    if(groupMemberQueueRecord.Operation__c == 'Delete'){
                        groupIdSet.add(groupMemberQueueRecord.Group_ID__c);
                        userIdSet.add(groupMemberQueueRecord.GAM_User__c);
                        uniqueKeySet.add(groupMemberQueueRecord.Group_ID__c+ ':' + groupMemberQueueRecord.GAM_User__c);
                    }
                }
            }
            if(groupIdSet.size()>0){
                for(GroupMember groupMemberItem :[SELECT Id,GroupId,UserOrGroupId FROM GroupMember 
                                                  WHERE GroupId IN :groupIdSet
                                                  AND UserOrGroupId IN :userIdSet]){
                    String uniqueKey = groupMemberItem.GroupId + ':' + groupMemberItem.UserOrGroupId;
                    if(uniqueKeySet.contains(uniqueKey)){
                        groupMemberListToDelete.add(groupMemberItem);
                    }
                }               
            }   
            
            database.SaveResult[] insertResults;
            Database.DeleteResult[] deleteResults;
             
            if(groupMemberListToDelete.size() >0){
                deleteResults = database.delete(groupMemberListToDelete, false);
            }
            if(groupMemberListToInsert.size() > 0){
                insertResults = database.insert(groupMemberListToInsert, false);
            }
            
            //Optionally notifies the exceptions through email
            if(Test.isRunningTest() || (GAMbatchJobUtils.enabledNotification 
                &&  GAMbatchJobUtils.emailList !=null && GAMbatchJobUtils.emailList.size()>0            
                && (groupMemberListToDelete.size() >0 || groupMemberListToInsert.size() > 0 ))){
            
                String message='';
                
                if(groupMemberListToInsert.size() > 0){
                    message = GAMbatchJobUtils.prepareNotificationMessage(groupMemberListToInsert, insertResults, 'Insert');
                }
                if(groupMemberListToDelete.size() >0){
                    message += '\n---------------------\n' + GAMbatchJobUtils.prepareNotificationMessage(groupMemberListToDelete, deleteResults, 'Delete');
                }
                    
                GAMbatchJobUtils.sendOptionalNotification('GAM : Group Member recalculation process result',message);   
            }
        }catch (Exception e){
            GAMbatchJobUtils.sendOptionalNotification('GAM : Exception in GAM Group Member recalculation job','Exceptin : '+ e.getMessage() );
        }
    
        
    }// end of execute method
    
    global void finish(Database.BatchableContext BC){
        // 3.0: Previously there is block of code that query the AsyncApexJob record and print debug statement. Now they are removed. The AsyncApexJob ID is added to the end of the email being sent by below code
        
        GAMbatchJobUtils.sendOptionalNotification('GAM : Finished Group member manipulation job',
                                                  'Finished Group member manipulation job now. Completed the GAM recalculation process. [AsyncApexJob Id: ' + BC.getJobId() + ']'); // 3.0: Added AsyncApexJob Id
    }
}