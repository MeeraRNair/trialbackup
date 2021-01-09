/***********************************************************
* Name          : MassUpdateAPVController
* Description   : Controller class for MassUpdateAPV Page
* ---------------------------------------------------------
* Revision      Release     Name            Date            CR#     Description
* 1.0          14.5        Mayank Mishra,  11-April-2013   8173    Mass update functionality in which user can update more than one records at a time
*                           Saurabh Gupta
*
************************************************************/

public class MassUpdateAPVController{
    
    //private List<APCWrapper> APCWrapList{get;set;}
    public list<Associated_Programs_Vendors__c> APCList = new list<Associated_Programs_Vendors__c>{};
    private string APCListQuery;
    public list<string> lstOfsortFields = new list<string>();
    public list<decimal> lstOfCurrFields = new list<decimal>();
    private set<Associated_Programs_Vendors__c> selectedAPC;
    public string marketPlanId {get;set;}
    public list<Associated_Programs_Vendors__c> lstOfAssociatedProgramVendors {get;set;}
    //public list<Associated_Programs_Vendors__c> lstOfAssociatedProgramVendorsOnNext {get;set;}
    public map<string,list<Associated_Programs_Vendors__c>> mapCombinationKeyAndLstOfAssociatedPrograms = new map<string,list<Associated_Programs_Vendors__c>>();
    public List<string> alphabet{get;set;}
    public list<Associated_Programs_Vendors__c> lstOfEditedAPVRecords;
    public string Name {get;set;}
    public Integer totalPages { get; set; }
    public  Boolean mplanErr { get; set; } 
    public String sortExp = 'Program_Name__c';
    public String sortDirection = 'ASC';
    //public String sortField {get;set;}
    string serverName; 
    // Reason :This method gets the value of Host.
    public void getHost()
    {
        serverName=ApexPages.currentPage().getHeaders().get('Host');
    }
     
    // Reason :This method gets the ServerName.
    public string getserverName()
    {
         return(serverName);
    }
    
   
    // Reason :This method sets the ServerName.
    public void setserverName(string serverName)
    {
        this.serverName=serverName;
    }
    
    public MassUpdateAPVController()
    {   
        getHost();
        String usrProfileName = [select u.Profile.Name from User u where u.id = :Userinfo.getUserId()].Profile.Name;
        
        if('MDF Co-Marketing  Manager'  == usrProfileName || 'System Administrator'  == usrProfileName || 'MDF Marketing Operations / Contract Admin'  == usrProfileName)
        {
            mplanErr = false;
        }
        else
        {
            mplanErr = true;
        }

        marketPlanId = Apexpages.currentPage().getParameters().get('id');
        Name = [select Name from Marketing_Plan__c where id =:marketPlanId limit 1].Name;  
        alphabet=new string[]{'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z','All','Other'};  
        selectedAPC= new set<Associated_Programs_Vendors__c>();
        APCListQuery= 'select id,name,LastModifiedDate,Program_Name__c,Business_Segment__c,Rate_Card_Price__c,Budgeted_Price__c,POP_Status__c,POP_Status_Reason__c,Status__c,Contract_Status_Reason__c,Package__c,Invoice_Amount__c from Associated_Programs_Vendors__c where Marketing_Plan__c =:marketPlanId order by Program_Name__c limit 10000';  
    }

    public ApexPages.StandardSetController standardSetCon
    {
        get {
         Decimal dtotalPages;
            if(standardSetCon == null) {
                standardSetCon = new ApexPages.StandardSetController(Database.getQueryLocator(APCListQuery));
                  standardSetCon.setPageSize(2000);
            }
            return standardSetCon;
        }
        set;
    }

    public List<Associated_Programs_Vendors__c > getCurrentList() 
    {
        
        
        lstOfAssociatedProgramVendors = new list<Associated_Programs_Vendors__c >();       
        
        for (Associated_Programs_Vendors__c category : (List<Associated_Programs_Vendors__c>)standardSetCon.getRecords())
        {
            lstOfAssociatedProgramVendors.add(category);
            if(mapCombinationKeyAndLstOfAssociatedPrograms.get(category.Name+ category.POP_Status__c+category.Status__c+category.POP_Status_Reason__c+category.Contract_Status_Reason__c)==NUll)
            {
                mapCombinationKeyAndLstOfAssociatedPrograms.put(category.Name+category.POP_Status__c+category.Status__c+category.POP_Status_Reason__c+category.Contract_Status_Reason__c+category.Budgeted_Price__c, new list<Associated_Programs_Vendors__c>());
            }
            mapCombinationKeyAndLstOfAssociatedPrograms.get(category.Name+category.POP_Status__c+category.Status__c+category.POP_Status_Reason__c+category.Contract_Status_Reason__c+category.Budgeted_Price__c).add(category);
            
        }
        
        // building map for updating those records which user updating
        // with the help of map buiiding unique key for the editable fields 
        return lstOfAssociatedProgramVendors;
    } 
    
    public pagereference massUpdateAPVRecrods()
    {
        lstOfEditedAPVRecords = new list<Associated_Programs_Vendors__c>();
        list<Associated_Programs_Vendors__c> lstOfAllProgramVendors = [select id,name,LastModifiedDate,Program_Name__c,POP_Status__c ,Business_Segment__c,Rate_Card_Price__c,Budgeted_Price__c,POP_Status_Reason__c,Status__c,Contract_Status_Reason__c,Package__c,Invoice_Amount__c from Associated_Programs_Vendors__c where Marketing_Plan__c =:marketPlanId];  
        for(Associated_Programs_Vendors__c apv : lstOfAssociatedProgramVendors)
        {             
            //Now checking with containsKey from the map it will give those records which are update            
                if(!mapCombinationKeyAndLstOfAssociatedPrograms.containskey(APV.Name+apv.POP_Status__c+apv.Status__c+apv.POP_Status_Reason__c+apv.Contract_Status_Reason__c+apv.Budgeted_Price__c))
                  {
                    lstOfEditedAPVRecords.add(apv);   
                  }
        }

        if(lstOfEditedAPVRecords!=Null && lstOfEditedAPVRecords.Size()>0)
        {
            update lstOfEditedAPVRecords;
        }
        //standardSetCon.save();
        PageReference pageRef;
        if(marketPlanId !=null){
           pageRef=new PageReference('/'+marketPlanId );
        }
        return pageRef;
    }
    
