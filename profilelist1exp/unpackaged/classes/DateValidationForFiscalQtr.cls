public class DateValidationForFiscalQtr{

    public static Date FYstartDate;
    public static Date FYEndDate;
    public static Map <String,Period> FYPeriodMap=new Map<String,Period> ();
    //public static Map <ID,FiscalYearSettings > FYSettingMap=new Map<ID,FiscalYearSettings > ();
    public static Map <ID,FiscalYearSettings > FYSettingMap;
    public static String FiscalQtrVal;
    public static String Fisyr;
    public static Boolean EffStartDate;
    public static Boolean EffEndDate;
    //public static Set<ID> FYIdSet =new Set<ID>();
    public static Set<String> FYNameSet=new Set<String>();
    
    public static void getFiscalQtrperiod(Set<String> FiscalYrSet ){
        //Get FY settings
        System.debug('## In getFiscalQtrperiod ##');
        for (String FY:FiscalYrSet){
            Fisyr='20'+FY.substring(2,4);
            System.debug('## Fisyr##'+Fisyr);
            FYNameSet.add(Fisyr);    
        }
        
        FYSettingMap=new Map<ID,FiscalYearSettings > ([select Id,Name from FiscalYearSettings where YearType = 'Custom' AND Name IN :FYNameSet]);
        /*for (FiscalYearSettings FYSettings :[select Id,Name from FiscalYearSettings where YearType = 'Custom' AND Name IN :FYNameSet]){
            FYIdSet.add(FYSettings.id);   
            FYSettingMap.put(FYSettings.id,FYSettings); 
        }*/
            //Get the start and End date for each Qtr in a FY
        for(Period Fqtr: [select Id,StartDate,EndDate,Number,FiscalYearSettingsId  from Period where FiscalYearSettingsId IN :FYSettingMap.keySet() and Type = 'Quarter' ]){
            FiscalQtrVal='FY'+String.valueOf(FYSettingMap.get(Fqtr.FiscalYearSettingsId ).Name.substring(2))+'Q'+String.valueOf(Fqtr.Number);
            FYPeriodMap.put(FiscalQtrVal,Fqtr);
        }
        // End of getFiscalQtrperiod
    }        
        
    
    public static Boolean DateValidation (String FiscalYr,Date DateToBeValidated){
        System.debug ('## In DateValidationForFiscalQtr.DateValidation ## ');
        Boolean ValidDate=True;
        //Get Fiscal Qtr start and end date 
        FYstartDate= FYPeriodMap.get(FiscalYr).StartDate;
        FYEndDate= FYPeriodMap.get(FiscalYr).EndDate;  
        
        //Check if the date entered falls out of the Fiscal Qtr period.
        ValidDate= (DateToBeValidated >= FYstartDate) && (DateToBeValidated <= FYEndDate);  
               
        return  ValidDate;
    }   

}