/*************************************************************************************

* Author   : Ashok
* Purpose  : This is the test class for DeleteAccountFeedFutureClass.
* 
* Revision CR Number   Release No      Date            Modified By     Description
* -------- ---------   ----------      -----------     ------------    -----------
* 1.0      14117      FY18 DCS-0502    11-Apr-2017     Ashok           LM2_Account chatter feed deletion after lead conversion
/* 
* Revision   Release No       Modified By               Description
* --------   ---------        -----------               ------------               
*            0202             Venugopalachary k         Implement Test Data Factory                               

***************************************************************************************/

@isTest
private class DeleteAccountFeedFutureClassTest{
    
    @testSetup static void setUpConversionTestData() {
        TriggerExecutionController.setSkipAllTriggers(true);
        OWD__c owdsetting = new OWD__c();
        owdsetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        owdsetting.Oppty_Stage10__c = 'Discover - 10%';
        owdsetting.Oppty_Stage100__c = 'Win - 100%';
        owdsetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdsetting.Oppty_Stage60__c = 'Propose - 60%';
        owdsetting.Oppty_Stage90__c = 'Commit - 90%';
        owdsetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdsetting.Oppty_Stage1__c = 'Plan - 1%';
        insert owdsetting;
        //Account Record INSERTION    
        /*   Account newAccount = new Account(Name = 'Dell Internal_01');
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
*/
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
        listAccTdf[0].Name='Dell Internal_01';
        insert listAccTdf;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        listOppTdf[0].AccountId=listAccTdf[0].id;
        insert listOppTdf;
        list<Contact> listConTdf=TestDataFactory.createNContacts(1);
        listConTdf[0].Accountid=listAccTdf[0].id;
        insert listConTdf;
        Profile userProfile= [select id,name from profile where name like '%GBL Sales Rep%' order by name limit 1 ];
        list<User> listUserTdf=TestDataFactory.createNGenralUsers(1);
        listUserTdf[0].ProfileID=userProfile.id;
        insert listUserTdf;
        list<Sales_Channel_Group__c> listSalesChaGrpTdf=TestDataFactory.createNSalesChannelGroups(1);
        insert listSalesChaGrpTdf;
        country__c country = new Country__c (Name = 'TestLeadConversion-Contry 1',code__c='TST',region__c = 'EMEA',Is_Active_in_Affinity__c = true);
        insert country;
        list<Campaign> listCampaignTdf=TestDataFactory.createNCampaign(1, 'Campaign 2.0');
        insert listCampaignTdf;
        list<Lead> listLeadTdf=TestDataFactory.createNLeads(1, 'Direct Lead 2.0');
        listLeadTdf[0].LastName='TestLeadConversion';
        listLeadTdf[0].Campaign__c=listCampaignTdf[0].id;
        insert listLeadTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    private static testMethod void testExistingOpptyType() {
        test.startTest();
        TriggerExecutionController.setSkipAllTriggers(true);
        Account newAccount=[SELECT Id,Name FROM Account WHERE Name='Dell Internal_01' LIMIT 1];
        User user=[SELECT Id,Username FROM User WHERE  profile.name like '%GBL Sales Rep%' LIMIT 1];
        Lead newLead=[SELECT Id,LastName,ownerid,Company,Account__c,Contact__c,isConverted FROM Lead Where LastName='TestLeadConversion' LIMIT 1];
        Contact objContact=[SELECT Id, Accountid FROM Contact WHERE Accountid=:newAccount.id LIMIT 1];
        Opportunity objOpportunity=[SELECT Id,Name,Accountid FROM Opportunity WHERE Accountid=:newAccount.id LIMIT 1 ];
        system.assertNotEquals(newAccount.id, null);
        newLead.Sales_Follow_up_days__c = null;
        newLead.First_time_assigned_to_Sales__c=system.now();
        newLead.Contact__c = objContact.id;
        newLead.Account__c =objContact.AccountId;
        //Test conversion validation with invalid lead status
        newLead.Status='Marketing Ready';
        update newLead;
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(newLead.id);
        lc.setAccountId(newLead.Account__c);
        lc.setContactId(newLead.Contact__c);
        
        lc.setDoNotCreateOpportunity(false);
        lc.setConvertedStatus('Converted without Opportunity');
        //TriggerExecutioncontroller.setSkipOpportunityTriggers(True);
        Database.LeadConvertResult lcr = Database.convertLead(lc); 
        lead convtlead = [select id,isconverted,ConvertedAccountId from lead where id=:lcr.getLeadId()]; 
        DeleteAccountFeedFutureClass.invokeDelAccountFeed(new list<lead>{convtLead});
        TriggerExecutionController.setSkipAllTriggers(false);
        test.stopTest();
    }
}