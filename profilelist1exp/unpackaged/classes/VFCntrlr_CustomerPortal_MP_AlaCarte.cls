/*
History:
Version Date            Modified By    Release    CR#        Description
--------------------------------------------------------------------------------------
1.0      24-FEB-2011    Ranjini                              Created for contract management module of VIPER-I
2.1      21-Jun-2011    Ranjini                              updated for CR :6307,6308,6286,6294 . VIPER -II
3.0      04-Dec-2012    Sheeba                    CR7739     Viper – Fix Contract Status & Status Reason when Vendor declines APV’s
4.0      17-Apr-2013    Saurabh       14.5        8171       “Accept All & Save” and “Reject All & Save” buttons in
                                                              Viper customer portal should work as expected.
*/



public class VFCntrlr_CustomerPortal_MP_AlaCarte {

    public Marketing_Plan__c MktgPlan {get; set;}
    public List <Associated_Programs_Vendors__c> apvList = new List <Associated_Programs_Vendors__c>{};
    public List <Associated_Programs_Vendors__c> updateapvList = new List <Associated_Programs_Vendors__c>{};  // for BR 008 in Release 14.5
    public List <Package__c> pkgList = new List <Package__c>{};
    public List <Associated_Programs_Vendors__c> apvListbutton {get; set;}
    public List <Package__c> pkgListbutton {get; set;}
    public boolean purchaseorder_render {get; set;}
    public List<pkgListDetails> pkgDetail {get;set;}    ////for Grouping of APVs
    public boolean isError {get; set;}
    public boolean renderButton {get; set;}
    public VFCntrlr_CustomerPortal_MP_AlaCarte(ApexPages.StandardController controller) {

      this.MktgPlan = (Marketing_Plan__c)controller.getRecord();
      if(MktgPlan.Primary_Marketing_Contact_Name__c==null ||MktgPlan.Billing_Contact_Name__c==null){
        renderButton = false;
        }
        else
        {
          renderButton = true;
        }
      apvList = [SELECT Id,Name,Marketing_Plan__c,MDF_Program__c,Budgeted_Price__c,APV_Status__c,Status__c,Accounting_Treatment__c,
                 MDF_Program__r.Name,MDF_Program__r.Business_Segment__c,
                 MDF_Program__r.Fiscal_Quarter__c,MDF_Program__r.Program_Owner__c,
                 MDF_Program__r.Email__c,MDF_Program__r.Phone__c,MDF_Program__r.Audience_Description__c,
                 MDF_Program__r.Audience_Size__c,MDF_Program__r.Program_Objective__c,MDF_Program__r.Program_Detail__c,
                 POP_Status__c,POP_Status_Reason__c,MDF_Program__r.POP_Details__c,MDF_Program__r.Vendor_Materials_Needed__c,
                 MDF_Program__r.Region__c,MDF_Program__r.Detailed_Job_Description__c,MDF_Program__r.Sub_Region__c,MDF_Program__r.Country__c,
                 MDF_Program__r.RecordType.Name,MDF_Program__r.Event_Date__c,MDF_Program__r.Preferred_Program__c,Program_Notes__c
                 FROM Associated_Programs_Vendors__c
                 WHERE Marketing_Plan__c=:MktgPlan.Id and (Status__c=:'Submitted for Review' or Status__c=:'Accepted' or (Status__c=:'Declined'AND Contract_Status_Reason__c!='Declined by Product Manager'))and Package__c=:null and MDF_Program__r.Preferred_Program__c=:False];
      if(apvList.size()>0)
      apvListbutton = [SELECT Id FROM Associated_Programs_Vendors__c WHERE Id IN :apvList and Status__c=:'Submitted for Review'];
      // Added for BR 08 ,CR 8171 in Release 14.5
      updateapvList = [SELECT Id FROM Associated_Programs_Vendors__c WHERE Marketing_Plan__c=:MktgPlan.Id and Status__c=:'Submitted for Review'];
      // End BR 08 ,CR 8171
      pkgList = [SELECT Id,Name,Fiscal_Quarter__c,Status__c,PKG_Status__c,Package_Price_del__c
                 FROM Package__c
                 WHERE Marketing_Plan__c=:MktgPlan.Id and (Status__c=:'Submitted for Review' or Status__c=:'Accepted' or Status__c=:'Declined')];
        //for Grouping of APVs
          if(pkgList.size()>0){
        pkgListbutton = [SELECT Id FROM Package__c WHERE Id IN :pkgList and Status__c=:'Submitted for Review'];
        pkgDetail = new List<pkgListDetails>();
        for(Package__c listobj : pkgList){
            pkgDetail.add(new pkgListDetails(listobj));
        }
          }//for Grouping of APVs

      purchaseorder_render = true;


    }// End of Constructor

    //for Grouping of APVs
    public class pkgListDetails{

        public Package__c packageObj{get;set;}
        public Package__c parentPackagelist{get;set;}
        public string packageName{get;set;}
        public string packageFiscalQuarter{get;set;}
        public List <Associated_Programs_Vendors__c> packageapvList {get; set;}

