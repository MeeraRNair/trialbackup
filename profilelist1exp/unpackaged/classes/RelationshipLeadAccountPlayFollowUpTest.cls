/***********************************************************
* Name          : RelationshipLeadAccountPlayFollowUpTest
* Description   : Relationship Lead / Account Play Follow-Up functionality Test Class
* ---------------------------------------------------------
* Revision  Name    Date        Release Description
* 1.0       MenMee  17.09.2009          Test class for RelationshipLeadAccountPlayFollowUp
* 1.1       MenMee  05.10.2009          Change object and field API name 
* 1.2       MenMee  06.10.2009          Remove Account Executive field from Account Play Object
* 1.3       Hanan   10.11.2009          Added test case for the requirement ??if CM status is not 'Require Follow-Up'  
*                                       RL record need not be created?? in beforeinsert trigger on RL
* 1.4       MenMee  10.11.2009          DF53194 Update test method accordingly
*                                       Only allow to create RL for CM with Status='Requires Follow-Up',
* 1.5       Meera   10.12.2009          Updated as part of CR 2234 Task Creation
* 1.6       MenMee  30.12.2009          CR 2279 Skip creating new RL when new CM get inserted during run tests
* 1.7       Meera   31.12.2009          Updated as part of CR 2043 Update Logic for Auto Email Notifications 
*                                       sent to Sales for Campaign Members Requiring Follow-up
* 1.8       MenMee  12.02.2010          CR 2400 Test Methods  
* 1.9       MenMee  21.04.2010  11.3    Defect 57776: CR 2371 Ability to differentiate/identify AP/RL records that had Account
*                                       add new isTriggerFireBefore flag to avoid trigger fire twice that caused by a "RL - Update Rel. Lead Close Date" workflow
* 2.0       MenMee  16.06.2010  11.7    CR 2728 Add AE to Account Play record
* 2.1       Azwanti 24.09.2010  11.7    CR 4126 Deselect System Auto-Populated? checkboxes on Relationship Lead/Account Plays when any of the follow-up roles changes
* 3.0       MenMee  15.12.2010  12.1    CR 2538 Create Follow-Up task for Awaiting FU/Future FU and FU Date > Today and AP/RL Owner field != null
* 4.0       MenMee  09.08.2011  12.10   CR 6505, 6507 Populate value to RL  
* 5.0       MenMee  06.06.2013  14.5    CR 8189 Enhance Campaign Vehicle CASE formula to simple formula
* 6.0       Impana  20.07.2014  15.07   CR 9533 Geo Process - RL/AP Asignment
* 7.0       Shue    02.04.2015  16.03   CR 10608 RL/AP Owner assignment takes ATM with Secondary Role from Campaign if no ATM with Follow Up Role exist
* 8.0       Shue    02.05.2015  16.03   CR 10607 To check FUR & SR picklist to have the same amount and values
* 9.0       Anamika 02.24.2015  16.03   CR 10743 To check if deal id of deal reg oppty is getting populated in deal id on RL
************************************************************/

@isTest
private class RelationshipLeadAccountPlayFollowUpTest {
    
    static Account testAcc;
    static Account testPartnerAcc;
    static Campaign testCampaign;
    static Campaign testCampaign1;
    static Campaign testCampaign2;
    static AccountTeamMember testISR;
    static AccountTeamMember testISM;
    static AccountTeamMember testAE;
    static AccountTeamMember testPDM;
    static List<User> testUserList = new List<User>();
    static List<CampaignMember> testCMList = new List<CampaignMember>();
    static List<Contact> testContactList = new List<Contact>();
    static Map<String, String> sParam = new Map<String, String>();
    
    static List<Lead> leadList=new List<Lead>();
    static List<Campaign> campaignList=new List<Campaign>();
    static List<CampaignMember> campaignMemberList=new List<CampaignMember>();  
    static List<Relationship_Lead__c> relationshipLeadList=new List<Relationship_Lead__c>();  
    static Set<String> CMIdSet=new Set<String>();    
    static Account accnt;
    static Contact contactObj;
    static Campaign campaignObj;
    static Lead leadObj1;
    static CampaignMember campaignMemberObj1;
    static Relationship_Lead__c relationShipLeadObj; 
    static Map<string,Relationship_Lead__c> mapRelationshipLead=new Map<string,Relationship_Lead__c>();
    static Map<String,Relationship_Lead__c> RLMap=new Map<String,Relationship_Lead__c>();
    static Id PartnerAcc;
    
    static Role__c CCCrole;
    static Geography__c CCCgeo;
    static Geography__c CCCstate;
    static Geography__c CCCzipcode;
    static Territory__c CCCterritory;  
    
    /* ----------------------------------- TEST METHODS FOR RELATIONSHIP LEAD --------------------------------------------------- */
    
    // Test Condition:
    // Multiple Relationship Lead with different account and campaign
    // Campaign Follow-up Role = ISR, ISR will be defaulted to Owner
    
 /*  static testMethod void populateOwnerAndSpecifiedRoleField_RLNormalFlow() {
        System.debug('***************** START populateOwnerAndSpecifiedRoleField_RLNormalFlow *****************');
               
        
        
        TriggerExecutionController.setSkipAllTriggers(true);       
        List<Relationship_Lead__c> testRelationshipLeadList = new List<Relationship_Lead__c>();
        TriggerExecutionController.setSkipAllTriggers(false);
        Test.starttest();
        TestDataCreation(false);        
                
        String testISR1 = testISR.UserId;       
        String testAE1 = testAE.UserId;
        
        Relationship_Lead__c relationshipLead1 = new Relationship_Lead__c(Contact__c = testContactList[0].Id, Campaign__c = testCampaign.Id,
                                                        CM_Source__c = testCMList[0].Id, Status__c = 'Requires Follow-Up');     
        testRelationshipLeadList.add(relationshipLead1);   
        
        /*Relationship_Lead__c relationshipLead2 = new Relationship_Lead__c(Contact__c = testContactList[1].Id, Campaign__c = testCampaign.Id,
                                                        CM_Source__c = testCMList[1].Id, Status__c = 'Requires Follow-Up');      
        testRelationshipLeadList.add(relationshipLead2);   

        TestDataCreation(false);
        
        String testISR3 = testISR.UserId;
        String testAE3 = testAE.UserId;
        
        Relationship_Lead__c relationshipLead3 = new Relationship_Lead__c(Contact__c = testContactList[0].Id, Campaign__c = testCampaign.Id,
                                                         CM_Source__c = testCMList[0].Id, Status__c = 'Requires Follow-Up');
        testRelationshipLeadList.add(relationshipLead3);
        
        List<Relationship_Lead__c> actualRelationshipLeadList = [SELECT Relationship_Lead_Owner__c, Inside_Sales_Rep__c, Account_Executive__c,
                                            System_Auto_Populated_RL_Owner__c, System_Auto_Populated_ISR__c, System_Auto_Populated_AE__c,   //Rev 1.9
                                            Next_Steps__c, Supporting_Information__c, Eloqua_Id__c  //Rev 4.0
                                            FROM Relationship_Lead__c
                                            WHERE ID IN (:relationshipLead1.Id, :relationshipLead2.Id, :relationshipLead3.Id)
                                            Order by Id];*/
      /*  insert testRelationshipLeadList;
             
        List<Relationship_Lead__c> actualRelationshipLeadList = [SELECT Relationship_Lead_Owner__c, Inside_Sales_Rep__c, Account_Executive__c,
                                            System_Auto_Populated_RL_Owner__c, System_Auto_Populated_ISR__c, System_Auto_Populated_AE__c,   //Rev 1.9
                                            Next_Steps__c, Supporting_Information__c, Eloqua_Id__c  //Rev 4.0
                                            FROM Relationship_Lead__c
                                            WHERE ID =: relationshipLead1.Id];
        
        Test.stopTest();        
        System.assertEquals(testISR1, actualRelationshipLeadList[0].Relationship_Lead_Owner__c );
        System.assertEquals(testISR1, actualRelationshipLeadList[0].Inside_Sales_Rep__c);       
        System.assertEquals(testAE1, actualRelationshipLeadList[0].Account_Executive__c);
        System.assertEquals(true, actualRelationshipLeadList[0].System_Auto_Populated_RL_Owner__c); //Rev 1.9
        System.assertEquals(true, actualRelationshipLeadList[0].System_Auto_Populated_ISR__c);      //Rev 1.9
        System.assertEquals(true, actualRelationshipLeadList[0].System_Auto_Populated_AE__c);       //Rev 1.9
        System.assertEquals(testCampaign.Next_Steps__c, actualRelationshipLeadList[0].Next_Steps__c); //Rev 4.0
        System.assertEquals(testCampaign.Supporting_Information__c, actualRelationshipLeadList[0].Supporting_Information__c); //Rev 4.0
        
        /*System.assertEquals(testISR1, actualRelationshipLeadList[1].Relationship_Lead_Owner__c );
        System.assertEquals(testISR1, actualRelationshipLeadList[1].Inside_Sales_Rep__c);       
        System.assertEquals(testAE1, actualRelationshipLeadList[1].Account_Executive__c);
                
        System.assertEquals(testISR3, actualRelationshipLeadList[2].Relationship_Lead_Owner__c );
        System.assertEquals(testISR3, actualRelationshipLeadList[2].Inside_Sales_Rep__c);       
        System.assertEquals(testAE3, actualRelationshipLeadList[2].Account_Executive__c);*/
                
        /*System.debug('***************** END populateOwnerAndSpecifiedRoleField_RLNormalFlow *****************');
    }*/
    
