/*
* Controller logic for Manage the User from partner Portal
* 
* 
* Story     CR Number   Release No     Date            Created By        Description
* --------  ---------   ----------    -----------     -----------       -----------
* #5688326  CR  16770   FY20-0402     08-Nov-2018     Mounika Ramagoni  
* #5663769  CR          FY20-0402     08-Nov-2018     Mounika Ramagoni  
* #5680698        FY20-0402    25-Jan-2019    Varsha    
* #7169839              FY20-1002     30-Aug-2018     Sneha Maheshwary
*/
public class ManageUsersCtrl{
    public string strtoPassData { get; set;}
    public string strFinalQuery {get; set;} 
    public user loggedInUser {get;set;}
    public List<Contact> listOfContacts ;
    public List<Contact> listOfContactsNew {get; set;}
    Public List<contactWrapper> listOfMapConWrap {get; set;}  
    public Boolean bErrorPartnerGroupTrackAdmin{get; set;}
    public Boolean bsuccess{get;set;}
    public string testdata {get;set;}
    public String strOfContactId {get;set;}// Passing selcetd contactId to PartnerAdminsCreateContact page.
    Public List<String> listOfAppAccess{get; set;}
    public String strOfAppAcc;
    public string strOfAppAccsInTooltip {set;get;} 
    public Map<String,string> mapOfFieldsStrWarp {get; set;}
    public Id userId {get;set;}
    public String strOfSelTrackAdmin {set;get;}
    public String strOfLastName{set;get;}
    public String strOfContactStatus{set;get;}
    public string strOfAppAccessCheck{set;get;}
    public string strOfPrtnerTrackCheck{set;get;}
    public string strOfSavePtnrTrackCheckForAction{set;get;} 
    public string strOfSaveContactId{set;get;} 
    public string strOfConIDToExport{set;get;}
    public string strOfLoginId {set;get;}
    public string strOfSaveToolAccessForAction{set;get;} 
    public string strEligibleTrackNamesInTooltip {set;get;}
    public Boolean bPartnerTrackForMoreValues {set;get;}
    public Boolean bAppAccessForMoreValues {set;get;}
    public Boolean bNoResults {get;set;}
    public Boolean bContactSelError {get;set;}
    public Boolean bContactSelSuccess {get;set;}
    public Boolean bContactInactiveError{get;set;}
    public Id masterAccountRecordTypeId;//Getting masteraccountrecordtype and assigned
    //Pallavi
    public String strOfActionOptions{get;set;}
    public string callfunc{get;set;}
    
    public User confirmActivateOrInactivateUser {get; set;}//Varsha
    // Raymond 20100224 - Added for CR2420
    public Partner_Request__c inactivationRequest;
    public static final String HTTP_PARAMETER_USERID = 'userId';//Varsha
    public String strAccountName {get;set;} 
    
    // For standard set controller
    Public Integer intsize{get;set;}
 Public Integer intnoOfRecords{get; set;}
 public List<SelectOption> listpaginationSizeOptions{get;set;}

 public static final Integer PAGE_SIZE = 10;
    public boolean bSearch = true;
    
    public ManageUsersCtrl() {
        confirmActivateOrInactivateUser = null;
        bContactSelError = false;
        //bsuccess = false;
        bContactSelSuccess =false;
        bContactInactiveError =false;
        userId = UserInfo.getUserId();
        testdata = 'null';
      
        //Logged in UserInfo 
       loggedInUser =  [SELECT Id,contact.accountId,Enable_Partner_Admin__c,
                        Enable_as_Partner_Group_Administrator__c,Enable_Partner_Deal_Registration__c,Enable_Partner_Lead_Management__c,OSC_Create_Quote__c,OSC_Create_Order__c,OSC_Specialty_Product_Create_Quote__c,OSC_Specialty_Product_Create_Order__c,
                        contact.EligibleTracks__c,Enable_As_Partner_Lead_Super_User__c,
                        contact.Premier_Partner__c,contact.Enable_User_for_MyRewards__c,contact.Allow_RFP_and_Proposal_Express_Tool__c,
                        contact.Allow_Partner_Central_User__c,contact.Allow_Program_Tracker__c,ContactId,contact.Is_MDF_User__c,contact.Is_Rebate_User__c FROM User WHERE Id =: userId];
        system.debug('userConid^^^^^^^^^^^^:'+loggedInUser.contact.accountId);
        strAccountName = [SELECT Name,Id FROM Account WHERE Id =: loggedInUser.contact.accountId].Name; 
         //loggedInUser = new user();
        // Make sure the user is a partner admin
        if(loggedInUser != null){
            if(loggedInUser.Enable_Partner_Admin__c == true || loggedInUser.Enable_as_Partner_Group_Administrator__c == true) {
                bErrorPartnerGroupTrackAdmin = false;     }
            
            // Make sure the user is a partner admin
            if(loggedInUser.Enable_Partner_Admin__c == false && loggedInUser.Enable_as_Partner_Group_Administrator__c == false) {
                bErrorPartnerGroupTrackAdmin = true;    }
        }
        
        bNoResults = false;
        system.debug('#####bNoResults '+bNoResults);
        getToolAccess();        
        getContactStatus();
        contactSetup();
        getPartnerTrackAdmin();
        getPartnerTracks();
        system.debug('bContactSelError^^^^^'+bContactSelError);
    } 
    
    Public List<String> loggedInUserEgT(){
        list<String> listOfloggedInUserConEgTrack = new list<String>();   
        if(String.isNotBlank(loggedInUser.contact.EligibleTracks__c)){
            if(loggedInUser.contact.EligibleTracks__c.contains(';')){
                listOfloggedInUserConEgTrack = loggedInUser.contact.EligibleTracks__c.split(';');
                system.debug('listOfloggedInUserConEgTrack !!!'+listOfloggedInUserConEgTrack);
            }else{
                listOfloggedInUserConEgTrack.add(loggedInUser.contact.EligibleTracks__c);  
            }
        }   
       return listOfloggedInUserConEgTrack;
    }
    
    // 0102 changes
    
    
    
    public ApexPages.StandardSetController setCon {
        get {
            system.debug('*****>>>>>>>>>'+strOfContactquery  +strWhereClause);
            if(setCon == null || !bSearch) {
                system.debug('>>>>>>>>>'+strOfContactquery  +strWhereClause);
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator((strOfContactquery  +' where'+strWhereClause)));
                // sets the number of records to show in each page view
                setCon.setPageSize(PAGE_SIZE);
                bSearch = true;
            }
            return setCon;
        }
        set;
    }
 
     
    public String strOfContactquery='';
        public string strOfCondition = '';
        public string strWhereClause = '';
        
     /** indicates whether there are more records after the current page set.*/
 public Boolean bhasNext {
 get {
   return setCon.getHasNext();
 }
 set;
 }
 
 /** indicates whether there are more records before the current page set.*/
 public Boolean bhasPrevious {
 get {
   return setCon.getHasPrevious();
 }
 set;
 }
 
 /** returns the first page of the page set*/
 public void first() {
   
   setCon.first();
   contactSetup();
 }
 
 /** returns the last page of the page set*/
 public void last() {
   
   setCon.last();
   contactSetup();
 }
 
 /** returns the previous page of the page set*/
 public void previous() {
   
   setCon.previous();
   contactSetup();
 }
 
    /** returns the next page of the page set*/
    public void next() {
        setCon.next();
        contactSetup();
    }
