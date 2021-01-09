/*REVISION HISTORY
Version      Author      Date        Release#    CR#     Description
-------      ------           ----                --------        ---     -----------
1.0        Sandhya      15-Nov-2012          14.2            --      Test class for CMAP_ManualAssignmentCntrlr.
2.0        Bianca        20-Feb-2013       14.2            --      Removed test data generator for SIT testing
3.0        Azwanti       15-March-2016       FY17-DCS-0401   12720   replace Campaign RT from 'Channel Campaign' to 'Campaign 2.0'.
4.0        Shue         02-May-2018       FY19-0602    15686  Story 4144896: Channel: Remove BANT Qualified leads process (Code)
4.1        Shue         02-May-2018       FY19-0602    15686  Story 4144896: Channel: Remove BANT Qualified leads process (Code) - Test Coverage
*/
@isTest(SeeAllData=true)
//@isTest(SeeAllData=false)
private class CMAP_ManualAssignmentCntrlr_Test{
    
    //4.1
    static Account newAcc;
    static Contact newContact;
    static Campaign newCampgn;
    static List<Profile> partnerProfiles = new List<Profile>(); 
    static List<Profile> partnerProfiles2 = new List<Profile>();
    static List<User>partnerUserList = new List<User>();
     
    //4.1
    static void createTestData(){
        //Retrieve RT
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v3.0
        //Create Account
        newAcc = new Account(name='Test_Account', Type = 'Partner', RecordtypeId = accRTId);
        insert newAcc;
        //Create Contact
        newContact = new Contact(FirstName='Test_FirstName', LastName='Test_LastName', Status__c = 'Marketing Suspect', accountId=newAcc.Id, Email='Test_Email@wxyz.comm', fax='1234567', MobilePhone='0987654');
        insert newContact;
        //Retrieve PRM profiles
        partnerProfiles = [select id,name from Profile where UserType = 'PowerPartner' and name like '%PRM%' ORDER BY CreatedDate DESC limit 1];
        //Retrieve Channel Mkt profiles
        partnerProfiles2 = [select id,name from Profile where name like '%GBL Channel Marketing'];
        //Create Campaign
        newCampgn = new Campaign(Name='Test_Campaign', Type='Advisory Councils', Segment_Business_Unit__c='SMB', Region__c='NA', Allocation_Source__c = 'Channel ABU Agency 1', 
                                          Nurture_Source__c = 'Channel ABU Agency 1', Follow_Up_Role__c='Account Executive', Description='Test Campaign Desc', StartDate=system.today(),EndDate=system.today(), 
                                          status='In Progress', Country_Code__c = 'BR - Brazil', Partner_Event_or_Campaign__c = False, IsActive = true, RecordTypeId = campRTId, Lead_Routing__c = 'Dell Standard',
                                          Total_Value_Won_Opportunities_Planned__c = 1, Total_Value_Opportunities_Planned__c = 1);
        insert newCampgn;
    }
      
    static testMethod void myUnitTestAssign() {
        //4.0 Add skip trigger to avoid too many soql
        TriggerExecutionController.setSkipAllTriggers(true);             
        //4.1
        createTestData();
        
        //Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v3.0
        Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Submission','Lead',true);
        
        List<User>partnerUserList = new List<User>();
        partnerUserList.add(new User(
                    Username='MyTestUser51' + System.currentTimeMillis() + '@dell.com',
                    Alias = 'MTU5', 
                    Email='MyTestUser51@dell.com', 
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
                    ContactId = newContact.id
                ));
        
       partnerUserList.add(new user(Username='shaundell121@acme.com',
                       Alias = 'test12',Email='test32445@dell.com', 
                       FirstName='Johns1',LastName='Doew',
                       LanguageLocaleKey='en_US',
                       ProfileId=partnerProfiles2.get(0).Id,
                              LocaleSidKey='en_US',EmailEncodingKey='UTF-8',
                              TimeZoneSidKey='America/Los_Angeles',
                              Enable_Partner_Admin__c= TRUE,IsActive =TRUE,
                              Badge_Number__c='5'));  
       insert partnerUserList;
       Test.startTest(); 
       
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
        
        Lead leadObj = new Lead(lastName = 'MyTestLead51',
                email ='MyTestLeadEmail51@cmaptest.com',
                status = 'Open - Channel Lead',
                Phone='88967544',
                Partner_Account__c =newAcc.Id,
                Campaign__c  = newCampgn.Id,
                Country = 'US',
                //OwnerId = OwnerIdString,
                OwnerId = partnerUserList[0].Id,
                recordTypeId = leadRTId,
                Budget__c = 'Yes',
                Purchase_Timeframe__c ='Immediate',
                Partner_User__c =  partnerUserList[0].Id,
                Company = 'Test Company',
                Ready_for_scoring__c = TRUE);
        insert leadObj; 
        Test.stopTest();       
                 
        PageReference  pr = new PageReference('/apex/CMAP_ManualAssignment?Id='+leadObj.Id+'&action=AssignLead');
        Test.setCurrentPage(pr);

        CMAP_ManualAssignmentCntrlr controller = new CMAP_ManualAssignmentCntrlr(new ApexPages.StandardController(new Lead()));
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
        TriggerExecutionController.setSkipAllTriggers(false);        
    }
    
