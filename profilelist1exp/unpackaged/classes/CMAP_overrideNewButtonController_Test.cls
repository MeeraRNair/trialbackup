/*
REVISION HISTORY
======================================================================================================================
Version    Author    Date            Release#       CR#     Description
-------    ------    ----            --------    ---    -----------
1.0                                                     created
2.0         Azwanti 15-March-2016   FY17-DCS-0401   12720   replace Campaign RT from 'Channel Campaign' to 'Campaign 2.0'.
3.0         Sui Yee 30-May-2016     FY17-DCS-0701   13199   replace RecordTypeId'Campaign 2.0'& lead 2.0 mandatory field.@isTest(SeeAllData=true)
4.0        Vasavi.M 14-Dec-2016     FY17-DCS-0103   13807   Fix the mandatory fields issue with camapaign record
*/
@isTest
   
private class CMAP_overrideNewButtonController_Test {
    
        //v3.0 Setup test data for queue
        @testSetup static void populateCMAPCustomSetting() {
            CMAP_Queue_Settings__c eClerxQueue = new CMAP_Queue_Settings__c(Name = 'Channel_eClerx', Queue_Id__c = '00GA0000002y6hl', Queue_Name__c = 'Channel_eClerx');
            Database.insert(eClerxQueue);
        }
    
    static testMethod void PartnerRedirect(){
        CMAP_Helper.skipinsert = true;
        CMAP_TestDataGenerator testData = new CMAP_TestDataGenerator();
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Account newAccn2 = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner');
        insert newAccn2;
        
        Contact newCon2 = new Contact(FirstName='TestContact3',
                 LastName='TestContactlast2',
                 accountId=newAccn2.Id,
                 Email='tesvt@ust-global.com',
                 fax='01987645',
                 MobilePhone='0000019',
                 //Last_Operation_Performed__c = 'testing',
                 Status__c = 'Marketing Suspect',
                 Phone='0000000');
        insert newCon2;
        Test.startTest();
        final List<Profile> partnerProfiles = [select id,name 
                                               from Profile 
                                               where UserType = 'PowerPartner' and name like '%PRM%' 
                                               order by CreatedDate DESC limit 1];
                                               
        User partnerUsr2 = new User(
                    Username='test106' + System.currentTimeMillis() + '@dell.com',
                    Alias = 'est016', 
                    Email='test006@dell.com', 
                    FirstName='John016', 
                    LastName='Dod016', 
                    ProfileId = partnerProfiles.get(0).Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Badge_Number__c='016', 
                    isActive = TRUE,
                    //AccountId = newAccn2.Id,
                    ContactId = newCon2.id
                );
        insert partnerUsr2;
        String stringToAppend = '';
        PageReference  pr2 = new PageReference('/00Q/e?nooverride=1&'+stringToAppend);
        Test.setCurrentPage(pr2);
        
        System.runAs(partnerUsr2) {
            CMAP_overrideNewController cntrlr2 = new CMAP_overrideNewController(new ApexPages.StandardController(new Lead()));           
            
            cntrlr2.redirect();
            String nextPage2 = cntrlr2.redirect().getUrl();
            Test.stopTest();
            System.assert(nextPage2!= NULL);            
        }        
        
    //[Bianca 11-Jan-2013]

    }
    static testMethod void marketingRedirect(){
    
        final List<Profile> partnerProfiles = [select id,name 
                                               from Profile 
                                               where name like '%GBL Marketing User - Non SSO' 
                                               order by CreatedDate DESC limit 1];   
        user mktingUsr=new user(Username='shaundell17@acme.com',
                     Alias = 'ting12', 
                     Email='te445@dell.com', 
                     FirstName='Johnsy',LastName='Doew',
                     LanguageLocaleKey='en_US',
                     LocaleSidKey='en_US', 
                     EmailEncodingKey='UTF-8',
                     TimeZoneSidKey='America/Los_Angeles',
                     //Enable_As_Partner_Lead_Super_User__c = TRUE, 
                     IsActive =TRUE,Badge_Number__c='53204',
                     ProfileId=partnerProfiles[0].Id); 
        insert mktingUsr;
        CMAP_Helper.skipinsert = true;
        CMAP_TestDataGenerator testData = new CMAP_TestDataGenerator();
        //Test.startTest();//V4.0
        //testData.getContact(true);//V4.0
        //testData.getPartnerUser(true);//V4.0
        Test.startTest();
        String stringToAppend = '';
        PageReference  pr2 = new PageReference('/00Q/e?nooverride=1&'+stringToAppend);
        Test.setCurrentPage(pr2);
        
        System.runAs(mktingUsr) {
            system.debug('###:' + mktingUsr);
            CMAP_overrideNewController cntrlr2 = new CMAP_overrideNewController(new ApexPages.StandardController(new Lead()));
                       
            cntrlr2.redirect();
            Test.stopTest();
            String nextPage2 = cntrlr2.redirect().getUrl();         
            system.debug('nextPage2:' + nextPage2);
            System.assert(nextPage2!= NULL);
            CMAP_Helper.skipinsert = true;          
        }
        
    //[Bianca 11-Jan-2013]

    }
    
