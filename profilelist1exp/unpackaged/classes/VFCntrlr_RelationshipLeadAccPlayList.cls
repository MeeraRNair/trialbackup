/***********************************************************
* Name          : VFCntrlr_RelationshipLeadAccPlayList
* Description   : Controller for APCustomView, RLCustomView, AccountPlayList and RelationshipLeadList view
* ---------------------------------------------------------
* Revision  Name        Date        Description
* 1.0       Azwanti     14.04.2011  CR5988 - added check box to query current Fiscal Quarter RL  
* 1.1       Azwanti     14.04.2011  CR5989 - added radio button
* 1.2       Azwanti     20.04.2011  CR5987 - added sort by Status_Importance__c
* 1.3       Azwanti     25.04.2011  CR5988 - remove filter by current Fiscal Quarter for AP
* 1.4		Azwanti		20.02.2012	Attached to CR6449 - to fix SOQL limit issue
* 1.5       Rahul       13-07-2018  Code Reduce!
************************************************************/
public class VFCntrlr_RelationshipLeadAccPlayList {
       
    //R1.0
    Public Boolean iscurrentQuarterRL{get; set;}  
    Public Boolean iscurrentQuarterAP{get;set;} 
    Public String selectedRLView;     
    Public String selectedAPView;
    Public String currentRLAPPage;
    Public String subTitle{get; set;}
    Public Boolean isTest = false;
    
    Public List<Relationship_Lead__c> listOfRL {
    get {
        if(listOfRL ==null){
            listOfRL = new List<Relationship_Lead__c>();
            listOfRL = (List<Relationship_Lead__c>) setCon.getRecords();
        }
        return listOfRL;
    }
    set;
    }
    
    Public List<Account_Play__c> listOfAP {
    get {
     if(listOfAP==null){
            listOfAP= new List<Account_Play__c>();
            listOfAP = (List<Account_Play__c>) setCon.getRecords();
        }
        return listOfAP;
    }
    set;
    }
    
    //R1.1
    Public String APQuery,RLQuery,queryString,stringToAppend;
    Public Set<Id> AccIdSet = new Set<Id>();
    Public List<Account> listOfAccounts = new List<Account>();
    //initialize for pagination
    Public Boolean hasNext {get; set;}
    Public Boolean hasPrevious {get; set;}
    Private static final Integer PAGE_SIZE=50;
    Public integer currentPage {get; set;}
    Public integer lastPage {get; set;}
    
    public VFCntrlr_RelationshipLeadAccPlayList() {
        doOnLoad();
    }


    //Define the Constructor 
    public VFCntrlr_RelationshipLeadAccPlayList(ApexPages.StandardController controller) {
        doOnLoad();  
    }
    
    public PageReference redirectPage(){
        // check if current page is Account Play OR Relationship Lead page
        currentRLAPPage = String.valueOf(ApexPages.currentPage());
        
        PageReference AccountPlayTab = Page.APCustomView; 
        if(currentRLAPPage.contains('apcustomview') || currentRLAPPage.contains('APCustomView') || currentRLAPPage.contains('accountplaylist')){
            
            if(!currentRLAPPage.contains('fcf')){                
                stringToAppend = '/apex/APCustomView?save_new=1&sfdc.override=1&fcf='+StringUtils.defaultString(Label.Default_AP_view_ID);
            }
            else{
                return null;
            }
        }       
     
        else if(currentRLAPPage.contains('rlcustomview') || currentRLAPPage.contains('RLCustomView') || currentRLAPPage.contains('relationshipleadlist')){
            
            if(!currentRLAPPage.contains('fcf')){
                stringToAppend = '/apex/RLCustomView?save_new=1&sfdc.override=1&fcf='+StringUtils.defaultString(Label.Default_RL_view_ID);           
            }
            else{
                return null;
            }
        }    
        return pageUtils.redirect(stringToAppend);
    }
    
