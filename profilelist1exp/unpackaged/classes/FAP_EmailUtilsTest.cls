@IsTest
private class FAP_EmailUtilsTest {
    
    static testMethod void testsendEmailtest() {
        List<String> strrecepients=new String[]{'test@test.com','test2@test.com'};
            FAP_EmailUtils.sendTextEmail(strrecepients,'Test method', 'This is to test the sendTextNotificationEmail method');
        FAP_EmailUtils.sendHTMLEmail(strrecepients,'Test method', 'This is to test the sendTextNotificationEmail method');
        System.assertNotEquals(Null, strrecepients);
    } 
    
    static testMethod void testsendEmailNoReceipientstest() {
        List<String> strrecepients=null;
        System.assertEquals(Null, strrecepients);
        FAP_EmailUtils.sendTextEmail(strrecepients,'Test method', 'This is to test the sendTextNotificationEmail method');
        
        strrecepients=new List<String>();
        FAP_EmailUtils.sendHTMLEmail(strrecepients,'Test method', 'This is to test the sendTextNotificationEmail method');
    }
    
    static testMethod void testsendEmailWithAttachmenttest() {
        List<String> strrecepients=new String[]{'test@test.com','test2@test.com'};
            System.assertNotEquals(Null, strrecepients);
        List<Attachment> liststdAttachments = new List<Attachment>();
        Attachment a = new Attachment();
        a.Name = 'Test';
        a.Body = EncodingUtil.base64Decode('Test Body');
        liststdAttachments.add(a);
        FAP_EmailUtils.sendEmailWithStandardAttachments(strrecepients,'Test method', 'This is to test the sendTextNotificationEmail method',false,liststdAttachments);
    }
    
    static testMethod void testsendEmailWithAttachmentIDstest() {
        List<String> strrecepients=new String[]{'test@test.com','test2@test.com'};
            System.assertNotEquals(Null, strrecepients);
        List<ID> liststdAttachments = new List<ID>();
        list<Account> listAcc = TestDataFactory.createNAccount(1, 'Master Account');
        insert listAcc;
        //   Account acct = new Account(name='Test Account');
        //   insert acct;       
        Attachment a = new Attachment();
        a.ParentId = listAcc[0].Id;
        a.Name = 'Test';
        a.Body = EncodingUtil.base64Decode('Test Body');
        insert a;
        liststdAttachments.add(a.Id);
        FAP_EmailUtils.sendEmailWithStandardAttachments(strrecepients,'Test method', 'This is to test the sendTextNotificationEmail method',false,liststdAttachments);
    }
}