public without sharing class PartnerSalesTeamVF {
    
    public list<AcountTeamWrapperCls> lstWrappercls {get; set;}
    
    // Constructor
    public PartnerSalesTeamVF() {
        try{
            Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=Edge');
            
            Id accId = [Select Id, Contact.Selected_Track_Account__c from User Where Id =: UserInfo.getUserId()].Contact.Selected_Track_Account__c;
            
            List<AccountTeamMember> accTeamMembers = new List<AccountTeamMember>();
            accTeamMembers = [Select
                              Id, UserId, AccountId, TeamMemberRole, User.Email 
                              From 
                              AccountTeamMember 
                              Where
                              AccountId =: accId ];
            
            Set<Id> userIdSet = new Set<Id>();
            for(AccountTeamMember accTeam: accTeamMembers){
                userIdSet.add(accTeam.UserId);
            }
            
            map<Id, User> userMap = new map<Id, User>([Select Id, Name, Email from User where Id IN: userIdSet]);
            
            lstWrappercls = new list<AcountTeamWrapperCls>();
            for(AccountTeamMember accTeam: accTeamMembers){
                AcountTeamWrapperCls accTeamWrap = new AcountTeamWrapperCls();
                accTeamWrap.accTeamName = userMap.get(accTeam.UserId).Name;
                accTeamWrap.accTeamEmail = userMap.get(accTeam.UserId).Email;
                accTeamWrap.accTeamRole = accTeam.TeamMemberRole;
                
                lstWrappercls.add(accTeamWrap);
            }
        }
        catch(QueryException qEx){
            system.debug('----QueryException---' + qEx.getMessage());
        }
        catch(Exception ex){
            system.debug('----Generic Exception---' + ex.getMessage());
        }  
    }
    
    //Wrapper class for  the AccountteamMembers   
    public class AcountTeamWrapperCls{
        public string accTeamName {get; set;}
        public string accTeamEmail {get; set;}
        public string accTeamRole {get; set;}
    }
}