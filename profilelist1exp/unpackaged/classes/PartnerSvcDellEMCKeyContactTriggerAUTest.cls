@Istest
public class PartnerSvcDellEMCKeyContactTriggerAUTest {
    static testmethod void dellEMCKeyContactUpdatetest(){
        TriggerExecutionController.setSkipAllTriggers(true);
        
        String strMockMetaData = '';
        
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'AfterUpdate' => new List<Boolean>{false, true, false, false, false}
        };
            
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "DellEMC_Key_Contacts__c", "Class_Name__c": "PartnerSvcDellEMCKeyContactTriggerAU"},';
            }
        
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'DellEMC_Key_Contacts__c';
        tec.RecursiveCount__c = 2;
        insert tec;
        
        Id partnerAccRTyId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Account acc = new Account();
        acc.Name = 'Test acc';
        acc.RecordTypeId = partnerAccRTyId;
      //  acc.OwnerId = portalAccountOwner1.Id;
        insert acc;

        DellEMC_Key_Contacts__c dkc = new DellEMC_Key_Contacts__c();
        dkc.Exception_message__c = 'Testmessage';
        dkc.Partner_Account__c = acc.Id;
        dkc.Action_Performed_By__c = 'Test@dell.com';
        //dkc.DellEMC_Contact_Name__c = user.Id;    
        dkc.EMC_Integration_Status__c  = 'Completed';
        dkc.Role__c = 'Partner Manager';
        dkc.EMC_Operation__c = 'Deletion';
        insert dkc;     
        TriggerExecutionController.setSkipAllTriggers(false);
        
        DellEMC_Key_Contacts__c dkc1 = [Select Id,Exception_message__c from DellEMC_Key_Contacts__c Where Id=:dkc.Id];
        dkc1.Exception_message__c = 'Testing!!!!';
        update dkc1;

        List<DellEMC_Key_Contacts__c> listDKC = [Select Id,Exception_message__c from DellEMC_Key_Contacts__c Where Id=:dkc.Id];
        system.assertEquals(true, listDKC.isEmpty());
    }
}