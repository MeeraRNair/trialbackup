/***********************************************************
* Name          : Controller for SalesNominationFromContact
* Description   : All Sales Nomination
* ---------------------------------------------------------
* Revision      Release     Name    Date            Description
* 1.0           14.5        Anamika 18.04.2013      CR 8189 commented Campaign_Vehicle__c field
* 2.0           -           Emily   30.09.2013      CR 8801 sales nomination - commented currentpage==1
* 3.0           15.10       Meghana 05.09.2014      CR 10082 Include Nomination Close Date in VF and allow sorting on columns
************************************************************/

public with sharing class VFCntrlr_SalesNominationConFromContact{
    public String errorMessage {get; set;}
    public string errormsgForConStatus{get;set;}
    public String confirmMsgForConStatus{get;set;}
    public String infoMessage{get;set;}
    public Id contactId{get;set;}
    public List<Campaign> campList{get;set;}
    public List<CampaignMember> campMemList{get;set;}
    public List<campaignsWithCheckBox> campListToBeDisplayed;
    public Map<Id,Campaign> campIdtoCampObjMap= new Map<Id,Campaign>(); 
    public Map<Id,Campaign> campIdtoCampOfCurPageMap;
    public String nominatedId{get;set;}
    public String selectedId{get;set;} 
    public Set<Id> campIdwithCM=new set<Id>();
    public Set<id> selCampIds= new set<Id>();
    public boolean isSelectedCamp{get;set;}
    public static final integer PAGEROWCOUNT =10;
    
    public boolean hasNext {get; set;} 
    public boolean hasPrevious{get;set;}  
    public integer lastPage {get; set;}
    public integer currentPage {get; set;}
    public contact conObj{get;set;}
    public Date todayDate;
    
    //rev 3.0 - start
    private String sortDirection = 'ASC';    
    public String sortExp{
        get {
            return sortExp;
        }
        set {
            if (value == sortExp)
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            else
                sortDirection = 'ASC';
                sortExp = value;
        }
    }
    public String getSortDirection(){
        if (sortExp == null || sortExp == '')
            return 'ASC';
        else
            return sortDirection;
    }

    public void setSortDirection(String value)  {  
        sortDirection = value;
    }
    
    public PageReference SortData() {      
      setCon = null;
      campListToBeDisplayed = null;
      getcampListToBeDisplayed();       
      //setCon.setPageNumber(1);
      return null;
    }
    //rev 3.0 - end

    public VFCntrlr_SalesNominationConFromContact(ApexPages.StandardController controller){
        sortExp = ''; // rev 3.0
        conObj=(contact)controller.getRecord();
        errorMessage='';
        confirmMsgForConStatus='';
        currentPage=0;
        lastPage=0;        
        nominatedId=userInfo.getUserId();
        ConObj=[select id,name,status__c from contact where id=:conObj.id];
        if(conObj.status__c!=null && conObj.status__c.contains('Invalid') ){
                errormsgForConStatus='The contact cannot be nominated as its status is invalid';
        }
        todayDate=system.today();
        for(campaignMember cmpMem:[SELECT Id, CampaignId FROM CampaignMember where contactId=:conObj.Id]){
            campIdwithCM.add(cmpMem.campaignId);
        }
        
    }
    public class campaignsWithCheckBox{
        public boolean isSelected{get;set;}
        public campaign camp{get;set;}
        public campaignsWithCheckBox(campaign camp){
            this.isSelected=false;
            this.camp=camp;
        }
    }
    public ApexPages.StandardSetController setCon {
        get {
            //rev 3.0
            String query = 'SELECT id,Campaign_Vehicle__c, Campaign_Short_Name__c,Type,name,Status,Focus_LOB__c, ownerId, startDate, endDate,  nomination_close_date__c '
                            + ' FROM campaign '
                            + ' where nomination_close_date__c >= :todayDate and  allow_nomination__c=true  '
                            + ' and isActive=true and Is_this_Account_Play_Campaign__c=false and '
                            + ' id not in :campIdwithCM ';
                            

            if(setCon == null) {
                /* rev 3.0
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT id,Campaign_Short_Name__c,Type,name,Status,Focus_LOB__c,ownerId,
                                                                                        startDate,endDate FROM campaign where nomination_close_date__c >= :todayDate and  allow_nomination__c=true 
                                                                                        and isActive=true and Is_this_Account_Play_Campaign__c=false and 
                                                                                        id not in :campIdwithCM]));
                */
                if (sortExp != '')   
                     query = query + ' Order by '  + sortExp + ' ' + sortDirection ;
                
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query));

                if(setCon.getResultSize()>0){
                    this.setCon.setPageSize(PAGEROWCOUNT);
                    setCon.last();                                     
                    lastPage =  setCon.getPageNumber(); 
                    if (sortExp != ''){
                        setCon.setPageNumber(currentPage);                      
                    }
                    else{
                        setCon.first();    
                        currentPage = setCon.getPageNumber();
                    }
                    setPreviousAndNext();                                       

                }else{
                    errorMessage='No campaigns are available for nomination';
                }
            }
            return setCon;
        }
        set;
    }
    public PageReference saveNomination(){
        if(conObj.Status__c=='Marketing Suspect'){
            confirmMsgForConStatus='By nominating this contact, the status will also be updated to “Prospect”. Do you want to confirm this action?';
            return null;
        }
        //2.0 CR 8801
        //if(currentpage==1){
            for(campaignsWithCheckBox campChkBoxObj:campListToBeDisplayed){
                if(campChkBoxObj.isSelected==true){
                    selCampIds.add(campChkBoxObj.camp.Id);  
                }   
            }
            system.debug('selCampIds: '+selCampIds);
        //}
        List<CampaignMember> campMemToAddList = new List<campaignMember>();
        Map<id,Campaign> mapOfCampIdtoCampObj = new Map<id,campaign>([Select Id,Type from Campaign where id in:selCampIds]);
        for(Id campId:mapOfCampIdtoCampObj.KeySet()){
            CampaignMember cmpMem = createCMforContact(mapOfCampIdtoCampObj.get(campId));
            campMemToAddList.add(cmpMem);
        }
        if(!campMemToAddList.isEmpty()){
            try{
                insert campMemToAddList;
            }catch(exception e){
                errorMessage = 'A problem has occured: ' + e.getMessage();   
                system.debug('## [Code: VFCntrlr_SalesNominationConFromContact.SaveNomination] Caught APEX exception '+e.getMessage());
                return null;    
            }
        }
        return PageUtils.redirect('/'+conObj.Id);
    }
    public campaignMember createCMForContact(campaign camp){
        CampaignMember cmpMem = new CampaignMember();
        cmpMem.contactId=conObj.id;
        //cmpMem.Campaign_Vehicle__c=camp.Type; //1.0
        cmpMem.CM_Status__c='Nominated';
        cmpMem.campaignId=camp.Id;
        cmpMem.Nominated_By__c=nominatedId;
        return cmpMem;
    }
    public boolean hasPreviousAndNext {
        get {
            return (hasPrevious && hasNext);
        }
    }
        
    public PageReference Previous() {
        if(hasPrevious){
            for(campaignsWithCheckBox campChkBoxObj:campListToBeDisplayed){
                if(campChkBoxObj.isSelected==true){
                    selCampIds.add(campChkBoxObj.camp.Id);  
                }else{
                    if(selCampIds.size()>0){
                        if(selCampIds.contains(campChkBoxObj.camp.id)){
                            selCampIds.remove(campChkBoxObj.camp.id);
                        }
                    }
                }
            }
            campListToBeDisplayed=null;
            setCon.previous();
            currentPage = setCon.getPageNumber();
        }
        setPreviousAndNext();
        return null;    
    }
    
    public PageReference Next() {
        if(hasNext){
            for(campaignsWithCheckBox campChkBoxObj:campListToBeDisplayed){
                if(campChkBoxObj.isSelected==true){
                    selCampIds.add(campChkBoxObj.camp.Id);  
                }else{
                    if(selCampIds.size()>0){
                        if(selCampIds.contains(campChkBoxObj.camp.id)){
                            selCampIds.remove(campChkBoxObj.camp.id);
                        }
                    }
                }
            }      
            campListToBeDisplayed=null;
            setCon.next();
            currentPage = setCon.getPageNumber();
        } 
        setPreviousAndNext();
        return null;
    }
        
    public void setPreviousAndNext() {              
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
    Public PageReference Ok(){
        confirmMsgForConStatus=null;
        conObj.status__c='Prospect';
        try{
            update conObj;
        }catch(exception e){
            errorMessage = 'A problem has occured: ' + e.getMessage();   
            system.debug('## [Code: VFCntrlr_SalesNominationConFromContact.SaveNomination] Caught APEX exception '+e.getMessage());
            return null; 
        }
        return saveNomination();
    }

    public List<campaignsWithCheckBox> getcampListToBeDisplayed(){
        if(campListToBeDisplayed==null){
            campListToBeDisplayed= new List<campaignsWithCheckBox>();
            campList= new List<campaign>();
            campList = (List<campaign>)setcon.getRecords();
            for(Campaign camp:campList){
                campaignsWithCheckBox campWithChkBoxObj = new campaignsWithCheckBox(camp);
                if(selCampIds.size()>0){
                    if(selCampIds.contains(camp.id)){
                        campWithChkBoxObj.isSelected=true;
                        campListToBeDisplayed.add(campWithChkBoxObj);
                    }else{
                        campListToBeDisplayed.add(campWithChkBoxObj);
                    }
                }else{
                    campListToBeDisplayed.add(campWithChkBoxObj);
                }
            }
        }
        return campListToBeDisplayed;
    }
    public void setcampListToBeDisplayed(List<campaignsWithCheckBox> campListToBeDisplayed){
        this.campListToBeDisplayed=campListToBeDisplayed;
    }
}