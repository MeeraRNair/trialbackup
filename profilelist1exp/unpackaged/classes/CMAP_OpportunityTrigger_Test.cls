/*
REVISION HISTORY
======================================================================================================================
Version    Author    Date            Release#    	CR#		Description
-------    ------    ----            --------    ---    -----------
1.0        Jiji    23-Nov-2012     	14.2        ---    		Test class for CMAP_OpportunityTrigger
2.0			Azwanti	15-March-2016	FY17-DCS-0401	12720	replace Campaign RT from 'Channel Campaign' to 'Campaign 2.0'.
3.0			Sui Yee	2-June-2016	    FY17-DCS-0701	13200	skip all trigger at ValidationTest_1.@isTest(SeeAllData=true)
*/

@isTest
private class CMAP_OpportunityTrigger_Test {   
    
    //v3.0 Setup test data for queue
    @testSetup static void populateCMAPCustomSetting() {
        CMAP_Queue_Settings__c eClerxQueue = new CMAP_Queue_Settings__c(Name = 'Channel_eClerx', Queue_Id__c = '00GA0000002y6hl', Queue_Name__c = 'Channel_eClerx');
        Database.insert(eClerxQueue);
    }

   static testMethod void insertOppTest() { 
        
        TriggerExecutionController.setSkipAllTriggers(true);//v3.0
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner');
        insert newAcc;   
        
        Id campRTId = IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
        Campaign campChannelObj= new Campaign(Name='Campaign_CMAP',
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
                Total_Value_Opportunities_Planned__c = 1);
        insert campChannelObj;
              
        List<Lead> leadtoInsertList = new List<Lead>();
        Id cleadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Assignment Complete','Lead',true);
        Lead leadObj1 = new Lead(lastName = 'Test Lead1',
                email ='testcmap@cmaptest.com',
                status = 'Accepted by Channel Partner',
                Phone='88967544',
                Called_Customer__c ='Yes',
                Sales_Qualified__c ='Qualified',
                //Relationship_Lead__c = '',                
                Campaign__c  = campChannelObj.Id,
                recordTypeId = cleadRTId,
                Budget__c = 'Yes',
                Country = 'US',
                Purchase_Timeframe__c ='Immediate',
                Company = 'Test Company');      
        leadtoInsertList.add(leadObj1);
        Lead leadObj2 = new Lead(lastName = 'Test Lead1',
                email ='testcmap@cmaptest.com',
                status = 'Accepted by Channel Partner',
                Phone='88967544',
                Called_Customer__c ='Yes',
                Sales_Qualified__c ='Qualified',
                //Relationship_Lead__c = '',                
                Campaign__c  = campChannelObj.Id,
                recordTypeId = cleadRTId,
                Budget__c = 'Yes',
                Country = 'US',
                Purchase_Timeframe__c ='Immediate',
                Company = 'Test Company');      
        leadtoInsertList.add(leadObj2);
        insert leadtoInsertList;         
         Test.startTest(); 
        Id DealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
       
        //TriggerExecutionController.setSkipOpportunityTriggers(true); //v2.0
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=newAcc.Id, 
                                                Channel_Lead_Id__c = LeadObj1.Id,
                                                Deal_Registration_Status__c= 'Approved',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = DealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Justification_Statement__c = 'Statement1',
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
                                                CloseDate = System.Today() + 30 );        
        
        
        insert testOppty;
        //TriggerExecutionController.setSkipOpportunityTriggers(false); //v2.0
      
       
        testOppty.Channel_Lead_Id__c = LeadObj2.Id;
        update testOppty;
        TriggerExecutionController.setSkipAllTriggers(false);//v3.0
        Test.stopTest();
         
    }
    static testMethod void ValidationTest_1() { 
        Test.startTest();
        TriggerExecutionController.setSkipAllTriggers(true);//v3.0
        //TriggerExecutionController.setSkipAccountTriggers(true); //v2.0
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner');
        insert newAcc;  
        //TriggerExecutionController.setSkipAccountTriggers(false); //v2.0
        
        //v2.0 - added        
        Contact newCont = new Contact(FirstName='TestContactFN9',
                 LastName='TestContactLN9',
                 accountId=newAcc.Id,
                 Email='TestContactEmail9@ust-global.com',
                 fax='01987645',
                 MobilePhone='0000019',
                 //Last_Operation_Performed__c = 'testing',
                 Phone='0000000');
        insert newCont;
        
        final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and Name like '%PRM%' order by CreatedDate desc limit 1];
                                               
        User partnerUser = new User(
                    Username='MyTest2' + System.currentTimeMillis() + '@dell.com',
                    Alias = 'tt2', 
                    Email='MyTest009@dell.com', 
                    FirstName='MyTestUser09', 
                    LastName='MyTestUser09',  
                    ProfileId = partnerProfiles.get(0).Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Badge_Number__c='909', 
                    isActive = TRUE,
                    Enable_Partner_Deal_Registration__c = TRUE, 
                    Enable_Partner_Lead_Management__c = TRUE, 
                    Enable_As_Partner_Lead_Super_User__c = TRUE,
                    ContactId = newCont.id);
        insert partnerUser;
        //v2.0 end
        
        Id campRTId= IdLookupUtils.getRecordTypeId('Direct Campaign','Campaign',true);
        Campaign campDirectObj= new Campaign(Name='Campaign_CMAP',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='ABU',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                //recordTypeId = campRTId,
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = TRUE,
                IsActive = true,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1,
                Partner_Campaign_Contact_Email__c = 'campaignCMAP@yahoo.com', //v2.0
                Partner_Campaign_Contact__c = partnerUser.Id ); //v2.0
        insert campDirectObj;
        Id leadRTId= IdLookupUtils.getRecordTypeId('Direct Lead 2.0','Lead',true); //v2.0 replace from Lead Qualification
        
        Lead leadObjs = new Lead(lastName = 'Test Lead1',
                email ='testcmap@cmaptest.com',
                status = 'Open',
                Phone='88967544',
                Campaign__c  = campDirectObj.Id,
                recordTypeId = leadRTId,
                Budget__c = 'Yes',
                Purchase_Timeframe__c ='Immediate',
                Company = 'Test Company',
                LeadSource = 'Employee Referral', //v2.0
                Lead_Type__c = 'Inbound'); //v2.0
        insert leadObjs;
        Id DealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
        
        //TriggerExecutionController.setSkipOpportunityTriggers(true); //v2.0
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=newAcc.Id, 
                                                //Channel_Lead_Id__c = LeadObjs.Id,
                                                Deal_Registration_Status__c= 'New',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = DealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Justification_Statement__c = 'Statement1',
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
                                                CloseDate = System.Today() + 30 );        
        
        
        insert testOppty; 
        TriggerExecutionController.setSkipAllTriggers(false);//v3.0
        //TriggerExecutionController.setSkipOpportunityTriggers(false); //v2.0
        Test.stopTest();      
        
        try{
            testOppty.Channel_Lead_Id__c = LeadObjs.Id;
            update testOppty;
        }
        catch(Exception e){        
            System.debug('Exception Occured while updating opportunity'+e);
        }
       

    }
   static testMethod void ValidationTest_2() { 
        Test.startTest();
        TriggerExecutionController.setSkipAllTriggers(true);
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner');
        insert newAcc;   
        
        Id campRTId = IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
        Campaign campChannelObj= new Campaign(Name='Campaign_CMAP',
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
                Total_Value_Opportunities_Planned__c = 1);
        insert campChannelObj;
               
        List<Lead> leadtoInsertList = new List<Lead>();
        Id cleadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete','Lead',true);
        Lead leadObj1 = new Lead(lastName = 'Test Lead1',
                email ='testcmap@cmaptest.com',
                status = 'Qualified - Channel Ready',
                Phone='88967544',
                //Called_Customer__c ='Yes',
                //Sales_Qualified__c ='Qualified',
                //Relationship_Lead__c = '',                
                Campaign__c  = campChannelObj.Id,
                recordTypeId = cleadRTId,
                Budget__c = 'Yes',
                Country = 'US',
                Purchase_Timeframe__c ='Immediate',
                Company = 'Test Company');      
       insert leadObj1;
       Id DealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=newAcc.Id, 
                                                //Channel_Lead_Id__c = LeadObj1.Id,
                                                Deal_Registration_Status__c= 'New',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = DealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Justification_Statement__c = 'Statement1',
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
                                                CloseDate = System.Today() + 30 );        
        
        
        insert testOppty;
        Test.stopTest();
        
        try{
            testOppty.Channel_Lead_Id__c = LeadObj1.Id;
            update testOppty;
        }
        catch(Exception e){        
            System.debug('Exception Occured while updating opportunity'+e);
        }
        
		TriggerExecutionController.setSkipAllTriggers(false);
    }
    static testMethod void ValidationTest_3() { 
        Test.startTest();
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
         // Skip all the triggers to avoid Too Many SOQL Query issue
      TriggerExecutionController.setSkipAllTriggers(true);
    
        Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner');
        insert newAcc;   
        
        Account newendUserAcc = new Account(name='Test End User Account');
        insert newendUserAcc ;
        
        Id campRTId = IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
        Campaign campChannelObj= new Campaign(Name='Campaign_CMAP',
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
                Total_Value_Opportunities_Planned__c = 1);
        insert campChannelObj;
        
        // Revert back the skip all triggers
    TriggerExecutionController.setSkipAllTriggers(false);
        
               
        List<Lead> leadtoInsertList = new List<Lead>();
        Id cleadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Assignment Complete','Lead',true);
        Lead leadObj1 = new Lead(lastName = 'Test Lead1',
                email ='testcmap@cmaptest.com',
                status = 'Accepted by Channel Partner',
                Phone='88967544',
                Account__c = newAcc.Id,                
                Campaign__c  = campChannelObj.Id,
                recordTypeId = cleadRTId,
                Budget__c = 'Yes',
                Country = 'US',
                Purchase_Timeframe__c ='Immediate',
                Company = 'Test Company');      
       insert leadObj1;
       Id DealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
        // Skip all the triggers to avoid Too Many SOQL Query issue
      TriggerExecutionController.setSkipAllTriggers(true);
    
       Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=newendUserAcc.Id, 
                                                //Channel_Lead_Id__c = LeadObj1.Id,
                                                Deal_Registration_Status__c= 'New',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = DealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Justification_Statement__c = 'Statement1',
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
                                                CloseDate = System.Today() + 30 );        
        
        
        insert testOppty;
        
        // Revert back the skip all triggers
    TriggerExecutionController.setSkipAllTriggers(false);
    
        Test.stopTest();
        
        try{
            testOppty.Channel_Lead_Id__c = LeadObj1.Id;
            update testOppty;
        }
        catch(Exception e){        
            System.debug('Exception Occured while updating opportunity'+e);
        }
        

    }
    static testMethod void ValidationTest_4() { 
        Test.startTest();
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
         // Skip all the triggers to avoid Too Many SOQL Query issue
      TriggerExecutionController.setSkipAllTriggers(true);
    
        Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner');
        insert newAcc;   
        
  // Revert back the skip all triggers
    TriggerExecutionController.setSkipAllTriggers(false);
        /*Account newendUserAcc = new Account(name='Test End User Account');
        insert newendUserAcc ;*/
        Id campRTId = IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
         // Skip all the triggers to avoid Too Many SOQL Query issue
      TriggerExecutionController.setSkipAllTriggers(true);
    
        Campaign campChannelObj= new Campaign(Name='Campaign_CMAP',
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
                Total_Value_Opportunities_Planned__c = 1);
        insert campChannelObj;
        
  // Revert back the skip all triggers
    TriggerExecutionController.setSkipAllTriggers(false);
               
        //List<Lead> leadtoInsertList = new List<Lead>();
       
        Id DealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
         // Skip all the triggers to avoid Too Many SOQL Query issue
      TriggerExecutionController.setSkipAllTriggers(true);
    
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=newAcc.Id, 
                                                //Channel_Lead_Id__c = LeadObj1.Id,
                                                Deal_Registration_Status__c= 'New',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = DealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Justification_Statement__c = 'Statement1',
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
                                                CloseDate = System.Today() + 30 );        
        
        
        insert testOppty;
        
  // Revert back the skip all triggers
    TriggerExecutionController.setSkipAllTriggers(false);
        
        Id cleadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Assignment Complete','Lead',true);
        Lead leadObj1 = new Lead(lastName = 'Test Lead1',
                email ='testcmap@cmaptest.com',
                status = 'Accepted by Channel Partner',
                Phone='88967544',
                Account__c = newAcc.Id,                
                Campaign__c  = campChannelObj.Id,
                recordTypeId = cleadRTId,
                Budget__c = 'Yes',
                Country = 'US',
                Related_Opportunity__c = testOppty.Id,
                Purchase_Timeframe__c ='Immediate',
                Company = 'Test Company');      
        insert leadObj1;
        Test.stopTest();
        
        try{
            testOppty.Channel_Lead_Id__c = LeadObj1.Id;
            update testOppty;
        }
        catch(Exception e){        
            System.debug('Exception Occured while updating opportunity'+e);
        }
        

    }
    static testMethod void ValidationTest_5() { 
        TriggerExecutionController.setSkipAllTriggers(true);//v3.0
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner');
        insert newAcc;   
        Id campRTId = IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
        Campaign campChannelObj= new Campaign(Name='Campaign_CMAP',
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
                Total_Value_Opportunities_Planned__c = 1);
        insert campChannelObj;
        Test.startTest();
        Id DealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=newAcc.Id, 
                                                //Channel_Lead_Id__c = LeadObj1.Id,
                                                Deal_Registration_Status__c= 'New',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = DealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Justification_Statement__c = 'Statement1',
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
                                                CloseDate = System.Today() + 30 );        
        
        
        insert testOppty;
        Id cleadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Assignment Complete','Lead',true);
        Lead leadObj1 = new Lead(lastName = 'Test Lead1',
                email ='testcmap@cmaptest.com',
                status = 'Inactive',
                Phone='88967544',
                Account__c = newAcc.Id,                
                Campaign__c  = campChannelObj.Id,
                recordTypeId = cleadRTId,
                Budget__c = 'Yes',
                Country = 'US',
                Purchase_Timeframe__c ='Immediate',
                Company = 'Test Company');      
        insert leadObj1;
        Test.stopTest();
        
        try{
            testOppty.Channel_Lead_Id__c = LeadObj1.Id;
            update testOppty;
        }
        catch(Exception e){        
            System.debug('Exception Occured while updating opportunity'+e);
        }
        
       TriggerExecutionController.setSkipAllTriggers(false);
    }
    static testMethod void ValidationTest_6() { 
        
        Test.startTest();
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        
        // Skip all the triggers to avoid Too Many SOQL Query issue
      TriggerExecutionController.setSkipAllTriggers(true);
        Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner');
        insert newAcc;
        // Revert back the skip all triggers
    TriggerExecutionController.setSkipAllTriggers(false);
        /*Contact newCont = new Contact(FirstName='MyTestContact3',
                 LastName='MyTestContact3',
                 accountId=newAcc.Id, 
                 Status__c = 'Marketing Suspect',
                 Email='MyTestContactEmail_3@ust-global.com',
                 fax='1234567',
                 MobilePhone='0987654',              
                 Last_Operation_Performed__c = 'testing');
        insert newCont;
        Campaign campDirectObj= new Campaign(Name='Campaign_CMAP',
                //Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='ABU',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = TRUE,
                IsActive = true,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1);
         insert campDirectObj;
         Id leadRTId= IdLookupUtils.getRecordTypeId('Lead Qualification','Lead',true);
         Lead leadObj = new Lead(lastName = 'Test Lead1',
                email ='testcmap@cmaptest.com',
                status = 'Open',
                Phone='88967544',
                Campaign__c  = campDirectObj.Id,
                recordTypeId = leadRTId,
                Budget__c = 'Yes',
                Purchase_Timeframe__c ='Immediate',
                Sales_ready_Lead__c = TRUE,
                Company = 'Test Company');
        insert leadObj;
              
        Relationship_Lead__c rlObj = new Relationship_Lead__c(
            Contact__c = newCont.Id,
            Lead_ID_Do_Not_Edit__c = leadObj.Id,
            Campaign_ID_LinkTracker__c = campDirectObj.Id,
            Campaign__c = campDirectObj.Id,
            Supporting_Information__c = 'Sample Supporting Info',
            Solution_ID__c = '1234',
            Sales_Comments__c= 'Sample Sales Comments',
            Questions_Comments__c= 'Sample Questions Comments',
            Purchase_Timeframe__c = 'Immediately',
            Purchase_Influence_Over__c= 'Sample Purchase',
            Next_Steps__c= 'Sample next Steps',
            Marketing_Comments__c= 'Sample Marketing Comments',
            Industry_Vertical_Need__c = 'Sample Industry',
            IT_Process_Simplification__c = 'Sample IT Simplification',
            End_user_Productivity__c = 'Sample End User',
            Employee__c = '1 - 99',
            Dell_can_contact_me_in_the_future__c = 'Yes',
            Dell_Existing_Customer__c = 'Yes',
            Decision_Making_Role__c = 'Influencer',
            Data_Center_Optimization__c = 'Sample Data Center'
            );
        Test.startTest();
        insert rlObj;*/
        Id campchannelRTId = IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
        // Skip all the triggers to avoid Too Many SOQL Query issue
      TriggerExecutionController.setSkipAllTriggers(true);
      
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
                Total_Value_Opportunities_Planned__c = 1);
        insert campChannelObj;
        // Revert back the skip all triggers
    TriggerExecutionController.setSkipAllTriggers(false);
        
        Id DealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
        // Skip all the triggers to avoid Too Many SOQL Query issue
      TriggerExecutionController.setSkipAllTriggers(true);
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=newAcc.Id, 
                                                //Channel_Lead_Id__c = LeadObj1.Id,
                                                Deal_Registration_Status__c= 'New',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = DealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Justification_Statement__c = 'Statement1',
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
                                                CloseDate = System.Today() + 30 );        
        
        
        insert testOppty;
        // Revert back the skip all triggers
    TriggerExecutionController.setSkipAllTriggers(false);
        
        Id cleadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Assignment Complete','Lead',true);
        Lead leadObj1 = new Lead(lastName = 'Test Lead1',
                email ='testcmap@cmaptest.com',
                status = 'Accepted by Channel Partner',
                Partner_Lead_Status__c = 'Accepted',
                Called_customer__c = 'Yes',
                Sales_Qualified__c = 'Unqualified',
                Unqualified_Lead_Reason__c = 'Contact Not Influencer',
                Phone='88967544',
                Account__c = newAcc.Id,                
                Campaign__c  = campChannelObj.Id,
                recordTypeId = cleadRTId,
                Budget__c = 'Yes',
                Country = 'US',
                //Relationship_Lead__c = rlObj.Id,                
                Purchase_Timeframe__c ='Immediate',
                Company = 'Test Company');      
        insert leadObj1;
        Test.stopTest();
        
        try{
            testOppty.Channel_Lead_Id__c = LeadObj1.Id;
            update testOppty;
        }
        catch(Exception e){        
            System.debug('Exception Occured while updating opportunity'+e);
        }
        

    }
     static testMethod void ValidationTest_7() { 
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        // Skip all the triggers to avoid Too Many SOQL Query issue
      TriggerExecutionController.setSkipAllTriggers(true);
        Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner');
        insert newAcc;
        // Revert back the skip all triggers
    TriggerExecutionController.setSkipAllTriggers(false);
        Test.startTest();
        // Skip all the triggers to avoid Too Many SOQL Query issue
      TriggerExecutionController.setSkipAllTriggers(true);

		//v2.0 - added
        Contact newCont = new Contact(FirstName='TestContactFN9',
                 LastName='TestContactLN9',
                 accountId=newAcc.Id,
                 Email='TestContactEmail9@ust-global.com',
                 fax='01987645',
                 MobilePhone='0000019',
                 //Last_Operation_Performed__c = 'testing',
                 Phone='0000000');
        insert newCont;
         
        final List<Profile> partnerProfiles = [select Id, Name from Profile 
                                               where UserType = 'PowerPartner' and Name like '%PRM%' order by CreatedDate desc limit 1];
                                               
        User partnerUser = new User(
                    Username='MyTest2' + System.currentTimeMillis() + '@dell.com',
                    Alias = 'tt2', 
                    Email='MyTest009@dell.com', 
                    FirstName='MyTestUser09', 
                    LastName='MyTestUser09',  
                    ProfileId = partnerProfiles.get(0).Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Badge_Number__c='909', 
                    isActive = TRUE,
                    Enable_Partner_Deal_Registration__c = TRUE, 
                    Enable_Partner_Lead_Management__c = TRUE, 
                    Enable_As_Partner_Lead_Super_User__c = TRUE,
                    ContactId = newCont.id
                );
        insert partnerUser;
        //v2.0 end
         
        Campaign campDirectObj= new Campaign(Name='Campaign_CMAP',
                //Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='ABU',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = TRUE,
                IsActive = true,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1,
                Partner_Campaign_Contact_Email__c = 'campaignCMAP@yahoo.com', //v2.0
                Partner_Campaign_Contact__c = partnerUser.Id ); //v2.0                             
         insert campDirectObj;
         // Revert back the skip all triggers
    TriggerExecutionController.setSkipAllTriggers(false);
         Id leadRTId= IdLookupUtils.getRecordTypeId('Direct Lead 2.0', 'Lead', true);//v2.0 replace from Lead Qualification
         Lead leadObj = new Lead(lastName = 'Test Lead1',
                email ='testcmap@cmaptest.com',
                status = 'Open',
                Phone='88967544',
                Campaign__c  = campDirectObj.Id,
                recordTypeId = leadRTId,
                Budget__c = 'Yes',
                Purchase_Timeframe__c ='Immediate',
                Sales_ready_Lead__c = TRUE,
                Company = 'Test Company',
                LeadSource = 'Employee Referral', //v2.0
                Lead_Type__c = 'Inbound'); //v2.0
        insert leadObj;
              
        Id campchannelRTId = IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
        // Skip all the triggers to avoid Too Many SOQL Query issue
      TriggerExecutionController.setSkipAllTriggers(true);
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
                Total_Value_Opportunities_Planned__c = 1);
        insert campChannelObj;
        // Revert back the skip all triggers
    TriggerExecutionController.setSkipAllTriggers(false);
        
        Id DealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
        // Skip all the triggers to avoid Too Many SOQL Query issue
      TriggerExecutionController.setSkipAllTriggers(true);
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=newAcc.Id, 
                                                //Channel_Lead_Id__c = LeadObj1.Id,
                                                Deal_Registration_Status__c= 'New',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = DealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Justification_Statement__c = 'Statement1',
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
                                                CloseDate = System.Today() + 30 );        
        
        
        insert testOppty;
        // Revert back the skip all triggers
    TriggerExecutionController.setSkipAllTriggers(false);
        Id cleadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Assignment Complete','Lead',true);
        Lead leadObj1 = new Lead(lastName = 'Test Lead1',
                email ='testcmap@cmaptest.com',
                status = 'Accepted by Channel Partner',
                Partner_Lead_Status__c = 'Accepted',
                Called_customer__c = 'Yes',
                Sales_Qualified__c = 'Unqualified',
                Unqualified_Lead_Reason__c = 'Contact Not Influencer',
                Phone='88967544',
                Account__c = newAcc.Id,                
                Campaign__c  = campChannelObj.Id,
                recordTypeId = cleadRTId,
                Budget__c = 'Yes',
                Country = 'US',
                //Segment_Lead__c = leadObj.Id,                
                Purchase_Timeframe__c ='Immediate',
                Company = 'Test Company');      
        insert leadObj1;
        Test.stopTest();
        try{
            testOppty.Channel_Lead_Id__c = LeadObj1.Id;
            update testOppty;
        }
        catch(Exception e){        
            System.debug('Exception Occured while updating opportunity'+e);
        }
        

    }
    static testMethod void ApprovedDealTest() { 
        Test.startTest();
        TriggerExecutionController.setSkipAllTriggers(true);//v3.0
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        
         // Skip all the triggers to avoid Too Many SOQL Query issue
      //TriggerExecutionController.setSkipAllTriggers(true);
      
        Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner');
        insert newAcc;
        // Revert back the skip all triggers
    //TriggerExecutionController.setSkipAllTriggers(false);
    
        Id campchannelRTId = IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
         // Skip all the triggers to avoid Too Many SOQL Query issue
      //TriggerExecutionController.setSkipAllTriggers(true);
      
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
                Total_Value_Opportunities_Planned__c = 1);
        insert campChannelObj;
        
        // Revert back the skip all triggers
    //TriggerExecutionController.setSkipAllTriggers(false);
        
        Id DealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
         // Skip all the triggers to avoid Too Many SOQL Query issue
      //TriggerExecutionController.setSkipAllTriggers(true);
      
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=newAcc.Id, 
                                                Deal_Registration_Status__c = 'Approved',
                                                Competitor_Lost_To__c = 'Absolute',
                                                StageName='Lost, Cancelled - 0%',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = DealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Justification_Statement__c = 'Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'Country',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                                Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                //StageName = 'Plan - 1%',
                                                CloseDate = System.Today() + 30 );        
        
        
        insert testOppty;
        
        // Revert back the skip all triggers
    //TriggerExecutionController.setSkipAllTriggers(false);
    
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
        Test.stopTest();

        try{
            testOppty.Channel_Lead_Id__c = LeadObj1.Id;
            update testOppty;
        }
        catch(Exception e){        
            System.debug('Exception Occured while updating opportunity'+e);
        }
        TriggerExecutionController.setSkipAllTriggers(false);

    }
    static testMethod void rejectedDealTest() { 
        Test.startTest();
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        
        // Skip all the triggers to avoid Too Many SOQL Query issue
      TriggerExecutionController.setSkipAllTriggers(true);
      
        Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner');
        insert newAcc;
        // Revert back the skip all triggers
    TriggerExecutionController.setSkipAllTriggers(false);
        
              
        Id campchannelRTId = IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
        // Skip all the triggers to avoid Too Many SOQL Query issue
      TriggerExecutionController.setSkipAllTriggers(true);
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
                Total_Value_Opportunities_Planned__c = 1);
        insert campChannelObj;
          // Skip all the triggers to avoid Too Many SOQL Query issue
      TriggerExecutionController.setSkipAllTriggers(true);
        
        Id DealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
        // Skip all the triggers to avoid Too Many SOQL Query issue
      TriggerExecutionController.setSkipAllTriggers(true);
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=newAcc.Id, 
                                                Deal_Registration_Status__c = 'Rejected',
                                                Rejection_Reason_Code__c = 'Revenue does not meet threshold',
                                                //StageName='Lost, Cancelled - 0%',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = DealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Justification_Statement__c = 'Statement1',
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
                                                CloseDate = System.Today() + 30 );        
        
        
        insert testOppty;
          // Skip all the triggers to avoid Too Many SOQL Query issue
      TriggerExecutionController.setSkipAllTriggers(true);
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
        Test.stopTest();
        
        try{
            testOppty.Channel_Lead_Id__c = LeadObj1.Id;
            update testOppty;
        }
        catch(Exception e){        
            System.debug('Exception Occured while updating opportunity'+e);
        }
        

    }
    static testMethod void rejectDealTest() { 
        Test.startTest();
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
         // Skip all the triggers to avoid Too Many SOQL Query issue
      TriggerExecutionController.setSkipAllTriggers(true);
        Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner');
        insert newAcc;
        // Revert back the skip all triggers
    TriggerExecutionController.setSkipAllTriggers(false);
              
        Id campchannelRTId = IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
         // Skip all the triggers to avoid Too Many SOQL Query issue
      TriggerExecutionController.setSkipAllTriggers(true);
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
                Total_Value_Opportunities_Planned__c = 1);
        insert campChannelObj;
        // Revert back the skip all triggers
    TriggerExecutionController.setSkipAllTriggers(false);
        
        Id DealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
         // Skip all the triggers to avoid Too Many SOQL Query issue
      TriggerExecutionController.setSkipAllTriggers(true);
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=newAcc.Id, 
                                                Deal_Registration_Status__c = 'Rejected',
                                                Rejection_Reason_Code__c = 'Incomplete data',
                                                //StageName='Lost, Cancelled - 0%',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = DealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Justification_Statement__c = 'Statement1',
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
                                                CloseDate = System.Today() + 30 );        
        
        
        insert testOppty;
        // Revert back the skip all triggers
    TriggerExecutionController.setSkipAllTriggers(false);
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
                Linking_Status__c = 'Accepted by Channel Partner;Accepted;Contact Not Influencer',
                Purchase_Timeframe__c ='Immediate',
                Company = 'Test Company');      
        insert leadObj1;
        Test.stopTest();
        
        try{
            testOppty.Channel_Lead_Id__c = LeadObj1.Id;
            update testOppty;
        }
        catch(Exception e){        
            System.debug('Exception Occured while updating opportunity'+e);
        }
        

    }
    static testMethod void recallDealTest() { 
        Test.startTest();
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
         // Skip all the triggers to avoid Too Many SOQL Query issue
      TriggerExecutionController.setSkipAllTriggers(true);
        Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner');
        insert newAcc;
        // Revert back the skip all triggers
    TriggerExecutionController.setSkipAllTriggers(false);
              
        Id campchannelRTId = IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
         // Skip all the triggers to avoid Too Many SOQL Query issue
      TriggerExecutionController.setSkipAllTriggers(true);
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
                Total_Value_Opportunities_Planned__c = 1);
        insert campChannelObj;
        // Revert back the skip all triggers
    TriggerExecutionController.setSkipAllTriggers(false);
        
        Id DealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
         // Skip all the triggers to avoid Too Many SOQL Query issue
      TriggerExecutionController.setSkipAllTriggers(true);
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=newAcc.Id, 
                                                Deal_Registration_Status__c = 'Recalled',
                                                //Rejection_Reason_Code__c = 'Registered to another Partner',
                                                //StageName='Lost, Cancelled - 0%',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = DealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Justification_Statement__c = 'Statement1',
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
                                                CloseDate = System.Today() + 30 );        
        
        
        insert testOppty;
        // Revert back the skip all triggers
    TriggerExecutionController.setSkipAllTriggers(false);
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
        Test.stopTest();
        try{
            testOppty.Channel_Lead_Id__c = LeadObj1.Id;
            update testOppty;
        }
        catch(Exception e){        
            System.debug('Exception Occured while updating opportunity'+e);
        }
       

    }
}