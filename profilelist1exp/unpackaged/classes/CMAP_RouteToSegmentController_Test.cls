/*
REVISION HISTORY
======================================================================================================================
Version    Author    Date            Release#       CR#     Description
-------    ------    ----            --------    ---    -----------
1.0                                                     created
2.0         Azwanti 15-March-2016   FY17-DCS-0401   12720   replace Campaign RT from 'Channel Campaign' to 'Campaign 2.0'.
3.0         SuiYee  25-July-2016    FY17-DCS-0801   12720   Make sure test class remove SeeAllData=true
*/
@isTest
private class CMAP_RouteToSegmentController_Test{
    static testMethod void testR2SSegmentChannelLead(){
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
        //Id leadRTId= IdLookupUtils.getRecordTypeId('Lead Qualification','Lead',true);//v3.0
        Id leadRTId= IdLookupUtils.getRecordTypeId('Direct Lead 2.0','Lead',true);//v3.0
        Id chleadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete','Lead',true);
        string strQueueName = 'NA:TQL Nurturing:N';
        CMAP_Queue_Settings__c queueId = CMAP_Queue_Settings__c.getValues(strQueueName);
        CMAP_Helper.skipinsert = true;
        TriggerExecutionController.setSkipAllTriggers(true);//v3.0
        //v3.0 Insert Custom Settings Data 
        CMAP_Queue_Settings__c objSetting = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6s0MAA',Queue_Name__c='Channel TQL Nurturing',Name='NA:TQL Nurturing:N');
        insert objSetting;
        CMAP_Queue_Settings__c objSettingEclerx = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6hl',Queue_Name__c='Channel_eClerx',Name='Channel_eClerx');
        insert objSettingEclerx;
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
        Id r = [select id from profile where name='R16.10 NA PRM Portal User (MOSS) - Non SSO'].id;
        User user = new User(alias = 'test1231', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = r, country='United States',IsActive =true,
                ContactId = newCont.Id,Badge_Number__c='001266',
                timezonesidkey='America/Los_Angeles', username='testUser'+System.currentTimeMillis()+'@test.com');
       
        insert user;
        //Segment Campaign
        Campaign cMapSegCamp= new Campaign(Name='TestCampaign_Seg',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='NA',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = TRUE,
                IsActive = true,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1,
                Partner_Campaign_Contact_Email__c = 'test@test.com',Partner_Campaign_Contact__c =user.Id);//v3.0
         //camptoInsertList.add(cMapSegCamp);
         insert  cMapSegCamp;
         //Seg LEad
         Lead segleadObj = new Lead(lastName = 'Test',
                firstName = 'Lead_R2S',
                Salutation = 'Mr.',
                MobilePhone = '918645678',
                fax = '87687689',
                Employees__c = '100 - 499',
                Title = 'Consultant',
                //City = 'Test City',
                //State = 'Test State',
                //Country = 'US',
                //PostalCode = '9876545',
                Country_Code__c = 'US',
                Consent_to_engage_Dell_Channel_Partner__c = TRUE,
                LeadSource = 'Demo Day',                
                AnnualRevenue = 10187879,
                Decision_Making_Role__c = 'Business User',
                Questions_Comments__c = 'Test Customer Comments', 
                Sales_Comments__c = 'Test Sales Comments', 
                Marketing_Comments__c = 'Test Marketing Comments',
                email ='testdircmap@cmaptest.com',
                status = 'Open',
                Phone='88967544',
                Campaign__c  =  cMapSegCamp.Id,
                recordTypeId = leadRTId,
                Lead_Type__c = 'Inbound',//v3.0
                Purchase_Timeframe__c ='3 months',              
                Company = 'Test Company');
        insert segleadObj;
        //Ch Camp
        Campaign cMapChCampaign= new Campaign(Name='TestCampaign_Ch',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='NA',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = False,
                Allocation_Source__c = 'Channel ABU Agency 1',
                Nurture_Source__c = 'Channel ABU Agency 1',
                IsActive = true,
                RecordTypeId = campRTId,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1);
        insert  cMapChCampaign;
        
        //Ch Lead status Assigned to Channel Partner
        Lead chleadRecs = new Lead();
                chleadRecs.lastName = 'Test';
                chleadRecs.firstName = 'Lead_R2S';
                chleadRecs.Salutation = 'Mr.';       
                chleadRecs.status = 'Assigned to Channel Partner';
                chleadRecs.Phone='88967544';
                chleadRecs.RecordTypeId = chLeadRTId;
                chleadRecs.Country = 'US';
                chleadRecs.Campaign__c  = cMapChCampaign.Id;
                chleadRecs.Company = 'Test Company';
                chleadRecs.Purchase_Timeframe__c ='3 months';                
                chleadRecs.Budget__c = 'Yes';
                chleadRecs.Segment_Lead__c = segleadObj.Id;
                chleadRecs.OwnerId='00GA0000002y6s0MAA';
                //if(queueId != NULL){
                        //chleadRecs.OwnerId = queueId.Queue_Id__c;
                //}                
        insert chleadRecs;
        chleadRecs.Channel_to_Segment_Criteria__c = 'End user has existing relationship with Dell Segment';
        update chleadRecs;
        System.debug('@@@Owner '+chleadRecs.OwnerId); 
        //get a admin user to run the code
        Profile p = [SELECT id from Profile where name = 'System Administrator' limit 1 ];
        List<User> listUsr = [select id from User where isactive=true AND profileid = :p.id limit 2];
        //Assign user to the queue
        System.runas(listUsr[0]){
            Groupmember q = new Groupmember(
                                    userorGroupId = listUsr[1].Id,
                                    GroupId = '00GA0000002y6s0MAA' 
                                );
            insert q;
        }
        
        System.runas(listUsr[1]){
            PageReference pageRef = Page.CMAP_RouteToSegment;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('chId', chleadRecs.Id);
            CMAP_RouteToSegmentController controller = new CMAP_RouteToSegmentController(new ApexPages.StandardController(new Lead()));
            //controller.chRecord = chleadRecs;
            controller.chId = chleadRecs.Id;
            //chleadRecs.User__c = usr.Id;
            Test.startTest();           
            controller.Redirect();
            controller.saveButton();
            controller.okButton();
            System.assertNotEquals(null,controller.chId);
            TriggerExecutionController.setSkipAllTriggers(false);//v3.0
            Test.stopTest();
        }            
    }
    
    static testMethod void testR2SSegmentSegnavigation(){
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
        //Id leadRTId= IdLookupUtils.getRecordTypeId('Lead Qualification','Lead',true);//v3.0
        Id leadRTId= IdLookupUtils.getRecordTypeId('Direct Lead 2.0','Lead',true);//v3.0
        Id chLeadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete','Lead',true);//v3.0
        //Id chLeadRTId= IdLookupUtils.getRecordTypeId('Channel Lead 2.0','Lead',true);
        string strQueueName = 'NA:TQL Nurturing:N';
        CMAP_Queue_Settings__c queueId = CMAP_Queue_Settings__c.getValues(strQueueName);
        CMAP_Helper.skipinsert = true;
        TriggerExecutionController.setSkipAllTriggers(true);//v3.0
        //v3.0 Insert Custom Settings Data 
        CMAP_Queue_Settings__c objSetting = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6s0MAA',Queue_Name__c='Channel TQL Nurturing',Name='NA:TQL Nurturing:N');
        insert objSetting;
        CMAP_Queue_Settings__c objSettingEclerx = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6hl',Queue_Name__c='Channel_eClerx',Name='Channel_eClerx');
        insert objSettingEclerx;
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
        Id r = [select id from profile where name='R16.10 NA PRM Portal User (MOSS) - Non SSO'].id;
        User user = new User(alias = 'test1232', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = r, country='United States',IsActive =true,
                ContactId = newCont.Id,Badge_Number__c='001266',
                timezonesidkey='America/Los_Angeles', username='testUser'+System.currentTimeMillis()+'@test.com');
       
        insert user;
        //Segment Campaign
        Campaign cMapSegCamp= new Campaign(Name='TestCampaign_Seg',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='NA',
                RecordTypeId = campRTId,//v3.0                       
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = TRUE,
                IsActive = true,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1,
                Partner_Campaign_Contact_Email__c = 'test@test.com',Partner_Campaign_Contact__c =user.Id);//v3.0
         //camptoInsertList.add(cMapSegCamp);
         insert  cMapSegCamp;
         //Seg LEad
         Lead segleadObj = new Lead(lastName = 'Test',
                firstName = 'Lead_R2S',
                Salutation = 'Mr.',
                MobilePhone = '918645678',
                fax = '87687689',
                Employees__c = '100 - 499',
                Title = 'Consultant',
                //City = 'Test City',
                //State = 'Test State',
                //Country = 'US',
                //PostalCode = '9876545',
                Country_Code__c = 'US',
                Consent_to_engage_Dell_Channel_Partner__c = TRUE,
                LeadSource = 'Demo Day',                
                AnnualRevenue = 10187879,
                Decision_Making_Role__c = 'Business User',
                Questions_Comments__c = 'Test Customer Comments', 
                Sales_Comments__c = 'Test Sales Comments', 
                Marketing_Comments__c = 'Test Marketing Comments',
                email ='testdircmap@cmaptest.com',
                status = 'Open',
                Phone='88967544',
                Campaign__c  =  cMapSegCamp.Id,
                recordTypeId = leadRTId, 
                Lead_Type__c = 'Inbound',//v3.0                    
                Purchase_Timeframe__c ='3 months',              
                Company = 'Test Company');
        insert segleadObj;
        //Ch Camp
        Campaign cMapChCampaign= new Campaign(Name='TestCampaign_Ch',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='NA',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = False,
                Allocation_Source__c = 'Channel ABU Agency 1',
                Nurture_Source__c = 'Channel ABU Agency 1',
                IsActive = true,
                RecordTypeId = campRTId,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1);
        insert  cMapChCampaign;
        //Ch Lead
        Lead chleadRecs = new Lead();
                chleadRecs.lastName = 'Test';
                chleadRecs.firstName = 'Lead_R2S';
                chleadRecs.Salutation = 'Mr.';       
                chleadRecs.status = 'Qualified - Channel Ready';
                chleadRecs.Phone='88967544';
                chleadRecs.RecordTypeId = chLeadRTId;
                chleadRecs.Country = 'US';
                chleadRecs.Campaign__c  = cMapChCampaign.Id;
                chleadRecs.Company = 'Test Company';
                chleadRecs.Purchase_Timeframe__c ='3 months';                
                chleadRecs.Budget__c = 'Yes';
                chleadRecs.Segment_Lead__c = segleadObj.Id;
                chleadRecs.User_Access_OLD__c = 'No Access';
                //chleadRecs.Lead_Type__c = 'Inbound';//v3.0 
                //chleadRecs.LeadSource = 'Demo Day';//v3.0
                //chleadRecs.Dell_Partner_can_contact_me__c = TRUE;//v3.0
                chleadRecs.OwnerId='00GA0000002y6s0MAA';
                //if(queueId != NULL){
                       // chleadRecs.OwnerId = queueId.Queue_Id__c;
                //}               
        insert chleadRecs;
        chleadRecs.Channel_to_Segment_Criteria__c = 'End user has existing relationship with Dell Segment';
        update chleadRecs;
        System.debug('@@@Owner '+chleadRecs.OwnerId); 
        //get a admin user to run the code
        Profile p = [SELECT id from Profile where name = 'System Administrator' limit 1 ];
        List<User> listUsr = [select id from User where isactive=true AND profileid = :p.id limit 2];
        //Assign user to the queue
        System.runas(listUsr[0]){
            Groupmember q = new Groupmember(
                                    userorGroupId = listUsr[1].Id,
                                    GroupId = '00GA0000002y6s0MAA' 
                                );
            insert q;
        }
        Leadshare share = new Leadshare();
        share.LeadAccessLevel = 'Edit';
        share.UserOrGroupId = listUsr[1].id;
        share.LeadId = chleadRecs.Id;
        insert share;
        System.runas(listUsr[1]){
            PageReference pageRef = Page.CMAP_RouteToSegment;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('newid', segleadObj.Id);
        ApexPages.currentPage().getParameters().put('recid', chleadRecs.Id);
        ApexPages.currentPage().getParameters().put('action', 'segLeadCancel');
        CMAP_RouteToSegmentController controller = new CMAP_RouteToSegmentController(new ApexPages.StandardController(new Lead()));
            //controller.chRecord = chleadRecs;
            //controller.newid = segleadObj.Id;
            //chleadRecs.User__c = usr.Id;
            Test.startTest();  
            controller.Redirect();
            System.assertNotEquals(null,controller.newId);          
            controller.saveButton();
            //controller.okButton();
            TriggerExecutionController.setSkipAllTriggers(false);//v3.0
        Test.stopTest();
        }            
    }
    