    static testMethod void myUnitTestReAssign() {        
        TriggerExecutionController.setSkipAllTriggers(true);       
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v3.0
        Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Submission','Lead',true);
        Id leadAssRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Assignment Complete','Lead',true);
        
        createTestData();
        
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
                                                     
       partnerUserList.add(new user(Username='HuanustJuan@acme.com',Alias = 'test12',Email='usttesting@dell.com', FirstName='Johnsust',LastName='ustDoew',LanguageLocaleKey='en_US',ProfileId=partnerProfiles2.get(0).Id,
                        LocaleSidKey='en_US',EmailEncodingKey='UTF-8',TimeZoneSidKey='America/Los_Angeles',Enable_Partner_Deal_Registration__c = TRUE,Enable_Partner_Lead_Management__c = TRUE,Enable_As_Partner_Lead_Super_User__c = TRUE,Enable_Partner_Admin__c= TRUE,IsActive =TRUE,Badge_Number__c='ust'));  
       insert partnerUserList;
       
        CMAP_Helper.skipinsert = true;
        
        //TriggerExecutionController.setSkipLeadTriggers(true); //v3.0
        
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
        
        //TriggerExecutionController.setSkipLeadTriggers(false);
        
        Test.startTest() ;   
        system.Runas(partnerUserList[0]){      
            CMAP_ManualAssignmentCntrlr controller = new CMAP_ManualAssignmentCntrlr(new ApexPages.StandardController(new Lead()));
                    
            PageReference  pref = new PageReference('/apex/CMAP_ManualAssignment?Id='+leadObj.Id+'&radioName=other');
            Test.setCurrentPage(pref);
            controller.selUserId = 'other';
            controller.userStr = partnerUserList[0].Id;
            controller.selectedUser();
            
        }    
        Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false); 
    }
    
    static testMethod void NoPAAssign() {        
        TriggerExecutionController.setSkipAllTriggers(true);    
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v3.0
        Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Submission','Lead',true);
        
        createTestData();
        
        string userStr;
        List<Lead> owner = new List<Lead>();
        List<User> ownerName = new List<User>();
        
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
                    ContactId = newContact.id
                ));
       
        /*
       final List<Profile> partnerProfiles2 = [select id,name 
                                               from Profile 
                                               where name like '%GBL Channel Marketing' order by CreatedDate DESC limit 1];
        */                                               
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
        Lead leadObj = new Lead(lastName = 'MyTestLead5',
                email ='MyTestLeadEmail5@cmaptest.com',
                status = 'Open - Channel Lead',
                Phone='88967544',
                Partner_Account__c =newAcc.Id,
                Campaign__c  = newCampgn.Id,
                Country = 'US',
                OwnerId = OwnerIdString ,
                recordTypeId = leadRTId,
                Budget__c = 'Yes',
                Purchase_Timeframe__c ='3 months',
                Partner_User__c =  partnerUserList[0].Id,               
                Company = 'Test Company',
                Ready_for_scoring__c = TRUE);
        insert leadObj;  
        Test.stopTest();         
        PageReference  pr = new PageReference('/apex/CMAP_ManualAssignment?Id='+leadObj.Id+'&action=AssignLead');
        Test.setCurrentPage(pr);
        
        CMAP_ManualAssignmentCntrlr controller = new CMAP_ManualAssignmentCntrlr(new ApexPages.StandardController(new Lead()));    
        
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
        controller.first();
        controller.last();
        controller.previous();
        controller.next();
        controller.cancel();
        controller.getpartnerUserToRole();
        controller.con.getHasNext();
        controller.con.getHasPrevious();
        controller.con.getPageNumber();      
        TriggerExecutionController.setSkipAllTriggers(false);
    }

