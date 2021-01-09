/*
History:
Version Date            Modified By     Release      CR#         Description
--------------------------------------------------------------------------------------
1.0      24-FEB-2011    Ranjini                                 Created for contract management module of VIPER-I
2.1      21-Jun-2011    Ranjini                                 updated for CR :6307,6308,6286,6294 . VIPER -II
3.0      04-Dec-2012    Sheeba                      CR7739                  Viper – Fix Contract Status & Status Reason when Vendor declines APV’s
4.0      15-Apr-2013    Saurabh        14.5         CR8171        “Accept All & Save” and “Reject All & Save” buttons in
                                                                Viper customer portal should work as expected. 
*/




public class VFCntrlr_CustomerPortal_MarketingPlan {
    
    public Marketing_Plan__c myMP {get; set;}
    public Marketing_Plan__c mrktinPlan = new Marketing_Plan__c();
    public List <Associated_Programs_Vendors__c> apvList = new List <Associated_Programs_Vendors__c>{};
    public List <Associated_Programs_Vendors__c> updateapvList = new List <Associated_Programs_Vendors__c>{};  // for BR 008 in Release 14.5
    public List <Associated_Programs_Vendors__c> apvbuttonlist {get; set;}
    public List <Package__c> pkgbuttonlist {get; set;}
    public List <Package__c> pkgList =  new List <Package__c>{};          
    public List<pkgListDetails> pkgDetail {get;set;}  
    public boolean purchaseorder_render{get;set;}  //for grouping of APVs  
    public List <Volume_Based_Rule_Line_Item__c> VBHLineItemList = new List <Volume_Based_Rule_Line_Item__c>{};
    public boolean isError {get; set;}   
    public boolean renderButton {get; set;} 
    public VFCntrlr_CustomerPortal_MarketingPlan(ApexPages.StandardController controller) {
        
        this.myMP = (Marketing_Plan__c)controller.getRecord();
        mrktinPlan=[SELECT id,Contract_Status__c,Contract_Type__c,Fiscal_Quarter__c,
                    Invoice__c,Invoice_Amount__c,Purchase_Order__c,Rebate_Rule_Header__c,
                    Region__c,Term__c,Vendor__c,Vendor__r.name,Volume_Based_Rule_Header__c,
                    Vendor__r.Budgeted_Discount__c,Sub_Region__c,OwnerId            
                    FROM Marketing_Plan__c 
                    WHERE id=:controller.getId()];
        if(myMP.Primary_Marketing_Contact_Name__c==null ||myMP.Billing_Contact_Name__c==null){
        renderButton = false;
        }
        else
        {
          renderButton = true;
        }
        
        VfCtrl_ViperSOQLMethod_Utility ViperSOQLMethod= new VfCtrl_ViperSOQLMethod_Utility();
        apvList = database.query(ViperSOQLMethod.getQueryMethod2(new Associated_Programs_Vendors__c(),'VFCntrlr_CustomerPortal_MarketingPlan') +
                ' where Marketing_Plan__c=\''+myMP.Id+'\' and (Status__c=\'Submitted for Review\' or Status__c=\'Accepted\' or (Status__c=\'Declined\' AND Contract_Status_Reason__c!=\'Declined by Product Manager\'))and Package__c=null and MDF_Program__r.Preferred_Program__c=False ');
             
        if(apvList.size()>0)
           apvbuttonlist = [SELECT Id FROM Associated_Programs_Vendors__c WHERE Id IN :apvList and Status__c=:'Submitted for Review'];
        // Added for BR 08,CR 8171 in Release 14.5
             updateapvList = [SELECT Id FROM Associated_Programs_Vendors__c WHERE Marketing_Plan__c=:myMP.Id and Status__c=:'Submitted for Review'];
             system.debug('updateapvList---------' +updateapvList);
        // End BR 08,CR 8171    
        pkgList = [SELECT Id,Name,Fiscal_Quarter__c,Package_Price_del__c,Status__c,PKG_Status__c 
                   FROM Package__c WHERE Marketing_Plan__c=:myMP.Id and (Status__c=:'Submitted for Review' or Status__c=:'Accepted' or Status__c=:'Declined')];                     
        if(myMP.Volume_Based_Rule_Header__c!=null)
            VBHLineItemList = [SELECT Id,Name,Category__c,Class_SubClass__c,Include_Exclude__c,Business_Segment__c,Manufacturer__c,Accrual__c,Amount_Per_Unit__c,Volume_Based_Rule_Header__c 
                               FROM Volume_Based_Rule_Line_Item__c WHERE Volume_Based_Rule_Header__c=:mrktinPlan.Volume_Based_Rule_Header__c];
            
        purchaseorder_render = true;
        // for grouping of APVs
        if(pkgList.size()>0){
                pkgbuttonlist = [SELECT Id FROM Package__c WHERE Id IN :pkgList and Status__c=:'Submitted for Review'];
            pkgDetail = new List<pkgListDetails>();
            for(Package__c listobj : pkgList){
                pkgDetail.add(new pkgListDetails(listobj));
            }
        }// for grouping of APVs    
        
        
    }//end of constructor
            
