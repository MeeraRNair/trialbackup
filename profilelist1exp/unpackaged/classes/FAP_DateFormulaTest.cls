@IsTest
private class FAP_DateFormulaTest {


    private static testmethod void testIllegalState(){
        Boolean exceptionCaught = false;
        try{
            new FAP_DateFormula().toSoql();
        }catch(FAP_IllegalStateException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'FAP_IllegalStateException not thrown');
    }

    private static testmethod void testInvalidN(){
        Boolean exceptionCaught = false;
        try{
            new FAP_DateFormula().next(-1,FAP_UnitOfTime.Year).toSoql();
        }catch(FAP_IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'FAP_IllegalArgumentException not thrown');
    }

    private static testmethod void testYesterday(){
        System.assertEquals('YESTERDAY',new FAP_DateFormula().yesterdayx().toSoql());
    }

    private static testmethod void testToday(){
        System.assertEquals('TODAY',new FAP_DateFormula().todayx().toSoql());
    }
    
    private static testmethod void testTomorrow(){
        System.assertEquals('TOMORROW',new FAP_DateFormula().tomorrowx().toSoql());
    }
    
    private static testmethod void testLast90Days(){
        System.assertEquals('LAST_90_DAYS',new FAP_DateFormula().last90Days().toSoql());
    }
    
    private static testmethod void testNext90Days(){
        System.assertEquals('NEXT_90_DAYS',new FAP_DateFormula().next90Days().toSoql());
    }
    
    private static testmethod void testNextDay(){
        System.assertEquals('NEXT_N_DAYS:1',new FAP_DateFormula().next(FAP_UnitOfTime.Day).toSoql());
        System.assertEquals('NEXT_N_DAYS:1',new FAP_DateFormula().next(1,FAP_UnitOfTime.Day).toSoql());
    }
    
    private static testmethod void testNextWeek(){
        System.assertEquals('NEXT_WEEK',new FAP_DateFormula().next(FAP_UnitOfTime.Week).toSoql());
        System.assertEquals('NEXT_WEEK',new FAP_DateFormula().next(1,FAP_UnitOfTime.Week).toSoql());
    }
    
    private static testmethod void testNextMonth(){
        System.assertEquals('NEXT_MONTH',new FAP_DateFormula().next(FAP_UnitOfTime.Month).toSoql());
        System.assertEquals('NEXT_MONTH',new FAP_DateFormula().next(1,FAP_UnitOfTime.Month).toSoql());
    }
    
    private static testmethod void testNextQuarter(){
        System.assertEquals('NEXT_QUARTER',new FAP_DateFormula().next(FAP_UnitOfTime.Quarter).toSoql());
        System.assertEquals('NEXT_QUARTER',new FAP_DateFormula().next(1,FAP_UnitOfTime.Quarter).toSoql());
    }
    
    private static testmethod void testNextYear(){
        System.assertEquals('NEXT_YEAR',new FAP_DateFormula().next(FAP_UnitOfTime.Year).toSoql());
        System.assertEquals('NEXT_YEAR',new FAP_DateFormula().next(1,FAP_UnitOfTime.Year).toSoql());
    }
    
    private static testmethod void testNextFiscalQuarter(){
        System.assertEquals('NEXT_FISCAL_QUARTER',new FAP_DateFormula().next(FAP_UnitOfTime.FiscalQuarter).toSoql());
        System.assertEquals('NEXT_FISCAL_QUARTER',new FAP_DateFormula().next(1,FAP_UnitOfTime.FiscalQuarter).toSoql());
    }
    
    private static testmethod void testNextFiscalYear(){
        System.assertEquals('NEXT_FISCAL_YEAR',new FAP_DateFormula().next(FAP_UnitOfTime.FiscalYear).toSoql());
        System.assertEquals('NEXT_FISCAL_YEAR',new FAP_DateFormula().next(1,FAP_UnitOfTime.FiscalYear).toSoql());
    }

    private static testmethod void testLastDay(){
        System.assertEquals('LAST_N_DAYS:1',new FAP_DateFormula().last(FAP_UnitOfTime.Day).toSoql());
        System.assertEquals('LAST_N_DAYS:1',new FAP_DateFormula().last(1,FAP_UnitOfTime.Day).toSoql());
    }
    
    private static testmethod void testLastWeek(){
        System.assertEquals('LAST_WEEK',new FAP_DateFormula().last(FAP_UnitOfTime.Week).toSoql());
        System.assertEquals('LAST_WEEK',new FAP_DateFormula().last(1,FAP_UnitOfTime.Week).toSoql());
    }
    
