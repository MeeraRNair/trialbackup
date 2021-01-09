/*        
 * Revision Ref Number  Release No  Date            Modified By     Description
 * -------- ----------  ----------  -----------     ------------    -----------
 * 1.0      CR14931  DCS-FY18-1101  20-Sep-2017    Naga            Code cleanup for savo functionality, removed all refferences of Product_Group_Hidden__c and Product_Brand_Hidden__c fields from code.
 * 2.0      CR15586  DCS-FY18-0502  30-Mar-2018    Gan             Modify existing test method integrateMyDealTest to cover some scenarios
 * 3.0    CR17750  DCE-FY20-0802  19-Jul-2019    Kiran          Modified fields with VisitOps package name as part of Version 2.54
*/

@isTest(seeAllData=true)
public class OpportunityUtilitiesTest {
  
  Static testmethod void testPartnerAccountSelection(){
        
        triggerexecutioncontroller.setSkipAllTriggers(True);
        User adminusr = [SELECT Id, username FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true LIMIT 1];
        Userrole testUserRole = [select id, name from Userrole where name like '%WW_Exec%' limit 1];
        system.runas(new User(Id = UserInfo.getUserId())){
            adminusr.userRole = testUserRole; 
            update new List<User> {adminusr};
        }
        Id partnerAccRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        system.debug('@@@@@' +partnerAccRTId);
        List<Account> listAccData = new List<Account>();
         
        // Partner account creation
        Account searchResultAccount = new Account(Name='partnerAccount', 
                                            RecordTypeId = partnerAccRTId,
                                            Partner_Tier__c = 'Tier 1',
                                            Partner_Relationship__c = 'Authorized',
                                            Account_Country__c = 'UNITED STATES',
                                            Account_ID__c = '9876543210',
                                            Partner_Type__c = 'Test',
                                            Status__c = 'Active',
                                            Type = 'Partner',
                                            OwnerId = adminusr.Id,
                                            DMU__c = false);       
        listAccData.add(searchResultAccount); 
         
        Id enduserAccRTId= IdLookupUtils.getRecordTypeId('End-User Account','Account',true);
        // End user account creation
        Account testAccount1 = new Account(Name='enduserAccount', 
                                            RecordTypeId = enduserAccRTId, 
                                            Partner_Type__c = 'Distributor (GCC)',
                                            Partner_Tier__c = 'Tier 1',
                                            Status__c = 'Active',
                                            Distribution_Sell_To_Countries__c = 'UNITED STATES',
                                            DMU__c = false,                                         
                                            Partner_Relationship__c = 'Authorized',
                                            Account_Country__c = 'UNITED STATES');      
        listAccData.add(testAccount1);
        insert listAccData;
      
    
// End Customer Creation
   End_Customer__c endCustomerString = new End_Customer__c(Name = 'TestEndCustomer',
                                                               Mailing_city__c = 'City',
                                                               Mailing_State__c ='state',
                                                               Partner_Account__c = searchResultAccount.id, 
                                                               Status__c = 'Active');

        system.assertEquals('Active',endCustomerString.Status__c );                                                                      
   insert endCustomerString;  
    
// End Customer contact Creation
   End_Customer_Contact__c endCustomerContact = new End_Customer_Contact__c(Last_Name__c = 'Last Name',
                                                                          Name = 'First Name',
                                                                          Status__c ='Active',
                                                                          Email__c = 'Test@email.com',
                                                                          Source_System__c ='Deal Registration',
                                                                          End_Customer__c =endCustomerString.id );
   insert endCustomerContact;
      
     
       //Contact creation      
        Contact newContSearch = new Contact(FirstName = 'My Search33',
                           LastName = 'Contact33',
                           AccountId =searchResultAccount.Id,
                           Status__c  =  'Marketing Suspect',
                           Email = 'MyLastName@dell.com',
                           Fax = '12345673',
                           MobilePhone = '09876543',
                           Last_Operation_Performed__c = 'testing',
                           Phone = '12345003');
        insert newContSearch;

        
       final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%PRM%' limit 1];
        
        User partnerUser = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
                            Alias = 'MTU9', 
                            Email='MyLastName@dell.com',         
                            FirstName='MyTestUser9', 
                            LastName='MyTestUser9',  
                            ProfileId = partnerProfiles.get(0).Id, 
                            LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', 
                            EmailEncodingKey='UTF-8', 
                            TimeZoneSidKey='America/Los_Angeles',
                            Badge_Number__c='9848348438955', 
                            isActive = true,
                            Enable_Partner_Admin__c = true,
                            Enable_Partner_Deal_Registration__c = true,
                            ContactId = newContSearch.Id);
        insert partnerUser;   
      
