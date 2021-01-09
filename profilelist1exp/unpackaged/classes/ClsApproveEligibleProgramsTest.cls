@isTest
public class ClsApproveEligibleProgramsTest {
    static list<Account> listAcc;
    static list<Account> listAcc1;

    static list<opportunity> listOpp=new list<opportunity>();
    static list<OpportunityLineItem> listOppLineItem;
    static List<String> listObjAPINames = new List<String>{'Opportunity'};
        @testSetup static void setup() {
            TriggerExecutionController.setSkipAllTriggers(true);
            List<Account> listAccfromFactory=TestDataFactory.createNAccount(3, 'Partner Account');
            List<Account> listAccfromFactory1=TestDataFactory.createNAccount(1, 'End-User Account');
 //  Map < Id, Deal_program__c > activeProgramsMap = new Map < Id, Deal_program__c > activeProgramsMap;

            insert listAccfromFactory;
            List<Opportunity> listOppFromFactory=TestDataFactory.CreateNOpportunities(1, 'Deal Registration');
            insert listOppFromFactory;
            list<OpportunityLineItem> listOppLineItemTdf=TestDataFactory.createNOpportunityLineItem(3);
            listOppLineItemTdf[0].OpportunityID=listOppFromFactory[0].id;
            listOppLineItemTdf[1].OpportunityID=listOppFromFactory[0].id;
            listOppLineItemTdf[2].OpportunityID=listOppFromFactory[0].id;
            insert listOppLineItemTdf;
        }

      
        Static testmethod void testEvaluationMethod3(){
        TriggerExecutionController.setSkipAllTriggers(true);
        List<String> listObjAPINames = new List<String>{'Opportunity'};
            listAcc=[select id from account];
        for(account acc : listAcc){
            acc.Partner_Tier__c = 'Tier 2';
            acc.Partner_Relationship__c = 'Registered';
            acc.Account_Country_Code__c ='US';
            acc.Account_Country__c = 'UNITED STATES';
        }
        listAcc[0].RecordTypeId=getRecordTypeIdbyName('Partner Account','Account');
        listAcc[0].Partner_Type__c = 'US Federal';
        listAcc[0].ispartner = true;
        listAcc[0].Account_Country_Code__c ='US';
        listAcc[0].Account_Country__c = 'UNITED STATES';

        //listAcc[1].Partner_Type__c = 'Federal Distributor';
        update listAcc;
        
        Sales_Channel_Group__c testSalesChannel = new Sales_Channel_Group__c(Name = 'MFG WEST',
                                                                             Sales_Method_Name__c = 'commercial');
        Insert testSalesChannel;     
        listAcc[2].RecordTypeId=getRecordTypeIdbyName('End-User Account','Account');
        listAcc[2].Partner_Type__c = 'COMMERCIAL';
        listAcc[2].Partner_Tier__c = 'Tier 1';
        listAcc[2].Sales_Channel__c = testSalesChannel.id;
        listAcc[2].GTM_Model__c = 'DELL CHANNEL';
        update listAcc;
        system.assertNotEquals(listAcc[2].id, null);
        Contact partnerContact = new Contact(FirstName = 'MyTestContact',
                                             LastName = 'MyTestContact',
                                             AccountId =listAcc[0].Id,
                                             Status__c  =  'Marketing Suspect',
                                             Email = 'dealregTestContact@dell.com',
                                             Fax = '1234567',
                                             MobilePhone = '0987654',
                                             Last_Operation_Performed__c = 'testing',
                                             Phone = '1234500');
        insert partnerContact;
        final List<Profile> partnerProfiles = [select Id, Name from Profile where profile.name='System Administrator' limit 1];
        system.debug('*****' +partnerProfiles);
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
                                    Badge_Number__c='DealReg123', 
                                    isActive = TRUE,
                                    DefaultCurrencyIsoCode = 'USD'
                                   );
        insert partnerUser;
        listOpp=[select id from Opportunity];
        listOpp[0].Deal_Registration_Status__c= 'New';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes';
        listOpp[0].Forecast_Category_Override__c = 'Omitted';
        system.runAs(partnerUser){
            update listOpp;
        } 
        listOpp[0].AccountId = listAcc[0].id;
        listOpp[0].Distributor_Reseller_Name__c = listAcc[1].id;
        listOpp[0].Deal_Type__c = 'Fulfillment';
        update listOpp;
        Country__c country = new Country__c(Name='UNITED STATES',
                                            Code__c='US',
                                            Dell_Online_Country_Code__c ='US',
                                            Region__c ='NA');
       // insert country;   
        list<Country__c> listc=new list<Country__c>();
        listc.add(country);
        insert listc;
        List<Deal_Program__c> listdealProgram = new List<Deal_Program__c>();
        List<Custom_Partner_Accounts__c> listcustomPartnerAcc = new List<Custom_Partner_Accounts__c>();


