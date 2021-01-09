/***************************************************************************************************************************************************************
* 
* Name          : VfCntrl_RequestEscalation
* Description   : controller class to support vfpage "RequestEscalationForCase" 
* ---------------------------------------------------------------------------------------
* Revision  Name            Date                 CR                                         Description
* 1.0       Srikanth      06.08.2017            14488                          Added logic on Request Escalation Button for Order support.
***************************************************************************************************************************************************************/

public class VfCntrl_RequestEscalation{
 public case caseObj {get;set;}
 List<CaseTeamMember> caseTeam = new List<CaseTeamMember>();
 public boolean requestEscalationCheck {get;set;}
 public boolean statusCompltedReqEscaIsfalse{get;set;}
 public boolean statusCompltedReqEscaIsTrue{get;set;}
 public boolean accountTeamMemberAccess{get;set;}
 public boolean cannotEscalateCaseWhenAssig{get;set;}
 
    
//Constructor
 public VfCntrl_RequestEscalation(ApexPages.StandardController controller) {
  Id loggedInUser = UserInfo.getUserId();
  cannotEscalateCaseWhenAssig = false;   
  List<User> loggedInUserProfile = new List<User>([SELECT Id,Profile.name  FROM User WHERE Id =:loggedInUser AND Profile.name LIKE '%portal%' Limit 1]); 
  caseObj = [select id, Escalation_Justification__c,Status,Time_of_escalation_request__c, Request_Escalation__c,Re_Open_Status_Flag__c,Is_Escalated_After_Close__c from case 
                       where id = :ApexPages.currentPage().getParameters().get('id')];
  caseTeam = [SELECT MemberId FROM CaseTeamMember 
                       where ParentId = :ApexPages.currentPage().getParameters().get('id') And MemberId = :loggedInUser And TeamRole.name ='Account Team Member' ];//TeamRoleId =: Label.CaseTeamRoleId
  
  
  if (caseObj.status == 'Assigned') {
      cannotEscalateCaseWhenAssig = true;
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.NoEscaltionBeforeInProgress));
  }else{     
  if (caseObj.Request_Escalation__c == false) {
   requestEscalationCheck = false;
  } else if(caseObj.Status != 'Completed' && caseObj.Request_Escalation__c == True && (caseTeam.size() > 0 || loggedInUserProfile.size() > 0)) {
   requestEscalationCheck = True;
   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.OrderSupportCaseEscalate));
  }
     
  if (caseObj.Status == 'Completed' && caseObj.Request_Escalation__c == false && (caseTeam.size() > 0 || loggedInUserProfile.size() > 0)){
    statusCompltedReqEscaIsFalse = true;
    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.OrderSupportCaseCompleted));
  }else if(caseObj.Status == 'Completed' && caseObj.Request_Escalation__c == True && (caseTeam.size() > 0 || loggedInUserProfile.size() > 0)){
      statusCompltedReqEscaIsTrue = true;
     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.OrderSupportCaseEscalate_Completed)); 
  }
   
  if(caseTeam.size() < 1 && loggedInUserProfile.size() < 1 && caseObj.status != 'Assigned'){
       accountTeamMemberAccess = true; 
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.AccountTeamMemReqToEscalate));
    }
     if (requestEscalationCheck != true && accountTeamMemberAccess != true && statusCompltedReqEscaIsTrue != true 
        && statusCompltedReqEscaIsFalse != true && caseObj.Re_Open_Status_Flag__c == true && caseObj.Status == 'Closed (Resolved)'){
        statusCompltedReqEscaIsTrue = true;
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.RequestEscalationReopen));
     }
  }
 }
  

// Save Button Functionality    
 public PageReference okSave() {
 
 if(caseObj.Status != 'Completed' && caseObj.Status != 'Closed (Resolved)' ){
  caseObj.Request_Escalation__c = True;
  caseObj.Time_of_escalation_request__c = System.now();
  update caseObj;
 }else if(caseObj.Status == 'Closed (Resolved)'){
  caseObj.Request_Escalation__c = True;
  caseobj.Is_Escalated_After_Close__c=true;
  caseObj.Time_of_escalation_request__c = System.now();
  caseObj.Re_Open_Status_Flag__c = True; 
  caseObj.Status = 'Re-Open';  
  update caseObj;
 } 
 

  PageReference page = new PageReference('/' + caseObj.Id);
  page.setRedirect(TRUE);
  return page;
 }

}