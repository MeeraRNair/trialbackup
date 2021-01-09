/*
* Author   : Sneha
* Purpose  : Test Class for Qualified Programs helper class.
* 
* Revision CR Number   Release No  Date            Modified By     Description
* -------- ---------   ----------  -----------     ------------    -----------
* 1.0      CR# 4161253 0203        21-Dec-2017     Sneha           Created for implementing trigger architecture - Best practices
* 2.0      CR# 5873250 0202        04-Dec-2018     Chethana        Display non NBI channel Programs in Channel Program Field on Opportunity Product
* 3.0      CR# 6095382 0402        28-Jan-2019     Chethana        Adding HCI and UDS to NBI Incentive category field
* 4.0	               0102		   04-Dec-2019	   Vikas Kh		   TDF Impelmentation 
*/
@isTest
public class QualifiedProgramTriggerHelperTest {
    static list<Account> listAcc;
    Static list<Opportunity> listOpp;
    static list<user> listuser;
    @testSetup static void setup() {
        OWD__c oWDsetting = new OWD__c();
        oWDsetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        oWDsetting.Oppty_Stage10__c = 'Discover - 10%';
        oWDsetting.Oppty_Stage100__c = 'Win - 100%';
        oWDsetting.Oppty_Stage30__c = 'Qualify - 30%';
        oWDsetting.Oppty_Stage60__c = 'Propose - 60%';
        oWDsetting.Oppty_Stage90__c = 'Commit - 90%';
        oWDsetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        oWDsetting.Oppty_Stage1__c = 'Plan - 1%';
        insert oWDsetting;
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTDF = TestDataFactory.createNAccount(3, 'Master Account');
        insert listAccTDF;   
        list<Opportunity> listOppTDF = TestDataFactory.createNOpportunities(6, 'Deal Registration');
        insert listOppTDF;   
        list<user> listUserTDF = TestDataFactory.createNPortalUser(1);
        insert listuserTDF;
    }   
    Static testmethod void testQPInsertions(){
        TriggerExecutionController.setSkipAllTriggers(true);
        final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and Name like '%PRM%' order by CreatedDate desc limit 1];
        system.debug('*****' +partnerProfiles);
        Sales_Channel_Group__c testSalesChannel = new Sales_Channel_Group__c(Name = 'MFG WEST', Sales_Method_Name__c = 'commercial');
        Insert testSalesChannel;     
        listAcc =[select Name, Id, RecordTypeID from Account limit 2];
        listAcc[0].Name = 'Test Partner Acc';
        listAcc[0].Partner_Type__c = 'US Federal';
        listAcc[0].Partner_Tier__c = 'Tier 2';
        listAcc[0].Partner_Relationship__c = 'Registered';
        listAcc[0].Account_Country_Code__c = 'US';
        listAcc[0].Account_Country__c = 'UNITED STATES'; 
        listAcc[1].Name = 'Test End User Acc';
        listAcc[1].Partner_Type__c = 'COMMERCIAL';
        listAcc[1].Partner_Tier__c = 'Tier 1';
        listAcc[1].Partner_Relationship__c = 'Registered';
        listAcc[1].Account_Country_Code__c = 'US';
        listAcc[1].Account_Country__c = 'UNITED STATES'; 
        listAcc[1].GTM_Model__c = 'DELL CHANNEL';
        listAcc[1].Sales_Channel__c = testSalesChannel.id;
        TriggerExecutionController.setSkipAccountTriggers(True);
        Update listAcc;
        /*        Contact partnerContact = new Contact(FirstName = 'MyTestContact',
LastName = 'MyTestContact',
AccountId =listAcc[0].Id,
Status__c  =  'Marketing Suspect',
Email = 'dealregTestContact@dell.com',
Fax = '1234567',
MobilePhone = '0987654',
Last_Operation_Performed__c = 'testing',
Phone = '1234500');
insert partnerContact;
User partnerUser = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
Alias = 'MTU9', 
Email='MyTestUser91@dell.com', 
FirstName='MyTestUser91', 
LastName='MyTestUser91',  
ProfileId = partnerProfiles.get(0).Id, 
LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', 
EmailEncodingKey='UTF-8', 
TimeZoneSidKey='America/Los_Angeles',
Badge_Number__c='DealReg123'+System.today().month(), 
isActive = TRUE,
ContactId = partnerContact.Id);        
insert partnerUser; */
        listUser = [select id from user limit 1];
        Pricebook2 pb2 = new Pricebook2(Name = 'Test Price', IsActive = False);
        List<Opportunity> listOpp = [select id, name, AccountID,Deal_Registration_Status__c,Total_Expected_Dell_Revenue__c, Engagement_Type__c,Is_the_Customer_Part_of_a_Larger_Group__c,StageName, CloseDate,Distributor_Name__c from Opportunity limit 2 ];        
        listOpp[0].Name='testOppDistiUser Test Oppty';
        listOpp[0].Deal_Registration_Status__c= 'New';
        listOpp[0].Total_Expected_Dell_Revenue__c =500;
        listOpp[0].Engagement_Type__c = 'Public Tender';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes';
        listOpp[0].StageName = 'Plan - 1%';
        listOpp[0].CloseDate = System.Today() + 30;
        listOpp[0].Distributor_Name__c = 'Direct fulfilment';
        listOpp[1].Name='testOppDistiUser Test Oppty';
        listOpp[1].AccountId = listAcc[0].Id;
        listOpp[1].Pricebook2Id = pb2.Id;
        listOpp[1].Deal_Registration_Status__c= 'New';
        listOpp[1].Total_Expected_Dell_Revenue__c =500;
        listOpp[1].Deal_Type__c = 'Fulfillment';
        listOpp[1].Engagement_Type__c = 'Public Tender';
        listOpp[1].Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes';
        listOpp[1].StageName = 'Plan - 1%';
        listOpp[1].CloseDate = System.Today() + 30;
        listOpp[1].Distributor_Name__c = 'Direct fulfilment';
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        update listOpp;  
        Country__c country = new Country__c(Name='United States',
                                            Code__c='US',
                                            Dell_Online_Country_Code__c ='US',
                                            Region__c ='NA');
        insert country;   
        List<Deal_Program__c> listDealProgram = new List<Deal_Program__c>();
        Deal_program__c testDealProgram1 = new Deal_program__c(Deal_Program_Name__c = 'Storage',
                                                               Benefit_Type__c = 'test',
                                                               Business_Unit__c = 'test',
                                                               Active__c = True,
                                                               Deal_Program_Description__c = 'test Program',
                                                               Start_Date__c = system.today(),
                                                               End_Date__c = system.today().adddays(10),                                                            
                                                               USD_Threshold__c = 900,
                                                               Fulfilment_Path__c = 'Distribution',
                                                               Partner_Type__c = 'Distributor (GCC)',
                                                               Partner_Relationships__c = 'Registered',
                                                               Partner_Tiers__c = 'Indirect Partner Purchase;Tier 1;Tier 2',
                                                               Partner_Account_Regions__c = 'APJ;LATAM;NA',
                                                               Partner_Account_Countrys__c = 'INDIA',
                                                               Exclude_Sales_Channels__c = 'FED',
                                                               Include_Sales__c = 'WED',
                                                               End_User_Account_Regions__c = 'APJ;LATAM',
                                                               End_User_Account_Countrys__c = 'INDIA',
                                                               Coverage__c = 'CFL;DELL CHANNEL',
                                                               Stack_Ranking__c = 2000,
                                                               Account_Classification__c = 'Commercial',
                                                               Exclude_Unassigned_End_User_Accounts__c = True);
        listDealProgram.add(testDealProgram1);
        Deal_program__c testDealProgram2 = new Deal_program__c(Deal_Program_Name__c = 'Server NBI',
                                                               Benefit_Type__c = 'test',
                                                               Business_Unit__c = 'test',
                                                               Active__c = True,
                                                               Deal_Program_Description__c = 'test Program',
                                                               Start_Date__c = system.today(),
                                                               End_Date__c = system.today().adddays(10),                                                            
                                                               USD_Threshold__c = 400,
                                                               Fulfilment_Path__c = 'Direct fulfilment',
                                                               Partner_Type__c = 'Distributor (GCC)',
                                                               Partner_Relationships__c = 'Registered',
                                                               Partner_Tiers__c = 'Indirect Partner Purchase',
                                                               Partner_Account_Regions__c = 'APJ;LATAM',
                                                               Partner_Account_Countrys__c = 'INDIA',
                                                               Exclude_Sales_Channels__c = 'FED',
                                                               Include_Sales__c = 'WEST',
                                                               End_User_Account_Regions__c = 'APJ;LATAM;NA',
                                                               End_User_Account_Countrys__c = 'UNITED STATES',
                                                               Coverage__c = 'CFL',
                                                               Stack_Ranking__c = 2000,
                                                               Account_Classification__c = 'Commercial',
                                                               Exclude_Unassigned_End_User_Accounts__c = True);
        listDealProgram.add(testDealProgram2);
        Deal_program__c testDealProgram3 = new Deal_program__c(Deal_Program_Name__c = 'Client NBI',
                                                               Benefit_Type__c = 'test',
                                                               Business_Unit__c = 'test',
                                                               Active__c = True,
                                                               Deal_Type__c = 'Fulfillment',
                                                               Deal_Program_Description__c = 'test Program',
                                                               Start_Date__c = system.today(),
                                                               End_Date__c = system.today().adddays(10),                                                            
                                                               USD_Threshold__c = 400,
                                                               Fulfilment_Path__c = 'Direct fulfilment',
                                                               Partner_Type__c = 'US Federal',
                                                               Partner_Relationships__c = 'Registered',
                                                               Partner_Tiers__c = 'Indirect Partner Purchase;Tier 1;Tier 2',
                                                               Partner_Account_Regions__c = 'APJ;LATAM;NA',
                                                               Partner_Account_Countrys__c = 'UNITED STATES',
                                                               Exclude_Sales_Channels__c = 'FED;TEST',
                                                               Include_Sales__c = 'WEST;Test',
                                                               Stack_Ranking__c = 2000,
                                                               End_User_Account_Regions__c = 'APJ;LATAM;NA',
                                                               End_User_Account_Countrys__c = 'UNITED STATES',
                                                               Coverage__c =  'DELL CHANNEL',
                                                               Exclude_Unassigned_End_User_Accounts__c = True);
        listDealProgram.add(testDealProgram3);
        Database.insert(listDealProgram);
        List<Product2> listPrdts = new List<Product2>();  
        Product2 newPrdt1 = new Product2();
        newPrdt1.Name = 'Test Server';
        newPrdt1.ProductCode = 'Server';
        newPrdt1.Family='Enterprise Solution Group';
        newPrdt1.Product_ID__c = String.valueOf(System.today().year());
        newPrdt1.NBI_Eligible__c = true;
        newPrdt1.NBI_Category__c='Server';
        newPrdt1.Channel_Product_LOB__c = 'Server';
        newPrdt1.isActive = true;
        listPrdts.add(newPrdt1);
        Product2 newPrdt2 = new Product2();
        newPrdt2.Name = 'Test Client';
        newPrdt2.ProductCode = 'Client';
        newPrdt2.Family='Enterprise Solution Group';
        newPrdt2.Product_ID__c = String.valueOf(System.today().addYears(1));
        newPrdt2.NBI_Eligible__c = true;
        newPrdt2.NBI_Category__c='Client';
        newPrdt2.Channel_Product_LOB__c = 'Client';
        newPrdt2.isActive = true;
        listPrdts.add(newPrdt2);
        Product2 newPrdt3 = new Product2();
        newPrdt3.Name = 'Test Client';
        newPrdt3.ProductCode = 'Client';
        newPrdt3.Family='Enterprise Solution Group';
        newPrdt3.Product_ID__c = String.valueOf(System.today().addYears(2));
        newPrdt3.Channel_Product_LOB__c = 'Client';
        newPrdt3.isActive = true;
        listPrdts.add(newPrdt3);
        Product2 newPrdt4 = new Product2();
        newPrdt4.Name = 'Test Networking';
        newPrdt4.ProductCode = 'Networking';
        newPrdt4.Family='Enterprise Solution Group';
        newPrdt4.Product_ID__c = String.valueOf(System.today().addYears(3));
        newPrdt4.Channel_Product_LOB__c = 'Networking';
        listPrdts.add(newPrdt4);
        Product2 newPrdt5 = new Product2();
        newPrdt5.Name = 'Test Storage';
        newPrdt5.ProductCode = 'Storage';
        newPrdt5.Family='Enterprise Solution Group';
        newPrdt5.Product_ID__c = String.valueOf(System.today().addYears(5));
        newPrdt5.Channel_Product_LOB__c = 'Storage';
        newPrdt5.isActive = true;
        newPrdt5.NBI_Eligible__c = true;
        newPrdt5.NBI_Category__c='Storage';
        listPrdts.add(newPrdt5);
        insert listPrdts;
        Id pricebookId = Test.getStandardPricebookId();  
        List<PricebookEntry> listPricBookEntry = new List<PricebookEntry>();
        for(Product2 prod :listPrdts){          
            PricebookEntry priceBookRecord = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
            listPricBookEntry.add(priceBookRecord);
        }
        insert listPricBookEntry;
        list<OpportunityLineItem> listOppLineItem=TestDataFactory.createNOpportunityLineItem(4);
        listOppLineItem[0].Opportunityid=listOpp[1].id;
        listOppLineItem[0].pricebookEntryId=listPricBookEntry[0].Id;
        listOppLineItem[0].Quantity =1;
        listOppLineItem[0].Service_Support_US__c = 'ProSupport for Software';
        listOppLineItem[1].Opportunityid=listOpp[1].id;
        listOppLineItem[1].pricebookEntryId=listPricBookEntry[1].id;
        listOppLineItem[1].Quantity =1;
        listOppLineItem[1].Service_Support_US__c = 'ProSupport IT - Mission Critical';
        listOppLineItem[1].NBI_Category__c = 'Client';
        listOppLineItem[2].Opportunityid=listOpp[1].id;
        listOppLineItem[2].pricebookEntryId=listPricBookEntry[2].id;
        listOppLineItem[2].Quantity =1;
        listOppLineItem[2].Service_Support_US__c = 'ProSupport for Cloud Services';
        listOppLineItem[2].NBI_Category__c = 'Client';
        listOppLineItem[3].Opportunityid=listOpp[1].id;
        listOppLineItem[3].pricebookEntryId=listPricBookEntry[1].id;
        listOppLineItem[3].Quantity =1;
        listOppLineItem[3].Service_Support_US__c = 'ProSupport IT - Mission Critical';
        listOppLineItem[3].NBI_Category__c = 'Client';
        insert listOppLineItem;
        Test.startTest();
        List<Qualified_Program__c> listQP = new List<Qualified_Program__c>();
        Qualified_Program__c qp1 = new Qualified_Program__c();
        qp1.Product__c = listPrdts[0].Id;
        qp1.Opportunity__c = listOpp[1].Id;
        qp1.Deal_Program__C = listDealProgram[0].Id;
        listQP.add(qp1);
        Qualified_Program__c qp2 = new Qualified_Program__c();
        qp2.Product__c = listPrdts[1].Id;
        qp2.Opportunity__c = listOpp[1].Id;
        qp2.Deal_Program__C = listDealProgram[1].Id;
        listQP.add(qp2);
        Qualified_Program__c qp3 = new Qualified_Program__c();
        qp3.Product__c = listPrdts[2].Id;
        qp3.Opportunity__c = listOpp[1].Id;
        qp3.Deal_Program__C = listDealProgram[2].Id;
        listQP.add(qp3);
        Qualified_Program__c qp4 = new Qualified_Program__c();
        qp4.Product__c = listPrdts[4].Id;
        qp4.Opportunity__c = listOpp[1].Id;
        qp4.Deal_Program__C = listDealProgram[2].Id;
        listQP.add(qp4);
        insert listQP;
        system.assertEquals(4, listQP.size());
        delete listQP[1];
        Test.stopTest();
        QualifiedProgramTriggerHelper.updateOpportunityLineItemWithNBIRelatedInfo(listQP, 'Opportunity');
    }
    Static testmethod void testNBICategory(){
        TriggerExecutionController.setSkipAllTriggers(true);  
        //        Set<String> setCustomerUserTypes = new Set<String> {'CSPLiteUser', 'PowerPartner', 'PowerCustomerSuccess',   'CustomerSuccess'};
        //        final List<Profile> partnerProfiles = [select Id,name from Profile where UserType in :setCustomerUserTypes limit 1];
        //        final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and Name like '%PRM%' order by CreatedDate desc limit 1];
        //        system.debug('*****' +partnerProfiles);
        Sales_Channel_Group__c testSalesChannel = new Sales_Channel_Group__c(Name = 'MFG WEST', Sales_Method_Name__c = 'commercial');
        Insert testSalesChannel;     
        listAcc =[select Name, Id, RecordTypeID from Account limit 2];
        listAcc[0].Name = 'Test Partner Acc';
        listAcc[0].Partner_Type__c = 'US Federal';
        listAcc[0].Partner_Tier__c = 'Tier 2';
        listAcc[0].Partner_Relationship__c = 'Registered';
        listAcc[0].Account_Country_Code__c = 'US';
        listAcc[0].Account_Country__c = 'UNITED STATES'; 
        listAcc[1].Name = 'Test End User Acc';
        listAcc[1].Partner_Type__c = 'COMMERCIAL';
        listAcc[1].Partner_Tier__c = 'Tier 1';
        listAcc[1].Partner_Relationship__c = 'Registered';
        listAcc[1].Account_Country_Code__c = 'US';
        listAcc[1].Account_Country__c = 'UNITED STATES'; 
        listAcc[1].GTM_Model__c = 'DELL CHANNEL';
        listAcc[1].Sales_Channel__c = testSalesChannel.id;
        TriggerExecutionController.setSkipAccountTriggers(True);
        Update listAcc;
        /*      Contact partnerContact = new Contact(FirstName = 'MyTestContact',
LastName = 'MyTestContact',
AccountId =listAcc[0].Id,
Status__c  =  'Marketing Suspect',
Email = 'dealregTestContact@dell.com',
Fax = '1234567',
MobilePhone = '0987654',
Last_Operation_Performed__c = 'testing',
Phone = '1234500');
insert partnerContact;
User partnerUser = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
Alias = 'MTU9', 
Email='MyTestUser91@dell.com', 
FirstName='MyTestUser91', 
LastName='MyTestUser91',  
ProfileId = partnerProfiles.get(0).Id, 
LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', 
EmailEncodingKey='UTF-8', 
TimeZoneSidKey='America/Los_Angeles',
Badge_Number__c='DealReg123'+System.today().month(), 
isActive = TRUE,
ContactId = partnerContact.Id);
insert partnerUser; */
        listUser = [select id from user limit 1];
        List<Opportunity> listOpp = [select id, name, AccountID,Deal_Registration_Status__c,Total_Expected_Dell_Revenue__c, Engagement_Type__c,Is_the_Customer_Part_of_a_Larger_Group__c,StageName, CloseDate,Distributor_Name__c from Opportunity limit 2 ];        
        listOpp[0].Name='testOppDistiUser Test Oppty';
        listOpp[0].Deal_Registration_Status__c= 'New';
        listOpp[0].Total_Expected_Dell_Revenue__c =500;
        listOpp[0].Engagement_Type__c = 'Public Tender';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes';
        listOpp[0].StageName = 'Plan - 1%';
        listOpp[0].CloseDate = System.Today() + 30;
        listOpp[0].Distributor_Name__c = 'Direct fulfilment';
        listOpp[1].Name='testOppDistiUser Test Oppty';
        listOpp[1].AccountId = listAcc[0].Id;
        listOpp[1].Deal_Registration_Status__c= 'New';
        listOpp[1].Total_Expected_Dell_Revenue__c =500;
        listOpp[1].Deal_Type__c = 'Fulfillment';
        listOpp[1].Engagement_Type__c = 'Public Tender';
        listOpp[1].Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes';
        listOpp[1].StageName = 'Plan - 1%';
        listOpp[1].CloseDate = System.Today() + 30;
        listOpp[1].Distributor_Name__c = 'Direct fulfilment';
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        update listOpp;  
        Country__c country = new Country__c(Name='United States',
                                            Code__c='US',
                                            Dell_Online_Country_Code__c ='US',
                                            Region__c ='NA');
        insert country;   
        List<Deal_Program__c> listDealProgram= new List<Deal_Program__c>();
        Deal_program__c testDealProgram1 = new Deal_program__c(Deal_Program_Name__c = 'Networking NBI',
                                                               Benefit_Type__c = 'test',
                                                               Business_Unit__c = 'test',
                                                               Active__c = True,
                                                               Deal_Program_Description__c = 'test Program',
                                                               Start_Date__c = system.today(),
                                                               End_Date__c = system.today().adddays(10),                                                            
                                                               USD_Threshold__c = 900,
                                                               Fulfilment_Path__c = 'Distribution',
                                                               Partner_Type__c = 'Distributor (GCC)',
                                                               Partner_Relationships__c = 'Registered',
                                                               Partner_Tiers__c = 'Indirect Partner Purchase;Tier 1;Tier 2',
                                                               Partner_Account_Regions__c = 'APJ;LATAM;NA',
                                                               Partner_Account_Countrys__c = 'INDIA',
                                                               Exclude_Sales_Channels__c = 'FED',
                                                               Include_Sales__c = 'WED',
                                                               End_User_Account_Regions__c = 'APJ;LATAM',
                                                               End_User_Account_Countrys__c = 'INDIA',
                                                               Coverage__c = 'CFL;DELL CHANNEL',
                                                               Stack_Ranking__c = 2000,
                                                               Account_Classification__c = 'Commercial',
                                                               Exclude_Unassigned_End_User_Accounts__c = True);
        listDealProgram.add(testDealProgram1);
        Deal_program__c testDealProgram2 = new Deal_program__c(Deal_Program_Name__c = 'Storage NBI',
                                                               Benefit_Type__c = 'test',
                                                               Business_Unit__c = 'test',
                                                               Active__c = True,
                                                               Deal_Program_Description__c = 'test Program',
                                                               Start_Date__c = system.today(),
                                                               End_Date__c = system.today().adddays(10),                                                            
                                                               USD_Threshold__c = 400,
                                                               Fulfilment_Path__c = 'Direct fulfilment',
                                                               Partner_Type__c = 'Distributor (GCC)',
                                                               Partner_Relationships__c = 'Registered',
                                                               Partner_Tiers__c = 'Indirect Partner Purchase',
                                                               Partner_Account_Regions__c = 'APJ;LATAM',
                                                               Partner_Account_Countrys__c = 'INDIA',
                                                               Exclude_Sales_Channels__c = 'FED',
                                                               Include_Sales__c = 'WEST',
                                                               End_User_Account_Regions__c = 'APJ;LATAM;NA',
                                                               End_User_Account_Countrys__c = 'UNITED STATES',
                                                               Coverage__c = 'CFL',
                                                               Stack_Ranking__c = 2000,
                                                               Account_Classification__c = 'Commercial',
                                                               Exclude_Unassigned_End_User_Accounts__c = True);
        listDealProgram.add(testDealProgram2);
        Deal_program__c testDealProgram3 = new Deal_program__c(Deal_Program_Name__c = 'Data Protection NBI',
                                                               Benefit_Type__c = 'test',
                                                               Business_Unit__c = 'test',
                                                               Active__c = True,
                                                               Deal_Type__c = 'Fulfillment',
                                                               Deal_Program_Description__c = 'test Program',
                                                               Start_Date__c = system.today(),
                                                               End_Date__c = system.today().adddays(10),                                                            
                                                               USD_Threshold__c = 400,
                                                               Fulfilment_Path__c = 'Direct fulfilment',
                                                               Partner_Type__c = 'US Federal',
                                                               Partner_Relationships__c = 'Registered',
                                                               Partner_Tiers__c = 'Indirect Partner Purchase;Tier 1;Tier 2',
                                                               Partner_Account_Regions__c = 'APJ;LATAM;NA',
                                                               Partner_Account_Countrys__c = 'UNITED STATES',
                                                               Exclude_Sales_Channels__c = 'FED;TEST',
                                                               Include_Sales__c = 'WEST;Test',
                                                               Stack_Ranking__c = 2000,
                                                               End_User_Account_Regions__c = 'APJ;LATAM;NA',
                                                               End_User_Account_Countrys__c = 'UNITED STATES',
                                                               Coverage__c =  'DELL CHANNEL',
                                                               Exclude_Unassigned_End_User_Accounts__c = True);
        listDealProgram.add(testDealProgram3);
        Deal_program__c testDealProgram4 = new Deal_program__c(Deal_Program_Name__c = 'Test Phase',
                                                               Benefit_Type__c = 'test',
                                                               Business_Unit__c = 'test',
                                                               Active__c = True,
                                                               Deal_Type__c = 'Fulfillment',
                                                               Deal_Program_Description__c = 'test Program',
                                                               Start_Date__c = system.today(),
                                                               End_Date__c = system.today().adddays(10),                                                            
                                                               USD_Threshold__c = 400,
                                                               Fulfilment_Path__c = 'Direct fulfilment',
                                                               Partner_Type__c = 'US Federal',
                                                               Partner_Relationships__c = 'Registered',
                                                               Partner_Tiers__c = 'Indirect Partner Purchase;Tier 1;Tier 2',
                                                               Partner_Account_Regions__c = 'APJ;LATAM;NA',
                                                               Partner_Account_Countrys__c = 'UNITED STATES',
                                                               Exclude_Sales_Channels__c = 'FED;TEST',
                                                               Include_Sales__c = 'WEST;Test',
                                                               Stack_Ranking__c = 2000,
                                                               End_User_Account_Regions__c = 'APJ;LATAM;NA',
                                                               End_User_Account_Countrys__c = 'UNITED STATES',
                                                               Coverage__c =  'DELL CHANNEL',
                                                               Exclude_Unassigned_End_User_Accounts__c = True);
        listDealProgram.add(testDealProgram4);
        Database.insert(listDealProgram);
        System.assertEquals(true,testDealProgram4.Exclude_Unassigned_End_User_Accounts__c );
        List<Product2> listPrdts = new List<Product2>();  
        Product2 newPrdt1 = new Product2();
        newPrdt1.Name = 'Test Server';
        newPrdt1.ProductCode = 'Server';
        newPrdt1.Family='Enterprise Solution Group';
        newPrdt1.Product_ID__c = String.valueOf(System.today().year());
        newPrdt1.NBI_Eligible__c = true;
        newPrdt1.NBI_Category__c='Server';
        newPrdt1.Channel_Product_LOB__c = 'Server';
        newPrdt1.isActive = true;
        listPrdts.add(newPrdt1);
        Product2 newPrdt2 = new Product2();
        newPrdt2.Name = 'Test Client';
        newPrdt2.ProductCode = 'Client';
        newPrdt2.Family='Enterprise Solution Group';
        newPrdt2.Product_ID__c = String.valueOf(System.today().addYears(1));
        newPrdt2.NBI_Eligible__c = true;
        newPrdt2.NBI_Category__c='Client';
        newPrdt2.Channel_Product_LOB__c = 'Client';
        newPrdt2.isActive = true;
        listPrdts.add(newPrdt2);
        Product2 newPrdt3 = new Product2();
        newPrdt3.Name = 'Test Client';
        newPrdt3.ProductCode = 'Client';
        newPrdt3.Family='Enterprise Solution Group';
        newPrdt3.Product_ID__c = String.valueOf(System.today().addYears(2));
        newPrdt3.Channel_Product_LOB__c = 'Client';
        newPrdt3.isActive = true;
        listPrdts.add(newPrdt3);
        Product2 newPrdt4 = new Product2();
        newPrdt4.Name = 'Test Networking';
        newPrdt4.ProductCode = 'Networking';
        newPrdt4.Family='Enterprise Solution Group';
        newPrdt4.Product_ID__c = String.valueOf(System.today().addYears(3));
        newPrdt4.Channel_Product_LOB__c = 'Networking';
        listPrdts.add(newPrdt4);
        Product2 newPrdt5 = new Product2();
        newPrdt5.Name = 'Test Storage';
        newPrdt5.ProductCode = 'Storage';
        newPrdt5.Family='Enterprise Solution Group';
        newPrdt5.Product_ID__c = String.valueOf(System.today().addYears(5));
        newPrdt5.Channel_Product_LOB__c = 'Storage';
        newPrdt5.isActive = true;
        newPrdt5.NBI_Eligible__c = true;
        newPrdt5.NBI_Category__c='Storage';
        listPrdts.add(newPrdt5);
        Product2 newPrdt6 = new Product2();
        newPrdt6.Name = 'Test Data Protection';
        newPrdt6.ProductCode = 'Protection';
        newPrdt6.Family='Enterprise Solution Group';
        newPrdt6.Product_ID__c = String.valueOf(System.today().addYears(7));
        newPrdt6.Channel_Product_LOB__c = 'Storage';
        newPrdt6.isActive = true;
        newPrdt6.NBI_Eligible__c = true;
        newPrdt6.NBI_Category__c='Data Protection';
        listPrdts.add(newPrdt6);
        insert listPrdts;
        system.assertEquals(6, listPrdts.size());
        Id pricebookId = Test.getStandardPricebookId();  
        List<PricebookEntry> listPricBookEntry= new List<PricebookEntry>();
        for(Product2 prod :listPrdts){          
            PricebookEntry priceBookRecord = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id,
                                                                UnitPrice = 10000, IsActive = true);
            listPricBookEntry.add(priceBookRecord);
        }
        insert listPricBookEntry;
        list<OpportunityLineItem> listOppLineItem=TestDataFactory.createNOpportunityLineItem(4);
        listOppLineItem[0].Opportunityid=listOpp[1].id;
        listOppLineItem[0].pricebookEntryId=listPricBookEntry[0].Id;
        listOppLineItem[0].Quantity =1;
        listOppLineItem[0].Service_Support_US__c = 'ProSupport for Software';
        listOppLineItem[1].Opportunityid=listOpp[1].id;
        listOppLineItem[1].pricebookEntryId=listPricBookEntry[1].id;
        listOppLineItem[1].Quantity =1;
        listOppLineItem[1].Service_Support_US__c = 'ProSupport IT - Mission Critical';
        listOppLineItem[1].NBI_Category__c = 'Client';
        listOppLineItem[2].Opportunityid=listOpp[1].id;
        listOppLineItem[2].pricebookEntryId=listPricBookEntry[2].id;
        listOppLineItem[2].Quantity =1;
        listOppLineItem[2].Service_Support_US__c = 'ProSupport for Cloud Services';
        listOppLineItem[2].NBI_Category__c = 'Client';
        listOppLineItem[3].Opportunityid=listOpp[1].id;
        listOppLineItem[3].pricebookEntryId=listPricBookEntry[1].id;
        listOppLineItem[3].Quantity =1;
        listOppLineItem[3].Service_Support_US__c = 'ProSupport IT - Mission Critical';
        listOppLineItem[3].NBI_Category__c = 'Client';
        insert listOppLineItem;
        Test.startTest();
        List<Qualified_Program__c> listQP = new List<Qualified_Program__c>();
        Qualified_Program__c qp1 = new Qualified_Program__c();
        qp1.Product__c = listPrdts[0].Id;
        qp1.Opportunity__c = listOpp[1].Id;
        qp1.Deal_Program__C = listDealProgram[0].Id;
        listQP.add(qp1);
        Qualified_Program__c qp2 = new Qualified_Program__c();
        qp2.Product__c = listPrdts[1].Id;
        qp2.Opportunity__c = listOpp[1].Id;
        qp2.Deal_Program__C = listDealProgram[1].Id;
        listQP.add(qp2);
        Qualified_Program__c qp3 = new Qualified_Program__c();
        qp3.Product__c = listPrdts[2].Id;
        qp3.Opportunity__c = listOpp[1].Id;
        qp3.Deal_Program__C = listDealProgram[2].Id;
        listQP.add(qp3);
        Qualified_Program__c qp4 = new Qualified_Program__c();
        qp4.Product__c = listPrdts[4].Id;
        qp4.Opportunity__c = listOpp[1].Id;
        qp4.Deal_Program__C = listDealProgram[2].Id;
        listQP.add(qp4);
        Qualified_Program__c qp5 = new Qualified_Program__c();
        qp5.Product__c = listPrdts[0].Id;
        qp5.Opportunity__c = listOpp[1].Id;
        qp5.Deal_Program__C = listDealProgram[3].Id;
        listQP.add(qp5);
        Qualified_Program__c qp6 = new Qualified_Program__c();
        qp6.Product__c = listPrdts[0].Id;
        qp6.Opportunity__c = listOpp[1].Id;
        qp6.Deal_Program__C = listDealProgram[2].Id;
        listQP.add(qp6);
        Qualified_Program__c qp7 = new Qualified_Program__c();
        qp7.Product__c = listPrdts[0].Id;
        qp7.Opportunity__c = listOpp[1].Id;
        qp7.Deal_Program__C = listDealProgram[3].Id;
        listQP.add(qp7);
        insert listQP;
        system.assertEquals(7, listQP.size());
        delete listQP;
        Test.stopTest();
    }
}