/*
Description: Utility module for Default follow up of user/group
- method followUser: Set the list of users to follow another User/Group
Version: 1.0

Author: Raghavendra Prasad

History:
1.0 - 08-Oct - Creation
2.0 - 10-Dec-2015 CR12402   This logic is separated from userAfterInsertUpdateTrigger trigger and rewritten as part of trigger redesign.
*/

/* 
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
3.0         CR13426     FY17-DCS-1002   23-Aug-2016     Fenny           To fix product issue which newly created user wasn't auto follow Michael Dell and group
*/
public class EntitySubscriptionUtils{

    //2.0
    public static void followUserAndGroup(List<string> subscribersList) {
        
        if(!Test.isRunningTest() || (Test.isRunningTest() && GlobalVariables.TEST_USER_SUBSCRIPTION)){
            // 3.0: Remove original code, then re-code
            followUser(subscribersList);
            followGroup(subscribersList);
        }
    }

    @future
    public static void followUser(List<string> subscribersList){ // 3.0: removed a parameter

       List<EntitySubscription> followersList = new List<EntitySubscription>();

       /* 3.0: Commented
       string userToFollowId = '';
        //to select michael_dell
       List<User> userToFlw = [select Id,Name from User where Badge_Number__c = '1' AND isActive = true AND email =: userToFollow];

       if(userToFlw != null && userToFlw.size() > 0)
        userToFollowId = userToFlw[0].Id;

       if(subscribersList   != null && subscribersList.size() > 0 && userToFollowId != ''){*/

        // 3.0: START
        Set<string> listParentId = null;
        for(string strParentId : System.Label.Chatter_User_To_Be_Followed.split(',')){
            if(listParentId == null) { listParentId = new Set<string>(); }
            listParentId.add(strParentId.trim());
        }
        if((subscribersList != null && subscribersList.size() > 0) && ((listParentId != null) && (listParentId.size() > 0))){
            
            for(User parent : [SELECT Id FROM User WHERE Id IN :listParentId]){
                for(string subscribers : subscribersList){
                       
                    system.debug('############### New Chatter User ID :  ' + subscribers + ' | Person to Follow : ' +  parent.Id );
    
                    followersList.add(new EntitySubscription ( parentId = parent.Id, subscriberid = subscribers));
                }
            }
        }
        // 3.0: END

        try{
            if(followersList.size() > 0) { insert followersList; }
        }
        catch  (Exception e)
        {
            system.debug('##KP: Caught APEX exception'+e.getMessage());
            throw new dellUtil.DellException(' Caught APEX exception:'+e.getMessage());
            //dellUtil.sendSupportEmail(e.getMessage(), 'sfdc_integration@dell.com');
        }
    }

    @future
    public static void followGroup(List<string> subscribersList){ // 3.0: removed a parameter
    
        /* 3.0: Commented

        string groupToFollowId = '';

        List<CollaborationGroupMember> followersList = new List<CollaborationGroupMember>();

        List<CollaborationGroup> grp = [select Id,Name from CollaborationGroup where Name like: groupToFollow];

       if(grp != null && grp.size() > 0)
        groupToFollowId = grp[0].Id;

      // system.debug(grp);

       if(subscribersList   != null && subscribersList.size() > 0 && groupToFollowId != '' ){*/
       
        // 3.0: START
        List<CollaborationGroupMember> followersList = new List<CollaborationGroupMember>();
        Set<string> listGroupId = null;
        for(string strGroupId : System.Label.Chatter_Group_To_Be_Followed.split(',')){
            if(listGroupId == null) { listGroupId = new Set<string>(); }
            listGroupId.add(strGroupId.trim());
        }
        if((subscribersList != null && subscribersList.size() > 0) && ((listGroupId != null) && (listGroupId.size() > 0))){
            
            for(CollaborationGroup grp : [SELECT Id FROM CollaborationGroup WHERE Id IN :listGroupId]){
    
                for(string subscribers : subscribersList){
                    
                    system.debug('############### New Chatter User ID :  ' + subscribers + '  |  Group to Follow : ' +  grp.Id );
                    
                    followersList.add(new CollaborationGroupMember ( CollaborationGroupId = grp.Id, MemberId = subscribers ));
                }
            }
        }
        // 3.0: END

        try{
            if(followersList.size() > 0) { insert followersList; }
        }
        catch  (Exception e)
        {
            system.debug('##KP: Caught APEX exception'+e.getMessage());
            throw new dellUtil.DellException(' Caught APEX exception:'+e.getMessage());
            //dellUtil.sendSupportEmail(e.getMessage(), 'sfdc_integration@dell.com');
        }
    }
}