@isTest
private class ExpressionUtilsTest{
    public static testmethod void testExpressionUtils(){
    
        ExpressionUtils expUtil = new ExpressionUtils();
        
        expUtil.convertInFixToPostFixNotation('a AND b');
        expUtil.convertInFixToPostFixNotation('a OR b');
        expUtil.convertInFixToPostFixNotation('( a OR b ) AND c');
        try{
            expUtil.convertInFixToPostFixNotation(null);
        }
        catch(Exception e){}
        
        try{
            expUtil.convertInFixToPostFixNotation('');
        }
        catch(Exception e){}

        expUtil.evaluateSimpleCondition('a', 'b', 'OR');
        expUtil.evaluateSimpleCondition('a', 'b', 'AND');
        expUtil.isEvaluated('a');
        expUtil.BoolToStr(true);
        expUtil.StrToBool('1');
                
        //expUtil.convertInFixToPostFixNotation(' A OR B ; C ');
    }
}