    static testMethod void testR2SSegmentSegnavigationRead(){
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
        //Id leadRTId= IdLookupUtils.getRecordTypeId('Lead Qualification','Lead',true);//v3.0
        Id leadRTId= IdLookupUtils.getRecordTypeId('Direct Lead 2.0','Lead',true);
        Id chLeadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete','Lead',true);
        string strQueueName = 'NA:TQL Nurturing:N';
        CMAP_Queue_Settings__c queueId = CMAP_Queue_Settings__c.getValues(strQueueName);
        CMAP_Helper.skipinsert = true;
        //v3.0 Insert Custom Settings Data 
        CMAP_Queue_Settings__c objSetting = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6s0MAA',Queue_Name__c='Channel TQL Nurturing',Name='NA:TQL Nurturing:N');
        insert objSetting;
        CMAP_Queue_Settings__c objSettingEclerx = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6hl',Queue_Name__c='Channel_eClerx',Name='Channel_eClerx');
        insert objSettingEclerx;
        TriggerExecutionController.setSkipAllTriggers(true);//v3.0
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
        Id r = [select id from profile where name='R16.10 NA PRM Portal User (MOSS) - Non SSO'].id;
        User user = new User(alias = 'test1233', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = r, country='United States',IsActive =true,
                ContactId = newCont.Id,Badge_Number__c='001266',
                timezonesidkey='America/Los_Angeles', username='testUser'+System.currentTimeMillis()+'@test.com');
       
        insert user;
        
        //Segment Campaign
        Campaign cMapSegCamp= new Campaign(Name='TestCampaign_Seg',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='NA',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = TRUE,
                IsActive = true,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1,
                Partner_Campaign_Contact_Email__c = 'test@test.com',Partner_Campaign_Contact__c =user.Id);//v3.0                            
         //camptoInsertList.add(cMapSegCamp);
         insert  cMapSegCamp;
         //Seg LEad
         Lead segleadObj = new Lead(lastName = 'Test',
                firstName = 'Lead_R2S',
                Salutation = 'Mr.',
                MobilePhone = '918645678',
                fax = '87687689',
                Employees__c = '100 - 499',
                Title = 'Consultant',
                //City = 'Test City',
                //State = 'Test State',
                //Country = 'US',
                //PostalCode = '9876545',
                Country_Code__c = 'US',
                Consent_to_engage_Dell_Channel_Partner__c = TRUE,
                LeadSource = 'Demo Day',                
                AnnualRevenue = 10187879,
                Decision_Making_Role__c = 'Business User',
                Questions_Comments__c = 'Test Customer Comments', 
                Sales_Comments__c = 'Test Sales Comments', 
                Marketing_Comments__c = 'Test Marketing Comments',
                email ='testdircmap@cmaptest.com',
                status = 'Open',
                Phone='88967544',
                Campaign__c  =  cMapSegCamp.Id,
                recordTypeId = leadRTId,                
                Purchase_Timeframe__c ='3 months', 
                Lead_Type__c = 'Inbound',//v3.0   
                Company = 'Test Company');
        insert segleadObj;
        //Ch Camp
        Campaign cMapChCampaign= new Campaign(Name='TestCampaign_Ch',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='NA',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = False,
                Allocation_Source__c = 'Channel ABU Agency 1',
                Nurture_Source__c = 'Channel ABU Agency 1',
                IsActive = true,
                RecordTypeId = campRTId,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1);
        insert  cMapChCampaign;
        //Ch Lead
        Lead chleadRecs = new Lead();
                chleadRecs.lastName = 'Test';
                chleadRecs.firstName = 'Lead_R2S';
                chleadRecs.Salutation = 'Mr.';       
                chleadRecs.status = 'Qualified - Channel Ready';
                chleadRecs.Phone='88967544';
                chleadRecs.RecordTypeId = chLeadRTId;
                chleadRecs.Country = 'US';
                chleadRecs.Campaign__c  = cMapChCampaign.Id;
                chleadRecs.Company = 'Test Company';
                chleadRecs.Purchase_Timeframe__c ='3 months';                
                chleadRecs.Budget__c = 'Yes';
                chleadRecs.Segment_Lead__c = segleadObj.Id;
                chleadRecs.User_Access_OLD__c = 'Read';
                chleadRecs.OwnerId ='00GA0000002y6s0MAA';
                //if(queueId != NULL){
                        //chleadRecs.OwnerId = queueId.Queue_Id__c;
                //}                
        insert chleadRecs;
        chleadRecs.Channel_to_Segment_Criteria__c = 'End user has existing relationship with Dell Segment';
        update chleadRecs;
        System.debug('@@@Owner '+chleadRecs.OwnerId); 
        //get a admin user to run the code
        Profile p = [SELECT id from Profile where name = 'System Administrator' limit 1 ];
        List<User> listUsr = [select id from User where isactive=true AND profileid = :p.id limit 2];
        //Assign user to the queue
        System.runas(listUsr[0]){
            Groupmember q = new Groupmember(
                                    userorGroupId = listUsr[1].Id,
                                    //GroupId = queueId.Queue_Id__c
                                    GroupId ='00GA0000002y6s0MAA'
                            );
            insert q;
        }
        Leadshare share = new Leadshare();
        share.LeadAccessLevel = 'Edit';
        share.UserOrGroupId = listUsr[1].id;
        share.LeadId = chleadRecs.Id;
        insert share;
        System.runas(listUsr[1]){
            PageReference pageRef = Page.CMAP_RouteToSegment;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('newid', segleadObj.Id);
        ApexPages.currentPage().getParameters().put('recid', chleadRecs.Id);
        ApexPages.currentPage().getParameters().put('action', 'segLeadCancel');
        CMAP_RouteToSegmentController controller = new CMAP_RouteToSegmentController(new ApexPages.StandardController(new Lead()));
            //controller.chRecord = chleadRecs;
            //controller.newid = segleadObj.Id;
            //chleadRecs.User__c = usr.Id;
            Test.startTest();  
            controller.Redirect();          
            System.assertNotEquals(null,controller.newId);          
            //controller.saveButton();
            //controller.okButton();
        TriggerExecutionController.setSkipAllTriggers(false);//v3.0
        Test.stopTest();
        }            
    }

