/* 
Author: Jessie Tan

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0     03-Dec-2011     Jessie Tan   Created for R13.1 - VF controller for Sales Motion UI page
1.1     01-Jul-2012     Ambickaa     Created for Go Back to Opportunity
                                     Created for Support Request Link on SalesMotion UI page  
1.1     01-Jul-2012     Sakthe       Created for SMUsage Tracker Record Insertion 
1.2     27-Nov-2012     Micky        R14.2 Sales Motion: Created for listing Salesmotion products in a picklist  
1.3     30-Jan-2013     Shue         Modify Country displayed in Sales Motion section according to Country Configured.
*/ 
                                     
public class VFCntrlr_SalesMotion {

    //share out to VF 
    public Sales_Motion__c salesMotion {get; set;}
    public Sales_Motion__c sm {get;set;}  //added Bikram
    public List<Sales_Motion_Page__c> salesMotionPages {get; set;} 
    public List<OpportunityLineItem> oppProducts {get; set;} 
    public List<String> stages {get; set;}    
    public List<String> stagePercents {get; set;}   
    public List<String> stageDescs {get; set;}  
    public List<Sales_Motion_Page_Section__c> currentLeftSections {get; set;}
    public List<Sales_Motion_Page_Section__c> currentRightSections {get; set;}
    public List<RecordType> rtList {get;set;}//added Bikram
    public String SalesNameID{get;set;} //added Bikram
    public Boolean showHide {get;set;}  //added Bikram
   
    public ID rt{get;set;}
    //R14.5
    public Boolean isRightSectionsExist {
        get {
            if(currentRightSections!=null) {
                return currentRightSections.size()>0;
            }
            return false;
        }
    }
    public String currentStage {get; set;}
    public String currentPage {get; set;}
    public boolean isStagedEnabled {get; set;}
    public String smErrMsg {get; set;}      
    public String smSearchMsg {get; set;}  
    public List<OpportunityTeamMember > teamMembers{get; set;}
    public OpportunityTeamMember teamMember{get; set;}
    public List<User> salesRep{get; set;}
    public String lineOfBusiness ='';
    public List<Opportunity> OppDetails {get; set;}  
    public Opportunity oppDetail{get; set;}
    public boolean isCustomError {get; set;}
    public boolean isCustomSearchError {get; set;}
    public boolean isSMavailable=true;
    public List<supportRequest> supportRequestLst{get; set;}
    public List<String> requestTypeSplit{get; set;}
    public static final Id OppId = ApexPages.currentPage().getParameters().get('Id');
    public static final Id smId = ApexPages.currentPage().getParameters().get('smId');
    public string OpportunityId=OppId;  
    public Map<String,Id> reqtype = new Map<String,Id>();
    public Boolean click = true;
    public boolean productTab {get; set;}
    public boolean newUserFlag {get; set;}
    public string selectedproduct{get;set;}
    public string countryregionparam{get;set;}
    public boolean isProdAvailable {get; set;}
    private Map<String, String> salesEdgeMappedLanguage = new Map<String, String>();
    
    Public List<selectOption> fullAvailableProducts = new List<SelectOption>();
    private Opportunity salesMotionSearch = new Opportunity();
    
    public void setSalesMotionSearch(Opportunity salesMotionSearch){
        salesMotionSearch = salesMotionSearch;
    }
    
    public Opportunity getSalesMotionSearch(){
        return salesMotionSearch;
    }
    
    //attribute that used locally
    private Map<Id, Sales_Motion_Page__c> salesMotionPagesMap = new Map<Id, Sales_Motion_Page__c>(); 
    private Map<String, List<Sales_Motion_Page_Section__c>> leftSections = new Map<String, List<Sales_Motion_Page_Section__c>>();
    private Map<String, List<Sales_Motion_Page_Section__c>> rightSections = new Map<String, List<Sales_Motion_Page_Section__c>>();
    private Id defaultPage;
    //private String salesEdgeMappedStage;   
    private Map<String, String> oppParameters =  new Map<String, String>();
    private Set<String> pageStageWithSalesEdgeContentRetrieved = new Set<String>();
    private static final String MARKETING_PAGE = 'Marketing/Sales ToolKit';   
    private static final String DOMAIN_KEY = 'domain';   
    private static final String SOLUTION_TYPE_KEY = 'soltype';   
    private static final String SOLUTION_NAME_KEY = 'solname';   
    private static final String COUNTRY_KEY = 'country';   
    private static final String STAGE_KEY = 'stage';
    private static final String CURRENT_PAGE_KEY = 'currentPage';
    private static final String CURRENT_STAGE_KEY = 'currentStage';
    private static final String OPP_ID_KEY = 'id';
    private static final String PRODUCT_KEY = 'product'; 
    private static final String BUSINESSUNIT_KEY = 'businessunit'; 
    private static final String REGION_KEY = 'region';
    private static final String SMSEARCH_KEY = 'search';
    
    private SalesEdgeDataProcesser salesEdgeDataProcesser;
    private SalesEdgeWebServiceCall salesEdgeWebServiceCall ;
    private boolean atLeast1SalesEdgeContentExisted = false;  
    
    
   
    public VFCntrlr_SalesMotion() {
        System.debug('### enter constructor');
        try {
            OppDetails = new list<Opportunity>();
            salesNameID = ApexPages.CurrentPage().getParameters().get('SalesMotionID'); //added Bikram
           
            system.debug('------Generic Sales Name-------'+salesNameID);
            rt = IdLookupUtils.getRecordTypeId('Generic Sales', 'Sales_Motion__c', true);
            showHide= true;
            if(salesNameID != NULL){
                sm = [select name, RecordTypeID from Sales_Motion__c where id =:salesNameID];
                if(sm.RecordTypeID == rt)
                {
                  system.debug('----inside if only when rt is generic');
                  showHide = false;
               }
               
            }
          
              
           
            initialLoad();
            retrieveAllSectionContent4CurrentPageStage();
        }
        catch (Exception e){
            handleError(e);
        } 
    }
    
    public class supportRequest {
        public String supportUrl{get;set;}
        public String supportName{get;set;}
        public String sectionName{get;set;}
        public String stage{get;set;}
        public String page{get;set;}
        
    }

