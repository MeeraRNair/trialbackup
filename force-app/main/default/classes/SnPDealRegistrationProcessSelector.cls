/***********************************************************
* Name          : SnPDealRegistrationProcessSelector
* Description   : 13.7 Rel - Collection of methods to check automation, lock and unlock record, and check for Federal value
* ---------------------------------------------------------
* Revision      Release     Name         Date            Description
* 1.0           13.7        Pat Redor    16.05.2012      CR 7114 Automate the S&P Deal Registration status change between SFDC and CommVault
* 2.0           13.10       Pat Redor    25.07.2012      CR 7375 Check exceptions for partial automation of SV Record
* 3.0           15.07       Rap Bernardo 26.06.2014      Stored the query to S_P_Vendor_Automation_Exception__c to a static variable to avoid Too Many SOQL issue
************************************************************/
public class SnPDealRegistrationProcessSelector {

    private Map<Id, List<S_P_Vendor_Automation_Exception__c>> svAutoExceptionMap = new Map<Id, List<S_P_Vendor_Automation_Exception__c>>();
    /*private static List<S_P_Vendor_Automation_Exception__c> svaeList = [SELECT Id, Name, Field_API_Name__c,Field_Name_Value__c,
                                                        S_P_Vendor_Automation_ID__c, Is_Active__c
                                                        FROM S_P_Vendor_Automation_Exception__c];*/ //3.0
    
    public SnPDealRegistrationProcessSelector (){
        
        for(S_P_Vendor_Automation_Exception__c svae : SnPHelperClass.svaeList){//[SELECT Id, Name, Field_API_Name__c,Field_Name_Value__c,
                                                        //S_P_Vendor_Automation_ID__c, Is_Active__c
                                                        //FROM S_P_Vendor_Automation_Exception__c]) { commented out as per 3.0
            if(svAutoExceptionMap.get(svae.S_P_Vendor_Automation_ID__c) == null)
                svAutoExceptionMap.put(svae.S_P_Vendor_Automation_ID__c, new List<S_P_Vendor_Automation_Exception__c> {svae});
            else
                svAutoExceptionMap.get(svae.S_P_Vendor_Automation_ID__c).add(svae);
        }
        
    }
    
    /* 
     * Method Name: checkAutomation()
     *
     * @params svForm - to be assigned with the concerned SV Record
     * @params svAutomation - to be assigned with the related SV Automation Record
     *
     */
    public S_P_Vendors__c checkAutomation(S_P_Vendors__c svForm, S_P_Vendor_Automation__c svAutomation){
  
        // Full Automation
        if(svAutomation.Is_Active__c && svAutomation.Automation_Type__c.trim() == 'Full Automation')
            svForm.Automated__c = true;
        
        // Partial Automation - only Partial Automation will have child records 
        else if(svAutomation.Is_Active__c && svAutomation.Automation_Type__c.trim() == 'Partial Automation') {
            svForm.Automated__c = checkAutomationExceptions(svForm, svAutomation.Id);
        }                     
        // Inactive mode
        else
            svForm.Automated__c = false;
        
        return svForm;
    }
    
    /* 
     * Method Name: checkAutomationExceptions()
     *
     * @params svForm - gets the sv record to be checked for exceptions
     * @params svAutoId - gets the Id of a vendor automation record
     *
     */
    public Boolean checkAutomationExceptions(S_P_Vendors__c svForm, Id svAutoId){
        
        if(svAutoExceptionMap.containsKey(svAutoId)){
            for(S_P_Vendor_Automation_Exception__c svae : svAutoExceptionMap.get(svAutoId)) {
                if(svForm.get(svae.Field_API_Name__c) != null) {
                    System.debug('***TEST PAT****' + String.valueOf(svForm.get(svae.Field_API_Name__c)).toLowerCase().trim() + '*****' + svae.Field_Name_Value__c.toLowerCase().trim());
                    if(svae.Field_Name_Value__c.toLowerCase().trim() == String.valueOf(svForm.get(svae.Field_API_Name__c)).toLowerCase().trim() &&
                       svae.Is_Active__c == true)
                        return false;
                }
            }
        }
        return true;
    }
    
    /* 
     * Method Name: lockUnlockRecord()
     *
     * @params svRec - will handle the record being locked or unlocked
     * @params action - pass "Approve" for lock and "Reject" for unlock
     *
     */
    public static void lockUnlockRecord(S_P_Vendors__c svRec, String action){
       
        // Create an approval request for the SV Record
        Approval.ProcessSubmitRequest request1 = new Approval.ProcessSubmitRequest();
        request1.setComments('An approval request for the sake of record Locking/Unlocking');
        request1.setObjectId(svRec.id);
        
        // Submit the approval request for the SV Record    
        Approval.ProcessResult result = Approval.process(request1);
               
        // Approve/Reject the submitted request 
    
        // First, get the ID of the newly created item     
        List<Id> newWorkItemIds = result.getNewWorkitemIds();
        
        // Instantiate the new ProcessWorkitemRequest object and populate it     
        Approval.ProcessWorkitemRequest request2 = new Approval.ProcessWorkItemRequest();
        request2.setAction(action);
        
        // Use the ID from the newly created item to specify the item to be worked     
        request2.setWorkitemId(newWorkItemIds.get(0));
        
        // Submit the request for approval 
        Approval.process(request2);
    }
    
    /* 
     * Method Name: checkCommVaultFederal()
     *
     * @params svRec - takes the record to be checked for Federal Value
     *
     */ 
    public static S_P_Vendors__c checkCommVaultFederal(S_P_Vendors__c svRec){
    
      if(svRec.CommVault_Federal_Formula__c == 'TRUE')
            svRec.CommVault_Federal__c = true;
       else
            svRec.CommVault_Federal__c = false;
            
       return svRec;
    }
}