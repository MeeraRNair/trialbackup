@isTest
private class CallPlanTemplateTest{

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
    }
     public static testmethod void testNewCallPlan(){
        Account acc = new Account();
        acc.name = 'Some test Account';        
        acc.status__c = 'Active';
        acc.Account_Country_Code__c='US';              
        insert acc;
       
        Opportunity testOpp = new Opportunity(AccountId = acc.Id, Name = 'testOpportunity', CurrencyIsoCode = 'USD', Type = 'Renewal', CloseDate = system.Today(), Domain__c = 'Non Domain', Solution_Type__c = 'Cloud Integration', Solution_Name__c = 'Boomi Solution', No_times_BookDate_moved__c = 0, StageName = 'Plan - 1%' );      
        
        insert testOpp;
        
        Event evRec = new Event(RecordTypeId = '012A0000000Vhzj', whatId= testOpp.id,
                                Subject = 'test', OwnerId = UserInfo.getUserId() ,
                                StartDateTime = system.Now(), EndDateTime = system.Now());
        insert evRec;
        
        Call_Plan_Template__c ctRec = new Call_Plan_Template__c (Name= 'testCT',type__c ='Call', Folder__c ='Public Call Plan Templates');
        insert ctRec;
        
        Call_Plan_Template__c ctRec1 = new Call_Plan_Template__c (Name= 'testCT',type__c ='Call', Folder__c ='My Personal Call Plan Templates');
        insert ctRec1;
        
        Call_Plan_Template__c ctRec2 = new Call_Plan_Template__c (Name= 'testCT1',type__c ='Call', Folder__c ='My Personal Call Plan Templates');
        insert ctRec2;
        
        
        List<Call_Plan_Template__c>  ctList = new List<Call_Plan_Template__c>();
        ctList.add(new Call_Plan_Template__c (Name= 'testCT',type__c ='Call', Folder__c ='My Personal Call Plan Templates'));
        ctList.add(new Call_Plan_Template__c (Name= 'testCT',type__c ='Call', Folder__c ='My Personal Call Plan Templates'));
        ctList.add(new Call_Plan_Template__c (Name= 'testCT1',type__c ='Call', Folder__c ='My Personal Call Plan Templates'));
        try{
            insert ctList;
        }
        catch(exception ex){
        }
       
        
        PageReference pageRef = Page.CallPlanTemplate_AutopopulateName;      
        pageRef.getParameters().put('id',ctRec.id);
        Test.setCurrentPageReference(pageRef);         
        ApexPages.StandardController sc = new ApexPages.StandardController(ctRec );
        CallPlanTemplate_AutopopulateNameCntlr testCntrl = new CallPlanTemplate_AutopopulateNameCntlr (sc);  
        
        PageReference pageRef1 = Page.CallPlanTemplate_Edit;      
        pageRef1.getParameters().put('eventId',evRec.id);
        pageRef1.getParameters().put('action','New');        
        Test.setCurrentPageReference(pageRef1); 
        
        ApexPages.StandardController sc1 = new ApexPages.StandardController(ctRec );
        CallPlanTemplate_EditCntlr testCntrl1 = new CallPlanTemplate_EditCntlr(sc1);  
        testCntrl1.save();
        testCntrl1.SaveAndNew();
        testCntrl1.cancel();
        
        PageReference pageRef2 = Page.CallPlanTemplate_Edit;      
        pageRef2.getParameters().put('eventId',evRec.id);
        pageRef2.getParameters().put('templateId',ctRec.id);        
        Test.setCurrentPageReference(pageRef2); 
        
        ApexPages.StandardController sc2 = new ApexPages.StandardController(ctRec );
        CallPlanTemplate_EditCntlr testCntrl2 = new CallPlanTemplate_EditCntlr(sc2);  
      
    } 
}