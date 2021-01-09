@IsTest
private class FAP_SoqlUtilsTest {
    
    private static testmethod void testInvalidValue(){
        Boolean exceptionCaught = false;
        try{
            FAP_SoqlUtils.toLiteral(new FAP_DecimalRange(0,1));
        }catch(FAP_IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'IllegalArgumentException not thrown');
    }

    private static testmethod void testSoqlableValue(){
        System.assertEquals(
            'NEXT_N_FISCAL_QUARTERS:2',
            FAP_SoqlUtils.toLiteral(new FAP_DateFormula().next(2,FAP_UnitOfTime.FiscalQuarter))
        );
    }

    private static testmethod void testNullValue(){
      Object value = null;
        System.assertEquals('null',FAP_SoqlUtils.toLiteral(value));   
    }

    private static testmethod void testStringValue(){
        System.assertEquals('\'acme\'',FAP_SoqlUtils.toLiteral('acme'));   
    }

    private static testmethod void testBooleanValue(){
        System.assertEquals('true',FAP_SoqlUtils.toLiteral(true));   
        System.assertEquals('false',FAP_SoqlUtils.toLiteral(false));   
    }

    private static testmethod void testIntegerValue(){
        Integer i = 1;
        System.assertEquals('1',FAP_SoqlUtils.toLiteral(i));   
    }

    private static testmethod void testLongValue(){
        Long l = 1;
        System.assertEquals('1',FAP_SoqlUtils.toLiteral(l));   
    }

    private static testmethod void testDoubleValue(){
        Double d = 1.1;
        System.assertEquals('1.1',FAP_SoqlUtils.toLiteral(d));   
    }

    private static testmethod void testDecimalValue(){
        Decimal d = 1.1;
        System.assertEquals('1.1',FAP_SoqlUtils.toLiteral(d));   
    }

    private static testmethod void testDateValue(){
        System.assertEquals('1960-02-17',FAP_SoqlUtils.toLiteral(Date.newinstance(1960, 2, 17)));   
    }

    private static testmethod void testDatetimeValue(){
        System.assertEquals('2008-12-01T12:00:00Z',FAP_SoqlUtils.toLiteral(Datetime.newInstance(2008, 12, 1)));   
    }
    
    private static testmethod void testPrimitivesToSoqlLiterals(){
      final List<Object> values = new List<Object>{1,'test123',1.1,true,null};
      final List<String> literals = FAP_SoqlUtils.toLiteral(values);
        System.assertEquals('1',literals.get(0));
        System.assertEquals('\'test123\'',literals.get(1));
        System.assertEquals('1.1',literals.get(2));
        System.assertEquals('true',literals.get(3));
        System.assertEquals('null',literals.get(4));
    }

    private static testmethod void testEquals1(){
        System.assertEquals(false,FAP_SoqlUtils.equals(
           'select id from account',
           'SELECT id FROM contact'
        ));
    }

    private static testmethod void testEquals2(){
        System.assertEquals(true,FAP_SoqlUtils.equals(
           'select id from account',
           'SELECT id FROM account'
        ));
    }

    private static testmethod void testEquals3(){
        System.assertEquals(false,FAP_SoqlUtils.equals(
           'select id,name from account',
           'SELECT id FROM account'
        ));
    }

    private static testmethod void testEquals4(){
        System.assertEquals(true,FAP_SoqlUtils.equals(
           '  select    ispartner,rating,id, name    from   account  ',
           ' SELECT  name,rating,  ispartner,id  FROM   account   '
        ));
    }

    private static testmethod void testEquals5(){
        System.assertEquals(false,FAP_SoqlUtils.equals(
           'xxx',
           ' SELECT  name,rating,  ispartner,id  FROM   account   '
        ));
    }

    private static testmethod void testAssertEquals(){
        FAP_SoqlUtils.assertEquals(
           'select id,name from account',
           'SELECT id,name FROM account'
        );
        System.assertEquals(false,FAP_SoqlUtils.equals(
           'xxx',
           ' SELECT  name,rating,  ispartner,id  FROM   account   '
        ));
    }

}