        // Test : Geo process assignment
    /*static testmethod void populateOwnerAndSpecifiedRoleField_GeoProcessFlowRL() {
        system.debug('*************** GEO PROCESS ASSIGNMENT ************************');
        
        TriggerExecutionController.setSkipAllTriggers(true);
        
        RecordType CountryRT = [select ID from RecordType where name =: 'Country' LIMIT 1];
        RecordType StateRT = [select ID from RecordType where name =: 'State' LIMIT 1];
        RecordType ZipcodeRT = [select ID from RecordType where name =: 'Zipcode' LIMIT 1];
        
        TestDataCreation(false);
        
       /* testAcc.Account_Country__c = 'CCCGeo';
        testAcc.Shippingpostalcode = 'testcode';
        testAcc.ShippingState = 'CCCstate';
        update testAcc;*/
        
     /*   Profile profile = [select id from profile where name = 'System Administrator' limit 1];
        User testUser = new User(Username='Test'+ System.currentTimeMillis() +'@dell.com',
                                        Alias = 'Test', 
                                        Email='Test'+System.currentTimeMillis()+'@dell.com',            
                                        LastName='Test', 
                                        ProfileId = profile.Id, 
                                        LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', 
                                        EmailEncodingKey='UTF-8', 
                                        TimeZoneSidKey='America/Los_Angeles',
                                        IsActive=true,
                                        Badge_Number__c='Test'+System.currentTimeMillis());
        insert testUser;
        
        testcampaign1 = new Campaign(Type='eSeminar/Webcast/Webinar', EndDate= System.today()+90, 
                                                    IsActive=true, Description='Test Campaign', StartDate=date.newInstance(2009, 12, 1), 
                                                    Name='Test Campaign1', Follow_Up_Role__c = 'CCCrole');
        insert testCampaign1;
        
        CCCterritory = new territory__c(name='CCCterritory' , group__c='Cloud Client Computing' , Geography_type__c = 'Country',Is_active__c =true);
        Insert CCCterritory;
        
        CCCgeo = new Geography__c(name='CCCgeo', RecordTypeId = CountryRT.Id);
        insert CCCgeo;
        
        CCCstate = new Geography__c(name = 'CCCstate', RecordTypeId = stateRT.Id , Country__c = CCCgeo.Id);
        insert CCCstate;
        
        CCCzipcode = new Geography__c(name = 'CCCzipcode', RecordTypeId = ZipcodeRT.Id , Country__c = CCCgeo.Id, state__c = CCCstate.Id);
        insert CCCzipcode;
        
        CCCrole = new Role__c(name='CCCrole', group__c = 'Cloud client Computing', Is_active__c =true);
        insert CCCrole;
        
        Territory_Geo_Assignment__c testTGA = new Territory_Geo_Assignment__c(Territory__c = CCCterritory.Id , Geography__c = CCCgeo.Id);
        insert testTGA;
        
        Territory_Sales_User_Assignment__c testTSUA = new Territory_Sales_User_Assignment__c(Territory__c = CCCterritory.Id,Group__c='Cloud Client Computing' , Role__c = CCCrole.Id, User__c = testUser.Id, Is_Active__c = true);
        insert testTSUA;
        
        Relationship_Lead__c GeoRL = new Relationship_Lead__c(Contact__c = testContactList[0].Id, Campaign__c = testCampaign1.Id,
                                                        CM_Source__c = testCMList[0].Id, Status__c = 'Requires Follow-Up');     
        
        TriggerExecutionController.setSkipAllTriggers(true);
        
        Test.starttest();
        insert GeoRL;                                                
        test.Stoptest();
        
        Relationship_Lead__c RLtest = [SELECT Relationship_Lead_Owner__c, Inside_Sales_Rep__c, Account_Executive__c,
                                            System_Auto_Populated_RL_Owner__c, System_Auto_Populated_ISR__c, System_Auto_Populated_AE__c,
                                            Geo_populated__c
                                            FROM Relationship_Lead__c where ID =: GeoRL.Id LIMIT 1];
                                            
        System.assertequals(testUser.Id , RLtest.Relationship_Lead_Owner__c);
        System.assertequals(RLtest.Geo_populated__c , true);
        System.assertEquals(true, RLtest.System_Auto_Populated_RL_Owner__c);
    
    
    }*/
    
    // Test condition:
    // Campaign Follow-up Role = ISR, No User associated with ISR. AE will be defaulted to Owner
    /*static testMethod void populateOwnerAndSpecifiedRoleField_NoUserAssociateWithFollowUpRole() {
        System.debug('***************** START populateOwnerAndSpecifiedRoleField_RLNoUserAssociateWithFollowUpRole *****************');
         
        TestDataCreation(false);    
        
        // Remove User with Follow-up Role
        delete testISR;
        
        Relationship_Lead__c testRelationshipLead = new Relationship_Lead__c(Contact__c = testContactList[0].Id, Campaign__c = testCampaign.Id,
                                                        CM_Source__c = testCMList[0].Id, Status__c = 'Requires Follow-Up');
                
        Test.StartTest();       
        insert testRelationshipLead;        
        Test.StopTest();
        
        Relationship_Lead__c actualRelationshipLead = [SELECT Relationship_Lead_Owner__c, Inside_Sales_Rep__c, Account_Executive__c
                                            FROM Relationship_Lead__c
                                            WHERE ID = :testRelationshipLead.Id];

        // Default AE to Owner field
        System.assertEquals(testAE.UserId, actualRelationshipLead.Relationship_Lead_Owner__c );
        System.assertEquals(null, actualRelationshipLead.Inside_Sales_Rep__c);      
        System.assertEquals(testAE.UserId, actualRelationshipLead.Account_Executive__c);        
        
        System.debug('***************** END populateOwnerAndSpecifiedRoleField_RLNoUserAssociateWithFollowUpRole *****************');  
    }*/
    
    // Test condition: 
    // Test the exception in trigger 
    /*static testMethod void populateOwnerAndSpecifiedRoleField_RLTriggerExceptionTest() {
        System.debug('***************** START populateOwnerAndSpecifiedRoleField_RLTriggerExceptionTest *****************');

        
        TriggerExecutionController.setSkipAllTriggers(true);
        TestDataCreation(false);      
          Account testAccount1 = new Account(Name='Test Account1',Type='OEM');  //9.0 -start
          insert   testAccount1;  
        Opportunity testOppty1 = new Opportunity(Name='Test Oppty1',AccountId=testAccount1.Id,StageName='90% - Commit',CloseDate=System.Today()+20);
        insert testOppty1;   //9.0 - end
        Relationship_Lead__c testRelationshipLead = new Relationship_Lead__c(Deal_Reg_Opportunity_Name__c= testOppty1.Id, contact__c = testContactList[0].Id, Campaign__c = testCampaign.Id,
                                                            CM_Source__c = testCMList[0].Id, Status__c = 'Requires Follow-Up');
                
                // 9.0 - added Deal_Reg_Opportunity_Name__c= testOppty1.Id
                
        RelationshipLeadAccountPlayFollowUp.isBeforeException = true;
         
        TriggerExecutionController.setSkipAllTriggers(false); 
        Test.StartTest();       
        insert testRelationshipLead;
        // 9.0 start
        Opportunity testOppty2 = new Opportunity(Name='Test Oppty2',AccountId=testAccount1.Id,StageName='90% - Commit',CloseDate=System.Today()+20);
                insert testOppty2;
                
                testRelationshipLead.Deal_Reg_Opportunity_Name__c= testOppty2.Id;     
                update testRelationshipLead;
                //9.0 - end
        Test.StopTest();        
        
        Relationship_Lead__c actualRelationshipLead = [SELECT Relationship_Lead_Owner__c, Inside_Sales_Rep__c, Account_Executive__c
                                            FROM Relationship_Lead__c
                                            WHERE ID = :testRelationshipLead.Id];
                                            
        System.assertEquals(null, actualRelationshipLead.Relationship_Lead_Owner__c );
        System.assertEquals(null, actualRelationshipLead.Inside_Sales_Rep__c);          
        System.assertEquals(null, actualRelationshipLead.Account_Executive__c);
        
        System.debug('***************** END populateOwnerAndSpecifiedRoleField_RLTriggerExceptionTest *****************');
    }*/
    

    // Test condition:
    // Insert a Bad Contact Info RL. Task is created to ISR.
    /*static testMethod void assignRejectionTaskToISR_RLNormalFlow() {
        System.debug('***************** START assignRejectionTaskToISR_RLNormalFlow *****************');
        
        TestDataCreation(false);        
        
        Relationship_Lead__c testRelationshipLead = new Relationship_Lead__c(Contact__c = testContactList[0].Id, Campaign__c = testCampaign.Id, 
                                                            CM_Source__c = testCMList[0].Id, Status__c = 'Requires Follow-Up');
        insert testRelationshipLead;
           
        testRelationshipLead = new Relationship_Lead__c(Id = testRelationshipLead.Id);                                                          
        testRelationshipLead.Accept_Reject_Status__c = 'Rejected By Sales';
        testRelationshipLead.Rejection_Reason__c = 'Bad Contact Info';
        testRelationshipLead.Status__c = 'Rejected - Completed Follow-Up';
        
        Test.startTest();
        update testRelationshipLead;
        Test.stopTest();
        
        System.assertEquals(1, [SELECT COUNT() FROM Task WHERE WhatId = :testRelationshipLead.Id]);
        
        System.debug('***************** END assignRejectionTaskToISR_RLNormalFlow *****************');
    }*/
    
