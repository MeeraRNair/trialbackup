@isTest
private class MDFRedirectTest{
    
    static testMethod void mdfProgram(){
        
        Headcount__c HC = new Headcount__c(
            Business_Segment__c = 'Consumer',
            Country__c = 'India',
            Detailed_Job_Description__c = 'Testing data',
            Program_Name__c = 'TestPrgrm',
            Rate_Card_Price__c = 100,
            Employee_Cost_Center__c = '1234-5678-123456',
            Region__c = 'APJ',
            Sub_Region__c = 'APJ');      
            insert HC;
            Headcount__c obj = [Select Id,Name from Headcount__c where Id=:HC.Id];
            user usr = [SELECT Id,name,Profile_Name__c FROM User WHERE Profile_Name__c = 'MDF Marketing Operations / Contract Admin' limit 1];
            
            MDF_Program__c mdfRecord = new MDF_Program__c(
                Business_Segment__c = HC.Business_Segment__c,
                Country__c = HC.Country__c,
                Detailed_Job_Description__c = HC.Detailed_Job_Description__c,
                Name = HC.Program_Name__c,
                Rate_Card_Price__c = HC.Rate_Card_Price__c,
                Region__c = HC.Region__c,
                Sub_Region__c = HC.Sub_Region__c,
                Fiscal_Quarter__c = 'FY17Q4',
                HCID__c = obj.Id,
                Pricing_Type__c = 'Variable',
                Program_Owner__c = usr.Id);
                
             insert mdfRecord;    
      
              PageReference pageRef = Page.MDF_New_HeadCount; // Add your VF page Name here
              pageRef.getParameters().put('RecordType', '012A0000000VhMu');
              Test.setCurrentPage(pageRef);
              MDFRedirect mdf = new MDFRedirect(new ApexPages.StandardController(mdfRecord));
              mdf.HCRecord = HC;
              mdf.mdfPrgram.HCID__c = mdfRecord.HCID__c;
              mdf.strFYQ = 'FY17Q4';
              //mdf.searchstring = obj.Name;
              Test.StartTest(); 
              mdf.continueButton(); 
              mdf.cancelButton();     
              Test.StopTest();
   }
    static testMethod void mdfProgram_Negative(){
        
        Headcount__c HC = new Headcount__c(
            Business_Segment__c = 'Consumer',
            Country__c = 'India',
            Detailed_Job_Description__c = 'Testing data',
            Program_Name__c = 'TestPrgrm',
            Rate_Card_Price__c = 100,
            Employee_Cost_Center__c = '1234-5678-123456',
            Region__c = 'APJ',
            Sub_Region__c = 'APJ');      
            insert HC;
            Headcount__c obj = [Select Id,Name from Headcount__c where Id=:HC.Id];
            user usr = [SELECT Id,name,Profile_Name__c FROM User WHERE Profile_Name__c = 'MDF Marketing Operations / Contract Admin' limit 1];
            
            MDF_Program__c mdfRecord = new MDF_Program__c(
                Business_Segment__c = HC.Business_Segment__c,
                Country__c = HC.Country__c,
                Detailed_Job_Description__c = HC.Detailed_Job_Description__c,
                Name = HC.Program_Name__c,
                Rate_Card_Price__c = HC.Rate_Card_Price__c,
                Region__c = HC.Region__c,
                Sub_Region__c = HC.Sub_Region__c,
                Fiscal_Quarter__c = 'FY17Q4',
                HCID__c = obj.Id,
                Pricing_Type__c = 'Variable',
                Program_Owner__c = usr.Id);
                
             insert mdfRecord;
      
              PageReference pageRef = Page.MDF_New_HeadCount; // Add your VF page Name here
              pageRef.getParameters().put('RecordType', '012A0000000VhMu');
              Test.setCurrentPage(pageRef);
              MDFRedirect mdf = new MDFRedirect(new ApexPages.StandardController(mdfRecord));
              mdf.strFYQ = 'FY17Q4';
              //mdf.searchstring = 'HC-XYZ';
              Test.StartTest(); 
              mdf.continueButton(); 
              mdf.cancelButton();     
              Test.StopTest();
   }
   static testMethod void mdfProgram_No_Record(){
        
        Headcount__c HC = new Headcount__c(
            Business_Segment__c = 'Consumer',
            Country__c = 'India',
            Detailed_Job_Description__c = 'Testing data',
            Program_Name__c = 'TestPrgrm',
            Rate_Card_Price__c = 100,
            Employee_Cost_Center__c = '1234-5678-123456',
            Region__c = 'APJ',
            Sub_Region__c = 'APJ');      
            insert HC;
            Headcount__c obj = [Select Id,Name from Headcount__c where Id=:HC.Id];
            user usr = [SELECT Id,name,Profile_Name__c FROM User WHERE Profile_Name__c = 'MDF Marketing Operations / Contract Admin' limit 1];
            MDF_Program__c mdfRecord = new MDF_Program__c(
                Business_Segment__c = HC.Business_Segment__c,
                Country__c = HC.Country__c,
                Detailed_Job_Description__c = HC.Detailed_Job_Description__c,
                Name = HC.Program_Name__c,
                Rate_Card_Price__c = HC.Rate_Card_Price__c,
                Region__c = HC.Region__c,
                Sub_Region__c = HC.Sub_Region__c,
                Fiscal_Quarter__c = 'FY17Q4',
                HCID__c = obj.Id,
                Pricing_Type__c = 'Variable',
                Program_Owner__c = usr.Id);
                
             insert mdfRecord;
      
             PageReference pageRef = Page.MDF_New_HeadCount; // Add your VF page Name here
             pageRef.getParameters().put('RecordType', '012A0000000VhMu');
             Test.setCurrentPage(pageRef);
             MDFRedirect mdf = new MDFRedirect(new ApexPages.StandardController(mdfRecord));
             mdf.strFYQ = 'FY17Q4'; 
             mdf.mdfPrgram.HCID__c = null;            
             Test.StartTest(); 
             mdf.continueButton(); 
             mdf.cancelButton();     
             Test.StopTest();
   }
  }