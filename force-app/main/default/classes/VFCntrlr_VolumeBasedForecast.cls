/*
Author: Ranjini

History:
Version Date            Modified By     Description
--------------------------------------------------------------------------------------
1.0      24-FEB-2011    Ranjini       Created for Partner Management module of VIPER-I
2.0      21-Jun-2011    Ranjini       updated for CR :6264 .VIPER -II
*/

public class VFCntrlr_VolumeBasedForecast {

    public Volume_Based_Forecast__c myVBFrec {get; set;} 
   // public Volume_Based_Forecast__c myVBF {get; set;}   
    public Volume_Based_Forecast__c newObj;
    public Volume_Based_Forecast__c vbfQueryobj=new Volume_Based_Forecast__c();    
    public boolean availableMDFRendered {get; set;}
    public boolean saveButtonRendered {get; set;}
    public boolean editrendercontrol{get;set;}
    public String duplicateRecord {get; set;}
    public List<Associated_Programs_Vendors__c> acceptedAPVList{get; set;}
    public List<Associated_Programs_Vendors__c> declinedAPVList{get; set;}
    public String wislistId {get;set;}
    public List<MDF_Program_Wish_List__c> wishlist{get; set;}
   
    public sumClass totalobj {get;set;}
    public sumClass totalobjdeclined {get;set;}
    public class sumClass{
        public Decimal total_CSMR {get;set;}
    	public Decimal total_LE {get;set;}
        public Decimal total_PUB {get;set;}
        public Decimal total_SMB {get;set;}
        public Decimal total_BP{get;set;}
        public sumClass(List<Associated_Programs_Vendors__c> apvlist){
	        total_CSMR=total_LE=total_PUB=total_SMB=total_BP=0;
	        for(Associated_Programs_Vendors__c apv:apvlist){
	                if(apv.CSMR__c!=null)
	                total_CSMR=total_CSMR+apv.CSMR__c;
	                if(apv.LE__c!=null)
	                total_LE=total_LE+apv.LE__c;
	                if(apv.PUB__c!=null)
	                total_PUB=total_PUB+apv.PUB__c;
	                if(apv.SMB__c!=null)
	                total_SMB=total_SMB+apv.SMB__c;
	                if(apv.Budgeted_Price__c!=null)
	                total_BP=total_BP+apv.Budgeted_Price__c;
	        }
        }
    }
    public VFCntrlr_VolumeBasedForecast(ApexPages.StandardController controller) {
    
        this.myVBFrec= (Volume_Based_Forecast__c)controller.getRecord(); 
        if(myVBFrec.Id!=null){           
            acceptedAPVList = PlanBreakOutUpdate.get_apv_list(myVBFrec,'Pending');
            if(acceptedAPVList.size()>0)
                totalobj=new sumClass(acceptedAPVList);
            declinedAPVList = PlanBreakOutUpdate.get_apv_list(myVBFrec,'Declined');
            if(declinedAPVList.size()>0)
                totalobjdeclined=new sumClass(declinedAPVList);
            wishlist = PlanBreakOutUpdate.get_wish_list(myVBFrec);
            saveButtonRendered = false; 
            editrendercontrol = true;
        }                        
        availableMDFRendered =  false;
        saveButtonRendered = true;
        duplicateRecord=null;
  
    }

        
    public PageReference saveObj(){
        Database.SaveResult sr_Insert;
        if(myVBFrec.Id==null){
                newObj = new Volume_Based_Forecast__c(Sub_Vendor__c = myVBFrec.Sub_Vendor__c,Fiscal_Quarter__c = myVBFrec.Fiscal_Quarter__c,Region__c = myVBFrec.Region__c,Volume_Based__c = myVBFrec.Volume_Based__c,Volume_Based_Forecast_filed__c=myVBFrec.Volume_Based_Forecast_filed__c,LE__c=myVBFrec.LE__c,PUB__c=myVBFrec.PUB__c,SMB__c=myVBFrec.SMB__c,CSMR__c=myVBFrec.CSMR__c,Name=myVBFrec.Name);       
                sr_Insert = Database.insert(newObj,false);
        }
        else{           
            newObj = myVBFrec;                   
                sr_Insert = Database.update(newObj,false);
        }
        
       if(sr_Insert.isSuccess()){               
            //availableMDFRendered = true;        
            vbfQueryobj=[Select Id,Available_MDF_CSMR__c,Available_MDF_LE__c,Available_MDF_PUB__c,Available_MDF_SMB__c,MDF_Forecast_CSMR__c,MDF_Forecast_LE__c,MDF_Forecast_PUB__c,MDF_Forecast_SMB__c,MDF_Forecast_Total__c,Forecast_Difference_CSMR__c,Forecast_Difference_LE__c,Forecast_Difference_PUB__c,Forecast_Difference_SMB__c,Forecast_Difference_Total__c,Plan_Breakout_CSMR__c,Plan_Breakout_LE__c,Plan_Breakout_PUB__c,Plan_Breakout_SMB__c,Plan_Breakout_Total__c,Outlook_1_CSMR__c,Outlook_1_LE__c,Outlook_1_PUB__c,Outlook_1_SMB__c,Outlook_1_Total__c,Outlook_1_Difference_CSMR__c,Outlook_1_Difference_LE__c,Outlook_1_Difference_PUB__c,Outlook_1_Difference_SMB__c,Outlook_1_Difference_Total__c,Outlook_2_CSMR__c,Outlook_2_LE__c,Outlook_2_PUB__c,Outlook_2_SMB__c,Outlook_2_Difference_CSMR__c,Outlook_2_Difference_LE__c,Outlook_2_Difference_PUB__c,Outlook_2_Difference_SMB__c,Outlook_2_Difference_Total__c,Final_Difference_CSMR__c,Final_Difference_LE__c,Final_Difference_PUB__c,Final_Difference_SMB__c,Final_Difference_Total__c,Final_Outlook_CSMR__c,Final_Outlook_LE__c,Final_Outlook_PUB__c,Final_Outlook_SMB__c,Invoice_Amount_CSMR__c,Invoice_Amount_LE__c,Invoice_Amount_PUB__c,Invoice_Amount_SMB__c,Invoice_Amount_Total__c,Total_MDF_Forecast__c,Final_Outlook_Total__c,Outlook_2_Total__c from Volume_Based_Forecast__c where Id =:newObj.Id];         
            //saveButtonRendered = false;       
            //myVBFrec.Total_MDF_Forecast__c = vbfQueryobj.Total_MDF_Forecast__c; 
            duplicateRecord = null;
            String urlString = '/'+ vbfQueryobj.Id;  
            return new Pagereference(urlString);           
       }
       else{
            Database.Error err = sr_Insert.getErrors()[0];
            String errormessage = err.getMessage();
            if(errormessage.contains('duplicate value found: VBF_Unique_Field__c')){
                duplicateRecord = 'Volume Based Forecast already exists for the Sub Vendor for this Region and Fiscal Quarter';
            }
            else
                duplicateRecord = err.getMessage();
            return null;
        }       
    }
    
