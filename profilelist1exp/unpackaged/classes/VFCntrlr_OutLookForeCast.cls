public class VFCntrlr_OutLookForeCast {

    public Outlook_Forecast__c myOutLookForeCasts {get; set;}
    List <Vendor__c> vendorList = new List <Vendor__c>();
    List <Outlook_Forecast_Line_Item__c> myOutLookForeCatsLineItem {get; set;}
    List <Marketing_Plan__c> mPList ;
    Set <Marketing_Plan__c> mPListrequired ;
    Set <Id> vendorIds = new Set <Id>();
    List <Outlook_Forecast_Line_Item__c> outLookForcastLineItemList = new List <Outlook_Forecast_Line_Item__c> ();
    //List <Associated_Programs_Vendors__c> apvList = new List <Associated_Programs_Vendors__c>();
    public boolean isVendorRendered{get; set;}
    public boolean buttonRendered {get; set;}
    public String messageText {get; set;}
    public String duplicateRecord {get; set;}
    
    public VFCntrlr_OutLookForeCast(ApexPages.StandardController controller) {
        this.myOutLookForeCasts = (Outlook_Forecast__c)controller.getRecord();
        isVendorRendered = false;
        buttonRendered = true;
        
         Outlook_Forecast_Line_Item__c outLookForcastLineItemObj;
        
        //mPList = [Select Id,Name,Vendor__c from Marketing_Plan__c where Contract_Type__c=:'Volume Based'];
        //apvList = [Select Id,Name,Status__c,POP_Status__c,Marketing_Plan__r.Contract_Type__c,Vendor__c from Associated_Programs_Vendors__c where Marketing_Plan__r.Contract_Type__c =:'Volume Based' and (Status__c =: 'Pending' OR Status__c =: 'Signed') and (POP_Status__c ='Pending' OR POP_Status__c ='Executed')];
        
        //if(apvList.size()>0){
            for(Associated_Programs_Vendors__c apv:[Select Id,Name,Status__c,POP_Status__c,Marketing_Plan__r.Contract_Type__c,Vendor__c 
                                                    From Associated_Programs_Vendors__c 
                                                    Where Marketing_Plan__r.Contract_Type__c =:'Volume Based' 
                                                    And (Status__c =: 'Pending' OR Status__c =: 'Signed') 
                                                    And (POP_Status__c ='Pending' OR POP_Status__c ='Executed')]){
                        vendorIds.add(apv.Vendor__c);
            }
        //}  
            if(vendorIds.size()>0)
            vendorList= [Select Id,Name from Vendor__c where Is_this_a_Parent_Vendor__c=:False AND Partner_Status__c=:'Active' AND Id in:vendorIds order by Name];
          
        if(vendorList.size()>0){
                //isVendorRendered = true;
                //buttonRendered = false;               
               for(Vendor__c vndorObj:vendorList){
                    outLookForcastLineItemObj = new Outlook_Forecast_Line_Item__c(Vendor__c=vndorObj.Id);
                    outLookForcastLineItemList.add(outLookForcastLineItemObj);
                }
            }
        
    }
    
    public void showVendors(){            
            if(vendorList.size()>0){
                isVendorRendered = true;
                buttonRendered = false;             
            }
        
        if(outLookForcastLineItemList.size()==0)
          messageText = 'No Vendors Found';
    }
    
    //To get the vendor list
    public List <Outlook_Forecast_Line_Item__c> getoutLookForcastLineItemList(){
        
        return outLookForcastLineItemList;
    }
    
    public Set <Id> getvendorIds(){
        return vendorIds;
    }
    
    public PageReference saveOutLookForeCastLineItem(){
        //To catch the Validation on Outlook Forecast
        
       
        String errors;      
        Database.SaveResult sr = Database.insert(myOutLookForeCasts,false);
        
        if(sr.isSuccess()){
        
            Id myOutLookForeCastsId = myOutLookForeCasts.Id;            
            String urlString = '/'+myOutLookForeCastsId;
            
            for(Outlook_Forecast_Line_Item__c obj:outLookForcastLineItemList){
                obj.Outlook_Forecast__c = myOutLookForeCastsId;
            }           
            insert outLookForcastLineItemList; 
            duplicateRecord = null;             
            return new PageReference(urlString);
        }
        
        else{   
            buttonRendered = true;
            isVendorRendered = false;
            Database.Error err = sr.getErrors()[0];
            String errormessage = err.getMessage();
            if(errormessage.contains('duplicate value found')){
                duplicateRecord = 'OutLoook Forecast already exists in this Category for this Region and Fiscal Quarter';
            }
            else
                duplicateRecord = err.getMessage();
            
            return null;
        }
    }
}