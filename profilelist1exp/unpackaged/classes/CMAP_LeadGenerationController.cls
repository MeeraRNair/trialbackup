/* 
REVISION HISTORY
================
Version     Author      Date            Release#        CR#         Description
-------     ------      ----            --------        ---         -----------
1.0         Bianca      08-Nov-2012     14.2            --          Controller for CMAP_LeadGenerationInterface page
2.0         Jiji        20-Nov-2012     14.2            --          Modified to include Campaign selection for Leads from end Customer
3.0         Afiq        17-Sep-2015     16.10                       Added logic to retrieve campaign-lead associated number field
4.0         Sakshi      3-July-2018                     16103       Reduce code
5.0         Yamini      12-Feb-2019     FY20-0202       17115       Story 6070726: Channel: [PAM] Update Mass Lead Upload Requests design in Partner Portal 
5.1         Shue        24-Feb-2019     FY20-0202       17115       Fix PMD Violations
6.0         Shue        14-Mar-2019     FY20-0402       CR17125     Defect 6326439: SDET - Wunderkind:: CAMP:: FY20-0402:: Unable to submit MLUR - <apex:param name="accName" value="{!strSelectedItem}" />
*/

public class CMAP_LeadGenerationController {
    //V50 Starts
    public String strSelectedItem{get; set;}
    public List<SelectOption> listItems {get; set;}
    Public Map<Id, String> mapTrackSMAs = new Map<Id, String>(); 
    //V5.0 Ends
    public boolean bShowLeadGenerationPage{get;set;}
    public Map<Id, Partner_Campaign_Management__c> mapPartnerCampId{get;set;}
    public List<Partner_Campaign_Management__c> listPartnerCampaign{get; set;}
    public Id campId{get;set;}
    public string strCampName{get;set;}
    /*Start 3.0 Added logic to retrieve campaign-lead number field */ 
    public string strCampLeadNum{get;set;}
    /*End   3.0*/ 
    Public Id eCusId{get;set;}
    Public Boolean bIsendCustomer{get;set;}
    Public Boolean bNotendCustomer{get;set;}
    public Integer intTotalPages{get;set;}
    List<campaignWrapper> listCampaignName {get;set;}
    Integer intPageSize = 10;
    
    public List<Partner_Campaign_Management__c> getCampaignList() {
        return (List<Partner_Campaign_Management__c>) con.getRecords();
    }
    
    public CMAP_LeadGenerationController(ApexPages.StandardController controller) {
        bShowLeadGenerationPage = false;
        bIsendCustomer = false;
        bNotendCustomer = TRUE;
        mapPartnerCampId = new Map<Id, Partner_Campaign_Management__c>();
        listPartnerCampaign = new List<Partner_Campaign_Management__c>();
        
        List<Account> listSalesmotionAccs = PamCMAPutilityClass.getSalesmotionAccounts(UserInfo.getUserId());
        listItems = new List<SelectOption>();

        if(listSalesmotionAccs.size() >= 1){
            for(Account acc:listSalesmotionAccs){listItems.add(new SelectOption(acc.Id, acc.name+'  ('+acc.Account_ID__c+')'));}
            strSelectedItem = listSalesmotionAccs[0].Id;
            fetchCampaigns();
        }
      
        try{
            string strY = ApexPages.currentPage().getURL();
            if(strY.contains('eCusId')){
                eCusId = ApexPages.currentPage().getParameters().get('eCusId');
                bIsendCustomer = TRUE;
                bNotendCustomer = FALSE;
            } bShowLeadGenerationPage = true; } catch (Exception e) {PageUtils.AddError(System.Label.CMAP_Default_Error_Message);}
    }
    //StandardSetController for Partner_Campaign_Management__c list
    public ApexPages.StandardSetController con {
        get {
            if(con == null) {
                try{
                    con = new ApexPages.StandardSetController(mapPartnerCampId.Values());
                    // sets the number of records in each page set
                    con.setPageSize(intPageSize);
                    if(math.mod(con.getResultSize(), intPageSize) > 0) {intTotalPages  =(con.getResultSize()/intPageSize) + 1;}else{intTotalPages  = (con.getResultSize()/intPageSize);}}catch(Exception e){PageUtils.AddError(System.Label.CMAP_Default_Error_Message);
                    }
            }
            return con;
        }
        set;
    }
    
