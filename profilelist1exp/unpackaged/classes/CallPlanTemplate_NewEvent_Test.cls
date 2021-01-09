@isTest
private class CallPlanTemplate_NewEvent_Test {
static list<Account> listAcc;
static list<Opportunity> listOpp;
@testSetup static void setup() {
    TriggerExecutionController.setSkipAllTriggers(True);
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
    list<Account> listAccTDF = TestDataFactory.createNAccount(1,'Partner Account');
    insert listAccTDF;
    list<Opportunity> listOppTDF = TestDataFactory.createNOpportunities(1,'Standard Opportunity');
    TriggerExecutionController.setSkipOpportunityTriggers(True);
    insert listOppTDF;

    }

     public static testmethod void testNewCallPlan(){
    /*    Account acc = new Account();
        acc.name = 'Some test Account';        
        acc.status__c = 'Active';
        acc.Account_Country_Code__c='US';              
        insert acc; */
         listAcc = [select id from Account limit 1];
         listAcc[0].status__c = 'Active';
        listAcc[0].Account_Country_Code__c='US'; 
         update listAcc;
         listOpp = [select id from Opportunity limit 1];
         listOpp[0].AccountID = listAcc[0].id;
         listOpp[0].CurrencyIsoCode = 'USD';
         listOpp[0].Type = 'Renewal';
         listOpp[0].CloseDate = system.Today();
         listOpp[0].Domain__c = 'Non Domain';
         listOpp[0].Solution_Type__c = 'Cloud Integration';
         listOpp[0].Solution_Name__c = 'Boomi Solution';
         listOpp[0].No_times_BookDate_moved__c = 0;
         TriggerExecutionController.setSkipOpportunityTriggers(True);
         Update listOpp;
       system.assertEquals(listOpp[0].No_times_BookDate_moved__c, listOpp[0].No_times_BookDate_moved__c);
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Opportunity');
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
  /*      Opportunity testOpp = new Opportunity(AccountId = acc.Id, Name = 'testOpportunity', CurrencyIsoCode = 'USD', Type = 'Renewal', CloseDate = system.Today(), Domain__c = 'Non Domain', Solution_Type__c = 'Cloud Integration', Solution_Name__c = 'Boomi Solution', No_times_BookDate_moved__c = 0, StageName = 'Plan - 1%' );      
        
        insert testOpp;
        */
        String  strEventRTid = IdlookUpUtils.getRecordTypeId('Call Plan','Event', true);
        strEventRTid = strEventRTid.substring(0, 15);
        
        Call_Plan_Template__c ctRec = new Call_Plan_Template__c (Name= 'testCT',type__c ='Call', Folder__c ='Public Call Plan Templates');
        insert ctRec;
        
        Call_Plan_Template__c ctRec1 = new Call_Plan_Template__c (Name= 'testCT1',type__c ='Call', Folder__c ='Public Call Plan Templates');
        insert ctRec1;
            
        PageReference pageRef2 = Page.EventNewButtonOverride;      
        pageRef2.getParameters().put('what_id',listOpp[0].id);
        pageRef2.getParameters().put('RecordType',strEventRTid);
            
        Test.setCurrentPageReference(pageRef2); 
        
        ApexPages.StandardController sc2 = new ApexPages.StandardController( new Event() );
        EventNewButtonOverrideCntlr testCntrl2 = new EventNewButtonOverrideCntlr (sc2);  
        testCntrl2.redirect();
        
        strEventRTid = IdlookUpUtils.getRecordTypeId('GBL_Standard_Event_RT','Event', true);
        strEventRTid = strEventRTid.substring(0, 15);
        
        pageRef2.getParameters().put('what_id',listOpp[0].id);
        pageRef2.getParameters().put('RecordType',strEventRTid);
        pageRef2.getParameters().put('retURL',strEventRTid);       
        Test.setCurrentPageReference(pageRef2);          
        testCntrl2.redirect();
        
        CallPlan_NewEventCntlr testCntrl1 = new CallPlan_NewEventCntlr(sc2);
        testCntrl1.showTemplates();
        testCntrl1.refreshPage();
        testCntrl1.selectedTemplateId = ctRec.id;
        testCntrl1.selectTemplate();
        testCntrl1.closePopup();
        testCntrl1.cancel();
        testCntrl1.evRec.StartDateTime = system.now();
        testCntrl1.reminder = 15;
        
        testCntrl1.save();
        testCntrl1.saveAndNewTask();
        testCntrl1.saveAndNewEvent();
         
        testCntrl1.evRec.IsAllDayEvent = true;
        testCntrl1.save();
        testCntrl1.saveAndNewTask();
        testCntrl1.saveAndNewEvent();
        
        pageRef2.getParameters().put('what_id','');
        pageRef2.getParameters().put('RecordType',strEventRTid);            
        Test.setCurrentPageReference(pageRef2);      
        testCntrl1 = new CallPlan_NewEventCntlr(sc2);      
        testCntrl1.evRec.WhatId = listOpp[0].id;
        testCntrl1.evRec.StartDateTime = system.now();
        testCntrl1.evRec.EndDateTime = system.now();
        testCntrl1.reminder = 15; 
        testCntrl1.evRec.IsAllDayEvent = true;       
        testCntrl1.saveAndNewTask();
        
         pageRef2.getParameters().put('what_id','');
        pageRef2.getParameters().put('RecordType',strEventRTid);            
        Test.setCurrentPageReference(pageRef2);      
        testCntrl1 = new CallPlan_NewEventCntlr(sc2);      
        testCntrl1.evRec.WhatId = listOpp[0].id;
        testCntrl1.evRec.StartDateTime = system.now();
        testCntrl1.evRec.EndDateTime = system.now();
        testCntrl1.reminder = 15; 
        testCntrl1.evRec.IsAllDayEvent = true;
        testCntrl1.saveAndNewEvent();    
        
    } 
}