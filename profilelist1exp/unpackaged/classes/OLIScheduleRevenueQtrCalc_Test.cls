/*
* Revision CR Number   Release No    Date            Modified By     Description
* -------- ---------   ----------    -----------     ------------    -----------
* 1.0                  0202         12-Dec-2019     venu            Implimented TestDataFactory
*/
@isTest
public class OLIScheduleRevenueQtrCalc_Test {
    static Date dcurrQtrStart, dcurrQtrend, dnextQtrStart, dnextQtrend;
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
        FiscalYearSetting();
        TriggerExecutionController.setSkipAllTriggers(true);  
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTdf;
        
        Profile sysAdminProfile = [select id from profile where name like '%System administrator%' Limit 1];
        /*  User testUser = new User(Username='testvaliduser' +'@dell.com',
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
*/
        list<User> listUserTdf=TestDataFactory.createNGenralUsers(1);
        listUserTdf[0].ProfileId=sysAdminProfile.id;
        insert listUserTdf;
        System.runas(listUserTdf[0]){
            //insert opportunity
            /* list<opportunity> oppList = new list<opportunity>();
Id oppRecordTypeId= IdLookupUtils.getRecordTypeId('Standard Opportunity','Opportunity',true);
opportunity oppnew1 = new Opportunity(
name='teset opp SR1', 
CurrencyIsoCode = 'USD', 
accountid = testAcc.Id,
Type = 'Deal/Bid - Direct',
Domain__c = 'Business Solutions',
StageName = 'Plan - 1%',
CloseDate=System.Today());    
oppList.add(oppnew1);

insert oppList;        
*/
            list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
            listOppTdf[0].accountid = listAccTdf[0].Id;
            insert listOppTdf;
            // insert product
            /* list<Product2> prodList = new list<product2>();
for(integer i=1;i<=2;i++){
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
PricebookEntry pbe=new PricebookEntry(Pricebook2Id= pbk1, Product2Id=prodList[i].Id, UnitPrice=150.00, Isactive = true, 
UseStandardPrice=false);
pbeList.add(pbe);
}
insert pbeList;
system.debug('***test harsha*** PricebookEntry '+pbeList);

//insert OpportunityLineItem
list<OpportunityLineItem> lineItemList = new list<OpportunityLineItem>();
for(integer i=0;i<pbeList.size();i++){
OpportunityLineItem  lineItem = new OpportunityLineItem(
Opportunityid =oppnew1.Id,
pricebookEntryId=pbeList[i].id,
Mrgn__c =6,
Discount_off__c = 7,
UnitPrice = 100*(i+1),
Quantity =10,
Description = 'Line Description1');
lineItemList.add(lineItem);
}
insert lineItemList;
*/
            list<OpportunityLineItem> listOppLineItemTdf=TestDataFactory.createNOpportunityLineItem(2);
            listOppLineItemTdf[0].Opportunityid=listOppTdf[0].id;
            listOppLineItemTdf[1].Opportunityid=listOppTdf[0].id;
            insert listOppLineItemTdf;
            //insert OpportunityLineItemSchedule
            list<OpportunityLineItemSchedule>  listlineITemSch = new list<OpportunityLineItemSchedule>();
            for(integer intk=0; intk<listOppLineItemTdf.size(); intk++){
                for(integer inti=1; inti<=10; inti++){
                    OpportunityLineItemSchedule  lineItemSch = new OpportunityLineItemSchedule();
                    lineItemSch.OpportunityLineItemId =listOppLineItemTdf[intk].Id;
                    if(intk==1){
                        lineItemSch.ScheduleDate=System.Today().addmonths(inti+8);
                    }else {
                        lineItemSch.ScheduleDate=System.Today().addmonths(-inti+3);
                    }
                    lineItemSch.Revenue = (listOppLineItemTdf[intk].UnitPrice*listOppLineItemTdf[intk].Quantity)/10;
                    lineItemSch.Type = 'Revenue'; 
                    listlineITemSch.add(lineItemSch);
                }
            }
            insert listlineITemSch;
            TriggerExecutionController.setSkipAllTriggers(false);
        }
    }
    /* static void testDataSetup(){    
TriggerExecutionController.setSkipAllTriggers(true);  

/* Profile sysAdminProfile = [select id from profile where name like '%System administrator%' Limit 1];
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

user testUser=[select id from User Limit 1];
Account testAcc = new Account(name='testaccount');
insert testAcc;

System.runas(testuser){
//insert opportunity
list<opportunity> oppList = new list<opportunity>();
Id oppRecordTypeId= IdLookupUtils.getRecordTypeId('Standard Opportunity','Opportunity',true);
opportunity oppnew1 = new Opportunity(
name='teset opp SR1', 
CurrencyIsoCode = 'USD', 
accountid = testAcc.Id,
Type = 'Deal/Bid - Direct',
Domain__c = 'Business Solutions',
StageName = 'Plan - 1%',
CloseDate=System.Today());    
oppList.add(oppnew1);

insert oppList;        

// insert product
list<Product2> prodList = new list<product2>();
for(integer i=1;i<=2;i++){
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
PricebookEntry pbe=new PricebookEntry(Pricebook2Id= pbk1, Product2Id=prodList[i].Id, UnitPrice=150.00, Isactive = true, 
UseStandardPrice=false);
pbeList.add(pbe);
}
insert pbeList;
system.debug('***test harsha*** PricebookEntry '+pbeList);

//insert OpportunityLineItem
list<OpportunityLineItem> lineItemList = new list<OpportunityLineItem>();
for(integer i=0;i<pbeList.size();i++){
OpportunityLineItem  lineItem = new OpportunityLineItem(
Opportunityid =oppnew1.Id,
pricebookEntryId=pbeList[i].id,
Mrgn__c =6,
Discount_off__c = 7,
UnitPrice = 100*(i+1),
Quantity =10,
Description = 'Line Description1');
lineItemList.add(lineItem);
}
insert lineItemList;

//insert OpportunityLineItemSchedule
list<OpportunityLineItemSchedule>  lineITemSchList = new list<OpportunityLineItemSchedule>();
for(integer k=0; k<lineItemList.size(); k++){
for(integer i=1; i<=10; i++){
OpportunityLineItemSchedule  lineItemSch = new OpportunityLineItemSchedule();
lineItemSch.OpportunityLineItemId =lineItemList[k].Id;
if(k==1){
lineItemSch.ScheduleDate=System.Today().addmonths(i+8);
}else {
lineItemSch.ScheduleDate=System.Today().addmonths(-i+3);
}
lineItemSch.Revenue = (lineItemList[k].UnitPrice*lineItemList[k].Quantity)/10;
lineItemSch.Type = 'Revenue'; 
lineITemSchList.add(lineItemSch);
}
}
insert lineITemSchList;
TriggerExecutionController.setSkipAllTriggers(false);
}
}
*/
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
    
    static void runApexclass(){
        
        TriggerExecutionController.setSkipAllTriggers(true);  
        OLIScheduleRevenueQtrCalc schRevQCal = new OLIScheduleRevenueQtrCalc();
        list<OLIScheduleRevenueQtrCalc.OLIFields> listoliIdMod = new list<OLIScheduleRevenueQtrCalc.OLIFields>();
        list<opportunitylineitem> listoli = [select id, lastmodifiedDate from opportunitylineitem];
        for(opportunitylineitem oli : listoli){
            OLIScheduleRevenueQtrCalc.OLIFields oliIdMod = new OLIScheduleRevenueQtrCalc.OLIFields();
            oliIdMod.oliId = oli.id;
            oliIdMod.lmDate = oli.lastModifiedDate;
            listoliIdMod.add(oliIdMod);
        }
        OLIScheduleRevenueQtrCalc.OLISchedule(listoliIdMod);
        list<OLIScheduleRevenueQtrCalc.OLIFields> listoliIdMod2 = new list<OLIScheduleRevenueQtrCalc.OLIFields>();
        OLIScheduleRevenueQtrCalc.OLIFields oliIdMod2 = new OLIScheduleRevenueQtrCalc.OLIFields();
        oliIdMod2.oliId = listoli[1].id;
        oliIdMod2.lmDate = listoli[1].lastModifiedDate;
        listoliIdMod2.add(oliIdMod2);
        OLIScheduleRevenueQtrCalc.oliSchedule(listoliIdMod2);
        TriggerExecutionController.setSkipAllTriggers(false);  
    }
    static testMethod void currentQtrScheduleRevenueAssertion(){
        runApexclass();
        test.startTest();
        map<string, date> mapQtrs = OLIScheduleRevenueQtrCalcHelper.getFiscalQtrs();
        for(opportunitylineitem  ol : [select id,Scheduled_Current_Qrt_Rev__c,Scheduled_Next_Qrt_Rev__c,opportunityid, 
                                       (select id, revenue, opportunitylineitemid, scheduledate,LastModifiedDate from opportunitylineitemschedules where scheduleDate>=:mapQtrs.get('currQtrStart') and scheduleDate<=:mapQtrs.get('currQtrEnd')) 
                                       from opportunitylineitem]){
                                           Decimal dcTotalRevenue = 0;                                  
                                           for(opportunitylineitemschedule  olis : ol.opportunitylineitemschedules){
                                               dcTotalRevenue+=olis.Revenue;                
                                           }  
                                           system.assertequals(ol.Scheduled_Current_Qrt_Rev__c, dcTotalRevenue, 'Current Quarter Scheule revenue didnot match');
                                       }
        test.stoptest();
    }
    static testMethod void nextQtrScheduleRevenueAssertion(){
        runApexclass();
        test.startTest();
        map<string, date> mapQtrs = OLIScheduleRevenueQtrCalcHelper.getFiscalQtrs();
        for(opportunitylineitem  ol : [select id,Scheduled_Current_Qrt_Rev__c,Scheduled_Next_Qrt_Rev__c,opportunityid, lastModifiedDate,
                                       (select id, revenue, opportunitylineitemid, scheduledate,LastModifiedDate from opportunitylineitemschedules where scheduleDate>=:mapQtrs.get('dnextQtrStart') and scheduleDate<=:mapQtrs.get('dnextQtrEnd')) 
                                       from opportunitylineitem])
        {
            Decimal dcTotalRevenue=0;
            for(opportunitylineitemschedule  olis : ol.opportunitylineitemschedules){
                dcTotalRevenue+=olis.Revenue;                
            }
            system.assertNotequals(ol.Scheduled_Next_Qrt_Rev__c, dcTotalRevenue, 'Next Quarter Schedule revenue didnot match');
        }    
        test.stoptest();
    }
}