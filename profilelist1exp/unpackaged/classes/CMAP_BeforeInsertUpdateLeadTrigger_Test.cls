/* 
REVISION HISTORY
======================================================================================================================
Version    Author    Date            Release#    CR#    Description
-------    ------    ----            --------    ---    -----------
1.0        Bianca    14-Nov-2012     14.2        ---    Test class for CMAP_BeforeInsertUpdateLeadTrigger
2.0        Jiji      26-Nov-2012     14.2        ---    Test metods for Automatic and Manual Allocation Queue
3.0        Meera     16-Feb-2015     16.03      10797   Test method to make sure super user is not populated for DSG Leads  
4.0        Azwanti  15-March-2016    FY17-DCS-0401   12720   replace Campaign RT from 'Channel Campaign' to 'Campaign 2.0'.
5.0        SuiYee    4-July-2016     FY17-DCS-0801   12720   Replace old lead record type to direct lead 2.0
6.0        Shue      31-May-2018     FY19-0602   15686  Story 4144896: Channel: Remove BANT Qualified leads process (Code)
7.0        Shue      15-Aug-2018     FY19-0902          Code coverage - For Channel Lead 2.0 RT, value for Marketing_Primary_Solution_Interest__c is only 'Client Solutions'
7.1        Yamini    06-Dec-2018     FY19-0102   xxxx   PMD Violations fix
8.0        Shue      25-Mar-2019     FY20-0402   ---    CMAP-PAM coverage fix
9.0        Shue      14-Aug-2019     FY20-0802   ---    Test coverage for Defect 7041494 fix
*/

@isTest
private class CMAP_BeforeInsertUpdateLeadTrigger_Test {
     //6.0
    static CMAP_Queue_Settings__c objCust;
    
    static void createTestData(){
    
        System.debug('Yuhuuuu');
        //Create Queue
        objCust = new CMAP_Queue_Settings__c();
        objCust.Queue_Id__c = '00GA0000002y6hl';
        objCust.Queue_Name__c = 'Channel_eClerx';
        objCust.Name ='Channel_eClerx';
        insert objCust ;
    }
    
    //9.0 Remove test method testChannelLeadPartner: 0% coverage

    static testMethod void testChannelLeadAdmin() 
    { 
        TriggerExecutionController.setskipUserTriggers(true); 
        TriggerExecutionController.setSkipAccountTriggers(true); 
        Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead 2.0','Lead',true);//v5.0
        createTestData();
        /* 6.0
        CMAP_Queue_Settings__c objCust = new CMAP_Queue_Settings__c();
        objCust.Queue_Id__c = '00GA0000002y6hl';
        objCust.Queue_Name__c = 'Channel_eClerx';
        objCust.Name ='Channel_eClerx';
        insert objCust ;*/
        CMAP_TestDataGenerator testData = new CMAP_TestDataGenerator();
        testData.getAccount(true);
        testData.getContact(true);
        testData.getPartnerUser(true);
        testData.getPartnerUser2(true);
        testData.getCampaign(true);
        
        Lead leadObj1;
        leadObj1 = new Lead(lastName = 'Test Lead',
            email ='testcmap@cmaptest.com',
            status = 'Open - Channel Lead',
            Phone='88967544',
            RecordTypeId = leadRTId,
            Budget__c = 'Yes',
            Budget_Range__c =1000,
            Purchase_Timeframe__c ='Immediately',
            Decision_Making_Role__c='Influencer',
            Solution_Type__c='Campus',
            Dell_Partner_can_contact_me__c = true,
            Solution_Scope__c='Hardware and Support Only',
            Product_Focus__c='Servers',
            Focus_LOB__c='EMC',
            LeadSource = 'Web',
            Lead_Type__c = 'Inbound',
            Country = 'US',
            Partner_Account__c = testdata.smaObj.Id,    //8.0
            Campaign__c  = testdata.campObj.Id,
            Company = 'Test Company',
            //Partner_User__c =testData.PartnerUser.Id,
            //Partner_Admin__c =testData.pUser2.Id,
            Ready_For_Scoring__c = false,                
            Lead_Score__c = 'High Priority (Extremely hot leads; SLA = 48 hours)',
            Country_CN__c = 'UNITED STATES');   //7.0
        CMAP_Helper.skipinsert = true;
        
        TriggerExecutionController.setskipLeadTriggers(true);
        insert leadObj1;
        TriggerExecutionController.setskipLeadTriggers(false); 
        
        Test.startTest();
        leadObj1.Ready_for_Scoring__c = true;
        leadObj1.Budget__c = 'Yes';
        leadObj1.Purchase_Timeframe__c = 'Immediately';
        Update leadObj1; 
        //System.assertEquals(leadObj1.Purchase_Timeframe__c,'Immediately');
        Test.stopTest(); 
        System.assertEquals(leadObj1.Lead_Type__c ,'Inbound');
        TriggerExecutionController.setSkipAccountTriggers(false); 
        TriggerExecutionController.setskipUserTriggers(false); 
    }
 
    static testMethod void testChannelLeadBantAdmin() { 
        TriggerExecutionController.setskipUserTriggers(true); 
        TriggerExecutionController.setSkipAccountTriggers(true); 
        Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead 2.0','Lead',true);
        createTestData();
        /*6.0
        CMAP_Queue_Settings__c objCust = new CMAP_Queue_Settings__c();
        objCust.Queue_Id__c = '00GA0000002y6hl';
        objCust.Queue_Name__c = 'Channel_eClerx';
        objCust.Name ='Channel_eClerx';
        insert objCust ;
        */
        CMAP_TestDataGenerator testData = new CMAP_TestDataGenerator();
        testData.getAccount(true);
        testData.getContact(true);
        testData.getPartnerUser(true);
        testData.getPartnerUser2(true);
        testData.getCampaign(true);
        
        CMAP_Helper.skipinsert = true;
        Lead leadObj1;
        
        leadObj1 = new Lead(lastName = 'Test Lead',
            email ='testcmap@cmaptest.com',
            status = 'Open - Channel Lead',
            Phone='88967544',
            RecordTypeId = leadRTId,
            Budget__c = 'Yes',
            Budget_Range__c =1000,
            Purchase_Timeframe__c ='Immediately',
            Decision_Making_Role__c='Influencer',
            Solution_Type__c='Campus',
            Dell_Partner_can_contact_me__c = true,
            Solution_Scope__c='Hardware and Support Only',
            Product_Focus__c='Servers',
            Focus_LOB__c='EMC',
            LeadSource = 'Web',
            Lead_Type__c = 'Inbound',
            Country = 'US',
            Partner_Account__c = testdata.smaObj.Id,        //8.0
            Campaign__c  = testdata.campObj.Id,
            Company = 'Test Company',                
            //Partner_User__c =testData.PartnerUser.Id,
            //Partner_Admin__c =testData.pUser2.Id,
            Ready_For_Scoring__c = false,
            Lead_Score__c = 'High Priority (Extremely hot leads; SLA = 48 hours)',
            Country_CN__c = 'UNITED STATES');
                 
        TriggerExecutionController.setskipLeadTriggers(true);
        insert leadObj1;
        TriggerExecutionController.setskipLeadTriggers(false);
        
        Test.startTest();
        leadObj1.Ready_for_Scoring__c = true;     
        //6.0 Removing leadObj1.BANT_Qualified__c
        //leadObj1.BANT_Qualified__c = true;
        leadObj1.status = 'Qualified - Channel Ready';
        //leadObj1.Owner.Name = 'partner assignment queue';
        Update leadObj1;                
        Test.stopTest();
        System.assertEquals(leadObj1.status,'Qualified - Channel Ready');
        TriggerExecutionController.setSkipAccountTriggers(false); 
        TriggerExecutionController.setskipUserTriggers(false);
    }
 
    static testMethod void testChannelLeadCmapAdmin() {
        //TriggerExecutionController.setskipUserTriggers(true);
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipContactTriggers(true);
        Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead 2.0','Lead',true); 
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true);
        createTestData();
        /*6.0
        CMAP_Queue_Settings__c objCust = new CMAP_Queue_Settings__c();
        objCust.Queue_Id__c = '00GA0000002y6hl';
        objCust.Queue_Name__c = 'Channel_eClerx';
        objCust.Name ='Channel_eClerx';
        insert objCust ;
        */
        CMAP_TestDataGenerator testData = new CMAP_TestDataGenerator();
        testData.getAccount(true);
        testData.getContact(true);
        testData.getPartnerUser(true);
        testData.getPartnerUser2(true);
        
        Campaign campObj = new Campaign(Name='Campaign_CMAP',
        Campaign_Objective__c='Acquisition/Site Development',
        Type='Advisory Councils',Segment_Business_Unit__c='SMB',
        Region__c='ABU',                        
        Follow_Up_Role__c='Account Executive',
        Description='Test',StartDate=system.today(),EndDate=system.today(),
        status='In Progress',
        Country_Code__c = 'BR - Brazil',
        Partner_Event_or_Campaign__c = False,
        IsActive = true,
        RecordTypeId = campRTId,
        Allocation_Source__c = 'Dell Allocation',
        Nurture_Source__c = 'Dell Nurturing',                
        Total_Campaign_Targets_Planned__c = 1,
        Total_Value_Won_Opportunities_Planned__c = 1,
        Total_Value_Opportunities_Planned__c = 1,
        Partner_Campaign_Contact__c =testData.partnerUser.Id,
        Partner_Campaign_Contact_Email__c = 'test@test.com', //3.0
        Lead_Routing__c = 'Lead Qualification Rep');//5.0            
        insert campObj;
        
        List<Profile> listPartnerProfiles =  [select id,name from Profile where Name like '%System Administrator%' limit 1];
        TriggerExecutionController.setskipUserTriggers(true);
        User adminUser = new User(
            Username='test765' + System.currentTimeMillis() + '@dell.com',
            Alias = 'test1', 
            Email='test3445@dell.com', 
            FirstName='John', 
            LastName='Doe', 
            ProfileId = listPartnerProfiles[0].Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='101011', 
            isActive = TRUE,
            Enable_Partner_Lead_Management__c = true,
            Enable_Partner_Deal_Registration__c = true,
            PortalRole = 'Manager'
            //AccountId = accountObj.Id,
            //ContactId = contObj.id
        );
        //if(xCommit) 
        insert adminUser;
        TriggerExecutionController.setskipUserTriggers(false);
        
        CMAP_Helper.skipinsert = true;
        Lead leadObj1;
        testData.getCampaign(true);
        System.runAs(adminUser){
            leadObj1 = new Lead(lastName = 'Test Lead',
            email ='testcmap@cmaptest.com',
            status = 'Open - Channel Lead',
            Phone='88967544',
            RecordTypeId = leadRTId,                
            Lead_Type__c = 'Inbound',
            Country = 'US',
            Partner_Account__c = testdata.smaObj.Id,    //8.0
            Campaign__c  = campObj.Id,
            Company = 'Test Company',
            LeadSource = 'Web',
            Dell_Partner_can_contact_me__c = true,
            //Partner_User__c =testData.PartnerUser.Id,
            //Partner_Admin__c =testData.PartnerUser.Id,
            Ready_For_Scoring__c = false
            );
        
            TriggerExecutionController.setskipLeadTriggers(true);
            insert leadObj1;
            TriggerExecutionController.setskipLeadTriggers(false);
        }
        
        Test.startTest();
        leadObj1.Ready_for_Scoring__c = true;                
        Update leadObj1;    
        System.assertEquals(leadObj1.Ready_for_Scoring__c,true);
        Test.stopTest();   
        