    public void doOnLoad(){
    
        currentRLAPPage = String.valueOf(ApexPages.currentPage());
        String isCurrentQuarterRLFlag = ApexPages.currentPage().getParameters().get('isCurrentQuarterRLFlag');
        String selectedRLViewFlag = ApexPages.currentPage().getParameters().get('selectedRLViewFlag'); 
        iscurrentQuarterRL  = BooleanUtils.strToBoolean(isCurrentQuarterRLFlag);
        selectedRLView = StringUtils.defaultString(selectedRLViewFlag);
        
        //Account Play
        String selectedAPViewFlag = ApexPages.currentPage().getParameters().get('selectedAPViewFlag'); 
        selectedAPView = StringUtils.defaultString(selectedAPViewFlag);
        
        //R1.3
        if(currentRLAPPage.contains('relationshipleadlist')){
            if(StringUtils.equalsIgnoreCase(selectedRLView.trim(),'myrl')){
                subTitle = 'My Relationship Leads';
            }
            else if(StringUtils.equalsIgnoreCase(selectedRLView.trim(),'myportfoliorl')){
                subTitle = 'My Portfolio Relationship Leads';
            }
            else{
                subTitle = 'All Relationship Leads';
            }
            
            if(iscurrentQuarterRL){
                subTitle += ' in Current Quarter';
            }
        }
        else if(currentRLAPPage.contains('accountplaylist')){
            if(StringUtils.equalsIgnoreCase(selectedAPView.trim(),'myap')){
                subTitle = 'My Account Plays';
            }
            else if(StringUtils.equalsIgnoreCase(selectedAPView.trim(),'myportfolioap')){
                subTitle = 'My Portfolio Account Plays';
            }
            else{
                subTitle = 'All Account Plays';
            }
        }         
    }
    