    private void handleError(Exception e){
        if (e instanceOf SMNotFoundException){
            //smErrMsg = 'Sales Motion is not currently available for this solution.';
            isCustomError=true;  
            isSMavailable=false;
        }
        else if (e instanceOf SMNoPageException){
            isCustomError=false;
            smErrMsg = 'There is no Sales Motion pages available for the Sales Motion.';
        }
        else if (e instanceOf SMParamNotFoundException){
            isCustomError=false;
            smErrMsg = 'The Opportunity data (domain, solution type, solution name, stage, country, id) is not passed properly to Sales Motion.';
        }
        else if (e instanceOf InvalidSearchDataException){
            isCustomError=false;
            smErrMsg = 'Please enter all search criterias above.';
        }
        else if (e instanceOf InvalidOppException){
            isCustomError=false;
            smErrMsg = 'Opportunity is not available for preview';
        }
        else{
           isCustomError=false;
           smErrMsg = 'System is unable to perform the task. Please contact administrator.';
        } 
        
        System.debug('### smErrMsg : ' + smErrMsg);
       
        if((e instanceOf SMNotFoundException) || 
            (e instanceOf SMNoPageException) ||
            (e instanceOf SMParamNotFoundException)){
            System.debug(Logginglevel.WARN,'### Error Message:' + e.getMessage());
            System.debug(Logginglevel.WARN,'### Error e:' + e);
            System.debug(Logginglevel.WARN, '### Error e:' + e.getStackTraceString());        
        }
        else{
            System.debug(Logginglevel.ERROR,'### Error Message:' + e.getMessage());
            System.debug(Logginglevel.ERROR,'### Error e:' + e);
            System.debug(Logginglevel.ERROR, '### Error e:' + e.getStackTraceString());
        }   
    }
    
    private void handleSearchError(Exception e){
        if (e instanceOf SMNotFoundException){
            isCustomSearchError =true;
            //smSearchMsg = 'Sales Motion is not currently available for this solution.';
        }
        else if (e instanceOf SMNoPageException){
            isCustomSearchError =false;
            smSearchMsg = 'There is no Sales Motion pages available for the Sales Motion.';
        }
        else if (e instanceOf InvalidSearchDataException){
            isCustomSearchError =false;
            smSearchMsg = 'Please enter all search criterias above.';
        }
        else if (e instanceOf InvalidOppException){
            isCustomSearchError=false;
            smSearchMsg = 'Opportunity is not available for preview';
        }  
        
        System.debug('### smSearchMsg : ' + smSearchMsg);
        
        if((e instanceOf SMNotFoundException) || 
            (e instanceOf SMNoPageException) ||
            (e instanceOf SMParamNotFoundException)){
            System.debug(Logginglevel.WARN,'### Error Message:' + e.getMessage());
            System.debug(Logginglevel.WARN,'### Error e:' + e);
            System.debug(Logginglevel.WARN, '### Error e:' + e.getStackTraceString());        
        }
        else{
            System.debug(Logginglevel.ERROR,'### Error Message:' + e.getMessage());
            System.debug(Logginglevel.ERROR,'### Error e:' + e);
            System.debug(Logginglevel.ERROR, '### Error e:' + e.getStackTraceString());
        }     
    }
        
    private void initialLoad(){
        System.debug('### enter initialLoad');
        //store paramater
        storeInitialParameters();
        System.debug('### before SMUsageTrackerInfo');
        getSMUsageTrackerInfo();  
        isProdAvailable=false;  
        //get all data in admin console
        System.debug('### before getSalesMotion');
        getOppProducts();
        getSalesMotion();        
        getSalesMotionPages();        
        identifyDefaultPage();              
        getStages();            
        getSalesMotionSection();          
        //get sales edge document
        //getSalesEdgeSectionData();
        //getOppProducts();            
    }
          
    //get sales edge section data    
    private void getSalesEdgeSectionData(){
    
        System.debug('### checking whether needed to call sales edge web service');
        System.debug('### atLeast1SalesEdgeContentExisted:'+atLeast1SalesEdgeContentExisted);
        if(atLeast1SalesEdgeContentExisted){            
            salesEdgeDataProcesser = new SalesEdgeDataProcesser();
            //salesEdgeDataProcesser.loadSalesEdgeData(salesMotion.SalesEdge_Category__c, oppParameters.get(COUNTRY_KEY));
            
            system.debug('--salesedge data before sending-->>>'+'Category-->'+salesMotion.SalesEdge_Category__c +'/Region--->'+REGION_KEY+'/Stage-->'+currentStage+'/Business Unit--->'+BUSINESSUNIT_KEY+'/countryregion--->'+countryregionparam+'/seacrch key--->'+oppParameters.get(SMSEARCH_KEY));
           // salesEdgeDataProcesser.loadSalesEdgeData(salesMotion.SalesEdge_Category__c, oppParameters.get(REGION_KEY),currentStage,oppParameters.get(BUSINESSUNIT_KEY),countryregionparam,oppParameters.get(SMSEARCH_KEY));
            salesEdgeDataProcesser.loadSalesEdgeData(salesMotion.SalesEdge_Category__c,'region',currentStage,'businessunit','region','smopp');
            newUserFlag =salesEdgeDataProcesser.searchSalesEdgeDocumentsForUser(salesMotion.SalesEdge_Category__c, oppParameters.get(REGION_KEY),currentStage,oppParameters.get(BUSINESSUNIT_KEY),countryregionparam,oppParameters.get(SMSEARCH_KEY));
            System.debug('###newUserFlag From Main Function '+newUserFlag );
        }
        else{
            System.debug('### do not need to call to sales edge web service');
        }
    }
    
   
  
    private void  getSMUsageTrackerInfo(){
        isCustomError =false;
        isCustomSearchError =false;
        OppDetail=new Opportunity();
        OppDetails=[Select o.Id,Deal_ID__C,Name, o.Account.Regional_Parent_Name_lookup__c, o.Account.Segment_Business_Unit_Name__c, o.Account.Account_Country__c, o.AccountId From Opportunity o where Id=:ApexPages.currentPage().getParameters().get('id')];
        
        if(OppDetails.size()>0){
            OppDetail=OppDetails[0];
            teamMember=new OpportunityTeamMember();
            teamMembers=[Select o.UserId, o.TeamMemberRole, o.OpportunityId, o.OpportunityAccessLevel From OpportunityTeamMember o where o.UserId=:UserInfo.getUserId() and o.OpportunityId=:ApexPages.currentPage().getParameters().get('id')];         
            if(teamMembers.size()>0){
                teamMember=  teamMembers[0];
            }
            for(OpportunityLineItem ol:[Select OpportunityId,Brand_Desc__c From OpportunityLineItem where OpportunityId=:ApexPages.currentPage().getParameters().get('id')]){
                lineOfBusiness =lineOfBusiness+'\n'+ol.Brand_Desc__c;
            }
        }
    }
   
