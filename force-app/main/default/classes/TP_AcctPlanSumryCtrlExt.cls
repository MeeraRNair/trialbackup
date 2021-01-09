/*
* Author   : Sri Harsha Ch
* Purpose  : Controller extension class to detail Account Plan summary
*        
* Revision 	Ref Number  	Release No  Date            Modified By     Description
* -------- 	----------  	----------  -----------     ------------    -----------
* 1.0      	CR15126,15127   DCS0102     14-Nov-2017     Harsha          Controller extension class to save input fields and detail Account Plan summary 
* 1.1	   	CR15152			FY18-0102	21-Nov-2017		Harsha			Removed logic related to save and pageNavigation
*/

public class TP_AcctPlanSumryCtrlExt {

    public List<TP_AccPlanSumWrapper> TP_APS_ShowList{get;set;}

    transient List<TP_AccPlanSumWrapper> TP_APS_List;
    
    //Navigation variables
    Integer counter = 0;//TO track the number of records parsed
    Integer limitSize = 10;//Number of records to be displayed
    Integer totalSize =0; //To Store the total number of records available
    public integer table{get;set;}
    public integer totalTables{get;set;}
    
    public TP_AcctPlanSumryCtrlExt(ApexPages.StandardController controller) {
        
        tabledata();
        TP_APS_ShowList = new list<TP_AccPlanSumWrapper>();
        totalSize = TP_APS_List.size();
        
        if(math.mod(totalSize , limitSize) == 0){
            table=1;
            totalTables= totalSize/limitSize;
        }
        else{
            table=1;
            totalTables= (totalSize/limitSize)+1;
        }
        
        if((counter+limitSize) <= totalSize){
            iterationlst(0,limitSize);
        }
        else{
            totalTables = (totalSize/limitSize);
            if(totalTables<1){
                totalTables=1;
            }
            table=1;
            iterationlst(0,totalSize);
        }
    }
    
    public void first(){
        
        TP_APS_ShowList.clear();
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
        
        TP_APS_ShowList.clear();
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
        
        TP_APS_ShowList.clear();
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
        
        TP_APS_ShowList.clear();
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
            TP_APS_ShowList.add(TP_APS_List.get(i));
        } 
    }
    
    public void tabledata(){ 
        TP_APS_List=new List<TP_AccPlanSumWrapper>();
        
        TP_Utilities.initiateFYQuarterCalc();
        List<List<string>> rows= TP_Utilities.getFocusAccountPlans();
        
        system.debug('rows : '+rows.size());
        for(integer i=0; i<rows.size(); i++)
        {
            TP_AccPlanSumWrapper wrapper = new TP_AccPlanSumWrapper();
            wrapper.accountName =rows[i][0];
            wrapper.accPlanName = rows[i][1];
            wrapper.status=rows[i][2];
            wrapper.noOfStrategies=rows[i][3];
            
            TP_APS_List.add(wrapper);
        }
    }
    
    public class TP_AccPlanSumWrapper{
        public String accountName { get; set; }
        public String accPlanName { get; set; }
        public String status { get; set; }
        public String noOfStrategies { get; set; }
        
        public TP_AccPlanSumWrapper( ){ }
    }
    
}