    // Test condition:
    // Insert a Bad Contact Info RL. No ISR associated with RL. No Task is created.
  /*  static testMethod void assignRejectionTaskToISR_RLNoTaskCreated() {
        System.debug('***************** START assignRejectionTaskToISR_RLNoTaskCreated *****************');
        
        TestDataCreation(false);        
        delete testISR;
        
        Relationship_Lead__c testRelationshipLead = new Relationship_Lead__c(Contact__c = testContactList[0].Id, Campaign__c = testCampaign.Id, 
                                                            CM_Source__c = testCMList[0].Id, Status__c = 'Requires Follow-Up');
        insert testRelationshipLead;
           
        testRelationshipLead = new Relationship_Lead__c(Id = testRelationshipLead.Id);     
        testRelationshipLead.Accept_Reject_Status__c = 'Rejected By Sales';
        testRelationshipLead.Rejection_Reason__c = 'Bad Contact Info';
        testRelationshipLead.Status__c = 'Rejected - Completed Follow-Up';
        
        Test.startTest();
        update testRelationshipLead;
        Test.stopTest();
        
        System.assertEquals(0, [SELECT COUNT() FROM Task WHERE WhatId = :testRelationshipLead.Id]);
        
        System.debug('***************** END assignRejectionTaskToISR_RLNoTaskCreated *****************');
    }*/
    
    // Test condition:
    // Test the exception
    /*static testMethod void assignRejectionTaskToISR_RLTriggerExceptionTest() {
        System.debug('***************** START assignRejectionTaskToISR_RLTriggerExceptionTest *****************');
        
        TestDataCreation(false);        
        
        RelationshipLeadAccountPlayFollowUp.isAfterException = true;
        
        Relationship_Lead__c testRelationshipLead = new Relationship_Lead__c(Contact__c = testContactList[0].Id, Campaign__c = testCampaign.Id, 
                                                        CM_Source__c = testCMList[0].Id, Status__c = 'Requires Follow-Up');
        insert testRelationshipLead;
           
        testRelationshipLead = new Relationship_Lead__c(Id = testRelationshipLead.Id);     
        testRelationshipLead.Accept_Reject_Status__c = 'Rejected By Sales';
        testRelationshipLead.Rejection_Reason__c = 'Bad Contact Info';
        testRelationshipLead.Status__c = 'Rejected - Completed Follow-Up';
        
        Test.startTest();
        update testRelationshipLead;
        Test.stopTest();
        
        System.assertEquals(0, [SELECT COUNT() FROM Task WHERE WhatId = :testRelationshipLead.Id]);
        
        System.debug('***************** END assignRejectionTaskToISR_RLTriggerExceptionTest *****************');
    }
      
    /* ----------------------------------- TEST METHODS FOR ACCOUNT PLAY --------------------------------------------------- */
    
    // Test Condition:
    // Update a No Contact Info AP. Task is created to ISR.
   /* static testMethod void assignRejectionTaskToISR_APNormalFlow() {
        System.debug('***************** START assignRejectionTaskToISR_APNormalFlow *****************');
        
        TestDataCreation(true);
        
        Account_Play__c testAccountPlay = new Account_Play__c(Account__c = testAcc.Id, Campaign__c = testCampaign.Id ,Campaign_Vehicle__c = testCampaign.Type);        
        testAccountPlay.Accept_Reject_Status__c = 'Rejected By Sales';
        testAccountPlay.Rejection_Reason__c = 'No Contact Info';
        testAccountPlay.Status__c = 'Rejected - Completed Follow-Up';
    
        Test.startTest();
        insert testAccountPlay;
        Test.stopTest();
        
        List<Task> taskList = [select id,whatid,OwnerId from Task where WhatId = :testAccountPlay.Id];
        System.debug('###taskList'+taskList);
        System.assertEquals(1, [SELECT COUNT() FROM Task WHERE WhatId = :testAccountPlay.Id]);
        
        System.debug('***************** END assignRejectionTaskToISR_APNormalFlow *****************');
    }   */
    
    // Test condition:
    // Campaign Follow-up Role = ISR, No User associated with ISR. Owner field is blank
    /*static testMethod void populateOwnerAndSpecifiedRoleField_APNoUserAssociateWithFollowUpRole() {
        System.debug('***************** START populateOwnerAndSpecifiedRoleField_APNoUserAssociateWithFollowUpRole *****************');
         
        TestDataCreation(true);     
        
        // Remove User with Follow-up Role
        delete testISR;
                
        Account_Play__c testAccountPlay = new Account_Play__c(Account__c = testAcc.Id, Campaign__c = testCampaign.Id ,Campaign_Vehicle__c = testCampaign.Type);
                
        Test.StartTest();       
        insert testAccountPlay;         
        Test.StopTest();
        
        // Rev 1.2
        //Account_Play__c actualAccountPlay = [SELECT Account_Play_Owner__c, Inside_Sales_Rep__c, Account_Executive_del__c
        //                                  FROM Account_Play__c
        //                                  WHERE ID = :testAccountPlay.Id];
        // Rev 2.0
        Account_Play__c actualAccountPlay = [SELECT Account_Play_Owner__c, Inside_Sales_Rep__c, Account_Executive__c,
                                            System_Auto_Populated_AP_Owner__c, System_Auto_Populated_ISR__c, System_Auto_Populated_AE__c 
                                            FROM Account_Play__c
                                            WHERE ID = :testAccountPlay.Id];                                            

        // Default AE to Owner field
        System.assertEquals(testAE.UserId, actualAccountPlay.Account_Play_Owner__c );       
        System.assertEquals(null, actualAccountPlay.Inside_Sales_Rep__c);       
        System.assertEquals(testAE.UserId, actualAccountPlay.Account_Executive__c);     //Rev 2.0   //Rev 1.2 
        System.assertEquals(true, actualAccountPlay.System_Auto_Populated_AP_Owner__c); //Rev 1.9
        System.assertEquals(true, actualAccountPlay.System_Auto_Populated_ISR__c);      //Rev 1.9
        System.assertEquals(true, actualAccountPlay.System_Auto_Populated_AE__c);       //Rev 2.0
        
        System.debug('***************** END populateOwnerAndSpecifiedRoleField_APNoUserAssociateWithFollowUpRole *****************');  
    }*/
    
     // Test : Geo process assignment
  /*  static testmethod void populateOwnerAndSpecifiedRoleField_GeoProcessFlowAP() {
        system.debug('*************** GEO PROCESS ASSIGNMENT ************************');
        
        RecordType CountryRT = [select ID from RecordType where name =: 'Country' LIMIT 1];
    
        TestDataCreation(false);
       
       
        Profile profile = [select id from profile where name = 'System Administrator' limit 1];
        User testUser = new User(Username='Test'+ System.currentTimeMillis() +'@dell.com',
                                        Alias = 'Test', 
                                        Email='Test'+System.currentTimeMillis()+'@dell.com',            
                                        LastName='Test', 
                                        ProfileId = profile.Id, 
                                        LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', 
                                        EmailEncodingKey='UTF-8', 
                                        TimeZoneSidKey='America/Los_Angeles',
                                        IsActive=true,
                                        Badge_Number__c='Test'+System.currentTimeMillis());
        insert testUser;
        
        CCCterritory = new territory__c(name='CCCterritory' , group__c='Cloud Client Computing' , Geography_type__c = 'Country',Is_active__c =true);
        Insert CCCterritory;
        
        CCCgeo = new Geography__c(name='CCCgeo', RecordTypeId = CountryRT.Id);
        insert CCCgeo;
        
        CCCrole = new Role__c(name='CCCrole', group__c = 'Cloud client Computing', Is_active__c =true);
        insert CCCrole;
        
        Territory_Geo_Assignment__c testTGA = new Territory_Geo_Assignment__c(Territory__c = CCCterritory.Id , Geography__c = CCCgeo.Id);
        insert testTGA;
        
        Territory_Sales_User_Assignment__c testTSUA = new Territory_Sales_User_Assignment__c(Territory__c = CCCterritory.Id,Group__c='Cloud Client Computing' , Role__c = CCCrole.Id, User__c = testUser.Id, Is_Active__c = true);
        insert testTSUA;
        
        testcampaign2 = new Campaign(Type='eSeminar/Webcast/Webinar', EndDate= System.today()+90, 
                                                    IsActive=true, Description='Test Campaign', StartDate=date.newInstance(2009, 12, 1), 
                                                    Name='Test Campaign2', Follow_Up_Role__c = 'CCCrole',Is_this_Account_Play_Campaign__c = true, 
                                                    Account_Play_Expiry_Date__c=System.today()+20);
        insert testCampaign2;
        
        Account_Play__c testAccountPlayGeo = new Account_Play__c(Account__c = testAcc.Id, Campaign__c = testCampaign2.Id );
        
        Test.starttest();
        insert testAccountPlayGeo;                                                
        test.Stoptest();
        
        Account_Play__c APtest = [SELECT Account_Play_Owner__c, Inside_Sales_Rep__c, Account_Executive__c,
                                            System_Auto_Populated_AP_Owner__c, System_Auto_Populated_ISR__c, System_Auto_Populated_AE__c,Geo_populated__c
                                            FROM Account_Play__c where ID =: testAccountPlayGeo.Id LIMIT 1];
                                            
        System.assertequals(testUser.Id , APtest.Account_Play_Owner__c);
        System.assertequals(APtest.Geo_populated__c , true);
        System.assertEquals(true, APtest.System_Auto_Populated_AP_Owner__c);
    
    
    }*/
    
