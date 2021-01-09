global class OpportunityUtils {

/************************************************************************
* Revision History
* Version   Date            ModifiedBy      Description
* -----------------------------------------------------------
* 1.0       Unknown         Unknown         First created by someone
* 2.0       09-Dec-2009     Raymond Yip     Modified for CR2134 (R11.1)
* 3.0       09-Dec-2009     Meera Nair      Updated as part of CR2341
* 4.0       24-Feb-2010     Men Mee         Format Date based on user's locale setting
* 5.0       16-Jun-2010     Alvin Chew      Added function for capturing latest date in between of two date 
* 6.0       28-Nove-2010    Raymond Yip     Remove query for RunRate RecordType to reduce number of query
* 6.1       11-Apr-2011     Raymond Yip     R12.3 Modified GetNearestQuarterEndDate test methods to work with locale
* 7.0       14-Apr-2011     Carmen          CR6108 - Fixed FY, remove mapOppIdCloseYear
* 8.0       24-Aug-2011     Krishna         CR6547(Emergency) - Calculating the week, instead of traversing through Week periods. Also removed week period traversing.
* 9.0       25-Apr-2012     Krishna         CR7079(R13.4) - Fixed nullpointer exceptions around Fiscal Book date calculation.
*10.0       11-Nov-2014     Jessie Tan      CR10590(R15.10) - Added 1 function (getCurrentFiscalYearDate) to fix the Strategy Opportunity Rollup Data calculation 
*11.0       18-Nov-2015     Men Mee         CR12361 Finetune the code to avoid 101 SOQL Exception
*12.0       05-Oct-2015     Afiq            Fix cannot execute flow trigger
************************************************************************/

    // Variable  to allow testing of exception scenarios
    public static boolean testException = false;
    
    // Variable to avoid recurisve call of CMAP Opportunity Trigger when manual linking of channel lead will happen.
    public static boolean runCMAPOppTrigger=true;   
    public static Map<string,Date> allYearPeriodMap; //11.0
    
    public static map<ID, String> setFYCloseDate(List<Opportunity> Opportunities) {

        system.debug('#### In OpportunityUtils.setFYCloseDate() . . . ');
    
    
        // Declare variables
        Integer iInputSize = 0;
        
        String sErrorMsg = '';

        //Insert Opportunity has null ID
        //map<ID, Integer> mapOppIdCloseYear = new map<ID, Integer>();
    
        Integer iCloseYear = 0;
        String sCloseYear = '';

        Integer iCounter = 1;

        Integer minCloseYearInt;
        String minCloseYearStr = '';

        Integer maxCloseYearInt = 0;
        
        //Set<Integer> setCloseYearInt = new Set<Integer>();  //v9.0 commented out
        Set<String> setCloseYearStr = new Set<String>();
    
        Set<Id> setFYSId = new Set<Id>();
    
        map<String, FiscalYearSettings> mapFYInfo = new map<String, FiscalYearSettings>();
        map<String, map<Integer, Period>> mapFYQTRInfo = new map<String, map<Integer, Period>>();
        
    
        Integer intCloseYear;
        String strCloseYear;
    
        Integer iFiscalYear;
        String sFiscalYear;
        
        Integer iQuarter;
        String sQuarter;
    
        Integer j;       
    
        Integer weekCalculated;
        String sWeek;
    
        String sFYCloseDate;
        Date quarterStartDate;
    
        Map<ID, String> mapOppIdFYCloseDate = new Map<ID, String>();
        Map<ID, String> mapOppNoFiscalYear = new Map<ID, String>();



        // Get the size of the opportunity and set the error message
        iInputSize = Opportunities.size();
        
        
        if (iInputSize > 1) {
            sErrorMsg = 'Fiscal year information does not exist for one or more opportunities in this set';
        }

        else {
            sErrorMsg = 'Fiscal year information does not exist for this book date';
        }


    
        // Find minimum and maximum close years, and capture the close year into an array with corresponding
        // opportunity ID
        for (Opportunity indOpp : Opportunities) {
                        
            Date dCloseDate = indOpp.CloseDate;
            iCloseYear = dCloseDate.year();
    

            if (iCounter == 1) {
                minCloseYearInt = iCloseYear;
                maxCloseYearInt = iCloseYear;
            }

            else {

                // Store the maximum close year up to this point
                if (iCloseYear > maxCloseYearInt) {
                    maxCloseYearInt = iCloseYear;
                }

                // Store the minimum close year up to this point
                if (iCloseYear < minCloseYearInt) {
                    minCloseYearInt = iCloseYear;
                }

            }   // End if (iCounter == 1)
            
            // Add to array of opportunities and close years
            //mapOppIdCloseYear.put(indOpp.id, iCloseYear);          

            iCounter++;

        }   // End for (Opportunity indOpp : Opportunities)    
    
    
        // Add one more year to the array.  Increment maximum year by 1, and add to arrays.
        maxCloseYearInt = maxCloseYearInt + 1;
        
        // Construct the string array of fiscal years
        for (Integer m=minCloseYearInt; m<=maxCloseYearInt; m++) {

            sCloseYear = String.valueof(m);

            //setCloseYearInt.add(m);  //v9.0 commented out
            setCloseYearStr.add(sCloseYear);
            
        }

        system.debug('#### Array of Fiscal Years = ' + setCloseYearStr);
        
        // Create a map of fiscal years, and start and end dates.   //v9.0 removed unnecessary iterations
        for (FiscalYearSettings indFYS : [select Id, Name, StartDate, EndDate from FiscalYearSettings where YearType = 'Custom' and Name in :setCloseYearStr]) {             
                                                    
            // Add record IDs to set of unique values
            setFYSId.add(indFYS.Id);

            // Create a map of fiscal year information
            mapFYInfo.put(indFYS.Name, indFYS);

        }   // for(FiscalYearSettings indFYS : [SOQL])    

        system.debug('#### Array of FY with start/snd dates = ' + mapFYInfo);
    
        // If no fiscal years are found in the system, throw an exception
        if (setFYSId.size() > 0) {

            // Create maps of fiscal years and quarters, and fiscal years  //v9.0 removed unnecessary iterations
            for (Period indPeriod : [select Id, FiscalYearSettings.Name, Number, Type, StartDate, EndDate from Period where FiscalYearSettingsId in :setFYSId and Type = 'Quarter']) {            
    
                // Create a map of fiscal year and quarter information
                if (indPeriod.Type == 'Quarter') {
        
                    Period dtStartEndDates = new Period(StartDate = indPeriod.StartDate, EndDate = indPeriod.EndDate);  //v9.0 moved parameter field assignment to initialization stmt 
                            
                    // Get the map associated to fiscal year
                    map<Integer, Period> mapQP = mapFYQTRInfo.get(indPeriod.FiscalYearSettings.Name);
                        
                    if (mapQP == null) {
                        mapQP = new map<Integer, Period>();
                    }
        
                    mapQP.put(indPeriod.Number, dtStartEndDates);
        
                    mapFYQTRInfo.put(indPeriod.FiscalYearSettings.Name, mapQP);
        
                }   // if (indPeriod.Type == 'Quarter')                 
    
            }   // End for (Period indPeriod : [SOQL])

        }   // End if (setFYSId.size() > 0)


        system.debug('#### Array of Quarters = ' + mapFYQTRInfo);           

        // Loop through the opportunities, and set the FY CloseDate
        for (Opportunity opp : Opportunities) {
    
            
            
            // Initialize the values of fiscal year, quarter, and week
            sFiscalYear = '';            
            sQuarter = '';            
            sWeek = '';


            // Determine fiscal year of close date
            //intCloseYear = mapOppIdCloseYear.get(opp.Id);
            intCloseYear = (Integer)opp.CloseDate.year();
            strCloseYear = String.valueOf(intCloseYear); 
                
            
            // Get start and end dates corresponding to opportunity close year
            FiscalYearSettings FYStartEndDates =  mapFYInfo.get(strCloseYear);   //v9.0 assigning directly

        
            if (FYStartEndDates != null) {

                // Calculate the fiscal year
                if (opp.CloseDate > FYStartEndDates.EndDate) {
                    iFiscalYear = intCloseYear + 1;
                }
        
                else {
                    iFiscalYear = intCloseYear;
                }
    
                sFiscalYear = String.valueOf(iFiscalYear);
            
                system.debug('#### Fiscal Year = ' + sFiscalYear);            
        
                // Determine the quarter that the close date falls into
                map<Integer, Period> mapQtrStartEndDates = mapFYQTRInfo.get(sFiscalYear);


                if (mapQtrStartEndDates != null && mapQtrStartEndDates.size() > 0) {

                    iQuarter = 0;  //v9.0
                    for (Integer i=1; i<=mapQtrStartEndDates.size(); i++) {
        
                        Period StartEndRange = mapQtrStartEndDates.get(i);  //v9.0 assigning directly
                    
                        if (opp.CloseDate >= StartEndRange.StartDate && opp.CloseDate <= StartEndRange.EndDate) {
                            iQuarter = i;
                            quarterStartDate = StartEndRange.StartDate;
                            break;
                        }
                    
                    }   // End for (Integer i=0; i<mapQtrStartEnddates.size(); i++)
            
            
                    sQuarter = String.valueOf(iQuarter);
                
                    /* v8.0  Mathematic for calculating weeks */
                        
                    weekCalculated = 0;

                    String log = '\nQuarterStartDate=' + quarterStartDate + + '\nCloseDate='+ opp.CloseDate;
                    if(quarterStartDate !=null){          //v9.0 added null checking            
                        integer numberOfDays = math.abs(quarterStartDate.daysBetween(opp.CloseDate))+1;
                            log+= '\nNumberOfDays=' + numberOfDays;
                        double numberOfWeeksDouble =  (numberOfDays/7.0);
                            log+= '\nNumberOfWeeks=' + numberOfWeeksDouble;
                        numberOfWeeksDouble  = math.ceil(numberOfWeeksDouble); 
                            log+= '\nNumberOfWeeks after rounding=' + numberOfWeeksDouble;
                        weekCalculated = numberOfWeeksDouble.intValue();
                            log+= '\nWeek Number=' + weekCalculated;
                    }   
                    System.debug('\n## Week Calculation log##' + log );
                    
                    /* v8.0 */
                    sWeek = String.valueOf(weekCalculated);
                
                }   // End if (mapQtrStartEndDates != null && mapQtrStartEndDates.size() > 0)  //v9.0 moved to here - more covering of statements under this block
                
            }   // End else (FYStartEndDates == null)


            
            // Set the values of the opportunity fiscal component fields
            opp.Fiscal_Year__c = sFiscalYear;
            opp.Fiscal_Quarter__c = sQuarter;
            opp.Fiscal_Week__c = sWeek;
               
            // Add the opportunity ID and FY close date to map
            sFYCloseDate = 'FY' + sFiscalYear + 'Q' + sQuarter + 'W' + sWeek;
    
            system.debug('#### Fiscal Year Close Date = ' + sFYCloseDate);

            mapOppIdFYCloseDate.put(opp.Id, sFYCloseDate);


        }   // End for (Opportunity opp : Opportunities)
        
        
        // Test the exception scenario
        if (testException) {
            throw new dellUtil.DellException('An exception occurred in OpportunityUtils.setFYCloseDate() while processing opportunity set ' + Opportunities);
        }
        
        //v9.0 deleted old commented out statements
        
        // Return the map of opportunity IDs and FY close date
        return mapOppIdFYCloseDate;
        
        
    }   // function setFYCloseDate()

    //Raymond 20091209: Added for CR2134
    //                  Returns the nearest end date of the given date according to Fiscal Year configuration
    //                  If the date is the same as the end date of the quarter, return the end date of the next quarter
    public static Date getNearestQuarterEndDate() {
        return getNearestQuarterEndDate(System.today());    
    }
        
    //Raymond 20091209: Added for CR2134
    //                  Returns the nearest end date of the given date according to Fiscal Year configuration
    //                  If the date is the same as the end date of the quarter, return the end date of the next quarter
    public static Date getNearestQuarterEndDate(Date dateToCheck) {
        List<Period> periodList;
        
        Date quarterEndDate;

        periodList = [SELECT EndDate FROM Period WHERE Type = 'Quarter' AND StartDate <= :dateToCheck AND EndDate >= :dateToCheck LIMIT 1];
        
        if(periodList.size() < 1) {
            throw new dellUtil.DellException('Unable to retrieve the nearest end-of-quarter date for ' + dateToCheck + '. Please ensure that the Fiscal Year is configured correctly.');
        }
        
        quarterEndDate = periodList[0].EndDate;
        
        if(dateToCheck == quarterEndDate) {
            periodList = [SELECT EndDate FROM Period WHERE Type = 'Quarter' AND StartDate = :dateToCheck+1  LIMIT 1];           
            
            if(periodList.size() < 1) {
                throw new dellUtil.DellException(dateToCheck + ' is the end of the quarter and unable to retrieve information of the next quarter. Please ensure that the Fiscal Year is configured correctly.');
            }
            
            quarterEndDate = periodList[0].EndDate;
        }
        
        return quarterEndDate;
    }

    //Raymond 20091209: Added for CR2134
    //                  returns the quarter end date in string format 'MM/DD/YYYY'
    //Rev 4.0: returns end date based on user's locale setting
    public static String getNearestQuarterEndDateString() {
        return getNearestQuarterEndDateString(System.today());
    }

    //Raymond 20091209: Added for CR2134
    //                  returns the quarter end date in string format 'MM/DD/YYYY'
    //Rev 4.0: returns end date based on user's locale setting
    public static String getNearestQuarterEndDateString(Date dateToCheck) {
        Date endDate = getNearestQuarterEndDate(dateToCheck);
        
        if(endDate == null) {           
            return null;
        }
    
        //Rev 4.0
        //return endDate.month() + '/' + endDate.Day() + '/' + endDate.Year();
        return endDate.format();
        //Rev 4.0-end
        
    }
    
    //Raymond 20091209: Added for CR2134
    //Default CloseDate to Date of nearest quarter end for Run Rate Opportunities, Stage to 90% and probability to 90%                 
    public static void defaultRunRateOppty(List<Opportunity> opptyList) {
  
        //CR4464: Removed the query statement to reduce number of queries. Hardcoding RecordTypeId in GlobalVariables
        //List<RecordType> recTypeList = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND Name = 'Run Rate Opportunity'];
        //RUNRATE_OPP_RECTYPE : 012A0000000TWOiIAO
        Date endDate;
        //if(recTypeList.size() >= 1) {
        if(GlobalVariables.RUNRATE_OPP_RECTYPE != '') {       
            //String runRateOpptyId = recTypeList[0].Id;
            String runRateOpptyId = GlobalVariables.RUNRATE_OPP_RECTYPE;
                
            for(Opportunity o : opptyList) {
                if(o.recordTypeId == runRateOpptyId){
                    
                    if(endDate == null) {
                        endDate = getNearestQuarterEndDate();
                    }
                    
                    if(endDate == null) {           
                        return;
                    }
            
                    o.CloseDate = endDate;
                    o.StageName = 'Commit - 90%';
                    o.Probability = 90;
                }                       
            }
        }       
    }
    
    //Alvin 20100616 : Compare two date by return the latest date 
    public static Date getCompareBookDate(Date paramQuarterDate, Date paramCompareBookDate){
        return (paramQuarterDate >= paramCompareBookDate) ? paramQuarterDate : paramCompareBookDate;
    }
    
    //Alvin 20100616 : return after addition of date
    public static Date getAddeddate(Date paramDateBeforeAdd, Integer paramNumberOfDay){
        return paramDateBeforeAdd.addDays(paramNumberOfDay);
    }
    
     //Alvin 20100616 : return latest between two date
    public static Date getLatestBookDate(){
        Date    quarterDate     = getNearestQuarterEndDate();
        Date    addedDate       = getAddeddate(System.today(),30);    
        System.debug('quarterDate : ' + quarterDate + ',  addedDate :' + addedDate);            
        return getCompareBookDate(quarterDate, addedDate);  
    }
    
    static testMethod void testGetLatestBookDate(){
        Date    quarterDate     = getNearestQuarterEndDate();
        Date    addedDate       = getAddeddate(System.today(),30);  
        
        System.assertEquals(quarterDate, getNearestQuarterEndDate(system.today()));
        System.assertEquals(addedDate, System.today()+30);
        
        if(quarterDate>addedDate){
            system.assertEquals(quarterDate, getCompareBookDate(quarterDate, addedDate));
        }else{
            system.assertEquals(addedDate, getCompareBookDate(quarterDate, addedDate));
        }
    
    }
    
    static testMethod void testFYCloseDate() {
        
      
        triggerexecutioncontroller.setSkipAllTriggers(true);    
        system.debug('#### In test method testFYCloseDate . . .');
    

        // Declare variables
        List<Opportunity> testOpp = new List<Opportunity>();
        List<Opportunity> lstOpp = new List<Opportunity>();
        Map<ID, String> mapFYCloseDateResults = new Map<ID, String>();



        // Create account
        Account testAccount = new Account(Name='Test Account 10');

        insert testAccount;
        
        // Verify the creation of the account
//      system.debug('#### Verification of account creation . . .');
//      system.assertEquals(1, [select count() from Account where Id = :testAccount.Id]);



        // Create the opportunity
        Date dCloseDate = Date.newInstance(2008,05,05);

        Date dCloseDateFY2009Q3W6 = Date.newInstance(2008,09,11);
        Date dCloseDateFY2008Q2W1 = Date.newInstance(2007,05,09);
        Date dCloseDateFY2009Q1W13 = Date.newInstance(2008,04,28);
        Date dCloseDateFY2008Q4W13 = Date.newInstance(2008,01,29);

        /* Fenny commented [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
        Opportunity testOpportunity1 = new Opportunity(RecordTypeId='012300000004zf2', Name='Test Opportunity 1', AccountId=testAccount.Id, Type='Deal/Bid Direct', CloseDate=dCloseDate, StageName='Plan - 1%');
        Opportunity testOpportunity2 = new Opportunity(RecordTypeId='012300000004zf2', Name='Test Opportunity 2', AccountId=testAccount.Id, Type='Deal/Bid Direct', CloseDate=dCloseDate, StageName='Plan - 1%');
        Opportunity testOpportunity3 = new Opportunity(RecordTypeId='012300000004zf2', Name='Test Opportunity 3', AccountId=testAccount.Id, Type='Deal/Bid Direct', CloseDate=dCloseDate, StageName='Plan - 1%');
        Opportunity testOpportunity4 = new Opportunity(RecordTypeId='012300000004zf2', Name='Test Opportunity 4', AccountId=testAccount.Id, Type='Deal/Bid Direct', CloseDate=dCloseDate, StageName='Plan - 1%');*/

        // Fenny added [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
        Opportunity testOpportunity1 = new Opportunity(RecordTypeId='012300000004zf2', Name='Test Opportunity 1', AccountId=testAccount.Id, Type='Deal/Bid Direct', CloseDate=dCloseDate, StageName='Win - 100%', Competitor_Lost_To__c='Unknown');
        Opportunity testOpportunity2 = new Opportunity(RecordTypeId='012300000004zf2', Name='Test Opportunity 2', AccountId=testAccount.Id, Type='Deal/Bid Direct', CloseDate=dCloseDate, StageName='Win - 100%', Competitor_Lost_To__c='Unknown');
        Opportunity testOpportunity3 = new Opportunity(RecordTypeId='012300000004zf2', Name='Test Opportunity 3', AccountId=testAccount.Id, Type='Deal/Bid Direct', CloseDate=dCloseDate, StageName='Win - 100%', Competitor_Lost_To__c='Unknown');
        Opportunity testOpportunity4 = new Opportunity(RecordTypeId='012300000004zf2', Name='Test Opportunity 4', AccountId=testAccount.Id, Type='Deal/Bid Direct', CloseDate=dCloseDate, StageName='Win - 100%', Competitor_Lost_To__c='Unknown');

        testOpp.add(testOpportunity1);
        testOpp.add(testOpportunity2);      
        testOpp.add(testOpportunity3);      
        testOpp.add(testOpportunity4);      

        triggerexecutioncontroller.setSkipAllTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(true); // 7.2
        TriggerExecutionController.setSkipOpportunityTriggers(true); // 7.2
        insert testOpp;
        TriggerExecutionController.setSkipAccountTriggers(false); // 7.2
        TriggerExecutionController.setSkipOpportunityTriggers(false); // 7.2

        
        // Verify the creation of the account
//      system.debug('#### Verification of opportunity creation . . .');
//      system.assertEquals(1, [select count() from Opportunity where Id = :testOpportunity1.Id]);
//      system.assertEquals(1, [select count() from Opportunity where Id = :testOpportunity2.Id]);
//      system.assertEquals(1, [select count() from Opportunity where Id = :testOpportunity3.Id]);
//      system.assertEquals(1, [select count() from Opportunity where Id = :testOpportunity4.Id]);
        
        

        // Update the close dates
        testOpportunity1.CloseDate = dCloseDateFY2009Q3W6;
        testOpportunity2.CloseDate = dCloseDateFY2008Q2W1;
        testOpportunity3.CloseDate = dCloseDateFY2009Q1W13;
        testOpportunity4.CloseDate = dCloseDateFY2008Q4W13;
        
        
        // Add to opportunity array
        lstOpp.add(testOpportunity1);
        lstOpp.add(testOpportunity2);
        lstOpp.add(testOpportunity3);
        lstOpp.add(testOpportunity4);


        // Test
        Test.startTest();
        
        mapFYCloseDateResults = setFYCloseDate(lstOpp);
        
        Test.stopTest();


        // Verify results
        system.debug('#### Calculated FY Close Date = ' + mapFYCloseDateResults.get(testOpportunity1.Id));
        system.debug('#### Calculated FY Close Date = ' + mapFYCloseDateResults.get(testOpportunity2.Id));      
        system.debug('#### Calculated FY Close Date = ' + mapFYCloseDateResults.get(testOpportunity3.Id));      
        system.debug('#### Calculated FY Close Date = ' + mapFYCloseDateResults.get(testOpportunity4.Id));      

        system.debug('#### Verification of FY Close Date calculation . . .');       
        system.assertEquals('FY2009Q3W6', mapFYCloseDateResults.get(testOpportunity1.Id));
        system.assertEquals('FY2008Q2W1', mapFYCloseDateResults.get(testOpportunity2.Id));
        system.assertEquals('FY2009Q1W13', mapFYCloseDateResults.get(testOpportunity3.Id));
        system.assertEquals('FY2008Q4W13', mapFYCloseDateResults.get(testOpportunity4.Id));
        
    }   // End testFYCloseDate()


    static testMethod void testExceptionCase() {

        system.debug('#### In test method testExceptionCase . . .');
    
triggerexecutioncontroller.setSkipAllTriggers(True);
        // Declare variables
        List<Opportunity> lstOpp = new List<Opportunity>();
        Map<ID, String> mapFYCloseDateResults = new Map<ID, String>();



        // Create account
        Account testAccount = new Account(Name='Test Account 10');

        insert testAccount;
        
        // Verify the creation of the account
//      system.debug('#### Verification of account creation . . .');
//      system.assertEquals(1, [select count() from Account where Id = :testAccount.Id]);



        // Create the opportunity
        Date dCloseDate = Date.newInstance(2008,05,05); 

        Date dCloseDateFY2009Q3W6 = Date.newInstance(2008,09,11); 

        // Fenny commented [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
        //Opportunity testOpportunity1 = new Opportunity(RecordTypeId='012300000004zf2', Name='Test Opportunity 1', AccountId=testAccount.Id, Type='Deal/Bid Direct', CloseDate=dCloseDate, StageName='Plan - 1%');
        // Fenny added [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
        Opportunity testOpportunity1 = new Opportunity(RecordTypeId='012300000004zf2', Name='Test Opportunity 1', AccountId=testAccount.Id, Type='Deal/Bid Direct', CloseDate=dCloseDate, StageName='Win - 100%', Competitor_Lost_To__c='Unknown');

        
        insert testOpportunity1;
        triggerexecutioncontroller.setSkipAllTriggers(false);
        
        // Verify the creation of the account
//      system.debug('#### Verification of opportunity creation . . .');
//      system.assertEquals(1, [select count() from Opportunity where Id = :testOpportunity1.Id]);
        

        // Update the close dates
        testOpportunity1.CloseDate = dCloseDateFY2009Q3W6;
        
        
        // Add to opportunity array
        lstOpp.add(testOpportunity1);


        try {

            // Force the exception
            testException = true;
    
    
            // Test
            Test.startTest();
            
            mapFYCloseDateResults = setFYCloseDate(lstOpp);
            
            Test.stopTest();
    
    
            // Reset the exception
            testException = false;
        }
        
        catch (Exception e) {
            system.debug('#### Caught exception ' + e.getMessage());
            testException = false;
        }

    }   // End testExceptionCase()



    static testMethod void testFYFoundAndNotFound() {
    
triggerexecutioncontroller.setSkipAllTriggers(True);
        
    
        system.debug('#### In test method testFYFoundAndNotFound . . .');
    

        // Declare variables
        List<Opportunity> testOpp = new List<Opportunity>();
        List<Opportunity> lstOpp = new List<Opportunity>();
        Map<ID, String> mapFYCloseDateResults = new Map<ID, String>();



        // Create account
        Account testAccount = new Account(Name='Test Account 10');

        insert testAccount;
        
        // Verify the creation of the account
//      system.debug('#### Verification of account creation . . .');
//      system.assertEquals(1, [select count() from Account where Id = :testAccount.Id]);



        // Create the opportunity
        Date dCloseDate = Date.newInstance(2008,05,05);

        Date dCloseDateFY2009Q3W6 = Date.newInstance(2008,09,11);
        Date dCloseDateFY2008Q2W1 = Date.newInstance(2007,05,09);
        Date dCloseDateFY2009Q1W13 = Date.newInstance(2008,04,28);
        Date dCloseDateFY2008Q4W13 = Date.newInstance(2008,01,29);
        Date dCloseDateFY2020Q4W13 = Date.newInstance(2020,01,29);
        Date dCloseDateFY2030Q4W13 = Date.newInstance(2030,01,29);

        /* Fenny commented [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
        Opportunity testOpportunity1 = new Opportunity(RecordTypeId='012300000004zf2', Name='Test Opportunity 1', AccountId=testAccount.Id, Type='Deal/Bid Direct', CloseDate=dCloseDate, StageName='Plan - 1%');
        Opportunity testOpportunity2 = new Opportunity(RecordTypeId='012300000004zf2', Name='Test Opportunity 2', AccountId=testAccount.Id, Type='Deal/Bid Direct', CloseDate=dCloseDate, StageName='Plan - 1%');
        Opportunity testOpportunity3 = new Opportunity(RecordTypeId='012300000004zf2', Name='Test Opportunity 3', AccountId=testAccount.Id, Type='Deal/Bid Direct', CloseDate=dCloseDate, StageName='Plan - 1%');
        Opportunity testOpportunity4 = new Opportunity(RecordTypeId='012300000004zf2', Name='Test Opportunity 4', AccountId=testAccount.Id, Type='Deal/Bid Direct', CloseDate=dCloseDate, StageName='Plan - 1%');*/

        // Fenny added [18-Jul-2014]: To accommondate new VR = OpptyBookDateValidation
        Opportunity testOpportunity1 = new Opportunity(RecordTypeId='012300000004zf2', Name='Test Opportunity 1', AccountId=testAccount.Id, Type='Deal/Bid Direct', CloseDate=dCloseDate, StageName='Win - 100%', Competitor_Lost_To__c='Unknown');
        Opportunity testOpportunity2 = new Opportunity(RecordTypeId='012300000004zf2', Name='Test Opportunity 2', AccountId=testAccount.Id, Type='Deal/Bid Direct', CloseDate=dCloseDate, StageName='Win - 100%', Competitor_Lost_To__c='Unknown');
        Opportunity testOpportunity3 = new Opportunity(RecordTypeId='012300000004zf2', Name='Test Opportunity 3', AccountId=testAccount.Id, Type='Deal/Bid Direct', CloseDate=dCloseDate, StageName='Win - 100%', Competitor_Lost_To__c='Unknown');
        Opportunity testOpportunity4 = new Opportunity(RecordTypeId='012300000004zf2', Name='Test Opportunity 4', AccountId=testAccount.Id, Type='Deal/Bid Direct', CloseDate=dCloseDate, StageName='Win - 100%', Competitor_Lost_To__c='Unknown');

        testOpp.add(testOpportunity1);
        testOpp.add(testOpportunity2);      
        testOpp.add(testOpportunity3);      
        testOpp.add(testOpportunity4);      

        TriggerExecutionController.setSkipAccountTriggers(True);

        insert testOpp;

        
        // Verify the creation of the account
//      system.debug('#### Verification of opportunity creation . . .');
//      system.assertEquals(1, [select count() from Opportunity where Id = :testOpportunity1.Id]);
//      system.assertEquals(1, [select count() from Opportunity where Id = :testOpportunity2.Id]);
//      system.assertEquals(1, [select count() from Opportunity where Id = :testOpportunity3.Id]);
//      system.assertEquals(1, [select count() from Opportunity where Id = :testOpportunity4.Id]);
        
        

        // Update the close dates
        testOpportunity1.CloseDate = dCloseDateFY2020Q4W13;
        testOpportunity2.CloseDate = dCloseDateFY2008Q2W1;
        testOpportunity3.CloseDate = dCloseDateFY2009Q1W13;
        testOpportunity4.CloseDate = dCloseDateFY2030Q4W13;
        
        
        // Add to opportunity array
        lstOpp.add(testOpportunity1);
        lstOpp.add(testOpportunity2);
        lstOpp.add(testOpportunity3);
        lstOpp.add(testOpportunity4);


        // Test
        Test.startTest();
        
        mapFYCloseDateResults = setFYCloseDate(lstOpp);
        
        Test.stopTest();



        // Verify results
        system.debug('#### Verification of FY Close Date calculation . . .');       
        system.assertEquals('FY2020Q4W13', mapFYCloseDateResults.get(testOpportunity1.Id));
        system.assertEquals('FY2008Q2W1', mapFYCloseDateResults.get(testOpportunity2.Id));
        system.assertEquals('FY2009Q1W13', mapFYCloseDateResults.get(testOpportunity3.Id));
        system.assertEquals('FYQW', mapFYCloseDateResults.get(testOpportunity4.Id));
        
    }   // End testFYFoundAndNotFound()

    //Raymond 20091209: Added for CR2134
    static testMethod void testGetNearestQuarterEndDate() {
        
        //Ray: Was unable to create Period from code, getting "DML not allowed on Period" error, so
        //      old records are used in the test method. Utilizing fiscal year setting for year 2007.
        //      The following shows the fiscal period when this testmethod is created:
        //      Q1 - 2007-02-03 - 2007-05-04
        //      Q2 - 2007-05-05 - 2007-08-03
        //      Q3 - 2007-08-04 - 2007-11-02
        //      Q4 - 2007-11-03 - 2008-02-01
        
        
        Date periodStartDate = Date.newInstance(2006,11,4);
        Date periodEndDate = Date.newInstance(2008,2,2);
        
        Date testDate1 = Date.newInstance(2007,4,4);
        Date testCorrectEndDate1 = Date.newInstance(2007,5,4);
        
        Date testDate2 = Date.newInstance(2007,8,3);
        Date testCorrectEndDate2 = Date.newInstance(2007,11,2);
        
        String testCorrectEndDateString3 = testCorrectEndDate2.format();
                
        Test.startTest();
        //Retrieves all the Period of year 2007
        List<Period> periodList = [SELECT StartDate, EndDate FROM Period WHERE Type='Quarter' AND StartDate > :periodStartDate AND EndDate < :periodEndDate];
        
        system.debug('testGetNearestQuarterEndDate: periodList = ' + periodList);
        System.assert(periodList.size() == 4); //should retrieve 4 periods. If periods do not exists, need to change the test code criteria
        
        //test with date that is within a quarter. It should retrieves the end date of that quarter
        Date testResultDate1 = OpportunityUtils.getNearestQuarterEndDate(testDate1);
        System.assertEquals(testCorrectEndDate1, testResultDate1);
        
        //test with date that is the end date of the quarter. Should retrieves the end date of next quarter
        Date testResultDate2 = OpportunityUtils.getNearestQuarterEndDate(testDate2);
        System.assertEquals(testCorrectEndDate2, testResultDate2);
        
        //test to return string format of the date in 'MM/DD/YYYY' format
        String testResultDateString3 = OpportunityUtils.getNearestQuarterEndDateString(testDate2);
        System.assertEquals(testCorrectEndDateString3,testResultDateString3);
        
        /*
        Date testResultDate4 = OpportunityUtils.getNearestQuarterEndDate();
        String testResultDateString5 = OpportunityUtils.getNearestQuarterEndDateString();
        
        try {
            Date testResultDate5 = OpportunityUtils.getNearestQuarterEndDate(Date.newInstance(1,1,1111));
        }
        catch(Exception e) {
            System.assert(e.getMessage().contains('Unable to retrieve the nearest end-of-quarter'));    
        }
        */
        Test.stopTest();        

    }  
    
    //Raymond 20091209: Added for CR2134
    static testMethod void testGetNearestQuarterEndDate2() {
        
        //Ray: Was unable to create Period from code, getting "DML not allowed on Period" error, so
        //      old records are used in the test method. Utilizing fiscal year setting for year 2007.
        //      The following shows the fiscal period when this testmethod is created:
        //      Q1 - 2007-02-03 - 2007-05-04
        //      Q2 - 2007-05-05 - 2007-08-03
        //      Q3 - 2007-08-04 - 2007-11-02
        //      Q4 - 2007-11-03 - 2008-02-01
        
        
        Date periodStartDate = Date.newInstance(2006,11,4);
        Date periodEndDate = Date.newInstance(2008,2,2);
        
        Date testDate1 = Date.newInstance(2007,4,4);
        Date testCorrectEndDate1 = Date.newInstance(2007,5,4);
        
        Date testDate2 = Date.newInstance(2007,8,3);
        Date testCorrectEndDate2 = Date.newInstance(2007,11,2);
        
        String testCorrectEndDateString3 = testCorrectEndDate2.format();
                
        Test.startTest();
        //Retrieves all the Period of year 2007
        List<Period> periodList = [SELECT StartDate, EndDate FROM Period WHERE Type='Quarter' AND StartDate > :periodStartDate AND EndDate < :periodEndDate];
        
        system.debug('testGetNearestQuarterEndDate: periodList = ' + periodList);
        System.assert(periodList.size() == 4); //should retrieve 4 periods. If periods do not exists, need to change the test code criteria
        
        /*
        //test with date that is within a quarter. It should retrieves the end date of that quarter
        Date testResultDate1 = OpportunityUtils.getNearestQuarterEndDate(testDate1);
        System.assertEquals(testCorrectEndDate1, testResultDate1);
        
        //test with date that is the end date of the quarter. Should retrieves the end date of next quarter
        Date testResultDate2 = OpportunityUtils.getNearestQuarterEndDate(testDate2);
        System.assertEquals(testCorrectEndDate2, testResultDate2);
        
        //test to return string format of the date in 'MM/DD/YYYY' format
        String testResultDateString3 = OpportunityUtils.getNearestQuarterEndDateString(testDate2);
        System.assertEquals(testResultDateString3, testCorrectEndDateString3);
        */
        
        Date testResultDate4 = OpportunityUtils.getNearestQuarterEndDate();
        String testResultDateString5 = OpportunityUtils.getNearestQuarterEndDateString();
        
        try {
            Date testResultDate5 = OpportunityUtils.getNearestQuarterEndDate(Date.newInstance(1,1,1111));
        }
        catch(Exception e) {
            System.assert(e.getMessage().contains('Unable to retrieve the nearest end-of-quarter'));    
        }
        
        Test.stopTest();        

    }  
    
	/*
    static testMethod void testFYCloseDateforWin(){
   
        triggerexecutioncontroller.setSkipAllTriggers(true);
        GlobalVariables.BYPASS_ALL_LOT_OCEAN_CALCULATION  = true;
        
        List<Opportunity> testOpp = new List<Opportunity>();
        List<Opportunity> lstOpp = new List<Opportunity>();
        Account testAccount = new Account(Name='Test Account 10');
        insert testAccount;
        Date dCloseDate = System.Today()+10;
        Opportunity testOpportunity1 = new Opportunity(RecordTypeId='012300000004zf2', Name='Test Opportunity 1',  AccountId=testAccount.Id, Type='Deal/Bid Direct', CloseDate=dCloseDate, StageName='Plan - 1%');
        
        insert testOpportunity1;
        lstOpp = [SELECT id,Fiscal_Book_Date__c FROM Opportunity WHERE id=:testOpportunity1.id];
        testOpportunity1.StageName = 'Win - 100%';
        testOpportunity1.Competitor_Lost_To__c = 'CA';
        Test.startTest();
        //
        //testOpportunity1.Skip_Calculate_LOT_OCEAN__c=true;
         
        //Raymond: Added to skip LOT calculation
        triggerexecutioncontroller.setSkipAllTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(true); // 7.2
        update testOpportunity1;
        TriggerExecutionController.setSkipAccountTriggers(false); // 7.2
        
        
        Opportunity testOpp2 = [SELECT id,Fiscal_Book_Date__c,CloseDate FROM Opportunity WHERE id=:testOpportunity1.id];
        System.assertEquals(testOpp2.CloseDate, System.today());
        //System.assertNotEquals(lstOpp[0].Fiscal_Book_Date__c,testOpp2.Fiscal_Book_Date__c);
        Opportunity testOpp3 = new Opportunity(id =testOpportunity1.id,CloseDate = System.today()+20 );
        
        //Raymond: Added to skip LOT calculation
        //12.0 Start 
        //testOpp3.Skip_Calculate_LOT_OCEAN__c=true;
        //12.0 End
        
        update testOpp3;
        //Asserts that it is possible to update close date to future date after stage becomes close/win.
        Opportunity testOpp4 = [SELECT id,Fiscal_Book_Date__c,CloseDate FROM Opportunity WHERE id=:testOpportunity1.id];
        System.assertEquals(testOpp4.CloseDate, System.today()+20);
  
        Test.stopTest();
  } 
  
  //Raymond 20100828 - Original before the above is copied from Production 
  /*
    static testMethod void testFYCloseDateforWin(){
        List<Opportunity> testOpp = new List<Opportunity>();
        List<Opportunity> lstOpp = new List<Opportunity>();
        Account testAccount = new Account(Name='Test Account 10');
        insert testAccount;
        Date dCloseDate = System.Today()+10;
        Opportunity testOpportunity1 = new Opportunity(RecordTypeId='012300000004zf2', Name='Test Opportunity 1', AccountId=testAccount.Id, Type='Deal/Bid Direct', CloseDate=dCloseDate, StageName='Plan - 1%');
        
        insert testOpportunity1;
        lstOpp = [SELECT id,Fiscal_Book_Date__c FROM Opportunity WHERE id=:testOpportunity1.id];
        testOpportunity1.StageName = 'Win - 100%';
        Test.startTest();
        update testOpportunity1;        
        
        
        Opportunity testOpp2 = [SELECT id,Fiscal_Book_Date__c,CloseDate FROM Opportunity WHERE id=:testOpportunity1.id];
        System.assertEquals(testOpp2.CloseDate, System.today());
        System.assertNotEquals(lstOpp[0].Fiscal_Book_Date__c,testOpp2.Fiscal_Book_Date__c);
        Opportunity testOpp3 = new Opportunity(id =testOpportunity1.id,CloseDate = System.today()+20 );
        update testOpp3;
        //Asserts that it is possible to update close date to future date after stage becomes close/win.
        Opportunity testOpp4 = [SELECT id,Fiscal_Book_Date__c,CloseDate FROM Opportunity WHERE id=:testOpportunity1.id];
        System.assertEquals(testOpp4.CloseDate, System.today()+20);
        
        Test.stopTest(); 
    } 
    */
    
     public static Date getNearestHalfYearEndDate(string key,Date dateToCheck) {
        List<Period> periodList;
        system.debug(' Input Key   ' + key);
        Map<string,Date> yearPeriodMap = new Map<string,Date>();
        
        periodList = [SELECT EndDate,StartDate,Number FROM Period WHERE Type = 'Quarter' AND StartDate >= :dateToCheck order by StartDate LIMIT 3];
        
        List<Period> periodList1 = [SELECT EndDate,StartDate,Number FROM Period WHERE Type = 'Quarter' AND StartDate <= :dateToCheck order by StartDate desc LIMIT 1];
        
        if(periodList1 != null){
            periodList.add(periodList1.get(0));
        }
        
        //periodList = [SELECT EndDate,StartDate,Number FROM Period WHERE Type = 'Quarter' AND StartDate <= :dateToCheck AND EndDate >= :dateToCheck];
        
        if(periodList.size() < 1) {
            throw new dellUtil.DellException('Unable to retrieve the nearest end-of-quarter date for ' + dateToCheck + '. Please ensure that the Fiscal Year is configured correctly.');
        }
       // for(Period perd : periodList ){
        //  system.debug('??????????????????    ' + perd.StartDate + '  ????????????   ' + perd.EndDate  + perd.Number);    
       // }
        for(Period perd : periodList ){
            //put in map the start dates and end dates of the half year
            
            string keyStart = perd.EndDate.year()+String.valueOf(perd.Number)+'StartDate' ;
            string keyEnd = perd.EndDate.year()+String.valueOf(perd.Number)+'EndDate' ;
            system.debug(' keyEnd   ' + keyEnd);
            yearPeriodMap.put(keyStart,perd.StartDate);
            yearPeriodMap.put(keyEnd,perd.EndDate);
        }
        
        
        
        return yearPeriodMap.get(key);
    }
    
    //v10.0 - start
    public static Date getCurrentFiscalYearDate(string key) {
        List<Period> periodList;
        system.debug(' Input Key = Quarter' + key);
        /*11.0 
        Map<string,Date> yearPeriodMap = new Map<string,Date>();
        
        periodList = [SELECT EndDate,StartDate,Number FROM Period WHERE Type = 'Quarter' AND StartDate = THIS_FISCAL_YEAR];
        
        //List<Period> periodList1 = [SELECT EndDate,StartDate,Number FROM Period WHERE Type = 'Quarter' AND StartDate <= :dateToCheck order by StartDate desc LIMIT 1];
        
        //if(periodList1 != null){
       //     periodList.add(periodList1.get(0));
       // }
        
        //periodList = [SELECT EndDate,StartDate,Number FROM Period WHERE Type = 'Quarter' AND StartDate <= :dateToCheck AND EndDate >= :dateToCheck];
        
        if(periodList.size() < 1) {
            throw new dellUtil.DellException('Unable to retrieve the nearest end-of-quarter date for year ' + System.Today().Year() + '. Please ensure that the Fiscal Year is configured correctly.');
        }
       // for(Period perd : periodList ){
        //  system.debug('??????????????????    ' + perd.StartDate + '  ????????????   ' + perd.EndDate  + perd.Number);    
       // }
       
        for(Period perd : periodList ){
            //put in map the start dates and end dates of the half year
            
            string keyStart = String.valueOf(perd.Number)+'StartDate' ;
            string keyEnd = String.valueOf(perd.Number)+'EndDate' ;
            system.debug(' keyEnd   ' + keyEnd);
            yearPeriodMap.put(keyStart,perd.StartDate);
            yearPeriodMap.put(keyEnd,perd.EndDate);
        }
        */

        //11.0
        if (allYearPeriodMap == null) getAllCurrentFYDate(System.Today());
        key = 'Quarter'+key;        
        if(!allYearPeriodMap.containsKey(key)) {
            throw new dellUtil.DellException('Unable to retrieve the nearest end-of-quarter date for year ' + System.Today().Year() + '. Please ensure that the Fiscal Year is configured correctly.');
        }
        //11.0-end
        
        return allYearPeriodMap.get(key);
    }
    
    //v10.0 - end
    
    public static Date getFYStartAndEndDate(string key,Date dateToCheck) {
            List<Period> periodList;
            
            /* 11.0 
            Map<string,Date> yearPeriodMap = new Map<string,Date>();
                    
            periodList = [SELECT EndDate,StartDate,Number FROM Period WHERE Type = 'Year' AND StartDate <= :dateToCheck order by StartDate desc LIMIT 1];
            //periodList = [SELECT EndDate,StartDate,Number FROM Period WHERE Type = 'Quarter' AND StartDate <= :dateToCheck AND EndDate >= :dateToCheck];
            
            if(periodList.size() < 1) {
                throw new dellUtil.DellException('Unable to retrieve the nearest end-of-quarter date for ' + dateToCheck + '. Please ensure that the Fiscal Year is configured correctly.');
            }
            
            for(Period perd : periodList ){
                //put in map the start dates and end dates of the half year
                string keyStart ='StartDate' ;
                string keyEnd = 'EndDate' ;
                yearPeriodMap.put(keyStart,perd.StartDate);
                yearPeriodMap.put(keyEnd,perd.EndDate);
            }
            */

            //11.0
            if (allYearPeriodMap == null) getAllCurrentFYDate(System.Today());
            key = 'Yearnull'+key;            

            if(!allYearPeriodMap.containsKey(key)) {
                throw new dellUtil.DellException('Unable to retrieve the nearest end-of-quarter date for ' + dateToCheck + '. Please ensure that the Fiscal Year is configured correctly.');
            }
            
            return allYearPeriodMap.get(key);
        }

    //11.0
    public static Map<String, Date> getAllCurrentFYDate (Date dateToCheck) {

        allYearPeriodMap = new Map<String, Date>();
                    
        for (Period perd: [SELECT EndDate, StartDate, Number, Type FROM Period WHERE StartDate  = THIS_FISCAL_YEAR OR (StartDate <= :dateToCheck AND EndDate >= :dateToCheck)]) {
            string keyStart = perd.Type+String.valueOf(perd.Number)+'StartDate' ;
            string keyEnd = perd.Type+String.valueOf(perd.Number)+'EndDate' ;
            allYearPeriodMap.put(keyStart, perd.StartDate);
            allYearPeriodMap.put(keyEnd, perd.EndDate);
            System.debug('### '+ keyStart);
        }
        
        return allYearPeriodMap;
    }
    //11.0-end
    
}   // End global class OpportunityUtils