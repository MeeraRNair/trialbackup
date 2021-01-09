/*
Description: Apex controller Class which contains the methods which help in displaying and manipulating sales team members using VF page : "Update_Sales_Team_Main"
Version: 2.0
History:
1.0 - 18-Aug-2008 :  Creation
2.0 - 02-Sept-2008:  Updated ::  Added more test methods & comments
Author: Meera Nair/Krishnaprasad P
*/
/*
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
1.0         13359       Sprint 13       27-July-2016    Kenny           To separate test method in a test class from VFCntrlr_UpdateSalesTeamMain main class and change logic to disable the method of creation of OpportunityShare record manually and set OpportunityAccess = Edit when OpportunityTeamMember is added as OpportunityShare record is to be created automatically. 
*/   
public class VFCntrlr_UpdateSalesTeamMain {
    /*  ---   VARIABLE DECLARATIONS   ---   */
    private List<OpportunityTeamMember> OppTeamMembersList ;
    private List<Opportunity>  CurrentOppList;
    private boolean IsTeamMember=False;
    private boolean NoTeamMembersForTheOpportunity=True;
    private Id UserIdTobeChecked=UserInfo.getUserId();
    private boolean DataAvailable=True;
    private string OppId = ApexPages.currentPage().getParameters().get('id');
    /*  ---   CONSTRUCTOR   ---   */
    public VFCntrlr_UpdateSalesTeamMain(){
        //CurrentOppList =  [select id,Name,OwnerId from Opportunity where Id = :OppId limit 1];  
        checkDataAvailability();
        //initializes the team member list
        if(DataAvailable==true){
            initializeTheTeamMembersList();
            //for enabling the functionalities we set this flag as True for Opportunity Owner.
            if(UserIdTobeChecked==CurrentOppList[0].OwnerId){ IsTeamMember=True; }
            else{
                for(OpportunityTeamMember teamMember:OppTeamMembersList){
                    if(UserIdTobeChecked==teamMember.UserId){ IsTeamMember=True;
                        break;
                        // sets the IsTeamMember flag to True             
                    }                      
                } //end of for-loop over OppTeamMembersList
            }//end of else
            if(!IsTeamMember){
                //checks whether the user has Sys Admin profile.
                Id profileIdOfTheUser= UserInfo.getProfileId();             
                List<Profile> AdminProfileList= [select id,name from profile where id=:profileIdOfTheUser AND name like 'System Administrator' limit 1];
                if(AdminProfileList.size()>0){
                    IsTeamMember=True;
                }
                //Mahesh -- INC8989106 Added logic to give Add Oppty Team access to all users who have edit access on deal - 5/31/2019 -- Start
                else{
                    List<Opportunity> isDealReg = [SELECT Deal_Reg_Oppty__c FROM Opportunity where id =:OppId limit 1];
                    List<UserRecordAccess> hasEditAccess =  [SELECT RecordId FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND HasEditAccess = true AND RecordId =:OppId limit 1];
                    if(hasEditAccess.size()>0 && isDealReg[0].Deal_Reg_Oppty__c == 'Yes'){
                        IsTeamMember=True;
                    }
                }
                //Mahesh -- INC8989106 Added logic to give Add Oppty Team access to all users who have edit access on deal - 5/31/2019 -- End
            }            
        }
    }//end of constructor
    /*  ---   GET METHODS   ---   */     
    public List<OpportunityTeamMember> getOpportunityTeamMembers() {
        return OppTeamMembersList;
    }
    public boolean getIsTeamMember() {
        return IsTeamMember;
    }
    public Opportunity getOpportunity() {
        return CurrentOppList[0];              
    }
    public boolean getDataAvailable() {
        return DataAvailable;
    }
    public boolean getNoTeamMembers(){
        return NoTeamMembersForTheOpportunity;
    }
    /*  ---   ACTION METHODS   ---   */  
    public PageReference add(){
        String url='/apex/addSalesTeamMembers?oid='+ OppId;
        PageReference pageRef = new PageReference(url);
        return pageRef;
    }
    public PageReference cancel() {
        if(!DataAvailable){          
            // Implies current opportunity is not available, navigates to the Opportunity HOME page 
            String url='/006/o';
            PageReference pageref=new PageReference(url);
            return pageref;
        }
        return (new ApexPages.StandardController(CurrentOppList[0])).view(); 
    }
    public PageReference DeleteTeamMember() {
        integer index=0;
        Id IdOfTeamMemberToBeDeleted=ApexPages.currentPage().getParameters().get('TMId');
        for(OpportunityTeamMember teamMember:OppTeamMembersList){
            if(teamMember.id==IdOfTeamMemberToBeDeleted){
                try{
                    delete OppTeamMembersList[index];                        
                    //refreshing the Team Member list for better data integrity
                    initializeTheTeamMembersList();
                }
                catch(System.DMLException e) {
                    ApexPages.addMessages(e);
                    checkDataAvailability();
                    return null; } break; } index++; } if(OppTeamMembersList.size()==0) { NoTeamMembersForTheOpportunity=True; } return null;
    }  
    public PageReference DeleteAll(){
        checkDataAvailability();
        if(!DataAvailable){ return null;
        }
        try{
            delete OppTeamMembersList;
        }
        catch(Exception e) {
            ApexPages.addMessages(e);            
            return null; }  return (new ApexPages.StandardController(CurrentOppList[0])).view();
    } 
    public PageReference AddDefaultTeam() {
        //getting the default team of the Opportunity Owner
        List<UserTeamMember> DeafaultTeamList= [SELECT OwnerId, UserId, OpportunityAccessLevel, TeamMemberRole 
                                                FROM UserTeamMember where OwnerId=:CurrentOppList[0].OwnerId];
        if(DeafaultTeamList.size()>0){ List<OpportunityTeamMember> teamMemberList=new List<OpportunityTeamMember>();
            //Rev 1.0 Start
            // List<OpportunityShare> shareList=new List<OpportunityShare>();
            // OpportunityShare shareMember;
            //Rev 1.0 End
            OpportunityTeamMember teamMember;
            try{
                for(UserTeamMember defaultTeamRecord: DeafaultTeamList){
                    teamMember = new OpportunityTeamMember(opportunityId=OppId,TeamMemberRole=defaultTeamRecord.TeamMemberRole,UserID=defaultTeamRecord.userId);
                    //Rev 1.0 Start
                    if(defaultTeamRecord.userId!=CurrentOppList[0].OwnerId){
                        teamMember.OpportunityAccessLevel= 'Edit';
                    }
                    teamMemberList.add(teamMember);                                                     

                    //Rev 1.0 End
                }
                //Rev 1.0 Start
                // system.debug('##KP: shareList-'+shareList);
                //Rev 1.0 End
                if(teamMemberList.size()>0){
                    insert teamMemberList;
                } 
                //Rev 1.0 Start
                /* if(shareList.size()>0){
insert shareList;
}   
*/
                //Rev 1.0 End
            }
            catch(Exception e) {
                ApexPages.addMessages(e);
                system.debug('#MN-Exception -'+e.getMessage());
                checkDataAvailability();
                return null;
            }   
            //initialise the team member list
            initializeTheTeamMembersList(); 
        }
        return null;  
    }//end of adddefautteam method
    /*  ---   AUXILIARY METHODS   ---   */ 
    public void initializeTheTeamMembersList(){
        OppTeamMembersList = [select id,OpportunityId,TeamMemberRole,UserId,OpportunityAccessLevel,
                              Primary_Secondary_Specialty_SE__c
                              from OpportunityTeamMember where OpportunityId = :OppId];
        if(OppTeamMembersList.size()>0){
            NoTeamMembersForTheOpportunity=False; } else {NoTeamMembersForTheOpportunity=True;
        }    
    }
    public void checkDataAvailability(){
        CurrentOppList =  [select id,Name,OwnerId from Opportunity where Id = :OppId limit 1];
        if(CurrentOppList.size()>0){
            DataAvailable=true; 
        }
        else
            DataAvailable=false;
        IsTeamMember=false;
    }
}