    private static testmethod void testLastMonth(){
        System.assertEquals('LAST_MONTH',new FAP_DateFormula().last(FAP_UnitOfTime.Month).toSoql());
        System.assertEquals('LAST_MONTH',new FAP_DateFormula().last(1,FAP_UnitOfTime.Month).toSoql());
    }
    
    private static testmethod void testLastQuarter(){
        System.assertEquals('LAST_QUARTER',new FAP_DateFormula().last(FAP_UnitOfTime.Quarter).toSoql());
        System.assertEquals('LAST_QUARTER',new FAP_DateFormula().last(1,FAP_UnitOfTime.Quarter).toSoql());
    }
    
    private static testmethod void testLastYear(){
        System.assertEquals('LAST_YEAR',new FAP_DateFormula().last(FAP_UnitOfTime.Year).toSoql());
        System.assertEquals('LAST_YEAR',new FAP_DateFormula().last(1,FAP_UnitOfTime.Year).toSoql());
    }
    
    private static testmethod void testLastFiscalQuarter(){
        System.assertEquals('LAST_FISCAL_QUARTER',new FAP_DateFormula().last(FAP_UnitOfTime.FiscalQuarter).toSoql());
        System.assertEquals('LAST_FISCAL_QUARTER',new FAP_DateFormula().last(1,FAP_UnitOfTime.FiscalQuarter).toSoql());
    }
    
    private static testmethod void testFiscalYear(){
        System.assertEquals('LAST_FISCAL_YEAR',new FAP_DateFormula().last(FAP_UnitOfTime.FiscalYear).toSoql());
        System.assertEquals('LAST_FISCAL_YEAR',new FAP_DateFormula().last(1,FAP_UnitOfTime.FiscalYear).toSoql());
    }

    private static testmethod void testThisDay(){
        System.assertEquals('TODAY',new FAP_DateFormula().thisx(FAP_UnitOfTime.Day).toSoql());
    }
    
    private static testmethod void testThisWeek(){
        System.assertEquals('THIS_WEEK',new FAP_DateFormula().thisx(FAP_UnitOfTime.Week).toSoql());
    }
    
    private static testmethod void testThisMonth(){
        System.assertEquals('THIS_MONTH',new FAP_DateFormula().thisx(FAP_UnitOfTime.Month).toSoql());
    }
    
    private static testmethod void testThisQuarter(){
        System.assertEquals('THIS_QUARTER',new FAP_DateFormula().thisx(FAP_UnitOfTime.Quarter).toSoql());
    }
    
    private static testmethod void testThisYear(){
        System.assertEquals('THIS_YEAR',new FAP_DateFormula().thisx(FAP_UnitOfTime.Year).toSoql());
    }
    
    private static testmethod void testThisFiscalQuarter(){
        System.assertEquals('THIS_FISCAL_QUARTER',new FAP_DateFormula().thisx(FAP_UnitOfTime.FiscalQuarter).toSoql());
    }
    
    private static testmethod void testThisFiscalYear(){
        System.assertEquals('THIS_FISCAL_YEAR',new FAP_DateFormula().thisx(FAP_UnitOfTime.FiscalYear).toSoql());
    }

    private static testmethod void testNextNDays(){
        System.assertEquals('NEXT_N_DAYS:0',new FAP_DateFormula().next(0,FAP_UnitOfTime.Day).toSoql());
        System.assertEquals('NEXT_N_DAYS:1',new FAP_DateFormula().next(1,FAP_UnitOfTime.Day).toSoql());
        System.assertEquals('NEXT_N_DAYS:2',new FAP_DateFormula().next(2,FAP_UnitOfTime.Day).toSoql());
    }
    
    private static testmethod void testNextNWeeks(){
        Boolean exceptionCaught = false;
        try{
            new FAP_DateFormula().next(2,FAP_UnitOfTime.Week);
        }catch(FAP_IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'FAP_IllegalArgumentException not thrown');
    }
    
    private static testmethod void testNextNMonths(){
        Boolean exceptionCaught = false;
        try{
            new FAP_DateFormula().next(2,FAP_UnitOfTime.Month);
        }catch(FAP_IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'FAP_IllegalArgumentException not thrown');
    }
    
