/*
REVISION HISTORY
================
Version         Author          Date                    Release#        CR#             Description
-------         ------          ----                    --------        ---             -----------
1.0             TK Chin                                 13.10                           Maintenance: Simplification project. 
1.1             TK Chin         17-Apr-2013             14.5            8202            Add Search.
1.2             TK Chin         17-Apr-2013             14.5            8203            Add Next Steps.
1.3             TK Chin         18-Jun-2013             14.5                            Post-release changes requested.
2.0             Bikram          4-Jan-2014              15.03           8977            Search All Open Criteria added where Search Criteria can be saved and viewed   
2.1             Meghana         4-Jan-2014              15.03           8973            Comment use of Verifiable Outcome field
3.0             Ragu            05-Oct-2014             15.10           10496           GlobalVariables.SKIP_ALL_OPP_TRIGGERS is replaced with TriggerExecutionController.setSkipOpportunityTriggers().
4.0             Kokila          28-Sep-2016                             13528           To Remove references of SecureWorks 
5.0				Emily			21-Mar-2018				FY19-DCE-0502	15540			Field Trip clean up for Opportunity
*/
public with sharing class VFCntrlr_MassUpdateOpportunitiesPage {

    //Version 1.1
    public String SearchAccountID { get; set; }
    public String SearchAccountName { get; set; }
    public String SearchOpportunityName { get; set; }
    public Opportunity SearchOpp { get; set; }
    public Opportunity SearchOpp2 { get; set; }
    public String SearchStageName { get; set; }
    public String SearchStartingFiscalBookDate { get; set; }
    public String SearchEndingFiscalBookDate { get; set; }
    public string soql { get; set; }
    public String errorList {get;set;}

    boolean openCriteriaDeleted = false;
    public boolean saveFlag{get;set;}
    public boolean showHide {get;set;}
    
    public List<opptyWrapper> oppWrapperList {get;set;}
    public Map<ID,String> oppErrorMap {get;set;}
    public Map<ID,Opportunity> oppErrorOppty_Map {get;set;}
    //v5.0 public Map<ID,String> Oppty_NewDescription {get;set;}

    //Boolean flags to display the PopUp Windows
    public boolean savesearchflag {get;set;}
    public boolean displayPopup{get;set;} // to open pop-up when save search is clicked
    public boolean displayPopUp1 {get;set;} // to open pop-up when no search criteria is entered
    public boolean displayPopUpPrevious {get;set;} // to open pop-up when previous search is clicked
    public String searchName {get;set;}
    //public String searchName_EditMode {get;set;}        
    private String Selected_searchName = '';      
    public boolean displayPopupOk {get; set;} // to open pop-up when save is successful
    public boolean displayError {get;set;} // to open error pop-up
    public boolean showSectionCollapsed{get;set;} // to expand and collapse the search criteria page block
    public boolean NoRecordFlag {get;set;} // flag to rerender when no record is searched.
    public boolean SuccessMsg {get;set;} // flag to display the success message
    public boolean displayError2 {get;set;} // flag to display error message when common search name is null
    
    
    //Added for CRQ - 0890 
    boolean showCancelBtnAndFilterName ; //flag to display the Common Filter Name & Cancel Button 
   // public Boolean numericError {get;set;}
    public boolean getshowCancelBtnAndFilterName(){
        return showCancelBtnAndFilterName;
    }
    
    public Integer totalSize{
        get{
            return (OpenOpportunities.size());
        }
        set;
    }   
    //public String UserInfo {get;set;}

    public List<Opportunity> OpenOpportunities { get; set; }
    public List<RecordType> rtRunRate { get; set; }
    public List<Opportunity> PageRecords { get; set; }
    public String strRecordsToSave { get; set; }
    //public boolean hasMessage {get; set;}
    Boolean msg=false;
    public Integer PageSize { get; set; }
    public Integer PageNumber { get; set; }
    
     // wrapper class used to display display the success/error message in column  
    public class opptyWrapper{
        public Opportunity opp {get;set;}
        public String errorMsg {get;set;}

        public opptyWrapper(Opportunity o,String err){
            opp =o;
            errorMsg = err;
        }
    }

    public Integer PageActualSize {
        get {
            if (PageNumber == PageTotal) {
                system.debug('Open oppty size'+OpenOpportunities.size());

            if (math.mod(OpenOpportunities.size(), PageSize) > 0) {
                return math.mod(OpenOpportunities.size(), PageSize);
            }
            else {
                return PageSize;
            }
            }
            else {
                return PageSize;
            }
        }
        set;
    }

    public Integer PageTotal {
        get {
            if (math.mod(OpenOpportunities.size(), PageSize) > 0) {
                return (OpenOpportunities.size()/PageSize) + 1;
            }
            else {
                return (OpenOpportunities.size()/PageSize);
            }
        }
        set;
    }

    public Integer PageNumber1 {
        get {
            if(PageNumber <= 2) {
                return 1;
            }
            else if(PageNumber == PageTotal) {
                return PageNumber - 2;
            }
            else {
                return PageNumber - 1;
            }
        }
        set;
    }

    public Integer PageNumber2 {
        get {
            if(PageNumber == 1) {
                return 2;
            }
            else if(PageNumber == PageTotal && PageTotal != 2) {
                return PageTotal - 1;
            }
            else {
                return PageNumber;
            }
        }
        set;
    }

    public Integer PageNumber3 {
        get {
            if(PageNumber == 1) {
                return 3;
            }
            else if(PageNumber == PageTotal) {
                return PageTotal;
            }
            else {
                return PageNumber + 1;
            }
        }
        set;
    }

    public VFCntrlr_MassUpdateOpportunitiesPage() {
        system.debug('$$$DEBUG: In Constructor');
        //Version 1.1
        SearchOpp = new Opportunity();
        SearchOpp.Decision_Date__c = null;
        SearchOpp2 = new Opportunity();
        SearchOpp2.Decision_Date__c = null;

        //Version 1.3
        isSearchOverdue = false;
        oppErrorMap  = new Map<ID,String>();
        oppErrorOppty_Map  = new Map<ID,Opportunity>();

        //Get the 2 record type ids, and use in query as :rtRunRate[0].Id, :rtRunRate[1].Id
        rtRunRate = [SELECT Id FROM RecordType
        WHERE SobjectType = 'Opportunity' AND IsActive = true
        AND (Name = 'Run Rate Marketing' OR Name = 'Run Rate Opportunity')];
        editFlag = false;
        NoRecordFlag = false;
        LoadOpenOpportunities();
        SetPageSize(25);
        SetPageNumber(1);

        //initializing the boolean flags
        displayPopupOk = false;
        
        showHide = false;
        
        showSectionCollapsed = true;
        SuccessMsg = false;
        totalSize =0;
        displayError2 = false;
        savesearchflag = false;
       
        showCancelBtnAndFilterName = false;
    }

    //public class testException extends Exception {}
    //Version 1.1
    
    public String accountIdError  {get;set;}
    public void chkAffinityId(){
        List<String> accIdList = new List<String>();
        accountIdError  ='';
        
        // checking if the Affinity Account ID length = 9 or 10 
            if(SearchAccountID != '' && SearchAccountID != NULL ){
                List<String> AccountIds = SearchAccountID.split(';');

                errorList = '';
               // numericError = false;
                for(String AccountID :AccountIds ){
                   // AccountID = AccountID.trim();
                     // AccountId = String.escapeSingleQuotes(AccountID);
                    //if(AccountId.trim().length() != 0){
                    //AccountID = AccountID.replaceAll( '\\s+', '');
                    if(AccountId.trim().length() == 9 || AccountId.trim().length()  == 10 ){
                            system.debug('$$$ Inside IF trim'); 
                            Pattern numberFormat = Pattern.Compile('[0-9]*'); 
                            Matcher numberMatch = numberFormat.matcher(AccountID.trim());
                            if(numberMatch.Matches()){
                              accIdList.add(AccountId.trim());
                            }else{
                             // numericError = true;
                                 system.debug('$$$$ Inside ELSE trim');      
                                errorList = errorList + AccountId + ',';                             
                            }  
                    }else{ 
                        system.debug('$$$ Inside ELSE OUT trim');
                        errorList = errorList + AccountId + ',';                        
                    }
                  
                }               
                    
                Map<String,Account> accMap = new Map<String,Account>();
                for(Account a:[Select Id,Account_ID__c from Account where Account_ID__c IN: accIdList]){
                    accMap.put(a.Account_ID__c,a);
                }
                for(String a: accIdList){
                    if(!accMap.containsKey(a)){
                        accountIdError = accountIdError + a + ','; 
                    }
                }
                system.debug('*****'+errorList);                  
            } 
    }
    public void SearchOpenOpportunities(){
        system.debug('$$$DEBUG: In SearchOpenOpportunities');
        showSectionCollapsed = true; // used for collapsing the section while navigating 
        errorList = '';
        NoRecordFlag = false;
        SuccessMsg = false; 
        if (oppErrorMap != null)
            oppErrorMap.clear(); 
        showHide = false;         
        
        try {
            
            chkAffinityId();
            
            if(errorList == ''  || isSearchOverdue == true){      //(errorList == null || errorList == '') && (accountIdError == null || accountIdError == '')){
                LoadOpenOpportunities();
            }else{
                OpenOpportunities.clear();
                //NoRecordFlag = true;
            }
            SetPageNumber(1);
            //throw new testException('try char >');
            //throw new testException('try html encode &gt;');
        }
        catch (Exception ex) {
            isSearchOverdue = false;
            ApexPages.addMessages(ex);
            //StrStatusMsg = String.valueOf(ex.getLineNumber());
        }
        //String str = 'try replaceAll html encode to char &gt;';
        //str = str.replaceAll('&gt;', '>');
        //ApexPages.Message msgChar = new ApexPages.Message(ApexPages.Severity.ERROR, 'try char >');
        //ApexPages.Message msgHEncode = new ApexPages.Message(ApexPages.Severity.ERROR, 'try html encode &gt;');
        //ApexPages.Message msgReplace = new ApexPages.Message(ApexPages.Severity.ERROR, str);
        //ApexPages.addMessage(msgChar);
        //ApexPages.addMessage(msgHEncode);
        //ApexPages.addMessage(msgReplace);
        //StrStatusMsg = 'line number:' + StrStatusMsg;
    }

    //Version 1.3 
    public boolean isSearchOverdue { get; set; }
    public void SearchOverdueOpportunities() {
    
        system.debug('$$$DEBUG: In SearchOverdueOpportunities');
        showCancelBtnAndFilterName = false;
      
        showSectionCollapsed = true;
        isSearchOverdue = true;
        SearchOpenOpportunities();
        isSearchOverdue = false;
        errorList = '';
    }

    public PageReference goAllOpenOpportunities() {
        system.debug('$$$DEBUG: In goAllOpenOpportunities');
        PageReference pg = new PageReference('/apex/VfMassUpdateOpportunitiesPage');
        pg.setRedirect(true);
        return pg;
    }

    public void LoadOpenOpportunities() {
        system.debug('$$$DEBUG: In LoadOpenOpportunities');
        //Version 1.1 - Add local variable and construct SOQL WHERE for search fields
        String searchCriteria = '';
        
        //Version 1.3 - Do not apply search criteria when Overdue button is clicked
        if(!isSearchOverdue) {
            if(String.isNotBlank(SearchAccountID)) {
            
                //Version 1.3 - allow comma separated value for multi search
                //SearchAccountID = SearchAccountID.replaceAll(' ', '');
                String AccountsToSearch ;
                
                if (errorList != '' && errorList != NULL)
                    AccountsToSearch = errorList;
                else
                    AccountsToSearch = SearchAccountID;
                
                List<String> accIDs = new List<String>();
                if (AccountsToSearch != null && AccountsToSearch != '')
                    accIDs = AccountsToSearch.split(';', 0);
                StrStatusMsg = '';
                String tmpIDs = '';
                for(String strAccID : accIDs) {
                    //  StrStatusMsg = StrStatusMsg + '$-' + strAccID.length();
                    strAccID = strAccID.trim();
                    strAccID = String.escapeSingleQuotes(strAccID);
                    if(strAccID.length() > 0) {
                        if(tmpIDs == '') {
                            tmpIDs = '\'' + strAccID + '\'';
                        }
                        else {
                            tmpIDs = tmpIDs + ',\'' + strAccID + '\'';  
                        }
                    }
                }
                if(tmpIDs.length() != 0) {
                    searchCriteria = searchCriteria + 'AND a.Account_ID__c IN (' + tmpIDs + ') ';
                }
                //searchCriteria = searchCriteria + 'AND a.Account_ID__c = \'' + String.escapeSingleQuotes(SearchAccountID) + '\' ';
            }
            if(String.isNotBlank(SearchAccountName)) {

                //Version 1.3 - allow comma separated value for multi search
                //SearchAccountName = SearchAccountName.replaceAll(' ', '');
                List<String> accNames = SearchAccountName.split(';', 0);
                StrStatusMsg = '';
                String tmpAccNames = '';
                for(String strAccName : accNames) {
                    //  StrStatusMsg = StrStatusMsg + '$-' + strAccName.length();
                    strAccName = strAccName.trim();
                    if(strAccName.length() > 0) {
                        if(tmpAccNames == '') {
                            tmpAccNames = 'a.Name LIKE \'%' + String.escapeSingleQuotes(strAccName) + '%\'';
                        }
                        else {
                            tmpAccNames = tmpAccNames + ' OR a.Name LIKE \'%' + String.escapeSingleQuotes(strAccName) + '%\'';
                        }
                    }
                }
                if(tmpAccNames.length() != 0) {
                    searchCriteria = searchCriteria + 'AND (' + tmpAccNames + ') ';
                }
                //searchCriteria = searchCriteria + 'AND a.Name LIKE \'%' + String.escapeSingleQuotes(SearchAccountName) + '%\' ';
            }
            if(String.isNotBlank(SearchOpportunityName)) {

                //Version 1.3 - allow comma separated value for multi search
                //SearchOpportunityName = SearchOpportunityName.replaceAll(' ', '');
                List<String> oppNames = SearchOpportunityName.split(';', 0);
                StrStatusMsg = '';
                String tmpOppNames = '';
                for(String strOppName : oppNames) {
                    //StrStatusMsg = StrStatusMsg + '$-' + strOppName.length();
                    strOppName = strOppName.trim();
                    if(strOppName.length() > 0) {
                        if(tmpOppNames == '') {
                            tmpOppNames = 'o.Name LIKE \'%' + String.escapeSingleQuotes(strOppName) + '%\'';
                        }
                        else {
                            tmpOppNames = tmpOppNames + ' OR o.Name LIKE \'%' + String.escapeSingleQuotes(strOppName) + '%\'';
                        }
                    }
                }
                if(tmpOppNames.length() != 0) {
                    searchCriteria = searchCriteria + 'AND (' + tmpOppNames + ') ';
                }
                //searchCriteria = searchCriteria + 'AND o.Name LIKE \'%' + String.escapeSingleQuotes(SearchOpportunityName) + '%\' ';
            }
            // use a non-mandatory field instead of CloseDate
            if(SearchOpp.Decision_Date__c != null) {
                searchCriteria = searchCriteria + 'AND o.CloseDate = ' + 
                                String.valueOf(SearchOpp.Decision_Date__c.year()) + '-' + 
                                (Integer.valueOf(SearchOpp.Decision_Date__c.month()) >= 10 ? '' + SearchOpp.Decision_Date__c.month() : '0' + SearchOpp.Decision_Date__c.month()) + '-' +
                                (Integer.valueOf(SearchOpp.Decision_Date__c.day()) >= 10 ? '' + SearchOpp.Decision_Date__c.day() : '0' + SearchOpp.Decision_Date__c.day()) + ' ';
            }
            if(SearchStageName != null && SearchStageName != '--None--') {
                searchCriteria = searchCriteria + 'AND o.StageName = \'' + SearchStageName + '\' ';
            }
            if(SearchOpp.Solution_Type__c != null && SearchOpp.Solution_Type__c != '--None--') {
                searchCriteria = searchCriteria + 'AND o.Solution_Type__c = \'' + SearchOpp.Solution_Type__c + '\' ';
            }
            if(SearchOpp.Solution_Name__c != null && SearchOpp.Solution_Name__c != '--None--') {
                searchCriteria = searchCriteria + 'AND o.Solution_Name__c = \'' + SearchOpp.Solution_Name__c + '\' ';
            }
            // use a non-mandatory field instead of Owner
            if(SearchOpp2.Services_Sales_Owner__c != null) {
                searchCriteria = searchCriteria + 'AND o.Owner.Id = \'' + String.escapeSingleQuotes(SearchOpp2.Services_Sales_Owner__c) + '\' ';
            }
            if(SearchOpp.Services_Sales_Owner__c != null) {
                searchCriteria = searchCriteria + 'AND o.Services_Sales_Owner__c = \'' + String.escapeSingleQuotes(SearchOpp.Services_Sales_Owner__c) + '\' ';
            }
            if(String.isNotBlank(SearchStartingFiscalBookDate)) {
                SearchStartingFiscalBookDate = String.escapeSingleQuotes(SearchStartingFiscalBookDate);
                SearchStartingFiscalBookDate = SearchStartingFiscalBookDate.toUpperCase();
                SearchStartingFiscalBookDate = SearchStartingFiscalBookDate.replaceAll(' ', '');

                //get the normal date from fiscal year Period using FY provided
                Integer startFYear = Integer.valueOf(SearchStartingFiscalBookDate.substring(2, 4));
                //get the normal date from fiscal quarter Period using FiscalYearSettingsId and FQ provided
                Integer startFQtr = Integer.valueOf(SearchStartingFiscalBookDate.substring(5, 6));
                //use the FiscalYearSetting and fiscal quarter to get all fiscal weeks in the quarter.
                Integer startFWeek = Integer.valueOf(SearchStartingFiscalBookDate.substringAfterLast('W'));

                Date sfy = Date.newInstance(1999 + startFYear, 6, 5);
                List<Period> startFYearPeriod = [SELECT FiscalYearSettingsId FROM Period WHERE Type = 'Year'
                AND IsForecastPeriod = false
                AND StartDate <= :sfy AND EndDate >= :sfy LIMIT 1];

                if(startFYearPeriod.size() == 1) { //add this so that if invalid fiscal year is entered, it returns no results.

                    //added for corrrection to resolve defect 68007 because every quarter starts with week 01 
                    //instead of incrementing uptil 54.
                    List<Period> startFQtrPeriod = [SELECT StartDate, EndDate FROM Period WHERE Type = 'Quarter'
                    AND IsForecastPeriod = false
                    AND FiscalYearSettingsId = :startFYearPeriod[0].FiscalYearSettingsId
                    AND Number = :startFQtr LIMIT 1];

                    if(startFQtrPeriod.size() == 1) { //add this so that if no such quarter found, it returns no results.

                        List<Period> startFWeekPeriod = [SELECT StartDate FROM Period WHERE Type = 'Week'
                        AND IsForecastPeriod = false
                        AND FiscalYearSettingsId = :startFYearPeriod[0].FiscalYearSettingsId
                        AND StartDate >= :startFQtrPeriod[0].StartDate
                        AND EndDate <= :startFQtrPeriod[0].EndDate
                        ORDER BY Number LIMIT 54];
                        //AND Number <= :startFWeek ORDER BY Number DESC LIMIT 1];

                        if(startFWeekPeriod.size() > 0) { // add this so that if no weeks found, it returns no results.

                            if(startFWeek > 13) {
                                //this is added so if some user think it is a leap year but actually not, fall out to 13 instead of 14.
                                if(startFWeekPeriod.size() < startFWeek) {
                                    startFWeek = startFWeek - 1;
                                }
                            }

                            try {
                                //use the StartDate to filter for CloseDate range. Fiscal_Book_Date__c is not used because it is a formula(text).                                                  
                                searchCriteria = searchCriteria + 'AND o.CloseDate >= ' + 
                                String.valueOf(startFWeekPeriod[startFWeek - 1].StartDate.year()) + '-' +
                                (Integer.valueOf(startFWeekPeriod[startFWeek - 1].StartDate.month()) >= 10 ? '' + startFWeekPeriod[startFWeek - 1].StartDate.month() : '0' + startFWeekPeriod[startFWeek - 1].StartDate.month()) + '-' +
                                (Integer.valueOf(startFWeekPeriod[startFWeek - 1].StartDate.day()) >= 10 ? '' + startFWeekPeriod[startFWeek - 1].StartDate.day() : '0' + startFWeekPeriod[startFWeek - 1].StartDate.day()) + ' ';
                            }
                            catch (Exception ex) {
                                //if this runs, one of the weeks in startFWeek list is missing.
                                //system unable to retrieve the fiscal week and treats the fiscal date as invalid.
                                searchCriteria = searchCriteria + 'AND o.StageName = \'noSuchFiscalWeek\'';
                            }
                        }
                        else {
                            // add this so that if no weeks found, it returns no results.
                            searchCriteria = searchCriteria + 'AND o.StageName = \'noFiscalWeekFound\'';
                        }
                    }
                    else {
                        //add this so that if no such quarter found, it returns no results.
                        searchCriteria = searchCriteria + 'AND o.StageName = \'noSuchFiscalQuarter\'';
                    }
                }       
                else {
                    //add this so that if invalid fiscal year is entered, it returns no results.
                    searchCriteria = searchCriteria + 'AND o.StageName = \'noSuchFiscalYear\'';
                }        
            }
            if(String.isNotBlank(SearchEndingFiscalBookDate)) {
                SearchEndingFiscalBookDate = String.escapeSingleQuotes(SearchEndingFiscalBookDate);
                SearchEndingFiscalBookDate = SearchEndingFiscalBookDate.toUpperCase();
                SearchEndingFiscalBookDate = SearchEndingFiscalBookDate.replaceAll(' ', '');

                Integer endFYear = Integer.valueOf(SearchEndingFiscalBookDate.substring(2, 4));
                Integer endFQtr = Integer.valueOf(SearchEndingFiscalBookDate.substring(5, 6));
                Integer endFWeek = Integer.valueOf(SearchEndingFiscalBookDate.substringAfterLast('W'));

                Date efy = Date.newInstance(1999 + endFYear, 6, 5);
                List<Period> endFYearPeriod = [SELECT FiscalYearSettingsId FROM Period WHERE Type = 'Year'
                AND IsForecastPeriod = false
                AND StartDate <= :efy AND EndDate >= :efy LIMIT 1];

                if(endFYearPeriod.size() == 1) { //add this so that if invalid fiscal year is entered, it returns no results.

                    List<Period> endFQtrPeriod = [SELECT StartDate, EndDate FROM Period WHERE Type = 'Quarter'
                    AND IsForecastPeriod = false
                    AND FiscalYearSettingsId = :endFYearPeriod[0].FiscalYearSettingsId
                    AND Number = :endFQtr LIMIT 1];

                    if(endFQtrPeriod.size() == 1) { //add this so that if no such quarter found, it returns no results.

                        List<Period> endFWeekPeriod = [SELECT StartDate, EndDate FROM Period WHERE Type = 'Week'
                        AND IsForecastPeriod = false
                        AND FiscalYearSettingsId = :endFYearPeriod[0].FiscalYearSettingsId
                        AND StartDate >= :endFQtrPeriod[0].StartDate
                        AND EndDate <= :endFQtrPeriod[0].EndDate
                        ORDER BY Number LIMIT 54];
                        //AND Number <= :endFWeek ORDER BY Number DESC LIMIT 1];

                        if(endFWeekPeriod.size() > 0) { // add this so that if no weeks found, it returns no results.

                            if(endFWeek > 13) {
                                //this is added so if some user think it is a leap year but actually not, fall out to 13 instead of 14.
                                if(endFWeekPeriod.size() < endFWeek) {
                                    endFWeek = endFWeek - 1;
                                }
                            }

                            try {
                                searchCriteria = searchCriteria + 'AND o.CloseDate <= ' + 
                                String.valueOf(endFWeekPeriod[endFWeek - 1].EndDate.year()) + '-' +
                                (Integer.valueOf(endFWeekPeriod[endFWeek - 1].EndDate.month()) >= 10 ? '' + endFWeekPeriod[endFWeek - 1].EndDate.month() : '0' + endFWeekPeriod[endFWeek - 1].EndDate.month()) + '-' +
                                (Integer.valueOf(endFWeekPeriod[endFWeek - 1].EndDate.day()) >= 10 ? '' + endFWeekPeriod[endFWeek - 1].EndDate.day() : '0' + endFWeekPeriod[endFWeek - 1].EndDate.day()) + ' ';
                            }
                            catch (Exception ex) {
                                //if this runs, one of the weeks in startFWeek list is missing.
                                //system unable to retrieve the fiscal week and treats the fiscal date as invalid.
                                searchCriteria = searchCriteria + 'AND o.StageName = \'noSuchFiscalWeek\'';
                            }
                        }
                        else {
                            // add this so that if no weeks found, it returns no results.
                            searchCriteria = searchCriteria + 'AND o.StageName = \'noFiscalWeekFound\'';
                        }
                    }
                    else {
                        //add this so that if no such quarter found, it returns no results.
                        searchCriteria = searchCriteria + 'AND o.StageName = \'noSuchFiscalQuarter\'';
                    }
                }
                else {
                    //add this so that if invalid fiscal year is entered, it returns no results.
                    searchCriteria = searchCriteria + 'AND o.StageName = \'noSuchFiscalYear\'';
                }        
            }

        }

        //Version 1.1 - Add criteria to exclude acquisition opportunities
        searchCriteria = searchCriteria + 
        'AND o.Source_System__c NOT IN (' +
        '\'AppAssure SFDC\', ' + 
        '\'Boomi SFDC\', ' +
        '\'Boomi SFDC-Dell Referral\', ' +
        '\'Boomi SFDC-Organic\', ' +
        '\'KACE\', ' +
        '\'Legacy Compellent\', ' +
        '\'Legacy Force10\', ' +
        '\'Legacy Perot\', ' +
        '\'Legacy SonicWALL\', ' +
        '\'Legacy Wyse\', ' +
        '\'PSM Portal\', ' +
        //Start v4.0 - To remove references of SecureWorks
        /*'\'SecureWorks SFDC\', ' +
        '\'SecureWorks SFDC-Dell Referral\', ' +
        '\'SecureWorks SFDC-Organic\', ' +
        '\'SecureWorks SFDC-Shared Dell/SecureWorks\', ' +*/
        //End v4.0 - To remove references of SecureWorks
        '\'SEP SFDC-Cloud Services Dell Referral\', ' +
        '\'SEP SFDC-Cloud Services Organic\', ' +
        '\'SEP SFDC-DCBA Dell Referral\', ' +
        '\'SEP SFDC-DCBA Organic\', ' +
        '\'Quest SFDC\') ';

        //Version 1.0 - Limit opportunities to current fiscal year
        Period fy = [SELECT StartDate, EndDate FROM Period WHERE Type = 'Year'
        AND StartDate <= TODAY AND EndDate >= TODAY LIMIT 1];
        Date fyStartDate = fy.StartDate;
        searchCriteria = searchCriteria + 'AND (o.CloseDate >= ' + 
        String.valueOf(fy.StartDate.year()) + '-' +
        (Integer.valueOf(fy.StartDate.month()) >= 10 ? String.valueOf(fy.StartDate.month()) : '0' + String.valueOf(fy.StartDate.month())) + '-' +
        (Integer.valueOf(fy.StartDate.day()) >= 10 ? String.valueOf(fy.StartDate.day()) : '0' + String.valueOf(fy.StartDate.day())) + ') ';

        //Version 1.0 - Get the 2 record type ids to use in soql
        rtRunRate = [SELECT Id FROM RecordType
        WHERE SobjectType = 'Opportunity' AND IsActive = true
        AND (Name = 'Run Rate Marketing' OR Name = 'Run Rate Opportunity')];
        searchCriteria = searchCriteria + 'AND o.RecordTypeId NOT IN (\'' + rtRunRate[0].Id + '\') ';

        //Version 1.3
        if(isSearchOverdue) {
            searchCriteria = searchCriteria + 'AND CloseDate < TODAY ';
        }

        //Version 1.1 - Use database.query for dynamic SOQL
        String soqlExisting = 'SELECT o.Id, o.Name, a.Name, o.StageName, o.CloseDate, o.Unweighted_Rev_Formula__c, ' +
        'o.Description, o.Probability, o.NextStep ' + //v5.0 o.New_Description__c,  ' + //, o.Verifiable_Outcome__c ' +
        'FROM Opportunity o, o.Account a ' +
        'WHERE o.CloseDate != null ' +
        'AND o.IsClosed != True ' +
        'AND o.IsDeleted != True ' +
        'AND o.IsWon != True ' +
        'AND o.StageName != \'Win - 100%\' ' +
        'AND o.StageName != \'Lost - Cancelled - 0%\' ' +
        'AND o.LOT_Large_Opportunity__c != True ' +
        'AND o.Eligible_for_Ocean__c != \'Yes\' ' +
        'AND o.Type != \'Run Rate\' ';
        String soqlOrder = ' ORDER BY o.CloseDate, o.Amount Desc LIMIT 250';

        String completeSOQL = soqlExisting + searchCriteria + soqlOrder;
        soql = completeSOQL;
        OpenOpportunities = Database.query(completeSOQL);

        /* Version 1.0 - Deprecated
        OpenOpportunities =
        [SELECT o.Id, o.Name, a.Name, o.StageName, o.CloseDate, o.Unweighted_Rev_Formula__c,
        o.Description, o.Probability, o.New_Description__c, o.NextStep, o.Verifiable_Outcome__c
        FROM Opportunity o, o.Account a
        WHERE o.CloseDate != null
        // AND o.CloseDate >= 2012-09-28
        // AND o.Deal_ID__c = '4359384'
        AND o.CloseDate >= :fyStartDate
        AND o.IsClosed != True
        AND o.IsDeleted != True
        AND o.IsWon != True
        AND o.StageName != 'Win - 100%'
        AND o.StageName != 'Lost - Cancelled - 0%'
        AND o.LOT_Large_Opportunity__c != True
        AND o.Eligible_for_Ocean__c != 'Yes'
        AND o.Type != 'Run Rate'
        AND o.RecordTypeId NOT IN (:rtRunRate[0].Id, :rtRunRate[1].Id)
        ORDER BY o.CloseDate, o.Amount Desc LIMIT 250];

        //OpenOpportunities  = getUserLevelOpenOpportunities(OpenOpportunities, UserInfo.getUserId());
        */
    }

    //public  List<Opportunity> getUserLevelOpenOpportunities(List<Opportunity> OpenOpportunities, string userId){
    //    List<Opportunity> userOpportunitiesList = new List<Opportunity>();
    //    List<Opportunity> userNewOpportunitiesList = new List<Opportunity>();
    //
    //    Map<string,Opportunity> userOpptyMap = new Map<string,Opportunity>();
    //
    //    List<UserRecordAccess> usrRecAccessRecords = new List<UserRecordAccess>();

    //    List<string> userOpptyIdList = new List<string>();

    //    for(Opportunity opp : OpenOpportunities){
    //        userOpptyMap.put(opp.Id , opp);
    //        userOpptyIdList.add(opp.Id);
    //    }

    //    system.debug('#### BEFORE USR RECORD ACCESS   ' + userOpptyIdList.size());
    //    string usrId = userId;
    //    usrRecAccessRecords = [SELECT RecordId, HasReadAccess,HasAllAccess,HasDeleteAccess, HasEditAccess, HasTransferAccess, MaxAccessLevel
    //                             FROM UserRecordAccess
    //                             WHERE UserId =:UserInfo.getUserId()//UserId =: UserInfo.getUserId()
    //                             AND RecordId in :  userOpptyIdList
    //                           ];

    // AND (HasAllAccess = 'true' OR HasDeleteAccess = 'true' OR HasEditAccess = 'true')

    //    for(UserRecordAccess ura : usrRecAccessRecords){
    //        if(userOpptyMap.containsKey(ura.RecordId)){
    //            if(ura.HasAllAccess == true || ura.HasDeleteAccess == true || ura.HasEditAccess == true)
    //                userNewOpportunitiesList.add(userOpptyMap.get(ura.RecordId));
    //        }
    //    }

    //    system.debug('#### After USR RECORD ACCESS   ' + userNewOpportunitiesList.size());
    //    return userNewOpportunitiesList;
    //}

    public void SetPageRecords() {
        system.debug('$$$DEBUG: In SetPageRecords');
        //LoadOpenOpportunities();
        List<opptyWrapper> successList = new List<opptyWrapper>();
        List<opptyWrapper> errorList = new List<opptyWrapper>();
        List<opptyWrapper> othersList = new List<opptyWrapper>();

        /*if (PageRecords != null) {
            PageRecords.clear();
            oppWrapperList.clear();
            // successList.clear();
        }
        else {
            PageRecords = new List<Opportunity>();
            oppWrapperList = new List<opptyWrapper>();
        }*/
        oppWrapperList = new List<opptyWrapper>();
        for (Integer i=((PageNumber*PageSize)-PageSize); i<(PageNumber*PageSize); i++) {
            if (i < OpenOpportunities.size()) {
                //PageRecords.add(OpenOpportunities[i]); 
                if(oppErrorMap.containsKey(OpenOpportunities[i].Id)){ 
                    oppWrapperList.add(new opptyWrapper(OpenOpportunities[i],oppErrorMap.get(OpenOpportunities[i].Id)));
                }else{          
                oppWrapperList.add(new opptyWrapper(OpenOpportunities[i],''));  
                }
            }                        
        }

        if(oppWrapperList.size() == 0){
            NoRecordFlag = true;            
        }
        showSectionCollapsed = true;
    }
    // added to retain the changes for the errored opportunities in Mass Update
    public void retainErroredRecords(){     
        system.debug('$$$DEBUG: In retainErroredRecords');
        for (opptyWrapper oppW : oppWrapperList ){      
            if(oppErrorMap.containsKey(oppW.opp.Id)){       
                if (oppErrorMap.get(oppW.opp.Id) != 'Record Saved'){
                    oppW.opp.StageName = oppErrorOppty_Map.get(oppW.opp.Id).StageName;
                    oppW.opp.CloseDate = oppErrorOppty_Map.get(oppW.opp.Id).CloseDate;
                    //v5.0 oppW.opp.New_Description__c = Oppty_NewDescription.get(oppW.opp.Id);
                    oppW.opp.NextStep = oppErrorOppty_Map.get(oppW.opp.Id).NextStep;
                }
            }
        }       
    }

    public PageReference Save() {
        system.debug('$$$DEBUG: In Save');
        String Successstr = '';
        String Failedstr = '';
        Integer counter = 0;
        
        //SuccessMsg = false;
        saveFlag = true;
        oppErrorMap.clear();
        oppErrorOppty_Map.clear();
        //v5.0 Oppty_NewDescription= new Map<Id, String>();
        List<Opportunity> opptyUpdateList = new List<Opportunity>();
        Integer diff = (PageNumber * PageSize) - PageSize;
        List<String> rowIds = strRecordsToSave.split('\\|\\|\\|', 0);
        List<Opportunity> PageRecords = new List<Opportunity>();
        for(opptyWrapper oppWrapper : oppWrapperList){
            PageRecords.add(oppWrapper.opp);
        }   
        for (String rowId : rowIds) {
            Integer i = Integer.valueOf(rowId);
            
            if (PageRecords[i].Id == OpenOpportunities[i + diff].Id) {
                //Version 1.2 - Here we need to add preprocess to swap back Next Steps and New Description values.
                //Version 1.3 - swapping no longer required as the value will be saved to NextStep.
                //String tmp = OpenOpportunities[i + diff].New_Description__c;
                //OpenOpportunities[i + diff].New_Description__c = OpenOpportunities[i + diff].NextStep;
                //OpenOpportunities[i + diff].NextStep = tmp;

                //process new description - append to top of description and clear (Version 1.0)
                /* v5.0
                if (OpenOpportunities[i + diff].Description != null) {
                    if (PageRecords[i].New_Description__c != null && PageRecords[i].New_Description__c.length() > 0) {
                        //look out for these tags. insert/append accordingly.
                        String salesOpsTag1 = '*Top Opportunity-Services* >> DO NOT REMOVE STRING. GLOBAL SALES OPERATIONS TAG';
                        String salesOpsTag2 = '*Top Opportunity-Services*';
                        String salesOpsTag3 = 'DO NOT REMOVE STRING. GLOBAL SALES OPERATIONS TAG';

                        if (OpenOpportunities[i + diff].Description.contains(salesOpsTag1)) {
                            OpenOpportunities[i + diff].Description = OpenOpportunities[i + diff].Description.replace(
                            salesOpsTag1,
                            salesOpsTag1 + '\n' + OpenOpportunities[i + diff].New_Description__c + '\n');
                        }
                        else if (OpenOpportunities[i + diff].Description.contains(salesOpsTag2) && OpenOpportunities[i + diff].Description.contains(salesOpsTag3)) {
                            OpenOpportunities[i + diff].Description = OpenOpportunities[i + diff].Description.replace(
                            salesOpsTag3,
                            salesOpsTag3 + '\n' + OpenOpportunities[i + diff].New_Description__c + '\n');
                        }
                        else if (OpenOpportunities[i + diff].Description.contains(salesOpsTag2)) {
                            OpenOpportunities[i + diff].Description = OpenOpportunities[i + diff].Description.replace(
                            salesOpsTag2,
                            salesOpsTag2 + '\n' + OpenOpportunities[i + diff].New_Description__c + '\n');
                        }
                        else {
                            OpenOpportunities[i + diff].Description = OpenOpportunities[i + diff].New_Description__c + '\n' + OpenOpportunities[i + diff].Description;
                        }
                    }
                }
                else {
                    //No need to look out for the tags if existing Description is empty 
                    OpenOpportunities[i + diff].Description = OpenOpportunities[i + diff].New_Description__c;
                }
                Oppty_NewDescription.put(OpenOpportunities[i + diff].id, OpenOpportunities[i + diff].New_Description__c);
                OpenOpportunities[i + diff].New_Description__c = '';
				*/
				
                //process book date - none

                //process stage - set values for verifiable outcome and probability
                if (OpenOpportunities[i + diff].StageName == 'Plan - 1%') {
                    //OpenOpportunities[i + diff].Verifiable_Outcome__c = 'Territory/Account/Opportunity Plan developed & reviewed by RSM';
                    OpenOpportunities[i + diff].Probability = 1;
                }
                else if (OpenOpportunities[i + diff].StageName == 'Discover - 10%') {
                    //OpenOpportunities[i + diff].Verifiable_Outcome__c = 'Documented customer discussion validated by sponsor/champion';
                    OpenOpportunities[i + diff].Probability = 10;
                }
                else if (OpenOpportunities[i + diff].StageName == 'Qualify - 30%') {
                    //OpenOpportunities[i + diff].Verifiable_Outcome__c = 'Documented customer discussion validated by power sponsor/decision maker';
                    OpenOpportunities[i + diff].Probability = 30;
                }
                else if (OpenOpportunities[i + diff].StageName == 'Propose - 60%') {
                    // OpenOpportunities[i + diff].Verifiable_Outcome__c = 'Confirmed selection by power sponsor/decision maker';
                    OpenOpportunities[i + diff].Probability = 60;
                }
                else if (OpenOpportunities[i + diff].StageName == 'Commit - 90%') {
                    //OpenOpportunities[i + diff].Verifiable_Outcome__c = 'Legal approval of deal/opportunity';
                    OpenOpportunities[i + diff].Probability = 90;
                }
                opptyUpdateList.add(OpenOpportunities[i + diff]);
                counter = counter + 1;

                //save
                /*
                try {
                update(OpenOpportunities[i + diff]);
                counter = counter + 1;
                }
                catch (Exception ex) {
                ApexPages.addMessages(ex);
                }*/

                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'ROW ID: ' + rowId));
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, PageRecords[i].Id + '---' + OpenOpportunities[i + diff].Id));
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, PageRecords[i].StageName + '---' + OpenOpportunities[i + diff].StageName));
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, PageRecords[i].CloseDate + '---' + OpenOpportunities[i + diff].CloseDate));
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, PageRecords[i].New_Description__c + '---' + OpenOpportunities[i + diff].New_Description__c));
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, '' + (PageRecords[i].New_Description__c == null)));

            }
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Saving Failed - ID mismatch. Please reload page.'));
                break;
            }
        }

        //Explicitly set the fiscal book date
        opptyUpdateList = ProcessFiscalBookDates(opptyUpdateList);
        integer FailedCount = 0;
        Database.SaveResult[] results = null;
        try {
            System.Debug('######## Database.update Start ########');
            TriggerExecutionController.setSkipOpportunityTriggers(true);
            //GlobalVariables.SKIP_ALL_OPP_TRIGGERS = true;
            GlobalVariables.BYPASS_ALL_LOT_OCEAN_CALCULATION = true;
            results = Database.update(opptyUpdateList, false);

            //DBUtils.processResult(opptyUpdateList,results,'Opportunity','Update',null,null);

            ApexPages.getMessages().clear();
            System.Debug('######## SaveResult[] results: ');

            Schema.DescribeSObjectResult sObjDesc = Opportunity.sObjectType.getDescribe();  
            Map<String, Schema.SObjectField> fieldMap = sObjDesc.fields.getMap();
            //system.debug('Test ' + fieldMap.get('Type').getDescribe().getLabel());

            for (Integer i=0; i<results.Size(); i++) {
                if (!results[i].isSuccess()) {
                    //String str = 'Update for Opportunity: ' + opptyUpdateList[i].Name + ' failed due to the following: ';
                    for (Database.Error err : results[i].getErrors()) {
                        //str = str + '  ' + err.getMessage();
                        msg = true;
                        String errMsg;
                        if(!err.getFields().isEmpty() && err.getFields()!= null){
                            errMsg = 'Error: [' + fieldMap.get(err.getFields().get(0)).getDescribe().getLabel() + '] ' + err.getMessage();
                        }else{
                            errMsg = 'Error: [' + err.getMessage() + ']';
                        } 
                        oppErrorMap.put(opptyUpdateList[i].id,errMsg);
                        oppErrorOppty_Map.put(opptyUpdateList[i].id,opptyUpdateList[i]);
                        FailedCount++;
                    }

                    //added replace for error message from 8306's VR
                    // str = str.replaceAll('&gt;', '>');
                    // ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, str);
                    //  ApexPages.addMessage(msg);

                    counter = counter - 1;
                }
                else {
                    oppErrorMap.put(opptyUpdateList[i].ID,'Record Saved');
                    system.debug('############## ID of the NOT failed   ' + results[i].getId() + '   The record Num ' + i);
                }
            }

            System.Debug('######## Database.update End ######## results.Size() = ' + results.Size());
            TriggerExecutionController.setSkipOpportunityTriggers(false);
            //GlobalVariables.SKIP_ALL_OPP_TRIGGERS = false;
            GlobalVariables.BYPASS_ALL_LOT_OCEAN_CALCULATION = false;
        }
        catch (System.DmlException e) {
            TriggerExecutionController.setSkipOpportunityTriggers(false);
            //GlobalVariables.SKIP_ALL_OPP_TRIGGERS = false;
            GlobalVariables.BYPASS_ALL_LOT_OCEAN_CALCULATION = false;
            for (Integer i = 0; i < e.getNumDml(); i++) {
                // Process exception here
                System.debug('############# The DML Message is '+ e.getDmlMessage(i));
            }
        }
        /*
        catch (Exception ex) {
        System.Debug('######## Database.update Catch Block ######## results.Size() = ' + results.Size());
        ApexPages.addMessages(ex);
        System.Debug('######## Database.update Catch Block ######## results.Size() = ' + results.Size());
        }*/

        //reload list to get updated records
        chkAffinityId();
        LoadOpenOpportunities();
        //SearchOpenOpportunities();

        if(counter == 1 || counter == 0){
            Successstr = 'Opportunity';
        }else{
            Successstr = 'Opportunities';
        }     
        SuccessMsg = true;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, + counter + ' ' + Successstr + ' ' + 'saved ' + ' ' + ' from page ' + PageNumber +' - Marked as Record Saved '));

        if(FailedCount == 1 || FailedCount == 0){
            Failedstr = 'Opportunity';
        }else{
            Failedstr = 'Opportunities';
        }
        if (FailedCount > 0)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,+ FailedCount + ' ' + Failedstr + ' ' + 'failed ' + ' ' +' from page ' + PageNumber + ' - See the specific message(s)'));

        //StrStatusMsg = '';
        //StrStatusMsg = 'Prop: ' + 'Saved ' + counter + ' ' + str + ' from page ' + PageNumber;

        PageReference pr = System.Page.VfMassUpdateOpportunitiesPage;
        pr.setRedirect(true);
        return pr;
    }

    //Explicitly set the fiscal book date
    public List<Opportunity> ProcessFiscalBookDates(List<Opportunity> opps) {
            system.debug('$$$DEBUG: In ProcessFiscalBookDates');
        Map<ID, String> results = OpportunityUtils.setFYCloseDate(opps);

        for(Opportunity opp : opps) {
            String fiscalBookDate = results.get(opp.Id);

            //opp.Fiscal_Year__c = fiscalBookDate.indexOf('FY')
            opp.Fiscal_Year__c = fiscalBookDate.substring(2, 6);
            opp.Fiscal_Quarter__c = fiscalBookDate.substring(fiscalBookDate.indexOf('Q') + 1, fiscalBookDate.indexOf('Q') + 2);
            opp.Fiscal_Week__c = fiscalBookDate.substring(fiscalBookDate.indexOf('W') + 1, fiscalBookDate.length());

            //system.debug('######fiscalBookDate ######' + fiscalBookDate);
            //system.debug('######FY ######' + fiscalBookDate.substring(2, 6));
            //system.debug('######Q ######' + fiscalBookDate.substring(fiscalBookDate.indexOf('Q') + 1, fiscalBookDate.indexOf('Q') + 2));
            //system.debug('######W ######' + fiscalBookDate.substring(fiscalBookDate.indexOf('W') + 1, fiscalBookDate.length()));
        }
        return opps;
    }

    public String StrStatusMsg { get; set; }

    public void Cancel() {
        //reload list to discard changes
        system.debug('$$$DEBUG: In Cancel');
        LoadOpenOpportunities();
    }

    public void SetPageSize(Integer pgsize) {
        PageSize = pgsize;
    }

    public void SetPageNumber(Integer pgnum) {
        PageNumber = pgnum;
        SetPageRecords();
    }

    public void SaveAndStay() {
        showHide= true;
        //SuccessMsg = true;
        Save();
        SetPageRecords();
    }

    public void NextPage() {
        PageNumber = PageNumber + 1;
        SetPageRecords();
        SuccessMsg = false; 
        showHide = false;       

    }

    public void SaveAndNextPage() {
        Save();
        NextPage();
        SuccessMsg = true;
    }

    public void CancelAndNextPage() {
    Cancel();
    NextPage();
    }

    public void PreviousPage() {
        PageNumber = PageNumber - 1;
        SetPageRecords();
        SuccessMsg = false; 
        showHide = false;       

    }

    public void SaveAndPreviousPage() {
        Save();
        PreviousPage();
        SuccessMsg = true;
    }

    public void CancelAndPreviousPage() {
        Cancel();
        PreviousPage();
    }

    public void FirstPage() {
        PageNumber = 1;
        SetPageRecords();
        SuccessMsg = false;
        showHide = false;        
    }

    public void SaveAndFirstPage() {
        Save();
        FirstPage();
        SuccessMsg = true;
    }

    public void CancelAndFirstPage() {
        Cancel();
        FirstPage();
    }

    public void LastPage() {
        PageNumber = PageTotal;
        SetPageRecords();
        SuccessMsg = false; 
        showHide = false;       
    }

    public void SaveAndLastPage() {
        Save();
        LastPage();
        SuccessMsg = true;
    }

    public void CancelAndLastPage() {
        Cancel();
        LastPage();
    }

    public void Page1() {
        PageNumber = PageNumber1;
        SetPageRecords();
        SuccessMsg = false; 
        showHide = false;       
    }

    public void SaveAndPage1() {
        Save();
        Page1();
        SuccessMsg = true;
    }

    public void CancelAndPage1() {
        Cancel();
        Page1();
    }

    public void Page2() {
        PageNumber = PageNumber2;
        SetPageRecords();
        SuccessMsg = false; 
        showHide = false;       
    }

    public void SaveAndPage2() {
        Save();
        Page2();
        SuccessMsg = true;
    }

    public void CancelAndPage2() {
        Cancel();
        Page2();
    }

    public void Page3() {
        PageNumber = PageNumber3;
        SetPageRecords(); 
        SuccessMsg = false;  
        showHide = false;     
    }

    public void SaveAndPage3() {
        Save();
        Page3();
        SuccessMsg = true;
    }

    public void CancelAndPage3() {
        Cancel();
        Page3();
    }

    public PageReference GoBack() {
        PageReference homePg = new PageReference('/apex/VfCustomOpportunityHomePage');
        return homePg;
    }

    public PageReference SaveAndGoBack() {
        Save();
        return GoBack();
    }

    public List<SelectOption> getListStageNames() {     
        List<SelectOption> listStageNames = new List<SelectOption>();
        listStageNames.add(new SelectOption('Plan - 1%', 'Plan - 1%'));
        listStageNames.add(new SelectOption('Discover - 10%', 'Discover - 10%'));
        listStageNames.add(new SelectOption('Qualify - 30%', 'Qualify - 30%'));
        listStageNames.add(new SelectOption('Propose - 60%', 'Propose - 60%'));
        listStageNames.add(new SelectOption('Commit - 90%', 'Commit - 90%'));
        return listStageNames;
    }

    //Version 1.1
    public List<SelectOption> getSearchListStageNames() {
        List<SelectOption> listStageNames = new List<SelectOption>();
        listStageNames.add(new SelectOption('--None--', '--None--'));
        listStageNames.add(new SelectOption('Plan - 1%', 'Plan - 1%'));
        listStageNames.add(new SelectOption('Discover - 10%', 'Discover - 10%'));
        listStageNames.add(new SelectOption('Qualify - 30%', 'Qualify - 30%'));
        listStageNames.add(new SelectOption('Propose - 60%', 'Propose - 60%'));
        listStageNames.add(new SelectOption('Commit - 90%', 'Commit - 90%'));
        return listStageNames;
    }

    public Boolean getMessage(){
        return msg;
    }

    //Opportunity_Search_Criteria__c oppSearchRecord;

    public PageReference saveSearch(){ 
    
          //ErrorsPresent();
        /*If (ApexPages.hasMessages())        {
            displayPopup = false;
            displayPopupOk = false;
            displayPopUp1 = false;
            return null;
        }
        else{*/
            system.debug('$$$DEBUG: In saveSearch');
            SuccessMsg = false;
            if (SearchAccountID != null)
                SearchAccountID = SearchAccountID.trim();
            
            if (SearchAccountName != null)
                SearchAccountName = SearchAccountName.trim();
                
            if (SearchOpportunityName != null)
                SearchOpportunityName = SearchOpportunityName.trim(); 
            if(showCancelBtnAndFilterName == false )
            {
                searchName ='';
            } 
            Selected_searchName = searchName; 
            if((SearchAccountName == '' || SearchAccountName == null ) && (SearchAccountID == '' || SearchAccountID == null)&& (SearchOpportunityName == '' || SearchOpportunityName == NULL)&& (SearchStageName == '--None--' )&& (SearchStartingFiscalBookDate == '' || SearchStartingFiscalBookDate == NULL) && (SearchEndingFiscalBookDate == '' || SearchEndingFiscalBookDate == NULL) && (SearchOpp.Solution_Type__c == '' || SearchOpp.Solution_Type__c == NULL)&& ( SearchOpp.Solution_Name__c == '' ||  SearchOpp.Solution_Name__c == NULL) && (/*SearchOpp2.Services_Sales_Owner__c == '' || */ SearchOpp2.Services_Sales_Owner__c == NULL) && (/*SearchOpp.Services_Sales_Owner__c == '' ||*/ SearchOpp.Services_Sales_Owner__c == NULL)
            && (SearchOpp.Decision_Date__c == NULL)){
                displayPopUp1 = true;              
            }else{
                /*oppSearchRecord = new Opportunity_Search_Criteria__c();
                oppSearchRecord.Account_Name__c = SearchAccountName;
                oppSearchRecord.Affinity_Account_ID__c = SearchAccountID;
                oppSearchRecord.Book_Date__c = SearchOpp.Decision_Date__c;
                oppSearchRecord.Ending_Fiscal_Book_Date__c = SearchEndingFiscalBookDate;
                oppSearchRecord.Opportunity_Name__c = SearchOpportunityName;
                oppSearchRecord.Opportunity_Owner__c = SearchOpp2.Services_Sales_Owner__c;
                oppSearchRecord.Solution_Name__c = SearchOpp.Solution_Name__c;
                oppSearchRecord.Solution_Type__c = SearchOpp.Solution_Type__c;
                oppSearchRecord.Service_Sales_Owner__c = SearchOpp.Services_Sales_Owner__c ;
                oppSearchRecord.Stage__c = SearchStageName;
                oppSearchRecord.Starting_Fiscal_Book_Date__c = SearchStartingFiscalBookDate;
               if(searchname != NULL || searchname != ''){
                    oppSearchRecord.Name =  searchname;
                }*/
                displayError = false;
                displayPopup = true;        
            }
            showSectionCollapsed = false;
            return null;
         //}   
    }
    
    public PageReference saveSearch_No(){    
        displayError = false;
        displayPopup = true;     
        displayError2 = false;
        showSectionCollapsed = false;
        return null;
    }

    public void saveSearchRecord(){     
        system.debug('$$$DEBUG: In saveSearchRecord');
        if (searchName != null)
            searchName = searchName.trim();
            
        if(searchName == '' || searchName == NULL)  {
            displayError2 = true;       
        }else{
            if([Select count() From Opportunity_Search_Criteria__c  where Name =: searchName AND  CreatedById =: UserInfo.getUserID()] == 0){
                Opportunity_Search_Criteria__c oppSearchRecord = new Opportunity_Search_Criteria__c();
                oppSearchRecord.Account_Name__c = SearchAccountName;
                oppSearchRecord.Affinity_Account_ID__c = SearchAccountID;
                oppSearchRecord.Book_Date__c = SearchOpp.Decision_Date__c;
                oppSearchRecord.Ending_Fiscal_Book_Date__c = SearchEndingFiscalBookDate;
                oppSearchRecord.Opportunity_Name__c = SearchOpportunityName;
                oppSearchRecord.Opportunity_Owner__c = SearchOpp2.Services_Sales_Owner__c;
                oppSearchRecord.Solution_Name__c = SearchOpp.Solution_Name__c;
                oppSearchRecord.Solution_Type__c = SearchOpp.Solution_Type__c;
                oppSearchRecord.Service_Sales_Owner__c = SearchOpp.Services_Sales_Owner__c ;
                oppSearchRecord.Stage__c = SearchStageName;
                oppSearchRecord.Starting_Fiscal_Book_Date__c = SearchStartingFiscalBookDate;
                oppSearchRecord.Name = searchName;
                try{
                    insert oppSearchRecord;
                    selectedCriteria = oppSearchRecord;
                }catch(exception e){
                    system.debug('exception'+e);
                }       
                displayPopupOk = True;   
                searchName =  oppSearchRecord.Name;
                displayError2 = false;
                //searchName_EditMode = searchName;
            }else{
                displayError = true;        
                displayPopupOk = false;     
            }  
        }
    }

    // function on OK to close the popup windows   
    public void saveSearchRecord_Ok(){
        showSectionCollapsed = false;
        showCancelBtnAndFilterName = true;
       
        displayPopup = false;
        displayPopupOk = false;
        displayPopUp1 = false;
        displayError2 = false;
        errorList = '';
    }

    public void saveSearchRecordErr_Ok(){
        showSectionCollapsed = false;            
        displayPopup = false;
        displayPopupOk = false;
        displayPopUp1 = false;
    }
    
    // cancel save search criteria  
    public PageReference cancelSaveSearch(){
       
        displayPopup = false;
        displayError2 = false;
        displayPopUpPrevious  = false;
        showSectionCollapsed = false;
        searchName = Selected_searchName;
        if (criteriaList != null)
            criteriaList.clear();
            
        if (openCriteriaDeleted){
            openCriteriaDeleted = false;
            //PageReference pg = new PageReference('/apex/VfMassUpdateOpportunitiesPage');
            //pg.setRedirect(true);
            //return pg;
            clearSearch();
            showCancelBtnAndFilterName = false;
            return null;
        }
        else
            return null;
            
        /*if (editflag == false)
            searchName = '';
        else */
        // searchName = oppSearchRecord.Name;
    }

    public List<Opportunity_Search_Criteria__c> criteriaList{get;set;}  
    
    //function to populate the saved search criteria
    public void previousSearch(){
        system.debug('$$$DEBUG: In previousSearch');
        SuccessMsg = false; 
        showSectionCollapsed = false;       
        criteriaList = [Select Id,Name from Opportunity_Search_Criteria__c where CreatedById =: UserInfo.getUserID() ORDER BY Name];
        system.debug('---criteria list values-----'+criteriaList);
        displayPopUpPrevious  = true;
        deleteFlag = false;
        Selected_searchName = searchName;
        
    }

    public void DeleteCriteria() {
        Opportunity_Search_Criteria__c tobedeleted =[Select Id from Opportunity_Search_Criteria__c where id =: searchId];
        if (selectedCriteria != null)
            if (tobedeleted.id == selectedCriteria.id)
                openCriteriaDeleted = true;
            
        Delete tobedeleted;
        deleteFlag = false;
        previousSearch();
    }   

    public string searchId   {get;set;}
    public boolean editFlag {get;set;}
    public Opportunity_Search_Criteria__c  selectedCriteria {get;set;}

    //function used to populate the Saved Seach Criteria
    public void populateCriteria_Edit(){
        system.debug('$$$DEBUG: In populateCriteria_Edit');
        showCancelBtnAndFilterName = true;
         errorList = '';
         openCriteriaDeleted = false;
        selectedCriteria = [Select id,Name,Account_Name__c,Affinity_Account_ID__c,Solution_Type__c,Book_Date__c,
                                Solution_Name__c,Opportunity_Owner__c,Opportunity_Name__c,Stage__c,
                                Service_Sales_Owner__c,Starting_Fiscal_Book_Date__c,Ending_Fiscal_Book_Date__c
                                from Opportunity_Search_Criteria__c where Id =:searchId];
                                                         
        system.debug('edited record'+selectedCriteria);                                                    
        
        SearchAccountName = selectedCriteria.Account_Name__c;      
        SearchAccountID =  selectedCriteria.Affinity_Account_ID__c; 
        SearchOpp.Decision_Date__c = selectedCriteria.Book_Date__c;
        SearchOpp.Solution_Type__c = selectedCriteria.Solution_Type__c;
        SearchOpp.Solution_Name__c = selectedCriteria.Solution_Name__c;
        SearchOpportunityName = selectedCriteria.Opportunity_Name__c;
        SearchOpp2.Services_Sales_Owner__c = selectedCriteria.Opportunity_Owner__c;
        SearchOpp.Services_Sales_Owner__c =selectedCriteria.Service_Sales_Owner__c;
        SearchStageName = selectedCriteria.Stage__c;
        SearchStartingFiscalBookDate = selectedCriteria.Starting_Fiscal_Book_Date__c;
        SearchEndingFiscalBookDate = selectedCriteria.Ending_Fiscal_Book_Date__c;
        if(editFlag == true){
            searchName = selectedCriteria.Name; 
            //searchName_EditMode = selectedCriteria.Name;
        } 
        displayPopupPrevious = false; 
        showSectionCollapsed = false;  
    }
   
    // function to update any saved search criteria  
    public void updateRecord(){
        system.debug('$$$DEBUG: In updateRecord');
        Opportunity_Search_Criteria__c  updatedRecord = [Select id,Name,Account_Name__c,Affinity_Account_ID__c,Solution_Type__c,Book_Date__c,
                                                Solution_Name__c,Opportunity_Owner__c,Opportunity_Name__c,Stage__c,
                                                Service_Sales_Owner__c,Starting_Fiscal_Book_Date__c,Ending_Fiscal_Book_Date__c
                                                From Opportunity_Search_Criteria__c  where Name =: searchName AND  CreatedById =: UserInfo.getUserID() LIMIT 1];
        updatedRecord.Account_Name__c = SearchAccountName;      
        updatedRecord.Affinity_Account_ID__c = SearchAccountID ; 
        updatedRecord.Book_Date__c = SearchOpp.Decision_Date__c;
        updatedRecord.Solution_Type__c = SearchOpp.Solution_Type__c;
        updatedRecord.Solution_Name__c = SearchOpp.Solution_Name__c;
        updatedRecord.Opportunity_Name__c = SearchOpportunityName ;
        updatedRecord.Opportunity_Owner__c = SearchOpp2.Services_Sales_Owner__c ;
        updatedRecord.Service_Sales_Owner__c = SearchOpp.Services_Sales_Owner__c ;
        updatedRecord.Stage__c = SearchStageName;
        updatedRecord.Starting_Fiscal_Book_Date__c = SearchStartingFiscalBookDate;
        updatedRecord.Ending_Fiscal_Book_Date__c = SearchEndingFiscalBookDate ;
        updatedRecord.Name = searchName;  
        update updatedRecord; 
        displayError = false;
        displayPopupOk = true; 
        editflag = false;
                                                             
    }

    public boolean deleteFlag {get;set;} // flag to check if the delete button is clicked
    public String deletedSearchCriteria {get;set;} 

    //function to delete the selected saved search criteria
    public void deleteCriterion(){
        deletedSearchCriteria  = [Select Name from Opportunity_Search_Criteria__c where id =: searchId].Name;
        displayPopUpPrevious  = true;
        deleteFlag = true;
    }

    //function for clear search
    public void clearSearch(){
        system.debug('$$$DEBUG: In clearSearch');
        SuccessMsg = false; 
        showSectionCollapsed = false;
        errorList = '';
        
        displayError2 = false; 
        SearchAccountName = '';
        SearchAccountID = '';
        SearchOpportunityName= '';
        SearchStageName= '';
        SearchStartingFiscalBookDate = '';
        SearchEndingFiscalBookDate = '';
        SearchOpp.Solution_Type__c = '';
        SearchOpp.Solution_Name__c = '';
        SearchOpp2.Services_Sales_Owner__c = NULL;
        SearchOpp.Services_Sales_Owner__c = NULL;
        SearchOpp.Decision_Date__c = NULL;       
    }

    // function to populate the criteria when edit flag is false     
    public void populateCriteria_View(){
        system.debug('$$$DEBUG: In populateCriteria_View');
        editFlag = false;
        errorList = '';
        openCriteriaDeleted = false;
        showCancelBtnAndFilterName = true;
       
        selectedCriteria = [Select id,Name,Account_Name__c,Affinity_Account_ID__c,Solution_Type__c,Book_Date__c,
        Solution_Name__c,Opportunity_Owner__c,Opportunity_Name__c,Stage__c,
        Service_Sales_Owner__c,Starting_Fiscal_Book_Date__c,Ending_Fiscal_Book_Date__c
        from Opportunity_Search_Criteria__c where
        Id =:searchId];
        system.debug('criteria record'+selectedCriteria);                                                    
        system.debug('edited record'+selectedCriteria);                                                    

        SearchAccountName = selectedCriteria.Account_Name__c;
        //if(selectedCriteria.Affinity_Account_ID__c != '' && selectedCriteria.Affinity_Account_ID__c != NULL){      
            SearchAccountID =  selectedCriteria.Affinity_Account_ID__c; 
       //  }   
        SearchOpp.Decision_Date__c = selectedCriteria.Book_Date__c;
        SearchOpp.Solution_Type__c = selectedCriteria.Solution_Type__c;
        SearchOpp.Solution_Name__c = selectedCriteria.Solution_Name__c;
        SearchOpportunityName = selectedCriteria.Opportunity_Name__c;
        SearchOpp2.Services_Sales_Owner__c = selectedCriteria.Opportunity_Owner__c;
        SearchOpp.Services_Sales_Owner__c =selectedCriteria.Service_Sales_Owner__c;
        SearchStageName = selectedCriteria.Stage__c;
        SearchStartingFiscalBookDate = selectedCriteria.Starting_Fiscal_Book_Date__c;
        SearchEndingFiscalBookDate = selectedCriteria.Ending_Fiscal_Book_Date__c;

        searchName = selectedCriteria.Name; 
        displayPopupPrevious = false; 
        SearchOpenOpportunities();
        //LoadOpenOpportunities();
        
        NoRecordFlag = false;
        SuccessMsg = false; 
        oppErrorMap.clear(); 
        showHide = false;     
        SetPageNumber(1);
        showSectionCollapsed = false;
    }
    
 //Added for CRQ 0890 - new Cancel Button   
    public PageReference CancelFilter()   {             
        system.debug('$$$DEBUG: In CancelFilter');
        PageReference pg = new PageReference('/apex/VfMassUpdateOpportunitiesPage');
        pg.setRedirect(true);
        return pg;
    }
    
    public PageReference resetSearchResult()   {             
        OpenOpportunities.clear();
         SetPageNumber(1);
        return null;
    }
    
    
   /* public Boolean ErrorsPresent()
    {
        return ApexPages.hasMessages(ApexPages.Severity.ERROR);
    }  */
}