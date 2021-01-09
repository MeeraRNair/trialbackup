/************************************************************************
Name: OpportunityLineItemRevenueSchedule_Test 
Author: Micky Toms
History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
*1.0     27-Jan-2015     Micky            Created for CR10616
*2.0     22-Apr-2015    Krishnamoorthi    Updated for CR11402
*3.0     27-Jul-2015    Krishnamoorthi    Updated for CR11748        
*4.0     08-Jan-2019     Meenu             FY20-DCE-0202 16970 Field Trip clean up for Opportunity (Remove/Comment deltekoppid__c field)
*5.0     29-Nov-2019     Monisha           FY20-DEC-1201-101 soql issue
************************************************************************/
@isTest
private class OpportunityLineItemRevenueSchedule_Test{
    static list<Account> listAcc;
    static list<Opportunity> listOpp;
    static list<OpportunityLineItem> listOppLineItem;
    @testSetup static void setup() {
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
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTdf;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        listOppTdf[0].AccountId=listAccTdf[0].id;
        insert listOppTdf;
        list<OpportunityLineItem> listOppLineItemTdf=TestDataFactory.createNOpportunityLineItem(2);
        listOppLineItemTdf[0].OpportunityID=listOppTdf[0].id;
        listOppLineItemTdf[1].OpportunityID=listOppTdf[0].id;
        insert listOppLineItemTdf;
    }
     //5.0 Declaring the string variable to pass only the triggers that should be excuted on after update and insert.
    public static String strMockMetaData = '';
    static testMethod void testInsertOppwithLineItemandLineItemSchedulewithContractTermBlankandUpdate() {
    //5.0 Execute only the triggers that should be excuted on after update and insert of Opportunity and OLI.
  
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
               'AfterUpdate' => new List<Boolean>{false, true, false, false, false},
               'AfterInsert' => new List<Boolean>{false, false, true, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
                if(strEvent=='AfterUpdate'){
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Opportunity", "Class_Name__c": "OpportunityTriggerHandlerAU"},'
                    + '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "OpportunityLineItemTriggerHandlerAU"},'; 
           }
           if(strEvent=='AfterInsert'){
               strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "OpportunityLineItemTriggerHandlerAI"},'; 
           } 
           }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';  
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        //5.0 ENDS
        ProcessFlowTriggerController.isTest = true;
        TriggerExecutionController.setSkipAllTriggers(true);
        Test.startTest();
        listOpp=[SELECT ID FROM Opportunity lIMIT 1];
        listOpp[0].StageName='Plan - 1%';
        listOpp[0].Partner_Opportunity_Stage__c='Plan - 1%';
        listOpp[0].CloseDate = System.Today();
        update listOpp;
        User sysadmin = [select id,name from User where profileId='00e30000000nJ6K' and isActive=true limit 1];
        System.runAs(sysadmin){
            listOpp[0].Cloned_Parent_Id__c='0063B000002yf7U';
            listOpp[0].Oppty_Self_Id__c='0063B000002yf7U';
            update listOpp;
        }
        Map<Id,OpportunityLineItem> mapLineItem1 = new Map<Id,OpportunityLineItem>();
        Map<Id,OpportunityLineItem> mapLineItem2 = new Map<Id,OpportunityLineItem>();
        listOppLineItem=[SELECT ID FROM OpportunityLineItem where Quantity != null LIMIT 2];
        listOppLineItem[0].Quantity=3;
        listOppLineItem[0].UnitPrice=10;
        listOppLineItem[1].Quantity=3;
        listOppLineItem[1].UnitPrice=10;
        update listOppLineItem;
        OpportunityLineItemSchedule  testLineItemSch = new OpportunityLineItemSchedule(OpportunityLineItemId =listOppLineItem[0].Id,
                                                                                       ScheduleDate=System.Today().addmonths(1),
                                                                                       Revenue = 100,
                                                                                       Type = 'Revenue'
                                                                                      ); 
        OpportunityLineItemSchedule  testLineItemSchSec = new OpportunityLineItemSchedule(OpportunityLineItemId =listOppLineItem[1].Id,
                                                                                          ScheduleDate=System.Today().addmonths(2),
                                                                                          Revenue = 1000,
                                                                                          Type = 'Revenue'
                                                                                         );
        insert testLineItemSch;
        insert testLineItemSchSec;
        listOpp[0].Contract_Term__c=5;
        update listOpp;
        List<OpportunityLineItemSchedule> listOppLineItemSch = [SELECT id, Revenue , OpportunityLineItemID,Type, ScheduleDate
                                                                FROM OpportunityLineItemSchedule
                                                                WHERE OpportunityLineItemID = :listOppLineItem[0].Id];
        for(OpportunityLineItemSchedule opplnitmsch:listOppLineItemSch){
            Date dcloseddate=listOpp[0].CloseDate.addMonths(1);
        }
        mapLineItem2.put(listOppLineItem[0].id,listOppLineItem[0]);
        OpportunityLineItemRevenueSchedule.updateOpportunityLineItemSchedule(mapLineItem2,mapLineItem2);
        system.assertEquals(listOppLineItemSch[0].OpportunityLineItemID, listOppLineItem[0].id);
        Test.stopTest();
    }
    static testMethod void testRevenueScheduleForSTDOpp() { 
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipAccountTriggers(true); 
        ProcessFlowTriggerController.isTest = true;
        Test.startTest();
        listOpp=[SELECT ID FROM Opportunity lIMIT 1];
        listOpp[0].StageName='Plan - 1%';
        listOpp[0].Partner_Opportunity_Stage__c='Plan - 1%';
        listOpp[0].Contract_Term__c=15;
        listOpp[0].CloseDate = System.Today() + 10;
        update listOpp;
        User sysadmin = [select id,name from User where profileId='00e30000000nJ6K' and isActive=true limit 1];
        System.runAs(sysadmin){
            listOpp[0].Cloned_Parent_Id__c='0063B000002yf7U';
            listOpp[0].Oppty_Self_Id__c='0063B000002yf7U';
            update listOpp[0];
        }
        Map<Id, Opportunity> mapOldOpp = new Map<Id, Opportunity>();
        mapOldOpp.put(listOpp[0].Id, listOpp[0]);
        listOppLineItem=[SELECT ID,opportunityID FROM OpportunityLineItem LIMIT 1];
        Map<Id, Opportunity> mapNewOpp = new Map<Id, Opportunity>();
        Map<Id, OpportunityLineItem> mapNewOppltm = new Map<Id, OpportunityLineItem>();
        Opportunity testOpp2 = [SELECT Id, Contract_Term__c, CloseDate,(select id,opportunityID,TotalPrice from OpportunityLineItems) FROM Opportunity WHERE Id =: listOpp[0].Id];
        testOpp2.CloseDate = System.Today() + 15;
        testOpp2.Contract_Term__c = 7;
        update testOpp2;
        mapNewOpp.put(testOpp2.Id, testOpp2);
        mapNewOppltm.put(testOpp2.OpportunityLineItems[0].id, testOpp2.OpportunityLineItems[0]);
        OpportunityLineItemRevenueSchedule.populateRevenuSchedules(mapNewOpp.values(), mapOldOpp, mapNewOpp);   
        OpportunityLineItemRevenueSchedule.populateOpportunityLineItemSchedule(mapNewOppltm);
        system.assertEquals(testOpp2.ID, listOpp[0].Id);
        Test.stopTest();
    }
    static testMethod void testRevenueScheduleForNonSTDOpp() {
        TriggerExecutionController.setSkipAllTriggers(true); 
        //5.0 Execute only the triggers that should be excuted on after update and insert of Opportunity and OLI.
     Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
               'AfterUpdate' => new List<Boolean>{false, true, false, false, false},
               'AfterInsert' => new List<Boolean>{false, false, true, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
                if(strEvent=='AfterUpdate'){
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Opportunity", "Class_Name__c": "OpportunityTriggerHandlerAU"},'
                    + '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "OpportunityLineItemTriggerHandlerAU"},'; 
           }
           if(strEvent=='AfterInsert'){
               strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "OpportunityLineItemTriggerHandlerAI"},'; 
           } 
           }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';  
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
    //5.0 ENDS
    	Test.startTest();
        ProcessFlowTriggerController.isTest = true;
        listOpp=[SELECT ID FROM Opportunity lIMIT 1];
        listOpp[0].RecordTypeId=TestDataFactory.getRecordTypeIdbyName('SMB Opportunity', 'Opportunity');
        listOpp[0].StageName='Plan - 1%';
        listOpp[0].Partner_Opportunity_Stage__c='Plan - 1%';
        listOpp[0].Contract_Term__c=5;
        listOpp[0].CloseDate = System.Today() + 10;
        User sysadmin = [select id,name from User where profileId='00e30000000nJ6K' and isActive=true limit 1];
       // listOpp[0].Cloned_Parent_Id__c='0063B000002yf7U';
       // listOpp[0].Oppty_Self_Id__c='0063B000002yf7U';
        update listOpp;
        Map<Id, Opportunity> mapOldOpp = new Map<Id, Opportunity>();
        mapOldOpp.put(listOpp[0].Id, listOpp[0]);
        listOppLineItem=[SELECT ID,opportunityID FROM OpportunityLineItem LIMIT 1];
        Map<Id, Opportunity> mapNewOpp = new Map<Id, Opportunity>();
        Opportunity testOpp2 = [SELECT Id, Contract_Term__c, CloseDate FROM Opportunity WHERE Id =: listOpp[0].Id];
        testOpp2.CloseDate = System.Today() + 15;
        testOpp2.Contract_Term__c = 7;
        mapNewOpp.put(testOpp2.Id, testOpp2);
        OpportunityLineItemRevenueSchedule.populateRevenuSchedules(mapNewOpp.values(), mapOldOpp, mapNewOpp);   
        system.assertEquals(testOpp2.ID, listOpp[0].Id);
        Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false); 
    }   
}