/*********************************************************************

Name: Goal of Selling Stage
Description: Class to view Sales Coach activities for the current user
Revision  Name            Date            Description
------------------------------------------------------------
*1.0      Devika          21.08.2013      CR 8579
*2.0      Krishnakumar    08.Dec.2016     13797 Sales Coach Button Tracking                   

**********************************************************************/

public with sharing class SalesCoachController {
    
    public Boolean renderCheck                                      {get; set;  }
    public Boolean flag                                             {get; set;  }
    private String opportunityStage;
    public String getOpportunityStage()                             {return this.opportunityStage;}        
    
    public Opportunity oppty {get;set;}
    private Sales_Coach_Setup__c salesCoachStage;    
    public Sales_Coach_Setup__c  getSalesCoachStage()                {return this.salesCoachStage;}
    
    private List<Sales_Coach_Activity__c> salesCoachActivities;
    public List<Sales_Coach_Activity__c> getSalesCoachActivities()  {return this.salesCoachActivities;}
    
    public void setOpportunityStage(String pStage)                  {this.opportunityStage = pStage;}
    
    
    public SalesCoachController() {
        String ID = ApexPages.currentPage().getParameters().get('id');
        try{ 
            this.oppty = [select id, 
                          StageName, 
                          forecastcategory,Account.Regional_Parent_Name_lookup__c
                          from Opportunity 
                          where id= :ID];        
            this.opportunityStage = this.oppty.StageName;
            startProcess();
        }catch(QueryException e){
            ApexPages.addMessages(e);
        }
    }
    
    public void countClick(){
        
        try{
            String oppAccountRegion = oppty.Account.Regional_Parent_Name_lookup__c;
            
            SF1_Adoption__c obj1 = new SF1_Adoption__c();
            obj1.Object_Name__c = 'Opportunity';
            obj1.Record_ID__c = oppty.Id;
            obj1.Source__c = 'SalesCoach';
            obj1.User_Action__c = '';
            obj1.User_Edited_Date__c = Datetime.now();
            obj1.User_Name__c = UserInfo.getUserId();
            obj1.Region__c =  oppAccountRegion;
            obj1.Platform__c = 'Salesforce Classic';   
            
           
            insert obj1;
        }catch(DmlException e){System.debug('DEBUG ERROR####'+e.getMessage());}
    }  
    
    public void startProcess(){
        
        Boolean englishFlag = false;
        try{
            
            List<Sales_Coach_Setup__c> salesCoachList = [select Name, Id, Goal_Stage__c, Active__c,
                                                         (select Sales_Coach_Setup__c , Ordering_Number__c, Name, Id, Activity_Details__c 
                                                          from Sales_Coach_Activities__r ORDER BY Ordering_Number__c)
                                                         from Sales_Coach_Setup__c 
                                                         where Name = : this.opportunityStage 
                                                         AND LanguageCode__c =:UserInfo.getLanguage() 
                                                         Limit 1 ];
            if(UserInfo.getLanguage() != 'en_US'){    
                if(!salesCoachList.isEmpty()){  
                    this.salesCoachStage  = salesCoachList[0];
                    this.salesCoachActivities = this.salesCoachStage.Sales_Coach_Activities__r;
                    if(this.salesCoachActivities.size()> 0){}else{                          
                        englishFlag = true; 
                    } 
                }else{
                    englishFlag = true;               
                }                       
            }else{
                if(!salesCoachList.isEmpty()){
                    this.salesCoachStage  = salesCoachList[0];
                    this.salesCoachActivities = this.salesCoachStage.Sales_Coach_Activities__r;
                }else{
                    this.salesCoachStage  =  null; 
                }  
            }
            
            if(!englishFlag){
                this.salesCoachStage = [select Name, Id, Goal_Stage__c, Active__c,
                                        (select Sales_Coach_Setup__c , Ordering_Number__c, Name, Id, Activity_Details__c 
                                         from Sales_Coach_Activities__r ORDER BY Ordering_Number__c)
                                        from Sales_Coach_Setup__c 
                                        where Name = : this.opportunityStage 
                                        AND LanguageCode__c =:'en_US' 
                                        Limit 1 ];
                this.salesCoachActivities =  this.salesCoachStage.Sales_Coach_Activities__r;                                
            }                            
            
        }catch(QueryException e){
            system.debug('***'+e);
            this.salesCoachStage=null;
            flag = true;
        }
        
        if(this.salesCoachStage != null){
            if(this.salesCoachActivities.size() > 0 )
                this.renderCheck = true;
            else{
                this.renderCheck = false;
                flag = true;
            } 
        }else{
            flag = true;
        }
        
        
    }
    
    public SelectOption[] getOpptyStages() {
        
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Opportunity.StageName.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        } 
        
        return options;
    }
    
    public PageReference updateStageData() {
        flag = false;
        startProcess();
        return null;
    }
    
}