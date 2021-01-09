public without sharing class salesMotionLookupCtlr {

    public List<Sales_Motion__c> smRecords{get; Private set;}
    public String searchText{get; set;}
    public string searchname {get;set;}
    //Pagination variables
    Public Integer pageSize{get;set;} 
    Public Integer pageNumber{get;set;} 
    Public Boolean previousDis{get;set;}
    public Boolean flag {get;set;}
    Public Boolean nextDis{get;set;}
    Public Integer totalSize{get;set;}
    public Integer offset  {get;set;}
    
    //Error message variables
    Public Boolean errorShowHide{get;set;}
    Public String errorMsg{get;set;}
    
    //Base Query
     Private String baseQuery='select id,name from Sales_Motion__c where  RecordTypeId=:recordTypeId and IsActive__c= True';
     Private String baseQuery1='select id,name from Sales_Motion__c where  RecordTypeId=:recordTypeId and IsActive__c= True and name like';
    
    public salesMotionLookupCtlr()
    {
        pageSize= 10;
        pageNumber=0;
        totalSize=0;
        previousDis=true;
        errorMsg='';
        errorShowHide=false;
        flag = false;
        searchname=ApexPages.currentPage().getParameters().get('searchSM');
        searchText=searchname;
        loadSalesMotion(searchText);
        
    }
    
    public PageReference go()
    {
        flag = false; 
        pagesize = 10;
        pageNumber=0;
       loadSalesMotion(searchText);
       return null;
    
    
    }
    
    public void loadSalesMotion(String name)
    {
        String query;                     
        offset = pageNumber * pageSize;
        if(offset == 0)
        {
                previousDis = true;
        }                        
        smRecords=new list<Sales_Motion__c>();
        string recordTypeId=[select id from RecordType where sobjectType='Sales_Motion__c' and name='Generic Sales'].Id;
        if(name!=null && name!='')
        {
           name='%'+name+'%';
           totalSize = [select count() from Sales_Motion__c where  RecordTypeId=:recordTypeId and IsActive__c= True and name like :name ];
           query = baseQuery1+'\''+name+'\''+'ORDER BY Name LIMIT '+pageSize +' OFFSET '+ offset;
           //smRecords=[select id,name from Sales_Motion__c where name like:name and RecordTypeId=:recordTypeId and IsActive__c= True limit 1000];
        }
        else{
            totalSize = [select count() from Sales_Motion__c where  RecordTypeId=:recordTypeId and IsActive__c= True];
            query = baseQuery+' ORDER BY Name LIMIT '+pageSize +' OFFSET '+ offset;
            //smRecords=[select id,name from Sales_Motion__c where RecordTypeId=:recordTypeId and IsActive__c= True limit 1000];
        }
        system.debug(query);
         if(totalSize==0 || totalSize<=pageSize)
         {
             nextDis=true;
         }
         else
         {
            nextDis=false;
         } 
        smRecords=Database.query(query);
        system.debug(smRecords);
        if(smRecords.size()== 0)
        {
            flag = true;
            //nextDis = true;
            //previousDis = true;
        }
   
    }
     //Method for previous button of pagination
    Public PageReference previous()
    {
        try{
            pageNumber--;
            nextDis=false;
            if (pageNumber < 0)
            {
                return null;
            } 
            else if(pageNumber ==0)
            {
                previousDis=true;
            }   
            errorShowHide=false;
            loadSalesMotion(searchText);
        }
         catch(Exception e){
            ApexPages.addMessages(e);
        }
            return null;        
    }
    //Method for next button of pagination
    Public PageReference next()
    { 
        try{
            pageNumber++;  
            errorShowHide=false;   
            loadSalesMotion(searchText);
            Integer rem=math.mod(totalSize,pageSize);
            if(rem>0)
            {
                if(pageNumber==math.round(math.floor(totalSize/pageSize)))
                    nextDis=true;     
            }
            else
            {
                if(pageNumber==(totalSize/pageSize)-1)
                    nextDis=true;
            }
            
            
            previousDis=false;                
        }
         catch(Exception e){
            ApexPages.addMessages(e);
        }            
        return null;
        
    }
     //Method for first button of pagination    
    Public PageReference first()
    {     
        try{
            pageNumber=0;
            nextDis=false;
            errorShowHide=false;
            loadSalesMotion(searchText);
            previousDis=true;

        }  
         catch(Exception e){
            ApexPages.addMessages(e);
        }     
            return null;         
    }
    //Method for last button of pagination    
    Public pageReference last()
    {
        try{
            previousDis=false;
            errorShowHide=false;
            Integer rem=math.mod(totalSize,pageSize);
            if(rem>0)
            {
                pageNumber=math.round(math.floor(totalSize/pageSize)); 
            }
            else
            {
                pageNumber=(totalSize/pageSize)-1;
            }
            loadSalesMotion(searchText);
            nextDis=true;
        }
         catch(Exception e){
            ApexPages.addMessages(e);
        }
            return null;        
    }   
    
    

}