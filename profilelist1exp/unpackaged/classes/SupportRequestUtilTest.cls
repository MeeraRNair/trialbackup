/* 
REVISION HISTORY
================
Version     Author      Date            Release#    CR#         Description
-------     ------      ----            --------    ---         -----------
1.0         Fenny       09-Aug-2012     13.7                    Test method failed when deploy changeset, do not hardcode profile name
2.0         Kokila      05-Jun-2015     16.7        CR11543     Test method to populate Total Account Revenue and Margin for last 4 Quarters from Revenue object as per user story 162174 
3.0         JatinPuri1  13-july-2018  FY19-DCS-0802 CR16149     Removed comments as part of code Reduce for the story 5240511
*/
@isTest
private class SupportRequestUtilTest {

static PricebookEntry pricebookEntry;  

    public static testmethod void testSupportRequestTrigger(){ 
    
        Account testAccount = new Account(Name='Test Account 10');
        
        //Standard Opportunity
        //RecordType recordType = [select id, Name  from RecordType where Name ='APOS' limit 1];
        
        Date dCloseDate1 = System.Today()+10;
        
        Opportunity testOpportunity = new Opportunity(RecordTypeId='012300000004zf2', Name='Test Opportunity 1', AccountId=testAccount.Id, Type='Deal/Bid Direct', CloseDate=dCloseDate1, StageName='Plan - 1%');
                
        //Opportunity testOpportunity = [select id from Opportunity limit 1];
        
        //Profile profile = [select id from profile where Name = 'R12.10 GBL Sales Rep - Non SSO' limit 1]; // Ver 1.0
        //3.0
        Profile profile = [SELECT id from profile WHERE Name LIKE '%GBL Sales Rep' ORDER BY Name DESC NULLS LAST LIMIT 1]; // Ver 1.0
        List<User> testUser = new List<User>();
        
        testUser.add(new User(Username=String.valueOf(datetime.now()).replace(':', '_').replace('-', '_').replace(' ', '_') +'1@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test',
                                    Title='GCC Program Manager', 
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test1'+System.currentTimeMillis()));
                                    
        testUser.add(new User(Username= String.valueOf(datetime.now()).replace(':', '_').replace('-', '_').replace(' ', '_') +'2@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test',
                                    Title='GCC Program Manager', 
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test2'+System.currentTimeMillis()));
                                    
        insert testUser;
        
        insert testAccount;
            
        insert testOpportunity;
        
        //2.0 - Commentting Starts - To avoid too many SOQL error 
        /*String PPT_RECORDTYPEID = IdLookupUtils.getRecordTypeId('Request Pre-Sales Product Technologist Support', 'Support_Request__c', true); 
        
        Support_Request__c request = 
            new Support_Request__c(RecordTypeId=PPT_RECORDTYPEID, Opportunity__c=testOpportunity.Id,  Customer_Contact_Name__c ='test customer', 
                Customer_Address__c ='test add', Customer_Email__c ='test@test.com', Security_Clearance__c ='Yes', 
                Customer_Phone_Number__c = '0123333445', Engagement_Type__c ='AIM POD Demo', Cost_Center_Number__c='0123344556', 
                Primary_Competitor__c='test competitor', Requested_By_Phone__c ='0128899887');
       
        Test.startTest();
        
        insert request;
        
        System.assertEquals(request.Intake_Manager__c, null);
        
        request.Request_meets_requirement__c = 'Yes';
        
        request.Assigned_System_Engineer_1__c = testUser[0].Id;
        
        request.Assigned_System_Engineer_2__c = testUser[0].Id;
        
        update request; */        //2.0 - Commentting Ends- To avoid too many SOQL error 
        
        
        /*request.Assigned_System_Engineer_1__c = testUser[0].Id;
        
        request.Assigned_System_Engineer_2__c = testUser[1].Id;
        
        update request;*/
        
        /*Support_Request__c updatedRequest = [select id, Intake_Manager__c from Support_Request__c where id = :request.id limit 1];
        
        System.debug('Intake Manager : ' + updatedRequest.Intake_Manager__c);
        
        System.assertNotEquals(updatedRequest.Intake_Manager__c, null);
        
        List<OpportunityTeamMember> foundOTMs = [select Id from OpportunityTeamMember where opportunityId=:testOpportunity.Id and (UserId=:testUser[0].Id or UserId=:testUser[1].id)];
       
        System.assertEquals(foundOTMs.size(), 2);
        
        List<OpportunityShare> foundOShares = [select Id from OpportunityShare where opportunityId=:testOpportunity.Id and (UserOrGroupId=:testUser[0].Id or UserOrGroupId=:testUser[1].id)];
       
        System.assertEquals(foundOShares.size(), 2);*/
        
        //Start - 2.0
        
        List<Support_Request__c> sr = new List<Support_Request__c>();
        
        String PPT_RECORDTYPEID     = IdLookupUtils.getRecordTypeId('Request Pre-Sales Product Technologist Support', 'Support_Request__c', true); 
        String OPP_STD_RECORDTYPEID = IdLookupUtils.getRecordTypeId('Standard Opportunity', 'Opportunity', true); 
        String SR_CSS_RECORDTYPEID  = IdLookupUtils.getRecordTypeId('Request Custom Service Support', 'Support_Request__c', true);
               
        Support_Request__c request = 
            new Support_Request__c(RecordTypeId=PPT_RECORDTYPEID, Opportunity__c=testOpportunity.Id,  Customer_Contact_Name__c ='test customer', 
                Customer_Address__c ='test add', Customer_Email__c ='test@test.com', Security_Clearance__c ='Yes', 
                Customer_Phone_Number__c = '0123333445', Engagement_Type__c ='AIM POD Demo', Cost_Center_Number__c='0123344556', 
                Primary_Competitor__c='test competitor', Requested_By_Phone__c ='0128899887');
  
        sr.add(request);
        
        Account testAcc  = new Account(Name='Test Account');
        insert testAcc;
        
        //Variables to identify the current date is in which Quarter and Fiscal Year
        Map<String, Map<Integer, Period>> FYQTRInfoMap = new Map<String, Map<Integer, Period>>();
        Map<String, FiscalYearSettings> mapFYInfo = new Map<String, FiscalYearSettings>();
        Set<Id> setFYSId = new Set<Id>();
        String sFiscalYear;
        Integer iFiscalYear;
        String sQuarter;
        Integer iQuarter;
        Integer intxYear;
        String strxYear;
        Integer iCloseYear = 0;     
        Date quarterStartDate;
        Integer minCloseYearInt;
        Integer maxCloseYearInt = 0;
        
        //Current Fiscal Quarter and Fiscal Year calculation -- Start
        Date dCloseDate = date.today(); 
        iCloseYear = dCloseDate.year();    
        
        //Find minimum and maximum Fiscal close years, and capture the close year into an array (For example, if current year is 2015, add 2016 also in set)
        minCloseYearInt = iCloseYear; 
        maxCloseYearInt = iCloseYear+1;  

        Set<String> setxYearStr = new Set<String>{String.valueof(minCloseYearInt),String.valueof(maxCloseYearInt)};

        //Create a map of fiscal years, and start and end dates for DELL org
        for(FiscalYearSettings FYSetting : [SELECT Id, Name, StartDate, EndDate, YearType FROM FiscalYearSettings WHERE YearType = 'Custom' and Name IN:                                        setxYearStr]) {

                setFYSId.add(FYSetting.Id);
                mapFYInfo.put(FYSetting.Name, FYSetting);
                
        }
                
        if(setFYSId.size() > 0) {
            
            //Create maps of fiscal years and quarters, and fiscal years from Period
            for (Period FYPeriod : [SELECT Id, FiscalYearSettings.Name, Number, Type, StartDate, EndDate FROM Period WHERE FiscalYearSettingsId IN: setFYSId AND                        Type = 'Quarter']) {
            
                // Create a map of fiscal year and quarter information
                if(FYPeriod.Type == 'Quarter') {
                    
                    Period dtStartEndDates = new Period(StartDate = FYPeriod.StartDate, EndDate = FYPeriod.EndDate); 
                    // Get the map associated to fiscal year
                    Map<Integer, Period> mapQP = FYQTRInfoMap.get(FYPeriod.FiscalYearSettings.Name);
                    
                    if (mapQP == null) 
                    {
                        mapQP = new map<Integer, Period>();
                    }        
                        mapQP.put(FYPeriod.Number, dtStartEndDates);  
                        FYQTRInfoMap.put(FYPeriod.FiscalYearSettings.Name, mapQP); 
                }
             }
        }

            sFiscalYear = '';
            sQuarter = '';
            
            Date xdate = date.today();
            intxYear = (Integer)xdate.year();
            strxYear = String.valueOf(intxYear); 

            // Get start and end dates corresponding to xYear by querying table[FiscalYearSettings]. 
            FiscalYearSettings FYStartEndDates =  mapFYInfo.get(strxYear);
            if(FYStartEndDates != null)
            {
                // Calculate the fiscal year
                if (xdate > FYStartEndDates.EndDate) 
                {
                    iFiscalYear = intxYear + 1;
                }        
                else 
                {
                    iFiscalYear = intxYear;
                }
                sFiscalYear = String.valueOf(iFiscalYear);
          
                // Determine the quarter that the Support Request created date (today) falls into
                map<Integer, Period> mapQtrStartEndDates = FYQTRInfoMap.get(sFiscalYear);
                if (mapQtrStartEndDates != null && mapQtrStartEndDates.size() > 0) 
                {
                    iQuarter = 0;
                    for (Integer i=1; i<=mapQtrStartEndDates.size(); i++) 
                    {        
                        Period StartEndRange = mapQtrStartEndDates.get(i);                    
                       
                       if (xdate >= StartEndRange.StartDate && xdate <= StartEndRange.EndDate) 
                        {
                            iQuarter = i;
                            quarterStartDate = StartEndRange.StartDate; 
                            break;
                        }                    
                    }
                    sQuarter = String.valueOf(iQuarter);
                }

            } //Current Fiscal Quarter and Fiscal Year calculation -- End
                    
            Integer FYear4;
        Revenue__c  testRevenue1 = new Revenue__c();
          testRevenue1.Account__c=testAcc.ID;
          if(iQuarter == 1) {
                FYear4 = Date.Today().Year();
                testRevenue1.Fiscal_Quarter__c = 'Q04';
                testRevenue1.Fiscal_Year__c = 'FY' + FYear4;
            } else if(iQuarter == 2) {
                FYear4 = Date.Today().Year()+1;
                testRevenue1.Fiscal_Quarter__c = 'Q01';
                testRevenue1.Fiscal_Year__c = 'FY' + FYear4;
            } else if(iQuarter == 3) {
                FYear4 = Date.Today().Year()+1;
                testRevenue1.Fiscal_Quarter__c = 'Q02';
                testRevenue1.Fiscal_Year__c = 'FY' + FYear4;
            }else if(iQuarter == 4) {
                FYear4 = Date.Today().Year()+1;
                testRevenue1.Fiscal_Quarter__c = 'Q03';
                testRevenue1.Fiscal_Year__c = 'FY' + FYear4;
            }   
          testRevenue1.Non_Tied_QTR_Rev__c = 1.00;
          testRevenue1.S_P_QTR_Rev__c = 1.00;
          testRevenue1.Server_QTR_Rev__c = 1.00;
          testRevenue1.Notebook_QTR_Rev__c = 1.00;
          testRevenue1.EMC_QTR_Rev__c = 1.00;
          testRevenue1.Power_Vault_QTR_Rev__c = 1.00;
          testRevenue1.Imaging_QTR_Rev__c = 1.00;
          testRevenue1.Desktop_QTR_Rev__c = 1.00;
          testRevenue1.Workstation_QTR_Rev__c = 1.00;
          testRevenue1.Non_Tied_QTR_Margin__c = 10.00; 
          testRevenue1.S_P_QTR_Margin__c = 10;  
          testRevenue1.Server_QTR_Margin__c = 10; 
          testRevenue1.Notebook_QTR_Margin__c = 10;  
          testRevenue1.EMC_QTR_Margin__c = 10;  
          testRevenue1.Powervault_QTR_Margin__c = 10; 
          testRevenue1.Imaging_QTR_Margin__c = 10; 
          testRevenue1.Desktop_QTR_Margin__c = 10; 
          testRevenue1.Workstation_QTR_Margin__c = 10;
        Insert testRevenue1;
   
        Revenue__c  testRevenue2 = new Revenue__c();
        testRevenue2.Account__c=testAcc.ID;
          if(iQuarter == 1) {
                FYear4 = Date.Today().Year();
                testRevenue2.Fiscal_Quarter__c = 'Q03';
                testRevenue2.Fiscal_Year__c = 'FY' + FYear4;
            } else if(iQuarter == 2) {
                FYear4 = Date.Today().Year();
                testRevenue2.Fiscal_Quarter__c = 'Q04';
                testRevenue2.Fiscal_Year__c = 'FY' + FYear4;
            } else if(iQuarter == 3) {
                FYear4 = Date.Today().Year()+1;
                testRevenue2.Fiscal_Quarter__c = 'Q01';
                testRevenue2.Fiscal_Year__c = 'FY' + FYear4;
            }else if(iQuarter == 4) {
                FYear4 = Date.Today().Year()+1;
                testRevenue2.Fiscal_Quarter__c = 'Q02';
                testRevenue2.Fiscal_Year__c = 'FY' + FYear4;
            }   
          testRevenue2.Non_Tied_QTR_Rev__c = 2;
          testRevenue2.S_P_QTR_Rev__c = 2;
          testRevenue2.Server_QTR_Rev__c = 2;
          testRevenue2.Notebook_QTR_Rev__c = 2; 
          testRevenue2.EMC_QTR_Rev__c = 2;
          testRevenue2.Power_Vault_QTR_Rev__c = 2;
          testRevenue2.Imaging_QTR_Rev__c = 2;
          testRevenue2.Desktop_QTR_Rev__c = 2;
          testRevenue2.Workstation_QTR_Rev__c = 2;
          testRevenue2.Non_Tied_QTR_Margin__c = 20; 
          testRevenue2.S_P_QTR_Margin__c = 20;
          testRevenue2.Server_QTR_Margin__c = 20; 
          testRevenue2.Notebook_QTR_Margin__c = 20;  
          testRevenue2.EMC_QTR_Margin__c = 20;  
          testRevenue2.Powervault_QTR_Margin__c = 20; 
          testRevenue2.Imaging_QTR_Margin__c = 20; 
          testRevenue2.Desktop_QTR_Margin__c = 20; 
          testRevenue2.Workstation_QTR_Margin__c = 20;
        Insert testRevenue2;
        
        Revenue__c  testRevenue3 = new Revenue__c();
        testRevenue3.Account__c=testAcc.ID;
          if(iQuarter == 1) {
                FYear4 = Date.Today().Year();
                testRevenue3.Fiscal_Quarter__c = 'Q02';
                testRevenue3.Fiscal_Year__c = 'FY' + FYear4;
            } else if(iQuarter == 2) {
                FYear4 = Date.Today().Year();
                testRevenue3.Fiscal_Quarter__c = 'Q03';
                testRevenue3.Fiscal_Year__c = 'FY' + FYear4;
            } else if(iQuarter == 3) {
                FYear4 = Date.Today().Year();
                testRevenue3.Fiscal_Quarter__c = 'Q04';
                testRevenue3.Fiscal_Year__c = 'FY' + FYear4;
            }else if(iQuarter == 4) {
                FYear4 = Date.Today().Year()+1;
                testRevenue3.Fiscal_Quarter__c = 'Q01';
                testRevenue3.Fiscal_Year__c = 'FY' + FYear4;
            }   
          testRevenue3.Non_Tied_QTR_Rev__c = 3;
          testRevenue3.S_P_QTR_Rev__c = 3;
          testRevenue3.Server_QTR_Rev__c = 3;
          testRevenue3.Notebook_QTR_Rev__c = 3; 
          testRevenue3.EMC_QTR_Rev__c = 3;
          testRevenue3.Power_Vault_QTR_Rev__c = 3;
          testRevenue3.Imaging_QTR_Rev__c = 3;
          testRevenue3.Desktop_QTR_Rev__c = 3;
          testRevenue3.Workstation_QTR_Rev__c = 3;
          testRevenue3.Non_Tied_QTR_Margin__c = 30; 
          testRevenue3.S_P_QTR_Margin__c = 30;  
          testRevenue3.Server_QTR_Margin__c = 30; 
          testRevenue3.Notebook_QTR_Margin__c = 30;  
          testRevenue3.EMC_QTR_Margin__c = 30;  
          testRevenue3.Powervault_QTR_Margin__c = 30; 
          testRevenue3.Imaging_QTR_Margin__c = 30; 
          testRevenue3.Desktop_QTR_Margin__c = 30; 
          testRevenue3.Workstation_QTR_Margin__c = 30;
        Insert testRevenue3;
        
        Revenue__c  testRevenue4 = new Revenue__c();
        testRevenue4.Account__c=testAcc.ID;
          if(iQuarter == 1) {
                FYear4 = Date.Today().Year();
                testRevenue4.Fiscal_Quarter__c = 'Q01';
                testRevenue4.Fiscal_Year__c = 'FY' + FYear4;
            } else if(iQuarter == 2) {
                FYear4 = Date.Today().Year();
                testRevenue4.Fiscal_Quarter__c = 'Q02';
                testRevenue4.Fiscal_Year__c = 'FY' + FYear4;
            } else if(iQuarter == 3) {
                FYear4 = Date.Today().Year();
                testRevenue4.Fiscal_Quarter__c = 'Q03';
                testRevenue4.Fiscal_Year__c = 'FY' + FYear4;
            }else if(iQuarter == 4) {
                FYear4 = Date.Today().Year();
                testRevenue4.Fiscal_Quarter__c = 'Q04';
                testRevenue4.Fiscal_Year__c = 'FY' + FYear4;
            }   
          testRevenue4.Non_Tied_QTR_Rev__c = 4;
          testRevenue4.S_P_QTR_Rev__c = 4;
          testRevenue4.Server_QTR_Rev__c = 4;
          testRevenue4.Notebook_QTR_Rev__c = 4; 
          testRevenue4.EMC_QTR_Rev__c = 4; 
          testRevenue4.Power_Vault_QTR_Rev__c = 4;
          testRevenue4.Imaging_QTR_Rev__c = 4;
          testRevenue4.Desktop_QTR_Rev__c = 4;
          testRevenue4.Workstation_QTR_Rev__c = 4;
          testRevenue4.Non_Tied_QTR_Margin__c = 40; 
          testRevenue4.S_P_QTR_Margin__c = 40; 
          testRevenue4.Server_QTR_Margin__c = 40; 
          testRevenue4.Notebook_QTR_Margin__c = 40;  
          testRevenue4.EMC_QTR_Margin__c = 40;  
          testRevenue4.Powervault_QTR_Margin__c = 40; 
          testRevenue4.Imaging_QTR_Margin__c = 40; 
          testRevenue4.Desktop_QTR_Margin__c = 40; 
          testRevenue4.Workstation_QTR_Margin__c = 40;
        Insert testRevenue4; 
               
        Contact testCon = new Contact(FirstName = 'Contact1',
                                      LastName = 'Test1',
                                      AccountId = testAcc.ID,
                                      Phone = '23566889',
                                      Decision_Making_Role__c = 'Sponsor/ Champion');
     
        insert testCon;

        Opportunity testOpp = new Opportunity(RecordTypeId      = OPP_STD_RECORDTYPEID,   
                                              Name              = 'Test Opportunity 1', 
                                              AccountId         = testAcc.ID, 
                                              Type              = 'Deal/Bid Direct', 
                                              Domain__c         = 'Business Solutions',
                                              Solution_Type__c  = 'Business Processing Solutions',
                                              Solution_Name__c  = 'CRM',
                                              CloseDate         = dCloseDate, 
                                              CurrencyIsoCode   = 'USD',
                                              StageName         = 'Qualify - 30%', 
                                              Competitor_Lost_To__c='Unknown');     
                                              
        TriggerExecutionController.setSkipOpportunityTriggers(true);                                      
        insert testOpp;
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        //3.0
        Product2 product = new product2(name='Test Product 1',family='Services',isActive=true, Dgr_Eligible__c = 'Yes', Product_ID__c='a1234');   
        insert product;            
        
        Pricebook2 pb = [select Id from Pricebook2 where isStandard=true ];                  
        pricebookEntry = new PricebookEntry(pricebook2id=pb.id, product2id=product.id, unitprice=900000.0, isActive=true);      
        insert pricebookEntry;
        
        //3.0
        OpportunityLineItem oppLI = new OpportunityLineItem(opportunityid=testOpp.id, UnitPrice=5000000, quantity=2, pricebookentryid=pricebookEntry.Id, Product_Type__c= 'Services');
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);            
        insert oppLI;             
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
        
        Support_Request__c testSR =  new Support_Request__c( RecordTypeId                         = SR_CSS_RECORDTYPEID,
                                                              Services_Proposal_Support__c        = 'Yes',
                                                              Custom_Service_Support__c           = 'Custom Service Solution',
                                                              Opportunity__c                      = testOpp.ID,
                                                              Deliverable_Due_Date__c             = dCloseDate + 20,
                                                              Comments__c                         = 'Testing SR REV/MAR',
                                                              Customer_Contact_InformationName__c = testCon.ID);
        sr.add(testSR);
        
        Test.startTest();
        Insert sr;
        
        Support_Request__c sr_IntkMgr = [Select Intake_Manager__c from Support_Request__c where Id =: sr[0].Id];
        System.assertEquals(sr_IntkMgr.Intake_Manager__c, null);
        
        sr[0].Request_meets_requirement__c = 'Yes';
        sr[0].Assigned_System_Engineer_1__c = testUser[0].Id;
        sr[0].Assigned_System_Engineer_2__c = testUser[0].Id;
        
        update sr[0];
        
        Test.stopTest();
        //End- 2.0
    }
}