    static testMethod void testR2SRLChannelLead(){
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
        Id leadRTId2= IdLookupUtils.getRecordTypeId('Lead Qualification','Lead',true);//v3.0
        Id leadRTId= IdLookupUtils.getRecordTypeId('Direct Lead 2.0','Lead',true);//v3.0
        Id chLeadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete','Lead',true);
        Id campChannelRTId= IdLookupUtils.getRecordTypeId('Channel Partner Communications','Campaign',true);//v3.0
        string strQueueName = 'NA:TQL Nurturing:N';
        CMAP_Queue_Settings__c queueId = CMAP_Queue_Settings__c.getValues(strQueueName);
        CMAP_Helper.skipinsert = true;
        //v3.0 Insert Custom Settings Data 
        CMAP_Queue_Settings__c objSetting = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6s0MAA',Queue_Name__c='Channel TQL Nurturing',Name='NA:TQL Nurturing:N');
        insert objSetting;
        CMAP_Queue_Settings__c objSettingEclerx = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6hl',Queue_Name__c='Channel_eClerx',Name='Channel_eClerx');
        insert objSettingEclerx;
        TriggerExecutionController.setSkipAllTriggers(true);//v3.0
        Account newAcc = new Account(name='MyTestAccount4444');
        insert newAcc;
                
        Contact newCont2 = new Contact(FirstName='MyTestContact444',
                 LastName='MyTestContact444',
                 accountId=newAcc.Id,
                 Status__c = 'Marketing Suspect',
                 Email='MyTestContactEmail_444@dell.com',
                 fax='1234567',
                 MobilePhone='0987654444',
                 Last_Operation_Performed__c = 'testing');
        insert newCont2;
        Id r = [select id from profile where name='R16.10 NA PRM Portal User (MOSS) - Non SSO'].id;
        User user = new User(alias = 'test443', email='test124443@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = r, country='United States',IsActive =true,
                ContactId = newCont2.Id,Badge_Number__c='001266',
                timezonesidkey='America/Los_Angeles', username='testUser'+System.currentTimeMillis()+'@test.com');
       
        insert user;
        //Segment Campaign
        Campaign cMapSegCamp= new Campaign(Name='TestCampaign_Seg',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='NA',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = TRUE,
                IsActive = true,
                recordTypeId = campChannelRTId,                             
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1,
                Partner_Campaign_Contact_Email__c = 'test@test.com',Partner_Campaign_Contact__c =user.Id);//v3.0     
         //camptoInsertList.add(cMapSegCamp);
         insert  cMapSegCamp;
         //Seg LEad
         Lead segleadObj = new Lead(lastName = 'Test',
                firstName = 'Lead_R2S',
                Salutation = 'Mr.',
                MobilePhone = '918645678',
                fax = '87687689',
                Employees__c = '100 - 499',
                Title = 'Consultant',
                //City = 'Test City',
                //State = 'Test State',
                //Country = 'US',
                //PostalCode = '9876545',
                Country_Code__c = 'US',
                Consent_to_engage_Dell_Channel_Partner__c = TRUE,
                LeadSource = 'Demo Day',                
                AnnualRevenue = 10187879,
                Decision_Making_Role__c = 'Business User',
                Questions_Comments__c = 'Test Customer Comments', 
                Sales_Comments__c = 'Test Sales Comments', 
                Marketing_Comments__c = 'Test Marketing Comments',
                email ='testdircmap@cmaptest.com',
                status = 'Open',
                Phone='88967544',
                Campaign__c  =  cMapSegCamp.Id,
                recordTypeId = leadRTId2,                
                Purchase_Timeframe__c ='3 months',
                Lead_Type__c = 'Inbound',//v3.0                      
                Company = 'Test Company');
        insert segleadObj;
        Contact newCont = new Contact(FirstName='MyTestContact3',
                 LastName='MyTestContact3',
                 accountId=newAcc.Id, 
                 Status__c = 'Marketing Suspect',
                 Email='MyTestContactEmail_3@ust-global.com',
                 fax='1234567',
                 MobilePhone='0987654',              
                 Last_Operation_Performed__c = 'testing');
        insert newCont;
         //RL
        Relationship_Lead__c rlObj = new Relationship_Lead__c(
            Contact__c = newCont.Id,
            Lead_ID_Do_Not_Edit__c = segleadObj.Id,
            Campaign_ID_LinkTracker__c = cMapSegCamp.Id,
            Campaign__c = cMapSegCamp.Id,
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
        Test.startTest();
        //Ch Camp
        Campaign cMapChCampaign= new Campaign(Name='TestCampaign_Ch',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='NA',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = False,
                Allocation_Source__c = 'Channel ABU Agency 1',
                Nurture_Source__c = 'Channel ABU Agency 1',
                IsActive = true,
                RecordTypeId = campRTId,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1);
        insert  cMapChCampaign;
        //Ch Lead
        Lead chleadRecs = new Lead();
                chleadRecs.lastName = 'Test';
                chleadRecs.firstName = 'Lead_R2S';
                chleadRecs.Salutation = 'Mr.';       
                chleadRecs.status = 'Qualified - Channel Ready';
                chleadRecs.Phone='88967544';
                chleadRecs.RecordTypeId = chLeadRTId;
                chleadRecs.Country = 'US';
                chleadRecs.Campaign__c  = cMapChCampaign.Id;
                chleadRecs.Company = 'Test Company';
                chleadRecs.Purchase_Timeframe__c ='3 months';                
                chleadRecs.Budget__c = 'Yes';
                chleadRecs.Relationship_Lead__c = rlObj.Id;
                chleadRecs.OwnerId = '00GA0000002y6s0MAA';
                //if(queueId != NULL){
                        //chleadRecs.OwnerId = queueId.Queue_Id__c;
                //}                
        insert chleadRecs;
        chleadRecs.Channel_to_Segment_Criteria__c = 'End user has existing relationship with Dell Segment';
        update chleadRecs;
        System.debug('@@@Owner '+chleadRecs.OwnerId); 
        //get a admin user to run the code
        Profile p = [SELECT id from Profile where name = 'System Administrator' limit 1 ];
        List<User> listUsr = [select id from User where isactive=true AND profileid = :p.id limit 2];
        //Assign user to the queue
        System.runas(listUsr[0]){
            system.Debug('---ghjkl---');
            Groupmember q = new Groupmember(
                                    userorGroupId = listUsr[1].Id,
                                    GroupId = '00GA0000002y6s0MAA'
                                );
            insert q;
        }
        
        System.runas(listUsr[1]){
            PageReference pageRef = Page.CMAP_RouteToSegment;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('chId', chleadRecs.Id);
            CMAP_RouteToSegmentController controller = new CMAP_RouteToSegmentController(new ApexPages.StandardController(new Lead()));
            //controller.chRecord = chleadRecs;
            controller.chId = chleadRecs.Id;
            //chleadRecs.User__c = usr.Id;
              
            controller.Redirect();
            System.assertNotEquals(null,controller.chId);           
            controller.saveButton();
            controller.okButton();
             TriggerExecutionController.setSkipAllTriggers(false);//v3.0
        Test.stopTest();
        }            
    }
    static testMethod void testR2SAPChannelLead(){
        Id leadRTId2= IdLookupUtils.getRecordTypeId('Lead Qualification','Lead',true);//v3.0
        Id leadRTId= IdLookupUtils.getRecordTypeId('Direct Lead 2.0','Lead',true);//v3.0
        Id chLeadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete','Lead',true);
        Id campChannelRTId= IdLookupUtils.getRecordTypeId('Channel Partner Communications','Campaign',true);//v3.0
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true);//v3.0
        string strQueueName = 'NA:TQL Nurturing:N';
        CMAP_Queue_Settings__c queueId = CMAP_Queue_Settings__c.getValues(strQueueName);
        CMAP_Helper.skipinsert = true;
        //v3.0 Insert Custom Settings Data 
        CMAP_Queue_Settings__c objSetting = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6s0MAA',Queue_Name__c='Channel TQL Nurturing',Name='NA:TQL Nurturing:N');
        insert objSetting;
        CMAP_Queue_Settings__c objSettingEclerx = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6hl',Queue_Name__c='Channel_eClerx',Name='Channel_eClerx');
        insert objSettingEclerx;
        TriggerExecutionController.setSkipAllTriggers(true);//v3.0
        Id apRTId= IdLookupUtils.getRecordTypeId('GBL_Account_Play_RT_R10.10','Account_Play__c',true);
        Date dt = System.Today();
        Id u = userinfo.getUserId();
        Account newCMAPAcc = new Account(name='MyTestAccountCMAP');
        insert newCMAPAcc;
        
        Contact newCont2 = new Contact(FirstName='MyTestContact444',
                 LastName='MyTestContact444',
                 accountId=newCMAPAcc.Id,
                 Status__c = 'Marketing Suspect',
                 Email='MyTestContactEmail_444@dell.com',
                 fax='1234567',
                 MobilePhone='0987654444',
                 Last_Operation_Performed__c = 'testing');
        insert newCont2;
        Id r = [select id from profile where name='R16.10 NA PRM Portal User (MOSS) - Non SSO'].id;
        User user = new User(alias = 'test441', email='test124443@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = r, country='United States',IsActive =true,
                ContactId = newCont2.Id,Badge_Number__c='001266',
                timezonesidkey='America/Los_Angeles', username='testUser'+System.currentTimeMillis()+'@test.com');
       
        insert user;   
        //Segment Campaign
        Campaign cMapDirAPCamp= new Campaign(Name='TestCampaign_Direct',
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
                RecordTypeId=campChannelRTId,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1,
                Partner_Campaign_Contact_Email__c = 'test@test.com',Partner_Campaign_Contact__c =user.Id);//v3.0 
        insert  cMapDirAPCamp;
        Contact newCMAPCont = new Contact(Salutation = 'Mr.',
                 FirstName='MyTestContactCMAP',
                 LastName='MyTestContactCMAP',
                 Title = 'Test Title',
                 accountId=newCMAPAcc.Id,
                 Email='MyTestCMAPContactEmail_3@ust-global.com',
                 fax='9876543',
                 Status__c = 'Prospect',
                 phone = '99888778',
                 MobilePhone='536389097',
                 Last_Operation_Performed__c = 'testing',
                 MailingCountry = 'US', 
                 MailingCity='City Test',
                 MailingState = 'Test State',
                 MailingStreet = 'Test Street',
                 MailingPostalCode = '683520'
                 );
        insert newCMAPCont;
        Account_Play__c apRecord = new Account_Play__c( recordTypeId = apRTId,
                                     Status__c = 'Requires Follow-Up',
                                     Account__c = newCMAPAcc.Id,
                                     Campaign__c = cMapDirAPCamp.Id,
                                     Primary_Contact__c = newCMAPCont .Id,
                                     Customer_Consents_to_Engage_Dell_Partner__c= TRUE,
                                     What_is_their_implementation_deadline__c = System.Today(),
                                     Roadblocks__c  = 'No Road Bloack',
                                     Desired_Outcome__c = 'OutCome',
                                     Estimated_Budget__c = 10922,
                                     Do_they_have_access_to_approved_funds__c = 'Yes', 
                                     Interested_in_DFS_funding__c='No',                                     
                                     Account_Executive__c = u
                                     
                                     
                                     );
        insert apRecord;
             
        Test.startTest();
        //Ch Camp
        Campaign cMapChCampaign= new Campaign(Name='TestCampaign_Ch',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='NA',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = False,
                Allocation_Source__c = 'Channel ABU Agency 1',
                Nurture_Source__c = 'Channel ABU Agency 1',
                IsActive = true,
                RecordTypeId = campRTId,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1);
        insert  cMapChCampaign;
        //Ch Lead status Qualified - Channel Ready
        Lead chleadRecs = new Lead();
                chleadRecs.lastName = 'Test';
                chleadRecs.firstName = 'Lead_R2S';
                chleadRecs.Salutation = 'Mr.';       
                chleadRecs.status = 'Assigned to Channel Partner';
                chleadRecs.Phone='88967544';
                chleadRecs.RecordTypeId = chLeadRTId;
                chleadRecs.Country = 'US';
                chleadRecs.Campaign__c  = cMapChCampaign.Id;
                chleadRecs.Company = 'Test Company';
                chleadRecs.Purchase_Timeframe__c ='3 months';                
                chleadRecs.Budget__c = 'Yes';
                chleadRecs.Account_Play__c = apRecord.Id;
                chleadRecs.OwnerId = '00GA0000002y6hl';
                //if(queueId != NULL){
                        //chleadRecs.OwnerId = queueId.Queue_Id__c;
                //}                 
        insert chleadRecs;
        chleadRecs.Channel_to_Segment_Criteria__c = 'End user has existing relationship with Dell Segment';
        update chleadRecs;
        System.debug('@@@Owner '+chleadRecs.OwnerId); 
        //get a admin user to run the code
        Profile p = [SELECT id from Profile where name = 'System Administrator' limit 1 ];
        List<User> listUsr = [select id from User where isactive=true AND profileid = :p.id limit 2];
        //Assign user to the queue
        System.runas(listUsr[0]){
            Groupmember q = new Groupmember(
                                    userorGroupId = listUsr[1].Id,
                                    GroupId = '00GA0000002y6hl'
                                );
            insert q;
        }
        
        System.runas(listUsr[1]){
            PageReference pageRef = Page.CMAP_RouteToSegment;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('chId', chleadRecs.Id);
            CMAP_RouteToSegmentController controller = new CMAP_RouteToSegmentController(new ApexPages.StandardController(new Lead()));
            //controller.chRecord = chleadRecs;
            controller.chId = chleadRecs.Id;
            //chleadRecs.User__c = usr.Id;
              
            controller.Redirect();
            System.assertNotEquals(null,controller.chId);           
            //controller.saveButton();
            controller.okButton();
             TriggerExecutionController.setSkipAllTriggers(false);//v3.0
        Test.stopTest();
        }            
    }
    static testMethod void testR2SRLRLnavigation(){
        Id leadRTId2= IdLookupUtils.getRecordTypeId('Lead Qualification','Lead',true);//v3.0
        Id leadRTId= IdLookupUtils.getRecordTypeId('Direct Lead 2.0','Lead',true);//v3.0
        Id chLeadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete','Lead',true);
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true);//v3.0
        Id campChannelRTId= IdLookupUtils.getRecordTypeId('Channel Partner Communications','Campaign',true);//v3.0
        string strQueueName = 'NA:TQL Nurturing:N';
        CMAP_Queue_Settings__c queueId = CMAP_Queue_Settings__c.getValues(strQueueName);
        CMAP_Helper.skipinsert = true;
        //v3.0 Insert Custom Settings Data 
        CMAP_Queue_Settings__c objSetting = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6s0MAA',Queue_Name__c='Channel TQL Nurturing',Name='NA:TQL Nurturing:N');
        insert objSetting;
        CMAP_Queue_Settings__c objSettingEclerx = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6hl',Queue_Name__c='Channel_eClerx',Name='Channel_eClerx');
        insert objSettingEclerx;
        TriggerExecutionController.setSkipAllTriggers(true);//v3.0
        Account newAcc = new Account(name='MyTestAccount3');
        insert newAcc;
        Contact newCont2 = new Contact(FirstName='MyTestContact444',
                 LastName='MyTestContact444',
                 accountId=newAcc.Id,
                 Status__c = 'Marketing Suspect',
                 Email='MyTestContactEmail_444@dell.com',
                 fax='1234567',
                 MobilePhone='0987654444',
                 Last_Operation_Performed__c = 'testing');
        insert newCont2;
        Id r = [select id from profile where name='R16.10 NA PRM Portal User (MOSS) - Non SSO'].id;
        User user = new User(alias = 'test442', email='test124443@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = r, country='United States',IsActive =true,
                ContactId = newCont2.Id,Badge_Number__c='001266',
                timezonesidkey='America/Los_Angeles', username='testUser'+System.currentTimeMillis()+'@test.com');
       
