/*
* Author  : Nagaraju Yelluri
* Purpose : To display Account Revenue Trends Information.
* 
* Revision 	CR Number   	Release No  Date            Modified By     Description
* -------- 	---------   	----------  -----------     ------------    -----------
* 1.0      	CR14927,14973   FY18-0102   15-Sep-2017     Nagaraju        Displays Account Revenue Trends information related to Territory Plan.
* 1.1	   	CR15152			FY18-0102	21-Nov-2017		Harsha			Removed logic related to save and pageNavigation
*/

public class TP_AccRevTrendsCtrlExt {
    
    public string accName {get;set;}
    public string qGrowth {get;set;}
    public string yGrowth {get;set;}
    
    public List < List < String >> colHeadersList {get;set;}
    @testVisible
    private static final string accountPrioritization1ObjectName = 'Apex_AccountPrioritization1';
    @testVisible
    private static final string accountPrioritization2ObjectName = 'Apex_AccountPrioritization2';
    private final integer maxSlide1AccountPrioritizationRows = 19;

    public transient List<TP_AccRevTrendsWrapper> TPARTList;
    public List<TP_AccRevTrendsWrapper> TPARTShowList{get;set;}
    
    //Navigation variables
    Integer counter = 0;//TO track the number of records parsed
    Integer limitSize = 10;//Number of records to be displayed
    Integer totalSize =0; //To Store the total number of records available
    public integer table{get;set;}
    public integer totalTables{get;set;}
    
    public TP_AccRevTrendsCtrlExt(ApexPages.StandardController controller) {
        
        accName = 'Account Name';
        qGrowth = 'Q/Q Growth';
        yGrowth = 'Y/Y Growth';
        
       // tp_Update = (Territory_Plan__c) Controller.getRecord();
        TP_Utilities.initiateFYQuarterCalc();
        
        colHeadersList = TP_Utilities.getTerritoryPlanning(maxSlide1AccountPrioritizationRows);
        
        tabledata();
        TPARTShowList = new list<TP_AccRevTrendsWrapper>();
        totalSize = TPARTList.size();
        
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
        system.debug('TPARTList '+TPARTList);
        system.debug('TPARTShowList '+TPARTShowList);
    }
    
    public void first(){
        
        TPARTShowList.clear();
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
        
        TPARTShowList.clear();
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
        
        TPARTShowList.clear();
        tabledata();
        table--;
        if(counter<limitSize && counter!=0){
            iterationlst(0,counter);
        }else{
            counter=counter-limitSize;
            iterationlst(counter,(counter+limitSize)); 
        }
        
    }
    
    public void last (){
        
        TPARTShowList.clear();
        tabledata();
        table=totalTables;
        if(math.mod(totalSize , limitSize) == 0){
            counter = limitSize * ((totalSize/limitSize)-1);
        } else if (math.mod(totalSize , limitSize) != 0){
            counter = limitSize * ((totalSize/limitSize));
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
            TPARTShowList.add(TPARTList.get(i));
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
    
    public void tabledata(){ 
        TPARTList=new List<TP_AccRevTrendsWrapper>();
        
        TP_Utilities.initiateFYQuarterCalc();
        List<List<string>> rows= TP_Utilities.getAccountPrioritization(accountPrioritization1ObjectName, TP_Utilities.accountIds, maxSlide1AccountPrioritizationRows, accountPrioritization1ObjectName, accountPrioritization2ObjectName);
        rows.addAll(TP_Utilities.getAccountPrioritization(accountPrioritization2ObjectName, TP_Utilities.accountIds, maxSlide1AccountPrioritizationRows, accountPrioritization1ObjectName, accountPrioritization2ObjectName));
        system.debug('rows size : '+rows.size());
        for(integer i=0; i<rows.size(); i++)
        {
            TP_AccRevTrendsWrapper wrapper = new TP_AccRevTrendsWrapper();
            wrapper.accountName =rows[i][0];
            wrapper.fy1 = currencyFormat(Decimal.valueOf(rows[i][3]));
            wrapper.fy2=currencyFormat(Decimal.valueOf(rows[i][2]));
            wrapper.fy_YTD=currencyFormat(Decimal.valueOf(rows[i][1]));
            wrapper.fy_Q1=currencyFormat(Decimal.valueOf(rows[i][4]));
            wrapper.fy_Q2=currencyFormat(Decimal.valueOf(rows[i][5]));
            wrapper.fy_Q3=currencyFormat(Decimal.valueOf(rows[i][6]));
            wrapper.fy_Q4=currencyFormat(Decimal.valueOf(rows[i][7]));
            wrapper.qq_Growth=percentsufix(Decimal.valueOf(rows[i][8]));
            wrapper.yy_Growth=percentsufix(Decimal.valueOf(rows[i][9]));
            
            TPARTList.add(wrapper);
        }
    }
    
    public class TP_AccRevTrendsWrapper{
        public String accountName { get; set; }
        public String fy1 { get; set; }
        public String fy2 { get; set; }
        public String fy_YTD { get; set; }
        public String fy_Q1 { get; set; }
        public String fy_Q2 { get; set; }
        public String fy_Q3 { get; set; }
        public String fy_Q4 { get; set; }
        public String qq_Growth { get; set; }
        public String yy_Growth { get; set; }
        
        public TP_AccRevTrendsWrapper( ){
            
        }
    }
    
}