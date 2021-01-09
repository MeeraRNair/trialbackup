/***********************************************************
* Name          : SnPDRSubmitToVendorExtension 
* Description   : Validate S&P Deal Status. Submit to Vendor phase
* ---------------------------------------------------------
* Revision      Release     Name         Date            Description
* 1.0           13.7        Pat Redor    05.14.2012      CR 7114 Automate the S&P Deal Registration status change between SFDC and CommVault 
* 2.0           13.10       Pat Redor    09.14.2012      Added filter when VMware deal is incomplete, it should be done manually
* 3.0           15.03       Rap Bernardo 05.14.2014      Allow submission of incomplete deals for Commvault and VMWare
************************************************************/
public class SnPDRSubmitToVendorExtension {
    
    private ApexPages.StandardController controller;
    private S_P_Vendors__c svRec;
    
    public String msgText {get; set;}    
    public boolean showPage {get; set;} // Displays message if the record is not automated
    public boolean showAlreadySubmitted {get; set;} // Displays message if record is currently in sent to vendor status
    public boolean showAlreadyApprovedRejected {get; set;} // Displays message if record is currently in approved or rejected status
    
    public Set<Id> CommvaultVMwareIds = new Set<Id>(); //3.0
    
    public SnPDRSubmitToVendorExtension(ApexPages.StandardController controller) {
        this.controller = controller;
        this.svRec = (S_P_Vendors__c)controller.getRecord();
        this.showPage = false;
        this.showAlreadySubmitted = false;
        this.showAlreadyApprovedRejected = false;
        
        CommvaultVMwareIds.add(IdLookupUtils.getRecordTypeId('Commvault', 'S_P_Vendors__c', true));//3.0
        CommvaultVMwareIds.add(IdLookupUtils.getRecordTypeId('VMware', 'S_P_Vendors__c', true));//3.0
    }

    public PageReference submitToVendor(){
        
        if(this.svRec.Automated__c == false){
            this.msgText = 'The current record is not implementing the automated process. Please contact your Product Manager or System Administrator.';
            this.showPage = true;
            return null;
        } else if(this.svRec.Contact_Name__c == NULL || this.svRec.Customer_Name__c == NULL) {
            this.msgText = 'Please complete all mandatory fields in the current S&P Vendor page before submit to vendor.';
            this.showPage = true;
            return null;
        } else if(this.svRec.S_P_Deal_Status__c == 'Sent to Vendor'){
            this.msgText = 'The current record was already submitted.';
            this.showAlreadySubmitted = true;
            return null;
        } else if(this.svRec.S_P_Deal_Status__c == 'Approved' || this.svRec.S_P_Deal_Status__c == 'Rejected'){
            this.msgText = 'The current record was already';
            this.showAlreadyApprovedRejected = true;
            return null;
        } else if(this.svRec.S_P_Deal_Status__c == 'Returned for more info'){//edited as per v3.0
            
            this.msgText = 'Incomplete deal should be completed manually by your Product Manager.';
            this.showPage = true;
            return null;
        //3.0 begin
        } else if (this.svRec.S_P_Deal_Status__c == 'Incomplete' && checkVendorRT()){//(this.svRec.S_P_Vendors_Name__c == 'CommVault' || this.svRec.S_P_Vendors_Name__c == 'VMware' )){
            
            this.msgText = 'Incomplete deal should be completed manually by your Product Manager.';
            this.showPage = true;
            return null;
            
        }
        
        //3.0 end
        
        this.svRec = SnPDRSubmitToVendorExtension.updateDealStatusAndSubmitFlag(this.svRec);
        updateSVRecord();
        
        return this.controller.view();
    }
    
    public Boolean checkVendorRT(){
        Integer checker = 0;
        for(Id rt : CommvaultVMwareIds){
            if(rt == this.svRec.RecordTypeId)
                checker = 1;
        }
        
        if (checker == 1)
            return false;
        
        return true;    
    }
    
    public void updateSVRecord(){
        update this.svRec;
    }
    
    public static S_P_Vendors__c updateDealStatusAndSubmitFlag(S_P_Vendors__c snp){
        snp.S_P_Deal_Status__c = 'Sent to Vendor';
        snp.Ready_to_submit_to_vendor__c = 'Yes';
        return snp;
    }
    
    public S_P_Vendors__c getSvRec(){
        return this.svRec;
    }
    
    public void setSvRec(S_P_Vendors__c svRec){
        this.svRec = svRec;
    }
    
    public ApexPages.StandardController getController(){
        return this.controller;
    }
    
    public void setController(ApexPages.StandardController controller){
        this.controller = controller;
    }
}