     public PageReference smUsageTracker(){
        salesRep = [select id,name,title from user where id= :UserInfo.getUserId()];
        SM_usage_tracker__c newSM = new SM_usage_tracker__c();
        System.debug('### OppDetails size:'+OppDetails.size());
        System.debug('### OppDetails:'+OppDetails);
        if(OppDetails.size()>0 &&OppDetails!=null){
            newSM .Opportunity_Name__c = oppDetails[0].id;
            newSM .Deal_ID__c = OppDetails[0].Deal_ID__C;
            newSM .Sales_Rep_Name__c = salesRep[0].name;
            newSM .Sales_Rep_Title__c = salesRep[0].title;
            newSM.Sales_Rep_Team_Role__c = teamMember.TeamMemberRole;
            newSM .Country__c=oppDetails[0].Account.Account_Country__c;
            newSM .Domain__c=oppParameters.get(DOMAIN_KEY);
            newSM .Line_of_Business__c=lineOfBusiness;
            newSM .Region__c=oppDetails[0].Account.Regional_Parent_Name_lookup__c;
            newSM .Segment_Business__c=oppDetails[0].Account.Segment_Business_Unit_Name__c;
            newSM .Solution_Name__c=oppParameters.get(SOLUTION_TYPE_KEY);
            newSM .Solution_Type__c=oppParameters.get(SOLUTION_NAME_KEY);
            newSM .SM_availability__c=isSMavailable;
            newSM .SM_Button_click_Date_Time__c=system.now();
            newSM .Sales_Motion_Name__c=(salesMotion==NULL)?'Sales Motion not available':salesMotion.name;
            insert newSM;
       }
       else{
            newSM.Sales_Rep_Name__c = salesRep[0].name;
            newSM.Sales_Rep_Title__c = salesRep[0].title;
            newSM.Domain__c = oppParameters.get(DOMAIN_KEY);
            newSM.Solution_Name__c = oppParameters.get(SOLUTION_TYPE_KEY);
            newSM.Solution_Type__c = oppParameters.get(SOLUTION_NAME_KEY);
            //System.debug('### PRODUCT KEY length:' + oppParameters.get(PRODUCT_KEY).length());
            System.debug('### PRODUCT KEY:' + oppParameters.get(PRODUCT_KEY));

            //if(oppParameters.get(PRODUCT_KEY).length() > 0){
                //newSM.Product__c = oppParameters.get(PRODUCT_KEY);
            //}
            newSM.SM_availability__c = isSMavailable;
            newSM.SM_Button_click_Date_Time__c = system.now();
            newSM.Sales_Motion_Name__c = (salesMotion==NULL)?'Sales Motion not available':salesMotion.name;
            //insert newSM;
       }  
       return null;
    }
    
    public PageReference Refresh(){
         newUserFlag=false;
         if(currentLeftSections!=null){
             currentLeftSections.Clear();
         }
         if(currentRightSections!=null){
             currentRightSections.Clear();
         }
         
         //try {
            OppDetails = new list<Opportunity>();
            initialLoad();
            retrieveAllSectionContent4CurrentPageStage();
        //}
        //catch (Exception e){
            //handleError(e);
        //}        
        return null;
    }
    
     public PageReference ClosePopUp(){
        newUserFlag=false;
        return null;
    }
        
    //store parameter into map  
    private void storeInitialParameters(){
        
        System.debug('### oppParameters Before:'+oppParameters);
        System.debug('### DOMAIN_KEY:'+ApexPages.currentPage().getParameters().get(DOMAIN_KEY));
        System.debug('### STAGE_KEY:'+ApexPages.currentPage().getParameters().get(STAGE_KEY));
        oppParameters.put(DOMAIN_KEY, ApexPages.currentPage().getParameters().get(DOMAIN_KEY));
        System.debug('### after put domain key');
        if(ApexPages.currentPage().getParameters().get(SOLUTION_TYPE_KEY) != null){
        oppParameters.put(SOLUTION_TYPE_KEY, ApexPages.currentPage().getParameters().get(SOLUTION_TYPE_KEY).replace('%26', '&'));
        }
        else{
        oppParameters.put(SOLUTION_TYPE_KEY, ApexPages.currentPage().getParameters().get(SOLUTION_TYPE_KEY));
        }
        System.debug('### after put solution type key');
        if(ApexPages.currentPage().getParameters().get(SOLUTION_NAME_KEY) != null){
        oppParameters.put(SOLUTION_NAME_KEY, ApexPages.currentPage().getParameters().get(SOLUTION_NAME_KEY).replace('%26', '&'));
        }
        else{
        oppParameters.put(SOLUTION_NAME_KEY, ApexPages.currentPage().getParameters().get(SOLUTION_NAME_KEY));
        }
        oppParameters.put(STAGE_KEY, ApexPages.currentPage().getParameters().get(STAGE_KEY));
        oppParameters.put(CURRENT_STAGE_KEY, ApexPages.currentPage().getParameters().get(STAGE_KEY));
        //System.debug('### MT Country Key'+ApexPages.currentPage().getParameters().get(COUNTRY_KEY));
        
        if(ApexPages.currentPage().getParameters().get(COUNTRY_KEY).length() > 0 || ApexPages.currentPage().getParameters().get(COUNTRY_KEY)!=''){
            //oppParameters.put(COUNTRY_KEY, ('AD-'+ApexPages.currentPage().getParameters().get(COUNTRY_KEY)));
            oppParameters.put(COUNTRY_KEY, (ApexPages.currentPage().getParameters().get(COUNTRY_KEY)));
            //countryregionparam='country';
        }
        /*else if((ApexPages.currentPage().getParameters().get(COUNTRY_KEY).length()==0 || ApexPages.currentPage().getParameters().get(COUNTRY_KEY)=='') && ApexPages.currentPage().getParameters().get(REGION_KEY)!=null){
            //oppParameters.put(COUNTRY_KEY, ('AD-'+ApexPages.currentPage().getParameters().get(REGION_KEY)));
            oppParameters.put(COUNTRY_KEY, (ApexPages.currentPage().getParameters().get(REGION_KEY)));
            countryregionparam='region';
        }*/
        if(ApexPages.currentPage().getParameters().get(REGION_KEY) != null){
            oppParameters.put(REGION_KEY, (ApexPages.currentPage().getParameters().get(REGION_KEY)));
            countryregionparam='region';
        }
        oppParameters.put(OPP_ID_KEY, ApexPages.currentPage().getParameters().get(OPP_ID_KEY));
        oppParameters.put(PRODUCT_KEY, ApexPages.currentPage().getParameters().get(PRODUCT_KEY));
        oppParameters.put(BUSINESSUNIT_KEY, ApexPages.currentPage().getParameters().get(BUSINESSUNIT_KEY));
        
        oppParameters.put(SMSEARCH_KEY, ApexPages.currentPage().getParameters().get(SMSEARCH_KEY));
        if(oppParameters.get(SMSEARCH_KEY)==null){
            oppParameters.put(SMSEARCH_KEY, 'smopp');
        }
         System.debug('### oppParameters After:'+oppParameters);
        System.debug('### store parameter : domain [' + oppParameters.get(DOMAIN_KEY) +'], ' +
                    'solution type [' + oppParameters.get(SOLUTION_TYPE_KEY) +'], ' +
                    'solution name [' + oppParameters.get(SOLUTION_NAME_KEY) +'], ' +
                    'stage [' + oppParameters.get(STAGE_KEY) +'], ' +
                    'country [' + oppParameters.get(COUNTRY_KEY) +'], ' +
                    'id [' + oppParameters.get(OPP_ID_KEY) +'],' +
                    'product [' + oppParameters.get(PRODUCT_KEY) +']');
        
        if((oppParameters.get(DOMAIN_KEY)==null || oppParameters.get(DOMAIN_KEY).length()==0)
            &&(oppParameters.get(SOLUTION_TYPE_KEY)==null || oppParameters.get(SOLUTION_TYPE_KEY).length()==0)
            &&(oppParameters.get(SOLUTION_NAME_KEY)==null || oppParameters.get(SOLUTION_NAME_KEY).length()==0)
            &&(oppParameters.get(STAGE_KEY)==null || oppParameters.get(STAGE_KEY).length()==0)
            &&(oppParameters.get(COUNTRY_KEY)==null || oppParameters.get(COUNTRY_KEY).length()==0)
            &&(oppParameters.get(OPP_ID_KEY)==null || oppParameters.get(OPP_ID_KEY).length()==0)
            &&(oppParameters.get(PRODUCT_KEY)==null || oppParameters.get(PRODUCT_KEY).length()==0)
            &&(sm.RecordTypeID != rt)          
            ){
            throw new SMParamNotFoundException();
        }  
    }
        
