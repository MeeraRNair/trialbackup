@IsTest
public class MyDealContentDocTriggerHandlerBDTest {
    static testmethod void contentDocumentDeleteTest(){
        String strMockMetaData = '';
        
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'BeforeDelete' => new List<Boolean>{true, false, false, true, false}
        };
            
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "ContentDocument", "Class_Name__c": "MyDealContentDocTriggerHandlerBD"},';
            }
        
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'ContentDocument';
        tec.RecursiveCount__c = 2;
        insert tec;
        
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content Version
        List<ContentVersion> listCV = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        System.assertEquals(listCV.size(), 1);
        
        //Get Content Documents
        List<ContentDocument> listCD = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        System.assertEquals(listCD.size(), 1);
        Delete listCD;
    }
    
}