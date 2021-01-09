@IsTest
private class FAP_NotConditionTest {
    
    private static testmethod void testNot1(){
        System.assertEquals(
            'NOT(((name = \'acme\' AND ispartner = true) OR rating = \'Hot\'))',
            new FAP_NotCondition()
                .add(
                  new FAP_OrCondition()
                  .add(new FAP_AndCondition()
                      .add(new FAP_FieldCondition('name ',FAP_Operator.EQUALS,'acme'))
                      .add(new FAP_FieldCondition('ispartner',FAP_Operator.EQUALS,true)))
                  .add(new FAP_FieldCondition('rating',FAP_Operator.EQUALS,'Hot')))
                .toSoql()
        );   
    }

}