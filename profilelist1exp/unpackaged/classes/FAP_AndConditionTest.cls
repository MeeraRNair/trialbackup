@IsTest
private class FAP_AndConditionTest {
    
    private static testmethod void testAndConditionEmpty(){
        System.assertEquals('',new FAP_AndCondition().toSoql());   
    }

    private static testmethod void testNestedAndConditionEmpty(){
        System.assertEquals('',new FAP_AndCondition().add(new FAP_AndCondition()).add(new FAP_AndCondition()).toSoql());   
    }

    private static testmethod void testAndConditionWithOneConditionOnly(){
        System.assertEquals(
            'name = \'acme\'',
            new FAP_AndCondition()
                .add(new FAP_FieldCondition('name ',FAP_Operator.EQUALS,'acme'))
                .toSoql());   
    }

    private static testmethod void testTwoFieldConditions(){
        System.assertEquals(
            '(name = \'acme\' AND ispartner = true)',
            new FAP_AndCondition()
                .add(new FAP_FieldCondition('name ',FAP_Operator.EQUALS,'acme'))
                .add(new FAP_FieldCondition('ispartner',FAP_Operator.EQUALS,true))
                .toSoql()
        );   
    }

}