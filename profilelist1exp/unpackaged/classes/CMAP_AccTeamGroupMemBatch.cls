/*
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------------
1.0     08-Nov-2013     Jiji            CR 235 - Lead visibility to Account Team Members  
                                        Batch to create Group member for account Group
1.1     29-Jan-2014     Meera           Defect 93399
2.0     01-Jun-2018     Kishore         As part of code reduce, commented the "DBUtils.flushOutTheJobsQueue()"
                                        Since the whole method "flushOutTheJobsQueue" was already commented in another class
                                        and hence we are commenting here aswell.
                                        Commented the lines where they are getting recordtypes from another class and Used standard 
                                        functionality to get the Account recordtypes.
2.1     05-Jun-2018     Kishore         Defined "isTest" variable, to get code coverage for finish method    
********************************************************************************************/
global class CMAP_AccTeamGroupMemBatch implements Database.Batchable<sObject> {
    public String query;
    public Boolean isTest=False; //v2.1
    global database.querylocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
   global void execute(Database.BatchableContext BC, List<sObject> scope){
       try{ 
            Set<Id> accId = new Set<Id>();
            Set<String> groupNameSet = new Set<String>();
            List< Account_Team__c> lstOfActiveAccTeam = new List< Account_Team__c>();
            List< Account_Team__c> lstOfInActiveAccTeam = new List< Account_Team__c>();
            List< GroupMember> groupMemberListToInsert = new List<GroupMember>();
            List< GroupMember> groupMemberListToDelete = new List< GroupMember> ();
            Set<Id> userIdSet = new Set< Id>();
            Set<Id> grpIdSet = new Set< Id>();
            Map<String,Group> mapOfNametoGrp = new Map<String,Group>();
            Map<String, String> MapOfOEMRole = new Map<String, String>();
            Map<String, String> MapOfpartnerRole = new Map<String, String>();
            Map<String,GroupMember> mapOfInactiveGrpMem = new Map<String,GroupMember>();
            Id PartnerAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId(); //v2.0
            Id EndUserRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End-User Account').getRecordTypeId(); //v2.0
            for(sObject obj :scope){
                Account_Team__c batchRec = (Account_Team__c)obj;
                accId.add(batchRec.Account__c);   
                if(batchRec.Status__c == 'Active'){
                    lstOfActiveAccTeam.add(batchRec);  
                }else{
                    lstOfInActiveAccTeam.add(batchRec);
                    userIdSet.add(batchRec.User__c);
                }
                groupNameSet.add('CMAP:AT:' + batchRec.Account__c);          
            }
            //List<CMAP_Account_Team_Roles__c> mcs = CMAP_Account_Team_Roles__c.getall().values();
            for(CMAP_Account_Team_Roles__c  roleSettingLst :CMAP_Account_Team_Roles__c.getall().values()){
                If(roleSettingLst.OEM_Role__c == true) {
                     MapOfOEMRole.put(roleSettingLst.Name, roleSettingLst.Name);
                }
                if(roleSettingLst.partner_Role__c == true){
                    MapOfpartnerRole.put(roleSettingLst.Name, roleSettingLst.Name);
                }
            }
            for(Group grp : [select Id, Name from Group where Name in :groupNameSet]){
                mapOfNametoGrp.put(grp.Name, grp);
                grpIdSet.add(grp.Id);
            }
            Map<Id, Account> accMap = new Map <Id, Account>();
            for(Account a :[select Id, Type, RecordTypeId from Account where Id in :accId]){
                accMap.put(a.Id, a);            
            }
            for(Account_Team__c acc: lstOfActiveAccTeam){
                String grpName = 'CMAP:AT:'+acc.Account__c;
                if(mapOfNametoGrp.get(grpName)  != NULL 
                    ){
                   if((((acc.Account_Type__c == 'Partner' ||
                        acc.Account_Type__c == 'OEM')&&
                        accMap.get(acc.Account__c).RecordTypeId == PartnerAccountRTId
                        )&&
                   /* Modifed for Defect*/
                    mapOfpartnerRole.get(acc.Team_Member_Role__c) != null )  ||
                    (((acc.Account_Type__c == 'End User' || 
                    acc.Account_Type__c == 'OEM')&&
                    accMap.get(acc.Account__c).RecordTypeId == EndUserRTId)&& 
                    acc.Sales_Channel_Name__c != NULL &&
                    acc.Sales_Channel_Name__c.contains('OEM')&&
                     mapOfOEMRole.get(acc.Team_Member_Role__c) != null) 
                     ){
                      GroupMember groupMemberItem = new GroupMember(GroupId = mapOfNametoGrp.get(grpName).Id, UserOrGroupId = acc.User__c); //v2.0
                      groupMemberListToInsert.add(groupMemberItem);
                    }
                    else{//To capture role change of the Account team members
                        lstOfInActiveAccTeam.add(acc);
                        userIdSet.add(acc.User__c);
                    }
                }
            }
            database.SaveResult[] insertResults;
            if(groupMemberListToInsert.size() > 0){
                insertResults = database.insert(groupMemberListToInsert, false);
            }
            If(lstOfInActiveAccTeam.size() > 0){
                For(GroupMember grpMem : [select Id, GroupId, UserorGroupId from GroupMember where GroupId in:grpIdSet and UserorGroupId in: userIdSet] ){
                    mapOfInactiveGrpMem.put('cmap:'+ grpMem.GroupId + ':' + grpMem.UserorGroupId, grpMem);
                }
            }
            For(Account_Team__c aT:  lstOfInActiveAccTeam){
                If(mapOfInactiveGrpMem.get(('cmap:'+mapOfNametoGrp.get('CMAP:AT:' + aT.Account__c).Id+ ':' +aT.User__c)) != null){
                       groupMemberListToDelete.add(mapOfInactiveGrpMem.get(('cmap:'+mapOfNametoGrp.get('CMAP:AT:' + aT.Account__c).Id+ ':' +aT.User__c)));
                }
            }
            database.deleteResult[] deleteResults;
            if(groupMemberListToDelete.size() > 0){
                deleteResults = database.delete(groupMemberListToDelete, false);
            }
        }
        catch (Exception e){
        }  
    }// end of execute method
    global void finish(Database.BatchableContext BC){
        if(!Test.isRunningTest() || isTest){ //v2.1- Added "isTest" variable, to get code coverage for below peice of code 
            CMAP_AccountTeamCleanUpScheduler schJob = new  CMAP_AccountTeamCleanUpScheduler();   
            datetime TodayDate = datetime.now();
            string schTime = AccountOwnerTransitionUtils.BatchJobScheduleTime(TodayDate);
            system.schedule('CMAP_AccountTeamCleanUpScheduler'+String.valueOf(TodayDate),schTime, schJob);
        }            
            
    }
}