/* 
History:
Version Release         CR #        Date            Modified By     Description     
1.0		0102						04-Dec-2019		Vikas KH		Implemented TDF
*/

@IsTest
public class CaseHistTriggerHandlerAITest {
    @testsetup static void setup() { 
        list<case> listcasefromTDF=TestDataFactory.createNCases(1);
        TriggerExecutionController.setSkipAllTriggers(true);
        insert listcasefromTDF;
    }            
    static testmethod void caseHistInsertTest(){
        String strMockMetaData = '';
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'AfterInsert' => new List<Boolean>{false, false, true, false, false}
        };
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Case_Status_History__c", "Class_Name__c": "CaseHistTriggerHandlerAI"},';
            }
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);       
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'Case_Status_History__c';
        tec.RecursiveCount__c = 2;
        insert tec;
        list<case> listCase=[select id from case];
        for(case c:listCase){
            c.Subject = 'Unit Testing'; 
        }
        update listCase;
        Case_Status_History__c csh = new Case_Status_History__c(Name = 'test1',
                                                                Case__c = listcase[0].Id,
                                                                Case_Id__c = listcase[0].Id,
                                                                Status__c = 'Completed',
                                                                Duration__c  = 8,
                                                                Time_In__c  = Datetime.now(),
                                                                Time_Out__c = Datetime.now());
        Insert csh;
        Case_Status_History__c csh1 = new Case_Status_History__c(Name = 'test2',
                                                                 Case__c = listcase[0].Id,
                                                                 Case_Id__c = listcase[0].Id,
                                                                 Status__c = 'Closed',
                                                                 Duration__c  = 8,
                                                                 Time_In__c  = Datetime.now(),
                                                                 Time_Out__c = Datetime.now());
        Insert csh1;
        system.assertNotEquals(Null, listCase[0].subject);
    }
}