public with sharing class VFCntrlr_CustomOppHomePage {

    private User currentUserObj;

    public String strWeekCommitRunRate { get; private set; }
    public String strWeekUpside { get; private set; }
    public String strWeekTotal { get; private set; }
    public String strQtrCommitRunRate { get; private set; }
    public String strQtrUpside { get; private set; }
    public String strQtrTotal { get; private set; }

    public Boolean renderWeekCRR { get; private set; }
    public Boolean renderWeekUpside { get; private set; }
    public Boolean renderWeekTotal { get; private set; }
    public Boolean renderQtrCRR { get; private set; }
    public Boolean renderQtrUpside { get; private set; }
    public Boolean renderQtrTotal { get; private set; }

    private Decimal valWeekCommitRunRate;
    private Decimal valWeekUpside;
    private Decimal valWeekTotal;
    private Decimal valQtrCommitRunRate;
    private Decimal valQtrUpside;
    private Decimal valQtrTotal;

    private Decimal valWeekCommitRunRateLocal;
    private Decimal valWeekUpsideLocal;
    private Decimal valQtrCommitRunRateLocal;
    private Decimal valQtrUpsideLocal;

    public String CurrencyPicklistValue { get; set; }
    public Boolean displayCurrencyControls { get; private set; }
    public String RunReportPicklistValue1 { get; set; }
    public String RunReportPicklistValue2 { get; set; }

    public VFCntrlr_CustomOppHomePage() {  
    string userRole = UserInfo.getUserRoleId();
     if(userRole == '00E30000000w2BzEAI')
         doRedirect();
    //Get the 2 record type ids, and use in query as :rtRunRate[0].Id, :rtRunRate[1].Id
        List<RecordType> rtRunRate = [SELECT Id FROM RecordType
                                    WHERE SobjectType = 'Opportunity' AND IsActive = true
                                    AND (Name = 'Run Rate Marketing' OR Name = 'Run Rate Opportunity')];

        //Get Start/End dates for current fiscal week
        List<Period> w = [SELECT StartDate, EndDate FROM Period WHERE Type = 'Week'
                          AND StartDate <= TODAY AND EndDate >= TODAY LIMIT 1];
        Date weekStartDate = w[0].StartDate;
        Date weekEndDate = w[0].EndDate;
        //Calculate Weekly Commmit + Run Rate
        valWeekCommitRunRate = 0.00;
        strWeekCommitRunRate = '0.00';
        List<AggregateResult> listWeekCommitRunRate = null;

        try {
            // currently 801 records
            listWeekCommitRunRate =
                [SELECT SUM(Amount)sumRev FROM Opportunity
                WHERE CloseDate >= :weekStartDate
                AND CloseDate <= :weekEndDate
                AND (StageName = 'Commit - 90%'
                    OR (Type = 'Run Rate'
                        AND (StageName = 'Plan - 1%' OR StageName = 'Discover - 10%' OR StageName = 'Qualify - 30%' OR StageName = 'Propose - 60%' OR StageName = 'Commit - 90%'))
                    OR (RecordTypeId IN (:rtRunRate[0].Id, :rtRunRate[1].Id)
                        AND (StageName = 'Plan - 1%' OR StageName = 'Discover - 10%' OR StageName = 'Qualify - 30%' OR StageName = 'Propose - 60%' OR StageName = 'Commit - 90%')))];
        }
        catch (Exception e) {

        }

        if(listWeekCommitRunRate <> null && listWeekCommitRunRate.size() > 0) {
            strWeekCommitRunRate = '' + listWeekCommitRunRate[0].get('sumRev');
            if (strWeekCommitRunRate == 'null')
                strWeekCommitRunRate = '0.00';
            else
                valWeekCommitRunRate = Decimal.ValueOf(strWeekCommitRunRate);
        }

        strWeekCommitRunRate = 'USD ' + strWeekCommitRunRate;
        //Calculate Weekly Upside
        valWeekUpside = 0.00;
        strWeekUpside = '0.00';
        List<AggregateResult> listWeekUpside = null;
        try {
            // currently 10779 records
            listWeekUpside =
                [SELECT SUM(Amount)sumRev FROM Opportunity
                WHERE CloseDate >= :weekStartDate
                AND CloseDate <= :weekEndDate
                AND (StageName = 'Plan - 1%' OR StageName = 'Discover - 10%' OR StageName = 'Qualify - 30%' OR StageName = 'Propose - 60%')
                AND  Type != 'Run Rate'
                AND RecordTypeId NOT IN (:rtRunRate[0].Id, :rtRunRate[1].Id)];
        }
        catch (Exception e) {
        }

        if(listWeekUpside <> null && listWeekUpside.size() > 0) {
            strWeekUpside = '' + listWeekUpside[0].get('sumRev');
            if (strWeekUpside == 'null')
                strWeekUpside = '0.00';
            else
                valWeekUpside = Decimal.ValueOf(strWeekUpside);
        }

        strWeekUpside = 'USD ' + strWeekUpside;
        valWeekTotal = valWeekCommitRunRate + valWeekUpside;
        strWeekTotal = 'USD ' + valWeekTotal;

        //Get Start/End dates for current fiscal quarter
        List<Period> q = [SELECT StartDate, EndDate FROM Period WHERE Type = 'Quarter'
                          AND StartDate <= TODAY AND EndDate >= TODAY LIMIT 1];
        Date qtrStartDate = q[0].StartDate;
        Date qtrEndDate = q[0].EndDate;

        //Calculate Rest of Quarter Commit + Run Rate
        renderQtrCRR = true;
        valQtrCommitRunRate = 0.00;
        strQtrCommitRunRate = '0.00';
        List<AggregateResult> listQtrCommitRunRate = null;
        try {
            // currently 2994 records
            listQtrCommitRunRate =
                [SELECT SUM(Amount)sumRev FROM Opportunity
                WHERE CloseDate > :weekEndDate
                AND CloseDate <= :qtrEndDate
                AND (StageName = 'Commit - 90%'
                    OR (Type = 'Run Rate'
                        AND (StageName = 'Plan - 1%' OR StageName = 'Discover - 10%' OR StageName = 'Qualify - 30%' OR StageName = 'Propose - 60%' OR StageName = 'Commit - 90%'))
                    OR (RecordTypeId IN (:rtRunRate[0].Id, :rtRunRate[1].Id)
                        AND (StageName = 'Plan - 1%' OR StageName = 'Discover - 10%' OR StageName = 'Qualify - 30%' OR StageName = 'Propose - 60%' OR StageName = 'Commit - 90%')))];
        }
        catch (Exception e) {
            renderQtrCRR = false;
        }

        if(listQtrCommitRunRate <> null && listQtrCommitRunRate.size() > 0) {
            strQtrCommitRunRate = '' + listQtrCommitRunRate[0].get('sumRev');
            if (strQtrCommitRunRate == 'null')
                strQtrCommitRunRate = '0.00';
            else
                valQtrCommitRunRate = Decimal.ValueOf(strQtrCommitRunRate);
        }
        strQtrCommitRunRate = 'USD ' + strQtrCommitRunRate;
		
        //Calculate Rest of Quarter Upside
        renderQtrUpside = true;
        valQtrUpside = 0.00;
        strQtrUpside = '0.00';
        List<AggregateResult> listQtrUpside = null;
        try {
            // currently 39951 records
            listQtrUpside =
                [SELECT SUM(Amount)sumRev FROM Opportunity
                WHERE CloseDate > :weekEndDate
                AND CloseDate <= :qtrEndDate
                AND (StageName = 'Plan - 1%' OR StageName = 'Discover - 10%' OR StageName = 'Qualify - 30%' OR StageName = 'Propose - 60%')
                AND Type != 'Run Rate'
                AND RecordTypeId NOT IN (:rtRunRate[0].Id, :rtRunRate[1].Id)];
        }
        catch (Exception e) {
            renderQtrUpside = false;
        }

        if(listQtrUpside <> null && listQtrUpside.size() > 0) {
            strQtrUpside = '' + listQtrUpside[0].get('sumRev');
            if (strQtrUpside == 'null')
                strQtrUpside = '0.00';
            else
                valQtrUpside = Decimal.ValueOf(strQtrUpside);
        }

        strQtrUpside = 'USD ' + strQtrUpside;

        if(renderQtrCRR == true && renderQtrUpside == true) {
            renderQtrTotal = true;
        }
        else {
            renderQtrTotal = false;
        }
        valQtrTotal = valQtrCommitRunRate + valQtrUpside;
        strQtrTotal = 'USD ' + valQtrTotal;
        //Read currency setting and conversion
        displayCurrencyControls = (UserInfo.getDefaultCurrency() <> 'USD');
        currentUserObj = [SELECT Username, OSPCurrency__c FROM User WHERE Username = :UserInfo.getUserName()];
        if (displayCurrencyControls) {
            if (currentUserObj.OSPCurrency__c == null)
                currentUserObj.OSPCurrency__c = 'USD';
            CurrencyPicklistValue = currentUserObj.OSPCurrency__c;
        }
        else {
            CurrencyPicklistValue = 'USD';
        }
        convertWeekQtrSummary();
    }

    private void convertWeekQtrSummary() {
        Map<String, Double> currencyConversionMap;
        Double conversionRate = 1.0;
        currencyConversionMap = CurrencyUtils.getCurrencyConversionMap();
        conversionRate = currencyConversionMap.get(UserInfo.getDefaultCurrency());
        CurrencyType dp = [SELECT DecimalPlaces FROM CurrencyType WHERE IsoCode = :UserInfo.getDefaultCurrency()];

        valWeekCommitRunRateLocal = valWeekCommitRunRate * conversionRate;
        valWeekUpsideLocal = valWeekUpside * conversionRate;

        valQtrCommitRunRateLocal = valQtrCommitRunRate * conversionRate;
        valQtrUpsideLocal = valQtrUpside * conversionRate;

        if (CurrencyPicklistValue == 'USD') {
            valWeekTotal = valWeekCommitRunRate + valWeekUpside;
            valWeekTotal = valWeekTotal.SetScale(dp.DecimalPlaces);
            strWeekTotal = '' + CurrencyPicklistValue + ' ' + addTrailingZero(valWeekTotal.format(), dp.DecimalPlaces);

            valWeekCommitRunRate = valWeekCommitRunRate.SetScale(dp.DecimalPlaces);
            strWeekCommitRunRate = '' + CurrencyPicklistValue + ' ' + addTrailingZero(valWeekCommitRunRate.format(), dp.DecimalPlaces);

            valWeekUpside = valWeekUpside.SetScale(dp.DecimalPlaces);
            strWeekUpside = '' + CurrencyPicklistValue + ' ' + addTrailingZero(valWeekUpside.format(), dp.DecimalPlaces);

            valQtrTotal = valQtrCommitRunRate + valQtrUpside;
            valQtrTotal = valQtrTotal.SetScale(dp.DecimalPlaces);
            strQtrTotal = '' + CurrencyPicklistValue + ' ' + addTrailingZero(valQtrTotal.format(), dp.DecimalPlaces);

            valQtrCommitRunRate = valQtrCommitRunRate.SetScale(dp.DecimalPlaces);
            strQtrCommitRunRate = '' + CurrencyPicklistValue + ' ' + addTrailingZero(valQtrCommitRunRate.format(), dp.DecimalPlaces);

            valQtrUpside = valQtrUpside.SetScale(dp.DecimalPlaces);
            strQtrUpside = '' + CurrencyPicklistValue + ' ' + addTrailingZero(valQtrUpside.format(), dp.DecimalPlaces);
        }
        else {
            valWeekTotal = valWeekCommitRunRateLocal + valWeekUpsideLocal;
            valWeekTotal = valWeekTotal.SetScale(dp.DecimalPlaces);
            strWeekTotal = '' + CurrencyPicklistValue + ' ' + addTrailingZero(valWeekTotal.format(), dp.DecimalPlaces);

            valWeekCommitRunRateLocal = valWeekCommitRunRateLocal.SetScale(dp.DecimalPlaces);
            strWeekCommitRunRate = '' + CurrencyPicklistValue + ' ' + addTrailingZero(valWeekCommitRunRateLocal.format(), dp.DecimalPlaces);

            valWeekUpsideLocal = valWeekUpsideLocal.SetScale(dp.DecimalPlaces);
            strWeekUpside = '' + CurrencyPicklistValue + ' ' + addTrailingZero(valWeekUpsideLocal.format(), dp.DecimalPlaces);

            valQtrTotal = valQtrCommitRunRateLocal + valQtrUpsideLocal;
            valQtrTotal = valQtrTotal.SetScale(dp.DecimalPlaces);
            strQtrTotal = '' + CurrencyPicklistValue + ' ' + addTrailingZero(valQtrTotal.format(), dp.DecimalPlaces);

            valQtrCommitRunRateLocal = valQtrCommitRunRateLocal.SetScale(dp.DecimalPlaces);
            strQtrCommitRunRate = '' + CurrencyPicklistValue + ' ' + addTrailingZero(valQtrCommitRunRateLocal.format(), dp.DecimalPlaces);

            valQtrUpsideLocal = valQtrUpsideLocal.SetScale(dp.DecimalPlaces);
            strQtrUpside = '' + CurrencyPicklistValue + ' ' + addTrailingZero(valQtrUpsideLocal.format(), dp.DecimalPlaces);
        }
    }

    public String addTrailingZero(String val, Integer dp) {
        String strVal = val;
        if (strVal.indexOf('.') != -1 &&
            strVal.indexOf(',') != -1 &&
            strVal.indexOf('.') < strVal.indexOf(',')) {

            strVal = strVal.replace(',', 'aaa');
            strVal = strVal.replace('.', ',');
            strVal = strVal.replace('aaa', '.');
            val = strVal;
        }
        List<String> sVal = val.split('\\.');
        //if decimal places required
        if (dp > 0) {
            if (sVal.size() > 1) {
                if (sVal[sVal.size() - 1].length() < dp) {
                    for (Integer i=0; i<(dp - sVal[sVal.size() - 1].length()); i++) {
                        strVal = strVal + '0';
                    }
                }
            }
            if (sVal.size() == 1) {
                strVal = strVal + '.';
                for (Integer i=0; i<dp; i++) {
                    strVal = strVal + '0';
                }
            }
        }

        return strVal;
    }

    public List<SelectOption> getCurrencyPicklist() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('USD','USD'));
        options.add(new SelectOption(UserInfo.getDefaultCurrency(), UserInfo.getDefaultCurrency()));
        return options;
    }

    public PageReference convertCurrencyDisplayForSummary() {
        currentUserObj.OSPCurrency__c  = CurrencyPicklistValue;
        UserUtils.updateUserCurrency(new List<string> {currentUserObj.Id}, CurrencyPicklistValue);
        convertWeekQtrSummary();
        return null;
    }

    public PageReference goToMassUpdate() {
        PageReference muPg = new PageReference('/apex/VfMassUpdateOpportunitiesPage');
        return muPg;
    }

    public PageReference doRedirect(){
        string userRole = UserInfo.getUserRoleId();
        PageReference muPg;
        if(userRole == '00E30000000w2BzEAI')
             muPg = new PageReference('/006/0');
        else
             muPg = new PageReference('apex/VfCustomOpportunityHomePage?fcf=00BA0000004VL3O');
        return muPg;
        //https://cs11.salesforce.com/apex/VfCustomOpportunityHomePage?fcf=00B300000036NNe
    }

    public PageReference goToRunReportQtrSummary() {
        String url = '/00O?c=RD&c=AL&c=AN&c=ON&c=SN&c=FQ&c=AM&c=EA&c=PB&c=AG&c=CD&c=CR&c=NS&c=LS&c=TY&rt=22&sort=STAGE_NAME' +
            '&quarter_q=' + RunReportPicklistValue1 + '&open=' + RunReportPicklistValue2 + '&go=Run+Report';
        PageReference rptPg = new PageReference(url);
        return rptPg;
    }
}