@IsTest
public class PQRelationshipsTriggerHandlerBITest {
    public static testmethod void pqRelationshipsTriggerTestBI(){
        
        String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'BeforeInsert' => new List<Boolean>{true, false, true, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Partner_Quoting_Relationships__c", "Class_Name__c": "PQRelationshipsTriggerHandlerBI"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        Id partnerAccaccRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Set<String> setcustomerUserTypes = new Set<String> {'CSPLiteUser', 'PowerPartner', 'PowerCustomerSuccess',   'CustomerSuccess'};
            final List<Profile> partnerProfiles = [select Id,name from Profile where UserType in :setcustomerUserTypes limit 1];
        
        system.debug('*****' +partnerProfiles);
        
        List<Account> listacc= new List<Account>();
        
        Account partnerAccount = new Account(Name='Test Partner Acc', 
                                             RecordTypeId = partnerAccaccRTId, 
                                             Partner_Type__c = 'US Federal',
                                             Partner_Tier__c = 'Tier 2',
                                             Partner_Relationship__c = 'Registered',
                                             Account_Country_Code__c = 'US',
                                             Account_Country__c = 'UNITED STATES'); 
        
        listacc.add(partnerAccount);
        insert listacc;
        
        Partner_Track__c pt = new Partner_Track__c(Services_Competencies__c= '',Partner_Track_Account_Local_Name__c='test12');
        insert pt;

        Partner_Quoting_Relationships__c pQRrecord = new Partner_Quoting_Relationships__c(EMC_Operation__c = 'Creation',
                                                                                          EMC_Integration_Status__c = 'Waiting Sync',
                                                                                          Relationship_Type__c = 'Distributor',
                                                                                          Partner_Track__c = pt.Id,
                                                                                          EMC_Last_Sync_date__c = datetime.newInstance(2014, 9, 15, 12, 30, 0),
                                                                                          Related_Account__c=partnerAccount.id);
        insert pQRrecord;

        try{
            Partner_Quoting_Relationships__c pQRrecord2 = new Partner_Quoting_Relationships__c(EMC_Operation__c = 'Creation',
                                                                                            EMC_Integration_Status__c = 'Waiting Sync',
                                                                                            Relationship_Type__c = 'Distributor',
                                                                                            Partner_Track__c = pt.Id,
                                                                                            EMC_Last_Sync_date__c = datetime.newInstance(2014, 9, 15, 12, 30, 0),
                                                                                            Related_Account__c=partnerAccount.id);
            insert pQRrecord2;
        }catch(Exception ex){
            system.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
        }
        
    }
}