    private static testmethod void testNextNQuaters(){
        System.assertEquals('NEXT_N_QUARTERS:2',new FAP_DateFormula().next(2,FAP_UnitOfTime.Quarter).toSoql());
    }
    
    private static testmethod void testNextNYears(){
        System.assertEquals('NEXT_N_YEARS:2',new FAP_DateFormula().next(2,FAP_UnitOfTime.Year).toSoql());
    }
    
    private static testmethod void testNextNFiscalQuaters(){
        System.assertEquals('NEXT_N_FISCAL_QUARTERS:2',new FAP_DateFormula().next(2,FAP_UnitOfTime.FiscalQuarter).toSoql());
    }
    
    private static testmethod void testNextNFiscalYears(){
        System.assertEquals('NEXT_N_FISCAL_YEARS:2',new FAP_DateFormula().next(2,FAP_UnitOfTime.FiscalYear).toSoql());
    }

    private static testmethod void testLastNDays(){
        System.assertEquals('LAST_N_DAYS:0',new FAP_DateFormula().last(0,FAP_UnitOfTime.Day).toSoql());
        System.assertEquals('LAST_N_DAYS:1',new FAP_DateFormula().last(1,FAP_UnitOfTime.Day).toSoql());
        System.assertEquals('LAST_N_DAYS:2',new FAP_DateFormula().last(2,FAP_UnitOfTime.Day).toSoql());
    }
    
    private static testmethod void testLastNWeeks(){
        Boolean exceptionCaught = false;
        try{
            new FAP_DateFormula().last(2,FAP_UnitOfTime.Week);
        }catch(FAP_IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'FAP_IllegalArgumentException not thrown');
    }
    
    private static testmethod void testLastNMonths(){
        Boolean exceptionCaught = false;
        try{
            new FAP_DateFormula().last(2,FAP_UnitOfTime.Month);
        }catch(FAP_IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'FAP_IllegalArgumentException not thrown');
    }
    
    private static testmethod void testLastNQuaters(){
        System.assertEquals('LAST_N_QUARTERS:2',new FAP_DateFormula().last(2,FAP_UnitOfTime.Quarter).toSoql());
    }
    
    private static testmethod void testLastNYears(){
        System.assertEquals('LAST_N_YEARS:2',new FAP_DateFormula().last(2,FAP_UnitOfTime.Year).toSoql());
    }
    
    private static testmethod void testLastNFiscalQuaters(){
        System.assertEquals('LAST_N_FISCAL_QUARTERS:2',new FAP_DateFormula().last(2,FAP_UnitOfTime.FiscalQuarter).toSoql());
    }
    
    private static testmethod void testLastNFiscalYears(){
        System.assertEquals('LAST_N_FISCAL_YEARS:2',new FAP_DateFormula().last(2,FAP_UnitOfTime.FiscalYear).toSoql());
    }

    
/*
 
 
+----------------+-----+----------------+
+ TYPE           + N   + THIS|NEXT|LAST +
+----------------+----------------------+
+ DAYS           + YES + NO             +
+ WEEK           + NO  + YES            +
+ MONTH          + NO  + YES            +
+ QUARTER        + YES + YES            +
+ YEAR           + YES + YES            +
+ FISCAL_QUARTER + YES + YES            +
+ FISCAL_YEAR    + YES + YES            +
+----------------------+----------------+

NEXT_WEEK 
NEXT_MONTH 
NEXT_QUARTER 
NEXT_YEAR 
NEXT_FISCAL_QUARTER 
NEXT_FISCAL_YEAR 

LAST_WEEK 
LAST_MONTH 
LAST_QUARTER 
LAST_YEAR 
LAST_FISCAL_QUARTER 
LAST_FISCAL_YEAR 

THIS_WEEK 
THIS_MONTH 
THIS_QUERTER 
THIS_YEAR 
THIS_FISCAL_QUARTER 
THIS_FISCAL_YEAR 

NEXT_N_DAYS ':' INTEGER 
NEXT_N_QUARTERS ':'INTEGER 
NEXT_N_YEARS ':' INTEGER 
NEXT_N_FISCAL_QUARTERS ':' INTEGER 
NEXT_N_FISCAL_YEARS ':' INTEGER 

LAST_N_DAYS ':' INTEGER 
LAST_N_QUARTERS ':' INTEGER 
LAST_N_YEARS ':' INTEGER 
LAST_N_FISCAL_QUARTERS ':' INTEGER 
LAST_N_FISCAL_YEARS ':' INTEGER
*/    
}