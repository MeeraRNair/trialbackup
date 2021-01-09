public with sharing class CertificationTracker_CurrentQTR_FY 
{
public static map<ID, String> setFYxDate(List<Certification_Tracker__c> Certifications) 
{
    system.debug('#### In testApexClass.setFYxDate() . . . ');
    //CurrentQTR
    //Varaible Declaraion
    Integer iInputSize=0;
    String sFYCloseDate;
    Integer iQuarter;
    String sQuarter;
    Integer intxYear;
    String strxYear;
    Integer iFiscalYear;
    String sFiscalYear;
    Date quarterStartDate;
    String sErrorMsg = '';
    Integer iCloseYear = 0;
    String sCloseYear = '';
    Integer iCounter=1;
    Integer minCloseYearInt;
    String minCloseYearStr = '';
    String str;

    Integer maxCloseYearInt = 0;

    Map<ID, String> mapIdFYxDate = new Map<ID, String>();              
    Set<String> setxYearStr = new Set<String>();
    Set<Id> setFYSId = new Set<Id>();
    
    map<String, FiscalYearSettings> mapFYInfo = new map<String, FiscalYearSettings>();
    map<String, map<Integer, Period>> mapFYQTRInfo = new map<String, map<Integer, Period>>();
    
    // Get the size of the CetificationList and set the error message
        iInputSize = Certifications.size();                
        if (iInputSize > 1) 
        {
            sErrorMsg = 'Fiscal year information does not exist for one or more certifications in this set';
        }

        else 
        {
            sErrorMsg = 'Fiscal year information does not exist for this book date';
        }
        // Find minimum and maximum close years, based on current date
        
            Date dCloseDate = date.today(); 
            //Date dCloseDate = date.newinstance(2010,12,1); //to hard code different dates.
            iCloseYear = dCloseDate.year();    
        
                minCloseYearInt = iCloseYear; 
                maxCloseYearInt = iCloseYear+1;    
        for (Integer m=minCloseYearInt; m<=maxCloseYearInt; m++) 
        {
            sCloseYear = String.valueof(m); 
            setxYearStr.add(sCloseYear);          
        }   
    
           system.debug('#### Array of Fiscal Years = ' + setxYearStr);
        
        // Create a map of fiscal years, and start and end dates.
        for (FiscalYearSettings indFYS : [select Id, Name, StartDate, EndDate from FiscalYearSettings where YearType = 'Custom' and Name in :setxYearStr]) 
        {                                                   
            // Add record IDs to set of unique values
            setFYSId.add(indFYS.Id);
            // Create a map of fiscal year information
            mapFYInfo.put(indFYS.Name, indFYS);
        }   // for(FiscalYearSettings indFYS : [SOQL]) 
        system.debug('#### Array of FY with start/snd dates = ' + mapFYInfo);
        // If no fiscal years are found in the system, throw an exception
        if (setFYSId.size() > 0) 
        {
            // Create maps of fiscal years and quarters, and fiscal years 
            for (Period indPeriod : [select Id, FiscalYearSettings.Name, Number, Type, StartDate, EndDate from Period where FiscalYearSettingsId in :setFYSId and Type = 'Quarter']) 
            {                
                // Create a map of fiscal year and quarter information
                if (indPeriod.Type == 'Quarter') 
                {        
                    Period dtStartEndDates = new Period(StartDate = indPeriod.StartDate, EndDate = indPeriod.EndDate);                            
                    // Get the map associated to fiscal year
                    map<Integer, Period> mapQP = mapFYQTRInfo.get(indPeriod.FiscalYearSettings.Name);
                        
                    if (mapQP == null) 
                    {
                        mapQP = new map<Integer, Period>();
                    }        
                    mapQP.put(indPeriod.Number, dtStartEndDates);        
                    mapFYQTRInfo.put(indPeriod.FiscalYearSettings.Name, mapQP);        
                }   // if (indPeriod.Type == 'Quarter')                     
            }   // End for (Period indPeriod : [SOQL])
        }   // End if (setFYSId.size() > 0)

// Loop through the Certification Trackers, and set the FYxDate
        for (Certification_Tracker__c tracker : Certifications) // 
        {                        
            //initialize the values of fiscal year and quarter
            sFiscalYear='';
            sQuarter='';            

            date xdate = date.today();
            //Date xdate= date.newinstance(2010,12,1); //to hard code different dates
            intxYear = (Integer)xDate.year();             
            intxYear = (Integer)xdate.year();
            strxYear = String.valueOf(intxYear); 

            // Get start and end dates corresponding to xYear by quering tble[FiscalYearSettings]. 
            FiscalYearSettings FYStartEndDates =  mapFYInfo.get(strxYear);
            if(FYStartEndDates != null)
            {
                // Calculate the fiscal year
                if (xdate > FYStartEndDates.EndDate) 
                //if (tracker.QTR_Updated_Date__c > date.today()) 
                {
                    iFiscalYear = intxYear + 1;
                }        
                else 
                {
                    iFiscalYear = intxYear;
                }
                sFiscalYear = String.valueOf(iFiscalYear);
                system.debug('#### Fiscal Year = ' + sFiscalYear);            
                  // Determine the quarter that the xDate falls into
                map<Integer, Period> mapQtrStartEndDates = mapFYQTRInfo.get(sFiscalYear);
                if (mapQtrStartEndDates != null && mapQtrStartEndDates.size() > 0) 
                {
                    iQuarter = 0;
                    for (Integer i=1; i<=mapQtrStartEndDates.size(); i++) 
                    {        
                        Period StartEndRange = mapQtrStartEndDates.get(i);                    
                       // if (tracker.QTR_Updated_Date__c >= StartEndRange.StartDate && tracker.QTR_Updated_Date__c<= StartEndRange.EndDate) 
                        if (xdate >= StartEndRange.StartDate && xdate <= StartEndRange.EndDate) 
                        {
                            iQuarter = i;
                            quarterStartDate = StartEndRange.StartDate; 
                            break;
                        }                    
                    }
                    sQuarter = String.valueOf(iQuarter);
                }                            
                 
            } 
            //format for currentQTR
            sFYCloseDate = 'FY' + sFiscalYear.SubString(2,4) + ' - Q' + sQuarter;
            system.debug('#### Fiscal Year Close Date = ' + sFYCloseDate);
            //if(tracker.QTR_Updated_Date__c != null)
            //{
                tracker.Current_QTR__c = sFYCloseDate;
            //}
            //else
            //{
            //        tracker.Current_QTR__c = '';
            //}
            mapIdFYxDate.put(tracker.Id,sFYCloseDate);                                  
        } 
return mapIdFYxDate;
}   
}