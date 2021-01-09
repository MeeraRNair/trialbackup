/*
* Author   : Kenny
* Purpose  : Controller extension class to detail for LOB Revenue Trends
*        
* Revision 	Ref Number  Release No  Date            Modified By     Description
* -------- 	----------  ----------  -----------     ------------    -----------
* 1.0      	CR#14891    CSM0102     15-Sep-2017     Kenny           Controller extension class to save input of Observations & Actions field for LOB Revenue Trends page 
* 1.1	   	CR14982		CSM0102		01-Oct-2017		Ramesh			Functionlity for table data display
* 1.2	   	CR15152		FY18-0102	21-Nov-2017		Harsha			Removed logic related to save and pageNavigation
*/

public class TP_LOBRT_ObsActionsCtrlExt {

    Transient List<TP_LOBRT_List> TPLLst;
    public List<TP_LOBRT_List> tp_toshow{get;set;}
    public integer table{get;set;}
    public integer totalTables{get;set;}
    
    //Navigation variables
    Integer counter = 0;//TO track the number of records parsed
    Integer limitSize = 10;//Number of records to be displayed
    Integer totalSize =0; //To Store the total number of records available
    
    TP_AccRevTrendsCtrlExt accRevTred;
	list<TP_AccRevTrendsCtrlExt.TP_AccRevTrendsWrapper> accRevTredLst; //use accRevenue Trends to sequence display of LOB data
    
    public TP_LOBRT_ObsActionsCtrlExt(ApexPages.StandardController controller) {
        TP_AccRevTrendsCtrlExt accRevTred = new TP_AccRevTrendsCtrlExt(controller);
        accRevTredLst = accRevTred.TPARTList;
        tabledata();
        
        tp_toshow = new list<TP_LOBRT_List>();
        totalSize = TPLLST.size();
        //number of pages
        
        if(math.mod(totalSize , limitSize) == 0){
            table=1;
            totalTables= totalSize/limitSize;
            
        } else{
            table=1;
            totalTables= (totalSize/limitSize)+1;
        }
        if((counter+limitSize) <= totalSize){
            iterationlst(0,limitSize);
        }else{
            totalTables = (totalSize/limitSize);
            if(totalTables<1){
                    totalTables=1;
                }
            table=1;
            iterationlst(0,totalSize);
        }
        //v1.1 end
    }
    
    public void first(){
        tp_toshow.clear();
        tabledata();
        table=1;
        counter=0;
        if((counter + limitSize) <= totalSize){
            iterationlst(0,limitSize);
        } else{
            iterationlst(0,totalSize);
        }
    }
    
    public void next(){
        tp_toshow.clear();
        tabledata();
        counter=counter+limitSize;
        table++;
        if((counter+limitSize) <= totalSize){
            iterationlst(counter,(counter+limitSize));
        } else{
            iterationlst(counter,totalSize);
        }
       
    }
    
    public void previous(){
        tp_toshow.clear();
        tabledata();
        table--;
        if(counter<limitSize && counter!=0){
            iterationlst(0,counter);
        } else{
            counter=counter-limitSize;
            iterationlst(counter,(counter+limitSize));  
        }
    }
    
    public void last (){
        tp_toshow.clear();
        tabledata();
        table=totalTables;
        if(math.mod(totalSize , limitSize) == 0){
            counter = limitSize * ((totalSize/limitSize)-1);
        } else if (math.mod(totalSize , limitSize) != 0){
            counter = (limitSize * (totalSize/limitSize));
        }
        iterationlst(counter,totalSize);  
    }
    
    public Boolean getDisableNext(){
        return (((counter + limitSize) >= totalSize )?true:false); 
    }
    
    public Boolean getDisablePrevious(){
        return (counter==0?true:false);
    } 
    
    public void iterationlst(integer counter, integer lmtsize){
        for(integer i=counter ;i<lmtsize; i++){
            tp_toshow.add(TPLLst.get(i));
        } 
    }
    public void tabledata(){ 
        TPLLst=new List<TP_LOBRT_List>();
        TP_Utilities.initiateFYQuarterCalc();
        List<List<string>> rows= TP_Utilities.getLobRevenueTrends();
        //system.debug('rowwww '+rows.size());
        List<TP_LOBRT_List> TPLstTemp = new List<TP_LOBRT_List>();
        for(integer i=0; i<rows.size(); i++)
        {
            TP_LOBRT_List tpl = new TP_LOBRT_List();
            tpl.accountName =rows[i][0];
            tpl.desktop = currencyFormat(Decimal.valueOf(rows[i][1]));
            tpl.des_qq=percentsufix(Decimal.valueOf(rows[i][2]));
            tpl.des_yy=percentsufix(Decimal.valueOf(rows[i][3]));
            tpl.notebook=currencyFormat(Decimal.valueOf(rows[i][4]));
            tpl.nb_qq=percentsufix(Decimal.valueOf(rows[i][5]));
            tpl.nb_yy=percentsufix(Decimal.valueOf(rows[i][6]));
            tpl.server=currencyFormat(Decimal.valueOf(rows[i][7]));
            tpl.ser_qq=percentsufix(Decimal.valueOf(rows[i][8]));
            tpl.ser_yy=percentsufix(Decimal.valueOf(rows[i][9]));
            tpl.storage=currencyFormat(Decimal.valueOf(rows[i][10]));
            tpl.stg_qq=percentsufix(Decimal.valueOf(rows[i][11]));
            tpl.stg_yy=percentsufix(Decimal.valueOf(rows[i][12]));
            tpl.netWorking=currencyFormat(Decimal.valueOf(rows[i][13]));
            tpl.nw_qq=percentsufix(Decimal.valueOf(rows[i][14]));
            tpl.nw_yy=percentsufix(Decimal.valueOf(rows[i][15]));
            //TPLLst.add(tpl);
            TPLstTemp.add(tpl);
        }
        
        for(integer i=0; i<accRevTredLst.size(); i++){
            for(TP_LOBRT_List lob : TPLstTemp){
                if(accRevTredLst[i].accountName == lob.accountName){
                    TPLLst.add(lob);
                }
            }
        }
    }
       
    private static string currencyFormat(decimal dAmt){
        String amount = '$'+ dAmt.format();
        return amount;
    }
    private static string percentsufix(decimal dAmt){
        String amount = dAmt.format() +'%';
        return amount;
    }
    public class TP_LOBRT_List{
        
        public String accountName { get; set; }
        public String desktop { get; set; }
        public String des_qq { get; set; }
        public String des_yy { get; set; }
        public String notebook { get; set; }
        public String nb_qq { get; set; }
        public String nb_yy { get; set; }
        public String server { get; set; }
        public String ser_qq { get; set; }
        public String ser_yy { get; set; }
        public String storage { get; set; }
        public String stg_qq { get; set; }
        public String stg_yy { get; set; }
        public String netWorking { get; set; }
        public String nw_qq { get; set; }
        public String nw_yy { get; set; }
        
        public TP_LOBRT_List( ){
            
        }
    }
}