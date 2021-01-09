/*
 * Author   : Kenny
 * Purpose  : Controller extension class to display charts for Historical Territory Overview page
 *        
 * Revision Ref Number  Release No  Date            Modified By     Description
 * -------- ----------  ----------  -----------     ------------    -----------
 * 1.0      CR#14845    CSM0102     09-Sep-2017     Kenny           Controller extension class to save input of Observations & Actions field for Historical Territory Overview page 
 * 1.1      CR14942     FY18-0102   20-Sep-2017     Harsha          Added functionality to display charts in VFP
 * 1.2		CR15152    	FY18-0102   21-Nov-2017     Harsha			Removed logic related to save and pageNavigation
 */

public class TP_HTOverviewCtrlExt{
    
    public string cFields {get; set;}
    public List<LOB_Compare> LOB_CompareData{get; set;}
    public List<RevenuesAll> revenuesData{get; set;}
    
    private static final Integer millions = 1000000;
    public map<string, map<string, Decimal>> summarizedRevenue;
    public Set<string> last4Quarters;
    
    public TP_HTOverviewCtrlExt(ApexPages.StandardController controller) {
        displayCharts();
    }
    
    public void displayCharts(){
        
        last4Quarters = TP_Utilities.initiateFYQuarterCalc();
        list<list<string>> row = TP_Utilities.getSummarizedRevenue();       
		system.debug('row '+row);

        list<string> commonFldsUnaligned = TP_Utilities.commonFields;
        system.debug('cFldsUnaligned '+commonFldsUnaligned);
        list<string> commonFields = new list<string>();
        for(integer i=commonFldsUnaligned.size()-1; i>=0;i--){
            commonFields.add(commonFldsUnaligned[i]);
        }
        //system.debug('commonFields '+commonFields);

        cFields = commonFields[commonfields.size()-1];
        for(integer i=commonfields.size()-2; i>=0; i--){
            cFields+=','+commonfields[i];
        }
		
        list<string> fieldsList = new list<string>{'Revenue', 'Margins'};
        fieldsList.addAll(commonFldsUnaligned);
        fieldsList.addall(new list<string>{'Partner', 'Direct'});
        system.debug('fieldsList'+ fieldsList);
        map<string, Decimal> l4q_smry = new map<string, Decimal>();
        map<string, Decimal> p4q_smry = new map<string, Decimal>();
        map<string, Decimal> pp4q_smry = new map<string, Decimal>();
        summarizedRevenue = new map<string, map<string, Decimal>>();

        for(integer i=0; i<fieldsList.size(); i++){
            for(integer j=0;j<row[0].size();j++){
                if(math.mod(j, 3)==0){
                    l4q_smry.put(fieldsList[i], Decimal.valueOf(row[0][j]));
                }
                else if(math.mod(j, 3)==1){
                    p4q_smry.put(fieldsList[i], Decimal.valueOf(row[0][j]));
                }
                else if(math.mod(j, 3)==2){
                    pp4q_smry.put(fieldsList[i], Decimal.valueOf(row[0][j]));
                    i+=1;
                }
            }
        }
        summarizedRevenue.put('L4Q', l4q_smry);
        summarizedRevenue.put('P4Q', p4q_smry);
        summarizedRevenue.put('PP4Q', pp4q_smry);
        system.debug('summarizedRevenue : '+summarizedRevenue);

        LOB_CompareData = new List<LOB_Compare>();
        Integer lcfIndex = fieldsList.size()-3;     //lcfIndex - lastCommonFieldIndex
        Integer fcfIndex = 2;                       //fcfIndex - firstCommonFieldIndex
        for(integer i=fcfIndex; i<=lcfIndex;i++) { 
            LOB_CompareData.add(new LOB_Compare(fieldsList[i], l4q_smry.get(fieldsList[i]), p4q_smry.get(fieldsList[i])));
        }
        
        revenuesData = new List<RevenuesAll>();
        revenuesData.add(new RevenuesAll('PP4Q',pp4q_smry));
        revenuesData.add(new RevenuesAll('P4Q',p4q_smry));
        revenuesData.add(new RevenuesAll('L4Q',l4q_smry));
        
        //system.debug('revenuesData : '+revenuesData);
        //system.debug('LOB_CompareData : '+LOB_CompareData);
        
    }
    
    private static string currencyFormat(decimal dAmt){
        String amount = dAmt.format().contains('.')?dAmt.format():(dAmt.format()+'.00');
        return amount;
    }
    

    public class RevenuesAll {
        public String name { get; set; }
        
        public Decimal Revenue { get; set; }
        public Decimal Margins { get; set; }
        public String s_Revenue { get; set; }
        public String s_Margins { get; set; }
        
        public Decimal Networking { get; set; }
        public Decimal Storage { get; set; }
        public Decimal Server { get; set; }
        public Decimal Notebook { get; set; }
        public Decimal Desktop { get; set; }
       
        public String s_Networking { get; set; }
        public String s_Storage { get; set; }
        public String s_Server { get; set; }
        public String s_Notebook { get; set; }
        public String s_Desktop { get; set; }
        
        public RevenuesAll(String name, map<string, Decimal> cf){
            this.name = name;
            decimal rev = cf.get('Revenue');
            decimal marg = cf.get('Margins');
            decimal ntw = cf.get('Networking');
            decimal strg = cf.get('Storage');
            decimal serv = cf.get('Server');
            decimal nb = cf.get('Notebook');
            decimal dktp = cf.get('Desktop');
            integer scale = 2;
            this.Revenue = rev.divide(millions, scale);
            this.Margins = marg.divide(millions, scale);
            this.Networking = ntw.divide(millions, scale);
            this.Storage = strg.divide(millions, scale);
            this.Server = serv.divide(millions, scale);
            this.Notebook = nb.divide(millions, scale);
            this.Desktop = dktp.divide(millions, scale);
            
            this.s_Revenue = currencyFormat(rev);
            this.s_Margins = currencyFormat(marg);
            this.s_Networking = currencyFormat(ntw);
            this.s_Storage = currencyFormat(strg);
            this.s_Server = currencyFormat(serv);
            this.s_Notebook = currencyFormat(nb);
            this.s_Desktop = currencyFormat(dktp);
        }
    }
    
    public class LOB_Compare {
        public String name { get; set; }
        public Decimal revenueL4Q { get; set; }
        public Decimal revenueP4Q { get; set; }
        public String s_revenueL4Q { get; set; }
        public String s_revenueP4Q { get; set; }
        public LOB_Compare(String name, Decimal rev_l4q, Decimal rev_p4q) {
            this.name = name;
            integer scale = 2;
            this.revenueL4Q = rev_l4q.divide(millions, scale);
            this.revenueP4Q = rev_p4q.divide(millions, scale);
            this.s_revenueL4Q = currencyFormat(rev_l4q);
            this.s_revenueP4Q = currencyFormat(rev_p4q);
        }
    }
    
}