    /*public PageReference updateObj(){
        
        Volume_Based_Forecast__c updateOject = [Select Id,Sub_Vendor__c,Fiscal_Quarter__c,Region__c,Volume_Based__c,Volume_Based_Forecast_filed__c,LE__c,PUB__c,SMB__c,CSMR__c,Total_MDF_Forecast__c from Volume_Based_Forecast__c where Id =:newObj.Id];
        
        //system.debug('Total MDF Forecast'+myVBF.Total_MDF_Forecast__c);       
        updateOject.Sub_Vendor__c = myVBF.Sub_Vendor__c;
        updateOject.Fiscal_Quarter__c = myVBF.Fiscal_Quarter__c;
        updateOject.Volume_Based__c = myVBF.Volume_Based__c;
        updateOject.Volume_Based_Forecast_filed__c = myVBF.Volume_Based_Forecast_filed__c;
        
        //system.debug('myVBF.LE__c'+myVBF.LE__c);      
        updateOject.LE__c = myVBF.LE__c;
        updateOject.CSMR__c = myVBF.CSMR__c;
        updateOject.PUB__c = myVBF.PUB__c;
        updateOject.SMB__c = myVBF.SMB__c;
        
        //system.debug('Total MDF Forecast'+myVBF.Total_MDF_Forecast__c);       
        updateOject.Total_MDF_Forecast__c = myVBF.Total_MDF_Forecast__c;
                
        //update updateOject;           
        Database.SaveResult sr_Update = Database.update(updateOject,false);
        
        if(sr_Update.isSuccess()){
        
                vbfQueryobj=[Select Id,Available_MDF_CSMR__c,Available_MDF_LE__c,Available_MDF_PUB__c,Available_MDF_SMB__c,MDF_Forecast_CSMR__c,MDF_Forecast_LE__c,MDF_Forecast_PUB__c,MDF_Forecast_SMB__c,MDF_Forecast_Total__c,Forecast_Difference_CSMR__c,Forecast_Difference_LE__c,Forecast_Difference_PUB__c,Forecast_Difference_SMB__c,Forecast_Difference_Total__c,Plan_Breakout_CSMR__c,Plan_Breakout_LE__c,Plan_Breakout_PUB__c,Plan_Breakout_SMB__c,Plan_Breakout_Total__c,Outlook_1_CSMR__c,Outlook_1_LE__c,Outlook_1_PUB__c,Outlook_1_SMB__c,Outlook_1_Total__c,Outlook_1_Difference_CSMR__c,Outlook_1_Difference_LE__c,Outlook_1_Difference_PUB__c,Outlook_1_Difference_SMB__c,Outlook_1_Difference_Total__c,Outlook_2_CSMR__c,Outlook_2_LE__c,Outlook_2_PUB__c,Outlook_2_SMB__c,Outlook_2_Difference_CSMR__c,Outlook_2_Difference_LE__c,Outlook_2_Difference_PUB__c,Outlook_2_Difference_SMB__c,Outlook_2_Difference_Total__c,Final_Difference_CSMR__c,Final_Difference_LE__c,Final_Difference_PUB__c,Final_Difference_SMB__c,Final_Difference_Total__c,Final_Outlook_CSMR__c,Final_Outlook_LE__c,Final_Outlook_PUB__c,Final_Outlook_SMB__c,Invoice_Amount_CSMR__c,Invoice_Amount_LE__c,Invoice_Amount_PUB__c,Invoice_Amount_SMB__c,Invoice_Amount_Total__c,Total_MDF_Forecast__c,Final_Outlook_Total__c,Outlook_2_Total__c from Volume_Based_Forecast__c where Id =:updateOject.Id];             
                myVBF.Total_MDF_Forecast__c = vbfQueryobj.Total_MDF_Forecast__c; // To display the updated value in the page
                 duplicateRecord = null;                
        }
        else{
                Database.Error err = sr_Update.getErrors()[0];
                String errormessage = err.getMessage();
                if(errormessage.contains('duplicate value found: VBF_Unique_Field__c')){
                        duplicateRecord = 'Volume Based Forecast already exists for the Sub Vendor for this Region and Fiscal Quarter';
                }
                else
                duplicateRecord = err.getMessage();
        }
        
        return null;
    }*/
    
