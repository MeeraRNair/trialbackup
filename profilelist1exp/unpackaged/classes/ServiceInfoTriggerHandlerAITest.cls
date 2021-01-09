@IsTest
public class ServiceInfoTriggerHandlerAITest {
    
    private static testMethod void testInsertServiceIfoMethod() 
    {
        String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'AfterInsert' => new List<Boolean>{false, false,true, false,false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Service_Information__c", "Class_Name__c": "ServiceInfoTriggerHandlerAI"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        Id partnerAccaccRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        List<Account> listacc = new List<Account>();
        list<Partner_Track__c> listpartnertrack=new list<Partner_Track__c>();
        
        Account partnerAccount = new Account(Name='Test Partner Acc', 
                                             RecordTypeId = partnerAccaccRTId, 
                                             Partner_Type__c = 'US Federal',
                                             Partner_Tier__c = 'Tier 2',
                                             Partner_Relationship__c = 'Registered',
                                             Account_Country_Code__c = 'US',
                                             Account_Country__c = 'UNITED STATES'); 
        listacc.add(partnerAccount);
        insert listacc;
        
        Partner_Track__c partnertrack=new Partner_Track__c(Partner_Track__c='Cloud Service Provider',
                                                           Enabled_for_Services__c=false
                                                          );
        
        listpartnertrack.add(partnertrack);
        insert listpartnertrack;
        
        
        List<Service_Information__c> listSerInfo = new List<Service_Information__c>(); 
        
        Service_Information__c serInfo = new Service_Information__c(Partner_Track__c=listpartnertrack[0].Id,
                                                                    Velocity_Services__c = 'Yes',
                                                                    Velocity_Services_Managed__c ='no',
                                                                    Velocity_Services_Implement__c ='yes'
                                                                   );
        
        Test.startTest();  
        listSerInfo.add(SerInfo);
        insert listSerInfo ;
        
        Partner_Track__c ptTest=[select id,Enabled_for_Services__c from Partner_Track__c where id =: partnertrack.id];
        system.assertEquals(ptTest.Enabled_for_Services__c,true);
        Test.stopTest();      
    }
    
}