    //Define the StandardSetController required for pagination
    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) { 
                if(currentRLAPPage.contains('relationshipleadlist')){
                    RLQuery = getRLlistQuery();
                    queryString = RLQuery;
                }        
                else if(currentRLAPPage.contains('accountplaylist')){ 
                    APQuery = getAPListQuery();
                    queryString = APQuery;
                }  
                else if(isTest){
                    queryString = 'SELECT Name,Account_Play_Owner_Role__c,Account_Play_Owner__c,Account__c,Campaign__c,Account_Play_Expiry_Date_New__c,Status__c FROM Account_Play__c WHERE (Status__c!=\'Cancelled\' AND Status__c != \'Inactive\' AND Status__c !=\'Closed - Expired\') AND recordtypeid != \'' +GlobalVariables.LATTICE_AP_RECTYPE+ '\'  ORDER BY Status_Importance__c ASC, Account_Play_Expiry_Date_New__c DESC LIMIT 10000';
                }
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString)); 
                if(setCon.getResultSize()>0){
                    this.setCon.setPageSize(PAGE_SIZE);
                    setNextPrevious();
                    setCon.last();                    
                    lastPage =  setCon.getPageNumber(); 
                    setCon.first();    
                    currentPage = setCon.getPageNumber();
                }
                else if(setCon.getResultSize() == 0){
                    setNextPrevious();
                }
            }
            return setCon;
        }
        set;
    }
     
    /*############################################# RELATIONSHIP LEADS #############################################*/
    //R1.1      
    public List<SelectOption> getRLItems() {
        List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('myrl','My Relationship Leads'));
            options.add(new SelectOption('myportfoliorl','My Portfolio Relationship Leads'));
            options.add(new SelectOption('allrl','All Relationship Leads')); 
        return options;
    }
    public String getSelectedRLView() {
        return selectedRLView;
    }
    public void setSelectedRLView(String selectedRLView) { 
        this.selectedRLView = selectedRLView; 
    }
    //R1.1
    
    public String getRLlistQuery(){
        //R1.1
        RLQuery = 'SELECT Name,Relationship_Lead_Owner_Role__c,Relationship_Lead_Owner__c,Contact__c,Account__c,Campaign__c,Due_Date__c,Status__c,Relationship_Lead_Score__c ';
        RLQuery+= 'FROM Relationship_Lead__c';              
        RLQuery+= ' WHERE (Status__c!=\'Cancelled\' AND Status__c != \'Inactive\')';
        
        if(iscurrentQuarterRL){                
            RLQuery+= ' AND Due_Date__c = THIS_FISCAL_QUARTER';
        } 
        
        //get My Relationship Lead
        if(selectedRLView == 'myrl'){
             RLQuery+= ' AND Relationship_Lead_Owner__c = ';
             RLQuery+= '\'' + UserInfo.getUserId() + '\' '; 
        }
        //get My Portfolio Relationship Lead
        else if(selectedRLView == 'myportfoliorl'){         
            listOfAccounts  =  [Select Id FROM Account WHERE Id IN (SELECT AccountId From AccountTeamMember where UserId =:UserInfo.getUserId())limit 10000];//r1.4
            RLQuery+= ' AND (Contact__r.AccountId IN :listOfAccounts OR Contact__r.Account.OwnerId =\''+ UserInfo.getUserId() + '\')'; 
        }  
        
        //R1.0
        RLQuery += ' ORDER BY Status_Importance__c ASC, Score_Importance__c ASC, Due_Date__c ASC'; //R1.2
        RLQuery += ' LIMIT 10000';
        return RLQuery;
    }
    
    // Go to the RL list page     
    public PageReference navigateToListRLView() {
        if(iscurrentQuarterRL == null){
            iscurrentQuarterRL = false;
        }
        PageReference RLDetailPage = Page.RelationshipLeadList;         
        RLDetailPage.getParameters().put('isCurrentQuarterRLFlag',String.valueOf(iscurrentQuarterRL));         
        RLDetailPage.getParameters().put('selectedRLViewFlag',selectedRLView);
        RLDetailPage.setRedirect(true);
        return RLDetailPage;
    }
   
    // Go to the RL tab - Back button 
    public PageReference navigateToRLTab() {
        PageReference detailPage = Page.RLCustomView; 
        detailPage.setRedirect(true);
        return detailPage;
    } 
    /*############################################# ACCOUNT PLAYS #############################################*/
    //R1.1    
    //radio button     
    public List<SelectOption> getAPItems() {
    List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('myap','My Account Plays'));
        options.add(new SelectOption('myportfolioap','My Portfolio Account Plays'));
        options.add(new SelectOption('allap','All Account Plays')); 
        return options;
    }
    public String getSelectedAPView() {
        return selectedAPView;
    }
    public void setSelectedAPView(String selectedAPView) { 
        this.selectedAPView = selectedAPView; 
    }
    //R1.1

    public String getAPListQuery(){
        //R1.1-start
        
        APQuery  = 'SELECT Name,Account_Play_Owner_Role__c,Account_Play_Owner__c,Account__c,Campaign__c,Account_Play_Expiry_Date_New__c,Status__c ';
        APQuery += 'FROM Account_Play__c '; 
        APQuery += 'WHERE (Status__c!=\'Cancelled\' AND Status__c != \'Inactive\' AND Status__c !=\'Closed - Expired\') ';
        APQuery += 'AND recordtypeid != ';
        APQuery +=  '\'' +GlobalVariables.LATTICE_AP_RECTYPE+ '\' ';
        
        //get My Account Play  
        if(selectedAPView == 'myap'){   
             APQuery += ' AND Account_Play_Owner__c = ';
             APQuery +=  '\'' + UserInfo.getUserId() + '\'';              
        }
        //get My Portfolio Account Play
        else if(selectedAPView == 'myportfolioap'){
        
            for(AccountTeamMember atm:[Select AccountId From AccountTeamMember where UserId =: UserInfo.getUserId()]){
                AccIdSet.add(atm.AccountId);
            }
            
            APQuery += ' AND (Account__r.OwnerId = ';
            APQuery +=  '\'' + UserInfo.getUserId() + '\' ';
            APQuery += ' OR Account__c IN :AccIdSet)';
        }
        
        
        APQuery += ' ORDER BY Status_Importance__c ASC, Account_Play_Expiry_Date_New__c DESC'; 
        APQuery += ' LIMIT 10000';
    
        return APQuery;    
    } 
   
    // Go to the AP list page - 'Go!' button
    public PageReference navigateToListAPView() {
        if(iscurrentQuarterAP == null){
            iscurrentQuarterAP = false;
        }
        PageReference APDetailPage = Page.AccountPlayList;
    //R1.3  APDetailPage.getParameters().put('isCurrentQuarterFlag',String.valueOf(iscurrentQuarterAP));         
        APDetailPage.getParameters().put('selectedAPViewFlag',selectedAPView);
        APDetailPage.setRedirect(true);
        return APDetailPage;
    }
  
    // Go to the AP tab - 'Back' button
    public PageReference navigateToAPTab() {
        PageReference APListPage = Page.APCustomView; 
        APListPage.setRedirect(true);
        return APListPage;
    }
    
    /*############################################# PAGINATION #############################################*/
    //Function get called when user click on next link in dplicate record list
    public PageReference next() {
        if (hasNext){  
             listOfAP = null;
             listOfRL = null;              
             setCon.next();
             currentPage = setCon.getPageNumber();
            }
        setNextPrevious();
        return null;
    }
    
    //Function get called when user click on previous link in record list
    public PageReference previous() {
        if (hasPrevious){
            listOfAP = null;
            listOfRL = null;
            setCon.previous();
            currentPage = setCon.getPageNumber();
        }
        setNextPrevious();
        return null;
    }
    
    //Set values for hasNext and hasPrevious booleans
    private void setNextPrevious() {
        if (setCon.getHasNext()) {
            hasNext = true;
        }
        else {
            hasNext = false;
        }
        if (setCon.getHasPrevious()) {
            hasPrevious = true;
        }
        else {
            hasPrevious = false;
        }
    } 
    
    public boolean getHasPreviousAndNext(){
        return (hasPrevious && hasNext);
    }
}