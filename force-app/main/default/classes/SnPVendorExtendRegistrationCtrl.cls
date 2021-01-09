/***********************************************************
* Name          : SnPVendorExtendRegistrationCtrl
* Description   : Extend Registration for S&P Vendor record
* ---------------------------------------------------------
* Revision      Release             Name         Date            Description
* 1.0           FY18-DCS-1001       Jessie Tan   16.08.2017      Story 3686076:VMware API – Registration Extensions (button logic)   
* 2.0           FY19-DCS-1002       Swathi       28.08.2018      Story 4399335:VVMware Opportunity Stage Values - CR 16400 
* 3.0           FY19-DCS-0102       Vivek        17.10.2019      STORY 4427064: VMware Form – Value Selling PopUp
************************************************************/

public class SnPVendorExtendRegistrationCtrl {
    
    private ApexPages.StandardController controller;
    public S_P_Vendors__c svRec {get;set;}
    public boolean hasError {get; set;} 
    public String msgText {get; set;}    
    
    public SnPVendorExtendRegistrationCtrl (ApexPages.StandardController controller) {   
        
        this.controller = controller;        
        Id idSnPVendor = controller.getRecord().Id;       
                 
        svRec = [Select Vendor_Tracking_Number__c, Vendor_Approval_Number__c, Value_Selling_Activities__c, 
                        Registration_Opportunity_Stage__c, Deal_Expiration_Date__c, S_P_Deal_Status__c, Extend_Registration__c
                 From S_P_Vendors__c 
                 Where Id = :idSnPVendor ];
        
    }

    public void extendRegistration (){
        
        try{
                        
            saveRecord(); 
                        
        }catch(Exception e){
        
            showError(e);
        
        }
        
        
        
    }
    
    private void validate(){
        
        if(svRec.Extend_Registration__c){
            throw new AlreadySubmittedException ('The current record was already requested to extend the registration');
        }
        
        if(!isEligibleForRegExtension()){
            throw new NotEligibleException ('Error: This S&P Deal Registration does not meet the criteria for extension with VMware. Please check the Registration Opportunity Stage and ensure that the deal is within 60 days of the Deal Expiration, or reach out to your S&P Registration operations team for assistance');
        }    
    
    }
   
    public PageReference loadUI(){
        
        try{
        
            validate();
            extendRegistration();
                                
        }catch(Exception e){
        
            showError(e);
            
        }
        
        return null;
    }
        
    private PageReference showError (Exception e){
        hasError = true;
        msgText = e.getMessage();
        return null;
    }
    
    //* 2.0 -CR 16400-  To rename '07 – Agreement to Purchase' to '07 - Agreement to Purchase' picklist value
    private Boolean isEligibleForRegExtension(){
    
        if(svRec.Vendor_Tracking_Number__c !=null && svRec.Vendor_Approval_Number__c!=null && svRec.S_P_Deal_Status__c == 'Approved' 
            && svRec.Registration_Opportunity_Stage__c != '07 - Agreement to Purchase' && isTodayWithinDateRange())
            return true;
        
        return false;
        
    }
    
    private boolean isTodayWithinDateRange(){
        
        Integer intDays = Date.today().daysBetween(svRec.Deal_Expiration_Date__c);
        
        System.debug('£££££££££ Deal Expiration Date : ' + svRec.Deal_Expiration_Date__c + ', Days to expiration: ' + intDays);
        
        System.debug('£££££££££ is Today Within Date Range? : ' + (intDays >=1 && intDays <=60));
        
        return (intDays >=1 && intDays <=60);
        
    }
    
    private void saveRecord(){
    
        svRec.Extend_Registration__c = true;
        update svRec;
        
    }
    
    public PageReference routeToDetailPage(){
        
        return new PageReference ('/' + svRec.Id);
        
    }
    
    public class NotEligibleException extends Exception {}
    public class AlreadySubmittedException extends Exception {}
    
}