    // Test condition: 
    // Test the exception in trigger 
   /* static testMethod void populateOwnerAndSpecifiedRoleField_APTriggerExceptionTest() {
        System.debug('***************** START populateOwnerAndSpecifiedRoleField_APTriggerExceptionTest *****************');
        
        List<Account_Play__c> testAccountPlayList = new List<Account_Play__c>(); 
         
        TestDataCreation(true);             
        Account_Play__c testAccountPlay1 = new Account_Play__c(Account__c = testAcc.Id, Campaign__c = testCampaign.Id ,Campaign_Vehicle__c = testCampaign.Type);
        testAccountPlayList.add(testAccountPlay1);
        Account_Play__c testAccountPlay2 = new Account_Play__c(Account__c = testAcc.Id, Campaign__c = testCampaign.Id ,Campaign_Vehicle__c = testCampaign.Type);
        testAccountPlayList.add(testAccountPlay2);
        
        RelationshipLeadAccountPlayFollowUp.isBeforeException = true;
        
        Test.StartTest();       
        insert testAccountPlayList;      
        Test.StopTest();        
         
        // Rev 1.2
        //List<Account_Play__c> actualAccountPlayList = [SELECT Account_Play_Owner__c, Inside_Sales_Rep__c, Account_Executive_del__c
        //                                  FROM Account_Play__c
        //                                  WHERE ID IN (:testAccountPlay1.Id, :testAccountPlay2.Id)];
        List<Account_Play__c> actualAccountPlayList = [SELECT Account_Play_Owner__c, Inside_Sales_Rep__c
                                            FROM Account_Play__c
                                            WHERE ID IN (:testAccountPlay1.Id, :testAccountPlay2.Id)];
                                                                                
        System.assertEquals(null, actualAccountPlayList[0].Account_Play_Owner__c );
        System.assertEquals(null, actualAccountPlayList[0].Inside_Sales_Rep__c);        
        // Rev 1.2 System.assertEquals(null, actualAccountPlayList[1].Account_Executive_del__c);
        
        System.debug('***************** END populateOwnerAndSpecifiedRoleField_APTriggerExceptionTest *****************');
    }  */  
 
    // Test condition:
    // Test the exception
    /*static testMethod void assignRejectionTaskToISR_APTriggerExceptionTest() {
        System.debug('***************** START assignRejectionTaskToISR_APTriggerExceptionTest *****************');
        
        TestDataCreation(true);
        
        RelationshipLeadAccountPlayFollowUp.isAfterException = true;
        
        Account_Play__c testAccountPlay = new Account_Play__c(Account__c = testAcc.Id, Campaign__c = testCampaign.Id ,Campaign_Vehicle__c = testCampaign.Type);
        testAccountPlay.Accept_Reject_Status__c = 'Rejected By Sales';
        testAccountPlay.Rejection_Reason__c = 'No Contact Info';
        testAccountPlay.Status__c = 'Rejected - Completed Follow-Up';
        
        Test.startTest();
        insert testAccountPlay;
        Test.stopTest();
        
        System.assertEquals(0, [SELECT COUNT() FROM Task WHERE WhatId = :testAccountPlay.Id]);
        
        System.debug('***************** END assignRejectionTaskToISR_APTriggerExceptionTest *****************');
    }*/
    
    /*static testMethod void testRelationShipLeadInsert(){

        System.debug('***************** START testRelationShipLeadInsert *****************');
        
        Test.startTest();
         
        accnt=new Account(Name='Test Account',Phone='9991110001');
        insert accnt;

        contactObj=new Contact(LastName='Contact',AccountId=accnt.id,
        Status__c='Active',
        EMEA_Decision_Making_Role__c='Decision Maker',
        Decision_Making_Role__c='Power Sponsor / Decision Maker',
        Job_Function__c='Marketing',Job_Function_Role__c='Analyst',
        Purchaser_Influence_Over__c='Enterprise',Phone='9991110003'
        );
        insert contactObj;

        for(integer count=0;count<12;count++){ 
            campaignObj=new Campaign(Name='Campaign'+count,
            Campaign_Objective__c='Acquisition/Site Development',
            Type='Multiple Vehicles',//Rev5.0 Type='Advisory Councils',
            Segment_Business_Unit__c='SMB',
            //Region__c='ABU',
            Follow_Up_Role__c='Account Executive',
            Secondary_Role__c='Inside Sales Manager',   //7.0
            IsActive = True,
            Description='Test',StartDate=system.today(),EndDate=system.today(),
            Total_Targets__c = 12.0,
            status='In Progress');
            campaignList.add(campaignObj);       
        }
        
        insert campaignList;

        for(integer i=0;i<campaignList.size();i++){ 
            leadObj1=new Lead(FirstName='NewTest',LastName='Lead'+i,Company='Test Company',
            Status='Open',Email='test_data@test.com',Campaign__c=campaignList[i].id);
            leadList.add(leadObj1);           
        }
        insert leadList;      

        for(Integer j=0;j<leadList.size();j++){
            campaignMemberObj1=new CampaignMember(CampaignId=leadList[j].Campaign__c,
            LeadId=leadList[j].id,status='Sent',            
            ContactId = contactObj.Id
            ,Campaign_Vehicle__c='Multiple Vehicles'); //Rev5.0 Type='Advisory Councils'
            if(j<6){
                campaignMemberObj1.CM_Status__c='Requires Follow-Up';                
            }
            else {
                campaignMemberObj1.CM_Status__c='Accepted';                
            }
            campaignMemberList.add(campaignMemberObj1);       
        }
        RelationshipLeadAccountPlayFollowUp.disableRLAutoCreation = true; // Rev 1.5
      
        insert campaignMemberList;
               
        RelationshipLeadAccountPlayFollowUp.disableRLAutoCreation = false; // Rev 1.5

        for(integer i=0;i<campaignMemberList.size();i++){
            relationShipLeadObj=new Relationship_Lead__c(Contact__c=contactObj.id,Campaign__c=campaignMemberList[i].CampaignId,
            Status__c='Requires Follow-Up',
            CM_Source__c=campaignMemberList[i].id,Opportunity_Status__c='New Opportunity');
            relationshipLeadList.add(relationShipLeadObj);            
            CMIdSet.add(campaignMemberList[i].id);
        }   

       // Test.startTest();
        try{
            insert relationshipLeadList;
        }
        catch(System.DmlException e){
        
            System.assert(e.getMessage().contains('Insert failed. First exception '+
            'on row 6; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, '+
            'You can only create Relationship Lead for CM with "Requires Follow-Up" status'),
            e.getMessage());
        }
        Test.stopTest();        

        for(Integer i=0;i<relationshipLeadList.size();i++){
            RLMap.put(relationshipLeadList[i].id,relationshipLeadList[i]);
            mapRelationshipLead.put(relationshipLeadList[i].CM_Source__c,relationshipLeadList[i]);        
        }

        CampaignMember[] testCM=[select id, CM_Status__c,Relationship_Lead_Opportunity_Status__c,Relationship_Lead__c,
        Relationship_Lead_Created__c from CampaignMember where id in:CMIdSet];     



        for(integer i=0;i<testCM.size();i++){
            relationShipLeadObj=RLMap.get(testCM[i].Relationship_Lead__c);

            if(relationShipLeadObj!=null){
                if((testCM[i].CM_Status__c=='Requires Follow-Up')&&(testCM[i].id==relationShipLeadObj.CM_SOurce__c)){
                    System.assertEquals(relationShipLeadObj.status__c,testCM[i].CM_Status__c);                  
                    System.assertEquals(relationShipLeadObj.Opportunity_Status__c,testCM[i].Relationship_Lead_Opportunity_Status__c);
                    System.assertEquals(relationShipLeadObj.id,testCM[i].Relationship_Lead__c);
                    System.assertEquals(true,testCM[i].Relationship_Lead_Created__c);
                }

            }
            if(testCM[i].CM_Status__c!='Requires Follow-Up'){
                System.assertEquals('Accepted',testCM[i].CM_Status__c);                  
                System.assertEquals(null,testCM[i].Relationship_Lead_Opportunity_Status__c);
                System.assertEquals(null,testCM[i].Relationship_Lead__c);
                System.assertEquals(false,testCM[i].Relationship_Lead_Created__c);
            }


        }
        
        System.debug('***************** END testRelationShipLeadInsert *****************');
    }
    /*---------Start of Test Methods for Assigning Follow-Up Task to Owner------------*/
    
/*  static testMethod void testassignFollowupTaskToOwner_RL(){
        System.debug('***************** START testassignFollowupTaskToOwner_RL *****************');
        
        TestDataCreation(false);
        
        Relationship_Lead__c testRelationshipLead;
        RelationshipLeadAccountPlayFollowUp.isAfterException = true;
        List<Relationship_Lead__c> rlList = new List<Relationship_Lead__c>();
        List<Relationship_Lead__c> rlUpdateList = new List<Relationship_Lead__c>();
        for(integer count =0 ;count<3;count++){
            testRelationshipLead = new Relationship_Lead__c(Contact__c = testContactList[0].Id, Campaign__c = testCampaign.Id, 
                                                            CM_Source__c = testCMList[count].Id, Status__c = 'Requires Follow-Up');
            rlList.add(testRelationshipLead);
        }        
        insert rlList;
        System.debug('##rlList'+rlList);
        System.debug('##testCMList'+testCMList);
        testRelationshipLead = new Relationship_Lead__c(Id = rlList[0].Id);     
        testRelationshipLead.Accept_Reject_Status__c = 'Accepted By Sales';
        //testRelationshipLead.Create_Follow_Up_Task__c = 'Yes';
        testRelationshipLead.Called_Customer__c = 'No';
        testRelationshipLead.Follow_Up_Date__c = System.today()+20;
        rlUpdateList.add(testRelationshipLead);
        testRelationshipLead = new Relationship_Lead__c(Id = rlList[1].Id);     
        testRelationshipLead.Accept_Reject_Status__c = 'Accepted By Sales';
        //testRelationshipLead.Create_Follow_Up_Task__c = 'Yes';
        testRelationshipLead.Called_Customer__c = 'Yes';
        testRelationshipLead.Lead_Quality__c = 'Unqualified';
        testRelationshipLead.Unqualified_Lead_Reasons__c = 'Future Follow-Up';
        testRelationshipLead.Follow_Up_Date__c = System.today()+20;
        rlUpdateList.add(testRelationshipLead);
        //Rev 3.0
        testRelationshipLead = new Relationship_Lead__c(Id = rlList[2].Id);     
        testRelationshipLead.Accept_Reject_Status__c = 'Accepted By Sales';        
        testRelationshipLead.Called_Customer__c = 'Yes';
        testRelationshipLead.Lead_Quality__c = 'Unqualified';
        testRelationshipLead.Unqualified_Lead_Reasons__c = 'Future Follow-Up';
        testRelationshipLead.Follow_Up_Date__c = System.today();
        rlUpdateList.add(testRelationshipLead);        
        //Rev 3.0-end
        Test.startTest();
        update rlUpdateList;
        Test.stopTest();
        
        System.assertEquals(1, [SELECT COUNT() FROM Task WHERE WhatId = :rlUpdateList[0].Id]);
        //Shue temp comment
        //System.assertEquals(1, [SELECT COUNT() FROM Task WHERE WhatId = :rlUpdateList[1].Id]);
        System.assertEquals(0, [SELECT COUNT() FROM Task WHERE WhatId = :rlUpdateList[2].Id]);
        
        System.debug('***************** END testassignFollowupTaskToOwner_RL *****************');
        
    }
    */
    
