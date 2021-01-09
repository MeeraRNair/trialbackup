/* 
* Author   : 
* Purpose  : 
* 
* REVISION HISTORY
* ================
* Version  Modified By     Date            Reference No    Description
* -------  -----------     ----            ------------    -----------
* 2.0      Ragu            25-Aug-2014     CR 10062        Modified to reject Account Plan (work with AccountPlanRejection.page)
* 2.1      Jananii         30-Sep-2015     CR 11998        Modified to Approve/Reject Partner Business Plan
* 2.2      Naga            30-May-2018     CR 15887        Modified to populate Apporved by field for Account Plan Lite RecordType
* 
*/

public class AccountPlanUpdateStatusController {
    
    SFDC_Acct_Plan__c accPlan;
    
    public AccountPlanUpdateStatusController (ApexPages.StandardController controller) {   
        accPlan = (SFDC_Acct_Plan__c)controller.getRecord();
    }
    
    public boolean getHasMessage() {
        return ApexPages.hasMessages();
    }
    
    public PageReference updateAccountPlanStatus(){
        system.debug('###AP STATUS IS accPlan.Plan_Status__c : ' + accPlan.Plan_Status__c);
        
        if(accPlan.Plan_Status__c == 'Submitted for Approval') {
            
            System.debug('**Controller Debug -- accPlan.Sales_Manager__c** ::'+accPlan.Sales_Manager__c);   
            System.debug('**Controller Debug -- accPlan.RecordType.Namec** ::'+accPlan.RecordType.Name);
            System.debug('**Controller Debug -- accPlan.Manager__c** ::'+accPlan.Manager__c); 
            
            
            // Rev 2.1 - Start             
            if(accPlan.Sales_Manager__c != null && accPlan.RecordTypeId==IdLookupUtils.getRecordTypeId('Direct Relationship Account Plan','SFDC_Acct_Plan__c',true)) {
                
                System.debug('Inside -- Sales_Manager__c not null and RecordTypeId is Direct Relationship Account Plan');
                accPlan.Approved_by_Sales_Management__c = accPlan.Sales_Manager__c; 
            }
            
            else if(accPlan.Manager__c!=null && accPlan.RecordTypeId==IdLookupUtils.getRecordTypeId('Channel/Partner Account Plan','SFDC_Acct_Plan__c',true)){
                System.debug('Inside -- Manager__c not null and RecordTypeId is Channel/Partner Account Plan');
                accPlan.Approved_by_Sales_Management__c = accPlan.Manager__c; 
                
            }
            //Rev 2.1 - End
            
            //Rev 2.2 - Start
            else if(accPlan.AP_Lite_Manager__c != Null && accPlan.RecordTypeId==IdLookupUtils.getRecordTypeId('Account Plan Lite','SFDC_Acct_Plan__c',true)){
                accPlan.Approved_by_Sales_Management__c = accPlan.AP_Lite_Manager__c;
                
            }
            //Rev 2.2 - End
            
            accPlan.Plan_Status__c = 'Reviewed and Approved';
            // Rev 2.0 - Start
            accPlan.Date_Rejected__c = null;
            accPlan.Rejected_by__c = null;
            accPlan.Reason_for_Rejection__c = null;
            
            // Rev 2.0 - End
            
        }
        // Rev 2.0 - Start
        else if(accPlan.Plan_Status__c == 'Pending' || accPlan.Plan_Status__c == 'Rejected') {
            accPlan.Plan_Status__c = 'Submitted for Approval';
            accPlan.Date_Submitted_for_Approval__c = System.now().dateGmt();
        }
        // Rev 2.0 - End
        
        try {
            update accPlan;
        }
        catch(Exception e) {
            System.debug('Error : ' + e.getMessage());
            ApexPages.addMessages(e);
            return null;
        }
        return PageUtils.redirect('/' + accPlan.Id);    
    }
    
    public PageReference redirectBack() {
        if(accPlan.Id != null) {
            return PageUtils.redirect('/' + accPlan.Id);    
        }
        else {
            return PageUtils.redirect('/a0D');
        }
    }
    
}