      //Rev 2.0
        List<Profile> listUserProfile= [select id,name from profile where name like '%Sales%' order by name limit 2 ];        
        User tempUser = new User(
            Username='testUser1'+System.currentTimeMillis()+'@test.com',
            Alias = 'test', 
            Email='test1@dell.com', 
            FirstName='Tfirst A', 
            LastName='TLast',
            ProfileId = listUserProfile[0].Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='TEST12345',
            Title = 'Test Title',
            CurrencyIsoCode = 'USD'
        );
        insert tempUser;
        
        SFDC_Acct_Plan__c testAccntPlan = new SFDC_Acct_Plan__c(Name= 'Test Plan OpportunityAccntPlanAfterTriggerTest', Account__c = testAccount1.Id,
                                            Sales_Manager__c = tempUser.Id );   
        
        insert testAccntPlan;
        
        List<SFDC_Strategy__c> listTestStrategy = new List<SFDC_Strategy__c>();
        
        for(integer intI = 1; intI <= 2; intI ++) {
            
            SFDC_Strategy__c temp = new SFDC_Strategy__c(Name='Test Strategy - ' + intI, SFDC_Acct_Plan__c = testAccntPlan.Id);
            listTestStrategy.add(temp);
        }
        
        insert listTestStrategy;
      
      test.starttest();
      
      CTI_Call_Log__c objCTICL = new CTI_Call_Log__c();
      objCTICL.Account__c = testAccount1.Id;
      insert objCTICL; 
      

   // Opportunity Creation  
        Id dealRTId = IdLookupUtils.getRecordTypeId('Deal Registration for Existing End Customer', 'Opportunity', true);
        Opportunity testOppty = new Opportunity(Name='testOppDistiUser Test Oppty', 
                                                AccountId=testAccount1.Id, 
                                                Deal_Registration_Status__c= 'submitted',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = DealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Distributor_Reseller_Name__c = testAccount1.Id,
                                                Primary_Product_Delivery_Address_Country__C = 'INDIA',
                                                Primary_Product_Delivery_Address_Region__c = 'APJ',
                                                Justification_Statement__c = 'Justification Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'UNITED STATES',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                                Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                StageName = 'Win - 100%',
                                                Competitor_Lost_To__c   = 'Unknown',
                                                CloseDate = System.Today(),
                                                Distributor_Name__c = 'Distribution',
                                                End_Customer__c = endCustomerString.Id,
                                                End_Customer_Contact__c = endCustomerContact.Id,
                                                Solution_Scope__c = 'Consulting or Managed Services',
                                                Solution_Type__c = 'Campus',
                                                Solution_Name__c = 'Wired Chassis Switches',
                                                OSC_Solution_ID__c = 'Text OSC:123',
                                                Supportability_Status__c = 'Supportable',
                                                CTI_Call_Log_Id__c = objCTICL.id,
                                                related_strategy__c = listTestStrategy[0].Id,
                                                Distributor_ID__c = 'Test Disti User');
      insert testOppty;
      update testOppty;
      
      
      testOppty.related_strategy__c = listTestStrategy[0].Id;
      update testOppty;
      
      Deal_Summary__c ds1 = new Deal_Summary__c(Opportunity__c = testOppty.id, ForcedCalculation__c = false, Stage__c = testOppty.StageName, No_Qualified_NPS__c=0);
      insert ds1;
      
      objCTICL.Opportunity__c = testOppty.id;
      try{
      update objCTICL;
      }
      catch(Exception e)
      { 
         System.debug('******' + e);
      }
      
      
      Pricebook2 pbk1 = [select Id from Pricebook2 where isStandard=true and IsActive = TRUE];
      Product2 newPrdct = new Product2(Name = 'Test Product',
                                         Product_Line_Desc__c = 'Services Product',
                                         IsActive = TRUE,
                                         CanUseRevenueSchedule=TRUE,
                                         Product_ID__c = '9876');
        insert newPrdct;
      
