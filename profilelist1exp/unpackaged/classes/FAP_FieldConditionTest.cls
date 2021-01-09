@IsTest
private class FAP_FieldConditionTest {

    private static testmethod void testInvalidField(){
        Boolean exceptionCaught = false;
        try{
            new FAP_FieldCondition('  ',null,null);
        }catch(FAP_IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(
            exceptionCaught == true, 
            'empty field param to FAP_FieldCondition constructor did not throw IllegalArgumentException');
    }

    private static testmethod void testInvalidOperatorINCLUDES(){
        Boolean exceptionCaught = false;
        try{
            new FAP_FieldCondition('x',FAP_Operator.INCLUDES,null);
        }catch(FAP_IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'IllegalArgumentException not thrown');
    }

    private static testmethod void testInvalidOperatorEXCLUDES(){
        Boolean exceptionCaught = false;
        try{
            new FAP_FieldCondition('x',FAP_Operator.EXCLUDES,null);
        }catch(FAP_IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'IllegalArgumentException not thrown');
    }

    private static testmethod void testInvalidOperatorINX(){
        Boolean exceptionCaught = false;
        try{
            new FAP_FieldCondition('x',FAP_Operator.INX,null);
        }catch(FAP_IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'IllegalArgumentException not thrown');
    }

    private static testmethod void testInvalidOperatorNOTIN(){
        Boolean exceptionCaught = false;
        try{
            new FAP_FieldCondition('x',FAP_Operator.NOT_IN,null);
        }catch(FAP_IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'IllegalArgumentException not thrown');
    }

    private static testmethod void testInvalidValue(){
        Boolean exceptionCaught = false;
        try{
            new FAP_FieldCondition('x',new FAP_DecimalRange(0,1)).toSoql();
        }catch(FAP_IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'IllegalArgumentException not thrown');
    }

    private static testmethod void testNullValue(){
        System.assertEquals('name = null',new FAP_FieldCondition('name',FAP_Operator.EQUALS,null).toSoql());   
    }

    private static testmethod void testStringValue(){
        System.assertEquals('name = \'acme\'',new FAP_FieldCondition().field('name').equals('acme').toSoql());   
        System.assertEquals('name = \'acme\'',new FAP_FieldCondition('name').equals('acme').toSoql());   
        System.assertEquals('name = \'acme\'',new FAP_FieldCondition('name',FAP_Operator.EQUALS,'acme').toSoql());   
        System.assertEquals('name like \'%acme%\'',new FAP_FieldCondition().field('name').likex('%acme%').toSoql());   
        System.assertEquals('name like \'%acme%\'',new FAP_FieldCondition('name').likex('%acme%').toSoql());   
        System.assertEquals('name like \'%acme%\'',new FAP_FieldCondition('name',FAP_Operator.LIKEX,'%acme%').toSoql());   
    }

    private static testmethod void testBooleanValue(){
        System.assertEquals('ispartner = true',new FAP_FieldCondition('ispartner',FAP_Operator.EQUALS,true).toSoql());   
        System.assertEquals('ispartner = false',new FAP_FieldCondition('ispartner',FAP_Operator.EQUALS,false).toSoql());   
    }

    private static testmethod void testIntegerValue(){
        System.assertEquals('employees = 1',new FAP_FieldCondition('employees',FAP_Operator.EQUALS,1).toSoql());   
        System.assertEquals('employees != 1',new FAP_FieldCondition('employees',FAP_Operator.NOT_EQUALS,1).toSoql());   
        System.assertEquals('employees < 1',new FAP_FieldCondition('employees',FAP_Operator.LESS_THAN,1).toSoql());   
        System.assertEquals('employees > 1',new FAP_FieldCondition('employees',FAP_Operator.GREATER_THAN ,1).toSoql());   
        System.assertEquals('employees <= 1',new FAP_FieldCondition('employees',FAP_Operator.LESS_THAN_OR_EQUAL_TO,1).toSoql());   
        System.assertEquals('employees >= 1',new FAP_FieldCondition('employees',FAP_Operator.GREATER_THAN_OR_EQUAL_TO,1).toSoql());   
    }

    private static testmethod void testDoubleValue(){
        System.assertEquals('employees = 1.1',new FAP_FieldCondition('employees',FAP_Operator.EQUALS,1.1).toSoql());   
        System.assertEquals('employees != 1.1',new FAP_FieldCondition('employees',FAP_Operator.NOT_EQUALS,1.1).toSoql());   
        System.assertEquals('employees < 1.1',new FAP_FieldCondition('employees',FAP_Operator.LESS_THAN,1.1).toSoql());   
        System.assertEquals('employees > 1.1',new FAP_FieldCondition('employees',FAP_Operator.GREATER_THAN ,1.1).toSoql());   
        System.assertEquals('employees <= 1.1',new FAP_FieldCondition('employees',FAP_Operator.LESS_THAN_OR_EQUAL_TO,1.1).toSoql());   
        System.assertEquals('employees >= 1.1',new FAP_FieldCondition('employees',FAP_Operator.GREATER_THAN_OR_EQUAL_TO,1.1).toSoql());   
    }

    private static testmethod void testDateValue(){
        System.assertEquals('createddate < 1960-02-17',new FAP_FieldCondition('createddate',FAP_Operator.LESS_THAN,Date.newinstance(1960, 2, 17)).toSoql());   
    }

    private static testmethod void testDatetimeValue(){
        System.assertEquals('createddate >= 2008-12-01T12:00:00Z',new FAP_FieldCondition('createddate',FAP_Operator.GREATER_THAN_OR_EQUAL_TO,Datetime.newInstance(2008, 12, 1)).toSoql());   
    }

    private static testmethod void testOperatorMethodequals(){
        System.assertEquals('x = 1',new FAP_FieldCondition().field('x').equals(1).toSoql());   
        System.assertEquals('x = 1',new FAP_FieldCondition('x').equals(1).toSoql());   
        System.assertEquals('x = 1',new FAP_FieldCondition('x',FAP_Operator.EQUALS,1).toSoql());   
    }

    private static testmethod void testOperatorMethodnotEquals(){
        System.assertEquals('x != 1',new FAP_FieldCondition().field('x').notEquals(1).toSoql());   
        System.assertEquals('x != 1',new FAP_FieldCondition('x').notEquals(1).toSoql());   
        System.assertEquals('x != 1',new FAP_FieldCondition('x',FAP_Operator.NOT_EQUALS,1).toSoql());   
    }

    private static testmethod void testOperatorMethodlessThan(){
      System.assertEquals('x < 1',new FAP_FieldCondition().field('x').lessThan(1).toSoql());   
        System.assertEquals('x < 1',new FAP_FieldCondition('x').lessThan(1).toSoql());   
        System.assertEquals('x < 1',new FAP_FieldCondition('x',FAP_Operator.LESS_THAN,1).toSoql());   
    }

    private static testmethod void testOperatorMethodlessThanOrEqualTo(){
        System.assertEquals('x <= 1',new FAP_FieldCondition().field('x').lessThanOrEqualTo(1).toSoql());   
        System.assertEquals('x <= 1',new FAP_FieldCondition('x').lessThanOrEqualTo(1).toSoql());   
        System.assertEquals('x <= 1',new FAP_FieldCondition('x',FAP_Operator.LESS_THAN_OR_EQUAL_TO,1).toSoql());   
    }

    private static testmethod void testOperatorMethodgreaterThan(){
        System.assertEquals('x > 1',new FAP_FieldCondition().field('x').greaterThan(1).toSoql());   
        System.assertEquals('x > 1',new FAP_FieldCondition('x').greaterThan(1).toSoql());   
        System.assertEquals('x > 1',new FAP_FieldCondition('x',FAP_Operator.GREATER_THAN,1).toSoql());   
    }

    private static testmethod void testOperatorMethodgreaterThanOrEqualTo(){
        System.assertEquals('x >= 1',new FAP_FieldCondition().field('x').greaterThanOrEqualTo(1).toSoql());   
        System.assertEquals('x >= 1',new FAP_FieldCondition('x').greaterThanOrEqualTo(1).toSoql());   
        System.assertEquals('x >= 1',new FAP_FieldCondition('x',FAP_Operator.GREATER_THAN_OR_EQUAL_TO,1).toSoql());   
    }

    private static testmethod void testOperatorMethodlikex(){
        System.assertEquals('x like \'acme\'',new FAP_FieldCondition().field('x').likex('acme').toSoql());   
        System.assertEquals('x like \'acme\'',new FAP_FieldCondition('x').likex('acme').toSoql());   
        System.assertEquals('x like \'acme\'',new FAP_FieldCondition('x',FAP_Operator.LIKEX,'acme').toSoql());   

        System.assertEquals('x like \'%acme%\'',new FAP_FieldCondition().field('x').likex('acme').toSoql(new FAP_SoqlOptions().wildcardStringsInLikeOperators()));   
        System.assertEquals('x like \'%acme%\'',new FAP_FieldCondition('x').likex('acme').toSoql(new FAP_SoqlOptions().wildcardStringsInLikeOperators()));   
        System.assertEquals('x like \'%acme%\'',new FAP_FieldCondition('x',FAP_Operator.LIKEX,'acme').toSoql(new FAP_SoqlOptions().wildcardStringsInLikeOperators()));   
    }

}