    //retrieve the sales motion info from db
    private void getSalesMotion(){
        List<Sales_Motion__c> salesMotions = new List<Sales_Motion__c>(); 
        if(sm != null){
        if(sm.RecordTypeID == rt )
        {
            system.debug('------Generic Records Data is now getting populated-------');
            salesMotions = [select s.ID, s.Name,s.SalesEdge_Category__c,s.Domain__c, s.Solution_Type__c, s.Solution_Name__c, s.Product__c, s.Product__r.name from Sales_Motion__c s
                               where s.ID =:salesNameID and s.IsActive__c = true ];
        } else{
            salesMotions  = [Select s.Id, s.Name, s.SalesEdge_Category__c, s.Domain__c, s.Solution_Type__c, s.Solution_Name__c, s.Product__c, s.Product__r.name from Sales_Motion__c s 
                                            where s.Domain__c = :oppParameters.get(DOMAIN_KEY) and s.Solution_Type__c= :oppParameters.get(SOLUTION_TYPE_KEY) and s.ID =:salesNameID
                                            and s.Solution_Name__c = :oppParameters.get(SOLUTION_NAME_KEY) and s.Product__c = :oppParameters.get(PRODUCT_KEY) and s.IsActive__c= true];
        }  
        }else{
            salesMotions  = [Select s.Id, s.Name, s.SalesEdge_Category__c, s.Domain__c, s.Solution_Type__c, s.Solution_Name__c, s.Product__c, s.Product__r.name from Sales_Motion__c s 
                                            where s.Domain__c = :oppParameters.get(DOMAIN_KEY) and s.Solution_Type__c= :oppParameters.get(SOLUTION_TYPE_KEY)
                                            and s.Solution_Name__c = :oppParameters.get(SOLUTION_NAME_KEY) and s.Product__c = :oppParameters.get(PRODUCT_KEY) and s.IsActive__c= true];
        }
        
        system.debug('------salesMotions details------'+salesMotions);
        
        if(salesMotions==null || salesMotions.size()<=0){
            throw new SMNotFoundException();
        }
        
        System.debug('### sales motion size : ' + salesMotions.size());
        
        salesMotion =  salesMotions.get(0); 
        system.debug('-------salesMotion ID-------'+salesMotion);
                                               
    }
    
    //retrieve all the sales motion pages with current sales motion id from db 
    private void getSalesMotionPages(){
            
        Id salesMotionId = salesMotion.id;
        system.debug('------salesMotionId Pages function------'+salesMotionId);
        salesMotionPages = [Select s.Id, s.Name, s.Stages_Enabled__c from Sales_Motion_Page__c s 
                                                                where Sales_Motion_Name__c = :salesMotionId and s.IsActive__c=true order by s.Sort_Order__c];
        
        System.debug('### salesMotionPages Details :' + salesMotionPages);
        System.debug('### salesMotionPages :' + salesMotionPagesMap);
        
        if(salesMotionPages==null || salesMotionPages.size()<=0){
            throw new SMNoPageException();
        }
        
        for (Sales_Motion_Page__c smpage : salesMotionPages ){       
            salesMotionPagesMap.put(smpage.Id, smpage);        
        }
        
        System.debug('### salesMotionPagesMap :' + salesMotionPagesMap);                                
    }
    
    //search sales motion and pages
    private void searchSalesMotionNPages(){
        List<Sales_Motion__c> searchedSalesMotions = new List<Sales_Motion__c>();
        if(sm != NULL){
        if(sm.RecordTypeID == rt)
        {
          system.debug('-----Searched SalesMotion Pages for Generic RT--------');
          searchedSalesMotions  = [Select s.Id from Sales_Motion__c s 
                                     where s.ID =: salesNameID ];  
        }
        }
        else{    
             searchedSalesMotions  = [Select s.Id from Sales_Motion__c s 
                                            where s.Domain__c = :salesMotionSearch.Domain__c and s.Solution_Type__c= :salesMotionSearch.Solution_Type__c
                                            and s.Solution_Name__c = :salesMotionSearch.Solution_Name__c];
         }                                   
        system.debug('------searchedSalesMotion------'+searchedSalesMotions);
        if(searchedSalesMotions==null || searchedSalesMotions.size()<=0){
            throw new SMNotFoundException();
        }
        
        System.debug('### sales motion size : ' + searchedSalesMotions.size());
        
        Sales_Motion__c searchedSalesMotion =  searchedSalesMotions.get(0);     
        
        List<Sales_Motion_Page__c> searchedSalesMotionPages = [Select s.Id from Sales_Motion_Page__c s 
                                                                where Sales_Motion_Name__c = :searchedSalesMotion.Id];
        
        system.debug('-----searchedSalesMotionPages-------'+searchedSalesMotionPages);
        if(searchedSalesMotionPages==null || searchedSalesMotionPages.size()<=0){
            throw new SMNoPageException();
        }
        
    }
    
    //business logic to identify the default page    
    private void identifyDefaultPage(){
        
        if(salesMotionPages.size()==1){
            defaultPage = salesMotionPages.get(0).Id;
            System.debug('### Only 1 page available. The defaultPage is ' + defaultPage );
            return;
        }
            
        for(integer i=0; i<=salesMotionPages.size()-1; i++){
            
            if(salesMotionPages.get(i).Name.equalsIgnoreCase(MARKETING_PAGE)){
                defaultPage = salesMotionPages.get(i).Id;
                System.debug('### More than 1 page available. The defaultPage is ' + defaultPage );
                return;
            }
        
        } 
        
        defaultPage = ((Sales_Motion_Page__c) salesMotionPages.get(0)).Id;
        System.debug('### More than 1 page available. Marketing page not available. The defaultPage is ' + defaultPage );
                         
    }
    
