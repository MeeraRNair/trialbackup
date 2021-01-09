/***************************************************************************************************************************************************************
* 
* Name          : Vfcntrl_SalesmotionSelection
* Description   : controller class to support vfpage "Sales_motion_account_selection_vfp" 
* ---------------------------------------------------------------------------------------
* Revision     Name            Date                 CR                                            Description
* 1.0         Mahesh        01.08.2019                                          Added logic to fetch sales motion account under selected partner track.
* 2.0      Mahesh    02.01.2019                      Added logic for OSC changes
***************************************************************************************************************************************************************/

public without sharing class Vfcntrl_SalesmotionSelection {
    public List<Account> listacc {get; set;}
    public Map<id,string> mapaccIdToName{get;set;}
    public Map<id,string> mapaccIdToSponsoringDist{get;set;}
    public String strselectSMId {get; set;}   
    public boolean bhasError{get;set;}
    map<id,string> mapIdtoCountry;
    String strrecId;
    Id dealRegRTId;
    Id dealWithECusRTId;
    String stringToAppend;
    Set<Id> setrecordType;
    boolean bisOSCDeal;
    ID salesmotionId;
    string strOSCSolutionID;
    
    
    public Vfcntrl_SalesmotionSelection(ApexPages.StandardController controller) {
        bhasError = false;
        PageReference pr = ApexPages.currentPage();
        Map<String, String> mapparams = pr.getParameters();
        bisOSCDeal = false;
        system.debug('***mapparams' +mapparams.keySet());
        
        dealRegRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
        dealWithECusRTId = IdLookupUtils.getRecordTypeId('Deal Registration for Existing End Customer', 'Opportunity', true);
        setrecordType=new Set<Id>{dealRegRTId, dealWithECusRTId};
            //retain the URL parameters:
            //get all the parameter and store to stringToAppend
            for(String strkey : mapparams.keySet()){
                if(strkey != 'core.apexpages.devmode.url' &&
                   strkey != 'sfdc.override' &&
                   strkey != 'save_new' &&
                   strkey != 'scontrolCaching'){
                       if(stringToAppend != ''){
                           stringToAppend += '&';
                       }  
                       stringToAppend += strkey + '=' + mapparams.get(strkey);
                       
                       if(strkey == 'OSCId' && mapparams.get(strkey) != null && mapparams.get(strkey) != ''){
                           strOSCSolutionID = mapparams.get(strkey);
                           bisOSCDeal = true;
                       }
                   }
            } 
        strrecId = mapparams.get('RecordType');  
        
        system.debug('*****strrecId' +strrecId);
    }
    
    public pagereference updateSelectedAccToCon(){
        System.debug('salesMotionName'+strselectSMId);
        string strURL;
        try{
            User loggedInUser = [select Id,Contact.Id from user where id = : UserInfo.getUserId()];
            contact con = new contact();
            con.id = loggedInUser.Contact.Id;
            con.Selected_Track_Account__c = strselectSMId;
            TriggerExecutionController.setSkipAllTriggers(true);
            update con;
            TriggerExecutionController.setSkipAllTriggers(false); 
            checkAndAddAccShare(strselectSMId);
            updateUserCurrency(mapIdtoCountry.get(strselectSMId));
            
            if(bisOSCDeal == true){
                strURL= '/apex/OpportunityRedirectPage?retURL=%2F006%2Fo&RecordType='+strrecId+'&ent=Opportunity&00NA00000063WWk=' +strOSCSolutionID;
                
            }else{
                strURL= '/apex/channelOpportunityOveride?'+stringToAppend+'&nooverride=1';
            }             
            pagereference page = new pagereference(strURL);
            page.setRedirect(TRUE);
            return page; 
        }catch(exception ex){
            bhasError = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Exception Occurred'));
            system.debug('Exception occured in updateSelectedAccToCon Method:' +ex.getMessage());
        }
        
        return null;       
    }
    
    public pagereference checkAndRedirect(){
        bhasError = false;
        listacc = new list<Account>();
        mapaccIdToName = new map<id,string>();
        mapaccIdToSponsoringDist = new map<id,string>();
        mapIdtoCountry = new map<id,string>();
        string strURL;
        try{
            User loggedInUser = [select Id,Contact.AccountId,Contact.Selected_Track__c from user where id = : UserInfo.getUserId()];
            if(setrecordType.contains(strrecId.subString(0,15))){               
                listacc = [Select Id,Name,Partner_Description__c,owner.name,NameLocal,partner_track__r.Name,Master_Group_Id__c,Master_Group_Id__r.Name,Account_ID__c,
                           Account_Country__c,(Select Id,Distributor_Account_Name_text__c,Reseller_Account__c from DistributorRelationships__r) 
                           from Account where Master_Group_Id__c =:loggedInUser.Contact.AccountId and partner_track__c =:loggedInUser.Contact.Selected_Track__c 
                           and Calculated_Status__c =  'Active' and Sales_Motion_Deal_Registration__c = true limit 1000]; 
                for(Account accRecord : listacc){
                    mapIdtoCountry.put(accRecord.id,accRecord.Account_Country__c);
                    mapaccIdToName.put(accRecord.id,accRecord.Master_Group_Id__r.Name);
                    if(accRecord.DistributorRelationships__r.size() > 0 && accRecord.DistributorRelationships__r[0].Distributor_Account_Name_text__c != null ){
                        mapaccIdToSponsoringDist.put(accRecord.id,accRecord.DistributorRelationships__r[0].Distributor_Account_Name_text__c);
                    }else{
                        mapaccIdToSponsoringDist.put(accRecord.id,'');  
                    }
                }if(listacc.size() == 0){
                    bhasError = true;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, System.Label.No_Salesmotions_Found));
                    return null;
                }else if(listacc.size() == 1){                
                    contact con = new contact();
                    con.id = loggedInUser.Contact.Id;
                    con.Selected_Track_Account__c = listacc[0].Id;
                    TriggerExecutionController.setSkipAllTriggers(true);
                    update con;
                    TriggerExecutionController.setSkipAllTriggers(false); 
                    checkAndAddAccShare(listacc[0].Id);
                    updateUserCurrency(listacc[0].Account_Country__c);
                    if(bisOSCDeal == true){
                        strURL= '/apex/OpportunityRedirectPage?retURL=%2F006%2Fo&RecordType='+strrecId+'&ent=Opportunity&00NA00000063WWk=' +strOSCSolutionID;
                        
                    }else{
                        strURL= '/apex/channelOpportunityOveride?'+stringToAppend+'&nooverride=1';
                    }                     
                }else{
                    return null;
                }
            }else{
                strURL= '/apex/OpportunityRedirectPage?'+stringToAppend+'&nooverride=1';  
            }
            pagereference page = new pagereference(strURL);
            page.setRedirect(true); 
            return page;
        }catch(exception ex){
            bhasError = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Exception Occurred'));
            system.debug('Exception occured in checkAndRedirect Method:' +ex.getMessage());
        }
        return null;
    }
    
    public static void checkAndAddAccShare(String straccId){
        /*  Integer intaccShareCount = [select count() from AccountShare where UserOrGroupId = : userinfo.getUserId() and AccountId = :straccId];
if (intaccShareCount == 0){
AccountShare accShare = new AccountShare();
accShare.AccountId = straccId;
accShare.UserOrGroupId = userinfo.getUserId();
accShare.AccountAccessLevel = 'Read';
accShare.OpportunityAccessLevel = 'None';
accShare.CaseAccessLevel = 'None';
insert accShare;
}  */
        
        PartnerOnBoardingUtilitycntrl ut=new PartnerOnBoardingUtilitycntrl();  
        List<AccountShare> listaccshareupdate=ut.chkandaddshare(straccId);      
        if(!listaccshareupdate.isempty()){
            insert listaccshareupdate;
        }
    }
    
    @future
    public static void updateUserCurrency(String strCountry){
        if(strCountry != null && strCountry != ''){
            list<Deal_Registration__mdt> listCurrencyMetadata = new list<Deal_Registration__mdt>();
            try{
                listCurrencyMetadata = [select Country__c,Currency__c from Deal_Registration__mdt where Country__c = :strCountry limit 1]; 
                if(listCurrencyMetadata.size() > 0 && listCurrencyMetadata[0].Currency__c != null){
                    user usrToUpdate = new user();
                    usrToUpdate.id = userinfo.getUserId();
                    usrToUpdate.CurrencyIsoCode = listCurrencyMetadata[0].Currency__c;
                    usrToUpdate.DefaultCurrencyIsoCode = listCurrencyMetadata[0].Currency__c;
                    
                    TriggerExecutionController.setSkipAllTriggers(true);
                    update usrToUpdate;
                    TriggerExecutionController.setSkipAllTriggers(false); 
                }
            }
            catch(exception ex){
                system.debug('Exception occured in updateUserCurrency Method:' +ex.getMessage());
                
            }
        }
    }
}