        insert user;   
        //Segment Campaign
        Campaign cMapSegCamp= new Campaign(Name='TestCampaign_Seg',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='NA', 
                recordTypeId = campChannelRTId,//v3.0                             
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = TRUE,
                IsActive = true,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1,
                Partner_Campaign_Contact_Email__c = 'test@test.com',Partner_Campaign_Contact__c =user.Id);//v3.0                              
         //camptoInsertList.add(cMapSegCamp);
         insert  cMapSegCamp;
         //Seg LEad
         Lead segleadObj = new Lead(lastName = 'Test',
                firstName = 'Lead_R2S',
                Salutation = 'Mr.',
                MobilePhone = '918645678',
                fax = '87687689',
                Employees__c = '100 - 499',
                Title = 'Consultant',
                //City = 'Test City',
                //State = 'Test State',
                //Country = 'US',
                //PostalCode = '9876545',
                Country_Code__c = 'US',
                Consent_to_engage_Dell_Channel_Partner__c = TRUE,
                LeadSource = 'Demo Day',                
                AnnualRevenue = 10187879,
                Decision_Making_Role__c = 'Business User',
                Questions_Comments__c = 'Test Customer Comments', 
                Sales_Comments__c = 'Test Sales Comments', 
                Marketing_Comments__c = 'Test Marketing Comments',
                email ='testdircmap@cmaptest.com',
                status = 'Open',
                Phone='88967544',
                Campaign__c  =  cMapSegCamp.Id,
                recordTypeId = leadRTId2,                
                Purchase_Timeframe__c ='3 months',
                Lead_Type__c = 'Inbound',//v3.0
                Company = 'Test Company');
        insert segleadObj;
         
         Contact newCont = new Contact(FirstName='MyTestContact3',
                 LastName='MyTestContact3',
                 accountId=newAcc.Id, 
                 Status__c = 'Marketing Suspect',
                 Email='MyTestContactEmail_3@ust-global.com',
                 fax='1234567',
                 MobilePhone='0987654',              
                 Last_Operation_Performed__c = 'testing');
        insert newCont;
         //RL
        Relationship_Lead__c rlObj = new Relationship_Lead__c(
            Contact__c = newCont.Id,
            Lead_ID_Do_Not_Edit__c = segleadObj.Id,
            Campaign_ID_LinkTracker__c = cMapSegCamp.Id,
            Campaign__c = cMapSegCamp.Id,
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
        Test.startTest();
        //Ch Camp
        Campaign cMapChCampaign= new Campaign(Name='TestCampaign_Ch',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='NA',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = False,
                Allocation_Source__c = 'Channel ABU Agency 1',
                Nurture_Source__c = 'Channel ABU Agency 1',
                IsActive = true,
                RecordTypeId = campRTId,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1);
        insert  cMapChCampaign;
        //Ch Lead
        Lead chleadRecs = new Lead();
                chleadRecs.lastName = 'Test';
                chleadRecs.firstName = 'Lead_R2S';
                chleadRecs.Salutation = 'Mr.';       
                chleadRecs.status = 'Qualified - Channel Ready';
                chleadRecs.Phone='88967544';
                chleadRecs.RecordTypeId = chLeadRTId;
                chleadRecs.Country = 'US';
                chleadRecs.Campaign__c  = cMapChCampaign.Id;
                chleadRecs.Company = 'Test Company';
                chleadRecs.Purchase_Timeframe__c ='3 months';                
                chleadRecs.Budget__c = 'Yes';
                chleadRecs.Relationship_Lead__c = rlObj.Id;
                chleadRecs.User_Access_OLD__c = 'No Access';
                chleadRecs.OwnerId = '00GA0000002y6hl';//v3.0
                chleadRecs.Dell_Partner_can_contact_me__c = TRUE;//v3.0
                //if(queueId != NULL){
                        //chleadRecs.OwnerId = queueId.Queue_Id__c;
                //}                
        insert chleadRecs;
        chleadRecs.Channel_to_Segment_Criteria__c = 'End user has existing relationship with Dell Segment';
        update chleadRecs;
        System.debug('@@@Owner '+chleadRecs.OwnerId); 
        //get a admin user to run the code
        Profile p = [SELECT id from Profile where name = 'System Administrator' limit 1 ];
        List<User> listUsr = [select id from User where isactive=true AND profileid = :p.id limit 2];
        //Assign user to the queue
        System.runas(listUsr[0]){
            Groupmember q = new Groupmember(
                                    userorGroupId = listUsr[1].Id,
                                    GroupId = '00GA0000002y6hl'
                                );
            insert q;
        }
        
        System.runas(listUsr[1]){
            PageReference pageRef = Page.CMAP_RouteToSegment;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('newid', rlObj.Id);
        ApexPages.currentPage().getParameters().put('recid', chleadRecs.Id);
        ApexPages.currentPage().getParameters().put('action', 'relLeadCancel');
        CMAP_RouteToSegmentController controller = new CMAP_RouteToSegmentController(new ApexPages.StandardController(new Lead()));
            //controller.chRecord = chleadRecs;
            //controller.newid = segleadObj.Id;
            //chleadRecs.User__c = usr.Id;
              
            controller.Redirect();
            System.assertNotEquals(null,controller.newId);          
            //controller.saveButton();
            //controller.okButton();
            TriggerExecutionController.setSkipAllTriggers(false);//v3.0
        Test.stopTest();
        }            
    }
    