    //retrieve all the SFDC stages from db
    private void getStages(){
        
         Schema.DescribeFieldResult stageField = Sales_Motion_Page_Section__c.Stage__c.getDescribe();            
            
         List<Schema.PicklistEntry> stagePickList= stageField.getPicklistValues();
         
         //stages = stageField.getPicklistValues();
          
         System.debug('### stage size : ' + stagePickList.size());
         System.debug('### stage  : ' + stagePickList);
         
         stages = new List<String>();         
         stagePercents = new List<String>();
         stageDescs = new List<String>();
         
         for(Schema.PicklistEntry entry : stagePickList)
         {
            stages.add(entry.getLabel());
            
            String stagePercent = entry.getLabel().substring(entry.getLabel().indexOf('-')+1,entry.getLabel().indexOf('%')).trim();
            String stageDec = entry.getLabel().substring(0,entry.getLabel().indexOf('-')).trim();
            
            System.debug('### Stage % [' + stagePercent +'], stage Desc [' + stageDec + ']');
            
            stagePercents.add(stagePercent);
            stageDescs.add(stageDec);
         } 
    }
        
    //retrieve all the Sales Edge stage and country from db
    /*private void getSalesEdgeStagesAndCountryMapping(){    
        
        String recordTypeForCountry = IdLookupUtils.getRecordTypeId('Sales Motion Country', 'Sales_Motion_Mappings__c', true);
        
        String recordTypeForStage = IdLookupUtils.getRecordTypeId('Sales Motion Stage', 'Sales_Motion_Mappings__c', true);
        
        List<Sales_Motion_Mappings__c> mappings = [Select s.RecordTypeId, s.SalesEdge_Country__c, s.SalesEdge_Opportunity_Stage__c, 
                                                    s.Salesforce_Country__c, s.Salesforce_Opportunity_Stage__c 
                                                    from Sales_Motion_Mappings__c s where (s.RecordTypeId = :recordTypeForStage and s.Salesforce_Opportunity_Stage__c = :oppParameters.get(STAGE_KEY))
                                                    or (s.RecordTypeId = :recordTypeForCountry and s.Salesforce_Country__c = :oppParameters.get(COUNTRY_KEY))];
        
        if(mappings==null || mappings.size()<=0)                                            
            throw new SMMappingNotFoundException();
            
        for(Sales_Motion_Mappings__c mapping: mappings){
        
            if((mapping.RecordTypeId==recordTypeForStage) && (salesEdgeMappedStage==null || salesEdgeMappedStage.length()<=0))
                salesEdgeMappedStage = mapping.SalesEdge_Opportunity_Stage__c;          
            else if ((mapping.RecordTypeId==recordTypeForCountry) && (salesEdgeMappedCountry==null || salesEdgeMappedCountry.length()<=0))
                salesEdgeMappedCountry = mapping.SalesEdge_Country__c;
                 
        } 
                           
        System.debug('### salesEdgeMappedCountry [' + salesEdgeMappedCountry + '], salesEdgeMappedStage [' + salesEdgeMappedStage  + ']');
        
        if(salesEdgeMappedStage==null || salesEdgeMappedStage.length()<=0)
            throw new SMMappingNotFoundException();
            
        if(salesEdgeMappedCountry==null || salesEdgeMappedCountry.length()<=0)
            throw new SMMappingNotFoundException();
       
    }*/
     
    /*private void getSalesMotionSection(){
        
        String key;
        
        for(Sales_Motion_Page_Section__c salesMotionSection : [Select s.Name, s.Type__c, s.Sales_Motion_Page__c, s.Side_Bar__c, 
                                            s.Stage__c, s.Section_Content__c , s.SalesEdge_Category__c from Sales_Motion_Page_Section__c s
                                            where (s.Country__c = :oppParameters.get(COUNTRY_KEY) OR s.Country__c = null )and s.Sales_Motion_Page__c IN :salesMotionPagesMap.keySet() order by s.Sort_Order__c]){
                                                          
            if(salesMotionPagesMap.get(salesMotionSection.Sales_Motion_Page__c).Stages_Enabled__c){
                key = salesMotionSection.Sales_Motion_Page__c+':' + salesMotionSection.Stage__c;
            }else{
                key = salesMotionSection.Sales_Motion_Page__c;
            }
                      
            System.debug('### section ['+ salesMotionSection.Id + '] is stored with key [' + key +']');
                      
            if(salesMotionSection.Side_Bar__c){
                insertSection(rightSections, key, salesMotionSection); 
                System.debug('### section ['+ salesMotionSection.Id + '] is stored in right panel');
            }else{
                insertSection(leftSections, key, salesMotionSection); 
                System.debug('### section ['+ salesMotionSection.Id + '] is stored in left panel');
            }
            
            System.debug('### type of this content [' + salesMotionSection.Type__c + ']');
            if(!atLeast1SalesEdgeContentExisted && salesMotionSection.Type__c.equalsIgnoreCase('SalesEdge Content')){
                atLeast1SalesEdgeContentExisted=true;
            }
        } 
    }
    */
    