    //approve /reject Apvs
    
    public PageReference accept_decline_APV(){
        boolean toupdate;        
        if(myMP.Primary_Marketing_Contact_Name__c==null ||myMP.Billing_Contact_Name__c==null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Please make sure that the Marketing and Billing Contact information are filled before reviewing the programs and packages.'));            
            isError = true;
            return null;
        }        
        else{  
        
                        for(Associated_Programs_Vendors__c apvObj:apvList){                     
                        if(apvObj.APV_Status__c == null){                               
                                toupdate = false;
                                break;                  
                        }
                        else{
                        //Rev 3.0 CR7739 - Changes Start
                            if(apvObj.APV_Status__c == 'Accept'){
                                apvObj.Status__c = 'Accepted';
                            }
                            if(apvObj.APV_Status__c == 'Decline'){
                                apvObj.Status__c = 'Declined';
                                apvObj.Contract_Status_Reason__c = 'Declined by Vendor';
                            }
                            toupdate = true;                    
                        }
                        //Rev 3.0 CR7739 - Changes End
                }               
                     if(toupdate==true){
                        update apvList; 
                        PageReference p = new PageReference('/apex/CustomerPortal_MarketingPlan?id='+myMP.Id);
                            p.setRedirect(true);    
                            return p;                   
                     }                          
                     else{
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,Label.VIPER_fill_all_apv_status));
                        return null;
                     }                          
        }
    }
    
    public List <Associated_Programs_Vendors__c> getApvList(){
        return apvList;
    }
    
    public List <Package__c> getPkgList(){
        return pkgList;
    }
    
    public List <Volume_Based_Rule_Line_Item__c> getVBHLineItemList(){
        return VBHLineItemList;
    }
    
    //----------for grouping of APVs
    public class pkgListDetails{

        public Package__c packageObj{get;set;}
        public Package__c parentPackagelist{get;set;}
        public string packageName{get;set;}
        public string packageFiscalQuarter{get;set;}
        public List <Associated_Programs_Vendors__c> packageapvList {get; set;}
        
        public pkgListDetails(Package__c pkg){

           packageObj = pkg; 
           
           VfCtrl_ViperSOQLMethod_Utility ViperSOQLMethod= new VfCtrl_ViperSOQLMethod_Utility();
           packageapvList = database.query(ViperSOQLMethod.getQueryMethod2(new Associated_Programs_Vendors__c(),'VFCntrlr_CustomerPortal_MarketingPlan') +' where Package__c =\''+pkg.Id+'\'');
          
           packageName = pkg.Name;
           packageFiscalQuarter = pkg.Fiscal_Quarter__c;
        }
    }//----------for grouping
    
    public PageReference savePKG(){
        boolean toupdate;
        if(myMP.Primary_Marketing_Contact_Name__c==null ||myMP.Billing_Contact_Name__c==null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Please make sure that the Marketing and Billing Contact information are filled before reviewing the programs and packages.'));
            return null;
        }
        else{  
                for(Package__c obj:pkgList){            
                    if(obj.PKG_Status__c == null){
                                toupdate = false;
                                break;                  
                                }
                        else{
                            if(obj.PKG_Status__c == 'Accept'){
                                obj.Status__c = 'Accepted';
                            }
                            if(obj.PKG_Status__c == 'Decline'){
                                obj.Status__c = 'Declined';
                            }
                            toupdate = true;                    
                        }       
                }       
                if(toupdate==true){
                        update pkgList; 
                        PageReference p = new PageReference('/apex/CustomerPortal_MarketingPlan?id='+myMP.Id);
                            p.setRedirect(true);    
                            return p;                   
                    }                           
                    else{
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,Label.VIPER_fill_all_pkg_status));
                        return null;
                    }    
        }
    }//to accpet/reject packages
    
    
    //to add_Primary_Contact VF Page
    
    public PageReference addPrimaryContact(){
        String urlString = '/apex/add_Primary_Contact?id='+myMP.Id;
        return new PageReference(urlString);
    }
    
    //to add billing contact
    public PageReference addBillingContact(){
        String urlString = '/apex/add_Billing_Contact?id='+myMP.Id;
        return new PageReference(urlString);
    }
    
    //to add purchaseorder
    public PageReference addpurchaseorder(){
        purchaseorder_render = false;       
        return null;
    }
    
    public PageReference savepruchaseorder(){
        purchaseorder_render = true;        
        update myMP;
        return null;
    }//to add purchaseorder
    
    public PageReference cancelfn(){
        PageReference p = new PageReference('/apex/CustomerPortal_MarketingPlan?id='+myMP.Id);
        p.setRedirect(true);    
        return p;
   }
   public PageReference acceptallapv(){
        if(myMP.Primary_Marketing_Contact_Name__c==null ||myMP.Billing_Contact_Name__c==null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Please make sure that the Marketing and Billing Contact information are filled before reviewing the programs and packages.'));
            isError = true;
            return null;
        }
        else{
             // Modified for BR 08,CR 8171 in Release 14.5
             system.debug('updateapvList---------' +updateapvList); 
             //for(Associated_Programs_Vendors__c apv:apvbuttonlist)
             for(Package__c obj:pkgList)
             {
             	//obj.PKG_Status__c = 'Accept';
             	obj.Status__c = 'Accepted';
             }
             update pkgList; 
            for(Associated_Programs_Vendors__c apv:updateapvList)
                 apv.Status__c = 'Accepted';               
            //update apvbuttonlist;
            update updateapvList;
            PageReference p = new PageReference('/apex/CustomerPortal_MarketingPlan?id='+myMP.Id);
                p.setRedirect(true);    
                return p;
        }       
   }
   
   public PageReference rejectallapv(){
       if(myMP.Primary_Marketing_Contact_Name__c==null ||myMP.Billing_Contact_Name__c==null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Please make sure that the Marketing and Billing Contact information are filled before reviewing the programs and packages.'));
            isError = true;
            return null;
        }
        else{
            // Modified for BR 08,CR8171 in Release 14.5
                system.debug('updateapvList---------' +updateapvList);
             for(Package__c obj:pkgList)
             {
             	//obj.PKG_Status__c = 'Decline';
             	obj.Status__c = 'Declined';
             }
     		update pkgList;   
          //  for(Associated_Programs_Vendors__c apv:apvbuttonlist){
               for(Associated_Programs_Vendors__c apv:updateapvList){
                apv.Status__c = 'Declined';  
                apv.Contract_Status_Reason__c = 'Declined by Vendor'; 
             }                   
           // update apvbuttonlist;
              update updateapvList;
            PageReference p = new PageReference('/apex/CustomerPortal_MarketingPlan?id='+myMP.Id);
                p.setRedirect(true);    
                return p;
        }       
   }
}