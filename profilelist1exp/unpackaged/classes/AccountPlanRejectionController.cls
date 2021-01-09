/*
 * Author   : Ragu
 * Purpose  : Additional custom functionality for rejecting the account plan.
 * 
 * REVISION HISTORY
 * ================
 * Version  Modified By     Date            Reference No    Description
 * -------  -----------     ----            ------------    -----------
 * 1.0      Ragu            25-Aug-2014     CR 10062        Created for to reject Account Plan (work with AccountPlanRejection.page)
 * 1.1      Jananii         30-Sep-2015     CR 11998        Updated to enable Rejecting Partner Business Plan. So that Partner Business Plan's Manager is able to reject
 * 
 * 
 */

public class AccountPlanRejectionController {

    public SFDC_Acct_Plan__c accPlan {get;set;}
    public boolean canProceed = true;
    public boolean getCanProceed() {
        return canProceed;
    }

    public AccountPlanRejectionController(ApexPages.StandardController controller) {
        try {
            Id accPlanId = controller.getId();
            if(accPlanId != null) {
            // V 1.1 - Start 
                accPlan = [select Id, Date_Rejected__c, Rejected_by__c, Sales_Manager__c, Plan_Status__c, Reason_for_Rejection__c, Manager__c,RecordType.Name from SFDC_Acct_Plan__c where Id = :accPlanId];
            //V 1.1 - End
            }
            else {
                throw new RequiredParametersMissingException();
            }
            checkPrerequisite();
        }
        catch(Exception e) {
            handleError(e);
        }
    }
    
    // Check whether account plan is eligible for rejection
   private void checkPrerequisite() {
    
       //V 1.1 - Start
       if(
           (accPlan.RecordType.Name== 'Direct Relationship Account Plan' &&             
            accPlan.Sales_Manager__c != UserInfo.getUserId()) 
           ||
           (accPlan.RecordType.Name== 'Channel/Partner Account Plan' &&             
            accPlan.Manager__c != UserInfo.getUserId()) 
       )
      //V 1.1 - End
        {
            throw new InsufficientPrivilegeException();
        } 
        if(accPlan.Plan_Status__c != 'Submitted for Approval') {
            throw new InvalidStatusException();
        }
    }


    
    // Reject account plan and populate rejection tracking fields
    private void rejectAccountPlan() {
        accPlan.Date_Rejected__c = System.now().dateGmt();
        accPlan.Rejected_by__c = UserInfo.getUserId();
        accPlan.Plan_Status__c = 'Rejected';
        update accPlan;
    }

    // Create error message to be displayed in the visualforce page
    private void createError(boolean canProceedBool, String errMsg) {
        apexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errMsg)); 
        canProceed = canProceedBool;
    }
    
    // Handle all exceptions
    private void handleError(Exception e) {
        System.debug('### Error Stack Trace : ' + e.getStackTraceString());
        System.debug('### Message : ' + e.getMessage());
        
        if(e instanceOf System.DmlException) {
           createError(false, e.getDmlMessage(0));
           return;
        }
        if(e instanceOf InsufficientPrivilegeException) {
            createError(false, 'You do not have privilege to reject the Account Plan. Please click Back to go back to previous page.');
            return;
        }
        if(e instanceOf InvalidStatusException){   
            createError(false, 'The status of Account Plan is not Submitted for Approval. Please click Back to go back to previous page.');
            return;
        }
        if(e instanceOf RequiredParametersMissingException) {
            createError(false, 'Required parameters missing. Please contact the administrator.');
            return;
        }
        createError(false, 'An unexpected error has occurred. Please contact the administrator.');
    }
    
    private boolean validateReasonForRejection() {
        boolean bValid = true;
        String strReason = accPlan.Reason_for_Rejection__c;
        if(String.isBlank(strReason)) {
            
            bValid = false;
        }
        return bValid;
    }
    
    // Reject the account plan
    public PageReference reject() {
        try {
            if(validateReasonForRejection()) {
                checkPrerequisite();
                rejectAccountPlan();
            }
            else {
                accPlan.Reason_for_Rejection__c.addError('You must enter a value');
                return null;
            }
        }
        catch(Exception e) {
            handleError(e);
            return null;
        }
        return back();
    }
    
    // Navigate back to the account plan detail page
    public PageReference back() {
        return PageUtils.redirect ('/' + accPlan.Id);
    }
    
    public class InvalidStatusException extends Exception {}
    public class InsufficientPrivilegeException extends Exception {}
    public class RequiredParametersMissingException extends Exception {}
    
}