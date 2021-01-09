/* ============================================================
 * Find a Partner Utility Class
 * ============================================================
 */
@IsTest
private class FAP_SObjectSortByNameComparatorTest {

    private static testmethod void testCompareBadInput(){
        FAP_ISObjectComparator comparator = new FAP_SObjectSortByNameComparator();
        System.assertEquals(-1,comparator.compare(null,new Account(name='test123'))); 
        System.assertEquals(0,comparator.compare(null,null)); 
        System.assertEquals(1,comparator.compare(new Account(name='test123'),null)); 
        
    }
    
    private static testmethod void testCompareWithAccounts(){
        Account a1 = new Account(name='abc');
        Account a2 = new Account(name='efg');
        FAP_ISObjectComparator comparator = new FAP_SObjectSortByNameComparator();
        System.assert(0 > comparator.compare(a1,a2)); 
        System.assert(0 == comparator.compare(a1,a1)); 
        System.assert(0 < comparator.compare(a2,a1)); 
    }
    
 /*   private static testmethod void testCompareWithContacts(){
        final Account acct = new Account(name='abc');
        insert acct;
        final Account acct2 = new Account(name='abc');
        insert acct;        
        Contact a1 = new Contact(accountid=acct.id,lastname='abc',phone='3213213211');
        insert a1;
        a1 = [select name from Contact where id = :a1.id];
        Contact a2 = new Contact(accountid=acct.id,lastname='efg',phone='3213213211');
        insert a2;
        a2 = [select name from Contact where id = :a2.id];
        FAP_ISObjectComparator comparator = new FAP_SObjectSortByNameComparator();
        System.assert(0 > comparator.compare(a1,a2)); 
        System.assert(0 == comparator.compare(a1,a1)); 
        System.assert(0 < comparator.compare(a2,a1)); 
    }*/
}