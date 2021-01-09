public class CMFinalizeContractController {
  id contractId{get;set;}
  Id[] idArray = new Id[]{};
  boolean autoApprovalInitiated = false;
  public boolean bolMessage = false;
  Contract contractObject{get;set;}
  public CMFinalizeContractController(ApexPages.StandardController controller) {
        contractId = controller.getid(); 
        contractObject=[select id,OwnerId,status,No_Approval_Required__c from contract where id=: contractID];
        idArray.add(contractObject.OwnerId);
  }    
  public PageReference autoApproveContract(){
      Pagereference contractPageRef;
      if(contractObject.status=='Approved' || contractObject.No_Approval_Required__c == TRUE ){
          contractObject.Finalized__c = true;
          try{
            update contractObject;
          }Catch(Exception e){
            PageUtils.addError(e.getMessage());
          }
          if(contractObject.Finalized__c == true){
              try{
                // Create an approval request for the Contract
                  Approval.Processsubmitrequest request = new Approval.Processsubmitrequest();
                  request.setComments('Submit for Finalize');
                  request.setNextApproverIds(idArray);
                  request.setObjectId(contractObject.id);
                  // Submit the approval request for the Contract
                  Approval.Processresult result = Approval.process(request);
                  autoApprovalInitiated = result.isSuccess();
                  //verifying the result
                  if(result.isSuccess() == true){
                    // First, get the ID of the newly created item
                    List<ID> newWorkItemIds = result.getNewWorkitemIds();
                    
                    // Instantiate the new ProcessWorkitemRequest object and populate it
                    Approval.Processworkitemrequest workingRequest = new Approval.Processworkitemrequest();
                    workingRequest.setComments('Finalizing request');
                    workingRequest.setAction('Approve');
                    workingRequest.setNextApproverIds(idArray);
                    workingRequest.setWorkitemId(newWorkItemIds.get(0));
                    
                    // Submit the request for approval
                    Approval.Processresult result2 = approval.process(workingRequest);
                    contractObject.Finalized__c = false;
                    contractObject.status='Finalized';
                    update contractObject;  
                     contractPageRef = new PageReference('/'+contractid);       
                  }else{                      
                    contractPageRef = contractPageRef;
                  }
              }catch(Exception e){
                    PageUtils.addError(e.getMessage());
              }
          }
      }
      else{
          bolMessage = true;
      }
      return contractPageRef;
        
    }
    public boolean getautoApprovalInitiated (){
        return autoApprovalInitiated ;
    }
    public void setautoApprovalInitiated (boolean autoApprovalInitiated ){
        this.autoApprovalInitiated=autoApprovalInitiated ;
    }
    public boolean getbolMessage (){
        return bolMessage;
    }
    public void setbolMessage (boolean bolMessage){
        this.bolMessage=bolMessage;
    }
}