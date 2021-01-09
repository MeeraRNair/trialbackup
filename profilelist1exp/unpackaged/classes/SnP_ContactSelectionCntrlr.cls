/***********************************************************
* Name          : SnP_ContactSelectionCntrlr
* Description   : Extension class for contact selection page
* ---------------------------------------------------------
* Revision      Release     Name        Date            Description
* 1.0           15.07       Raphael     16-05-2014      CR 9457 Auto populate contact section on the SV form, across all S&P Vendors
* 2.0           0703        Sakshi      14-06-2918      CR 15967 Reduce Code
************************************************************/

public class SnP_ContactSelectionCntrlr{
    
    public S_P_Vendors__c spVendor;
    public Contact con;
    public String acctId;
    public String pmProfile;
    //public ApexPages.StandardController controller;
    public String contactInfo {get;set;}
    public String searchString {get;set;}
    public String query {get;set;}
    public Boolean showResults {get;set;}
    public Integer conListSize;

    public SnP_ContactSelectionCntrlr(ApexPages.StandardController controller) {
        conListSize = 0;
        this.spVendor = (S_P_Vendors__c)controller.getRecord();
        this.acctId = spVendor.Opportunity__r.AccountId;
        hasPrevious = FALSE;
        hasNext = FALSE;
        showResults = true;
        this.conListSize = [SELECT COUNT() FROM Contact WHERE AccountId = :acctId AND Status__c NOT IN ('Invalid - Bad Email', 'Invalid - Bad Phone', 'Invalid - No Longer w/ Company', 'Invalid - Unmarketable')];
    }
    
    
    public pageReference redirect(){
        PageReference retUrl;
        pmProfile = [Select Name from Profile where Id =: userinfo.getProfileid()].Name;
        if(spVendor.Contact_Name__c != null || conListSize == 0 || pmProfile == 'GBL Manage S&P – Non SSO')// && sfdcUrl != urlNow)
            retUrl = goToSVEditPage();

        return retUrl;
    }
    
    public pageReference goToContactSelection(){
        PageReference retUrl = new PageReference('/apex/SnP_ContactSelectionPage?id=' + spVendor.Id);
        return retUrl;
    }
    
    public pageReference goToSVEditPage(){
        PageReference retUrl = new PageReference('/' + spVendor.Id + '/e?nooverride=1&retURL=%2F' + spVendor.Id);
        return retUrl;
    }
    
    
    public pageReference doSearch(){
        
    
        if(contactWrapperList != null)
            contactWrapperList.clear();
            
        query = 'SELECT Name, Phone, Email, Job_Function_Role__c FROM Contact WHERE AccountId = :acctId AND Status__c NOT IN (\'Invalid - Bad Email\', \'Invalid - Bad Phone\', \'Invalid - No Longer w/ Company\', \'Invalid - Unmarketable\')';
        
        if(searchString != null)
            query += ' AND Name LIKE \'%' + searchString + '%\'';
            //query += ' AND Name LIKE : \'%searchString%\'';
            
        query += ' ORDER BY Name ASC LIMIT ' + System.Label.SnP_ContactSelectionLimit;
        
        if(Database.query(query).size() == 0){
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'No records matching the search criteria. Please try again.'));
               showResults = false;
               return null;
        }
        else{
            setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query));
            
            if(setCon.getResultSize()>0 && setCon != null){
                arrangePageSize();                                       
    
            }
       }
       showResults = true;
       return null;   
    }
    
    public pageReference doSelect(){
        if(contactInfo == ''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Please select a contact or click Back'));
        }
        else{
            ID conId = (ID) contactInfo.subString(0, 15);
            con = [SELECT Name, Phone, Email, Job_Function_Role__c FROM Contact WHERE Id = :conId LIMIT 1];
            String contactUrl = '/' + spVendor.Id + '/e?nooverride=1&retURL=%2F' + spVendor.Id + '&00NA00000063PAe=' + con.Name;
            
            if(con.Phone != null)
            contactUrl += '&00NA00000063PBS=' + EncodingUtil.urlEncode(con.Phone, 'UTF-8');
            
            if(con.Email != null)
            contactUrl += '&00NA00000063PAy=' + EncodingUtil.urlEncode(con.Email, 'UTF-8');
            
            if(con.Job_Function_Role__c != null)
            contactUrl += '&00NA00000063PB3=' + EncodingUtil.urlEncode(con.Job_Function_Role__c, 'UTF-8');
            
            
            PageReference retUrl = new PageReference(contactUrl);
            
            return retUrl;
        }
        
        return null;
        
    }

    /////////////////////////////////////////////////////////////////////
    
    private final Integer PAGE_SIZE = Integer.ValueOf(System.Label.SnP_ContactSelectionPageSize);
    List<contactWrapper> contactWrapperList;
    List<Contact> contactList;
    
    public Boolean hasNext {get; private set;}
    public Boolean hasPrevious {get; private set;}
    public integer currentPage {get; private set;}
    public integer lastPage {get; private set;}
    
    public ApexPages.StandardSetController setCon{//{get;set;}
        get{
            if(setCon == null){
                //String query;
                query = 'SELECT Name, Phone, Email, Job_Function_Role__c FROM Contact WHERE AccountId = :acctId AND Status__c NOT IN (\'Invalid - Bad Email\', \'Invalid - Bad Phone\', \'Invalid - No Longer w/ Company\', \'Invalid - Unmarketable\') ORDER BY Name ASC';
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query));
                if(setCon.getResultSize()>0){
                   arrangePageSize();                                      

                }
            }
            return setCon;
        }
        set;
    }
    
    private void arrangePageSize(){
        
        this.setCon.setPageSize(PAGE_SIZE);
        setCon.last();                                     
        lastPage =  setCon.getPageNumber(); 
        setCon.first();    
        currentPage = setCon.getPageNumber();
        setNextPrevious();   
    }
    
    public boolean getHasPreviousAndNext(){
        return (hasPrevious && hasNext);
    }
    
    //Method executed when clicked on Next
    public PageReference next() {
        if(setCon != null){
            if (hasNext){
                contactWrapperList = null;
                setCon.next(); 
                currentPage = setCon.getPageNumber();
            }
            setNextPrevious();
        }
        return null;
    }

    //Function get called when user click on previous link 
    public PageReference previous() {
        if(setCon != null){
            if (hasPrevious){
                contactWrapperList = null;
                setCon.previous();
                currentPage = setCon.getPageNumber();
            }
            setNextPrevious();
        }
        return null;
    }
    //Set values for hasNext and hasPrevious booleans
    private void setNextPrevious() {
        if(setCon != null){
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
    }
    
    public class contactWrapper{
    
        public Boolean isChecked {get; set;}
        public Contact contWrap{get; set;}
        
        public contactWrapper(Contact con){
            isChecked = FALSE;
            contWrap = con;
        }    
        
    }
    
    public List<contactWrapper> getContactWrapperList(){
        if((contactWrapperList== null || contactWrapperList.isEmpty()) && setCon != null){
            contactWrapperList= new List<contactWrapper>();
            
            contactList = (List<Contact>) setCon.getRecords();
            for(Contact c : contactList){
              contactWrapperList.add(new contactWrapper(c));
            }
        }
        
        return contactWrapperList;
    }
}