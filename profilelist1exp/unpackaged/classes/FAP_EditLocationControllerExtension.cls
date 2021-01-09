/*
REVISION HISTORY
================
Version     Author      Date            Release#        CR#     Description
-------     ------      ----            --------        ---     -----------
1.0         Fenny       31-May-2012     13.7            7108    Dell.com look and feel
1.1         Fenny       05-Jun-2012     13.7            7241    Pre-populate Partner Location Country is Account Shipping Country match
1.2         Fenny       13-Jul-2012     13.7                    Initialize boolean properties to prevent NullPointerException
2.0         Kokila      07-Oct-2015     16.10                   User story 192359 - CMS: Update Location Tab
3.0         Madhava     30-Dec-2015     16.12           198183  Add "Date of Profile Update" field in SFDC
4.0         Ashish      08-Jan-2016     16.12           220378  E2E: Unable to add location for partner account in PP.
5.0         Gan         18-Nov-2016     FY17-DCS-0103   13725   Baidu Map Implementation 
*/
public without sharing class FAP_EditLocationControllerExtension extends FAP_PartnerFinderBaseController {

    //======================================================
    // PAGE LOAD ERROR CODES
    //======================================================
    public String errorNoMapAPIKEY { get{ return 'ERROR_NO_MAP_API_KEY'; }}
    public String errorNoAccountId  { get{ return 'ERROR_NO_ACCOUNT_ID' ; }}

    //==================================================
    // PROPERTIES
    //==================================================
    public Boolean                       lookingForLocation     {get;private set;}
    public Boolean                       showConfirmation       {get;private set;}
    public Boolean                       locationFound          {get;private set;}
    public String                        countryCodeHint        {get;private set;}
    public String                        errorCode              {get;private set;}
    public FAP_Configuration                 config                 {get;private set;}
    public List<FAP_FormField>               fields                 {get;private set;}
    public Partner_Location__c           primary                {get;private set;}
    public Partner_Location__c           location               {get;private set;}
    public ID                           idUsedInVFpage         {get; set;}
    //public Partner_Location__c           mainContactlocation               {get;private set;}

    private ApexPages.StandardController controller;
    private PageReference                retURL;
    private PageReference                cancelURL;
    public String                        countryFromUI{get;set;}
    
    public String isPrimary; 
    
    
    public String googleMapsApiURL   { get{return FAP_Configuration.getInstance().googleMapsApiURL;}}
    //5.0 GAN POC
    public String strBaiduMapsApiUrl   { get{return FAP_Configuration.getInstance().baiduMapsApiUrl;}}
    public Boolean isIE{get{return FAP_PageUtils.isIE();}}  // Ver 1.0
    public Boolean isChrome{get {return FAP_PageUtils.isChrome();}} // Ver 1.0
    public Boolean isFirefox{get {return FAP_PageUtils.isFirefox();}} // Ver 1.0
    private Account acct{get;set;}
    private Partner_Track__c partnerTrack{get;set;}

    //public Partner_Location__c ptLocationObj{get;set;}
    //public double latitude{get;set;}
    //public double longitude{get;set;}
    
     
    //==================================================
    // CONSTRUCTOR  
    //==================================================
    public FAP_EditLocationControllerExtension(ApexPages.StandardController controller) {
        // Ver 1.2
        lookingForLocation = false;
        showConfirmation = false;
        locationFound = false;

        this.controller = controller;
       
        if(this.controller.getRecord() != null && this.controller.getRecord() instanceof Partner_Location__c){
            this.location = (Partner_Location__c) this.controller.getRecord();
            
             system.debug('##### this.location'+this.location);
            
        } else {
            this.location = new Partner_Location__c();
      }
    }
    
    public String country {get;set;}

    public void getipaddress(){
        string returnValue= '';  
        returnValue= ApexPages.currentPage().getHeaders().get('True-Client-IP');
        if (returnValue == '' || returnValue == null) {
           returnValue= ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        } 
        if (returnValue== '' || returnValue== null) {
           returnValue= ApexPages.currentPage().getHeaders().get('X-Forwarded-For');
        }
        System.Debug('ReturnValue##'+returnValue);
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        //String endpoint = 'http://freegeoip.net/json/'+ReturnValue;
        //req.setEndpoint('http://ipinfo.io/'+ReturnValue+'/json');
        //String endpoint = https://ipinfo.io/country?token=dell_internal
        String endpoint = 'https://ipinfo.io/'+ReturnValue+'/json?token=dell_internal';
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        HttpResponse res;
        try{
           res = h.send(req);
           Map<string,object> m = (Map<string,object>)JSON.deserializeUntyped(res.getbody());
           System.Debug('m##'+m);
           country =(String)m.get('country');
           system.debug('Naga###ipcountyr :'+country);
        }
        catch(Exception e){
          }
    }
    
    //==================================================
    // ACTIONS
    //==================================================
    public PageReference doOnLoad(){
        //GAN POC
        //this.country = 'CN';
        getipaddress();
        
        //LOAD FIELDS
        this.config = FAP_Configuration.getInstance();
        this.fields = FAP_FormField.build(config.detailScreenLocationFields);
        //QUERY FOR LOCATION RECORD
                       system.debug('Location.country $$$$' +location.id);

        if(this.location.id != null){
            this.location = Database.query(new FAP_SoqlBuilder()
                .selectx(FAP_SearchHit.minimumFields())
                .selectx(FAP_FormField.fieldNames(fields))
               // .selectx('Country__c')
                .fromx('Partner_Location__c')
                .wherex(new FAP_FieldCondition('id',location.id))
                .toSoql());
            FAP_FormField.populateFields(fields,location);
            
            this.isPrimary = (location.Is_Primary__c == true ? 'YES' : 'NO');
            System.debug('this.isPrimary>>>>>>>>>> '+this.isPrimary);
            if(this.isPrimary!=null && this.isPrimary=='NO'){
                this.primary = new Partner_Location__c();
            }
        }
        sObject sb = location.getSobject(FAP_Configuration.keyValueWithoutDot);
system.debug('Debug sobject 190 line number $$$$$$'+sb);
        String lookupValueAccOrPT=string.valueOf(location.get(FAP_Configuration.strObjectAPIName));
        this.idUsedInVFpage = lookupValueAccOrPT;

           
        
        this.retURL = FAP_StringUtils.isBlank(FAP_PageUtils.param('retURL')) ? FAP_PageUtils.redirect('/'+lookupValueAccOrPT) : FAP_PageUtils.redirect(FAP_PageUtils.param('retURL')+'?returnTab=Locations');  //v2.0 Updated with returnTab
        this.cancelURL = FAP_StringUtils.isBlank(FAP_PageUtils.param('cancelURL')) ? FAP_PageUtils.redirect('/'+lookupValueAccOrPT) : FAP_PageUtils.redirect(FAP_PageUtils.param('cancelURL')+'?returnTab=Locations'); //v2.0 Updated with returnTab
  //this.retURL = FAP_PageUtils.redirect('/'+lookupValueAccOrPT);
 //this.cancelURL = FAP_PageUtils.redirect('/'+lookupValueAccOrPT);
        this.showConfirmation = false;
        
        if(FAP_StringUtils.isBlank(config.googleMapsApiKey)){
            return error(errorNoMapAPIKEY);
        }

        ID partnerAccountOrPTId = getPartnerAccountOrPTrackID();
        system.debug('partnerAccountId @@@@'+partnerAccountOrPTId);
        if(partnerAccountOrPTId == null){
            if(lookupValueAccOrPT == null){
               return error(errorNoAccountId);
               
            }
        } else {
          // location.Account__c = partnerAccountOrPTId;
            
          location.put(FAP_Configuration.strObjectAPIName,partnerAccountOrPTId);
        }
                        String objectrec=string.valueof(location.get(FAP_Configuration.strObjectAPIName));
        //this.retURL = FAP_PageUtils.redirect('/'+partnerAccountOrPTId);
        //this.cancelURL = FAP_PageUtils.redirect('/'+partnerAccountOrPTId);       
        this.retURL = FAP_StringUtils.isBlank(FAP_PageUtils.param('retURL')) ? FAP_PageUtils.redirect('/'+lookupValueAccOrPT) : FAP_PageUtils.redirect(FAP_PageUtils.param('retURL')+'?returnTab=Locations');  //v2.0 Updated with returnTab
        this.cancelURL = FAP_StringUtils.isBlank(FAP_PageUtils.param('cancelURL')) ? FAP_PageUtils.redirect('/'+lookupValueAccOrPT) : FAP_PageUtils.redirect(FAP_PageUtils.param('cancelURL')+'?returnTab=Locations'); //v2.0 Updated with returnTab 


        try{          
                        String soqlQuery = '';

            if(this.location.id != null){      
              List<Partner_Location__c> plList= new List<Partner_Location__c>();
              system.debug('##### this.location.Country__c'+this.location.Country__c);
              //v2.0 Start - Updated with list to avoid the exception always
                //       plList = [select id, is_primary__c, Country__c from Partner_Location__c where account__c = :location.Account__c and Is_Primary__c = true and Country__c=:location.Country__c];               
                
                
                string countryy=location.Country__c;
                 objectrec=string.valueof(location.get(FAP_Configuration.strObjectAPIName));
                  soqlQuery = 'select id, is_primary__c, Country__c from Partner_Location__c where ' + FAP_Configuration.strObjectAPIName + '=\'' + objectrec + '\' and Is_Primary__c = true and Country__c=\''+countryy+'\'';
                
                system.debug('soqlQuery @@@@@' + soqlQuery);
                plList = Database.query(soqlQuery);
                if(!plList.isEmpty()){
                 this.primary = plList[0];
              }
                
            }else{
             //   this.primary = [select id, is_primary__c,Country__c from Partner_Location__c where account__c = :location.Account__c and Is_Primary__c = true limit 1];
                 objectrec=string.valueof(location.get(FAP_Configuration.strObjectAPIName));

                soqlQuery = 'select id, is_primary__c,Country__c from Partner_Location__c where ' + FAP_Configuration.strObjectAPIName + '=\'' + objectRec + '\' and Is_Primary__c = true Limit 1';
                this.primary = database.query(soqlQuery);
            
            }
            System.debug('this.primary>>>>>>>>>>>>> '+this.primary);
            if(this.primary != null && this.primary.id == this.location.id){
                this.primary = null;                
            }
            
        }catch(QueryException e){                
            //no primary location exists
            populateFirstLocation(location, id.valueof(objectrec));
       }
        return null;
    }
    public PageReference validationForCountry(){
                  system.debug('$$$$$$$ this.location.Country__c'+this.location.Country__c);
                  countryFromUI=this.location.Country__c;
    return null;

}
    public PageReference doDetailsDone(){
        //v2.0 Start
        
        if (this.isPrimary== 'None'){
                apexpages.addmessage(new apexpages.message(ApexPages.severity.ERROR,Label.Head_Office_Error));
                return null; 
        }//v2.0 End
        this.lookingForLocation = true;
        this.locationFound = false;
        this.countryCodeHint = FAP_StringUtils.mid(FAP_StringUtils.substringAfterLast(location.Country__c, '('),0,2);
        this.showConfirmation = true; 

        return null;
    }
    
    public PageReference handleLocationFound(){
        this.lookingForLocation = false;
        this.locationFound = true;
        return null;
    }
    
    public PageReference handleLocationNotFound(){
        this.lookingForLocation = false;
        this.locationFound = false;
        return null;
    }
    
    public PageReference doConfirmationDone(){
         system.debug('countryFromUI 3 $$$$$$$'+this.location.country__c );
           Set<String> authorizedCountriesSet= new Set<String>();
           List<String> authorizedCountriesList= new List<String>();

        Savepoint sp = null;
        try { 
            sp = Database.setSavepoint();   
            
            //v2.0 Start
            if(this.isPrimary == 'YES'){
                location.Is_Primary__c = true;
            } else if (this.isPrimary == 'NO'){
                location.Is_Primary__c = false;
            }  //v2.0 End
            
          //  List<Partner_Location__c> pList = [select id, is_primary__c,Country__c from Partner_Location__c where account__c = :location.Account__c and Country__c=:location.Country__c and is_primary__c=true];
            List<Partner_Location__c> pList=new  List<Partner_Location__c>();
            string countryy=location.Country__c;
            system.debug('country !!'+countryy);
            String objectrec=string.valueof(location.get(FAP_Configuration.strObjectAPIName));
             String  soqlQuery = 'select id, is_primary__c, Country__c from Partner_Location__c where ' + FAP_Configuration.strObjectAPIName + '=\'' + objectrec + '\' and Is_Primary__c = true and Country__c=\''+countryy+'\'';
       system.debug('soqlQuery!!!'+soqlQuery);
            pList=database.query(soqlQuery);
            for(Partner_Location__c pl : pList){
                if(pl.is_primary__c==true && this.location.Is_Primary__c == true){
                    pl.is_primary__c=false;                     
                }
                
              } 
                   
            //V3.0 : Update date of profile field on account/PartnerTrack when any changes happens on edit location section
            if(FAP_Configuration.keyValue == 'Account__r.'){
            acct=getPartnerAccount();
            }
            else{
                partnerTrack=getPartnerTrack();
                system.debug('PartnerTrack @@@@'+partnerTrack);
                if(partnerTrack!=null && partnerTrack.Authorized_Countries__c!=null && (partnerTrack.Partner_Track__c=='Distributor')){
                    authorizedCountriesList=partnerTrack.Authorized_Countries__c.split(';');
                    authorizedCountriesSet.addAll(authorizedCountriesList);
                }  
            }
                partnerTrack=getPartnerTrack();

            
            String locationCountry=this.location.country__c;
            locationCountry=locationCountry.substring(0,locationCountry.length()-4);
            locationCountry=locationCountry.trim();
            system.debug('locationCountry $$$$$'+locationCountry+'$$$:::'+'authorizedCountriesSet:::'+authorizedCountriesSet);
            system.debug('countryFromUI:::'+countryFromUI);
      
            if(PartnerTrack!=null && (PartnerTrack.Partner_Track__c=='Distributor') && authorizedCountriesSet.size()>0 && !authorizedCountriesSet.contains(locationCountry) ){
                  apexpages.addmessage(new apexpages.message(ApexPages.severity.ERROR,'Please select a country where you are authorized to sell. The selected location can’t be published based on your valid Distribution agreement.'));
                system.debug('Country selected is not Authorized to sell for distributor');
            throw new MyException('Country selected is not Authorized to sell for distributor');
            
            }else{
                
               /* for(Partner_Location__c pl: pList){
                    pl.Country__c=countryFromUI;
            }*/
                system.debug('plist size'+plist.size());
                if(plist.size()>40){
                            FAP_LocationCallouts.isGeoLocationUpdate=false;    

                }
                update plist;
                upsert location;
                system.debug('partnerTrack !!!'+partnerTrack);
                if(acct != null){
                    acct.Date_of_Profile_Update__c=datetime.now();
                    update acct;
                }
                if(partnerTrack!=null){
                    partnerTrack.Date_of_Profile_Update__c=datetime.now();
                    update partnerTrack;
                }
            }

         FAP_FormField.populateSObject(location,fields);   
            
        }catch(Exception e) {
            Database.rollback(sp);
            ApexPages.addMessages(e);
            return null;
        }
        return retURL;
    }
    
    public PageReference doConfirmationPrevious(){
        this.showConfirmation = false;
        return null;
    }   
    
    public PageReference doCancel(){
        return cancelURL;
    }
    
    //==================================================
    // DERIVED PROPERTIES
    //==================================================
    public ID getId(){ return controller == null ? null : controller.getId();}
    public Boolean errorOccurred {get{ return FAP_StringUtils.isNotEmpty(this.errorCode); }}

    //==================================================
    // HELPER METHODS
    //==================================================
    
    public Partner_Track__c getPartnerTrack(){
        try{
        ID partnerAccountOrPTId=getPartnerAccountOrPTrackID();
if(partnerAccountOrPTId==null && location.Partner_Track__c!=null){
                partnerAccountOrPTId=location.Partner_Track__c;
            }
        //Partner_Track__c ptRec=[SELECT ID,Legal_Address_City__c,Authorized_Countries__c,Partner_Track__c FROM Partner_Track__c where id=:this.location.Partner_Track__c limit 1];
       String soql='SELECT ID,Legal_Address_City__c,Legal_Address_Country__c,Legal_Address_Postal_Code__c,Legal_Address_State_Province__c,Legal_Address_Street__c,Partner_Track__c,Authorized_Countries__c FROM Partner_Track__c where id=\'';
            soql+=partnerAccountOrPTId;
            soql+='\''+' limit 1';
            system.debug('soql !!'+soql);
            
            
         Partner_Track__c ptRec=Database.query(soql);   
            if(ptRec!=null){
            return ptRec;
            }
            else{
             return null;
             }
            }
            catch(exception e){
            system.debug('Exception is $$$$'+e);
            return null;
            }
    }
    
    public static Account getPartnerAccount(){
        
        ID partnerAccId=getPartnerAccountID();
        Account acctObj;
        if(partnerAccId !=null){
            //below query changed by ashish for E2E Defect 220378 : Unable to add location for partner account in PP.
            acctObj = [SELECT Id,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry FROM Account WHERE id = :partnerAccId];
        
        }
            
        if(acctObj == null){
            return null;
        }
        return acctObj;
    }
        
    private void populateFirstLocation(Partner_Location__c loc, ID acctId){
        loc.Is_Primary__c = true;
        this.isPrimary = 'YES';
       //v2.0 Added
        if(String.valueof(acctId.getsobjectType())=='Account'){
            
        acct=getPartnerAccount();
        
        if(acct != null){
            
            loc.Street__c = acct.ShippingStreet;
            loc.City__c = acct.ShippingCity;
            loc.State_Province__c = acct.ShippingState;
            loc.Postal_Code__c = acct.ShippingPostalCode;
            
            // Ver 1.1: Get the valid partner location country based on shipping country code
            string shippingCountry = FAP_StringUtils.upperCase(acct.ShippingCountry);
            string country =FAP_CountryUtils.PartnerCountryMap.get(shippingCountry);
            // Ver 1.1: If country code not found in PartnerCountryMap, get country based on shipping country name
            country = FAP_StringUtils.isEmpty(country)?FAP_CountryUtils.PartnerShippingCountryMap.get(shippingCountry):country; 
            // Ver 1.1: If both shipping country code and name not found in PartnerCountryMap and PartnerShippingCountryMap, get country based on full shipping country value
            country = FAP_StringUtils.isEmpty(country)?FAP_CountryUtils.PartnerLocationCountryMap.get(shippingCountry):country; 
            loc.Country__c = FAP_StringUtils.isEmpty(country)?null:country;
            
        }
        }
        
        else{
            partnerTrack=getPartnerTrack();
        
        if(partnerTrack != null){
            
            loc.Street__c = partnerTrack.Legal_Address_Street__c!=null?partnerTrack.Legal_Address_Street__c:'';
            loc.City__c = partnerTrack.Legal_Address_City__c!=null?partnerTrack.Legal_Address_City__c:'';
            loc.State_Province__c = partnerTrack.Legal_Address_State_Province__c!=null?partnerTrack.Legal_Address_State_Province__c:'';
            loc.Postal_Code__c = partnerTrack.Legal_Address_Postal_Code__c!=null?partnerTrack.Legal_Address_Postal_Code__c:'';

            
            // Ver 1.1: Get the valid partner location country based on shipping country code
            string shippingCountry =partnerTrack.Legal_Address_Country__c!=null?FAP_StringUtils.upperCase(partnerTrack.Legal_Address_Country__c):'';
            string country =FAP_CountryUtils.PartnerCountryMap.get(shippingCountry);
            // Ver 1.1: If country code not found in PartnerCountryMap, get country based on shipping country name
            country = FAP_StringUtils.isEmpty(country)?FAP_CountryUtils.PartnerShippingCountryMap.get(shippingCountry):country; 
            // Ver 1.1: If both shipping country code and name not found in PartnerCountryMap and PartnerShippingCountryMap, get country based on full shipping country value
            country = FAP_StringUtils.isEmpty(country)?FAP_CountryUtils.PartnerLocationCountryMap.get(shippingCountry):country; 
            loc.Country__c = FAP_StringUtils.isEmpty(country)?null:country;
            
        }
            
        }
      
    }   
    
    
    public static ID getPartnerAccountOrPTrackID() {
        final List < User > userList = [
            select id, ContactId, Contact.AccountId, Contact.Account.id,Contact.Selected_Track__c, Contact.Account.name, userrole.name
            from user where id =: UserInfo.getUserId()
        ];
        if (userList.isEmpty() ||
            userList.get(0).userrole == null ||
            FAP_StringUtils.isBlank(userList.get(0).userrole.name) ||
            userList.get(0).contact == null ||
            userList.get(0).contact.id == null ||
            ((FAP_Configuration.keyValue=='Account__r.' && userList.get(0).Contact.AccountId == null) ||
            (FAP_Configuration.keyValue=='Partner_Track__r.' && userList.get(0).Contact.Selected_Track__c==null))) {
            return null;
        }
        //return userList.get(0).Contact.AccountId;
        return FAP_Configuration.keyValue=='Account__r.'?userList.get(0).Contact.AccountId:userList.get(0).Contact.Selected_Track__c;
    }
    
    public static ID getPartnerAccountID(){
        final List<User> userList = [
            select id, ContactId, Contact.AccountId, Contact.Account.id, Contact.Account.name,userrole.name 
            from user where id = :UserInfo.getUserId()];
        if( userList.isEmpty()
            || userList.get(0).userrole == null 
            || FAP_StringUtils.isBlank(userList.get(0).userrole.name)
            || userList.get(0).contact == null
            || userList.get(0).contact.id == null
            || userList.get(0).Contact.AccountId == null){
            return null;
        }
        return userList.get(0).Contact.AccountId;
    }

    private PageReference error(String errorCode){
        this.errorCode = errorCode;
        return null;
    }
    
    public List<String> getMessages(){
        List<String> msgList= new List<String>();
        for(ApexPages.Message msg:ApexPages.getMessages()){
            msgList.add(msg.getSummary());
        }
        return msgList;
    }
    
    //v2.0 Start
    public List<SelectOption> getIsPrimaryOptions() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('None',Label.none));
        options.add(new SelectOption('YES',Label.YES_in_Caps)); 
        options.add(new SelectOption('NO',Label.NO_in_Caps)); 
    return options; 
    }
    
    public String getIsPrimary() {
        return isPrimary;
    }

    public void setIsPrimary(String isPrimary) { 
        this.isPrimary = isPrimary; 
    }
    //v2.0 End
}