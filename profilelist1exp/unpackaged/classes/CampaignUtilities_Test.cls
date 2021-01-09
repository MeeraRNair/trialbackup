/*
 * Author   : Ragu
 * Purpose  : Test class for CampaignUtilities. 
 *
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      11480       16.07       18-May-2015     Ragu            Created.
 * 2.0      11931       16.10       09-Sep-2015     Dipin Raju      Added test logic for cancelling leads when campaign is aborted
 * 3.0		12491		16.12		23-Dec-2015		Ragu			LM3_13_4- Fix SOQL error in campaign update
 * 4.0      14545       FY18-0702   14-Jun-2017     Sajith          PCM Insert/Update for Campaign from Vistex with a partner related  
 */
@isTest(SeeAllData=true)
private class CampaignUtilities_Test {
    
    @isTest
    static void testFieldHistoryTracking() {
        CampaignTestData.iNumberOfCampaigns = 3;
        CampaignTestData.createStandardCampaign();
        list<Campaign> lstCampaigns = CampaignTestData.lstCampaigns;
        
        for(integer i=0; i<lstCampaigns.size(); i++) {
            Campaign campaignIterator = lstCampaigns[i];
            campaignIterator.Name = 'Test Campaign - Revised' + i;
            campaignIterator.Follow_Up_Role__c = 'Account Owner';
            
            if(i != 0) {
                campaignIterator.ParentId = lstCampaigns[0].Id;
            }
        }
        update lstCampaigns;
    }
    
