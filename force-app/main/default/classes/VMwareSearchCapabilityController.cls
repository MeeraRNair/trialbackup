/*
  * Author   : Ravali K
  * Purpose  : This is the controller class for VF_VMwareSearchCapability page
  *
  * Revision   CR Number   Release No          Date          Modified By      Description
  * --------  ---------   ----------        -----------     ------------      -----------
  * 1.0        14782      FY18-DCS-1001       09-Aug-17      Ravali - UST      Controller class  
  *
*/



Public class VMwareSearchCapabilityController
{
   
     //public String country {get;set;}
     public String  companyname{get;set;}     
     public String  state{get;set;}
     public List<Accts> CompanyList {get; set;}
     public boolean ShowCompanylist {get; set;}
     public boolean EnableOtherFields {get;set;}     
     public boolean popupShow {get;set;} 
     public boolean disableSearch {get; set;}    
     //public Map<String,VMwarewrapper> CompanyMap = new Map<String,VMwarewrapper>();
     public S_P_Vendors__c  SnPRecord {get; set;}
     public id RecId;
     
     Public VMwareSearchCapabilityController()
     {
         RecId = ApexPages.currentPage().getParameters().get('id');
         SnPRecord = [Select id,Customer_Name__c, Customer_Domain__c, Ship_to_Address__c, Country__c, City__c, State__c, 
                                                Zip__c from S_P_Vendors__c where id =: RecId ];
         
         popupShow = false;
         
     }
     
     
     
    public void Search()
    {
        
        if(String.isEmpty(SnPRecord.country__c))
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Country Cannot be blank'));
            ShowCompanylist = true;
            disableSearch = true;
            
        }
        if(String.isEmpty(companyname))
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ' Please enter at least few characters of company name '));
            ShowCompanylist = true;
            disableSearch = true;
        }
        
        if(disableSearch != true)
        {
             ShowCompanylist = false;
        }                    
            
            HttpResponse objHttpResponse = VMWareSearchAPICallout.getAccountInfo(SnPRecord.country__c,companyname,state);
            system.debug('**************Resp on controller---'+objHttpResponse);
            if(objHttpResponse.getStatusCode() == 200){
                  CompanyList = new List<Accts>();    
                  ShowCompanylist = true;
                  VmWareAccountInfo objReponse = (VmWareAccountInfo) System.JSON.deserialize(objHttpResponse.getBody(), VmWareAccountInfo.class);
                  if(objReponse.accts !=null){
                    CompanyList.addAll(objReponse.accts);   
                  }else{
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning, objReponse.message));
                    return;    
                  }
                  
                }else{
                    //Show error in page message...
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, objHttpResponse.getStatusCode()+':'+objHttpResponse.getBody()));
                    return;    
            }
           
    }
   
    public Pagereference save(){

        String strSelectedRow = ApexPages.currentPage().getParameters().get('selectedRow');
        system.debug('********SelectedRow on VF Page**********'+strSelectedRow);
        S_P_Vendors__c objSnPUpdate = null;
        for(Accts accInfo:CompanyList){
            if(strSelectedRow == accInfo.CustomerID){
                            
                accInfo.isSelected = true;
                objSnPUpdate = new S_P_Vendors__c();
                objSnPUpdate.id = SnPRecord.id;
                objSnPUpdate.Customer_Name__c = accInfo.Name;
                objSnPUpdate.Customer_Domain__c = accInfo.DomainName;
                objSnPUpdate.Country__c = accInfo.Country;
                objSnPUpdate.City__c = accInfo.City;
                objSnPUpdate.Ship_to_Address__c = accInfo.Address_1_del
                                                +(accInfo.Address_2 == NULL? '':','+accInfo.Address_2)
                                                +(accInfo.Address_3 == NULL? '':','+accInfo.Address_3)
                                                +(accInfo.Address_4 == NULL? '':','+accInfo.Address_4);
                objSnPUpdate.State__c = accInfo.StateProvince;
                objSnPUpdate.Zip__c = accInfo.ZipPostalCode;
            }           
        }
        if(objSnPUpdate != null){
            try{
                update objSnPUpdate; // Capture Exception and show in VF page.
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Info, 'Record Updated Successfully.'));
                }catch(Exception ex){
                    ex.getStackTraceString();
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()));
                }
            
        }
        Pagereference pg = new pagereference('/'+SnPRecord.id);
        
        return pg;
        
    }
    
    
    public Pagereference Cancel(){
        Pagereference pg = new pagereference('/'+SnPRecord.id);
        
        return pg;
    
    }
    

    
    public class Accts{
        
        public Boolean isSelected {get;set;}
        public String ZipPostalCode {get;set;}
        public String StateProvince {get;set;}
        public String Name {get;set;}
        public String DomainName {get;set;}
        public String CustomerID {get;set;}
        public String Country {get;set;}
        public String City {get;set;}
        public String Address_4 {get;set;}
        public String Address_3 {get;set;}
        public String Address_2 {get;set;}
        public String Address_1_del {get;set;}
        public String AccountId;       
        
    }
    public class VmWareAccountInfo {
        public String success;
        public Integer responseCode;
        public String message;
        public List<Accts> accts;
    }  
   

}