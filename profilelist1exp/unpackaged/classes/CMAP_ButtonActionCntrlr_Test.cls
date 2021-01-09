/* 
REVISION HISTORY
================
Version     Author      Date            Release#        CR#     Description
-------     ------      ----            --------        ---     -----------
1.0         Sandhya     15-Nov-2012     14.2            --     Test class for CMAP_ManualAssignmentCntrlr.
2.0         Meera       10-Feb-2015     16.03           10799   Tes class modification to support DSG CMAP Changes
3.0         Azwanti     15-March-2016   FY17-DCS-0401   12720   replace Campaign RT from 'Channel Campaign' to 'Campaign 2.0'.
3.1         Azwanti     8-May-2016      0602                    Fixed DUPLICATES_DETECTED found in Prod Validation
*/
@isTest
private class CMAP_ButtonActionCntrlr_Test{
   static testMethod void TestAccept() {
        /*CMAP_TestDataGenerator testData = new CMAP_TestDataGenerator();
        testData.getContact(true);
        testData.getPartnerUser(true);
        testData.getCampaign(true);
        testData.getLead(true);
        */
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v3.0
        Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead 2.0','Lead',true);
        //Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Submission','Lead',true);//v3.0
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner');
        insert newAcc;
       
        /*newAcc.IsPartner = True;
        newAcc. ;
        update newAcc;
        */
        Contact newCont = new Contact(FirstName='TestContactFN9'+system.now().millisecond(), //v3.1
                 LastName='TestContactLN9'+system.now().millisecond(), //v3.1 
                 accountId=newAcc.Id,
                 Status__c = 'Marketing Suspect',
                 Email='TestContactEmail9'+system.now().millisecond()+'@ust-global.com', //v3.1
                 fax='01987645',
                 MobilePhone = String.valueOf(Math.round(Math.random()*1000)) + '00' +system.now().millisecond(), //v3.1
                 Last_Operation_Performed__c = 'testing',
                 Phone= String.valueOf(Math.round(Math.random()*1000)) + '00' +system.now().millisecond()); //v3.1
        insert newCont;
        
        final List<Profile> partnerProfiles = [select id,name 
                                               from Profile 
                                               where UserType = 'PowerPartner' and name like '%PRM%' 
                                               limit 1];
                                               
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
                    Enable_Partner_Lead_Management__c = true,
                    Enable_Partner_Deal_Registration__c = true,
                    Badge_Number__c='909', 
                    isActive = TRUE,
                    ContactId = newCont.id
                );
       User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];   
       System.runAs ( thisUser ) {
       insert partnerUser;
        }
       Campaign newCampgn = new Campaign(Name='Campaign_CMAP',
                //Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='ABU',  
                Allocation_Source__c = 'Dell Allocation ABU',
                Nurture_Source__c = 'Dell Nurturing',                      
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = TRUE,
                Partner_Campaign_Contact__c = partnerUser.Id,
                Partner_Campaign_Contact_Email__c = 'test@dell.com',
                IsActive = true,
                RecordTypeId = campRTId,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1,
               Lead_Routing__c ='Dell Standard');
        insert newCampgn;
        //Integer MAX_QUERY = Limits.getLimitQueries(); 
        //Integer NUM_QUERY = MAX_QUERY - 1; 
        CMAP_Helper.skipinsert = true;
        test.starttest();
        Lead leadObj;
        //for (Integer i = 0; i < NUM_QUERY; i++) { 
        leadObj = new Lead(lastName = 'Test Lead1',
            email ='testcmap@cmaptest.com',
            status = 'Open - Channel Lead',
            Phone='88967544',
            Country = 'US',
            Partner_Account__c =newAcc.Id,
            Campaign__c  = newCampgn.Id,
            recordTypeId = leadRTId,
            Budget__c = 'Yes',
            Purchase_Timeframe__c ='Immediate',
            Partner_User__c =  partnerUser.Id,
            Ready_for_scoring__c = TRUE,
            LeadSource = 'Employee Referral',
            Lead_Type__c = 'Inbound',
            Dell_Partner_can_contact_me__c = true,
            Company = 'Test Company');
     
        insert leadObj;
        //}
        
        PageReference  pr1 = new PageReference('/apex/CMAP_ButtonActions?Id='+leadObj.Id+'&action=Accept');
        Test.setCurrentPage(pr1);     
        CMAP_ButtonActionCntrlr controller = new CMAP_ButtonActionCntrlr (new ApexPages.StandardController(new Lead()));
        controller.leadObj= leadObj;
        controller.redirect();

        PageReference  pageRefActual=controller.redirect();
        PageReference  pageRefExpected=new PageReference('/'+leadObj.Id);
        //System.assertEquals(pageRefExpected, pageRefActual); 
        test.stoptest();
    }
        
    static testMethod void TestReject() {
        /*CMAP_TestDataGenerator testData = new CMAP_TestDataGenerator();
        testData.getContact(true);
        testData.getPartnerUser(true);
        testData.getCampaign(true);
        testData.getLead(true);
        */
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v3.0
        Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead 2.0','Lead',true);
        //Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Submission','Lead',true);//v3.0
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Account newAcc1 = new Account(name='Test1', Type = 'Partner', RecordtypeId = accRTId);
        insert newAcc1;
        /*
        newAcc1.IsPartner = True;
        newAcc1.Type = 'Partner' ;
        update newAcc1;
        */
        
        Contact newCont = new Contact(FirstName='TestContactFN10'+system.now().millisecond(), //v3.1
                 Status__c = 'Marketing Suspect',
                 LastName='TestContactLN10'+system.now().millisecond(), //v3.1
                 accountId=newAcc1.Id,
                 Email='TestContactEmail10'+system.now().millisecond()+'@ust-global.com', //v3.1
                 fax='01987645',
                 MobilePhone= String.valueOf(Math.round(Math.random()*1000)) + '00' +system.now().millisecond(), //v3.1
                 Last_Operation_Performed__c = 'testing',
                 Phone= String.valueOf(Math.round(Math.random()*1000)) + '00' +system.now().millisecond()); //v3.1
        insert newCont;
        
        final List<Profile> partnerProfiles = [select id,name 
                                               from Profile 
                                               where UserType = 'PowerPartner' and name like '%PRM%' 
                                               limit 1];
                                               
        User partnerUser = new User(
                    Username='JohnDoe001' + System.currentTimeMillis() + '@dell.com',
                    Alias = 'JD1001', 
                    Email='JohnDoe001@dell.com', 
                    FirstName='John001', 
                    LastName='Doe001', 
                    ProfileId = partnerProfiles.get(0).Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Enable_Partner_Lead_Management__c = true,
                    Enable_Partner_Deal_Registration__c = true,
                    Badge_Number__c='001', 
                    isActive = TRUE,
                    //AccountId = accountObj.Id,
                    ContactId = newCont.id
                );
       User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];   
       System.runAs ( thisUser ) {
       try{
       insert partnerUser;
       }catch(Exception ex){}
       }
        
       Campaign newCampgn1 = new Campaign(Name='Campaign_CMAP2',
                //Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='ABU',   
                Allocation_Source__c = 'Dell Allocation ABU',
                Nurture_Source__c = 'Dell Nurturing',                     
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = TRUE,
                 Partner_Campaign_Contact__c = partnerUser.Id,
                Partner_Campaign_Contact_Email__c = 'test@dell.com',
                IsActive = true,
                RecordTypeId = campRTId,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1,
                Lead_Routing__c ='Dell Standard');
        insert newCampgn1;
        CMAP_Helper.skipinsert = true;
        test.starttest();
        Lead leadObjt = new Lead(lastName = 'Test Lead1',
                email ='testcmap@cmaptest.com',
                status = 'Open - Channel Lead',
                Phone='88967544',
                Country = 'US',
                Partner_Account__c =newAcc1.Id,
                Campaign__c  = newCampgn1.Id,
                recordTypeId = leadRTId,
                Budget__c = 'Yes',
                Ready_for_scoring__c = TRUE,
                Purchase_Timeframe__c ='Immediate',
                Partner_User__c =  partnerUser.Id,
                LeadSource = 'Employee Referral',
                Lead_Type__c = 'Inbound',
                Dell_Partner_can_contact_me__c = true,
                Company = 'Test Company');
        insert leadObjt;
        //leadObjt.Ready_for_scoring__c = TRUE;
        //update leadObjt; 
        test.stoptest();
        PageReference  pr2 = new PageReference('/apex/CMAP_ButtonActions?Id='+leadObjt.Id+'&action=Reject');
        Test.setCurrentPage(pr2);        
        CMAP_ButtonActionCntrlr controller1 = new CMAP_ButtonActionCntrlr (new ApexPages.StandardController(new Lead()));
        controller1.leadObj= leadObjt;
        controller1.redirect();

        PageReference  pageRefActual=controller1.redirect();
        
        //PageReference  pageRefExpected=new PageReference('/'+leadObjt.Id);
        //System.assertEquals(pageRefExpected, pageRefActual); 
    }
    static testMethod void TestNurturing() {
        /*CMAP_TestDataGenerator testData = new CMAP_TestDataGenerator();
        testData.getContact(true);
        testData.getPartnerUser(true);
        testData.getCampaign(true);
        testData.getLead(true);
        */
        
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v3.0
        //Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Submission','Lead',true);//v3.0
        Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead 2.0','Lead',true);
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Account newAcc2 = new Account(name='Test2',Type = 'Partner', RecordtypeId = accRTId);
        insert newAcc2;
        /*
        newAcc2.IsPartner = True;
        newAcc2.Type = 'Partner' ;
        update newAcc2;*/
       
        Contact newCont2= new Contact(FirstName='TestContact3'+system.now().millisecond(), //v3.1
                 LastName='TestContactlast3'+system.now().millisecond(), //v3.1
                 accountId=newAcc2.Id,
                 Email='test2'+system.now().millisecond()+'@ust-global.com', //v3.1
                  Status__c = 'Marketing Suspect',
                 fax='01987645',
                 MobilePhone= String.valueOf(Math.round(Math.random()*1000)) + '00' +system.now().millisecond(), //v3.1
                 Last_Operation_Performed__c = 'testing',
                 Phone= String.valueOf(Math.round(Math.random()*1000)) + '00' +system.now().millisecond()); //v3.1
        insert newCont2;
        
        final List<Profile> partnerProfiles = [select id,name 
                                               from Profile 
                                               where UserType = 'PowerPartner' and name like '%PRM%' 
                                               limit 1];
                                               
        User partnerUser2 = new User(
                    Username='test002' + System.currentTimeMillis() + '@dell.com',
                    Alias = 'test002', 
                    Email='test002@dell.com', 
                    FirstName='John002', 
                    LastName='Doe002', 
                    ProfileId = partnerProfiles.get(0).Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Enable_Partner_Lead_Management__c = true,
                    Enable_Partner_Deal_Registration__c = true,
                    Badge_Number__c='002', 
                    isActive = TRUE,
                    //AccountId = accountObj.Id,
                    ContactId = newCont2.id
                );
       User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];   
       System.runAs ( thisUser ) {
       try{
       insert partnerUser2;
       }catch(Exception ex){}
       }
       Campaign newCampaign = new Campaign(Name='Campaign_CMAP3',
                //Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='ABU',
                Allocation_Source__c = 'Dell Allocation ABU',
                Nurture_Source__c = 'Dell Nurturing',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = TRUE,
                 Partner_Campaign_Contact__c = partnerUser2.Id,
                Partner_Campaign_Contact_Email__c = 'test@dell.com',
                IsActive = true,
                RecordTypeId = campRTId,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1,
                Lead_Routing__c ='Dell Standard');
        insert newCampaign ;
        CMAP_Helper.skipinsert = true;
        Test.startTest();
        Lead leadObj1 = new Lead(lastName = 'Test Lead12',
                email ='testcmap@cmaptest.com',
                status = 'Open - Channel Lead',
                Phone='88967544',
                Country = 'US',
                Partner_Account__c =newAcc2.Id,
                Campaign__c  = newCampaign.Id,
                recordTypeId = leadRTId,
                Budget__c = 'Yes',
                Ready_for_scoring__c = TRUE,
                Purchase_Timeframe__c ='Immediate',
                Partner_User__c =  partnerUser2.Id,
                LeadSource = 'Employee Referral',
                Lead_Type__c = 'Inbound',
                Dell_Partner_can_contact_me__c = true,
                Company = 'Test Company');
        insert leadObj1; 
        //leadObj1.Ready_for_scoring__c = TRUE;
        //update leadObj1;
        PageReference  pr3 = new PageReference('/apex/CMAP_ButtonActions?Id='+leadObj1.Id+'&action=Nurturing');
        Test.setCurrentPage(pr3);        
        CMAP_ButtonActionCntrlr controller2 = new CMAP_ButtonActionCntrlr (new ApexPages.StandardController(new Lead()));
        controller2.leadObj= leadObj1;
        controller2.redirect();
        
        PageReference  pageRefActual=controller2.redirect();
        PageReference  pageRefExpected=new PageReference('/00Q/o');
        Test.stoptest();
        //System.assertEquals(pageRefExpected, pageRefActual); 
    }
    //version2.0
  /*  static testMethod void TestDSGAccept() {
        /*CMAP_TestDataGenerator testData = new CMAP_TestDataGenerator();
        testData.getContact(true);
        testData.getPartnerUser(true);
        testData.getCampaign(true);
        testData.getLead(true);
       
        //retrieve DSG Partner RT
        Id DSGLeadRTId = IdLookupUtils.getRecordTypeId('DSG Partner', 'Lead', true);
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v3.0
        
        //Query for DSG Partner campaign, if does not exsits create new
        List<Campaign> camList = [SELECT id from Campaign where name = 'DSG Partner'];
        if(camList.size()==0 || camList == null){
            Campaign dsgCampaign = new Campaign(name = 'DSG Partner',Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='ABU',                
                Description='Test',StartDate=system.today(),EndDate=system.today()+15,
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = false,                
                IsActive = true,
                RecordTypeId = campRTId,
                Allocation_Source__c = 'Dell Allocation ABU',
                Nurture_Source__c = 'Dell Nurturing',
                Lead_Routing__c ='Dell Standard'
                );
                insert dsgCampaign;
                camList.add(dsgCampaign);
            
        }
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner');
        insert newAcc;
       
        /*newAcc.IsPartner = True;
        newAcc. ;
        update newAcc;
        */
        /*Contact newCont = new Contact(FirstName='TestContactFN9'+system.now().millisecond(), //v3.1
                 LastName='TestContactLN9'+system.now().millisecond(), //v3.1
                 accountId=newAcc.Id,
                 Status__c = 'Marketing Suspect',
                 Email='TestContactEmail9'+system.now().millisecond()+'@ust-global.com', //v3.1
                 fax='01987645',
                 MobilePhone= String.valueOf(Math.round(Math.random()*1000)) + '00' +system.now().millisecond(), //v3.1
                 Last_Operation_Performed__c = 'testing',
                 Phone= String.valueOf(Math.round(Math.random()*1000)) + '00' +system.now().millisecond()); //v3.1
        insert newCont;
        
        final List<Profile> partnerProfiles = [select id,name 
                                               from Profile 
                                               where UserType = 'PowerPartner' and name like '%PRM%' 
                                               limit 1];
                                               
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
                    Enable_Partner_Lead_Management__c = true,
                    Enable_Partner_Deal_Registration__c = true,
                    Badge_Number__c='909', 
                    isActive = TRUE,
                    ContactId = newCont.id
                );
       User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];   
       System.runAs ( thisUser ) {
       insert partnerUser;
       }
       Profile AdminProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE 'System Administrator' LIMIT 1];
       User admin = [SELECT id FROM User WHERE profileid = :AdminProfile.id AND isactive = true limit 1];
       System.runAs(admin){
        CMAP_Helper.skipinsert = true;
        Lead leadObj = new Lead(lastName = 'Test DSG Lead1',
                email ='testcmap@cmaptestdsg.com',
                status = 'Open - Channel Lead',
                Phone='88967544',
                Country = 'US',
                Partner_Account__c =newAcc.Id,
                //Campaign__c  = camList[0].Id,//v3.1
                recordTypeId = DSGLeadRTId,
                Budget__c = 'Yes',
                Purchase_Timeframe__c ='Immediate',
                Partner_User__c =  partnerUser.Id,                
                Company = 'Test Company');
       try{
        insert leadObj;
        }catch(Exception ex){}
        test.startTest();
        PageReference  pr1 = new PageReference('/apex/CMAP_ButtonActions?Id='+leadObj.Id+'&action=Accept');
        Test.setCurrentPage(pr1);     
        CMAP_ButtonActionCntrlr controller = new CMAP_ButtonActionCntrlr (new ApexPages.StandardController(new Lead()));
        controller.leadObj= leadObj;
        try{
        controller.redirect();
        }catch(Exception ex){}
        Test.stopTest();
        //Assert contacted customer and sales qualified     
       
       }
        
        
    }
    */
}