    public string sortField{ 
        get{
            return sortExp;   
        }    
        set{
            if (value== sortExp)
            sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            else
            sortDirection = 'ASC';
            sortExp = value;
        }
    }
    
    public String getSortDirection(){
        if (sortField == null)
        return 'ASC';
        else
        return sortDirection;
    }
    
    public void setSortDirection(String value){ 
        sortDirection = value;
    }
    
    
    
    public PageReference refreshList2() 
    {   standardSetCon = null;     
        string s;
        if(sortField==null){
            sortField='Program_Name__c';
        }
        string str='Associated_Programs_Vendors__c';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(str);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        Schema.DisplayType fielddataType = fieldMap.get(sortField).getDescribe().getType();
       
        if(apexpages.currentpage().getparameters().get('alpha') == 'Other')
        {  
            APCList= [select id,name,LastModifiedDate,Program_Name__c,Package__c,POP_Status__c ,Business_Segment__c,Rate_Card_Price__c,Budgeted_Price__c,POP_Status_Reason__c,Status__c,Contract_Status_Reason__c from Associated_Programs_Vendors__c where Marketing_Plan__c =:marketPlanId limit 10000];           
            String strName='';
            for ( Associated_Programs_Vendors__c objAPCList : APCList)
            {
                if(fielddataType == Schema.DisplayType.Currency){
                    Double dubl=objAPCList.Rate_Card_Price__c;
                    strName=String.valueOf(dubl); 
                }
                else{
                    if(sortField=='Name'){
                        strName=objAPCList.Name;
                    }                
                    else if(sortField=='Business_Segment__c'){                
                        strName=objAPCList.Business_Segment__c;
                    }                     
                    else{                
                        strName=objAPCList.Program_Name__c;
                    }
                }                
                
                if(!((strName.substring(0,1)>='A' && strName.substring(0,1)<='z'))) 
                //|| Name.substring(0,1)==' '))
                {
                    lstOfsortFields.add(strName);
                    lstOfCurrFields.add(Decimal.valueOf(strName));
                    //APCListQuery =APCListQuery +objAPCList ;
                    
                }
            }
            massUpdateAPVRecrods();   
       }
       else if(apexpages.currentpage().getparameters().get('alpha') == 'All')
       {
           s='%';
           lstOfsortFields.clear();
       }    
       else
       { 
           s= apexpages.currentpage().getparameters().get('alpha')+'%';
           lstOfsortFields.clear();
           massUpdateAPVRecrods();
           system.debug('lstOfCurrFields '+lstOfCurrFields);
       }
        
        if(fielddataType == Schema.DisplayType.Currency){
            if(lstOfCurrFields.size()==0){
                APCListQuery= 'select id,name,LastModifiedDate,Program_Name__c,Package__c,POP_Status__c ,Business_Segment__c,Rate_Card_Price__c,Budgeted_Price__c,POP_Status_Reason__c,Status__c,Contract_Status_Reason__c from Associated_Programs_Vendors__c where Marketing_Plan__c =:marketPlanId order by '+sortField+' '+sortDirection+' limit 5000';
            }else
            {
                APCListQuery= 'select id,name,LastModifiedDate,Program_Name__c,Package__c,POP_Status__c ,Business_Segment__c,Rate_Card_Price__c,Budgeted_Price__c,POP_Status_Reason__c,Status__c,Contract_Status_Reason__c from Associated_Programs_Vendors__c where '+sortField+' IN :lstOfCurrFields and Marketing_Plan__c =:marketPlanId order by '+sortField+' '+sortDirection+' limit 5000';
            }
        }
        else{
            APCListQuery= 'select id,name,LastModifiedDate,Program_Name__c,Package__c,POP_Status__c ,Business_Segment__c,Rate_Card_Price__c,Budgeted_Price__c,POP_Status_Reason__c,Status__c,Contract_Status_Reason__c from Associated_Programs_Vendors__c where ('+sortField+' like' +'\''+s +'\''+ ' or '+sortField+' IN:lstOfsortFields) and Marketing_Plan__c =:marketPlanId order by '+sortField+' '+sortDirection+' limit 5000';
        }
        return null;
    }
    
    public PageReference sorting(){              
        standardSetCon = null;
        APCListQuery= 'select id,name,LastModifiedDate,Program_Name__c,Package__c,POP_Status__c ,Business_Segment__c,Rate_Card_Price__c,Budgeted_Price__c,POP_Status_Reason__c,Status__c,Contract_Status_Reason__c from Associated_Programs_Vendors__c where Marketing_Plan__c =:marketPlanId order by '+sortField+' '+sortDirection+' limit 5000';
        return null;  
    }
    
   
    
    public List<Associated_Programs_Vendors__c> getDisplaySelectedList(){
        List<Associated_Programs_Vendors__c> displaycon = new list<Associated_Programs_Vendors__c>();
        displaycon.addall(selectedAPC);
        return displaycon;
    }
      
    
    public PageReference CancelAction(){
       PageReference pageRef;
       if(marketPlanId !=null){
           pageRef=new PageReference('/'+marketPlanId );
       }
       return pageRef;
    }

}