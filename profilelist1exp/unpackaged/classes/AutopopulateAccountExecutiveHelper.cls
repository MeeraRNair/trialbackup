public class AutopopulateAccountExecutiveHelper{
    
    list<AccountTeamMember> accTeamList; 
    
    public map<Id, list<AccountTeamMember>> getLstAccTeamRoles(list<ID> accIDs, map<Id, list<AccountTeamMember>> accTeamRoleMap, map<Id, Account> accountMap){
        accTeamList = new list<AccountTeamMember>();
        accTeamList = [SELECT AccountId,TeamMemberRole,UserId,CreatedDate, User.Badge_Number__c FROM AccountTeamMember where AccountId IN: accIDs and (TeamMemberRole = 'Account Executive' OR TeamMemberRole = 'Partner Development Manager')];
               
        Schema.DescribeSObjectResult d = Schema.SObjectType.Account;
        Map<Id,Schema.RecordTypeInfo> ACCRTMAP = d.getRecordTypeInfosById();
       
               if( accTeamList.size() > 0 ){
            for(AccountTeamMember accTeam: accTeamList){
            
                Id temp = AccountMap.get(accteam.accountId).RecordtypeId;
                           
                list<AccountTeamMember> accTeamMembList ;
                if(accTeamRoleMap.get(accTeam.AccountId)  == null )
                    accTeamMembList = new list<AccountTeamMember>();
                 
                else if((ACCRTMAP.get(temp).getname() == 'End-User Account' && ACCTEAM.TeamMemberRole == 'Account Executive') || (ACCRTMAP.get(temp).getname()  == 'Partner Account' && ACCTEAM.TEAMMEMBERROLE == 'Partner Development Manager'))
                    accTeamMembList = accTeamRoleMap.get(accTeam.AccountId);
                 
                IF((ACCRTMAP.get(temp).getname() == 'End-User Account' && ACCTEAM.TeamMemberRole == 'Account Executive') || (ACCRTMAP.get(temp).getname()  == 'Partner Account' && ACCTEAM.TEAMMEMBERROLE == 'Partner Development Manager'))
                    accTeamMembList.add(accTeam);
                
                IF(accTeamMembList!= NULL)
                    accTeamRoleMap.put(accTeam.AccountId, accTeamMembList);
            } 
                    
        }
            return accTeamRoleMap;
        
    }
    
    public map<ID, User> getUserData(list<ID> accIDs, map<Id, list<AccountTeamMember>> accTeamRoleMap, map<ID, User> userInfoMap,map<Id, Account> accountMap){
        getLstAccTeamRoles(accIDs, accTeamRoleMap, accountmap);
        list<Id> userIds = new list<Id>();
        for(AccountTeamMember accTeam: accTeamList){
            userIds.add(accTeam.UserId);
        }
        userInfoMap = new map<ID, User>([SELECT Id,Name FROM User where ID IN: userIds]);
            return userInfoMap;
    }
    
    public Id getFirstCreatedUser(list<AccountTeamMember> accTeamList){
        DateTime accTeamCreatedDate = null;
        Id usrId = null;
        Integer userBadgeNumber = null;
        for(AccountTeamMember accTeam: accTeamList){
            if(accTeamCreatedDate == null){
                accTeamCreatedDate = accTeam.CreatedDate;
                usrId = accTeam.UserId;
                userBadgeNumber = Integer.valueOf(accTeam.User.Badge_Number__c);
            }
            if(accTeam.CreatedDate < accTeamCreatedDate){
                accTeamCreatedDate = accTeam.CreatedDate;
                usrId = accTeam.UserId;
                userBadgeNumber = Integer.valueOf(accTeam.User.Badge_Number__c);
            }else if(accTeam.CreatedDate == accTeamCreatedDate){
                if( Integer.valueOf(accTeam.User.Badge_Number__c) < userBadgeNumber ){
                    usrId = accTeam.UserId;
                    userBadgeNumber = Integer.valueOf(accTeam.User.Badge_Number__c);
                }else{
                    usrId = usrId ;
                }
            }
        }
        return usrId;
    }
}