    /*static testMethod void testassignFollowupTaskToOwner_AP(){
        System.debug('***************** START testassignFollowupTaskToOwner_AP *****************');
        
        TestDataCreation(true);
        Account_Play__c testAccountPlay;
        RelationshipLeadAccountPlayFollowUp.isAfterException = true;
        List<Account_Play__c> apList = new List<Account_Play__c>();
        List<Account_Play__c> apUpdateList = new List<Account_Play__c>();
        for(integer count =0 ;count<3;count++){
            testAccountPlay = new Account_Play__c(Account__c = testAcc.Id, Campaign__c = testCampaign.Id,Campaign_Vehicle__c = testCampaign.Type);
            apList.add(testAccountPlay);
        }
        insert apList;
        testAccountPlay = new Account_Play__c(Id = apList[0].Id);     
        testAccountPlay.Accept_Reject_Status__c = 'Accepted By Sales';
        //testAccountPlay.Create_Follow_Up_Task__c = 'Yes';
        testAccountPlay.Called_Customer__c = 'No';
        testAccountPlay.Follow_Up_Date__c = System.today()+20;
        apUpdateList.add(testAccountPlay); 
        testAccountPlay = new Account_Play__c(Id = apList[1].Id);     
        testAccountPlay.Accept_Reject_Status__c = 'Accepted By Sales';
        //testAccountPlay.Create_Follow_Up_Task__c = 'Yes';
        testAccountPlay.Called_Customer__c = 'Yes';
        testAccountPlay.Lead_Quality__c = 'Unqualified';
        testAccountPlay.Unqualified_Lead_Reasons__c = 'Future Follow-Up';
        testAccountPlay.Follow_Up_Date__c = System.today()+20;
        apUpdateList.add(testAccountPlay);
        //Rev 3.0
        testAccountPlay = new Account_Play__c(Id = apList[2].Id);     
        testAccountPlay.Accept_Reject_Status__c = 'Accepted By Sales';        
        testAccountPlay.Called_Customer__c = 'No';
        testAccountPlay.Follow_Up_Date__c = System.today()-10;
        apUpdateList.add(testAccountPlay);
        //Rev 3.0-end
        Test.startTest();
        update apUpdateList;
        Test.stopTest();
        
        System.assertEquals(1, [SELECT COUNT() FROM Task WHERE WhatId = :apUpdateList[0].Id]);
        // Shue temp comment 
        //System.assertEquals(1, [SELECT COUNT() FROM Task WHERE WhatId = :apUpdateList[1].Id]);
        System.assertEquals(0, [SELECT COUNT() FROM Task WHERE WhatId = :apUpdateList[2].Id]);
        
        System.debug('***************** END testassignFollowupTaskToOwner_AP *****************');
        
    }
    /*---------End of Test Methods for Assigning Follow-Up Task to Owner------------*/
    
    /*---------Start of Test Methods for Assigning Account Owner To RL/AP Owner Based on Condition------------*/
    
   /*static testMethod void testassignAccountOwnerToRLOwner(){
        System.debug('***************** START testassignAccountOwnerToRLOwner *****************');
        
        Account testAccountforOwner;

        TestDataCreation(false);

        Test.startTest();
        //Get one Sales Channel Group defined in Custom Settings
        List<MASalesChannelDetails__c> sclist = MASalesChannelDetails__c.getall().values();
        
        if(sclist.size()>0){
            List<Sales_Channel_Group__c> scGrpList = [SELECT name,Group_ID__c,id FROM Sales_Channel_Group__c WHERE Group_ID__c=:sclist[0].group_Id__c];
            //If that does not exist create that Sales Channel Group record
            if(scGrpList.size()==0){
                Sales_Channel_Group__c testSalesChannelRecord = new Sales_Channel_Group__c
                                                                (Name=sclist[0].name, 
                                                                 Group_ID__c=sclist[0].group_Id__c);
                scGrpList.add(TestSalesChannelRecord);
                insert scGrpList;
            }
            
            //Create Test User
            Profile profile = [select id from profile where name = 'System Administrator' limit 1];
            User testUser = new User(Username='Test'+ System.currentTimeMillis() +'@dell.com',
                                        Alias = 'Test', 
                                        Email='Test'+System.currentTimeMillis()+'@dell.com',            
                                        LastName='Test', 
                                        ProfileId = profile.Id, 
                                        LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', 
                                        EmailEncodingKey='UTF-8', 
                                        TimeZoneSidKey='America/Los_Angeles',
                                        Badge_Number__c='Test'+System.currentTimeMillis());
            insert testUser;
            //Create an Account with that Sales Channel Group
            testAccountforOwner = new Account(name = 'testAccount'+System.currentTimeMillis(),
                                              Sales_Channel__c=scGrpList[0].Id,
                                              ownerid=testUser.id);
            insert testAccountforOwner; 
            System.debug('###testAccountforOwner'+testAccountforOwner);
            //Create Contact
            Contact testContactforOwner = new Contact(Status__c='Active', AccountId=testAccountforOwner.Id, EMEA_Decision_Making_Role__c='Influencer', 
                                            Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                            Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact');
            insert testContactforOwner;
            Relationship_Lead__c testRelationshipLead;
            RelationshipLeadAccountPlayFollowUp.isAfterException = true;
            List<Relationship_Lead__c> rlList = new List<Relationship_Lead__c>();
            
            for(integer count =0 ;count<1;count++){
                testRelationshipLead = new Relationship_Lead__c(Contact__c = testContactforOwner.Id, Campaign__c = testCampaign.Id, 
                                                                CM_Source__c = testCMList[count].Id, Status__c = 'Requires Follow-Up');
                rlList.add(testRelationshipLead);
            }        
            
            
            //Test.startTest();
            insert rlList;
            Test.stopTest();
            
            Relationship_Lead__c testRL = [SELECT Relationship_Lead_Owner__c,id FROM Relationship_Lead__c WHERE Id = :rlList[0].Id];
            
            System.assertEquals(testUser.id, testRL.Relationship_Lead_Owner__c);
            
        }
        System.debug('***************** END testassignAccountOwnerToRLOwner *****************');
        
    }*/
    
   /* static testMethod void testassignAccountOwnerToAPOwner(){
        System.debug('***************** START testassignAccountOwnerToAPOwner *****************');
        
        Account testAccountforOwner;

        TestDataCreation(true);

        //Get one Sales Channel Group defined in Custom Settings
        List<MASalesChannelDetails__c> sclist = MASalesChannelDetails__c.getall().values();
        
        if(sclist.size()>0){
            List<Sales_Channel_Group__c> scGrpList = [SELECT name,Group_ID__c,id FROM Sales_Channel_Group__c WHERE Group_ID__c=:sclist[0].group_Id__c];
            //If that does not exist create that Sales Channel Group record
            if(scGrpList.size()==0){
                Sales_Channel_Group__c testSalesChannelRecord = new Sales_Channel_Group__c
                                                                (Name=sclist[0].name, 
                                                                 Group_ID__c=sclist[0].group_Id__c);
                scGrpList.add(TestSalesChannelRecord);
                insert scGrpList;
            }
            
            //Create Test User
            Profile profile = [select id from profile where name = 'System Administrator' limit 1];
            User testUser = new User(Username='Test'+ System.currentTimeMillis() +'@dell.com',
                                        Alias = 'Test', 
                                        Email='Test'+System.currentTimeMillis()+'@dell.com',            
                                        LastName='Test', 
                                        ProfileId = profile.Id, 
                                        LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', 
                                        EmailEncodingKey='UTF-8', 
                                        TimeZoneSidKey='America/Los_Angeles',
                                        Badge_Number__c='Test'+System.currentTimeMillis());
            insert testUser;
            //Create an Account with that Sales Channel Group
            testAccountforOwner = new Account(name = 'testAccount'+System.currentTimeMillis(),
                                              Sales_Channel__c=scGrpList[0].Id,
                                              ownerid=testUser.id);
            insert testAccountforOwner; 
            System.debug('###testAccountforOwner'+testAccountforOwner);
            //Create Contact
            Contact testContactforOwner = new Contact(Status__c='Active', AccountId=testAccountforOwner.Id, EMEA_Decision_Making_Role__c='Influencer', 
                                            Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                            Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact');
            insert testContactforOwner;
            Account_Play__c testAccountPlay;
            RelationshipLeadAccountPlayFollowUp.isAfterException = true;
            List<Account_Play__c> apList = new List<Account_Play__c>();
            List<Account_Play__c> apUpdateList = new List<Account_Play__c>();
            for(integer count =0 ;count<1;count++){
                testAccountPlay = new Account_Play__c(Account__c = testAccountforOwner.Id, Campaign__c = testCampaign.Id ,Campaign_Vehicle__c = testCampaign.Type);
                apList.add(testAccountPlay);
            }
            
            
            
            Test.startTest();
            insert apList;
            Test.stopTest();
            
            Account_Play__c testAP = [SELECT Account_Play_Owner__c,id FROM Account_Play__c WHERE Id = :apList[0].Id];
            
            System.assertEquals(testUser.id, testAP.Account_Play_Owner__c);
            
        }
        System.debug('***************** END testassignAccountOwnerToAPOwner *****************');
        
    }
    /*---------Start of Test Methods for Assigning Account Owner To RL/AP Owner Based on Condition------------*/
    
