/* 
History:
Version     Date           Modified By           Description    
1.0      11-Nov-2015     Yeswanth Ravilla     Created for CR 12311
*/


public class Approve_Reject_Action {
    public Opportunity oppObj {get;set;}
    Public Id oppId {get;set;}
    public Boolean validApprover {get;set;}
    public Boolean DealTypeEmpty {get;set;}
    public Boolean bDealregReviw {get;set;}
    public String approveRejectUrl {get;set;}
    public List<ProcessInstanceWorkitem> workItemList {get; set;}
    public List<ProcessInstanceWorkitem> workItemListForSysAdmin {get; set;}
  
  
 public Approve_Reject_Action(ApexPages.StandardController controller) {
   try
   {
    DealTypeEmpty=false;
    bDealregReviw = false;
    oppId=ApexPages.currentPage().getParameters().get('id');
    System.Debug('URTString --'+oppId);
    //oppObj = [Select Id, RecordtypeId,OwnerId,Deal_Registration_Status__c,Is_GC_Deal__c,Deal_Type__c,Enterprise_Sales_Approval_Requested__c,Account_Classification__c from Opportunity where Id = :oppId];   
    oppObj = [Select Id, RecordtypeId,OwnerId,Deal_Registration_Status__c,Deal_Type__c,Distributor_Name__c,Distributor_Reseller_Name__c,Enterprise_Sales_Approval_Requested__c,Account_Classification__c,Deal_Registration_Reviewer__c from Opportunity where Id = :oppId];
          
       If( oppObj.Deal_Registration_Status__c == 'Submitted'){
                workItemList = new List<ProcessInstanceWorkitem>();
                workItemList = getApprovalProcessRequest();
                               
                If( workItemList.size() > 0  ){
                    // Check If valid Approver or not
                    validApprover = isValidApprover();
                }else If( UserInfo.getProfileId() == System.Label.System_Administrator_Profile_Id ){ 
                    validApprover = true;
                }
                 else
                  { 
                     validApprover = false;  
                 }    
       }
               else
                {    
               validApprover = false;  
                }
         if(validApprover && String.isEmpty(oppObj.deal_Type__c)){  
             DealTypeEmpty=true; 
             }
      /* if(validApprover && oppObj.Deal_Registration_Reviewer__c ==null){  
             bDealregReviw=true; 
             }*/
             System.debug('**** validApprover '+ validApprover);
             
   }
   
     catch (Exception e) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An error occurred while loading the page. Please contact your administrator for assistance');
            ApexPages.addMessage(myMsg);
            system.debug('ERROR@@@@@@@@@@@' + e);
 }
 }
     
  // Navigate to Standard Approve/Reject page for a particular deal when Approver clicks on Approve/Reject Button  
    public pagereference Approve_Reject_Action(){ 
        boolean isValid = true;
        /* If(bDealregReviw){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Deal Registration Reviewer field cannot be blank before approving or rejecting a deal.');
            ApexPages.addMessage(myMsg);
            isValid = false;
        } */
        If(DealTypeEmpty){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please input a Deal Type value before approving or rejecting a deal.');
            ApexPages.addMessage(myMsg);
            isValid = false;
        }
        
         If(validApprover && String.isEmpty(oppObj.Distributor_Name__c)){
         ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Fulfilment Path cannot be blank.');
            ApexPages.addMessage(myMsg);
            isValid = false;
        }
         If(validApprover && String.isEmpty(oppObj.Distributor_Reseller_Name__c) && oppObj.Distributor_Name__c=='Distribution'){
         ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Distributor/Reseller Account Name cannot be blank for Distribution deal registrations.');
            ApexPages.addMessage(myMsg);
            isValid = false;
        }
        If(DealRegUtils.isOwnerIdhasGcProfile(oppObj.OwnerId) == False){
        If(oppObj.Enterprise_Sales_Approval_Requested__c == false && oppObj.Account_Classification__c == 'Enterprise') {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please conduct the Enterprise Sales Approval process before approving or rejecting this Enterprise deal.');
            ApexPages.addMessage(myMsg);
            isValid = false;
        }
        }
        If(validapprover == false){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'<b>Insufficient Privileges</b> You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.');
            ApexPages.addMessage(myMsg);
            isValid = false;
        }

        If(isValid == true){
            If(workItemList.size() > 0){
                             approveRejectUrl ='/p/process/ProcessInstanceWorkitemWizardStageManager?id='+ workItemList[0].id;  
                             PageReference pageRef= new PageReference(approveRejectUrl);
                             pageRef.setredirect(true); 
                             return pageRef; 
                     }   
                        else If(UserInfo.getProfileId() == System.Label.System_Administrator_Profile_Id ){   
                             workItemListForSysAdmin = getWorkItemList();
                             approveRejectUrl = '/p/process/ProcessInstanceWorkitemWizardStageManager?id='+ workItemListForSysAdmin[0].id;
                             PageReference pageRef= new PageReference(approveRejectUrl);
                             pageRef.setredirect(true); 
                             return pageRef; 
                     }
                 }
                    return null;     
            }
  
     //  Get the submitted Approval process Request Id for the sysAdmin        
    public List<ProcessInstanceWorkitem> getWorkItemList()
     {
        List<ProcessInstanceWorkitem> workItemListForSysAdmin = [SELECT id FROM ProcessInstanceWorkitem WHERE 
                                                                  processInstance.TargetObjectId=:oppId];  
        return workItemListForSysAdmin;
     }
    
     //  Get the submitted Approval process Request Id for the Deal    
     public List<ProcessInstanceWorkitem> getApprovalProcessRequest(){
        Set<Id> actorIdSet = new Set<Id>();
        actorIdSet.add(Userinfo.getUserId()); 
        List<ProcessInstanceWorkitem> workItemList = [SELECT id FROM ProcessInstanceWorkitem WHERE processInstance.TargetObjectId=:oppId 
                                                      AND ActorId IN: actorIdSet];
        return workItemList;     
     }
     
     
      //  Check for the Valid Approver
     public Boolean isValidApprover(){
            list<ProcessInstance> PI = [SELECT Id, Status,(SELECT Id, ActorId, OriginalActorId FROM StepsAndWorkItems)
                                      FROM ProcessInstance WHERE Status = 'pending' AND TargetObjectId = :oppId LIMIT 1];  
            list<ProcessInstanceHistory > PIHlist = new list<ProcessInstanceHistory>();  
            if(PI!=null && PI.size() > 0) {                   
                  for(ProcessInstance p : PI){            
                    PIHlist.addall(p.StepsAndWorkItems);          
                  }
            }
      
            Set<string> actoridSet = new Set<string>();
            Set<string> OriginalactoridSet = new Set<string>();
            if(PIHlist!=null && PIHlist.size() > 0) {
                for(ProcessInstanceHistory pih: PIHlist){
                  actoridSet.add(pih.actorId);
                  actoridSet.add(pih.OriginalActorId);
                  }
             }

            system.debug('actoridset'+actoridSet);
            Boolean isValidApprver ;
            If( actoridset.contains(Userinfo.getUserId()) ){
                 isValidApprver = true;
            }else{
                 isValidApprver = false;
            }
                return isValidApprver;
    }
}