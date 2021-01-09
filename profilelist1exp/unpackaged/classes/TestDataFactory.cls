@isTest
public class TestDataFactory {
    /** 
* ******************************************************
* This method is test data for create Account
* ******************************************************
*/
    public static List<Account> createNAccount(Integer intnumRecords,String strAccountType){
        String strmasterAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Master_Account_Record_Type_Name).getRecordTypeId();
        String strpartnerAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();
        String strendUserAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End-User Account').getRecordTypeId();
        List<Account> listAcc = new List<Account>();
        for(Integer inti = 1; inti <= intnumRecords ; inti++){
            Account acc = new Account();
            acc.Name = 'Test Account Version'+inti+'_'+string.valueof(Math.abs(Crypto.getRandomInteger()));
            acc.NPS_Qualified_Contacts__c = 1;
            acc.Website = 'www.dell.com';
            if(strAccountType.equals('Master Account')){
                acc.Master_Group_Affinity_ID__c='MGAff1212'+string.valueof(Math.abs(Crypto.getRandomInteger())); 
                acc.RecordTypeId = strmasterAccountRecordTypeId;
            }
            else if(strAccountType.equals('Partner Account') ){
                acc.Account_ID__c='SMAff1211'+string.valueof(Math.abs(Crypto.getRandomInteger()));
                acc.RecordTypeId = strpartnerAccountRecordTypeId;
            }
            else{
                acc.Account_ID__c='EUAAff1211'+string.valueof(Math.abs(Crypto.getRandomInteger()));
                acc.RecordTypeId = strendUserAccountRecordTypeId;
                acc.Participating_in_LOB_Program__c=true;
            }
            listAcc.add(acc);
        }
        return listAcc;
    }
    /** 
* ******************************************************
* This method is test data for create Campaign of a specific record tyep
* ******************************************************
*/
    public static List<Campaign> createNCampaign(Integer intnumRecords,String strcampaignRecordTypeName){
        List<Campaign> listcampaign = new List<Campaign>();
        for(Integer inti = 1; inti <= intnumRecords ; inti++){
            Campaign campaignObject = new Campaign();
            campaignObject.Name = 'Test Campaign Version'+inti+'_'+string.valueof(Math.abs(Crypto.getRandomInteger()));
            campaignObject.StartDate = System.Today() - 10;
            campaignObject.EndDate = System.Today();
            campaignObject.IsActive = true;
            campaignObject.RecordTypeId = Schema.getGlobalDescribe().get('Campaign').getDescribe().getRecordTypeInfosByName().get(strcampaignRecordTypeName).getRecordTypeId();
            
            campaignObject.Campaign_Objective__c='Acquisition/Site Development';
            campaignObject.Vertical__c ='Consulting';
            campaignObject.Segment_Business_Unit__c='Channel';
            campaignObject.Business_Unit__c = 'LE - G500';
            campaignObject.Region__c='ABU';
            campaignObject.Follow_Up_Role__c='Account Executive';
            campaignObject.Solution__c = 'IS - Integrated Security';
            campaignObject.Account_Play__c = TRUE;
            campaignObject.Account_Play_Expiry_Date__c = System.Today()+360;
            campaignObject.Is_this_Account_Play_Campaign__c = TRUE;
            campaignObject.Type='Advisory Councils';
            campaignObject.Description='Test';
            campaignObject.status='In Progress';
            campaignObject.Country_Code__c = 'BR - Brazil';
            campaignObject.Partner_Event_or_Campaign__c = TRUE;
            campaignObject.Total_Campaign_Targets_Planned__c = 1;
            campaignObject.Total_Value_Won_Opportunities_Planned__c = 1;
            campaignObject.Total_Value_Opportunities_Planned__c = 1;
            campaignObject.Partner_Campaign_Contact_Email__c = 'test@test.com';
            campaignObject.Lead_Routing__c = 'Not Applicable';
            listcampaign.add(campaignObject);
        }
        return listcampaign;
    }
    /** 
* ******************************************************
* This method is test data for create Portal Active Contact
* ******************************************************
*/
    public static List<User> createNPortalUser(Integer intnumRecords){
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipContactTriggers(true);
        List<Account>listMA = TestDataFactory.createNAccount(1,'Master Account');
        if(listMA.size() > 0){
            insert listMA;
        }
        List<Contact> listActiveCon = new List<Contact>();
        for(Integer inti = 1; inti <= intnumRecords ; inti++){
            Contact con = new Contact(AccountId = listMA[0].Id,
                                      Email='testcontact_'+inti+'@DELLTEAM.com',
                                      FirstName = 'Test Contact', 
                                      LastName = 'Version'+inti+'_'+String.valueOf(Math.abs(Crypto.getRandomInteger())),
                                      Status__c = 'Customer',phone = '6739543210',
                                      //EligibleTracks__c = listPT[i-1].Id,
                                      Allow_Partner_Central_User__c=true, Premier_Partner__c = true
                                     );
            listActiveCon.add(con);
        }
        Integer intuserNumber = Math.abs(Crypto.getRandomInteger());
        String strnewusername = 'Test '+intuserNumber +'_data'+'@DELLTEAM.com'; 
        String strbadgeNumber = String.valueOf(intuserNumber )+string.valueof(Math.abs(Crypto.getRandomInteger()));
        insert listActiveCon;
        List<Profile> listp = new List<Profile>([select Id,name from Profile where UserType =:'PowerPartner' limit 2]);
        List<User> listActiveUsr = new List<User>();
        for(Integer inti = 1; inti <= intnumRecords ; inti++){
            User newUser = new User(profileId = listp [1].id,username =listActiveCon[inti-1].Email,
                                    email = listActiveCon[inti-1].Email,Badge_Number__c=null, 
                                    emailencodingkey = 'UTF-8',localesidkey = 'en_US',languagelocalekey = 'en_US',
                                    timezonesidkey = 'America/Los_Angeles',alias='nuser'+inti,
                                    lastname=listActiveCon[inti-1].LastName,
                                    contactId = listActiveCon[inti-1].id,
                                    Enable_Partner_Deal_Registration__c = true,
                                    Enable_Partner_Lead_Management__c = true, 
                                    Enable_As_Partner_Lead_Super_User__c = true,
                                    isActive = TRUE);
            listActiveUsr.add(newUser);
        }
        return listActiveUsr;
    }
    /** 
* *******************************************************************
* This method is test data for creating Opportunity with Record Type
* *******************************************************************
**/
    public static List<Opportunity> createNOpportunities(Integer intRecords,String strOpportunityRecordTypeName){
        List<Opportunity> listOpportunity = new List<Opportunity>();
        for(Integer inti = 1; inti <= intRecords ; inti++)
        {
            Opportunity opptyObject = new Opportunity();
            opptyObject.Name = 'Test Opportunity Version'+inti+'_'+string.valueof(Math.abs(Crypto.getRandomInteger()));
            opptyObject.CloseDate= System.Now().Date().addDays(180);
            opptyObject.StageName = 'Discover - 10%';
            //opptyObject.CurrencyIsoCode = 'USD- U.S.Dollar';
            opptyObject.ForecastCategoryName = 'Pipeline';
            opptyObject.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(strOpportunityRecordTypeName).getRecordTypeId();
            if(strOpportunityRecordTypeName.equals('APOS') || strOpportunityRecordTypeName.equals('Channel Opportunity') || strOpportunityRecordTypeName.equals('Create New Deal From LOB') || strOpportunityRecordTypeName.equals('Deal Registration') || strOpportunityRecordTypeName.equals('Deal Registration for Existing End Customer') || strOpportunityRecordTypeName.equals('Deal Registration-Rejected') || strOpportunityRecordTypeName.equals('Deal Registration-Submitted') || strOpportunityRecordTypeName.equals('ForScratchOrgSetup') || strOpportunityRecordTypeName.equals('Protected Deal') || strOpportunityRecordTypeName.equals('Small Deal Marketing')|| strOpportunityRecordTypeName.equals('Run Rate Marketing')|| strOpportunityRecordTypeName.equals('Run Rate Opportunity') || strOpportunityRecordTypeName.equals('SMB Opportunity')|| strOpportunityRecordTypeName.equals('Standard Opportunity') ){
                opptyObject.Solution_Name__c = 'Amacus';
                opptyObject.Solution_Type__c = 'Applications';
                opptyObject.Type = 'Design';
                opptyObject.Forecast_Category_Override__c = 'Omitted';
                opptyObject.Payment_Type__c = 'Credit Card';
                opptyObject.Deal_Expiration_Timeframe__c = '60';
                opptyObject.Solution_Scope__c = 'Hardware and Support Only';
                opptyObject.End_User_Account_Name__c = 'Opportunity End user Account Name'+inti;
                opptyObject.End_User_Email__c = 'user@dell.coin';
                opptyObject.Is_the_Customer_Part_of_a_Larger_Group__c = 'No';
                opptyObject.Customer_Willing_To__c = 'Not Interested';
                opptyObject.Distributor_Name__c = 'Distribution';
                opptyObject.Justification_Statement__c = 'Opportunity Justification Statement'+inti;
                opptyObject.Service_Solution_Reason__c = 'Pricing';
                opptyObject.End_User_First_Name__c = 'Test Opportunity'+inti;
                opptyObject.End_User_Last_Name__c = 'Opp LastName';
                opptyObject.End_User_Mailing_City__c = 'Opp CityName';
                opptyObject.End_User_Mailing_Country__c = 'INDIA';
                opptyObject.End_User_Mailing_State_Province_Region__c = 'Opp Region';
                opptyObject.End_User_Mailing_Street__c = 'Opp MailingStreet';
                opptyObject.Engagement_Type__c = 'Collaboration';
                opptyObject.Total_Expected_Dell_Revenue__c = (Math.abs(Crypto.getRandomInteger()));
                opptyObject.Materials_Used_to_Help_Close_Deal__c = 'Seed Units';
                opptyObject.Domain__c = 'Deal Reg';
                opptyObject.Reason_Won_Lost__c = 'Incumbent';
                opptyObject.Primary_Product_Delivery_Address_Region__c='APJ';
                opptyObject.Primary_Product_Delivery_Address_Country__c='SINGAPORE';
                opptyObject.End_User_Phone__c='96763439';
                opptyObject.Forecast_Category_Override__c = 'Omitted';
            }
            
            listOpportunity.add(opptyObject);
        }  
        system.debug('lsitopp'+listOpportunity);
        return listOpportunity;
    }    
    /** 
* *********************************
* This method to get RecordType Id
* *********************************
**/
    public static Id getRecordTypeIdbyName(String strRecordTypeName,String strobjectName){
        return  Schema.getGlobalDescribe().get(strobjectName).getDescribe().getRecordTypeInfosByName().get(strRecordTypeName).getRecordTypeId();
    }
    /** 
* *******************************************************************
* This method is test data for creating case with Record Type
* *******************************************************************
**/
    public static List<case> createNCases(Integer intRecords){
        List<Account> listMA = TestDataFactory.createNAccount(1,'Partner Account');
        listMA[0].Partner_Type__c = 'COMMERCIAL';
        listMA[0].Partner_Tier__c = 'Direct Partner Purchase';
        listMA[0].Partner_Relationship__c = 'Registered';
        listMA[0].NPS_Account_Tier__c = 'Priority 1';
        listMA[0].Account_Country__c = 'United States';
        if(listMA.size() > 0){
            insert listMA;
        }
        List<Contact> listActiveCon = new List<Contact>();
        for(Integer inti = 1; inti <= intRecords ; inti++){
            Contact con = new Contact(AccountId = listMA[0].Id,
                                      Email='testcontact_'+inti+'@DELLTEAM.com',
                                      FirstName = 'Test Contact', 
                                      LastName = 'Version'+inti+'_'+String.valueOf(Math.abs(Crypto.getRandomInteger())),
                                      Status__c = 'Customer',phone = '6739543210',
                                      //EligibleTracks__c = listPT[i-1].Id,
                                      Allow_Partner_Central_User__c=true, Premier_Partner__c = true
                                     );
            listActiveCon.add(con);
        }
        Integer intuserNumber = Math.abs(Crypto.getRandomInteger());
        String strnewusername = 'Test '+intuserNumber +'_data'+'@DELLTEAM.com'; 
        String strbadgeNumber = String.valueOf(intuserNumber )+string.valueof(Math.abs(Crypto.getRandomInteger()));
        TriggerExecutionController.setSkipAllTriggers(true);
        insert listActiveCon;
        List<case> listCase = new List<case>();
        for(Integer inti = 1; inti <= intRecords ; inti++){
            Case cs=new case();
            cs.Country__c = 'United States';
            cs.AccountId = listMA[0].Id;
            cs.ContactId = listActiveCon[inti-1].id;
            cs.Status = 'Open';
            cs.Priority = 'High';
            cs.Sub_Type_Order_Support__c = 'Box Recycling';
            cs.Order_Number1__c = '123432';
            cs.Alternate_Phone__c = '745476';
            cs.Description = 'Test Case Subject'+inti;
            cs.Subject = 'Test Case Subject';
            cs.Origin = 'Partner Portal';
            //  cs.Order_Reference_Number_Type__c = 'Order Number';   
            cs.Case_Category__c = 'Partner';
            cs.Recipient__c = 'test@test.com';
            cs.Sub_Segment__c = null;
            cs.Segment__c = 'test';
            cs.Account_Affinity_ID__c = '14232423432';
            cs.NPS_Category__c = 'Detractor';
            cs.Inbound_Email_Message__c = true;
            cs.Recipient__c = 'no_reply@dell.com';
            cs.Sub_Segment__c = '';
            cs.Sub_Type_Internal_User__c='Test';
            cs.RecordTypeId=getRecordTypeIdbyName('Deal Registration', 'Case');
            cs.Unauthenticated_Case__c=false;
            cs.Sub_Type_Partner_User__c= 'Login Issues';
            listCase.add(cs);
        }
        return listCase;
    }
    /** 
* *******************************************************************
* This method is test data for creating Opportunity Product
* *******************************************************************
**/
    public static List<OpportunityLineItem> createNOpportunityLineItem(Integer intRecords){
        List<Product2> listProduct=new List<Product2>();
        List<PricebookEntry> listPricebookEntry=new List<PricebookEntry>();
        for(Integer inti = 0; inti <= intRecords-1 ; inti++){
            Product2 newProd = new Product2(Name = 'Test Product1'+inti,
                                            ProductCode = 'TP1'+inti,
                                            Product_Line_Desc__c = 'Test Product1'+inti,
                                            IsActive = TRUE, 
                                            Product_ID__c= '12345'+inti,
                                            CanUseRevenueSchedule=TRUE); 
            listProduct.add(newProd);  
        }
        Upsert listProduct;
        system.debug('Product>>> '+listProduct);
        system.debug('Productsize>>> '+listProduct.size());
        Id stdPriceBook = Test.getStandardPricebookId();
        for(Integer inti = 0; inti <= intRecords-1 ; inti++){
            PricebookEntry pBE1= new PricebookEntry (Product2ID=listProduct[inti].id,
                                                     Pricebook2ID=stdPriceBook,
                                                     isActive=true,
                                                     useStandardPrice=false,
                                                     UnitPrice = 50); 
            listPricebookEntry.add(pBE1);
        }
        Upsert listPricebookEntry;
        system.debug('listPricebookEntry>>> '+listPricebookEntry);
        system.debug('listPricebookEntry>>> '+listPricebookEntry.size());
        list<OpportunityLineItem> listOppLItems=new list<OpportunityLineItem>();
        for(Integer inti = 0; inti <= intRecords-1 ; inti++){
            OpportunityLineItem opptyLitem=new OpportunityLineItem();
            opptyLitem.pricebookEntryId=listPricebookEntry[inti].id;
            opptyLitem.Mrgn__c =6;
            opptyLitem.Discount_off__c = 7;
            opptyLitem.UnitPrice = 100;
            opptyLitem.Quantity =2;
            opptyLitem.Description = 'Line Description'+inti;
            opptyLitem.Service_Support_US__c = 'ProSupport IT - Mission Critical';
            listOppLItems.add(opptyLitem);
        }
        system.debug('listOppLItems>>> '+listOppLItems);
        system.debug('listOppLItems>>> '+listOppLItems.size());
        return listOppLItems;
    }
    /** 
* **********************************************
* This method is to Return List of Genral Users 
* **********************************************
**/
    public static list<User> createNGenralUsers(integer intNoRec){
        Profile profile = [select Id from profile where Name = 'System Administrator' limit 1];
        list<User> listUsr=new list<User>(); 
        for(Integer inti = 0; inti < intNoRec ; inti++){
            //Create a user with Standard User profile
            User usr = new User(Username = 'TestValidUser1'+inti+ '@dell.com',
                                Alias = 'Test'+inti, 
                                Email = 'Test212'+inti+'@dell.com', 
                                LastName = 'Test22'+inti,
                                Title = 'GCC Program Manager', 
                                ProfileId = profile.Id, 
                                LanguageLocaleKey = 'en_US', 
                                LocaleSidKey = 'en_US', 
                                EmailEncodingKey = 'UTF-8', 
                                TimeZoneSidKey = 'America/Los_Angeles',
                                Country = 'US',
                                Badge_Number__c = inti+'Test'+inti,
                                isActive=true);
            listUsr.add(usr);
        }
        system.debug('listUsr>>>'+listUsr);
        system.debug('listUsrsize>>>'+listUsr.size());
        return listUsr;
    }
    /** 
* **********************************************
* This method is to Return List of Contacts 
* **********************************************
**/
    public static list<Contact> createNContacts(integer intNoRec){
        System_Behavior_Bypasser__c vr = new System_Behavior_Bypasser__c();
        vr.Bypass_Contact_VRs__c = true;
        insert vr;
        list<Contact> listCon=new list<Contact>();
        for(Integer inti = 0; inti < intNoRec ; inti++){
            Contact testContact = new Contact(FirstName='first'+inti, 
                                              LastName='last'+inti, 
                                              Phone='044223667788'+inti,
                                              Email='dellmail'+inti+'@dell.com',
                                              Decision_Making_Role__c='Influencer',
                                              Job_Function__c='Finance',
                                              Job_Function_Role__c='Finance Manager'+inti,
                                              Primary_Contact__c=false,
                                              Status__c = 'Customer',
                                              Email_Opt_In__c = 'yes',
                                              Survey__c = 'yes',
                                              Title='CEO'+inti,
                                              Department='Marketing',
                                              MailingStreet = '123 Main'+inti,
                                              MailingCity = 'Peoria'+inti,
                                              MailingState = 'IL'+inti,
                                              MailingCountry = 'US'+inti, 
                                              MailingPostalCode = '33333'+inti,
                                              MobilePhone = '3213213211'+inti,
                                              Fax = '3213123211'+inti,
                                              Account_Changed__c=true
                                             );
            listCon.add(testContact);
        }
        system.debug('con>>>'+listCon);
        system.debug('conSize>>>'+listCon.size());
        Return listCon;
    }
    
    /** 
* **********************************************
* This method is to Return List of Leads 
* **********************************************
**/
    public static List<Lead> createNLeads(Integer intNoRec,String strleadRecordType){
        Country__c testCountry = new Country__c(
            Name = 'TestCountry',
            Code__c = 'TY',
            User_Currency_Iso_Code__c = 'INR',
            Region__c = 'APJ');
        insert testCountry;
        List<Lead> listLead = new List<Lead>();
        
        for(Integer inti = 0; inti < intNoRec ; inti++){
            Lead leadObject = new Lead();
            leadObject.FirstName = 'Direct'+inti;
            leadObject.LastName = 'Test Lead Version'+inti;
            leadObject.Lead_Type__c = 'Inbound';
            leadObject.Company = 'Test Company Version'+inti;
            leadObject.Email = 'testLead_'+inti+'@test.com';
            leadObject.RecordTypeId = schema.SObjectType.Lead.getRecordTypeInfosByName().get(strleadRecordType).getRecordTypeId();
            leadObject.Status = 'New'; 
            leadObject.Dell_Partner_can_contact_me__c = true;
            leadObject.Country_Code__c = 'AE';
            leadObject.Phone = '123456789'+inti;
            leadObject.LeadSource = 'Web';
            leadObject.Department__c = 'DepartmentYes';
            leadObject.Country = 'india';
            if(strleadRecordType=='Account Suggestion'){
                leadObject.Status = 'Open';
                leadObject.CFI_Project_Numbers__c = 'testPN';
                leadObject.Questions_Comments__c = 'Sample Questions And Comments';
                leadObject.Date_Founded__c = DateTime.now();
                leadObject.DMU_Flag__c = true;
                leadObject.FIN_GEO__c = 'Test';
                leadObject.Fiscal_Year_End__c = DateTime.now();
                leadObject.Company = 'Test Company';
                leadObject.Function_Category_Code__c = 'Air Force Air Station';
                leadObject.Program_Type__c = 'Test';
                leadObject.Location_Number__c = 4;
                leadObject.Marketing_Class_Code__c = 'Defense Army';
                leadObject.National_ID__c = '344';
                leadObject.NDA_Expiry_Date__c = DateTime.now();
                leadObject.NDA_Flag__c = false;
                leadObject.Other_Company_Name__c = 'Other Company';
                leadObject.Website = 'Mywebsite';
                leadObject.Physical_City__c = 'City';
                leadObject.Physical_Company_Name__c = 'Name';
                leadObject.Physical_County__c = 'Test';
                leadObject.Physical_PostalCode__c = '3455';
                leadObject.Physical_State__c = 'City';
                leadObject.Physical_Address_1__c = 'Add';
                leadObject.Physical_Address_2__c = 'Add2';
                leadObject.Physical_suburb__c = 'Suburb';
                leadObject.Postal_City__c = 'city';
                leadObject.Postal_Company_Name__c = 'Company';
                leadObject.Postal_County__c = 'County';
                leadObject.Postal_PostalCode__c = '45554';
                leadObject.Postal_State__c = 'State';
                leadObject.Postal_Address_1__c = 'Add1';
                leadObject.Postal_Address_2__c = 'Add2';
                leadObject.Postal_suburb__c = 'Suburb';
                leadObject.Premier_Page_URL__c = 'URL';
                leadObject.Suggestion_Reason__c = 'Reseller';
                leadObject.Retail_Flag__c = true;
                leadObject.Sales_Model_Code__c = 'Relationship';
                leadObject.Std_Quote_Numbers__c = 'Test';
                leadObject.Sub_Market_Code__c = 'Army';
                leadObject.Account_Category__c = 'Partner';
                leadObject.Partner_Type__c = 'ISG';
                leadObject.Partner_Class__c = 'Tier 1';        
                leadObject.Partner_Status__c = 'Registered';
                leadObject.Secondary_Partner_Type_Optional__c = 'Global Alliance';
                leadObject.Organization_Country__c = testCountry.id;     
                leadObject.Physical_Country__c = testCountry.id;
                leadObject.Postal_Country__c = testCountry.id; 
                leadObject.Country_Code__c='AE';
                
            }
            
            listLead.add(leadObject);
        }
        return listLead;
    }
    
    /** 
* ****************************************************
* This method is to Return List of Account_Branch__c 
* ****************************************************
**/
    
    public static List<Account_Branch__c> createNAccountBranch(Integer intNoRec){
        list<Account_Branch__c> listAccountBranch = new list<Account_Branch__c>();
        for(Integer inti = 0; inti < intNoRec ; inti++){
            //Create a Opportunity_Workload__c 
            Account_Branch__c acb = new Account_Branch__c();
            acb.Name = 'Test'+inti;
            listAccountBranch.add(acb);
        }
        system.debug('listAccountBranch>>>'+listAccountBranch);
        system.debug('listAccountBranch>>>'+listAccountBranch.size());
        return listAccountBranch;
    }
    
    /** 
* ********************************************************
* This method is to Return List of Workload_Definition__c 
* ********************************************************
**/
    public static list<Workload_Definition__c> createNWorkloadDef(Integer intNoRec){
        list<Workload_Definition__c> listworkloaddef = new list<Workload_Definition__c>();
        for(Integer inti = 0; inti < intNoRec ; inti++){
            //Create a Workload_Definition__c
            Workload_Definition__c wdc = new Workload_Definition__c();
            wdc.Name = 'Test WorkLoad'+inti;
            listworkloaddef.add(wdc);
        }
        system.debug('listworkloaddef>>>'+listworkloaddef);
        system.debug('listworkloaddef>>>'+listworkloaddef.size());
        
        return listworkloaddef;
    }
    
    /** 
* ****************************************************
* This method is to Return List of Workloads__c 
* ****************************************************
**/
    
    public static list<Workloads__c> createNworkloads (Integer intNoRec){
        list<Workload_Definition__c> listworkloaddefin = TestDataFactory.createNWorkloadDef(1);
        if(listworkloaddefin.size()>0){
            insert listworkloaddefin;
        }
        list<Workloads__c> listworkload = new list<Workloads__c>();
        for(Integer inti = 0; inti < intNoRec ; inti++){
            //Create a Workloads__c
            Workloads__c wkldc = new Workloads__c();
            wkldc.Workload_Definition__c = listworkloaddefin[0].id;
            listworkload.add(wkldc);
        }
        system.debug('listworkload>>>'+listworkload);
        system.debug('listworkload>>>'+listworkload.size());
        return listworkload;
        
    } 
    
    /** 
* *************************************************************
* This method is to Return List of Opportunity_Workload__c 
* *************************************************************
**/
    
    
    public static List<Opportunity_Workload__c> createNOpportunityWorkload(Integer intNoRec){
        list<Workloads__c> listWorkLoadss = TestDataFactory.createNworkloads(1);
        insert listWorkLoadss;
        list<Opportunity_Workload__c> listOpportunityWorkload = new list<Opportunity_Workload__c>();
        for(Integer inti = 0; inti < intNoRec ; inti++){
            //Create a Opportunity_Workload__c 
            Opportunity_Workload__c ow = new Opportunity_Workload__c();
            ow.Workload__c = listWorkLoadss[0].id;
            listOpportunityWorkload.add(ow);
        }
        system.debug('listOpportunityWorkload>>>'+listOpportunityWorkload);
        system.debug('listOpportunityWorkload>>>'+listOpportunityWorkload.size());
        return listOpportunityWorkload;
    }
    
    /** 
* **********************************************
* This method is to Return List of Support Requests 
* **********************************************
**/
    public static List<Support_Request__c> createNSupportRequests(Integer intNoRec,String strRecordTypeName){
        id rtid1=[select Id,Name from RecordType where sObjectType='Support_Request__c' and name='Request PG Custom Solutions Engineering Support' Limit 1].id;
        id rtid2=[select Id,Name from RecordType where sObjectType='Support_Request__c' and name='Request Solution Operation Center Support' Limit 1].id;
        list<Support_Request__c> listSuppReq=new list<Support_Request__c>();
        for(Integer inti = 0; inti < intNoRec ; inti++){
            Support_Request__c supReq = new Support_Request__c();
            if(strRecordTypeName=='Request PG Custom Solutions Engineering Support'){
                supReq.RecordTypeId=rtid1;
            }else if(strRecordTypeName=='Request Solution Operation Center Support'){
                supReq.RecordTypeId=rtid2;
            }
            else{
                supReq.RecordTypeId = schema.SObjectType.Support_Request__c.getRecordTypeInfosByName().get(strRecordTypeName).getRecordTypeId();
            }
            supReq.Receive_Notification__c = 'Yes';
            supReq.Requestor_Comments__c = 'testComment'+intNoRec;
            supReq.Specialist_Role__c = 'testRole';
            supReq.Engagement_Time_Frame__c=Date.today();
            supReq.Support_Owner__c = UserInfo.getUserId();
            //supReq.Specialist_Name__c=UserInfo.getUserId();
            supReq.Solution_Architect__c = 'Yes';
            supReq.Support_Owner_Team_Role__c = 'Services Intake Manager';
            //supReq.Status__c='New';
            supReq.Project_Type__c='CWS';
            supReq.Project_Duration_months__c =1;
            supReq.Suggested_Delivery_Method__c='Custom';
            supReq.Decision_Date__c=Date.today();
            supReq.Primary_Work_Delivery_Language__c='Spanish';
            supReq.CSMB_Contract_Request_Type__c = 'New Contract';
            supReq.Region__c = 'EMEA';
            supReq.Sub_Region__c = 'Western Europe';
            supReq.Business_unit1__c = 'Consumer Retail';
            supReq.Support_Status__c = 'Pending';
            supReq.Segment_Business_Unit__c = 'PLE';
            supReq.Request_Status__c='Scoping';
            supReq.Services_Proposal_Support__c = 'Yes';
            supReq.Custom_Service_Support__c = 'Custom Service Solution';
            supReq.Comments__c = 'Test Comments';
            supReq.Deliverable_Due_Date__c = System.Today() + 15;
            supReq.Services_Finance_Support__c = 'Yes';  
            supReq.Customer_Pricing_Due_Date__c = system.Date.today()+1;
            supReq.HW_SW_or_other_Financing_Dell_owned__c = 'Yes';
            supReq.Services_Finance_Support_Status__c = null;
            supReq.Pricing_Cycle_Status__c = 'Preliminary/indicative pricing';
            supReq.Services_Proposal_Support_Status__c = null;
            supReq.Engagement_Time_Frame__c=system.Date.today()+1;
            supReq.Deal_Governance_Review_Support__c = 'Yes';
            supReq.Deal_Governance_Review_Support_Status__c = null;
            supReq.Services_Legal_Support__c = 'Yes';
            supReq.Services_Legal_Support_Status__c = null;
            supReq.Solution_Architect__c = 'Yes';
            supReq.Solution_Architect_Status__c = null;
            
            
            if(strRecordTypeName=='Request PG Custom Solutions Engineering Support'||strRecordTypeName=='Request Pre-Sales Product Technologist Support'||strRecordTypeName=='Request Solution Operation Center Support'){
                supReq.Request_Type__c='CSE';
                supReq.NDA__c='no';
                supReq.Pre_Post_Sales__c='pre-sales';
                supReq.Sales_Type__c='retention';
                supReq.Request_Description__c='jhgdfgh';
                supReq.Target_Due_Date__c=System.today();
                supReq.Level_of_Support__c='other';
                supReq.CFI__c='yes';
                supReq.Customer_Facing_SOW_needed__c='yes'; 
                supReq.Export_Compliant__c='yes';
                supReq.Standardized_Benchmark__c='yes';
                supReq.OEM_Request__c='yes';
                supReq.Receive_Notification__c='yes';
                supReq.Overall_Situation__c='lkjhggf';
                supReq.Scope__c='kjhhgfhjh';
                supReq.Account_Executive__c=UserInfo.getUserId();
                supReq.System_Consultant__c=UserInfo.getUserId();
                supReq.Buying_Power__c=1000;
                supReq.Customer_Address__c ='test add';
                supReq.Customer_Email__c ='test@test.com';
                supReq.Security_Clearance__c ='Yes';                 
                supReq.Customer_Phone_Number__c = '0123333445'; 
                supReq.Engagement_Type__c ='AIM POD Demo';
                supReq.Cost_Center_Number__c='0123344556';                                 
                supReq.Primary_Competitor__c='test competitor'; 
                supReq.Requested_By_Phone__c ='0128899887';
                supReq.Operating_Systems_List__c = 'TestOp1'; 
                supReq.Platform_List__c = 'TestPlatform';
                supReq.Network_Switches_List__c = 'TestNetwork';
                supReq.Peripherals_List__c = 'TestPeripherals';
                supReq.Storage_List__c = 'TestStorage';
                supReq.HBA_List__c = 'TestHba';
                
            }
            listSuppReq.add(supReq);
        }
        system.debug('listSuppReq'+listSuppReq);
        Return listSuppReq;
    }
    
    /** 
* ****************************************************
* This method is to Return List of Account_Branch__c 
* ****************************************************
**/
    
    public static List<Account_Handover__c> createNAccountHandover(Integer intNoRec){
        list<Account_Handover__c> listAccountHandover = new list<Account_Handover__c>();
        for(Integer inti = 0; inti < intNoRec ; inti++){
            //Create a Account_Handover__c 
            Account_Handover__c ahvr = new Account_Handover__c();
            ahvr.Account_Access_Share__c = True;
            ahvr.Contracts_and_Pricing__c = '1234'+inti;
            listAccountHandover.add(ahvr);
        }
        system.debug('listAccountHandover>>>'+listAccountHandover);
        system.debug('listAccountHandover>>>'+listAccountHandover.size());
        return listAccountHandover;
    }
    /** 
* ********************************************************
* This method is to Return List of Account_Plan_Fields__c 
* ********************************************************
**/
    
    public static List<Account_Plan_Fields__c> createNAccountPlanFields(Integer intNoRec){
        list<Account_Plan_Fields__c> listAccountplanfields = new list<Account_Plan_Fields__c>();
        for(Integer inti = 0; inti < intNoRec ; inti++){
            //Create a Account_Plan_Fields__c 
            Account_Plan_Fields__c accplan = new Account_Plan_Fields__c();
            accplan.Name = 'Test Account'+inti;
            listAccountplanfields.add(accplan);
        }
        system.debug('listAccountplanfields>>>'+listAccountplanfields);
        system.debug('listAccountplanfields>>>'+listAccountplanfields.size());
        return listAccountplanfields;
    }
    
    /** 
* **********************************************
* This method is to Return List of SFDC_Acct_Plan__c 
* **********************************************
**/
    public static List<SFDC_Acct_Plan__c> createNSFDCAccPlan(Integer intNoRec,String strRecordTypeName){
        list<SFDC_Acct_Plan__c> listSFDCAccPlan=new list<SFDC_Acct_Plan__c>();
        for(Integer inti = 0; inti < intNoRec ; inti++){
            SFDC_Acct_Plan__c sfdAccPl = new SFDC_Acct_Plan__c();
            sfdAccPl.RecordTypeId = schema.SObjectType.SFDC_Acct_Plan__c.getRecordTypeInfosByName().get(strRecordTypeName).getRecordTypeId();
            sfdAccPl.Name = 'Test'+inti;
            sfdAccPl.Plan_Starting_Fiscal_Year__c = '--None--';
            sfdAccPl.Joint_Business_Goals_Long_Terms__c = '20 Months';
            sfdAccPl.Joint_Business_Goals_Short_Terms__c = '15 Months';
            sfdAccPl.Partnership_Executive_Summary__c = 'Text Description '+ inti;
            sfdAccPl.Partner_Certification__c = 'Partner Certfication' +inti;
            sfdAccPl.Risks_Mitigation_Incl_NPS__c = 'Risk Mitigation' + inti;
            sfdAccPl.Partner_Industry_Challenges__c = 'Test challenges'+inti;
            sfdAccPl.Partner_Inhouse_Financial_Services__c = 'Yes';
            sfdAccPl.Account_Plan_Type__c = 'Core';
            sfdAccPl.Account_Plan_Owner__c = userinfo.getUserId();
            sfdAccPl.Business_Description__c = 'Auto populated from Account'+inti;
            sfdAccPl.Customer_Technology_Initiatives__c = 'Intiative Description'+inti;
            sfdAccPl.Customer_Industry_Challenges__c = 'Customer Challenges'+inti;
            listSFDCAccPlan.add(sfdAccPl);
            
        }
        return listSFDCAccPlan;
    }
    /** 
* ********************************************************
* This method is to Return List of EMC_General_Settings__c 
* ********************************************************
**/
    
    public static List<EMC_General_Settings__c> createNEMCGeneralSetting(Integer intNoRec){
        list<EMC_General_Settings__c> listEMCGeneralSetting = new list<EMC_General_Settings__c>();
        for(Integer inti = 0; inti < intNoRec ; inti++){
            //Create a EMC_General_Settings__c 
            EMC_General_Settings__c eMCgs = new EMC_General_Settings__c();
            eMCgs.Name = 'Test Account'+inti;
            listEMCGeneralSetting.add(eMCgs);
        }
        system.debug('listEMCGeneralSetting>>>'+listEMCGeneralSetting);
        system.debug('listEMCGeneralSetting>>>'+listEMCGeneralSetting.size());
        return listEMCGeneralSetting;
    }
    /** 
* ********************************************************
* This method is to Return List of Alliance_Rebate_Request__c
* ********************************************************
**/
    
    public static List<Alliance_Rebate_Request__c> createNAllianceRebateRequests(Integer intNoRec){
        Alliance_STF_Price__c stfPrice = new Alliance_STF_Price__c(Net_Price__c = 10,Name= '123456');
        insert stfPrice;
        list<Opportunity> listOpp=TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        insert listOpp;
        List<Alliance_Rebate_Request__c> listAllianceRebateReq=new List<Alliance_Rebate_Request__c>();
        for(Integer inti = 0; inti < intNoRec ; inti++){
            Alliance_Rebate_Request__c allianceReq=new Alliance_Rebate_Request__c();
            allianceReq.System_Partner_Name__c ='Intel';
            allianceReq.Part_Requested__c ='CPU';
            allianceReq.Client_Enterprise__c ='Enterprise';
            allianceReq.Dell_Standard_CPU_Currency__c = 123.45;
            allianceReq.Finance_Contact__c = 'xxx'+inti+'@dell.com';
            allianceReq.Business_Case_Information__c = 'test'+inti;
            allianceReq.Dell_Standard_CPU__c  =stfPrice.id;
            allianceReq.Partner_BDM_Name__c='test'+intNoRec;
            allianceReq.Additional_Sales_Person_Email__c = '';
            allianceReq.Status__c = 'Draft';
            allianceReq.Region__c = 'APJ';
            allianceReq.Sales_Force_Deal_ID__c = listOpp[0].id;
            listAllianceRebateReq.add(allianceReq);
        }
        return listAllianceRebateReq;
    }
    /** 
* ********************************************************
* This method is to Return List of Rebate_Request_Product__c
* ********************************************************
**/
    public static List<Rebate_Request_Product__c> createNRebateRequestProducts(Integer intNoRec){
        list<Rebate_Request_Product__c> listRebReqProd=new list<Rebate_Request_Product__c>();
        for(Integer inti = 0; inti < intNoRec ; inti++){
            Rebate_Request_Product__c rebReqProd=new Rebate_Request_Product__c();
            rebReqProd.Quantity__c=2;
            rebReqProd.Part_Name_Part_Number__c='test'+inti;
            rebReqProd.Dell_System_Model_type__c='testing'+inti;
            rebReqProd.Sl_No__c= 4;
            rebReqProd.Status__c='Active';
            rebReqProd.Competitor_Name_Competitor_Part__c= 'part';
            rebReqProd.Rebate_per_unit__c= '';
            rebReqProd.Start_Date__c= System.today();
            rebReqProd.End_Date__c= System.today() + 10;
            rebReqProd.Price_Requested__c = 25.00;
            listRebReqProd.add(rebReqProd);
            
        }
        Return listRebReqProd;
    }
    
    /** 
* ********************************************************
* This method is to Return List of Sales_Channel_Group__c
* ********************************************************
**/
    public static List<Sales_Channel_Group__c> createNSalesChannelGroups(Integer intNoRec){
        List<Sales_Channel_Group__c> listSalChaGrp=new List<Sales_Channel_Group__c>();
        for(Integer inti = 0; inti < intNoRec ; inti++){
            Sales_Channel_Group__c salchagrp=new Sales_Channel_Group__c();
            salchagrp.Name = 'Test Sales channel';
            salchagrp.Regional_Parent_Name__c = 'APJ';
            salchagrp.Group_id__c='100053708';
            salchagrp.Sales_Method_Name__c = 'commercial';
            salchagrp.Segment_Desc__c = 'US1';
            salchagrp.Segment_Business_Unit_Name__c='SCG';
            salchagrp.Region_Name__c = 'REGION1'+inti;
            salchagrp.Segment_Name__c='CHANNEL';
            listSalChaGrp.add(salchagrp);
        }
        return listSalChaGrp;
    }
    
    /** 
* **********************************************
* This method is to Return List of Ocean_Data__c 
* **********************************************
**/
    
    public static List<Ocean_Data__c> createNOceanData(Integer intNoRec){
        List<Ocean_Data__c> listOceanData=new List<Ocean_Data__c>();
        for(Integer inti = 0; inti < intNoRec ; inti++){
            Ocean_Data__c oceanData=new Ocean_Data__c();
            oceanData.CFI_Delivery_Time_in_Weeks__c = 70+inti;
            oceanData.Days_in_country_Delivery__c = 70+inti;
            oceanData.On_the_sea_by_ODM__c = 70+inti;
            oceanData.CFI_Delivery_Time_in_Weeks__c = 70+inti;
            oceanData.Exception_Country__c = 'COUNTRY1'+inti;
            oceanData.MSP_Incremental_in_Weeks__c = 10+inti;
            oceanData.Region__c = 'REGION1'+inti;
            oceanData.Ship_Rate__c = 4+inti;
            oceanData.Source__c = 'Compal'+inti;
            oceanData.Pallet_Rate__c = 2+inti;        
            listOceanData.add(oceanData);
        }
        return listOceanData;
    }
    
    /** 
* **********************************************
* This method is to Return List of LOT_Region__c 
* **********************************************
**/
    
    public static List<LOT_Region__c> createNLoTRegion(Integer intNoRec){
        List<LOT_Region__c> listlotRegion=new List<LOT_Region__c>();
        for(Integer inti = 0; inti < intNoRec ; inti++){
            LOT_Region__c lotRegion=new LOT_Region__c();
            lotRegion.Name = 'COUNTRY1'+inti;
            lotRegion.Region__c = 'REGION1'+inti;
            lotRegion.Threshold_Region__c = 'EMEA';
            lotRegion.RM_Country__c = 'Text Country'+inti;
            listlotRegion.add(lotRegion);
        }
        return listlotRegion;
    }
    
    
    /** 
* **********************************************
* This method is to Return List of LOT_OCEAN_EMAIL__c 
* **********************************************
**/
    
    public static List<LOT_OCEAN_EMAIL__c> createNLoTOceanEmail(Integer intNoRec){
        List<LOT_Region__c> listlotRegion = TestDataFactory.createNLoTRegion(1);
        if(listlotRegion.size() > 0){
            insert listlotRegion;
        }
        List<LOT_OCEAN_EMAIL__c> listlotOceanEmail=new List<LOT_OCEAN_EMAIL__c>();
        for(Integer inti = 0; inti < intNoRec ; inti++){
            LOT_OCEAN_EMAIL__c lotOcean=new LOT_OCEAN_EMAIL__c();
            lotOcean.Country__c = listlotRegion[0].Id;
            lotOcean.Country_LE__c = 'test@testmail.com'+inti;
            lotOcean.region__c = 'APJ';
            lotOcean.Country_APJ_Commercial__c = 'test@testmail.com'+inti;            
            listlotOceanEmail.add(lotOcean);
        }
        return listlotOceanEmail;
    }
    
    /** 
* **********************************************
* This method is to Return List of Case_Management_Queue__c 
* **********************************************
**/
    public static List<Case_Management_Queue__c> createNCaseManagementQueues(Integer intNoRec){
        List<Case_Management_Queue__c> listCaseManQue = new list<Case_Management_Queue__c>();
        
        for(Integer inti = 0; inti < intNoRec ; inti++){
            Case_Management_Queue__c caseManQue=new Case_Management_Queue__c();
            caseManQue.Name= 'EMEA';
            caseManQue.Country__c ='INDIA';
            caseManQue.Segment__c ='ES';
            listCaseManQue.add(caseManQue);
        }
        return listCaseManQue;
    }
    /** 
* **********************************************
* This method is to Return List of Certification_Tracker__c(Competency Tracker) 
* **********************************************
**/
    public static List<Certification_Tracker__c> createNcertTracker(Integer intNoRec){
        List<Certification_Tracker__c> listcertTracker = new list<Certification_Tracker__c>();
        
        for(Integer inti = 0; inti < intNoRec ; inti++){
            Certification_Tracker__c certTracker=new Certification_Tracker__c();
            certTracker.Evaluate_Criteria__c=true;       
            certTracker.Dell_Certification_Areas__c = 'Networking';
            certTracker.Demo_Unit_Criteria_Met__c = true;
            certTracker.Training_Criteria_Met__c = true;
            certTracker.Last_Evaluation_date__c = System.Now().Date().addDays(180);
            
            listcertTracker.add(certTracker);
        }
        return listcertTracker;
    }
    
    /** 
* **********************************************
* This method is to Return List of Country__c 
* **********************************************
**/
    public static List<Country__c> createNCountry(Integer intNoRec){
        List<Country__c> listCountry=new List<Country__c>();
        for(Integer inti = 0; inti < intNoRec ; inti++){
            Country__c country=new Country__c();
            country.name = 'TESCOUNTRY';
            country.Code__c = 'T6';
            country.Region__c = 'APJ';
            country.Training_Enabled__c = 'Yes';
            country.Deal_Registration_Enabled__c = 'Yes';
            country.Last_Operation_Performed__c='Test Data';
            country.Inc_Vendor_Name__c='Not Applicable/On Hold';
            country.Lead_Management_Enabled__c = 'Yes';
            country.Lead_Management_Enabled_for_OEM__c = 'Yes';
            country.Partner_Relationship__c = 'All';
            country.Partner_Relationship_for_OEM__c = 'All';
            listCountry.add(country);
        }
        return listCountry;
    }
    /** 
* **********************************************
* This method is to Return List of CSMB Contract Email Edit(Contract_Manager_Email__c) 
* **********************************************
**/
    public static List<Contract_Manager_Email__c> createNContractManager(Integer intNoRec){
        List<Contract_Manager_Email__c> listCSMB=new List<Contract_Manager_Email__c>();
        for(Integer inti = 0; inti < intNoRec ; inti++){
            Contract_Manager_Email__c cSMB =new Contract_Manager_Email__c();
            cSMB.Region__c='Americas';
            cSMB.Sub_Region1__c='LatinAmericas';
            cSMB.Business_unit1__c='CSG/Telco';
            listCSMB.add(cSMB);
        }
        return listCSMB;
    }  
    
    /** 
* **********************************************
* This method is to Return List of Contract 
* **********************************************
**/
    public static List<Contract> createNContract(Integer intNoRec){
        List<Contract> listContract=new List<Contract>();
        for(Integer inti = 0; inti < intNoRec ; inti++){
            Contract contr =new Contract();
            contr.Contract_Entity_Name__c = 'Test Name'+inti;
            contr.Account_Country__c = 'Country'+inti;
            contr.Corporate_Parent_Name__c = 'Test Corp'+inti;
            contr.Status='Pending';
            contr.Business_Unit_Primary_SR1__c = 'Consumer Retail';
            contr.Region_SR__c = 'Americas'; 
            contr.Sub_Region_SR__c = 'Latin America';
            contr.Completed__c=false;
            contr.Contract_Type_mainData__c = 'Customer Terms & Conditions';
            contr.Initial_Contract_Term_Requested__c = '1 Year';
            contr.Prior_Contact_Agreement__c = 'No';
            contr.Renew__c = 'Evergreen';
            contr.Customer_Signed_By__c = 'Text Sign'+inti;
            contr.Company_Signed_By__c = 'Text Company Sign'+inti;
            contr.CustomerSignedTitle = 'Sign Tittle'+inti;
            contr.CompanySignedDate = System.Now().Date().addDays(180);
            contr.Contract_Status__c = 'Active';
            contr.Effective_date__c = System.now().Date().addDays(180);
            contr.Expiration_mainData__c = system.now().Date().addDays(90);
            contr.Contract_Type__c = 'CFI';
            contr.Dell_Contracting_Entity_Region__c = 'Americas - US';
            contr.Revenue_Recognition_Flag__c = 'Yes';
            contr.Revenue_Recognition_Flag_If_Yes_then__c = 'Acceptance Language';
            contr.Rebates__c = '30';
            contr.Fee__c = '30';
            listContract.add(Contr);
        }
        return listContract;
    } 
    /** 
* **********************************************
* This method is to Return List of Idea_Intake__c 
* **********************************************
**/
    public static List<Idea_Intake__c> createNIdeaIntake(Integer intNoRec,string strRecordTypeName){
        List<Idea_Intake__c> listIdeaIntake=new List<Idea_Intake__c>();
        for(Integer inti = 0; inti < intNoRec ; inti++){
            Idea_Intake__c idiaIntake=new Idea_Intake__c();
            idiaIntake.RecordTypeId = schema.SObjectType.Idea_Intake__c.getRecordTypeInfosByName().get(strRecordTypeName).getRecordTypeId();
            idiaIntake.Regions_Impacted__c ='testRegion';
            idiaIntake.Requesting_organization__c='testReqOrg';
            idiaIntake.Requesting_region__c  ='testReqReg';
            idiaIntake.Business_Challenge__c = 'testBusCha';
            idiaIntake.Business_Justification__c ='testBusJus';
            idiaIntake.Business_Objective__c ='testBusObj';
            listIdeaIntake.add(idiaIntake);
        }
        return listIdeaIntake;
    }
    /** 
* **********************************************
* This method is to Return List of Account_Play__c 
* **********************************************
**/
    public static List<Account_Play__c> createNAccountPlay(Integer intNoRec,string strRecordTypeName){
        List<Account_Play__c> listAccountPlay=new List<Account_Play__c>();
        for(Integer inti = 0; inti < intNoRec ; inti++){
            Account_Play__c accountPlay=new Account_Play__c();
            accountPlay.RecordTypeId = schema.SObjectType.Account_Play__c.getRecordTypeInfosByName().get(strRecordTypeName).getRecordTypeId();
            if(strRecordTypeName=='Lattice'){
                accountPlay.Campaign_Vehicle__c='Multiple Vehicles';
                accountPlay.Lattice_IsActive__c=true;
                accountPlay.Lattice_Pre_Lead_External_ID__c='aaaa';
                accountPlay.Status__c='Existing Opportunity';
            }else{
                accountPlay.Status__c = 'Requires Follow-Up';
                //Account__c = newCMAPAcc.Id,
                //Campaign__c = CMAP_dirAP_camp.Id,
                //Primary_Contact__c = newCMAPCont .Id,
                accountPlay.Customer_Consents_to_Engage_Dell_Partner__c= TRUE;
                accountPlay.What_is_their_implementation_deadline__c = System.Today();
                accountPlay.Roadblocks__c  = 'No Road Bloack';
                accountPlay.Desired_Outcome__c = 'OutCome';
                accountPlay.Estimated_Budget__c = 10922;
                accountPlay.Do_they_have_access_to_approved_funds__c = 'Yes';
                accountPlay.Interested_in_DFS_funding__c='No';                                     
                accountPlay.Marketing_Comments__c = 'test';
                accountPlay.Challenges_Driving_the_Project__c = 'channelges';
            }
            listAccountPlay.add(accountPlay);
        }
        return listAccountPlay;
    }
    /** 
* *************************************************************************************************
* This method is to Return List of Contract_Terms_and_Conditions__c(Contract Terms and Conditions) 
* ************************************************************************************************
**/
    public static List<Contract_Terms_and_Conditions__c> createNContractTermsANdCondition(Integer intNoRec,string strRecordTypeName){
        List<Contract_Terms_and_Conditions__c> listContractTC=new List<Contract_Terms_and_Conditions__c>();
        for(Integer inti = 0; inti < intNoRec ; inti++){
            Contract_Terms_and_Conditions__c contractTc=new Contract_Terms_and_Conditions__c();
            contractTc.RecordTypeId = schema.SObjectType.Contract_Terms_and_Conditions__c.getRecordTypeInfosByName().get(strRecordTypeName).getRecordTypeId();
            contractTc.Non_Standard_Term_Repository__c='Audit';
            contractTc.Non_Standard_Terms_and_Conditions__c='Non standard Audit Test data';
            contractTc.Section__c = 'Text'+inti;
            contractTc.Terms_and_conditions_Content__c = 'Terms and Conditions'+inti;
            listContractTC.add(contractTc);
        }
        return listContractTC;
    }  
    /** 
* ******************************************************************************
* This method is to Return List of CSMB_Terms_and_Conditions_Maintenance__c 
* ******************************************************************************
**/
    public static List<CSMB_Terms_and_Conditions_Maintenance__c> createNCSMBTermsANdConditionMaintenance(Integer intNoRec){
        List<CSMB_Terms_and_Conditions_Maintenance__c> listCSMBTermsMain=new List<CSMB_Terms_and_Conditions_Maintenance__c>();
        for(Integer inti = 0; inti < intNoRec ; inti++){
            CSMB_Terms_and_Conditions_Maintenance__c cSMBTermsMain=new CSMB_Terms_and_Conditions_Maintenance__c();
            cSMBTermsMain.Name = 'Name Description'+inti;
            cSMBTermsMain.status__c=True;
            cSMBTermsMain.Description__c = 'Terms and maintenance'+inti;
            listCSMBTermsMain.add(cSMBTermsMain);
        }
        return listCSMBTermsMain; 
    }  
    /** 
* ******************************************************************************
* This method is to Return List of CSMB_Terms_and_Condition__c 
* ******************************************************************************
**/
    public static List<CSMB_Terms_and_Condition__c> createNCSMBTermsANdCondition(Integer intNoRec){
        List<CSMB_Terms_and_Conditions_Maintenance__c> listCSMBTermsMain = TestDataFactory.createNCSMBTermsANdConditionMaintenance(1);
        if(listCSMBTermsMain.size() > 0){
            insert listCSMBTermsMain;
        }
        
        List<CSMB_Terms_and_Condition__c> listCSMBTermsCond=new List<CSMB_Terms_and_Condition__c>();
        for(Integer inti = 0; inti < intNoRec ; inti++){
            CSMB_Terms_and_Condition__c cSMBTerms=new CSMB_Terms_and_Condition__c();
            cSMBTerms.Standard_Term__c = listCSMBTermsMain[0].id;
            cSMBTerms.status__c=True;
            cSMBTerms.Standard_Terms_and_Conditions__c = 'Terms and Conditions'+inti;
            listCSMBTermsCond.add(cSMBTerms);
        }
        return listCSMBTermsCond; 
    }  
    /** 
* ******************************************************************************
* This method is to Return List of Addendum_Data__c 
* ******************************************************************************
**/ 
    public static List<Addendum_Data__c> createNAddendumData(Integer intNoRec){
        List<Addendum_Data__c> listAddendumData=new List<Addendum_Data__c>();
        for(Integer inti = 0; inti < intNoRec ; inti++){
            Addendum_Data__c addendumData=new Addendum_Data__c();
            addendumData.Addendum_status__c = 'Active';
            addendumData.name='Test Name'+inti;
            addendumData.Addendum_Effective_Date__c = System.now().Date().addDays(180);
            addendumData.Addendum_Expiration__c = System.now().Date().addDays(90);
            addendumData.Addendum_Form_Version__c = 'Version'+inti;
            addendumData.Addendum_Non_Standard__c = True;
            addendumData.Addendum_Summary__c = 'Test Description'+inti;
            addendumData.Link_to_Addendum_Documentation__c = 'Addendum Documentaion'+inti;
            listAddendumData.add(addendumData);
        } 
        return listAddendumData;
    }   
    /** 
* ******************************************************************************
* This method is to Return List of Demo_Unit__c 
* ******************************************************************************
**/ 
    public static List<Demo_Unit__c> createNDemounit(Integer intNoRec){
        List<Demo_Unit__c> listdemounit=new List<Demo_Unit__c>();
        for(Integer inti = 0; inti < intNoRec ; inti++){
            Demo_Unit__c demounit=new Demo_Unit__c();
            demounit.Demo_Unit_Type__c='Compellent Demo'+inti;
            demounit.Order_Number__c='1'+inti;
            // demounit.TSR_Name__c='abcd'; 
            demounit.Order_Date__c= System.now().Date().addDays(180);
            //  demounit.Contact_Name__c='Name'+inti;
            demounit.T_C__c='Yes';
            demounit.Contact_Email__c='Demomail'+inti+'@dell.com';
            listdemounit.add(demounit);
        } 
        return listdemounit;
    }  
    /** 
* ******************************************************************************
* This method is to Return List of CTI_Call_Log__c 
* ******************************************************************************
**/ 
    public static List<CTI_Call_Log__c> createNCTIcallLog(Integer intNoRec){
        List<CTI_Call_Log__c> listCTICALL=new List<CTI_Call_Log__c>();
        for(Integer inti = 0; inti < intNoRec ; inti++){
            CTI_Call_Log__c cticall=new CTI_Call_Log__c();
            cticall.Router_Call_Day__c = 'Call Details'+inti;
            cticall.Router_Call_Key__c = 'Call Key Details'+inti;
            cticall.Phone_Number__c = '12345678'+inti;
            cticall.Comments__c = 'Text Comnents'+inti;
            listCTICALL.add(cticall);
        } 
        return listCTICALL; 
    }  
    
    /** 
* ******************************************************************************
* This method is to Return List of Demo_Unit_Setup__c 
* ******************************************************************************
**/ 
    public static List<Demo_Unit_Setup__c> createNDemoUnitSetup(Integer intNoRec){
        List<Demo_Unit_Setup__c> listDemoUnitSetup=new List<Demo_Unit_Setup__c>();
        for(Integer inti = 0; inti < intNoRec ; inti++){
            Demo_Unit_Setup__c demoUnitsetup=new Demo_Unit_Setup__c();
            demoUnitsetup.Name = 'Setup Name'+inti;
            demoUnitsetup.Active__c = True;
            demoUnitsetup.Demo_Unit_Description__c = 'Demo Setup Description'+inti;
            listDemoUnitSetup.add(demoUnitsetup);
        } 
        return listDemoUnitSetup; 
    }  
    /** 
* ******************************************************************************
* This method is to Return List of Course__c 
* ******************************************************************************
**/ 
    public static List<Course__c> createNCourse(Integer intNoRec){
        List<Course__c> listCourse=new List<Course__c>();
        for(Integer inti = 0; inti < intNoRec ; inti++){
            Course__c course=new Course__c();
            course.Course_Description__c = 'Course Details'+ inti;
            course.Course_Type__c = 'Type of Course'+inti;
            course.Course_Modality__c = 'Modules'+inti;
            course.Course_Name__c = 'Type of Course'+inti;
            course.Credit_Hours__c = 6;
            listCourse.add(course);
        } 
        return listCourse; 
    }  
    
    /** 
* ******************************************************************************
* This method is to Return List of Master_Program_Setup__c 
* ******************************************************************************
**/ 
    public static List<Master_Program_Setup__c> createNMasterProSetup(Integer intNoRec){
        List<Master_Program_Setup__c> listMasterProSetup=new List<Master_Program_Setup__c>();
        for(Integer inti = 0; inti < intNoRec ; inti++){
            Master_Program_Setup__c masterProSet=new Master_Program_Setup__c();
            masterProSet.Master_Program_Name__c = 'TestMP'+inti;
            masterProSet.Apply_Requirement_To__c ='Global';
            masterProSet.Active__c=true;
            masterProSet.Certification_Name__c='Security ; Networking';
            masterProSet.CompetencyName2__c = 'Server';
            masterProSet.Competency_FName__c='Server';
            masterProSet.Competency_F1Name__c='Server'; 
            listMasterProSetup.add(masterProSet);
        } 
        return listMasterProSetup; 
    }  
    
    /** 
* ******************************************************************************
* This method is to Return List of Certification_Requirement_Setup__c 
* ******************************************************************************
**/ 
    public static List<Certification_Requirement_Setup__c> createNCertificationReqSetUp(Integer intNoRec){
        List<Certification_Requirement_Setup__c> listCertiReqSetup=new List<Certification_Requirement_Setup__c>();
        for(Integer inti = 0; inti < intNoRec ; inti++){
            Certification_Requirement_Setup__c certiReqSetup=new Certification_Requirement_Setup__c();
            certiReqSetup.name='test1'+inti;
            certiReqSetup.Apply_Requirement_To__c='Global';       
            certiReqSetup.Certification_Name__c = 'Security';    
            certiReqSetup.Acquisition__c = 'A'+inti;               
            certiReqSetup.Active__c = true;
            certiReqSetup.Prerequisites__c =true;
            listCertiReqSetup.add(certiReqSetup);
        } 
        return listCertiReqSetup;  
    }  
    /** 
* ******************************************************************************
* This method is to Return List of Certification_Prerequisites_Setup__c 
* ******************************************************************************
**/ 
    public static List<Certification_Prerequisites_Setup__c> createNCertificationPreReqSetUp(Integer intNoRec){
        List<Certification_Prerequisites_Setup__c> listCertiPreReqSetup=new List<Certification_Prerequisites_Setup__c>();
        for(Integer inti = 0; inti < intNoRec ; inti++){
            Certification_Prerequisites_Setup__c certiPreReqSetup=new Certification_Prerequisites_Setup__c();
            certiPreReqSetup.Condition__c = 'All';
            certiPreReqSetup.Prerequisites__c='D101 - Dell Course 1 OR D102 - Dell Course2 ; D103 - Dell Course 3 ; D104 - Dell Course 4';
            certiPreReqSetup.Prerequisites_Ids__c = 'D101 OR D102 ; D103 ; D104';
            listCertiPreReqSetup.add(certiPreReqSetup);
        } 
        return listCertiPreReqSetup; 
    }  
    /** 
* ******************************************************************************
* This method is to Return List of Certification_Criteria_Setup__c 
* ******************************************************************************
**/ 
    public static List<Certification_Criteria_Setup__c> createNCertificationCriteriaSetup(Integer intNoRec){
        List<Certification_Criteria_Setup__c> listCriteriaSetup=new List<Certification_Criteria_Setup__c>();
        for(Integer inti = 0; inti < intNoRec ; inti++){
            Certification_Criteria_Setup__c certCriteriaSetup=new Certification_Criteria_Setup__c();
            certCriteriaSetup.Certification_Criteria_Name__c = 'Demo Unit';
            certCriteriaSetup.Certification_Criteria_Value__c = 'TextDemo'+inti;
            certCriteriaSetup.Number_of_Demo_Units__c = 1;
            certCriteriaSetup.Certification_Criteria_Order__c = 2;
            certCriteriaSetup.Criteria_Value_Ids_PostFixFormat__c = 'Criteria Value '+inti;
            certCriteriaSetup.Criteria_Value_Ids__c = 'text id '+inti;
            certCriteriaSetup.Condition__c = 'All';
            listCriteriaSetup.add(certCriteriaSetup);
        } 
        return listCriteriaSetup; 
    } 
    
    /** 
* ******************************************************************************
* This method is to Return List of Partner_Course__c 
* ******************************************************************************
**/ 
    public static List<Partner_Course__c> createNPartnerCourse(Integer intNoRec){
        List<Partner_Course__c> listPartnerCourse=new List<Partner_Course__c>();
        for(Integer inti = 0; inti < intNoRec ; inti++){
            Partner_Course__c partnercourse=new Partner_Course__c();
            partnercourse.Course_Completed_Date__c = System.now().Date().addDays(180);
            listPartnerCourse.add(partnercourse);
        }  
        return listPartnerCourse; 
    }     
    /** 
* ******************************************************************************
* This method is to Return List of End_Customer__c 
* ******************************************************************************
**/ 
    public static List<End_Customer__c> createNEndCustomer(Integer intNoRec){
        List<End_Customer__c> listEndCustomer=new List<End_Customer__c>();
        for(Integer inti = 0; inti < intNoRec ; inti++){
            End_Customer__c endcustomer=new End_Customer__c();
            endcustomer.Name = 'Company Name'+inti;
            endcustomer.Account_Department__c = 'Department'+inti;
            endcustomer.Account_Industry__c = 'Banking';
            endcustomer.B2BCRTEndUserID__c = 'External ID'+inti;
            endcustomer.Created_using_Partner_D_B_Search__c = 'No';
            endcustomer.IsInactivateBatchClassError__c = 'Test Description'  + inti;
            endcustomer.End_Customer_Selection__c = 'D&B Search';
            endcustomer.EU_ORG_PID__c = 'EU HUB '+inti;
            endcustomer.EU_Local_Channel__c = 'EU Local Channel'+inti;
            endcustomer.EU_OMS__c = 'EU OMS'+inti;
            endcustomer.Mailing_city__c = 'Mailing City'+inti;
            endcustomer.Mailing_country__c = 'United States';
            endcustomer.Mailing_State__c = 'State'+inti;
            endcustomer.Mailing_street__c = 'Street'+inti;
            endcustomer.Mailing_Street2__c = 'Steet2'+inti;
            endcustomer.DUNS_Number__c = 'Select DUNS Number'+inti;
            endcustomer.Segment__c = 'Education';
            endcustomer.Source_System__c = 'Deal Registration';
            endcustomer.Status__c = 'Active';
            endcustomer.Total_of_End_User_Employees__c = '100-199';
            endcustomer.Zip_Code__c = '00000'+inti;
            listEndCustomer.add(endcustomer);
        }  
        return listEndCustomer; 
    }     
    
    /** 
* ******************************************************************************
* This method is to Return List of End_Customer_Contact__c 
* ******************************************************************************
**/ 
    public static List<End_Customer_Contact__c> createNEndCustomerContact(Integer intNoRec){
        List<End_Customer_Contact__c> listEndCustomercontact=new List<End_Customer_Contact__c>();
        for(Integer inti = 0; inti < intNoRec ; inti++){
            End_Customer_Contact__c endcustomercon=new End_Customer_Contact__c();
            endcustomercon.Name = 'Company Name'+inti;
            endcustomercon.Email__c = 'customermail'+inti+'@dell.com';
            endcustomercon.Fax__c = '12345'+inti;
            endcustomercon.Last_Name__c = 'Last Name'+inti;
            endcustomercon.Mobile__c = '123456789'+inti;
            endcustomercon.Phone__c = '99999999'+inti;
            endcustomercon.Source_System__c = 'Channel DB';
            endcustomercon.Status__c = 'Active';
            endcustomercon.Title__c = 'End Customer Contact'+inti;
            listEndCustomercontact.add(endcustomercon);
        }  
        return listEndCustomercontact; 
    }     
    /** 
* ******************************************************************************
* This method is to Return List of SFDC_Strategy__c 
* ******************************************************************************
**/ 
    public static List<SFDC_Strategy__c> createNSfdcStrategy(Integer intNoRec){
        List<SFDC_Strategy__c> listSfdcStrategy=new List<SFDC_Strategy__c>();
        for(Integer inti = 0; inti < intNoRec ; inti++){
            SFDC_Strategy__c sfdcStrategy=new SFDC_Strategy__c();
            sfdcStrategy.Name='Test Strategy'+inti;
            sfdcStrategy.When_do_you_plan_to_realize_Strategy__c='FY20 Q3';
            sfdcStrategy.What_BU_s_are_involved__c='Client; Compute (Servers); Enterprise Infrastructure; Networking; Pivotal; Services; Storage; Virtustream; VMware; Boomi; Client S&P; CS; ESG; RSA; SecureWorks; DPS; UDS; Unified Workspace';
            sfdcStrategy.Potential_Strategy_Value__c = 1.00;
            sfdcStrategy.Customer_Business_Challenges_Objectives__c='Test Customer Objectives';
            sfdcStrategy.IT_Implications__c='Test IT Implications'+inti;
            sfdcStrategy.Dell_s_Strategy_Response__c='Test Dell Proposed Solution';
            sfdcStrategy.Which_LOB_will_you_offer__c='Services';
            sfdcStrategy.Region__c='APJ';
            sfdcStrategy.Strengths__c='Test Soln Strengths';
            sfdcStrategy.Threats__c='Test threats';
            sfdcStrategy.Enterprise_Business_Issue__c = 'Test Customer Objective';
            
            listSfdcStrategy.add(sfdcStrategy);
        }  
        return listSfdcStrategy; 
    }     
}