    /* -------Test methods for fuctionality for creating RLs for CMs. CR 2279 --------*/
    
   /* static testMethod void testcreateNewRLsForCampMembers_CreateCMs(){
        System.debug('***************** START testcreateNewRLsForCampMembers_CreateCMs *****************');
        
        //Test Account
        Account testAccInstance = new Account(name = 'testAccount'+System.currentTimeMillis()); 
        insert testAccInstance; 
        
        //Test Campaign
        Campaign testCampaignInstance = new Campaign (Type='DM', EndDate= date.newInstance(2010, 1, 1), 
                                    IsActive=true, Description='Test Campaign', StartDate=date.newInstance(2009, 12, 1), 
                                    Name='Test Campaign 1234567', Follow_Up_Role__c = 'Inside Sales Rep'
                                    ,Secondary_Role__c='Inside Sales Manager'   //7.0
                                    );
        insert testCampaignInstance;         
         
        //Contacts
        List<Contact> testContactItemList = new  List<Contact>();        
        for (integer i = 0; i < 20; i++) {            
            Contact testContact = new Contact(Status__c='Active', AccountId=testAccInstance.Id, EMEA_Decision_Making_Role__c='Influencer', 
                                            Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                            Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact'+i);
            testContactItemList.add(testContact);
        }                                            
        insert testContactItemList;
         
        //Campaign members
        List<CampaignMember> testCMItemList = new List<CampaignMember>();
        for (integer i = 0; i < 20; i++) {            
            CampaignMember testCampaignMember = new CampaignMember(CampaignId = testCampaignInstance.Id, Campaign_Vehicle__c = 'DM',
                                                            ContactId = testContactItemList[i].Id, CM_Status__c = 'Requires Follow-Up');
            if (i == 0) testCampaignMember.Eloqua_Id__c = 'WQEs123455097'; //Rev 4.0
            testCMItemList.add(testCampaignMember);
        }                                            
        
        Test.startTest();
        //inserts the CMs
        insert testCMItemList;
        Test.stopTest();
        
        List<id> CMIdList = new List<id>();
        for (integer i = 0; i < 20; i++) {            
            CMIdList.add(testCMItemList[i].Id);
        } 
        //asserts 20 RLs have been created
        System.assertEquals(20, [SELECT COUNT() FROM Relationship_Lead__c WHERE  CM_Source__c IN :CMIdList]);
        //asserts that Relationship_Lead_Created__c in CM has been changed to true.
        System.assertEquals(true, [SELECT Relationship_Lead_Created__c 
                                    FROM CampaignMember WHERE Id = :CMIdList[0] limit 1].Relationship_Lead_Created__c);
        System.assertEquals(testCMItemList[0].Eloqua_Id__c, [SELECT Eloqua_Id__c FROM Relationship_Lead__c WHERE CM_Source__c =:CMIdList[0] limit 1].Eloqua_Id__c);
                                    
        
        System.debug('***************** END testcreateNewRLsForCampMembers_CreateCMs *****************');
        
    }
    
    
    static testMethod void testcreateNewRLsForCampMembers_updateCMs(){
        System.debug('***************** START testcreateNewRLsForCampMembers_updateCMs *****************');
        
        //Test Account
        Account testAccInstance = new Account(name = 'testAccount'+System.currentTimeMillis()); 
        insert testAccInstance; 
        
        //Test Campaign
        Campaign testCampaignInstance = new Campaign (Type='DM', EndDate= date.newInstance(2010, 1, 1), 
                                    IsActive=true, Description='Test Campaign', StartDate=date.newInstance(2009, 12, 1), 
                                    Name='Test Campaign 1234567', Follow_Up_Role__c = 'Inside Sales Rep'
                                    ,Secondary_Role__c='Inside Sales Manager'   //7.0
                                    );
        insert testCampaignInstance;         
         
        //Contacts
        List<Contact> testContactItemList = new  List<Contact>();        
        for (integer i = 0; i < 20; i++) {            
            Contact testContact = new Contact(Status__c='Active', AccountId=testAccInstance.Id, EMEA_Decision_Making_Role__c='Influencer', 
                                            Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                            Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact'+i);
            testContactItemList.add(testContact);
        }                                            
        insert testContactItemList;
         
        //Campaign members
        List<CampaignMember> testCMItemList = new List<CampaignMember>();
        for (integer i = 0; i < 20; i++) {            
            CampaignMember testCampaignMember = new CampaignMember(CampaignId = testCampaignInstance.Id, Campaign_Vehicle__c = 'DM',
                                                            ContactId = testContactItemList[i].Id, CM_Status__c = 'Returned'); //Rev 5.0 = 'General comment');
            testCMItemList.add(testCampaignMember);
        }                                            
               
        //inserts the CMs
        insert testCMItemList;
        
        List<id> CMIdList = new List<id>();
        for (integer i = 0; i < 20; i++) {            
            CMIdList.add(testCMItemList[i].Id);
        } 
        
        //asserts no RL has been created
        System.assertEquals(0, [SELECT COUNT() FROM Relationship_Lead__c WHERE  CM_Source__c IN :CMIdList]);       
        
        for (integer i = 0; i < 20; i++) {            
            testCMItemList[i].CM_Status__c = 'Requires Follow-Up';            
        }        
        
        Test.startTest();
        //inserts the CMs
        update testCMItemList;
        Test.stopTest(); 
        
        //asserts 20 RLs have been created
        System.assertEquals(20, [SELECT COUNT() FROM Relationship_Lead__c WHERE  CM_Source__c IN :CMIdList]);
        //asserts that Relationship_Lead_Created__c in CM has been chnaged to true.
        System.assertEquals(true, [SELECT Id, Relationship_Lead_Created__c 
                                    FROM CampaignMember WHERE Id = :CMIdList[0] limit 1].Relationship_Lead_Created__c);
        
        System.debug('***************** END testcreateNewRLsForCampMembers_updateCMs *****************');
        
    }*/
    /* -------Ends Test methods for fuctionality for creating RLs for CMs. CR 2279 --------*/
    
    /* ----------------------------------- START TEST METHODS FOR CR2400 --------------------------------------------------- */
   /* static testMethod void assignAccountOwner_RLPopulateToRLAPOwner() {
        
        System.debug('***************** START assignAccountOwner_RLPopulateToRLAPOwner *****************');
        
        TestDataCreation(false);
        
        // Update Follow-up role to Account Owner
        testCampaign.Follow_Up_Role__c = 'Account Owner';
        update testCampaign;
        
        Relationship_Lead__c testRelationshipLead = new Relationship_Lead__c(Contact__c = testContactList[0].Id, Campaign__c = testCampaign.Id,
                                                        CM_Source__c = testCMList[0].Id, Status__c = 'Requires Follow-Up');
                
        Test.StartTest();       
        insert testRelationshipLead;        
        Test.StopTest();
        
        System.assertEquals(testAcc.OwnerId, testRelationshipLead.Relationship_Lead_Owner__c);
      
        System.debug('***************** END assignAccountOwner_RLPopulateToRLAPOwner *****************');
    }
    
    static testMethod void assignAccountOwner_APPopulateToRLAPOwner() {
        
        System.debug('***************** START assignAccountOwner_APPopulateToRLAPOwner *****************');
        
        TestDataCreation(true);                                        
        
        // Update Follow-up role to Account Owner
        testCampaign.Follow_Up_Role__c = 'Account Owner';
        update testCampaign;
        
        Account_Play__c testAccountPlay = new Account_Play__c(Account__c = testAcc.Id, Campaign__c = testCampaign.Id ,Campaign_Vehicle__c = testCampaign.Type);        
        
        Test.StartTest();       
        insert testAccountPlay;
        Test.StopTest();
        
        System.assertEquals(testAcc.OwnerId, testAccountPlay.Account_Play_Owner__c);
      
        System.debug('***************** END assignAccountOwner_APPopulateToRLAPOwner *****************');
    }    
    
    static testMethod void assignAccountOwner_DoNotOverwrite() {
        
        System.debug('***************** START assignAccountOwner_DoNotOverwrite *****************');
        
        TestDataCreation(true);
        
        Profile profile = [select id from profile where name = 'System Administrator' limit 1];
        User testDoNotOverwriteOwner = new User(Username='noOverwriteOwner@dell.com',
                                        Alias = 'owner', 
                                        Email='noOverwriteOwner@dell.com',            
                                        LastName='noOverwriteOwner', 
                                        ProfileId = profile.Id, 
                                        LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', 
                                        EmailEncodingKey='UTF-8', 
                                        TimeZoneSidKey='America/Los_Angeles',
                                        Badge_Number__c='Test'+System.currentTimeMillis());
        insert testDoNotOverwriteOwner;                                        
        
        // Update Follow-up role to Account Owner
        testCampaign.Follow_Up_Role__c = 'Account Owner';
        update testCampaign;
        
        Account_Play__c testAccountPlay = new Account_Play__c(Account__c = testAcc.Id, Campaign__c = testCampaign.Id 
                                                        ,Campaign_Vehicle__c = testCampaign.Type, Account_Play_Owner__c = testDoNotOverwriteOwner.Id);        
        
        Test.StartTest();       
        insert testAccountPlay;
        Test.StopTest();
        
        System.assertEquals(testDoNotOverwriteOwner.Id, testAccountPlay.Account_Play_Owner__c);
      
        System.debug('***************** END assignAccountOwner_DoNotOverwrite *****************');
    }    
    /* ----------------------------------- END TEST METHODS FOR CR2400 --------------------------------------------------- */
    
