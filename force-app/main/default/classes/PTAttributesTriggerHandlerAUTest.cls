@IsTest
public class PTAttributesTriggerHandlerAUTest {
    public static testmethod void ptaAttributesTriggerTestAU(){

        String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'AfterUpdate' => new List<Boolean>{false, true, false, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Partner_Type_Attribute__c", "Class_Name__c": "PTAttributesTriggerHandlerAU"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);

        List<Partner_Type_Attribute__c>  listPTALst = new List<Partner_Type_Attribute__c> ();
        Partner_Type_Attribute__c pTARecord =new Partner_Type_Attribute__c(EMC_Operation__c = 'Creation',
                                                                           EMC_Integration_Status__c = 'Waiting Sync',
                                                                           EMC_Last_Sync_date__c = datetime.newInstance(2014, 9, 15, 12, 30, 0),
                                                                           Partner_Price_List_Type__c='Distributor',Distribution_Channel__c='Distributor');
        listPTALst.add(pTARecord);        
        insert listPTALst;

        List<Partner_Type_Attribute__c>  listPTALstUp = new List<Partner_Type_Attribute__c> ();
        pTARecord.EMC_Operation__c = 'Deletion';
        pTARecord.EMC_Integration_Status__c = 'Completed';
        
        listPTALstUp.add(pTARecord);
        Update listPTALstUp;

        List<Partner_Type_Attribute__c>  listPTALstUpdated = [SELECT Id FROM Partner_Type_Attribute__c WHERE Id = :pTARecord.Id];
        system.assertEquals(true, (listPTALstUpdated == null || listPTALstUpdated.isEmpty()));
    }
}