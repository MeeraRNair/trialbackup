/*
REVISION HISTORY
======================================================================================================================
Version     Author      Date            Release#    CR#     Description
-------     ------      ----            --------    ---     -----------
1.0        Afiq        18/8/2015        16.09       11665   To add "Segment Description" for search field
1.10       Afiq        14/10/2015       16.10               Added new method to Add All Search Partner into the Opportunity
1.2        Sakshi      18/6/2018                    15979   Reduce code
*/

public class CMAP_AddMultiplePartnersCntrlr{
    Id partnerAccountRT = IdLookupUtils.getRecordTypeId('Partner Account', 'Account', true);
    List <Partner_Campaign_Management__c> pcm = new List<Partner_Campaign_Management__c>();
    List <Account> acct = new List <Account>();
    List <Account> acctAll = new List <Account>();
    List <Id> returnAllAccountId = new List <Id>();
    
    private final Integer PAGE_SIZE = Integer.ValueOf(System.Label.CMAP_AddMultiplePartnersPageSize);
    public List<Account> customAcctList;
    public List<customAcctWrapper> customAcctListWrap = new List<customAcctWrapper>();// {get; set;}
    public Set<String> checkedCustomAcct = new Set<String>();
    public Set<String> existingAccts = new Set<String>();
    public Boolean colCheck {get; set;}
    public Boolean noFilter {get; set;}
    public Boolean noResult {get; set;}
    public Boolean displaySearch {get; set;}
    
    public Boolean hasNext {get; private set;}
    public Boolean hasPrevious {get; private set;}
    public integer currentPage {get; private set;}
    public integer lastPage {get; private set;}
    
    public String accountQuery {get;set;}
    public String accountQueryAll {get;set;}
    public String AccountName {get;set;}
    public String AccountType {get;set;}
    public String AccountOwner {get;set;}
    public String PartnerAccountID {get;set;}
    public String BillingCity {get;set;}
    public String AffinityAccountID {get;set;}
    public String BillingState {get;set;}
    public String PartnerTier {get;set;}
    public String BillingPostal {get;set;}
    public String PartnerRelationship {get;set;}
    public String BillingCountry {get;set;}
    // Ver 1.0 Start
    public String SegmentDescription {get;set;}
    // Ver 1.0 End 
    public List<String> DellCertificationChosen {get;set;}
    public List<String> DellCertificationAvailable {get;set;}
    public String DellCertification = '';
    
    public String campaignId {get;set;}
    
    Set<String> originalvalues = new Set<String>();
    Set<string> leftvalues = new Set<string>();
    Set<string> rightvalues = new Set<string>();
    
    public List<SelectOption> getType(){
        List<SelectOption> typeOptions = new List<SelectOption>();
        typeOptions.add(new SelectOption('--None--', '--None--'));
        Schema.DescribeFieldResult field = Account.Account_Type_Integration__c.getDescribe();
        for(Schema.PicklistEntry pic : field.getPicklistValues())
            typeOptions.add(new SelectOption(pic.getLabel(), pic.getLabel()));
        
        return typeOptions;
    }
    
    public List<SelectOption> getCertification(){
        List<SelectOption> options = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(leftvalues);
        tempList.sort();
        for(string s : tempList)
            options.add(new SelectOption(s,s));
        return options;    
    }
    
    public List<SelectOption> getCertificationChosen(){
        List<SelectOption> options1 = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(rightvalues);
        tempList.sort();
        for(String s : tempList)
            options1.add(new SelectOption(s,s));
        return options1;    
    }
    
    public PageReference selectclick(){
        DellCertificationChosen.clear();
        for(String s : DellCertificationAvailable){
            leftvalues.remove(s);
            rightvalues.add(s);
        }
        return null;

    }
    