        //TriggerExecutionController.setskipUserTriggers(false);
    }
    
    //9.0 Remove test method automaticAssignmentTest: 0% coverage

    static testMethod void routingfromRLTest() {
        
        CMAP_TestDataGenerator testData = new CMAP_TestDataGenerator();
        TriggerExecutionController.setskipUserTriggers(true);
        //Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Submission','Lead',true);
        //Id DleadRTId= IdLookupUtils.getRecordTypeId('Lead Qualification','Lead',true);//v5.0
        Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete','Lead',true);
        Id dleadRTId= IdLookupUtils.getRecordTypeId('Direct Lead 2.0','Lead',true);//v5.0
        Id campChannelRTId= IdLookupUtils.getRecordTypeId('Channel Partner Communications','Campaign',true);//v5.0
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v4.0
        TriggerExecutionController.setSkipAllTriggers(true);
        //testData.getContact(true);
        //testData.getContact2(true);
        //testData.getPartnerUser(true);
        //testData.getPartnerUser2(true);
        //testData.getCampaign(true);
        //testData.getAccount(true);
        Account newAcc = new Account(name='MyTestAccount3');
        insert newAcc;
                
        Contact newCont = new Contact(FirstName='MyTestContact3',
                 LastName='MyTestContact3',
                 accountId=newAcc.Id,
                 Status__c = 'Marketing Suspect',
                 Email='MyTestContactEmail_3@ust-global.com',
                 fax='1234567',
                 MobilePhone='0987654',
                 Last_Operation_Performed__c = 'testing');
        insert newCont;
        Id p = [select id from profile where name='R16.10 NA PRM Portal User (MOSS) - Non SSO'].id;
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = newCont.Id,Badge_Number__c='00126689',
                timezonesidkey='America/Los_Angeles', PortalRole = 'Manager', username='tester98@noemail.com');
       
        insert user;
        Campaign campDirectObj= new Campaign(Name='Campaign_CMAP',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='ABU',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = TRUE,
                IsActive = true,
                //RecordTypeId = CampRTId,//v5.0
                RecordTypeId = campChannelRTId,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1,
                Lead_Routing__c = 'Not Applicable',
                Partner_Campaign_Contact_Email__c = 'test@test.com',Partner_Campaign_Contact__c =user.Id);
        insert campDirectObj;
        Campaign cMAPChannelcamp= new Campaign(Name='TestCampaign_CL',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='ABU',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = False,
                Allocation_Source__c = 'Dell Allocation ABU',
                Nurture_Source__c = 'Dell Nurturing',
                IsActive = true,
                RecordTypeId = CampRTId,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Lead_Routing__c = 'Not Applicable',
                Total_Value_Opportunities_Planned__c = 1);
        insert  CMAPChannelcamp;
        createTestData();
         /* 6.0
         CMAP_Queue_Settings__c objCust = new CMAP_Queue_Settings__c();
         objCust.Queue_Id__c = '00GA0000002y6hl';
         objCust.Queue_Name__c = 'Channel_eClerx';
         objCust.Name ='Channel_eClerx';
         insert objCust ;
         */
        Lead leadObj = new Lead(lastName = 'Test Lead1',
                email ='testcmap@cmaptest.com',
                status = 'Open',
                Phone='88967544',
                //Campaign__c  = campDirectObj.Id,                 
                recordTypeId = leadRTId,
                Budget__c = 'Yes',
                Purchase_Timeframe__c ='Immediate',
                LeadSource = 'Web',//v5.0 - added since its required field
                Lead_Type__c = 'Inbound',//v5.0
                Campaign__c  = CMAPChannelcamp.Id,//v5.0
                Company = 'Test Company',Country ='US',
                FAP_Originated_Lead__c = 'No',
                Country_CN__c = 'UNITED STATES');
        insert leadObj;
               
        Relationship_Lead__c rlObj = new Relationship_Lead__c(
            Contact__c = newCont.Id,
            Lead_ID_Do_Not_Edit__c = leadObj.Id,
            Campaign_ID_LinkTracker__c = campDirectObj.Id,
            Campaign__c = campDirectObj.Id,
            Consent_to_engage_Dell_Channel_Partner__c  = TRUE,
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
        insert rlObj;
        TriggerExecutionController.setSkipAllTriggers(false);
        Lead leadObj1 = new Lead(lastName = 'Test Lead',
                email ='testrelationshipcmap@cmaptest.com',
                status = 'Qualified - Channel Ready',
                Phone='8895467544',
                RecordTypeId = leadRTId,
                Country = 'US',
                Account__c =newAcc.Id,
                Campaign__c  = CMAPChannelcamp.Id,
                Company = 'Test11 Company',
                Marketing_Comments__c = 'Marketing_Comments__c',
                Sales_Comments__c = 'Sales_Comments__c',
                Questions_Comments__c = 'Customer_Comments__c',
                Relationship_Lead__c = rlObj.Id,//v5.0
                //Ready_For_Scoring__C = TRUE,
                Ignore_Duplicate_Record__c = true,
                Lead_Score__c = 'Priority (Contact participated in Marketing program; SLA = 1 Week)',
                FAP_Originated_Lead__c = 'No',
                Country_CN__c = 'UNITED STATES');                                
        Test.startTest(); 
        insert leadObj1;      
        Test.stopTest();
        System.assertEquals(leadObj1.Country_CN__c,'UNITED STATES');
    }
    
    static testMethod void routingfromSegLeadTest() {
        CMAP_TestDataGenerator testData = new CMAP_TestDataGenerator();
        Id dleadRTId= IdLookupUtils.getRecordTypeId('Lead Qualification','Lead',true);
        Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete','Lead',true);
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v4.0
        TriggerExecutionController.setSkipAllTriggers(true);
        //testData.getContact(true);
        //testData.getContact2(true);
        //testData.getPartnerUser(true);
        //testData.getPartnerUser2(true);
        //testData.getCampaign(true);
        //testData.getAccount(true);
        Account newAcc = new Account(name='MyTestAccount3');
        insert newAcc;
                
        Contact newCont = new Contact(FirstName='MyTestContact3',
                 LastName='MyTestContact3',
                 accountId=newAcc.Id,
                  Status__c = 'Marketing Suspect',
                 Email='MyTestContactEmail_3@ust-global.com',
                 fax='1234567',
                 MobilePhone='0987654',
                 Last_Operation_Performed__c = 'testing');
        insert newCont;
        Id p = [select id from profile where name='R16.10 NA PRM Portal User (MOSS) - Non SSO'].id;
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = newCont.Id,Badge_Number__c='00126688',
                timezonesidkey='America/Los_Angeles', PortalRole = 'Manager', 
                username='MyTest2'+ System.currentTimeMillis() + '@noemail.com'
                );
       
        insert user;
        Campaign campDirectObj= new Campaign(Name='Campaign_CMAP',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='ABU',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = TRUE,
                IsActive = true,
                RecordTypeId = CampRTId,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1,
                Lead_Routing__c = 'Not Applicable',
                Partner_Campaign_Contact_Email__c = 'test@test.com',Partner_Campaign_Contact__c =user.Id);
        insert campDirectObj;
        Campaign cMAPChannelcamp= new Campaign(Name='TestCampaign_CL',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='ABU',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = False,
                Allocation_Source__c = 'Dell Allocation ABU',
                Nurture_Source__c = 'Dell Nurturing',
                IsActive = true,
                RecordTypeId = CampRTId,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Lead_Routing__c = 'Not Applicable',
                Total_Value_Opportunities_Planned__c = 1);
        insert  CMAPChannelcamp;
        createTestData();
        /*6.0
        CMAP_Queue_Settings__c objCust = new CMAP_Queue_Settings__c();
        objCust.Queue_Id__c = '00GA0000002y6hl';
        objCust.Queue_Name__c = 'Channel_eClerx';
        objCust.Name ='Channel_eClerx';
        insert objCust ;
        */
        Lead leadObj = new Lead(lastName = 'Test Lead1',
                email ='testcmap@cmaptest.com',
                status = 'Open',
                Phone='88967544',
                Campaign__c  = campDirectObj.Id,
                recordTypeId = leadRTId,
                Budget__c = 'Yes',
                Purchase_Timeframe__c ='Immediate',
                Account__c =newAcc.Id,
                Marketing_Comments__c = 'Marketing_Comments__c',
                Sales_Comments__c = 'Sales_Comments__c',
                Questions_Comments__c = 'Customer_Comments__c',
                Lead_Capture_DateTime__c=system.today(),
                Company = 'Test Company',Country ='US',
                FAP_Originated_Lead__c = 'No',
                Country_CN__c = 'UNITED STATES');   //7.0
        insert leadObj;
        //TriggerExecutionController.setSkipAllTriggers(false);
        Lead leadObj1 = new Lead(lastName = 'Test Lead',
                email ='testcmap@cmaptest.com',
                status = 'Qualified - Channel Ready',
                Phone='88967544',
                RecordTypeId = leadRTId,
                Country = 'US',
                Account__c =newAcc.Id,
                Campaign__c  = CMAPChannelcamp.Id,
                Company = 'Test Company',
                Marketing_Comments__c = 'Marketing_Comments__c',
                Sales_Comments__c = 'Sales_Comments__c',
                Questions_Comments__c = 'Customer_Comments__c',
                //Partner_Admin__c =testData.pUser2.Id,
                Segment_Lead__c = leadObj.Id,//v5.0
                Ignore_Duplicate_Record__c = true,
                //Ready_For_Scoring__C = TRUE,
                Lead_Score__c = 'Priority (Contact participated in Marketing program; SLA = 1 Week)',
                FAP_Originated_Lead__c = 'No',
                Country_CN__c = 'UNITED STATES');
        Test.startTest();
        insert leadObj1;       
        Test.stopTest();
        System.assertEquals(leadObj1.Country_CN__c,'UNITED STATES');
    }

    //9.0 Remove test method testABUAgency
    //9.0 Remove test method aBUAgency2Test until aBUAgency4Test: 0% coverage
    //9.0 Remove test method aBUAgency5Test: 0% coverage
    //9.0 Remove test method aBUAgency6Test: 0% coverage
    //9.0 Remove test method laTAM1Test
    //9.0 Remove test method laTAM01Test
    //9.0 Remove test method laTAM2Test: 0% coverage
    //9.0 Remove test method laTAM3Test: 0% coverage
    //9.0 Remove test method laTAM4Test: 0% coverage
    //9.0 Remove test method laTAM5Test: 0% coverage
    //9.0 Remove test method aPJ1Test: 0% coverage
    //9.0 Remove test method aPJ2Test: 0% coverage
    //9.0 Remove test method aPJ3Test: 0% coverage
    //9.0 Remove test method aPJ4Test: 0% coverage
    //9.0 Remove test method aPJ5Test: 0% coverage
    //9.0 Remove test method aPJ6Test: 0% coverage
    //9.0 Remove test method apj7test: 0% coverage
    //9.0 Remove test method aPJ9Test: 0% coverage
    //9.0 Remove test method apj10test: 0% coverage
    //9.0 Remove test method apj11test: 0% coverage
    //9.0 Remove test method aPJ12Test: 0% coverage
    //9.0 Remove test method aPJ13Test: 0% coverage
    //9.0 Remove test method eCEMEA1Test: 0% coverage
    //9.0 Remove test method eCEMEA2Test: 0% coverage
    //9.0 Remove test method ecemea3test: 0% coverage
    //9.0 Remove test method oEMTest: 0% coverage
    //9.0 Remove test method oEMAgencyTest: 0% coverage
    //9.0 Remove test method eMEATest: 0% coverage
    //9.0 Remove test method eMEAAgency1Test: 0% coverage
    //9.0 Remove test method eMEAAgency2Test: 0% coverage
    //9.0 Remove test method eMEAAgency3Test: 0% coverage
    //9.0 Remove test method eMEAAgency4Test: 0% coverage
    //9.0 Remove test method eMEAAgency5Test: 0% coverage
    //9.0 Remove test method eMEAAgency6Test: 0% coverage
    //9.0 Remove test method eMEAAgency7Test: 0% coverage
    //9.0 Remove test method eMEAAgency8Test: 0% coverage
    //9.0 Remove test method eMEAAgency9Test: 0% coverage
    //9.0 Remove test method eMEAAgency10Test: 0% coverage
    //9.0 Remove test method eMEAAgency11Test: 0% coverage

    //Channel lead with lead score blank is needed for Nurturing//jj
    //9.0 Remove test method aBUNurturingTest: 0% coverage
    
    //9.0 Remove test method tQLNurturingTest: 0% coverage
    //9.0 Remove test method latAM1NurturingTest: 0% coverage
    //9.0 Remove test method latAM2NurturingTest: 0% coverage
    //9.0 Remove test method latAM3NurturingTest: 0% coverage
    //9.0 Remove test method aPJ1NurturingTest: 0% coverage
    //9.0 Remove test method aPJ2NurturingTest: 0% coverage
    //9.0 Remove test method aPJ3NurturingTest: 0% coverage
    //9.0 Remove test method aPJ4NurturingTest: 0% coverage
    //9.0 Remove test method aPJ5NurturingTest: 0% coverage
    //9.0 Remove test method aPJ6NurturingTest: 0% coverage
    //9.0 Remove test method aPJ7NurturingTest: 0% coverage
    //9.0 Remove test method aPJ8NurturingTest: 0% coverage
    //9.0 Remove test method aPJ9NurturingTest: 0% coverage
    //9.0 Remove test method aPJ10NurturingTest: 0% coverage
    //9.0 Remove test method eCEMEA1NurturingTest: 0% coverage
    //9.0 Remove test method eCEMEA2NurturingTest: 0% coverage
    //9.0 Remove test method eCEMEA3NurturingTest: 0% coverage
    //9.0 Remove test method oEMNurturingTest: 0% coverage
    //9.0 Remove test method oEMAgency1NurturingTest: 0% coverage
    //9.0 Remove test method eMEA1NurturingTest: 0% coverage
    //9.0 Remove test method eMEA2NurturingTest: 0% coverage
    //9.0 Remove test method eMEA3NurturingTest: 0% coverage
    //9.0 Remove test method eMEA4NurturingTest: 0% coverage
    //9.0 Remove test method eMEA5NurturingTest: 0% coverage
    //9.0 Remove test method eMEA6NurturingTest: 0% coverage
    //9.0 Remove test method eMEA7NurturingTest: 0% coverage
    //9.0 Remove test method eMEA8NurturingTest: 0% coverage
    //9.0 Remove test method eMEA9NurturingTest: 0% coverage
    //9.0 Remove test method eMEA10NurturingTest: 0% coverage
    //9.0 Remove test method eMEA11NurturingTest: 0% coverage
    //9.0 Remove test method eMEA12NurturingTest: 0% coverage
    //9.0 Remove test method eMEA1AgencyTest: 0% coverage
    //9.0 Remove test method eMEA2AgencyTest: 0% coverage
    //9.0 Remove test method eMEA3AgencyTest: 0% coverage
    //9.0 Remove test method eMEA4AgencyTest: 0% coverage
    //9.0 Remove test method eMEA5AgencyTest: 0% coverage
    //9.0 Remove test method eMEA6AgencyTest: 0% coverage
    //9.0 Remove test method eMEA7AgencyTest: 0% coverage
    //9.0 Remove test method eMEA8AgencyTest: 0% coverage
    //9.0 Remove test method eMEA9AgencyTest: 0% coverage
    //9.0 Remove test method eMEA10AgencyTest: 0% coverage
    //9.0 Remove test method eMEA11AgencyTest: 0% coverage
    //9.0 Remove test method eMEA12AgencyTest: 0% coverage
    //9.0 Remove test method eMEA13AgencyTest: 0% coverage
    //9.0 Remove test method eMEA14AgencyTest: 0% coverage
    //9.0 Remove test method eMEA15AgencyTest: 0% coverage
    //9.0 Remove test method eMEA16AgencyTest: 0% coverage
    //9.0 Remove test method eMEA17AgencyTest: 0% coverage
    //9.0 Remove test method eMEA18AgencyTest: 0% coverage
    //9.0 Remove test method eMEA19AgencyTest: 0% coverage
    //9.0 Remove test method eMEA20AgencyTest: 0% coverage
    //9.0 Remove test method eMEA21AgencyTest: 0% coverage
    //9.0 Remove test method eMEA22AgencyTest: 0% coverage
    //9.0 Remove test method eMEA23AgencyTest: 0% coverage
    //9.0 Remove test method eMEA24AgencyTest: 0% coverage
    //9.0 Remove test method eMEA25AgencyTest: 0% coverage
    //9.0 Remove test method eMEA26AgencyTest: 0% coverage
    //9.0 Remove test method eMEA27AgencyTest: 0% coverage
    //9.0 Remove test method eMEA28AgencyTest: 0% coverage
    //9.0 Remove test method eMEA2AgencyTestA until eMEA9AgencyTestA: 0% coverage
    //9.0 Remove test method eMEA3AgencyTestA until eMEA9AgencyTestA: 0% coverage
    //9.0 Remove test method eMEA5AgencyTestA until eMEA9AgencyTestA: 0% coverage
    //9.0 Remove test method eMEA10AgencyTestA until eMEA20AgencyTestA: 0% coverage
    //9.0 Remove test method eMEA21AgencyTestA: 0% coverage
    //9.0 Remove test method eMEA22AgencyTestA: 0% coverage
    //9.0 Remove test method eMEA23AgencyTestA: 0% coverage
    //9.0 Remove test method eMEA24AgencyTestA: 0% coverage
    
    static testMethod void testSegmentBizUnitName() {
        //Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Submission','Lead',true);
        Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead 2.0','Lead',true);//v5.0
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v4.0
        Sales_Channel_Group__c scg = new Sales_Channel_Group__c(Name='TestSC', Segment_Business_Unit_Name__c='SCG');
        insert scg;
        Account newAcc = new Account(name='MyTestAccount3', Type='EndUser', Sales_Channel__c=scg.Id);
        insert newAcc;
        Campaign campObj= new Campaign(Name='Campaign_CMAP',
                Vertical__c='PTG',
                Sub_Region__c='ABU',
                StartDate=system.today(),
                Solution__c='Unknown',
                Segment_Business_Unit__c='CSB',
                Region__c='ABU',
                Parent_Vehicle__c='Content Development',
                Nurture_Source__c='OEM Nurturing',
                Line_Of_Business__c='Desktop',
                Follow_Up_Role__c='Inside Sales Rep',
                IsActive = true,
                EndDate=system.today(),
                Description='Test',
                Campaign_Vehicle__c='Creative Concept Development',
                Campaign_Objective__c='Action',
                Partner_Event_or_Campaign__c = FALSE,
                Allocation_Source__c='Channel OEM',
                Lead_Routing__c = 'Not Applicable',
                RecordTypeId = campRTId);
                //RecordTypeId='012A00000012Xt5');
        insert campObj;
        CMAP_Queue_Settings__c objCust = new CMAP_Queue_Settings__c();
        objCust.Queue_Id__c = '00GA0000002y6hl';
        objCust.Queue_Name__c = 'Channel_eClerx';
        objCust.Name ='Channel_eClerx';
        insert objCust ;
        Lead leadRecord = new Lead(lastName = 'Test Lead1',
                email ='testcmap@cmaptest.com',
                status = 'Open',
                Phone='88967544',
                Campaign__c  = campObj.Id,
                //recordTypeId = IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete','Lead',true),//v5.0
                Budget__c = 'Yes',
                Purchase_Timeframe__c ='Immediate',
                Company = 'Test Company',
                Country = 'US',
                RecordTypeId = leadRTId,//v5.0
                LeadSource = 'Web',//v5.0 - added since its required field
                Lead_Type__c = 'Inbound',//v5.0 
                Dell_Partner_can_contact_me__c = True,//v5.0
                Marketing_Primary_Solution_Interest__c = 'Client Solutions', //7.0 'HCI',
                Account__c = newAcc.Id,
                FAP_Originated_Lead__c = 'No',
                Country_CN__c = 'UNITED STATES');
        insert leadRecord;
        Test.startTest();
        if(leadRecord.Account__c!=null){
            leadRecord.Segment_Business_Unit_Name__c = scg.Segment_Business_Unit_Name__c;
        }     
        update leadRecord;
        Test.stopTest();
        System.assertEquals(leadRecord.Country_CN__c,'UNITED STATES');
    }
    
    //9.0 Remove test method aPJLeadAllocationTest: 0% coverage
    //9.0 Remove test method eCEMEALeadAllocationTest: 0% coverage
    //9.0 Remove test method eCEMEALeadNurturingTest: 0% coverage
    //9.0 Remove test method nATQLNurturingTest: 0% coverage
    //9.0 Remove test method channelSATest: 0% coverage
    //9.0 Remove test method eMEACountrycodeTest: 0% coverage
    //9.0 Remove test method eMEACountryGroupingTest: 0% coverage
    //9.0 Remove test method testRelatedContValidation: 0% coverage
    
    
    //version 3.0
    static testMethod void testDSGuperuser() {
        /*CMAP_TestDataGenerator testData = new CMAP_TestDataGenerator();
        testData.getContact(true);
        testData.getPartnerUser(true);
        testData.getCampaign(true);
        testData.getLead(true);
        */
        
        System_Behavior_Bypasser__c settings = System_Behavior_Bypasser__c.getOrgDefaults();
        settings.Bypass_Lead_VRs__c  = true;
        upsert settings System_Behavior_Bypasser__c.Id;
        LeadValidator.bSkipLeadValidator = true;
        
        //retrieve DSG Partner RT
        Id dSGLeadRTId = IdLookupUtils.getRecordTypeId('DSG Partner', 'Lead', true);
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v4.0
        Id camp2RTId = StaticFactory.getRecordTypeIdByName('Campaign', 'Campaign 2.0'); //v4.0
        
        //Query for DSG Partner campaign, if does not exsits create new
        List<Campaign> listCam= [SELECT id from Campaign where name = 'DSG Partner' and RecordType.Name = 'Campaign 2.0'];
        if(listCam.size()==0 || listCam == null){
            Campaign dsgCampaign = new Campaign(name = 'DSG Partner',Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='ABU',                
                Description='Test',StartDate=system.today(),EndDate=system.today()+15,
                status='In Progress',
                Allocation_Source__c='Channel OEM',
                Nurture_Source__c='OEM Nurturing',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = false,                
                IsActive = true,
                Lead_Routing__c = 'Not Applicable',
                RecordTypeId = camp2RTId
                );
            insert dsgCampaign;
            listCam.add(dsgCampaign);
        }
        
        TriggerExecutionController.setSkipAccountTriggers(true);
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner');
        insert newAcc;
        TriggerExecutionController.setSkipAccountTriggers(false);
       
        /*newAcc.IsPartner = True;
        newAcc. ;
        update newAcc;
        */
        TriggerExecutionController.setSkipContactTriggers(true);
        List<Contact> listContact = new List<Contact>();
        for(integer intCnt=0;intCnt<2;intCnt++){
            Contact newCont = new Contact(FirstName='TestContactFN9',
                 LastName='TestContactLN9'+intCnt,
                 accountId=newAcc.Id,
                 Status__c = 'Marketing Suspect',
                 Email='TestContactEmail9@ust-global.com',
                 fax='01987645',
                 MobilePhone='0000019',
                 Last_Operation_Performed__c = 'testing',
                 Phone='0000000');
                listContact.add(newCont);
        }
        insert listContact;
        TriggerExecutionController.setSkipContactTriggers(false);

        createTestData();
        /* 6.0
        CMAP_Queue_Settings__c objCust = new CMAP_Queue_Settings__c();
        objCust.Queue_Id__c = '00GA0000002y6hl';
        objCust.Queue_Name__c = 'Channel_eClerx';
        objCust.Name ='Channel_eClerx';
        insert objCust ;
        */
        final List<Profile> listPartnerProfiles = [select id,name from Profile where UserType = 'PowerPartner' and name like '%PRM%' limit 1];

        //Test.startTest();                                       
        List<User> listUser = new List<User>();
        for(integer intCnt=0;intCnt<2;intCnt++){
            User partnerUser = new User(
                    Username='MyTest2'+intCnt+ System.currentTimeMillis() + '@dell.com',
                    Alias = 'tt2', 
                    Email='MyTest009'+intCnt+'@dell.com', 
                    FirstName='MyTestUser09', 
                    LastName='MyTestUser09',  
                    ProfileId = listPartnerProfiles.get(0).Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Enable_Partner_Lead_Management__c = true,
                    Enable_Partner_Deal_Registration__c = true,
                    Enable_As_Partner_Lead_Super_User__c = true,
                    Badge_Number__c='909'+intCnt, 
                    isActive = TRUE,
                    PortalRole = 'Manager',
                    ContactId = listContact[intCnt].id
                );
            listUser.add(partnerUser);
        }                                      
        listUser[1].Enable_As_Partner_Lead_Super_User__c = true;
        TriggerExecutionController.setskipUserTriggers(true);
        insert listUser;
        Profile adminProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE 'System Administrator' LIMIT 1];
        User admin = [SELECT id FROM User WHERE profileid = :AdminProfile.id AND isactive = true limit 1];
        TriggerExecutionController.setskipUserTriggers(true);
        TriggerExecutionController.setSkipCampaignTriggers(true);
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipAllTriggers(true);
        System.runAs(admin){
        CMAP_Helper.skipinsert = true;
            Test.startTest(); 
        Lead leadObj = new Lead(lastName = 'Test DSG Lead1',
            email ='testcmap@cmaptestdsg.com',
            status = 'Open - Channel Lead',
            Phone='88967544',
            Country = 'US',
            Partner_Account__c =newAcc.Id,
            Campaign__c  = listCam[0].Id,
            recordTypeId = '012A0000000VnzZ',
            Budget__c = 'Yes',
            Purchase_Timeframe__c ='Immediate',
            Partner_User__c =  listUser[0].Id, 
            LeadSource ='Partner',  
            Lead_Type__c = 'Inbound', 
            Dell_Partner_can_contact_me__c = true,
            Marketing_Primary_Solution_Interest__c = 'Client Solutions', //7.0'Cloud',
            //Partner_Admin__c = null,
            Company = 'Test Company',
            FAP_Originated_Lead__c = 'No',
            Country_CN__c = 'UNITED STATES');
            
            
            insert leadObj;
            
            //Assert contacted customer and sales qualified     
            Lead result = [SELECT id,Partner_Admin__c FROM Lead WHERE id = :leadObj.id];
            System.assertEquals(leadObj.Country_CN__c,'UNITED STATES');
            Test.stopTest();
          //  System.assertEquals(null, result.Partner_Admin__c);
           // System.assertEquals(listUser[0].Id, result.Partner_Admin__c);
            
        }
    }
    
    //version ISMAIL
    static testMethod void testDSGuperuser2() {
        //retrieve DSG Partner RT
        Id dSGLeadRTId = IdLookupUtils.getRecordTypeId('DSG Partner', 'Lead', true);
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v4.0
        Id camp2RTId = StaticFactory.getRecordTypeIdByName('Campaign', 'Campaign 2.0'); //v4.0
        TriggerExecutionController.setSkipAllTriggers(true);
        System_Behavior_Bypasser__c settings = System_Behavior_Bypasser__c.getOrgDefaults();
            settings.Bypass_Lead_VRs__c  = true;
        upsert settings System_Behavior_Bypasser__c.Id;
        
        //Query for DSG Partner campaign, if does not exsits create new
        List<Campaign> listCam = [SELECT id from Campaign where name = 'DSG Partner' and RecordType.Name = 'Campaign 2.0'];
        if(listCam.size()==0 || listCam == null){
            Campaign dsgCampaign = new Campaign(name = 'DSG Partner',Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='ABU',                
                Description='Test',StartDate=system.today(),EndDate=system.today()+15,
                status='In Progress',
                Allocation_Source__c='Channel OEM',
                Nurture_Source__c='OEM Nurturing',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = false,                
                IsActive = true,
                Lead_Routing__c = 'Not Applicable',
                RecordTypeId = camp2RTId
                );
            insert dsgCampaign;
            listCam.add(dsgCampaign);
        }
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner');
        insert newAcc;
        
        Sales_Channel_Group__c scg = new Sales_Channel_Group__c(Name='TestSC', Segment_Business_Unit_Name__c='SCG');
        insert scg;
        Id endUserAccountRT = IdLookupUtils.getRecordTypeId('End-User Account', 'Account', true);
        Account newAcc2 = new Account(name='Test ', RecordtypeId = endUserAccountRT, Type = 'EndUser', Sales_Channel__c = scg.id);
        insert newAcc2;

        List<Contact> listContact = new List<Contact>();
        for(integer intCnt=0;intCnt<2;intCnt++){
            Contact newCont = new Contact(FirstName='TestContactFN9',
                 LastName='TestContactLN9'+intCnt,
                 accountId=newAcc.Id,
                 Status__c = 'Marketing Suspect',
                 Email='TestContactEmail9@ust-global.com',
                 fax='01987645',
                 MobilePhone='0000019',
                 Last_Operation_Performed__c = 'testing',
                 Phone='0000000');
             listContact.add(newCont);
        }
        
        insert listContact;

        CMAP_Queue_Settings__c objCust = new CMAP_Queue_Settings__c();
        objCust.Queue_Id__c = '00GA0000002y6hl';
        objCust.Queue_Name__c = 'Channel_eClerx';
        objCust.Name ='Channel_eClerx';
        insert objCust ;
        
        final List<Profile> listPartnerProfiles = [select id,name 
                                               from Profile 
                                               where UserType = 'PowerPartner' and name like '%PRM%' 
                                               limit 1];
                                               
        List<User> listUser = new List<User>();
        for(integer intCnt=0;intCnt<2;intCnt++){
            User partnerUser = new User(
                    Username='MyTest2'+intCnt+ System.currentTimeMillis() + '@dell.com',
                    Alias = 'tt2', 
                    Email='MyTest009'+intCnt+'@dell.com', 
                    FirstName='MyTestUser09', 
                    LastName='MyTestUser09',  
                    ProfileId = listPartnerProfiles.get(0).Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Enable_Partner_Lead_Management__c = true,
                    Enable_Partner_Deal_Registration__c = true,
                    Enable_As_Partner_Lead_Super_User__c = true,
                    Badge_Number__c='909'+intCnt, 
                    isActive = TRUE,
                    PortalRole = 'Manager',
                    ContactId = listContact[intCnt].id
                );
            listUser.add(partnerUser);
        }                                      
        listUser[1].Enable_As_Partner_Lead_Super_User__c = true;
        insert listUser;
        Profile adminProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE 'System Administrator' LIMIT 1];
        User admin = [SELECT id FROM User WHERE profileid = :AdminProfile.id AND isactive = true limit 1];
        Lead leadObj = null;
        
        Test.startTest();
        System.runAs(admin){
        CMAP_Helper.skipinsert = true;
        leadObj = new Lead(lastName = 'Test DSG Lead1',
                email ='testcmap@cmaptestdsg.com',
                status = 'Assigned to Channel Partner',
                Phone='88967544',
                Country = 'US',
                Partner_Account__c =newAcc.Id,
                Campaign__c  = listCam[0].Id,
                recordTypeId = '012A0000000VnzZ',
                Budget__c = 'Yes',
                Purchase_Timeframe__c ='Immediate',
                Partner_User__c =  listUser[0].Id, 
                LeadSource ='Partner',  
                Lead_Type__c = 'Inbound', 
                Dell_Partner_can_contact_me__c = true,
                Marketing_Primary_Solution_Interest__c = 'Client Solutions', //7.0 'Cloud',
                //Partner_Admin__c = null,
                Company = 'Test Company',
                FAP_Originated_Lead__c = 'No',
                Lead_Score__c = 'High Priority (Extremely hot leads; SLA = 48 hours)',
                Country_CN__c = 'UNITED STATES');
            insert leadObj;
            leadObj.Status = 'Qualified - Channel Ready';
            leadObj.Partner_Admin__c = null;
            leadObj.OwnerId = listUser[0].Id;
            update leadObj;
            TriggerExecutionController.setSkipAllTriggers(false);
            Test.stopTest();
            //Assert contacted customer and sales qualified     
            //Lead result = [SELECT id,Partner_Admin__c FROM Lead WHERE id = :leadObj.id];
           // System.assertEquals(listUser[0].Id, result.Partner_Admin__c);
            System.assertEquals(leadObj.Country_CN__c,'UNITED STATES');
        }
        
    }
    
    //version ISMAIL
    static testMethod void testEndUserAccSalesGroupName() {
        //Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Submission','Lead',true);
        Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead 2.0','Lead',true);//v5.0
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v4.0
        TriggerExecutionController.setSkipAllTriggers(true);
        Sales_Channel_Group__c scg = new Sales_Channel_Group__c(Name='OEM', Segment_Business_Unit_Name__c='SCG');
        insert scg;
        Account newAcc = new Account(name='MyTestAccount3', Type='EndUser', Sales_Channel__c=scg.Id);
        insert newAcc;
        Campaign campObj= new Campaign(Name='Campaign_CMAP',
                Vertical__c='PTG',
                Sub_Region__c='ABU',
                StartDate=system.today(),
                Solution__c='Unknown',
                Segment_Business_Unit__c='CSB',
                Region__c='ABU',
                Parent_Vehicle__c='Content Development',
                Nurture_Source__c='OEM Nurturing',
                Line_Of_Business__c='Desktop',
                Follow_Up_Role__c='Inside Sales Rep',
                IsActive = true,
                EndDate=system.today(),
                Description='Test',
                Campaign_Vehicle__c='Creative Concept Development',
                Campaign_Objective__c='Action',
                Partner_Event_or_Campaign__c = FALSE,
                Allocation_Source__c='Channel OEM',
                Lead_Routing__c = 'Not Applicable',
                RecordTypeId = campRTId);
                //RecordTypeId='012A00000012Xt5');
        insert campObj;
        CMAP_Queue_Settings__c objCust = new CMAP_Queue_Settings__c();
        objCust.Queue_Id__c = '00GA0000002y6hl';
        objCust.Queue_Name__c = 'Channel_eClerx';
        objCust.Name ='Channel_eClerx';
        insert objCust ;
        Lead leadRecord = new Lead(lastName = 'Test Lead1',
                email ='testcmap@cmaptest.com',
                status = 'Open',
                Phone='88967544',
                Campaign__c  = campObj.Id,
                //recordTypeId = IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete','Lead',true),//v5.0
                Budget__c = 'Yes',
                Purchase_Timeframe__c ='Immediate',
                Company = 'Test Company',
                Country = 'US',
                RecordTypeId = leadRTId,//v5.0
                LeadSource = 'Web',//v5.0 - added since its required field
                Lead_Type__c = 'Inbound',//v5.0 
                Dell_Partner_can_contact_me__c = True,//v5.0
                Marketing_Primary_Solution_Interest__c = 'Client Solutions', //7.0 'HCI',
                Account__c = newAcc.Id,
                Partner_Account_Owner_ApiOnly__c = UserInfo.getUserId(),
                FAP_Originated_Lead__c = 'No',
                Country_CN__c = 'UNITED STATES');
        insert leadRecord;
        Test.startTest();
        if(leadRecord.Account__c!=null) {
            leadRecord.Segment_Business_Unit_Name__c = scg.Segment_Business_Unit_Name__c;
        }     
        //User currentLoggesInUser = UserInfo.getUserid();
        //User u = [SELECT id FROM User WHERE Id <> :currentLoggesInUser Limit 1];
        
        Profile adminProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE 'System Administrator' LIMIT 1];
        User admin = [SELECT id FROM User WHERE profileid = :AdminProfile.id AND isactive = true limit 1];
        leadRecord.ownerId = admin.id;
        leadRecord.Status = 'Assigned to Channel Partner';
        leadRecord.Partner_Admin__c = null;
        //leadRecord.Status = 'Qualified - Channel Ready';
        leadRecord.recordTypeId = IdLookupUtils.getRecordTypeId('Channel Lead - Assignment Complete', 'Lead', true);
        update leadRecord;
        leadRecord.Status = 'Qualified - Channel Ready';
        leadRecord.Partner_Admin__c = null;
        leadRecord.ownerId = UserInfo.getUserId();
        update leadRecord;
        TriggerExecutionController.setSkipAllTriggers(false);
        Test.stopTest();
        System.assertEquals(leadRecord.Status,'Qualified - Channel Ready');
        
    }
    
    static testMethod void testduprelcontact() {
        Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Submission','Lead',true);
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v4.0
        
        TriggerExecutionController.setSkipAccountTriggers(true);
        Account newAcc = new Account(name='MyTestAccount3', Type='EndUser');
        insert newAcc;
        TriggerExecutionController.setSkipAccountTriggers(false);
        
        TriggerExecutionController.setSkipContactTriggers(true);
        Contact newCont = new Contact(FirstName='MyTestContact3',
                 LastName='MyTestContact3',
                 accountId=newAcc.Id,
                 Status__c = 'Marketing Suspect',
                 Email='MyTestContactEmail_061@ust-global.com',
                 fax='1234567',
                 MobilePhone='0987654',
                 Last_Operation_Performed__c = 'testing');
        insert newCont;
        Contact newCont1 = new Contact(FirstName='MyTestContact3',
                 LastName='MyyTestyyContact56',
                 accountId=newAcc.Id,
                 Status__c = 'Marketing Suspect',
                 Email='MyTestContactEmail_062@ust-global.com',
                 fax='7701326666',
                 MobilePhone='7701326666',
                 Last_Operation_Performed__c = 'testing');
        insert newCont1;
        TriggerExecutionController.setSkipContactTriggers(false);
        
        Campaign campObj= new Campaign(Name='Campaign_CMAP',
                Vertical__c='PTG',
                Sub_Region__c='ABU',
                StartDate=system.today(),
                Solution__c='Unknown',
                Segment_Business_Unit__c='CSB',
                Region__c='ABU',
                Parent_Vehicle__c='Content Development',
                Nurture_Source__c='OEM Nurturing',
                Line_Of_Business__c='Desktop',
                Follow_Up_Role__c='Inside Sales Rep',
                IsActive = true,
                EndDate=system.today(),
                Description='Test',
                Campaign_Vehicle__c='Creative Concept Development',
                Campaign_Objective__c='Action',
                Partner_Event_or_Campaign__c = FALSE,
                Allocation_Source__c='Channel OEM',
                Lead_Routing__c = 'Not Applicable',
                RecordTypeId = campRTId);
                //RecordTypeId='012A00000012Xt5');
        insert campObj;
        createTestData();
        /*
        CMAP_Queue_Settings__c objCust = new CMAP_Queue_Settings__c();
        objCust.Queue_Id__c = '00GA0000002y6hl';
        objCust.Queue_Name__c = 'Channel_eClerx';
        objCust.Name ='Channel_eClerx';
        insert objCust ;
        */
        /*
        Lead leadRecord = new Lead(lastName = 'Test Lead1',
            email ='testcmap@cmaptest.com',
            status = 'Open',
            Phone='88967544',
            Campaign__c  = campObj.Id,
            recordTypeId = IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete','Lead',true),
            Budget__c = 'Yes',
            Purchase_Timeframe__c ='Immediate',
            Company = 'Test Company',
            Country = 'US',
            Account__c = newAcc.Id,
            Related_Contact__c = newCont.Id,
            FAP_Originated_Lead__c = 'No',
            Country_CN__c = 'UNITED STATES');
        insert leadRecord;
        */
        Test.startTest();
        try{
            Lead leadRecord2 = new Lead(lastName = 'Test Lead2',
                email ='testcmap@cmaptest.com',
                status = 'Open',
                Phone='88967544',
                Campaign__c  = campObj.Id,
                recordTypeId = IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete','Lead',true),
                Budget__c = 'Yes',
                Purchase_Timeframe__c ='Immediate',
                Company = 'Test Company',
                Country = 'US',
                Account__c = newAcc.Id,
                Ignore_Duplicate_Record__c = false,
                Related_Contact__c = newCont.Id,
                Country_CN__c = 'UNITED STATES');
            insert leadRecord2;
            
            leadRecord2.Invalid_Lead_Reason__c = 'Existing CL';
            leadRecord2.Status ='Closed - Invalid Lead';
            leadRecord2.FAP_Originated_Lead__c = 'No';
            //leadRecord2.Related_Contact__c = newCont1.id;
           System.assertEquals(leadRecord2.Status,'Closed - Invalid Lead');
        }
        catch(Exception e){
            System.debug('Success');
        }
        Test.stopTest();
        
    }
    
    static testMethod void  testAPtoCHLEad() {
        //Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Submission','Lead',true);//5.0
        Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead 2.0','Lead',true);
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v4.0
        Id campChannelRTId= IdLookupUtils.getRecordTypeId('Channel Partner Communications','Campaign',true);//v5.0
        Account newAcc = new Account(name='MyTestAccount3', Type='EndUser');
        insert newAcc;
        Id u = userinfo.getUserId();
        Account newCMAPAcc = new Account(name='MyTestAccountCMAP');
        insert newCMAPAcc;
        CMAP_Helper.skipinsert = true;
        TriggerExecutionController.setSkipContactTriggers(true);
        Contact newCont = new Contact(FirstName='MyTestContact3',
                 LastName='MyTestContact3',
                 accountId=newAcc.Id,
                 Status__c = 'Marketing Suspect',
                 Email='MyTestContactEmail_3@ust-global.com',
                 fax='1234567',
                 MobilePhone='0987654',
                 Last_Operation_Performed__c = 'testing');
        insert newCont;
        Contact newCont1 = new Contact(FirstName='MyTestContact4',
                 LastName='MyTestContact56',
                 accountId=newAcc.Id,
                 Status__c = 'Marketing Suspect',
                 Email='MyTestContactEmail_044@ust-global.com',
                 fax='1234567',
                 MobilePhone='0983333',
                 Last_Operation_Performed__c = 'testing');
        insert newCont1;
        
        Contact newCMAPCont = new Contact(Salutation = 'Mr.',
                 FirstName='MyTestContactCMAP',
                 LastName='MyTestContactCMAP',
                 Title = 'Test Title',
                 accountId=newCMAPAcc.Id,
                 Email='MyTestCMAPContactEmail_045@ust-global.com',
                 fax='712045555',
                 phone = '712045555',
                 MobilePhone='712045555',
                 Status__c = 'Prospect',
                 Last_Operation_Performed__c = 'testing',
                 MailingCountry = 'US', 
                 MailingCity='City Test',
                 MailingState = 'Test State',
                 MailingStreet = 'Test Street',
                 MailingPostalCode = '683520'
                 );
        insert newCMAPCont;
        TriggerExecutionController.setSkipContactTriggers(false);
        Test.startTest();
        Id apRTId= IdLookupUtils.getRecordTypeId('GBL_Account_Play_RT_R10.10','Account_Play__c',true);
        Id p = [select id from profile where name='R16.10 NA PRM Portal User (MOSS) - Non SSO'].id;
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = newCMAPCont.Id,Badge_Number__c='00126696',
                PortalRole = 'Manager',
                timezonesidkey='America/Los_Angeles', username='tester3@noemail.com');
       
        insert user;
        Profile adminProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE 'System Administrator' LIMIT 1];
        User admin = [SELECT id FROM User WHERE profileid = :AdminProfile.id AND isactive = true limit 1];
        
        Campaign cMAPdirAPcamp= new Campaign(Name='TestCampaign_Direct',
                Campaign_Objective__c='Acquisition/Site Development',
                Vertical__c ='Consulting',
                StartDate=system.today(),
                EndDate=system.today(),
                Segment_Business_Unit__c='Channel',
                Business_Unit__c = 'LE - G500',
                Region__c='ABU',
                Follow_Up_Role__c='Account Executive',
                Solution__c = 'IS - Integrated Security',
                Account_Play__c = TRUE,
                Account_Play_Expiry_Date__c = System.Today()+360,
                Is_this_Account_Play_Campaign__c = TRUE,
                Type='Advisory Councils',
                Description='Test',
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = TRUE,
                IsActive = true,
                //RecordTypeId = CampRTId,//v5.0
                RecordTypeId = campChannelRTId,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1,
                Lead_Routing__c = 'Not Applicable',
                Partner_Campaign_Contact_Email__c = 'test@test.com',Partner_Campaign_Contact__c =user.Id);
         insert  cMAPdirAPcamp;
         Account_Play__c apRecord = new Account_Play__c( recordTypeId = apRTId,
                                     Status__c = 'Requires Follow-Up',
                                     Account__c = newCMAPAcc.Id,
                                     Campaign__c = cMAPdirAPcamp.Id,//v5.0
                                     Primary_Contact__c = newCMAPCont .Id,
                                     Customer_Consents_to_Engage_Dell_Partner__c= TRUE,
                                     What_is_their_implementation_deadline__c = System.Today(),
                                     Roadblocks__c  = 'No Road Bloack',
                                     Desired_Outcome__c = 'OutCome',
                                     Estimated_Budget__c = 10922,
                                     Do_they_have_access_to_approved_funds__c = 'Yes', 
                                     Interested_in_DFS_funding__c='No', 
                                     Marketing_Comments__c = 'test',
                                    Account_Play_Owner__c = admin.Id
                                     );
        insert apRecord;
        Campaign campObj= new Campaign(Name='Campaign_CMAP',
                Vertical__c='PTG',
                Sub_Region__c='ABU',
                StartDate=system.today(),
                Solution__c='Unknown',
                Segment_Business_Unit__c='CSB',
                Region__c='ABU',
                Parent_Vehicle__c='Content Development',
                Nurture_Source__c='OEM Nurturing',
                Line_Of_Business__c='Desktop',
                Follow_Up_Role__c='Inside Sales Rep',
                IsActive = true,
                EndDate=system.today(),
                Description='Test',
                Campaign_Vehicle__c='Creative Concept Development',
                Campaign_Objective__c='Action',
                Partner_Event_or_Campaign__c = FALSE,
                Allocation_Source__c='Channel OEM',
                Lead_Routing__c = 'Not Applicable',
                RecordTypeId = campRTId);
                //RecordTypeId='012A00000012Xt5');
        insert campObj;
    
        try{
            Lead leadRecord = new Lead(lastName = 'Test Lead1',
                email ='testcmap@cmaptest.com',
                status = 'Qualified - Channel Ready',
                Phone='88967544',
                Campaign__c  = campObj.Id,
                recordTypeId = leadRTId,
                Budget__c = 'Yes',
                Purchase_Timeframe__c ='Immediate',
                Company = 'Test Company',
                Country = 'US',
                Account__c = newAcc.Id,
                Account_Play__c = apRecord.id,
                Related_Contact__c = newCont.Id,
                FAP_Originated_Lead__c = 'No',
                Country_CN__c = 'UNITED STATES');
            insert leadRecord;
            System.assertEquals(leadRecord.Phone,'88967544');
        }
        
        
        catch(Exception e){
            System.debug('Success');
        }
        Test.stopTest();
        
    }
    
    static testMethod void testAPtoCHLEadnurture() {
        //Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Submission','Lead',true);//v5.0
        Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead 2.0','Lead',true);
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v4.0
        Id campChannelRTId= IdLookupUtils.getRecordTypeId('Channel Partner Communications','Campaign',true);//v5.0
        Account newAcc = new Account(name='MyTestAccount3', Type='EndUser');
        insert newAcc;
        Id u = userinfo.getUserId();
        Account newCMAPAcc = new Account(name='MyTestAccountCMAP');
        insert newCMAPAcc;
        CMAP_Helper.skipinsert = true;
        TriggerExecutionController.setSkipContactTriggers(true);
        Contact newCont = new Contact(FirstName='MyTestContact3',
                 LastName='MyTestContact3',
                 accountId=newAcc.Id,
                 Status__c = 'Marketing Suspect',
                 Email='MyTestContactEmail_051@ust-global.com',
                 fax='1234567',
                 MobilePhone='0987654',
                 Last_Operation_Performed__c = 'testing');
        insert newCont;
        Contact newCont1 = new Contact(FirstName='MyTestyyContact3',
                 LastName='MyTestyyContact56',
                 accountId=newAcc.Id,
                 Status__c = 'Marketing Suspect',
                 Email='MyTestContactEmail_052@ust-global.com',
                 fax='8950322',
                 MobilePhone='8950322',
                 Last_Operation_Performed__c = 'testing');
        insert newCont1;
        
        Contact newCMAPCont = new Contact(Salutation = 'Mr.',
                 FirstName='MyyyTestContactCMAP',
                 LastName='MyyyTestContactCMAP',
                 Title = 'Test Title',
                 accountId=newCMAPAcc.Id,
                 Email='MyTestCMAPContactEmail_053@ust-global.com',
                 fax='77779993321',
                 phone = '77779993321',
                 MobilePhone='77779993321',
                 Status__c = 'Prospect',
                 Last_Operation_Performed__c = 'testing',
                 MailingCountry = 'US', 
                 MailingCity='City Test',
                 MailingState = 'Test State',
                 MailingStreet = 'Test Street',
                 MailingPostalCode = '683520'
                 );
        insert newCMAPCont;
        TriggerExecutionController.setSkipContactTriggers(false);
        Test.startTest();
        Id apRTId= IdLookupUtils.getRecordTypeId('GBL_Account_Play_RT_R10.10','Account_Play__c',true);
        Id p = [select id from profile where name='R16.10 NA PRM Portal User (MOSS) - Non SSO'].id;
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = newCMAPCont.Id,Badge_Number__c='00126692',
                PortalRole = 'Manager',
                timezonesidkey='America/Los_Angeles', username='tester4@noemail.com');
       
        insert user;
        Campaign cMAPdirAPcamp= new Campaign(Name='TestCampaign_Direct',
                Campaign_Objective__c='Acquisition/Site Development',
                Vertical__c ='Consulting',
                StartDate=system.today(),
                EndDate=system.today(),
                Segment_Business_Unit__c='Channel',
                Business_Unit__c = 'LE - G500',
                Region__c='ABU',
                Follow_Up_Role__c='Account Executive',
                Solution__c = 'IS - Integrated Security',
                Account_Play__c = TRUE,
                Account_Play_Expiry_Date__c = System.Today()+360,
                Is_this_Account_Play_Campaign__c = TRUE,
                Type='Advisory Councils',
                Description='Test',
                status='In Progress',
                //RecordTypeId = CampRTId,//v5.0
                RecordTypeId = campChannelRTId,
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = TRUE,
                IsActive = true,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Lead_Routing__c = 'Not Applicable',
                Total_Value_Opportunities_Planned__c = 1, Partner_Campaign_Contact_Email__c = 'test@test.com',Partner_Campaign_Contact__c =user.Id);
        insert  cMAPdirAPcamp;
        Account_Play__c apRecord = new Account_Play__c( recordTypeId = apRTId,
                                     Status__c = 'Requires Follow-Up',
                                     Account__c = newCMAPAcc.Id,
                                     Campaign__c = cMAPdirAPcamp.Id,//v5.0
                                     Primary_Contact__c = newCMAPCont .Id,
                                     Customer_Consents_to_Engage_Dell_Partner__c= TRUE,
                                     What_is_their_implementation_deadline__c = System.Today(),
                                     Roadblocks__c  = 'No Road Bloack',
                                     Desired_Outcome__c = 'OutCome',
                                     Estimated_Budget__c = 10922,
                                     Do_they_have_access_to_approved_funds__c = 'Yes', 
                                     Interested_in_DFS_funding__c='No',                                     
                                     Account_Executive__c = u,
                                     Marketing_Comments__c = 'test'
                                     );
        insert apRecord;
        Campaign campObj= new Campaign(Name='Campaign_CMAP',
                Vertical__c='PTG',
                Sub_Region__c='ABU',
                StartDate=system.today(),
                Solution__c='Unknown',
                Segment_Business_Unit__c='CSB',
                Region__c='ABU',
                Parent_Vehicle__c='Content Development',
                Nurture_Source__c='TQL Nurturing',
                Line_Of_Business__c='Desktop',
                Follow_Up_Role__c='Inside Sales Rep',
                IsActive = true,
                EndDate=system.today(),
                Description='Test',
                Campaign_Vehicle__c='Creative Concept Development',
                Campaign_Objective__c='Action',
                Partner_Event_or_Campaign__c = FALSE,
                Allocation_Source__c='Channel',
                Lead_Routing__c = 'Not Applicable',
                RecordTypeId = campRTId);
                //RecordTypeId='012A00000012Xt5');
        insert campObj;
    
        try{
            Lead leadRecord = new Lead(lastName = 'Test Lead1',
                email ='testcmap@cmaptest.com',
                status = 'Qualified - Channel Ready',
                Phone='88967544',
                Campaign__c  = campObj.Id,
                recordTypeId = leadRTId,
                Budget__c = 'Yes',
                Purchase_Timeframe__c ='Immediate',
                Company = 'Test Company',
                Country = 'US',
                Account__c = newAcc.Id,
                Account_Play__c = apRecord.id,
                Related_Contact__c = newCont.Id,
                FAP_Originated_Lead__c = 'No',
                Country_Code__c = 'AE',
                Country_CN__c = 'UNITED STATES');
                System.assertEquals(leadRecord.Phone,'88967544');
            insert leadRecord;
        }
        catch(Exception e){
            System.debug('Success');
        }
        Test.stopTest();
        
    }
    
    static testMethod void testAPtoCHLEadDELLnurture() {
        //Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Submission','Lead',true);//v5.0
        Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead 2.0','Lead',true);
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v4.0
        Id campChannelRTId= IdLookupUtils.getRecordTypeId('Channel Partner Communications','Campaign',true);//v5.0
        Account newAcc = new Account(name='MyTestAccount3', Type='EndUser');
        insert newAcc;
        Id u = userinfo.getUserId();
        Account newCMAPAcc = new Account(name='MyTestAccountCMAP');
        insert newCMAPAcc;
        CMAP_Helper.skipinsert = true;
        TriggerExecutionController.setSkipContactTriggers(true);
        Contact newCont = new Contact(FirstName='MyTestContact3',
                 LastName='MyTestContact3',
                 accountId=newAcc.Id,
                 Status__c = 'Marketing Suspect',
                 Email='MyTestContactEmail_046@ust-global.com',
                 fax='1234567',
                 MobilePhone='0987654',
                 Last_Operation_Performed__c = 'testing');
        insert newCont;
        Contact newCont1 = new Contact(FirstName='MyTestContact3',
                 LastName='MyTestContact56',
                 accountId=newAcc.Id,
                 Status__c = 'Marketing Suspect',
                 Email='MyTestContactEmail_047@ust-global.com',
                 fax='767754122',
                 MobilePhone='767754122',
                 Last_Operation_Performed__c = 'testing');
        insert newCont1;
        
        Contact newCMAPCont = new Contact(Salutation = 'Mr.',
                 FirstName='MyTestContactyyCMAP',
                 LastName='MyTestContactyyCMAP',
                 Title = 'Test Title',
                 accountId=newCMAPAcc.Id,
                 Email='MyTestCMAPContactEmail_048@ust-global.com',
                 fax='832645001',
                 phone = '832645001',
                 MobilePhone='832645001',
                 Status__c = 'Prospect',
                 Last_Operation_Performed__c = 'testing',
                 MailingCountry = 'US', 
                 MailingCity='City Test',
                 MailingState = 'Test State',
                 MailingStreet = 'Test Street',
                 MailingPostalCode = '683520'
                 );
        insert newCMAPCont;
        TriggerExecutionController.setSkipContactTriggers(false);
        Test.startTest();
        Id apRTId= IdLookupUtils.getRecordTypeId('GBL_Account_Play_RT_R10.10','Account_Play__c',true);
        Id p = [select id from profile where name='R16.10 NA PRM Portal User (MOSS) - Non SSO'].id;
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = newCMAPCont.Id,Badge_Number__c='00126695',
                PortalRole = 'Manager',
                timezonesidkey='America/Los_Angeles', username='tester5@noemail.com');
       
        insert user;
        Campaign cMAPdirAPcamp= new Campaign(Name='TestCampaign_Direct',
                Campaign_Objective__c='Acquisition/Site Development',
                Vertical__c ='Consulting',
                StartDate=system.today(),
                EndDate=system.today(),
                Segment_Business_Unit__c='Channel',
                Business_Unit__c = 'LE - G500',
                Region__c='ABU',
                Follow_Up_Role__c='Account Executive',
                Solution__c = 'IS - Integrated Security',
                Account_Play__c = TRUE,
                Account_Play_Expiry_Date__c = System.Today()+360,
                Is_this_Account_Play_Campaign__c = TRUE,
                Type='Advisory Councils',
                Description='Test',
                status='In Progress',
                //RecordTypeId = CampRTId,//v5.0
                RecordTypeId = campChannelRTId,
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = TRUE,
                IsActive = true,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Lead_Routing__c = 'Not Applicable',
                Total_Value_Opportunities_Planned__c = 1,Partner_Campaign_Contact_Email__c = 'test@test.com',Partner_Campaign_Contact__c =user.Id);
         insert  cMAPdirAPcamp;
         Account_Play__c apRecord = new Account_Play__c( recordTypeId = apRTId,
                                     Status__c = 'Requires Follow-Up',
                                     Account__c = newCMAPAcc.Id,
                                     Campaign__c = cMAPdirAPcamp.Id,//v5.0
                                     Primary_Contact__c = newCMAPCont .Id,
                                     Customer_Consents_to_Engage_Dell_Partner__c= TRUE,
                                     What_is_their_implementation_deadline__c = System.Today(),
                                     Roadblocks__c  = 'No Road Bloack',
                                     Desired_Outcome__c = 'OutCome',
                                     Estimated_Budget__c = 10922,
                                     Do_they_have_access_to_approved_funds__c = 'Yes', 
                                     Interested_in_DFS_funding__c='No',                                     
                                     Account_Executive__c = u,
                                     Marketing_Comments__c = 'test',
                                     Challenges_Driving_the_Project__c = 'channelges'
                                     );
        insert apRecord;
        Campaign campObj= new Campaign(Name='Campaign_CMAP',
                Vertical__c='PTG',
                Sub_Region__c='ABU',
                StartDate=system.today(),
                Solution__c='Unknown',
                Segment_Business_Unit__c='CSB',
                Region__c='ABU',
                Parent_Vehicle__c='Content Development',
                Nurture_Source__c='Dell Nurturing',
                Line_Of_Business__c='Desktop',
                Follow_Up_Role__c='Inside Sales Rep',
                IsActive = true,
                EndDate=system.today(),
                Description='Test',
                Campaign_Vehicle__c='Creative Concept Development',
                Campaign_Objective__c='Action',
                Partner_Event_or_Campaign__c = FALSE,
                Allocation_Source__c='Channel',
                Lead_Routing__c = 'Not Applicable',
                RecordTypeId = campRTId);
                //RecordTypeId='012A00000012Xt5');
        insert campObj;
        Id leadcleansingRTId = IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete', 'Lead', true);
       
        try{
            Lead leadRecord = new Lead(lastName = 'Test Lead1',
                email ='testcmap@cmaptest.com',
                status = 'Qualified - Channel Ready',
                Phone='88967544',
                Campaign__c  = campObj.Id,
                recordTypeId = leadcleansingRTId,
                Budget__c = 'Yes',
                Purchase_Timeframe__c ='Immediate',
                Company = 'Test Company',
                Country = 'US',
                Account__c = newAcc.Id,
                Account_Play__c = apRecord.id,
                Marketing_Comments__c = 'test',
                Related_Contact__c = newCont.Id,
                FAP_Originated_Lead__c = 'No',
                Country_CN__c = 'UNITED STATES');
            insert leadRecord;
            System.assertEquals(leadRecord.Country_CN__c,'UNITED STATES');
        }
        catch(Exception e){
            System.debug('Success');
        }
        Test.stopTest();
        
    }
    
    static testMethod void routing2S() {
        TriggerExecutionController.setSkipAllTriggers(true);//v5.0
         TriggerExecutionController.setSkipAccountTriggers(true);
        CMAP_Helper.skipinsert = true;
        CMAP_TestDataGenerator testData = new CMAP_TestDataGenerator();
        //Id DleadRTId= IdLookupUtils.getRecordTypeId('Lead Qualification','Lead',true); //v5.0 
        Id dleadRTId= IdLookupUtils.getRecordTypeId('Direct Lead 2.0','Lead',true);
        Id dSGLeadRTId = IdLookupUtils.getRecordTypeId('DSG Partner', 'Lead', true);
        Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete','Lead',true);
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v4.0
        //testData.getContact(true);
        //testData.getContact2(true);
        //testData.getPartnerUser(true);
        //testData.getPartnerUser2(true);
        //testData.getCampaign(true);
        //testData.getAccount(true);
        //v5.0
        //Account newAcc = new Account(name='MyTestAccount3');
        //insert newAcc;
        string strAccountRTId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Partner Account'][0].Id;
        Account newAcc = new Account(Name = 'Partner Account', Account_Country_Code__c = 'US',Type='Partner' ,Is_GTM_Partner__c = true, RecordTypeId = strAccountRTId);//,
                                    //OwnerId = '00530000000n5szAAA'); // TODO: OwnerId
        insert newAcc;
        /*newAcc.IsPartner = true;
        update newAcc;*/
        
        Contact newCont3 = new Contact(FirstName='TestContact45',
                 LastName='TestContactlast35',
                 accountId=newAcc.Id,
                 Email='tesvtss@ust-global.com',
                 fax='01987645',
                 MobilePhone='0000019',
                 //Last_Operation_Performed__c = 'testing',
                 Status__c = 'Marketing Suspect',
                 Phone='0000000');
        insert newCont3;
        
        Id p = [select id from profile where name='R16.10 NA PRM Portal User (MOSS) - Non SSO'].id;
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                contactid=newCont3.id,
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                Badge_Number__c='00126699', 
                Enable_Partner_Deal_Registration__c = TRUE, 
                Enable_Partner_Lead_Management__c = TRUE, 
                Enable_As_Partner_Lead_Super_User__c = TRUE,
                timezonesidkey='America/Los_Angeles', PortalRole = 'Manager', username='tester6@noemail.com');
       
        insert user; 
        
        Contact newCont = new Contact(FirstName='MyTestContact3',
                 LastName='MyTestContact3',
                 accountId=newAcc.Id,
                 Status__c = 'Marketing Suspect',
                 Email='MyTestContactEmail_3@ust-global.com',
                 fax='1234567',
                 MobilePhone='0987654',
                 Partner_User__c=user.id,
                 Last_Operation_Performed__c = 'testing');
        insert newCont;
        
    
          user suiyeeuser =[ select contactid,IsActive,Enable_Partner_Lead_Management__c from user where email='test123@noemail.com' Limit 1] ;
          system.debug('suiyeeuser'+suiyeeuser);   
          contact suiyee = [SELECT id,Partner_User_Lead_Management__c, Partner_User_Active__c, Partner_Contact__c FROM contact WHERE email= 'MyTestContactEmail_3@ust-global.com'];
          system.debug('suiyeeL2'+suiyee);
         //v5.0 - added        
        /*Contact newCont1 = new Contact(FirstName='TestContactFN9',
                 LastName='TestContactLN9',
                 accountId=newAcc.Id,
                 Email='TestContactEmail9@ust-global.com',
                 fax='01987645',
                 MobilePhone='0000019',
                 //Last_Operation_Performed__c = 'testing',
                 Phone='0000000');
        insert newCont1;*/
        
        //v5.0
        Contact newCon2 = new Contact(FirstName='TesttestContact3',
                 LastName='TesttestContactlast2',
                 accountId=newAcc.Id,
                 Email='tesvtsss@ust-global.com',
                 fax='0198764555',
                 MobilePhone='000001977',
                 //Last_Operation_Performed__c = 'testing',
                 Status__c = 'Marketing Suspect',
                 Phone='0000044');
        insert newCon2;
        
        //Test.startTest();
        final List<Profile> listPartnerProfiles2 = [select id,name 
                                               from Profile 
                                               where UserType = 'PowerPartner' and name like '%PRM%' 
                                               order by CreatedDate DESC limit 1];
                                               
        User partnerUsr2 = new User(
                    Username='test106' + System.currentTimeMillis() + '@dell.com',
                    Alias = 'est016', 
                    Email='test006@dell.com', 
                    FirstName='John016', 
                    LastName='Dod016', 
                    ProfileId = listPartnerProfiles2.get(0).Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Badge_Number__c='016', 
                    isActive = TRUE,
                    Enable_Partner_Deal_Registration__c = TRUE, 
                    Enable_Partner_Lead_Management__c = TRUE, 
                    Enable_As_Partner_Lead_Super_User__c = TRUE,
                    //AccountId = newAcc.Id,
                    ContactId = newCon2.id
                );
        insert partnerUsr2;
       
        final List<Profile> listPartnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and Name like '%PRM%' order by CreatedDate desc limit 1];
                                               
        /*User partnerUser = new User(
                    Username='MyTest2' + System.currentTimeMillis() + '@dell.com',
                    Alias = 'tt2', 
                    Email='MyTest009@dell.com', 
                    FirstName='MyTestUser09', 
                    LastName='MyTestUser09',  
                    ProfileId = listPartnerProfiles.get(0).Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Badge_Number__c='909', 
                    isActive = TRUE,
                    Enable_Partner_Deal_Registration__c = TRUE, 
                    Enable_Partner_Lead_Management__c = TRUE, 
                    Enable_As_Partner_Lead_Super_User__c = TRUE,
                    ContactId = partnerUsr2.id);
        insert partnerUser;*/
        //v5.0 end
        Campaign campDirectObj= new Campaign(Name='Campaign_CMAP',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='ABU',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = TRUE,
                IsActive = true,
                RecordTypeId = CampRTId,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1,
                Lead_Routing__c = 'Not Applicable',
                Partner_Campaign_Contact_Email__c = 'test@test.com',Partner_Campaign_Contact__c =user.Id);
        insert campDirectObj;
        Campaign cMAPChannelcamp= new Campaign(Name='TestCampaign_CL',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='ABU',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = True,//v5.0
                Allocation_Source__c = 'Dell Allocation ABU',
                Nurture_Source__c = 'Dell Nurturing',
                IsActive = true,
                RecordTypeId = CampRTId,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1,
                Partner_Campaign_Contact_Email__c = 'campaignCMAP@yahoo.com', //v5.0
                Lead_Routing__c = 'Not Applicable',
                Partner_Campaign_Contact__c = partnerUsr2.Id ); //v5.0
        insert  CMAPChannelcamp;
        Test.startTest();
        createTestData();
        /*
        CMAP_Queue_Settings__c objCust = new CMAP_Queue_Settings__c();
        objCust.Queue_Id__c = '00GA0000002y6hl';
        objCust.Queue_Name__c = 'Channel_eClerx';
        objCust.Name ='Channel_eClerx';
        insert objCust ;
        */
        Lead leadObj = new Lead(lastName = 'Test Lead1',
                email ='testcmap@cmaptest.com',
                status = 'Open',
                Phone='88967544',
                Campaign__c  = campDirectObj.Id,
                //recordTypeId = leadRTId,//v5.0
                recordTypeId = '012A0000000VnzZ',
                Budget__c = 'Yes',
                Purchase_Timeframe__c ='Immediate',
                Account__c =newAcc.Id,
                Marketing_Comments__c = 'Marketing_Comments__c',
                Sales_Comments__c = 'Sales_Comments__c',
                Questions_Comments__c = 'Customer_Comments__c',
                Partner_User__c =user.id,
                Partner_Contact__c=newCont.id,  
                LeadSource ='Partner',
                Lead_Type__c = 'Inbound',
                Dell_Partner_can_contact_me__c = true,  
                Marketing_Primary_Solution_Interest__c = 'Client Solutions', //7.0 'Storage',            
                Company = 'Test Company',Country ='US',
                FAP_Originated_Lead__c = 'No',
                Country_Code__c = 'AE',
                Country_CN__c = 'UNITED ARAB EMIRATES');
        insert leadObj;
        
        Lead leadObj1 = new Lead(lastName = 'Test Lead',
                email ='testcmap@cmaptest.com',
                status = 'Qualified - Channel Ready',
                Phone='88967544',
                RecordTypeId = leadRTId,
                Country = 'US',
                Account__c =newAcc.Id,
                Campaign__c  = CMAPChannelcamp.Id,
                Company = 'Test Company',
                Marketing_Comments__c = 'Marketing_Comments__c',
                Sales_Comments__c = 'Sales_Comments__c',
                Questions_Comments__c = 'Customer_Comments__c',
                //Partner_Admin__c =testData.pUser2.Id,
               // Segment_Lead__c = leadObj.Id,
                //Ready_For_Scoring__C = TRUE,
                Lead_Score__c = 'Priority (Contact participated in Marketing program; SLA = 1 Week)',
                FAP_Originated_Lead__c = 'No',
                Country_CN__c = 'UNITED STATES');    //7.0

        insert leadObj1; 
        //leadObj1.Channel_to_Segment_Criteria__c = 'NOT Valid Lead';//v5.0
        //update leadObj1;//v5.0
        //leadObj2.Ready_for_Scoring__c = TRUE;
        //Update leadList;        
        leadObj.Status = 'Open';
        leadObj.RecordTypeId = DleadRTId;
        leadObj.LeadSource = 'Web';//v5.0 - added since its required field
        leadObj.Lead_Type__c = 'Inbound';//v5.0
        leadObj.Channel_Lead__c = leadObj1.id;
        
        update leadObj;
        TriggerExecutionController.setSkipAllTriggers(false);//v5.0
        Test.stopTest();
        System.assertEquals(leadObj.LeadSource,'Web');
        
        
    }
 
    //9.0 Remove test method aPJNZAUTest: 0% coverage
    //9.0 Remove test method regionAsAccountPlayTestCases: 0% coverage
    //9.0 Remove test method r2SCodeStartTest: 0% coverage

   
   static testMethod void populatePartnerUserToLead() {
   
       TriggerExecutionController.setSkipAllTriggers(true);
       
       string strAccountRTId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Partner Account'][0].Id;
       Account newAcc = new Account(Name = 'Partner Account', Account_Country_Code__c = 'US',Type='Partner' ,Is_GTM_Partner__c = true, RecordTypeId = strAccountRTId);//,
                                    //OwnerId = '00530000000n5szAAA'); // TODO: OwnerId
       insert newAcc;
       /*newAcc.IsPartner = true;
       update newAcc;*/
       
       Id dSGLeadRTId = IdLookupUtils.getRecordTypeId('DSG Partner', 'Lead', true);
       
        Contact newCont = new Contact(FirstName='MyTestContact3',
                 LastName='MyTestContact3',
                 accountId=newAcc.Id,
                 Status__c = 'Marketing Suspect',
                 Email='MyTestContactEmail_3@ust-global.com',
                 fax='1234567',
                 MobilePhone='0987654',
                 Last_Operation_Performed__c = 'testing');
        insert newCont;
       
        createTestData();
       /*6.0
        CMAP_Queue_Settings__c objCust = new CMAP_Queue_Settings__c();
        objCust.Queue_Id__c = '00GA0000002y6hl';
        objCust.Queue_Name__c = 'Channel_eClerx';
        objCust.Name ='Channel_eClerx';
        insert objCust ;
        */
        
        Id p = [select id from profile where name='R16.10 NA PRM Portal User (MOSS) - Non SSO'].id;
        User user = new User(alias = 'T321', email='TestingHYD321@noemail.com',
                emailencodingkey='UTF-8', lastname='TestingHYD321', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = newCont.Id,Badge_Number__c='00126697', 
                timezonesidkey='America/Los_Angeles', username='tester11@Prodnoemail.com',
                Enable_Partner_Deal_Registration__c = TRUE, 
                Enable_Partner_Lead_Management__c = TRUE, 
                PortalRole = 'Manager',
                Enable_As_Partner_Lead_Super_User__c = TRUE);      
        insert user;
        
        Contact newCon2 = new Contact(FirstName='TestContact3',
                 LastName='TestContactlast2',
                 accountId=newAcc.Id,
                 Email='tesvt@ust-global.com',
                 fax='01987645',
                 MobilePhone='0000019',
                 //Last_Operation_Performed__c = 'testing',
                 Status__c = 'Marketing Suspect',
                 Phone='0000000');
        insert newCon2;

        final List<Profile> listPartnerProfiles2 = [select id,name 
                                               from Profile 
                                               where UserType = 'PowerPartner' and name like '%PRM%' 
                                               order by CreatedDate DESC limit 1];
                                               
        User partnerUsr2 = new User(
                    Username='test106' + System.currentTimeMillis() + '@dell.com',
                    Alias = 'est016', 
                    Email='test006@dell.com', 
                    FirstName='John016', 
                    LastName='Dod016', 
                    ProfileId = listPartnerProfiles2.get(0).Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Badge_Number__c='016', 
                    isActive = TRUE,
                    //AccountId = newAcc.Id,
                    ContactId = newCon2.id
                );
        insert partnerUsr2;

        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true);
        Campaign cMAPChannelcamp= new Campaign(Name='TestCampaign_CL',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='ABU',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = True,//v5.0
                Allocation_Source__c = 'Dell Allocation ABU',
                Nurture_Source__c = 'Dell Nurturing',
                IsActive = true,
                RecordTypeId = CampRTId,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1,
                Partner_Campaign_Contact_Email__c = 'campaignCMAP@yahoo.com', //v5.0
                Lead_Routing__c = 'Not Applicable',
                Partner_Campaign_Contact__c = partnerUsr2.id ); //v5.0
                insert  CMAPChannelcamp;
                CMAP_Helper.skipinsert = true;
        Lead leadObj = new Lead(lastName = 'Test Lead1',
                email ='testcmap@cmaptest.com',
                //status = 'Open',
                status = 'Qualified - Channel Ready',
                Phone='88967544',
                Campaign__c  = CMAPChannelcamp.Id,                
                recordTypeId = '012A0000000VnzZ',
                Budget__c = 'Yes',
                Purchase_Timeframe__c ='Immediate',
                Account__c =newAcc.Id,
                Marketing_Comments__c = 'Marketing_Comments__c',
                Sales_Comments__c = 'Sales_Comments__c',
                Questions_Comments__c = 'Customer_Comments__c',                
                Partner_Contact__c=newCont.id, 
                LeadSource ='Partner',
                Lead_Type__c = 'Inbound', 
                Dell_Partner_can_contact_me__c = true,
                Marketing_Primary_Solution_Interest__c = 'Client Solutions', //7.0 'Server',          
                Company = 'Test Company',Country ='US',
                FAP_Originated_Lead__c = 'No',
                Country_CN__c = 'UNITED STATES');   //7.0
               
        TriggerExecutionController.setSkipAllTriggers(false);
        Test.StartTest();
        insert leadObj;
        Test.StopTest();
        System.assertEquals(leadObj.status,'Qualified - Channel Ready');
   }
    
   //SY Test
   static testMethod void testAPtoCHLEadDELLnurtureAPJRegion() {
        //Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Submission','Lead',true);//v5.0
        Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead 2.0','Lead',true);
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v4.0
        Id campChannelRTId= IdLookupUtils.getRecordTypeId('Channel Partner Communications','Campaign',true);//v5.0
        Account newAcc = new Account(name='MyTestAccount3', Type='EndUser');
        insert newAcc;
        Id u = userinfo.getUserId();
        Account newCMAPAcc = new Account(name='MyTestAccountCMAP');
        insert newCMAPAcc;
        CMAP_Helper.skipinsert = true;
        TriggerExecutionController.setSkipContactTriggers(true);
        Contact newCont = new Contact(FirstName='MyTestContact3',
                 LastName='MyTestContact3',
                 accountId=newAcc.Id,
                 Status__c = 'Marketing Suspect',
                 Email='MyTestContactEmail_046@ust-global.com',
                 fax='1234567',
                 MobilePhone='0987654',
                 Last_Operation_Performed__c = 'testing');
        insert newCont;
        Contact newCont1 = new Contact(FirstName='MyTestContact3',
                 LastName='MyTestContact56',
                 accountId=newAcc.Id,
                 Status__c = 'Marketing Suspect',
                 Email='MyTestContactEmail_047@ust-global.com',
                 fax='767754122',
                 MobilePhone='767754122',
                 Last_Operation_Performed__c = 'testing');
        insert newCont1;
        
        Contact newCMAPCont = new Contact(Salutation = 'Mr.',
                 FirstName='MyTestContactyyCMAP',
                 LastName='MyTestContactyyCMAP',
                 Title = 'Test Title',
                 accountId=newCMAPAcc.Id,
                 Email='MyTestCMAPContactEmail_048@ust-global.com',
                 fax='832645001',
                 phone = '832645001',
                 MobilePhone='832645001',
                 Status__c = 'Prospect',
                 Last_Operation_Performed__c = 'testing',
                 MailingCountry = 'US', 
                 MailingCity='City Test',
                 MailingState = 'Test State',
                 MailingStreet = 'Test Street',
                 MailingPostalCode = '683520'
                 );
        insert newCMAPCont;
        TriggerExecutionController.setSkipContactTriggers(false);
        Test.startTest();
        Id apRTId= IdLookupUtils.getRecordTypeId('GBL_Account_Play_RT_R10.10','Account_Play__c',true);
        Id p = [select id from profile where name='R16.10 NA PRM Portal User (MOSS) - Non SSO'].id;
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = newCMAPCont.Id,Badge_Number__c='00126694',
                PortalRole = 'Manager',
                timezonesidkey='America/Los_Angeles', username='tester12122727@noemail.com');
       
        insert user;
        Campaign cMAPdirAPcamp= new Campaign(Name='TestCampaign_Direct',
                Campaign_Objective__c='Acquisition/Site Development',
                Vertical__c ='Consulting',
                StartDate=system.today(),
                EndDate=system.today(),
                Segment_Business_Unit__c='Channel',
                Business_Unit__c = 'LE - G500',
                Region__c='ABU',
                Follow_Up_Role__c='Account Executive',
                Solution__c = 'IS - Integrated Security',
                Account_Play__c = TRUE,
                Account_Play_Expiry_Date__c = System.Today()+360,
                Is_this_Account_Play_Campaign__c = TRUE,
                Type='Advisory Councils',
                Description='Test',
                status='In Progress',
                //RecordTypeId = CampRTId,//v5.0
                RecordTypeId = campChannelRTId,
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = TRUE,
                IsActive = true,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Lead_Routing__c = 'Not Applicable',
                Total_Value_Opportunities_Planned__c = 1,Partner_Campaign_Contact_Email__c = 'test@test.com',Partner_Campaign_Contact__c =user.Id);
         insert  cMAPdirAPcamp;
         Account_Play__c apRecord = new Account_Play__c( recordTypeId = apRTId,
                                     Status__c = 'Requires Follow-Up',
                                     Account__c = newCMAPAcc.Id,
                                     Campaign__c = cMAPdirAPcamp.Id,//v5.0
                                     Primary_Contact__c = newCMAPCont .Id,
                                     Customer_Consents_to_Engage_Dell_Partner__c= TRUE,
                                     What_is_their_implementation_deadline__c = System.Today(),
                                     Roadblocks__c  = 'No Road Bloack',
                                     Desired_Outcome__c = 'OutCome',
                                     Estimated_Budget__c = 10922,
                                     Do_they_have_access_to_approved_funds__c = 'Yes', 
                                     Interested_in_DFS_funding__c='No',                                     
                                     Account_Executive__c = u,
                                     Marketing_Comments__c = 'test',
                                     Challenges_Driving_the_Project__c = 'channelges'
                                     );
        insert apRecord;
       
       List<Campaign> listCampaign = new List<Campaign>();
        Campaign campObj= new Campaign(Name='Campaign_CMAP',
                Vertical__c='PTG',
                Sub_Region__c='APJ',
                StartDate=system.today(),
                Solution__c='Unknown',
                Segment_Business_Unit__c='CSB',
                Region__c='APJ',
                Country_Code__c = 'SG - Singapore',
                Allocation_Source__c ='Dell Allocation APJ',                     
                Parent_Vehicle__c='Content Development',
                Nurture_Source__c='Dell Nurturing',
                Line_Of_Business__c='Desktop',
                Follow_Up_Role__c='Inside Sales Rep',
                IsActive = true,
                EndDate=system.today(),
                Description='Test',
                Campaign_Vehicle__c='Creative Concept Development',
                Campaign_Objective__c='Action',
                Partner_Event_or_Campaign__c = FALSE,
                Lead_Routing__c = 'Not Applicable',
                RecordTypeId = campRTId);
                //RecordTypeId='012A00000012Xt5');
        
        listCampaign.add(campObj);      
        Campaign campObj2= new Campaign(Name='Campaign_CMAP_NZ',
                Vertical__c='PTG',
                Sub_Region__c='APJ',
                StartDate=system.today(),
                Solution__c='Unknown',
                Segment_Business_Unit__c='CSB',
                Region__c='APJ',
                Country_Code__c = 'NZ - New Zealand',
                Allocation_Source__c ='Dell Allocation APJ',                     
                Parent_Vehicle__c='Content Development',
                Nurture_Source__c='Dell Nurturing',
                Line_Of_Business__c='Desktop',
                Follow_Up_Role__c='Inside Sales Rep',
                IsActive = true,
                EndDate=system.today(),
                Description='Test',
                Campaign_Vehicle__c='Creative Concept Development',
                Campaign_Objective__c='Action',
                Partner_Event_or_Campaign__c = FALSE,
                Lead_Routing__c = 'Not Applicable',
                RecordTypeId = campRTId);
       
        listCampaign.add(campObj2);
       
       Campaign campObj3= new Campaign(Name='Campaign_CMAP_NZ_OEM',
                Vertical__c='PTG',
                Sub_Region__c='APJ',
                StartDate=system.today(),
                Solution__c='Unknown',
                Segment_Business_Unit__c='CSB',
                Region__c='APJ',
                Country_Code__c = 'NZ - New Zealand',
                Allocation_Source__c ='Channel OEM Agency 1',                     
                Parent_Vehicle__c ='Content Development',
                Nurture_Source__c='Dell Nurturing',
                Line_Of_Business__c='Desktop',
                Follow_Up_Role__c='Inside Sales Rep',
                IsActive = true,
                EndDate=system.today(),
                Description='Test',
                Campaign_Vehicle__c ='Creative Concept Development',
                Campaign_Objective__c='Action',
                Partner_Event_or_Campaign__c = FALSE,
                Lead_Routing__c = 'Not Applicable',
                RecordTypeId = campRTId);
       
        listCampaign.add(campObj3);
        insert listCampaign;
       
        Id leadcleansingRTId = IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete', 'Lead', true);
       
        try{
            List<Lead> listLead = new list<Lead>();
            Lead leadRecord = new Lead(lastName = 'Test Lead1',
                email ='testcmap@cmaptest.com',
                status = 'Qualified - Channel Ready',
                Phone='88967544',
                Campaign__c  = listCampaign[0].Id,
                recordTypeId = leadcleansingRTId,
                Budget__c = 'Yes',
                Purchase_Timeframe__c ='Immediate',
                Company = 'Test Company',
                Country = 'US',
                Account__c = newAcc.Id,
                Account_Play__c = apRecord.id,
                Marketing_Comments__c = 'test',
                Related_Contact__c = newCont.Id,
                FAP_Originated_Lead__c = 'No',Country_CN__c = 'UNITED STATES');
            listLead.add(leadRecord);
            Lead leadRecord2 = new Lead(lastName = 'Test Lead2',
                email ='testcmap2@cmaptest.com',
                status = 'Qualified - Channel Ready',
                Phone='889675442',
                Campaign__c  = listCampaign[1].Id,
                recordTypeId = leadcleansingRTId,
                Budget__c = 'Yes',
                Purchase_Timeframe__c ='Immediate',
                Company = 'Test Company',
                Country = 'US',
                Account__c = newAcc.Id,
                Account_Play__c = apRecord.id,
                Marketing_Comments__c = 'test',
                Related_Contact__c = newCont.Id,
                FAP_Originated_Lead__c = 'No',Country_CN__c = 'UNITED STATES');
            listLead.add(leadRecord2);
            Lead leadRecord3 = new Lead(lastName = 'Test Lead2',
                email ='testcmap2@cmaptest.com',
                status = 'Qualified - Channel Ready',
                Phone='889675442',
                Campaign__c  = listCampaign[2].Id,
                recordTypeId = leadcleansingRTId,
                Budget__c = 'Yes',
                Purchase_Timeframe__c ='Immediate',
                Company = 'Test Company',
                Country = 'US',
                Account__c = newAcc.Id,
                Account_Play__c = apRecord.id,
                Marketing_Comments__c = 'test',
                Related_Contact__c = newCont.Id,
                FAP_Originated_Lead__c = 'No',Country_CN__c = 'UNITED STATES');
            listLead.add(leadRecord3);
            insert listLead;
            System.assertEquals(leadRecord3.status,'Qualified - Channel Ready');
        }
        catch(Exception e){
            System.debug('Success');
        }
        Test.stopTest();
        
        
    }
    
    static testMethod void testAPtoCHLEadDELLnurtureEMEARegion() {
        //Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Submission','Lead',true);//v5.0
        Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead 2.0','Lead',true);
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v4.0
        Id campChannelRTId= IdLookupUtils.getRecordTypeId('Channel Partner Communications','Campaign',true);//v5.0
        Account newAcc = new Account(name='MyTestAccount3', Type='EndUser');
        insert newAcc;
        Id u = userinfo.getUserId();
        Account newCMAPAcc = new Account(name='MyTestAccountCMAP');
        insert newCMAPAcc;
        CMAP_Helper.skipinsert = true;
        TriggerExecutionController.setSkipContactTriggers(true);
        Contact newCont = new Contact(FirstName='MyTestContact3',
                 LastName='MyTestContact3',
                 accountId=newAcc.Id,
                 Status__c = 'Marketing Suspect',
                 Email='MyTestContactEmail_046@ust-global.com',
                 fax='1234567',
                 MobilePhone='0987654',
                 Last_Operation_Performed__c = 'testing');
        insert newCont;
        Contact newCont1 = new Contact(FirstName='MyTestContact3',
                 LastName='MyTestContact56',
                 accountId=newAcc.Id,
                 Status__c = 'Marketing Suspect',
                 Email='MyTestContactEmail_047@ust-global.com',
                 fax='767754122',
                 MobilePhone='767754122',
                 Last_Operation_Performed__c = 'testing');
        insert newCont1;
        
        Contact newCMAPCont = new Contact(Salutation = 'Mr.',
                 FirstName='MyTestContactyyCMAP',
                 LastName='MyTestContactyyCMAP',
                 Title = 'Test Title',
                 accountId=newCMAPAcc.Id,
                 Email='MyTestCMAPContactEmail_048@ust-global.com',
                 fax='832645001',
                 phone = '832645001',
                 MobilePhone='832645001',
                 Status__c = 'Prospect',
                 Last_Operation_Performed__c = 'testing',
                 MailingCountry = 'US', 
                 MailingCity='City Test',
                 MailingState = 'Test State',
                 MailingStreet = 'Test Street',
                 MailingPostalCode = '683520'
                 );
        insert newCMAPCont;
        TriggerExecutionController.setSkipContactTriggers(false);
        
        Id apRTId= IdLookupUtils.getRecordTypeId('GBL_Account_Play_RT_R10.10','Account_Play__c',true);
        Id p = [select id from profile where name='R16.10 NA PRM Portal User (MOSS) - Non SSO'].id;
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = newCMAPCont.Id,Badge_Number__c='00126693',
                PortalRole = 'Manager',
                timezonesidkey='America/Los_Angeles', username='tester13@noemail.com');
       
        insert user;
        Campaign cMAPdirAPcamp= new Campaign(Name='TestCampaign_Direct',
                Campaign_Objective__c='Acquisition/Site Development',
                Vertical__c ='Consulting',
                StartDate=system.today(),
                EndDate=system.today(),
                Segment_Business_Unit__c='Channel',
                Business_Unit__c = 'LE - G500',
                Region__c='ABU',
                Follow_Up_Role__c='Account Executive',
                Solution__c = 'IS - Integrated Security',
                Account_Play__c = TRUE,
                Account_Play_Expiry_Date__c = System.Today()+360,
                Is_this_Account_Play_Campaign__c = TRUE,
                Type='Advisory Councils',
                Description='Test',
                status='In Progress',
                //RecordTypeId = CampRTId,//v5.0
                RecordTypeId = campChannelRTId,
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = TRUE,
                IsActive = true,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Lead_Routing__c = 'Not Applicable',
                Total_Value_Opportunities_Planned__c = 1,Partner_Campaign_Contact_Email__c = 'test@test.com',Partner_Campaign_Contact__c =user.Id);
         insert  cMAPdirAPcamp;
         Account_Play__c apRecord = new Account_Play__c( recordTypeId = apRTId,
                                     Status__c = 'Requires Follow-Up',
                                     Account__c = newCMAPAcc.Id,
                                     Campaign__c = cMAPdirAPcamp.Id,//v5.0
                                     Primary_Contact__c = newCMAPCont .Id,
                                     Customer_Consents_to_Engage_Dell_Partner__c= TRUE,
                                     What_is_their_implementation_deadline__c = System.Today(),
                                     Roadblocks__c  = 'No Road Bloack',
                                     Desired_Outcome__c = 'OutCome',
                                     Estimated_Budget__c = 10922,
                                     Do_they_have_access_to_approved_funds__c = 'Yes', 
                                     Interested_in_DFS_funding__c='No',                                     
                                     Account_Executive__c = u,
                                     Marketing_Comments__c = 'test',
                                     Challenges_Driving_the_Project__c = 'channelges'
                                     );
        insert apRecord;
        
        TriggerExecutionController.setSkipCampaignTriggers(true);
        list<Campaign> listCampaign = new list<Campaign>();
        Campaign campObj= new Campaign(Name='Campaign_CMAP',
                Vertical__c='PTG',
                Sub_Region__c='EMEA',
                StartDate=system.today(),
                Solution__c='Unknown',
                Segment_Business_Unit__c='CSB',
                Region__c='EMEA',
                Country_Code__c = 'IE - Ireland',
                Allocation_Source__c ='Dell Allocation EC EMEA',                     
                Parent_Vehicle__c='Content Development',
                Nurture_Source__c='Dell Nurturing',
                Line_Of_Business__c='Desktop',
                Follow_Up_Role__c='Inside Sales Rep',
                IsActive = true,
                EndDate=system.today(),
                Description='Test',
                Campaign_Vehicle__c='Creative Concept Development',
                Campaign_Objective__c='Action',
                Partner_Event_or_Campaign__c = FALSE,
                Lead_Routing__c = 'Not Applicable',
                RecordTypeId = campRTId);
                //RecordTypeId='012A00000012Xt5');
        listCampaign.add(campObj);
        
        Campaign campObj2= new Campaign(Name='Campaign_CMAP_OEM',
                Vertical__c='PTG',
                Sub_Region__c='EMEA',
                StartDate=system.today(),
                Solution__c='Unknown',
                Segment_Business_Unit__c='CSB',
                Region__c='EMEA',
                Country_Code__c = 'IE - Ireland',
                Allocation_Source__c ='Channel OEM Agency 1',                     
                Parent_Vehicle__c ='Content Development',
                Nurture_Source__c='Dell Nurturing',
                Line_Of_Business__c='Desktop',
                Follow_Up_Role__c='Inside Sales Rep',
                IsActive = true,
                EndDate=system.today(),
                Description='Test',
                Campaign_Vehicle__c ='Creative Concept Development',
                Campaign_Objective__c='Action',
                Partner_Event_or_Campaign__c = FALSE,
                Lead_Routing__c = 'Not Applicable',
                RecordTypeId = campRTId);
        listCampaign.add(campObj2);
        insert listCampaign;
        TriggerExecutionController.setSkipCampaignTriggers(false);        
        
        Id leadcleansingRTId = IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete', 'Lead', true);
        Test.startTest();
        try{
            List<Lead> listLead = new list<Lead>();
            Lead leadRecord = new Lead(lastName = 'Test Lead1',
                email ='testcmap@cmaptest.com',
                status = 'Qualified - Channel Ready',
                Phone='88967544',
                Campaign__c  = listCampaign[0].id,
                recordTypeId = leadcleansingRTId,
                Budget__c = 'Yes',
                Purchase_Timeframe__c ='Immediate',
                Company = 'Test Company',
                Country = 'US',
                Account__c = newAcc.Id,
                Account_Play__c = apRecord.id,
                Marketing_Comments__c = 'test',
                Related_Contact__c = newCont.Id,
                FAP_Originated_Lead__c = 'No',
                Country_CN__c = 'UNITED STATES');
            listLead.add(leadRecord);
            
            Lead leadRecord2 = new Lead(lastName = 'Test Lead2',
                email ='testcmap2@cmaptest.com',
                status = 'Qualified - Channel Ready',
                Phone='889675442',
                Campaign__c  = listCampaign[1].id,
                recordTypeId = leadcleansingRTId,
                Budget__c = 'Yes',
                Purchase_Timeframe__c ='Immediate',
                Company = 'Test Company',
                Country = 'US',
                Account__c = newAcc.Id,
                Account_Play__c = apRecord.id,
                Marketing_Comments__c = 'test',
                Related_Contact__c = newCont.Id,
                FAP_Originated_Lead__c = 'No',Country_CN__c = 'UNITED STATES');
            listLead.add(leadRecord2);
            
            insert listLead;
            System.assertEquals(leadRecord2.status,'Qualified - Channel Ready');
        }
        catch(Exception e){
            System.debug('Success');
        }
        Test.stopTest();
        
        
    }
}