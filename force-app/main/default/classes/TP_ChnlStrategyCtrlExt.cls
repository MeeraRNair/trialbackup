/*
 * Author   : Josie
 * Purpose  : Controller extension class to detail Channel Strategy charts
 *        
 * Revision Ref Number  Release No  Date            Modified By     Description
 * -------- ----------  ----------  -----------     ------------    -----------
 * 1.0      CR#14937    CSM0102     22-Sep-2017     Josie           Controller extension class to save input of Observations & Actions field for Channel Strategy page 
 * 1.1		CR14984		FY18-0102	02-Oct-2017		Harsha			Modified class to display charts in VF page
 * 1.2	   	CR15152		FY18-0102	21-Nov-2017		Harsha			Removed logic related to save and pageNavigation
 */

public class TP_ChnlStrategyCtrlExt{

    public List<PartnerDirectRev> revenuesData{get; set;}
    public List<PartnerRevQQGrowth> parRevQQData{get; set;}
    public List<Top10Accounts> top10AccData{get; set;}
    
    private static final Integer millions = 1000000;

    public TP_ChnlStrategyCtrlExt(ApexPages.StandardController controller) {
        //TP_Update = (Territory_Plan__c)Controller.getRecord(); 
        displaycharts(controller);
    }
 
    private void displaycharts(ApexPages.StandardController controller){
        TP_HTOverviewCtrlExt tp_HTobj = new TP_HTOverviewCtrlExt(controller);
        system.debug('*****chnl**********start');
        map<string, map<string, Decimal>> summarizedRevenue = tp_HTobj.summarizedRevenue;
        
        revenuesData = new List<PartnerDirectRev>();
        revenuesData.add(new PartnerDirectRev('PP4Q', summarizedRevenue.get('PP4Q').get('Partner'), summarizedRevenue.get('PP4Q').get('Direct')));
        revenuesData.add(new PartnerDirectRev('P4Q', summarizedRevenue.get('P4Q').get('Partner'), summarizedRevenue.get('P4Q').get('Direct')));
        revenuesData.add(new PartnerDirectRev('L4Q', summarizedRevenue.get('L4Q').get('Partner'), summarizedRevenue.get('L4Q').get('Direct')));
        
        list<list<string>> pgValues = TP_Utilities.getPartnerGrowth();
        parRevQQData = new list<PartnerRevQQGrowth>();
        map<string, Decimal> parDirValues = new map<string, Decimal>();
        list<string> fyQuarter = new list<string>();
        for(integer i=0;i<pgValues.size();i++){
            parDirValues.put(pgValues[i][0], decimal.valueof(pgValues[i][1]));
            fyQuarter.add(pgValues[i][0]); 
        }
        fyQuarter.sort();
        for(integer i=0;i<fyQuarter.size();i++){
            parRevQQData.add(new PartnerRevQQGrowth(fyQuarter[i], parDirValues.get(fyQuarter[i])));
        }
        //system.debug('parRevQQData : '+parRevQQData);
        
        list<list<string>> prValues = TP_Utilities.getPartnerRevenue(tp_HTobj.last4Quarters);
        //system.debug('prValues : '+prValues);
        top10AccData = new List<Top10Accounts>();
        for(integer i=0;i<prValues.size();i++){
            top10AccData.add(new Top10Accounts(prValues[i][0], decimal.valueof(prValues[i][1]), prValues.size()));
        }
    }
    
    
    private static string currencyFormat(decimal dAmt){
        String amount = dAmt.format().contains('.')?dAmt.format():(dAmt.format()+'.00');
        return amount;
    }
	
	public class PartnerDirectRev {
        public String name { get; set; }
        public Decimal Partner { get; set; }
        public Decimal Direct { get; set; }
        public String s_Partner { get; set; }
        public String s_Direct { get; set; }
        
        public PartnerDirectRev(String name, Decimal par, Decimal dir){
            this.name = name;
            integer scale = 2;
            this.Partner = par.divide(millions, scale);
            this.Direct = dir.divide(millions, scale);
            this.s_Partner = currencyFormat(par);
            this.s_Direct = currencyFormat(dir);

        }
    }  
    
    public class PartnerRevQQGrowth{
        public String name{ get; set; }
        public Decimal data{ get; set; }
        public String s_data{ get; set; }
        
        public PartnerRevQQGrowth(String name, Decimal data){
            this.name = name;
            integer scale =2;
            this.data = data.divide(millions, scale);
            this.s_data = currencyFormat(data);
        }
    }
    
    public class Top10Accounts{
        public String name{ get; set; }
        public String concName{ get; set; }
        public Decimal data{ get; set; }
        public String s_data{ get; set; }
        
        public Top10Accounts(String name, Decimal data, integer size){
            this.name = name;
            integer scale =2;
            this.data = data.divide(millions, scale);
            this.s_data = currencyFormat(data);
            if(size>=0&&size<=2){
                concName = (name.length()<=32?name:name.substring(0,32)+'..');
            }else if(size>2&&size<=4){
                concName = (name.length()<=16?name:name.substring(0,16)+'..');
            }else if(size>4&&size<=7){
                concName = (name.length()<=8?name:name.substring(0,8)+'..');
            }else if((size>7&&size<=10)){
                concName = (name.length()<=5?name:name.substring(0,5)+'..');
            }
        }
    }
}