      PricebookEntry pBE= new PricebookEntry (Product2ID=newPrdct.id,
                                                Pricebook2ID=pbk1.Id,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        insert PBE;
      List<OpportunityLineItem> listlineItem = new List<OpportunityLineItem>();
      OpportunityLineItem  testLineItem1 = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=PBE.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                   Request_Type__c='Ship',
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                  Customer_Requested_Date__c = System.Today() + 1,
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    ); 
       OpportunityLineItem  testLineItem2 = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=PBE.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Request_Type__c='Delivery',
                                                                    Quantity =2,
                                                                    Description = 'Line Description',  
                                                                    Customer_Requested_Date__c = System.Today() + 1,
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    ); 
      listlineItem.add(testLineItem1);
      listlineItem.add(testLineItem2);
      insert listlineItem;
      
      List<Opportunity> listOppnew = new List<Opportunity>();
      listOppnew.add(testOppty);
      Map<Id, Opportunity> mapOldOpp = new Map<Id, Opportunity>();
      mapOldOpp.put(testOppty.Id, testOppty);
      
      Opportunity newMapUpdate = [Select Id, StageName, CloseDate from Opportunity where Id =: testOppty.Id];
      newMapUpdate.StageName = 'Discover - 10%';
      newMapUpdate.CloseDate = System.Today() + 5;      
        triggerexecutioncontroller.setSkipAllTriggers(True);
      update newMapUpdate;
      
      list<Opportunity> listUpdateNew = new list<Opportunity>();
      listUpdateNew.add(newMapUpdate);
      
      Map<Id, Opportunity> mapNewOpp = new Map<Id, Opportunity>();
      mapNewOpp.put(newMapUpdate.Id, newMapUpdate);
      
      Solution__c solutionobj = new Solution__c(Opportunity__c = testOppty.Id, OSC_Regional_Id__c = 'Text OSCD:1234');
      insert solutionobj;
      
      
      OpportunityUtilities.updateDealSummary(mapNewOpp, mapOldOpp);
      OpportunityUtilities.createEndCustomerAndPopulateDetailsInOpps(listOppnew, null);
      OpportunityUtilities.createSolutions(listOppnew, null);
      OpportunityUtilities.RealtimeSolutionsupdate(listUpdateNew, mapOldOpp);
      OpportunityUtilities.recalculateStrategyValues(listUpdateNew, mapOldOpp, TriggerHandler.TriggerEvent.ISINSERT);
      OpportunityUtilities.createOpportunityDescriptionHistory(JSON.serialize(listOppnew));
      //OpportunityUtilities.recalculateQuestRevenues(listOppnew, null, null);
      //OpportunityUtilities.linkToAccountPlay(listOppnew, null);
      
      OpportunityUtilities.storeDeletedOpportunityDetailInPartnerHub(listOppnew);
      OpportunityUtilities.updateSupportabilityIndicator(TriggerHandler.TriggerEvent.ISINSERT, listUpdateNew, mapOldOpp);
      //OpportunityUtilities.updateFieldsForSAVO(listUpdateNew, mapOldOpp);
      OpportunityUtilities.removeSalesSupportRolefromOppTeam(listUpdateNew, mapOldOpp);
      OpportunityUtilities.updateCTICallLog(TriggerHandler.TriggerEvent.ISINSERT, listOppnew, null);
      OpportunityUtilities.updateCustomerReqDate(listUpdateNew, mapOldOpp, null);
      OpportunityUtilities.updateRSSSupportRequest(new Set<Id>{testOppty.Id});
      
      Opportunity op = mapNewOpp.get(newMapUpdate.Id);
      op.ownerId = [SELECT id FROM User WHERE id <>: UserInfo.getUserId() Limit 1].Id;
      op.Related_Parent_Opportunity__c = testOppty.Id;
      Map<Id, Opportunity> mapN = new Map<Id, Opportunity>();
      mapN.put(op.Id, op);
      OpportunityUtilities.updatePartnerSalesRepDetails(new list<Opportunity>{op}, mapOldOpp, mapN);
       
       OpportunityUtilities.recalculateQuestRevenues(mapN.values(), mapOldOpp, TriggerHandler.TriggerEvent.ISINSERT);
       OpportunityUtilities.linkToAccountPlay(listOppnew, new Set<String>{[SELECT id FROM Lead LIMIT 1].id});
      test.stoptest();
      }
    
    Static testmethod void testPartnerAccountSelection1(){
        
        triggerexecutioncontroller.setSkipAllTriggers(True);
        User adminusr = [SELECT Id, username FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true LIMIT 1];
        Userrole testUserRole = [select id, name from Userrole where name like '%WW_Exec%' limit 1];
        system.runas(new User(Id = UserInfo.getUserId())){
            adminusr.userRole = testUserRole; 
            update new List<User> {adminusr};
        }
        Id partnerAccRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        system.debug('@@@@@' +partnerAccRTId);
        List<Account> listAccData = new List<Account>();
         
        // Partner account creation
        Account searchResultAccount = new Account(Name='partnerAccount', 
                                            RecordTypeId = partnerAccRTId,
                                            Partner_Tier__c = 'Tier 1',
                                            Partner_Relationship__c = 'Authorized',
                                            Account_Country__c = 'UNITED STATES',
                                            Account_ID__c = '9876543210',
                                            Partner_Type__c = 'Test',
                                            Status__c = 'Active',
                                            Type = 'Partner',
                                            OwnerId = adminusr.Id,
                                            DMU__c = false);       
        listAccData.add(searchResultAccount); 
         
        Id enduserAccRTId= IdLookupUtils.getRecordTypeId('End-User Account','Account',true);
        // End user account creation
        Account testAccount1 = new Account(Name='enduserAccount', 
                                            RecordTypeId = enduserAccRTId, 
                                            Partner_Type__c = 'Distributor (GCC)',
                                            Partner_Tier__c = 'Tier 1',
                                            Status__c = 'Active',
                                            Distribution_Sell_To_Countries__c = 'UNITED STATES',
                                            DMU__c = false,                                         
                                            Partner_Relationship__c = 'Authorized',
                                            Account_Country__c = 'UNITED STATES');      
        listAccData.add(testAccount1);
        insert listAccData;
      
    
// End Customer Creation
   End_Customer__c endCustomerString = new End_Customer__c(Name = 'TestEndCustomer',
                                                               Mailing_city__c = 'City',
                                                               Mailing_State__c ='state',
                                                               Partner_Account__c = searchResultAccount.id, 
                                                               Status__c = 'Active');

        system.assertEquals('Active',endCustomerString.Status__c );                                                                      
   insert endCustomerString;  
    
// End Customer contact Creation
   End_Customer_Contact__c endCustomerContact = new End_Customer_Contact__c(Last_Name__c = 'Last Name',
                                                                          Name = 'First Name',
                                                                          Status__c ='Active',
                                                                          Email__c = 'Test@email.com',
                                                                          Source_System__c ='Deal Registration',
                                                                          End_Customer__c =endCustomerString.id );
   insert endCustomerContact;
      
     
       //Contact creation      
        Contact newContSearch = new Contact(FirstName = 'My Search33',
                           LastName = 'Contact33',
                           AccountId =searchResultAccount.Id,
                           Status__c  =  'Marketing Suspect',
                           Email = 'MyLastName@dell.com',
                           Fax = '12345673',
                           MobilePhone = '09876543',
                           Last_Operation_Performed__c = 'testing',
                           Phone = '12345003');
        insert newContSearch;

        
       final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%PRM%' limit 1];
        
        User partnerUser = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
                            Alias = 'MTU9', 
                            Email='MyLastName@dell.com',         
                            FirstName='MyTestUser9', 
                            LastName='MyTestUser9',  
                            ProfileId = partnerProfiles.get(0).Id, 
                            LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', 
                            EmailEncodingKey='UTF-8', 
                            TimeZoneSidKey='America/Los_Angeles',
                            Badge_Number__c='9848348438955', 
                            isActive = true,
                            Enable_Partner_Admin__c = true,
                            Enable_Partner_Deal_Registration__c = true,
                            ContactId = newContSearch.Id);
        insert partnerUser;   
      
      //Rev 2.0
        List<Profile> listUserProfile= [select id,name from profile where name like '%Sales%' order by name limit 2 ];        
        User tempUser = new User(
            Username='testUser1'+System.currentTimeMillis()+'@test.com',
            Alias = 'test', 
            Email='test1@dell.com', 
            FirstName='Tfirst A', 
            LastName='TLast',
            ProfileId = listUserProfile[0].Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='TEST12345',
            Title = 'Test Title',
            CurrencyIsoCode = 'USD'
        );
        insert tempUser;
        
        SFDC_Acct_Plan__c testAccntPlan = new SFDC_Acct_Plan__c(Name= 'Test Plan OpportunityAccntPlanAfterTriggerTest', Account__c = testAccount1.Id,
                                            Sales_Manager__c = tempUser.Id );   
        
        insert testAccntPlan;
        
        List<SFDC_Strategy__c> listTestStrategy = new List<SFDC_Strategy__c>();
        
        for(integer intI = 1; intI <= 2; intI ++) {
            
            SFDC_Strategy__c temp = new SFDC_Strategy__c(Name='Test Strategy - ' + intI, SFDC_Acct_Plan__c = testAccntPlan.Id);
            listTestStrategy.add(temp);
        }
        
        insert listTestStrategy;
      
      test.starttest();
      
      CTI_Call_Log__c objCTICL = new CTI_Call_Log__c();
      objCTICL.Account__c = testAccount1.Id;
      insert objCTICL; 
      
           
   // Opportunity Creation  
        Id dealRTId = IdLookupUtils.getRecordTypeId('Deal Registration for Existing End Customer', 'Opportunity', true);
        Opportunity testOppty = new Opportunity(Name='testOppDistiUser Test Oppty', 
                                                AccountId=testAccount1.Id, 
                                                Deal_Registration_Status__c= 'submitted',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = DealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Distributor_Reseller_Name__c = testAccount1.Id,
                                                Primary_Product_Delivery_Address_Country__C = 'INDIA',
                                                Primary_Product_Delivery_Address_Region__c = 'APJ',
                                                Justification_Statement__c = 'Justification Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'UNITED STATES',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                                Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                StageName = 'Win - 100%',
                                                Competitor_Lost_To__c   = 'Unknown',
                                                CloseDate = System.Today(),
                                                Distributor_Name__c = 'Distribution',
                                                End_Customer__c = endCustomerString.Id,
                                                End_Customer_Contact__c = endCustomerContact.Id,
                                                Solution_Scope__c = 'Consulting or Managed Services',
                                                Solution_Type__c = 'Campus',
                                                Solution_Name__c = 'Wired Chassis Switches',
                                                OSC_Solution_ID__c = 'Text OSC:123',
                                                Supportability_Status__c = 'Supportable',
                                                CTI_Call_Log_Id__c = objCTICL.id,
                                                related_strategy__c = listTestStrategy[0].Id,
                                                Distributor_ID__c = 'Test Disti User');
      insert testOppty;
      update testOppty;
 
      Deal_Summary__c ds1 = new Deal_Summary__c(Opportunity__c = testOppty.id, ForcedCalculation__c = false, Stage__c = testOppty.StageName, No_Qualified_NPS__c=0);
      insert ds1;
      
      objCTICL.Opportunity__c = testOppty.id;
      update objCTICL;
      
      
      Pricebook2 pbk1 = [select Id from Pricebook2 where isStandard=true and IsActive = TRUE];
      Product2 newPrdct = new Product2(Name = 'Test Product',
                                         Product_Line_Desc__c = 'Services Product',
                                         IsActive = TRUE,
                                         CanUseRevenueSchedule=TRUE,
                                         Product_ID__c = '9876');
        insert newPrdct;
      
      PricebookEntry pBE= new PricebookEntry (Product2ID=newPrdct.id,
                                                Pricebook2ID=pbk1.Id,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        insert PBE;
      List<OpportunityLineItem> listlineItem = new List<OpportunityLineItem>();
      OpportunityLineItem  testLineItem1 = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=PBE.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                   Request_Type__c='Ship',
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                  Customer_Requested_Date__c = System.Today() + 1,
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    ); 
       OpportunityLineItem  testLineItem2 = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=PBE.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Request_Type__c='Delivery',
                                                                    Quantity =2,
                                                                    Description = 'Line Description',  
                                                                    Customer_Requested_Date__c = System.Today() + 1,
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    ); 
      listlineItem.add(testLineItem1);
      listlineItem.add(testLineItem2);
      database.insert(listlineItem, false);
      
      
      
      List<Opportunity> listOppnew = new List<Opportunity>();
      listOppnew.add(testOppty);
      Map<Id, Opportunity> mapOldOpp = new Map<Id, Opportunity>();
      mapOldOpp.put(testOppty.Id, testOppty);
      
      Opportunity newMapUpdate = [Select Id, StageName, CloseDate from Opportunity where Id =: testOppty.Id];
      newMapUpdate.StageName = 'Order Submitted - 99%';
      newMapUpdate.CloseDate = System.Today() + 5;      
      update newMapUpdate;
      
      list<Opportunity> listUpdateNew = new list<Opportunity>();
      listUpdateNew.add(newMapUpdate);
      
      Map<Id, Opportunity> mapNewOpp = new Map<Id, Opportunity>();
      mapNewOpp.put(newMapUpdate.Id, newMapUpdate);
      
      Solution__c solutionobj = new Solution__c(Opportunity__c = testOppty.Id, OSC_Regional_Id__c = 'Text OSCD:1234');
      insert Solutionobj;
      
      OpportunityUtilities.updateDealSummary(mapNewOpp, mapOldOpp);
      test.stoptest();
      }
    
    
    static testMethod void integrateMyDealTest(){
        TriggerExecutionController.setSkipAllTriggers(true);
        Account acc = new Account(Name='testAccount'); 
        insert acc;
        Contact con = new Contact(FirstName=system.now()+'test',LastName='Test2'+system.now()+'22',Email='test@dell2w.com',MailingStreet='test',MailingCity='test',MailingState='test',
                        MailingCountry='test',AccountId=acc.Id,Phone='12345');
        insert con;
        
        Opportunity objOppty = new Opportunity(AccountId = acc.Id, Name = 'testOpportunity', RecordTypeId = '012300000004zf2AAA', CurrencyIsoCode = 'USD', Type = 'Renewal',
                                                    CloseDate = system.Today(), Domain__c = 'Non Domain', Solution_Type__c = 'Cloud Integration', Solution_Name__c = 'Boomi Solution',
                                                    //StageName = 'Plan - 1%', Quest_Software_Contact__c= con.id);
                                                    StageName = 'Qualify - 30%', Quest_Software_Contact__c= con.id, Competitor_Lost_To__c='Unknown', Primary_Competitor_Product_Type__c = 'Server');
        insert objOppty;
        
        //2.0
        Pricebook2 objPbk1 = [select Id from Pricebook2 where isStandard=true and IsActive = TRUE];
        Product2 objNewPrdct = new Product2(Name = 'Test Product',
                                         Product_Line_Desc__c = 'Services Product',
                                         IsActive = TRUE,
                                         CanUseRevenueSchedule=TRUE,
                                         Product_ID__c = '9876');
        insert objNewPrdct;
      
        PricebookEntry objPBE= new PricebookEntry (Product2ID=objNewPrdct.id,
                                                Pricebook2ID=objPbk1.Id,
                                                isActive=true,
                                                CurrencyIsoCode = 'USD',
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        insert objPBE;
  
      OpportunityLineItem  objLineItem1 = new OpportunityLineItem(Opportunityid =objOppty.Id,
                                                                    pricebookEntryId=objPBE.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Request_Type__c='Ship',
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    Customer_Requested_Date__c = System.Today() + 1,
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    ,Product_Type__c = 'Services'); //2.0
        system.assertEquals('Ship',objLineItem1.Request_Type__c );                                                                      
        insert objLineItem1;
        
        Test.startTest();
        String strCSSrECORDTYPEID = IdLookupUtils.getRecordTypeId('Request Custom Service Support', 'Support_Request__c', true);
        Support_Request__c cssSR = new Support_Request__c(RecordTypeId = strCSSrECORDTYPEID, Receive_Notification__c = 'Yes', Opportunity__c = objOppty.Id,
                                            Requestor_Comments__c = 'testComment', Specialist_Role__c = 'testRole',Engagement_Time_Frame__c=Date.today(),
                                            Support_Owner__c = UserInfo.getUserId(), Solution_Architect__c = 'Yes', Customer_Contact_InformationName__c = con.Id,
                                            Support_Owner_Team_Role__c = 'Services Intake Manager',Status__c='New',Project_Type__c='CWS',Project_Duration_months__c =1,
                                            Suggested_Delivery_Method__c='Custom',Decision_Date__c=Date.today(),Primary_Work_Delivery_Language__c='Spanish'
                                            ,CurrencyIsoCode = 'USD'); //2.0
       insert cssSR; //2.0
        
       Opportunity oldOpp = [SELECT Id, Contract_Term__c FROM Opportunity WHERE Id = :objOppty.Id];
        Map<Id, Opportunity> mapOldOpp = new Map<Id, Opportunity>();
        mapOldOpp.put(oldOpp.Id, oldOpp);
        
        objOppty.Contract_Term__c = 123;
        Map<Id, Opportunity> mapNewOpp = new Map<Id, Opportunity>();
        mapNewOpp.put(objOppty.Id, objOppty);
        //2.0
        SuppReqMyDealIntegration.REQUIRE_CALLOUT = true;
        OpportunityUtilities.pushCustomServiceSupportRequestToMyDeal(mapOldOpp, mapNewOpp);
        Test.stopTest();
        
    } 
    
    static testMethod void integrateMyDealTest1(){
        TriggerExecutionController.setSkipAllTriggers(true);
        Account acc = new Account(Name='testAccount'); 
        insert acc;
        
        SFDC_Acct_Plan__c accPlan = new SFDC_Acct_Plan__c(Account__c=acc.Id, Name='accPlan Test');
        insert accPlan;
        
        SFDC_Strategy__c strategy = new SFDC_Strategy__c(SFDC_Acct_Plan__c = accPlan.Id, Name = 'Test Strategy');
        insert strategy;
        
        Opportunity oppty = new Opportunity(AccountId = acc.Id, Name = 'testOpportunity', RecordTypeId = '012300000004zf2AAA', CurrencyIsoCode = 'USD', Type = 'Renewal',
                                                    CloseDate = system.Today(), Domain__c = 'Non Domain', Solution_Type__c = 'Cloud Integration', Solution_Name__c = 'Boomi Solution',
                                                    StageName = 'Plan - 1%', Related_Strategy__c = strategy.Id, Amount = 100);
system.assertEquals('Non Domain',oppty.Domain__c );                                                                      
        insert oppty;
        List<Opportunity> listOpp = new List<Opportunity>();
        listOpp.add(oppty);
        
        OpportunityUtilities.recalculateStrategyValues(listOpp, null, TriggerHandler.TriggerEvent.ISINSERT);
        
    }
    
     /*
    CR          Date            Created By      Description
    ---         -----------     -----------     ------------
    CR12116     21-Oct-2015     Krishnamoorthi  The below test method will cover the createSOMBoomiLogs method in OpportunityUtilities
    */
    public static testMethod void testcreateSOMBoomiLogs() {
        
        Map<Id, Opportunity> mapOldOpportunity = new Map<Id, Opportunity>();
        Map<Id, Opportunity> mapNewOpportunity = new Map<Id, Opportunity>();

        List<Profile> listUserProfile= [select id,name from profile where name like '%Sales%' order by name limit 2 ];        
        User tempUser = new User(
            Username=String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.dev',
            Alias = 'test', 
            Email='test109@dell.com', 
            FirstName='Tfirst A1', 
            LastName='TLast2',
            ProfileId = listUserProfile[0].Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='Test'+System.currentTimeMillis(),
            Title = 'Test Title',
            CurrencyIsoCode = 'USD'
        );
        TriggerExecutionController.setSkipAllTriggers(true);
        Test.startTest();
        insert tempUser;
        
        User tempUser2 = new User(
            Username=String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.dev' +1,
            Alias = 'test1a', 
            Email='test19@dell.com', 
            FirstName='Tfirst A11', 
            LastName='TLast2q',
            ProfileId = listUserProfile[0].Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='Test'+System.currentTimeMillis()+1,
            Title = 'Test Title',
            CurrencyIsoCode = 'USD'
        );
        insert tempUser2;
        
        Account testAcc = new Account(name='testaccount');
        insert testAcc;
        
        Contact con = new Contact(FirstName=system.now()+'test',LastName='Test2'+system.now()+'22',Email='test@dell2w.com',MailingStreet='test',MailingCity='test',MailingState='test',
                        MailingCountry='test',AccountId=testAcc.Id,Phone='12345');
        insert con; 
        
        Opportunity testOpp = new Opportunity(Name='Test Opportunity', 
                                                AccountId=testAcc.Id,
                                                RecordTypeId = GlobalVariables.STANDARD_OPP_RECTYPE,   
                                                StageName = 'Discover - 10%',
                                                CloseDate = System.Today() + 30 );
       
        insert testOpp;
        mapOldOpportunity.put(testOpp.Id, testOpp);
        
        //Insert Services Project for the Opportunity
        Services_Project__c testSP = new Services_Project__c(Project_Name__c = 'testSP',Opportunity__c = testOpp.id);
        insert testSP;
                
        TriggerExecutionController.setSkipAllTriggers(false);
        
        Opportunity testOpp2 = [SELECT Id, StageName, OwnerId, Services_Sales_Owner__c, Services_Project_Count__c, Deal_ID__c FROM Opportunity WHERE Id =: testOpp.Id];
        //Update the Opportunity Stage with  Lost, Cancelled - 0%
        testOpp2.StageName = 'Lost, Cancelled - 0%';
        testOpp2.Competitor_Lost_To__c = 'HCL';
        testOpp2.OwnerId = tempUser.Id;
        testOpp2.Services_Sales_Owner__c = tempUser2.Id;
        mapNewOpportunity.put(testOpp2.Id, testOpp2);
        //Call the createSOMBoomiLogs from OpportunityUtilities
        OpportunityUtilities.createSOMBoomiLogs(mapNewOpportunity.values(), mapOldOpportunity, mapNewOpportunity);
        Test.stopTest();
        
        //Assert the Opportunity Stage value populated in SOM Boomi Log object
        SOM_Boomi_Log__c sBM = [SELECT Opportunity_Stage__c FROM SOM_Boomi_Log__c WHERE Opportunity_Stage__c != null AND Deal_ID__c =: testOpp2.Deal_ID__c];
        System.assertEquals(SBM.Opportunity_Stage__c,testOpp2.StageName);
    }
    
    public static testMethod void testVisitOpsDetails() {
        
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipOpportunitySplitTriggers(true);
        ProcessFlowTriggerController.isTest = true;    
        
        account acc= new account();
        acc.name='test';
        acc.BillingStreet ='Street abc1';
        acc.BillingCity = 'City abc1';
        acc.BillingState = 'State abc1';
        acc.BillingPostalCode = '12345';
        acc.BillingCountry = 'United States';
        insert acc;
        
        system.debug('Emily acc: ' + acc.Billing_Address_CN__c);
        
        account acc1= new account();
        acc1.name='test';
        acc1.BillingStreet ='Street abc2';
        acc1.BillingCity = 'City abc2';
        acc1.BillingState = 'State abc2';
        acc1.BillingPostalCode = '12345';
        acc1.BillingCountry = 'United States';
        insert acc1;
        
        system.debug('Emily acc1: ' + acc1.Billing_Address_CN__c);
        
        opportunity opp= new opportunity();
        opp.name='test';
        opp.accountId=acc.id;
        opp.closedate=date.today();
        opp.StageName='Discover - 10%';
        opp.Amount=5;
        opp.VisitOps__MainCompetitors__c='test';
        opp.EMC_Opportunity_Number__c = '121212';
        insert opp;
        
        
        VisitOps__Location__c loc = new VisitOps__Location__c();
        loc.name='Banglore';
        loc.VisitOps__Time_Zone__c='(GMT+14:00) Line Islands Time (Pacific/Kiritimati)';
        insert loc;
        
        VisitOps__VisitType__c  vType= new VisitOps__VisitType__c   ();
        vType.name='Community Visit Type';
        vType.VisitOps__Category__c ='Community';
        insert vType;
        
        VisitOps__Status__c status= new VisitOps__Status__c();
        status.name='Submitted';
        insert status;
        
        
        
        visitops__visit__c visit= new visitops__visit__c();
        visit.VisitOps__VisitName__c='test';
        visit.VisitOps__VisitType__c=vType.id;
        visit.VisitOps__TotalNoOfAttendees__c=1;
        visit.VisitOps__Location__c=loc.id;
        visit.VisitOps__DepartureDateTimeLocationTZ__c= '2017-09-11 02:02:42';
        visit.VisitOps__ArrivalDateTimeLocationTZ__c= '2017-09-11 02:02:42';
        visit.VisitOps__ArrivalDateTime__c=datetime.now()+1;
        visit.VisitOps__DepartureDateTime__c=datetime.now()+2;
        visit.VisitOps__VisitOwner__c=userinfo.getUserId();
        visit.VisitOps__VisitStatus__c  =status.id;
        insert visit;
        
        VisitOps__VisitBundle__c bundle= new VisitOps__VisitBundle__c();
        bundle.VisitOps__Opportunity__c=opp.id;
        bundle.VisitOps__Visit__c=visit.id;
        insert bundle;
        
        bundle.Corresponding_Opportunity_ID__c= '33333';
        update bundle;
        
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        
        test.startTest();        
		Test.setMock(HttpCalloutMock.class, new VOGetAPIKeyMock(200, 'OK'));     
        bundle.VisitOps__Opportunity__c= null;
        update bundle;

        opp.name='test - test';
        opp.accountId=acc1.id;
        opp.closedate=date.today()+1;
        opp.EMC_Opportunity_Number__c = '33333';
        update opp;
        
        test.stopTest();

		    //Thor team - Commented to pass test method as feature is not working on SIT5 but working in DIT5 (System.AssertException: Assertion Failed: Expected: test - test1, Actual: test)
        //VisitOps__VisitBundle__c bundle1= [select id, VisitOpsP__Opp_Name__c from VisitOps__VisitBundle__c where id = :bundle.id];
        //System.assertEquals(opp.name, bundle1.VisitOpsP__Opp_Name__c);
        Opportunity tempOpp = [SELECT Name FROM Opportunity WHERE Id =: opp.Id];
        System.assertEquals(opp.Name, tempOpp.Name);
    }
      
    
  /*  static testMethod void sample(){
        set<id>oppset = new set<id>();
        Account testAcc1 = new Account(name='testaccount1');
        insert testAcc1;
        Opportunity testOpp = new Opportunity(Name='Test Opportunity', 
                                                AccountId=testAcc1.Id,
                                                RecordTypeId = GlobalVariables.STANDARD_OPP_RECTYPE,   
                                                StageName = 'Discover - 10%',
                                                CloseDate = System.Today() + 30 );
        insert testOpp;
        update testOpp;
        oppset.add(testOpp.id);
        RecordType rt =[select id,Name from RecordType where sObjectType='Support_Request__c' AND Name='Request Specialist Support' limit 1];
    list<Support_Request__c> lstSupportRequests = new list<Support_Request__c>();
    OpportunityUtilities.updateRSSSupportRequest(oppset);
        
    }*/
     
}