@IsTest
private class FAP_SetConditionTest {
    
    private static testmethod void testInvalidField(){
        Boolean exceptionCaught = false;
        try{
            new FAP_SetCondition('  ');
        }catch(FAP_IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(
            exceptionCaught == true, 
            'empty field param to FAP_FieldCondition constructor did not throw IllegalArgumentException');
    }

    private static testmethod void testInvalidOperatorEuqals(){
        Boolean exceptionCaught = false;
        try{
            new FAP_SetCondition('x',FAP_Operator.EQUALS,new List<Object>{1,2});
        }catch(FAP_IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'IllegalArgumentException not thrown');
    }

    private static testmethod void testNullValueList(){
        Boolean exceptionCaught = false;
        List<Object> value = null;
        try{
            new FAP_SetCondition('x',FAP_Operator.INCLUDES,value);
        }catch(FAP_IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'FAP_IllegalArgumentException not thrown');
    }

    private static testmethod void testNullValueSoqlBuilder(){
        Boolean exceptionCaught = false;
        FAP_SoqlBuilder value = null;
        try{
            new FAP_SetCondition('x',FAP_Operator.NOT_IN,value);
        }catch(FAP_IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'IllegalArgumentException not thrown');
    }

    private static testmethod void testEmptyValue(){
        Boolean exceptionCaught = false;
        try{
            new FAP_SetCondition('x',FAP_Operator.INCLUDES,new List<Object>{});
        }catch(FAP_IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'IllegalArgumentException not thrown');
    }

    private static testmethod void testNameNotDefined(){
        Boolean exceptionCaught = false;
        try{
            new FAP_SetCondition().toSoql();   
        }catch(FAP_IllegalStateException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'IllegalStateException not thrown');
    }

    private static testmethod void testOperationNotDefined(){
        Boolean exceptionCaught = false;
        try{
            new FAP_SetCondition('name').toSoql();   
        }catch(FAP_IllegalStateException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'IllegalStateException not thrown');
    }

    private static testmethod void testInvalidValue(){
        Boolean exceptionCaught = false;
        try{
            new FAP_SetCondition('name').includes(new List<Object>{new DecimalRange(0,1)}).toSoql();   
        }catch(FAP_IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'IllegalArgumentException not thrown');
    }

    private static testmethod void testNullValuesList(){
        Boolean exceptionCaught = false;
        List<Object> value = null;
        try{
            new FAP_SetCondition('name').includes(value);   
        }catch(FAP_IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'IllegalArgumentException not thrown');
    }

    private static testmethod void testEmptyValuesList(){
        Boolean exceptionCaught = false;
        try{
            new FAP_SetCondition('name').includes(new List<Object>());   
        }catch(FAP_IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'IllegalArgumentException not thrown');
    }

    private static testmethod void testIncludes(){
        System.assertEquals(
            'name INCLUDES (\'test\',123)',
            new FAP_SetCondition('name').includes(new List<Object>{'test',123}).toSoql());   
    }

    private static testmethod void testExcludes(){
        System.assertEquals(
            'name EXCLUDES (\'test\',123)',
            new FAP_SetCondition('name').excludes(new List<Object>{'test',123}).toSoql());   
    }

    private static testmethod void testIn(){
        System.assertEquals(
            'name IN (\'test\',123)',
            new FAP_SetCondition('name').inx(new List<Object>{'test',123}).toSoql());   
    }

    private static testmethod void testNotIn(){
        System.assertEquals(
            'name NOT IN (\'test\',123)',
            new FAP_SetCondition('name').notIn(new List<Object>{'test',123}).toSoql());   
    }

    private static testmethod void testOperatorMethodIncludes(){
        System.assertEquals('x INCLUDES (1,2)',new FAP_SetCondition().field('x').includes(new List<Object>{1,2}).toSoql());   
        System.assertEquals('x INCLUDES (1,2)',new FAP_SetCondition('x').includes(new List<Object>{1,2}).toSoql());   
        System.assertEquals('x INCLUDES (1,2)',new FAP_SetCondition('x',FAP_Operator.INCLUDES,new List<Object>{1,2}).toSoql());   
    }

    private static testmethod void testOperatorMethodExcludes(){
        System.assertEquals('x EXCLUDES (1,2)',new FAP_SetCondition().field('x').excludes(new List<Object>{1,2}).toSoql());   
        System.assertEquals('x EXCLUDES (1,2)',new FAP_SetCondition('x').excludes(new List<Object>{1,2}).toSoql());   
        System.assertEquals('x EXCLUDES (1,2)',new FAP_SetCondition('x',FAP_Operator.excludes,new List<Object>{1,2}).toSoql());   
    }

    private static testmethod void testOperatorMethodInx(){
        System.assertEquals('x IN (1,2)',new FAP_SetCondition().field('x').inx(new List<Object>{1,2}).toSoql());   
        System.assertEquals('x IN (1,2)',new FAP_SetCondition('x').inx(new List<Object>{1,2}).toSoql());   
        System.assertEquals('x IN (1,2)',new FAP_SetCondition('x',FAP_Operator.INX,new List<Object>{1,2}).toSoql());   
    }

    private static testmethod void testOperatorMethodNotIn(){
        System.assertEquals('x NOT IN (1,2)',new FAP_SetCondition().field('x').notIn(new List<Object>{1,2}).toSoql());   
        System.assertEquals('x NOT IN (1,2)',new FAP_SetCondition('x').notIn(new List<Object>{1,2}).toSoql());   
        System.assertEquals('x NOT IN (1,2)',new FAP_SetCondition('x',FAP_Operator.NOT_IN,new List<Object>{1,2}).toSoql());   
    }


    private static testmethod void testBasicSemiJoinConstructor(){
        System.assertEquals('ID IN (SELECT AccountId FROM Opportunity WHERE StageName = \'Closed Lost\')',
            new FAP_SetCondition('ID', FAP_Operator.INX, 
                new FAP_SoqlBuilder().selectx('AccountId').fromx('Opportunity').wherex(new FAP_FieldCondition('StageName','Closed Lost'))
            ).toSoql());   
    }
    
    private static testmethod void testBasicSemiJoin1(){
        System.assertEquals('ID IN (SELECT AccountId FROM Opportunity WHERE StageName = \'Closed Lost\')',
            new FAP_SetCondition('ID').inx(
                new FAP_SoqlBuilder().selectx('AccountId').fromx('Opportunity').wherex(new FAP_FieldCondition('StageName','Closed Lost'))
            ).toSoql());   
    }

    private static testmethod void testBasicSemiJoin2(){
        System.assertEquals('ID NOT IN (SELECT AccountId FROM Opportunity WHERE StageName = \'Closed Lost\')',
            new FAP_SetCondition('ID').notIn(
                new FAP_SoqlBuilder().selectx('AccountId').fromx('Opportunity').wherex(new FAP_FieldCondition('StageName','Closed Lost'))
            ).toSoql());   
    }

    private static testmethod void testBasicSemiJoin3(){
        System.assertEquals('ID INCLUDES (SELECT AccountId FROM Opportunity WHERE StageName = \'Closed Lost\')',
            new FAP_SetCondition('ID').includes(
                new FAP_SoqlBuilder().selectx('AccountId').fromx('Opportunity').wherex(new FAP_FieldCondition('StageName','Closed Lost'))
            ).toSoql());   
    }

    private static testmethod void testBasicSemiJoin4(){
        System.assertEquals('ID EXCLUDES (SELECT AccountId FROM Opportunity WHERE StageName = \'Closed Lost\')',
            new FAP_SetCondition('ID').excludes(
                new FAP_SoqlBuilder().selectx('AccountId').fromx('Opportunity').wherex(new FAP_FieldCondition('StageName','Closed Lost'))
            ).toSoql());   
    }


}