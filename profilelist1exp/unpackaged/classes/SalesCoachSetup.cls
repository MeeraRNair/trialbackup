/***********************************************************

Name: Goal of Selling Stage
Description: Class to create/edit/view Sales Coach activities
Revision  Name            Date            Description
------------------------------------------------------------
*1.0      Devika          21.08.2013      CR 8579
*2.0      Devika          12.09.2013      Defect 80048

************************************************************/
public without sharing class SalesCoachSetup {

    public String stage                         { get; set; }
    public String toDelete                      { get; set; }
    public String language                      { get; set; }
    public String goalStage                     { get; set; }
    public String lang                          { get; set; }      
    private Boolean showSections = false;
    public Boolean flag {get;set;}
    public Boolean getShowSections(){return this.showSections;}

    private Sales_Coach_Setup__c scStage;
    public Sales_Coach_Setup__c getScStage(){return this.scStage;}

    private List<Sales_Coach_Activity__c> scActivities;
    public List<Sales_Coach_Activity__c> getScActivities(){return this.scActivities;}
    
    Map<String, String> LanguageCodeMap = new Map<String, String>();
    
    //this gets the opportunity stages from OppurtunityStage which is set by user   
    public static SelectOption[] getOpptyStages(){
      SelectOption[] options = new SelectOption[] {};
      options.add( new SelectOption( '-- Select --', '-- Select --' ) );
      List<OpportunityStage> OS = [Select MasterLabel from OpportunityStage where IsActive=true order by SortOrder];
      
      for(OpportunityStage ml:OS){
        options.add( new SelectOption(ml.MasterLabel.trim(), ml.MasterLabel.trim() ) );   
      }  
                       
      return options;
    }   
     
    public List<SelectOption> getLanguages()
    {
      List<SelectOption> options = new List<SelectOption>();
        
       Schema.DescribeFieldResult fieldResult =
         User.LanguageLocaleKey.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
          system.debug('*****'+ple);
          options.add(new SelectOption('-- Select --', '-- Select --'));
        
       for( Schema.PicklistEntry f : ple)
       {
          options.add(new SelectOption(f.getValue(), f.getLabel()));
          LanguageCodeMap.put(f.getValue(), f.getLabel());
       }       
       system.debug('*****'+options);
       
       return options;
    }   
    
    public SalesCoachSetup(ApexPages.StandardController controller) {
        
        // View Page
        flag = false;
        List<Sales_Coach_Setup__c> scStage = [Select Id,Name,LanguageCode__c,Language__c from Sales_Coach_Setup__c where Id =: controller.getRecord().id];               
        if(!scStage.isEmpty()){
          this.stage  = scStage[0].Name;
          this.language = scStage[0].LanguageCode__c;
          lang = scStage[0].Language__c;
          getSections();
          flag = true;
        }      
    }

    // Retrieve the sales coach sections (and items in those sections)
    public PageReference getSections() {
        Sales_Coach_Setup__c[] salesCoachStage;
        // Only show the data if both picklists have an option selected
        if  ( this.stage == '-- Select --' || this.language == '-- Select --') {
            this.showSections = false;
            return null;
        }
        try{
            salesCoachStage = [select id, 
                                      name,Goal_Stage__c,
                                      active__c,(select id, 
                                            name, 
                                            activity_details__c, 
                                            ordering_number__c,
                                            Sales_Coach_Setup__c
                                     from Sales_Coach_Activities__r ORDER BY ordering_number__c )
                               from Sales_Coach_Setup__c 
                               where active__c = true 
                               and name = : this.stage 
                               and LanguageCode__c =: this.language]; 
        }catch(QueryException e){ 
            ApexPages.addMessages(e);
        }
        if( salesCoachStage.size() > 0 ){
            this.scStage = salesCoachStage[0]; 
        }
        else {
            createNewScStage();
        }   
        this.showSections = true;
        // Get activities for this stage, populate them if necessary
        try{
            if(this.scStage != null){
                this.scActivities =  this.scStage.Sales_Coach_Activities__r;
            }
        }catch(QueryException e){
            ApexPages.addMessages(e);
        }
        addBlankActivities(3);                    
        return null;
    }
    
    public Static String getKeyprefix(){   
        Schema.DescribeSObjectResult sObjDesc = Sales_Coach_Setup__c.sObjectType.getDescribe();  
        return '/'+ sObjDesc.keyPrefix;
    }
    public PageReference saveClose() {
        saveActivities();
        return new PageReference(getKeyPrefix());        
    }   
    public PageReference btncancel() {
        return new PageReference(getKeyPrefix());        
    } 

    public PageReference saveActivities() {
        
        
        upsert this.scStage;        
        
        List<Sales_Coach_Activity__c> toAdd = new List<Sales_Coach_Activity__c>();        
        for(Sales_Coach_Activity__c sca : this.scActivities){
            if(sca.activity_details__c != null){
                if(sca.Sales_Coach_Setup__c == null)sca.Sales_Coach_Setup__c = scStage.id;
                toAdd.add(sca);
            }
        }

        upsert toAdd;
        if(!flag)lang = LanguageCodeMap.get(this.language);        
        getSections();
        flag = true;
        return null;
    }

    
    public PageReference deleteActivity(){
        Sales_Coach_Activity__c scActivity;
        if(this.toDelete != null || this.toDelete != ''){
            try{
                 scActivity = [select id
                               from Sales_Coach_Activity__c
                               where id = : this.toDelete];
                    
                delete scActivity;
                getSections();
            }catch(Exception e){
                ApexPages.addMessages(e);
            }
        }
        return null;        
    }
    
       
    private void createNewScStage(){
        lang = LanguageCodeMap.get(this.language);
        this.scStage = new Sales_Coach_Setup__c(Name = this.stage,LanguageCode__c = this.language,           
                                             Active__c = true, Language__c = lang);
                    
    }
       
    private void addBlankActivities(Integer pNumOfBlank){
        if(this.scActivities == null){
            this.scActivities = new List<Sales_Coach_Activity__c>();
         }
        
        integer i = this.scActivities.size();
        
        if(pNumOfBlank != null){
            for(Integer x = 0; x < pNumOfBlank; x++){
                this.scActivities.add(new Sales_Coach_Activity__c(ordering_number__c = i + x + 1 ));
            }
        }
    }
}