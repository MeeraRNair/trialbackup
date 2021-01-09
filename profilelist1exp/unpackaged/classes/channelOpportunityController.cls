/*
Revision    CR Number   Release No  Date            Modified By     Description
--------    ---------   ----------  -----------     ------------    -----------
1.0         10582        15.10      14-Oct-2014    Jiji           Lead Search PAge for new opportunity
2.0         10738        16.03      16-Dec-2014    jiji           Modified for CR 10738
3.0         10798        16.03      31-Dec-2014    Meera          Include DSG Partner also for opportunity association      
4.0         10738        16.03      03-Feb-2015    Jiji           CRQ: 1114 - Leads with Lost By Channel Partner status can be available in lead search page
5.0         15930   DCS-FY19-0703   07-Jun-2018    Akshita        Removed Commented lines and, system.debug statements as part of Opportunity code reduce story
*/
Public without sharing class channelOpportunityController {
    //variable Declaration
    Public List<Lead> LeadList;
    Public Id LeadId{ get; set; }
    Public Id leadOwnerId{ get; set; }
    Public String LeadName{ get; set; }
    Public String LeadcampName{get; Set;}
    Public Id LeadcampId{get; Set;}
    Public Id userId;
    Public Boolean isPartner{get;set;}
    Public String PartnerAccount{get; Set;}
    Public String FirstName{get; Set;}
    Public String LastName{get; Set;}
    Public String Email{get; Set;}
    Public String Company{get; Set;}
    Public String Campaign{get; Set;}
    Public lead leadRec{get; set;}
    Public Opportunity oppRec{get; set;}
    public Boolean isSearch{get; Set;}
    public Boolean isRecordExist{get; Set;}
    Public String URLstring{get; Set;}
    Public User u;
    Boolean searchExist;
    String stringToAppend;
    Id dealRegRTId;
    Id dealWithECusRTId;
    String recId ;
    String soql;
    Id channelLeadAssignedRT;
    Id channelLeadConvertedRT;
    Integer pageSize =10;
    
    public Integer totalPages{get;set;}
    public ApexPages.StandardSetController setCon {
        get {
        if(setCon == null){
            setCon = new ApexPages.StandardSetController(Database.getQueryLocator(soql));
            setCon.setPageSize(pageSize);
        }
            return setCon;
        }
        set;
    }
    
    public channelOpportunityController(ApexPages.StandardController controller) {
        
       leadRec = new Lead();
       oppRec = new Opportunity();
       isPartner = TRUE;
       isSearch = False;
       isRecordExist = False;
       searchExist = False;
       userId= UserInfo.getUserId();
       //get record type id from URL
       u = [Select Id, Phone, isPortalEnabled, UserType,AccountId,contact.Selected_track_account__c,ContactId,Enable_As_Partner_Lead_Super_User__c from User where Id = :userId];
       
       PageReference pr = ApexPages.currentPage();
       Map<String, String> params = pr.getParameters();
       channelLeadAssignedRT=StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead - Assignment Complete');
       channelLeadConvertedRT=StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead - Conversion');
       //version 3.0
       stringToAppend = '';
       //retain the URL parameters:
       //get all the parameter and store to stringToAppend
       for(String keyStr : params.keySet()){
            if(keyStr != 'core.apexpages.devmode.url' &&
                    keyStr != 'sfdc.override' &&
                    keyStr != 'save_new' &&
                    keyStr != 'scontrolCaching'){
                        if(stringToAppend != '') {
                            stringToAppend += '&';
                        }   
                stringToAppend += keyStr + '=' + params.get(keyStr);
            }
       } 
       recId = params.get('RecordType');   
        system.debug('****channelopportunityrec' +recId);
    }
     public List<Lead> getLeadList() {
         LeadList = setcon.getRecords();
        return LeadList;
    }

    public void setLeadList(String LeadList) {
        LeadList = LeadList;
    }
    //Redirect to respective pages based on the conitions
     public pagereference redirect(){       
       try{
           Map<String, String> opptyRecTypeMap = new Map<String,String>();
           dealRegRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
           dealWithECusRTId = IdLookupUtils.getRecordTypeId('Deal Registration for Existing End Customer', 'Opportunity', true);
           Set<Id> recordTypeSet=new Set<Id>{dealRegRTId, dealWithECusRTId};
           List<Lead> channelLeadList = [Select Id from Lead where OwnerId = :u.Id AND (Status ='Assigned to Channel partner' OR Status = 'Accepted by Channel Partner' OR Status = 'Pending Deal Reg' 
                                OR Status = 'Lost by Channel Partner' OR Status = 'Converted to Deal Reg') AND (RecordTypeId=:channelLeadAssignedRT OR RecordTypeId=:channelLeadConvertedRT)]; //version 3.0
           //Show this Vf page if the user is a Portal user with atleast one
           //Lead Assigned to him and seleted RT is Deal Reg
           if(u.isPortalEnabled == TRUE && u.UserType== 'PowerPartner' &&
               recordTypeSet.contains(recId.subString(0,15))  && 
               channelLeadList.Size() >0){
                  isPartner = TRUE;
                  return null;
           }
           //else navigate to opportunity redirect page
           else{
               String URL ;
               If(recordTypeSet.contains(recId.subString(0,15))){
                    URL= '/apex/EndCustomerSelectionPage?'+stringToAppend+'&nooverride=1';
                }else{
                    URL= '/apex/OpportunityRedirectPage?'+stringToAppend+'&nooverride=1';  
                }
               pagereference page = new pagereference(URL);
               page.setRedirect(TRUE);
               return page;
               //return NULL;
           }
       }
       catch(Exception ex){
            ApexPages.addmessages(ex);
       }
        return null;
    }
    //When User click on Search, get the lead details 
    public pagereference search(){
        isSearch = TRUE;
        LeadList = new List<Lead>();
        setCon = NULL;
        String assignedStatus = 'Assigned to Channel partner';
        String acceptedStatus = 'Accepted by Channel Partner';
        String convertedStatus = 'Converted to Deal Reg';//Ver 2.0
        String pendingStatus = 'Pending Deal Reg';//Ver 2.0
        String lostStatus = 'Lost by Channel Partner';//Ver 4.0
        searchExist = False;
        if(!Firstname.equals('') || !LastName.equals('') ||
            !Company.equals('') || !PartnerAccount.equals('') ||
            !Campaign.equals('') || !Email.equals('') ||
            leadRec.Follow_up_Date__c != NULL ||
            oppRec.CloseDate != NULL
        ){
            //Ver 2.0:
            soql = 'select Id, Name, MobilePhone, OwnerId , Company, Campaign__c,Source_Campaign_Id__c,Related_Opportunity_Count__c, Source_Campaign_Name__c, '+
                    ' Partner_Account__c, Country, Lead_Accepted_date__c, Campaign__r.Name,Partner_Lead_Status__c, Email, Status, CreatedDate,Partner_User__r.Name From Lead where '+
                    ' ((Status=\''+String.escapeSingleQuotes(assignedStatus) +'\''+' OR '+' Status=\''+String.escapeSingleQuotes(pendingStatus) +'\''+' OR '+
                    ' Status=\''+String.escapeSingleQuotes(convertedStatus) +'\''+' OR '+' Status=\''+String.escapeSingleQuotes(lostStatus) +'\''+' OR '+
                    ' Status =\''+String.escapeSingleQuotes(acceptedStatus)+ '\''+') AND '+' (RecordTypeId=\''+channelLeadAssignedRT +'\' '+ ' OR '+
                    ' RecordTypeId=\''+channelLeadConvertedRT +'\''+ ')'+' AND '+' Related_Opportunity_Count__c < 6' + ' AND '+' Partner_Account__c = \''+u.contact.Selected_track_account__c +'\')';
              
            if (!Firstname.equals('')){
                soql += ' AND (FirstName LIKE \'%'+String.escapeSingleQuotes(FirstName)+'%\'';
                searchExist = TRUE;
            }
            if (!LastName.equals('') && searchExist == TRUE)
                soql += ' OR LastName LIKE \'%'+String.escapeSingleQuotes(LastName)+'%\''; 
            else if (!LastName.equals('')){
                soql += ' AND (LastName LIKE \'%'+String.escapeSingleQuotes(LastName)+'%\'';
                searchExist = TRUE;
            }
            if (!Company.equals('') &&  searchExist == TRUE )
                soql += ' OR Company LIKE \'%'+String.escapeSingleQuotes(Company)+'%\'';    
            else if (!Company.equals('')){
                searchExist = TRUE;
                soql += ' AND ( Company LIKE \'%'+String.escapeSingleQuotes(Company)+'%\''; 
            }
            if (!PartnerAccount.equals('') && searchExist == TRUE){
                soql += ' OR Partner_Account__r.Name LIKE \'%'+String.escapeSingleQuotes(PartnerAccount)+'%\'';
            }else if (!PartnerAccount.equals('')){
                searchExist = TRUE;
                soql += ' AND( Partner_Account__r.Name LIKE \'%'+String.escapeSingleQuotes(PartnerAccount)+'%\'';
            }
            if (!Campaign.equals('') && searchExist == TRUE)  
                soql += ' OR Campaign__r.Name LIKE \'%'+String.escapeSingleQuotes(Campaign)+'%\'';
            else if (!Campaign.equals('')){
                searchExist = TRUE;
                soql += ' AND (Campaign__r.Name LIKE \'%'+String.escapeSingleQuotes(Campaign)+'%\'';
            }
            if (!Email.equals('') &&  searchExist == TRUE)
                soql += ' OR Email= \''+String.escapeSingleQuotes(Email)+'\'';      
            else if (!Email.equals('')){
                 searchExist = TRUE;
                 soql += ' AND (Email= \''+String.escapeSingleQuotes(Email)+'\'';  
            }
              if (leadRec.Follow_up_Date__c != NULL && searchExist == TRUE){ 
                DateTime dd = leadRec.Follow_up_Date__c;
                String dd1 = dd.format('yyyy-MM-dd\'T\'HH:mm:ss\'z\'', 'GMT');
                DateTime nextdd = leadRec.Follow_up_Date__c.addDays(1);
                String nextdd1 = nextdd.format('yyyy-MM-dd\'T\'HH:mm:ss\'z\'', 'GMT');
                
                soql += ' OR (CreatedDate>= '+dd1+ ' AND CreatedDate < '+nextdd1 +')';
            }
            else if (leadRec.Follow_up_Date__c != NULL){
                searchExist = TRUE;
                DateTime dd = leadRec.Follow_up_Date__c;
                String dd1 = dd.format('yyyy-MM-dd\'T\'HH:mm:ss\'z\'', 'GMT');
                DateTime nextdd = leadRec.Follow_up_Date__c.addDays(1);
                String nextdd1 = nextdd.format('yyyy-MM-dd\'T\'HH:mm:ss\'z\'', 'GMT');
                soql += ' AND ((CreatedDate >= '+dd1+' AND CreatedDate < '+nextdd1 +')';  
            }
            
            if (oppRec.CloseDate!= NULL && searchExist == TRUE){
                DateTime dd = oppRec.CloseDate; 
                String dd1 = dd.format('yyyy-MM-dd\'T\'HH:mm:ss\'z\'', 'GMT');
                DateTime nextdd = oppRec.CloseDate.addDays(1);
                String nextdd1 = nextdd.format('yyyy-MM-dd\'T\'HH:mm:ss\'z\'', 'GMT');
                
                soql += ' OR (CreatedDate>= '+dd1+ ' AND  CreatedDate < '+nextdd1 +')';  
            }    
            else if (oppRec.CloseDate!= NULL){
                 searchExist = TRUE;
                 DateTime dd = oppRec.CloseDate;
                 String dd1 = dd.format('yyyy-MM-dd\'T\'HH:mm:ss\'z\'', 'GMT');
                 DateTime nextdd = oppRec.CloseDate.addDays(1);
                 String nextdd1 = nextdd.format('yyyy-MM-dd\'T\'HH:mm:ss\'z\'', 'GMT'); 
                
                 soql += ' AND ((CreatedDate >= '+dd1+' AND CreatedDate < '+nextdd1 +')' ;  
            }
            soql=soql+') Order By Name LIMIT 1000';
            setCon.getRecords();
            if(setCon.getResultSize() > 0){
                isRecordExist= TRUE;
                if(math.mod(setCon.getResultSize(), pageSize) > 0) {
                    totalPages  =(setCon.getResultSize()/pageSize) + 1;
                }else{
                    totalPages  = (setCon.getResultSize()/pageSize);
                }
                if(totalPages ==0){
                    totalPages =1;
                }
                return null; 
            }
            else{
                totalPages =0;
                isRecordExist= False;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, System.Label.CMAP_NoMatchesfound);
                
                ApexPages.addMessage(myMsg);
                return null; 
            }
        }
        else{
            totalPages =0;
            isRecordExist= False;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, System.Label.CMAP_entercriteria);
            ApexPages.addMessage(myMsg);
            return NULL;
        }
    }
    //Navigate to Oppoutunity redirect page if user clicks on SkipSearch 
    public pagereference skipSearch(){
       String URL= '/apex/EndCustomerSelectionPage?'+stringToAppend+'&nooverride=1';
       pagereference page = new pagereference(URL);
       page.setRedirect(TRUE);
       return page;
    }
    // indicates whether there are more records after the current page set.
    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
        set;
    }
 
    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }
        set;
    }
 
    // returns the page number of the current page set
    public Integer pageNumber {
        get {
             return setCon.getPageNumber();
        }
        set;
    }
 
    // returns the first page of records
    public void first() {
        setCon.first();
    }
 
    // returns the last page of records
    public void last() {
        setCon.last();
    }
 
    // returns the previous page of records
    public void previous() {
        setCon.previous();
    }
 
    // returns the next page of records
    public void next() {
        setCon.next();
        
    }
    //Navigate to Opportunity create page when a user 
    //select a lead to be attached with the Opportunity
    public pagereference selectButton(){
        if(recId != NULL ){ 
            recId = recId.subString(0,15);
        }
        Date pastDate= Date.today()+15;
        if(u.UserType.contains('Partner')  ){
            List<contact> curContact=[select phone from contact where id = :u.contactId];
            //insert lead share for the selected lead
            if(u.Id != LeadOwnerId){
                LeadShare leadShareRec = new LeadShare(LeadId =LeadId,
                                    UserOrGroupId = u.Id,
                                    LeadAccessLevel ='Read');            
                insert leadShareRec;
            }
              URLstring= '/apex/EndCustomerSelectionPage?opp9='+pastDate.format()+(stringToAppend!=NULL?'&'+stringToAppend:'')+(LeadId!=NULL?'&CF00NA00000063bHk_lkid='+pageUtils.encodeVariable(LeadId):'')+
                       (LeadName!=NULL?'&CF00NA00000063bHk='+pageUtils.encodeVariable(LeadName):'')+(u.phone!=NULL?'&00NA00000063WX9='+pageUtils.encodeVariable(u.phone):'')+
                       (LeadcampId!=NULL?'&opp17_lkid='+pageUtils.encodeVariable(LeadcampId):'')+(LeadcampName!=NULL?'&opp17='+pageUtils.encodeVariable(LeadcampName):'');
       }
       else{
             URLstring = '/apex/EndCustomerSelectionPage?RecordType='+recId+'&opp9='+pastDate.format()+'&'+stringToAppend;
       }
       pagereference page = new pagereference(URLstring);
       page.setRedirect(TRUE);
       return page;
    }
}