    static testMethod void testPCMRecordInsertUpdate() {
        Account partnerAccount1,partnerAccount2 ;
        
        system.debug(Logginglevel.INFO,'@@@ Inside testPCMRecordInsertUpdate');
        AccountTestData.bCreate = false;
        AccountTestData.createPartnerAccount();
        system.debug(Logginglevel.INFO,'@@@ Partner Accounts ' + AccountTestData.lstAccounts);
    	partnerAccount1 = AccountTestData.lstAccounts[1];
    	partnerAccount1.Account_Country__c = 'Malaysia';
    	partnerAccount1.ShippingState = 'Selangor';
    	partnerAccount1.ShippingPostalCode = '63000';
        partnerAccount1.Account_ID__c = '99998888';  
		partnerAccount2 = AccountTestData.lstAccounts[2];
    	partnerAccount2.Account_Country__c = 'Malaysia';
    	partnerAccount2.ShippingState = 'Selangor';
    	partnerAccount2.ShippingPostalCode = '63000';
        partnerAccount2.Account_ID__c = '88889999';
        
        system.debug(Logginglevel.INFO,'@@@ Partner Account1 ' + partnerAccount1);
		
        system.debug(Logginglevel.INFO,'@@@ Partner Account2 ' + partnerAccount2);
    
    	insert (new list<Account>{partnerAccount1,partnerAccount2});
        
        list<Account> lstAccount =new list <Account>([SELECT Id,Account_ID__c FROM Account Where Account_ID__c in ('99998888','88889999')]);
        system.debug(Logginglevel.INFO,'@@@ Partner Account is Ready' + lstAccount);
		//update objAccount;
        Campaign objCampaign = new Campaign(Name='Campaign_CMAP',
                                               Follow_Up_Role__c='Account Executive',
                                               Secondary_Role__c='Affiliates Technical Sales Rep',
                                               Description='Test',StartDate=system.today(),EndDate=system.today(),
                                               status='In Progress',
                                               IsActive = true,
                                               //MDF_Partner_ID__c='1122334477',
                                               MDF_Partner_ID__c=lstAccount[0].Account_ID__c,
                                               Total_Campaign_Targets_Planned__c = 1,
                                               Aprimo_Activity_Id__c ='12345',
                                               Lead_Routing__c = 'Not Applicable');
        insert objCampaign;
        system.debug(Logginglevel.INFO,'@@@ New Campaign inserted with MDF_Partner_Id value');
        objCampaign.MDF_Partner_ID__c=lstAccount[1].Account_ID__c;
        update objCampaign;
        objCampaign.MDF_Partner_ID__c='XXX';
        update objCampaign;
        objCampaign.MDF_Partner_ID__c='';
        update objCampaign;
        objCampaign.MDF_Partner_ID__c=lstAccount[0].Account_ID__c;
        update objCampaign;
      
    }
    
    
    // v3.0 Start: Commented all the test methods since CampaignToLeadUpdaterTest will handle all these scenarios going forward. 
    /*
    @isTest(SeeAllData=true)
    static void testAbortedCampaign() {
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true);
        Id lead2RTId = IdLookupUtils.getRecordTypeId('Direct Lead 2.0','Lead',true);
        Campaign testCampaign = new Campaign (Type='eSeminar/Webcast/Webinar', EndDate=date.newInstance(2019, 12, 1), 
                                              IsActive=true, Description='Test Campaign', StartDate=date.newInstance(2009, 12, 1), 
                                              Name='Test Campaign for test AutoLeadClose', Follow_Up_Role__c = 'Inside Sales Rep', RecordTypeId =campRTId, 
                                              Allocation_Source__c='Dell Allocation APJ', Nurture_Source__c='Dell Nurturing',Global_Campaign_Type__c='Campaign 2.0',
                                              Secondary_Role__c='Account Owner', Status='In Progress'); //, Proceed_with_cancellation__c='Yes');
        insert testCampaign;
        Lead SalesLead = new Lead(LastName = 'Test Lead 1',
            Lead_Type__c = 'Inbound',
            RecordTypeId = lead2RTId ,
            Email = 'testcmap@cmaptest.com',
            Status = 'Cancelled',
            Phone = '88967544',
            Country = 'US',
            Campaign__c = testCampaign.Id,
            Company = 'Test Company',
            LeadSource='Partner',
            Lead_Score__c = 'High Priority (Extremely hot leads; SLA = 48 hours)');
       insert SalesLead;       
       
       Campaign testCamp = [Select Id from Campaign Limit 1];
       testCamp.Status='Aborted';
       testCamp.Proceed_with_cancellation__c='Yes';
       Update(testCamp);                                  
    }

    @isTest(SeeAllData=true)
    static void populateCampFields() {
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true);
        Id lead2RTId = IdLookupUtils.getRecordTypeId('Direct Lead 2.0','Lead',true);
        Campaign testCampaign = new Campaign (Type='eSeminar/Webcast/Webinar', EndDate=date.newInstance(2019, 12, 1), 
                                              IsActive=true, Description='Test Campaign', StartDate=date.newInstance(2009, 12, 1), 
                                              Name='Test Camp 1', Follow_Up_Role__c = 'Inside Sales Rep', RecordTypeId =campRTId, 
                                              Allocation_Source__c='Dell Allocation APJ', Nurture_Source__c='Dell Nurturing',Global_Campaign_Type__c='Campaign 2.0',
                                              Secondary_Role__c='Account Owner', Status='In Progress'); 
        insert testCampaign ;
        
        Lead SLead = new Lead(LastName = 'Test Lead 2',
            Lead_Type__c = 'Inbound',
            RecordTypeId =lead2RTId, 
            Email = 'testcmap@cmaptest.com',
            Status = 'Cancelled',
            Phone = '88967544',
            Country = 'US',
            Campaign__c = testCampaign.Id,
            Company = 'Test Company',
            LeadSource='Partner',
            Lead_Score__c = 'High Priority (Extremely hot leads; SLA = 48 hours)');
       insert SLead;       
       
       Campaign testCamp1 = [Select Id from Campaign where Name='Test Camp 1' Limit 1];
       testCamp1.Next_Steps__c='Test Next Steps';
       testCamp1.Supporting_Information__c='Test Suporting Info';
       Update(testCamp1);                                  
    }    
    
    @isTest(SeeAllData=false)
    static void updateLeadStatus()
    {
        CampaignTestData.iNumberOfCampaigns = 1;
        CampaignTestData.createCampaign2();
        list<Campaign> lstCampaigns = CampaignTestData.lstCampaigns;
        Id directLead2RTId = StaticFactory.getRecordTypeIdByName('Lead', 'Direct Lead 2.0');
        
        Lead objLead = new Lead();
        objLead.FirstName = 'testMethod';
        objLead.LastName = 'Test Lead';
        objLead.Email = '123456@test.com';
        objLead.Phone = '123456789';
        objLead.Status = 'Open';
        objLead.LeadSource = 'Web';
        objLead.Company = 'Dell Internal';
        objLead.Lead_Type__c = 'Inbound';
        objLead.RecordTypeId = directLead2RTId;
        objLead.Campaign__c = lstCampaigns[0].Id;       
        insert objLead;
        
        lstCampaigns[0].IsActive = false;
        lstCampaigns[0].ActualCost = 1000;
        lstCampaigns[0].Actual_Partner_Cost__c = 1000;
        update lstCampaigns[0];
        
        lstCampaigns[0].IsActive = true;
        update lstCampaigns[0];
    }
    */
    // v3.0 End: Commented all the test methods since CampaignToLeadUpdaterTest will handle all these scenarios going forward. 
}