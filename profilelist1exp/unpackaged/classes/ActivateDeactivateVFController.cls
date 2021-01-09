public class ActivateDeactivateVFController { 
    
    public Boolean vendor_rec=False; 
    public List<Vendor__c>subVendorList=new List<Vendor__c>();
    public List<Vendor__c>inactivesubVendorList=new List<Vendor__c>();
    Vendor__c Vendor =new Vendor__c(); 
    Vendor__c Vendor1 =new Vendor__c(); 
    public Boolean displayerr=True;
    public string strvndrId {get;set;}
    public Map<String,RecordType> vendorRT=new Map<String,RecordType>();
    //Constructor
    public  ActivateDeactivateVFController (ApexPages.StandardController ActivateDeactivatecontoller){ 
        strvndrId = apexpages.currentpage().getparameters().get('id');
        Id vendorId=ActivateDeactivatecontoller.getId();
        for(RecordType rtElt:[Select Name, Id From RecordType where sObjectType='vendor__c'])    {           
            vendorRT.put(rtElt.Name,rtElt);
        }  
        
        Vendor =[select Name,Parent_Vendor__c,recordtypeId,Is_this_a_Parent_Vendor__c,Partner_Status__c from Vendor__c where id=:vendorId];
            system.debug('###parent?' + Vendor.Is_this_a_Parent_Vendor__c);
    
        if (Vendor.Is_this_a_Parent_Vendor__c ==True) {
            system.debug('###inside if');
            subVendorList= [select Partner_Status__c from Vendor__c where Parent_Vendor__c=:Vendor.Id ]; 
        }
        
        if ((Vendor.Is_this_a_Parent_Vendor__c !=True) && (Vendor.recordtypeId==vendorRT.get('Sub Vendor').Id)){
            Vendor1=[select Name,Parent_Vendor__c,Partner_Status__c from Vendor__c where id=:Vendor.Parent_Vendor__c];
        }
    
    
    } 
    
    public Pagereference DeactivateVendor(){
        Id upd_id=Vendor.id;
        Vendor__c  subVendorUpdateObj;
        List<Vendor__c> subVendorUpdateList=new List<Vendor__c>(); 
        subVendorUpdateObj = new Vendor__c();  
        PageReference newPageRef;
        try{    
            if ((Vendor.recordtypeId==vendorRT.get('Sub Vendor').Id)){
                if (Vendor1.Partner_Status__c=='Inactive' ){
                    displayerr=False;  
//                    newPageRef=new PageReference('/apex/DeactivateVendorPage?id='+ Vendor.Id);         
                    return null;
                }else if (Vendor1.Partner_Status__c=='Active' ){
                    Vendor__c updateSubVendorobj=new Vendor__c(id=Vendor.id,Partner_Status__c='Inactive');
                    update updateSubVendorobj;  
                    newPageRef=new PageReference('/'+ Vendor.Id);     
                    return newPageRef;
                }
                     
            }
            if (Vendor.Is_this_a_Parent_Vendor__c ==True) {  
                for(Integer i=0;i<subVendorList.size();i++) {
                     if(subVendorList[i].Partner_Status__c !='Inactive'){
                         subVendorUpdateObj=new Vendor__c(id=subVendorList[i].Id,Partner_Status__c='Inactive'); 
                         subVendorUpdateList.add(subVendorUpdateObj);
                     }
                }
                update subVendorUpdateList;
            }
            Vendor__c updateParentVendorobj=new Vendor__c(id=Vendor.id,Partner_Status__c='Inactive');
            update updateParentVendorobj;
        }catch (DmlException e){
            System.debug(e.getmessage()); 
            ApexPages.addMessages(e);            
        }   
       newPageRef=new PageReference('/'+ Vendor.Id); 
       return newPageRef;
    }
    
    public Pagereference ActivateVendor(){
        Id upd_id=Vendor.id;
        Vendor__c  subVendorUpdateObj;
        List<Vendor__c> subVendorUpdateList=new List<Vendor__c>(); 
        subVendorUpdateObj = new Vendor__c();  
        PageReference newPageRef;
    
        try{
            if ((Vendor.recordtypeId==vendorRT.get('Sub Vendor').Id)){
                if (Vendor1.Partner_Status__c=='Inactive' ){
                    displayerr=False;  
//                    newPageRef=new PageReference('/apex/ActivateVendorPage?id='+ Vendor.Id);         
                    return null;
                }else if (Vendor1.Partner_Status__c=='Active' ){
                    Vendor__c updateSubVendorobj=new Vendor__c(id=Vendor.id,Partner_Status__c='Active');
                    update updateSubVendorobj;   
                    newPageRef=new PageReference('/'+ Vendor.Id);   
                    return newPageRef;   
                }               
            }
            Vendor__c updateParentVendorobj=new Vendor__c(id=Vendor.id,Partner_Status__c='Active');
            update updateParentVendorobj;
            
            if (Vendor.Is_this_a_Parent_Vendor__c ==True ) {  
            
                for(Integer i=0;i<subVendorList.size();i++) {
                     if(subVendorList[i].Partner_Status__c !='Active'){
                         subVendorUpdateObj=new Vendor__c(id=subVendorList[i].Id,Partner_Status__c='Active'); 
                         subVendorUpdateList.add(subVendorUpdateObj);
                     }
                }
                update subVendorUpdateList;
            
            }
        }catch (DmlException e){
            System.debug(e.getmessage()); 
            ApexPages.addMessages(e);
        }
       newPageRef=new PageReference('/'+ Vendor.Id); 
       return newPageRef;
    }
    
    public boolean getdisplayerr(){
        return displayerr; 
    }
    
    public string getparentvendor(){
        return Vendor1.Name; 
    }

}