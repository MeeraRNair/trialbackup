/* 10 -12-2018         Haribabu.A     STORY 5907651 Removed reference for the field direct_account_name__c */
@isTest(seealldata=false)
private class LOBRRegistrationScheduleExecuteTest{
    
    
    private static testmethod void TestLOBRRegistrationScheduleExecute1(){
      TriggerExecutionController.setSkipAllTriggers(true);     
     Id endUserAccountRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End-User Account').getRecordTypeId();
     Id partnerAccountRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();
     System_Behavior_Bypasser__c cs = new System_Behavior_Bypasser__c();
  cs.Bypass_Opportunity_VRs__c = true;
  insert cs;
     Account EUacc = new Account();
     EUacc.Name = 'Test Account';
     EUacc.Participating_in_LOB_Program__c = true;
     EUacc.RecordTypeId = endUserAccountRT;
     EUacc.Account_Country__c = 'UNITED STATES';
     EUacc.ShippingStreet = '12';
     EUacc.ShippingCity = 'testStreet';
     EUacc.ShippingState = 'testTexas';
     EUacc.ShippingPostalCode = '1324';
     EUacc.Tax_Registration_Number__c = '124214';
     insert EUacc;
     
     Contact EUCon = new Contact();
     EUCon.FirstName = 'testFirstName';
     EUCon.LastName = 'testLastName';
     EUCon.Email = 'test@test.com';
     EUCon.Phone = '1234';
     EUCon.AccountId = EUacc.Id;
     insert EUCon;
     EUacc.Primary_Contact__c = EUCon.Id;
     update EUacc;
     
     Account partnerAcc = new Account();
     partnerAcc.Name = 'Test Account1';
     partnerAcc.Is_GTM_Partner__c = true;
     partnerAcc.RecordTypeId = partnerAccountRT;
     insert partnerAcc;
        
     /*Account_Branch__c ab = new Account_Branch__c();
     ab.Account__c = EUacc.id;
     ab.Name = 'Test Branch';
     insert ab;*/
             
            
     List<LOB_Registration__c> lobRegList = new List<LOB_Registration__c>();
                
     LOB_Registration__c lobRegClientRecord = new LOB_Registration__c ();
     lobRegClientRecord.LOB_Name__c ='Client';             
     lobRegClientRecord.Registered_End_User__c= EUacc.Id;
     lobRegClientRecord.LOB_Partner_Approved_Date__c =system.today().addDays(-1);
     lobRegClientRecord.LOB_registration_status__c = 'Partner(approved)';
     lobRegClientRecord.LOB_Award_Type__c = 'All Accounts' ; 
     lobRegClientRecord.Preferred_GTM_Partner_Account__c = partnerAcc.Id;          
     lobRegClientRecord.GTM_Linkage_Expiry_Date__c =system.today().addDays(35); 
     lobRegClientRecord.City__c = 'testCity';
     lobRegClientRecord.State_Province_Region__c = 'testState';      
     
     lobRegList.add(lobRegClientRecord);
     
     LOB_Registration__c lobRegServerRecord = new LOB_Registration__c ();
     lobRegServerRecord.LOB_Name__c ='Server';             
     lobRegServerRecord.Registered_End_User__c= EUacc.Id;
     lobRegServerRecord.LOB_Partner_Approved_Date__c =system.today().addDays(-275);
     lobRegServerRecord.GTM_Linkage_Expiry_Date__c =system.today().addDays(35);
     lobRegServerRecord.LOB_registration_status__c = 'Partner(approved)';
     lobRegServerRecord.LOB_Award_Type__c = 'All Accounts' ; 
     lobRegServerRecord.Preferred_GTM_Partner_Account__c = partnerAcc.Id;              
     lobRegServerRecord.City__c = 'testCity';
     lobRegServerRecord.State_Province_Region__c = 'testState';      
     
     lobRegList.add(lobRegServerRecord);
     /*
     LOB_Registration__c lobRegNetworkingRecord = new LOB_Registration__c ();
     lobRegNetworkingRecord.LOB_Name__c ='Networking';             
     lobRegNetworkingRecord.Registered_End_User__c= EUacc.Id;
     lobRegNetworkingRecord.LOB_Partner_Approved_Date__c =system.today().addDays(-275);
     lobRegNetworkingRecord.GTM_Linkage_Expiry_Date__c =system.today().addDays(35);
     lobRegNetworkingRecord.LOB_registration_status__c = 'Partner(approved)';
     lobRegNetworkingRecord.LOB_Award_Type__c = 'All Accounts' ; 
     lobRegNetworkingRecord.Preferred_GTM_Partner_Account__c = partnerAcc.Id;          
     lobRegNetworkingRecord.City__c = 'testCity';
     lobRegNetworkingRecord.State_Province_Region__c = 'testState';     
     
     
     lobRegList.add(lobRegNetworkingRecord);
     
     LOB_Registration__c lobRegStorageRecord = new LOB_Registration__c ();
     lobRegStorageRecord.LOB_Name__c ='Storage';       
     lobRegStorageRecord.City__c = 'testCity';
     lobRegStorageRecord.State_Province_Region__c = 'testState';      
     lobRegStorageRecord.Registered_End_User__c= EUacc.Id;
     lobRegStorageRecord.LOB_Partner_Approved_Date__c =system.today().addDays(-275);
     lobRegClientRecord.Preferred_GTM_Partner_Account__c = partnerAcc.Id;   
     lobRegStorageRecord.GTM_Linkage_Expiry_Date__c =system.today();
     lobRegStorageRecord.LOB_registration_status__c = 'Partner(Approved)';
     lobRegStorageRecord.LOB_Award_Type__c = 'All Accounts' ; 
     lobRegList.add(lobRegStorageRecord);*/
     
     insert lobRegList;
            
            Id DealRTId = IdLookupUtils.getRecordTypeId('Deal Registration-Submitted', 'Opportunity', true);
            List<Opportunity> oppList = new List<Opportunity>();
        
            Opportunity testOppty1 = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=EUacc.Id, 
                                                Deal_Registration_Status__c= 'Approved',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = DealRTId,
                                                Stage_Changed_On__c= system.today().addDays(-10),
                                                Engagement_Type__c = 'Public Tender',
                                                Justification_Statement__c = 'Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'Country',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                End_User_First_Name__c = 'Fi rst Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                                Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                StageName = 'Win - 100%',
                                                Probability = 100,
                                                Reason_Won_Lost__c = 'Incumbent',
                                                Competitor_Lost_To__c ='3i-Infotech',
                                                Region__c = 'APJ',
                                                //End_User_Account_Department__c = ab.Name,
                                                CloseDate = System.Today() + 30 ); 
            oppList.add(testOppty1);                                       
/*
            Opportunity testOppty2 = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=EUacc.Id, 
                                                Deal_Registration_Status__c= 'Approved',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = DealRTId,
                                                Stage_Changed_On__c= system.today().addDays(-10),
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
                                                StageName = 'Win - 100%',
                                                Probability = 100,
                                                Reason_Won_Lost__c = 'Incumbent',
                                                Primary_Competitor__c ='3i-Infotech',
                                                Region__c = 'APJ',
                                                Direct_Account_Name__c = EUacc.Id,
                                                //End_User_Account_Department__c = ab.Name,
                                                LOB_Registration_ID__c = lobRegList[3].Id,
                                                CloseDate = System.Today() + 30 );                                                        

            oppList.add(testOppty2);
            Opportunity testOppty3 = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=EUacc.Id, 
                                                Deal_Registration_Status__c= 'Approved',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = DealRTId,
                                                Stage_Changed_On__c= system.today().addDays(-365),
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
                                                StageName = 'Win - 100%',
                                                
                                                Direct_Account_Name__c = EUacc.Id,
                                                //End_User_Account_Department__c = ab.Name,
                                                LOB_Registration_ID__c = lobRegList[0].Id+';'+lobRegList[1].Id,
                                                CloseDate = System.Today() + 30 ); 
            oppList.add(testOppty3);                                       

            Opportunity testOppty4 = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=EUacc.Id, 
                                                Deal_Registration_Status__c= 'Submitted',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = DealRTId,
                                                Stage_Changed_On__c= system.today().addDays(-365),
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
                                                Direct_Account_Name__c = EUacc.Id,
                                                //End_User_Account_Department__c = ab.Name,
                                                LOB_Registration_ID__c = lobRegList[3].Id,
                                                CloseDate = System.Today() + 30 );                                                        

            oppList.add(testOppty4);   */                                     
            Test.StartTest(); 
            insert oppList;
            LOBRRegistrationScheduleExecute lobse = new LOBRRegistrationScheduleExecute();
            String sch = '0 0 23 * * ?';
            DateTime systime= System.now();
            system.schedule('LOB Registration'+string.valueof(systime), sch, lobse);
            Test.stopTest();
            
   }
   
   private static testmethod void TestLOBRRegistrationScheduleExecute2(){
   TriggerExecutionController.setSkipAllTriggers(true);   
            Test.StartTest();
             Id endUserAccountRT = [select Name from RecordType where Name ='End-User Account' limit 1].Id;
     Id partnerAccountRT = [select Name from RecordType where Name ='Partner Account' limit 1].Id;
     System_Behavior_Bypasser__c cs = new System_Behavior_Bypasser__c();
  cs.Bypass_Opportunity_VRs__c = true;
  insert cs;
     Account EUacc = new Account();
     EUacc.Name = 'Test Account';
     EUacc.Participating_in_LOB_Program__c = true;
     EUacc.RecordTypeId = endUserAccountRT;
     EUacc.Account_Country__c = 'UNITED STATES';
     EUacc.ShippingStreet = '12';
     EUacc.ShippingCity = 'testStreet';
     EUacc.ShippingState = 'testTexas';
     EUacc.ShippingPostalCode = '1324';
     EUacc.Tax_Registration_Number__c = '124214';
     insert EUacc;
     
     Contact EUCon = new Contact();
     EUCon.FirstName = 'testFirstName';
     EUCon.LastName = 'testLastName';
     EUCon.Email = 'test@test.com';
     EUCon.Phone = '1234';
     EUCon.AccountId = EUacc.Id;
     insert EUCon;
     EUacc.Primary_Contact__c = EUCon.Id;
     update EUacc;
     
     Account partnerAcc = new Account();
     partnerAcc.Name = 'Test Account1';
     partnerAcc.Is_GTM_Partner__c = true;
     partnerAcc.RecordTypeId = partnerAccountRT;
     insert partnerAcc;
        
     /*Account_Branch__c ab = new Account_Branch__c();
     ab.Account__c = EUacc.id;
     ab.Name = 'Test Branch';
     insert ab;*/
             
            
     List<LOB_Registration__c> lobRegList = new List<LOB_Registration__c>();
                
     LOB_Registration__c lobRegClientRecord = new LOB_Registration__c ();
     lobRegClientRecord.LOB_Name__c ='Client';             
     lobRegClientRecord.Registered_End_User__c= EUacc.Id;
     lobRegClientRecord.LOB_Partner_Approved_Date__c =system.today().addDays(-1);
     lobRegClientRecord.LOB_registration_status__c = 'Partner(approved)';
     lobRegClientRecord.LOB_Award_Type__c = 'All Accounts' ; 
     lobRegClientRecord.Preferred_GTM_Partner_Account__c = partnerAcc.Id;          
     lobRegClientRecord.City__c = 'testCity';
     lobRegClientRecord.State_Province_Region__c = 'testState';      
     
     lobRegList.add(lobRegClientRecord);
     
     LOB_Registration__c lobRegServerRecord = new LOB_Registration__c ();
     lobRegServerRecord.LOB_Name__c ='Server';             
     lobRegServerRecord.Registered_End_User__c= EUacc.Id;
     lobRegServerRecord.LOB_Partner_Approved_Date__c =system.today().addDays(-365);
     lobRegServerRecord.LOB_registration_status__c = 'Partner(submit for approval)';
     lobRegServerRecord.LOB_Award_Type__c = 'All Accounts' ; 
     lobRegServerRecord.Preferred_GTM_Partner_Account__c = partnerAcc.Id;              
     lobRegServerRecord.City__c = 'testCity';
     lobRegServerRecord.State_Province_Region__c = 'testState';      
     
     lobRegList.add(lobRegServerRecord);
     
     LOB_Registration__c lobRegNetworkingRecord = new LOB_Registration__c ();
     lobRegNetworkingRecord.LOB_Name__c ='Networking';             
     lobRegNetworkingRecord.Registered_End_User__c= EUacc.Id;
     lobRegNetworkingRecord.LOB_Partner_Approved_Date__c =system.today().addDays(-365);
     lobRegNetworkingRecord.LOB_registration_status__c = 'Partner(submit for approval)';
     lobRegNetworkingRecord.LOB_Award_Type__c = 'All Accounts' ; 
     lobRegNetworkingRecord.Preferred_GTM_Partner_Account__c = partnerAcc.Id;          
     lobRegNetworkingRecord.City__c = 'testCity';
     lobRegNetworkingRecord.State_Province_Region__c = 'testState';      
     
     lobRegList.add(lobRegNetworkingRecord);
     
     LOB_Registration__c lobRegStorageRecord = new LOB_Registration__c ();
     lobRegStorageRecord.LOB_Name__c ='Storage';             
     lobRegStorageRecord.Registered_End_User__c= EUacc.Id;
     lobRegStorageRecord.LOB_Partner_Approved_Date__c =system.today().addDays(-365);
     lobRegStorageRecord.LOB_registration_status__c = 'Expired';
     lobRegStorageRecord.City__c = 'testCity';
     lobRegStorageRecord.State_Province_Region__c = 'testState';          
     lobRegStorageRecord.LOB_Award_Type__c = 'All Accounts' ; 
     lobRegList.add(lobRegStorageRecord);
     
     insert lobRegList;
            
            Id DealRTId = IdLookupUtils.getRecordTypeId('Deal Registration-Submitted', 'Opportunity', true);
            List<Opportunity> oppList = new List<Opportunity>();
        
            Opportunity testOppty1 = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=EUacc.Id, 
                                                Deal_Registration_Status__c= 'Submitted',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = DealRTId,
                                                Stage_Changed_On__c= system.today().addDays(-365),
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
                                                //End_User_Account_Department__c = ab.Name,
                                                CloseDate = System.Today() + 30 ); 
            oppList.add(testOppty1);                                       

            Opportunity testOppty2 = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=EUacc.Id, 
                                                Deal_Registration_Status__c= 'Submitted',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = DealRTId,
                                                Stage_Changed_On__c= system.today().addDays(-365),
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
                                                //End_User_Account_Department__c = ab.Name,
                                                CloseDate = System.Today() + 30 );                                                        

            oppList.add(testOppty2);           
            Opportunity testOppty3 = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=EUacc.Id, 
                                                Deal_Registration_Status__c= 'Submitted',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = DealRTId,
                                                Stage_Changed_On__c= system.today().addDays(-365),
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
                                                //End_User_Account_Department__c = ab.Name,
                                                CloseDate = System.Today() + 30 ); 
            oppList.add(testOppty3);                                       

            Opportunity testOppty4 = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=EUacc.Id, 
                                                Deal_Registration_Status__c= 'Submitted',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = DealRTId,
                                                Stage_Changed_On__c= system.today().addDays(-365),
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
                                                //End_User_Account_Department__c = ab.Name,
                                                CloseDate = System.Today() + 30 );                                                        

            oppList.add(testOppty4);                                       
           // Test.StartTest();
            insert oppList;
            LOBRRegistrationScheduleExecute lobse = new LOBRRegistrationScheduleExecute();
            String sch = '0 0 23 * * ?';
            DateTime systime= System.now();
            system.schedule('LOB Registration'+string.valueof(systime), sch, lobse);
            Test.stopTest();
            
   }
    private static testmethod void TestLOBRRegistrationScheduleExecutewithoutoppassociated(){
    TriggerExecutionController.setSkipAllTriggers(true);   
     Test.StartTest();       
     Id endUserAccountRT = [select Name from RecordType where Name ='End-User Account' limit 1].Id;
     Id partnerAccountRT = [select Name from RecordType where Name ='Partner Account' limit 1].Id;

     Account EUacc = new Account();
     EUacc.Name = 'Test Account';
     EUacc.Participating_in_LOB_Program__c = true;
     EUacc.RecordTypeId = endUserAccountRT;
     EUacc.Account_Country__c = 'UNITED STATES';
     EUacc.ShippingStreet = '12';
     EUacc.ShippingCity = 'testStreet';
     EUacc.ShippingState = 'testTexas';
     EUacc.ShippingPostalCode = '1324';
     EUacc.Tax_Registration_Number__c = '124214';
     insert EUacc;
     
     Contact EUCon = new Contact();
     EUCon.FirstName = 'testFirstName';
     EUCon.LastName = 'testLastName';
     EUCon.Email = 'test@test.com';
     EUCon.Phone = '1234';
     EUCon.AccountId = EUacc.Id;
     insert EUCon;
     EUacc.Primary_Contact__c = EUCon.Id;
     update EUacc;
     
     Account partnerAcc = new Account();
     partnerAcc.Name = 'Test Account1';
     partnerAcc.Is_GTM_Partner__c = true;
     partnerAcc.RecordTypeId = partnerAccountRT;
     insert partnerAcc;
        
     /*Account_Branch__c ab = new Account_Branch__c();
     ab.Account__c = EUacc.id;
     ab.Name = 'Test Branch';
     insert ab;*/
             
            
     List<LOB_Registration__c> lobRegList = new List<LOB_Registration__c>();
                
     LOB_Registration__c lobRegClientRecord = new LOB_Registration__c ();
     lobRegClientRecord.LOB_Name__c ='Client';             
     lobRegClientRecord.Registered_End_User__c= EUacc.Id;
     lobRegClientRecord.LOB_Partner_Approved_Date__c =system.today().addDays(-1);
     lobRegClientRecord.LOB_registration_status__c = 'Partner(approved)';
     lobRegClientRecord.LOB_Award_Type__c = 'All Accounts' ; 
     lobRegClientRecord.Preferred_GTM_Partner_Account__c = partnerAcc.Id;          
     lobRegClientRecord.GTM_Linkage_Expiry_Date__c =system.today().addDays(35); 
     lobRegClientRecord.City__c = 'testCity';
     lobRegClientRecord.State_Province_Region__c = 'testState';      
     
     lobRegList.add(lobRegClientRecord);
     
     LOB_Registration__c lobRegServerRecord = new LOB_Registration__c ();
     lobRegServerRecord.LOB_Name__c ='Server';             
     lobRegServerRecord.Registered_End_User__c= EUacc.Id;
     lobRegServerRecord.LOB_Partner_Approved_Date__c =system.today().addDays(-275);
     lobRegServerRecord.GTM_Linkage_Expiry_Date__c =system.today().addDays(35);
     lobRegServerRecord.LOB_registration_status__c = 'Partner(approved)';
     lobRegServerRecord.LOB_Award_Type__c = 'All Accounts' ; 
     lobRegServerRecord.Preferred_GTM_Partner_Account__c = partnerAcc.Id;              
     lobRegServerRecord.City__c = 'testCity';
     lobRegServerRecord.State_Province_Region__c = 'testState';      
     
     lobRegList.add(lobRegServerRecord);
     
     insert lobRegList;
            
            /*Id DealRTId = IdLookupUtils.getRecordTypeId('Deal Registration-Submitted', 'Opportunity', true);
            List<Opportunity> oppList = new List<Opportunity>();
        
            Opportunity testOppty1 = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=EUacc.Id, 
                                                Deal_Registration_Status__c= 'Approved',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = DealRTId,
                                                Stage_Changed_On__c= system.today().addDays(-10),
                                                Engagement_Type__c = 'Public Tender',
                                                Justification_Statement__c = 'Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'Country',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                End_User_First_Name__c = 'Fi rst Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                                Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                StageName = 'Win - 100%',
                                                Probability = 100,
                                                Reason_Won_Lost__c = 'Incumbent',
                                                Competitor_Lost_To__c ='3i-Infotech',
                                                Region__c = 'APJ',
                                                Direct_Account_Name__c = EUacc.Id,
                                                 
                                                //End_User_Account_Department__c = ab.Name,
                                                LOB_Registration_ID__c = lobRegList[0].Id+';'+lobRegList[1].Id,
                                                CloseDate = System.Today() + 30 ); 
            oppList.add(testOppty1);                                       
            
            insert oppList;*/
         // Test.StartTest();
         LOBRRegistrationScheduleExecute lobse = new LOBRRegistrationScheduleExecute();
            String sch = '0 0 23 * * ?';
            DateTime systime= System.now();
            system.schedule('LOB Registration'+string.valueof(systime), sch, lobse);
            Test.stopTest();
            
   }
}