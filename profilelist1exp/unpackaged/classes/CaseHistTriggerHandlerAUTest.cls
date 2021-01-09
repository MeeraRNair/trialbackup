/* 
History:
Version Release         CR #        Date            Modified By     Description     
1.0		0102						04-Dec-2019		Vikas KH		Implemented TDF
*/

@IsTest
public class CaseHistTriggerHandlerAUTest {
    @testsetup static void setup() {  
        list<case> listcasefromTDF=TestDataFactory.createNCases(1);
        TriggerExecutionController.setSkipAllTriggers(true);
        insert listcasefromTDF;
    }    
    static testmethod void caseHistUpdateTest(){
        String strMockMetaData = '';
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'AfterUpdate' => new List<Boolean>{false, true, false, false, false}
        };
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Case_Status_History__c", "Class_Name__c": "CaseHistTriggerHandlerAU"},';
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
        Case_Status_History__c csh1 = [Select Id,Name,Case_Id__c from Case_Status_History__c Where Id = :csh.Id];
        csh1.Name = 'Test';
        csh1.Status__c = 'Assigned';
        update csh1;
        system.assertNotEquals(Null, listCase[0].subject);
    }
}