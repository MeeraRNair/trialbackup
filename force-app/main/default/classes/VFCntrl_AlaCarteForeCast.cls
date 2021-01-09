/*
Author: Ranjini

History:
Version Date            Modified By     Description
--------------------------------------------------------------------------------------
1.0      21-Jun-2011    Ranjini       updated for CR :6264 .VIPER -II
*/
public class VFCntrl_AlaCarteForeCast {
        public Volume_Based_Forecast__c myAFC {get; set;} 
        public boolean button_rendered{get; set;}
        //public Volume_Based_Forecast__c myAFCrecord {get; set;} 
        public boolean americas_mdf_forecast_shown{get; set;}
        public boolean emea_mdf_forecast_shown{get; set;}
        public boolean apj_mdf_forecast_shown{get; set;}
        public String regionvalueselected{get; set;}
        public Volume_Based_Forecast__c newObj;
        public List<Associated_Programs_Vendors__c> acceptedAPVList{get; set;}
        public List<Associated_Programs_Vendors__c> declinedAPVList{get; set;}
        public List<MDF_Program_Wish_List__c> wishlist{get; set;}
        public String wislistId {get;set;}
        RecordType ACFCRtId = [Select Id from RecordType where SobjectType='Volume_Based_Forecast__c' and Name ='Ala Carte'];               
        public List<SelectOption> options {get;set;}
        public TotalClass accepttotalclass{get;set;}
        public TotalClass declinedtotalclass{get;set;}
        
        public class TotalClass{
            public Decimal total_CSMR {get;set;}
            public Decimal total_LE {get;set;}
            public Decimal total_PUB {get;set;}
            public Decimal total_SMB {get;set;}
            public Decimal total_ABU_S_P {get;set;}
            public Decimal total_Global_Mktg {get;set;}
            public Decimal total_ASAP {get;set;}
            public Decimal total_CSRM_S_P {get;set;}
            public Decimal total_Corporate_Events {get;set;}
            public Decimal total_Int_l {get;set;}
            public Decimal total_SMB_Direct {get;set;}
            public Decimal total_SMB_Channel {get;set;}
            public Decimal total_All_Segments {get;set;}
            public TotalClass(List<Associated_Programs_Vendors__c> apvlist){
                total_CSMR=total_LE=total_PUB=total_SMB=total_Global_Mktg=total_ABU_S_P=total_ASAP=total_CSRM_S_P=total_Corporate_Events=total_Int_l=total_SMB_Direct=total_SMB_Channel=total_All_Segments=0;
                for(Associated_Programs_Vendors__c apv:apvlist){
                    if(apv.CSMR__c!=null)
                    total_CSMR=total_CSMR+apv.CSMR__c;
                    if(apv.LE__c!=null)
                    total_LE=total_LE+apv.LE__c;
                    if(apv.PUB__c!=null)
                    total_PUB=total_PUB+apv.PUB__c;
                    if(apv.SMB__c!=null)
                    total_SMB=total_SMB+apv.SMB__c;
                    if(apv.AlaCarte_ABU_S_P__c!=null)
                    total_ABU_S_P=total_ABU_S_P+apv.AlaCarte_ABU_S_P__c;
                    if(apv.Alacarte_Global_Mktg__c!=null)
                    total_Global_Mktg=total_Global_Mktg+apv.Alacarte_Global_Mktg__c;
                    if(apv.Alacarte_ASAP__c!=null)
                    total_ASAP=total_ASAP+apv.Alacarte_ASAP__c;
                    if(apv.AlaCarte_CSRM_S_P__c!=null)
                    total_CSRM_S_P=total_CSRM_S_P+apv.AlaCarte_CSRM_S_P__c;
                    if(apv.AlaCarte_Corporate_Events__c!=null)
                    total_Corporate_Events=total_Corporate_Events+apv.AlaCarte_Corporate_Events__c;
                    if(apv.AlaCarte_Int_l__c!=null)
                    total_Int_l=total_Int_l+apv.AlaCarte_Int_l__c;
                    if(apv.AlaCarte_SMB_Direct__c!=null)
                    total_SMB_Direct=total_SMB_Direct+apv.AlaCarte_SMB_Direct__c;
                    if(apv.AlaCarte_SMB_Channel__c!=null)
                    total_SMB_Channel=total_SMB_Channel+apv.AlaCarte_SMB_Channel__c;
                    if(apv.AlaCarte_All_Segments__c!=null)
                    total_All_Segments=total_All_Segments+apv.AlaCarte_All_Segments__c;
                        
                }
            }
        }
        public VFCntrl_AlaCarteForeCast(ApexPages.StandardController controller) {
            this.myAFC= (Volume_Based_Forecast__c)controller.getRecord(); 
            if(myAFC.Id!=null){
                    acceptedAPVList = PlanBreakOutUpdate.get_apv_list(myAFC,'Pending');
                    if(acceptedAPVList.size()>0)
                        accepttotalclass=new TotalClass(acceptedAPVList);
                    declinedAPVList = PlanBreakOutUpdate.get_apv_list(myAFC,'Declined');
                    if(declinedAPVList.size()>0)
                        declinedtotalclass=new TotalClass(declinedAPVList);
                    wishlist = PlanBreakOutUpdate.get_wish_list(myAFC);
                    if(myAFC.Region__c=='Americas'){
                        americas_mdf_forecast_shown = true;
                        emea_mdf_forecast_shown = false;
                        apj_mdf_forecast_shown = false;
                    }
                    if(myAFC.Region__c=='EMEA'){
                        emea_mdf_forecast_shown = true;
                        americas_mdf_forecast_shown = false;
                        apj_mdf_forecast_shown = false;                          
                    }
                    if(myAFC.Region__c=='APJ'){
                        apj_mdf_forecast_shown = true;
                        emea_mdf_forecast_shown = false;
                        americas_mdf_forecast_shown = false;
                          
                    }
                    button_rendered = true;
            }
            else
            {
                // Aman Sharma 25 June,13 CR 8393 Monthly Maintenance SPRINT 2
                this.myAFC.Region__c='';
                button_rendered = true;
                // Code End CR 8393 Monthly Maintenance SPRINT 2
            }
        }
    