    //Submit single lead button is clicked
    public PageReference submitSingleLeadButton(){
        String strCampId = ApexPages.currentPage().getParameters().get('campId');
        return(PageUtils.Redirect('/apex/CMAP_SubmitSingleLead?campId='+strCampId));
    }
    
    //V5.0 Starts
    public Void fetchCampaigns(){
        try{
            listPartnerCampaign = [SELECT Id, Partner_Account__c, Campaign__r.Name, Campaign__c, Campaign_Lead_Flag__c, Name FROM Partner_Campaign_Management__c WHERE Partner_Account__c=:strSelectedItem and Campaign__r.isActive = true ORDER BY campaign__r.CREATEDDATE DESC];
            if(listPartnerCampaign.size() == 0){
               PageUtils.AddError(System.Label.CMAP_Lead_submission_error);
               PageUtils.AddError(System.Label.CMAP_no_Campaigns_associated_with_Partner_Account);
            }else{for(Partner_Campaign_Management__c pc : listPartnerCampaign){mapPartnerCampId.put(pc.Campaign__c,pc);}
            }
        }catch (Exception e){PageUtils.AddError(System.Label.CMAP_Default_Error_Message);}
    }//V5.0 Ends

    //Submit multiple leads button is clicked
    public PageReference submitMultipleLeadsButton(){
        String strCampId = ApexPages.currentPage().getParameters().get('campId');
        String strCampName= ApexPages.currentPage().getParameters().get('campName');
        String strAccName= ApexPages.currentPage().getParameters().get('accName');  //6.0
        return(PageUtils.Redirect('/apex/CMAP_MassLeadUpload?campId='+strCampId+'&campName='+strCampName+'&accName='+strAccName));  //6.0
    }    
    //Campaign Selection page for Lead Generation from an End customer
    public List<CampaignWrapper> getcampaignName() {
        listCampaignName= new List<CampaignWrapper>();
        CampaignWrapper campObj ;
        for(Partner_Campaign_Management__c pc :(List<Partner_Campaign_Management__c>)con.getRecords()){
            campObj = new CampaignWrapper();
            campObj.strCampName = pc.Campaign__r.Name;
            campObj.strCampLeadNum = String.valueOf(pc.Campaign_Lead_Flag__c);  /*3.0 Added logic to retrieve campaign-lead number field */ 
            campObj.id = pc.Campaign__c;
            listCampaignName.add(campObj);  
        }
        if(math.mod(con.getResultSize(), intPageSize) > 0) {intTotalPages  =(con.getResultSize()/intPageSize) + 1;}else{intTotalPages  = (con.getResultSize()/intPageSize);}
        return listCampaignName;
    }

    //Wrapper for Showing radio button for Campaign Selection 
    public class CampaignWrapper {
        public String strCampName{get;set;}
        public String id{get;set;}
        public String strCampLeadNum{get;set;}  /*Start 3.0 Added logic to retrieve campaign-lead number field */
        public CampaignWrapper(){
            this.strCampName ='';
            this.id ='';
            this.strCampLeadNum ='';    /*Start 3.0 Added logic to retrieve campaign-lead number field */
        }
     }

     //Continue Button action  
     public PageReference continueButton() {
        String strSelcampId = ApexPages.currentPage().getParameters().get('radioName');
        if(strSelcampId != null){return(PageUtils.Redirect('/apex/CMAP_SubmitSingleLead?eCusId='+eCusId+'&campId='+strSelcampId));}else{
            PageUtils.AddError(System.Label.CMAP_select_a_Campaign_to_proceed);
            return null;
        }
    }
    
    // indicates whether there are more records after the current page set.
    public Boolean bHasNext {
        get {return con.getHasNext();} set;
    }
 
    // indicates whether there are more records before the current page set.
    public Boolean bHasPrevious {
        get {return con.getHasPrevious();}
        set;
    }
 
    // returns the page number of the current page set
    public Integer intPageNumber{
        get{return con.getPageNumber();} set;
    }
 
    // returns the first page of records
    public void first() {
        con.first();
    }
 
    // returns the last page of records
    public void last() {
        con.last();
    }
 
    // returns the previous page of records
    public void previous() {
        con.previous();
    }
 
    // returns the next page of records
    public void next() {
        con.next();
    }
 
}