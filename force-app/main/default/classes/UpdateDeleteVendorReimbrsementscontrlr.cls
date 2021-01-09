Public class UpdateDeleteVendorReimbrsementscontrlr{

    public String reimbursFormId;
    public MDF_Program__c mdfProgram{get;set;}
    public List<wrapperClass> wrapperList{get;set;}
    public List<Vendor_Reimbursement__c> totalList = new List<Vendor_Reimbursement__c>();
    public String searchAlphabet;
    
    public String getsearchAlphabet(){
        return searchAlphabet;
    }
    
    public void setsearchAlphabet(String alpha){
        searchAlphabet = alpha;
    }
    
    public UpdateDeleteVendorReimbrsementscontrlr(ApexPages.StandardSetController controller){
        
        wrapperList = new List<wrapperClass>();
        if(Apexpages.currentpage().getParameters().containsKey('id')){
        
            reimbursFormId = Apexpages.currentpage().getParameters().get('Id');
        }
        Reimbursement_Form__c rf;
        if(reimbursFormId != null){
        
            rf = [Select Id,Name,MDF_Program__c,(Select Id,Name,Vendorlob__c,SubVendor__c,APV__c,Distributed_Price__c,Vendor__r.name,BudgetedPrice__c,ContractStatus__c,POPStatus__c,MdfProgram__c,MdfProgram_ID__c FROM Vendor_Reimbersments__r) FROM Reimbursement_Form__c WHERE Id=:reimbursFormId LIMIT 1];
            mdfProgram = [Select Id,Name,Program_Id__c FROM MDF_Program__c WHERE Id=:rf.MDF_Program__c LIMIT 1];
        }
        
        if(!rf.Vendor_Reimbersments__r.isEmpty()){
            
            for(Vendor_Reimbursement__c vrs : rf.Vendor_Reimbersments__r){
            
                wrapperList.add(new wrapperClass(vrs));
                totalList.add(vrs);
            }
        }
        else{
        
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'No Records Found'));
        }
    }
    
    public void sortByAlphabet(){
        
        if(!totalList.isEMpty()){
        
            if(searchAlphabet != null && searchAlphabet != 'All' && searchAlphabet != 'Other'){
                wrapperList = new List<wrapperClass>();
                for(Vendor_Reimbursement__c apv : totalList){
                    
                    if(apv.Vendor__r.name.startsWith(searchAlphabet)){
                    
                        wrapperList.add(new wrapperClass(apv));
                    }
                }
            }
            if(searchAlphabet == 'All' || searchAlphabet == 'Other'){
                wrapperList = new List<wrapperClass>();
                for(Vendor_Reimbursement__c apv : totalList){
                    
                    
                        wrapperList.add(new wrapperClass(apv));
                    
                }
            }
            
        }
        
    }
    
    public pagereference updateVendorReimbRecords(){
        
        List<Vendor_Reimbursement__c> updateList = new List<Vendor_Reimbursement__c>();
        for(wrapperClass wrp : wrapperList){
        
            if(wrp.selected == True){
                
                Vendor_Reimbursement__c vr = new Vendor_Reimbursement__c();
                vr.Id = wrp.vrRecord.Id;
                vr.Distributed_Price__c = wrp.vrRecord.Distributed_Price__c;
                
                updateList.add(vr);
            }
        }
        
        if(!updateList.isEmpty()){
        
            Database.Update(updateList,false);
        }    
         
         
         return new pagereference('/'+reimbursFormId);
    }
    
    public pagereference deleteVendorReimbRecords(){
        
        List<Vendor_Reimbursement__c> deleteList = new List<Vendor_Reimbursement__c>();
        for(wrapperClass wrp : wrapperList){
        
            if(wrp.selected == True){
                
                deleteList.add(wrp.vrRecord);
            }
        }
        
        if(!deleteList.isEmpty()){
        
            Database.delete(deleteList,false);
        }    
         
         
         return new pagereference('/'+reimbursFormId);
    }
    
    public class wrapperClass{
    
        public Vendor_Reimbursement__c vrRecord{get;set;}
        public Boolean selected {get;set;}
        public Double distributedPrice{get;set;}
        public wrapperClass(Vendor_Reimbursement__c vrObj){
            vrRecord = vrObj;
            selected = false;
        }
    }
}