    private void getSalesMotionSection(){
        
        String key;
        integer i;  
        integer j; 
        String OppName = ApexPages.currentPage().getParameters().get('oppName');
        system.debug('------OppNAme--------'+OppName);
        
        supportRequestLst = new List<supportRequest>();
        String supReq_RecTypeId;
        Schema.DescribeSObjectResult rectypinfo = Support_Request__c.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> rectypinfoschema = rectypinfo.getRecordTypeInfos(); 
        List<String> recinfolist = new List<String>();
        for(Schema.RecordTypeInfo recinfo : rectypinfoschema)
         {
            if(recinfo.isAvailable() == True){
                recinfolist.add(recinfo.getName());
            }

         }   
        for(RecordType rt : [SELECT Name,Id FROM RecordType WHERE SobjectType='Support_Request__c']){
            reqtype.put(rt.Name,rt.Id);
        }
        User userDet=new User();
                 userDet=[select Id,LanguageLocaleKey from User where id=:userInfo.getUserId()];
                 System.debug('### userDet'+ userDet);
        getLanguageandCodeFromMapping();
        for(Sales_Motion_Page_Section__c salesMotionSection : [Select s.Name, s.Type__c, s.Sales_Motion_Page__c, s.Side_Bar__c,s.Country_List__c,s.Business_Unit_List__c,s.Region_List__c, 
                                            s.Language_List__c,s.Stage__c, s.Support_Request_Type__c, s.Section_Content__c , s.SalesEdge_Category__c,s.IsActive__c from Sales_Motion_Page_Section__c s
                                            where s.Sales_Motion_Page__c IN :salesMotionPagesMap.keySet() order by s.Sort_Order__c]){
                              
                system.debug('------salesMotionSection-------'+salesMotionSection.Name);
                String requestType = salesMotionSection.Support_Request_Type__c;  
                            
                if(requestType != NULL){
                List<String> requestTypeSplit = requestType.split(';',-1);
                List<String> finalreq = new List<String>(); 
                for(i=0; i<requestTypeSplit.size(); i++){
                    for(j=0; j<recinfolist.size(); j++){
                        if(requestTypeSplit[i] == 'Request Pre-Sales Prod Tech Support'){
                             requestTypeSplit[i] = 'Request Pre-Sales Product Technologist Support';
                        }
                        if(requestTypeSplit[i] == 'Request Pre-Sales Prod Tech Support – IM'){
                             requestTypeSplit[i] = 'Request Pre-Sales Product Technologist Support - IM';
                        }
                         if(requestTypeSplit[i] == 'Request Pre-Sales Prod Tech Support – SE'){
                             requestTypeSplit[i] = 'Request Pre-Sales Product Technologist Support - SE';
                        }

                        if(requestTypeSplit[i] == recinfolist[j]){
                            finalreq.add(requestTypeSplit[i]);
                        }
                   }
               }
                Set<String> reqSet = new Set<String>(finalreq);
                supportRequest supportWrapper = new supportRequest(); 

                for(String rectype : reqSet){
                     supportWrapper = new supportRequest(); 
                     supReq_RecTypeId = reqtype.get(rectype);
                     supportWrapper.supportUrl= '/a0J/e?CF00N70000002NKud=' + OppName + '&CF00N70000002NKud_lkid=' + OppId + '&RecordType=' + supReq_RecTypeId + '&retURL=%2F' + OppId;
                     supportWrapper.supportName = rectype;              
                     supportWrapper.sectionName = salesMotionSection.Name ;
                     supportWrapper.stage = salesMotionSection.Stage__c;
                     supportWrapper.page = salesMotionSection.Sales_Motion_Page__c;   
                     supportRequestLst.add(supportWrapper);                                     
                     
                }
            } 
                 
                 
                string languageToPass=salesEdgeMappedLanguage.get(userDet.LanguageLocaleKey);
                system.debug('----language to pass ----'+languageToPass);
                if(isSectionConfiguredCountry(salesMotionSection, oppParameters.get(COUNTRY_KEY)) && isSectionConfiguredBusinessUnit(salesMotionSection, oppParameters.get(BUSINESSUNIT_KEY)) && isSectionConfiguredRegion(salesMotionSection, oppParameters.get(REGION_KEY)) && isSectionConfiguredLanguage(salesMotionSection, languageToPass)){
                     
                if(salesMotionPagesMap.get(salesMotionSection.Sales_Motion_Page__c).Stages_Enabled__c){
                    key = salesMotionSection.Sales_Motion_Page__c+':' + salesMotionSection.Stage__c;
                }else{
                    key = salesMotionSection.Sales_Motion_Page__c;
                }
                          
                System.debug('### section ['+ salesMotionSection.Id + '] is stored with key [' + key +']');
                          
                if(salesMotionSection.Side_Bar__c){
                    insertSection(rightSections, key, salesMotionSection); 
                    System.debug('### section ['+ salesMotionSection.Id + '] is stored in right panel');
                }else{
                    insertSection(leftSections, key, salesMotionSection); 
                    System.debug('### section ['+ salesMotionSection.Id + '] is stored in left panel');
                }
                
                System.debug('### type of this content [' + salesMotionSection.Type__c + ']');
                
                if(!atLeast1SalesEdgeContentExisted && salesMotionSection.Type__c.equalsIgnoreCase('SalesEdge Content')){
                    atLeast1SalesEdgeContentExisted=true;
                }
            }
        } 
    }
    
     //retrieve all the Language and Language Codes from Mapping Table
    private void getLanguageandCodeFromMapping(){    
        
        String recordTypeForLanguage = IdLookupUtils.getRecordTypeId('Sales Motion Language', 'Sales_Motion_Mappings__c', true);
        system.debug('#### language record type----'+recordTypeForLanguage);
       // List<Sales_Motion_Mappings__c> mappings = new List<Sales_Motion_Mappings__c>();
       /* if(sm != null){
        if(sm.RecordTypeID == rt)
        {
            mappings = [Select s.RecordTypeId, s.Language_Code_for_SM_Configuration__c, s.Language_for_SM_Configuration__c,s.SalesEdge_BusinessUnit__c, 
                                                    s.SalesEdge_Region__c,s.SalesForce_BusinessUnit__c,s.Salesforce_Region__c from Sales_Motion_Mappings__c s ];
            system.debug('----Sales Motion Mapping Details & on Language------'+mappings);                                        
        }
        }else{*/
        List<Sales_Motion_Mappings__c> mappings = [Select s.RecordTypeId, s.Language_Code_for_SM_Configuration__c, s.Language_for_SM_Configuration__c 
                                                    from Sales_Motion_Mappings__c s where (s.RecordTypeId = :recordTypeForLanguage)];

        system.debug('------Sales Motion Mapping on Language------'+mappings);
      //  }
        //if(mappings==null || mappings.size()<=0)                                            
        //    throw new SMMappingNotFoundException();
            
        for(Sales_Motion_Mappings__c mapping: mappings){
        
            if(mapping.RecordTypeId==recordTypeForLanguage)
                salesEdgeMappedLanguage.put(mapping.Language_Code_for_SM_Configuration__c, mapping.Language_for_SM_Configuration__c);          
               
        } 
                         
        System.debug('### salesEdgeMappedLanguage'+salesEdgeMappedLanguage);   
            
    }
    
    public List<supportRequest> getSupportRequest() {
    
     String Section_Name = Apexpages.currentPage().getParameters().get('SectionName');
     System.debug('Section Name in get Method-----------' + Section_Name);
     return supportRequestLst; 

    } 
    
    //insert a section into a section list (that contains all sections of the sales motion)
    private void insertSection(Map<String, List<Sales_Motion_Page_Section__c>> sectionMap, String key, Sales_Motion_Page_Section__c section){
        
        if(sectionMap.containsKey(key)){
            sectionMap.get(key).add(section);
        }else{
            sectionMap.put(key, new List<Sales_Motion_Page_Section__c> {section});
        }
    }
    
    private String getCurrentPageStageKey(){
        
        currentPage = ApexPages.currentPage().getParameters().get(CURRENT_PAGE_KEY);
        system.debug('----currentPage-----'+currentPage);
        //currentStage = ApexPages.currentPage().getParameters().get(STAGE_KEY);
        //currentStage = ApexPages.currentPage().getParameters().get(CURRENT_STAGE_KEY);
        if(ApexPages.currentPage().getParameters().get(CURRENT_STAGE_KEY)==null){
            currentStage = ApexPages.currentPage().getParameters().get(STAGE_KEY);
        }   
        else{
            currentStage = ApexPages.currentPage().getParameters().get(CURRENT_STAGE_KEY);
        }        
        System.debug('Ambickaa' + currentPage + 'Ambickaa' + currentStage); 
        System.debug('### store parameter : page [' + currentPage + '], stage [' + currentStage +']');   
        
        //if it is search page, return back to page without getting content
        if(currentPage !=null && currentPage.equalsIgnoreCase('Search')){
            return null;
        }
        
        //if the current page is null, which means it comes from opportunity detail page, 
        //then replace current page with default page    
        if(currentPage==null){
          currentPage = defaultPage;
        }
                            
        isStagedEnabled = salesMotionPagesMap.get(currentPage).Stages_Enabled__c;
        
        System.debug('### final current page [' + currentPage +'], stages enabled =[' + isStagedEnabled +']');           
        
        //if stages disabled, then return currentPage as key
        if(!isStagedEnabled){
            return currentPage;
        }
        
        //if the stages is enabled for the page, return combination of currentpage and currentStage as key
       /* if(currentStage == null && sm.RecordTypeID == rt)
        {
            currentStage = 'Plan-1%'; // hardcoded by Bikram--need to be confirmed from Teck Kee
        }  */       
        if(currentStage==null){
            currentStage = oppParameters.get(STAGE_KEY); 
        }
        
        return currentPage + ':' +currentStage;   
    }
    