            Deal_program__c testDealProgram1 = new Deal_program__c(Deal_Program_Name__c = 'testDealProgram1',
                                                               Benefit_Type__c = 'test',
                                                               Business_Unit__c = 'test',
                                                               Active__c = True,
                                                               Deal_Program_Description__c = 'test Program',
                                                               Program_Region__c='NA',
                                                               Start_Date__c = system.today(),
                                                               End_Date__c = system.today().adddays(10),                                                            
                                                               USD_Threshold__c = 900,
                                                               Fulfilment_Path__c = 'Distribution',
                                                               Partner_Type__c = 'Distributor (GCC)',
                                                               Partner_Relationships__c = 'Registered',
                                                               Partner_Tiers__c = 'Indirect Partner Purchase;Tier 1;Tier 2',
                                                               Partner_Account_Regions__c = 'APJ;LATAM;NA',
                                                               Distributor_Reseller_Account_Region_s__c='APJ;LATAM;NA',
                                                               Partner_Account_Countrys__c = 'INDIA',
                                                               Exclude_Sales_Channels__c = 'FED',
                                                               Include_Sales__c = 'WED',
                                                               End_User_Account_Regions__c = 'APJ;LATAM',
                                                               End_User_Account_Countrys__c = 'INDIA',
                                                               Coverage__c = 'CFL;DELL CHANNEL',
                                                               Stack_Ranking__c = 10,
                                                               Deal_Type__c = 'Fulfillment',
                                                               Account_Classification__c = 'Commercial',
                                                               Exclude_Unassigned_End_User_Accounts__c = True);
        listdealProgram.add(testDealProgram1);
        Deal_program__c testDealProgram2 = new Deal_program__c(Deal_Program_Name__c = 'testDealProgram2',
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
                                                               Distributor_Reseller_Account_Region_s__c='APJ;LATAM;NA',
                                                               Partner_Account_Countrys__c = 'INDIA',
                                                               Exclude_Sales_Channels__c = 'FED',
                                                               Include_Sales__c = 'WEST',
                                                               End_User_Account_Regions__c = 'APJ;LATAM;NA',
                                                               End_User_Account_Countrys__c = 'UNITED STATES',
                                                               Coverage__c = 'CFL',
                                                               Stack_Ranking__c = 20,
                                                               Program_Region__c='NA',
                                                               Deal_Type__c = 'Fulfillment',
                                                               Account_Classification__c = 'Commercial',
                                                               Exclude_Unassigned_End_User_Accounts__c = True);
        listdealProgram.add(testDealProgram2);
        Deal_program__c testDealProgram3 = new Deal_program__c(Deal_Program_Name__c = 'testDealProgram3',
                                                               Benefit_Type__c = 'test',
                                                               Business_Unit__c = 'test',
                                                               Active__c = True,
                                                               Deal_Type__c = 'Fulfillment',
                                                               Deal_Program_Description__c = 'test Program',
                                                               Program_Region__c='NA',
                                                               Start_Date__c = system.today(),
                                                               End_Date__c = system.today().adddays(10),                                                            
                                                               USD_Threshold__c = 400,
                                                               Fulfilment_Path__c = 'Direct fulfilment',
                                                               Partner_Type__c = 'US Federal',
                                                               Partner_Relationships__c = 'Registered',
                                                               Partner_Tiers__c = 'Indirect Partner Purchase;Tier 1;Tier 2',
                                                               Partner_Account_Regions__c = 'APJ;LATAM;NA',
                                                               Distributor_Reseller_Account_Region_s__c='APJ;LATAM;NA',
                                                               Partner_Account_Countrys__c = 'UNITED STATES',
                                                               Exclude_Sales_Channels__c = 'FED;TEST',
                                                               Include_Sales__c = 'WEST;Test',
                                                               Stack_Ranking__c = 3,
                                                               End_User_Account_Regions__c = 'APJ;LATAM;NA',
                                                               End_User_Account_Countrys__c = 'UNITED STATES',
                                                               Coverage__c =  'DELL CHANNEL',
                                                               Exclude_Unassigned_End_User_Accounts__c = True);
        listdealProgram.add(testDealProgram3);
        Database.insert(listdealProgram);
                system.debug('---------180---'+listdealProgram);