    static testMethod void PartnerSalesRedirect(){
        final List<Profile> salesProfiles = [select id,name 
                                               from Profile 
                                               where name like '%GBL EMEA Sales Mgr' 
                                               order by CreatedDate DESC limit 1];   
        user salesUsr=new user(Username='shaun333@acme.com',
                     Alias = 'test2312', 
                     Email='test3244445@dell.com', 
                     FirstName='Johnes',LastName='Doewer',
                     LanguageLocaleKey='en_US',
                     LocaleSidKey='en_US', 
                     EmailEncodingKey='UTF-8',
                     TimeZoneSidKey='America/Los_Angeles',
                     //Enable_As_Partner_Lead_Super_User__c = TRUE, 
                     IsActive =TRUE,Badge_Number__c='5454565674',
                     ProfileId=salesProfiles[0].Id); 
        insert salesUsr;
        //[Bianca 11-Jan-2013]
        System.runAs(salesUsr) {
            CMAP_overrideNewController cntrlr = new CMAP_overrideNewController(new ApexPages.StandardController(new Lead()));           
            Test.startTest();
            cntrlr.redirect();
            Test.stopTest();
            String nextPage2 = cntrlr.okbuttonAction().getUrl();
            System.assert(nextPage2!= NULL);            
        }
    }
    static testMethod void PartnerInternalRedirect(){
    
        final List<Profile> partnerProfiles = [select id,name 
                                               from Profile 
                                               where name like 'System Administrator' 
                                               limit 1];   
        user usr=new user(Username='shaundell118@acme.com',
                     Alias = 'test12', 
                     Email='test32445@dell.com', 
                     FirstName='Johns',LastName='Doew',
                     LanguageLocaleKey='en_US',
                     LocaleSidKey='en_US', 
                     EmailEncodingKey='UTF-8',
                     TimeZoneSidKey='America/Los_Angeles',
                     //Enable_As_Partner_Lead_Super_User__c = TRUE, 
                     IsActive =TRUE,Badge_Number__c='765423466',
                     ProfileId=partnerProfiles[0].Id); 
        insert usr;
   
        //[Bianca 11-Jan-2013]
        PageReference  pr = new PageReference('/apex/CMAP_LeadGenerationInterface');
        Test.setCurrentPage(pr);
        System.runAs(usr) {
            CMAP_overrideNewController cntrlr = new CMAP_overrideNewController(new ApexPages.StandardController(new Lead()));           
            Test.startTest();
            cntrlr.redirect();
            Test.stopTest();
            String nextPage2 = cntrlr.okbuttonAction().getUrl();
            System.assert(nextPage2!= NULL);            
        }            
    }
    static testMethod void RoutingRLRedirect(){
    
        final List<Profile> partnerProfiles = [select id,name 
                                               from Profile 
                                               where name like 'System Administrator' 
                                               limit 1];   
        user usr=new user(Username='shaundell1121@acme.com',
                     Alias = 'route', 
                     Email='testRLRouting@dell.com', 
                     FirstName='Johns',LastName='DoewHello',
                     LanguageLocaleKey='en_US',
                     LocaleSidKey='en_US', 
                     EmailEncodingKey='UTF-8',
                     TimeZoneSidKey='America/Los_Angeles',
                     //Enable_As_Partner_Lead_Super_User__c = TRUE, 
                     IsActive =TRUE,Badge_Number__c='Route',
                     ProfileId=partnerProfiles[0].Id); 
        insert usr;
   
        //v3.0 start
        //Id leadRTId= IdLookupUtils.getRecordTypeId('Lead Qualification','Lead',true);
        Id leadRTId= IdLookupUtils.getRecordTypeId('DSG Partner','Lead',true);
        //v3.0 end
        CMAP_Helper.skipinsert = true;
        Account newAcc1 = new Account(name='MyTestAccount333');
        insert newAcc1;
                
        Contact newCont = new Contact(FirstName='MyTestRoute3',
                 LastName='MyTestRoute3',
                 accountId=newAcc1.Id,
                 Status__c = 'Marketing Suspect',
                 Email='MyTestContactRoute@ust-global.com',
                 fax='1234567',
                 MobilePhone='12987654',
                 Last_Operation_Performed__c = 'testing');
        insert newCont;
        Test.startTest();
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
                Partner_Campaign_Contact__c = usr.Id, //v3.0 - added since its required field
                Partner_Campaign_Contact_Email__c = 'test@test.com', //v3.0 - added since its required field
                RecordTypeId='012A0000000VnHF', //v3.0 - added since its required field                            
                Total_Value_Opportunities_Planned__c = 1,
                Lead_Routing__c = 'Not Applicable');//V4.0
         insert campDirectObj;
         Lead leadObj = new Lead(lastName = 'Test Lead1',
                email ='testcmap@cmaptest.com',
                status = 'Open',
                Phone='88967544',
                //Campaign__c  = campDirectObj.Id,
                recordTypeId = leadRTId,
                Budget__c = 'Yes',
                Purchase_Timeframe__c ='Immediate',
                LeadSource = 'Web',//v3.0 - added since its required field   
                Country = 'US',
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
        insert rlObj;
        
        PageReference  pr = new PageReference('/00Q/e?CF00NA00000063aoO='+rlObj.Name+'&CF00NA00000063aoO_lkid='+rlObj.Id);
        Test.setCurrentPage(pr);
        System.runAs(usr) {
            CMAP_overrideNewController cntrlr = new CMAP_overrideNewController(new ApexPages.StandardController(new Lead()));           
            
            cntrlr.redirect();          
            Test.stopTest();
            String nextPage2 = cntrlr.okbuttonAction().getUrl();
            System.assert(nextPage2!= NULL);            
        }            
    }
    static testMethod void RoutingLeadRedirect(){
    
        final List<Profile> partnerProfiles = [select id,name 
                                               from Profile 
                                               where name like 'System Administrator' 
                                               limit 1];   
        user usr=new user(Username='shaundell119@acme.com',
                     Alias = 'route', 
                     Email='testRLRouting@dell.com', 
                     FirstName='Johns',LastName='DoewHello',
                     LanguageLocaleKey='en_US',
                     LocaleSidKey='en_US', 
                     EmailEncodingKey='UTF-8',
                     TimeZoneSidKey='America/Los_Angeles',
                     //Enable_As_Partner_Lead_Super_User__c = TRUE, 
                     IsActive =TRUE,Badge_Number__c='Route',
                     ProfileId=partnerProfiles[0].Id); 
        insert usr;
        //v3.0 start
        //Id leadRTId= IdLookupUtils.getRecordTypeId('Lead Qualification','Lead',true);
        Id leadRTId= IdLookupUtils.getRecordTypeId('Direct Lead 2.0','Lead',true);
        //v3.0 end
        CMAP_Helper.skipinsert = true;
        Account newAcc4 = new Account(name='MyTestAccountfor Lead');
        insert newAcc4;
                
        Contact newLeadCont = new Contact(FirstName='MyLeadRoute3',
                 LastName='MyLeadRoute3',
                 accountId=newAcc4.Id,
                 Email='MyTestContactRoute@ust-global.com',
                 fax='1234567',
                 Status__c = 'Marketing Suspect',
                 MobilePhone='12987654',
                 Last_Operation_Performed__c = 'testing');
        insert newLeadCont;
        Test.startTest();
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
                Partner_Campaign_Contact__c = usr.Id, //v3.0 - added since its required field
                Partner_Campaign_Contact_Email__c = 'test@test.com', //v3.0 - added since its required field
                Total_Value_Opportunities_Planned__c = 1,
                Lead_Routing__c = 'Not Applicable');//V4.0
         insert campDirectObj;
         Lead leadObj = new Lead(lastName = 'Test Lead1',
                email ='testcmap@cmaptest.com',
                status = 'Open',
                Phone='88967544',
                Campaign__c  = campDirectObj.Id,
                recordTypeId = leadRTId,
                Budget__c = 'Yes',
                Purchase_Timeframe__c ='Immediate',
                LeadSource = 'Web',//v3.0 - added since its required field
                Lead_Type__c = 'Inbound',//v3.0
                Company = 'Test Company',
                Country_Code__c='US'
                );
        insert leadObj;
                    
