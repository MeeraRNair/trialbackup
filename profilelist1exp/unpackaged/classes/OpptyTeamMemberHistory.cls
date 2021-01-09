public class  OpptyTeamMemberHistory {
    
    public static void insertOpptyTeamMemberHistory(List<OpportunityTeamMember> opptyTeamMembers, String addOrRemove) {
        
        Set<Id> userIds = new Set<Id>();
        Set<Id> opportunityIds = new Set<Id>();
        Set<Id> opportunityTeamIds = new Set<Id>();

        for(OpportunityTeamMember opptyTeamMember: opptyTeamMembers) {
            userIds.add(opptyTeamMember.UserId);
            userIds.add(opptyTeamMember.CreatedById);
            opportunityIds.add(opptyTeamMember.OpportunityId);
            opportunityTeamIds.add(opptyTeamMember.Id);
        }
        System.debug('*****User Ids: '+ userIds);
        
        // Get Opportunity Team Users
        Map<Id, User> userMap = new Map<Id, User>([Select Id, 
                                                          Profile.Name, 
                                                          UserRole.Name,
                                                          Name 
                                                          from User 
                                                          where Id IN: userIds]);
        
        /*List<Id> usrIdList = new List<Id>();
        for(Id usrId: userIds){
            usrIdList.add(usrId);
        }                                                  
        List<User> userList = new List<User>();
        userList = [Select Id, Name, Profile.Name, UserRole.Name from User where Id = '005K0000003WTSfIAO'];
        
        System.debug('****UserList: '+ userList);
        
        for(User u: userList){
            userMap.put(u.Id, u);
        }*/
        System.debug('*****User Map: '+ userMap);
        
        // Get Opportunity Team Member Opportunities
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>([Select Id, Account.Sales_Channel__r.Name,
                                                                               AccountId, 
                                                                               Account.Name, 
                                                                               Account.Owner.Name, 
                                                                               Name, 
                                                                               Owner.Name 
                                                                               from Opportunity 
                                                                               where Id IN: opportunityIds]);

        List<OTM_History__c> existOTMHistoryList = new List<OTM_History__c>();
        existOTMHistoryList = [Select Id, Action__c, OTM_SFDC_ID__c from OTM_History__c where OTM_SFDC_ID__c IN: opportunityTeamIds];

        Map<Id, OTM_History__c> otmHistoryMap = new Map<Id, OTM_History__c>();
        for(OTM_History__c otmHistory: existOTMHistoryList){
            otmHistoryMap.put(otmHistory.OTM_SFDC_ID__c, otmHistory);
        }

        List<OTM_History__c> otmHistoryList = new List<OTM_History__c>();
        OTM_History__c otmHistoryObj;

        If(addOrRemove == 'Add'){
            for(OpportunityTeamMember opptyTeamMember: opptyTeamMembers){
                otmHistoryObj = new OTM_History__c();
                system.debug('******&&&&& Opptyteam member User iD: '+opptyTeamMember.UserId);
                system.debug('******&&&&& Opptyteam member User map: '+userMap.get(opptyTeamMember.UserId));
                otmHistoryObj.Name = userMap.get(opptyTeamMember.UserId).Name;
                otmHistoryObj.OTM_Team_member_role__c = opptyTeamMember.TeamMemberRole;
                otmHistoryObj.Action__c = 'Added';
                otmHistoryObj.OTM_ACCNT_ID__c = opportunityMap.get(opptyTeamMember.OpportunityId).Account.Id;
                otmHistoryObj.OTM_Accnt_Name__c = opportunityMap.get(opptyTeamMember.OpportunityId).Account.Name;
                otmHistoryObj.OTM_Sales_Channel_Name__c = opportunityMap.get(opptyTeamMember.OpportunityId).Account.Sales_Channel__r.Name;
                otmHistoryObj.OTM_Accnt_Owner__c = opportunityMap.get(opptyTeamMember.OpportunityId).Account.Owner.Name;
                otmHistoryObj.OTM_OPPTY_ID__c = opportunityMap.get(opptyTeamMember.OpportunityId).Id;
                otmHistoryObj.OTM_Oppty_Name__c = opportunityMap.get(opptyTeamMember.OpportunityId).Name;
                otmHistoryObj.OTM_Oppty_Owner__c = opportunityMap.get(opptyTeamMember.OpportunityId).Owner.Name;
                otmHistoryObj.OTM_SFDC_ID__c = opptyTeamMember.Id;
                otmHistoryObj.OTM_User_Profile__c = userMap.get(opptyTeamMember.UserId).Profile.Name;
                otmHistoryObj.OTM_User_Role__c = userMap.get(opptyTeamMember.UserId).UserRole.Name;
                otmHistoryObj.OTM_Created_By__c = userMap.get(opptyTeamMember.CreatedById).Name;
                otmHistoryObj.OTM_Date__c = System.now();

                otmHistoryList.add(otmHistoryObj);
            }
        }else If(addOrRemove == 'Remove'){
            for(OpportunityTeamMember opptyTeamMember: opptyTeamMembers){

                 otmHistoryObj = otmHistoryMap.get(opptyTeamMember.Id);
                if(otmHistoryObj == null)
                otmHistoryObj = new OTM_History__c();
               
               

                otmHistoryObj.Action__c = 'Removed';
                otmHistoryObj.OTM_Removed_By__c = UserInfo.getName();

                otmHistoryList.add(otmHistoryObj);
            }
        }

        upsert otmHistoryList ;
    }
}