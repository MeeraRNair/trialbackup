/*
 * REVISION HISTORY
 * ================
 
 * Revision#        Author      Date        Release#        CR#     Description
 * ---------        ------      ----        --------        ---     -----------
 * 1.0              Gan         7-Oct-2015  CSM1102         12034   Create OEM Change Control records when click on [Add] button on Change Control related list on OEM Requirement page
 */
 
public class OEMChangeControlCntrl{
    private string oemReqId = null;
    private string changeControlId = null;
    private string retURL = null;
    
    public OEM_Change_Control__c changeControl { get; set;}
    
    public OEMChangeControlCntrl(ApexPages.StandardController controller){
        try{
             retURL = Apexpages.currentPage().getParameters().get('retURL');
             changeControlId =  ((OEM_Change_Control__c)controller.getRecord()).Id;
             
             Schema.DescribeSObjectResult d = OEM_Requirement__c.SObjectType.getDescribe();
             string prefix = d.getKeyPrefix();
             Integer index = retURL.indexOf(prefix);
             if(index > 0){ // the index will be -1 if the edit button is clicked from Communication Plan details page
                 oemReqId = retURL.substring(index, (index+15));
             }

             if(changeControlId != null){ // Execution will enter this block if edit Communication Plan
                changeControl = [SELECT OEM_Requirement__c, Revision__c, Date__c, Customer_approver__c, Schedule_Impact__c, Change_details__c FROM OEM_Change_Control__c WHERE Id = : changeControlId];
                oemReqId = changeControl.OEM_Requirement__c;
             
             }else{ // Execution will enter this block if create new Communication Plan
                 if(oemReqId == null){
                     addMessages('Change Control can be created from only OEM Requirement record.');
                 }else{
                     changeControl = new OEM_Change_Control__c();
                 }
             }

         }catch(Exception ex){
             addMessages('Line ' + ex.getLineNumber() + ': ' + ex.getMessage());
         }
     }
     
     public PageReference save(){
         try{
             if(changeControl != null){
                 if(changeControlId == null){
                     changeControl.OEM_Requirement__c = oemReqId;
                     insert changeControl;
                 }else{
                     update changeControl;
                 }
             }
         }catch(Exception ex){
             addMessages('Line ' + ex.getLineNumber() + ': ' + ex.getMessage());
             return null;
         }
         return new PageReference(retURL);
     }
     
    public PageReference cancel(){
         return new PageReference(retURL);
     } 
     
     private void addMessages(string msg){
         ApexPages.Message apexMsg = new ApexPages.Message(ApexPages.Severity.ERROR, msg);
         ApexPages.addMessage(apexMsg);
     }

    public boolean getHasError(){
         return ApexPages.hasMessages();
     }
}