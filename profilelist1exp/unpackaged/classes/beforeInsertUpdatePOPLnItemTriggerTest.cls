@isTest

private class beforeInsertUpdatePOPLnItemTriggerTest{
 
    static testMethod void TestbeforeInsertUpdatePOPLnItemTrigger() {
        //final List<Profile> testprofile = [select id,name from Profile where name IN ('MDF Co-Marketing Manager', 'MDF Marketing Operations / Contract Admin')];

                                               
List <Profile> p = [SELECT Id FROM Profile WHERE name IN ('MDF Co-Marketing Manager', 'MDF Marketing Operations / Contract Admin')]; 
 User us = new User(Alias = 'standt', Email='testuser@dellteam.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p[0].Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='testuser@dellteam.com');
insert us; 

           System.runAs(us){
            MDF_Approver__c MA = new MDF_Approver__c();
            
            MA.Region__c = 'APJ';
            MA.Sub_Region__c = 'APJ';
            MA.Country__c = 'All Countries';
            MA.Business_Segment__c = 'Consumer';
            MA.Program_Type__c = 'Event';
            MA.Program_Approver__c = us.id;
            MA.POP_Approver__c = us.id;
            
            insert MA;
            update MA;
            }
        

           System.runAs(us){
            MDF_Program__c MP = new MDF_Program__c();
            
            MP.Name = 'myTest';
            MP.Fiscal_Quarter__c = 'FY12Q3';
            MP.Region__c = 'APJ';
            MP.Sub_Region__c = 'APJ';
            MP.Country__c = 'All Countries';
            MP.Business_Segment__c = 'Consumer';
            MP.Program_Owner__c = us.id;
            MP.Rate_Card_Price__c = 50.00;
            MP.Pricing_Type__c = 'Non-Variable';
            MP.Audience_Size__c = 'abc';
            MP.Audience_Description__c = 'testabc';
            MP.Program_Objective__c = 'testabcd';
            MP.Program_Detail__c = 'testab';
            MP.Vendor_Materials_Needed__c = 'tests';
            //MP.Program_Approver__c = us.id;
            //MP.POP_Approver__c = us.id;
            
            insert MP;
            update MP;
            }
            
            System.runAs(us){
            MDF_Program__c MP1 = new MDF_Program__c();
            
            MP1.Name = 'myTest1';
            MP1.Fiscal_Quarter__c = 'FY12Q3';
            MP1.Region__c = 'APJ';
            MP1.Sub_Region__c = 'APJ';
            MP1.Country__c = 'All Countries';
            MP1.Business_Segment__c = 'Consumer';
            MP1.Program_Owner__c = us.id;
            MP1.Rate_Card_Price__c = 70.00;
            MP1.Pricing_Type__c = 'Non-Variable';
            MP1.Audience_Size__c = 'abcd';
            MP1.Audience_Description__c = 'testabcd';
            MP1.Program_Objective__c = 'testabcdd';
            MP1.Program_Detail__c = 'testabb';
            MP1.Vendor_Materials_Needed__c = 'testsd';
            //MP1.Program_Approver__c = us.id;
            //MP1.POP_Approver__c = us.id;
            
            insert MP1;
            update MP1;
            }
            
            System.runAs(us){
            Proof_of_Performance_POP__c PP = new Proof_of_Performance_POP__c();
            PP.Name = 'testsfnrgwfryjtyhthhrthrrthrthrtg';
            Insert PP;
          
            POP_Line_Item__c POP = new POP_Line_Item__c();
            
          //  POP.Country__c = 'All Countries';
          //  POP.Business_Segment__c = 'Consumer';
            POP.Proof_of_Performance_POP__c = PP.Id;
            POP.POP_Status__c = 'abc';
            //POP.POP_Approver__c = us.id;
            POP.POP_Submission_Status__c = 'New';
            insert POP;
            }
              
            
        }
  }