    static testMethod void testR2SRLRLnavigationRead(){
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
        Id leadRTId= IdLookupUtils.getRecordTypeId('Lead Qualification','Lead',true);
        Id leadRTId2= IdLookupUtils.getRecordTypeId('Direct Lead 2.0','Lead',true);//v3.0
        Id chLeadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete','Lead',true);
        Id campChannelRTId= IdLookupUtils.getRecordTypeId('Channel Partner Communications','Campaign',true);//v3.0
        string strQueueName = 'NA:TQL Nurturing:N';
        CMAP_Queue_Settings__c queueId = CMAP_Queue_Settings__c.getValues(strQueueName);
        CMAP_Helper.skipinsert = true;
        //v3.0 Insert Custom Settings Data 
        CMAP_Queue_Settings__c objSetting = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6s0MAA',Queue_Name__c='Channel TQL Nurturing',Name='NA:TQL Nurturing:N');
        insert objSetting;
        CMAP_Queue_Settings__c objSettingEclerx = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6hl',Queue_Name__c='Channel_eClerx',Name='Channel_eClerx');
        insert objSettingEclerx;
        TriggerExecutionController.setSkipAllTriggers(true);//v3.0
        Account newAcc = new Account(name='MyTestAccount3');
        insert newAcc;
        //Segment Campaign
        Campaign cMapSegCamp= new Campaign(Name='TestCampaign_Seg',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='NA',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                recordTypeId=campChannelRTId,//v3.0
                Partner_Event_or_Campaign__c = false,//v3.0
                IsActive = true,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1);
         //camptoInsertList.add(cMapSegCamp);
         insert  cMapSegCamp;
         //Seg LEad
         Lead segleadObj = new Lead(lastName = 'Test',
                firstName = 'Lead_R2S',
                Salutation = 'Mr.',
                MobilePhone = '918645678',
                fax = '87687689',
                Employees__c = '100 - 499',
                Title = 'Consultant',
                //City = 'Test City',
                //State = 'Test State',
                //Country = 'US',
                //PostalCode = '9876545',
                Country_Code__c = 'US',
                Consent_to_engage_Dell_Channel_Partner__c = TRUE,
                LeadSource = 'Demo Day',                
                AnnualRevenue = 10187879,
                Decision_Making_Role__c = 'Business User',
                Questions_Comments__c = 'Test Customer Comments', 
                Sales_Comments__c = 'Test Sales Comments', 
                Marketing_Comments__c = 'Test Marketing Comments',
                email ='testdircmap@cmaptest.com',
                status = 'Open',
                Phone='88967544',
                Campaign__c  =  cMapSegCamp.Id,
                recordTypeId = leadRTId,                
                Purchase_Timeframe__c ='3 months', 
                Lead_Type__c = 'Inbound',//v3.0
                Company = 'Test Company');
        insert segleadObj;
         
         Contact newCont = new Contact(FirstName='MyTestContact3',
                 LastName='MyTestContact3',
                 accountId=newAcc.Id, 
                 Status__c = 'Marketing Suspect',
                 Email='MyTestContactEmail_3@ust-global.com',
                 fax='1234567',
                 MobilePhone='0987654',              
                 Last_Operation_Performed__c = 'testing');
        insert newCont;
         //RL
        Relationship_Lead__c rlObj = new Relationship_Lead__c(
            Contact__c = newCont.Id,
            Lead_ID_Do_Not_Edit__c = segleadObj.Id,
            Campaign_ID_LinkTracker__c = cMapSegCamp.Id,
            Campaign__c = cMapSegCamp.Id,
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
        Test.startTest();
        //Ch Camp
        Campaign cMapChCampaign= new Campaign(Name='TestCampaign_Ch',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='NA',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = False,
                Allocation_Source__c = 'Channel ABU Agency 1',
                Nurture_Source__c = 'Channel ABU Agency 1',
                IsActive = true,
                RecordTypeId = campRTId,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1);
        insert  cMapChCampaign;
        //Ch Lead
        Lead chleadRecs = new Lead();
                chleadRecs.lastName = 'Test';
                chleadRecs.firstName = 'Lead_R2S';
                chleadRecs.Salutation = 'Mr.';       
                chleadRecs.status = 'Qualified - Channel Ready';
                chleadRecs.Phone='88967544';
                chleadRecs.RecordTypeId = chLeadRTId;
                chleadRecs.Country = 'US';
                chleadRecs.Campaign__c  = cMapChCampaign.Id;
                chleadRecs.Company = 'Test Company';
                chleadRecs.Purchase_Timeframe__c ='3 months';                
                chleadRecs.Budget__c = 'Yes';
                chleadRecs.Relationship_Lead__c = rlObj.Id;
                chleadRecs.User_Access_OLD__c = 'Read';
                chleadRecs.OwnerId = '00GA0000002y6hl';
                //if(queueId != NULL){
                        //chleadRecs.OwnerId = queueId.Queue_Id__c;
                //}                
        insert chleadRecs;
        chleadRecs.Channel_to_Segment_Criteria__c = 'End user has existing relationship with Dell Segment';
        update chleadRecs;
        System.debug('@@@Owner '+chleadRecs.OwnerId); 
        //get a admin user to run the code
        Profile p = [SELECT id from Profile where name = 'System Administrator' limit 1 ];
        List<User> listUsr = [select id from User where isactive=true AND profileid = :p.id limit 2];
        //Assign user to the queue
        System.runas(listUsr[0]){
            Groupmember q = new Groupmember(
                                    userorGroupId = listUsr[1].Id,
                                    GroupId = '00GA0000002y6hl' 
                                );
            insert q;
        }
        
        System.runas(listUsr[1]){
            PageReference pageRef = Page.CMAP_RouteToSegment;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('newid', rlObj.Id);
        ApexPages.currentPage().getParameters().put('recid', chleadRecs.Id);
        ApexPages.currentPage().getParameters().put('action', 'relLeadCancel');
        CMAP_RouteToSegmentController controller = new CMAP_RouteToSegmentController(new ApexPages.StandardController(new Lead()));
            //controller.chRecord = chleadRecs;
            //controller.newid = segleadObj.Id;
            //chleadRecs.User__c = usr.Id;
              
            controller.Redirect();
            System.assertNotEquals(null,controller.newId);          
            //controller.saveButton();
            //controller.okButton();
            TriggerExecutionController.setSkipAllTriggers(false);//v3.0
        Test.stopTest();
        }
        
    
    }

    static testMethod void testR2SAddPermissionset(){
        User usr;
        List<profile> listProf;
        
        listProf = [select id,name from Profile where name like '%GBL Channel Marketing%' order by CreatedDate DESC limit 1];
        
        usr = new User(
                    Username='testUser'+System.currentTimeMillis()+'@test.com',
                    Alias = 'test1', 
                    Email='test3445@dell.com', 
                    FirstName='John', 
                    LastName='Doe', 
                    ProfileId = listProf[0].Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Badge_Number__c='UATUser', 
                    isActive = TRUE
                    );
        insert usr;
		System.assertEquals('test3445@dell.com',usr.Email);
        System.runas(usr){
        CMAP_RouteToSegmentController controller = new CMAP_RouteToSegmentController(new ApexPages.StandardController(new Lead()));
        Test.startTest();
        controller.addPermissionset();
        Test.stopTest();
        }
    }
    
    static testMethod void testR2SForAssignedLead(){
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
        Id leadRTId= IdLookupUtils.getRecordTypeId('Lead Qualification','Lead',true);
        Id leadRTId2= IdLookupUtils.getRecordTypeId('Direct Lead 2.0','Lead',true);//v3.0
        Id chLeadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Assignment Complete','Lead',true);
        TriggerExecutionController.setSkipAllTriggers(true);//v3.0
        CMAP_Helper.skipinsert = true;
        string strQueueName = 'NA:Default Queue:A';
        CMAP_Queue_Settings__c queueId = CMAP_Queue_Settings__c.getValues(strQueueName);
        //v3.0 Insert Custom Settings Data 
        CMAP_Queue_Settings__c objSetting = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6s0MAA',Queue_Name__c='Channel TQL Nurturing',Name='NA:TQL Nurturing:N');
        insert objSetting;
        CMAP_Queue_Settings__c objSettingEclerx = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6hl',Queue_Name__c='Channel_eClerx',Name='Channel_eClerx');
        insert objSettingEclerx;
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Account newAcc = new Account(name='MyTestAccountABC', Type = 'Partner' ,
                                    RecordtypeId = accRTId);
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
        final List<Profile> partnerProfiles = [select id,name 
                                               from Profile 
                                               where UserType = 'PowerPartner' and name like '%PRM%' 
                                               ORDER BY CreatedDate DESC limit 1];
                                               
        User partnerUser=new User(
                    Username='myUSTABC5' + System.currentTimeMillis() + '@dell.com',
                    Alias = 'MTU5', 
                    Email='MyTestUserABC5@dell.com', 
                    FirstName='MyTestUser5', 
                    LastName='MyTestUser5',  
                    ProfileId = partnerProfiles.get(0).Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Badge_Number__c='998ABC', 
                    isActive = TRUE,  
                    Enable_Partner_Deal_Registration__c = TRUE,
                    Enable_Partner_Lead_Management__c = TRUE,
                    Enable_Partner_Admin__c= TRUE,
                    ContactId = newCont.id
                );
        insert partnerUser;
        List<profile> listProf;
        listProf = [select id,name from Profile where name like 'System Administrator' order by CreatedDate DESC limit 1];
        
        User usr = new User(
                    Username='testUser'+System.currentTimeMillis()+'@test.com',
                    Alias = 'test1', 
                    Email='test3445@dell.com', 
                    FirstName='John', 
                    LastName='Doe', 
                    ProfileId = listProf[0].Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Badge_Number__c='UATUser', 
                    isActive = TRUE
                    );
        insert usr;
        system.Runas(usr){  
        Groupmember q = new Groupmember(
                                    userorGroupId = partnerUser.Id,
                                    GroupId = '00GA0000002y6s0MAA' 
                                );
        insert q;
        }
        //Segment Campaign
        Campaign cMapSegCamp= new Campaign(Name='TestCampaign_Seg',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='NA',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = TRUE,
                IsActive = true,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1,
                Partner_Campaign_Contact_Email__c = 'test@test.com',Partner_Campaign_Contact__c =usr.Id);//v3.0 
         //camptoInsertList.add(cMapSegCamp);
         insert  cMapSegCamp;
         //Ch Camp
        Campaign cMapChCampaign= new Campaign(Name='TestCampaign_Ch',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='NA',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = False,
                Allocation_Source__c = 'Channel ABU Agency 1',
                Nurture_Source__c = 'Channel ABU Agency 1',
                IsActive = true,
                RecordTypeId = campRTId,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1);
        insert  cMapChCampaign;
         //Seg LEad
         Test.startTest();
         Lead segleadObj = new Lead(lastName = 'Test',
                firstName = 'Lead_R2S',
                Salutation = 'Mr.',
                MobilePhone = '918645678',
                fax = '87687689',
                Employees__c = '100 - 499',
                Title = 'Consultant',
                //City = 'Test City',
                //State = 'Test State',
                //Country = 'US',
                //PostalCode = '9876545',
                Country_Code__c = 'US',
                Consent_to_engage_Dell_Channel_Partner__c = TRUE,
                LeadSource = 'Demo Day',                
                AnnualRevenue = 10187879,
                Decision_Making_Role__c = 'Business User',
                Questions_Comments__c = 'Test Customer Comments', 
                Sales_Comments__c = 'Test Sales Comments', 
                Marketing_Comments__c = 'Test Marketing Comments',
                email ='testdircmap@cmaptest.com',
                status = 'Open',
                Phone='88967544',
                Campaign__c  =  cMapSegCamp.Id,
                recordTypeId = leadRTId2,
                Lead_Type__c = 'Inbound',//v3.0                    
                Purchase_Timeframe__c ='3 months',              
                Company = 'Test Company');
        insert segleadObj;
        
        //Ch Lead
        Lead chleadRecs = new Lead();
                chleadRecs.lastName = 'Test';
                chleadRecs.firstName = 'Lead_R2S';
                chleadRecs.Salutation = 'Mr.';       
                chleadRecs.status = 'Assigned to Channel Partner';
                chleadRecs.Phone='88967544';
                chleadRecs.RecordTypeId = chLeadRTId;
                chleadRecs.Country = 'US';
                chleadRecs.Campaign__c  = cMapChCampaign.Id;
                chleadRecs.Company = 'Test Company';
                chleadRecs.Purchase_Timeframe__c ='3 months';                
                chleadRecs.Budget__c = 'Yes';
                chleadRecs.Segment_Lead__c = segleadObj.Id;
                //if(queueId != NULL)
                //chleadRecs.OwnerId = partnerUser.Id;
                chleadRecs.OwnerId = '00GA0000002y6hl';
                             
        insert chleadRecs;
        chleadRecs.Channel_to_Segment_Criteria__c = 'End user has existing relationship with Dell Segment';
        update chleadRecs;   
         Test.stopTest();     
        //PageReference  pr = new PageReference('/apex/CMAP_RouteToSegmentController?chId='+chleadRecs.Id);
        //Test.setCurrentPage(pr);
        PageReference pageRef = Page.CMAP_RouteToSegment;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('chId', chleadRecs.Id);
        CMAP_RouteToSegmentController controller = new CMAP_RouteToSegmentController(new ApexPages.StandardController(new Lead()));
            controller.channelRecord = chleadRecs;
            controller.chId = chleadRecs.Id;
            //chleadRecs.User__c = usr.Id;
              
            controller.Redirect();
            System.assertNotEquals(null,controller.chId);
            controller.saveButton();
            controller.okButton();
           TriggerExecutionController.setSkipAllTriggers(false);//v3.0
    }

    static testMethod void testR2SFornewSegLead(){
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
        Id leadRTId= IdLookupUtils.getRecordTypeId('Lead Qualification','Lead',true);
        Id leadRTId2= IdLookupUtils.getRecordTypeId('Direct Lead 2.0','Lead',true);//v3.0
        Id chLeadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete','Lead',true); 
        TriggerExecutionController.setSkipAllTriggers(true);//v3.0
        CMAP_Helper.skipinsert = true;
        string strQueueName = 'NA:TQL Nurturing:N';
        CMAP_Queue_Settings__c queueId = CMAP_Queue_Settings__c.getValues(strQueueName);
        //v3.0 Insert Custom Settings Data 
        CMAP_Queue_Settings__c objSetting = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6s0MAA',Queue_Name__c='Channel TQL Nurturing',Name='NA:TQL Nurturing:N');
        insert objSetting;
        CMAP_Queue_Settings__c objSettingEclerx = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6hl',Queue_Name__c='Channel_eClerx',Name='Channel_eClerx');
        insert objSettingEclerx;
        User usr;
        List<profile> listProf;
        
        listProf = [select id,name from Profile where name like 'System Administrator' order by CreatedDate DESC limit 1];
        
        usr = new User(
                    Username='testUser'+System.currentTimeMillis()+'@test.com',
                    Alias = 'test1', 
                    Email='test3445@dell.com', 
                    FirstName='John', 
                    LastName='Doe', 
                    ProfileId = listProf[0].Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Badge_Number__c='UATUser', 
                    isActive = TRUE
                    );
        insert usr;
        //Segment Campaign
        Campaign cMapSegCamp= new Campaign(Name='TestCampaign_Seg',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='NA',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = TRUE,
                IsActive = true,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1,
                Partner_Campaign_Contact_Email__c = 'test@test.com',Partner_Campaign_Contact__c =usr.Id);//v3.0                              
         //camptoInsertList.add(cMapSegCamp);
         insert  cMapSegCamp;
         //Seg LEad
         Lead segleadObj = new Lead(lastName = 'Test',
                firstName = 'Lead_R2S',
                Salutation = 'Mr.',
                MobilePhone = '918645678',
                fax = '87687689',
                Employees__c = '100 - 499',
                Title = 'Consultant',
                //City = 'Test City',
                //State = 'Test State',
                //Country = 'US',
                //PostalCode = '9876545',
                Consent_to_engage_Dell_Channel_Partner__c = TRUE,
                LeadSource = 'Demo Day',                
                AnnualRevenue = 10187879,
                Decision_Making_Role__c = 'Business User',
                Questions_Comments__c = 'Test Customer Comments', 
                Sales_Comments__c = 'Test Sales Comments', 
                Marketing_Comments__c = 'Test Marketing Comments',
                email ='testdircmap@cmaptest.com',
                status = 'Open',
                Phone='88967544',
                Campaign__c  =  cMapSegCamp.Id,
                recordTypeId = leadRTId2,                
                Purchase_Timeframe__c ='3 months',
                Lead_Type__c = 'Inbound',//v3.0                      
                Company = 'Test Company',
                Country_Code__c = 'US');
        insert segleadObj;
        //Ch Camp
        Campaign cMapChCampaign= new Campaign(Name='TestCampaign_Ch',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='NA',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = False,
                Allocation_Source__c = 'Channel ABU Agency 1',
                Nurture_Source__c = 'Channel ABU Agency 1',
                IsActive = true,
                RecordTypeId = campRTId,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1);
        insert  cMapChCampaign;
        //Ch Lead
        Lead chleadRecs = new Lead();
                chleadRecs.lastName = 'Test';
                chleadRecs.firstName = 'Lead_R2S';
                chleadRecs.Salutation = 'Mr.';       
                chleadRecs.status = 'Qualified - Channel Ready';
                chleadRecs.Phone='88967544';
                chleadRecs.RecordTypeId = chLeadRTId;
                chleadRecs.Country = 'US';
                chleadRecs.Campaign__c  = cMapChCampaign.Id;
                chleadRecs.Company = 'Test Company';
                chleadRecs.Purchase_Timeframe__c ='3 months';                
                chleadRecs.Budget__c = 'Yes';
                chleadRecs.Segment_Lead__c = segleadObj.Id;
                chleadRecs.User_Access_OLD__c = 'No Access';
                //if(queueId != NULL){
                        //chleadRecs.OwnerId = queueId.Queue_Id__c;
                //}
                chleadRecs.OwnerId = '00GA0000002y6hl';                
        insert chleadRecs;
        chleadRecs.Channel_to_Segment_Criteria__c = 'End user has existing relationship with Dell Segment';
        update chleadRecs;
        system.debug('----segleadObj.Id----'+segleadObj.Id);        
            LeadShare ldShare = new LeadShare();
            ldShare.LeadId = chleadRecs.Segment_Lead__c;
            ldShare.UserOrGroupId = chleadRecs.OwnerId;
            ldShare.LeadAccessLevel = 'Edit';
            insert ldShare;
            
        //PageReference pr = new PageReference('/apex/CMAP_RouteToSegmentController?newId ='+segleadObj.Id);
        //Test.setCurrentPage(pr);
        
        PageReference pageRef = Page.CMAP_RouteToSegment;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('newId', segleadObj.Id);        
                
        CMAP_RouteToSegmentController controller = new CMAP_RouteToSegmentController(new ApexPages.StandardController(new Lead()));        
            
            controller.channelLead = segleadObj;
            controller.newId = segleadObj.Id;
            
            //segleadObj.User__c = usr.Id;                                          
            //System.debug('@@newId'+ newId);
            Test.startTest();      
            controller.Redirect();
            
            System.assertNotEquals(null,controller.newId);
            controller.saveButton();
            TriggerExecutionController.setSkipAllTriggers(false);//v3.0
        Test.stopTest();
    
    }
    
    static testMethod void testR2SfornewSegLeadaLL(){
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
        //Id leadRTId= IdLookupUtils.getRecordTypeId('Lead Qualification','Lead',true);//v3.0
        Id leadRTId= IdLookupUtils.getRecordTypeId('Direct Lead 2.0','Lead',true);//v3.0
        Id chleadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete','Lead',true);
        string strqueueName = 'NA:TQL Nurturing:N';
        CMAP_Queue_Settings__c queueId = CMAP_Queue_Settings__c.getValues(strqueueName);
        CMAP_Helper.skipinsert = true;
        TriggerExecutionController.setSkipAllTriggers(true);//v3.0
        TriggerExecutionController.setSkipLeadTriggers(true);
        //v3.0 Insert Custom Settings Data 
        
        list<QueueSobject> listQueueSobject = [SELECT queueId FROM QueueSobject  where SobjectType = 'Lead' And Queue.name like '%Nurturing%' limit 1];
        //Group objGroup = [select Id,name from Group where Type = 'Queue' and name != null limit 1];
        CMAP_Queue_Settings__c objSetting = new CMAP_Queue_Settings__c(Queue_Id__c= listQueueSobject.size()>0 ? listQueueSobject[0].queueId : null,Queue_Name__c='Channel TQL Nurturing',Name='NA:TQL Nurturing:N');
        insert objSetting;
        CMAP_Queue_Settings__c objSettingeclerx = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6hl',Queue_Name__c='Channel_eClerx',Name='Channel_eClerx');
        insert objSettingeclerx;
        Profile p = [SELECT id from Profile where name = 'System Administrator' limit 1 ];
        List<User> listusrList = [select id from User where isactive=true AND profileid = :p.id limit 2];
        //Assign user to the queue
        System.runas(listusrList[0]){
            Groupmember q = new Groupmember(
                                    userorGroupId = listusrList[1].Id,
                                    GroupId = listQueueSobject.size()>0 ? listQueueSobject[0].queueId : null
                                );
            insert q;
        }
        Account newAcc = new Account(name='MyTestAccount3',Website='https://test@test.com');
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
        Id r = [select id from profile where name='R16.10 NA PRM Portal User (MOSS) - Non SSO'].id;
        User user = new User(alias = 'test1234', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = r, country='United States',IsActive =true,
                ContactId = newCont.Id,Badge_Number__c='001266',
                timezonesidkey='America/Los_Angeles', username='testUser'+System.currentTimeMillis()+'@test.com');
       
        insert user;
        //Segment Campaign
        Campaign cMAPsegcamp= new Campaign(Name='TestCampaign_Seg',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='NA',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = TRUE,
                IsActive = true,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1,
                Partner_Campaign_Contact_Email__c = 'test@test.com',Partner_Campaign_Contact__c =user.Id);//v3.0
         //camptoInsertList.add(cMAPsegcamp);
         insert  cMAPsegcamp;
         //Seg LEad
         Lead segleadObj = new Lead(lastName = 'Test',
                firstName = 'Lead_R2S',
                Salutation = 'Mr.',
                MobilePhone = '918645678',
                fax = '87687689',
                Employees__c = '100 - 499',
                Title = 'Consultant',
                //City = 'Test City',
                //State = 'Test State',
                //Country = 'US',
                //PostalCode = '9876545',
                Country_Code__c = 'US',
                Consent_to_engage_Dell_Channel_Partner__c = TRUE,
                LeadSource = 'Demo Day',                
                AnnualRevenue = 10187879,
                Decision_Making_Role__c = 'Business User',
                Questions_Comments__c = 'Test Customer Comments', 
                Sales_Comments__c = 'Test Sales Comments', 
                Marketing_Comments__c = 'Test Marketing Comments',
                email ='testdircmap@cmaptest.com',
                status = 'Open',
                Phone='88967544',
                Campaign__c  =  cMAPsegcamp.Id,
                recordTypeId = leadRTId,
                Lead_Type__c = 'Inbound',//v3.0
                Purchase_Timeframe__c ='3 months',              
                Company = 'Test Company');
        insert segleadObj;
        //Ch Camp
        Campaign cMAPChCampaign= new Campaign(Name='TestCampaign_Ch',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='NA',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = False,
                Allocation_Source__c = 'Channel ABU Agency 1',
                Nurture_Source__c = 'Channel ABU Agency 1',
                IsActive = true,
                RecordTypeId = campRTId,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1);
        insert  cMAPChCampaign;
        
        //Ch Lead status Assigned to Channel Partner
        Lead chleadRecs = new Lead();
                chleadRecs.lastName = 'Test';
                chleadRecs.firstName = 'Lead_R2S';
                chleadRecs.Salutation = 'Mr.';       
                chleadRecs.status = 'Assigned to Channel Partner';
                chleadRecs.Phone='88967544';
                chleadRecs.RecordTypeId = chleadRTId;
                chleadRecs.Country = 'US';
                chleadRecs.Campaign__c  = cMAPChCampaign.Id;
                chleadRecs.Company = 'Test Company';
                chleadRecs.Purchase_Timeframe__c ='3 months';                
                chleadRecs.Budget__c = 'Yes';
                chleadRecs.Segment_Lead__c = segleadObj.Id;
                chleadRecs.Allocation_Queue_GUID__c = listQueueSobject.size()>0 ? listQueueSobject[0].queueId : null;
                chleadRecs.OwnerId= listQueueSobject.size()>0 ? listQueueSobject[0].queueId : UserInfo.getUserId();
                               
        insert chleadRecs;
        chleadRecs.Channel_to_Segment_Criteria__c = 'End user has existing relationship with Dell Segment';
        update chleadRecs;
        System.debug('@@@Owner '+chleadRecs.OwnerId); 
        //get a admin user to run the code
        
        
        System.runas(listusrList[1]){
            
            lead obj = [select status,Owner.Name from lead where id = :chleadRecs.Id];
            PageReference pageRef = Page.CMAP_RouteToSegment;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('chId', chleadRecs.Id);
            ApexPages.currentPage().getParameters().put('recid', chleadRecs.Id);
            CMAP_RouteToSegmentController controller = new CMAP_RouteToSegmentController(new ApexPages.StandardController(new Lead()));
            //controller.chRecord = chleadRecs;
            controller.chId = chleadRecs.Id;
            //chleadRecs.User__c = usr.Id;
            Test.startTest();           
            controller.Redirect();
            controller.saveButton();
            controller.okButton();
            System.assertNotEquals(null,controller.chId);
            TriggerExecutionController.setSkipAllTriggers(false);//v3.0
            Test.stopTest();
        }            
    }
    static testMethod void testR2SfornewSegLeadaLL2(){
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
        //Id leadRTId= IdLookupUtils.getRecordTypeId('Lead Qualification','Lead',true);//v3.0
        Id leadRTId= IdLookupUtils.getRecordTypeId('Direct Lead 2.0','Lead',true);//v3.0
        Id chleadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete','Lead',true);
        string strqueueName = 'NA:TQL Nurturing:N';
        CMAP_Queue_Settings__c queueId = CMAP_Queue_Settings__c.getValues(strqueueName);
        CMAP_Helper.skipinsert = true;
        TriggerExecutionController.setSkipAllTriggers(true);//v3.0
        TriggerExecutionController.setSkipLeadTriggers(true);
        //v3.0 Insert Custom Settings Data 
        
        list<QueueSobject> listQueueSobject = [SELECT queueId FROM QueueSobject  where SobjectType = 'Lead' And Queue.name like '%Nurturing%' limit 1];
        //Group objGroup = [select Id,name from Group where Type = 'Queue' and name != null limit 1];
        CMAP_Queue_Settings__c objSetting = new CMAP_Queue_Settings__c(Queue_Id__c= listQueueSobject.size()>0 ? listQueueSobject[0].queueId : null,Queue_Name__c='Channel TQL Nurturing',Name='NA:TQL Nurturing:N');
        insert objSetting;
        CMAP_Queue_Settings__c objSettingeclerx = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6hl',Queue_Name__c='Channel_eClerx',Name='Channel_eClerx');
        insert objSettingeclerx;
        Profile p = [SELECT id from Profile where name = 'System Administrator' limit 1 ];
        List<User> listusrList = [select id from User where isactive=true AND profileid = :p.id limit 2];
        //Assign user to the queue
        System.runas(listusrList[0]){
            Groupmember q = new Groupmember(
                                    userorGroupId = listusrList[1].Id,
                                    GroupId = listQueueSobject.size()>0 ? listQueueSobject[0].queueId : null
                                );
            insert q;
        }
        Account newAcc = new Account(name='MyTestAccount3',Website='https://test@test.com');
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
        Id r = [select id from profile where name='R16.10 NA PRM Portal User (MOSS) - Non SSO'].id;
        User user = new User(alias = 'test1235', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = r, country='United States',IsActive =true,
                ContactId = newCont.Id,Badge_Number__c='001266',
                timezonesidkey='America/Los_Angeles', username='testUser'+System.currentTimeMillis()+'@test.com');
       
        insert user;
        //Segment Campaign
        
        Id devCompaignRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Channel_Partner_Communications').getRecordTypeId();
        Id devLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Channel_Lead_Conversion').getRecordTypeId();
        
        Campaign cMAPsegcamp1= new Campaign(Name='TestCampaign_Seg',
                Campaign_Objective__c='Acquisition/Site Development',
                recordtypeid = devCompaignRecordTypeId,
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='NA',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = TRUE,
                IsActive = true,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1,
                Partner_Campaign_Contact_Email__c = 'test@test.com',Partner_Campaign_Contact__c =user.Id);//v3.0
         //camptoInsertList.add(cMapSegCamp);
         insert  cMAPsegcamp1;
         
         
         
         Campaign cMAPsegcamp= new Campaign(Name='TestCampaign_Seg',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='NA',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = TRUE,
                IsActive = true,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1,
                Partner_Campaign_Contact_Email__c = 'test@test.com',Partner_Campaign_Contact__c =user.Id);//v3.0
         //camptoInsertList.add(cMAPsegcamp);
         insert  cMAPsegcamp;
         
         
         //Seg LEad
         Lead segleadObj1 = new Lead(lastName = 'Test',
                firstName = 'Lead_R2S',
                Salutation = 'Mr.',
                recordtypeId = devLeadRecordTypeId,
                MobilePhone = '918645678',
                fax = '87687689',
                Employees__c = '100 - 499',
                Title = 'Consultant',
                //City = 'Test City',
                //State = 'Test State',
                Country = 'US',
                //PostalCode = '9876545',
                Country_Code__c = 'US',
                Consent_to_engage_Dell_Channel_Partner__c = TRUE,
                LeadSource = 'Demo Day',                
                AnnualRevenue = 10187879,
                Decision_Making_Role__c = 'Business User',
                Questions_Comments__c = 'Test Customer Comments', 
                Sales_Comments__c = 'Test Sales Comments', 
                Marketing_Comments__c = 'Test Marketing Comments',
                email ='testdircmap@cmaptest.com',
                status = 'Open',
                Phone='88967544',
                Campaign__c  =  cMAPsegcamp.Id,
                //recordTypeId = leadRTId,
                Lead_Type__c = 'Inbound',//v3.0
                Purchase_Timeframe__c ='3 months', 
                User_Access_OLD__c = 'No Access',
                Company = 'Test Company');
        insert segleadObj1;
        
         //Seg LEad
         Lead segleadObj = new Lead(lastName = 'Test',
                firstName = 'Lead_R2S',
                Salutation = 'Mr.',
                MobilePhone = '918645678',
                fax = '87687689',
                Employees__c = '100 - 499',
                Title = 'Consultant',
                //City = 'Test City',
                //State = 'Test State',
                //Country = 'US',
                //PostalCode = '9876545',
                Country_Code__c = 'US',
                Consent_to_engage_Dell_Channel_Partner__c = TRUE,
                LeadSource = 'Demo Day',                
                AnnualRevenue = 10187879,
                Decision_Making_Role__c = 'Business User',
                Questions_Comments__c = 'Test Customer Comments', 
                Sales_Comments__c = 'Test Sales Comments', 
                Marketing_Comments__c = 'Test Marketing Comments',
                email ='testdircmap@cmaptest.com',
                status = 'Open',
                Phone='88967544',
                Campaign__c  =  cMAPsegcamp.Id,
                recordTypeId = leadRTId,
                Lead_Type__c = 'Inbound',//v3.0
                Purchase_Timeframe__c ='3 months', 
                User_Access_OLD__c = 'No Access',
                Company = 'Test Company');
        insert segleadObj;
        //Ch Camp
        Campaign cMAPChCampaign= new Campaign(Name='TestCampaign_Ch',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='NA',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = False,
                Allocation_Source__c = 'Channel ABU Agency 1',
                Nurture_Source__c = 'Channel ABU Agency 1',
                IsActive = true,
                RecordTypeId = campRTId,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1);
        insert  cMAPChCampaign;
        
        
        Relationship_Lead__c objRelLead = new Relationship_Lead__c(Contact__c = newCont.id,
                                                                    Campaign__c =cMAPsegcamp1.Id,
                                                                    Channel_Lead__c =   segleadObj1.Id,
                                                                    CM_Source__c = '23123200110',
                                                                    Lead_ID_Do_Not_Edit__c = segleadObj1.Id 
                                                                    );
        insert objRelLead;
        
        //Ch Lead status Assigned to Channel Partner
        Lead chleadRecs = new Lead();
                chleadRecs.lastName = 'Test';
                chleadRecs.firstName = 'Lead_R2S';
                chleadRecs.Salutation = 'Mr.';       
                chleadRecs.status = 'Assigned to Channel Partner';
                chleadRecs.Phone='88967544';
                chleadRecs.RecordTypeId = chleadRTId;
                chleadRecs.Country = 'US';
                chleadRecs.Campaign__c  = cMAPChCampaign.Id;
                chleadRecs.Company = 'Test Company';
                chleadRecs.Purchase_Timeframe__c ='3 months';                
                chleadRecs.Budget__c = 'Yes';
                chleadRecs.Relationship_Lead__c = objRelLead.Id;
                chleadRecs.Segment_Lead__c = null;
                //chleadRecs.Allocation_Queue_GUID__c = listQueueSobject.size()>0 ? listQueueSobject[0].queueId : null;
                chleadRecs.OwnerId= listQueueSobject.size()>0 ? listQueueSobject[0].queueId : UserInfo.getUserId();
                                
        insert chleadRecs;
        System.debug('@@@Owner '+chleadRecs.OwnerId); 
        //get a admin user to run the code
        
        
        System.runas(listusrList[1]){
            
            lead obj = [select status,Owner.Name from lead where id = :chleadRecs.Id];
            PageReference pageRef = Page.CMAP_RouteToSegment;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('chId', chleadRecs.Id);
            ApexPages.currentPage().getParameters().put('recid', chleadRecs.Id);
            ApexPages.currentPage().getParameters().put('newId', objRelLead.Id);
            CMAP_RouteToSegmentController controller = new CMAP_RouteToSegmentController(new ApexPages.StandardController(new Lead()));
            //controller.chRecord = chleadRecs;
            controller.chId = chleadRecs.Id;
            //chleadRecs.User__c = usr.Id;
            Test.startTest();           
            controller.Redirect();
            controller.saveButton();
            segleadObj.User_Access_OLD__c = 'Read';
            controller.saveButton();
            controller.okButton();
            System.assertNotEquals(null,controller.chId);
            TriggerExecutionController.setSkipAllTriggers(false);//v3.0
            Test.stopTest();
        }            
    }
    
    static testMethod void testR2SfornewSegLeadaLL3(){
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
        Id leadRTId= IdLookupUtils.getRecordTypeId('Direct Lead 2.0','Lead',true);//v3.0
        Id chleadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete','Lead',true);
        string strqueueName = 'NA:TQL Nurturing:N';
        CMAP_Queue_Settings__c queueId = CMAP_Queue_Settings__c.getValues(strqueueName);
        CMAP_Helper.skipinsert = true;
        TriggerExecutionController.setSkipAllTriggers(true);//v3.0
        TriggerExecutionController.setSkipLeadTriggers(true);
        //v3.0 Insert Custom Settings Data 
        
        list<QueueSobject> listQueueSobject = [SELECT queueId FROM QueueSobject  where SobjectType = 'Lead' And Queue.name like '%Nurturing%' limit 1];
        //Group objGroup = [select Id,name from Group where Type = 'Queue' and name != null limit 1];
        CMAP_Queue_Settings__c objSetting = new CMAP_Queue_Settings__c(Queue_Id__c= listQueueSobject.size()>0 ? listQueueSobject[0].queueId : null,Queue_Name__c='Channel TQL Nurturing',Name='NA:TQL Nurturing:N');
        insert objSetting;
        CMAP_Queue_Settings__c objSettingeclerx = new CMAP_Queue_Settings__c(Queue_Id__c='00GA0000002y6hl',Queue_Name__c='Channel_eClerx',Name='Channel_eClerx');
        insert objSettingeclerx;
        Profile p = [SELECT id from Profile where name = 'System Administrator' limit 1 ];
        List<User> listusrList = [select id from User where isactive=true AND profileid = :p.id limit 2];
        
        //Assign user to the queue
        System.runas(listusrList[0]){
            Groupmember q = new Groupmember(
                                    userorGroupId = listusrList[1].Id,
                                    GroupId = listQueueSobject.size()>0 ? listQueueSobject[0].queueId : null
                                );
            insert q;
        }
        Account newAcc = new Account(name='MyTestAccount3',Website='https://test@test.com');
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
        Id r = [select id from profile where name='R16.10 NA PRM Portal User (MOSS) - Non SSO'].id;
        User user = new User(alias = 'test1236', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = r, country='United States',IsActive =true,
                ContactId = newCont.Id,Badge_Number__c='001266',
                timezonesidkey='America/Los_Angeles', username='testUser'+System.currentTimeMillis()+'@test.com');
       
        insert user;
        //Segment Campaign
        
        Id devCompaignRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Channel_Partner_Communications').getRecordTypeId();
        Id devLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Channel_Lead_Conversion').getRecordTypeId();
        
        Campaign cMAPsegcamp1= new Campaign(Name='TestCampaign_Seg',
                Campaign_Objective__c='Acquisition/Site Development',
                recordtypeid = devCompaignRecordTypeId,
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='NA',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = TRUE,
                IsActive = true,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1,
                Partner_Campaign_Contact_Email__c = 'test@test.com',Partner_Campaign_Contact__c =user.Id);//v3.0
         //camptoInsertList.add(cMAPsegcamp);
         insert  cMAPsegcamp1;
         
        Campaign cMAPsegcamp= new Campaign(Name='TestCampaign_Seg',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='NA',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = TRUE,
                IsActive = true,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1,
                Partner_Campaign_Contact_Email__c = 'test@test.com',Partner_Campaign_Contact__c =user.Id);//v3.0
         //camptoInsertList.add(cMAPsegcamp);
         insert  cMAPsegcamp;
         
         //Seg LEad
         Lead segleadObj1 = new Lead(lastName = 'Test',
                firstName = 'Lead_R2S',
                Salutation = 'Mr.',
                recordtypeId = devLeadRecordTypeId,
                MobilePhone = '918645678',
                fax = '87687689',
                Employees__c = '100 - 499',
                Title = 'Consultant',
                Country = 'US',
                Country_Code__c = 'US',
                Consent_to_engage_Dell_Channel_Partner__c = TRUE,
                LeadSource = 'Demo Day',                
                AnnualRevenue = 10187879,
                Decision_Making_Role__c = 'Business User',
                Questions_Comments__c = 'Test Customer Comments', 
                Sales_Comments__c = 'Test Sales Comments', 
                Marketing_Comments__c = 'Test Marketing Comments',
                email ='testdircmap@cmaptest.com',
                status = 'Open',
                Phone='88967544',
                Campaign__c  =  cMAPsegcamp.Id,
                Lead_Type__c = 'Inbound',//v3.0
                Purchase_Timeframe__c ='3 months', 
                User_Access_OLD__c = 'No Access',
                Company = 'Test Company');
        insert segleadObj1;
        
         //Seg LEad
         Lead segleadObj = new Lead(lastName = 'Test',
                firstName = 'Lead_R2S',
                Salutation = 'Mr.',
                MobilePhone = '918645678',
                fax = '87687689',
                Employees__c = '100 - 499',
                Title = 'Consultant',
                Country_Code__c = 'US',
                Consent_to_engage_Dell_Channel_Partner__c = TRUE,
                LeadSource = 'Demo Day',                
                AnnualRevenue = 10187879,
                Decision_Making_Role__c = 'Business User',
                Questions_Comments__c = 'Test Customer Comments', 
                Sales_Comments__c = 'Test Sales Comments', 
                Marketing_Comments__c = 'Test Marketing Comments',
                email ='testdircmap@cmaptest.com',
                status = 'Open',
                Phone='88967544',
                Campaign__c  =  cMAPsegcamp.Id,
                recordTypeId = leadRTId,
                Lead_Type__c = 'Inbound',//v3.0
                Purchase_Timeframe__c ='3 months',              
                Company = 'Test Company');
        insert segleadObj;
        //Ch Camp
        Campaign cMAPChCampaign= new Campaign(Name='TestCampaign_Ch',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='NA',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = False,
                Allocation_Source__c = 'Channel ABU Agency 1',
                Nurture_Source__c = 'Channel ABU Agency 1',
                IsActive = true,
                RecordTypeId = campRTId,
                Total_Campaign_Targets_Planned__c = 1,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1);
        insert  cMAPChCampaign;
        
        
        Relationship_Lead__c objRelLead = new Relationship_Lead__c(Contact__c = newCont.id,
                                                                    Campaign__c =cMAPsegcamp1.Id,
                                                                    Channel_Lead__c =   segleadObj1.Id,
                                                                    CM_Source__c = '23123200110',
                                                                    Lead_ID_Do_Not_Edit__c = segleadObj1.Id 
                                                                    );
        insert objRelLead;
        
        //Ch Lead status Assigned to Channel Partner
        Lead chleadRecs = new Lead();
                chleadRecs.lastName = 'Test';
                chleadRecs.firstName = 'Lead_R2S';
                chleadRecs.Salutation = 'Mr.';       
                chleadRecs.status = 'Assigned to Channel Partner';
                chleadRecs.Phone='88967544';
                chleadRecs.RecordTypeId = chleadRTId;
                chleadRecs.Country = 'US';
                chleadRecs.Campaign__c  = cMAPChCampaign.Id;
                chleadRecs.Company = 'Test Company';
                chleadRecs.Purchase_Timeframe__c ='3 months';                
                chleadRecs.Budget__c = 'Yes';
                chleadRecs.Segment_Lead__c = null;
                chleadRecs.Relationship_Lead__c = objRelLead.Id;
                chleadRecs.Allocation_Queue_GUID__c = listQueueSobject.size()>0 ? listQueueSobject[0].queueId : null;
                chleadRecs.OwnerId= listQueueSobject.size()>0 ? listQueueSobject[0].queueId : UserInfo.getUserId();
                               
        insert chleadRecs;
        System.debug('@@@Owner '+chleadRecs.OwnerId); 
        //get a admin user to run the code
        
        
        System.runas(listusrList[1]){
            
            lead obj = [select status,Owner.Name from lead where id = :chleadRecs.Id];
            PageReference pageRef = Page.CMAP_RouteToSegment;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('chId', chleadRecs.Id);
            ApexPages.currentPage().getParameters().put('recid', chleadRecs.Id);
            CMAP_RouteToSegmentController controller = new CMAP_RouteToSegmentController(new ApexPages.StandardController(new Lead()));
            //controller.chRecord = chleadRecs;
            controller.chId = chleadRecs.Id;
            //chleadRecs.User__c = usr.Id;
            Test.startTest();           
            controller.Redirect();
            controller.saveButton();
            controller.okButton();
            System.assertNotEquals(null,controller.chId);
            TriggerExecutionController.setSkipAllTriggers(false);//v3.0
            Test.stopTest();
        }            
    }
}