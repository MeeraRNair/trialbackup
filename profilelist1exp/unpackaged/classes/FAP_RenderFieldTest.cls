@IsTest
private class FAP_RenderFieldTest {
    
    private static testmethod void testTranslatePicklistValueMultipicklist(){
        final String result = FAP_RenderField.translatePicklistValue(
            'abc;xyz',
            new Map<String,String>{'abc'=>'123','xyz'=>'456'},
            true);
        System.assertNotEquals(null, result);            
        System.assertEquals('123;456', result);            
    }

    private static testmethod void testTranslatePicklistValueSinglepicklist1(){
        final String result = FAP_RenderField.translatePicklistValue(
            'abc',
            new Map<String,String>{'abc'=>'123','xzy'=>'456'},
            false);
        System.assertNotEquals(null, result);            
        System.assertEquals('123', result);            
    }

    private static testmethod void testTranslatePicklistValueSinglepicklist2(){
        final String result = FAP_RenderField.translatePicklistValue(
            'abc;xyz',
            new Map<String,String>{'abc'=>'123','xzy'=>'456'},
            false);
        System.assertNotEquals(null, result);            
        System.assertEquals('abc;xyz', result);            
    }
    
    private static testmethod void testCreate(){
      final FAP_RenderField field = new FAP_RenderField(
         'Account',
         Account.Profile_Published_to_Partner_Finder__c.getDescribe());
      final Map<String,String> valuesToLabels = field.pickListValuesValueToLabelMap;
        System.assertNotEquals(null,valuesToLabels);
        System.assert(valuesToLabels.size()>0);
    }
    
    private static testmethod void testThreeParamConstructor(){
    final Schema.DescribeFieldResult d1 = Account.Industry.getDescribe();
    final Schema.DescribeFieldResult d2 = Account.Type.getDescribe();
    
    List<FAP_RenderField> theList = new List<FAP_RenderField>();
    
    for(Integer i = 0; i < 10; i++){
      theList.add(new FAP_RenderField('Account', d1, d2));
    }    
    System.assertNotEquals(null,theList);
    //FAP_RenderFilterField.putFilterFieldList(theList);
  }
    
    
}