    //retrieve salesforce section data for current page and current stage
    private void retrieveSalesForceSectionContent4CurrentPageStage(String key){        
         
        currentLeftSections = leftSections.get(key);
        currentRightSections = rightSections.get(key); 
              
        if (currentLeftSections!=null){
            System.debug('### The current left sections size [' + currentLeftSections.size() + ']');  
        }
        
        if (currentRightSections!=null){
            System.debug('### The current right sections size [' + currentRightSections.size() + ']');    
        }           
    }
   
    //retrieve sales Edge section data for current page and current stage
    private void retrieveSalesEdgeSectionContent4CurrentPageStage(List<Sales_Motion_Page_Section__c> sections, String key){
            
        if((sections==null||sections.size()<=0) || pageStageWithSalesEdgeContentRetrieved.contains(key)){
            system.debug('-----inside returning if------');
            return;
        }
            
        for(Sales_Motion_Page_Section__c section: sections){
        
            system.debug('----section type----'+section.type__c);
            if(section.Type__c!=null && section.Type__c.equalsIgnoreCase('SalesEdge Content')){
                
                system.debug('----inside section if------');
                system.debug('--Section Data Passed to SE--->>'+'1.Category-->'+section.SalesEdge_Category__c+''+'2.Stage'+currentStage);
                section.Section_Content__c = salesEdgeDataProcesser.getSectionData(section.SalesEdge_Category__c, currentStage);
            }
        }
    }
    
    //retrieve section content (sales edge or static content) for current page and current stage
    private void retrieveAllSectionContent4CurrentPageStage(){    
        String key = getCurrentPageStageKey();
        getSalesEdgeSectionData();

        if(key==null){
             return;
        }
            
        //retrieve content
        retrieveSalesForceSectionContent4CurrentPageStage(key);
        
        retrieveSalesEdgeSectionContent4CurrentPageStage(currentLeftSections, key);
        retrieveSalesEdgeSectionContent4CurrentPageStage(currentRightSections, key);
        
    }   
        
    public PageReference refreshSectionData() { 
                   
        System.debug('### enter to refresh section data');
        
        try {
            
            retrieveAllSectionContent4CurrentPageStage();
            
        } catch (Exception e){
            handleError(e);
        }
        
        return null;
                   
    }
    
    //check if the search data is valid
    private void checkSearchDataValidity(){
        
        if((salesMotionSearch.Domain__c==null || StringUtils.isBlank(salesMotionSearch.Domain__c))
            || 
            (salesMotionSearch.Solution_Type__c==null || StringUtils.isBlank(salesMotionSearch.Solution_Type__c))
            ||
            (salesMotionSearch.Solution_Name__c==null || StringUtils.isBlank(salesMotionSearch.Solution_Name__c))
            ){
            System.debug('### Not all search data are entered');
            throw new InvalidSearchDataException();
        }
    }
    
    public PageReference searchSalesMotion(){
    
        System.debug('### enter to search SM');
        
        try {
            smSearchMsg =null;
            checkSearchDataValidity();
            
            System.debug('### pass parameter from search to constructor : domain__c [' + salesMotionSearch.Domain__c +            
                '], solution_Type__c [' + salesMotionSearch.Solution_Type__c +            
                '], solution_Name__c [' + salesMotionSearch.Solution_Name__c + ']');    
                                 
            searchSalesMotionNPages();    
                        
            /*return PageUtils.redirect('/apex/SalesMotion?' 
                + DOMAIN_KEY + '=' + salesMotionSearch.Domain__c + '&' 
                + SOLUTION_TYPE_KEY + '=' + salesMotionSearch.Solution_Type__c.replace('&', '%26') + '&' 
                + SOLUTION_NAME_KEY + '=' + salesMotionSearch.Solution_Name__c.replace('&', '%26') + '&'
                + COUNTRY_KEY + '=' + oppParameters.get(COUNTRY_KEY) + '&'
                + STAGE_KEY + '=' + oppParameters.get(STAGE_KEY) + '&'
                + OPP_ID_KEY + '=' + oppParameters.get(OPP_ID_KEY) + '&'
                + PRODUCT_KEY + '=' + oppParameters.get(PRODUCT_KEY)
                );*/
                
                //modified by Micky
                
                return PageUtils.redirect('/apex/SalesMotion?' 
                + DOMAIN_KEY + '=' + salesMotionSearch.Domain__c + '&' 
                + SOLUTION_TYPE_KEY + '=' + salesMotionSearch.Solution_Type__c.replace('&', '%26') + '&' 
                + SOLUTION_NAME_KEY + '=' + salesMotionSearch.Solution_Name__c.replace('&', '%26') + '&'
                + COUNTRY_KEY + '=' + oppParameters.get(COUNTRY_KEY) + '&'
                + STAGE_KEY + '=' + oppParameters.get(STAGE_KEY) + '&businessunit='
                + '&region='
                );
               
        } catch (SMNotFoundException e){
            handleSearchError(e);
        } catch (SMNoPageException e){
            handleSearchError(e);
        } catch (InvalidSearchDataException e){
            handleSearchError(e);
        } catch (Exception e){
            handleError(e);
        }
        System.debug('Ambickaa before return');
        return null;
    
    }
    
    public List<selectoption> getfullAvailableProducts (){
        return fullAvailableProducts ;
    }
    public void setfullAvailableProducts (list<selectoption> fullAvailableProducts ){
        this.fullAvailableProducts =fullAvailableProducts;
    }
        
    /*
    private boolean isSectionConfigured (Sales_Motion_Page_Section__c salesMotionSection, string oppCountry){
        string countryList = salesMotionSection.Country_List__c == null ? null : salesMotionSection.Country_List__c ;
        countryList = countryList == null? null : countryList.toUpperCase();
        
        System.debug('### Opportunity Country   ' + oppCountry.toUpperCase() + '   ### Country List    '  + countryList);
        
       // System.debug('### countryList.contains(oppCountry) :' + countryList.contains(oppCountry.toUpperCase()));
        if(countryList == null){ 
            return true;
        } else if (countryList.contains(oppCountry.toUpperCase())){
            return true;
        } else {
            return false;
        }
        
    }
    */
    
