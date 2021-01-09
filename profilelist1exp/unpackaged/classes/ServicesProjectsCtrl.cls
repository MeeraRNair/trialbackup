/*
History:
Version Date            Modified By     Description
--------------------------------------------------------------------------------------
1.0                                     Created
2.0    05-Dec-2013      Azwanti        R15.03 CR8954 - added Dell Services Industry as multipicklist field
3.0    16-May-2014      Shahiruni      R15.07 CR9478 SOM - Rename Services Project button
4.0    18-Sep-2015      Fenny          CSM1102 CR11975 - Add Project_End_Date__c field
*/


public class ServicesProjectsCtrl {

    public Integer PAGE_SIZE {get;set;}
    public Opportunity opp {get;set;}
    public List<Services_Project__c> spList ;
    public Integer noOfRecords {get;set;}
    public string queryString {get;set;}
    public String dealID {get;set;}
    public String affinityAccountID {get;set;}
    public String projectID {get;set;}      
    
    public String sortDirection='ASC';
    public String sortExp = 'Book_date__c';
    public string sortFullExp; 
    
    public String dealIdString {get;set;}
    //public String dslobString {get;set;}
    public String dellDefinedLobString {get;set;}
    public String affinityAccountString {get;set;}
    public String projectIdString {get;set;}
    //CR8954 added Dell_Services_Industry__c in SOQL
    public String selectString = 'Select Id,Name, Opportunity__c, Affinity_Account_ID__c, Account_Name__c, Deal_ID__c,Dell_Services_LOB__c, Dell_Services_Industry__c, ' + 
                                    'Opportunity_Name__c,Services_Unweighted_Revenue__c,Book_Date__c,Opportunity_Owner__c,CP_Affinity_Customer_Number__c,Project_ID__c, ' +
                                    'Project_Manager__c,Project_Name__c,Project_Start_Date__c,Services_Sales_Owner__c,opportunity__r.Dell_Defined_LOB__c, ' +
                                    'Project_End_Date__c ' + // 4.0
                                    'From Services_Project__c where Name!=null ';
   
   public List<Services_project__c > exportSpList {get;set;}
 
    //public Integer currentPageNo ;
    
    //CR8954 for Dell Services Industry multi picklist
    List<SelectOption> dellServIndOriginalvalues = new List<SelectOption>();
    Public List<string> dellServIndLeftselected{get;set;}
    Public List<string> dellServIndRightselected{get;set;}
    Set<string> dellServIndLeftvalues = new Set<string>();
    public Set<string> dellServIndRightvalues {get;set;}
    public String dellServIndString {get;set;}
    //End of CR8954 
    
    public ServicesProjectsCtrl() {
        PAGE_SIZE = 25;
        setCon = null;
        spList = new List<Services_Project__c> ();
        dellDefinedLobString ='';
        affinityAccountString ='';
        projectIdString ='';
        dellServIndString ='';
        
        opp = new Opportunity();
        dealID =  ApexPages.currentPage().getParameters().get('dlid');
        
        if(dealID !=null && dealID !=''){
         dealIdString =  ' and Deal_ID__c like  \'%'+dealID + '%\'';
         //CR8954 - added dellServIndString in the SOQL
         queryString = selectString +dealIdString + dellDefinedLobString +affinityAccountString +projectIdString +dellServIndString + ' order by Project_ID__c ASC'+' limit 10000' ;
        }
        else {
        dealIdString = '';
        //CR8954 - added dellServIndString in the SOQL
        queryString = selectString +dealIdString + dellDefinedLobString +affinityAccountString +projectIdString +dellServIndString + ' order by Book_date__c ASC'+' limit 10000' ;
        }
        
        //Start of CR 8954        
        //for Dell Services Industry multi picklist
        dellServIndLeftselected = new List<String>();
        dellServIndRightselected = new List<String>();
        dellServIndRightvalues = new Set<string>();
        dellServIndOriginalvalues = SObjectUtils.getPickValues(new Opportunity(), 'Dell_Defined_Industry__c', null);
        for(System.SelectOption entry : dellServIndOriginalvalues){
            dellServIndLeftvalues.add(entry.getValue());  
        }        
        //End of CR 8954
    }

    public ApexPages.StandardSetController setCon {
        get{
            if(setCon == null){
            system.debug('###8954 queryString: '+queryString);
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                setCon.setPageSize(PAGE_SIZE);
                noOfRecords = setCon.getResultSize();
            }
            return setCon;
        }set;
    }

    //To get the Services project List
    Public List<Services_Project__c> getspList (){
        List<Services_Project__c> projectList= new List<Services_Project__c>();
        for(Services_Project__c sp : (List<Services_Project__c>)setCon.getRecords())
            projectList.add(sp);
        return projectList;
    }
  
    
    //Return total pages    
    Public Integer getTotalPages(){
 
        Decimal totalSize = this.setCon.getResultSize();
        Decimal pageSize = this.setCon.getPageSize();
        Decimal pages = totalSize/pageSize; 
        return (Integer)pages.round(System.RoundingMode.CEILING);
    }
    
    //To get Current Page Number
    public Integer currentPageNo {
        get {
            return setCon.getPageNumber();
        }
        set;
    }
    
