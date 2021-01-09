public class  AllianceRebateRequestFieldPopulater{
    
    public static void insertingopportunityteamrolesintorebaterequestteam (list<Alliance_Rebate_Request__c> listOfNewRecords){
        Map<id,Alliance_Rebate_Request__c> oppIdsMap = new Map<id,Alliance_Rebate_Request__c>();
        list<Alliance_Rebate_Request_Team__c> teamMemsToInsert = new list<Alliance_Rebate_Request_Team__c>();
        for(Alliance_Rebate_Request__c RebateObj : listOfNewRecords){
            if(RebateObj.Sales_Force_Deal_ID__c != null){
                oppIdsMap.put(RebateObj.Sales_Force_Deal_ID__c,RebateObj);
            }
        }
        If (oppIdsMap.size()>0){
            
            for(OpportunityTeamMember oppTeamObj : [select id, userID, OpportunityID,TeamMemberRole from OpportunityTeamMember where OpportunityID IN : oppIdsMap.keyset()]){
                if(oppTeamObj.userID<>null && oppIdsMap.get(oppTeamObj.OpportunityID).id <> null){
                    Alliance_Rebate_Request_Team__c obj = new Alliance_Rebate_Request_Team__c();
                    obj.User__c= oppTeamObj.userID;
                    obj.Role__c= oppTeamObj.TeamMemberRole;
                    obj.Alliance_Rebate_Request_Id__c= oppIdsMap.get(oppTeamObj.OpportunityID).id;
                    teamMemsToInsert.add(obj);
                }
            }
            if(teamMemsToInsert.size()>0){
                database.insert(teamMemsToInsert);
            }
        }
    }
    
    public static void updatingingopportunityteamrolesintorebaterequestteam(list<Alliance_Rebate_Request__c> listOfRecords,map<id,Alliance_Rebate_Request__c>oldAllianceRebate){
        
        List<Alliance_Rebate_Request_Team__c> rebateRequestTeamTobeDeleted = new List<Alliance_Rebate_Request_Team__c>();
        List<Alliance_Rebate_Request_Team__c> rebateRequestTeamTobeInserted = new List<Alliance_Rebate_Request_Team__c>();
        List<Id> OppIDs = new List<Id>();
        List<Id> RebateIDs = new List<Id>();
        Map<id, List<OpportunityTeamMember>> OppTeam = new Map<id, List<OpportunityTeamMember>>();
        
        for(Alliance_Rebate_Request__c Reqobj: listOfRecords){
            Alliance_Rebate_Request__c ARR=(Alliance_Rebate_Request__c )oldAllianceRebate.get(Reqobj.id);
            
            if(Reqobj.Sales_Force_Deal_ID__c!=ARR.Sales_Force_Deal_ID__c || test.isrunningtest()){
                RebateIDs.add(Reqobj.id);
                OppIDs.add(Reqobj.Sales_Force_Deal_ID__c);
            }
        }
        
        if(!RebateIDs.isEmpty()){
            rebateRequestTeamTobeDeleted =[select id from Alliance_Rebate_Request_Team__c where Alliance_Rebate_Request_Id__c in:RebateIDs];
            if(!rebateRequestTeamTobeDeleted.isEmpty()){
                delete rebateRequestTeamTobeDeleted;
            }
        }
        if(!OppIDs.isEmpty()){
            for(Opportunity opp:[select id, (select id, userID, OpportunityID,TeamMemberRole from OpportunityTeamMembers) from Opportunity where ID IN: OppIDs]){
                
                Oppteam.put(opp.id,opp.OpportunityTeamMembers);
            }
            for(Alliance_Rebate_Request__c Reqobj: Listofrecords){
                if(Oppteam.containskey(Reqobj.Sales_Force_Deal_ID__c)){
                    //List<OpportunityTeamMember> newteam = OppTeam.get(Reqobj.Sales_Force_Deal_ID__c);
                    for(OpportunityTeamMember Opptm: OppTeam.get(Reqobj.Sales_Force_Deal_ID__c)) {
                        Alliance_Rebate_Request_Team__c newRequestteam = new Alliance_Rebate_Request_Team__c();
                        newRequestteam.User__c= Opptm.userID;
                        newRequestteam.Role__c= Opptm.TeamMemberRole;
                        newRequestteam.Alliance_Rebate_Request_Id__c= Reqobj.id;
                        rebateRequestTeamTobeInserted.add(newRequestteam);
                    }
                }
            }
        }
        if(!rebateRequestTeamTobeInserted.isEmpty()){
            insert rebateRequestTeamTobeInserted;
        }
    }
    
    // Assign Submitted Request to Global leads for Approval
     public static void assignSubmittedToGlobalLeads(map<id, Alliance_Rebate_Request__c> newAllianceRebateMap, map<id, Alliance_Rebate_Request__c> oldAllianceRebateMap) {

            set<Id> globalReqIds = new set<Id>();
            
            Map<String,Id> mapOfQueueNameToId = new Map<String,Id>();
            
            If( newAllianceRebateMap != NULL ){
                for( Alliance_Rebate_Request__c rebReqObj: newAllianceRebateMap.values() ) {
                    If(oldAllianceRebateMap.get(rebReqObj.Id).Status__c == 'Draft' && rebReqObj.Status__c == 'Submitted'){
                        globalReqIds.add(rebReqObj.Id);
                    }
                }
            }
            System.debug('***Global Set: '+ globalReqIds);
            If( !globalReqIds.isEmpty() ) {
                for(Group gp : [select Id,Name from Group where Type = 'Queue']){
                    mapOfQueueNameToId.put(gp.Name,gp.Id);
                }
                System.debug('***mapOfQueueNameToId: '+ mapOfQueueNameToId);
                boolean isUpdated = false;
                List<ProcessInstanceWorkItem> workItemList = [SELECT ActorId, Id, OriginalActorId, ProcessInstanceId, ProcessInstance.TargetObjectId 
                FROM ProcessInstanceWorkitem 
                WHERE ProcessInstance.TargetObjectId IN: globalReqIds ];
                
                for( ProcessInstanceWorkItem workItem: workItemList ){
                    System.debug('***mapOfQueueNameToId.get ');
                    workItem.ActorId = mapOfQueueNameToId.get('Alliance Global Leads');
                    isUpdated = true;
                }
                System.debug('***isUpdated: '+ isUpdated);
                If( isUpdated == true ){
                    update workItemList;
                }
            }
        } 
    
    public static void reAssignApproversBasedOnRegion(map<id, Alliance_Rebate_Request__c> newAllianceRebateMap, map<id, Alliance_Rebate_Request__c> oldAllianceRebateMap) {
        
        set<Id> regionNAReqIds = new set<Id>();
        set<Id> regionEMEAReqIds = new set<Id>();
        set<Id> regionLATAMReqIds = new set<Id>();
        set<Id> regionAPJReqIds = new set<Id>();
        set<Id> globalReqIds = new set<Id>();
        
        Map<String,Id> mapOfQueueNameToId = new Map<String,Id>();
        for(Group gp : [select Id,Name from Group where Type = 'Queue']){
            mapOfQueueNameToId.put(gp.Name,gp.Id);
        }
        
        If( newAllianceRebateMap != NULL ){
            for( Alliance_Rebate_Request__c rebReqObj: newAllianceRebateMap.values() ) {
                If(rebReqObj.Region__c != oldAllianceRebateMap.get(rebReqObj.Id).Region__c){
                    If( rebReqObj.Region__c != 'GLOBAL' && oldAllianceRebateMap.get(rebReqObj.Id).Region__c != 'GLOBAL' ){
                        If( rebReqObj.Region__c == 'NA' ){
                            regionNAReqIds.add(rebReqObj.Id);
                        }else If( rebReqObj.Region__c == 'EMEA' ){
                            regionEMEAReqIds.add(rebReqObj.Id);
                        }else If( rebReqObj.Region__c == 'LATAM' ){
                            regionLATAMReqIds.add(rebReqObj.Id);
                        }else If( rebReqObj.Region__c == 'APJ' ){
                            regionAPJReqIds.add(rebReqObj.Id);
                        }
                    }else If( rebReqObj.Region__c == 'GLOBAL' && oldAllianceRebateMap.get(rebReqObj.Id).Region__c != 'GLOBAL' ) {
                        globalReqIds.add(rebReqObj.Id);
                    }
                }
            }
            
            // Reassign to NA Region Leads - Queue:Alliance NA Lead
            If(!regionNAReqIds.isEmpty()) {
                boolean isUpdated = false;
                List<ProcessInstanceWorkItem> workItemList = [SELECT ActorId, Id, OriginalActorId, ProcessInstanceId, ProcessInstance.TargetObjectId 
                                                              FROM ProcessInstanceWorkitem 
                                                              WHERE ProcessInstance.TargetObjectId IN: regionNAReqIds ];
                
                for( ProcessInstanceWorkItem workItem: workItemList ){
                    If(newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).Region__c == 'NA' && 
                       newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).Client_Enterprise__c == 'Enterprise' && 
                       newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).System_Partner_Name__c != 'Intel' ){
                           
                           workItem.ActorId = mapOfQueueNameToId.get('Alliance NA Lead');
                           isUpdated = true;
                       }
                }
                If( isUpdated == true ){
                    update workItemList;
                    system.debug('********4'+workItemList);
                }
            }
            
            // Reassign to NA Region Leads - Queue:Alliance NA Intel Enterprise
            If(!regionNAReqIds.isEmpty()) {
                boolean isUpdated = false;
                List<ProcessInstanceWorkItem> workItemList = [SELECT ActorId, Id, OriginalActorId, ProcessInstanceId, ProcessInstance.TargetObjectId 
                                                              FROM ProcessInstanceWorkitem 
                                                              WHERE ProcessInstance.TargetObjectId IN: regionNAReqIds ];
                
                for( ProcessInstanceWorkItem workItem: workItemList ){
                    If(newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).Region__c == 'NA' && 
                       newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).Client_Enterprise__c == 'Enterprise' && 
                       newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).System_Partner_Name__c == 'Intel' ){
                           
                           workItem.ActorId = mapOfQueueNameToId.get('Alliance NA Intel Enterprise');
                           isUpdated = true;
                       }
                }
                If( isUpdated == true ){
                    update workItemList;
                }
            }
            
            // Reassign to NA Region Leads - Queue:Alliance NA All But Intel Client
            If(!regionNAReqIds.isEmpty()) {
                boolean isUpdated = false;
                List<ProcessInstanceWorkItem> workItemList = [SELECT ActorId, Id, OriginalActorId, ProcessInstanceId, ProcessInstance.TargetObjectId 
                                                              FROM ProcessInstanceWorkitem 
                                                              WHERE ProcessInstance.TargetObjectId IN: regionNAReqIds ];
                
                for( ProcessInstanceWorkItem workItem: workItemList ){
                    If(newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).Region__c == 'NA' && 
                       newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).Client_Enterprise__c == 'Client' && 
                       newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).System_Partner_Name__c != 'Intel' ){
                           
                           workItem.ActorId = mapOfQueueNameToId.get('Alliance NA All But Intel Client');
                           isUpdated = true;
                       }
                }
                If( isUpdated == true ){
                    update workItemList;
                }
            }
            
            // Reassign to NA Region Leads - Queue:Alliance NA Intel Client
            If(!regionNAReqIds.isEmpty()) {
                boolean isUpdated = false;
                List<ProcessInstanceWorkItem> workItemList = [SELECT ActorId, Id, OriginalActorId, ProcessInstanceId, ProcessInstance.TargetObjectId 
                                                              FROM ProcessInstanceWorkitem 
                                                              WHERE ProcessInstance.TargetObjectId IN: regionNAReqIds ];
                
                for( ProcessInstanceWorkItem workItem: workItemList ){
                    If(newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).Region__c == 'NA' && 
                       newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).Client_Enterprise__c == 'Client' && 
                       newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).System_Partner_Name__c == 'Intel' ){
                           
                           workItem.ActorId = mapOfQueueNameToId.get('Alliance NA Intel Client');
                           isUpdated = true;
                       }
                }
                If( isUpdated == true ){
                    update workItemList;
                }
            }
            
            // Reassign to APJ Region Leads - Queue:Alliance APJ All But Intel Enterprise
            If(!regionAPJReqIds.isEmpty()) {
                boolean isUpdated = false;
                List<ProcessInstanceWorkItem> workItemList = [SELECT ActorId, Id, OriginalActorId, ProcessInstanceId, ProcessInstance.TargetObjectId 
                                                              FROM ProcessInstanceWorkitem 
                                                              WHERE ProcessInstance.TargetObjectId IN: regionAPJReqIds ];
                
                for( ProcessInstanceWorkItem workItem: workItemList ){
                    If(newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).Region__c == 'APJ' && 
                       newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).Client_Enterprise__c == 'Enterprise' && 
                       newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).System_Partner_Name__c != 'Intel'
                       && newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).System_Partner_Name__c != 'AMD' ){
                           
                           workItem.ActorId = mapOfQueueNameToId.get('Alliance APJ All But Intel Enterprise');
                           isUpdated = true;
                       }
                }
                If( isUpdated == true ){
                    update workItemList;
                }
            }
            
            // Reassign to APJ Region Leads - Queue:Alliance APJ Intel Client
            If(!regionAPJReqIds.isEmpty()) {
                boolean isUpdated = false;
                List<ProcessInstanceWorkItem> workItemList = [SELECT ActorId, Id, OriginalActorId, ProcessInstanceId, ProcessInstance.TargetObjectId 
                                                              FROM ProcessInstanceWorkitem 
                                                              WHERE ProcessInstance.TargetObjectId IN: regionAPJReqIds ];
                If(!workItemList.isEmpty()) {
                    for( ProcessInstanceWorkItem workItem: workItemList ){
                        If(newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).Region__c == 'APJ' && 
                           newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).Client_Enterprise__c == 'Client' && 
                           (newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).System_Partner_Name__c == 'Intel' 
                           || newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).System_Partner_Name__c == 'AMD') ){
                               
                               workItem.ActorId = mapOfQueueNameToId.get('Alliance APJ Intel Client');
                               isUpdated = true;
                           }
                    }
                    If( isUpdated == true ){
                        update workItemList;
                    }
                }   
            }
            
            // Reassign to APJ Region Leads - Queue:Alliance APJ Intel Enterprise
            If(!regionAPJReqIds.isEmpty()) {
                boolean isUpdated = false;
                List<ProcessInstanceWorkItem> workItemList = [SELECT ActorId, Id, OriginalActorId, ProcessInstanceId, ProcessInstance.TargetObjectId 
                                                              FROM ProcessInstanceWorkitem 
                                                              WHERE ProcessInstance.TargetObjectId IN: regionAPJReqIds ];
                
                for( ProcessInstanceWorkItem workItem: workItemList ){
                    If(newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).Region__c == 'APJ' && 
                       newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).Client_Enterprise__c == 'Enterprise' && 
                       (newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).System_Partner_Name__c == 'Intel' 
                       || newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).System_Partner_Name__c == 'AMD') ){
                           
                           workItem.ActorId = mapOfQueueNameToId.get('Alliance APJ Intel Enterprise');
                           isUpdated = true;
                       }
                }
                If( isUpdated == true ){
                    update workItemList;
                }
            }
            
            // Reassign to APJ Region Leads - Queue:Alliance APJ All But Intel Client
            If(!regionAPJReqIds.isEmpty()) {
                boolean isUpdated = false;
                List<ProcessInstanceWorkItem> workItemList = [SELECT ActorId, Id, OriginalActorId, ProcessInstanceId, ProcessInstance.TargetObjectId 
                                                              FROM ProcessInstanceWorkitem 
                                                              WHERE ProcessInstance.TargetObjectId IN: regionAPJReqIds ];
                
                for( ProcessInstanceWorkItem workItem: workItemList ){
                    If(newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).Region__c == 'APJ' && 
                       newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).Client_Enterprise__c == 'Client' && 
                       newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).System_Partner_Name__c != 'Intel'
                       && newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).System_Partner_Name__c != 'AMD' ){
                           
                           workItem.ActorId = mapOfQueueNameToId.get('Alliance APJ All But Intel Client');
                           isUpdated = true;
                       }
                }
                If( isUpdated == true ){
                    update workItemList;
                }
            }
            
            // Reassign to EMEA Region Leads - Queue:Alliance EMEA ALL But Intel Enterprise
            If(!regionEMEAReqIds.isEmpty()) {
                boolean isUpdated = false;
                List<ProcessInstanceWorkItem> workItemList = [SELECT ActorId, Id, OriginalActorId, ProcessInstanceId, ProcessInstance.TargetObjectId 
                                                              FROM ProcessInstanceWorkitem 
                                                              WHERE ProcessInstance.TargetObjectId IN: regionEMEAReqIds ];
                
                for( ProcessInstanceWorkItem workItem: workItemList ){
                    If(newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).Region__c == 'EMEA' && 
                       newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).Client_Enterprise__c == 'Enterprise' && 
                       newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).System_Partner_Name__c != 'Intel' ){
                           
                           workItem.ActorId = mapOfQueueNameToId.get('Alliance EMEA ALL But Intel Enterprise');
                           isUpdated = true;
                       }
                }
                If( isUpdated == true ){
                    update workItemList;
                }
            }
            
            // Reassign to EMEA Region Leads - Queue:Alliance EMEA Intel Enterprise
            If(!regionEMEAReqIds.isEmpty()) {
                boolean isUpdated = false;
                List<ProcessInstanceWorkItem> workItemList = [SELECT ActorId, Id, OriginalActorId, ProcessInstanceId, ProcessInstance.TargetObjectId 
                                                              FROM ProcessInstanceWorkitem 
                                                              WHERE ProcessInstance.TargetObjectId IN: regionEMEAReqIds ];
                
                for( ProcessInstanceWorkItem workItem: workItemList ){
                    If(newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).Region__c == 'EMEA' && 
                       newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).Client_Enterprise__c == 'Enterprise' && 
                       newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).System_Partner_Name__c == 'Intel' ){
                           
                           workItem.ActorId = mapOfQueueNameToId.get('Alliance EMEA Intel Enterprise');
                           isUpdated = true;
                       }
                }
                If( isUpdated == true ){
                    update workItemList;
                }
            }
            
            // Reassign to EMEA Region Leads - Queue:Alliance EMEA ALL Client
            If(!regionEMEAReqIds.isEmpty()) {
                boolean isUpdated = false;
                List<ProcessInstanceWorkItem> workItemList = [SELECT ActorId, Id, OriginalActorId, ProcessInstanceId, ProcessInstance.TargetObjectId 
                                                              FROM ProcessInstanceWorkitem 
                                                              WHERE ProcessInstance.TargetObjectId IN: regionEMEAReqIds ];
                
                for( ProcessInstanceWorkItem workItem: workItemList ){
                    If(newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).Region__c == 'EMEA' && 
                       newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).Client_Enterprise__c == 'Client' ){
                           
                           workItem.ActorId = mapOfQueueNameToId.get('Alliance EMEA ALL Client');
                           isUpdated = true;
                       }
                }
                If( isUpdated == true ){
                    update workItemList;
                }
            }
            
            // Reassign to LATAM Region Leads - Queue:Alliance LATAM Intel Enterprise
            If(!regionLATAMReqIds.isEmpty()) {
                boolean isUpdated = false;
                List<ProcessInstanceWorkItem> workItemList = [SELECT ActorId, Id, OriginalActorId, ProcessInstanceId, ProcessInstance.TargetObjectId 
                                                              FROM ProcessInstanceWorkitem 
                                                              WHERE ProcessInstance.TargetObjectId IN: regionLATAMReqIds ];
                
                for( ProcessInstanceWorkItem workItem: workItemList ){
                    If(newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).Region__c == 'LATAM' && 
                       newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).Client_Enterprise__c == 'Enterprise' && 
                       newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).System_Partner_Name__c == 'Intel'){
                           
                           workItem.ActorId = mapOfQueueNameToId.get('Alliance LATAM Intel Enterprise');
                           isUpdated = true;
                       }
                }
                If( isUpdated == true ){
                    update workItemList;
                }
            }
            
            // Reassign to LATAM Region Leads - Queue:Alliance LATAM Intel Client
            If(!regionLATAMReqIds.isEmpty()) {
                boolean isUpdated = false;
                List<ProcessInstanceWorkItem> workItemList = [SELECT ActorId, Id, OriginalActorId, ProcessInstanceId, ProcessInstance.TargetObjectId 
                                                              FROM ProcessInstanceWorkitem 
                                                              WHERE ProcessInstance.TargetObjectId IN: regionLATAMReqIds ];
                
                for( ProcessInstanceWorkItem workItem: workItemList ){
                    If(newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).Region__c == 'LATAM' && 
                       newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).Client_Enterprise__c == 'Client' ){
                           
                           workItem.ActorId = mapOfQueueNameToId.get('Alliance LATAM Intel Client');
                           isUpdated = true;
                       }
                }
                If( isUpdated == true ){
                    update workItemList;
                }
            }
            
            // Reassign to LATAM Region Leads - Queue:Alliance LATAM All But Intel Enterprise
            If(!regionLATAMReqIds.isEmpty()) {
                boolean isUpdated = false;
                List<ProcessInstanceWorkItem> workItemList = [SELECT ActorId, Id, OriginalActorId, ProcessInstanceId, ProcessInstance.TargetObjectId 
                                                              FROM ProcessInstanceWorkitem 
                                                              WHERE ProcessInstance.TargetObjectId IN: regionLATAMReqIds ];
                
                for( ProcessInstanceWorkItem workItem: workItemList ){
                    If(newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).Region__c == 'LATAM' && 
                       newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).Client_Enterprise__c == 'Enterprise'  && 
                       newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).System_Partner_Name__c != 'Intel'){
                           
                           workItem.ActorId = mapOfQueueNameToId.get('Alliance LATAM All But Intel Enterprise');
                           isUpdated = true;
                       }
                }
                If( isUpdated == true ){
                    update workItemList;
                }
            }
            
            // Reassign to LATAM Region Leads - Queue:Alliance LATAM All But Intel Client
            If(!regionLATAMReqIds.isEmpty()) {
                boolean isUpdated = false;
                List<ProcessInstanceWorkItem> workItemList = [SELECT ActorId, Id, OriginalActorId, ProcessInstanceId, ProcessInstance.TargetObjectId 
                                                              FROM ProcessInstanceWorkitem 
                                                              WHERE ProcessInstance.TargetObjectId IN: regionLATAMReqIds ];
                
                for( ProcessInstanceWorkItem workItem: workItemList ){
                    If(newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).Region__c == 'LATAM' && 
                       newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).Client_Enterprise__c == 'Client'  && 
                       newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).System_Partner_Name__c != 'Intel'){
                           
                           workItem.ActorId = mapOfQueueNameToId.get('Alliance LATAM All But Intel Client');
                           isUpdated = true;
                       }
                }
                If( isUpdated == true ){
                    update workItemList;
                }
            }
            
            // Reassign to Global Leads
            If(!globalReqIds.isEmpty()) {
                boolean isUpdated = false;
                List<ProcessInstanceWorkItem> workItemList = [SELECT ActorId, Id, OriginalActorId, ProcessInstanceId, ProcessInstance.TargetObjectId 
                                                              FROM ProcessInstanceWorkitem 
                                                              WHERE ProcessInstance.TargetObjectId IN: globalReqIds ];
                
                for( ProcessInstanceWorkItem workItem: workItemList ){
                    If(newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).Region__c == 'GLOBAL' ){
                        
                        workItem.ActorId = mapOfQueueNameToId.get('Alliance Global Leads');
                        isUpdated = true;
                    }
                }
                If( isUpdated == true ){
                    update workItemList;
                }
            }
        }
    }
    
    /* public static void reAssignToRegionLeads(set<Id> regionRequestIds, String region, string clientEnterprise, string systemPartnerName, string queueName ) {
List<ProcessInstanceWorkItem> workItemList = [SELECT ActorId, Id, OriginalActorId, ProcessInstanceId, ProcessInstance.TargetObjectId 
FROM ProcessInstanceWorkitem 
WHERE ProcessInstance.TargetObjectId IN: regionRequestIds ];

for( ProcessInstanceWorkItem workItem: workItemList ){
If(newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).Region__c == region && 
newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).Client_Enterprise__c == clientEnterprise && 
newAllianceRebateMap.get(workItem.ProcessInstance.TargetObjectId).System_Partner_Name__c != systemPartnerName ){
Set<Id> apjQueueUsers = queueMembersMap.get(queueName);

for( Id queueUser: apjQueueUsers ) {
workItem.ActorId = queueUser;
}
}
}
update workItemList;
}*/
    
    // Get Group Members from Queue
    /*public static map<String, Set<Id>> getUsersFromQueue() {

List<Group> groupQueues = [ SELECT DeveloperName, Id, Name, Type, (SELECT GroupId, Id, UserOrGroupId, Group.Name FROM GroupMembers) FROM Group WHERE Name LIKE 'Alliance%' ];

map<String, Set<Id>> groupMemberMap = new map<String, Set<Id>>();

for(Group groupObj: groupQueues){

Set<Id> userIds = new Set<Id>();
for(GroupMember groupMemb: groupObj.GroupMembers){
userIds.add(groupMemb.UserOrGroupId);
}
groupMemberMap.put(groupObj.Name,userIds);
}
System.debug('*****Group Member Map: '+ groupMemberMap);

return groupMemberMap;
} */
    
   // Sending EMail notifications to Opp team members when Rebate Request is Submitted
    public static void sendSubmittedNotificationsToOppTeamMembers(list<Alliance_Rebate_Request__c> listOfNewRecords, map<id,Alliance_Rebate_Request__c> oldAllianceRebateMap){
        try{
        String emailTemplateName = '' ;
        Set<Id> rebReqIds = new Set<Id>();
        Boolean sendEmailToCustom = false;
        for(Alliance_Rebate_Request__c rebateObj : listOfNewRecords) {
            If(oldAllianceRebateMap.get(rebateObj.Id).Status__c == 'Draft' && rebateObj.Status__c == 'Submitted'){
                emailTemplateName = 'Alliance Rebate Request Oppty Team';
                rebReqIds.add(rebateObj.Id);
                sendEmailToCustom = true;
            } 
            /*else If( oldAllianceRebateMap.get(rebateObj.Id).Status__c != rebateObj.Status__c && 
                    ( rebateObj.Status__c == 'Work in Progress' || rebateObj.Status__c == 'Awaiting Vendors Response') ){
                         emailTemplateName = 'Alliance Rebate Request Status to Oppty';
                         rebReqIds.add(rebateObj.Id);
                         
                     } else If(oldAllianceRebateMap.get(rebateObj.Id).Status__c !='Rejected'&& rebateObj.Status__c == 'Cancelled'){
                       emailTemplateName = 'Alliance Cancelled Notification to Team';
                         rebReqIds.add(rebateObj.Id);
                     
                     }else If(oldAllianceRebateMap.get(rebateObj.Id).Status__c !='Cancelled'&&rebateObj.Status__c == 'Rejected'){
                       emailTemplateName = 'Alliance Rejected Notification to Team';
                         rebReqIds.add(rebateObj.Id);
                     
                     }else If(oldAllianceRebateMap.get(rebateObj.Id).Status__c !='Approved'&&rebateObj.Status__c == 'Approved') {
                       emailTemplateName = 'Alliance Approved Notification to Team';
                         rebReqIds.add(rebateObj.Id);
                     
                     }else If(oldAllianceRebateMap.get(rebateObj.Id).Status__c !='Expired'&&rebateObj.Status__c == 'Expired'){
                       emailTemplateName = 'Alliance Expired Notification to Team';
                         rebReqIds.add(rebateObj.Id);
                     
                     }else{
                         emailTemplateName = '';
                     }*/
            
        }
        
        If(emailTemplateName !='' && emailTemplateName != null){
            EmailTemplate templateId = [Select id from EmailTemplate where name =: emailTemplateName ];  
            EmailTemplate templateId2 = [Select id from EmailTemplate where name = 'Alliance Rebate Request Submission to Partner Email' ];  
            
            
            If( !rebReqIds.isEmpty() ){
                list<Alliance_Rebate_Request__c> allianceRebateRequests = new list<Alliance_Rebate_Request__c>();
                set<Id> userIds = new set<Id>();
                
                allianceRebateRequests = [Select Id, Status__c,Recipient_Email__c, (Select Id, User__c from Alliance_Rebate_Request_Teams__r) from Alliance_Rebate_Request__c Where ID IN: rebReqIds];
                list<Messaging.SingleEmailMessage> mails = new list<Messaging.SingleEmailMessage>();
                list<Messaging.SingleEmailMessage> mails2 = new list<Messaging.SingleEmailMessage>();
                
                
                
                    
                Contact cnt = [select id, Email from Contact  limit 1];
                for( Alliance_Rebate_Request__c rebReq: allianceRebateRequests ){
                   /* If( !rebReq.Alliance_Rebate_Request_Teams__r.isEmpty() ){
                        for( Alliance_Rebate_Request_Team__c rebReqTeam: rebReq.Alliance_Rebate_Request_Teams__r ){
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.setTemplateId(templateId.Id);
                            mail.setTargetObjectId(rebReqTeam.User__c); 
                            mail.setSaveAsActivity(false);
                            mail.setWhatId(rebReq.Id);
                            mails.add(mail);
                        }
                    }*/
                    if(sendEmailToCustom && rebReq.Recipient_Email__c != null){
                        //cnt.email = 'khan.wassim28@gmail.com';
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(rebReq.Recipient_Email__c.split(','));
                        mail.setTargetObjectId(cnt.id);
                        mail.setTreatTargetObjectAsRecipient(false);
                        mail.setTemplateId(templateId2.Id);
                        mail.setSaveAsActivity(false);
                        mail.setWhatId(rebReq.Id);
                        mails2.add(mail);
                        
                    }
                }
                
                /*If( !mails.isEmpty() ){
                    //Savepoint sp = Database.setSavepoint();
                   // Messaging.sendEmail(mails);
                    //Database.rollback(sp);
                }*/
                If( !mails2.isEmpty() ){
                    System.debug('===mails2==='+mails2);
                    Savepoint sp = Database.setSavepoint();
                    Messaging.sendEmail(mails2);
                   /* Database.rollback(sp);
                    List<Messaging.SingleEmailMessage> msgListToBeSend = new List<Messaging.SingleEmailMessage>();
                    for (Messaging.SingleEmailMessage email : mails2) {
                        Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                        emailToSend.setToAddresses(email.getToAddresses());
                        emailToSend.setPlainTextBody(email.getPlainTextBody());
                        emailToSend.setHTMLBody(email.getHTMLBody());
                        emailToSend.setSubject(email.getSubject());
                        msgListToBeSend .add(emailToSend);
                    }*/
                   // Messaging.sendEmail(msgListToBeSend);
                }
            }
          } 
        } Catch(Exception Ex){}
    }
    
}