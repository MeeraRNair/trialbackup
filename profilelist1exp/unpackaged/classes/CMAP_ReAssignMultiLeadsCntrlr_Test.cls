/*REVISION HISTORY
Version        Author              Date                   Release#       Description
----------     ------              ----                   --------      -----------
1.0            Anwar D            15-Dec-2015             16.12          Test class for CMAP_ReAssignMultiLeadsCntrlr.   
2.0            Azwanti            15-March-2016         FY17-DCS-0401   replace Campaign RT from 'Channel Campaign' to 'Campaign 2.0'.
3.0            Sui Yee            1-June-2016           FY17-DCS-0701   CR13199 - replace RecordTypeId'Campaign 2.0'& lead 2.0 mandatory field.@isTest(SeeAllData=true)
*/
@isTest
private class CMAP_ReAssignMultiLeadsCntrlr_Test{
    
    //v3.0 Setup test data for queue
        @testSetup static void populateCMAPCustomSetting() {
            CMAP_Queue_Settings__c eClerxQueue = new CMAP_Queue_Settings__c(Name = 'Channel_eClerx', Queue_Id__c = '00GA0000002y6hl', Queue_Name__c = 'Channel_eClerx');
            Database.insert(eClerxQueue);
        }
      
    static testMethod void myUnitTestAssign() {        
        Test.startTest() ;  
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipLeadTriggers(true);
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Lead');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);


        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
        Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Assignment Complete','Lead',true);
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Account newAcc = new Account(name='MyTestAccount5', Type = 'Partner', RecordtypeId = accRTId);
        insert newAcc;
        
        
        Contact newCont = new Contact(FirstName='MyTestContact5',
                 LastName='MyTestContact5', Status__c = 'Marketing Suspect',
                 accountId=newAcc.Id,
                 Email='MyTestContactEmail5@ust-global.com',
                 fax='1234567',
                 MobilePhone='0987654'
                 );
        insert newCont;
        
        final List<Profile> partnerProfiles = [select id,name 
                                               from Profile 
                                               where UserType = 'PowerPartner' and name like '%PRM%' 
                                               ORDER BY CreatedDate DESC limit 1];
                                               
        List<User>partnerUserList = new List<User>();
        partnerUserList.add(new User(
                    Username='MyTestUser5' + System.currentTimeMillis() + '@dell.com',
                    Alias = 'MTU5', 
                    Email='MyTestUser5@dell.com', 
                    FirstName='MyTestUser5', 
                    LastName='MyTestUser5',  
                    ProfileId = partnerProfiles.get(0).Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Badge_Number__c='9982657', 
                    isActive = TRUE,
                    Enable_Partner_Deal_Registration__c = TRUE,
                    Enable_Partner_Lead_Management__c = TRUE,
                    Enable_As_Partner_Lead_Super_User__c = TRUE,
                    ContactId = newCont.id
                ));
       final List<Profile> partnerProfiles2 = [select id,name 
                                               from Profile 
                                               where name like '%GBL Channel Marketing'];
                                               
       partnerUserList.add(new user(Username='shaundell12@acme.com',
                       Alias = 'test12',Email='test32445@dell.com', 
                       FirstName='Johns',LastName='Doew',
                       LanguageLocaleKey='en_US',
                       ProfileId=partnerProfiles2.get(0).Id,
                              LocaleSidKey='en_US',EmailEncodingKey='UTF-8',
                              TimeZoneSidKey='America/Los_Angeles',
                              Enable_Partner_Admin__c= TRUE,IsActive =TRUE,
                              Badge_Number__c='5'));  
       insert partnerUserList;
       system.debug('partnerUserList'+ partnerUserList);
       Campaign newCampgn = new Campaign(Name='MyTestCampaign5',
                //Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='NA',  
                Allocation_Source__c = 'Channel ABU Agency 1',
                Nurture_Source__c = 'Channel ABU Agency 1',                      
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = False,
                IsActive = true,
                RecordTypeId = campRTId,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1);
        insert newCampgn;
        string queueName = 'NA:Channel ABU Agency 1:A';
        CMAP_Queue_Settings__c QueueId = CMAP_Queue_Settings__c.getValues(queueName);
        /* Group gp = new Group();
            if(QueueId == NULL){
                gp = [Select id, Name from Group where Name Like '%ABU_Agency_1_Allocation%' Limit 1];
            }*/
            String OwnerIdString;
            if(QueueId != NULL){
                    OwnerIdString = QueueId.Queue_Id__c;
                }
               /* else if(gp != NULL){
                    OwnerIdString = gp.Id;
                }*/
        CMAP_Helper.skipinsert = true;
        Lead leadObj = new Lead(lastName = 'MyTestLead5',
                email ='MyTestLeadEmail5@cmaptest.com',
                status = 'Open - Channel Lead',
                Phone='88967544',
                Partner_Account__c =newAcc.Id,
                Campaign__c  = newCampgn.Id,
                Country = 'US',
                Country_CN__c = 'UNITED STATES',
                //OwnerId = OwnerIdString,
                OwnerId = '00GA0000002y6hl',//v3.0
                recordTypeId = leadRTId,
                Budget__c = 'Yes',
                Purchase_Timeframe__c ='Immediate',
                Partner_User__c =  partnerUserList[0].Id,
                Company = 'Test Company',
                Ready_for_scoring__c = TRUE);
        insert leadObj;        
                  
        PageReference  pr = new PageReference('/apex/CMAP_ReAssignMultiLeadsCntrlr?leadRecorIds='+leadObj.Id+'&action=AssignLead');
        Test.setCurrentPage(pr);

        CMAP_ReAssignMultiLeadsCntrlr controller = new CMAP_ReAssignMultiLeadsCntrlr(new ApexPages.StandardController(new Lead()));
        controller.selectedUser();
        
        controller.selUserId = 'other';        
        controller.leadObjForUser.OwnerId = partnerUserList[0].Id;
        controller.userStr = partnerUserList[0].Id;
        controller.selectedUser();
        controller.first();
        controller.last();
        controller.previous();
        controller.next();
        controller.cancel();
        controller.getpartnerUserToRole();
        controller.con.getHasNext();
        controller.con.getHasPrevious();
        controller.con.getPageNumber();      
        Test.stopTest();

    }

