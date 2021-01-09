/*
 * REVISION HISTORY
 * ================
 
 * Revision#        Author      Date        Release#        CR#     Description
 * ---------        ------      ----        --------        ---     -----------
 * 1.0              Fenny       1-Oct-2015  CSM1102         12015   Create OEM Communication Plan records when click on [Add] button on Communication Plan related list on OEM Requirement page
 */
 
 public class OEMCommunicationPlanCntrl{
     private string oemReqId = null;
     private string comPlanId = null;
     private string retURL = null;
     
     public OEM_Communication_Plan__c comPlan { get; set;}
     
     public OEMCommunicationPlanCntrl(ApexPages.StandardController controller){
         try{
             retURL = Apexpages.currentPage().getParameters().get('retURL');
             comPlanId =  ((OEM_Communication_Plan__c)controller.getRecord()).Id;
             
             Schema.DescribeSObjectResult d = OEM_Requirement__c.SObjectType.getDescribe();
             string prefix = d.getKeyPrefix();
             Integer index = retURL.indexOf(prefix);
             if(index > 0){ // the index will be -1 if the edit button is clicked from Communication Plan details page
                 oemReqId = retURL.substring(index, (index+15));
             }

             if(comPlanId != null){ // Execution will enter this block if edit Communication Plan
                comPlan = [SELECT OEM_Requirement__c, Type__c, Description__c, Delivery_Method__c, Frequency__c, Owner__c, Details__c FROM OEM_Communication_Plan__c WHERE Id = : comPlanId];
                oemReqId = comPlan.OEM_Requirement__c;
             
             }else{ // Execution will enter this block if create new Communication Plan
                 if(oemReqId == null){
                     addMessages('Communication Plan can be created from only OEM Requirement record.');
                 }else{
                     comPlan = new OEM_Communication_Plan__c();
                 }
             }

         }catch(Exception ex){
             addMessages('Line ' + ex.getLineNumber() + ': ' + ex.getMessage());
         }
     }

     public PageReference save(){
         try{
             if(comPlan != null){
                 if(comPlanId == null){
                     comPlan.OEM_Requirement__c = oemReqId;
                     insert comPlan;
                 }else{
                     update comPlan;
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