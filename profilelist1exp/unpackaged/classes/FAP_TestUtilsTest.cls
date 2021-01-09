/* ============================================================
 * Find a Partner Utility Class
 * ============================================================
 */
@IsTest
private class FAP_TestUtilsTest {

    private static testmethod void testAssertConfirmMessagesExist(){
        //test: global static void assertConfirmMessagesExist()
        FAP_PageUtils.addConfirm('test');
        FAP_TestUtils.assertConfirmMessagesExist();
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');         
    }

    private static testmethod void testAssertInfoMessagesExist(){
        //test: global static void assertInfoMessagesExist()
        FAP_PageUtils.addInfo('test');
        FAP_TestUtils.assertInfoMessagesExist();
    	account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account'); 
    }

    private static testmethod void testAssertWarningMessagesExist(){
        //test: global static void assertWarningMessagesExist()
        FAP_PageUtils.addWarning('test');
        FAP_TestUtils.assertWarningMessagesExist();
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');         
    }

    private static testmethod void testAssertErrorMessagesExist(){
        //test: global static void assertErrorMessagesExist()
        FAP_PageUtils.addError('test');
        FAP_TestUtils.assertErrorMessagesExist();
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');         
    }

    private static testmethod void testAssertFatalMessagesExist(){
        //test: global static void assertFatalMessagesExist()
        FAP_PageUtils.addFatal('test');
        FAP_TestUtils.assertFatalMessagesExist();
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');         
    }

    private static testmethod void testAssertNoConfirmMessagesExist(){
        //test: global static void assertNoConfirmMessagesExist()
        FAP_TestUtils.assertNoConfirmMessagesExist();
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');         
    }

    private static testmethod void testAssertNoInfoMessagesExist(){
        //test: global static void assertNoInfoMessagesExist(){ assertNoMessagesAtLevelExist(ApexPages.Severity.INFO); }
        FAP_TestUtils.assertNoInfoMessagesExist();
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');         
    }

    private static testmethod void testAssertNoWarningMessagesExist(){
        //test: global static void assertNoWarningMessagesExist(){ assertNoMessagesAtLevelExist(ApexPages.Severity.WARNING); }
        FAP_TestUtils.assertNoWarningMessagesExist();
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');         
    }

    private static testmethod void testAssertNoErrorMessagesExist(){
        //test: global static void assertNoErrorMessagesExist(){ assertNoMessagesAtLevelExist(ApexPages.Severity.ERROR); }
        FAP_TestUtils.assertNoErrorMessagesExist();        
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account'); 
    }

    private static testmethod void testAssertNoFatalMessagesExist(){
        //test: global static void assertNoFatalMessagesExist(){ assertNoMessagesAtLevelExist(ApexPages.Severity.FATAL); }
        FAP_TestUtils.assertNoFatalMessagesExist();
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');         
    }
    
    private static testmethod void testGetObjectAcct(){
        Map<String,String> values = new Map<String,String>();
        values.put('name','Account xyz');
        List<SObject> records = FAP_TestUtils.getObject(new Account(), 2, values);
        System.assertEquals(2,records.size());
        for(SObject record : records){
            System.assertEquals('Account xyz',record.get('name'));
        }
    }
    
    private static testmethod void testGetObjectContact(){
        Map<String,String> values = new Map<String,String>();
        values.put('LastName','Account xyz');
        List<SObject> records = FAP_TestUtils.getObject(new Contact(), 2, values);
        System.assertEquals(2,records.size());
        for(SObject record : records){
            System.assertEquals('Account xyz',record.get('LastName'));
        }
    }
    
    private static testmethod void testGetObjectDoInsert(){
        //test doInsert == false
        List<SObject> records = FAP_TestUtils.getObject(new Account(), 2);
        System.assertEquals(2,records.size());
        for(SObject record : records){
            System.assertEquals(null,record.get('id'));
        }

        //test doInsert == true
        Map<String,String> values = new Map<String,String>();
        values.put('name','Account xyz');
        records = FAP_TestUtils.getObject(new Account(), 2, values, true);
        Set<Id> idSet = new Set<Id>();
        for(SObject record : records){
            System.assertEquals('Account xyz',record.get('name'));
            idSet.add((Id)record.get('id'));
        }
        records = [select id from Account where id in :idSet];
        System.assertEquals(2,records.size());
    }
    
    private static testmethod void testGetObjectBadInput(){
        System.assertEquals(null,FAP_TestUtils.getObject(null, -1, null, true));
        System.assertEquals(null,FAP_TestUtils.getObject(null, 2, null, true));
        System.assert(FAP_TestUtils.getObject(new Account(), -1, null, true).isEmpty());
        System.assert(FAP_TestUtils.getObject(new Account(), 0, null, true).isEmpty());
    }
    

}