    public PageReference goBack(){
     
        //Id OpId;
       
        
         
        String Url = ApexPages.currentPage().getUrl();  
        System.debug('Ambickaaurl'+ Url);   
        try{      
            click = Url.contains('id=') || Url.contains('product='); 
            System.debug('Ambickaa'+ click );
            if(click == false){  
                //if(!Url.contains('id')){
                System.debug('Ambickaa inside click');
                throw new InvalidOppException();
            } 
            return PageUtils.redirect('/'+OpportunityId);
        }
        catch (InvalidOppException e){
            handleError(e);
        }
        catch (Exception e){
            handleSearchError(e);
        }
        return null;         
    }  
    /*public PageReference goBack(){
        return PageUtils.redirect('/'+OpportunityId);
    }*/
  
    private boolean isSectionConfiguredCountry (Sales_Motion_Page_Section__c salesMotionSection, String oppCountry){
        
        if(salesMotionSection.Country_List__c == null && salesMotionSection.IsActive__c==true){ 
            return true;
        }
        if(salesMotionSection.IsActive__c==false){
            return false;
        }
        if(salesMotionSection.Country_List__c != null && oppCountry==null){
            return false;
        }
        if(salesMotionSection.Country_List__c != null && oppCountry.length()==0){
            return false;
        }
        String countryList = salesMotionSection.Country_List__c.toUpperCase() ;
        oppCountry = oppCountry.toUpperCase();
        
        System.debug('### Opportunity Country   ' + oppCountry + '   ### Country List    '  + countryList);
        
        // 1.3 Shue start
        String[] splittedCountryList =  countryList.split(';');
        
        Set<String> countrySet= new Set<String>();
        countrySet.addAll(splittedCountryList);
        
        // if (countryList.contains(oppCountry)) {
        if (countrySet.contains(oppCountry)){
            return true;
        } else {
            return false;
        }
        // 1.3 Shue end               
    }
    
    private boolean isSectionConfiguredBusinessUnit (Sales_Motion_Page_Section__c salesMotionSection, String oppBusinessUnit){
        
        if(salesMotionSection.Business_Unit_List__c == null){ 
            return true;
        }
        if(salesMotionSection.Business_Unit_List__c != null && oppBusinessUnit==null){
            return false;
        }

        if(salesMotionSection.Business_Unit_List__c != null && oppBusinessUnit.length()==0){
            return false;
        }
        String businessUnitList = salesMotionSection.Business_Unit_List__c.toUpperCase() ;
        oppBusinessUnit = oppBusinessUnit.toUpperCase();
        System.debug('### businessUnitList'+businessUnitList); 
        System.debug('### oppBusinessUnit'+oppBusinessUnit); 
        if (businessUnitList.contains(oppBusinessUnit)){
            return true;
        } else {
            return false;
        }
              
    }
    private boolean isSectionConfiguredRegion (Sales_Motion_Page_Section__c salesMotionSection, String oppRegion){
        
        if(salesMotionSection.Region_List__c== null ){  
            return true;
        }
        if(salesMotionSection.Region_List__c != null && oppRegion==null){
            return false;
        }

        if(salesMotionSection.Region_List__c != null && oppRegion.length()==0){
            return false;
        }
        System.debug('### oppRegionMT '+oppRegion); 
        String regionList = salesMotionSection.Region_List__c.toUpperCase() ;
        oppRegion = oppRegion.toUpperCase();
        if (regionList.contains(oppRegion)){
            return true;
        } else {
            return false;
        }
              
    }
    
    private boolean isSectionConfiguredLanguage (Sales_Motion_Page_Section__c salesMotionSection, String oppLanguage){
        
        if(salesMotionSection.Language_List__c== null ){  
            return true;
        }
        if(salesMotionSection.Language_List__c != null && oppLanguage==null){
            return false;
        }

        if(salesMotionSection.Language_List__c != null && oppLanguage.length()==0){
            return false;
        }
        String languageList = salesMotionSection.Language_List__c.toUpperCase() ;
        oppLanguage = oppLanguage.toUpperCase();
        if (languageList.contains(oppLanguage)){
            return true;
        } else {
            return false;
        }
              
    }
    
     private void getOppProducts() {
        OpportunityId=OppId;
        List<string> prodId=new List<string>();
        List<Sales_Motion__c> lstSalesmotion=new List<Sales_Motion__c>();
        oppProducts =  [SELECT OpportunityLineItem.PricebookEntry.Product2.Id, OpportunityLineItem.PricebookEntry.Product2.Name FROM OpportunityLineItem WHERE OpportunityId = :OppId ];
        
        if(oppProducts==null || oppProducts.size()<=0){
            productTab = false;
        }
        else{
            productTab = true;            
            System.debug('##### Sang Chian : ' + oppProducts[0].PricebookEntry.Product2.Name);
        }
        System.debug('##### oppProducts : ' + oppProducts);

        fullAvailableProducts.add(new selectOption('None','None'));
        for(integer i=0;i<oppProducts.size();i++){
            prodId.add(oppProducts[i].PricebookEntry.Product2.Id);
        }
        System.debug('##### prodIdMK: ' + prodId);
        lstSalesmotion=[Select Product__c,Product__r.Name from Sales_Motion__c where Product__c in:prodId and IsActive__c=true];
        System.debug('##### lstSalesmotionMK: ' + lstSalesmotion);
        for(Sales_Motion__c prodSM:lstSalesmotion){
            fullAvailableProducts.add(new selectOption(prodSM.Product__c,prodSM.Product__r.Name));
        }
        if(lstSalesmotion.size()>0){
            isProdAvailable=true;
        }
        /*for(integer i=0;i<oppProducts.size();i++){
            fullAvailableProducts.add(new selectOption(oppProducts[i].PricebookEntry.Product2.Id,oppProducts[i].PricebookEntry.Product2.Name));
        }*/
    }  
    
    public ApexPages.PageReference redirectSalesMotion(){
       if(selectedproduct!='None'){
            //Sales_Motion__c sm = (Sales_Motion__c)controller.getRecord();
            System.debug('### STAGE_KEYMK:'+ApexPages.currentPage().getParameters().get(STAGE_KEY));
            PageReference previewPage = new PageReference('/apex/SalesMotion?product=' + selectedproduct+'&id='+OppId+'&businessunit='+oppParameters.get(BUSINESSUNIT_KEY)+'&region='+oppParameters.get(REGION_KEY)+'&country='+oppParameters.get(COUNTRY_KEY)+'&stage='+oppParameters.get(STAGE_KEY)+'25');              
            //PageReference previewPage = new PageReference('/apex/SalesMotion?product=01t700000017VMfAAM');
            //PageReference previewPage = new PageReference('https://cs11.salesforce.com/apex/SalesMotion?product=' + ApexPages.currentPage().getParameters().get('salesMotionProd'));
            previewPage.setRedirect(true);
            System.debug('##### Sang Chian 222: ' + ApexPages.currentPage().getParameters().get('salesMotionProd'));
            return previewPage;
        }
        else{
            return null;
        }
    }
    
    public class SMNotFoundException extends Exception {}
    public class SMNoPageException extends Exception {}
    public class SMParamNotFoundException extends Exception {}    
    public class InvalidSearchDataException extends Exception {}
    public class InvalidOppException extends Exception {} 

}