/*************************************************************************************************************************
* Name          : AttendeeController
* Description   : Add account team attendees
* ---------------------------------------------------------
* Revision  Name        Date            Description
* 1.0       Sandhya     16.06.2011      CR 6382 -Change the subject line and email template for EBC/DSC Presenter invite.
* 2.0       Rahul       28.June-2018    Code Reduce!
**************************************************************************************************************************/

public with sharing class AttendeeController{
    public String ceRecord;
    public List<AccountTeamMember> teamMemberList = new List<AccountTeamMember>();
    public List<TeamDetails> teamDetail = new List<TeamDetails>();
    public List<Attendees__c> newAttendeeList = new List<Attendees__c>();
    public List<SelectOption> options = new List<SelectOption>();
    public Boolean listSizeNotZero = False;
    public Boolean errorForNoAccountTeam = False;
    public String accountName;
 
    /*CR 6372 : Search function for Customer and account team attendees*/
    public String accntTMember {get; set;}
    public List<Id> acctTeamIds = new List<Id>();
    public Boolean searchErrorForNoAccountTeam = False;
    public Boolean searchListSizeNotZero = False;

    public AttendeeController(ApexPages.StandardController controller) {
        ceRecord = ApexPages.currentPage().getParameters().get('CEId');
    }
      
    public class TeamDetails{
        public Boolean selected{get;set;}
        public AccountTeamMember acc{get;set;}
        public TeamDetails(AccountTeamMember accnt){
           acc = accnt; 
           selected = false;
        }
    }
  
    public void setaccountName(String accountName){   
        this.accountName = accountName;    
    }
   
    public String getaccountName(){ 
        return accountName;
    }
    
    public List<SelectOption> getaccountNames() {
        try{ 
            options.clear(); 
            
            for (Attending_Accounts__c account : [select Account__c, Account__r.Name, Name,Customer_Engagement__c from Attending_Accounts__c where Customer_Engagement__c=:ceRecord]){
                options.add(new SelectOption(account.Account__r.Name, account.Account__r.Name));
            } 
        }
        catch(Exception e){
            PageUtils.addError('Exception Occured while listing account team');
        }
        return options;
    }
    
    public Boolean getlistSizeNotZero() {
        return listSizeNotZero;
    }
    
    public Boolean geterrorfornoaccountteam() {
        return errorfornoaccountteam;
    }
     
    public PageReference Next() {
         teamDetail.clear();
         //List<Id> acctTeamIds = new List<Id>();    //CR 6372
         try{
             for(Attendees__c atnd :  [select Account_Team__c from Attendees__c where Customer_Engagement__c=:ceRecord]){
                 acctTeamIds.add(atnd.Account_Team__c);
             }
             
             teamMemberList = [select UserId, AccountId,User.Name, TeamMemberRole From AccountTeamMember where Account.Name=:accountName and UserId NOT IN :acctTeamIds];        
             if(teamDetail == null){
                 teamDetail = new List<TeamDetails>();
             }
             for(AccountTeamMember acc : teamMemberList){
                  teamDetail.add(new TeamDetails(acc));
             }
             if(teamDetail.size() >0){
                  errorForNoAccountTeam = FALSE;
                  listSizeNotZero = TRUE;
                  //CR 6372
                  searchListSizeNotZero = true;
                  searchErrorForNoAccountTeam = false;                              
             }
             else{
                  errorForNoAccountTeam = TRUE;
                  listSizeNotZero = False; 
                  //CR 6372
                  searchListSizeNotZero = false; 
                  searchErrorForNoAccountTeam = false;                   
             }
         }
         catch(Exception e){
            PageUtils.addError('Exception Occured while retreiving attendee List');
         }
         return NULL;
    }
 
    /*CR 6372 : Search function for Customer and account team attendees : Start*/
    public PageReference Search() {
         teamDetail.clear();

         try{
             for(Attendees__c atnd :  [select Account_Team__c from Attendees__c where Customer_Engagement__c=:ceRecord]){
                 acctTeamIds.add(atnd.Account_Team__c);
             }

             string teamMemberquery = 'select UserId, AccountId,User.Name, TeamMemberRole  From AccountTeamMember where Account.Name=:accountName and UserId NOT IN :acctTeamIds';
                teamMemberquery = teamMemberquery + ' and ' + 'User.Name like ' + '\'%' + accntTMember + '%\'' ;
       
              teamMemberList = Database.query(teamMemberquery);
              
             if(teamDetail == null){
                 teamDetail = new List<TeamDetails>();
             }
             for(AccountTeamMember acc : teamMemberList){
                  teamDetail.add(new TeamDetails(acc));
             }
             if(teamDetail.size() >0){
                  searchErrorForNoAccountTeam = FALSE;
                  listSizeNotZero = TRUE;
                  searchListSizeNotZero = true;          
             }
             else{
                  searchErrorForNoAccountTeam = TRUE;
                  listSizeNotZero = true; 
                  searchListSizeNotZero = false;
             }
         }
         catch(Exception e){
            PageUtils.addError('Exception Occured while retreiving attendee List');
         }    
        return null;
    }
    /*CR 6372 : Search function for Customer and account team attendees : End*/
        
    public List<TeamDetails> getAccountTeamMember() {
         return teamDetail;        
    }
    
    public void setAccountTeamMember(List<AccountTeamMember> newteamMemberList){
         teamMemberList = newTeamMemberList;
    }
    
    public PageReference Save(){
         try{
             Id rtList=IdLookupUtils.getRecordTypeId('Account Team','Attendees__c',true);
             for (TeamDetails team : teamDetail ){
                if (team.selected == TRUE) {
                    /* CR 6382 -Change the subject line and email template for EBC/DSC Presenter invite. */
                    Attendees__c attendeeList = new Attendees__c(Attendee_Name__c=team.acc.User.Name,RecordTypeId= rtList,
                                                Account_Team__c=team.acc.UserId,Role__c=team.acc.TeamMemberRole, 
                                                Customer_Engagement__c=ceRecord,Account_Name__c=accountName);
                    newAttendeeList.add(attendeeList);
                }
             }
             if(newAttendeeList.size()>0){
                 insert newAttendeeList;
             }
         }
         catch(Exception e){
            PageUtils.addError('Exception Occured while saving the record');
         }
         return PageUtils.redirect('/'+ceRecord);
    }
    
    public PageReference Cancel(){
        return PageUtils.redirect('/'+ceRecord);
    }
    
    /*CR 6372 : Search function for Customer and account team attendees*/   
    public Boolean getsearcherrorfornoaccountteam() {
        return searcherrorfornoaccountteam;    
    }
    public Boolean getsearchListSizeNotZero() {
        return searchListSizeNotZero;    
    }       
}