    static testMethod void myUnitTestReAssign() {        
        Test.startTest() ; 
             
             
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipLeadTriggers(true);
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Lead');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);     


        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
        Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Submission','Lead',true);
        Id leadAssRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Assignment Complete','Lead',true);
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Account newAcc = new Account(name='MyTestAccountABC', RecordtypeId = accRTId);
        insert newAcc;
        newAcc.Type = 'Partner' ;
        update newAcc;
        List<Contact> lstOfCont = new List<Contact>();
        lstOfCont.add(new Contact(FirstName='MyTestContact5ABC',
                 LastName='MyTestContact5',
                 accountId=newAcc.Id, Status__c = 'Marketing Suspect',
                 Email='MyTestContactEmailABC@ust-global.com',
                 fax='1234567',
                 MobilePhone='450987654'));
       
        lstOfCont.add(new Contact(FirstName='MyTestContact5DEFc',
                 LastName='MyTestContact5',
                 accountId=newAcc.Id, Status__c = 'Marketing Suspect',
                 Email='MyTestContactEmailDEF@ust-global.com',
                 fax='12342567',
                 MobilePhone='4507654'));
        insert lstOfCont;
        
        final List<Profile> partnerProfiles = [select id,name 
                                               from Profile 
                                               where UserType = 'PowerPartner' and name like '%PRM%' 
                                               ORDER BY CreatedDate DESC limit 1];
                                               
        List<User>partnerUserList = new List<User>();
        partnerUserList.add(new User(
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
                    ContactId = lstOfCont[0].id
                ));
                 partnerUserList.add(new User(
                    Username='userABCUST' + System.currentTimeMillis() + '@dell.com',
                    Alias = 'MTU5', 
                    Email='MyTestUserdef5@dell.com', 
                    FirstName='MyTestUserdef5', 
                    LastName='MyTestUserdef5',  
                    ProfileId = partnerProfiles.get(0).Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Badge_Number__c='998DEF', 
                    isActive = TRUE,
                    ContactId = lstOfCont[1].id
                ));
       final List<Profile> partnerProfiles2 = [select id,name 
                                               from Profile 
                                               where name like '%GBL Channel Marketing'];
                                               
       partnerUserList.add(new user(Username='HuanustJuan@acme.com',Alias = 'test12',Email='usttesting@dell.com', FirstName='Johnsust',LastName='ustDoew',LanguageLocaleKey='en_US',ProfileId=partnerProfiles2.get(0).Id,
                        LocaleSidKey='en_US',EmailEncodingKey='UTF-8',TimeZoneSidKey='America/Los_Angeles',Enable_Partner_Deal_Registration__c = TRUE,Enable_Partner_Lead_Management__c = TRUE,Enable_As_Partner_Lead_Super_User__c = TRUE,Enable_Partner_Admin__c= TRUE,IsActive =TRUE,Badge_Number__c='ust'));  
       insert partnerUserList;
       
       Campaign newCampgn = new Campaign(Name='MyTestABCCampaign5',
                //Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='NA',  
                Allocation_Source__c = 'Channel ABU Agency 1',
                Nurture_Source__c = 'Channel ABU Agency 1',                      
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = False,
                IsActive = true,
                RecordTypeId = campRTId,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1);
        insert newCampgn;
        CMAP_Helper.skipinsert = true;
        Lead leadObj = new Lead(lastName = 'MyTestABCLead5',
                email ='MyTestLeadABCEmail5@cmaptest.com',
                status = 'Assigned To Channel Partner',
                Phone='88967544',
                Partner_Account__c =newAcc.Id,
                Campaign__c  = newCampgn.Id,
                Country = 'US',
                recordTypeId = leadAssRTId,
                Budget__c = 'Yes',
                Purchase_Timeframe__c ='Immediate',
                Partner_User__c =  partnerUserList[0].Id,
                OwnerId = partnerUserList[0].Id,
                Company = 'Test Company',
                Ready_for_scoring__c = TRUE);
        insert leadObj;        
        system.Runas(partnerUserList[0]){      
        CMAP_ReAssignMultiLeadsCntrlr controller = new CMAP_ReAssignMultiLeadsCntrlr(new ApexPages.StandardController(new Lead()));
                
        PageReference  pref = new PageReference('/apex/CMAP_ReAssignMultiLeadsCntrlr?leadRecorIds='+leadObj.Id+'&radioName=other');
        Test.setCurrentPage(pref);
            
        controller.selUserId = 'other';
        controller.userStr = partnerUserList[0].Id;
        controller.selectedUser();
        }    
        Test.stopTest();

    }
    static testMethod void NoPAAssign() {        
                         TriggerExecutionController.setSkipAccountTriggers(true);

           
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
        //Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Submission','Lead',true);
        Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead 2.0','Lead',true);//3.0
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Account newAcc = new Account(name='MyTestAccount5', Type = 'Partner', RecordtypeId = accRTId);
        insert newAcc;
        //newAcc.Type = 'Partner' ;
        //update newAcc;
        string userStr;
        List<Lead> owner = new List<Lead>();
        List<User> ownerName = new List<User>();
        
        Contact newCont = new Contact(FirstName='MyTestContact5',
                 LastName='MyTestContact5',
                 accountId=newAcc.Id,  Status__c = 'Marketing Suspect',
                 Email='MyTestContactEmail5@ust-global.com',
                 fax='1234567',
                 MobilePhone='0987654'
                 );
        insert newCont;
        
        final List<Profile> partnerProfiles = [select id,name 
                                               from Profile 
                                               where UserType = 'PowerPartner' and name like '%PRM%' 
                                               ORDER BY CreatedDate DESC limit 1];
                                               
        List<User>partnerUserList = new List<User>();
        partnerUserList.add(new User(
                    Username='MyTestUser5' + System.currentTimeMillis() + '@dell.com',
                    Alias = 'MTU5', 
                    Email='MyTestUser5@dell.com', 
                    FirstName='MyTestUser5', 
                    LastName='MyTestUser5',  
                    ProfileId = partnerProfiles.get(0).Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Badge_Number__c='9982657', 
                    isActive = TRUE,
                    Enable_Partner_Deal_Registration__c = TRUE,
                    Enable_Partner_Lead_Management__c = TRUE,
                    Enable_As_Partner_Lead_Super_User__c = TRUE,
                    Enable_Partner_Admin__c= TRUE,
                    ContactId = newCont.id
                ));
       final List<Profile> partnerProfiles2 = [select id,name 
                                               from Profile 
                                               where name like '%GBL Channel Marketing'];
                                               
       partnerUserList.add(new user(Username='shaundell13@acme.com',
                       Alias = 'test12',Email='test32445@dell.com', 
                       FirstName='Johns',LastName='Doew',
                       LanguageLocaleKey='en_US',
                       ProfileId=partnerProfiles2.get(0).Id,
                              LocaleSidKey='en_US',EmailEncodingKey='UTF-8',
                              TimeZoneSidKey='America/Los_Angeles',
                              Enable_Partner_Admin__c= TRUE,IsActive =TRUE,
                              Badge_Number__c='5'));  
       insert partnerUserList;
       Test.startTest() ;     
       Campaign newCampgn = new Campaign(Name='MyTestCampaign5',
                //Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='NA',  
                Allocation_Source__c = 'Channel ABU Agency 1',
                Nurture_Source__c = 'Channel ABU Agency 1',                      
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = False,
                IsActive = true,
                RecordTypeId = campRTId,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1);
        insert newCampgn;
        string queueName = 'NA:Channel ABU Agency 1:A';
        CMAP_Queue_Settings__c QueueId = CMAP_Queue_Settings__c.getValues(queueName);
         /*Group gp = new Group();
            if(QueueId == NULL){
                gp = [Select id, Name from Group where Name Like '%ABU_Agency_1_Allocation%' Limit 1];
            }
           */
            String OwnerIdString;
            if(QueueId != NULL){
                    OwnerIdString = QueueId.Queue_Id__c;
                }
           /*     else if(gp != NULL){
                    OwnerIdString = gp.Id;
                }
        */
        CMAP_Helper.skipinsert = true;
        LeadValidator.bSkipLeadValidator = true;
        Lead leadObj = new Lead(lastName = 'MyTestLead5',
                email ='MyTestLeadEmail5@cmaptest.com',
                status = 'Open - Channel Lead',
                Phone='88967544',
                Partner_Account__c =newAcc.Id,
                Campaign__c  = newCampgn.Id,
                Country = 'US',
                 //OwnerId = OwnerIdString,
                OwnerId = '00GA0000002y6hl',//v3.0
                recordTypeId = leadRTId,
                Budget__c = 'Yes',
                Purchase_Timeframe__c ='3 months',
                Partner_User__c =  partnerUserList[0].Id,               
                Company = 'Test Company',
                Ready_for_scoring__c = TRUE);
        insert leadObj;  
        Test.stopTest();         
        PageReference  pr = new PageReference('/apex/CMAP_ReAssignMultiLeadsCntrlr?leadRecorIds='+leadObj.Id+'&action=AssignLead');
        Test.setCurrentPage(pr);
        
        CMAP_ReAssignMultiLeadsCntrlr  controller = new CMAP_ReAssignMultiLeadsCntrlr(new ApexPages.StandardController(new Lead()));    
        
        //controller.selectedUser();                      
        
        
        String newOwnerLangStr = 'en_US';
        
        owner = [Select ownerId from Lead where id =:leadObj.Id];
        ownerName = [Select name from User where Id =:partnerUserList[0].Id];                    

        User u = [Select id, Name,UserType,AccountId,LanguageLocaleKey from User where id =: partnerUserList[0].Id];
        
        
        system.currentpagereference().getparameters().put('radioName','other');
        String selUserId = ApexPages.currentPage().getParameters().get('radioName');
        
        
        controller.leadObjForUser.OwnerId = partnerUserList[0].Id; 
        system.currentpagereference().getparameters().put('radioName','other');
        controller.selectedUser();
        
        controller.cancel();
        controller.getpartnerUserToRole();
        controller.con.getHasNext();
        controller.con.getHasPrevious();
        controller.con.getPageNumber();      
        
    }
    static testMethod void PUAssign() {  
        
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipLeadTriggers(true);



                 
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
        Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Assignment Complete','Lead',true);
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Account newAcc = new Account(name='MyTestAccount5', Type = 'Partner', RecordtypeId = accRTId);
        insert newAcc;
        newAcc.Type = 'Partner' ;
        update newAcc;
        string userStr;
        List<Lead> owner = new List<Lead>();        
        List<Lead> lead = new List<Lead>();        
        List<User> ownerName = new List<User>();
        string action = '';
        Lead leadOb = new Lead();       
        
        Contact newCont = new Contact(FirstName='MyTestContact6',
                 LastName='MyTestContact6',
                 accountId=newAcc.Id, Status__c = 'Marketing Suspect',
                 Email='MyTestContactEmail6@ust-global.com',
                 fax='1234567',
                 MobilePhone='0987654'
                 );
        insert newCont;
        
        final List<Profile> partnerProfiles = [select id,name 
                                               from Profile 
                                               where UserType = 'PowerPartner' and name like '%PRM%' 
                                               ORDER BY CreatedDate DESC limit 1];
                                               
        List<User>partnerUserList = new List<User>();
        partnerUserList.add(new User(
                    Username='MyTestUser6' + System.currentTimeMillis() + '@dell.com',
                    Alias = 'MTU5', 
                    Email='MyTestUser6@dell.com', 
                    FirstName='MyTestUser6', 
                    LastName='MyTestUser6',  
                    ProfileId = partnerProfiles.get(0).Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Badge_Number__c='9982657', 
                    isActive = TRUE,
                    Enable_Partner_Deal_Registration__c = TRUE,
                    Enable_Partner_Lead_Management__c = TRUE,
                    Enable_As_Partner_Lead_Super_User__c = TRUE,
                    Enable_Partner_Admin__c= TRUE,
                    ContactId = newCont.id
                ));
       final List<Profile> partnerProfiles2 = [select id,name 
                                               from Profile 
                                               where name like '%GBL Channel Marketing' limit 1];
                                               
       partnerUserList.add(new user(Username='ann@acme.com',
                       Alias = 'test12',Email='test32445@dell.com', 
                       FirstName='Jos',LastName='Don',
                       LanguageLocaleKey='en_US',
                       ProfileId=partnerProfiles2.get(0).Id,
                              LocaleSidKey='en_US',EmailEncodingKey='UTF-8',
                              TimeZoneSidKey='America/Los_Angeles',
                              Enable_Partner_Admin__c= TRUE,IsActive =TRUE,
                              Badge_Number__c='4564'));  
       insert partnerUserList;
       
       Campaign newCampgn = new Campaign(Name='MyTestCamp',
                //Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                Region__c='NA',  
                Allocation_Source__c = 'Channel ABU Agency 1',
                Nurture_Source__c = 'Channel ABU Agency 1',                      
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Country_Code__c = 'BR - Brazil',
                Partner_Event_or_Campaign__c = False,
                IsActive = true,
                RecordTypeId = campRTId,
                Total_Value_Won_Opportunities_Planned__c = 1,
                Total_Value_Opportunities_Planned__c = 1);
        insert newCampgn;
        string queueName = 'NA:Channel ABU Agency 1:A';
        CMAP_Queue_Settings__c QueueId = CMAP_Queue_Settings__c.getValues(queueName);
        CMAP_Helper.skipinsert = true;
               List<string> listObjectNames = new List<string>();
        listObjectNames.add('Lead');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        Lead leadObj = new Lead(lastName = 'MyTestLeadU',
                email ='MyTestLeadUEmail5@cmaptest.com',
                status = 'Open - Channel Lead',
                Phone='88967544',
                Partner_Account__c =newAcc.Id,
                Campaign__c  = newCampgn.Id,
                Country = 'US',
                //OwnerId = QueueId.Queue_Id__c,              
                recordTypeId = leadRTId,
                Budget__c = 'Yes',
                Purchase_Timeframe__c ='3 months',
                Partner_User__c =  partnerUserList[0].Id,               
                Company = 'Test Company',
                Ready_for_scoring__c = TRUE);
        insert leadObj;  
                  
        PageReference  pr = new PageReference('/apex/CMAP_ReAssignMultiLeadsCntrlr?leadRecorIds='+leadObj.Id+'&action=AssignLead');
        Test.setCurrentPage(pr);
        Test.startTest() ;
        CMAP_ReAssignMultiLeadsCntrlr controller = new CMAP_ReAssignMultiLeadsCntrlr(new ApexPages.StandardController(new Lead()));    
        
        controller.selectedUser();              
                
        String newOwnerLangStr = 'en_US';
        //CMAP_Helper.skipinsert = true;
        lead = [Select Id, name,Partner_Account__c,Partner_Account__r.OwnerId,Partner_Account__r.Name,Owner_Language_Code__c,
                         Partner_User__c,Partner_Admin__c,Partner_Account_Owner_ApiOnly__c, Accept_Reject_Reassign_Status__c,
                         Partner_Lead_Status__c, Allocation_Queue_GUID__c, 
                         Owner.Name, OwnerId,Owner.Type,Status from Lead where id =:leadObj.Id];
                         
        system.debug('@@OwnerId 1: '+lead[0].ownerId);
        ownerName = [Select name from User where Id =:partnerUserList[0].Id];                    
        User u;
        u = [Select id, Name,UserType,AccountId,LanguageLocaleKey from User where id =: partnerUserList[0].Id];

        controller.leadObjForUser.OwnerId = partnerUserList[1].id;
        system.currentpagereference().getparameters().put('radioName',partnerUserList[1].id);
        String selUserId = ApexPages.currentPage().getParameters().get('radioName');
        system.debug('@@RadioName: '+selUserId);  
        
        controller.selectedUser();              
                
        owner = [Select ownerId from Lead where id =:leadObj.Id];
        system.debug('@@OwnerId 2: '+owner[0].ownerId);                             
        controller.selectedUser();
        
        controller.cancel();
        controller.getpartnerUserToRole();
        controller.con.getHasNext();
        controller.con.getHasPrevious();
        controller.con.getPageNumber();      
        Test.stopTest();
    } 
    static testMethod void testAsssignPermission() { 
                         TriggerExecutionController.setSkipAccountTriggers(true);
                         TriggerExecutionController.setSkipLeadTriggers(true);

        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
        //Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Submission','Lead',true);
        Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead 2.0','Lead',true);//3.0
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        List<User> partnerUserList = new List<User>();
        Lead lead = new Lead();    
        Account newAcc = new Account(name='MyTestAccount5', Type = 'Partner', RecordtypeId = accRTId);
        insert newAcc;
        Contact newCont = new Contact(FirstName='MyTestContact6',
                 LastName='MyTestContact6',
                 accountId=newAcc.Id, 
                 Status__c = 'Marketing Suspect',
                 Email='MyTestContactEmail6@ust-global.com',
                 fax='1234567',
                 MobilePhone='0987654'
                 );
        insert newCont;
        final Profile partnerProf = [select id,name 
                                       from Profile 
                                       where UserType = 'PowerPartner' and name like '%PRM%' 
                                       ORDER BY CreatedDate DESC limit 1];
                                               
         partnerUserList.add(new User(Username='MyTestUser6' + System.currentTimeMillis() + '@dell.com',
                    Alias = 'MTU5', 
                    Email='MyTestUser6@dell.com', 
                    FirstName='MyTestUser6', 
                    LastName='MyTestUser6',  
                    ProfileId = partnerProf.Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Badge_Number__c='765656345', 
                    isActive = TRUE,
                    Enable_Partner_Deal_Registration__c = TRUE,
                    Enable_Partner_Lead_Management__c = TRUE,
                    Enable_As_Partner_Lead_Super_User__c = TRUE,
                    Enable_Partner_Admin__c= TRUE,
                    ContactId = newCont.id));  
        final Profile mrktgProfile = [select id,name 
                                                   from Profile 
                                                   where name like '%GBL Channel Marketing - Non SSO' 
                                                   order by CreatedDate DESC limit 1];   
        
        partnerUserList.add(new User(Username='shaundell14@acme.com',
                     Alias = 'route', 
                     Email='testRLRouting@dell.com', 
                     FirstName='Johns',LastName='DoewHello',
                     LanguageLocaleKey='en_US',
                     LocaleSidKey='en_US', 
                     EmailEncodingKey='UTF-8',
                     TimeZoneSidKey='America/Los_Angeles',
                     IsActive =TRUE,Badge_Number__c='BadgeNumber',
                     profileId=mrktgProfile.Id)); 
        insert partnerUserList;
        string queueName = 'NA:Channel ABU Agency 1:A';
        CMAP_Queue_Settings__c QueueId = CMAP_Queue_Settings__c.getValues(queueName);
        String OwnerIdString;
        if(QueueId != NULL){
            OwnerIdString = QueueId.Queue_Id__c;
        }
        Campaign campObj= new Campaign(Name='Campaign_CMAP',
                Vertical__c='PTG',
                Sub_Region__c='Canada',
                StartDate=system.today(),
                Solution__c='Unknown',
                Segment_Business_Unit__c='CSB',
                Region__c='NA',
                Parent_Vehicle__c='Events',
                Nurture_Source__c='Channel ABU Agency 1',
                Line_Of_Business__c='Desktop',
                Follow_Up_Role__c='Inside Sales Rep',
                IsActive = true,
                EndDate=system.today(),
                Description='Test',
                Campaign_Vehicle__c='Advisory Councils',
                Campaign_Objective__c='Action',
                Partner_Event_or_Campaign__c = FALSE,
                Allocation_Source__c='Channel ABU Agency 1',
                RecordTypeId = campRTId);
                //RecordTypeId='012A00000012Xt5');
         insert campObj;
         string partnerUser;
         User marketingUser = new User();
         if(partnerUserList[0].ContactId != NUll){
             partnerUser =  partnerUserList[0].Id;
             marketingUser = partnerUserList[1];
         } 
         else{
             partnerUser =  partnerUserList[1].Id;
             marketingUser = partnerUserList[0];
         }
         CMAP_Helper.skipinsert = true;   
        
         Lead leadRecord = new Lead(lastName = 'Test Lead1',
                email ='testcmap@cmaptest.com',
                status = 'Open',
                Phone='88967544',
                Campaign__c  = campObj.Id,
                recordTypeId = leadRTId,
                Budget__c = 'Yes',
                Purchase_Timeframe__c ='Immediate',
                Company = 'Test Company',
                Country = 'US',
                Partner_Account__c =newAcc.Id,
                //OwnerId = OwnerIdString,
                OwnerId = '00GA0000002y6hl',//v3.0
                //OwnerId = QueueId.Queue_Id__c,
                Partner_User__c =  partnerUser,             
                //Partner_User__c =  partnerUserList[0].Id,
                //v3.0 start
                LeadSource = 'Web',
                Lead_Type__c = 'Inbound',
                Dell_Partner_can_contact_me__c = true,
                //v3.0 end               
                Ready_for_scoring__c = TRUE);
            insert leadRecord;
            GroupMember gpMem;
            String strOwner = leadRecord.OwnerId;
            if(strOwner.startsWith('00G')){
                gpMem = new GroupMember(GroupId = leadRecord.OwnerId, UserOrGroupId = marketingUser.Id);
            }
            PageReference pref = new PageReference('/apex/CMAP_ReAssignMultiLeadsCntrlr?leadRecorIds='+leadRecord.Id+'&action=AssignLead');
            Test.setCurrentPage(pref);
            system.debug('###pref-' + pref);
            Test.startTest();
            CMAP_ReAssignMultiLeadsCntrlr cntrlr = new CMAP_ReAssignMultiLeadsCntrlr(new ApexPages.StandardController(leadRecord)); 
            cntrlr.leadObjForUser.OwnerId = partnerUserList[0].Id;  
            cntrlr.profileName =  mrktgProfile.Name;   
            cntrlr.redirect();
            Test.stopTest(); 
    }
    static testMethod void testReAsssignPermission() { 
                         TriggerExecutionController.setSkipAccountTriggers(true);
                                                  TriggerExecutionController.setSkipLeadTriggers(true);


        TriggerExecutionController.setSkipAllTriggers(true);//v3.0
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v2.0
        //Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Submission','Lead',true);
        Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead 2.0','Lead',true);//3.0
        Id leadAssRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Assignment Complete','Lead',true);
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Account newAcc = new Account(name='MyTestAccountABC', RecordtypeId = accRTId);
        insert newAcc;
        newAcc.Type = 'Partner' ;
        update newAcc;
        List<Contact> lstOfCont = new List<Contact>();
        lstOfCont.add(new Contact(FirstName='MyTestContact5ABC',
                 LastName='MyTestContact5',
                 accountId=newAcc.Id, Status__c = 'Marketing Suspect',
                 Email='MyTestContactEmailABC@ust-global.com',
                 fax='1234567',
                 MobilePhone='450987654'));
        lstOfCont.add(new Contact(FirstName='MyTestContact5DEFc',
                 LastName='MyTestContact5',
                 accountId=newAcc.Id, Status__c = 'Marketing Suspect',
                 Email='MyTestContactEmailDEF@ust-global.com',
                 fax='12342567',
                 MobilePhone='4507654'));
        insert lstOfCont;
        final List<Profile> partnerProfiles = [select id,name 
                                               from Profile 
                                               where UserType = 'PowerPartner' and name like '%PRM%' 
                                               ORDER BY CreatedDate DESC limit 1];
        List<User>partnerUserList = new List<User>();
        partnerUserList.add(new User(
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
                    ContactId = lstOfCont[0].id
                ));
                 partnerUserList.add(new User(
                    Username='userABCUST' + System.currentTimeMillis() + '@dell.com',
                    Alias = 'MTU5', 
                    Email='MyTestUserdef5@dell.com', 
                    FirstName='MyTestUserdef5', 
                    LastName='MyTestUserdef5',  
                    ProfileId = partnerProfiles.get(0).Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Badge_Number__c='998DEF', 
                    isActive = TRUE,
                    ContactId = lstOfCont[1].id
                ));
       final List<Profile> partnerProfiles2 = [select id,name 
                                               from Profile 
                                               where name like '%GBL Channel Marketing'];
                                               
       partnerUserList.add(new user(Username='HuanustJuan@acme.com',Alias = 'test12',Email='usttesting@dell.com', FirstName='Johnsust',LastName='ustDoew',LanguageLocaleKey='en_US',ProfileId=partnerProfiles2.get(0).Id,
                        LocaleSidKey='en_US',EmailEncodingKey='UTF-8',TimeZoneSidKey='America/Los_Angeles',Enable_Partner_Deal_Registration__c = TRUE,Enable_Partner_Lead_Management__c = TRUE,Enable_As_Partner_Lead_Super_User__c = TRUE,Enable_Partner_Admin__c= TRUE,IsActive =TRUE,Badge_Number__c='ust'));  
       insert partnerUserList;
       //string queueName = 'ABU:Channel OEM:A';
        string queueName = 'NA:Channel ABU Agency 1:A';
        CMAP_Queue_Settings__c QueueId = CMAP_Queue_Settings__c.getValues(queueName);
        String OwnerIdString;
        if(QueueId != NULL){
            OwnerIdString = QueueId.Queue_Id__c;
        }
       Campaign campObj= new Campaign(Name='Campaign_CMAP',
                Vertical__c='PTG',
                Sub_Region__c='US',
                StartDate=system.today(),
                Solution__c='Unknown',
                Segment_Business_Unit__c='CSB',
                Region__c='NA',
                Parent_Vehicle__c='Events',
                Nurture_Source__c='OEM Nurturing',
                Line_Of_Business__c='Desktop',
                Follow_Up_Role__c='Inside Sales Rep',
                IsActive = true,
                EndDate=system.today(),
                Description='Test',
                Campaign_Vehicle__c='Advisory Councils',
                Campaign_Objective__c='Action',
                Partner_Event_or_Campaign__c = FALSE,
                Allocation_Source__c='Channel ABU Agency 1',
                RecordTypeId = campRTId);
                //RecordTypeId='012A0000000VnHF');
         insert campObj;
        CMAP_Helper.skipinsert = true;
        Lead leadRecord = new Lead(lastName = 'Test Lead1',
                email ='testcmap@cmaptest.com',
                status = 'Open',
                Phone='88967544',
                Campaign__c  = campObj.Id,
                recordTypeId = leadRTId,
                Budget__c = 'Yes',
                Purchase_Timeframe__c ='Immediate',
                Company = 'Test Company',
                Country = 'US',
                Partner_Account__c =newAcc.Id,
                //OwnerId = OwnerIdString,
                OwnerId = '00GA0000002y6hl',//v3.0
                //v3.0 start
                LeadSource = 'Web',
                Lead_Type__c = 'Inbound',
                Dell_Partner_can_contact_me__c = true,
                //v3.0 end
                //OwnerId = QueueId.Queue_Id__c,
                //Partner_User__c =  partnerUser,             
                Partner_User__c =  partnerUserList[0].Id,               
                Ready_for_scoring__c = TRUE
                );
            insert leadRecord;
            TriggerExecutionController.setSkipAllTriggers(false);
            leadRecord.Allocation_Queue_GUID__c = leadRecord.OwnerId;
            GroupMember gpMem;
            String strOwner = leadRecord.OwnerId;
            if(strOwner.startsWith('00G')){
                gpMem = new GroupMember(GroupId = leadRecord.OwnerId, UserOrGroupId = partnerUserList[2].Id);
            }
            PageReference pref = new PageReference('/apex/CMAP_ReAssignMultiLeadsCntrlr?leadRecorIds='+leadRecord.Id);
            Test.setCurrentPage(pref);
            Test.startTest();
            CMAP_ReAssignMultiLeadsCntrlr cntrlr = new CMAP_ReAssignMultiLeadsCntrlr(new ApexPages.StandardController(leadRecord)); 
            cntrlr.profileName =  partnerUserList[2].Name;   
            cntrlr.redirect();
            Test.stopTest();
    }
}