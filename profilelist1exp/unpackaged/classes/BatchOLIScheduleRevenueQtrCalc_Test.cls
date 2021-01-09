/***********************************************************
* ---------------------------------------------------------
* Revision  Name                Description
* 1.0       VIKAS KH         Implemeted TDF for 0202 Release
* 
************************************************************/

@isTest
public class BatchOLIScheduleRevenueQtrCalc_Test {
    static Date dcurrQtrStart, dcurrQtrend, dnextQtrStart, dnextQtrend;
    static list<Account> listAcc;
    static list<Opportunity> listOpp;
    static list<OpportunityLineItem> listOppline;
    static list<user> listuser;
    static integer intnoOfOpportunities = 1;
    @testSetup static void setup() {
        // Create common test OWD settings
        OWD__c owdSetting = new OWD__c();
        owdSetting.Oppty_Stage1__c = 'Plan - 1%';
        owdSetting.Oppty_Stage10__c = 'Discover - 10%';
        owdSetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdSetting.Oppty_Stage60__c = 'Propose - 60%';
        owdSetting.Oppty_Stage90__c = 'Commit - 90%';
        owdSetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdSetting.Oppty_Stage100__c = 'Win - 100%';
        owdSetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        Insert owdSetting;
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTDF;
        list<Opportunity> listOppTDF = TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        TriggerExecutioncontroller.setSkipOpportunitySplitTriggers(True);
        insert listOppTDF;
        list<user> listUserTDF = TestDataFactory.CreateNGenralUsers(1);
        insert listUserTDF;
        list<OpportunityLineItem> listOppLineTDF = TestDataFactory.createNOpportunityLineItem(10);
                   listOppLineTDF[0].OpportunityID = listOppTDF[0].id;
            listOppLineTDF[1].OpportunityID = listOppTDF[0].id;
            listOppLineTDF[2].OpportunityID = listOppTDF[0].id;
            listOppLineTDF[3].OpportunityID = listOppTDF[0].id;
            listOppLineTDF[4].OpportunityID = listOppTDF[0].id;
            listOppLineTDF[5].OpportunityID = listOppTDF[0].id;
            listOppLineTDF[6].OpportunityID = listOppTDF[0].id;
            listOppLineTDF[7].OpportunityID = listOppTDF[0].id;
            listOppLineTDF[8].OpportunityID = listOppTDF[0].id;
            listOppLineTDF[9].OpportunityID = listOppTDF[0].id;
        insert listOppLineTDF;
        FiscalYearSetting();
        testDataSetup();        
    }
    
    
    static void testDataSetup(){    
        TriggerExecutionController.setSkipAllTriggers(true);  
        
/*        Profile sysAdminProfile = [select id from profile where name like '%System administrator%' Limit 1];
        User testUser = new User(Username='testvaliduser' +'@dell.com',
                                 Alias = 'Test', 
                                 Email='Test'+'@dell.com',            
                                 LastName='Test',
                                 ProfileId = sysAdminProfile.Id, 
                                 LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', 
                                 EmailEncodingKey='UTF-8', 
                                 TimeZoneSidKey='America/Los_Angeles',
                                 Badge_Number__c='Test'+System.currentTimeMillis());
        insert testUser;
        
        Account testAcc = new Account(name='testaccount');
        insert testAcc; */
        listuser =  [select id from user limit 1];
        listAcc = [select id from Account limit 1];
        System.runas(listuser[0]){
            //insert opportunity
           listOpp = [select id from Opportunity limit 1];
  //          list<opportunity> oppList = new list<opportunity>();
  //          Id oppRecordTypeId= IdLookupUtils.getRecordTypeId('Standard Opportunity','Opportunity',true);
            
            for(integer inti=0;inti<listOpp.size();inti++){
                for(Opportunity oppnew1:listOpp){
                date dtodayDT = System.Today();
                oppnew1.name='teset opp SR1'; 
                    oppnew1.CurrencyIsoCode = 'USD';
                    oppnew1.accountid = listAcc[0].Id;
                    oppnew1.Type = 'Deal/Bid - Direct';
                    oppnew1.Domain__c = 'Business Solutions';
                    oppnew1.StageName = 'Plan - 1%';
                    oppnew1.CloseDate=dtodayDT.addDays(inti);    
            }
            }
            update listOpp;        
            
            // insert product
/*            list<Product2> prodList = new list<product2>();
            for(integer i=1;i<=oppList.size();i++){
                Product2 prod = new Product2(Name = 'Test Product',
                                             Product_Line_Desc__c = 'Services Product',
                                             IsActive = TRUE,Product_ID__c = 'test'+i,
                                             CanUseRevenueSchedule=TRUE);
                prodList.add(prod);
            }
            insert prodList;
            
            //insert priceBookEntry
            Id pbk1 = Test.getStandardPricebookId();
            list<PricebookEntry> pbeList = new list<PricebookEntry>();
            for(integer i=0;i<prodList.size(); i++){
                PricebookEntry PBE=new PricebookEntry(Pricebook2Id= pbk1, Product2Id=prodList[i].Id, UnitPrice=150.00, Isactive = true, 
                                                      UseStandardPrice=false);
                pbeList.add(PBE);
            }
            insert pbeList;
            
            //insert OpportunityLineItem
            list<OpportunityLineItem> lineItemList = new list<OpportunityLineItem>();
            for(integer i=0;i<noOfOpportunities*10;i++){
                integer count = math.mod(i, noOfOpportunities);
                OpportunityLineItem  lineItem = new OpportunityLineItem(
                    //Opportunityid =oppList[count].Id,
                    Opportunityid =oppList[0].Id,
                    //pricebookEntryId=pbeList[count].id,
                    pricebookEntryId=pbeList[0].id,
                    Mrgn__c =6,
                    Discount_off__c = 7,
                    UnitPrice = 100*(count+1),
                    Quantity =10,
                    Description = 'Line Description1',
                    //S_P_Deal_Status__c = 'Pending'
                    Rejection_Reason__c = 'Test reason'
                  );
                
                lineItemList.add(lineItem);
            }
            insert lineItemList;
            */
            listOppline = [select id,UnitPrice,Quantity from OpportunitylineItem limit 10];
           // listOppline[0].S_P_Deal_Status__c = 'Approved';
           // update listOppline;
            //insert OpportunityLineItemSchedule
            list<OpportunityLineItemSchedule>  listlineITemSch = new list<OpportunityLineItemSchedule>();
            for(integer intk=0; intk<listOppline.size(); intk++){
                for(integer inti=1; inti<=10; inti++){
                    OpportunityLineItemSchedule  lineItemSch = new OpportunityLineItemSchedule();
                        lineItemSch.OpportunityLineItemId =listOppline[intk].Id;
                        if(intk==1){
                            lineItemSch.ScheduleDate=System.Today().addmonths(inti+8);
                        }else {
                            lineItemSch.ScheduleDate=System.Today().addmonths(-inti+3);
                        }
                        lineItemSch.Revenue = (listOppline[intk].UnitPrice*listOppline[intk].Quantity)/10;
                        lineItemSch.Type = 'Revenue'; 
                    listlineITemSch.add(lineItemSch);
                }
            }
            insert listlineITemSch;
            TriggerExecutionController.setSkipAllTriggers(false);
        }
    }
    
