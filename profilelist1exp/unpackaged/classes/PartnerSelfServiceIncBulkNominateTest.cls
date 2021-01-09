/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
 /*
* Revision CR Number   Release No      Date            Modified By     Description
* -------- ---------   ----------      -----------     ------------    -----------
* 1.0 -    CR 16018    FY19-DCS-0802    6-June-2018:   Jatin Puri      Decommisioned netexam and Feature_Request_Training__c as part of story# 4988542
*/

@isTest
private class PartnerSelfServiceIncBulkNominateTest {
    static Account partnerAccount = new Account();     
    static User  partnerUser = new User();
    static User  partnerUserAdmin = new User();
    static Contact partnerContact = new COntact();
    static Contact partnerContactAdmin = new COntact();

    static testMethod void testPartnerUserLoggedIn() {
        TriggerExecutionController.setSkipAllTriggers(true);
        createData();  
        Test.startTest();     
        PartnerSelfServiceIncBulkNominateCtrlExt controller;        
        
        // Test user is a partner user but is not admin
        system.runAs(partnerUser){
            controller = new PartnerSelfServiceIncBulkNominateCtrlExt();
            controller.doPageLoad();      
            system.assert(!controller.isPartnerAdmin);   
            system.assert(!controller.isPermittedUser);
            system.assert(controller.hasError);   
        }
        Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false);
    }

    static testMethod void testPartnerAdminLoggedIn() {
        TriggerExecutionController.setSkipAllTriggers(true);
        createData();       
        PartnerSelfServiceIncBulkNominateCtrlExt controller;        
         Test.startTest();
        // Create users for paging test
        List<Contact> cons = new List<Contact>();
        List<User> usrs = new List<User>();
        Contact c = null;
        User u = null;
        Integer totalRecordSize = 55;
        String username = null;
        
        Account objPartnerAccount = new Account();
        objPartnerAccount.name='objPartnerAccount';
        objPartnerAccount.Account_Country_Code__c='AI';
        objPartnerAccount.Account_Country__c = 'ANGUILLA';
        objPartnerAccount.Type = 'Partner';
        insert objPartnerAccount;        
        objPartnerAccount.IsPartner = true;
        objPartnerAccount.RecordTypeId = System.Label.RecType_Partner_Account;                
        update objPartnerAccount;
        
        for(Integer i = 0; i < totalRecordSize; i++){
            c = new Contact(AccountId=objPartnerAccount.Id, Email='John.Doe'+1+'@dell.com', FirstName = 'John', LastName = 'Doe', 
                            MailingStreet='123Main', MailingCity='Peoria', MailingState='IL', MailingPostalCode='33333', Phone='3213213211', 
                            MobilePhone='3213213211', Fax='3213123211', Is_Enabled_for_Incentives__c=true, Title='King');
            cons.add(c);
        }
        insert cons;
        
        for(Integer i = 0; i < cons.size(); i++){
            username = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@test.unit' + string.valueOf(i);
            u = new User(Username = username, Alias = 'test', Email='testuser'+1+'@dell.com', FirstName='John', LastName='Doe', 
                            ProfileId =partnerUserAdmin.ProfileId, LanguageLocaleKey='en_US', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', 
                            TimeZoneSidKey='America/Los_Angeles', Badge_Number__c=null, ContactId=cons[i].id, Enable_Partner_Admin__c =false);
            usrs.add(u);
        }
        insert usrs;
        
        // Test user is a partner admin
        system.runAs(partnerUserAdmin){
            controller = new PartnerSelfServiceIncBulkNominateCtrlExt();
            controller.pageSize = 5;
            controller.doPageLoad();
            system.assert(controller.isPartnerAdmin);   
            system.assert(!controller.isPermittedUser);
            system.assert(!controller.hasError);  
            
            controller.searchFirstNameVal = 'oh';
            controller.searchLastNameVal = 'do';
            controller.searchJobTitleVal = 'in';
            controller.searchStatusVal = Label.Bulk_Nomination_Yes;
            controller.doSearch();
            controller.reset();
            controller.getMyRewardsOptions();
            controller.getRewardRoles();
            controller.getSearchIsEnabled();
            controller.getSearchIsEnabledOptions();
            controller.saveAction();
            controller.goSelfServiceProfilePage();
            controller.goUserDetailsPage();
            Integer totalPageNum = Integer.valueOf(Math.ceil((Double)totalRecordSize/controller.pageSize));
            system.assert(controller.totalPageNumber != totalPageNum);
            
            system.assertEquals(1, controller.pageNumber);
            system.assertEquals(false, controller.hasNext);
            system.assertEquals(false, controller.hasPrevious);
            controller.next();
            //system.assertEquals(2, controller.pageNumber);
            //system.assertEquals(true, controller.hasNext);
            //system.assertEquals(true, controller.hasPrevious);
            controller.first();
            //system.assertEquals(1, controller.pageNumber);
            //system.assertEquals(true, controller.hasNext);
            //system.assertEquals(false, controller.hasPrevious);
            controller.last();
            //system.assertEquals(totalPageNum, controller.pageNumber);
            //system.assertEquals(true, controller.hasNext);
            //system.assertEquals(false, controller.hasPrevious);
            controller.previous();
            //system.assertEquals((totalPageNum - 1), controller.pageNumber);
            //system.assertEquals(true, controller.hasNext);
            //system.assertEquals(false, controller.hasPrevious);
        }        
        Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false);
    }

    static testMethod void testPermittedUserLoggedIn() {
       TriggerExecutionController.setSkipAllTriggers(true);
        createData();       
        List<Id> permittedProfileIds = new List<Id>();
        permittedProfileIds.add('00e30000000nJ6K'); // System Administrator
        permittedProfileIds.add('00e70000000wzqq'); // GBL PRM Operations
        permittedProfileIds.add('00e70000000x0Xj'); // GBL PRM Operations - non SSO
        permittedProfileIds.add('00eA0000000hOpn'); // GBL PRM Certification Admin
        permittedProfileIds.add('00eA0000000hOps'); // GBL PRM Certification Admin - Non SSO
        permittedProfileIds.add('00eA0000000hORl'); // GBL PRM Operations Admin
        permittedProfileIds.add('00eA0000000hORq'); // GBL PRM Operations Admin - Non SSO
          Test.startTest();
        List<User> userRec = new List<User>();
        string username = null;
        for(Integer i = 0; i < permittedProfileIds.size(); i++){    
            username = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@test.unit' + string.valueOf(i);       
            userRec.add(
                new User(Username=username, Alias = 'test'+i, Email='testuser'+i+'@dell.com', FirstName='John', LastName='Doe'+i, 
                            ProfileId =permittedProfileIds[i], LanguageLocaleKey='en_US', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', 
                            TimeZoneSidKey='America/Los_Angeles', Badge_Number__c='John.doe'+i)
            );
        }
        insert userRec;

        PartnerSelfServiceIncBulkNominateCtrlExt controller;        
        // Test user is a permitted user with account id passed in
        for(Integer i = 0; i < permittedProfileIds.size(); i++){
            system.runAs(userRec[i]){
                PageReference pr = new PageReference('apex/PartnerSelfServiceIncentiveBulkNominate');
                Test.setCurrentPage(pr);
                ApexPages.currentPage().getParameters().put('accountId', partnerAccount.Id); 
                controller = new PartnerSelfServiceIncBulkNominateCtrlExt();
                controller.doPageLoad();         
                system.assertEquals(false, controller.isPartnerAdmin);
                system.assertEquals(true, controller.isPermittedUser);
                system.assertEquals(false, controller.hasError);
            }
        }

        // Test user is a permitted user without account id passed in
        for(Integer i = 0; i < permittedProfileIds.size(); i++){
            system.runAs(userRec[i]){
                PageReference pr = new PageReference('apex/PartnerSelfServiceIncentiveBulkNominate');
                Test.setCurrentPage(pr);
                controller = new PartnerSelfServiceIncBulkNominateCtrlExt();
                controller.doPageLoad();         
                system.assertEquals(false, controller.isPartnerAdmin);
                system.assertEquals(false, controller.isPermittedUser);
                system.assertEquals(true, controller.hasError);
            }
        }
        Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    
    static testmethod void testDoNominate_toNominate(){         
        TriggerExecutionController.setSkipAllTriggers(true);
        createData();                
        partnerContact.Is_Enabled_for_Incentives__c = false;
        update partnerContact;
        partnerContactAdmin.Is_Enabled_for_Incentives__c = false;
        update partnerContactAdmin;
        Test.startTest();
        PartnerSelfServiceIncBulkNominateCtrlExt controller = null;
        Partner_Request__c pr = null;       
        system.runAs(partnerUserAdmin){
            controller = new PartnerSelfServiceIncBulkNominateCtrlExt();
            controller.doPageLoad();
            controller.users[0].enabledIncentiveInput = true;
            controller.users[1].enabledIncentiveInput = true;
            //controller.doNomination();
            
        /*    pr = [SELECT Status__c, Is_Enabled_for_Incentives_CF__c, Is_Enabled_for_Incentives__c, Description__c
                           FROM Partner_Request__c WHERE Contact__c = :partnerContact.Id ORDER BY LastModifiedDate DESC LIMIT 1];
            
            system.assertEquals(PartnerConstants.REG_STATUS_DRAFT, pr.Status__c);
            system.assertEquals(true, pr.Is_Enabled_for_Incentives_CF__c);
            system.assertEquals(true, pr.Is_Enabled_for_Incentives__c);
            system.assert(pr.Description__c.contains(controller.prChangeDescription)); */
        } 
                                  Test.stopTest();

        TriggerExecutionController.setSkipAllTriggers(false);
    }
    
     static testmethod void testbackreference(){
        TriggerExecutionController.setSkipAllTriggers(true); 
        createData(); 
        Test.startTest();       
        partnerContact.Is_Enabled_for_Incentives__c = false;
        update partnerContact;
        partnerContactAdmin.Is_Enabled_for_Incentives__c = false;
        update partnerContactAdmin;
        
        PartnerSelfServiceIncBulkNominateCtrlExt controller = null;
        Partner_Request__c pr = null;
        system.runAs(partnerUserAdmin){
            controller = new PartnerSelfServiceIncBulkNominateCtrlExt();
            controller.doPageLoad();
            controller.users[0].enabledIncentiveInput = true;
            controller.users[1].enabledIncentiveInput = true;
            controller.backreference();
                       
            Test.stopTest();                      
        }
         TriggerExecutionController.setSkipAllTriggers(false);
    }
    
    static testmethod void testDoNominate_toTerminate(){
        TriggerExecutionController.setSkipAllTriggers(true);
        createData(); 
        Test.startTest();       
        partnerContact.Is_Enabled_for_Incentives__c = true;
        update partnerContact;
        partnerContactAdmin.Is_Enabled_for_Incentives__c = true;
        update partnerContactAdmin;
        
        PartnerSelfServiceIncBulkNominateCtrlExt controller = null;
        Partner_Request__c pr = null;
        system.runAs(partnerUserAdmin){
            controller = new PartnerSelfServiceIncBulkNominateCtrlExt();
            controller.doPageLoad();
            controller.users[0].enabledIncentiveInput = false;
            controller.users[1].enabledIncentiveInput = false;
          //  controller.doNomination();
            
        /*    pr = [SELECT Status__c, Is_Enabled_for_Incentives_CF__c, Is_Enabled_for_Incentives__c, Description__c
                    FROM Partner_Request__c WHERE Contact__c = :partnerContact.Id ORDER BY LastModifiedDate DESC LIMIT 1];
            //Test.stopTest();
            
            system.assertEquals(PartnerConstants.REG_STATUS_DRAFT, pr.Status__c);
            system.assertEquals(true, pr.Is_Enabled_for_Incentives_CF__c);
            system.assertEquals(false, pr.Is_Enabled_for_Incentives__c);
            system.assert(pr.Description__c.contains(controller.prChangeDescription)); */
        }
         Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    
      public static void createData(){
     
        profile profileRec = [select id from profile where name like '%PRM Portal%' Limit 1]; 
        //profile profileRec = [select id from profile where id='00e70000000wzqq'];
        UserRole  userRoleRec=[Select  PortalAccountId,Name,Id From UserRole  where  name like '%WW_Exec' Limit 1];
        Profile SysAdminProfile=[select id,name from Profile where name='System Administrator' limit 1];
        
        //Creating Partner Account   
        partnerAccount.name='PartnerAccount';
        partnerAccount.Account_Country_Code__c='AI';
        partnerAccount.Account_Country__c = 'ANGUILLA';
        partnerAccount.Type = 'Partner'; 
        insert partnerAccount;
        partnerAccount.IsPartner = true;
        partnerAccount.RecordTypeId = System.Label.RecType_Partner_Account;                
        update partnerAccount;
        
        List<Contact> conList = new List<Contact>();
        
        //Creating Partner Contact
        partnerContact.AccountId=partnerAccount.id;
        partnerContact.Email='John.Doe@dell.com';
        partnerContact.FirstName = 'John';
        partnerContact.LastName = 'Doe';
        partnerContact.Title='VP';
        
        partnerContact.MailingStreet='123Main';
        partnerContact.MailingCity='Peoria';
        partnerContact.MailingState='IL';
        partnerContact.MailingPostalCode='33333';
        
        partnerContact.Phone='3213213211';
        partnerContact.MobilePhone='3213213211';
        partnerContact.Fax='3213123211' ;
        partnerContact.Is_Enabled_for_Incentives__c=true;
        //partnerContact.IsActive=true;        
        //insert partnerContact; 
        conList.add(partnerContact);
         
        //Creating Partner Contact
        partnerContactAdmin.AccountId=partnerAccount.id;
        partnerContactAdmin.Email='John.Doe@dell.com';
        partnerContactAdmin.FirstName = 'John';
        partnerContactAdmin.LastName = 'Doe';
        partnerContactAdmin.Title='VP';
        
        partnerContactAdmin.MailingStreet='123Main';
        partnerContactAdmin.MailingCity='Peoria';
        partnerContactAdmin.MailingState='IL';
        partnerContactAdmin.MailingPostalCode='33333';
        
        partnerContactAdmin.Phone='3213213211';
        partnerContactAdmin.MobilePhone='3213213211';
        partnerContactAdmin.Fax='3213123211' ;
        partnerContactAdmin.Is_Enabled_for_Incentives__c=true;
        //partnerContact.IsActive=true;        
        //insert partnerContactAdmin;    
        conList.add(partnerContactAdmin);  
        //Creating Partner User
        insert conList;
        
        List<User> userList = new List<User>();
        String username = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@test.unit.user';
        partnerUser.Username=username;
        partnerUser.Alias = 'test';
        partnerUser.Email='testuser@dell.com';
        partnerUser.FirstName='John'; 
        partnerUser.LastName='Doe'; 
        partnerUser.ProfileId =profileRec.Id; 
        partnerUser.LanguageLocaleKey='en_US'; 
        partnerUser.LocaleSidKey='en_US';
        partnerUser.EmailEncodingKey='UTF-8';
        partnerUser.TimeZoneSidKey='America/Los_Angeles';
        partnerUser.Badge_Number__c=null;
        partnerUser.ContactId=partnerContact.id;
        partnerUser.Enable_Partner_Admin__c =false;
        //insert partnerUser; 
        userList.add(partnerUser);
        
        username = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@test.unit.admin';
        partnerUserAdmin.Username=username;
        partnerUserAdmin.Alias = 'test';
        partnerUserAdmin.Email='testuser@test.com';
        partnerUserAdmin.FirstName='John'; 
        partnerUserAdmin.LastName='Doe'; 
        partnerUserAdmin.ProfileId =profileRec.Id; 
        partnerUserAdmin.LanguageLocaleKey='en_US'; 
        partnerUserAdmin.LocaleSidKey='en_US';
        partnerUserAdmin.EmailEncodingKey='UTF-8';
        partnerUserAdmin.TimeZoneSidKey='America/Los_Angeles';
        partnerUserAdmin.Badge_Number__c=null;
        partnerUserAdmin.ContactId=partnerContactAdmin.id;
        partnerUserAdmin.Enable_Partner_Admin__c =true;
        //insert partnerUserAdmin;
        userList.add(partnerUserAdmin);
        
        insert userList;
    }
    
}