    public Volume_Based_Forecast__c getNewObj(){               
        return vbfQueryobj;        
    }
    
    /*public PageReference done(){
        
        Id myVBFCId = vbfQueryobj.Id;
        String urlString = '/'+myVBFCId;
        return new PageReference(urlString);
    }*/
    
    public PageReference redirect(){
        String recSelcted=ApexPages.currentPage().getParameters().get('RecordType');
        String recId = ApexPages.currentPage().getParameters().get('id');
        String subvendorname=pageUtils.encodeVariable(ApexPages.currentPage().getParameters().get('CF00NA00000063PkM')); 
        String subvendorId=ApexPages.currentPage().getParameters().get('CF00NA00000063PkM_lkid');       
        String urlString;
        RecordType vbFCRT;
        if(recSelcted!=null)
                vbFCRT = [Select Id,Name from RecordType where sObjectType ='Volume_Based_Forecast__c'and isActive=true and Id=:recSelcted];
        else if(recId!=null){
                Volume_Based_Forecast__c vbcrec= [select Id,RecordTypeId,Sub_Vendor__c,Region__c,Fiscal_Quarter__c from Volume_Based_Forecast__c where Id=:recId];
                vbFCRT = [Select Id,Name from RecordType where sObjectType ='Volume_Based_Forecast__c'and isActive=true and Id=:vbcrec.RecordTypeId];
        }
        if(vbFCRT.Name=='Ala Carte'){
            if(recId!=null)
                urlString = '/apex/alacarteForeCastNewpage?id='+recId;
            else 
                urlString = '/apex/alacarteForeCastNewpage?CF00NA00000063PkM='+subvendorname+'&CF00NA00000063PkM_lkid='+subvendorId+'&sfdc.override=1';
            return new PageReference(urlString);
        }
        else return null;
    }
     
     public PageReference redirectViewPage(){
        String recordId=ApexPages.currentPage().getParameters().get('id');
        Volume_Based_Forecast__c recordFC = [Select Id,RecordTypeId from Volume_Based_Forecast__c where Id=:recordId];
        String urlString;
        
        RecordType vbFCRT = [Select Id,Name from RecordType where sObjectType ='Volume_Based_Forecast__c'and isActive=true and Id=:recordFC.RecordTypeId];
        if(vbFCRT.Name=='Ala Carte'){
            urlString = '/apex/alacarteForeCastViewpage?id='+recordFC.Id;
            return new PageReference(urlString);
        }
        else if(vbFCRT.Name=='Volume Based'){
            return null;
        }        
        else return null;   
     }
     
     public PageReference deleteWishlist(){
                MDF_Program_Wish_List__c wishlistrec = [Select Id from MDF_Program_Wish_List__c where Id=:wislistId];
                delete wishlistrec;
                return new PageReference('/'+myVBFrec.Id);                
            }
         public PageReference newWishlist(){
            String urlString = '/apex/AddWishListPage?FC='+myVBFrec.Id+'&retURL=%2F'+myVBFrec.Id;
            return new PageReference(urlString);
        } 


}