    public PageReference unselectclick(){
        DellCertificationAvailable.clear();
        for(String s : DellCertificationChosen){
            rightvalues.remove(s);
            leftvalues.add(s);
        }
        return null;

    }
    
       
    public PageReference doSearch(){
        DellCertification = '';    
        displaySearch = true;
        if(System.Test.isRunningTest()){
            campaignId = null;
        }
        else{
            //defect 15.10: regression issue: Start
            campaignId = ApexPages.currentPage().getParameters().get('id');
            //defect 15.10: regression issue.: End
        }
        for(Partner_Campaign_Management__c pAcct : [SELECT Partner_Account__c FROM Partner_Campaign_Management__c WHERE Campaign__c = :campaignId])
            existingAccts.add(pAcct.Partner_Account__c);    
        
        if(customAcctListWrap != null)
            customAcctListWrap.clear();
        if(checkedCustomAcct != null)
            checkedCustomAcct.clear();
        accountQuery = 'SELECT Name, Account_ID__c, Segment_Desc__c, Segment_Business_Unit_Name__c, BillingCity, BillingState, BillingCountry, Owner.Alias FROM Account WHERE RecordTypeId = :partnerAccountRT AND Id NOT IN :existingAccts AND Type IN (\'Partner\',\'OEM\')';
        if(AccountName != '')
            accountQuery += ' AND Name LIKE \'%' + AccountName + '%\'';
        if(AccountType != '--None--')
            accountQuery += ' AND Account_Type_Integration__c LIKE \'%' + AccountType + '%\'';
        if(AccountOwner != '')
            accountQuery += ' AND Owner.Name LIKE \'%' + AccountOwner + '%\'';
        if(PartnerAccountID != '')
            accountQuery += ' AND Id =: PartnerAccountID ';
        if(BillingCity != '')
            accountQuery += ' AND BillingCity LIKE \'%' + BillingCity + '%\'';
        if(AffinityAccountID != '')
            accountQuery += ' AND Account_ID__c LIKE \'%' + AffinityAccountID + '%\'';
        if(BillingState != '')
            accountQuery += ' AND BillingState LIKE \'%' + BillingState + '%\'';
        if(PartnerTier != '')
            accountQuery += ' AND Partner_Tier__c LIKE \'%' + PartnerTier + '%\'';
        if(BillingPostal != '')
            accountQuery += ' AND BillingPostalCode LIKE \'%' + BillingPostal + '%\'';
        if(PartnerRelationship != '')
            accountQuery += ' AND Partner_Relationship__c LIKE \'%' + PartnerRelationship + '%\'';
        if(BillingCountry != '')
            accountQuery += ' AND BillingCountry LIKE \'%' + BillingCountry + '%\'';
        //Ver 1.0 Start
        if(SegmentDescription != '')
            accountQuery += ' AND Segment_Desc__c LIKE \'%' + SegmentDescription + '%\'';
        //Ver 1.0 End   
        if(!rightvalues.isEmpty()){
            for(String val : rightvalues){
                DellCertification += val + ';';
            }
            DellCertification = DellCertification.substring(0,DellCertification.length()-1);                   
            accountQuery += ' AND Dell_Certification_Areas__c = \'' + DellCertification + '\'';
        }
            
        accountQuery += ' LIMIT ' + System.Label.CMAP_AddMultiplePartnersLimit;
        
        if(AccountName == '' && AccountType == '--None--' && AccountOwner == '' && PartnerAccountID == '' && BillingCity == ''
            && AffinityAccountID == '' && BillingState == '' && PartnerTier == '' && BillingPostal == '' && PartnerRelationship == '' 
            && BillingCountry == '' && SegmentDescription == '' && rightvalues.isEmpty()){
            noFilter = true;
            noResult = false;
            displaySearch = false;
            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter any of the fields and search again.'));
        }
        else{
            noFilter = false;
            acct = Database.query(accountQuery);
        
            if(acct.isEmpty()){
                noResult = true;
                displaySearch = false;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'No records to display. Please widen your search.'));
            }
            else{
                displaySearch = true;
                if(accountQuery != null){
                    setCon = new ApexPages.StandardSetController(Database.getQueryLocator(accountQuery));
                    if(setCon.getResultSize()>0){
                        setCon.setPageSize(PAGE_SIZE);
                        setCon.last();                                     
                        lastPage =  setCon.getPageNumber(); 
                        setCon.first();    
                        currentPage = setCon.getPageNumber();
                        setNextPrevious();                                       
    
                    }
                }  
            }
        }
        return null;
    }
    
    Public ApexPages.StandardSetController setCon{get;set;}
    
    Public CMAP_AddMultiplePartnersCntrlr(ApexPages.StandardSetController stdSetController){
        colCheck = false;
        noFilter = false;
        noResult = false;
        displaySearch = false;
        Schema.DescribeFieldResult field = Account.Dell_Certification_Areas__c.getDescribe();
        for(Schema.PicklistEntry pic : field.getPicklistValues())
            originalValues.add(pic.getLabel());
        leftValues.addAll(originalValues);
        DellCertificationAvailable = new List<string>();
        DellCertificationChosen = new List<string>();
    }
    
    public boolean getHasPreviousAndNext(){
        return (hasPrevious && hasNext);
    }
  
  //Method executed when clicked on Next
    public PageReference next() {
    
        if (hasNext){
            nextOrPrevious();
            setCon.next();
            currentPage = setCon.getPageNumber();                   
        }
        setNextPrevious();
        return null;
    }

  //Function get called when user click on previous link 
    public PageReference previous() {
        if (hasPrevious){
            nextOrPrevious();
            setCon.previous();
            currentPage = setCon.getPageNumber();
        }
        setNextPrevious();
        return null;
    }

    private void nextOrPrevious(){
        
        colCheck = FALSE;
        for(customAcctWrapper acct : customAcctListWrap){
            if(acct.acctCheck == TRUE)
                checkedCustomAcct.add(acct.custAcct.Id);
            if(acct.acctCheck == FALSE)
                checkedCustomAcct.remove(acct.custAcct.Id);
        }
        customAcctListWrap=null;
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
    
    public pageReference selectAllAccounts(){
        
        for(customAcctWrapper objWrapper : customAcctListWrap){
            if(colCheck == FALSE)
                objWrapper.acctCheck = FALSE;  
            if(colCheck == TRUE)
                objWrapper.acctCheck = TRUE;
        }
        return null;
    }
    
    public class customAcctWrapper{
    
        public Boolean acctCheck {get; set;}
        public Account custAcct{get; set;}
        
        public customAcctWrapper(Account ca){
            acctCheck = FALSE;
            custAcct= ca;
        }    
        
    }
    
    public List<customAcctWrapper> getCustomAcctListWrap(){
        if(customAcctListWrap == null || customAcctListWrap.isEmpty()){
          customAcctListWrap = new List<customAcctWrapper>();
          customAcctList = (List<Account>) setCon.getRecords();
            for(Account ca : customAcctList){
              customAcctWrapper caw = new customAcctWrapper(ca);
              
                if(checkedCustomAcct.contains(caw.custAcct.Id))
                  caw.acctCheck = TRUE;    
              
                customAcctListWrap.add(caw);
            }
        }
        
        return customAcctListWrap;
    }
    
    public PageReference doAddPartners(){
        PageReference retUrl = new PageReference(URL.getSalesforceBaseUrl().toExternalForm() + '/' + campaignId);
        for(customAcctWrapper acct : customAcctListWrap){
            if(acct.acctCheck == TRUE)
                checkedCustomAcct.add(acct.custAcct.Id);
            if(acct.acctCheck == FALSE)
                checkedCustomAcct.remove(acct.custAcct.Id);
        }
        pcm.clear();
        
        for(String acct : checkedCustomAcct){
            //defect 15.10: regression issue.
            pcm.add(new Partner_Campaign_Management__c(Partner_Account__c = acct,  Campaign__c = campaignId));
        }
        try{
            if(pcm.isEmpty() || pcm == null){
                noResult = false;
                noFilter = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'No partners have been selected. To continue, please select one or more partners and click the "Add Partners" button, or click "Cancel" to return to the campaign detail page.'));
                return null;    
            }
            
            insert pcm;
        }
        
        
        catch(DMLException e){
            noResult = false;
            noFilter = true;
            ApexPages.addMessages(e);
            return null;
        }
        return retUrl;
    }
    
    // Ver 1.1 Start
     public PageReference AddAllPartners(){
        if(System.Test.isRunningTest()){
            campaignId = ApexPages.currentPage().getParameters().get('id');
            system.debug(campaignId);
        }
        PageReference retUrl = new PageReference(URL.getSalesforceBaseUrl().toExternalForm() + '/' + campaignId);
        accountQueryAll = 'SELECT Id, Name, Account_ID__c, Segment_Desc__c, Segment_Business_Unit_Name__c, BillingCity, BillingState, BillingCountry, Owner.Alias FROM Account WHERE RecordTypeId = :partnerAccountRT AND Id NOT IN :existingAccts AND Type IN (\'Partner\',\'OEM\')';
        if(AccountName != '')
            accountQueryAll += ' AND Name LIKE \'%' + AccountName + '%\'';
        if(AccountType != '--None--')
            accountQueryAll += ' AND Account_Type_Integration__c LIKE \'%' + AccountType + '%\'';
        if(AccountOwner != '')
            accountQueryAll += ' AND Owner.Name LIKE \'%' + AccountOwner + '%\'';
        if(PartnerAccountID != '')
            accountQueryAll += ' AND Id =: PartnerAccountID ';
        if(BillingCity != '')
            accountQueryAll += ' AND BillingCity LIKE \'%' + BillingCity + '%\'';
        if(AffinityAccountID != '')
            accountQueryAll += ' AND Account_ID__c LIKE \'%' + AffinityAccountID + '%\'';
        if(BillingState != '')
            accountQueryAll += ' AND BillingState LIKE \'%' + BillingState + '%\'';
        if(PartnerTier != '')
            accountQueryAll += ' AND Partner_Tier__c LIKE \'%' + PartnerTier + '%\'';
        if(BillingPostal != '')
            accountQueryAll += ' AND BillingPostalCode LIKE \'%' + BillingPostal + '%\'';
        if(PartnerRelationship != '')
            accountQueryAll += ' AND Partner_Relationship__c LIKE \'%' + PartnerRelationship + '%\'';
        if(BillingCountry != '')
            accountQueryAll += ' AND BillingCountry LIKE \'%' + BillingCountry + '%\'';
        if(SegmentDescription != '')
            accountQueryAll += ' AND Segment_Desc__c LIKE \'%' + SegmentDescription + '%\'';
            accountQueryAll += 'LIMIT 1000';
        if(!rightvalues.isEmpty()){
            for(String val : rightvalues){
                DellCertification += val + ';';
            }
            DellCertification = DellCertification.substring(0,DellCertification.length()-1);                   
            accountQueryAll += ' AND Dell_Certification_Areas__c = \'' + DellCertification + '\'';
        }
        
        List<Account> acctAll = Database.query(accountQueryAll);
        
        for(Account acct : acctAll){
                returnAllAccountId.add(acct.Id);
        }
        pcm.clear();
        
        for(String acct : returnAllAccountId){
            pcm.add(new Partner_Campaign_Management__c(Partner_Account__c = acct,  Campaign__c = campaignId));
        }
        insert pcm;        
        return retUrl;
    }
    // Ver 1.1 End
}