/** returns the page number of the current page set*/
 public Integer intpageNumber {
 get {
   return setCon.getPageNumber();
 }
 set;
 }
 
 /** return total number of pages for page set*/
   Public Integer getTotalPages(){
     Decimal dctotalSize = setCon.getResultSize();
     Decimal dcpageSize = setCon.getPageSize();
     Decimal dcpages = dctotalSize/dcpageSize;
     return (Integer)dcpages.round(System.RoundingMode.CEILING);
 }
    
    List<String> listOfLoggedinUserToolAccess = new List<String>();
    Public void contactSetup(){
        system.debug('#####contactSetup()');
        bNoResults = false;
        string strOfCondition = '';
        system.debug('#####bNoResults '+bNoResults);
       system.debug('userConid^^^^^^^^^^^^:'+loggedInUser.contact.accountId);
        listOfMapConWrap = new List<contactWrapper>();//to avoid repated list
        /*String strOfContactquery='';
        string strOfCondition = '';
        string strWhereClause = '';*/
       
        //TODO:Remove
        //system.debug('strOfContactStatus===>>'+strOfContactStatus);
        
        strOfPrtnerTrackCheck = Apexpages.currentPage().getParameters().get('ptnrTrackCheck');
        strOfAppAccessCheck = Apexpages.currentPage().getParameters().get('appAccCheck');
        
        masterAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Master_Account_Record_Type_Name).getRecordTypeId();
        system.debug('masterAccountRecordTypeId ####'+masterAccountRecordTypeId );
        if(masterAccountRecordTypeId != null){
            strOfContactquery = 'select id,AccountId,Name,FirstName,LastName,Email,phone,Premier_Partner__c,Partner_User__r.OSC_Specialty_Product_Create_Order__c,Partner_User__r.OSC_Specialty_Product_Create_Quote__c,Partner_User__r.OSC_Create_Order__c,Partner_User__r.OSC_Create_Quote__c,Partner_User__r.Email,Partner_User__r.Enable_As_Partner_Lead_Super_User__c,Partner_User__r.Enable_Partner_Lead_Management__c,Partner_User__r.Enable_Partner_Deal_Registration__c,Partner_User_Deal_Registration__c,OSC_Create_Quote__c,OSC_Create_Order__c,OSC_Specialty_Product_Create_Quote__c,OSC_Specialty_Product_Create_Order__c,Partner_User_Lead_Management__c,Partner_User_Lead_Super_User__c,EligibleTracks__c,Enable_as_Partner_Group_Administrator__c,Partner_User_Partner_Admin__c,Status__c,Partner_Application_Access__c,Enable_User_for_MyRewards__c,Allow_RFP_and_Proposal_Express_Tool__c,Allow_Partner_Central_User__c,Allow_Program_Tracker__c,Account.Master_Group_Affinity_ID__c,Partner_User__c,Partner_User_Active__c,Is_MDF_User__c,Is_Rebate_User__c FROM Contact';
            system.debug('strOfContactquery####'+strOfContactquery);
         
            strWhereClause  = ' AccountId =\''+loggedInUser.contact.accountId+'\' AND Account.RecordTypeId =: masterAccountRecordTypeId';
            system.debug('strWhereClause #### in where'+strWhereClause);
        
        }
       
        //Partner Group Admin
        String strOfIsActiveCheck;
        if(String.isBlank(strOfContactStatus) || strOfContactStatus == 'True'){
            strOfIsActiveCheck = 'True';
        }
        else If(strOfContactStatus == 'False'){
            strOfIsActiveCheck = 'False'; 
        }
         
        if(loggedInUser.Enable_as_Partner_Group_Administrator__c == true){
            if(String.isBlank(strOfContactStatus) || strOfContactStatus == 'True' || strOfContactStatus == 'False'){
             //strOfContactquery += ' AND  Partner_User_Active__c = '+ strOfIsActiveCheck;
             strWhereClause  += ' AND  Partner_User_Active__c = '+ strOfIsActiveCheck;
                  system.debug('in group');
                system.debug('in group strWhereClause  '+strWhereClause);
            }
        }
        system.debug('in group strWhereClause  119'+strWhereClause);
        //Partner Tarck Admin
        if(loggedInUser.Enable_Partner_Admin__c == true && loggedInUser.Enable_as_Partner_Group_Administrator__c == false){
            if(String.isBlank(strOfContactStatus) || strOfContactStatus == 'True' || strOfContactStatus == 'False'){
                strWhereClause  += ' AND  Enable_as_Partner_Group_Administrator__c = false' + ' AND Partner_User_Active__c = '+ strOfIsActiveCheck;// only TackAdmin Checked contacts 
             system.debug('in track');
             system.debug('strOfContactquery@@@'+strWhereClause);
            }
            else{
                strWhereClause  += ' AND Enable_as_Partner_Group_Administrator__c= false' ;
                 system.debug('in track esle');
            }
        }
       
        if(String.isBlank(strOfLastName) && String.isBlank(strOfAppAccessCheck) && String.isBlank(strOfSelTrackAdmin) && String.isBlank(strOfPrtnerTrackCheck) && strOfContactStatus == 'True'){
             system.debug('in 130');
            //strOfContactquery = strOfContactquery;
            strWhereClause  = strWhereClause;
            bSearch = false;
            system.debug('>>>strWhereClause'+strWhereClause);
        }
        else{
            system.debug('else'); 
            System.debug('strOfLastName: '+strOfLastName);
            System.debug('strOfAppAccessCheck: '+strOfAppAccessCheck);
            System.debug('strOfSelTrackAdmin: '+strOfSelTrackAdmin);
            System.debug('strOfPrtnerTrackCheck: '+strOfPrtnerTrackCheck);
            System.debug('strOfContactStatus: '+strOfContactStatus);
            
            if(strOfLastName != null && strOfAppAccessCheck != null && String.isEmpty(strOfLastName)){
                strOfCondition = strOfCondition.replaceAll('AND\\s*LastName\\s*LIKE\\s*\'%[^%]*%\'','');
                bSearch = false;
            }
            if(String.isNotBlank(strOfLastName)){
                strOfCondition += ' AND LastName LIKE \'%'+strOfLastName.trim()+'%\'';
                bSearch = false;
            }
            if(String.isNotBlank(strOfAppAccessCheck)){
                list<string> listOfAppAccCheck = strOfAppAccessCheck.split(',');
                for(Integer intI=0; intI<listOfAppAccCheck.size();intI++){
                   strOfCondition += ' AND '+listOfAppAccCheck[intI]+'='+true;
                }
            }
            system.debug('>>strOfCondition:'+strOfCondition);
            if(String.isNotBlank(strOfSelTrackAdmin)){
                system.debug('>>strOfSelTrackAdmin:'+strOfSelTrackAdmin);
                if(strOfSelTrackAdmin == 'False'){
                    
                    strOfCondition += ' AND Partner_User_Partner_Admin__c = '+false;
                }
                else{
                    strOfCondition += ' AND Partner_User_Partner_Admin__c = '+true;
                }
            }
        }
         system.debug('>>strOfCondition:'+strOfCondition);
        if(strOfCondition != ''){
            strWhereClause  +=strOfCondition;
            system.debug('>>strWhereClause:'+strWhereClause);
        }
        
        strWhereClause  = strWhereClause+' ORDER BY LastName ASC LIMIT 5000';
        system.debug('Query===>>'+strOfContactquery);
        system.debug('finalQuery: '+strOfContactquery  +' where'+strWhereClause);
        strFinalQuery =  strWhereClause ;  
       // listOfContacts = database.Query(strOfContactquery  +' where'+strWhereClause);
       listOfContactsNew = setCon.getRecords();
       system.debug('listOfContactsNew >>>:'+listOfContactsNew );
       listOfContacts= listOfContactsNew.clone();
       system.debug('listOfContacts###'+listOfContacts+'listOfContacts###size'+listOfContacts.size());
        system.debug('strOfPrtnerTrackCheck out:'+strOfPrtnerTrackCheck);
        //listOfContacts = new List<Contact>();
        if(String.isNotBlank(strOfPrtnerTrackCheck)){
            list<string> listOfPtnrTrckCheck = strOfPrtnerTrackCheck.split(',');
            Integer intJ = 0;
            while (intJ < listOfContacts.size())
            {
                system.debug('===List==>>>'+listOfContacts.get(intJ));
                boolean bFlag=true;
                for(integer intI=0;intI<listOfPtnrTrckCheck.size();intI++){
                    string strPtChk = listOfPtnrTrckCheck[intI];
                    //system.debug(intJ+'strPtChk ###'+strPtChk);
                    if(listOfContacts.get(intJ).EligibleTracks__c != null){
                        if(listOfContacts.get(intJ).EligibleTracks__c.contains(strPtChk)){
                            bFlag=false;
                            break;
                        }
                    }
                }
                if(bFlag){listOfContacts.remove(intJ);}else
                { intJ++;}
                //   system.debug(intJ+'====Size===>>>'+listOfContacts.size());
            }
        }
        system.debug('Final list'+listOfContacts.size());
        Map<String, string> mapOfFieldsStr = new Map<String, string>();//to avoid repated list
        List<String> listOfloggedInUserEligibleTracksIds =  new List<String>();
        Map<Id, String> mapOfContTrackNames = new Map<Id, String>();
        Map<String, string> mapOfFieldsStrSize = new Map<String, string>();
        
        // EligibleTracks Names
       
        system.debug(': =========Conid ==== :'+loggedInUser.contact.EligibleTracks__c);
        if(loggedInUser.contact.EligibleTracks__c != null){//&& con.id == loggedInUser.contactId
            List<String> listOfEligibleTrackIdsOfLoggedInUser = loggedInUserEgT();//loggedInUser.contact.EligibleTracks__c.split(';');
            //TODO:Remove
            system.debug('listOfEligibleTrackIdsOfLoggedInUser '+listOfEligibleTrackIdsOfLoggedInUser);
            for(String strOfEgTrackId: listOfEligibleTrackIdsOfLoggedInUser){
                system.debug('strOfEgTrackId '+strOfEgTrackId);
                listOfloggedInUserEligibleTracksIds.add(strOfEgTrackId);    
            } 
        }        
         system.debug(': listOfloggedInUserEligibleTracksIds :'+listOfloggedInUserEligibleTracksIds);   
        if(!listOfloggedInUserEligibleTracksIds.isEmpty()){
        for(Partner_Track__c partnerTrack : [SELECT Id,Name,Track_Name__c,Partner_Track_Name__c,Track_Id__c FROM Partner_Track__c WHERE Id IN: listOfloggedInUserEligibleTracksIds ORDER BY Track_Name__c ASC NULLS LAST]){
            if(String.isNotBlank(partnerTrack.Track_Name__c)){
                mapOfContTrackNames.put(partnerTrack.id, partnerTrack.Track_Name__c);
                system.debug('ContactTrackNames In ###'+mapOfContTrackNames);
            }
        }
      }
        system.debug('ContactTrackNames###'+mapOfContTrackNames);
        
        // Application Access check
       // if(listOfContacts != null){
       system.debug('227777'+listOfContacts.size());
            for(Contact con: listOfContacts){
                system.debug('con****'+con);
                listOfAppAccess = new List<String>();
                strOfAppAcc ='';
                strOfAppAccsInTooltip ='';
                string strOfAppAccStrWithNextLine ='';
                mapOfFieldsStr = new Map<String, string>();
                bAppAccessForMoreValues = false;
                //system.debug('toolaccess****'+listOfLoggedinUserToolAccess);
                if(con.Partner_User_Deal_Registration__c == True && listOfLoggedinUserToolAccess.contains(label.Deal_Registration)){
                    listOfAppAccess.add(label.Deal_Registration);
                    
                }
                if(con.Partner_User_Lead_Management__c == True  && listOfLoggedinUserToolAccess.contains(label.Lead_Management)){
                    listOfAppAccess.add(label.Lead_Management);
                    
                }
                if(con.Partner_User_Lead_Super_User__c == True  && listOfLoggedinUserToolAccess.contains(label.Lead_Super_User)){
                    listOfAppAccess.add(label.Lead_Super_User);
                    
                }
                if(con.Is_MDF_User__c== True  && listOfLoggedinUserToolAccess.contains(label.MDF)){
                  listOfAppAccess.add(label.MDF);
                   
                }
                if(con.Enable_User_for_MyRewards__c == True  && listOfLoggedinUserToolAccess.contains(label.MyRewards)){
                    listOfAppAccess.add(label.MyRewards);
                    
                }
                if(con.Allow_Partner_Central_User__c == True  && listOfLoggedinUserToolAccess.contains(label.Partner_Central)){
                    listOfAppAccess.add(label.Partner_Central);
                    
                }
                if(con.Premier_Partner__c == True  && listOfLoggedinUserToolAccess.contains(label.Premier)){
                    listOfAppAccess.add(label.Premier);
                    
                }
                if(con.Allow_Program_Tracker__c== True  && listOfLoggedinUserToolAccess.contains(label.Program_Tracker)){
                    listOfAppAccess.add(label.Program_Tracker);
                    
                }
                if(con.Is_Rebate_User__c== True  && listOfLoggedinUserToolAccess.contains(label.Rebates)){
                   listOfAppAccess.add(label.Rebates);
                   
                }
                if(con.Allow_RFP_and_Proposal_Express_Tool__c == True  && listOfLoggedinUserToolAccess.contains(label.RFP_Proposal_Express_Tool)){
                    listOfAppAccess.add(label.RFP_Proposal_Express_Tool);
                    
                }
                //Added as part of 6335018 [SFDC] ISG Enablement: Channel 2 Tier: Retrofit Manage User Partner Admin Search filters for create quote/order
                if(con.OSC_Create_Quote__c == True && listOfLoggedinUserToolAccess.contains(label.OSC_Create_Quote)){
                    listOfAppAccess.add(label.OSC_Create_Quote);
                }
                if(con.OSC_Create_Order__c ==True && listOfLoggedinUserToolAccess.contains(label.OSC_Create_Order)){
                    listOfAppAccess.add(label.OSC_Create_Order);
                }
                if(con.OSC_Specialty_Product_Create_Quote__c ==True && listOfLoggedinUserToolAccess.contains(label.OSC_SP_Create_Quote)){
                    listOfAppAccess.add(label.OSC_SP_Create_Quote);
                }
                if(con.OSC_Specialty_Product_Create_Order__c ==True && listOfLoggedinUserToolAccess.contains(label.OSC_SP_Create_Order)){
                    listOfAppAccess.add(label.OSC_SP_Create_Order);
                }
               // system.debug('listOfAppAccess'+listOfAppAccess);
                strOfAppAcc = String.join(listOfAppAccess,',');
                // system.debug('strOfAppAcc '+strOfAppAcc);
                strOfAppAcc = strOfAppAcc.remove('[]');
                strOfAppAccStrWithNextLine = strOfAppAcc+','; 
                //system.debug('strOfAppAccStrWithNextLine '+strOfAppAccStrWithNextLine);
                String strFinalAppAccStr = '';
                List<String> listOfAppAccStrs= new List<String>();
                listOfAppAccStrs= strOfAppAcc.Split(',');
                //system.debug('listOfAppAccStrs!!!'+listOfAppAccStrs);
                if(listOfAppAccStrs!=null && con.id != loggedInUser.contactId){
                    for(Integer intI=0; intI<listOfAppAccStrs.size(); intI++){
                        if(intI<3){
                            strFinalAppAccStr += listOfAppAccStrs[intI]+',';
                            if(listOfAppAccStrs.size() > 3){
                                bAppAccessForMoreValues = true;
                                strOfAppAccsInTooltip = strOfAppAccStrWithNextLine;
                                //system.debug('strOfAppAccsInTooltip'+strOfAppAccsInTooltip);
                            }
                            //system.debug('strFinalAppAccStr'+strFinalAppAccStr);
                        }
                    }
                }
                
                mapOfFieldsStr.put('Application_Access',strOfAppAccsInTooltip.replace(',','<br/>'));
                mapOfFieldsStr.put('Application_AccessSize',strFinalAppAccStr.removeEnd(','));
                system.debug('appAccessList24999'+mapOfFieldsStr);
                
                List<String> listOfPartnerTrackEgTrackIds = new List<String>();
                String strOfEligibleTrackNames='';
                String strOfFinalPartnerTrackNames ='';
                List<String> listofEligibleTrackNames= new List<String>();
                strEligibleTrackNamesInTooltip ='';
                String strOfEligibleTrackNamesWithNextLine = '';
                //String logEG = loggedInUser.contact.EligibleTracks__c;
                bPartnerTrackForMoreValues = false;
                if(String.isNotBlank(con.EligibleTracks__c)){
                   listOfPartnerTrackEgTrackIds = con.EligibleTracks__c.split(';');
                    //system.debug('@@@@listOfPartnerTrackEgTrackIds'+listOfPartnerTrackEgTrackIds);
                    listofEligibleTrackNames = new List<String>();
                    for(String strOfTrackNames: listOfPartnerTrackEgTrackIds){
                      //system.debug('strOfTrackNames$$$strOfTrackNames'+strOfTrackNames);
                        //system.debug('@@@@Contains : '+listOfloggedInUserEligibleTracksIds.Contains(strOfTrackNames));
                      if(listOfloggedInUserEligibleTracksIds.Contains(strOfTrackNames)){
                            strOfEligibleTrackNames += mapOfContTrackNames.get(strOfTrackNames)+',';
                            //system.debug('@@@@strOfEligibleTrackNames'+strOfEligibleTrackNames);
                            listofEligibleTrackNames = strOfEligibleTrackNames.Split(',');
                            //system.debug('listofEligibleTrackNames!!!'+listofEligibleTrackNames);
                            strOfEligibleTrackNamesWithNextLine += mapOfContTrackNames.get(strOfTrackNames)+',';
                        }
                    }
                    //system.debug('con.id'+con.id +'###loggedInUser.contactId '+loggedInUser.contactId);
                    if(listofEligibleTrackNames!=null && con.id != loggedInUser.contactId){
                        //system.debug('listofEligibleTrackNames'+listofEligibleTrackNames);
                        for(Integer intI=0; intI<listofEligibleTrackNames.size(); intI++){
                            if(intI<3){
                                strOfFinalPartnerTrackNames += listofEligibleTrackNames[intI]+',';
                                //system.debug('strOfFinalPartnerTrackNames'+strOfFinalPartnerTrackNames);
                                if(listofEligibleTrackNames.size() > 3){
                                    bPartnerTrackForMoreValues = true;
                                    strEligibleTrackNamesInTooltip = strOfEligibleTrackNamesWithNextLine;
                                    //system.debug('strEligibleTrackNamesInTooltip'+strEligibleTrackNamesInTooltip);
                                }
                                //system.debug('finalPartnerTrackNames'+finalPartnerTrackNames);
                            }
                        }
                    }
                }
                if(con.id != loggedInUser.contactId){
                    
                    mapOfFieldsStr.put('EligibleTracks__c',strEligibleTrackNamesInTooltip.replace(',','<br/>'));
                    mapOfFieldsStr.put('EligibleTracks__c_of_Size',strOfFinalPartnerTrackNames.removeEnd(','));
                    listOfMapConWrap.add(new contactWrapper(con, mapOfFieldsStr, bPartnerTrackForMoreValues, bAppAccessForMoreValues));
                    system.debug('#####strOfFinalPartnerTrackNames '+mapOfFieldsStr);
                    system.debug('#####listOfMapConWrap '+listOfMapConWrap);
                }
        }
         if(listOfMapConWrap.isEmpty()){
                system.debug('#####listOfMapConWrap.isEmpty() '+listOfMapConWrap.isEmpty());  
                system.debug('#####bNoResults '+bNoResults);
                bNoResults = true;
            }
    }
    
 
    
    /* Public list<String> conEligibleTracks(String strEgTrack){
    list<String> selecetdContactEgTrack;   
       // if(String.isNotBlank(con.EligibleTracks__c)){
            if(strEgTrack.contains(';')){
                selecetdContactEgTrack = strEgTrack.split(';');
                system.debug('selecetdContactEgTrack !!!'+selecetdContactEgTrack);
            }else{
                selecetdContactEgTrack.add(strEgTrack);  
            }
       // }   
       return selecetdContactEgTrack;
    }*/
    
    // Return Contact list after validations 
    Public list<Contact> allActionLogic(){
        string strOfErrorMsg = '';
        bContactSelError = false;
        bContactSelSuccess =false;
        bContactInactiveError =false;

        strOfSaveToolAccessForAction = Apexpages.currentPage().getParameters().get('ToolAccessForAction');//Selected TA id to update
        strOfSaveContactId = Apexpages.currentPage().getParameters().get('saveContactConId');//Selected contact id to update
        strOfSavePtnrTrackCheckForAction = Apexpages.currentPage().getParameters().get('ptnrTrackCheckForAction'); 
        
        list<string> listOfRecToSave = new list<string>();
        if(String.isNotBlank(strOfSaveContactId)){
            for(string strOfConIds: strOfSaveContactId.split(',')){
                //system.debug('strOfConIds***'+strOfConIds);
                listOfRecToSave.add(strOfConIds);// Selected contact Id/Ids's adding to list to compare in soql(listOfContactsToUpdate)
            }
        }
        
        if(String.isBlank(strOfSaveContactId)){
            bContactSelError = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, label.No_Contact_Selected_Error));
            strOfErrorMsg = label.No_Contact_Selected_Error;
           
        }
        if(String.isBlank(strOfSavePtnrTrackCheckForAction) && (strOfActionOptions == label.Add_selected_users_to_Tracks || strOfActionOptions == label.Remove_selected_users_from_Tracks)){
            bContactSelError = true;
            bContactInactiveError = false;
            bContactSelSuccess = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, label.partner_track_to_perform_an_action_error));
            strOfErrorMsg = label.partner_track_to_perform_an_action_error;
            system.debug('strOfSavePtnrTrackCheckForAction!!!'+strOfSavePtnrTrackCheckForAction);
        }
        if(String.isBlank(strOfSaveToolAccessForAction) && (strOfActionOptions == label.Provide_Tools_Access_to_selected_users || strOfActionOptions == label.Remove_Tools_Access_to_selected_users)){
                bContactSelError = true;
                bContactInactiveError = false;
                bContactSelSuccess = false;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, label.tool_to_perform_an_action_error));
                strOfErrorMsg = label.tool_to_perform_an_action_error;
            }
         
          return  [SELECT id,name,Premier_Partner__c,Enable_as_Partner_Group_Administrator__c,Enable_User_for_MyRewards__c,Allow_RFP_and_Proposal_Express_Tool__c,
                                         Allow_Partner_Central_User__c,Allow_Program_Tracker__c,EligibleTracks__c,
                                         Partner_User_Active__c,Partner_User__r.id,Selected_Track__c,Preferred_Track__c,
                                         Is_MDF_User__c,Is_Rebate_User__c,Partner_User_Deal_Registration__c,OSC_Create_Quote__c,OSC_Create_Order__c,OSC_Specialty_Product_Create_Quote__c,OSC_Specialty_Product_Create_Order__c,
                                         Partner_User_Lead_Management__c,Partner_User_Lead_Super_User__c,
                                         Enable_As_Partner_Lead_Super_User__c,Enable_Partner_Lead_Management__c,
                                         Enable_Partner_Deal_Registration__c FROM Contact WHERE id IN: listOfRecToSave];
    }
    
    public void partnerTracksAddRemoveAction(){
        Boolean blnToCheckRemove =true;
        string strOfErrorMsg ='';
        Boolean bInSelectedTrack =false;
        Boolean bInPreferredTrack =false;
        List<String> listOfGroupAdminContactIds = new List<String>();
        List<Contact> listOfContactEligibleTracksToUpdate = new List<Contact>();// PT contact list to update
        List<Contact> listOfContactsToUpdate = allActionLogic();//genaric contact list to update for all action with validations
        List<String> listOfEligibleTrackIds;
       
        //system.debug('listOfContactsToUpdate!!!'+listOfContactsToUpdate);
        list<String> listOfEgTrckConName = new List<String>();// to display error names of contact if single
        
        for(contact conRec : listOfContactsToUpdate){
            listOfEligibleTrackIds = new List<String>();
            //system.debug('in for conRec!!!'+conRec.EligibleTracks__c);
            list<String> listOfEgTrackToUpdate= new List<String>();
            
            if(String.isNotBlank(conRec.EligibleTracks__c)){ 
                system.debug('contains value:'+conRec.EligibleTracks__c);
                if(String.ValueOf(conRec.EligibleTracks__c).contains(';')){
                    listOfEligibleTrackIds = conRec.EligibleTracks__c.split(';'); 
                    listOfEgTrackToUpdate.addAll(listOfEligibleTrackIds);
                    
                }
                else{
                    listOfEgTrackToUpdate.add(conRec.EligibleTracks__c);
                }
            }
            system.debug('414!!!'+listOfEgTrackToUpdate);
            //system.debug('listOfEgTrckConName!!!'+listOfEgTrckConName);
            String strOfEligibleTracks = '';
          if(strOfActionOptions == label.Remove_selected_users_from_Tracks && conRec.Partner_User_Active__c == true && listOfEgTrackToUpdate.size()==1){ //listOfEgTrackToUpdate.size() < 1 &&
              system.debug('in remove 1&&&&');
             for(String strOfComparePT : strOfSavePtnrTrackCheckForAction.split(',')){    
                
            if(conRec.EligibleTracks__c.contains(';')){
                system.debug('in contains&&&&');
             
              if(conRec.EligibleTracks__c.split(';').contains(strOfComparePT)){ 
                system.debug('in if name&&&&');
              listOfEgTrckConName.add(conRec.name);
             }
           }
              else if(conRec.EligibleTracks__c.contains(strOfComparePT)){
                system.debug('in else name&&&&');
               listOfEgTrckConName.add(conRec.name);
              }
            }
          }
          else if(String.ValueOf(strOfSavePtnrTrackCheckForAction).contains(',')){
              
               for(String strOfComparePT : strOfSavePtnrTrackCheckForAction.split(',')){
                    system.debug('496!!!'+strOfComparePT);
                    if(!listOfEgTrackToUpdate.isEmpty()){
                        //if selected PT is not contains in with contact EgTracks check, strOfComparePT is a selecetd value of logged in user
                        // listOfEgTrackToUpdate is contact EgTracks
                        If(strOfActionOptions == label.Add_selected_users_to_Tracks){
                            If(!listOfEgTrackToUpdate.contains(strOfComparePT)){
                                system.debug('In side Add check');
                                system.debug('before add !!! contactS'+conRec.EligibleTracks__c);
                                if(String.isBlank(strOfEligibleTracks)){
                                    strOfEligibleTracks = conRec.EligibleTracks__c;
                                    system.debug('if 452 !!!'+strOfEligibleTracks);
                                    system.debug('if 452 strOfComparePT !!!'+strOfComparePT);
                                    strOfEligibleTracks += ';' + strOfComparePT;
                                    system.debug('if 454 !!!'+strOfEligibleTracks);
                                }
                                else{
                                    strOfEligibleTracks += ';' + strOfComparePT;
                                    system.debug('else add !!!'+strOfEligibleTracks);
                                }
                            }
                        }
                              
                        else if(strOfActionOptions ==label.Remove_selected_users_from_Tracks){
                              
                               system.debug('520 !!!'+strOfComparePT);
                               system.debug('listOfEgTrackToUpdate!!!size'+listOfEgTrackToUpdate.size()+'listOfEgTrackToUpdate!!!'+listOfEgTrackToUpdate);
                            if(listOfEgTrackToUpdate.contains(strOfComparePT)){
                                 system.debug('520 !!!'+strOfEligibleTracks);
                                //if(true){
                                    //system.debug('listOfEgTrackToUpdate!!!'+listOfEgTrackToUpdate);
                                    system.debug('strOfComparePT!!!after435'+strOfComparePT);
                                    if(String.isBlank(strOfEligibleTracks)){
                                    strOfEligibleTracks = conRec.EligibleTracks__c;
                                    system.debug('before remove if block !!!437'+strOfEligibleTracks); 
                                    }
                                    if(strOfEligibleTracks.contains(';')){
                                      String strOfLastId = strOfEligibleTracks.substringAfterLast(';');
                                      system.debug('strOfLastId !!!'+strOfLastId);
                                       system.debug('strOfComparePT!!!'+strOfComparePT);
                                        if(strOfLastId == strOfComparePT){
                                             strOfComparePT = strOfComparePT;
                                             system.debug('strOfComparePT in if!!!'+strOfComparePT);
                                        }else{
                                   
                                        strOfComparePT = strOfComparePT + ';'; 
                                        system.debug('strOfComparePT in else!!!'+strOfComparePT);
                                        }  
                                    }
                                      //selected and pref logic starts here
                                    system.debug('in Selected_Track__c$$$$ ISSS before'+conRec.Selected_Track__c);
                                    if(String.isNotBlank(conRec.Selected_Track__c)){
                                        if(strOfEligibleTracks.contains(conRec.Selected_Track__c)){
                                            system.debug('in Selected_Track__c innn');
                                            bInSelectedTrack = true;
                                        }else{
                                            bInSelectedTrack = false;
                                        }
                                    }
                                    
                                   system.debug('in Preferred_Track__c$$$$ ISSS before'+conRec.Preferred_Track__c);
                                    if(String.isNotBlank(conRec.Preferred_Track__c)){
                                        if(strOfEligibleTracks.contains(conRec.Preferred_Track__c)){
                                            system.debug('in Preferred_Track__c innn');
                                            bInPreferredTrack = true;
                                        }else{
                                            bInPreferredTrack = false;
                                        }
                                    }
                                    //ends here
                                    
                                   if(listOfEgTrackToUpdate.size() > 1){
                                        strOfEligibleTracks = strOfEligibleTracks.remove(strOfComparePT);
                                      
                                     system.debug('after remove if block !!!'+strOfEligibleTracks); 
                                   
                                }
                                else{
                                    if(strOfEligibleTracks.contains(';')){
                                        String strOfLastId = strOfEligibleTracks.substringAfterLast(';');
                                        if(strOfLastId == strOfComparePT){
                                             strOfComparePT = strOfComparePT;
                                        }else{
                                   
                                        strOfComparePT = strOfComparePT + ';'; 
                                        }  
                                        
                                    }
                                    if(listOfEgTrackToUpdate.size() > 1){
                                        system.debug('!!!strOfComparePT size'+strOfComparePT);
                                        strOfEligibleTracks = strOfEligibleTracks.remove(strOfComparePT);
                                    }
                                }
                                    if(String.isNotBlank(conRec.Selected_Track__c)){
                                        if(strOfEligibleTracks.contains(conRec.Selected_Track__c)){
                                            system.debug('in Selected_Track__c innn');
                                            bInSelectedTrack = true;
                                        }else{
                                            bInSelectedTrack = false;
                                        }
                                    }
                                    
                                   system.debug('in Preferred_Track__c$$$$ ISSS before'+conRec.Preferred_Track__c);
                                    if(String.isNotBlank(conRec.Preferred_Track__c)){
                                        if(strOfEligibleTracks.contains(conRec.Preferred_Track__c)){
                                            system.debug('in Preferred_Track__c innn');
                                            bInPreferredTrack = true;
                                        }else{
                                            bInPreferredTrack = false;
                                        }
                                    }
                           // }
                        }
                    }
                    
                }
             }
             
            system.debug('strOfEligibleTracks!!!'+strOfEligibleTracks);
            system.debug('in Selected_Track__c$$$$ ISSS 484'+conRec.Selected_Track__c);
            system.debug('in Preferred_Track__c$$$$ ISSS 485'+conRec.Preferred_Track__c);
            if(String.isNotBlank(strOfEligibleTracks)){
                conRec.EligibleTracks__c = strOfEligibleTracks.removeEnd(';');
                if(! bInSelectedTrack){
                    string[] listOfStrings = conRec.EligibleTracks__c.split(';');
                    system.debug('in Selected_Track__c str'+listOfStrings [0]);
                    conRec.Selected_Track__c = listOfStrings[0];
                    system.debug('in Selected_Track__c$$$$ ISSS after'+conRec.Selected_Track__c);
                }
                if(! bInPreferredTrack){
                    string[] listOfStrings = conRec.EligibleTracks__c.split(';');
                     system.debug('in Preferred_Track__c str'+listOfStrings[0]);
                    conRec.Preferred_Track__c = listOfStrings[0];
                     system.debug('in Preferred_Track__c$$$$ ISSS after'+conRec.Preferred_Track__c); 
                    
                }
            }else{
            if(strOfActionOptions == label.Remove_selected_users_from_Tracks){
              blnToCheckRemove = false;
              }
            }
          
            
            if(conRec.Partner_User_Active__c == false){
                bContactInactiveError = true;
                bContactSelError = false;
                bContactSelSuccess = false;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,label.Inactive_contact_selected_error));
                strOfErrorMsg = label.Inactive_contact_selected_error;
            }
            system.debug(conRec.EligibleTracks__c+'!!!!!!!!'+strOfEligibleTracks);
            if(strOfActionOptions == label.Add_selected_users_to_Tracks){//conRec.EligibleTracks__c != strOfEligibleTracks && 
               // system.debug('In IF ADD !!!'+conRec);
                listOfContactEligibleTracksToUpdate.add(conRec);
            }
            //system.debug('conRec.EligibleTracks__c::'+conRec.EligibleTracks__c);
            //system.debug('strOfEligibleTracks::'+strOfEligibleTracks);
            else if(strOfActionOptions == label.Remove_selected_users_from_Tracks){//conRec.EligibleTracks__c != strOfEligibleTracks &&
               // system.debug('in side strOfActionOptions to update');
               // system.debug('conRec.EligibleTracks__c***'+conRec.EligibleTracks__c);
                system.debug('in Selected_Track__c$$$$ ISSS 514'+conRec.Selected_Track__c);
                system.debug('in Preferred_Track__c$$$$ ISSS 515'+conRec.Preferred_Track__c);
                listOfContactEligibleTracksToUpdate.add(conRec);
                if(conRec.Enable_as_Partner_Group_Administrator__c){
                    listOfGroupAdminContactIds.add(conRec.Id);
                }
            }
        } 
        
        } 
        if(strOfActionOptions == label.Remove_selected_users_from_Tracks && listOfEgTrckConName.size() > 0){
            //system.debug('conRec.EligibleTracks__c***'+listOfEgTrckConName);
             string strAllString = string.join(listOfEgTrckConName,',');
            bContactSelError = true;
            bContactSelSuccess = false;
            bContactInactiveError = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,label.Track_is_mandatory_error + '\n'+strAllString));
            
        }
        system.debug('listOfContactEligibleTracksToUpdate b4 try'+listOfContactEligibleTracksToUpdate.size());
        try {
            // Make the update call.
            if(String.isNotBlank(strOfSaveContactId) && String.isNotBlank(strOfSavePtnrTrackCheckForAction) && strOfErrorMsg =='' && listOfContactEligibleTracksToUpdate.size() > 0 && strOfActionOptions == label.Add_selected_users_to_Tracks && listOfContactEligibleTracksToUpdate[0].Partner_User_Active__c == true){
                update listOfContactEligibleTracksToUpdate;
                bContactSelSuccess = true;
              system.debug('listOfContactEligibleTracksToUpdate@@@'+listOfContactEligibleTracksToUpdate);
            }
            
            if(String.isNotBlank(strOfSaveContactId) && String.isNotBlank(strOfSavePtnrTrackCheckForAction) && strOfErrorMsg =='' && listOfContactEligibleTracksToUpdate.size() > 0 && strOfActionOptions == label.Remove_selected_users_from_Tracks && listOfContactEligibleTracksToUpdate[0].Partner_User_Active__c == true){
               // System.debug('In side remove###'+strOfActionOptions);
                 system.debug('listOfContactEligibleTracksToUpdate^^^^'+listOfContactEligibleTracksToUpdate);
                update listOfContactEligibleTracksToUpdate;
                bContactSelSuccess = true;
            }
            if(bContactSelSuccess){
              
                bContactSelError = false;
                bContactInactiveError = false;
                bsuccess = false;
                 system.debug('blnToCheckRemove^^^^'+blnToCheckRemove);
                if(blnToCheckRemove){
                    
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, label.Changes_saved_successfully));
                bsuccess = true; 
                testdata = 'test';
                system.debug('>>>>bsuccess::'+bsuccess+'>>>>>>>testdata:'+testdata);
                }else{
                 system.debug('blnToCheckRemove^^^^in else'+blnToCheckRemove);
                  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,label.Track_is_mandatory_error));
               }
                contactSetup();
                system.debug('>>>>bsuccess1::'+bsuccess+'>>>>>>>testdata:1'+testdata);
                 
            }
            list<User> listUsersToUpdate=new list<User>();
            for(User u:[select id,Enable_as_Partner_Group_Administrator__c  from User where ContactId IN : listOfGroupAdminContactIds]){
                u.Enable_as_Partner_Group_Administrator__c =false;
              //  u.Enable_Partner_Admin__c=true;
                listUsersToUpdate.add(u);
            }
            UpdateContactCtrl.updateUser(JSON.serialize(listUsersToUpdate));
        }
        catch(DmlException e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
        
    }
      
   public void toolAccessAddRemoveAction(){
         boolean blnIsUpdate=false;
         String strOfErrorMsg = '';
      
        List<Contact> listOfContactsToUpdateSend =new List<Contact>();// tool access contact list to update 
        List<Contact> listOfContactsToUpdate =  allActionLogic();//genaric contact list to update for all action with validations 
       List<Id> listOfConUserIds = new List<Id>();// user id list to update   
        
        for(Contact conRecTA : listOfContactsToUpdate){
             system.debug('conRecTA.Partner_User__r.id!!!'+conRecTA.Partner_User__r.id);
             if(strOfSaveToolAccessForAction.contains(',')){
                     for(String strOfCompareTA : strOfSaveToolAccessForAction.split(',')){
                    //system.debug('in compareTA@@@@ with API Name'+compareTA);
                   
                  if(strOfActionOptions == label.Provide_Tools_Access_to_selected_users){
                      
                    if(strOfCompareTA.contains('Premier_Partner__c') && conRecTA.Premier_Partner__c == false ){
                        blnIsUpdate=true;
                        conRecTA.Premier_Partner__c = true;
                    }
                    if(strOfCompareTA.contains('Enable_User_for_MyRewards__c') && conRecTA.Enable_User_for_MyRewards__c == false){
                        blnIsUpdate=true;
                        conRecTA.Enable_User_for_MyRewards__c = true;
                    } 
                    if(strOfCompareTA.contains('Allow_RFP_and_Proposal_Express_Tool__c') && conRecTA.Allow_RFP_and_Proposal_Express_Tool__c == false){
                        blnIsUpdate=true;
                        conRecTA.Allow_RFP_and_Proposal_Express_Tool__c = true;
                    }
                    if(strOfCompareTA.contains('Allow_Partner_Central_User__c') && conRecTA.Allow_Partner_Central_User__c == false){
                        blnIsUpdate=true;
                        conRecTA.Allow_Partner_Central_User__c = true;
                    }
                    if(strOfCompareTA.contains('Allow_Program_Tracker__c') && conRecTA.Allow_Program_Tracker__c == false){
                        blnIsUpdate=true;
                        conRecTA.Allow_Program_Tracker__c = true;
                    }
                    if(strOfCompareTA.contains('Is_MDF_User__c') && conRecTA.Is_MDF_User__c == false){
                          blnIsUpdate=true;
                          conRecTA.Is_MDF_User__c = true;
                      }
                      if(strOfCompareTA.contains('Is_Rebate_User__c') && conRecTA.Is_Rebate_User__c == false){
                          blnIsUpdate=true;
                          conRecTA.Is_Rebate_User__c = true;
                     }
                     if(strOfCompareTA.contains('Partner_User_Deal_Registration__c') && conRecTA.Partner_User_Deal_Registration__c  == false){
                       //system.debug('in side deal if@@@'); 
                        blnIsUpdate=true;
                        conRecTA.Enable_Partner_Deal_Registration__c = true;
                    } 
                    if(strOfCompareTA.contains('Partner_User_Lead_Management__c') && conRecTA.Partner_User_Lead_Management__c == false){
                        blnIsUpdate=true;
                        if(conRecTA.Partner_User_Deal_Registration__c== true){
                           conRecTA.Enable_Partner_Lead_Management__c = true;
                        }else{
                           conRecTA.Enable_Partner_Deal_Registration__c = true; 
                           conRecTA.Enable_Partner_Lead_Management__c = true;
                        }
                    } 
                    if(strOfCompareTA.contains('Partner_User_Lead_Super_User__c') && conRecTA.Partner_User_Lead_Super_User__c == false){
                        blnIsUpdate=true;
                        if(conRecTA.Partner_User_Deal_Registration__c== true && conRecTA.Partner_User_Lead_Management__c== true){
                            conRecTA.Enable_As_Partner_Lead_Super_User__c = true;
                        }else{
                            conRecTA.Enable_Partner_Deal_Registration__c = true; 
                            conRecTA.Enable_Partner_Lead_Management__c = true;
                            conRecTA.Enable_As_Partner_Lead_Super_User__c = true;
                        }
                    }
                    
                   }else{
                       system.debug('in remove!!! contact');
                       if(strOfCompareTA.contains('Premier_Partner__c') && conRecTA.Premier_Partner__c == true){
                        blnIsUpdate=true;
                        conRecTA.Premier_Partner__c = false;
                       }
                       if(strOfCompareTA.contains('Enable_User_for_MyRewards__c') && conRecTA.Enable_User_for_MyRewards__c == true){
                        blnIsUpdate=true;
                        conRecTA.Enable_User_for_MyRewards__c = false;
                       } 
                       if(strOfCompareTA.contains('Allow_RFP_and_Proposal_Express_Tool__c') && conRecTA.Allow_RFP_and_Proposal_Express_Tool__c == true){
                           blnIsUpdate=true;
                           conRecTA.Allow_RFP_and_Proposal_Express_Tool__c = false;
                       }
                       if(strOfCompareTA.contains('Allow_Partner_Central_User__c') && conRecTA.Allow_Partner_Central_User__c == true){
                           blnIsUpdate=true;
                           conRecTA.Allow_Partner_Central_User__c = false;
                       }
                       if(strOfCompareTA.contains('Allow_Program_Tracker__c') && conRecTA.Allow_Program_Tracker__c == true){
                           blnIsUpdate=true;
                           conRecTA.Allow_Program_Tracker__c = false;
                       }
                      if(strOfCompareTA.contains('Is_MDF_User__c') && conRecTA.Is_MDF_User__c == true){
                          blnIsUpdate=true;
                          conRecTA.Is_MDF_User__c = false;
                      }
                      if(strOfCompareTA.contains('Is_Rebate_User__c') && conRecTA.Is_Rebate_User__c == true){
                          blnIsUpdate=true;
                          conRecTA.Is_Rebate_User__c = false;
                     }
                      if(strOfCompareTA.contains('Partner_User_Deal_Registration__c') && conRecTA.Partner_User_Deal_Registration__c == true){
                            blnIsUpdate=true;
                          if(conRecTA.Partner_User_Deal_Registration__c == true || conRecTA.Partner_User_Lead_Super_User__c== true){
                            conRecTA.Enable_Partner_Deal_Registration__c = false;
                            conRecTA.Enable_Partner_Lead_Management__c = false; 
                            conRecTA.Enable_As_Partner_Lead_Super_User__c = false;
                          }else{
                            conRecTA.Enable_Partner_Deal_Registration__c = false;  
                          }
                        }
                        if(strOfCompareTA.contains('Partner_User_Lead_Management__c') && conRecTA.Partner_User_Lead_Management__c == true){
                            blnIsUpdate=true;
                            if(conRecTA.Partner_User_Lead_Super_User__c== false){
                                conRecTA.Enable_Partner_Lead_Management__c = false;
                            }else{
                                conRecTA.Enable_As_Partner_Lead_Super_User__c = false; 
                                conRecTA.Enable_Partner_Lead_Management__c = false;
                            }
                        }
                        if(strOfCompareTA.contains('Partner_User_Lead_Super_User__c') && conRecTA.Partner_User_Lead_Super_User__c == true){
                            blnIsUpdate=true;
                            conRecTA.Enable_As_Partner_Lead_Super_User__c = false;
                        }
                       
                   }
               }
            
           if(conRecTA.Partner_User_Active__c == false){
                    bContactInactiveError = true;
                    bContactSelError = false;
                    bContactSelSuccess = false;
                   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,label.Inactive_contact_selected_error));
                    strOfErrorMsg = label.Inactive_contact_selected_error;
              }
            
            if(String.isNotBlank(strOfSaveToolAccessForAction)){
                if(conRecTA.Partner_User__r.id != null){
                    listOfConUserIds.add(conRecTA.Partner_User__r.id);
                   // system.debug('in conRecTA!!!'+conRecTA);
                    system.debug('in listOfConUserIds!!!'+listOfConUserIds.size());
                }
            }
            } 
             if(blnIsUpdate){
               if(strOfActionOptions == label.Provide_Tools_Access_to_selected_users){
                listOfContactsToUpdateSend.add(conRecTA); 
               }
                system.debug('Added list in IF'+listOfContactsToUpdateSend.size());
            }
            
            if(blnIsUpdate){
                 if(strOfActionOptions == label.Remove_Tools_Access_to_selected_users){
                 listOfContactsToUpdateSend.add(conRecTA); 
                 system.debug('Added list in else'+listOfContactsToUpdateSend.size());
                 }
            } 
            
        }
       
        system.debug('listOfConUserIds!!!'+listOfConUserIds);
       
       list<User> listOfUsersToUpdateToolAcc = new list<User>();// tool access user list to update
       list<User>  listOfUsersToUpdateTA = [SELECT Id,Enable_Partner_Deal_Registration__c,Enable_Partner_Lead_Management__c,Enable_As_Partner_Lead_Super_User__c,OSC_Create_Quote__c,OSC_Create_Order__c,OSC_Specialty_Product_Create_Quote__c,OSC_Specialty_Product_Create_Order__c,
                                             contact.Partner_User_Active__c FROM User WHERE Id IN: listOfConUserIds];
       
        for(User usr : listOfUsersToUpdateTA){
            system.debug('usr!!!'+usr);
           if(strOfSaveToolAccessForAction.contains(',')){
                for(String strOfCompareTA : strOfSaveToolAccessForAction.split(',')){
                       system.debug('strOfCompareTA!!!'+strOfCompareTA);
                  if(strOfActionOptions == label.Provide_Tools_Access_to_selected_users){
                    if(strOfCompareTA.contains('Partner_User_Deal_Registration__c') && usr.Enable_Partner_Deal_Registration__c == false){
                       //system.debug('in side deal if@@@'); 
                        blnIsUpdate=true;
                        usr.Enable_Partner_Deal_Registration__c = true;
                    } 
                    if(strOfCompareTA.contains('Partner_User_Lead_Management__c') && usr.Enable_Partner_Lead_Management__c == false){
                        blnIsUpdate=true;
                        if(usr.Enable_Partner_Deal_Registration__c == true){
                           usr.Enable_Partner_Lead_Management__c = true;
                        }else{
                           usr.Enable_Partner_Deal_Registration__c = true; 
                           usr.Enable_Partner_Lead_Management__c = true;
                        }
                    } 
                    if(strOfCompareTA.contains('Partner_User_Lead_Super_User__c') && usr.Enable_As_Partner_Lead_Super_User__c == false){
                        blnIsUpdate=true;
                        if(usr.Enable_Partner_Deal_Registration__c == true && usr.Enable_Partner_Lead_Management__c == true){
                            usr.Enable_As_Partner_Lead_Super_User__c = true;
                        }else{
                            usr.Enable_Partner_Deal_Registration__c = true; 
                            usr.Enable_Partner_Lead_Management__c = true;
                            usr.Enable_As_Partner_Lead_Super_User__c = true;
                        }
                    }
                    //Added as part of 6335018 [SFDC] ISG Enablement: Channel 2 Tier: Retrofit Manage User Partner Admin Search filters for create quote/order
                    if(strOfCompareTA.contains('OSC_Create_Quote__c') && usr.OSC_Create_Quote__c ==false ){
                        blnIsUpdate=true;   
                        usr.OSC_Create_Quote__c =true;
                    } 
                    if(strOfCompareTA.contains('OSC_Create_Order__c') && usr.OSC_Create_Order__c ==false){
                         blnIsUpdate=true;
                         usr.OSC_Create_Order__c =true;
                         usr.OSC_Create_Quote__c =true;
                         
                    }
                    if(strOfCompareTA.contains('OSC_Specialty_Product_Create_Quote__c') && usr.OSC_Specialty_Product_Create_Quote__c ==false ){
                       blnIsUpdate=true;    
                       usr.OSC_Specialty_Product_Create_Quote__c =true;
                    } 
                    if(strOfCompareTA.contains('OSC_Specialty_Product_Create_Order__c') && usr.OSC_Specialty_Product_Create_Order__c ==false){
                         blnIsUpdate=true;
                         usr.OSC_Specialty_Product_Create_Order__c =true;
                         usr.OSC_Specialty_Product_Create_Quote__c =true;
                         
                    }
                  }else{
                       system.debug('in remove user!!!');
                        if(strOfCompareTA.contains('Partner_User_Deal_Registration__c') && usr.Enable_Partner_Deal_Registration__c == true){
                            blnIsUpdate=true;
                          if(usr.Enable_Partner_Lead_Management__c == true || usr.Enable_As_Partner_Lead_Super_User__c == true){
                            usr.Enable_Partner_Deal_Registration__c = false;
                            usr.Enable_Partner_Lead_Management__c = false; 
                            usr.Enable_As_Partner_Lead_Super_User__c = false;
                          }else{
                            usr.Enable_Partner_Deal_Registration__c = false;  
                          }
                        }
                        if(strOfCompareTA.contains('Partner_User_Lead_Management__c') && usr.Enable_Partner_Lead_Management__c == true){
                            blnIsUpdate=true;
                            if(usr.Enable_As_Partner_Lead_Super_User__c == false){
                                usr.Enable_Partner_Lead_Management__c = false;
                            }else{
                                usr.Enable_As_Partner_Lead_Super_User__c = false; 
                                usr.Enable_Partner_Lead_Management__c = false;
                            }
                        }
                        if(strOfCompareTA.contains('Partner_User_Lead_Super_User__c') && usr.Enable_As_Partner_Lead_Super_User__c == true){
                            blnIsUpdate=true;
                            usr.Enable_As_Partner_Lead_Super_User__c = false;
                        }
                        //Added as part of 6335018 [SFDC] ISG Enablement: Channel 2 Tier: Retrofit Manage User Partner Admin Search filters for create quote/order
                        if(strOfCompareTA.contains('OSC_Create_Quote__c') && usr.OSC_Create_Quote__c ==true ){
                           blnIsUpdate=true;
                           if(usr.OSC_Create_Order__c ==false){
                             usr.OSC_Create_Quote__c =false;
                           }else{
                             usr.OSC_Create_Quote__c =false;
                             usr.OSC_Create_Order__c =false;
                           }    
                           
                        } 
                       if(strOfCompareTA.contains('OSC_Create_Order__c') && usr.OSC_Create_Order__c ==true){
                          blnIsUpdate=true;
                          usr.OSC_Create_Order__c =false;
                        
                      }
                    if(strOfCompareTA.contains('OSC_Specialty_Product_Create_Quote__c') && usr.OSC_Specialty_Product_Create_Quote__c ==true ){
                        blnIsUpdate=true;   
                        if(usr.OSC_Specialty_Product_Create_Order__c ==false){
                          usr.OSC_Specialty_Product_Create_Quote__c =false;
                        }else{
                           usr.OSC_Specialty_Product_Create_Quote__c =false;
                           usr.OSC_Specialty_Product_Create_Order__c =false;
                        }
                       
                    } 
                    if(strOfCompareTA.contains('OSC_Specialty_Product_Create_Order__c') && usr.OSC_Specialty_Product_Create_Order__c ==true){
                         blnIsUpdate=true;
                         usr.OSC_Specialty_Product_Create_Order__c =false;
                    }
                   }
               }  
           }
            
            if(blnIsUpdate){
               if(strOfActionOptions == label.Provide_Tools_Access_to_selected_users){
                listOfUsersToUpdateToolAcc.add(usr);
                system.debug('listOfUsersToUpdateToolAcc in add!!!'+listOfUsersToUpdateToolAcc.size()); 
               }
            }
            
            if(blnIsUpdate){
                 if(strOfActionOptions == label.Remove_Tools_Access_to_selected_users){
                 listOfUsersToUpdateToolAcc.add(usr);
                system.debug('listOfUsersToUpdateToolAcc in remove!!!'+listOfUsersToUpdateToolAcc.size()); 
                 }
            } 
           
        }
       try {
            //system.debug('strOfSaveContactId!!'+strOfSaveContactId+'strOfErrorMsg!!'+strOfErrorMsg+'listOfUsersToUpdateToolAcc.size()'+listOfUsersToUpdateToolAcc.size()+'listOfUsersToUpdateToolAcc[0].contact.Partner_User_Active__c:'+listOfUsersToUpdateToolAcc[0].contact.Partner_User_Active__c+':'+strOfSaveToolAccessForAction);
           if(String.isNotBlank(strOfSaveContactId) && strOfErrorMsg =='' && listOfUsersToUpdateToolAcc.size() > 0 && String.isNotBlank(strOfSaveToolAccessForAction) && listOfUsersToUpdateToolAcc[0].contact.Partner_User_Active__c == true){
               //TriggerExecutionController.setSkipUserTriggers(true);
               
               // Raymond 20100224 - Added for CR2420. Set to true so that contact trigger will not sync to CMI
               GlobalVariables.BYPASS_PARTNER_PROFILE_INTEGRATION = true;
              update listOfUsersToUpdateToolAcc;
               //TriggerExecutionController.setSkipUserTriggers(false);
               bContactSelSuccess = true;
              system.debug('Update Successfully user'+listOfUsersToUpdateToolAcc.size());
           } 
          
          /* if(bContactSelSuccess){
               bContactSelError = false;
               bContactInactiveError = false;
               ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, label.Changes_saved_successfully));
               ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, label.Tools_Access_Update_Message));
               contactSetup(); 
           }*/
              
       }  
       catch (System.DMLException e) {
           ApexPages.addMessages(e);
       }
       try{
           system.debug('listOfContactsToUpdateSend!!!'+listOfContactsToUpdateSend.size());
           if(listOfContactsToUpdateSend!=null && listOfContactsToUpdateSend.size()>0 && listOfUsersToUpdateToolAcc.size()>0){
               system.debug('UpdateContactCtrl!!!');
               UpdateContactCtrl.updateContactToolAccess(JSON.serialize(listOfContactsToUpdateSend)); 
           }
           else if(listOfContactsToUpdateSend!=null && listOfContactsToUpdateSend.size()>0 && listOfUsersToUpdateToolAcc.isEmpty()){
               update listOfContactsToUpdateSend;
               bContactSelSuccess = true;
           }  
       }
       catch (System.DMLException e) {
           ApexPages.addMessages(e);
       }
       
       if(bContactSelSuccess){
           bContactSelError = false;
           bContactInactiveError = false;
           bsuccess = true;
           system.debug('>>>>bsuccess 1186::'+bsuccess);
           ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, label.Changes_saved_successfully));
           ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, label.Tools_Access_Update_Message));
           contactSetup(); 
           
       }
            
   }
    
    //Export selected contacts
    public PageReference exportAction(){
        strOfConIDToExport = Apexpages.currentPage().getParameters().get('conIDExport');//Selected contact id to update
        system.debug('in strOfConIDToExport^^^^'+strOfConIDToExport);
        
        if(String.isBlank(strOfConIDToExport)){
            bContactSelError = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, label.No_Contact_Selected_Error));
            //strOfErrorMsg = label.No_Contact_Selected_Error;
        }  
        
        strOfLoginId = loggedInUser.id;
        //system.debug('in loggedInUser^^^^'+loggedInUser);
        PageReference redir;
       if(String.isNotBlank(strOfConIDToExport)){
            redir = new PageReference('/apex/ManageUsersExport?selectedConIDToExport='+strOfConIDToExport+'&loggedInUsr='+strOfLoginId);
        }
        strtoPassData =strFinalQuery ; 
        Cookie cook = new Cookie('value', strtoPassData, null, -1, false);
        redir .setCookies(new Cookie[] {cook}); 
        return redir;
    }
    
    //ExportAll selected contacts
    public PageReference exportActionAll(){
         String strOfAllConIds;
        strOfLoginId = loggedInUser.id;
        system.debug('mapconWarp_______'+listOfMapConWrap.size());
        // system.debug('mapconWarp_______'+listOfMapConWrap.get(0).con.id);
        for(Integer intI=0; intI<listOfMapConWrap.size(); intI++){
             strOfAllConIds += listOfMapConWrap[intI].con.id+',';
           strOfConIDToExport =  strOfAllConIds.removeStart('null');
         }
        system.debug('strOfConIDToExport-----'+strOfConIDToExport);
       PageReference redir;
        if(String.isNotBlank(strOfConIDToExport)){
           // redir = new PageReference('/apex/ManageUsersExport?selectedConIDToExport='+strOfConIDToExport+'&loggedInUsr='+strOfLoginId);
           // redir = new PageReference('/apex/ManageUsersExport?selectedConIDToExport='+strOfConIDToExport+'&loggedInUsr='+strOfLoginId+'&strOfContactquery='+strWhereClause);
            redir = new PageReference('/apex/ManageUsersExport?loggedInUsr='+strOfLoginId);
        }
        strtoPassData =strFinalQuery ; 
        Cookie cook = new Cookie('value', strtoPassData, null, -1, false);
        redir .setCookies(new Cookie[] {cook}); 
        return redir;
        
    }
    
    
    public void saveAction(){ 
        if(strOfActionOptions == label.Provide_Tools_Access_to_selected_users || strOfActionOptions == label.Remove_Tools_Access_to_selected_users){
            toolAccessAddRemoveAction();
        }
        else if(strOfActionOptions == label.Add_selected_users_to_Tracks || strOfActionOptions == label.Remove_selected_users_from_Tracks){
            partnerTracksAddRemoveAction(); 
        }else{
            system.debug('In else');
        }
    }    

    
    //Cancel to reset the Action values
    public void cancel(){
        strOfActionOptions ='';
    }
    // This method is to create New Contact 
    public PageReference newContact(){
        PageReference redir = new PageReference('/apex/PartnerAdminsCreateContact?'+'retURL='+Page.ManageUsers.getUrl()+'&cancelURL='+ Page.ManageUsers.getUrl()+'&newFlag=true');
        redir.setRedirect(true);
        return redir;
    }
    // This method is to edit Existing Contact
    public PageReference editContact(){
        //By Sneha
        Contact con = [Select id,name,Partner_User__c  from Contact where id=: strOfContactId];
        //System.debug('Partner_User__c : ' +con.Partner_User__c);
        PageReference redir = new PageReference('/apex/PartnerAdminsCreateContact?'+'retURL='+Page.ManageUsers.getUrl()+'&cancelURL='+ Page.ManageUsers.getUrl()+'&newFlag=false'+'&userId='+con.Partner_User__c);
        redir.setRedirect(true);
        return redir;
    } 
    
    public List<selectOption> getPartnerTrackAdmin() {
        List<selectOption> listOfOptions = new List<selectOption>(); 
        listOfOptions.add(new selectOption('', label.none_for_drop_down)); 
        listOfOptions.add(new selectOption('True', label.yes));
        listOfOptions.add(new selectOption('False', label.no)); 
        
        return listOfOptions; //return the picklist listOfOptions
    } 
    
    public List<selectOption> getContactStatus() {
        List<selectOption> listOfOptions = new List<selectOption>(); 
        listOfOptions.add(new selectOption('', label.none_for_drop_down));
        listOfOptions.add(new selectOption('All', label.All_for_drop_down)); 
        listOfOptions.add(new selectOption('True', label.Active));
        listOfOptions.add(new selectOption('False', label.Inactive)); 
        return listOfOptions; //return the picklist listOfOptions
    } 
    
    public List<selectOption> getPartnerTracks() {
        List<String> listOfTracks = new List<String>();
        List<selectOption> listOfOptions = new List<selectOption>();
        //listOfOptions.add(new selectOption('', label.none_for_drop_down)); 
       
            // system.debug('###loggedInUser>'+loggedInUser.contact.EligibleTracks__c);
            if(loggedInUser.contact.EligibleTracks__c != null){
                String strOfEgTrack = loggedInUser.contact.EligibleTracks__c;
                String  strOfEgTrackToDel = strOfEgTrack.deleteWhitespace();
                list<String> listOfAllEgTracks  = strOfEgTrackToDel.split(';');
                //system.debug('listOfAllEgTracks   '+listOfAllEgTracks  );
                listOfTracks.addAll(listOfAllEgTracks);
            }
        
        //system.debug('###listOfTracks '+listOfTracks);
        if(!listOfTracks.isEmpty()){
      for(Partner_Track__c addtrack : [SELECT Id,Track_Name__c,Track_Id__c FROM Partner_Track__c WHERE Id IN: listOfTracks ORDER BY Track_Name__c ASC NULLS LAST]) { 
           if(addtrack.Track_Name__c != null && addtrack.Track_Name__c != ''){
                listOfOptions.add(new selectOption(addtrack.Id,addtrack.Track_Name__c)); //for all records found - add them to the picklist listOfOptions
           }
         }
        }
        return listOfOptions; //return the picklist listOfOptions
    }
    
    public List<selectOption> getToolAccess() {
        List<selectOption> listOfOptions = new List<selectOption>();
       
       // listOfOptions.add(new selectOption('', label.none_for_drop_down)); 
        if(loggedInUser != null){
            if(loggedInUser.Enable_Partner_Deal_Registration__c == True){
                listOfOptions.add(new selectOption('Partner_User_Deal_Registration__c', label.Deal_Registration));
                listOfLoggedinUserToolAccess.add(label.Deal_Registration);
            }
            if(loggedInUser.Enable_Partner_Lead_Management__c == True && loggedInUser.Enable_Partner_Deal_Registration__c == True){
                listOfOptions.add(new selectOption('Partner_User_Lead_Management__c', label.Lead_Management));
                listOfLoggedinUserToolAccess.add(label.Lead_Management);
            }
            if(loggedInUser.Enable_As_Partner_Lead_Super_User__c == True && loggedInUser.Enable_Partner_Deal_Registration__c == True && loggedInUser.Enable_Partner_Lead_Management__c == True ){
                listOfOptions.add(new selectOption('Partner_User_Lead_Super_User__c', label.Lead_Super_User));
                listOfLoggedinUserToolAccess.add(label.Lead_Super_User);
            } 
            if(loggedInUser.contact.Is_MDF_User__c == True){
                 listOfOptions.add(new selectOption('Is_MDF_User__c', label.MDF));
                listOfLoggedinUserToolAccess.add(label.MDF);
             }
            if(loggedInUser.contact.Enable_User_for_MyRewards__c == True){
                listOfOptions.add(new selectOption('Enable_User_for_MyRewards__c', label.MyRewards));
                listOfLoggedinUserToolAccess.add(label.MyRewards);
            } 
            if(loggedInUser.contact.Allow_Partner_Central_User__c == True){
                listOfOptions.add(new selectOption('Allow_Partner_Central_User__c', label.Partner_Central));
                listOfLoggedinUserToolAccess.add(label.Partner_Central);
            } 
            if(loggedInUser.contact.Premier_Partner__c == True){
                listOfOptions.add(new selectOption('Premier_Partner__c', label.Premier));
                listOfLoggedinUserToolAccess.add(label.Premier);
            } 
            if(loggedInUser.contact.Allow_Program_Tracker__c == True){
                listOfOptions.add(new selectOption('Allow_Program_Tracker__c', label.Program_Tracker));
                listOfLoggedinUserToolAccess.add(label.Program_Tracker);
            }
            if(loggedInUser.contact.Is_Rebate_User__c == True){
                 listOfOptions.add(new selectOption('Is_Rebate_User__c', label.Rebates));
                 listOfLoggedinUserToolAccess.add(label.Rebates);
             }   
            if(loggedInUser.contact.Allow_RFP_and_Proposal_Express_Tool__c== True){
                listOfOptions.add(new selectOption('Allow_RFP_and_Proposal_Express_Tool__c', label.RFP_Proposal_Express_Tool));
                listOfLoggedinUserToolAccess.add(label.RFP_Proposal_Express_Tool);
            } 
            //Added as part of 6335018 [SFDC] ISG Enablement: Channel 2 Tier: Retrofit Manage User Partner Admin Search filters for create quote/order
            if(loggedInUser.OSC_Create_Quote__c == True){
                listOfOptions.add(new selectOption('OSC_Create_Quote__c', label.OSC_Create_Quote));
                listOfLoggedinUserToolAccess.add(label.OSC_Create_Quote);
            }
            if(loggedInUser.OSC_Create_Order__c == True){
                listOfOptions.add(new selectOption('OSC_Create_Order__c', label.OSC_Create_Order));
                listOfLoggedinUserToolAccess.add(label.OSC_Create_Order);
            }
            if(loggedInUser.OSC_Specialty_Product_Create_Quote__c == True){
                listOfOptions.add(new selectOption('OSC_Specialty_Product_Create_Quote__c', label.OSC_SP_Create_Quote));
                listOfLoggedinUserToolAccess.add(label.OSC_SP_Create_Quote);
            }
            if(loggedInUser.OSC_Specialty_Product_Create_Order__c == True){
                listOfOptions.add(new selectOption('OSC_Specialty_Product_Create_Order__c', label.OSC_SP_Create_Order));
                listOfLoggedinUserToolAccess.add(label.OSC_SP_Create_Order);
            } 
         }     
        return listOfOptions; //return the picklist listOfOptions
    }
    
    //Pallavi
    public List<SelectOption> getActions(){
        List<SelectOption> listOfOptions = new List<SelectOption>();
        listOfOptions.add(new selectOption('', label.none_for_drop_down));     
        listOfOptions.add(new SelectOption(label.Provide_Tools_Access_to_selected_users, label.Provide_Tools_Access_to_selected_users));
        listOfOptions.add(new SelectOption(label.Remove_Tools_Access_to_selected_users, label.Remove_Tools_Access_to_selected_users));
        listOfOptions.add(new SelectOption(label.Add_selected_users_to_Tracks,label.Add_selected_users_to_Tracks));
        listOfOptions.add(new SelectOption(label.Remove_selected_users_from_Tracks, label.Remove_selected_users_from_Tracks));
        listOfOptions.add(new selectOption(label.Export_Selected_users, label.Export_Selected_users));
        listOfOptions.add(new selectOption(label.Export_All_users, label.Export_All_users));
        listOfOptions.sort();
        return listOfOptions;
    }
    
     // Raymond 20100224 - Added for CR2420. This is now the "second" step to inactivate a user.
    // After the user clicks the OK button to confirm inactivation, the method createInactivateUserPartnerRequest()
    // will create a PR and assign to inactivationRequest. Refer to Page for more info.
    public PageReference doConfirmActivateOrInactivateUser() {
        try{
            system.debug('doConfirmActivateOrInactivateUser'+confirmActivateOrInactivateUser.isActive);
            // Raymond 20100224 - Added for CR2420. Set to true so that afterInactivatedUser.trigger will not create PR
            GlobalVariables.BYPASS_REMOVE_USER_RERQUEST_CREATION = true; 
            
            // Raymond 20100224 - Added for CR2420. Set to true so that contact trigger will not sync to CMI
            GlobalVariables.BYPASS_PARTNER_PROFILE_INTEGRATION = true;
            
            if(confirmActivateOrInactivateUser.isActive){
                confirmActivateOrInactivateUser.IsActive = false; 
            }
            else{
                confirmActivateOrInactivateUser.IsActive = true; 
            }
                update confirmActivateOrInactivateUser;
                
                //Varsha 5680698 - Updating contact status
                //Updating contact using future call, to avoid Mixed DML Exception
                /*Contact inactivateContact = [SELECT Id, Status__c FROM Contact WHERE Id =: confirmActivateOrInactivateUser.ContactId];
                inactivateContact.Status__c = 'Invalid - No Longer w/Company';
                update inactivateContact;*/
            
            //This is for activate user - Deferred for 0402 release
            /*else{
                system.debug('Else:'+confirmActivateOrInactivateUser.isActive);
                confirmActivateOrInactivateUser.IsActive = true;   
                update confirmActivateOrInactivateUser;
                
                //Varsha 5680698 - Updating contact status
                Contact activateContact = [SELECT Id, Status__c FROM Contact WHERE Id =: confirmActivateOrInactivateUser.ContactId];
                activateContact.Status__c = 'Customer';
                update activateContact;
            }*/
            
        }
        catch(Exception e) { 
            ApexPages.addMessages(e);
        }
        System.debug('inactivationRequest'+inactivationRequest);
        // Raymond 20100224 - Added for CR2420.Synchronize to CMI
        if(inactivationRequest != null) {
            UpdateContactCtrl.updateContactStatus(confirmActivateOrInactivateUser.ContactId);
            synchronizeToCMI(confirmActivateOrInactivateUser.Id, inactivationRequest.Id);
        }
        confirmActivateOrInactivateUser = null;
        if(!Test.isRunningTest()){
        getContactStatus();
        contactSetup();
        }
        return null;
    }
    
    public PageReference doCancelActivateOrInactivateUser() {
        confirmActivateOrInactivateUser = null;
        return null;
    }
    
    // Raymond 20100224 - Added for CR2420. OK Button from Confirm Inactivation page will call this method first
    public PageReference createInactivateUserPartnerRequest() {
        system.debug('createInactivateUserPartnerRequest'+confirmActivateOrInactivateUser.isActive);
        final Id REMOVE_USER_RECORD_TYPE = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_REMOVE_USER, 'Partner_Request__c', true);
        final Id Update_USER_RECORD_TYPE = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_UPDATE_USER, 'Partner_Request__c', true);
        list<Country__c> listOfQueueIds = [SELECT Code__c, Partner_Support_Queue_ID__c 
                                           FROM Country__c 
                                           WHERE Code__c = :confirmActivateOrInactivateUser.Contact.Account.Account_Country_Code__c];
        try{
            Partner_Request__c request = new Partner_Request__c();
            request.Account__c = confirmActivateOrInactivateUser.Contact.AccountId;
            request.Contact__c = confirmActivateOrInactivateUser.ContactId;
            request.Status__c = PartnerConstants.REG_STATUS_DRAFT;
            request.Email__c = confirmActivateOrInactivateUser.Contact.Email;
            if(listOfQueueIds.size() > 0) {
                request.OwnerId = listOfQueueIds[0].Partner_Support_Queue_ID__c; 
            }
            if(confirmActivateOrInactivateUser.isActive){
                request.RecordTypeId = REMOVE_USER_RECORD_TYPE;
            }
            else{
                request.RecordTypeId = Update_USER_RECORD_TYPE;
            }
            
            insert request;
            System.debug('##requestid:' + request.Id);
            inactivationRequest = request;
        }       
        catch(Exception e) {
                ApexPages.addMessages(e);
            }  
        return null;
    }
    
    // Raymond 20100224 - Added for CR2420. This method will synchronize to CMI and update PR with status
    @future(callout=true)
    public static void synchronizeToCMI(String struserId, String strrequestId) {
        String strOfErrorMsg = '';
        
        User targetUser = [SELECT Id, ContactId, IsActive, Contact.Partner_My_Account_GUID__c FROM User WHERE Id = :struserId];
        
        Partner_Request__c request = [SELECT Id, Status__c, Description__c FROM Partner_Request__c WHERE Id = :strrequestId];     
        /*
         * Commented as part of Story #7169839
        if(targetUser != null && targetUser.isActive) {
            return;
        }
        */
        try {
            //Partner_Request__c inactivateRequest = createInactivateUserPartnerRequest(confirmInactivateUser); 
            //request = [SELECT Id, Status__c, Description__c FROM Partner_Request__c WHERE Id = :strrequestId];
             PartnerPortalProfilingserviceIntegration.integratePartnerDataWithContact(targetUser.contactId);
             CPDBXmlGenerator.getContactDataforCPDB(targetUser.contactId);  
             if(!targetUser.IsActive){
                 String strOfResponse = PartnerProfileIntegration.sendContactInfo(targetUser.contactId, targetUser.Id, !targetUser.IsActive);
               // String strOfResponse = PartnerProfileIntegration.integratePartnerDataWithResponse(targetUser.contactId);
                // [Krishna 10-May-2010]Updated to handle Nullpointer exception
                System.debug('strOfResponse'+strOfResponse);
                strOfResponse = StringUtils.defaultString(strOfResponse);
                if(strOfResponse.contains(GlobalVariables.CMI_RESPONSE_SUCCESSFUL)) {
                    // 14.2 SSO Update
                    //request.Status__c = PartnerConstants.REG_STATUS_COMPLETE;
                }
                else {
                request.Status__c = PartnerConstants.REG_STATUS_INCOMPLETE;             
                strOfErrorMsg = 'Integration with CMI falied. Please contact your System Administrator.';
            }
            }
        }
        catch(Exception e) {
            request.Status__c = PartnerConstants.REG_STATUS_INCOMPLETE;
            strOfErrorMsg = 'Integration with CMI/CPDB/Profiling falied.';         
        }
        
        try {
            if(strOfErrorMsg != '' && request.status__c == PartnerConstants.REG_STATUS_INCOMPLETE) {
                if(request.Description__c == '') {
                    request.Description__c = strOfErrorMsg;
                }
                else {
                    request.Description__c += '\n' + strOfErrorMsg;  
                }               
            }
            
            update request;
        }
        catch(Exception e) {
            System.debug('##Caught APEX exception ' + e.getMessage());
            emailUtils.sendSupportEmail('PartnerSelfServiceAutoUpdateUserError: while updating Partner Request ' + request.Id + ': ' + e.getMessage(), dellConfig.errorEmail);   
        }
    }
    
    //Add by varsha
    public PageReference doActivateOrInactivateUser() {
        String struserId = PageUtils.param(HTTP_PARAMETER_USERID);
        System.debug('userid*****'+HTTP_PARAMETER_USERID);
        System.debug('userid*****'+PageUtils.param(HTTP_PARAMETER_USERID));
        System.debug('userid*****'+struserId);
        //Varsha 5680698 - Added Contact.Status in query
        list<User> listOfUsers = [select Id, Name, IsActive, ContactId, Contact.Email, Contact.AccountId, Contact.Account.Account_Country_Code__c,Contact.Status__c from User where Id = :struserId];
        if(!listOfUsers.isEmpty()) {
            confirmActivateOrInactivateUser = listOfUsers.get(0);
        }
         system.debug('createInactivateUserPartnerRequest'+confirmActivateOrInactivateUser);
        return null;
    }
    
    //  Wrapper class
    public class contactWrapper{
        public Contact con {get; set;}       
        public Map<String,string> mapOfFieldsStrWarp {get; set;}
        public Boolean bPtMoreVal{get; set;}
        public Boolean bAtMoreVal{get;set;}
        
        // Contructor method 
        public contactWrapper(Contact Cont, Map<String,string> mapOfFieldsStrWarp, Boolean bPtMoreVal, Boolean bAtMoreVal) {
            this.con = Cont;
            this.mapOfFieldsStrWarp= mapOfFieldsStrWarp;
            this.bPtMoreVal = bPtMoreVal;
            this.bAtMoreVal= bAtMoreVal;
        }
    }
}