@IsTest
public class PQRelationshipsTriggerHandlerAUTest {
    public static testmethod void pqRelationshipsTriggerTestAU(){

        String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'AfterUpdate' => new List<Boolean>{false, true, false, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Partner_Quoting_Relationships__c", "Class_Name__c": "PQRelationshipsTriggerHandlerAU"},';
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
        List<Partner_Quoting_Relationships__c> listPQRlst = new List<Partner_Quoting_Relationships__c>();
        Partner_Quoting_Relationships__c pQRrecord = new Partner_Quoting_Relationships__c(EMC_Operation__c = 'Creation',
                                                                                          EMC_Integration_Status__c = 'Waiting Sync',
                                                                                          Relationship_Type__c = 'Distributor',
                                                                                          EMC_Last_Sync_date__c = datetime.newInstance(2014, 9, 15, 12, 30, 0),
                                                                                          Related_Account__c=partnerAccount.id);
        listPQRlst.add(pQRrecord);
        insert listPQRlst;
        
        pQRrecord.EMC_Operation__c = 'Deletion';
        pQRrecord.EMC_Integration_Status__c = 'Completed';
        update pQRrecord;

        List<Partner_Quoting_Relationships__c> listDel = [SELECT Id FROM Partner_Quoting_Relationships__c WHERE Id = :pQRrecord.Id];
        system.assertEquals(true, (listDel == null || listDel.isEmpty()));
       
    }
}