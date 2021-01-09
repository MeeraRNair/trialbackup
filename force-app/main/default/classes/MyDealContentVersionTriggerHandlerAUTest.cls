@IsTest
public class MyDealContentVersionTriggerHandlerAUTest {
    static testmethod void contentVersionUpdateTest(){
        String strMockMetaData = '';
        
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'AfterUpdate' => new List<Boolean>{false, true, false, false, false}
        };
            
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "ContentVersion", "Class_Name__c": "MyDealContentVersionTriggerHandlerAU"},';
            }
        
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'ContentVersion';
        tec.RecursiveCount__c = 2;
        insert tec;        
        Test.startTest();
        
        ContentVersion cv = new Contentversion();
        cv.title='ABC';
        cv.PathOnClient ='test';
        //Blob b=Blob.valueOf('Unit Test Attachment Body');
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv;
        
        ContentVersion cv2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        cv2.title = 'test';
        update cv2;
        Test.stopTest();
    }
    
}