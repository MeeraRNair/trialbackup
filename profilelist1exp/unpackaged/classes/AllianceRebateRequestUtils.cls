public class AllianceRebateRequestUtils {

    // Get Loggein User Info
    public static User getLoggedInUser() {
        User user = [Select Id, Country, Profile.Name from User where Id = :UserInfo.getUserId()];

        return user;
    }

    // Get Loggedin User Region
    public static string getLoggedInUserRegion() {
        
        User user = getLoggedInUser();
        
        If(user.Country != NULL) {
        list<Country__c> ctrLst = new list<Country__c>([Select Region__c, Code__c from Country__c where Code__c =: user.Country]);
            Country__c ctr ; 
            if(ctrLst.size() > 0){
                ctr = ctrLst [0];
            }
            
            If(ctr != null && ctr.Region__c != null){
                return ctr.Region__c;
            }else{
                return null;
            }
        }else{
            return null;
        }
    }

    // Get Loggedin User Profile info
    public static string getLoggedInUserProfile() {

        User user = getLoggedInUser();
        
        set<Id> globalLeadsSet = new set<id>();
        globalLeadsSet = getGlobalLeads();
        
        If(user.Profile.Name == 'Alliance Regional Program Lead' && globalLeadsSet.contains(user.Id) ) {
            return 'allianceGlobalPrgmLead';
        }else If(user.Profile.Name == 'Alliance Regional Program Lead') {
            return 'allianceRegionalPrgmLead';
        }else If(user.Profile.Name.contains('Sales') || user.Profile.Name.contains('GBL Dell Services') ) {
            return 'salesReps';
        }else If(user.Profile.Name.contains('admin')){
           return 'admin';
        }else {
             return 'None';
        }
    }
    
    // Get all Global Program Leads(Super users)
    public static set<Id> getGlobalLeads(){
        
        set<Id> globalUserIds = new set<Id>();      
        for(GroupMember grpMember: [SELECT GroupId, Id, UserOrGroupId, Group.Type, Group.Name FROM GroupMember Where Group.Type = 'Queue' AND Group.Name = 'Alliance Global Leads'] ){
            globalUserIds.add(grpMember.UserOrGroupId);
        }
        System.debug('***Global Users: '+ globalUserIds);
        
        return globalUserIds;
    }
}