    /*----------------------------------- START TEST METHOD FOR CR4126 ---------------------------------------------------*/
    // 1. Update AP Follow-Up
   /* static testMethod void assignAPFollowUp(){
        TestDataCreation(true);                                        
        Profile profile = [select id from profile where name = 'System Administrator' limit 1];
        User testDoNotOverwriteOwner = new User(Username='noOverwriteOwner@dell.com',
                                        Alias = 'owner', 
                                        Email='noOverwriteOwner@dell.com',            
                                        LastName='noOverwriteOwner', 
                                        ProfileId = profile.Id, 
                                        LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', 
                                        EmailEncodingKey='UTF-8', 
                                        TimeZoneSidKey='America/Los_Angeles',
                                        Badge_Number__c='Test'+System.currentTimeMillis());
        insert testDoNotOverwriteOwner;  
            
        Account_Play__c testAccountPlay1 = new Account_Play__c(Account__c = testAcc.Id, Campaign__c = testCampaign.Id ,Campaign_Vehicle__c = testCampaign.Type);        
        insert testAccountPlay1;
        Account_Play__c testAccountPlay2 = new Account_Play__c(Account__c = testAcc.Id, Campaign__c = testCampaign.Id ,Campaign_Vehicle__c = testCampaign.Type);        
        insert testAccountPlay2;
        Account_Play__c testAccountPlay3 = new Account_Play__c(Account__c = testAcc.Id, Campaign__c = testCampaign.Id ,Campaign_Vehicle__c = testCampaign.Type);        
        insert testAccountPlay3;
        
        testAccountPlay1.Account_Play_Owner__c = testDoNotOverwriteOwner.Id;
        testAccountPlay2.Account_Executive__c = testDoNotOverwriteOwner.Id;
        testAccountPlay3.Inside_Sales_Rep__c = testDoNotOverwriteOwner.Id;
        
        Test.StartTest();       
        update testAccountPlay1;
        update testAccountPlay2;
        update testAccountPlay3;
        Test.StopTest();
        
        System.assertEquals(false, testAccountPlay1.System_Auto_Populated_AP_Owner__c);
        System.assertEquals(false, testAccountPlay2.System_Auto_Populated_AE__c);
        System.assertEquals(false, testAccountPlay3.System_Auto_Populated_ISR__c);
        system.debug('###DEBUG System_Auto_Populated_AP_Owner__c : ' + testAccountPlay1.System_Auto_Populated_AP_Owner__c);
    }
    
    // 2. Update RL Follow-Up
    static testMethod void assignRLFollowUp(){
        
        TestDataCreation(false);
                   
        Profile profile = [select id from profile where name = 'System Administrator' limit 1];
        User testDoNotOverwriteOwner = new User(Username='noOverwriteOwner@dell.com',
                                        Alias = 'owner', 
                                        Email='noOverwriteOwner@dell.com',            
                                        LastName='noOverwriteOwner', 
                                        ProfileId = profile.Id, 
                                        LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', 
                                        EmailEncodingKey='UTF-8', 
                                        TimeZoneSidKey='America/Los_Angeles',
                                        Badge_Number__c='Test'+System.currentTimeMillis());
        insert testDoNotOverwriteOwner;  
                        
        Relationship_Lead__c testRL1 = new Relationship_Lead__c(Contact__c = testContactList[0].Id, Campaign__c = testCampaign.Id,
                                                  CM_Source__c = testCMList[0].Id, Status__c = 'Requires Follow-Up');
        insert testRL1;
        Relationship_Lead__c testRL2 = new Relationship_Lead__c(Contact__c = testContactList[0].Id, Campaign__c = testCampaign.Id,
                                                  CM_Source__c = testCMList[1].Id, Status__c = 'Requires Follow-Up');
        insert testRL2;
        
        testRL1.Relationship_Lead_Owner__c = testDoNotOverwriteOwner.Id;
        testRL2.Inside_Sales_Rep__c = testDoNotOverwriteOwner.Id;
        
        Test.StartTest();       
        update testRL1;
        update testRL2;
        Test.StopTest();
        
        System.assertEquals(false, testRL1.System_Auto_Populated_RL_Owner__c);
        System.assertEquals(false, testRL2.System_Auto_Populated_ISR__c);
        system.debug('###DEBUG Relationship_Lead_Owner__c : ' + testRL1.Relationship_Lead_Owner__c);
    }*/
    
    
    
    //7.0 Secondary Role
   /* static testmethod void populateOwnerAndSpecifiedRoleField_APNoUserAssociateWithFollowUpRole_SR() {
        TestDataCreation(true);
        
        Profile profile = [select id from profile where name = 'System Administrator' limit 1];
        User testDoNotOverwriteOwner = new User(Username='noOverwriteOwner@dell.com',
                                        Alias = 'owner', 
                                        Email='noOverwriteOwner@dell.com',            
                                        LastName='noOverwriteOwner', 
                                        ProfileId = profile.Id, 
                                        LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', 
                                        EmailEncodingKey='UTF-8', 
                                        TimeZoneSidKey='America/Los_Angeles',
                                        Badge_Number__c='Test'+System.currentTimeMillis());
        insert testDoNotOverwriteOwner;  
        
        testISM = new AccountTeamMember (AccountId = testAcc.Id, UserId = testDoNotOverwriteOwner.Id, TeamMemberRole = 'Inside Sales Manager');
        insert testISM;
        delete testISR;
        delete testAE;
                
        Account_Play__c testAccountPlay = new Account_Play__c(Account__c = testAcc.Id, Campaign__c = testCampaign.Id ,Campaign_Vehicle__c = testCampaign.Type);
                
        Test.StartTest();       
        insert testAccountPlay;         
        Test.StopTest();
        
        Account_Play__c actualAccountPlay = [SELECT Account_Play_Owner__c, Inside_Sales_Rep__c, Account_Executive__c,
                                            System_Auto_Populated_AP_Owner__c, System_Auto_Populated_ISR__c, System_Auto_Populated_AE__c 
                                            FROM Account_Play__c
                                            WHERE ID = :testAccountPlay.Id];                                            

        
        //System.assertEquals(testISM.UserId, actualAccountPlay.Account_Play_Owner__c );       
        System.assertEquals(null, actualAccountPlay.Inside_Sales_Rep__c);       
        //System.assertEquals(testISM.UserId, actualAccountPlay.Account_Executive__c);     //Rev 2.0   //Rev 1.2 
        System.assertEquals(true, actualAccountPlay.System_Auto_Populated_AP_Owner__c); //Rev 1.9
        System.assertEquals(true, actualAccountPlay.System_Auto_Populated_ISR__c);      //Rev 1.9
        System.assertEquals(true, actualAccountPlay.System_Auto_Populated_AE__c);       //Rev 2.0
    }
    
    //7.0 Secondary Role Shue
    static testMethod void populateOwnerAndSpecifiedRoleField_NoUserAssociateWithFollowUpRole_SR() {
        TestDataCreation(false);    
        
        Profile profile = [select id from profile where name = 'System Administrator' limit 1];
        User testDoNotOverwriteOwner = new User(Username='noOverwriteOwner@dell.com',
                                        Alias = 'owner', 
                                        Email='noOverwriteOwner@dell.com',            
                                        LastName='noOverwriteOwner', 
                                        ProfileId = profile.Id, 
                                        LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', 
                                        EmailEncodingKey='UTF-8', 
                                        TimeZoneSidKey='America/Los_Angeles',
                                        Badge_Number__c='Test'+System.currentTimeMillis());
        insert testDoNotOverwriteOwner;  
        
        testISM = new AccountTeamMember (AccountId = testAcc.Id, UserId = testDoNotOverwriteOwner.Id, TeamMemberRole = 'Inside Sales Manager');
        insert testISM;
        delete testISR;
        delete testAE;
        
        Relationship_Lead__c testRelationshipLead = new Relationship_Lead__c(Contact__c = testContactList[0].Id, Campaign__c = testCampaign.Id,
                                                        CM_Source__c = testCMList[0].Id, Status__c = 'Requires Follow-Up');
                
        Test.StartTest();       
        insert testRelationshipLead;        
        Test.StopTest();
        
        Relationship_Lead__c actualRelationshipLead = [SELECT Relationship_Lead_Owner__c, Inside_Sales_Rep__c, Account_Executive__c
                                            FROM Relationship_Lead__c
                                            WHERE ID = :testRelationshipLead.Id];

        
        //System.assertEquals(testISM.UserId, actualRelationshipLead.Relationship_Lead_Owner__c );
        System.assertEquals(null, actualRelationshipLead.Inside_Sales_Rep__c);      
        //System.assertEquals(testISM.UserId, actualRelationshipLead.Account_Executive__c);
    }
    
    //7.0
    static testMethod void assignAccountOwner_APPopulateToRLAPOwner_SR() {
        
        System.debug('***************** START assignAccountOwner_APPopulateToRLAPOwner_SR *****************');
        
        TestDataCreation(true);                                        
        
        // Update Follow-up role to Account Owner
        testCampaign.Follow_Up_Role__c = 'Account Owner';
        testCampaign.Secondary_Role__c = 'Account Owner';
        update testCampaign;
        
        Account_Play__c testAccountPlay = new Account_Play__c(Account__c = testAcc.Id, Campaign__c = testCampaign.Id ,Campaign_Vehicle__c = testCampaign.Type);        
        
        Test.StartTest();       
        insert testAccountPlay;
        Test.StopTest();
        
        System.assertEquals(testAcc.OwnerId, testAccountPlay.Account_Play_Owner__c);
      
        System.debug('***************** END assignAccountOwner_APPopulateToRLAPOwner_SR *****************');
    }
    
    //7.0
    static testMethod void assignAccountOwner_RLPopulateToRLAPOwner_SR() {
        
        System.debug('***************** START assignAccountOwner_RLPopulateToRLAPOwner_SR *****************');
        
        TestDataCreation(false);
        
        // Update Follow-up role to Account Owner
        testCampaign.Follow_Up_Role__c = 'Account Owner';
        testCampaign.Secondary_Role__c = 'Account Owner';
        update testCampaign;
        
        Relationship_Lead__c testRelationshipLead = new Relationship_Lead__c(Contact__c = testContactList[0].Id, Campaign__c = testCampaign.Id,
                                                        CM_Source__c = testCMList[0].Id, Status__c = 'Requires Follow-Up');
                
        Test.StartTest();       
        insert testRelationshipLead;        
        Test.StopTest();
        
        System.assertEquals(testAcc.OwnerId, testRelationshipLead.Relationship_Lead_Owner__c);
      
        System.debug('***************** END assignAccountOwner_RLPopulateToRLAPOwner_SR *****************');
    }
    
    /*Static testmethod void AssignPDM_ICAMusers_RLAP(){
        TestDataCreation(false);     
        
        
        //testcampaign.Contact__c = partnercon.Id;
        //Update testcampaign;
        
        Contact partnercon = new Contact(Status__c='Active', AccountId=testPartnerAcc.Id, EMEA_Decision_Making_Role__c='Influencer', 
                                            Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                            Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact');  
        insert partnercon;
        
        Relationship_Lead__c testRelationshipLead1 = new Relationship_Lead__c(Contact__c = partnercon.Id, Campaign__c = testCampaign.Id, 
                                                        CM_Source__c = testCMList[0].Id, Status__c = 'Requires Follow-Up');
        //insert testRelationshipLead;
        
        Test.StartTest();       
        insert testRelationshipLead1;        
        Test.StopTest();
                
         //RelationshipLeadAccountPlayFollowUp.assignUserToOwnerAndSpecifiedRoleFields();       
         System.debug('Rllllllllllllll1'+ testRelationshipLead1);       
       //System.assertEquals(testPDM.UserID, testRelationshipLead1.Account_Executive__c);
        
    
    }*/
    