static testMethod void PUAssign() {        
        TriggerExecutionController.setSkipAllTriggers(true);
        Id campRTId= IdLookupUtils.getRecordTypeId('Channel Partner Communications','Campaign',true); //v3.0
        Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Submission','Lead',true);
        
        createTestData();
        
        string userStr;
        List<Lead> owner = new List<Lead>();        
        List<Lead> lead = new List<Lead>();        
        List<User> ownerName = new List<User>();
        string action = '';
        Lead leadOb = new Lead();       
        
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
                    ContactId = newContact.id
                ));
        
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
       Test.startTest() ;
       
        string queueName = 'NA:Channel ABU Agency 1:A';
        CMAP_Queue_Settings__c QueueId = CMAP_Queue_Settings__c.getValues(queueName);
        String OwnerIdString;
            if(QueueId != NULL){
                    OwnerIdString = QueueId.Queue_Id__c;
                }
        CMAP_Helper.skipinsert = true;
        Lead leadObj = new Lead(lastName = 'MyTestLeadU',
                email ='MyTestLeadUEmail5@cmaptest.com',
                status = 'Open - Channel Lead',
                Phone='88967544',
                Partner_Account__c =newAcc.Id,
                Campaign__c  = newCampgn.Id,
                Country = 'US',
                Origin__c ='Channel Lead 2.0',
                //OwnerId = QueueId.Queue_Id__c,
                OwnerId = OwnerIdString,              
                recordTypeId = leadRTId,
                Budget__c = 'Yes',
                Purchase_Timeframe__c ='3 months',
                Partner_User__c =  partnerUserList[0].Id,               
                Company = 'Test Company',
                Ready_for_scoring__c = TRUE);
        insert leadObj;  
        Test.stopTest();          
        PageReference  pr = new PageReference('/apex/CMAP_ManualAssignment?Id='+leadObj.Id+'&action=AssignLead');
        Test.setCurrentPage(pr);
        
        CMAP_ManualAssignmentCntrlr controller = new CMAP_ManualAssignmentCntrlr(new ApexPages.StandardController(new Lead()));    
        
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
        controller.first();
        controller.last();
        controller.previous();
        controller.next();
        controller.cancel();
        controller.getpartnerUserToRole();
        controller.con.getHasNext();
        controller.con.getHasPrevious();
        controller.con.getPageNumber();
        TriggerExecutionController.setSkipAllTriggers(false);      
        
    }  
    
    
    static testMethod void testAsssignPermission() {
        TriggerExecutionController.setSkipAllTriggers(true);        
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v3.0
        //Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Submission','Lead',true); v3.0
        Id leadRTId= IdLookupUtils.getRecordTypeId('Direct Lead 2.0','Lead',true);
        List<User> partnerUserList = new List<User>();
        Lead lead = new Lead();    
        
        createTestData();
        
        partnerUserList.add(new User(Username='MyTestUser6' + System.currentTimeMillis() + '@dell.com',
                    Alias = 'MTU5', 
                    Email='MyTestUser6@dell.com', 
                    FirstName='MyTestUser6', 
                    LastName='MyTestUser6',  
                    //ProfileId = partnerProf.Id, 
                    ProfileId = partnerProfiles.get(0).Id, 
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
                    ContactId = newContact.id));  
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
                //4.0 fix test data
                Parent_Vehicle__c='Other',
                Nurture_Source__c='Channel ABU Agency 1',
                Line_Of_Business__c='Desktop',
                Follow_Up_Role__c='Inside Sales Rep',
                IsActive = true,
                Lead_Routing__c = 'Dell Standard',
                EndDate=system.today(),
                Description='Test',
                //4.0 fix test data
                Campaign_Vehicle__c='Other',
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
                OwnerId = OwnerIdString ,
                //OwnerId = QueueId.Queue_Id__c,
                Partner_User__c =  partnerUser,             
                //Partner_User__c =  partnerUserList[0].Id,               
                Ready_for_scoring__c = TRUE,
                Country_Code__c = 'AE',
                LeadSource = 'Employee Referral',//v3.0
                Lead_Type__c = 'Inbound'); //v3.0
            insert leadRecord;
            GroupMember gpMem;
            String strOwner = leadRecord.OwnerId;
            if(strOwner.startsWith('00G')){
                gpMem = new GroupMember(GroupId = leadRecord.OwnerId, UserOrGroupId = marketingUser.Id);
            }
            PageReference pref = new PageReference('/apex/CMAP_ManualAssignment?Id='+leadRecord.Id+'&action=AssignLead');
            Test.setCurrentPage(pref);
            system.debug('###pref-' + pref);
        
            Test.startTest();
            CMAP_ManualAssignmentCntrlr cntrlr = new CMAP_ManualAssignmentCntrlr(new ApexPages.StandardController(leadRecord)); 
            cntrlr.leadObjForUser.OwnerId = partnerUserList[0].Id;  
            cntrlr.profileName =  mrktgProfile.Name;   
            cntrlr.redirect();
            cntrlr.first();
            cntrlr.last();
            cntrlr.previous();
            cntrlr.next();
            cntrlr.cancel();
            cntrlr.getpartnerUserToRole();
            cntrlr.con.getHasNext();
            cntrlr.con.getHasPrevious();
            cntrlr.con.getPageNumber();
            Test.stopTest();
            TriggerExecutionController.setSkipAllTriggers(false);           
    }
    
    
    static testMethod void testReAsssignPermission() { 
        TriggerExecutionController.setSkipAllTriggers(true);        
        Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true); //v3.0
        //Id leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Submission','Lead',true); //v3.0
        Id leadRTId= IdLookupUtils.getRecordTypeId('Direct Lead 2.0','Lead',true); //v3.0
        Id leadAssRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Assignment Complete','Lead',true);
        
        createTestData();
        
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
                //4.0 fix test data
                Parent_Vehicle__c='Other',
                Nurture_Source__c='OEM Nurturing',
                Line_Of_Business__c='Desktop',
                Follow_Up_Role__c='Inside Sales Rep',
                IsActive = true,
                Lead_Routing__c = 'Dell Standard',
                EndDate=system.today(),
                Description='Test',
                //4.0 fix test data
                Campaign_Vehicle__c='Other',
                Campaign_Objective__c='Action',
                Partner_Event_or_Campaign__c = FALSE,
                Allocation_Source__c='Channel ABU Agency 1',
                RecordTypeId = campRTId);
                //RecordTypeId='012A00000012Xt5');
         insert campObj;
        CMAP_Helper.skipinsert = true;
        
        //TriggerExecutionController.setSkipLeadTriggers(true); //v3.0
        
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
                OwnerId = OwnerIdString ,
                //OwnerId = QueueId.Queue_Id__c,
                //Partner_User__c =  partnerUser,             
                Partner_User__c =  partnerUserList[0].Id,               
                Ready_for_scoring__c = TRUE,
                Country_Code__c = 'AE',
                LeadSource = 'Employee Referral',//v3.0
                Lead_Type__c = 'Inbound'); //v3.0
            insert leadRecord;
        
        //TriggerExecutionController.setSkipLeadTriggers(false); //v3.0
        
            leadRecord.Allocation_Queue_GUID__c = leadRecord.OwnerId;
            GroupMember gpMem;
            String strOwner = leadRecord.OwnerId;
            if(strOwner.startsWith('00G')){
                gpMem = new GroupMember(GroupId = leadRecord.OwnerId, UserOrGroupId = partnerUserList[2].Id);
            }
            PageReference pref = new PageReference('/apex/CMAP_ManualAssignment?Id='+leadRecord.Id);
            Test.setCurrentPage(pref);
            Test.startTest();
            CMAP_ManualAssignmentCntrlr cntrlr = new CMAP_ManualAssignmentCntrlr(new ApexPages.StandardController(leadRecord)); 
            cntrlr.profileName =  partnerUserList[2].Name;   
            cntrlr.redirect();
            cntrlr.first();
            cntrlr.last();
            cntrlr.previous();
            cntrlr.next();
            cntrlr.cancel();
            cntrlr.getpartnerUserToRole();
            cntrlr.con.getHasNext();
            cntrlr.con.getHasPrevious();
            cntrlr.con.getPageNumber();
            Test.stopTest();
            TriggerExecutionController.setSkipAllTriggers(false); 
    }
}