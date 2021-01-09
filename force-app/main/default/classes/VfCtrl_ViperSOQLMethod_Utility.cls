public class VfCtrl_ViperSOQLMethod_Utility{
    
    public String QueryString1{get;set;}
    public String QueryString2{get;set;}
    public String QueryString3{get;set;}
    
    public String getQueryMethod1(sObject o, String className){ 
        
        String objType = String.valueOf(o.getSobjectType());
        
        QueryString1  = 'select ';
        
        QueryString1  += 'Id,Contract_Status__c,Contract_Type__c,Fiscal_Quarter__c,'+
                         'Invoice__c,Invoice_Amount__c,Purchase_Order__c,Rebate_Rule_Header__c,'+
                         'Region__c,Term__c,Vendor__c,Vendor__r.name,Volume_Based_Rule_Header__c,Vendor__r.Budgeted_Discount__c,'+
                         'Billing_City__c,Billing_Cell__c, Billing_Contact_Country__c,Billing_Contact_Email__c,Billing_Contact_Name__c,'+
                         'Billing_Contact_Phone__c,Billing_Contact_Title__c,Billing_State__c,Bill_To_Address__c,Billing_Zip__c,Billing_Fax__c,'+
                         'Primary_Marketing_Contact_Address__c,Primary_Marketing_Contact_Cell__c,Primary_Marketing_Contact_City__c,Primary_Marketing_Contact_State__c,'+
                         'Primary_Marketing_Contact_Title__c,Primary_Marketing_Contact_Country__c,Primary_Marketing_Contact_E_mail__c,'+
                         'Primary_Marketing_Contact_Name__c,Primary_Marketing_Contact_Phone__c,Primary_Marketing_Contact_Fax__c,Primary_Marketing_Contact_Zip__c,'+
                         'Reply_Method__c,Sub_Region__c,recordTypeId';
        
        
        if((className == 'VFCntlr_COGSOEMSOW' || className == 'VFCntlr_COGSSOW') && objType == 'Marketing_Plan__c'){
            QueryString1  += ',Marketing_Plan__c.Volume_Based_Rule_Header__r.Flat_Rate_Deduction__c,Marketing_Plan__c.Volume_Based_Rule_Header__r.Deduction_Reason__c from Marketing_Plan__c';
        }
        
        if((className == 'VFCntlr_HeadCountSOW' || className == 'VFCntlr_RebatesSOW' || className == 'VFCntrlr_NonCogsSOW' || className == 'VFCntlr_SOWHeadCountValidation' || className == 'VFCntrlr_SOWAlaCarteOEM') 
            && objType == 'Marketing_Plan__c'){
            QueryString1  += ' from Marketing_Plan__c';
        }
        
        if((className == 'SOWDefaultCtrlExt' || className == 'VFCntlr_DefaultSOW') && objType == 'Marketing_Plan__c'){
            QueryString1 = QueryString1.remove(',Reply_Method__c');
            QueryString1 = QueryString1.remove(',recordTypeId');
            QueryString1  += ',Volume_Based_Rule_Header__r.COGS__c from Marketing_Plan__c';
        }
        return QueryString1;
    }
    public String getQueryMethod2(sObject o, String className){ //, Map<String, String> lookupField
        
        String objType = String.valueOf(o.getSobjectType());
        
        QueryString2  = 'select ';
       
        QueryString2  += 'id,name,vendor__c,Status__c,POP_Status__c,'+
                         'MDF_Program__c, recordtypeId,Business_Segment__c,Marketing_Plan__c,Package__c,Region__c,Sub_Region__c,Program_Notes__c,'+
                         'MDF_Program__r.Region__c,MDF_Program__r.name,MDF_Program__r.Fiscal_Quarter__c,MDF_Program__r.Program_Objective__c,MDF_Program__r.Program_Detail__c,'+
                         'MDF_Program__r.Vendor_Materials_Needed__c,MDF_Program__r.POP_Details__c,MDF_Program__r.POP_Owner__r.name,MDF_Program__r.Audience_Description__c,'+
                         'MDF_Program__r.Email__c,MDF_Program__r.Audience_Size__c,MDF_Program__r.Program_Status__c,MDF_Program__r.Program_Owner__r.name,MDF_Program__r.Program_Type__c,'+
                         'MDF_Program__r.recordType.name,MDF_Program__r.Detailed_Job_Description__c,Budgeted_Price__c';
          
        if((className == 'VFCntlr_COGSOEMSOW') && objType == 'Associated_Programs_Vendors__c'){
            QueryString2  += ' from Associated_Programs_Vendors__c ';
        }
        
        if(className == 'VFCntlr_SOWHeadCountValidation' || className == 'VFCntlr_HeadCountSOW' && objType == 'Associated_Programs_Vendors__c'){
            QueryString2 = QueryString2.remove(',Business_Segment__c');
            QueryString2 = QueryString2.remove('Package__c,Region__c,Sub_Region__c,');
            QueryString2 = QueryString2.remove('MDF_Program__r.Program_Objective__c,MDF_Program__r.Program_Detail__c,MDF_Program__r.Vendor_Materials_Needed__c,');
            QueryString2 = QueryString2.remove('MDF_Program__r.POP_Owner__r.name,MDF_Program__r.Audience_Description__c,MDF_Program__r.Email__c,MDF_Program__r.Audience_Size__c,'+
                                                'MDF_Program__r.Program_Status__c,MDF_Program__r.Program_Owner__r.name,MDF_Program__r.Program_Type__c,');
            QueryString2  += ',MDF_Program__r.Business_Segment__c,MDF_Program__r.Country__c,Rate_Card_Price__c,PUB__c,SMB__c,CSMR__c,LE__c from Associated_Programs_Vendors__c ';    
        }
        
        if((className == 'VFCntrlr_SOWAlaCarteOEM') && objType == 'Associated_Programs_Vendors__c'){
            QueryString2  += ',MDF_Program__r.Rate_Card_Price__c from Associated_Programs_Vendors__c ';
        }
        
        if((className == 'PlanBreakOutUpdate') && objType == 'Associated_Programs_Vendors__c'){
            QueryString2 = QueryString2.remove('id,name,vendor__c,Status__c,POP_Status__c,'+
                                                 'MDF_Program__c, recordtypeId,Business_Segment__c,Marketing_Plan__c,Package__c,Region__c,Sub_Region__c,Program_Notes__c,'+
                                                 'MDF_Program__r.Region__c,MDF_Program__r.name,MDF_Program__r.Fiscal_Quarter__c,MDF_Program__r.Program_Objective__c,MDF_Program__r.Program_Detail__c,'+
                                                 'MDF_Program__r.Vendor_Materials_Needed__c,MDF_Program__r.POP_Details__c,MDF_Program__r.POP_Owner__r.name,MDF_Program__r.Audience_Description__c,'+
                                                 'MDF_Program__r.Email__c,MDF_Program__r.Audience_Size__c,MDF_Program__r.Program_Status__c,MDF_Program__r.Program_Owner__r.name,MDF_Program__r.Program_Type__c,'+
                                                 'MDF_Program__r.recordType.name,MDF_Program__r.Detailed_Job_Description__c,Budgeted_Price__c');
            
            QueryString2  += 'Id,Name,Vendor__c,POP_Status__c,MDF_Program__r.Name,AlaCarte_Total__c,Status__c,Business_Segment__c,Budgeted_Price__c,MP_Region__c,MP_Fiscal_Quarter__c,MP_Contract_Type__c,'+
                             'Marketing_Plan__r.Contract_Type__c,AlaCarte_SMB_Direct__c,AlaCarte_SMB_Channel__c,AlaCarte_ABU_S_P__c,AlaCarte_All_Segments__c,Alacarte_ASAP__c,AlaCarte_Corporate_Events__c,'+
                             'AlaCarte_CSRM_S_P__c,Alacarte_Global_Mktg__c,AlaCarte_Int_l__c,CSMR__c,LE__c,PUB__c,SMB__c from Associated_Programs_Vendors__c ';
        }
        
        if((className == 'VFCntrlr_CustomerPortal_MPlan_HeadCount' || className == 'VFCntrlr_CustomerPortal_MarketingPlan') && objType == 'Associated_Programs_Vendors__c'){
            QueryString2 = QueryString2.remove('id,name,vendor__c,Status__c,POP_Status__c,'+
                                                 'MDF_Program__c, recordtypeId,Business_Segment__c,Marketing_Plan__c,Package__c,Region__c,Sub_Region__c,Program_Notes__c,'+
                                                 'MDF_Program__r.Region__c,MDF_Program__r.name,MDF_Program__r.Fiscal_Quarter__c,MDF_Program__r.Program_Objective__c,MDF_Program__r.Program_Detail__c,'+
                                                 'MDF_Program__r.Vendor_Materials_Needed__c,MDF_Program__r.POP_Details__c,MDF_Program__r.POP_Owner__r.name,MDF_Program__r.Audience_Description__c,'+
                                                 'MDF_Program__r.Email__c,MDF_Program__r.Audience_Size__c,MDF_Program__r.Program_Status__c,MDF_Program__r.Program_Owner__r.name,MDF_Program__r.Program_Type__c,'+
                                                 'MDF_Program__r.recordType.name,MDF_Program__r.Detailed_Job_Description__c,Budgeted_Price__c');
            
            QueryString2  += 'Id,Name,Package__c,Package__r.Package_Price_del__c,Package__r.Name,Package__r.Fiscal_Quarter__c,Marketing_Plan__c,MDF_Program__c,'+
                               'Budgeted_Price__c,APV_Status__c,Status__c,Accounting_Treatment__c,MDF_Program__r.Name,MDF_Program__r.Business_Segment__c,'+
                               'POP_Status__c,POP_Status_Reason__c,MDF_Program__r.Fiscal_Quarter__c,MDF_Program__r.Program_Owner__c,MDF_Program__r.Audience_Size__c,'+
                               'MDF_Program__r.Email__c,MDF_Program__r.Phone__c,MDF_Program__r.Audience_Description__c,MDF_Program__r.Program_Objective__c,'+
                               'MDF_Program__r.Program_Detail__c,MDF_Program__r.POP_Details__c,MDF_Program__r.Vendor_Materials_Needed__c,MDF_Program__r.Region__c,'+
                               'MDF_Program__r.Detailed_Job_Description__c,MDF_Program__r.Sub_Region__c,MDF_Program__r.Country__c,MDF_Program__r.RecordType.Name,'+
                               'MDF_Program__r.Event_Date__c,MDF_Program__r.Preferred_Program__c,Program_Notes__c from Associated_Programs_Vendors__c ';
        }
        if(className == 'VFCntlr_SOWAlaCarteIngramMicro' && objType == 'Associated_Programs_Vendors__c'){
            QueryString2 = QueryString2.remove('id,name,vendor__c,Status__c,POP_Status__c,'+
                                             'MDF_Program__c, recordtypeId,Business_Segment__c,Marketing_Plan__c,Package__c,Region__c,Sub_Region__c,Program_Notes__c,'+
                                             'MDF_Program__r.Region__c,MDF_Program__r.name,MDF_Program__r.Fiscal_Quarter__c,MDF_Program__r.Program_Objective__c,MDF_Program__r.Program_Detail__c,'+
                                             'MDF_Program__r.Vendor_Materials_Needed__c,MDF_Program__r.POP_Details__c,MDF_Program__r.POP_Owner__r.name,MDF_Program__r.Audience_Description__c,'+
                                             'MDF_Program__r.Email__c,MDF_Program__r.Audience_Size__c,MDF_Program__r.Program_Status__c,MDF_Program__r.Program_Owner__r.name,MDF_Program__r.Program_Type__c,'+
                                             'MDF_Program__r.recordType.name,MDF_Program__r.Detailed_Job_Description__c,Budgeted_Price__c' );
            
            QueryString2  += ' id,name,vendor__c,Status__c,POP_Status__c,Budgeted_Price__c,Program_Notes__c,'+
                                'MDF_Program__c, recordtypeId,Business_Segment__c,Marketing_Plan__c,Package__c,'+
                                'MDF_Program__r.Region__c,MDF_Program__r.name,MDF_Program__r.Fiscal_Quarter__c,'+
                                'MDF_Program__r.Program_Objective__c,MDF_Program__r.Program_Detail__c,'+
                                'MDF_Program__r.Vendor_Materials_Needed__c,MDF_Program__r.POP_Details__c,MDF_Program__r.POP_Owner__r.name,'+
                                'MDF_Program__r.Audience_Description__c,MDF_Program__r.Audience_Size__c,MDF_Program__r.Email__c,MDF_Program__r.recordType.name,'+
                                'MDF_Program__r.Program_Status__c,MDF_Program__r.Program_Owner__r.name,region__c,sub_region__c,MDF_Program__r.Program_Type__c,MDF_Program__r.Detailed_Job_Description__c from Associated_Programs_Vendors__c ';
        }
         
        return QueryString2;
    }
    
    public String getQueryMethod3(sObject o, String className){ 
        
        String objType = String.valueOf(o.getSobjectType());
        
        QueryString3  = 'select ';
        
        QueryString3  += 'Vendor__c,MDF_Contact__r.Name,MDF_Contact__c,MDF_Contact__r.Id,MDF_Contact__r.Region__c,MDF_Contact__r.Sub_Region__c,'+
                         'MDF_Contact__r.Country__c,MDF_Contact__r.Business_Segment__c,MDF_Contact__r.Notify_When_APV_Created__c,'+
                         'MDF_Contact__r.Email__c, MDF_Contact__r.Primary_Secondary__c';
        
        
        if(className == 'AssociateProgramVendorUtils' && objType == 'MDF_Associated_Contact__c'){
            QueryString3  += ' from MDF_Associated_Contact__c';
        }
        
        return QueryString3;
    }
}