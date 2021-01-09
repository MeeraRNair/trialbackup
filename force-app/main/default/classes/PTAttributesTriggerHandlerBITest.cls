@IsTest
public class PTAttributesTriggerHandlerBITest {
    public static testmethod void ptaAttributesTriggerTestBI(){
        
        String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'BeforeInsert' => new List<Boolean>{true, false, true, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Partner_Type_Attribute__c", "Class_Name__c": "PTAttributesTriggerHandlerBI"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        Partner_Track__c pt = new Partner_Track__c(Services_Competencies__c= '',Partner_Track_Account_Local_Name__c='test12');
        insert pt;

        Partner_Type_Attribute__c pTARecord1 = new Partner_Type_Attribute__c(EMC_Operation__c = 'Creation',
                                                                       EMC_Integration_Status__c = 'Completed',
                                                                       Partner_Track__c = pt.Id,
                                                                       EMC_Last_Sync_date__c = datetime.newInstance(2014, 9, 15, 12, 30, 0),
                                                                       Partner_Price_List_Type__c='Distributor',Distribution_Channel__c='Distributor');
        insert pTARecord1;

        try{
            Partner_Type_Attribute__c pTARecord2 = new Partner_Type_Attribute__c(EMC_Operation__c = 'Creation',
                                                                        EMC_Integration_Status__c = 'Waiting Sync',
                                                                        Partner_Track__c = pt.Id,
                                                                        EMC_Last_Sync_date__c = datetime.newInstance(2014, 9, 15, 12, 30, 0),
                                                                        Partner_Price_List_Type__c='Distributor',Distribution_Channel__c='Distributor');
            insert pTARecord2;

        }catch(Exception ex){
            system.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
        }
    }
}