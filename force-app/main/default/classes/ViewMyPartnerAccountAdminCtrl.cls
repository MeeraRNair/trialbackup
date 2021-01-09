/*
* Controller logic for search functionality on pratner track
* 
* Get logged in users account partner tracks
* Based on user selection from partner track drop down, 
* display all contacts under master group account on selection of track
* 
* 
* Story     CR Number   Release No      Date            Created By    Modify By     Description
* --------  ---------   ----------      -----------     -----------   ---------     -----------
* #5780924              FY20-0402       08-Nov-2018     Varsha                      Search functionality on partner track
* #5901640              FY20-0402       21-Jan-2019                   Varsha                             
*/
public without sharing class ViewMyPartnerAccountAdminCtrl {
    
    public user loggedInUser {get;set;}//Getting login user details
    public List<contactWrapper> listConWrap {get; set;}//Contact wrapper list to display contacts in page
    public List<Contact> listAdminCon {get;set;}//Contact list based on master group account
    public List<string> listPartnerIds {get;set;}//Setting partner track ids
    public string strPartnerTrackId {get;set;}//Getting selected value from partner track drop down from page
    public List<String> listEligibleTrackNames {get;set;}//To display all partner tracks of particular contact in tooltip
    public Boolean bNoResults {get;set;}//To display error message for no record found
    public Id masterAccountRecordTypeId;//Getting masteraccountrecordtype and assigned
    
    //Constructor: Getting contacts list to display on load
    public ViewMyPartnerAccountAdminCtrl(){
        bNoResults = false;
        listConWrap = new List<contactWrapper>();
        listAdminCon = new List<Contact>();
        loggedInUser = [SELECT Id,contact.accountId FROM User WHERE Id =: UserInfo.getUserId()];//UserInfo.getUserId()
        getContacts();
    }
    
    //This method is used to prepare partner tracks under user mastergroup account and display in page as drop down
    public List<selectOption> getPartnerTracks() {
        system.debug('accountid:'+loggedInUser.Contact.AccountId);
        List<selectOption> listTrackOptions = new List<selectOption>(); 
        listTrackOptions.add(new selectOption('', Label.Select));        
        if(loggedInUser.Contact.AccountId != null){
            List<Partner_Track__c> listTrack = new List<Partner_Track__c>();
            listTrack = [SELECT Id,Partner_Track_Name__c,Master_Group_Id__c,Track_Name__c FROM Partner_Track__c WHERE Master_Group_Id__c =: loggedInUser.Contact.AccountId];
            system.debug('listTrackrecords:'+listTrack);
            for (Partner_Track__c addtrack : listTrack) { 
                if(String.isNotBlank(addtrack.Track_Name__c)){
                    listTrackOptions.add(new selectOption(addtrack.Id, addtrack.Track_Name__c)); //for all records found - add them to the picklist listTrackOptions
                }
            }
        }
        system.debug('partner tracks:'+listTrackOptions);
        return listTrackOptions; //return the picklist listTrackOptions
    }
    
    //This method is used to display alladmincontacts with partner tracks
    public void getContacts(){
        bNoResults = false;
        listConWrap.clear();
        if(loggedInUser != null){
            system.debug('accountID'+loggedInUser.contact.accountId);
            masterAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Master_Account_Record_Type_Name).getRecordTypeId();
            if(masterAccountRecordTypeId != null){
                listAdminCon =  [SELECT id,AccountId,Name,FirstName,LastName,Email,Phone,EligibleTracks__c,Enable_as_Partner_Group_Administrator__c,Partner_User_Partner_Admin__c,Account.RecordTypeId,Account_Active_Contact__c,
                                Partner_User__c,Account_Inactive_Contact__c,Partner_User_Active__c,Partner_User__r.Email,Partner_User__r.Phone FROM Contact WHERE AccountId =: loggedInUser.contact.accountId AND
                                Account.RecordTypeId =: masterAccountRecordTypeId  AND Partner_User_Active__c = true AND (Enable_as_Partner_Group_Administrator__c = true OR Partner_User_Partner_Admin__c = true) Limit 1000];
            }
        }
        
        Map<Id, String> mapContTrackNames = new Map<Id, String>();
        List<String> listEligibleTracksId = new List<String>();
        //TODO:Remove
        system.debug('listAdminCon'+listAdminCon);
        //Listing EligibletrackIds of admin contacts
        for(Contact con: listAdminCon){
            List<String> listConEligibleTracksId = new List<String>();
            if(con.EligibleTracks__c != null){
                if(String.ValueOf(con.EligibleTracks__c).contains(';')){
                    listConEligibleTracksId = con.EligibleTracks__c.split(';');
                    //TODO:Remove
                    system.debug('listEligibleTracksId '+listConEligibleTracksId);
                    for(String strEgTrackId: listConEligibleTracksId){
                        listEligibleTracksId.add(strEgTrackId);  
                    } 
                }
                else{
                    listEligibleTracksId.add(con.EligibleTracks__c);
                }
            }        
        }
        //Getting strPartnerTrackNames in map with eligibletrackids
        for(Partner_Track__c partnerTrack : [SELECT Id,Partner_Track_Name__c,Track_Name__c FROM Partner_Track__c WHERE Id IN: listEligibleTracksId]){
            if(String.isNotBlank(partnerTrack.Track_Name__c)){
                mapContTrackNames.put(partnerTrack.id, partnerTrack.Track_Name__c);
            }
            //TODO:Remove
            system.debug('ContactTrackNames'+mapContTrackNames);
        }
        
        Partner_Track__c partnerTrackObj;//Getting partnertrack record of selected value
        if(String.isNotEmpty(strPartnerTrackId)){
            partnerTrackObj = [SELECT Id,Partner_Track_Name__c FROM Partner_Track__c WHERE Id =: strPartnerTrackId];
        }
        //TODO:Remove
        system.debug('partnerTrackObj'+partnerTrackObj);
        for(Contact con: listAdminCon){
            listPartnerIds = new List<string>();
            String strPartnerTrackNames = '';//Based on eligibletrackids fetching tracknames from map
            String strPartnerTrackIds = '';//Adding strPartnerTrackIds to prepare wrapper list
            listEligibleTrackNames = new List<String>();
            String strEligibleTrackNamesWithNextLine = '';//Adding partnertrack values with next line
            String strEligibleTrackNamesInTooltip = '';//Adding partnertrack values to display in tooltip
            List<String> listEgTrackIds = new List<String>();
            if(con.EligibleTracks__c != null){
                if(String.ValueOf(con.EligibleTracks__c).contains(';')){
                    listEgTrackIds = con.EligibleTracks__c.split(';');
                }
                else{
                    listEgTrackIds.add(con.EligibleTracks__c);
                }
                for(String strTrackId: listEgTrackIds){
                    strPartnerTrackNames += mapContTrackNames.get(strTrackId)+',';
                    system.debug('trackNames****'+strPartnerTrackNames);
                    listPartnerIds.add(strTrackId);
                    listEligibleTrackNames = strPartnerTrackNames.Split(',');
                    strEligibleTrackNamesWithNextLine += mapContTrackNames.get(strTrackId)+',';
                }
                //TODO:Remove
                system.debug('strEligibleTrackNamesWithNextLine:'+strEligibleTrackNamesWithNextLine);
            }
            //TODO:Remove
            system.debug('listPartnerIds****'+listPartnerIds);
            String strFinalPartnerTrackNames = '';
            //Setting partnertrack names to display in column and tooltip
            if(listEligibleTrackNames!=null){
                for(Integer intI=0; intI<listEligibleTrackNames.size(); intI++){
                    if(intI<3){
                        strFinalPartnerTrackNames += listEligibleTrackNames[intI]+',';
                        if(listEligibleTrackNames.size() > 3){
                            strEligibleTrackNamesInTooltip = strEligibleTrackNamesWithNextLine;
                            //TODO:Remove
                            system.debug('strEligibleTrackNamesInTooltip'+strEligibleTrackNamesInTooltip);
                        }
                        //TODO:Remove
                        system.debug('strFinalPartnerTrackNames'+strFinalPartnerTrackNames);
                    }
                }
            }
            //Based on partner track selection adding contact and tracknames in wrapper list to display in page
            //If none selected adding all admin contacts with partner tracks
            if(partnerTrackObj != null){
                if(listPartnerIds.contains(partnerTrackObj.id)){
                    listConWrap.add(new contactWrapper(con, strFinalPartnerTrackNames.removeEnd(','), strEligibleTrackNamesInTooltip.replace(',','<br/>')));
                }
            }
            else{
                listConWrap.add(new contactWrapper(con, strFinalPartnerTrackNames.removeEnd(','), strEligibleTrackNamesInTooltip.replace(',','<br/>')));
            }
            //TODO:Remove
            system.debug('finaleligibleTrackNamesInTooltip:'+strEligibleTrackNamesInTooltip);
            system.debug('finaladmincontactlist:'+listConWrap);
        }
        if(listConWrap.isEmpty()){
            bNoResults = true;
        }
    }
    
    //  Wrapper class
    public class contactWrapper{
        public Contact con {get; set;} 
        public String strConPartnerTrackNames {get; set;}
        public String strConPartnerTrackToolTip {get;set;}
        
        // Contructor method 
        public contactWrapper(Contact cont, String strConPartnerTrackNames, String strConPartnerTrackToolTip) {
            this.con = cont;
            this.strConPartnerTrackNames = strConPartnerTrackNames;
            this.strConPartnerTrackToolTip = strConPartnerTrackToolTip;
        }
    }
}