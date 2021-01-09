@isTest
public class PartnerOnboardingPTRUtility_Test {
    
    @isTest static void createAccountShare() {
        
        Test.enableChangeDataCapture();
        
        String strMockMetaData = '';
        
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'AfterInsert' => new List<Boolean>{false, false, true, false, false}
        };
            
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Partner_Track_Relationship__ChangeEvent", "Class_Name__c": "PartnerOnboardingPTRChangeEventTriggerAI"},';
            }
        
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
     
        List<Partner_Track_Relationship__c> listPTR = new List<Partner_Track_Relationship__c>();
        
        Partner_Track_Relationship__c pr=new Partner_Track_Relationship__c();
        pr.Master_Group_AffinityId__c = '1234898';//listAcc[0].Master_Group_Affinity_ID__c;
        pr.Sales_Motion_Account_AffinityId__c= '2345879'; //listAcc[1].Account_ID__c;
        pr.Partner_Track_AffinityId__c='87654098';//testPartnerTrackObj.partner_Track_affinityId__c;
        pr.PTR_AffinityId__c = '1212';
        pr.Is_Processed__c = true;
        listPTR.add(pr);
        
        Partner_Track_Relationship__c pr2=new Partner_Track_Relationship__c();
        pr2.Master_Group_AffinityId__c = '32457';
        pr2.Sales_Motion_Account_AffinityId__c='3245678';
        pr2.Partner_Track_AffinityId__c='41235';
        pr2.PTR_AffinityId__c = '1313';
        pr2.Is_Processed__c = false;
        listPTR.add(pr2);
        
        Partner_Track_Relationship__c pr3=new Partner_Track_Relationship__c();
        pr3.Master_Group_AffinityId__c = '54236';
        pr3.Sales_Motion_Account_AffinityId__c='76538';
        pr3.Partner_Track_AffinityId__c= '7634523';
        pr3.PTR_AffinityId__c = '1414';
        pr3.Is_Processed__c = true;
        pr3.Relationship_Status__c = true;
        listPTR.add(pr3);
        
        test.startTest();
        insert listPTR;
        System.assertEquals(3, listPTR.size());
        System.debug('listPTR:'+listPTR);
        Test.getEventBus().deliver();
        /*   Partner_Track_Relationship__c pr4=new Partner_Track_Relationship__c();
pr4.Master_Group_AffinityId__c = listAcc[0].Master_Group_Affinity_ID__c;
pr4.Sales_Motion_Account_AffinityId__c=listAcc[4].Account_ID__c;
pr4.Partner_Track_AffinityId__c=testPartnerTrackObj2.partner_Track_affinityId__c;
pr4.PTR_AffinityId__c = '1424';
pr4.Is_Processed__c = true;
TriggerExecutionController.setSkipAllTriggers(true);
insert pr4;




Test.getEventBus().deliver();
listPTR[1].Partner_Track_AffinityId__c =testPartnerTrackObj.partner_Track_affinityId__c; 
update listPTR;
*/
        listPTR[0].Partner_Track_AffinityId__c ='765890'; 
        listPTR[1].Is_Processed__c = true;
        listPTR[2].Relationship_Status__c = false;
        update listPTR;
        test.stopTest();
        
        
        
        
    }
    
}