        public PageReference saveFC(){
            //button_rendered = true;
            Database.SaveResult result;
            if(myAFC.Id==null){
                newObj = new Volume_Based_Forecast__c(Name=myAFC.Name,Sub_Vendor__c = myAFC.Sub_Vendor__c,Fiscal_Quarter__c = myAFC.Fiscal_Quarter__c,Region__c = myAFC.Region__c,AlaCarte_MDF_Forecast_CSMR__c = myAFC.AlaCarte_MDF_Forecast_CSMR__c,AlaCarte_MDF_Forecast_LE__c = myAFC.AlaCarte_MDF_Forecast_LE__c,AlaCarte_MDF_Forecast_PUB__c = myAFC.AlaCarte_MDF_Forecast_PUB__c,AlaCarte_MDF_Forecast_SMB__c = myAFC.AlaCarte_MDF_Forecast_SMB__c , AlaCarte_MDF_Forecast_ABU_S_P__c = myAFC.AlaCarte_MDF_Forecast_ABU_S_P__c, AlaCarte_MDF_Forecast_Global_Mktg__c=myAFC.AlaCarte_MDF_Forecast_Global_Mktg__c,AlaCarte_MDF_Forecast_ASAP__c=myAFC.AlaCarte_MDF_Forecast_ASAP__c,AlaCarte_MDF_Forecast_CSRM_S_P__c=myAFC.AlaCarte_MDF_Forecast_CSRM_S_P__c,AlaCarte_MDF_Forecast_Corporate_Events__c=myAFC.AlaCarte_MDF_Forecast_Corporate_Events__c,AlaCarte_MDF_Forecast_Intl__c =myAFC.AlaCarte_MDF_Forecast_Intl__c,AlaCarte_MDF_Forecast_SMB_Channel__c=myAFC.AlaCarte_MDF_Forecast_SMB_Channel__c,AlaCarte_MDF_Forecast_SMB_Direct__c=myAFC.AlaCarte_MDF_Forecast_SMB_Direct__c,AlaCarte_MDF_Forecast_All_Segments__c=myAFC.AlaCarte_MDF_Forecast_All_Segments__c,RecordTypeId=ACFCRtId.Id);
                result = Database.insert(newObj,false);
            } 
            else{
                newObj=myAFC;
                result = Database.update(newObj,false);
            }                
            if(result.isSuccess()){
                    String urlString = '/'+newObj.Id;
                    return new PageReference(urlString);
            }
            else{
                Database.Error err = result.getErrors()[0];
                if(err.getMessage().contains('duplicate value found')){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Ala Carte foreacst already exist for this subvnedor for this region and Fiscal Quarter.'));
                }
                return null;
            }
        } 
    
         public PageReference regionSelection(){
            
            if(regionvalueselected=='Americas'){
                    americas_mdf_forecast_shown = true;
                    emea_mdf_forecast_shown = false;
                    apj_mdf_forecast_shown = false;
            }
            if(regionvalueselected=='EMEA'){
                    emea_mdf_forecast_shown = true;
                    americas_mdf_forecast_shown = false;
                    apj_mdf_forecast_shown = false;
                   
            }
            if(regionvalueselected=='APJ'){
                    apj_mdf_forecast_shown = true;
                    emea_mdf_forecast_shown = false;
                    americas_mdf_forecast_shown = false;
                  
            }
            if(regionvalueselected==''){
                    apj_mdf_forecast_shown = false;
                    emea_mdf_forecast_shown = false;
                    americas_mdf_forecast_shown = false;
                  
            }
            button_rendered = true;
            return null;
            
        }  
            
        public PageReference newWishlist(){
            String urlString = '/apex/AddWishListPage?FC='+myAFC.Id+'&retURL=%2F'+myAFC.Id;
            return new PageReference(urlString);
        } 
        
        public PageReference deleteWishlist(){
            MDF_Program_Wish_List__c wishlistrec = [Select Id from MDF_Program_Wish_List__c where Id=:wislistId];
            delete wishlistrec;
            return new PageReference('/'+myAFC.Id);
            
        }

}