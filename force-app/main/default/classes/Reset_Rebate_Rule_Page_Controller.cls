public class Reset_Rebate_Rule_Page_Controller{
 public string strComments{get;set;}
 public boolean showPage{get;set;}
 public Rebate_Rule_Header__c objHdr{get;set;}
 public String ruleid{get;set;}   
 public Reset_Rebate_Rule_Page_Controller(){
     ruleid = ApexPages.CurrentPage().getParameters().get('id');
     System.debug('##ruleid:'+ruleid);
     if(!checkUserProfile(UserInfo.getProfileId())){
         showPage = false;
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'You do not have sufficient privileges to reset rebate request.'));
     }
     else{
        objHdr = [Select Id,CreatedById,Status__c from Rebate_Rule_Header__c  Where Id=:ApexPages.CurrentPage().getParameters().get('id') LIMIT 1];
        if(objHdr.Status__c != 'Pending'){
          showPage = true;
        }
        else{
          showPage = false;
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Rebate rule header is already in Pending Status.'));
        }
     }
 }
 public void invokeOnLoad(){    
        if(ApexPages.CurrentPage().getParameters().get('id') != null){
             try{                 
                 if(objHdr !=null && objHdr.Status__c != 'Pending'){
                     objHdr.Status__c = 'Pending';   
                     System.Debug('Entered Try');
                     //Recall the Existing Approval Actions and unlock the record.
                     if(Approval.isLocked(ApexPages.CurrentPage().getParameters().get('id'))){                   
                        Approval.UnlockResult urList = Approval.unlock(objHdr, false);
                        processApprovalLogic(ApexPages.CurrentPage().getParameters().get('id'));
                     }
                     //Update the Status to Pending
                     update objHdr;
                     showPage = false;
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,'Reset Rebate Request Completed.'));
                 }
             }
             catch(Exception ex){
               System.Debug('Entered Catch');
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,ex.getMessage()));
             }
        }
 }
 
 //Method to check if User is Marketing User
 public boolean checkUserProfile(string profileId){
   if(profileId !=null){
       Profile pf =[Select Id,Name from Profile Where Id=:profileId LIMIT 1];
       if(pf !=null && pf.Name.contains('MDF Marketing Operations / Contract Admin')){
          return true;
       }
   }
   return false;
 }
 
 //Method to initiate new approval request
 public void processApprovalLogic(string recordId){
   System.Debug('Entered');
   if(recordId != null){
       List<ProcessInstance> procins = new List<ProcessInstance>([select Id from ProcessInstance where Status = 'Pending' and TargetObjectId = :recordId]);
       System.Debug('procins'+procins+'size'+procins.size());
       if(procins.size() > 0){
           List<ProcessInstanceWorkitem>  workitem = new List<ProcessInstanceWorkitem>([select Id from ProcessInstanceWorkitem where ProcessInstanceId = :procins[0].id order by CreatedDate DESC]);
           System.Debug('workitem'+workitem+'size'+workitem.size());
           Approval.ProcessWorkitemRequest PWR = new Approval.ProcessWorkitemRequest();
           PWR.setComments(strComments);
           PWR.setAction('Removed');
           if(workitem.size() > 0){
             PWR.setWorkitemId(workitem[0].Id);
             Approval.ProcessResult resultPrev =  Approval.process(PWR);
           }        
           System.Debug('Executed');
       }
   }
 }
   
}