    public PageReference search(){
        setCon = null;
       
         /*if(dealID == '' && opp.Dell_Defined_LOB__c == null && affinityAccountID =='' && projectID ==''){
                dellDefinedLobString = ' and Opportunity__r.Dell_Defined_LOB__c = null ';
                dealIdString = ' and Deal_ID__c = null';
                affinityAccountString = ' and Affinity_Account_ID__c = null ';
                projectIdString = ' and Project_ID__c = null';
                // return;
         }
        else{*/
                
        if(dealID !='')
          dealIdString =  ' and Deal_ID__c like  \'%'+dealID.trim() + '%\'';
        else  dealIdString = '';
       
           
        if(opp.Dell_Defined_LOB__c!=null){
                 List <string> dellDefinedLobStringList = opp.Dell_Defined_LOB__c.split(';');
                 dellDefinedLobString = ' and (Opportunity__r.Dell_Defined_LOB__c INCLUDES (\'' + dellDefinedLobStringList[0] + '\')';
                 for(Integer i=1;i<dellDefinedLobStringList.size();i++){
                    dellDefinedLobString = dellDefinedLobString+' OR Opportunity__r.Dell_Defined_LOB__c INCLUDES (\'' + dellDefinedLobStringList[i] + '\')';
                 } 
                dellDefinedLobString = dellDefinedLobString +')';
             }
         else  dellDefinedLobString = '';
         
         
         if(affinityAccountID !='')
            affinityAccountString = ' and Affinity_Account_ID__c like  \'%'+affinityAccountID.trim()+ '%\'';
         else affinityAccountString = '';
         
         
         if(projectID !='')
            projectIdString = ' and Project_ID__c like  \'%'+projectID.trim()+ '%\'';
         else projectIdString = '';
         
        //CR8954
        if(dellServIndRightvalues.size() >0){  
            system.debug('###8954 dellServIndRightvalues: '+dellServIndRightvalues);     
            Integer counter = 0;      
            dellServIndString = ' and Dell_Services_Industry__c IN (';
            for(String s: dellServIndRightvalues){
                if(counter++ != 0){     
                    dellServIndString += ',';
                }
                dellServIndString += '\'' + s+ '\'';
            }
            dellServIndString += ')'; 
        }
        else dellServIndString = '';
        // End of CR8954
            
        queryString = selectString +dealIdString + dellDefinedLobString +affinityAccountString +projectIdString +dellServIndString +' order by Name'+' limit 10000' ;

    return null;
    
    }
    

   public String sortExpression
       {
         get
             {
                return sortExp;
             }
         set
             {
       //if the column is clicked on then switch between Ascending and Descending modes
               if (value == sortExp)
                 sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
               else
                 sortDirection = 'ASC';
               sortExp = value;
             }
       }

 public String getSortDirection()
 {
    //if not column is selected 
    if (sortExpression == null || sortExpression == '')
      return 'ASC';
    else
     return sortDirection;
 }

 public void setSortDirection(String value)
 {  
   sortDirection = value;
 }
 
public PageReference ViewData(){
    setCon = null;
    sortFullExp = sortExpression  + ' ' + sortDirection;
    //CR8954 - added dellServIndString in the SOQL
    queryString = selectString +dealIdString + dellDefinedLobString +affinityAccountString +projectIdString +dellServIndString +' order by '+sortFullExp +' limit 10000';
    System.debug('Query string &&&&&&&view'+queryString );
    return null;
}

public PageReference openReport(){
    exportSpList = Database.query(queryString);
    String urlString = '/apex/ServicesProjectsExport';    
    PageReference pageRef = new PageReference(urlString);
    return pageRef;

}

//3.0 CR9478 Start
    public String getOpenNewReport(){
        String reportId = [SELECT Id FROM Report WHERE Name = 'Services_projects' LIMIT 1].Id;
        if(reportId != '' && reportId != null){
            return '/'+reportId;
        }else{
            return null;
        }
    }
//3.0 CR9478 End

//Start of CR8954
    //to mimick multipicklist function on Dell Services Industry picklist
    public PageReference dellServIndSelectclick(){
        dellServIndrightselected.clear();
        system.debug('#### 8954 dellServIndleftselected: '+dellServIndleftselected);
        for(String s : dellServIndleftselected){
            dellServIndleftvalues.remove(s);
            dellServIndrightvalues.add(s);
        }
        return null;
    }
    
    public PageReference dellServIndUnselectclick(){
        dellServIndleftselected.clear();
        for(String s : dellServIndrightselected){
            dellServIndrightvalues.remove(s);
            dellServIndleftvalues.add(s);
        }
        return null;
    }

    public List<SelectOption> getdellServIndUnSelectedValues(){        
        List<SelectOption> options = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(dellServIndLeftvalues);
        tempList.sort();
        for(string s : tempList)
            options.add(new SelectOption(s,s));
        return options;
    }

    public List<SelectOption> getdellServIndSelectedValues(){
        List<SelectOption> options1 = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(dellServIndRightvalues);
        tempList.sort();
        for(String s : tempList)
            options1.add(new SelectOption(s,s));
        return options1;
    }
    //End of CR8954

}