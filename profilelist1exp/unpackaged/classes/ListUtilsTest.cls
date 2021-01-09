/**

  This class tests the ListiUtils
 */
@isTest
private class ListUtilsTest {

    static testMethod void test_containsSameElements() {
        system.debug('##KP: Starts test_containsSameElements');
        
        String str1 = 'Afghanistan;Albania;Algeria;Angola;Antigua and Barbuda;Argentina;Armenia;Aruba;Austria';
		String str2 = 'Antigua and Barbuda;Argentina;Albania;Algeria;Angola;Afghanistan;Aruba;Armenia;Austria';		

		List<String> list1 = str1.split(';',-1);
		List<String> list2 = str2.split(';',-1);

		System.assertEquals(true, ListUtils.containsSameElements(list1,list2));    
        System.assertEquals(true, ListUtils.containsSameElements(null,null));   
		
		str1 = 'Afghanistan;Algeria;Angola;Antigua and Barbuda;Argentina;Armenia;Aruba;Austria';
		str2 = 'Antigua and Barbuda;Argentina;Albania;Algeria;Angola;Afghanistan;Aruba;Armenia;Austria';       
        
        list1 = str1.split(';',-1);
		list2 = str2.split(';',-1);
        System.assertEquals(false, ListUtils.containsSameElements(list1,list2)); 
        
        system.debug('##KP: Ends test_containsSameElements');
        
    }
}