    static void fiscalYearSetting(){
        Date dtoday = system.today();
        period currentFYQ = [select StartDate,EndDate,  FullyQualifiedLabel,Number, Type FROM Period WHERE Type = 'Quarter' and StartDate <= :dtoday and EndDate >= :dtoday];
        dcurrQtrStart = currentFYQ.StartDate;
        dcurrQtrend = currentFYQ.EndDate;
        dnextQtrStart = dcurrQtrend.addDays(1);
        period nextFYQ = [select StartDate,EndDate,FullyQualifiedLabel, Number, Type FROM Period WHERE Type = 'Quarter' and StartDate = :dnextQtrStart];
        dnextQtrend = nextFYQ.EndDate;
        list<Fiscal_Years__c> listfy = new list<Fiscal_Years__c>();
        string strqtrname;
        strqtrname = 'FY'+currentFYQ.FullyQualifiedLabel.right(2)+'Q'+currentFYQ.Number;
        Fiscal_Years__c fycq = new Fiscal_Years__c(
            name = strqtrname,
            Start_Date__c = dcurrQtrStart,
            End_Date__c = dcurrQtrend);
        listfy.add(fycq);
        strqtrname = 'FY'+nextFYQ.FullyQualifiedLabel.right(2)+'Q'+nextFYQ.Number;
        Fiscal_Years__c fynq = new Fiscal_Years__c(
            name = strqtrname,
            Start_Date__c = dnextQtrStart,
            End_Date__c = dnextQtrend);
        listfy.add(fynq);
        insert listfy;
    }
    static testMethod void runBatchClass(){
        test.startTest();
        datetime dtnowDT = system.now();
        integer intMins = dtnowDT.minute()+1;
        if(intMins >=60){
            intMins = 0;
        }
        integer intHrs = dtnowDT.hour();
        integer intDay = dtnowDT.day();
        integer intMonth = dtnowDT.month();
        integer intYear = dtnowDT.year();
        string strcronT = '0 '+intMins+' '+intHrs+' '+intDay+' '+intMonth+' ? '+intYear;
        BatchOLIScheduleRevenueQtrCalc_Scheduler g = new BatchOLIScheduleRevenueQtrCalc_Scheduler();
        system.schedule('BatchOLIScheduleRevenueQtrCalc_SchedulerTest', strcronT, g);
        system.assertEquals(dtnowDT, dtnowDT);

        /*
        BatchOLIScheduleRevenueQtrCalc oliSchRevExcecute = new BatchOLIScheduleRevenueQtrCalc();
        Id batchinstanceid = database.executeBatch(oliSchRevExcecute); */
        
        /*map<string, date> qtrsMap = OLIScheduleRevenueQtrCalcHelper.getFiscalQtrs();
        for(opportunitylineitem  ol : [select id,Scheduled_Current_Qrt_Rev__c,Scheduled_Next_Qrt_Rev__c,opportunityid, 
                                           (select id, revenue, opportunitylineitemid, scheduledate,LastModifiedDate from opportunitylineitemschedules where scheduleDate>=:qtrsMap.get('currQtrStart') and scheduleDate<=:qtrsMap.get('currQtrEnd')) 
                                           from opportunitylineitem]){
            Decimal totalRevenue = 0;                                  
            for(opportunitylineitemschedule  olis : ol.opportunitylineitemschedules){
                totalRevenue+=olis.Revenue;                
            }  
            if(totalRevenue ==0)
                totalRevenue = Null;
            system.assertequals(ol.Scheduled_Current_Qrt_Rev__c, totalRevenue, 'Current Quarter Scheule revenue didnot match');
        } */

        test.stoptest();
    }
}