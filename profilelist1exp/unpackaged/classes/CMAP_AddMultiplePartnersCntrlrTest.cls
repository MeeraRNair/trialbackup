/*
REVISION HISTORY
======================================================================================================================
Version     Author      Date            Release#    	CR#     Description
-------     ------      ----            --------    	---     -----------
1.0        Afiq        18/8/2015        16.09       	11665   To add "Segment Description" for test class 
1.1        Afiq        15/10/2015       16.10       	12102   Add new method to be tested
2.0		Azwanti 	   15/03/2016		FY17-DCS-0401 	12720	replace Campaign RT from 'Channel Campaign' to 'Campaign 2.0'.
3.0		Azwanti		   04/05/2016		FY17-DCS-0602	13113	LM2_6-Fix Test Class Impacted on Campaign RT Deactivated (Part 1)
4.0     Sakshi         18/6/2018                        15979   Increase coverage
*/

@isTest(seeAllData=false)
private class CMAP_AddMultiplePartnersCntrlrTest{
    static list<Account> listAcc;
    static list<Campaign> listCamp;
    @testSetup static void setup(){
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'Partner Account');
        Database.insert(listAccTDF); 
        list<Campaign> listCampTDF = TestDataFactory.createNCampaign(1, 'Campaign 2.0');
        insert listCampTDF;
    }
    static testMethod void cMAPAddMultiplePartnersCntrlrTestHappyPath(){
        
        TriggerExecutionController.setSkipAllTriggers(true);
        
        Id partnerAccountRT = IdLookupUtils.getRecordTypeId('Partner Account', 'Account', true);
        //Id channelCampaignRT = IdLookupUtils.getRecordTypeId('Campaign 2.0', 'Campaign', true); //v2.0
        
        //Ver 1.0 Start
        Sales_Channel_Group__c scg = new Sales_Channel_Group__c(Name ='US', Segment_Desc__c = 'US1');
        
        Database.insert(scg);
        //Ver 1.0 End
        listCamp = [select id from Campaign limit 1];
        listCamp[0].Nurture_Source__c = 'Channel ANZ';
        listCamp[0].isActive = TRUE;
        listCamp[0].Status = 'Planned';
        listCamp[0].StartDate = date.parse('02/11/2015');
        listCamp[0].EndDate = system.today().addDays(10);
        listCamp[0].Segment_Business_Unit__c = 'Consumer'; // v3.0 populate EndDate to future date
        listCamp[0].Business_Unit__c = 'Consumer - Direct';
        listCamp[0].Region__c = 'APJ';
        listCamp[0].Sub_Region__c = 'APJ';
        listCamp[0].Country_Code__c = 'AU - Australia; NZ - New Zealand';
        listCamp[0].Follow_Up_Role__c = 'Inside Sales Rep';
        listCamp[0].Line_Of_Business__c = 'All-In-One';
        listCamp[0].Solution__c = 'IS - Integrated Security';
        listCamp[0].Allocation_Source__c = 'Dell Allocation APJ';
        listCamp[0].Description = 'test';
        update listCamp;
        system.assertEquals('test', listCamp[0].Description);
        /*
listAcc = [select id,Name from Account limit 1];
listAcc[0].Type = 'Partner';
listAcc[0].Account_Type_Integration__c = 'Account';//Owner.Name, Id
listAcc[0].BillingCity = 'Hayward';
listAcc[0].Account_ID__c = 'Test1234567';
listAcc[0].BillingState = 'California';
listAcc[0].Partner_Tier__c = 'Tier1';
listAcc[0].BillingPostalCode = '6750'; 
listAcc[0].Partner_Relationship__c = 'Relationship1';
listAcc[0].BillingCountry = 'USA'; 
listAcc[0].Dell_Certification_Areas__c = 'Cloud Builder;Cloud Enabler';
listAcc[0].Sales_Channel__c = scg.id;
DataBase.update (listAcc); */
        
        //   string strAccID = String.valueOf(listAcc[0].id);
        /*    Campaign camp = new Campaign(Name = 'Test Campaign', Vertical__c = 'Architecture', Campaign_Objective__c = 'Action',
Nurture_Source__c = 'Channel ANZ', isActive = TRUE, Status = 'Planned', 
StartDate = date.parse('02/11/2015'), EndDate = system.today().addDays(10), Segment_Business_Unit__c = 'Consumer', // v3.0 populate EndDate to future date
Business_Unit__c = 'Consumer - Direct', Region__c = 'APJ', Sub_Region__c = 'APJ',
Country_Code__c = 'AU - Australia; NZ - New Zealand', 
Follow_Up_Role__c = 'Inside Sales Rep', Line_Of_Business__c = 'All-In-One', 
Solution__c = 'IS - Integrated Security', Allocation_Source__c = 'Dell Allocation APJ',
Description = 'test', RecordTypeId = channelCampaignRT);
Database.insert(camp);
*/
        Account acc = new Account(Name = 'Test Account Power', Account_Type_Integration__c = 'Account',//Owner.Name, Id
                                  BillingCity = 'Hayward', Account_ID__c = 'Test1234', BillingState = 'California', 
                                  Partner_Tier__c = 'Tier1', BillingPostalCode = '6750', 
                                  Partner_Relationship__c = 'Relationship1', BillingCountry = 'USA', 
                                  Dell_Certification_Areas__c = 'Cloud Builder;Cloud Enabler', RecordTypeId = partnerAccountRT,
                                  Type = 'Partner', Sales_Channel__c = scg.id);
        Database.insert(acc);
        
        TriggerExecutionController.setSkipAllTriggers(false);
        
        List <Partner_Campaign_Management__c> listpcm = new List<Partner_Campaign_Management__c>();
        
        //ApexPages.StandardSetController sc = new ApexPages.StandardSetController(listpcm);
        CMAP_AddMultiplePartnersCntrlr cmap = new CMAP_AddMultiplePartnersCntrlr(new ApexPages.StandardSetController(listpcm));
        
        //PageReference campPage = new PageReference('/' + camp.Id);
        //Test.setCurrentPage(campPage);
        //PageReference addMultPage = Page.CMAP_AddMultiplePartners;
        //Test.setCurrentPage(addMultPage);
        cmap.campaignId = listCamp[0].Id;
        cmap.getType();
        cmap.getCertification();
        cmap.DellCertificationAvailable.add('Cloud Builder');
        cmap.DellCertificationAvailable.add('Cloud Enabler');
        cmap.selectclick();
        cmap.getCertificationChosen();
        cmap.DellCertificationChosen.add('Cloud Builder');
        cmap.DellCertificationChosen.add('Cloud Enabler');
        cmap.unselectclick();
        cmap.campaignId = listCamp[0].Id;
        cmap.AccountName = 'Test Account Power';
        cmap.AccountType = 'Account';
        // change to null so that any user name can run this test class in below line
        cmap.AccountOwner = '';
        cmap.PartnerAccountID = acc.id;
        cmap.BillingCity = 'Hayward';
        cmap.AffinityAccountID = 'Test1234';
        cmap.BillingState = 'California';
        cmap.PartnerTier = 'Tier1';
        cmap.BillingPostal = '6750';
        cmap.PartnerRelationship = 'Relationship1';
        cmap.BillingCountry = 'USA';
        //Ver 1.0 Start
        cmap.SegmentDescription = 'US1';
        //Ver 1.0 End
        cmap.doSearch();
        cmap.getCustomAcctListWrap();
        cmap.selectAllAccounts();
        cmap.doAddPartners();
        cmap.next();
        cmap.previous();
        cmap.getHasPreviousAndNext();
        //cmap.AddAllPartners();
        //cmap.nextOrPrevious();
        
    }
    
    //Ver 1.1 Start
    static testMethod void cMAPAddMultiplePartnersCntrlrTestHappyPathB(){
        
        TriggerExecutionController.setSkipAllTriggers(true);
        
        //    Id partnerAccountRT = IdLookupUtils.getRecordTypeId('Partner Account', 'Account', true);
        //    Id channelCampaignRT = IdLookupUtils.getRecordTypeId('Campaign 2.0', 'Campaign', true);
        
        //Ver 1.0 Start
        Sales_Channel_Group__c scg = new Sales_Channel_Group__c(Name ='US', Segment_Desc__c = 'US1');
        
        Database.insert(scg);
        //Ver 1.0 End
        /*  
Campaign camp = new Campaign(Name = 'Test Campaign', Vertical__c = 'Architecture', Campaign_Objective__c = 'Action',
Nurture_Source__c = 'Channel ANZ', isActive = TRUE, Status = 'Planned', 
StartDate = date.parse('02/11/2015'), EndDate = system.today().addDays(10), Segment_Business_Unit__c = 'Consumer', // v3.0 populate EndDate to future date
Business_Unit__c = 'Consumer - Direct', Region__c = 'APJ', Sub_Region__c = 'APJ',
Country_Code__c = 'AU - Australia; NZ - New Zealand', 
Follow_Up_Role__c = 'Inside Sales Rep', Line_Of_Business__c = 'All-In-One', 
Solution__c = 'IS - Integrated Security', Allocation_Source__c = 'Dell Allocation APJ',
Description = 'test', RecordTypeId = channelCampaignRT);
Database.insert(camp);

Account acc = new Account(Name = 'Test Account Power', Account_Type_Integration__c = 'Account',//Owner.Name, Id
BillingCity = 'Hayward', Account_ID__c = 'Test1234567', BillingState = 'California', 
Partner_Tier__c = 'Tier1', BillingPostalCode = '6750', 
Partner_Relationship__c = 'Relationship1', BillingCountry = 'USA', 
Dell_Certification_Areas__c = 'Cloud Builder;Cloud Enabler', RecordTypeId = partnerAccountRT,
Type = 'Partner', Sales_Channel__c = scg.id);
Database.insert(acc); */
        listCamp = [select id from Campaign limit 1];
        listCamp[0].Nurture_Source__c = 'Channel ANZ';
        listCamp[0].isActive = TRUE;
        listCamp[0].Status = 'Planned';
        listCamp[0].StartDate = date.parse('02/11/2015');
        listCamp[0].EndDate = system.today().addDays(10);
        listCamp[0].Segment_Business_Unit__c = 'Consumer'; // v3.0 populate EndDate to future date
        listCamp[0].Business_Unit__c = 'Consumer - Direct';
        listCamp[0].Region__c = 'APJ';
        listCamp[0].Sub_Region__c = 'APJ';
        listCamp[0].Country_Code__c = 'AU - Australia; NZ - New Zealand';
        listCamp[0].Follow_Up_Role__c = 'Inside Sales Rep';
        listCamp[0].Line_Of_Business__c = 'All-In-One';
        listCamp[0].Solution__c = 'IS - Integrated Security';
        listCamp[0].Allocation_Source__c = 'Dell Allocation APJ';
        listCamp[0].Description = 'test';
        update listCamp;
        system.assertEquals('test', listCamp[0].Description);
        listAcc = [select id,Name from Account limit 1];
        listAcc[0].Type = 'Partner';
        listAcc[0].Account_Type_Integration__c = 'Account';//Owner.Name, Id
        listAcc[0].BillingCity = 'Hayward';
        listAcc[0].Account_ID__c = 'Test1234567';
        listAcc[0].BillingState = 'California';
        listAcc[0].Partner_Tier__c = 'Tier1';
        listAcc[0].BillingPostalCode = '6750'; 
        listAcc[0].Partner_Relationship__c = 'Relationship1';
        listAcc[0].BillingCountry = 'USA'; 
        listAcc[0].Dell_Certification_Areas__c = 'Cloud Builder;Cloud Enabler';
        listAcc[0].Sales_Channel__c = scg.id;
        DataBase.update (listAcc);
        
        TriggerExecutionController.setSkipAllTriggers(false);
        
        List <Partner_Campaign_Management__c> listpcm = new List<Partner_Campaign_Management__c>();
        
        CMAP_AddMultiplePartnersCntrlr cmap = new CMAP_AddMultiplePartnersCntrlr(new ApexPages.StandardSetController(listpcm));
        
        // Instantiate VisualForce Page
        
        PageReference pgRef = Page.CMAP_AddMultiplePartners; //Create Page Reference - 'Appt_New' is the name of Page
        Test.setCurrentPage(pgRef); //Set the page for Test Method
        ApexPages.currentPage().getParameters().put('id', listCamp[0].id);//Pass Id to page
        
        cmap.campaignId = listCamp[0].Id;
        cmap.getType();
        cmap.getCertification();
        cmap.DellCertificationAvailable.add('Cloud Builder');
        cmap.DellCertificationAvailable.add('Cloud Enabler');
        cmap.selectclick();
        cmap.getCertificationChosen();
        cmap.DellCertificationChosen.add('Cloud Builder');
        cmap.DellCertificationChosen.add('Cloud Enabler');
        cmap.unselectclick();
        cmap.campaignId = listCamp[0].Id;
        cmap.AccountName = 'Test Account Power';
        cmap.AccountType = 'Account';
        // change to null so that any user name can run this test class in below line
        cmap.AccountOwner = '';
        cmap.PartnerAccountID = listAcc[0].Id;
        cmap.BillingCity = 'Hayward';
        cmap.AffinityAccountID = 'Test1234567';
        cmap.BillingState = 'California';
        cmap.PartnerTier = 'Tier1';
        cmap.BillingPostal = '6750';
        cmap.PartnerRelationship = 'Relationship1';
        cmap.BillingCountry = 'USA';
        cmap.SegmentDescription = 'US1';
        
        test.startTest();
        cmap.doSearch();
        cmap.AddAllPartners();
        test.stopTest();
        //cmap.getHasPreviousAndNext();
    }
    //Ver 1.0 End
    
    static testMethod void cMAPAddMultiplePartnersCntrlrTestNoSearchCriteria(){
        /*     
Id channelCampaignRT = IdLookupUtils.getRecordTypeId('Campaign 2.0', 'Campaign', true);

Campaign camp = new Campaign(Name = 'Test Campaign', Vertical__c = 'Architecture', Campaign_Objective__c = 'Action',
Nurture_Source__c = 'Channel ANZ', isActive = TRUE, Status = 'Planned', 
StartDate = date.parse('02/11/2015'), EndDate = system.today().addDays(10), Segment_Business_Unit__c = 'Consumer', // v3.0 populate EndDate to future date
Business_Unit__c = 'Consumer - Direct', Region__c = 'APJ', Sub_Region__c = 'APJ',
Country_Code__c = 'AU - Australia; NZ - New Zealand', 
Follow_Up_Role__c = 'Inside Sales Rep', Line_Of_Business__c = 'All-In-One', 
Solution__c = 'IS - Integrated Security', Allocation_Source__c = 'Dell Allocation APJ',
Description = 'test', RecordTypeId = channelCampaignRT);
Database.insert(camp);
*/
        listCamp = [select id from Campaign limit 1];
        listCamp[0].Nurture_Source__c = 'Channel ANZ';
        listCamp[0].isActive = TRUE;
        listCamp[0].Status = 'Planned';
        listCamp[0].StartDate = date.parse('02/11/2015');
        listCamp[0].EndDate = system.today().addDays(10);
        listCamp[0].Segment_Business_Unit__c = 'Consumer'; // v3.0 populate EndDate to future date
        listCamp[0].Business_Unit__c = 'Consumer - Direct';
        listCamp[0].Region__c = 'APJ';
        listCamp[0].Sub_Region__c = 'APJ';
        listCamp[0].Country_Code__c = 'AU - Australia; NZ - New Zealand';
        listCamp[0].Follow_Up_Role__c = 'Inside Sales Rep';
        listCamp[0].Line_Of_Business__c = 'All-In-One';
        listCamp[0].Solution__c = 'IS - Integrated Security';
        listCamp[0].Allocation_Source__c = 'Dell Allocation APJ';
        listCamp[0].Description = 'test';
        update listCamp;
        system.assertEquals('test', listCamp[0].Description);
        List <Partner_Campaign_Management__c> listpcm = new List<Partner_Campaign_Management__c>();
        CMAP_AddMultiplePartnersCntrlr cmap = new CMAP_AddMultiplePartnersCntrlr(new ApexPages.StandardSetController(listpcm));
        
        cmap.campaignId = listCamp[0].Id;
        cmap.AccountName = '';
        cmap.AccountType = '--None--';
        cmap.AccountOwner = '';
        cmap.PartnerAccountID = '';
        cmap.BillingCity = '';
        cmap.AffinityAccountID = '';
        cmap.BillingState = '';
        cmap.PartnerTier = '';
        cmap.BillingPostal = '';
        cmap.PartnerRelationship = '';
        cmap.BillingCountry = '';
        //Ver 1.0 Start
        cmap.SegmentDescription = '';
        //Ver 1.0 End
        cmap.doSearch();
    }
    
}