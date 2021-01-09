/*
 * Revision Ref Number  Release No      Date            Modified By     Description
 * -------- ----------  ----------      -----------     ------------    -----------
 * 1.0      CR 12130    16.10           01-Oct-2015     Ragu            Created for testing ChannelLeadUtilities. Methods are copied from CMAP_OpportunityTrigger_Test and optimized.
 * 2.0      CR12720     FY17-DCS-0401   15-March-2016   Azwanti         replace Campaign RT from 'Channel Campaign' to 'Campaign 2.0'.
 * 3.0      CR13441     FY17-DCS-1002   09-Sep-2016     Sajith          LM2_6-Fix Test Class Impacted on Campaign RT Deactivated (Part 10)
 */
 
 @isTest
private class ChannelLeadUtilities_Test {
    static list<Account> listAcc;
    static list<Opportunity> listOpp;
        @testSetup static void setup() {
        // Create common test OWD settings
        OWD__c owdSetting = new OWD__c();
        owdSetting.Oppty_Stage1__c = 'Plan - 1%';
        owdSetting.Oppty_Stage10__c = 'Discover - 10%';
        owdSetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdSetting.Oppty_Stage60__c = 'Propose - 60%';
        owdSetting.Oppty_Stage90__c = 'Commit - 90%';
        owdSetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdSetting.Oppty_Stage100__c = 'Win - 100%';
        owdSetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        Insert owdSetting;
         TriggerExecutionController.setSkipAllTriggers(True);
         list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'Partner Account');
         insert listAccTDF;
         list<Opportunity> listOppTDF = TestDataFactory.createNOpportunities(6, 'Deal Registration');
         insert listOppTDF;
    }

