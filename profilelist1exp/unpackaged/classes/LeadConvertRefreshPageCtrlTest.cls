/*************************************************************************************

* Author   : Ashok
* Purpose  : This is the test class for LeadConvertRefreshPageCtrl.
* 
* Revision CR Number   Release No      Date            Modified By     Description
* -------- ---------   ----------      -----------     ------------    -----------
* 1.0      14012      FY18-DCS-0302   27-Mar-2017      Ashok            LM2_Optimization in lead conversion process - UI changes refresh

***************************************************************************************/

@isTest
private class LeadConvertRefreshPageCtrlTest
{
    

@testSetup static void setUpConversionTestData() {

        OWD__c oWDsetting = new OWD__c();
        oWDsetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        oWDsetting.Oppty_Stage10__c = 'Discover - 10%';
        oWDsetting.Oppty_Stage100__c = 'Win - 100%';
        oWDsetting.Oppty_Stage30__c = 'Qualify - 30%';
        oWDsetting.Oppty_Stage60__c = 'Propose - 60%';
        oWDsetting.Oppty_Stage90__c = 'Commit - 90%';
        oWDsetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        oWDsetting.Oppty_Stage1__c = 'Plan - 1%';
        insert oWDsetting;
        
        TriggerExecutionController.setSkipAllTriggers(true);
        
        //Account Record INSERTION    
        Account newAccount = new Account(Name = 'Dell Internal_01');
        insert newAccount;
        
        //User Record INSERTION
        Profile userProfile= [select id,name from profile where name like '%GBL Sales Rep%' order by name limit 1 ];
        User user = new User( Username='TestLeadConversion' +System.currentTimeMillis() + '@test.com',
                             Alias = 'TstLd'+056,
                             Email='test'+ 012 +'@dell.com',
                             FirstName='Tfirst'+0,
                             LastName='TestLeadConversion'+100,
                             ProfileId = userProfile.Id,
                             LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US',
                             EmailEncodingKey='UTF-8',
                             TimeZoneSidKey='America/Los_Angeles',
                             Badge_Number__c='TstLeadCon123456789' );
        insert user;
        
        //Test Data for CONTACT
        ContactTestData.iNumberOfContacts = 1;
        ContactTestData.createContact();
        list<Contact> lstContacts = ContactTestData.lstContacts;
        lstContacts[0].LastName = 'TestLeadConversion-Contact 1';
        lstContacts[0].Accountid = newAccount.id;
        update lstContacts;
        
        //TEST data for Opportunity
        Id oppRecordTypeId= IdLookupUtils.getRecordTypeId('Standard Opportunity','Opportunity',true);
        Opportunity opp=new Opportunity (name='TestLeadConversion-Opp 1', Total_Expected_Dell_Revenue__c=5000,CloseDate=System.Today(),Description='Test Desc',StageName='Plan - 1%',RecordtypeId = oppRecordTypeId);
        insert opp;
        
        //TestData for SALES CHANNEL
        Sales_Channel_Group__c testSalesChannelRecord = new Sales_Channel_Group__c
            (Name='TestLeadConversion-SC Record 1',
             Group_ID__c=''+System.currentTimeMillis()
            );
        insert TestSalesChannelRecord;
        
        //TestData for COUNTRY
        country__c country = new Country__c (Name = 'TestLeadConversion-Contry 1',code__c='TST',region__c = 'EMEA',Is_Active_in_Affinity__c = true);
        insert country;
        
        LeadTestData.iNumberOfLeads = 1;
        LeadTestData.createDirectLead2();
        list<Lead> lstLeads = LeadTestData.lstLeads;
        lstLeads[0].LastName='TestLeadConversion';
        lstLeads[0].ownerid = user.id;
        
        update lstLeads;
     
        TriggerExecutionController.setSkipAllTriggers(false);
    }

