/*====================================================================================================================+
|  HISTORY |                                                                 
|                                                                           
| DATE         Modified              Story           DESCRIPTION                               
| ===========  =========           =========          =========== 
| 06-Dec-2019  Venu K 				  0102			   Implemented TDF
+====================================================================================================================*/

@isTest
public class ChannelProgramFieldDisplayTest{
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
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(2, 'Deal Registration');
        insert listOppTdf;
    }
    Static testmethod void testMethod1(){
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Opportunity> listOpp=[Select id from Opportunity Limit 2];
        Deal_program__c testDealProgram = new Deal_program__c(Deal_Program_Name__c = 'testDealProgram'+System.currentTimeMillis(),
                                                              Benefit_Type__c = 'test', Business_Unit__c = 'test', Active__c = True, Deal_Program_Description__c = 'test Program',
                                                              Start_Date__c = system.today(),End_Date__c=system.today().adddays(10));                                                        
        insert testDealProgram;     
        Product2 prod = new Product2(Name = 'Workstations',ProductCode = 'Workstations', Family = 'Hardware',
                                     Channel_Product_LOB__c = 'NETWORKING', isActive = true ,Product_ID__c = 'P1');
        insert prod;
        Qualified_Program__c qP= new Qualified_Program__c(Deal_program__c = testDealProgram.id, product__c = prod.id, Opportunity__c = listOpp[0].id);
        insert QP;
        system.assertEquals(listOpp[0].id, qP.Opportunity__c);
        PageReference pageRef = Page.ChannelProgramDisplayForPartners;
        Test.setCurrentPageReference(pageRef);        
        ApexPages.Standardcontroller sc= new ApexPages.Standardcontroller(listOpp[0]);
        ApexPages.currentPage().getParameters().put('cid',listOpp[0].id);
        ChannelProgramFieldDisplay aep = new ChannelProgramFieldDisplay(sc);   
        PageReference pageRef1 = Page.ChannelProgramDisplayForPartners;
        Test.setCurrentPageReference(pageRef1);        
        ApexPages.Standardcontroller sc1= new ApexPages.Standardcontroller(listOpp[1]);
        ApexPages.currentPage().getParameters().put('cid',listOpp[1].id);
        ChannelProgramFieldDisplay aep1 = new ChannelProgramFieldDisplay(sc1);   
    }
}