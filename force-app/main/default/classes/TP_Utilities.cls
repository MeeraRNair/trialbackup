/***********************************************************
    * Name          : TP_Utilities
    * ------------------------------------------------------------------
    * Revision  Name         CR#        Date        Description
    * 1.0       Harsha       14786      14/08/2017  Utlities class for TP, Seperated common functionalities from Drawloop_TerritoryPlanning class
    * 2.0       Harsha       15436      09/04/2018  Focus_account__c fieldtype change
    * ------------------------------------------------------------------
    * 
    * Note          : If there is any modification in sequence/order of list<list<string> return variables make sure this 
    *                 reflects in both VF pages and PPT Templates.
************************************************************/
public class TP_Utilities {
    
    public static integer currentFiscalYear { get; set; }
    public static Date currentFYStartDate { get; set; }
    public static Map<string, RevenueItem> revenueItemsByQuarterPeriod { get; set; }
    public static Map<Id, RevenuePrioritization> revenueItemsByAccount { get; set; }
    public static Map<string, double> partnerRevenueLast4Quarters { get; set; }
    
    public static List<string> currentFYQuarters;
    public static List<string> previousQuarters;
        
    public static List<Id> accountIds;
    public static string currentFYQ;
    public static List<double> totalValues = new List<double>{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
        
    public static Map<string, Set<string>> usersByRole;
    
    //If team role or sequence is modified do the modification in TP_OnYourTeam page also.
    public static final List<string> teamRoles = new List<string>{
        'Inside Sales Rep',
        'Technical Sales Rep',
        'Data Center Sales Specialist', //pptv2.0
        'Account System Engineer', //pptv2.0
        'System Consultant',
        'EUC Sales Specialist',
        'Services Sales Exec Bus. Solutions Svcs',
        'Networking Sales Specialist',
        'Networking Solutions Engineer',//pptv2.0 
        'DFS Account Executive'
  };
    
    public static final List<string> commonFields = new List<string>{
        'Desktop',
        'Notebook',
        'Server',
        'Storage',
        'Networking'
    };
    
    public static Set<string> initiateFYQuarterCalc(){
        FiscalYearSettings fy = getCurrentFiscalYearSettings();
        
        currentFiscalYear = fy.EndDate.year();
        currentFYStartDate = fy.StartDate;
        
        currentFYQuarters = getCurrentFYQuarters(currentFiscalYear);
        previousQuarters = getPreviousQuarters(currentFiscalYear, currentFYStartDate);
        
        currentFYQ = currentFYQuarters[0];
        for (integer i = 0; i < 3; i++) {
            if (currentFYQ == previousQuarters[i]) {
                currentFYQ = currentFYQuarters[i+1];
                break;
            }
        }
        
        Set<string> last4Quarters = new Set<string>();
        for (integer i = 0; i < 4; i++) {
            last4Quarters.add(previousQuarters[i]);
        }
        Set<string> previous4Quarters = new Set<string>();
        for (integer i = 4; i < 8; i++) {
            previous4Quarters.add(previousQuarters[i]);
        }
        Set<string> pprevious4Quarters = new Set<string>();
        for (integer i = 8; i < 12; i++) {
            pprevious4Quarters.add(previousQuarters[i]);
        }
        
        revenueItemsByQuarterPeriod = new Map<string, RevenueItem>();
        revenueItemsByAccount = new Map<Id, RevenuePrioritization>();
        partnerRevenueLast4Quarters = new Map<string, double>();
        getRevenueData(currentFYQuarters, previousQuarters, last4Quarters, previous4Quarters, pprevious4Quarters);
            
        accountIds = new List<Id>(revenueItemsByAccount.keySet());
        //List<double> totalValues = new List<double>{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
        return last4Quarters;
    }
        
    public static List<List<string>> getAccountTeamRecords(List<string> teamRoles) {
        Set<Id> accountIds = new Set<Id>();
        for (AccountTeamMember atm : [SELECT AccountId FROM AccountTeamMember WHERE UserId = :userInfo.getUserId()
                                     AND (TeamMemberRole = 'Account Executive' or TeamMemberRole = 'OEM Account Executive' or 
                                     TeamMemberRole = 'OEM Global Account Manager' or TeamMemberRole = 'Inside Sales Rep')]) {
            accountIds.add(atm.AccountId);
        }
        //system.debug('***Harsha*** accountids : '+accountIds);
        //Map<string, Set<string>> usersByRole = new Map<string, Set<string>>();
        usersByRole = new Map<string, Set<string>>();
        for (AccountTeamMember atm : [SELECT Id, UserId, User.Name, TeamMemberRole FROM AccountTeamMember WHERE AccountId IN :accountIds AND TeamMemberRole IN :teamRoles]) {
            string role = normalizeRoleFieldName(atm.TeamMemberRole);
            if (!usersByRole.containsKey(role)) {
                usersByRole.put(role, new Set<string>());
            }
            usersByRole.get(role).add(atm.User.Name);
        }
        system.debug('***Harsha*** usersByRole : '+usersByRole);
        List<string> row = new List<string>();
        for (string teamRole : teamRoles) {
            string value = '';
            string role = normalizeRoleFieldName(teamRole);
            if (usersByRole.containsKey(role)) {
                List<string> names = new List<string>(usersByRole.get(role));
                names.sort();
                value = string.join(names, ', ');
            }
            row.add(value);
        }
        
        return new List<List<string>>{ row };
    }

    public static List<List<string>> getAccountPrioritization(string objectName, List<Id> accountIds, integer maxSlide1AccountPrioritizationRows, 
                                                             string accountPrioritization1ObjectName, string accountPrioritization2ObjectName) {
        List<List<string>> rows = new List<List<string>>();
        //List<double> totalValues = new List<double>{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
            
        integer startIndex = 0;
        integer endIndex = 0;
        if (objectName == accountPrioritization1ObjectName) {
            endIndex = Math.min(maxSlide1AccountPrioritizationRows, accountIds.size());
        } else if (objectName == accountPrioritization2ObjectName && accountIds.size() > maxSlide1AccountPrioritizationRows) {
            startIndex = maxSlide1AccountPrioritizationRows;
            endIndex = accountIds.size();
        }
        
        if (endIndex > startIndex) {
            List<RevenuePrioritization> rps = revenueItemsByAccount.values();
            rps.sort();
            
            for (integer i = startIndex; i < endIndex; i++) {
                RevenuePrioritization rp = rps[i];//this.revenueItemsByAccount.get(accountId);
                rows.add(new List<string>{
                    rp.accountName,
                    getNonNullString(rp.fyRevenue[0].round()),
                    getNonNullString(rp.fyRevenue[1].round()),
                    getNonNullString(rp.fyRevenue[2].round()),
                    getNonNullString(rp.currentFYQRevenue[0].round()),
                    getNonNullString(rp.currentFYQRevenue[1].round()),
                    getNonNullString(rp.currentFYQRevenue[2].round()),
                    getNonNullString(rp.currentFYQRevenue[3].round()),
                    getNonNullString(percentageGrowth(rp.lastQuarter.revenue, rp.previousQuarter.revenue).round()),
                    getNonNullString(percentageGrowth(rp.last4Quarters.revenue, rp.previous4Quarters.revenue).round()),
                    getNonNullString(rp.last4Quarters.revenue.round())
                });
                /*'AccountName', 'CFY_Revenue', 'LFY_Revenue', 'PFY_Revenue',
                    'Q1_Revenue', 'Q2_Revenue', 'Q3_Revenue', 'Q4_Revenue',
                    'QQ_Growth', 'YY_Growth', 'L4Q_Revenue'*/
               // system.debug('***Harsha***TP_Utilities**** totalValues <<<<< add list : '+totalValues);
                addLists(totalValues, new List<double>{
                    rp.fyRevenue[0],
                    rp.fyRevenue[1],
                    rp.fyRevenue[2],
                    rp.currentFYQRevenue[0],
                    rp.currentFYQRevenue[1],
                    rp.currentFYQRevenue[2],
                    rp.currentFYQRevenue[3],
                    rp.lastQuarter.revenue,
                    rp.previousQuarter.revenue,
                    rp.last4Quarters.revenue,
                    rp.previous4Quarters.revenue,
                    rp.last4Quarters.revenue
                });
            }
        }
       // system.debug('***Harsha***TP_Utilities**** totalValues after add list : '+totalValues);
        if ((TP_Utilities.accountIds.size() <= maxSlide1AccountPrioritizationRows && objectName == accountPrioritization1ObjectName) ||
            (TP_Utilities.accountIds.size() >  maxSlide1AccountPrioritizationRows && objectName == accountPrioritization2ObjectName)
                    ) {
                        rows.add(new List<string>{
                            'Total',
                            getNonNullString(totalValues[0].round()),
                            getNonNullString(totalValues[1].round()),
                            getNonNullString(totalValues[2].round()),
                            getNonNullString(totalValues[3].round()),
                            getNonNullString(totalValues[4].round()),
                            getNonNullString(totalValues[5].round()),
                            getNonNullString(totalValues[6].round()),
                            getNonNullString(percentageGrowth(totalValues[7], totalValues[8]).round()),
                            getNonNullString(percentageGrowth(totalValues[9], totalValues[10]).round()),
                            '-1000000'
                        });
                    }
        
        return rows;
    }
    
    public static List<List<string>> getLobRevenueTrends() {
        List<List<string>> rows = new List<List<string>>();
        
        for (Id accountId : revenueItemsByAccount.keySet()) {
            RevenuePrioritization rp = revenueItemsByAccount.get(accountId);
            rows.add(new List<string>{
                rp.accountName,
                getNonNullString(rp.last4Quarters.desktop.round()),
                getNonNullString(percentageGrowth(rp.lastQuarter.desktop, rp.previousQuarter.desktop).round()),
                getNonNullString(percentageGrowth(rp.last4Quarters.desktop, rp.previous4Quarters.desktop).round()),
                getNonNullString(rp.last4Quarters.notebook.round()),
                getNonNullString(percentageGrowth(rp.lastQuarter.notebook, rp.previousQuarter.notebook).round()),
                getNonNullString(percentageGrowth(rp.last4Quarters.notebook, rp.previous4Quarters.notebook).round()),
                getNonNullString(rp.last4Quarters.server.round()),
                getNonNullString(percentageGrowth(rp.lastQuarter.server, rp.previousQuarter.server).round()),
                getNonNullString(percentageGrowth(rp.last4Quarters.server, rp.previous4Quarters.server).round()),
                getNonNullString(rp.last4Quarters.storage.round()),
                getNonNullString(percentageGrowth(rp.lastQuarter.storage, rp.previousQuarter.storage).round()),
                getNonNullString(percentageGrowth(rp.last4Quarters.storage, rp.previous4Quarters.storage).round()),
                getNonNullString(rp.last4Quarters.networking.round()),
                getNonNullString(percentageGrowth(rp.lastQuarter.networking, rp.previousQuarter.networking).round()),
                getNonNullString(percentageGrowth(rp.last4Quarters.networking, rp.previous4Quarters.networking).round()),
                getNonNullString(rp.last4Quarters.revenue.round())
            });
        }
        
        return rows;
    }
        
    public static List<List<string>> getSummarizedRevenue() {
        RevenueItem l4q  = revenueItemsByQuarterPeriod.containsKey('L4Q') ? revenueItemsByQuarterPeriod.get('L4Q') : new RevenueItem();
        RevenueItem p4q  = revenueItemsByQuarterPeriod.containsKey('P4Q') ? revenueItemsByQuarterPeriod.get('P4Q') : new RevenueItem();
        RevenueItem pp4q  = revenueItemsByQuarterPeriod.containsKey('PP4Q') ? revenueItemsByQuarterPeriod.get('PP4Q') : new RevenueItem();
        system.debug('***Harsha*** l4q : '+l4q);
        system.debug('***Harsha*** p4q : '+p4q);
        system.debug('***Harsha*** pp4q : '+pp4q);
        return new List<List<string>>{ new List<string>{
            getNonNullString(l4q.revenue.round()),    getNonNullString(p4q.revenue.round()),    getNonNullString(pp4q.revenue.round()),
            getNonNullString(l4q.margin.round()),     getNonNullString(p4q.margin.round()),     getNonNullString(pp4q.margin.round()),
            getNonNullString(l4q.desktop.round()),    getNonNullString(p4q.desktop.round()),    getNonNullString(pp4q.desktop.round()),
            getNonNullString(l4q.notebook.round()),   getNonNullString(p4q.notebook.round()),   getNonNullString(pp4q.notebook.round()),
            getNonNullString(l4q.server.round()),     getNonNullString(p4q.server.round()),     getNonNullString(pp4q.server.round()),
            getNonNullString(l4q.storage.round()),    getNonNullString(p4q.storage.round()),    getNonNullString(pp4q.storage.round()),
            getNonNullString(l4q.networking.round()), getNonNullString(p4q.networking.round()), getNonNullString(pp4q.networking.round()),
            getNonNullString(l4q.partner.round()),    getNonNullString(p4q.partner.round()),    getNonNullString(pp4q.partner.round()),
            getNonNullString(l4q.direct.round()),     getNonNullString(p4q.direct.round()),     getNonNullString(pp4q.direct.round())
        } };
    }
    
    public static void getRevenueData(List<string> currentFYQuarters, List<string> previousQuarters, Set<string> l4Quarters, Set<string> p4Quarters, Set<string> pp4Quarters) {
        Set<Id> accountIds = new Set<Id>();
        for (AccountTeamMember atm : [SELECT AccountId FROM AccountTeamMember WHERE UserId = :userInfo.getUserId() 
                                     AND (TeamMemberRole = 'Account Executive' or TeamMemberRole = 'OEM Account Executive' or 
                                     TeamMemberRole = 'OEM Global Account Manager' or TeamMemberRole = 'Inside Sales Rep')]) {
            accountIds.add(atm.AccountId);
        }
        
        for (integer k = 0; k < 2; k++) {
            integer offset = k * 2000;
            for (AggregateResult ar : [SELECT Account__c, Account__r.Name, Fiscal_Year__c, Fiscal_Quarter__c,
                                            SUM(Total_QTR_Rev__c) revenue, SUM(Total_QTR_Margin__c) margin, SUM(Desktop_QTR_Rev__c) desktop, SUM(Notebook_QTR_Rev__c) notebook,
                                            SUM(Server_QTR_Rev__c) server, SUM(Storage_QTR_Rev__c) storage, SUM(Networking_QTR_Rev__c) networking, SUM(Partner_QTR_Rev__c) partner,
                                            SUM(Direct_QTR_Rev__c) direct
                                        FROM Revenue__c WHERE
                                            Account__c IN :accountIds AND
                                            (FiscalYearQuarter__c IN :previousQuarters OR FiscalYearQuarter__c IN :currentFYQuarters)
                                        GROUP BY Account__c, Account__r.Name, Fiscal_Year__c, Fiscal_Quarter__c
                                        LIMIT 2000 OFFSET :offset
            ]) {
                Id accountId = (Id)ar.get('Account__c');
                RevenuePrioritization rp = new RevenuePrioritization((string)ar.get('Name'));
                if (revenueItemsByAccount.containsKey(accountId)) {
                    rp = revenueItemsByAccount.get(accountId);
                }
                
                string quarterPeriod;
                string fiscalYear = string.valueOf(ar.get('Fiscal_Year__c'));
                string fiscalYearQuarter = fiscalYear + string.valueOf(ar.get('Fiscal_Quarter__c'));
                if (l4Quarters.contains(fiscalYearQuarter)) {
                    quarterPeriod = 'L4Q';
                    rp.last4Quarters.add(ar);
                    if (!partnerRevenueLast4Quarters.containsKey(fiscalYearQuarter)) {
                        partnerRevenueLast4Quarters.put(fiscalYearQuarter, getNonNullDouble(ar.get('partner')));
                    } else {
                        partnerRevenueLast4Quarters.put(fiscalYearQuarter, partnerRevenueLast4Quarters.get(fiscalYearQuarter) + getNonNullDouble(ar.get('partner')));
                    }
                } else if (p4Quarters.contains(fiscalYearQuarter)) {
                    quarterPeriod = 'P4Q';
                    rp.previous4Quarters.add(ar);
                } else if (pp4Quarters.contains(fiscalYearQuarter)) {
                    quarterPeriod = 'PP4Q';
                }
                
                double revenue = getNonNullDouble(ar.get('revenue'));
                
                for (integer i = 0; i < currentFYQuarters.size(); i++) {
                    if (currentFYQuarters[i] == fiscalYearQuarter) {
                        rp.currentFYQRevenue[i] = revenue;
                    }
                }
                
                if (fiscalYearQuarter == previousQuarters[0]) {
                    rp.lastQuarter = new RevenueItem(ar);
                } else if (fiscalYearQuarter == previousQuarters[1]) {
                    rp.previousQuarter = new RevenueItem(ar);
                }
                
                for (integer i = 0; i < 3; i++) {
                    if (fiscalYear == 'FY'+getNonNullString(currentFiscalYear - i)) {
                        rp.fyRevenue[i] += revenue;
                        break;
                    }
                }
                
                if (!string.isBlank(quarterPeriod)) {
                    if (!revenueItemsByQuarterPeriod.containsKey(quarterPeriod)) {
                        revenueItemsByQuarterPeriod.put(quarterPeriod, new RevenueItem(ar));
                    } else {
                        revenueItemsByQuarterPeriod.get(quarterPeriod).add(ar);
                    }
                }
                
                revenueItemsByAccount.put(accountId, rp);
            }
        }
    }
    
    public static List<List<string>> getFocusAccountPlans() {
        string fiscalYear = 'FY' + getNonNullString(currentFiscalYear).substring(2);
        
        List<List<string>> rows = new List<List<string>>();
        for (Account a : [SELECT Name, (SELECT Name, Plan_Status__c, No_of_Strategies__c FROM R00N60000001PRP8EAO__r WHERE Plan_Starting_Fiscal_Year__c = :fiscalYear)
                            FROM Account WHERE
                                //Focus_Account__c = true AND
                                Focus_Account__c != null AND //v2.0
                                Id IN (SELECT AccountId FROM AccountTeamMember WHERE UserId = :userInfo.getUserId() 
                                AND (TeamMemberRole = 'Account Executive' or TeamMemberRole = 'OEM Account Executive' or 
                                TeamMemberRole = 'OEM Global Account Manager' or TeamMemberRole = 'Inside Sales Rep'))]){
                                
            if (a.R00N60000001PRP8EAO__r != null && !a.R00N60000001PRP8EAO__r.isEmpty()) {
                for (SFDC_Acct_Plan__c ap : a.R00N60000001PRP8EAO__r) {
                    rows.add(new List<string> { a.Name, ap.Name, ap.Plan_Status__c, getNonNullString(ap.No_of_Strategies__c) });
                }
            } else {
                rows.add(new List<string> { a.Name, '-', '-', '-' });
            }
        }
        return rows;
    }
    
    
    public static List<List<string>> getPartnerRevenue(Set<string> fiscalYearQuarters) {
        List<List<string>> rows = new List<List<string>>();
        
        for (AggregateResult ar : [SELECT Account__r.Name, SUM(Partner_QTR_Rev__c) rev FROM Revenue__c
                                  WHERE Account__c IN (SELECT AccountId FROM AccountTeamMember WHERE UserId = :userInfo.getUserId() 
                                          AND (TeamMemberRole = 'Account Executive'or TeamMemberRole = 'OEM Account Executive' or 
                                          TeamMemberRole = 'OEM Global Account Manager' or TeamMemberRole = 'Inside Sales Rep')) AND
                                    FiscalYearQuarter__c IN :fiscalYearQuarters
                                GROUP BY Account__r.Name
                                HAVING SUM(Partner_QTR_Rev__c) > 0
                                ORDER BY SUM(Partner_QTR_Rev__c) DESC
                                LIMIT 10
        ]) {
            rows.add(new List<string>{ (string)ar.get('Name'), string.valueOf(ar.get('rev')) });
        }
        return rows;
    }
    
    public static List<List<string>> getPartnerGrowth() {
        List<List<string>> rows = new List<List<string>>();
        for (string fyq : partnerRevenueLast4Quarters.keySet()) {
            rows.add(new List<string>{
                fyq,
                getNonNullString(partnerRevenueLast4Quarters.get(fyq))
            });
        }
        return rows;
    }
    
     public static List<List<string>> getTerritoryPlanning(Integer maxSlide1AccountPrioritizationRows) {
     List<List<string>> rows = new List<List<string>>{ new List<string>{
                        currentFYQ.replace('Q', ' Q'),
                        'FY'+getNonNullString(currentFiscalYear).substring(2),
                        'FY'+getNonNullString(currentFiscalYear-1).substring(2),
                        'FY'+getNonNullString(currentFiscalYear-2).substring(2),
                        string.valueOf(accountIds.size() > maxSlide1AccountPrioritizationRows)
                    } };
                        return rows;
     }
        
    @testVisible
    private static FiscalYearSettings getCurrentFiscalYearSettings() {
        return [SELECT StartDate, EndDate FROM FiscalYearSettings WHERE StartDate <= today ORDER BY EndDate DESC LIMIT 1];
    }
    
    @testVisible
    private static List<string> getCurrentFYQuarters(integer fiscalYear) {
        string fyPrefix = string.format('FY{0}Q0', new List<string>{ getNonNullString(fiscalYear) });
        return new List<string>{
            fyPrefix + '1',
            fyPrefix + '2',
            fyPrefix + '3',
            fyPrefix + '4'
        };
    }
    
    @testVisible
    private static List<string> getPreviousQuarters(integer fiscalYear, Date fyStartDate) {
        integer year = fiscalYear;
        Date today = Date.today();
        
        integer currentQuarterIndex = 0;
        for (integer i = 0; i < 4; i++) {
            if (today >= fyStartDate.addMonths(3 * i)) {
                currentQuarterIndex = i;
            } else {
                break;
            }
        }
        
        List<string> fiscalYearQuarters = new List<string>();
        for (integer i = 11; i > -1; i--) {
            integer quarterIndex = Math.mod(i + currentQuarterIndex, 4);
            if (quarterIndex == 3) {
                year--;
            }
            fiscalYearQuarters.add(string.format('FY{0}Q0{1}',  new List<string>{ string.valueOf(year).replace(',', ''), string.valueOf(quarterIndex+1) }));
        }
        return fiscalYearQuarters;
    }
    
    public class RevenueItem {
        double revenue { get; set; }
        double margin { get; set; }
        double desktop { get; set; }
        double notebook { get; set; }
        double server { get; set; }
        double storage { get; set; }
        double networking { get; set; }
        double partner { get; set; }
        double direct { get; set; }
        
        RevenueItem() {
            this.revenue = this.margin = this.desktop =
                this.notebook = this.server = this.storage = 
                this.networking = this.partner = this.direct = 0;
        }
        
        RevenueItem(AggregateResult r) {
            this.revenue    = getNonNullDouble(r.get('revenue'));
            this.margin     = getNonNullDouble(r.get('margin'));
            this.desktop    = getNonNullDouble(r.get('desktop'));
            this.notebook   = getNonNullDouble(r.get('notebook'));
            this.server     = getNonNullDouble(r.get('server'));
            this.storage    = getNonNullDouble(r.get('storage'));
            this.networking = getNonNullDouble(r.get('networking'));
            this.partner    = getNonNullDouble(r.get('partner'));
            this.direct     = getNonNullDouble(r.get('direct'));
        }
        
        void add(AggregateResult otherRevenue) {
            this.revenue    += getNonNullDouble(otherRevenue.get('revenue'));
            this.margin     += getNonNullDouble(otherRevenue.get('margin'));
            this.desktop    += getNonNullDouble(otherRevenue.get('desktop'));
            this.notebook   += getNonNullDouble(otherRevenue.get('notebook'));
            this.server     += getNonNullDouble(otherRevenue.get('server'));
            this.storage    += getNonNullDouble(otherRevenue.get('storage'));
            this.networking += getNonNullDouble(otherRevenue.get('networking'));
            this.partner    += getNonNullDouble(otherRevenue.get('partner'));
            this.direct     += getNonNullDouble(otherRevenue.get('direct'));
        }
    }
    
    public class RevenuePrioritization implements Comparable {
        RevenueItem lastQuarter { get; set; }
        RevenueItem previousQuarter { get; set; }
        RevenueItem last4Quarters { get; set; }
        RevenueItem previous4Quarters { get; set; }
        List<double> fyRevenue { get; set; }
        List<double> currentFYQRevenue { get; set; }
        string accountName { get; set; }
        
        RevenuePrioritization(string accountName) {
            this.accountName = accountName;
            this.fyRevenue = new List<double>{ 0, 0, 0 };
            this.currentFYQRevenue = new List<double>{ 0, 0, 0, 0 };
            this.lastQuarter = new RevenueItem();
            this.previousQuarter = new RevenueItem();
            this.last4Quarters = new RevenueItem();
            this.previous4Quarters = new RevenueItem();
        }
        public integer compareTo(object compareTo) {
            if (compareTo == null) return -1;
            RevenuePrioritization otherRP = (RevenuePrioritization)compareTo;
            if (this.last4Quarters.revenue > otherRP.last4Quarters.revenue) return -1;
            if (this.last4Quarters.revenue == otherRP.last4Quarters.revenue) return 0;
            return 1;
        }
    }
    
    private static void addLists(List<double> list1, List<double> list2) {
        for (integer i = 0; i < Math.min(list1.size(), list2.size()); i++) {
            list1[i] = list1[i] + list2[i];
        }
    }
    
    public static string normalizeRoleFieldName(string role) {
        return role.replace(' ', '_').replace('.', '');
    }
        
    public static double percentageGrowth(double d1, double d2) {
        return d2 == 0 ? 0 : 100 * ((d1 - d2) / d2);
    }
    
    private static double getNonNullDouble(object o) {
        return o == null ? 0 : double.valueOf(o);
    }
    
    private static string getNonNullString(object o) {
        return o == null ? '' : string.valueOf(o);
    }
}