public class MDFRedirect{

     public Headcount__c HCRecord {get; set;}
     //public string searchstring {get;set;} 
     public String strRT {get;set;}
     public String strFYQ {get;set;} 
     public MDF_Program__c mdfPrgram {get;set;}    
    
     public MDFRedirect(ApexPages.StandardController controller){  
        mdfPrgram = (MDF_Program__c)controller.getrecord();      
        getFYQ();
        //searchstring = null;            
                  
     }
     public List<SelectOption> getFYQ()
    {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = MDF_Program__c.Fiscal_Quarter__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple)
        options.add(new SelectOption(p.getValue(), p.getValue()));    
            
        return options;
    }  
      
      public pageReference continueButton() {            
            strRT = ApexPages.currentPage().getParameters().get('RecordType');            
            PageReference pageRef;
            if(mdfPrgram.HCID__c != null){
               Headcount__c HCRecord = [select id, Name, Program_Name__c, Region__c, Sub_Region__c, Country__c, Business_Segment__c, Rate_Card_Price__c, Detailed_Job_Description__c
                                        from Headcount__c where id = :mdfPrgram.HCID__c];
                if(HCRecord.id != null){       
                    String strURL = '/a1R/e?RecordType=' + strRT;
                                if(HCRecord.Program_Name__c != null){ strURL += '&Name=' + pageUtils.encodeVariable(HCRecord.Program_Name__c);}
                                if(HCRecord.Region__c != null){ strURL += '&00NA00000063PhC=' + pageUtils.encodeVariable(HCRecord.Region__c);}                                                    
                                if(HCRecord.Sub_Region__c != null){strURL += '&00NA00000063PhD=' + pageUtils.encodeVariable(HCRecord.Sub_Region__c);}
                                if(HCRecord.Business_Segment__c != null){strURL += '&00NA00000063Pgt=' + pageUtils.encodeVariable(HCRecord.Business_Segment__c);}
                                if(HCRecord.Country__c != null){strURL += '&00NA00000063Pgu=' + pageUtils.encodeVariable(HCRecord.Country__c) ;}                            
                                if(HCRecord.Rate_Card_Price__c != null){strURL += '&00NA00000063PhB=' + HCRecord.Rate_Card_Price__c;}
                                if(HCRecord.Name != null){ strURL += Label.MDF_HCID_ID + '=' + pageUtils.encodeVariable(HCRecord.Name) + Label.MDF_HCID_ID + '_lkid='+mdfPrgram.HCID__c;}
                                if(HCRecord.Detailed_Job_Description__c != null){strURL += '&00NA00000063Pgv=' + pageUtils.encodeVariable(HCRecord.Detailed_Job_Description__c);}
                                strURL += '&00NA00000063Pgy=' + strFYQ;
                                strURL += '&nooverride=1&ent=01IA00000016E5P';
                                
                    pageRef = new pagereference(strURL);
                 }
                 
                else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'HCID does not exist'));
                    //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter value'));
                    pageRef = null;
                }
           }
           else{
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter HCID value'));
               //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter value'));
               pageRef = null;

           } 
               
            return pageRef;
        }
      
      public pageReference cancelButton() {
        return PageUtils.Redirect('/a1R/o');
    }  
}