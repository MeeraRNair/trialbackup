@Istest
public class DistiVisibilityTriggerHandlerBUTest {
	static testmethod void distiRelationshipUpdateTest(){
        TriggerExecutionController.setSkipAllTriggers(true);
         String strMockMetaData = '';
        
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'BeforeUpdate' => new List<Boolean>{true, true, false, false, false}
        };
            
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Disti_Relationship__c", "Class_Name__c": "DistiVisibilityTriggerHandlerBU"},';
            }
        
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'Disti_Relationship__c';
        tec.RecursiveCount__c = 2;
        insert tec;
        
       Account distiAccount12 = new Account(Name='testOppDistiUser Test Account12', 
                                         Partner_Type__c = 'DISTRIBUTOR (GCC)',
                                          //        Partner_Type__c = 'OEM',
                                            Partner_Tier__c = 'Tier 1',
                                            Status__c = 'Active',
                                            Distribution_Sell_To_Countries__c = 'UNITED STATES',
                                            DMU__c = false,                                         
                                      //      Partner_Relationship__c = 'Authorized',
                                            Account_Country__c = 'UNITED KINGDOM' ) ;       
        insert distiAccount12;

       Partner_Request__c  request = new Partner_Request__c();
      
       /* request.RecordTypeId = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_NEW_PARTNER,
            'Partner_Request__c', true);*/
        request.email__c = 'test@dell.com';
        request.Export_Compliance_Agreed__c = true;
        request.Partner_Terms_Conditions__c = true;
        request.Other_Customers__c = 'test1';
        request.Preferred_Dell_Distribution_Partner__c = 'Test prefer';
        request.Feature_Request_Deal_Registration__c = true;
        request.Sponsoring_Distributor__c = 'testOppDistiUser Test Account12';
        insert request;
        
       Partner_Request__c  request1 = new Partner_Request__c();
      
       /* request1.RecordTypeId = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_NEW_PARTNER,
            'Partner_Request__c', true);*/
        request1.email__c = 'test@dell.com';
        request1.Export_Compliance_Agreed__c = true;
        request1.Partner_Terms_Conditions__c = true;
        request1.Other_Customers__c = 'test2';
        request1.Preferred_Dell_Distribution_Partner__c = 'Test prefer';
        request1.Feature_Request_Deal_Registration__c = true;
        request1.Sponsoring_Distributor__c = 'testOppDistiUser Test Account';
        insert request1;

        List<Account> listAccData = new List<Account>();

        Account resellerAccount = new Account(Name='testOppDistiUser Test Account', 
                                            Partner_Tier__c = 'Tier 1',
                                            Partner_Relationship__c = 'Authorized,Storage',
                                            Account_Country__c = 'UNITED STATES',
                                            Partner_Type__c = 'GLOBAL ALLIANCE',
                                            Status__c = 'Active',
                                            Partner_Registration__c= request.id,
                                            DMU__c = false );
        listAccData.add(resellerAccount); 

        Account resellerAccount1 = new Account(Name='testOppDistiUser Test Account', 
                                            Partner_Tier__c = 'Tier 1',
                                            Partner_Relationship__c = 'Authorized',
                                            Account_Country__c = 'UNITED STATES',
                                            Partner_Type__c = 'GLOBAL ALLIANCE',
                                            Status__c = 'Active',
                                            Partner_Registration__c= request1.id,
                                            DMU__c = false );
        listAccData.add(resellerAccount1);      

        Account distiAccount = new Account(Name='testOppDistiUser Test Account', 
                                         Partner_Type__c = 'DISTRIBUTOR (GCC)',
                                          //        Partner_Type__c = 'OEM',
                                            Partner_Tier__c = 'Tier 1',
                                            Status__c = 'Active',
                                            Distribution_Sell_To_Countries__c = 'UNITED STATES',
                                            DMU__c = false,                                         
                                            Partner_Relationship__c = 'Storage',
                                            Partner_Registration__c= request.id,
                                            Account_Country__c = 'UNITED KINGDOM' ) ;       
        listAccData.add(distiAccount);

        Account distiAccount1 = new Account(Name='testOppDistiUser Test Account', 
                                            Partner_Type__c = 'DISTRIBUTOR (GCC)',
                                            Partner_Tier__c = 'Tier 1',
                                            Status__c = 'Active',
                                            Distribution_Sell_To_Countries__c = 'UNITED STATES',
                                            DMU__c = false,                                         
                                            Partner_Relationship__c = 'Authorized',
                                            Partner_Registration__c= request.id,
                                            Account_Country__c = 'UNITED KINGDOM' ) ;    
        listAccData.add(distiAccount1);
        Database.SaveResult[] listDBSaveResult = Database.insert(listAccData, false);
        TriggerExecutionController.setSkipAllTriggers(false);

        Disti_Relationship__c distiObj1  = new Disti_Relationship__c();
        distiObj1.Disti_Account__c = distiAccount.Id;
        distiObj1.Reseller_Account__c = resellerAccount.Id;
        insert distiObj1; 

        Disti_Relationship__c distiObj2  = new Disti_Relationship__c();
        distiObj2.Disti_Account__c = distiAccount1.Id;
        distiObj2.Reseller_Account__c = resellerAccount1.Id;
        insert distiObj2;

        try{
            Disti_Relationship__c dr1 = [Select Id,Distributor_Account_Name_text__c From Disti_Relationship__c Where Id=:distiObj2.Id];
            dr1.Distributor_Account_Name_text__c = 'Testing!!!!!';
            dr1.Disti_Account__c = distiAccount.Id;
            dr1.Reseller_Account__c =resellerAccount.Id;
            update dr1;
        }catch(DmlException ex){
            system.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
        }
    }
}