        PageReference  pr = new PageReference('/00Q/e?CF00NZ00000010Mxx='+leadObj.Name+'&CF00NZ00000010Mxx_lkId ='+leadObj.Id+'&CF00NA0000006442I_lkid= '+leadObj.Id);
        Test.setCurrentPage(pr);
        System.runAs(usr) {
            CMAP_overrideNewController cntrlr = new CMAP_overrideNewController(new ApexPages.StandardController(new Lead())); 
                       
            cntrlr.redirect();
            Test.stopTest();
            String nextPage2 = cntrlr.okbuttonAction().getUrl();
            System.assert(nextPage2!= NULL);            
        }            
    }
    
    static testMethod void cloneTestformarketing(){
        TriggerExecutionController.setSkipAllTriggers(true);//v3.0
        
    
        final List<Profile> marketingProfiles = [select id,name 
                                                   from Profile 
                                                   where name like '%GBL Marketing User - Non SSO' 
                                                   order by CreatedDate DESC limit 1];   
        system.debug('----partnerProfiles[0]---'+marketingProfiles[0]);
        User usr=new user(Username='shaundell1120@acme.com',
                     Alias = 'route', 
                     Email='testRLRouting@dell.com', 
                     FirstName='Johns',LastName='DoewHello',
                     LanguageLocaleKey='en_US',
                     LocaleSidKey='en_US', 
                     EmailEncodingKey='UTF-8',
                     TimeZoneSidKey='America/Los_Angeles',
                     //Enable_As_Partner_Lead_Super_User__c = TRUE, 
                     IsActive =TRUE,Badge_Number__c='Route',
                     ProfileId=marketingProfiles[0].Id); 
        insert usr;
        Test.startTest();
        Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Submission','Lead',true);
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Lead',true); //v2.0
        Campaign campObj= new Campaign(Name='Campaign_CMAP', 
                //Campaign_Objective__c='Acquisition/Site Development',
                Vertical__c='PTG',
                Sub_Region__c='ABU',
                StartDate=system.today(),
                Solution__c='Unknown',
                Segment_Business_Unit__c='CSB',
                Region__c='ABU',
                Parent_Vehicle__c='Digital Media',
                Nurture_Source__c='OEM Nurturing',
                Line_Of_Business__c='Desktop',
                Follow_Up_Role__c='Inside Sales Rep',
                IsActive = true,
                EndDate=system.today(),
                Description='Test',
                Campaign_Vehicle__c='Email',
                Campaign_Objective__c='Action',
                Partner_Event_or_Campaign__c = FALSE,
                Allocation_Source__c='Channel OEM',
                RecordTypeId='012A0000000VnzX',
                Lead_Routing__c = 'Not Applicable');//V4.0
         insert campObj;
         Lead leadRecord = new Lead(lastName = 'Test Lead1',
                email ='testcmap@cmaptest.com',
                status = 'Open',
                Phone='88967544',
                Campaign__c  = campObj.Id,
                //recordTypeId = leadRTId,
                recordtypeId = IdLookupUtils.getRecordTypeId('Channel Lead - Assignment Complete','Lead',true),
                Origin__c = 'Direct Lead 2.0',
                Budget__c = 'Yes',
                Purchase_Timeframe__c ='Immediate',
                Company = 'Test Company',
                Country = 'US',
                Country_Code__c = 'US');
        insert leadRecord;
        TriggerExecutionController.setSkipAllTriggers(false);//v3.0
        System.runAs(usr){     
        PageReference pref = new PageReference('/apex/CMAP_overrideNewController?clId='+leadRecord.Id);
        Test.setCurrentPage(pref);
        CMAP_overrideNewController cntrlr = new CMAP_overrideNewController(new ApexPages.StandardController(new Lead())); 
            
        
        cntrlr.okbutton = true;
        cntrlr.redirect();
        cntrlr.okbuttonAction();
        Test.stopTest(); 
        }
    }
    
    static testMethod void cloneTestforsfdc(){             
        Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Submission','Lead',true);
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Lead',true); //v2.0
        Id leadRTCleansing = IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete','Lead',true);        
        Campaign campObj= new Campaign(Name='Campaign_CMAP',
                //Campaign_Objective__c='Acquisition/Site Development',
                Vertical__c='PTG',
                Sub_Region__c='ABU',
                StartDate=system.today(),
                Solution__c='Unknown',
                Segment_Business_Unit__c='CSB',
                Region__c='ABU',
                Parent_Vehicle__c='Digital Media',
                Nurture_Source__c='OEM Nurturing',
                Line_Of_Business__c='Desktop',
                Follow_Up_Role__c='Inside Sales Rep',
                IsActive = true,
                EndDate=system.today(),
                Description='Test',
                Campaign_Vehicle__c='Email',
                Campaign_Objective__c='Action',
                Partner_Event_or_Campaign__c = FALSE,
                Allocation_Source__c='Channel OEM',
                RecordTypeId='012A0000000VnzX',
                Lead_Routing__c = 'Not Applicable');//V4.0
         insert campObj;
         Lead leadRecord = new Lead(lastName = 'Test Lead1',
                email ='testcmap@cmaptest.com',
                status = 'Open',
                Phone='88967544',
                Campaign__c  = campObj.Id,
                //recordTypeId = leadRTId,
                recordtypeId = leadRTCleansing,
                Origin__c = 'Channel Lead 2.0',
                Budget__c = 'Yes',
                Purchase_Timeframe__c ='Immediate',
                Company = 'Test Company',
                Country = 'US'
                );
        insert leadRecord;
        PageReference pref = new PageReference('/apex/CMAP_overrideNewController?clId='+leadRecord.Id);
        Test.setCurrentPage(pref);
        CMAP_overrideNewController cntrlr = new CMAP_overrideNewController(new ApexPages.StandardController(new Lead()));
        Test.startTest();
        cntrlr.redirect();
        Test.stopTest(); 
    }
}