/*    static testMethod void test_ApprovedOnOppCreation() {
        //3.0  TriggerExecutionController.setSkipAllTriggers(true);
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner');
        insert newAcc;
        
        Contact newContact = new Contact(AccountId = newAcc.Id, FirstName = 'First Name', LastName = 'Last Name', Email = 'FirstLast@gmail.com');
        insert newContact;
        
        Id channelCampRTId= IdLookupUtils.getRecordTypeId('Channel Partner Communications','Campaign',true); //v3.0
        list<Campaign> listCampaigns = new list<Campaign>();
        Campaign testCampaign = new Campaign(Name='Test RL Campaign',
                                        RecordTypeId = channelCampRTId,
                                        Campaign_Objective__c = 'LOB Conversion',
                                        Type='DM',
                                        Segment_Business_Unit__c='PUB',                                 
                                        StartDate=System.Today() - 12,
                                        EndDate=System.Today(),
                                        Description='This is Test RL Campaign',
                                        IsActive=true,
                                        Lead_Routing__c = 'Not Applicable');
        listCampaigns.add(testCampaign);
        
        Id campRTId = IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
        Campaign campChannelObj = new Campaign(Name='Campaign_CMAP',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='ABU',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                recordTypeId = campRTId,
                Allocation_Source__c = 'Dell Allocation ABU',
                Nurture_Source__c = 'Dell Nurturing',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = False,
                IsActive = true,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1,
                Lead_Routing__c = 'Not Applicable');
        listCampaigns.add(campChannelObj);
        
        insert listCampaigns;
        
        //v3.0 Insert Custom Settings Data 
        CMAP_Queue_Settings__c objSetting = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6s0MAA',Queue_Name__c='Channel TQL Nurturing',Name='NA:TQL Nurturing:N');
        insert objSetting;
        CMAP_Queue_Settings__c objSetting_eclerx = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6hl',Queue_Name__c='Channel_eClerx',Name='Channel_eClerx');
        insert objSetting_eclerx;

        list<Lead> listleadtoInsertList = new list<Lead>();
        Id cleadRTId = IdLookupUtils.getRecordTypeId('Channel Lead - Assignment Complete','Lead',true);
        Lead leadObj1 = new Lead(lastName = 'Test Lead1',
                email ='testcmap@cmaptest.com',
                status = 'Accepted by Channel Partner',
                Phone='88967544',
                Called_Customer__c ='Yes',
                Sales_Qualified__c ='Qualified',
                Unqualified_Lead_Reason__c = 'Test',
                Campaign__c  = campChannelObj.Id,
                recordTypeId = cleadRTId,
                Budget__c = 'Yes',
                Country = 'US',
                Purchase_Timeframe__c ='Immediate',
                Company = 'Test Company',
                Related_Opportunity_Count__c = null);      
        listleadtoInsertList.add(leadObj1);
         
        TriggerExecutionController.setSkipLeadTriggers(true); //wanti
        insert listleadtoInsertList;
        TriggerExecutionController.setSkipLeadTriggers(false); //wanti
        
        Relationship_Lead__c newRL = new Relationship_Lead__c(Contact__c = newContact.Id,
                                                                Campaign__c = testCampaign.Id,
                                                                CM_Source__c = leadObj1.Id,
                                                                Status__c = 'Requires Follow-up',
                                                                Inside_Sales_Manager__c = UserInfo.getUserId());
        insert newRL;
        Test.startTest();
        leadObj1.Relationship_Lead__c = newRL.Id;
        update leadObj1;   
        
        //v3.0 TriggerExecutionController.setSkipOpportunityTriggers(false);
        
        Id dealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=newAcc.Id, 
                                                Channel_Lead_Id__c = LeadObj1.Id,
                                                Deal_Registration_Status__c = 'Approved',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = dealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Justification_Statement__c = 'Justification Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'Country',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                                Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                StageName = 'Lost, Cancelled - 0%',
                                                Competitor_Lost_To__c = 'Unknown',
                                                CloseDate = System.Today() + 30
                                                );
        //v3.0 : skipping Opportunity triggers by process flow
        ProcessFlowTriggerController.isTest = true;
        insert testOppty;
       
        
        Test.stopTest();
    }*/
    
    static testMethod void testChannelLeadUtilities1() {
        TriggerExecutionController.setSkipAllTriggers(true);
/*        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner');
        insert newAcc; */
        listAcc = [select id,name,type from Account limit 1];
        listAcc[0].Type = 'Partner';
        update listAcc;
        Contact newContact = new Contact(AccountId = listAcc[0].Id, FirstName = 'First Name', LastName = 'Last Name', Email = 'FirstLast@gmail.com');
        insert newContact;
        Id channelCampRTId= IdLookupUtils.getRecordTypeId('Channel Partner Communications','Campaign',true); //v3.0
        list<Campaign> listCampaigns = new list<Campaign>();
        Campaign testCampaign = new Campaign(Name='Test RL Campaign',
                                             RecordTypeId = channelCampRTId, //v3.0
                                             Campaign_Objective__c = 'LOB Conversion',
                                             Type='DM',
                                             Segment_Business_Unit__c='PUB',                                 
                                             StartDate=System.Today() - 12,
                                             EndDate=System.Today(),
                                             Description='This is Test RL Campaign',
                                             IsActive=true,
                                             Lead_Routing__c = 'Not Applicable');
        listCampaigns.add(testCampaign);
        Id campRTId = IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
        Campaign campChannelObj = new Campaign(Name='Campaign_CMAP',
                                               Campaign_Objective__c='Acquisition/Site Development',
                                               Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                                               Region__c='ABU',                        
                                               Follow_Up_Role__c='Account Executive',
                                               Description='Test',StartDate=system.today(),EndDate=system.today(),
                                               status='In Progress',
                                               recordTypeId = campRTId,
                                               Allocation_Source__c = 'Dell Allocation ABU',
                                               Nurture_Source__c = 'Dell Nurturing',
                                               Country_Code__c = 'BR - Brazil',
                                               Partner_Event_or_Campaign__c = False,
                                               IsActive = true,
                                               Total_Campaign_Targets_Planned__c = 1,
                                               Total_Value_Won_Opportunities_Planned__c = 1,
                                               Total_Value_Opportunities_Planned__c = 1,
                                               Lead_Routing__c = 'Not Applicable');
        listCampaigns.add(campChannelObj);
        insert listCampaigns;
        System.assertEquals(false, listCampaigns[1].Partner_Event_or_Campaign__c);
        //v3.0 Insert Custom Settings Data 
        CMAP_Queue_Settings__c objSetting = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6s0MAA',Queue_Name__c='Channel TQL Nurturing',Name='NA:TQL Nurturing:N');
        insert objSetting;
        CMAP_Queue_Settings__c objSettingeclerx = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6hl',Queue_Name__c='Channel_eClerx',Name='Channel_eClerx');
        insert objSettingeclerx;
        list<Lead> listleadtoInsertList = new list<Lead>();
        Id cleadRTId = IdLookupUtils.getRecordTypeId('Channel Lead - Assignment Complete','Lead',true);
        Lead leadObj1 = new Lead(lastName = 'Test Lead1',
                                 email ='testcmap@cmaptest.com',
                                 status = 'Accepted by Channel Partner',
                                 Phone='88967544',
                                 Called_Customer__c ='Yes',
                                 Sales_Qualified__c ='Qualified',
                                 Unqualified_Lead_Reason__c = 'Test',
                                 Campaign__c  = campChannelObj.Id,
                                 recordTypeId = cleadRTId,
                                 Budget__c = 'Yes',
                                 Country = 'US',
                                 Purchase_Timeframe__c ='Immediate',
                                 Company = 'Test Company',
                                 Related_Opportunity_Count__c = 1);
        listleadtoInsertList.add(leadObj1);
        Lead leadObj2 = new Lead(lastName = 'Test Lead1',
                                 email ='testcmap@cmaptest.com',
                                 status = 'Accepted by Channel Partner',
                                 Phone='88967544',
                                 Called_Customer__c ='Yes',
                                 Sales_Qualified__c ='Qualified',
                                 Unqualified_Lead_Reason__c = 'Test',
                                 Campaign__c  = campChannelObj.Id,
                                 recordTypeId = cleadRTId,
                                 Budget__c = 'Yes',
                                 Country = 'US',
                                 Purchase_Timeframe__c ='Immediate',
                                 Company = 'Test Company');      
        listleadtoInsertList.add(leadObj2);
        insert listleadtoInsertList;
        Relationship_Lead__c newRL = new Relationship_Lead__c(Contact__c = newContact.Id,
                                                              Campaign__c = testCampaign.Id,
                                                              CM_Source__c = leadObj1.Id,
                                                              Status__c = 'Requires Follow-up',
                                                              Inside_Sales_Manager__c = UserInfo.getUserId());
        insert newRL;        
        listOpp = [select id,AccountID,Channel_Lead_Id__c,StageName,Forecast_Category_Override__c,Amount from Opportunity limit 1];
        listOpp[0].AccountID = listAcc[0].id;
        listOpp[0].Deal_Registration_Status__c= 'Approved';
        listOpp[0].Engagement_Type__c = 'Public Tender';
        listOpp[0].Total_Expected_Dell_Revenue__c =1919191;
        listOpp[0].Channel_Lead_Id__c = LeadObj1.Id;
        listOpp[0].Forecast_Category_Override__c = 'Omitted';
        listOpp[0].CloseDate = System.Today() + 30;
        update listOpp;
      /*  Id dealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=newAcc.Id, 
                                                Channel_Lead_Id__c = LeadObj1.Id,
                                                Deal_Registration_Status__c= 'Approved',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = dealRTId,
                                                Distributor_Name__c='Distribution',
                                                Engagement_Type__c = 'Public Tender',
                                                Justification_Statement__c = 'Justification Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'Country',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                                Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                StageName = 'Plan - 1%',
                                                //Probability = 0,
                                                Forecast_Category_Override__c = 'Omitted',
                                                CloseDate = System.Today() + 30 );        
        insert testOppty;
         */
        leadObj1.Related_Opportunity__c = listOpp[0].Id;
        leadObj1.Relationship_Lead__c = newRL.Id;
        leadObj2.Relationship_Lead__c = newRL.Id;
        update listleadtoInsertList;
        TriggerExecutionController.setSkipAllTriggers(false);
        Test.startTest();
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        TriggerExecutionController.setSkipAllTriggers(false);
        //v3.0 : skipping Opportunity triggers by process flow
        ProcessFlowTriggerController.isTest = true;
        listOpp[0].Channel_Lead_Id__c = LeadObj2.Id;
        listOpp[0].Amount = 10000;
        //v3.0 : skipping Opportunity triggers by process flow
        TriggerExecutioncontroller.setskipOpportunitySplitTriggers(True);
        update listOpp[0];
        Test.stopTest();
    }
    static testMethod void testChannelLeadUtilitiesRejected1() {
        TriggerExecutionController.setSkipAllTriggers(true);
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        //    Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner');
        //    insert newAcc;
        listAcc = [select id,name,type from Account limit 1];
        listAcc[0].Type = 'Partner';
        update listAcc;
        Contact newContact = new Contact(AccountId = listAcc[0].Id, FirstName = 'First Name', LastName = 'Last Name', Email = 'FirstLast@gmail.com');
        insert newContact;
        Id channelCampRTId= IdLookupUtils.getRecordTypeId('Channel Partner Communications','Campaign',true); //v3.0
        list<Campaign> listCampaigns = new list<Campaign>();
        Campaign testCampaign = new Campaign(Name='Test RL Campaign',
                                             RecordTypeId = channelCampRTId,
                                             Campaign_Objective__c = 'LOB Conversion',
                                             Type='DM',
                                             Segment_Business_Unit__c='PUB',                                 
                                             StartDate=System.Today() - 12,
                                             EndDate=System.Today(),
                                             Description='This is Test RL Campaign',
                                             IsActive=true,
                                             Lead_Routing__c = 'Not Applicable');
        listCampaigns.add(testCampaign);
        Id campRTId = IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
        Campaign campChannelObj = new Campaign(Name='Campaign_CMAP',
                                               Campaign_Objective__c='Acquisition/Site Development',
                                               Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                                               Region__c='ABU',                        
                                               Follow_Up_Role__c='Account Executive',
                                               Description='Test',StartDate=system.today(),EndDate=system.today(),
                                               status='In Progress',
                                               recordTypeId = campRTId,
                                               Allocation_Source__c = 'Dell Allocation ABU',
                                               Nurture_Source__c = 'Dell Nurturing',
                                               Country_Code__c = 'BR - Brazil',
                                               Partner_Event_or_Campaign__c = False,
                                               IsActive = true,
                                               Total_Campaign_Targets_Planned__c = 1,
                                               Total_Value_Won_Opportunities_Planned__c = 1,
                                               Total_Value_Opportunities_Planned__c = 1,
                                               Lead_Routing__c = 'Not Applicable');
        listCampaigns.add(campChannelObj);
        insert listCampaigns;
        System.assertEquals(1, listCampaigns[1].Total_Campaign_Targets_Planned__c);
        //v3.0 Insert Custom Settings Data 
        CMAP_Queue_Settings__c objSetting = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6s0MAA',Queue_Name__c='Channel TQL Nurturing',Name='NA:TQL Nurturing:N');
        insert objSetting;
        CMAP_Queue_Settings__c objSettingeclerx = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6hl',Queue_Name__c='Channel_eClerx',Name='Channel_eClerx');
        insert objSettingeclerx;
        list<Lead> listleadtoInsertList = new list<Lead>();
        Id cleadRTId = IdLookupUtils.getRecordTypeId('Channel Lead - Assignment Complete','Lead',true);
        Lead leadObj1 = new Lead(lastName = 'Test Lead1',
                                 email ='testcmap@cmaptest.com',
                                 status = 'Accepted by Channel Partner',
                                 Phone='88967544',
                                 Called_Customer__c ='Yes',
                                 Sales_Qualified__c ='Qualified',
                                 Unqualified_Lead_Reason__c = 'Test',
                                 Campaign__c  = campChannelObj.Id,
                                 recordTypeId = cleadRTId,
                                 Budget__c = 'Yes',
                                 Country = 'US',
                                 Purchase_Timeframe__c ='Immediate',
                                 Company = 'Test Company',
                                 Related_Opportunity_Count__c = 1);
        listleadtoInsertList.add(leadObj1);
        Lead leadObj2 = new Lead(lastName = 'Test Lead1',
                                 email ='testcmap@cmaptest.com',
                                 status = 'Accepted by Channel Partner',
                                 Phone='88967544',
                                 Called_Customer__c ='Yes',
                                 Sales_Qualified__c ='Qualified',
                                 Unqualified_Lead_Reason__c = 'Test',
                                 Campaign__c  = campChannelObj.Id,
                                 recordTypeId = cleadRTId,
                                 Budget__c = 'Yes',
                                 Country = 'US',
                                 Purchase_Timeframe__c ='Immediate',
                                 Company = 'Test Company');      
        listleadtoInsertList.add(leadObj2);
        insert listleadtoInsertList;
        Relationship_Lead__c newRL = new Relationship_Lead__c(Contact__c = newContact.Id,
                                                              Campaign__c = testCampaign.Id,
                                                              CM_Source__c = leadObj1.Id,
                                                              Status__c = 'Requires Follow-up',
                                                              Inside_Sales_Manager__c = UserInfo.getUserId());
        insert newRL;
        leadObj1.Relationship_Lead__c = newRL.Id;
        leadObj2.Relationship_Lead__c = newRL.Id;
        update listleadtoInsertList;
        listOpp = [select id,AccountID,Channel_Lead_Id__c,StageName,Forecast_Category_Override__c,Amount from Opportunity limit 1];
        listOpp[0].AccountID = listAcc[0].id;
        listOpp[0].Deal_Registration_Status__c= 'Approved';
        listOpp[0].Engagement_Type__c = 'Public Tender';
        listOpp[0].Total_Expected_Dell_Revenue__c =1919191;
        listOpp[0].Channel_Lead_Id__c = LeadObj1.Id;
        listOpp[0].Forecast_Category_Override__c = 'Omitted';
        listOpp[0].CloseDate = System.Today() + 30;
        update listOpp;
 /*       Id dealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=newAcc.Id, 
                                                Channel_Lead_Id__c = LeadObj1.Id,
                                                Deal_Registration_Status__c = 'New',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = DealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Justification_Statement__c = 'Justification Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'Country',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                Distributor_Name__c='Distribution',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                                Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                StageName = 'Plan - 1%',
                                                //Probability = 0,
                                                Forecast_Category_Override__c = 'Omitted',
                                                CloseDate = System.Today() + 30 );        
        insert testOppty; */
        TriggerExecutionController.setSkipAllTriggers(True);
        update listOpp;
        Test.startTest();
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        TriggerExecutionController.setSkipAllTriggers(false);
        //v3.0 : skipping Opportunity triggers by process flow
        ProcessFlowTriggerController.isTest = true;
        listOpp[0].Deal_Registration_Status__c = 'Rejected';
        listOpp[0].Rejection_Reason_Code__c = 'Revenue does not meet threshold';
        //v3.0 : skipping Opportunity triggers by process flow
        TriggerExecutionController.setSkipOpportunityTriggers(True);
        update listOpp[0];
        Test.stopTest();
    }
    static testMethod void testChannelLeadUtilitiesRejected2() {
        TriggerExecutionController.setSkipAllTriggers(true);
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        //        Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner');
        //        insert newAcc;
        listAcc = [select id,name,type from Account limit 1];
        listAcc[0].Type = 'Partner';
        update listAcc;
        Contact newContact = new Contact(AccountId = listAcc[0].Id, FirstName = 'First Name', LastName = 'Last Name', Email = 'FirstLast@gmail.com');
        insert newContact;
        Id channelCampRTId= IdLookupUtils.getRecordTypeId('Channel Partner Communications','Campaign',true); //v3.0
        list<Campaign> listCampaigns = new list<Campaign>();
        Campaign testCampaign = new Campaign(Name='Test RL Campaign',
                                             RecordTypeId = channelCampRTId,
                                             Campaign_Objective__c = 'LOB Conversion',
                                             Type='DM',
                                             Segment_Business_Unit__c='PUB',                                 
                                             StartDate=System.Today() - 12,
                                             EndDate=System.Today(),
                                             Description='This is Test RL Campaign',
                                             IsActive=true,
                                             Lead_Routing__c = 'Not Applicable');
        listCampaigns.add(testCampaign);
        Id campRTId = IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
        Campaign campChannelObj = new Campaign(Name='Campaign_CMAP',
                                               Campaign_Objective__c='Acquisition/Site Development',
                                               Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                                               Region__c='ABU',                        
                                               Follow_Up_Role__c='Account Executive',
                                               Description='Test',StartDate=system.today(),EndDate=system.today(),
                                               status='In Progress',
                                               recordTypeId = campRTId,
                                               Allocation_Source__c = 'Dell Allocation ABU',
                                               Nurture_Source__c = 'Dell Nurturing',
                                               Country_Code__c = 'BR - Brazil',
                                               Partner_Event_or_Campaign__c = False,
                                               IsActive = true,
                                               Total_Campaign_Targets_Planned__c = 1,
                                               Total_Value_Won_Opportunities_Planned__c = 1,
                                               Total_Value_Opportunities_Planned__c = 1,
                                               Lead_Routing__c = 'Not Applicable');
        listCampaigns.add(campChannelObj);
        insert listCampaigns;
        System.assertEquals(true, listCampaigns[0].IsActive);
        //v3.0 Insert Custom Settings Data 
        CMAP_Queue_Settings__c objSetting = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6s0MAA',Queue_Name__c='Channel TQL Nurturing',Name='NA:TQL Nurturing:N');
        insert objSetting;
        CMAP_Queue_Settings__c objSettingeclerx = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6hl',Queue_Name__c='Channel_eClerx',Name='Channel_eClerx');
        insert objSettingeclerx;
        list<Lead> listleadtoInsertList = new list<Lead>();
        Id cleadRTId = IdLookupUtils.getRecordTypeId('Channel Lead - Assignment Complete','Lead',true);
        Lead leadObj1 = new Lead(lastName = 'Test Lead1',
                                 email ='testcmap@cmaptest.com',
                                 status = 'Accepted by Channel Partner',
                                 Phone='88967544',
                                 Called_Customer__c ='Yes',
                                 Sales_Qualified__c ='Qualified',
                                 Unqualified_Lead_Reason__c = 'Test',
                                 Campaign__c  = campChannelObj.Id,
                                 recordTypeId = cleadRTId,
                                 Budget__c = 'Yes',
                                 Country = 'US',
                                 Purchase_Timeframe__c ='Immediate',
                                 Company = 'Test Company',
                                 Related_Opportunity_Count__c = 1);
        listleadtoInsertList.add(leadObj1);
        Lead leadObj2 = new Lead(lastName = 'Test Lead1',
                                 email ='testcmap@cmaptest.com',
                                 status = 'Accepted by Channel Partner',
                                 Phone='88967544',
                                 Called_Customer__c ='Yes',
                                 Sales_Qualified__c ='Qualified',
                                 Unqualified_Lead_Reason__c = 'Test',
                                 Campaign__c  = campChannelObj.Id,
                                 recordTypeId = cleadRTId,
                                 Budget__c = 'Yes',
                                 Country = 'US',
                                 Purchase_Timeframe__c ='Immediate',
                                 Company = 'Test Company');      
        listleadtoInsertList.add(leadObj2);
        insert listleadtoInsertList;
        Relationship_Lead__c newRL = new Relationship_Lead__c(Contact__c = newContact.Id,
                                                              Campaign__c = testCampaign.Id,
                                                              CM_Source__c = leadObj1.Id,
                                                              Status__c = 'Requires Follow-up',
                                                              Inside_Sales_Manager__c = UserInfo.getUserId());
        insert newRL;
        leadObj1.Relationship_Lead__c = newRL.Id;
        leadObj2.Relationship_Lead__c = newRL.Id;
        update listleadtoInsertList;
     /*
        Id dealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=newAcc.Id, 
                                                Channel_Lead_Id__c = LeadObj1.Id,
                                                Deal_Registration_Status__c = 'New',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = dealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Justification_Statement__c = 'Justification Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'Country',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                Distributor_Name__c='Distribution',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                                Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                StageName = 'Plan - 1%',
                                                //Probability = 0,
                                                Forecast_Category_Override__c = 'Omitted',
                                                CloseDate = System.Today() + 30 ); 
        insert testOppty;*/
        listOpp = [select id,AccountID,Channel_Lead_Id__c,StageName,Forecast_Category_Override__c,Amount from Opportunity limit 1];
        listOpp[0].Deal_Registration_Status__c= 'Approved';
        listOpp[0].Engagement_Type__c = 'Public Tender';
        listOpp[0].Total_Expected_Dell_Revenue__c =1919191;
        listOpp[0].Channel_Lead_Id__c = LeadObj1.Id;
        listOpp[0].Forecast_Category_Override__c = 'Omitted';
        listOpp[0].CloseDate = System.Today() + 30;
        update listOpp;
        TriggerExecutionController.setSkipAllTriggers(false);
        ProcessFlowTriggerController.isTest = true;
        Test.startTest();
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        TriggerExecutionController.setSkipAllTriggers(false);
        //v3.0 : skipping Opportunity triggers by process flow
        ProcessFlowTriggerController.isTest = true;
        listOpp[0].Deal_Registration_Status__c = 'Rejected';
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        update listOpp[0];
        Test.stopTest();
    }
    static testMethod void testChannelLeadUtilitiesRecalled1() {
        TriggerExecutionController.setSkipAllTriggers(true);
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        //       Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner');
        //       insert newAcc;
        listAcc = [select id,name,type from Account limit 1];
        listAcc[0].Type = 'Partner';
        update listAcc;
        Contact newContact = new Contact(AccountId = listAcc[0].Id, FirstName = 'First Name', LastName = 'Last Name', Email = 'FirstLast@gmail.com');
        insert newContact;
        Id channelCampRTId= IdLookupUtils.getRecordTypeId('Channel Partner Communications','Campaign',true); //v3.0
        list<Campaign> listCampaigns = new list<Campaign>();
        Campaign testCampaign = new Campaign(Name='Test RL Campaign',
                                             RecordTypeId = channelCampRTId,
                                             Campaign_Objective__c = 'LOB Conversion',
                                             Type='DM',
                                             Segment_Business_Unit__c='PUB',                                 
                                             StartDate=System.Today() - 12,
                                             EndDate=System.Today(),
                                             Description='This is Test RL Campaign',
                                             IsActive=true,
                                             Lead_Routing__c = 'Not Applicable');
        listCampaigns.add(testCampaign);
        Id campRTId = IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
        Campaign campChannelObj = new Campaign(Name='Campaign_CMAP',
                                               Campaign_Objective__c='Acquisition/Site Development',
                                               Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                                               Region__c='ABU',                        
                                               Follow_Up_Role__c='Account Executive',
                                               Description='Test',StartDate=system.today(),EndDate=system.today(),
                                               status='In Progress',
                                               recordTypeId = campRTId,
                                               Allocation_Source__c = 'Dell Allocation ABU',
                                               Nurture_Source__c = 'Dell Nurturing',
                                               Country_Code__c = 'BR - Brazil',
                                               Partner_Event_or_Campaign__c = False,
                                               IsActive = true,
                                               Total_Campaign_Targets_Planned__c = 1,
                                               Total_Value_Won_Opportunities_Planned__c = 1,
                                               Total_Value_Opportunities_Planned__c = 1,
                                               Lead_Routing__c = 'Not Applicable');
        listCampaigns.add(campChannelObj);
        insert listCampaigns;
        System.assertEquals(true, listCampaigns[0].IsActive);
        //v3.0 Insert Custom Settings Data 
        CMAP_Queue_Settings__c objSetting = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6s0MAA',Queue_Name__c='Channel TQL Nurturing',Name='NA:TQL Nurturing:N');
        insert objSetting;
        CMAP_Queue_Settings__c objSettingeclerx = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6hl',Queue_Name__c='Channel_eClerx',Name='Channel_eClerx');
        insert objSettingeclerx;
        list<Lead> listleadtoInsertList = new list<Lead>();
        Id cleadRTId = IdLookupUtils.getRecordTypeId('Channel Lead - Assignment Complete','Lead',true);
        Lead leadObj1 = new Lead(lastName = 'Test Lead1',
                                 email ='testcmap@cmaptest.com',
                                 status = 'Accepted by Channel Partner',
                                 Phone='88967544',
                                 Called_Customer__c ='Yes',
                                 Sales_Qualified__c ='Qualified',
                                 Unqualified_Lead_Reason__c = 'Test',
                                 Campaign__c  = campChannelObj.Id,
                                 recordTypeId = cleadRTId,
                                 Budget__c = 'Yes',
                                 Country = 'US',
                                 Purchase_Timeframe__c ='Immediate',
                                 Company = 'Test Company',
                                 Related_Opportunity_Count__c = 1);
        listleadtoInsertList.add(leadObj1);
        Lead leadObj2 = new Lead(lastName = 'Test Lead1',
                                 email ='testcmap@cmaptest.com',
                                 status = 'Accepted by Channel Partner',
                                 Phone='88967544',
                                 Called_Customer__c ='Yes',
                                 Sales_Qualified__c ='Qualified',
                                 Unqualified_Lead_Reason__c = 'Test',
                                 Campaign__c  = campChannelObj.Id,
                                 recordTypeId = cleadRTId,
                                 Budget__c = 'Yes',
                                 Country = 'US',
                                 Purchase_Timeframe__c ='Immediate',
                                 Company = 'Test Company');      
        listleadtoInsertList.add(leadObj2);
        insert listleadtoInsertList;
        Relationship_Lead__c newRL = new Relationship_Lead__c(Contact__c = newContact.Id,
                                                              Campaign__c = testCampaign.Id,
                                                              CM_Source__c = leadObj1.Id,
                                                              Status__c = 'Requires Follow-up',
                                                              Inside_Sales_Manager__c = UserInfo.getUserId());
        insert newRL;
        leadObj1.Relationship_Lead__c = newRL.Id;
        leadObj2.Relationship_Lead__c = newRL.Id;
        update listleadtoInsertList;
        /*
        Id dealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=newAcc.Id, 
                                                Channel_Lead_Id__c = LeadObj1.Id,
                                                Deal_Registration_Status__c = 'New',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = dealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Justification_Statement__c = 'Justification Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                Distributor_Name__c='Distribution',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'Country',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                                Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                StageName = 'Plan - 1%',
                                                //Probability = 0,
                                                Forecast_Category_Override__c = 'Omitted',
                                                CloseDate = System.Today() + 30 );        
        insert testOppty;        
        */
        listOpp = [select id,AccountID,Channel_Lead_Id__c,StageName,Forecast_Category_Override__c,Amount from Opportunity limit 1];
        listOpp[0].Deal_Registration_Status__c= 'Approved';
        listOpp[0].Engagement_Type__c = 'Public Tender';
        listOpp[0].Total_Expected_Dell_Revenue__c =1919191;
        listOpp[0].Channel_Lead_Id__c = LeadObj1.Id;
        listOpp[0].Forecast_Category_Override__c = 'Omitted';
        listOpp[0].CloseDate = System.Today() + 30;
        update listOpp;
        Test.startTest();
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        TriggerExecutionController.setSkipAllTriggers(false);
        //v3.0 : skipping Opportunity triggers by process flow
        ProcessFlowTriggerController.isTest = true;
        listOpp[0].Deal_Registration_Status__c = 'Recalled';
        listOpp[0].Rejection_Reason_Code__c = 'Revenue does not meet threshold';
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        update listOpp[0];
        Test.stopTest();
    }
    static testMethod void rejectDealTest() { 
        TriggerExecutionController.setSkipAllTriggers(true);
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        //      Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner');
        //      insert newAcc;
        listAcc = [select id,name,type from Account limit 1];
        listAcc[0].Type = 'Partner';
        update listAcc;
        Id campchannelRTId = IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
        Campaign campChannelObj= new Campaign(Name='Campaign_CMAP',
                                              Campaign_Objective__c='Acquisition/Site Development',
                                              Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                                              Region__c='ABU',                        
                                              Follow_Up_Role__c='Account Executive',
                                              Description='Test',StartDate=system.today(),EndDate=system.today(),
                                              status='In Progress',
                                              recordTypeId = campchannelRTId,
                                              Allocation_Source__c = 'Dell Allocation ABU',
                                              Nurture_Source__c = 'Dell Nurturing',
                                              Country_Code__c = 'BR - Brazil',
                                              Partner_Event_or_Campaign__c = False,
                                              IsActive = true,
                                              Total_Campaign_Targets_Planned__c = 1,
                                              Total_Value_Won_Opportunities_Planned__c = 1,
                                              Total_Value_Opportunities_Planned__c = 1,
                                              Lead_Routing__c = 'Not Applicable');
        insert campChannelObj;
        System.assertEquals(1,campChannelObj.Total_Value_Opportunities_Planned__c );
        //v3.0 Insert Custom Settings Data 
        CMAP_Queue_Settings__c objSetting = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6s0MAA',Queue_Name__c='Channel TQL Nurturing',Name='NA:TQL Nurturing:N');
        insert objSetting;
        CMAP_Queue_Settings__c objSettingeclerx = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6hl',Queue_Name__c='Channel_eClerx',Name='Channel_eClerx');
        insert objSettingeclerx;
        Id cleadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Assignment Complete','Lead',true);
        Lead leadObj1 = new Lead(lastName = 'Test Lead1',
                                 email ='testcmap@cmaptest.com',
                                 status = 'Accepted by Channel Partner',
                                 Partner_Lead_Status__c = 'Accepted',
                                 Phone='88967544',
                                 Account__c = listAcc[0].Id,                
                                 Campaign__c  = campChannelObj.Id,
                                 recordTypeId = cleadRTId,
                                 Budget__c = 'Yes',
                                 Country = 'US',
                                 Linking_Status__c = 'Accepted by Channel Partner;Accepted;Contact Not Influencer',
                                 Purchase_Timeframe__c ='Immediate',
                                 Company = 'Test Company');      
        insert leadObj1;
        /*
        Id dealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=newAcc.Id, 
                                                Deal_Registration_Status__c = 'Rejected',
                                                Rejection_Reason_Code__c = 'Incomplete data',
                                                //StageName='Lost, Cancelled - 0%',
                                                Channel_Lead_Id__c = leadObj1.Id,
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = dealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Justification_Statement__c = 'Justification Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'Country',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                                Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                StageName = 'Plan - 1%',
                                                //Probability = 0,
                                                Forecast_Category_Override__c = 'Omitted',
                                                CloseDate = System.Today() + 30 );        
        
        insert testOppty; */
        listOpp = [select id,AccountID,Channel_Lead_Id__c,StageName,Forecast_Category_Override__c,Amount from Opportunity limit 1];
        listOpp[0].Deal_Registration_Status__c= 'Approved';
        listOpp[0].Engagement_Type__c = 'Public Tender';
        listOpp[0].Total_Expected_Dell_Revenue__c =1919191;
        listOpp[0].Channel_Lead_Id__c = LeadObj1.Id;
        listOpp[0].Forecast_Category_Override__c = 'Omitted';
        listOpp[0].CloseDate = System.Today() + 30;
        update listOpp;
        TriggerExecutionController.setSkipAllTriggers(false); //v3.0
        TriggerExecutionController.setSkipLeadTriggers(true); //v3.0
        leadObj1.Related_opportunity_1__c = listOpp[0].Id;
        update leadObj1;
        TriggerExecutionController.setSkipLeadTriggers(false); //v3.0
        Test.startTest();
        try{
             
             delete listOpp[0];
        }
        catch(Exception e){        
            System.debug('Exception Occured while updating opportunity'+e);
        }
        Test.stopTest();
    }
    static testMethod void testChannelLeadUtilitiesRecalled2() {
        TriggerExecutionController.setSkipAllTriggers(true);
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        //      Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner');
        //      insert newAcc;
        listAcc = [select id,name,type from Account limit 1];
        listAcc[0].Type = 'Partner';
        update listAcc;
        Contact newContact = new Contact(AccountId = listAcc[0].Id, FirstName = 'First Name', LastName = 'Last Name', Email = 'FirstLast@gmail.com');
        insert newContact;
        Id channelCampRTId= IdLookupUtils.getRecordTypeId('Channel Partner Communications','Campaign',true); //v3.0
        list<Campaign> listCampaigns = new list<Campaign>();
        Campaign testCampaign = new Campaign(Name='Test RL Campaign',
                                             RecordTypeId = channelCampRTId,
                                             Campaign_Objective__c = 'LOB Conversion',
                                             Type='DM',
                                             Segment_Business_Unit__c='PUB',                                 
                                             StartDate=System.Today() - 12,
                                             EndDate=System.Today(),
                                             Description='This is Test RL Campaign',
                                             IsActive=true,
                                             Lead_Routing__c = 'Not Applicable');
        listCampaigns.add(testCampaign);
        Id campRTId = IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
        Campaign campChannelObj = new Campaign(Name='Campaign_CMAP',
                                               Campaign_Objective__c='Acquisition/Site Development',
                                               Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                                               Region__c='ABU',                        
                                               Follow_Up_Role__c='Account Executive',
                                               Description='Test',StartDate=system.today(),EndDate=system.today(),
                                               status='In Progress',
                                               recordTypeId = campRTId,
                                               Allocation_Source__c = 'Dell Allocation ABU',
                                               Nurture_Source__c = 'Dell Nurturing',
                                               Country_Code__c = 'BR - Brazil',
                                               Partner_Event_or_Campaign__c = False,
                                               IsActive = true,
                                               Total_Campaign_Targets_Planned__c = 1,
                                               Total_Value_Won_Opportunities_Planned__c = 1,
                                               Total_Value_Opportunities_Planned__c = 1,
                                               Lead_Routing__c = 'Not Applicable');
        listCampaigns.add(campChannelObj);
        
        insert listCampaigns;
        System.assertEquals(2, listCampaigns.size());
        //v3.0 Insert Custom Settings Data 
        CMAP_Queue_Settings__c objSetting = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6s0MAA',Queue_Name__c='Channel TQL Nurturing',Name='NA:TQL Nurturing:N');
        insert objSetting;
        CMAP_Queue_Settings__c objSettingeclerx = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6hl',Queue_Name__c='Channel_eClerx',Name='Channel_eClerx');
        insert objSettingeclerx;
        list<Lead> listlistleadtoInsertList = new list<Lead>();
        Id cleadRTId = IdLookupUtils.getRecordTypeId('Channel Lead - Assignment Complete','Lead',true);
        Lead leadObj1 = new Lead(lastName = 'Test Lead1',
                                 email ='testcmap@cmaptest.com',
                                 status = 'Accepted by Channel Partner',
                                 Phone='88967544',
                                 Called_Customer__c ='Yes',
                                 Sales_Qualified__c ='Qualified',
                                 Unqualified_Lead_Reason__c = 'Test',
                                 Campaign__c  = campChannelObj.Id,
                                 recordTypeId = cleadRTId,
                                 Budget__c = 'Yes',
                                 Country = 'US',
                                 Purchase_Timeframe__c ='Immediate',
                                 Company = 'Test Company',
                                 Related_Opportunity_Count__c = 1);
        listlistleadtoInsertList.add(leadObj1);
        Lead leadObj2 = new Lead(lastName = 'Test Lead1',
                                 email ='testcmap@cmaptest.com',
                                 status = 'Accepted by Channel Partner',
                                 Phone='88967544',
                                 Called_Customer__c ='Yes',
                                 Sales_Qualified__c ='Qualified',
                                 Unqualified_Lead_Reason__c = 'Test',
                                 Campaign__c  = campChannelObj.Id,
                                 recordTypeId = cleadRTId,
                                 Budget__c = 'Yes',
                                 Country = 'US',
                                 Purchase_Timeframe__c ='Immediate',
                                 Company = 'Test Company');      
        listlistleadtoInsertList.add(leadObj2);
        insert listlistleadtoInsertList;
        Relationship_Lead__c newRL = new Relationship_Lead__c(Contact__c = newContact.Id,
                                                              Campaign__c = testCampaign.Id,
                                                              CM_Source__c = leadObj1.Id,
                                                              Status__c = 'Requires Follow-up',
                                                              Inside_Sales_Manager__c = UserInfo.getUserId());
        insert newRL;
        leadObj1.Relationship_Lead__c = newRL.Id;
        leadObj2.Relationship_Lead__c = newRL.Id;
        update listlistleadtoInsertList;
        /*
        Id dealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=newAcc.Id, 
                                                Channel_Lead_Id__c = LeadObj1.Id,
                                                Deal_Registration_Status__c = 'New',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = dealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Justification_Statement__c = 'Justification Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'Country',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                Distributor_Name__c='Distribution',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                                Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                StageName = 'Plan - 1%',
                                                //Probability = 0,
                                                Forecast_Category_Override__c = 'Omitted',
                                                CloseDate = System.Today() + 30 );        
        
        
        insert testOppty;
        */
        listOpp = [select id,AccountID,Channel_Lead_Id__c,StageName,Forecast_Category_Override__c,Amount from Opportunity limit 1];
        listOpp[0].Deal_Registration_Status__c= 'Approved';
        listOpp[0].Engagement_Type__c = 'Public Tender';
        listOpp[0].Total_Expected_Dell_Revenue__c =1919191;
        listOpp[0].Channel_Lead_Id__c = LeadObj1.Id;
        listOpp[0].Forecast_Category_Override__c = 'Omitted';
        listOpp[0].CloseDate = System.Today() + 30;
        update listOpp;
        Test.startTest();
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        TriggerExecutionController.setSkipAllTriggers(false);
        //v3.0 : skipping Opportunity triggers by process flow
        ProcessFlowTriggerController.isTest = true;
        listOpp[0].Deal_Registration_Status__c = 'Submitted';
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        update listOpp[0];
        Test.stopTest();
    }

   /* static testMethod void ApprovedDealDeleteTest() { 
        TriggerExecutionController.setSkipAllTriggers(true);
        TriggerExecutionController.setSkipAccountTriggers(true);
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner');
        insert newAcc;
        TriggerExecutionController.setSkipAccountTriggers(False);
        
        //v3.0 Insert Custom Settings Data 
        CMAP_Queue_Settings__c objSetting = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6s0MAA',Queue_Name__c='Channel TQL Nurturing',Name='NA:TQL Nurturing:N');
        insert objSetting;
        CMAP_Queue_Settings__c objSettingeclerx = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6hl',Queue_Name__c='Channel_eClerx',Name='Channel_eClerx');
        insert objSettingeclerx;
        
        Id campchannelRTId = IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
        Campaign campChannelObj= new Campaign(Name='Campaign_CMAP',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='ABU',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                recordTypeId = campchannelRTId,
                Allocation_Source__c = 'Dell Allocation ABU',
                Nurture_Source__c = 'Dell Nurturing',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = False,
                IsActive = true,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1,
                Lead_Routing__c = 'Not Applicable');
        insert campChannelObj;
        Id cleadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Assignment Complete','Lead',true);
        Lead leadObj1 = new Lead(lastName = 'Test Lead1',
                email ='testcmap@cmaptest.com',
                status = 'Accepted by Channel Partner',
                Partner_Lead_Status__c = 'Accepted',
                Phone='88967544',
                Account__c = newAcc.Id,                
                Campaign__c  = campChannelObj.Id,
                recordTypeId = cleadRTId,
                Budget__c = 'Yes',
                Country = 'US',
                Purchase_Timeframe__c ='Immediate',
                Company = 'Test Company');      
        insert leadObj1;
        Id dealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=newAcc.Id, 
                                                Deal_Registration_Status__c = 'Approved',
                                                Competitor_Lost_To__c = 'Absolute',
                                              //  StageName='Lost, Cancelled - 0%',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = dealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Justification_Statement__c = 'Justification Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'Country',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                                Channel_Lead_Id__c = LeadObj1.Id,
                                                Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                StageName = 'Plan - 1%',
                                                CloseDate = System.Today() + 30 );      
        //v3.0 : skipping Opportunity triggers by process flow
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        
        TriggerExecutionController.setSkipAllTriggers(false);
        //v3.0 : skipping Opportunity triggers by process flow
        
        TriggerExecutionController.setSkipAllTriggers(false); //V3.0
        TriggerExecutionController.setSkipAllTriggers(true); //V3.0
        Test.startTest();
        ProcessFlowTriggerController.isTest = true;
        insert testOppty;
        leadObj1.Related_opportunity_1__c = testOppty.Id;
        update leadObj1;
        TriggerExecutionController.setSkipAllTriggers(false);
        
        
        
        try{
            delete testOppty;
        }
        catch(Exception e){        
            System.debug('Exception Occured while updating opportunity'+e);
        }
        Test.stopTest();
    }*/

    /*static testMethod void MultipleApprovedDealDeleteTest() { 
        TriggerExecutionController.setSkipAllTriggers(true);
        TriggerExecutionController.setSkipAccountTriggers(true);
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner');
        insert newAcc;
        TriggerExecutionController.setSkipAccountTriggers(False);
        
        //v3.0 Insert Custom Settings Data 
        CMAP_Queue_Settings__c objSetting = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6s0MAA',Queue_Name__c='Channel TQL Nurturing',Name='NA:TQL Nurturing:N');
        insert objSetting;
        CMAP_Queue_Settings__c objSettingeclerx = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6hl',Queue_Name__c='Channel_eClerx',Name='Channel_eClerx');
        insert objSettingeclerx;
        
        Id campchannelRTId = IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
        Campaign campChannelObj= new Campaign(Name='Campaign_CMAP',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='ABU',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                recordTypeId = campchannelRTId,
                Allocation_Source__c = 'Dell Allocation ABU',
                Nurture_Source__c = 'Dell Nurturing',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = False,
                IsActive = true,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1,
                Lead_Routing__c = 'Not Applicable');
        insert campChannelObj;
        Id cleadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Assignment Complete','Lead',true);
        Lead leadObj1 = new Lead(lastName = 'Test Lead1',
                email ='testcmap@cmaptest.com',
                status = 'Accepted by Channel Partner',
                Partner_Lead_Status__c = 'Accepted',
                Phone='88967544',
                Account__c = newAcc.Id,                
                Campaign__c  = campChannelObj.Id,
                recordTypeId = cleadRTId,
                Budget__c = 'Yes',
                Country = 'US',
                Purchase_Timeframe__c ='Immediate',
                Company = 'Test Company');      
        insert leadObj1;
        List<Opportunity> oppList = new List<opportunity>();
        Id dealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
        Opportunity testOppty1 = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=newAcc.Id, 
                                                Deal_Registration_Status__c = 'Approved',
                                                Competitor_Lost_To__c = 'Absolute',
                                                StageName='Lost, Cancelled - 0%',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = dealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Justification_Statement__c = 'Justification Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'Country',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                                Channel_Lead_Id__c = LeadObj1.Id,
                                                Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                //StageName = 'Plan - 1%',
                                                CloseDate = System.Today() + 30 );        
        //insert testOppty;
        oppList.add(testOppty1);
        Opportunity testOppty2 = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=newAcc.Id, 
                                                Deal_Registration_Status__c = 'Approved',
                                                Competitor_Lost_To__c = 'Absolute',
                                                StageName='Lost, Cancelled - 0%',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = dealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Justification_Statement__c = 'Justification Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'Country',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                                Channel_Lead_Id__c = LeadObj1.Id,
                                                Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                //StageName = 'Plan - 1%',
                                                CloseDate = System.Today() + 30 );        
        oppList.add(testOppty2); 
        //v3.0 : skipping Opportunity triggers by process flow
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        
        TriggerExecutionController.setSkipAllTriggers(false);
        //v3.0 : skipping Opportunity triggers by process flow
    
        TriggerExecutionController.setSkipAllTriggers(false);
        Test.startTest();
            ProcessFlowTriggerController.isTest = true;
         insert oppList; 
        leadObj1.Related_opportunity_1__c = oppList[0].Id;
        leadObj1.Related_opportunity_1__c = oppList[1].Id;
        update leadObj1;
        
        try{
           
            delete testOppty1;
        }
        catch(Exception e){        
            System.debug('Exception Occured while updating opportunity'+e);
        }
        Test.stopTest();
    }*/

    static testMethod void multiplerejectedDealTest() { 
        TriggerExecutionController.setSkipAllTriggers(true);
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        //       Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner');
        //       insert newAcc;
        listAcc = [select id,name,type from Account limit 1];
        listAcc[0].Type = 'Partner';
        update listAcc;
        //v3.0 Insert Custom Settings Data 
        CMAP_Queue_Settings__c objSetting = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6s0MAA',Queue_Name__c='Channel TQL Nurturing',Name='NA:TQL Nurturing:N');
        insert objSetting;
        CMAP_Queue_Settings__c objSettingeclerx = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6hl',Queue_Name__c='Channel_eClerx',Name='Channel_eClerx');
        insert objSettingeclerx;
        Id campchannelRTId = IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
        Campaign campChannelObj= new Campaign(Name='Campaign_CMAP',
                                              Campaign_Objective__c='Acquisition/Site Development',
                                              Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                                              Region__c='ABU',                        
                                              Follow_Up_Role__c='Account Executive',
                                              Description='Test',StartDate=system.today(),EndDate=system.today(),
                                              status='In Progress',
                                              recordTypeId = campchannelRTId,
                                              Allocation_Source__c = 'Dell Allocation ABU',
                                              Nurture_Source__c = 'Dell Nurturing',
                                              Country_Code__c = 'BR - Brazil',
                                              Partner_Event_or_Campaign__c = False,
                                              IsActive = true,
                                              Total_Campaign_Targets_Planned__c = 1,
                                              Total_Value_Won_Opportunities_Planned__c = 1,
                                              Total_Value_Opportunities_Planned__c = 1,
                                              Lead_Routing__c = 'Not Applicable');
        insert campChannelObj;
        System.assertEquals(1, campChannelObj.Total_Campaign_Targets_Planned__c );
        Id cleadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Assignment Complete','Lead',true);
        Lead leadObj1 = new Lead(lastName = 'Test Lead1',
                                 email ='testcmap@cmaptest.com',
                                 status = 'Accepted by Channel Partner',
                                 Partner_Lead_Status__c = 'Accepted',
                                 Phone='88967544',
                                 Account__c = listAcc[0].Id,                
                                 Campaign__c  = campChannelObj.Id,
                                 recordTypeId = cleadRTId,
                                 Budget__c = 'Yes',
                                 Country = 'US',
                                 Linking_Status__c = 'Accepted by Channel Partner;Accepted;Contact Not Influencer',
                                 Purchase_Timeframe__c ='Immediate',
                                 Company = 'Test Company');      
        insert leadObj1;
      //  List<Opportunity> listoppList = new List<Opportunity>();
        //Id dealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
        listOpp = [select id,AccountID,Channel_Lead_Id__c,StageName,Forecast_Category_Override__c,Amount from Opportunity limit 6];
    /*    for(integer inti=0; inti<=6; inti++){
            Opportunity testOppty1 = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty'+inti, 
                                                AccountId=newAcc.Id, 
                                                Deal_Registration_Status__c = 'Rejected',
                                                Rejection_Reason_Code__c = 'Incomplete data',
                                                //StageName='Lost, Cancelled - 0%',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = dealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Justification_Statement__c = 'Justification Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'Country',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                                Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                Channel_Lead_Id__c = LeadObj1.Id,
                                                StageName = 'Plan - 1%',
                                                //Probability = 0,
                                                Forecast_Category_Override__c = 'Omitted',
                                                CloseDate = System.Today() + 30 );        
        
            listoppList.add(testOppty1);    
             
        } */
        listOpp[0].Name='testOpportunityPlanRedirectPage Test Oppty';
        listOpp[0].Deal_Registration_Status__c= 'Approved';
        listOpp[0].Engagement_Type__c = 'Public Tender';
        listOpp[0].Total_Expected_Dell_Revenue__c =1919191;
        listOpp[0].Channel_Lead_Id__c = LeadObj1.Id;
        listOpp[0].Forecast_Category_Override__c = 'Omitted';
        listOpp[0].CloseDate = System.Today() + 30;
        //v3.0 : skipping Opportunity triggers by process flow
        ProcessFlowTriggerController.isTest = true;
        // insert listoppList;
        update listOpp;
        TriggerExecutionController.setSkipAllTriggers(false);
        TriggerExecutionController.setSkipLeadTriggers(true);
        leadObj1.Related_opportunity_1__c = listopp[0].Id;
        leadObj1.Related_opportunity_1__c = listopp[1].Id;
        leadObj1.Related_opportunity_1__c = listopp[2].Id;
        leadObj1.Related_opportunity_1__c = listopp[3].Id;
        leadObj1.Related_opportunity_1__c = listopp[4].Id;
        leadObj1.Related_opportunity_1__c = listopp[5].Id;
        update leadObj1;
        TriggerExecutionController.setSkipLeadTriggers(false);
        Test.startTest();
        try{
            
            delete listOpp;
        }
        catch(Exception e){        
            System.debug('Exception Occured while updating opportunity'+e);
        }
        Test.stopTest();
    }
    //v3.0 New method to cover the rest of related opportunitity utilities
    static testMethod void testRestofRelatedOpportunityUtilities() {
        TriggerExecutionController.setSkipAllTriggers(true);
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        //      Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner');
        //      insert newAcc;
        listAcc = [select id,name,type from Account limit 1];
        listAcc[0].Type = 'Partner';
        update listAcc;
        Contact newContact = new Contact(AccountId = listAcc[0].Id, FirstName = 'First Name', LastName = 'Last Name', Email = 'FirstLast@gmail.com');
        insert newContact;
        Id channelCampRTId= IdLookupUtils.getRecordTypeId('Channel Partner Communications','Campaign',true); //v3.0
        list<Campaign> listCampaigns = new list<Campaign>();
        Campaign testCampaign = new Campaign(Name='Test RL Campaign',
                                             RecordTypeId = channelCampRTId,
                                             Campaign_Objective__c = 'LOB Conversion',
                                             Type='DM',
                                             Segment_Business_Unit__c='PUB',                                 
                                             StartDate=System.Today() - 12,
                                             EndDate=System.Today(),
                                             Description='This is Test RL Campaign',
                                             IsActive=true,
                                             Lead_Routing__c = 'Not Applicable');
        listCampaigns.add(testCampaign);
        Id campRTId = IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
        Campaign campChannelObj = new Campaign(Name='Campaign_CMAP',
                                               Campaign_Objective__c='Acquisition/Site Development',
                                               Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                                               Region__c='ABU',                        
                                               Follow_Up_Role__c='Account Executive',
                                               Description='Test',StartDate=system.today(),EndDate=system.today(),
                                               status='In Progress',
                                               recordTypeId = campRTId,
                                               Allocation_Source__c = 'Dell Allocation ABU',
                                               Nurture_Source__c = 'Dell Nurturing',
                                               Country_Code__c = 'BR - Brazil',
                                               Partner_Event_or_Campaign__c = False,
                                               IsActive = true,
                                               Total_Campaign_Targets_Planned__c = 1,
                                               Total_Value_Won_Opportunities_Planned__c = 1,
                                               Total_Value_Opportunities_Planned__c = 1,
                                               Lead_Routing__c = 'Not Applicable');
        listCampaigns.add(campChannelObj);
        insert listCampaigns;
        System.assertEquals(1,listCampaigns[1].Total_Value_Opportunities_Planned__c );
        CMAP_Queue_Settings__c objSetting = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6s0MAA',Queue_Name__c='Channel TQL Nurturing',Name='NA:TQL Nurturing:N');
        insert objSetting;
        CMAP_Queue_Settings__c objSettingeclerx = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6hl',Queue_Name__c='Channel_eClerx',Name='Channel_eClerx');
        insert objSettingeclerx;
        list<Lead> listleadtoInsertList = new list<Lead>();
        Id cleadRTId = IdLookupUtils.getRecordTypeId('Channel Lead - Assignment Complete','Lead',true);
        Lead leadObj1 = new Lead(lastName = 'Test Lead1',
                                 email ='testcmap@cmaptest.com',
                                 status = 'Accepted by Channel Partner',
                                 Phone='88967544',
                                 Called_Customer__c ='Yes',
                                 Sales_Qualified__c ='Qualified',
                                 Unqualified_Lead_Reason__c = 'Test',
                                 Campaign__c  = campChannelObj.Id,
                                 recordTypeId = cleadRTId,
                                 Budget__c = 'Yes',
                                 Country = 'US',
                                 Purchase_Timeframe__c ='Immediate',
                                 Company = 'Test Company',
                                 Related_Opportunity_Count__c = 1);
        listleadtoInsertList.add(leadObj1);
        Lead leadObj2 = new Lead(lastName = 'Test Lead1',
                                 email ='testcmap@cmaptest.com',
                                 status = 'Accepted by Channel Partner',
                                 Phone='88967544',
                                 Called_Customer__c ='Yes',
                                 Sales_Qualified__c ='Qualified',
                                 Unqualified_Lead_Reason__c = 'Test',
                                 Campaign__c  = campChannelObj.Id,
                                 recordTypeId = cleadRTId,
                                 Budget__c = 'Yes',
                                 Country = 'US',
                                 Purchase_Timeframe__c ='Immediate',
                                 Company = 'Test Company');      
        listleadtoInsertList.add(leadObj2);
        insert listleadtoInsertList;
        Relationship_Lead__c newRL = new Relationship_Lead__c(Contact__c = newContact.Id,
                                                              Campaign__c = testCampaign.Id,
                                                              CM_Source__c = leadObj1.Id,
                                                              Status__c = 'Requires Follow-up',
                                                              Inside_Sales_Manager__c = UserInfo.getUserId());
        insert newRL;
        leadObj1.Relationship_Lead__c = newRL.Id;
        leadObj2.Relationship_Lead__c = newRL.Id;
        update listleadtoInsertList;
       /* 
        Id dealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=newAcc.Id, 
                                                Channel_Lead_Id__c = LeadObj1.Id,
                                                Deal_Registration_Status__c = 'New',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = dealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Justification_Statement__c = 'Justification Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'Country',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                                Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                StageName = 'Plan - 1%',
                                                //Probability = 0,
                                                Forecast_Category_Override__c = 'Omitted',
                                                CloseDate = System.Today() + 30 );        
        
        
        insert testOppty; */
        listOpp = [select id,AccountID,Channel_Lead_Id__c,StageName,Forecast_Category_Override__c,Amount from Opportunity limit 1];
        listOpp[0].Deal_Registration_Status__c= 'Approved';
        listOpp[0].Engagement_Type__c = 'Public Tender';
        listOpp[0].Total_Expected_Dell_Revenue__c =1919191;
        listOpp[0].Channel_Lead_Id__c = LeadObj1.Id;
        listOpp[0].Forecast_Category_Override__c = 'Omitted';
        listOpp[0].CloseDate = System.Today() + 30;
        update listOpp;
        TriggerExecutionController.setSkipAllTriggers(false);
        ProcessFlowTriggerController.isTest = true;
        Test.startTest();
        ChannelLeadUtilities.populateRelatedOpportunity(leadObj1, listOpp[0]); 
        ChannelLeadUtilities.isRelatedOpportunityExists(leadObj1, listOpp[0].Id); 
        ChannelLeadUtilities.clearRelatedOpportunity(leadObj1, listOpp[0]); 
        Test.stopTest();
    }
}