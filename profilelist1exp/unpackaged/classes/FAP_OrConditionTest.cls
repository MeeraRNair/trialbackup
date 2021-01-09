@IsTest
private class FAP_OrConditionTest {
    
    private static testmethod void testOrConditionEmpty(){
        System.assertEquals('',new FAP_OrCondition().toSoql());   
    }

    private static testmethod void testNestedOrConditionEmpty(){
        System.assertEquals('',new FAP_OrCondition().add(new FAP_OrCondition()).add(new FAP_OrCondition()).toSoql());   
    }

    private static testmethod void testOrConditionWithOneConditionOnly(){
        System.assertEquals(
            'name = \'acme\'',
            new FAP_OrCondition()
                .add(new FAP_FieldCondition('name ',FAP_Operator.EQUALS,'acme'))
                .toSoql());   
    }

    private static testmethod void testTwoFieldConditions(){
        System.assertEquals(
            '(name = \'acme\' OR ispartner = true)',
            new FAP_OrCondition()
                .add(new FAP_FieldCondition('name ',FAP_Operator.EQUALS,'acme'))
                .add(new FAP_FieldCondition('ispartner',FAP_Operator.EQUALS,true))
                .toSoql()
        );   
    }

}