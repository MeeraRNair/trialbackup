Public class AddVendorReimbursementFormCntrlr{

public String reimbursFormId;
public MDF_Program__c mdfProgram{get;set;}
public List<APVWrapper> selectedAssociatedVendorsWrapper{get;set;}
public List<Associated_Programs_Vendors__c> totalList = new List<Associated_Programs_Vendors__c>();
public String searchAlphabet;

public String getsearchAlphabet(){

    return searchAlphabet;
    
}

public void setsearchAlphabet(String alpha){

    searchAlphabet = alpha;
}
    
    public AddVendorReimbursementFormCntrlr(ApexPages.StandardSetController controller){
    
        selectedAssociatedVendorsWrapper = new List<APVWrapper>();
        if(Apexpages.currentpage().getParameters().containsKey('id')){
        
            reimbursFormId = Apexpages.currentpage().getParameters().get('Id');
        }
        
        if(reimbursFormId != null){
        
            Reimbursement_Form__c parentReimbForm = [Select Id,MDF_Program__c,(Select Id,APV__c,Distributed_Price__c FROM Vendor_Reimbersments__r) FROM Reimbursement_Form__c WHERE Id=:reimbursFormId LIMIT 1];
            Set<Id> existingAssPrgIds = new Set<Id>();
            if(!parentReimbForm.Vendor_Reimbersments__r.isEmpty()){
                existingAssPrgIds = new Set<Id>();
                for(Vendor_Reimbursement__c vrf : parentReimbForm.Vendor_Reimbersments__r){
                
                    existingAssPrgIds.add(vrf.APV__c);
                }
            }
            if(!existingAssPrgIds.isEmpty()){
                mdfProgram = [Select Id,Name,Program_Id__c,(Select Id,Name,Budgeted_Price__c,Status__c,Vendor__c,POP_Status__c,Vendor__r.name,vendor__r.Lob__c FROM Associated_Programs_Vendors__r WHERE Id NOT IN:existingAssPrgIds AND Status__c != 'declined' order by Vendor__r.name ASC) FROM MDF_Program__c WHERE Id=:parentReimbForm.MDF_Program__c  LIMIT 1];
            }
            else{
                mdfProgram = [Select Id,Name,Program_Id__c,(Select Id,Name,Budgeted_Price__c,Status__c,Vendor__c,POP_Status__c,Vendor__r.name,vendor__r.Lob__c FROM Associated_Programs_Vendors__r WHERE Status__c != 'declined' order by Vendor__r.name ASC) FROM MDF_Program__c WHERE Id=:parentReimbForm.MDF_Program__c  LIMIT 1];
            }
            
            //mdfProgram = [Select Id,Name,Program_Id__c,(Select Id,Name,Converted_Budget_Price__c,Status__c,Vendor__c FROM Associated_Programs_Vendors__r) FROM MDF_Program__c WHERE Id=:parentReimbForm.MDF_Program__c LIMIT 1];
            if(!mdfProgram.Associated_Programs_Vendors__r.isEmpty()){
            
                for(Associated_Programs_Vendors__c apv : mdfProgram.Associated_Programs_Vendors__r){
                
                if(apv.Status__c != 'declined')
                    selectedAssociatedVendorsWrapper.add(new APVWrapper(apv,mdfProgram));
                    totalList.add(apv);
                  // else
                  //  Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'No vendors have been contracted for this program, please contact program owner for assistance'));
                    
                }
                
            }
            else{
            
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'There are no available vendors for this record'));
            }
        }
    }
    
    //Wrapper class
    public class APVWrapper{
        public Associated_Programs_Vendors__c apvElt{get;set;}
        public MDF_Program__c mdPrgrm{get;set;}  
        public Boolean selected {get;set;}
        public Double distributedPrice{get;set;}
        //Constructor for wrapper class
        public APVWrapper(Associated_Programs_Vendors__c apvObj,MDF_Program__c prgrm){
            apvElt = apvObj;
            mdPrgrm = prgrm;            
            selected = false;
        }
    }
    
    public void sortByAlphabet(){
        
        if(!totalList.isEMpty()){
        
            if(searchAlphabet != null && searchAlphabet != 'All' && searchAlphabet != 'Other'){
                selectedAssociatedVendorsWrapper = new List<APVWrapper>();
                for(Associated_Programs_Vendors__c apv : totalList){
                    
                    if(apv.Vendor__r.name.startsWith(searchAlphabet)){
                    
                        selectedAssociatedVendorsWrapper.add(new APVWrapper(apv,mdfProgram));
                    }
                }
            }
            if(searchAlphabet == 'All' || searchAlphabet == 'Other'){
                selectedAssociatedVendorsWrapper = new List<APVWrapper>();
                for(Associated_Programs_Vendors__c apv : totalList){
                    
                    
                        selectedAssociatedVendorsWrapper.add(new APVWrapper(apv,mdfProgram));
                    
                }
            }
            
        }
        
    }
    
    public pagereference insertVendorReimbrsRecords(){
    
        List<Vendor_Reimbursement__c> VendorReimbrsRecords = new List<Vendor_Reimbursement__c>();
        
        for(APVWrapper wrp : selectedAssociatedVendorsWrapper ){
        
            if(wrp.selected == True){
            
                Vendor_Reimbursement__c vr = new Vendor_Reimbursement__c();
               vr.vendor__c = wrp.apvElt.Vendor__c;
                vr.lob__c = wrp.apvElt.vendor__r.lob__c;
                vr.APV__c = wrp.apvElt.Id;
                vr.Budgeted_Price__c = wrp.apvElt.Budgeted_Price__c;
                vr.Contract_Status__c = wrp.apvElt.Status__c;
                vr.POP_Status__c =    wrp.apvElt.POP_Status__c;
                vr.Program__c = wrp.mdPrgrm.Name;
                vr.Program_ID__c = wrp.mdPrgrm.Program_Id__c;
                vr.Reimbursement_Form__c = reimbursFormId;
                vr.Distributed_Price__c = vr.Distributed_Price__c;
                vr.MDF_Program__c = wrp.mdPrgrm.Id; 
                if(wrp.distributedPrice != null){
                    vr.Distributed_Price__c = wrp.distributedPrice;
                }
                                
                VendorReimbrsRecords.add(vr);
            }
        }
        
        if(!VendorReimbrsRecords.isEmpty()){
        
            Database.insert(VendorReimbrsRecords,false);
        }
        
        return new pagereference('/'+reimbursFormId);
    }
    
    
}