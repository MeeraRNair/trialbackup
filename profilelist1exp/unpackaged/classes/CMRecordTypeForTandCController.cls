public class CMRecordTypeForTandCController {
    String recType {get;set;}
    List<RecordType> recTypeList = new List<RecordType>();
    Contract contractObj{get;set;}
    Id contractId{get;set;}
    Id stdRecTypeId{get;set;}
    Id nonStdRecTypeId{get;set;}
    public String isEditButtonClicked{get;set;}
    public String isNewButtonClicked{get;set;} 
    public CMRecordTypeForTandCController(ApexPages.StandardController controller) {        
        contractObj = (Contract)controller.getRecord();
        contractId = controller.getID();
        contractObj=[SELECT id,ContractNumber from Contract where id =:contractId]; 
        isEditButtonClicked = Apexpages.currentPage().getParameters().get('isEditButtonClicked');
        isNewButtonClicked = Apexpages.currentPage().getParameters().get('isNewButtonClicked');
        for(RecordType rt:[select id,name,description from RecordType where sobjecttype='Contract_Terms_and_Conditions__c']){
            recTypeList.add(rt);
        }
    }
    public PageReference redirect() {
        PageReference pageRef;
        if(recType == StdRecTypeId){
            return PageUtils.redirect('/apex/CMVF_StdTandC?id='+contractId+'&isEditButtonClicked='+isEditButtonClicked+'&isNewButtonClicked='+isNewButtonClicked);                         
        }else if(recType ==nonStdRecTypeId){
            //return PageUtils.redirect('/a1d/e?CF00NT0000001IXUS='+contractObj.ContractNumber+'&CF00NT0000001IXUS_lkid='+contractId+'&RecordType='+nonStdRecTypeId);
            return PageUtils.redirect('/apex/CMVF_NonStdTandC?id='+contractId+'&isEditButtonClicked='+isEditButtonClicked+'&isNewButtonClicked='+isNewButtonClicked);
        }
        return pageRef;    
    }
    public PageReference cancel(){
         return PageUtils.redirect('/'+contractId);
    }
    
    public List<SelectOption> getrectypes() {
       List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--Select Record Type --'));
        //for(RecordType rt:[select id,name,description from RecordType where sobjecttype='Contract_Terms_and_Conditions__c']){
        for(RecordType rt:recTypeList){
            options.add(new SelectOption(rt.id,rt.name)); 
            //recTypeList.add(rt); 
            if(rt.name == 'Non-Standard Terms and Conditions'){
                nonStdRecTypeId = rt.id;
            }else if(rt.name == 'Standard Terms and Conditions'){
                StdRecTypeId = rt.id;
            }  
        }
        return options;
    }
    public String getRecordType() {
        return recType;
    }
    
    public void setRecordType(String recType) {
        this.recType= recType;
    }
    public List<RecordType> getRecTypeList() {
        return recTypeList;
    }
    
    

}