@IsTest
public class AttachmentTriggerHandlerAITest {
    static testmethod void attachmentInsertTest(){
        String strMockMetaData = '';
        
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'AfterInsert' => new List<Boolean>{false, false, true, false, false}
        };
            
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Attachment", "Class_Name__c": "AttachmentTriggerHandlerAI"},'; 
            }
        
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'Attachment';
        tec.RecursiveCount__c = 1;
        insert tec;
        
        Test.startTest();
        Account acc = new Account(Name = 'Testacc');
        insert acc;
        
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.Email = 'test@test.com';
        con.phone = '6739';
        con.LastName = 'conLastName';
        con.FirstName = 'conFirstName';
        con.Status__c = 'Customer';
        con.Email_Opt_In__c = 'yes';
        con.Survey__c = 'yes';
        insert con;
        
        Case c = new Case();
        c.Status = 'Open';
       // c.AccountId = acc.Id;
        c.ContactId = con.id;
        c.Description = 'Unit Testing';
        c.Subject = 'Unit Testing';
        insert c;
        
        Blob blbA = Blob.valueOf('test data');
        Attachment attachment = new Attachment(); 
        attachment.Name = 'Test Attachment for Parent'; 
        attachment.Body = blbA;   
        attachment.ParentId = c.Id;
        insert(attachment);
        Test.stopTest();

        FeedItem fi = [SELECT ParentId FROM FeedItem WHERE ParentId = :attachment.ParentId];
        System.assert((fi != null));
    }
}