        public pkgListDetails(Package__c pkg){
           packageObj = pkg;
           packageapvList = [SELECT Id,Name,Package__c,Package__r.Name,Package__r.Fiscal_Quarter__c,Marketing_Plan__c,
                             MDF_Program__c,Budgeted_Price__c,APV_Status__c,Status__c,Accounting_Treatment__c,
                             MDF_Program__r.Name,MDF_Program__r.Business_Segment__c,
                             MDF_Program__r.Fiscal_Quarter__c,MDF_Program__r.Program_Owner__c,
                             MDF_Program__r.Email__c,MDF_Program__r.Phone__c,MDF_Program__r.Audience_Description__c,POP_Status__c,POP_Status_Reason__c,
                             MDF_Program__r.Audience_Size__c,MDF_Program__r.Program_Objective__c,MDF_Program__r.Program_Detail__c,
                             MDF_Program__r.POP_Details__c,MDF_Program__r.Vendor_Materials_Needed__c,MDF_Program__r.Region__c,MDF_Program__r.Detailed_Job_Description__c,
                             MDF_Program__r.Sub_Region__c,MDF_Program__r.Country__c,MDF_Program__r.RecordType.Name,MDF_Program__r.Event_Date__c,Program_Notes__c
                             FROM Associated_Programs_Vendors__c
                             WHERE Package__c =: pkg.Id];

          packageName = pkg.Name;
          packageFiscalQuarter = pkg.Fiscal_Quarter__c;
        }
    }//for Grouping of APVs

    //Adding Primary Contact
    public PageReference addPrimaryContact(){
        String urlString = '/apex/add_Primary_Contact?id='+MktgPlan.Id;
        return new PageReference(urlString);
    }

    //Adding Billing Contact
    public PageReference addBillingContact(){
        String urlString = '/apex/add_Billing_Contact?id='+MktgPlan.Id;
        return new PageReference(urlString);
    }

    public List <Associated_Programs_Vendors__c> getApvList(){
        return apvList;
    }

    public List <Package__c> getpkgList(){
        return pkgList;
    }

    public PageReference savePKG(){
        boolean toupdate;
        if(MktgPlan.Primary_Marketing_Contact_Name__c==null ||MktgPlan.Billing_Contact_Name__c==null){
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
                PageReference p = new PageReference('/apex/CustomerPortal_MarketingPlan_AlaCarte?id='+MktgPlan.Id);
                p.setRedirect(true);
                return p;
            }
            else{
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,Label.VIPER_fill_all_pkg_status));
                return null;
            }
        }

    }//Accepting or rejecting the package

    public PageReference saveAPV(){
        boolean toupdate;
        if(MktgPlan.Primary_Marketing_Contact_Name__c==null ||MktgPlan.Billing_Contact_Name__c==null){
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
                    if(apvObj.APV_Status__c == 'Accept'){
                        apvObj.Status__c = 'Accepted';
                    }
                    //Rev 3.0 CR7739 - Changes Start
                    if(apvObj.APV_Status__c == 'Decline'){
                        apvObj.Status__c = 'Declined';
                        apvObj.Contract_Status_Reason__c = 'Declined by Vendor';
                    }
                    toupdate = true;
                    //Rev 3.0 CR7739 - Changes End
                }
            }
             }
            if(toupdate==true){
                update apvList;
                PageReference p = new PageReference('/apex/CustomerPortal_MarketingPlan_AlaCarte?id='+MktgPlan.Id);
                p.setRedirect(true);
                return p;
            }
            else{
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,Label.VIPER_fill_all_apv_status));
                return null;
            }

    }//Accepting or rejecting APVs

    //Adding purchaseorder
    public PageReference addpurchaseorder(){
        purchaseorder_render = false;
        return null;
    }

    public PageReference savepruchaseorder(){
        purchaseorder_render = true;
        update MktgPlan;
        return null;
    }//Adding purchaseorder

   public PageReference cancelfn(){
        PageReference p = new PageReference('/apex/CustomerPortal_MarketingPlan_AlaCarte?id='+MktgPlan.Id);
        p.setRedirect(true);
        return p;
   }

   public PageReference acceptallAPV(){
        if(MktgPlan.Primary_Marketing_Contact_Name__c==null ||MktgPlan.Billing_Contact_Name__c==null){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Please make sure that the Marketing and Billing Contact information are filled before reviewing the programs and packages.'));
                isError = true;
                return null;
        }
        else{
              // Modified for BR 08, CR 8171 in Release 14.5
			 for(Package__c obj:pkgList)
             {
             	//obj.PKG_Status__c = 'Accept';
             	obj.Status__c = 'Accepted';
             }
             update pkgList; 		
              //for(Associated_Programs_Vendors__c apv:apvListbutton)
             for(Associated_Programs_Vendors__c apv:updateapvList)
                  apv.Status__c = 'Accepted';
             //update apvListbutton;
             update updateapvList;
             PageReference p = new PageReference('/apex/CustomerPortal_MarketingPlan_AlaCarte?id='+MktgPlan.Id);
             p.setRedirect(true);
             return p;
        }
   }

    public PageReference rejectallapv(){
              if(MktgPlan.Primary_Marketing_Contact_Name__c==null ||MktgPlan.Billing_Contact_Name__c==null){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Please make sure that the Marketing and Billing Contact information are filled before reviewing the programs and packages.'));
                isError = true;
                return null;
                
               }
              else{
                     //Modified for BR 08,CR 8171 in Release 14.5
					for(Package__c obj:pkgList)
		             {
		             	//obj.PKG_Status__c = 'Decline';
		             	obj.Status__c = 'Declined';
		             }
             		update pkgList;
                   //for(Associated_Programs_Vendors__c apv:apvListbutton){
                      for(Associated_Programs_Vendors__c apv:updateapvList){
                      apv.Status__c = 'Declined';
                      apv.Contract_Status_Reason__c = 'Declined by Vendor';
                 }
                 //update apvListbutton;
                   update updateapvList;
                 PageReference p = new PageReference('/apex/CustomerPortal_MarketingPlan_AlaCarte?id='+MktgPlan.Id);
                 p.setRedirect(true);
                 return p;
              }
    }

}