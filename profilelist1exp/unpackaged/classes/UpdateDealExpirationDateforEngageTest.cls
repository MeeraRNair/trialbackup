/*
 * Author   : Bikram
 * Purpose  : Test Class to Update Deal Expiration Date for Engage Channel Deals
 *
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      13212                       04th July 2016    Bikram        Update Deal Expiration Date for Engage Channel Deals
   2.0       16018     FY-19-DCS-0802        12.06.2018   Jatin          Commented NET exam logic statements as part of NET003 story
 * 
 */
@isTest(SeeAllData=true)
public class UpdateDealExpirationDateforEngageTest { 
  public static testMethod void testGreaterChina() {

   triggerexecutioncontroller.setSkipAllTriggers(True);
        Id partnerAccRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        system.debug('@@@@@' +partnerAccRTId);
        Partner_Request__c partnerReq = createPartnerRequest();
        List<Account> accData = new List<Account>();
  //Account #2
    Account testAccount2 = new Account(Name='testOppDistiUser Test Account', 
                                            RecordTypeId = partnerAccRTId, 
                                            Partner_Type__c = 'OEM',
                                            Partner_Tier__c = 'Tier 1',
                                            Account_ID__c = '987654321011',
                                            Status__c = 'Active',
                                            Distribution_Sell_To_Countries__c = 'UNITED STATES',
                                            DMU__c = false,                                         
                                            Partner_Relationship__c = 'Premier',
                                            Account_Country__c = 'china',
                                            Partner_Registration__c = partnerReq.Id );        
        
        insert testAccount2;   
        
  //Contact #2        
       Contact newContSearch2 = new Contact(FirstName = 'My Search',
                           LastName = 'Contact3333',
                           AccountId =testAccount2.Id,
                           Status__c  =  'Marketing Suspect333',
                           Email = 'MyLastNae@dell.com3',
                           Fax = '1234567333',
                           MobilePhone = '098765433333',
                           Last_Operation_Performed__c = 'testing',
                           Phone = '12345003333');
        insert newContSearch2;
    //User#2
     final List<Profile> partnerProfiles1 = [select Id, Name from Profile where name like '%Greater %' limit 1];
        
        User partnerUser2 = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
                            Alias = 'MTU9', 
                            Email='MyLastName@dell.com2',         
                            FirstName='MyTestUser93', 
                            LastName='MyTestUser93',  
                            ProfileId = partnerProfiles1.get(0).Id, 
                            LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', 
                            EmailEncodingKey='UTF-8', 
                            TimeZoneSidKey='America/Los_Angeles',
                            Badge_Number__c='Test846258',
                            Enable_Partner_Admin__c = true,
                            isActive = true,
                            Enable_Partner_Deal_Registration__c = true,
                            ContactId = newContSearch2.Id);
        insert partnerUser2;
      
    // Partner account creation
        Account searchResultAccount = new Account(Name='partnerAccount', 
                                            RecordTypeId = partnerAccRTId,
                                            Partner_Tier__c = 'Tier 2',
                                            Partner_Relationship__c = 'Premier',
                                            Account_Country__c = 'china',
                                            Account_ID__c = '9876543210',
                                            Partner_Type__c = 'COMMERCIAL',      
                                           // Partner_Type__c = 'Commercial Distributor',
                                            Status__c = 'Active',
                                            DMU__c = false,        
                                            Partner_Registration__c = partnerReq.Id ); 
        accData.add(searchResultAccount); 
         
        Id enduserAccRTId= IdLookupUtils.getRecordTypeId('End-User Account','Account',true);
        // End user account creation
        Account testAccount1 = new Account(Name='enduserAccount', 
                                            RecordTypeId = enduserAccRTId, 
                                           // Partner_Type__c = 'Commercial Distributor',
                                            Partner_Type__c = 'COMMERCIAL',
                                            Partner_Tier__c = 'Tier 2',
                                            Status__c = 'Active',
                                            Distribution_Sell_To_Countries__c = 'china',
                                            DMU__c = false,                                         
                                            Partner_Relationship__c = 'Premier',
                                            Account_Country__c = 'china',
                                            Partner_Registration__c = partnerReq.Id );        
        accData.add(testAccount1);
        insert accData;
     
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

