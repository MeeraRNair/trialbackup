@IsTest
public class OrderSuppEmailMsgTriggerHandlerAITest {
    static testmethod void emailMessageInserTest(){
        String strMockMetaData = '';
        
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'AfterInsert' => new List<Boolean>{false, false, true, false, false}
        };
            
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "EmailMessage", "Class_Name__c": "OrderSuppEmailMessageTriggerHandlerAI"},';
            }
        
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'EmailMessage';
        tec.RecursiveCount__c = 2;
        insert tec;

        Id orderSupportRTId = StaticFactory.getRecordTypeIdByName('Case', 'Order Support');
        
        Case c = new Case();
        c.Subject = 'Om Test';  
        c.Description = 'Unit Testing';
        c.Status ='Open';
        c.Priority = 'Medium';
        c.Origin = 'Email';
        c.RecordTypeId = orderSupportRTId;
        insert c;
        
        EmailMessage email = new EmailMessage();
        email.FromAddress = 'test@abc.org';
        email.Incoming = true;
        email.Status = '0';
        email.ToAddress= 'test@xyz.org';
        email.Subject = 'Test email';
        email.HtmlBody = 'Test email body';
        email.ParentId = c.Id; 
        insert email;

        Case updatedCase = [SELECT new_email_flag__C FROM Case WHERE Id = :c.Id];
        system.assertEquals(true, updatedCase.new_email_flag__C);
    }
}