/* 
Description: Apex controller Class which contains the methods which help in deleting Accountteam member created and modified by endusers using VF page : "AccountTeamMemberDeletion"
Version: 1.0

History:

1.0 - 03-Dec-2008 :  Creation


Author: Meera Nair/Krishnaprasad P
*/
public class VFCntrlr_AccountTeamMemberDelete {
   

    
    //Variable Declaration
    
    @TestVisible private String message='NOT STARTED';   
    @TestVisible private Map<id,Profile> adminProfiles;
    @TestVisible private Integer limitCount;
    @TestVisible private Integer buttonClickCount=0;
    @TestVisible private Integer processedRecordCount=0;
    @TestVisible private List<AccountTeamMember> TeamMemberListToDelete=new List<AccountTeamMember>();
    @TestVisible private Integer totalRecordsDeleted=0;
    
    @TestVisible private boolean testInvocation=false;
   
     
    //GET METHODS
    public String getMessage() {
        return message;
    }
    
     public Integer getTotalRecordsDeleted() {
        return totalRecordsDeleted;
    }
    
    public Integer getButtonClickCount() {
        return buttonClickCount;
    }

    
    //ACTION METHODS    
    public void deleteTeamMember(){
        try{
            buttonClickCount++;
            System.debug('#MN:button click count is:'+buttonClickCount);
            
            //Get Admin User Profiles
            adminProfiles=new Map<id,Profile>([SELECT id FROM Profile WHERE Name LIKE '%Dell%' OR Name  LIKE '%/User/%' OR Name = 'System Administrator']);
            System.debug('#MN:adminProfiles are:'+adminProfiles);
            
            //Limit the count of selected Account Team Member records to a safe value
            limitCount=Limits.getLimitQueryRows()-Limits.getQueryRows();            
            
            //SET LIMIT =300 FOR TEST MODE
            if(testInvocation)limitCount=100; 
                                 
            System.debug('#MN:Limit Count is:'+limitCount);
            
            //Select Account Team Members created and modified by end users
            for(List<AccountTeamMember> accountTeamMemberList :[SELECT Id, AccountId, UserId,TeamMemberRole, 
                                                             CreatedDate, CreatedById, LastModifiedDate, LastModifiedById FROM AccountTeamMember 
                                                             WHERE CreatedBy.ProfileId NOT IN :adminProfiles.keySet() AND LastModifiedBy.ProfileId 
                                                             NOT IN :adminProfiles.keySet() LIMIT :limitCount]){
                                                                
                
                
                
                for(AccountTeamMember accountTeamMembertoCheck : accountTeamMemberList){
                    
                    //System.debug('#MN:AccountTeamMember to be checked is: '+accountTeamMembertoCheck );
                    
                    if(accountTeamMembertoCheck!=null){
                        processedRecordCount++;
                        
                        if(accountTeamMembertoCheck.CreatedDate==accountTeamMembertoCheck.LastModifiedDate){
                            TeamMemberListToDelete.add(accountTeamMembertoCheck);
                        }
                        
                        if(TeamMemberListToDelete.size()==200 || testInvocation){
                            totalRecordsDeleted = totalRecordsDeleted + 200;
                            delete TeamMemberListToDelete;
                            TeamMemberListToDelete.clear();
                        }
                                                
                    }//end if
                
                }// end list-for-loop
                    
            }//end query-for-loop
            
            //If there exist more record to be deleted
            if(TeamMemberListToDelete.size()>0){
                totalRecordsDeleted = totalRecordsDeleted + TeamMemberListToDelete.size();
                delete TeamMemberListToDelete;
            }
            
            //If there exist more users whose default team is to be deleted
                         
            //Check count of processed record with limitCount  
            if(processedRecordCount==limitCount){
               message='There may exist more Account Team Members to be deleted, please click the button once again to complete the operation.'; 
            }
            else{
               message ='ACCOUNT TEAM MEMBER DELETION HAS BEEN COMPLETED';
            }
        }catch(Exception e) {
            ApexPages.addMessages(e);
            system.debug('#MN-Exception -'+e.getMessage()); 
        } 
       
    }   
  }