    private static testMethod void testExistingOpptyType() {

       test.startTest();
 
        TriggerExecutionController.setSkipAllTriggers(true);
        Account newAccount=[SELECT Id,Name FROM Account WHERE Name='Dell Internal_01' LIMIT 1];
        User user=[SELECT Id,Username FROM User WHERE LastName='TestLeadConversion100' LIMIT 1];
        Lead newLead=[SELECT Id,LastName,ownerid,Company FROM Lead Where LastName='TestLeadConversion' LIMIT 1];
        Contact objContact=[SELECT Id, Accountid FROM Contact WHERE LastName = 'TestLeadConversion-Contact 1' LIMIT 1];
        Opportunity objOpportunity=[SELECT Id,Name FROM Opportunity WHERE Name='TestLeadConversion-Opp 1' LIMIT 1 ];
        
        newLead.Sales_Follow_up_days__c = null;
        newLead.First_time_assigned_to_Sales__c=system.now();
        newLead.Contact__c = objContact.id;
        newLead.Account__c =objContact.AccountId;
        //Test conversion validation with invalid lead status
        newLead.Status='Marketing Ready Lead';
        update newLead;
        
  
        PageReference pageRef = Page.leadConvertRefreshPage;
        pageRef.getParameters().put('id',newLead.id);
        pageRef.getParameters().put('contactId',newlead.contact__c);
        pageRef.getParameters().put('OpptyId',objOpportunity.id);
        pageRef.getParameters().put('OpptyType','Existing');
        pageRef.getParameters().put('salesLoginUser','FALSE');
        pageRef.getParameters().put('strOpptyDaysCreated','1');
        test.setCurrentPage(pageRef);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(newLead);
        LeadConvertRefreshPageCtrl leadController = new LeadConvertRefreshPageCtrl(stdController);
        //leadcontroller.leadToConvert = newLead;
        leadController.updateAccContCMTask(); 
                      
        Test.stopTest();
        
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    
    
    private static testMethod void testNewOpptyType() {

       test.startTest();
 
        TriggerExecutionController.setSkipAllTriggers(true);
        Account newAccount=[SELECT Id,Name FROM Account WHERE Name='Dell Internal_01' LIMIT 1];
        User user=[SELECT Id,Username FROM User WHERE LastName='TestLeadConversion100' LIMIT 1];
        Lead newLead=[SELECT Id,LastName,ownerid,Company FROM Lead Where LastName='TestLeadConversion' LIMIT 1];
        Contact objContact=[SELECT Id, Accountid FROM Contact WHERE LastName = 'TestLeadConversion-Contact 1' LIMIT 1];
        Opportunity objOpportunity=[SELECT Id,Name FROM Opportunity WHERE Name='TestLeadConversion-Opp 1' LIMIT 1 ];
        
        newLead.Sales_Follow_up_days__c = null;
        newLead.First_time_assigned_to_Sales__c=system.now();
        newLead.Contact__c = objContact.id;
        newLead.Account__c =objContact.AccountId;
        //Test conversion validation with invalid lead status
        newLead.Status='Marketing Ready Lead';
        update newLead;
        
  
        PageReference pageRef = Page.leadConvertRefreshPage;
        pageRef.getParameters().put('id',newLead.id);
        pageRef.getParameters().put('contactId',newlead.contact__c);
        pageRef.getParameters().put('OpptyId',objOpportunity.id);
        pageRef.getParameters().put('OpptyType','New');
        pageRef.getParameters().put('salesLoginUser','TRUE');
        pageRef.getParameters().put('strOpptyDaysCreated','1');
        test.setCurrentPage(pageRef);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(newLead);
        LeadConvertRefreshPageCtrl leadController = new LeadConvertRefreshPageCtrl(stdController);
        //leadcontroller.leadToConvert = newLead;
        leadController.updateAccContCMTask(); 
                      
        Test.stopTest();
        
        TriggerExecutionController.setSkipAllTriggers(false);
    }
 
}