    /*----------------------------------- END TEST METHOD FOR CR4126 ---------------------------------------------------*/
    
    
    // *********************************** 8.0 CR 10607 Pleas DO NOT modify/remove this testMethod.***********************************************
    // Readded on 18/3 due to missing test method
    // To check FUR & SR picklist to have the same amount and values.
    static testMethod void compareFURandSR() {
        Schema.DescribeFieldResult FURfieldResult = Campaign.Follow_Up_Role__c.getDescribe();
        Schema.DescribeFieldResult SRfieldResult = Campaign.Secondary_Role__c.getDescribe();
        
        List<Schema.PicklistEntry> FURple = FURfieldResult.getPicklistValues();
        List<Schema.PicklistEntry> SRple = SRfieldResult.getPicklistValues();
        
        List<String> FURlstPickvals=new List<String>();
        for (Schema.PicklistEntry a : FURple) {
            FURlstPickvals.add(a.getValue().trim()); //add the value  to our list
            FURlstPickvals.sort();
        }
        
        List<String> SRlstPickvals=new List<String>();
        for (Schema.PicklistEntry a : SRple) {
            SRlstPickvals.add(a.getValue().trim()); //add the value  to our list
            SRlstPickvals.sort();
        }
        
        
        System.debug(LoggingLevel.error,'Shue FURlstPickvals --- '+FURlstPickvals);
        System.debug(LoggingLevel.error,'Shue FURlstPickvals --- '+SRlstPickvals);
        System.assertEquals(FURlstPickvals.size(), SRlstPickvals.size()); // FUR & SR must have the same amount of picklist values
        //System.assertEquals(FURlstPickvals, SRlstPickvals); // FUR & SR must have the same picklist values. Commented because 'Territory Account Executive' in FUR not sorted
    }
    
    static testMethod void testgetLeadScore_LeadQualification() {
         
         
         TestDataCreation(true);
         
         string testStr =  RelationshipLeadAccountPlayFollowUp.getLeadScore_LeadQualification(true,'Telemarketing');
         System.assertEquals('TeleQualified Lead (Potential Opportunity; SLA = 48 hours)',testStr);
         testStr =  RelationshipLeadAccountPlayFollowUp.getLeadScore_LeadQualification(true,'Telemarketing2');
         testStr =  RelationshipLeadAccountPlayFollowUp.getLeadScore_LeadQualification(false,'Telemarketing');
         RelationshipLeadAccountPlayFollowUp.isBeforeException = false;
         RelationshipLeadAccountPlayFollowUp.isAfterException = false;
         RelationshipLeadAccountPlayFollowUp.disableRLAutoCreation = false;
         RelationshipLeadAccountPlayFollowUp.isTriggerFireBefore = false;
         
    }
    
     static void TestDataCreation(boolean isAccountCampaign) {

        Profile profile = [select id from profile where name = 'System Administrator' limit 1];
                                
        for (integer i = 0; i < 3; i++) {
            User testUser = new User(Username='Test'+i+ System.currentTimeMillis() +'@dell.com',
                                        Alias = 'Test'+i, 
                                        Email='Test'+i+'@dell.com',            
                                        LastName='Test'+i, 
                                        ProfileId = profile.Id, 
                                        LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', 
                                        EmailEncodingKey='UTF-8', 
                                        TimeZoneSidKey='America/Los_Angeles',
                                        Badge_Number__c='Test'+i+System.currentTimeMillis());
            testUserList.add(testUser);
        }
        insert testUserList;
        
        PartnerAcc = [Select ID from Recordtype where name =: 'Partner Account' AND SobjectType = 'Account' LIMIT 1].Id;
    
        testPartnerAcc = new Account(name = 'testPartnerAccount'+System.currentTimeMillis() , Account_Country__c = 'CCCGeo', Shippingpostalcode = 'testcode', ShippingState = 'CCCstate' , RecordtypeId = PartnerAcc); 
        insert testPartnerAcc;   
        
        
        
        testAcc = new Account(name = 'testAccount'+System.currentTimeMillis() , Account_Country__c = 'CCCGeo', Shippingpostalcode = 'testcode', ShippingState = 'CCCstate' ); 
        insert testAcc;
        
        
        testISR = new AccountTeamMember (AccountId = testAcc.Id, UserId = testUserList[0].Id, TeamMemberRole = 'Inside Sales Rep');
        insert testISR;
        
        testAE = new AccountTeamMember (AccountId = testAcc.Id, UserId = testUserList[1].Id, TeamMemberRole = 'Account Executive');
        insert testAE;      
          
        
        testPDM =  new AccountTeamMember(AccountId = testPartnerAcc.Id, UserId = testUserList[2].Id, TeamMemberRole = 'Partner Development Manager');
        insert testPDM;
               
        
        testContactList.clear();
        for (integer i = 0; i < 3; i++) {
            
            Contact testContact = new Contact(Status__c='Active', AccountId=testAcc.Id, EMEA_Decision_Making_Role__c='Influencer', 
                                            Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                            Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact'+i);
            testContactList.add(testContact);
        }
                                                                                      
        insert testContactList;
         Integer Year = Date.today().addYears(1).year();
                
        if (isAccountCampaign) {  
            
           
            testCampaign = new Campaign (Type='eSeminar/Webcast/Webinar', EndDate= date.newInstance(Year, 1, 1), 
                                                        IsActive=true, Description='Test Campaign', StartDate=date.newInstance(2009, 12, 1), 
                                                        Name='Test Campaign', Follow_Up_Role__c = 'Inside Sales Rep',
                                                        Is_this_Account_Play_Campaign__c = True, Account_Play_Expiry_Date__c = System.today() + 60
                                                        //7.0
                                                        ,Secondary_Role__c = 'Inside Sales Manager'
                                                        );
             insert testCampaign;
        }
        else {
            testCampaign = new Campaign (Type='eSeminar/Webcast/Webinar', EndDate= date.newInstance(Year, 1, 1), 
                                                    IsActive=true, Description='Test Campaign', StartDate=date.newInstance(2009, 12, 1), 
                                                    Name='Test Campaign', Follow_Up_Role__c = 'Inside Sales Rep',
                                                    Next_Steps__c = 'Next Steps', Supporting_Information__c = 'Supporting Info'
                                                    //7.0         
                                                    ,Secondary_Role__c = 'Inside Sales Manager'
                                                    ); //Rev 4.0
            
            insert testCampaign;
                       
            RelationshipLeadAccountPlayFollowUp.disableRLAutoCreation = true;
            testCMList.clear();   
            for (integer i = 0; i < 3; i++) {
                CampaignMember testCampaignMember = new CampaignMember(CampaignId = testCampaign.Id, Campaign_Vehicle__c = 'eSeminar/Webcast/Webinar',
                                                            ContactId = testContactList[i].Id, CM_Status__c = 'Requires Follow-Up');
                testCMList.add(testCampaignMember);
            }                   
            insert testCMList;
            RelationshipLeadAccountPlayFollowUp.disableRLAutoCreation = false;                  
        }              
        testUserList.clear();  
    }
}