        Map<id,Deal_Program__c> mapDeal=new Map<id,Deal_Program__c>();
        for(Deal_Program__c del : listdealProgram){
            mapDeal.put(del.id,del);
        }
           Id pricebookId = Test.getStandardPricebookId();   
      List<String> prodCodeList = new List<String> {'Workstations','Notebooks','Storage Systems','PowerEdge Servers','Networking Software'};      
      List<Product2> prodList = new List<Product2>();
      List<PricebookEntry> pricBookList = new List<PricebookEntry>();
      List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
      for(Integer j=0;j < prodCodeList.size();j++){      
         Product2 prod = new Product2(Name = prodCodeList[j],ProductCode = prodCodeList[j],
                                       Family = 'Hardware',
                                     Channel_Product_LOB__c = 'NETWORKING', isActive = true ,Product_ID__c = 'P1' + j);
         prodList.add(prod);
      }
      for(Integer j=0;j < prodCodeList.size();j++){      
         Product2 undefinedProd = new Product2(Name = prodCodeList[j],Family = 'Hardware',Product_ID__c = 'P2' + j);
         prodList.add(undefinedProd);
      }
      insert prodList;
      for(Product2 prod :prodList){          
        PricebookEntry priceBookRecord = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id,
                                                           UnitPrice = 10000, IsActive = true);
        pricBookList.add(priceBookRecord);
      }
      insert pricBookList;
      for(PricebookEntry priceBookRecord : pricBookList){  
        OpportunityLineItem  oliRecord = new OpportunityLineItem(Opportunityid =listOpp[0].Id,
                                                                    pricebookEntryId=priceBookRecord.Id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical');
        oliList.add(oliRecord);   
      }
      insert oliList;
      
        listOppLineItem=[select id from OpportunityLineItem Limit 3];
        TriggerExecutionController.setSkipAllTriggers(true);
         Custom_Products__c cp1 = new Custom_Products__c(Include__c = true, Deal_Program__c = testDealProgram3.id, Filter_type__c = 'Product Group', Criteria__c = 'Hardware', Product__c = null);
        Custom_Products__c cp2 = new Custom_Products__c(Exclude__c = true, Deal_Program__c = testDealProgram3.id, Filter_type__c = 'Product Group', Criteria__c = 'Hardware',  Product__c = null);
        Custom_Products__c cp3 = new Custom_Products__c(Include__c = true, Deal_Program__c = testDealProgram3.id, Filter_type__c = null, Criteria__c = null, Product__c = prodList[0].id);
        Custom_Products__c cp4 = new Custom_Products__c(Exclude__c = true, Deal_Program__c = testDealProgram3.id, Filter_type__c = null, Criteria__c = null, Product__c = prodList[1].id);
        
        List<Custom_Products__c> cplist = new List<Custom_Products__c>();
        cplist.add(cp1);
        cplist.add(cp2);
        cplist.add(cp3);
        cplist.add(cp4);
        insert cplist;
        Qualified_Program__c qp = new Qualified_Program__c(Opportunity__c=listOpp[0].id,Deal_Program__c=listdealProgram[0].id,Product__c=prodList[0].id);
        insert qp;
        Custom_Partner_Accounts__c CPA = new Custom_Partner_Accounts__c(Account__c=listAcc[0].id,Exclude__c=true,Deal_Program__c=listdealProgram[1].id);
            insert CPA;
            
            Custom_End_User_Accounts__c CEA = new Custom_End_User_Accounts__c(Deal_Program__c=listdealProgram[0].id,Account__c=listAcc[2].id,Include__c =true);
            insert CEA;
        Test.starttest();
        PageReference pageRef123 = Page.ApproveEligiblePrograms;
        Test.setCurrentPage(pageRef123);
        ApexPages.Standardcontroller sc123 = new ApexPages.Standardcontroller(listOpp[0]);
        ApexPages.currentPage().getParameters().put('cid',listOpp[0].id);
        clsApproveEligiblePrograms aEP = new clsApproveEligiblePrograms(sc123);    
        aEP.onPageLoad();    
        aEP.saveApproved(); 
        //string str =listprod[0].id;
        try{
        aEP.FrameFinalMap();
        aEP.RemoveMethod(prodList[0].id,cplist[0]); 
        }
        catch(exception e)
        {}  
        Apexpages.Currentpage().getparameters().put('selected_ids1',qp.id);
        Apexpages.Currentpage().getparameters().put('selected_ids',qp.id);
aep.MainMethod();
        aEP.saveRejected();
        aEP.dealslist();
        aEP.UpdateOpportunity();
        Apexpages.Currentpage().getparameters().put('ProductId',cplist[0].id);
        aEP.showPopup();
        aEP.cancel();
        aEP.closepopup();
        Apexpages.Currentpage().getparameters().put('selected_ids1',listdealProgram[2].id);
        aEP.Savelist();
        PageReference pageRef1234 = Page.ApproveEligiblePrograms;
        Test.setCurrentPage(pageRef1234);
        ApexPages.Standardcontroller sc1234 = new ApexPages.Standardcontroller(testDealProgram3);
        clsApproveEligiblePrograms aEPs = new clsApproveEligiblePrograms(sc1234);    
        Test.stoptest();
        Apexpages.Currentpage().getparameters().put('ProductId',cplist[0].id);
        

        
    }
        Static testmethod void testEvaluationMethod4(){
        TriggerExecutionController.setSkipAllTriggers(true);
        List<String> listObjAPINames = new List<String>{'Opportunity'};
            listAcc=[select id from account];
        for(account acc : listAcc){
            acc.Partner_Tier__c = 'Tier 2';
            acc.Partner_Relationship__c = 'Registered';
            acc.Account_Country_Code__c ='US';
            acc.Account_Country__c = 'UNITED STATES';
        }
         
        listAcc[0].Partner_Type__c = 'US Federal';
        listAcc[0].ispartner = true;
        listAcc[0].Account_Country_Code__c ='US';
        listAcc[0].Account_Country__c = 'UNITED STATES';

        //listAcc[1].Partner_Type__c = 'Federal Distributor';
        update listAcc;
        
        Sales_Channel_Group__c testSalesChannel = new Sales_Channel_Group__c(Name = 'MFG WEST',
                                                                             Sales_Method_Name__c = 'commercial');
        Insert testSalesChannel;     
        listAcc[2].RecordTypeId=getRecordTypeIdbyName('End-User Account','Account');
        listAcc[2].Partner_Type__c = 'COMMERCIAL';
        listAcc[2].Partner_Tier__c = 'Tier 1';
        listAcc[2].Sales_Channel__c = testSalesChannel.id;
        listAcc[2].GTM_Model__c = 'DELL CHANNEL';
        update listAcc;
        system.assertNotEquals(listAcc[2].id, null);
        Contact partnerContact = new Contact(FirstName = 'MyTestContact',
                                             LastName = 'MyTestContact',
                                             AccountId =listAcc[0].Id,
                                             Status__c  =  'Marketing Suspect',
                                             Email = 'dealregTestContact@dell.com',
                                             Fax = '1234567',
                                             MobilePhone = '0987654',
                                             Last_Operation_Performed__c = 'testing',
                                             Phone = '1234500');
        insert partnerContact;
        final List<Profile> partnerProfiles = [select Id, Name from Profile where profile.name='System Administrator' limit 1];
        system.debug('*****' +partnerProfiles);
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
                                    Badge_Number__c='DealReg123', 
                                    isActive = TRUE,
                                    DefaultCurrencyIsoCode = 'USD'
                                   );
        insert partnerUser;
        listOpp=[select id from Opportunity];
        listOpp[0].Deal_Registration_Status__c= 'New';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes';
        listOpp[0].Forecast_Category_Override__c = 'Omitted';
        system.runAs(partnerUser){
            update listOpp;
        } 
        listOpp[0].AccountId = listAcc[2].id;
        listOpp[0].Distributor_Reseller_Name__c = listAcc[1].id;
        listOpp[0].Deal_Type__c = 'Fulfillment';
        update listOpp;
        Country__c country = new Country__c(Name='UNITED STATES',
                                            Code__c='US',
                                            Dell_Online_Country_Code__c ='US',
                                            Region__c ='NA');
       // insert country;   
        list<Country__c> listc=new list<Country__c>();
        listc.add(country);
        insert listc;
        List<Deal_Program__c> listdealProgram = new List<Deal_Program__c>();
        List<Custom_Partner_Accounts__c> listcustomPartnerAcc = new List<Custom_Partner_Accounts__c>();


            Deal_program__c testDealProgram1 = new Deal_program__c(Deal_Program_Name__c = 'testDealProgram1',
                                                               Benefit_Type__c = 'test',
                                                               Business_Unit__c = 'test',
                                                               Active__c = True,
                                                               Deal_Program_Description__c = 'test Program',
                                                               Program_Region__c='NA',
                                                               Start_Date__c = system.today(),
                                                               End_Date__c = system.today().adddays(10),                                                            
                                                               USD_Threshold__c = 900,
                                                               Fulfilment_Path__c = 'Distribution',
                                                               Partner_Type__c = 'Distributor (GCC)',
                                                               Partner_Relationships__c = 'Registered',
                                                               Partner_Tiers__c = 'Indirect Partner Purchase;Tier 1;Tier 2',
                                                               Partner_Account_Regions__c = 'APJ;LATAM;NA',
                                                               Distributor_Reseller_Account_Region_s__c='APJ;LATAM;NA',
                                                               Partner_Account_Countrys__c = 'INDIA',
                                                               Exclude_Sales_Channels__c = 'FED',
                                                               Include_Sales__c = 'WED',
                                                               End_User_Account_Regions__c = 'APJ;LATAM',
                                                               End_User_Account_Countrys__c = 'INDIA',
                                                               Coverage__c = 'CFL;DELL CHANNEL',
                                                               Stack_Ranking__c = 10,
                                                               Deal_Type__c = 'Fulfillment',
                                                               Account_Classification__c = 'Commercial',
                                                               Exclude_Unassigned_End_User_Accounts__c = True);
        listdealProgram.add(testDealProgram1);
        Deal_program__c testDealProgram2 = new Deal_program__c(Deal_Program_Name__c = 'testDealProgram2',
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
                                                               Distributor_Reseller_Account_Region_s__c='APJ;LATAM;NA',
                                                               Partner_Account_Countrys__c = 'INDIA',
                                                               Exclude_Sales_Channels__c = 'FED',
                                                               Include_Sales__c = 'WEST',
                                                               End_User_Account_Regions__c = 'APJ;LATAM;NA',
                                                               End_User_Account_Countrys__c = 'UNITED STATES',
                                                               Coverage__c = 'CFL',
                                                               Stack_Ranking__c = 20,
                                                               Program_Region__c='NA',
                                                               Deal_Type__c = 'Fulfillment',
                                                               Account_Classification__c = 'Commercial',
                                                               Exclude_Unassigned_End_User_Accounts__c = True);
        listdealProgram.add(testDealProgram2);
        Deal_program__c testDealProgram3 = new Deal_program__c(Deal_Program_Name__c = 'testDealProgram3',
                                                               Benefit_Type__c = 'test',
                                                               Business_Unit__c = 'test',
                                                               Active__c = True,
                                                               Deal_Type__c = 'Fulfillment',
                                                               Deal_Program_Description__c = 'test Program',
                                                               Program_Region__c='NA',
                                                               Start_Date__c = system.today(),
                                                               End_Date__c = system.today().adddays(10),                                                            
                                                               USD_Threshold__c = 400,
                                                               Fulfilment_Path__c = 'Direct fulfilment',
                                                               Partner_Type__c = 'US Federal',
                                                               Partner_Relationships__c = 'Registered',
                                                               Partner_Tiers__c = 'Indirect Partner Purchase;Tier 1;Tier 2',
                                                               Partner_Account_Regions__c = 'APJ;LATAM;NA',
                                                               Distributor_Reseller_Account_Region_s__c='APJ;LATAM;NA',
                                                               Partner_Account_Countrys__c = 'UNITED STATES',
                                                               Exclude_Sales_Channels__c = 'FED;TEST',
                                                               Include_Sales__c = 'WEST;Test',
                                                               Stack_Ranking__c = 3,
                                                               End_User_Account_Regions__c = 'APJ;LATAM;NA',
                                                               End_User_Account_Countrys__c = 'UNITED STATES',
                                                               Coverage__c =  'DELL CHANNEL',
                                                               Exclude_Unassigned_End_User_Accounts__c = True);
        listdealProgram.add(testDealProgram3);
        Database.insert(listdealProgram);
                system.debug('---------180---'+listdealProgram);

        Map<id,Deal_Program__c> mapDeal=new Map<id,Deal_Program__c>();
        for(Deal_Program__c del : listdealProgram){
            mapDeal.put(del.id,del);
        }
        Id pricebookId = Test.getStandardPricebookId();   
        List<String> listprodCode = new List<String> {'Workstations','Notebooks','Storage Systems','PowerEdge Servers','Networking Software'};      
            List<Product2> listprod = new List<Product2>();
        List<PricebookEntry> listpricBook = new List<PricebookEntry>();
        List<OpportunityLineItem> listoli = new List<OpportunityLineItem>();
        Product2 prod = new Product2(Name = 'Worksta',ProductCode = 'Workstations',
                                     Family = 'Hardware',
                                     Channel_Product_LOB__c = 'NETWORKING', isActive = true ,Product_ID__c = 'P1');
        listprod.add(prod);
         
        Product2 undefinedProd = new Product2(Name = 'Notebooks',Family = 'Hardware',Product_ID__c = 'P2');
        listprod.add(undefinedProd);
        insert listprod;
        listOppLineItem=[select id from OpportunityLineItem Limit 3];
        TriggerExecutionController.setSkipAllTriggers(true);
        Custom_Products__c cp1 = new Custom_Products__c(Include__c = true, Deal_Program__c = listdealProgram[0].id, Filter_type__c = 'Product Group', Criteria__c = 'Hardware', Product__c = null);
        Custom_Products__c cp2 = new Custom_Products__c(Exclude__c = true, Deal_Program__c = listdealProgram[1].id, Filter_type__c = 'Product Group', Criteria__c = 'Hardware',  Product__c = null);
        List<Custom_Products__c> listcp = new List<Custom_Products__c>();
        listcp.add(cp1);
        listcp.add(cp2);
        insert listcp;
        Qualified_Program__c qp = new Qualified_Program__c(Opportunity__c=listOpp[0].id,Deal_Program__c=listdealProgram[0].id,Product__c=listprod[0].id);
        insert qp;
        Custom_Partner_Accounts__c CPA = new Custom_Partner_Accounts__c(Account__c=listAcc[0].id,Include__c=true,Deal_Program__c=listdealProgram[1].id);
            insert CPA;
            
            Custom_End_User_Accounts__c CEA = new Custom_End_User_Accounts__c(Deal_Program__c=listdealProgram[0].id,Account__c=listAcc[2].id,Exclude__c =true);
            insert CEA;
        Test.starttest();
        PageReference pageRef123 = Page.ApproveEligiblePrograms;
        Test.setCurrentPage(pageRef123);
        ApexPages.Standardcontroller sc123 = new ApexPages.Standardcontroller(listOpp[0]);
        ApexPages.currentPage().getParameters().put('cid',listOpp[0].id);
        clsApproveEligiblePrograms aEP = new clsApproveEligiblePrograms(sc123);    
        aEP.onPageLoad();    
        aEP.saveApproved(); 
        //string str =listprod[0].id;
        try{
        aEP.FrameFinalMap();
        aEP.RemoveMethod(listprod[0].id,listcp[0]); 
        }
        catch(exception e)
        {}  
        Apexpages.Currentpage().getparameters().put('selected_ids1',qp.id);
        Apexpages.Currentpage().getparameters().put('selected_ids',qp.id);

        aEP.saveRejected();
        aEP.dealslist();
        aEP.UpdateOpportunity();
        Apexpages.Currentpage().getparameters().put('ProductId',listcp[0].id);
        aEP.showPopup();
        aEP.cancel();
        aEP.closepopup();
        Apexpages.Currentpage().getparameters().put('selected_ids1',listdealProgram[2].id);
        aEP.Savelist();
        PageReference pageRef1234 = Page.ApproveEligiblePrograms;
        Test.setCurrentPage(pageRef1234);
        ApexPages.Standardcontroller sc1234 = new ApexPages.Standardcontroller(testDealProgram3);
        clsApproveEligiblePrograms aEPs = new clsApproveEligiblePrograms(sc1234);    
        Test.stoptest();
        Apexpages.Currentpage().getparameters().put('ProductId',listcp[0].id);
        

        
    }
        Static testmethod void testEvaluationMethod6(){
        TriggerExecutionController.setSkipAllTriggers(true);
        List<String> listObjAPINames = new List<String>{'Opportunity'};
            listAcc=[select id from account];
        for(account acc : listAcc){
            acc.Partner_Tier__c = 'Tier 2';
            acc.Partner_Relationship__c = 'Registered';
            acc.Account_Country_Code__c ='US';
            acc.Account_Country__c = 'UNITED STATES';
        }
         
        listAcc[0].Partner_Type__c = 'US Federal';
        listAcc[0].ispartner = true;
        listAcc[0].Account_Country_Code__c ='US';
        listAcc[0].Account_Country__c = 'UNITED STATES';

        //listAcc[1].Partner_Type__c = 'Federal Distributor';
        update listAcc;
        
        Sales_Channel_Group__c testSalesChannel = new Sales_Channel_Group__c(Name = 'MFG WEST',
                                                                             Sales_Method_Name__c = 'commercial');
        Insert testSalesChannel;     
        listAcc[2].RecordTypeId=getRecordTypeIdbyName('End-User Account','Account');
        listAcc[2].Partner_Type__c = 'COMMERCIAL';
        listAcc[2].Partner_Tier__c = 'Tier 1';
        listAcc[2].Sales_Channel__c = testSalesChannel.id;
        listAcc[2].GTM_Model__c = 'DELL CHANNEL';
        update listAcc;
        system.assertNotEquals(listAcc[2].id, null);
        Contact partnerContact = new Contact(FirstName = 'MyTestContact',
                                             LastName = 'MyTestContact',
                                             AccountId =listAcc[0].Id,
                                             Status__c  =  'Marketing Suspect',
                                             Email = 'dealregTestContact@dell.com',
                                             Fax = '1234567',
                                             MobilePhone = '0987654',
                                             Last_Operation_Performed__c = 'testing',
                                             Phone = '1234500');
        insert partnerContact;
        final List<Profile> partnerProfiles = [select Id, Name from Profile where profile.name='System Administrator' limit 1];
        system.debug('*****' +partnerProfiles);
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
                                    Badge_Number__c='DealReg123', 
                                    isActive = TRUE,
                                    DefaultCurrencyIsoCode = 'USD'
                                   );
        insert partnerUser;
        listOpp=[select id from Opportunity];
        listOpp[0].Deal_Registration_Status__c= 'New';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes';
        listOpp[0].Forecast_Category_Override__c = 'Omitted';
        system.runAs(partnerUser){
            update listOpp;
        } 
        listOpp[0].AccountId = listAcc[2].id;
        listOpp[0].Distributor_Reseller_Name__c = listAcc[1].id;
        listOpp[0].Deal_Type__c = 'Fulfillment';
        update listOpp;
        Country__c country = new Country__c(Name='UNITED STATES',
                                            Code__c='US',
                                            Dell_Online_Country_Code__c ='US',
                                            Region__c ='NA');
       // insert country;   
        list<Country__c> listc=new list<Country__c>();
        listc.add(country);
        insert listc;
        List<Deal_Program__c> listdealProgram = new List<Deal_Program__c>();
        List<Custom_Partner_Accounts__c> listcustomPartnerAcc = new List<Custom_Partner_Accounts__c>();


            Deal_program__c testDealProgram1 = new Deal_program__c(Deal_Program_Name__c = 'testDealProgram1',
                                                               Benefit_Type__c = 'test',
                                                               Business_Unit__c = 'test',
                                                               Active__c = True,
                                                               Deal_Program_Description__c = 'test Program',
                                                               Program_Region__c='NA',
                                                               Start_Date__c = system.today(),
                                                               End_Date__c = system.today().adddays(10),                                                            
                                                               USD_Threshold__c = 900,
                                                               Fulfilment_Path__c = 'Distribution',
                                                               Partner_Type__c = 'Distributor (GCC)',
                                                               Partner_Relationships__c = 'Registered',
                                                               Partner_Tiers__c = 'Indirect Partner Purchase;Tier 1;Tier 2',
                                                               Partner_Account_Regions__c = 'APJ;LATAM;NA',
                                                               Distributor_Reseller_Account_Region_s__c='APJ;LATAM;NA',
                                                               Partner_Account_Countrys__c = 'INDIA',
                                                               Exclude_Sales_Channels__c = 'FED',
                                                               Include_Sales__c = 'WED',
                                                               End_User_Account_Regions__c = 'APJ;LATAM',
                                                               End_User_Account_Countrys__c = 'INDIA',
                                                               Coverage__c = 'CFL;DELL CHANNEL',
                                                               Stack_Ranking__c = 10,
                                                               Deal_Type__c = 'Fulfillment',
                                                               Account_Classification__c = 'Commercial',
                                                               Exclude_Unassigned_End_User_Accounts__c = True);
        listdealProgram.add(testDealProgram1);
        Deal_program__c testDealProgram2 = new Deal_program__c(Deal_Program_Name__c = 'testDealProgram2',
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
                                                               Distributor_Reseller_Account_Region_s__c='APJ;LATAM;NA',
                                                               Partner_Account_Countrys__c = 'INDIA',
                                                               Exclude_Sales_Channels__c = 'FED',
                                                               Include_Sales__c = 'WEST',
                                                               End_User_Account_Regions__c = 'APJ;LATAM;NA',
                                                               End_User_Account_Countrys__c = 'UNITED STATES',
                                                               Coverage__c = 'CFL',
                                                               Stack_Ranking__c = 20,
                                                               Program_Region__c='NA',
                                                               Deal_Type__c = 'Fulfillment',
                                                               Account_Classification__c = 'Commercial',
                                                               Exclude_Unassigned_End_User_Accounts__c = True);
        listdealProgram.add(testDealProgram2);
        Deal_program__c testDealProgram3 = new Deal_program__c(Deal_Program_Name__c = 'testDealProgram3',
                                                               Benefit_Type__c = 'test',
                                                               Business_Unit__c = 'test',
                                                               Active__c = True,
                                                               Deal_Type__c = 'Fulfillment',
                                                               Deal_Program_Description__c = 'test Program',
                                                               Program_Region__c='NA',
                                                               Start_Date__c = system.today(),
                                                               End_Date__c = system.today().adddays(10),                                                            
                                                               USD_Threshold__c = 400,
                                                               Fulfilment_Path__c = 'Direct fulfilment',
                                                               Partner_Type__c = 'US Federal',
                                                               Partner_Relationships__c = 'Registered',
                                                               Partner_Tiers__c = 'Indirect Partner Purchase;Tier 1;Tier 2',
                                                               Partner_Account_Regions__c = 'APJ;LATAM;NA',
                                                               Distributor_Reseller_Account_Region_s__c='APJ;LATAM;NA',
                                                               Partner_Account_Countrys__c = 'UNITED STATES',
                                                               Exclude_Sales_Channels__c = 'FED;TEST',
                                                               Include_Sales__c = 'WEST;Test',
                                                               Stack_Ranking__c = 3,
                                                               End_User_Account_Regions__c = 'APJ;LATAM;NA',
                                                               End_User_Account_Countrys__c = 'UNITED STATES',
                                                               Coverage__c =  'DELL CHANNEL',
                                                               Exclude_Unassigned_End_User_Accounts__c = True);
        listdealProgram.add(testDealProgram3);
        Database.insert(listdealProgram);
                system.debug('---------180---'+listdealProgram);

        Map<id,Deal_Program__c> mapDeal=new Map<id,Deal_Program__c>();
        for(Deal_Program__c del : listdealProgram){
            mapDeal.put(del.id,del);
        }
        Id pricebookId = Test.getStandardPricebookId();   
        List<String> listprodCode = new List<String> {'Workstations','Notebooks','Storage Systems','PowerEdge Servers','Networking Software'};      
            List<Product2> listprod = new List<Product2>();
        List<PricebookEntry> listpricBook = new List<PricebookEntry>();
        List<OpportunityLineItem> listoli = new List<OpportunityLineItem>();
        Product2 prod = new Product2(Name = 'Worksta',ProductCode = 'Workstations',
                                     Family = 'Hardware',
                                     Channel_Product_LOB__c = 'NETWORKING', isActive = true ,Product_ID__c = 'P1');
        listprod.add(prod);
         
        Product2 undefinedProd = new Product2(Name = 'Notebooks',Family = 'Hardware',Product_ID__c = 'P2');
        listprod.add(undefinedProd);
        insert listprod;
        listOppLineItem=[select id from OpportunityLineItem Limit 3];
        TriggerExecutionController.setSkipAllTriggers(true);
        Custom_Products__c cp1 = new Custom_Products__c(Include__c = true, Deal_Program__c = listdealProgram[0].id, Filter_type__c = 'Product Group', Criteria__c = 'Hardware', Product__c = null);
        Custom_Products__c cp2 = new Custom_Products__c(Exclude__c = true, Deal_Program__c = listdealProgram[1].id, Filter_type__c = 'Product Group', Criteria__c = 'Hardware',  Product__c = null);
        List<Custom_Products__c> listcp = new List<Custom_Products__c>();
        listcp.add(cp1);
        listcp.add(cp2);
        insert listcp;
        Qualified_Program__c qp = new Qualified_Program__c(Opportunity__c=listOpp[0].id,Deal_Program__c=listdealProgram[0].id,Product__c=listprod[0].id);
        insert qp;
        Custom_Partner_Accounts__c CPA = new Custom_Partner_Accounts__c(Account__c=listAcc[0].id,Include__c=true,Deal_Program__c=listdealProgram[1].id);
            insert CPA;
            
            Custom_End_User_Accounts__c CEA = new Custom_End_User_Accounts__c(Deal_Program__c=listdealProgram[0].id,Account__c=listAcc[2].id,Include__c =true);
            insert CEA;
        Test.starttest();
        PageReference pageRef123 = Page.ApproveEligiblePrograms;
        Test.setCurrentPage(pageRef123);
        ApexPages.Standardcontroller sc123 = new ApexPages.Standardcontroller(listAcc[0]);
        ApexPages.currentPage().getParameters().put('cid',listOpp[0].id);
        clsApproveEligiblePrograms aEP = new clsApproveEligiblePrograms(sc123);    
        aEP.onPageLoad();    
        aEP.saveApproved(); 
        //string str =listprod[0].id;
        try{
        aEP.FrameFinalMap();
        aEP.RemoveMethod(listprod[0].id,listcp[0]); 
        }
        catch(exception e)
        {}  
        Apexpages.Currentpage().getparameters().put('selected_ids1',qp.id);
        Apexpages.Currentpage().getparameters().put('selected_ids',qp.id);

        aEP.saveRejected();
        aEP.dealslist();
        aEP.UpdateOpportunity();
        Apexpages.Currentpage().getparameters().put('ProductId',listcp[0].id);
        aEP.showPopup();
        aEP.cancel();
        aEP.closepopup();
        Apexpages.Currentpage().getparameters().put('selected_ids1',listdealProgram[2].id);
        aEP.Savelist();
        PageReference pageRef1234 = Page.ApproveEligiblePrograms;
        Test.setCurrentPage(pageRef1234);
        ApexPages.Standardcontroller sc1234 = new ApexPages.Standardcontroller(testDealProgram3);
        clsApproveEligiblePrograms aEPs = new clsApproveEligiblePrograms(sc1234);    
        Test.stoptest();
        Apexpages.Currentpage().getparameters().put('ProductId',listcp[0].id);
        

        
    }
    
        Static testmethod void testEvaluationMethod5(){
        TriggerExecutionController.setSkipAllTriggers(true);
        List<String> listObjAPINames = new List<String>{'Opportunity'};
            listAcc=[select id from account];
        for(account acc : listAcc){
            acc.Partner_Tier__c = 'Tier 2';
            acc.Partner_Relationship__c = 'Registered';
            acc.Account_Country_Code__c ='US';
            acc.Account_Country__c = 'UNITED STATES';
        }
         
        listAcc[0].Partner_Type__c = 'US Federal';
        listAcc[0].ispartner = true;
        listAcc[0].Account_Country_Code__c ='US';
        listAcc[0].Account_Country__c = 'UNITED STATES';

        //listAcc[1].Partner_Type__c = 'Federal Distributor';
        update listAcc;
        
        Sales_Channel_Group__c testSalesChannel = new Sales_Channel_Group__c(Name = 'MFG WEST',
                                                                             Sales_Method_Name__c = 'commercial');
        Insert testSalesChannel;     
        listAcc[2].RecordTypeId=getRecordTypeIdbyName('End-User Account','Account');
        listAcc[2].Partner_Type__c = 'COMMERCIAL';
        listAcc[2].Partner_Tier__c = 'Tier 1';
        listAcc[2].Sales_Channel__c = testSalesChannel.id;
        listAcc[2].GTM_Model__c = 'DELL CHANNEL';
        update listAcc;
        system.assertNotEquals(listAcc[2].id, null);
        Contact partnerContact = new Contact(FirstName = 'MyTestContact',
                                             LastName = 'MyTestContact',
                                             AccountId =listAcc[0].Id,
                                             Status__c  =  'Marketing Suspect',
                                             Email = 'dealregTestContact@dell.com',
                                             Fax = '1234567',
                                             MobilePhone = '0987654',
                                             Last_Operation_Performed__c = 'testing',
                                             Phone = '1234500');
        insert partnerContact;
        final List<Profile> partnerProfiles = [select Id, Name from Profile where profile.name='System Administrator' limit 1];
        system.debug('*****' +partnerProfiles);
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
                                    Badge_Number__c='DealReg123', 
                                    isActive = TRUE,
                                    DefaultCurrencyIsoCode = 'USD'
                                   );
        insert partnerUser;
        listOpp=[select id from Opportunity];
        listOpp[0].Deal_Registration_Status__c= 'New';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes';
        listOpp[0].Forecast_Category_Override__c = 'Omitted';
        system.runAs(partnerUser){
            update listOpp;
        } 
       // listOpp[0].AccountId = listAcc[0].id;
        listOpp[0].Distributor_Reseller_Name__c = listAcc[1].id;
        listOpp[0].Deal_Type__c = 'Fulfillment';
        update listOpp;
        Country__c country = new Country__c(Name='UNITED STATES',
                                            Code__c='US',
                                            Dell_Online_Country_Code__c ='US',
                                            Region__c ='NA');
       // insert country;   
        list<Country__c> listc=new list<Country__c>();
        listc.add(country);
        insert listc;
        List<Deal_Program__c> listdealProgram = new List<Deal_Program__c>();
        List<Custom_Partner_Accounts__c> listcustomPartnerAcc = new List<Custom_Partner_Accounts__c>();


            Deal_program__c testDealProgram1 = new Deal_program__c(Deal_Program_Name__c = 'testDealProgram'+System.currentTimeMillis(),
                                                               Benefit_Type__c = 'test',
                                                               Business_Unit__c = 'test',
                                                               Active__c = True,
                                                               Deal_Program_Description__c = 'test Program',
                                                               Start_Date__c = system.today(),
                                                               End_Date__c = system.today().adddays(10),                                                            
                                                               USD_Threshold__c = 900,
                                                               Fulfilment_Path__c = 'Distribution',
                                                               Program_Region__c='NA',
                                                               Partner_Type__c = 'Distributor (GCC)',
                                                               Partner_Relationships__c = 'Registered',
                                                               Partner_Tiers__c = 'Indirect Partner Purchase;Tier 1;Tier 2',
                                                               Partner_Account_Regions__c = 'APJ;LATAM;NA',
                                                               Distributor_Reseller_Account_Region_s__c='APJ;LATAM;NA',
                                                               Partner_Account_Countrys__c = 'INDIA',
                                                               Exclude_Sales_Channels__c = 'FED',
                                                               Include_Sales__c = 'WED',
                                                               End_User_Account_Regions__c = 'APJ;LATAM',
                                                               End_User_Account_Countrys__c = 'INDIA',
                                                               Coverage__c = 'CFL;DELL CHANNEL',
                                                               Stack_Ranking__c = 2000,
                                                               Deal_Type__c = 'Fulfillment',
                                                               Account_Classification__c = 'Commercial',
                                                               Exclude_Unassigned_End_User_Accounts__c = True);
        listdealProgram.add(testDealProgram1);
        Deal_program__c testDealProgram2 = new Deal_program__c(Deal_Program_Name__c = 'testDealProgram2'+System.currentTimeMillis(),
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
                                                               Program_Region__c='NA',
                                                               Partner_Tiers__c = 'Indirect Partner Purchase',
                                                               Partner_Account_Regions__c = 'APJ;LATAM',
                                                               Distributor_Reseller_Account_Region_s__c='APJ;LATAM;NA',
                                                               Partner_Account_Countrys__c = 'INDIA',
                                                               Exclude_Sales_Channels__c = 'FED',
                                                               Include_Sales__c = 'WEST',
                                                               End_User_Account_Regions__c = 'APJ;LATAM;NA',
                                                               End_User_Account_Countrys__c = 'UNITED STATES',
                                                               Coverage__c = 'CFL',
                                                               Stack_Ranking__c = 2000,
                                                               Deal_Type__c = 'Fulfillment',
                                                               Account_Classification__c = 'Commercial',
                                                               Exclude_Unassigned_End_User_Accounts__c = True);
        listdealProgram.add(testDealProgram2);
        Deal_program__c testDealProgram3 = new Deal_program__c(Deal_Program_Name__c = 'testDealProgram3'+System.currentTimeMillis(),
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
                                                               Program_Region__c='NA',
                                                               Partner_Relationships__c = 'Registered',
                                                               Partner_Tiers__c = 'Indirect Partner Purchase;Tier 1;Tier 2',
                                                               Partner_Account_Regions__c = 'APJ;LATAM;NA',
                                                               Distributor_Reseller_Account_Region_s__c='APJ;LATAM;NA',
                                                               Partner_Account_Countrys__c = 'UNITED STATES',
                                                               Exclude_Sales_Channels__c = 'FED;TEST',
                                                               Include_Sales__c = 'WEST;Test',
                                                               Stack_Ranking__c = 2000,
                                                               End_User_Account_Regions__c = 'APJ;LATAM;NA',
                                                               End_User_Account_Countrys__c = 'UNITED STATES',
                                                               Coverage__c =  'DELL CHANNEL',
                                                               Exclude_Unassigned_End_User_Accounts__c = True);
        listdealProgram.add(testDealProgram3);
        Database.insert(listdealProgram);
        system.debug('---------398---'+listdealProgram);
        Map<id,Deal_Program__c> mapDeal=new Map<id,Deal_Program__c>();
        for(Deal_Program__c del : listdealProgram){
            mapDeal.put(del.id,del);
        }
        Id pricebookId = Test.getStandardPricebookId();   
        List<String> listprodCode = new List<String> {'Workstations','Notebooks','Storage Systems','PowerEdge Servers','Networking Software'};      
            List<Product2> listprod = new List<Product2>();
        List<PricebookEntry> listpricBook = new List<PricebookEntry>();
        List<OpportunityLineItem> listoli = new List<OpportunityLineItem>();
        Product2 prod = new Product2(Name = 'Worksta',ProductCode = 'Workstations',
                                     Family = 'Hardware',
                                     Channel_Product_LOB__c = 'NETWORKING', isActive = true ,Product_ID__c = 'P1');
        listprod.add(prod);
         
        Product2 undefinedProd = new Product2(Name = 'Notebooks',Family = 'Hardware',Product_ID__c = 'P2');
        listprod.add(undefinedProd);
        insert listprod;
        listOppLineItem=[select id from OpportunityLineItem Limit 3];
        TriggerExecutionController.setSkipAllTriggers(true);
        Custom_Products__c cp1 = new Custom_Products__c(Include__c = true, Deal_Program__c = listdealProgram[0].id, Filter_type__c = 'Product Group', Criteria__c = 'Hardware', Product__c = null);
        Custom_Products__c cp2 = new Custom_Products__c(Exclude__c = true, Deal_Program__c = listdealProgram[1].id, Filter_type__c = 'Product Group', Criteria__c = 'Hardware',  Product__c = null);
        List<Custom_Products__c> listcp = new List<Custom_Products__c>();
        listcp.add(cp1);
        listcp.add(cp2);
        insert listcp;
        Qualified_Program__c qp = new Qualified_Program__c(Opportunity__c=listOpp[0].id,Deal_Program__c=listdealProgram[0].id,Product__c=listprod[0].id);
        insert qp;
        Custom_Partner_Accounts__c CPA = new Custom_Partner_Accounts__c(Account__c=listAcc[0].id,Include__c=true,Deal_Program__c=listdealProgram[1].id);
            insert CPA;
        Test.starttest();
        PageReference pageRef123 = Page.ApproveEligiblePrograms;
        Test.setCurrentPage(pageRef123);
        ApexPages.Standardcontroller sc123 = new ApexPages.Standardcontroller(listOpp[0]);
        ApexPages.currentPage().getParameters().put('cid',listOpp[0].id);
        clsApproveEligiblePrograms aEP = new clsApproveEligiblePrograms(sc123);    
        aEP.onPageLoad();    
       // aEP.saveApproved();  
        
        aEP.saveRejected();
        aEP.dealslist();
        aEP.UpdateOpportunity();
        Apexpages.Currentpage().getparameters().put('ProductId',listcp[0].id);
        aEP.showPopup();
        aEP.cancel();
        aEP.closepopup();
        Apexpages.Currentpage().getparameters().put('selected_ids1',listdealProgram[2].id);
        aEP.Savelist();
        PageReference pageRef1234 = Page.ApproveEligiblePrograms;
        Test.setCurrentPage(pageRef1234);
        ApexPages.Standardcontroller sc1234 = new ApexPages.Standardcontroller(testDealProgram3);
        clsApproveEligiblePrograms aEPs = new clsApproveEligiblePrograms(sc1234);    
        Test.stoptest();
        Apexpages.Currentpage().getparameters().put('ProductId',listcp[0].id);
        

        
    }
    
    public static Id getRecordTypeIdbyName(String strRecordTypeName,String strobjectName){
        return  Schema.getGlobalDescribe().get(strobjectName).getDescribe().getRecordTypeInfosByName().get(strRecordTypeName).getRecordTypeId();
    }
}