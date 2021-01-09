/*
REVISION HISTORY
----------------
Version     Author      Date        Release#    CR#     Description
-------     ------      ----        --------    ---     -----------
1.0         Fenny       16-Dec-11   13.1        6741    Size limits exceeded and exception thrown, so to limit the number of returned records to 1000.
*/
public class PartnerDealRegistrationCtrl {

    public Integer rowLimit;
    public boolean protectedDealsSelected=false;
    public String userId; 
    public RecordType protectedDealRecType;
    public List<PartnerApprovalRequest> requests {get;set;}
    public Integer getCountOfRequests(){ return requests.size(); }
    
    public List<Opportunity> opportunityList=new List<Opportunity>();

    public String getPreferredLanguageCode(){  return PartnerUtils.getPreferredLanguageCode(); }
    
    public PartnerDealRegistrationCtrl(){
        userId = UserInfo.getUserId();        
        protectedDealRecType=[Select Name,Id From RecordType where Name='Protected Deal' Limit 1];
                
        requests = new List<PartnerApprovalRequest>();
        
        //rowLimit = LimitUtils.getAllowableQueryRows(); // Ver1.0
        rowLimit = 1000; // Ver1.0
        
        List<ProcessInstanceStep> processInstanceSteps = [
            select Id, ProcessInstance.TargetObject.Name, toLabel(ProcessInstance.TargetObject.Type), 
                ProcessInstance.Status, CreatedDate, ProcessInstance.Id, ProcessInstance.TargetObjectId 
            from ProcessInstanceStep 
            where StepStatus = 'Started' and ActorId=:UserInfo.getUserId() 
            order by CreatedDate DESC LIMIT  :rowLimit];
        PartnerApprovalRequest request = null;
        for(ProcessInstanceStep processInstanceStep : processInstanceSteps){
            request = new PartnerApprovalRequest();
            request.relatedToText = processInstanceStep.ProcessInstance.TargetObject.Name;
            request.relatedToId = processInstanceStep.ProcessInstance.TargetObjectId;
            request.approvalType = processInstanceStep.ProcessInstance.TargetObject.Type;
            request.status = processInstanceStep.ProcessInstance.Status; 
            request.dateSubmitted = processInstanceStep.CreatedDate;
            requests.add(request);
        }
    }
    //r1.0 - to be removed after compelted DIT Test for CR6741
    /*public void onPageLoad(){
        For(Opportunity opp : [SELECT Id,OwnerId FROM Opportunity WHERE OwnerId = '005J0000000NABQ' AND Name Like 'Oppty Loaded %']){
            try{
            system.debug('%%%%%%%%% inside onPageLoad');
            system.debug('%%%%%%%%% loaded oppty: '+opp);*/
             // Create an approval request for the opportunity
            /*Id[] idArr = new Id[]{};
            idArr.add(opp.OwnerId);
            Approval.ProcessResult result;
            Approval.ProcessSubmitRequest submitReq = new Approval.ProcessSubmitRequest();
            submitReq.setComments('Submitting request for approval.');
            submitReq.setObjectId(opp.Id); 
            submitReq.setNextApproverIds(idArr); */
            
            // Submit the approval request for the opportunity
            /*result = Approval.process(submitReq);
            
            if(result.isSuccess()){*/
                // First, get the ID of the newly created item
                /*List<Id> newWorkItemIds = result.getNewWorkitemIds();*/
                
                // Instantiate the new ProcessWorkitemRequest object and populate it
                /*Approval.ProcessWorkitemRequest workItemReq = new Approval.ProcessWorkitemRequest();
                workItemReq.setComments('Auto-approval');
                workItemReq.setAction('Approve');              
                workItemReq.setNextApproverIds(idArr);*/
                // Use the ID from the newly created item to specify the item to be worked
                /*workItemReq.setWorkitemId(newWorkItemIds.get(0));*/
                
                // Submit the request for auto-approval
                /*Approval.ProcessResult result2 = Approval.process(workItemReq);*/
                //succeed = result2.isSuccess();
            /*}
            
            }Catch(Exception e){
                System.debug(e);
            }
        }   
    }*/
   //r1.0 - to be removed after compelted DIT Test for CR6741 
   
    public List<Opportunity> getProtectedDealList(){
        if(!protectedDealsSelected){
            //rowLimit = LimitUtils.getAllowableQueryRows(); // Ver1.0
            opportunityList=[Select name,id, StageName,createddate From Opportunity where  
                            ownerId=:userId and recordTypeId=:protectedDealRecType.id and  
                            StageName!='Win - 100%' and StageName!='Lost, Cancelled - 0%' LIMIT  :rowLimit];

            protectedDealsSelected = true;

        }              

        return opportunityList;
        
    } 


}