        Contact newCont = new Contact(FirstName = 'MyTestContact9',
                           LastName = 'MyTestContact9',
                           AccountId =testAccount1.Id,
                           Status__c  =  'Marketing Suspect',
                           Email = 'MyTestContactEmail_9@ust-global.com',
                           Fax = '1234567',
                           MobilePhone = '0987654',
                           Last_Operation_Performed__c = 'testing',
                           Phone = '1234500');
        insert newCont;
      
       final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%prm%' limit 1];
       // final List<Profile> partnerProfiles = [select id from profile where name='System Administrator' Limit 1];
        User partnerUser = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
                            Alias = 'MTU9', 
                            Email='MyTestUser9@dell.com', 
                            FirstName='MyTestUser9', 
                            LastName='MyTestUser9',  
                            ProfileId = partnerProfiles.get(0).Id, 
                            LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', 
                            EmailEncodingKey='UTF-8', 
                            TimeZoneSidKey='America/Los_Angeles',
                            Badge_Number__c='Test99826513', 
                            isActive = TRUE,
                            //IsPortalEnabled = TRUE,
                            //AccountId = testAccount.Id,
                            ContactId = newCont.Id);
        insert partnerUser;
      system.debug('@@@PartUser: '+partnerUser.id);
 triggerexecutioncontroller.setSkipAllTriggers(True);
   // Opportunity Creation  
    Id DealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
     Opportunity testOpptyDealRegist = new Opportunity(Name='testOppDistiUser Test Oppty', 
                                                AccountId=testAccount1.Id,
                                                Deal_Registration_Status__c= 'New',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = DealRTId,
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
                                              //  Distributor_Reseller_Name__c = testaccount2.id,
                                                StageName = 'Plan - 1%',
                                                CloseDate = System.Today() + 30,
                                                Distributor_Name__c = 'Distribution',
                                                Distributor_ID__c = 'Test Disti User' ); 
   system.runAs(partnerUser){
      insert testOpptyDealRegist;
     }
     
      
   /*  PageReference pageRef = Page.DistributorResellerSelectionPage;
            Test.setCurrentPage(pageRef);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(testOpptyDealRegist);
            ApexPages.currentPage().getParameters().put('Id',testOpptyDealRegist.id);

            Vfcntrl_DistributorResellerSelectionExt DistiSelectPage = new Vfcntrl_DistributorResellerSelectionExt(sc);
            
            DistiSelectPage.searchString = '987654321011';
            DistiSelectPage.accName = 'Affinity';
            DistiSelectPage.fetchResults();
            DistiSelectPage.saveFunction();
            */
            testOpptyDealRegist.Distributor_Reseller_Name__c = testaccount2.id;
            update testOpptyDealRegist; 
      
   //Submitted   
   opportunity testOpptyDealSubmitted = [select id, name, Deal_Registration_Status__c from opportunity where id =:testOpptyDealRegist.id];
   testOpptyDealSubmitted.Deal_Registration_Status__c = 'Submitted';
   testOpptyDealSubmitted.Engage_Channel_Opportunity__c =False;
   testOpptyDealSubmitted.AccountId=testAccount1.Id;
  update testOpptyDealSubmitted;
      system.debug('@@END USER COUN Id:'+ testOpptyDealSubmitted.AccountId);
      system.debug('@@END USER COUN1:'+ testOpptyDealSubmitted.Account.Account_Country__c );
   //Approved  
   opportunity testOpptyDealApproved= [select id, name, Deal_Registration_Status__c from opportunity where id =:testOpptyDealSubmitted.id]; 
   Id DealRTId1 = IdLookupUtils.getRecordTypeId('Channel Opportunity', 'Opportunity', true);   
    testOpptyDealApproved.Deal_Registration_Status__c = 'Approved';
    testOpptyDealApproved.RecordTypeID = DealRTId1;
    testOpptyDealApproved.Engage_Channel_Opportunity__c =False;
    testOpptyDealApproved.AccountId=testAccount1.Id;
      system.debug('@@END USER COUN2:'+ testOpptyDealApproved.Account.Account_Country__c );
   Update testOpptyDealApproved;
      system.debug('@@@DISTI ACCOUNT:'+ testOpptyDealApproved.Distributor_Reseller_Name__c);
   Opportunity oppNew = [Select Id, OwnerId,Distributor_Reseller_Name__c, Distributor_Reseller_Name__r.Partner_Relationship__c,
                           Owner.Contact.Account.Partner_Relationship__c, Engage_Channel_Opportunity__c, Deal_Expiration_Timeframe__c,
                           Deal_Expiration_Date__c from Opportunity where Id=:testOpptyDealApproved.ID ];
     
     oppNew.Engage_Channel_Opportunity__c = True;
     oppNew.Deal_Expiration_Date__c = System.Today();
     update oppNew;
     
     list<Opportunity> opLIst = new list<Opportunity>();
     opLIst.add(oppNew);
     Map<Id, Opportunity> relatedOppMap = new Map<Id, Opportunity>();
     Map<Id, Opportunity> oldOppMap = new Map<Id, Opportunity>();
     oldOppMap.put(testOpptyDealApproved.Id, testOpptyDealApproved);  
     relatedOppMap = new map<Id, Opportunity>([Select Id, OwnerId,Distributor_Reseller_Name__c, Distributor_Reseller_Name__r.Partner_Relationship__c,
                           Owner.Contact.Account.Partner_Relationship__c, Engage_Channel_Opportunity__c, Deal_Expiration_Timeframe__c,
                           Deal_Expiration_Date__c from Opportunity where Id=:testOpptyDealApproved.ID]);
     system.runAs(partnerUser){
     UpdateDealExpirationDateforEngageChannel.updateDealExpirationEngageChannel(opLIst,oldOppMap);   
     }
  }
   
 public static testMethod void testEngageChannel() {

   triggerexecutioncontroller.setSkipAllTriggers(True);
        Id partnerAccRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        system.debug('@@@@@' +partnerAccRTId);
        Partner_Request__c partnerReq = createPartnerRequest();
        List<Account> accData = new List<Account>();
        
    // Partner account creation
        Account searchResultAccount = new Account(Name='partnerAccount', 
                                            RecordTypeId = partnerAccRTId,
                                            Partner_Tier__c = 'Tier 1',
                                            Partner_Relationship__c = 'Premier',
                                            Account_Country__c = 'UNITED STATES',
                                            Account_ID__c = '9876543210',
                                            Partner_Type__c = 'Commercial Distributor',
                                            Status__c = 'Active',
                                            DMU__c = false,        
                                            Partner_Registration__c = partnerReq.Id ); 
        accData.add(searchResultAccount); 
         
        Id enduserAccRTId= IdLookupUtils.getRecordTypeId('End-User Account','Account',true);
        // End user account creation
        Account testAccount1 = new Account(Name='enduserAccount', 
                                            RecordTypeId = enduserAccRTId, 
                                            Partner_Type__c = 'Commercial Distributor',
                                            Partner_Tier__c = 'Tier 1',
                                            Status__c = 'Active',
                                            Distribution_Sell_To_Countries__c = 'UNITED STATES',
                                            DMU__c = false,                                         
                                            Partner_Relationship__c = 'Premier',
                                            Account_Country__c = 'UNITED STATES',
                                            Partner_Registration__c = partnerReq.Id );        
        accData.add(testAccount1);
        insert accData;
     
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

        
       final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%Greater China PRM Portal User (MOSS)%' limit 1];
     system.debug('@@ProfileId: ' +partnerProfiles);
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
                            Badge_Number__c='Test123', 
                            isActive = true,
                            Enable_Partner_Admin__c = true,
                            Enable_Partner_Deal_Registration__c = true,
                            ContactId = newContSearch.Id);
        insert partnerUser;
             
   // Opportunity Creation  
        List<Opportunity> opplist = new List<Opportunity>();
      //  system.runAs(partnerUser){
        Id DealRTId = IdLookupUtils.getRecordTypeId('Channel Opportunity', 'Opportunity', true);
        Opportunity testOppty = new Opportunity(Name='testOppDistiUser Test Oppty', 
                                                AccountId=testAccount1.Id, 
                                                Deal_Registration_Status__c= 'New',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = DealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Distributor_Reseller_Name__c = testAccount1.Id,
                                                Primary_Product_Delivery_Address_Country__C = 'INDIA',
                                                Primary_Product_Delivery_Address_Region__c = 'APJ',
                                                Justification_Statement__c = 'Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'UNITED STATES',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                                Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                StageName = 'Plan - 1%',
                                                CloseDate = System.Today() + 30,
                                                Distributor_Name__c = 'Direct Fulfilment',
                                                Distributor_ID__c = 'Test Disti User',
                                                Engage_Channel_Opportunity__c = False ); 
      
      opplist.add(testOppty);
      insert oppList;
     Opportunity oppNew = [Select Id, OwnerId,Distributor_Reseller_Name__c, Distributor_Reseller_Name__r.Partner_Relationship__c,
                           Owner.Contact.Account.Partner_Relationship__c, Engage_Channel_Opportunity__c, Deal_Expiration_Timeframe__c,
                           Deal_Expiration_Date__c from Opportunity where Id=:testOppty.ID ];
     oppNew.OwnerId = partnerUser.Id;
     oppNew.Engage_Channel_Opportunity__c = True; 
     update oppNew;
     
     list<Opportunity> opLIst = new list<Opportunity>();
     opLIst.add(oppNew);
     Map<Id, Opportunity> relatedOppMap = new Map<Id, Opportunity>();
     Map<Id, Opportunity> oldOppMap = new Map<Id, Opportunity>();
     oldOppMap.put(testOppty.Id, testOppty);  
     relatedOppMap = new map<Id, Opportunity>([Select Id, OwnerId,Distributor_Reseller_Name__c, Distributor_Reseller_Name__r.Partner_Relationship__c,
                           Owner.Contact.Account.Partner_Relationship__c, Engage_Channel_Opportunity__c, Deal_Expiration_Timeframe__c,
                           Deal_Expiration_Date__c from Opportunity where Id=:testOppty.ID]);
     system.debug('***oppNew Id: '+oppNew.ownerId) ;
     // }
     // DistiVisibilityHelperClass.getPartnerType(testOppty.OwnerID);
      UpdateDealExpirationDateforEngageChannel.updateDealExpirationEngageChannel(opLIst,oldOppMap);
    }
 
   public static testMethod void testEngageChannel1() {

   triggerexecutioncontroller.setSkipAllTriggers(True);
        Id partnerAccRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        system.debug('@@@@@' +partnerAccRTId);
        Partner_Request__c partnerReq = createPartnerRequest();
        List<Account> accData = new List<Account>();
        
    // Partner account creation
        Account searchResultAccount = new Account(Name='partnerAccount', 
                                            RecordTypeId = partnerAccRTId,
                                            Partner_Tier__c = 'Tier 1',
                                            Partner_Relationship__c = 'Registered',
                                            Account_Country__c = 'UNITED STATES',
                                            Account_ID__c = '9876543210',
                                            Partner_Type__c = 'Test',
                                            Status__c = 'Active',
                                            DMU__c = false,        
                                            Partner_Registration__c = partnerReq.Id ); 
        accData.add(searchResultAccount); 
         
        Id enduserAccRTId= IdLookupUtils.getRecordTypeId('End-User Account','Account',true);
        // End user account creation
        Account testAccount1 = new Account(Name='enduserAccount', 
                                            RecordTypeId = enduserAccRTId, 
                                            Partner_Type__c = 'Commercial Distributor',
                                            Partner_Tier__c = 'Tier 1',
                                            Status__c = 'Active',
                                            Distribution_Sell_To_Countries__c = 'UNITED STATES',
                                            DMU__c = false,                                         
                                            Partner_Relationship__c = 'Registered',
                                            Account_Country__c = 'UNITED STATES',
                                            Partner_Registration__c = partnerReq.Id );        
        accData.add(testAccount1);
        insert accData;
     
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

        
       final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%Greater %' limit 1];
        
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
                            Badge_Number__c='Test123', 
                            isActive = true,
                            Enable_Partner_Admin__c = true,
                            Enable_Partner_Deal_Registration__c = true,
                            ContactId = newContSearch.Id);
        insert partnerUser;
             
   // Opportunity Creation  
        List<Opportunity> opplist = new List<Opportunity>();
        //system.runAs(partnerUser){
        Id DealRTId = IdLookupUtils.getRecordTypeId('Channel Opportunity', 'Opportunity', true);
        Opportunity testOppty = new Opportunity(Name='testOppDistiUser Test Oppty', 
                                                AccountId=testAccount1.Id, 
                                                Deal_Registration_Status__c= 'New',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = DealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Distributor_Reseller_Name__c = testAccount1.Id,
                                                Primary_Product_Delivery_Address_Country__C = 'INDIA',
                                                Primary_Product_Delivery_Address_Region__c = 'APJ',
                                                Justification_Statement__c = 'Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'UNITED STATES',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                                Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                StageName = 'Plan - 1%',
                                                CloseDate = System.Today() + 30,
                                                Distributor_Name__c = 'Direct Fulfilment',
                                                Distributor_ID__c = 'Test Disti User',
                                                Engage_Channel_Opportunity__c = False ); 
      
      opplist.add(testOppty);
      insert oppList;
     Opportunity oppNew = [Select Id, OwnerId,Distributor_Reseller_Name__c, Distributor_Reseller_Name__r.Partner_Relationship__c,
                           Owner.Contact.Account.Partner_Relationship__c, Engage_Channel_Opportunity__c, Deal_Expiration_Timeframe__c,
                           Deal_Expiration_Date__c from Opportunity where Id=:testOppty.ID ];
     oppNew.OwnerId = partnerUser.Id;
     oppNew.Engage_Channel_Opportunity__c = True;
     oppNew.Deal_Expiration_Date__c =system.today();
     //oppNew.Distributor_Reseller_Name__r.Partner_Relationship__c = 'Premier';
     update oppNew;
     
     list<Opportunity> opLIst = new list<Opportunity>();
     opLIst.add(oppNew);
     Map<Id, Opportunity> relatedOppMap = new Map<Id, Opportunity>();
     Map<Id, Opportunity> oldOppMap = new Map<Id, Opportunity>();
     oldOppMap.put(testOppty.Id, testOppty);  
     relatedOppMap = new map<Id, Opportunity>([Select Id, OwnerId,Distributor_Reseller_Name__c, Distributor_Reseller_Name__r.Partner_Relationship__c,
                           Owner.Contact.Account.Partner_Relationship__c, Engage_Channel_Opportunity__c, Deal_Expiration_Timeframe__c,
                           Deal_Expiration_Date__c from Opportunity where Id=:testOppty.ID]);
     system.debug('***oppNew Id: '+oppNew.ownerId) ;
     // }
     // DistiVisibilityHelperClass.getPartnerType(testOppty.OwnerID);
     system.runAs(partnerUser){
      UpdateDealExpirationDateforEngageChannel.updateDealExpirationEngageChannel(opLIst,oldOppMap);
     }
   }
    
    public static testMethod void testEngageChannel2() {

   triggerexecutioncontroller.setSkipAllTriggers(True);
        Id partnerAccRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        system.debug('@@@@@' +partnerAccRTId);
        Partner_Request__c partnerReq = createPartnerRequest();
        List<Account> accData = new List<Account>();
        
    // Partner account creation
        Account searchResultAccount = new Account(Name='partnerAccount', 
                                            RecordTypeId = partnerAccRTId,
                                            Partner_Tier__c = 'Tier 1',
                                            Partner_Relationship__c = 'Preferred',
                                            Account_Country__c = 'UNITED STATES',
                                            Account_ID__c = '9876543210',
                                            Partner_Type__c = 'Commercial Distributor',
                                            Status__c = 'Active',
                                            DMU__c = false,        
                                            Partner_Registration__c = partnerReq.Id ); 
        accData.add(searchResultAccount); 
         
        Id enduserAccRTId= IdLookupUtils.getRecordTypeId('End-User Account','Account',true);
        // End user account creation
        Account testAccount1 = new Account(Name='enduserAccount', 
                                            RecordTypeId = enduserAccRTId, 
                                            Partner_Type__c = 'Commercial Distributor',
                                            Partner_Tier__c = 'Tier 1',
                                            Status__c = 'Active',
                                            Distribution_Sell_To_Countries__c = 'UNITED STATES',
                                            DMU__c = false,                                         
                                            Partner_Relationship__c = 'Preferred',
                                            Account_Country__c = 'UNITED STATES',
                                            Partner_Registration__c = partnerReq.Id );        
        accData.add(testAccount1);
        insert accData;
     
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

        
       final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%Greater %' limit 1];
       // final List<Profile> partnerProfiles = [select id from profile where name='System Administrator' Limit 1];
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
                            Badge_Number__c='Test123', 
                            isActive = true,
                            Enable_Partner_Admin__c = true,
                            Enable_Partner_Deal_Registration__c = true,
                            ContactId = newContSearch.Id);
        insert partnerUser;
             
   // Opportunity Creation  
        List<Opportunity> opplist = new List<Opportunity>();
        //system.runAs(partnerUser){
        Id DealRTId = IdLookupUtils.getRecordTypeId('Channel Opportunity', 'Opportunity', true);
        Opportunity testOppty = new Opportunity(Name='testOppDistiUser Test Oppty', 
                                                AccountId=testAccount1.Id, 
                                                Deal_Registration_Status__c= 'New',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = DealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Distributor_Reseller_Name__c = testAccount1.Id,
                                                Primary_Product_Delivery_Address_Country__C = 'INDIA',
                                                Primary_Product_Delivery_Address_Region__c = 'APJ',
                                                Justification_Statement__c = 'Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'UNITED STATES',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                                Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                StageName = 'Plan - 1%',
                                                CloseDate = System.Today() + 30,
                                                Distributor_Name__c = 'Direct Fulfilment',
                                                Distributor_ID__c = 'Test Disti User',
                                                Engage_Channel_Opportunity__c = False ); 
      
      opplist.add(testOppty);
      insert oppList;
     Opportunity oppNew = [Select Id, OwnerId,Distributor_Reseller_Name__c, Distributor_Reseller_Name__r.Partner_Relationship__c,
                           Owner.Contact.Account.Partner_Relationship__c, Engage_Channel_Opportunity__c, Deal_Expiration_Timeframe__c,
                           Deal_Expiration_Date__c from Opportunity where Id=:testOppty.ID ];
     oppNew.OwnerId = partnerUser.Id;
     oppNew.Deal_Expiration_Date__c = System.Today();
     oppNew.Engage_Channel_Opportunity__c = True;
     //oppNew.Distributor_Reseller_Name__r.Partner_Relationship__c = 'Premier';
     update oppNew;
     
     list<Opportunity> opLIst = new list<Opportunity>();
     opLIst.add(oppNew);
     Map<Id, Opportunity> relatedOppMap = new Map<Id, Opportunity>();
     Map<Id, Opportunity> oldOppMap = new Map<Id, Opportunity>();
     oldOppMap.put(testOppty.Id, testOppty);  
     relatedOppMap = new map<Id, Opportunity>([Select Id, OwnerId,Distributor_Reseller_Name__c, Distributor_Reseller_Name__r.Partner_Relationship__c,
                           Owner.Contact.Account.Partner_Relationship__c, Engage_Channel_Opportunity__c, Deal_Expiration_Timeframe__c,
                           Deal_Expiration_Date__c from Opportunity where Id=:testOppty.ID]);
     system.debug('***oppNew Id: '+oppNew.ownerId) ;
        system.runAs(partnerUser){
      UpdateDealExpirationDateforEngageChannel.updateDealExpirationEngageChannel(opLIst,oldOppMap);
        }
    }

    public static testMethod void testEngageChannel3() {

   triggerexecutioncontroller.setSkipAllTriggers(True);
        Id partnerAccRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        system.debug('@@@@@' +partnerAccRTId);
        Partner_Request__c partnerReq = createPartnerRequest();
        List<Account> accData = new List<Account>();
        
    // Partner account creation
        Account searchResultAccount = new Account(Name='partnerAccount', 
                                            RecordTypeId = partnerAccRTId,
                                            Partner_Tier__c = 'Tier 1',
                                            Partner_Relationship__c = 'Registered',
                                            Account_Country__c = 'UNITED STATES',
                                            Account_ID__c = '9876543210',
                                            Partner_Type__c = 'Commercial Distributor',
                                            Status__c = 'Active',
                                            DMU__c = false,        
                                            Partner_Registration__c = partnerReq.Id ); 
        accData.add(searchResultAccount); 
         
        Id enduserAccRTId= IdLookupUtils.getRecordTypeId('End-User Account','Account',true);
        // End user account creation
        Account testAccount1 = new Account(Name='enduserAccount', 
                                            RecordTypeId = enduserAccRTId, 
                                            Partner_Type__c = 'Commercial Distributor',
                                            Partner_Tier__c = 'Tier 1',
                                            Status__c = 'Active',
                                            Distribution_Sell_To_Countries__c = 'UNITED STATES',
                                            DMU__c = false,                                         
                                            Partner_Relationship__c = 'Registered',
                                            Account_Country__c = 'UNITED STATES',
                                            Partner_Registration__c = partnerReq.Id );        
        accData.add(testAccount1);
        insert accData;
     
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

        
       final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%Greater %' limit 1];
       // final List<Profile> partnerProfiles = [select id from profile where name='System Administrator' Limit 1];
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
                            Badge_Number__c='Test123', 
                            isActive = true,
                            Enable_Partner_Admin__c = true,
                            Enable_Partner_Deal_Registration__c = true,
                            ContactId = newContSearch.Id);
        insert partnerUser;
             
   // Opportunity Creation  
        List<Opportunity> opplist = new List<Opportunity>();
        //system.runAs(partnerUser){
        Id DealRTId = IdLookupUtils.getRecordTypeId('Channel Opportunity', 'Opportunity', true);
        Opportunity testOppty = new Opportunity(Name='testOppDistiUser Test Oppty', 
                                                AccountId=testAccount1.Id, 
                                                Deal_Registration_Status__c= 'New',
                                                Total_Expected_Dell_Revenue__c =1919191,
                                                RecordTypeID = DealRTId,
                                                Engagement_Type__c = 'Public Tender',
                                                Distributor_Reseller_Name__c = testAccount1.Id,
                                                Primary_Product_Delivery_Address_Country__C = 'INDIA',
                                                Primary_Product_Delivery_Address_Region__c = 'APJ',
                                                Justification_Statement__c = 'Statement1',
                                                End_User_Account_Name__c = 'Test Account',
                                                End_User_Mailing_City__c = 'City',
                                                End_User_Mailing_State_Province_Region__c = 'State 1',
                                                End_User_Mailing_Country__c = 'UNITED STATES',
                                                Save_End_Customer_to_my_list__c = 'No',
                                                End_User_First_Name__c = 'First Name',
                                                End_User_Last_Name__c = 'Last Name',
                                                End_User_Email__c = 'user@dell.coin',
                                                Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
                                                StageName = 'Plan - 1%',
                                                CloseDate = System.Today() + 30,
                                                Distributor_Name__c = 'Direct Fulfilment',
                                                Distributor_ID__c = 'Test Disti User',
                                                Engage_Channel_Opportunity__c = TRUE ); 
      
      opplist.add(testOppty);
      insert oppList;
     Opportunity oppNew = [Select Id, OwnerId,Distributor_Reseller_Name__c, Distributor_Reseller_Name__r.Partner_Relationship__c,
                           Owner.Contact.Account.Partner_Relationship__c, Engage_Channel_Opportunity__c, Deal_Expiration_Timeframe__c,
                           Deal_Expiration_Date__c from Opportunity where Id=:testOppty.ID ];
     oppNew.OwnerId = partnerUser.Id;
     //oppNew.Distributor_Reseller_Name__r.Partner_Relationship__c = 'Premier';
     update oppNew;
     
     list<Opportunity> opLIst = new list<Opportunity>();
     opLIst.add(oppNew);
     Map<Id, Opportunity> relatedOppMap = new Map<Id, Opportunity>();
     Map<Id, Opportunity> oldOppMap = new Map<Id, Opportunity>();
     oldOppMap.put(testOppty.Id, testOppty);  
     relatedOppMap = new map<Id, Opportunity>([Select Id, OwnerId,Distributor_Reseller_Name__c, Distributor_Reseller_Name__r.Partner_Relationship__c,
                           Owner.Contact.Account.Partner_Relationship__c, Engage_Channel_Opportunity__c, Deal_Expiration_Timeframe__c,
                           Deal_Expiration_Date__c from Opportunity where Id=:testOppty.ID]);
     system.debug('***oppNew Id: '+oppNew.ownerId) ;
     // }
     // DistiVisibilityHelperClass.getPartnerType(testOppty.OwnerID);
      UpdateDealExpirationDateforEngageChannel.updateDealExpirationEngageChannel(opLIst,oldOppMap);
    }

    // Partner Request Creation
  static Partner_Request__c createPartnerRequest(){
        //create Account
        Account testAccount = new Account(
        name='Test 1',
        Account_Country_Code__c = 'AI',
        Account_Country__c = 'ANGUILIA',            
        Account_ID__c =''+System.currentTimeMillis()
        );
        insert testAccount;

        //Create country
        Country__c testCountry = new Country__c(
        Name = 'TestCountry',
        Code__c = 'TY',
        User_Currency_Iso_Code__c = 'INR',
        Region__c = 'APJ');
        insert testCountry;
        
        //Create User
        Profile userProfile= [select id,name from profile where name like '%Sales Rep%' order by name limit 1 ];        
        User userRecord = new User(
        Username='testUser'+System.currentTimeMillis()+'@test.com',
        Alias = 'test', 
        Email='test@dell.com', 
        FirstName='Tfirst', 
        LastName='TLast',
        ProfileId = userProfile.Id, 
        LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', 
        EmailEncodingKey='UTF-8', 
        TimeZoneSidKey='America/Los_Angeles',
        Badge_Number__c='TEST12345'
        );
        insert userRecord;

        //Create Partner Request
        Partner_Request__c request = new Partner_Request__c();
        request.Account__c = testAccount.id;
        request.RecordTypeId = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_NEW_PARTNER,
        'Partner_Request__c', true);
        request.email__c = 'test@dell.com';
        //request.Contact__c=contact.id;
        request.Export_Compliance_Agreed__c = true;
        request.Partner_Terms_Conditions__c = true;
        request.Other_Customers__c = 'test1';
        request.Preferred_Dell_Distribution_Partner__c = 'Test prefer';
        request.Feature_Request_Deal_Registration__c = true;
        //request.Company__c = 'Test Company';
        request.Org_Country__c = testCountry.id;
        request.Website__c = 'website';     
        request.Org_Address_1__c =  'Address 1';
        request.Org_Address_2__c = 'Address 2';
        request.Org_Address_3__c =  'Address 3';
        request.Org_City__c = 'city';
        request.Org_State__c = 'state';
        request.Org_Postal_Code__c = 'postalcode';      
        request.Address_Line_1__c = 'Address 1';
        request.Address_Line_2__c = 'Address 2';
        request.Address_Line_3__c = 'Address 3';
        request.City__c = 'city';
        request.State__c = 'state';
        request.Postal_Code__c = 'postalcode';
        request.Last_Name__c = 'Test Last Name';
        request.Country__c = testCountry.id;
        request.OwnerId = userRecord.Id;
        insert request;

        return request;
    }

    
    
}