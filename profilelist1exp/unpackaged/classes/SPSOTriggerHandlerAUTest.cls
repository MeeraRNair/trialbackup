@IsTest
public class SPSOTriggerHandlerAUTest {
    public static testmethod void testSPSOUpdate(){
        String strMockMetaData = '';
        
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'AfterUpdate' => new List<Boolean>{false, true, false, false, false}
        };
            
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Partner_Service_Enabled_Product__c", "Class_Name__c": "SPSOTriggerHandlerAU"},';
            }
        
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        List<Partner_Service_Enabled_Product__c> listSPSOInfoLst = new List<Partner_Service_Enabled_Product__c>(); 
        
        Partner_Service_Enabled_Product__c sPSORecd = new Partner_Service_Enabled_Product__c(EMC_Operation__c = 'Creation',
                                                                                             EMC_Integration_Status__c = 'Waiting Sync',
                                                                                             EMC_Last_Sync_date__c = datetime.newInstance(2014, 9, 15, 12, 30, 0),
                                                                                             Service_Enabled_Key__c = 'Test',
                                                                                             Service_Level__c = 'HW L1 L2 L3 MON B/F PART-DEL RTF 4HR',
                                                                                             Service_Enabled_Product__c = 'AppSync-SW');
        
        
        
        listSPSOInfoLst.add(sPSORecd);
        insert listSPSOInfoLst;
        
        Partner_Service_Enabled_Product__c spso1 = [Select Id,Service_Enabled_Key__c,EMC_Integration_Status__c From Partner_Service_Enabled_Product__c Where Id = :sPSORecd.Id];
        spso1.EMC_Operation__c = 'Deletion';
        spso1.EMC_Integration_Status__c = 'Completed';       
        update spso1;

        List<Partner_Service_Enabled_Product__c> listDel = [SELECT Id FROM Partner_Service_Enabled_Product__c WHERE Id = :sPSORecd.Id];
        system.assertEquals(true, (listDel == null || listDel.isEmpty()));
    }
}