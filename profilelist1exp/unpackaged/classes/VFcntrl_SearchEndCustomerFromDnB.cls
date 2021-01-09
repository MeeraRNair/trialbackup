/**********************************************************************************************************************************************************
* Name          : VFcntrl_SearchEndCustomerFromDnB
* Description   : Class for retrieving details from D&B and other related activities
* ---------------------------------------------------------
* Revision  Name               Date             Description
* 1.0       Yeswanth        21.july.2016    CR 13328: Building request and capturing the response
* 2.0        Meera          02-Aug-2016     CR 13379: Addition of duplicate check logic  
* 3.0       Yeswanth        04.Aug.2016     CR 13378: Added Logic for end customer contact creation
* 4.0        Meera          24-Aug-2016     CR 13444: CIL1.0->CIL2.0 migration 
* 5.0        Meera          31-Aug-2016     CR 13457: UI enhancements  
* 6.0       Yeswanth        06-Sep-2016     CR 13458: Exception Handling 
* 7.0       Meera           27-Sep-2016     CR 13540: Customer Selection: Search for Customer - UI Enhancements to support Deterministic Search
* 8.0       Mahesh          26-June-2018    CR 16070: Modify DnB search logic to accommodate multi track changes track account
************************************************************************************************************************************************************/

global class VFcntrl_SearchEndCustomerFromDnB {
    //Declare variable
    public boolean bdisplayPopup {get; set;}
    public String strSelectedvalue{get; set;}
    public map<string,string> countryCodeMap;
    public String selectedMailingCountry {get;set;}
    public map<string,string> regionMap;
    public boolean showButton{set;get;}
    public boolean showError{set;get;}
    public string selectedcountry{set;get;}
    public List<Country__c>  countriesList;
    Public End_Customer__c endCustomer=new End_Customer__c();
    Public End_Customer_Contact__c endCustomerContact=new End_Customer_Contact__c(); 
    Public Boolean ziprequired{get;set;}
    public Map<String, String> sfdcCountryMap1;
    public Map<String, String> sfdcRegionMap;
    public Map<String, String> sfdcCountryCodeMap;
    public Map<String, String> sfdcDNBCountryCodeMap;
    public Map<String, String> sfdcCountryRegionMap;
    public Boolean showunsupportPageBlockButtons{set;get;}
    public Set <Country__c> CountryName;
    public String searchMethod {get;set;}
    public String currentDNBCode {get;set;}
    public Boolean dunsNameCountryPostal {get;set;}
    public List<dunsdetails> finalList{get;set;}
    public String minscore{get;set;}
    public Integer totalRun;
    public boolean showPageBlockButtons{get;set;}
    public boolean showOriginalEnduserButton {get;set;}
    public Set<string>validDnBCountries;
    public boolean showDnbMessage {get;set;}
    public Boolean showDunsNumber, showAffinity, showCusNum, showBUID, showDunsName, showCountry, showState, showCity, showPostalCode, showResultTable, showResultBlock, showRegion;
    Account acct;
    public String oMessage{get;set;}
    public string CILresponseBody;
    public Integer SearchOrgReCount;
    public String oCountry{get;set;}
    public String oCountyCode{get;set;}
    public String oCity{get;set;}
    public String oDunsId{get;set;}
    public String oBusinessName{get;set;}
    public String oState{get;set;}
    public String oPostalCode{get;set;}
    public String oAddress1{get;set;}
    public String oOOB{get;set;}
    public String oEmployeeSize{get;set;}
    public String oTaxId{get;set;}
    public string ResError; 
    public string CILResError;
    public boolean displaynew{get;set;}
    
    public boolean displaycontacts{get;set;}
    public boolean showcontacts{get;set;}
    public boolean showContactSection{get;set;}
    public boolean showendcustduplicateerror{get;set;}
    public String duperror{get;set;}
    public String errorMsg{get;set;}
    public boolean showErroMsg{get;set;}
    public String exceptionMessage{get;set;}
    public boolean showexceptionMessage{get;set;}
    public boolean editableSearchPanel{get;set;}
    public boolean isLocalLanguageSearch{get;set;}
    public boolean showLocaLanguageCheckBox{get;set;}
    public boolean isEMEA{get;set;}
    public boolean isEmergingCountry{get;set;}
    public List<End_Customer_Contact__c> endCustomerContacts {get;set;}
    End_Customer__c dupEndCust ;
    string endCustomerContactName;
    List<End_Customer_Contact__c> endCustomerContactList;
    String stringToAppend = '';
    string requestBody;
    string responseBody;
    string selecteddunsName;
    Id endCustomerContactId;
    string endCustomerName;
    Id endCustomerId;
    String country;
    List<User> partneruser;
    End_customer__c newendcutomer;
    
    public End_Customer__c getEndCustomer(){
        return endCustomer; 
    }
    public End_Customer_Contact__c getEndCustomerContact(){
        return endCustomerContact; 
    }

    // Method that executes on Pageload
    public void onPageLoad(){
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=9');
        bdisplayPopup = false;
        showPageBlockButtons = true;
        editableSearchPanel = true;
        newendcutomer = new End_customer__c();
        sfdcCountryMap1 = new Map<String,String>();
        sfdcRegionMap = new Map<String,String>();
        sfdcCountryCodeMap = new Map<String,String>();
        sfdcDNBCountryCodeMap = new Map<String,String>();
        validDnBCountries = new Set<String>();
        dunsNameCountryPostal = false;
        SearchOrgReCount =  0;
        showDnbMessage = true;
        showLocaLanguageCheckBox = false;
        isLocalLanguageSearch = false;
        isEmergingCountry = false;
        strSelectedvalue = '';    
        // Get Parameters from URL and append to url 
        PageReference pr = ApexPages.currentPage();                
        Map<String, String> params = pr.getParameters();       
        for(String keyStr : params.keySet()){           
            if(keyStr != 'sfdc.override' && keyStr != 'save_new'){                
                if(stringToAppend != '') {
                    stringToAppend += '&';
                }
                stringToAppend += keyStr + '=' + pageUtils.encodeVariable(params.get(keyStr));
            }
        }
        try{
            
            partneruser = [SELECT id,contact.accountId,contact.Selected_Track_Account__c  FROM USER WHERE id = :Userinfo.getUserId()]; 
            countriesList = [SELECT Name,CurrencyIsoCode,Region__c,DNB_COUNTRY_CODE__c,DnB_Supported_Country__c,DNB_Region__c,DNB_ISO_country_code__c FROM Country__c where DnB_Supported_Country__c=true];
            countryCodeMap = new map<string,string>();
            regionMap = new map<string,string>();
            sfdcCountryRegionMap = new map<string,string>();
            //Create required country map
            for(country__c temp : countriesList ){
                countryCodeMap.put(temp.Name,temp.DNB_ISO_country_code__c);
                sfdcCountryMap1.put(temp.DNB_Country_Code__c,temp.Name );
                regionmap.put(temp.Name, temp.DNB_Region__c);
                sfdcCountryCodeMap.put(temp.DNB_Country_Code__c, temp.DNB_ISO_Country_Code__c);
                sfdcDNBCountryCodeMap.put(temp.Name, temp.DNB_Country_Code__c);
                validDnBCountries.add(temp.Name);
                sfdcCountryRegionMap.put(temp.Name,temp.Region__c);
            }
        }
        catch(exception ex){
            exceptionMessage = 'Exception:' +ex.getMessage();
            showexceptionMessage = true;
            showresultblock = false;
            showContactSection = false;                
        }
    }  
    
    public List<SelectOption> getMailingCountries()
    {
       
        List<SelectOption> options = new List<SelectOption>();         
        Schema.DescribeFieldResult fieldResult = End_Customer__c.Mailing_country__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
        options.add(new SelectOption('', '--None--'));
        for( Schema.PicklistEntry f : ple)
        {
             options.add(new SelectOption(f.getLabel(), f.getValue()));
        } 
        
        
        return options;
    }
    
    public pagereference markRequired(){
        

        Map<string,countries_zipcode_require__c> mapCodes = countries_zipcode_require__c.getAll();
        Set<String> mapCodeSet = new Set<String>();
        selectedMailingCountry = '';
        isEmergingCountry = False;
        for(String s: mapCodes.keySet()){
            mapCodeSet.add(s.toUpperCase());
        }
        if (mapCodeSet.contains(EndCustomer.Mailing_country__c)){
            ziprequired = true;
        }else{
            ziprequired = false;
        }
        isEMEA = false;
        if(sfdcCountryRegionMap.get(endCustomer.Mailing_country__c) !=null){
            isEMEA = sfdcCountryRegionMap.get(endCustomer.Mailing_country__c).contains('EMEA');
        }
        showResultBlock = false;
        showButton = true;
        showError = false;
        
        /*************************************/
        selectedMailingCountry = EndCustomer.Mailing_country__c;
        system.debug('>>>>selectedMailingCountry:::'+selectedMailingCountry);
        
        List<string> setEC = system.label.Emerging_countries.split(',');
        Set<String> setString = new Set<String>(setEC);
        system.debug('>>>setString::'+setString);
        if(setString.contains(selectedMailingCountry)){
            system.debug('>>>INSIDE::');
            isEmergingCountry = True;
        }
        if(selectedMailingCountry == 'BOSNIA AND HERZEGOVINA'|| selectedMailingCountry == 'MACEDONIA, THE FORMER YUGOSLAV REPUBLIC OF' || selectedMailingCountry == 'MOLDOVA, REPUBLIC OF'){
            isEmergingCountry = True;
        }
        system.debug('>>>>>isEmergingCountry:::'+isEmergingCountry);
        /*****************************/
        
        //Boolean supportCountry = validDnBCountries.contains(EndCustomer.Mailing_country__c);
        if ( validDnBCountries.contains(EndCustomer.Mailing_country__c) || EndCustomer.Mailing_country__c == null ){
            showDnbMessage = true;
            showPageBlockButtons=true;
            showunsupportPageBlockButtons=false;
        } else{
            showDnbMessage = false;
            showpageblockButtons=false;
            showunsupportPageBlockButtons=true;
        }
       // Local language checkbox will be enabled for the countries stored in custom setting
        isLocalLanguageSearch = false;
        Map<string,Dnb_Local_language_supported_countries__c> countryMap = Dnb_Local_language_supported_countries__c.getAll();
        Set<String> KeySet = new Set<String>();
        for(String s: countryMap.keySet()){
            KeySet.add(s.toUpperCase());
        }
        if (KeySet.contains(EndCustomer.Mailing_country__c)){
            showLocaLanguageCheckBox = true;
        }else{
            showLocaLanguageCheckBox = false;
        }
        return null;
    }
    
    public void useOriginalAddress(){
        system.debug('>>>>>Inside method');
        newendcutomer = new End_customer__c();
        endCustomerContact = new End_Customer_Contact__c(); 
        showContactSection = false;
        showErroMsg = false;
        try{
            if (endCustomer.Name == null ||(endCustomer.Name != null && endCustomer.Name.contains('%')) || endCustomer.Mailing_street__c == null || endCustomer.Mailing_city__c == null || (endCustomer.Mailing_State__c == null && !sfdcCountryRegionMap.get(endCustomer.Mailing_country__c).contains('EMEA')) ||((ziprequired == true ) && endCustomer.Zip_Code__c == null) || ((isEmergingCountry == true ) && endCustomer.Tax_Id__c == null)|| endCustomer.Mailing_country__c == null || endCustomer.Mailing_country__c == 'None') {
                if (endCustomer.Name == null) {
                    endCustomer.Name.addError(system.label.You_must_enter_a_value);
                }
                if(endCustomer.Name != null && endCustomer.Name.contains('%')){
                    endCustomer.Name.addError(system.label.DealReg_UseOriginalAddValidation); 
                    showunsupportPageBlockButtons=true;
                }
                if (endCustomer.Mailing_street__c == null) {
                    endCustomer.Mailing_street__c.addError(system.label.You_must_enter_a_value);
                }
                if (endCustomer.Mailing_city__c == null) {
                    endCustomer.Mailing_city__c.addError(system.label.You_must_enter_a_value);
                }
                if (endCustomer.Mailing_State__c == null) {
                    endCustomer.Mailing_State__c.addError(system.label.You_must_enter_a_value);
                } 
                //Add region checking for Mailing_State__c 
                if(sfdcCountryRegionMap.get(endCustomer.Mailing_country__c) !=null){
                    if (endCustomer.Mailing_State__c == null && !sfdcCountryRegionMap.get(endCustomer.Mailing_country__c).contains('EMEA')) {
                        endCustomer.Mailing_State__c.addError(system.label.You_must_enter_a_value);
                    }                    
                } 
                if((ziprequired == true )&& (endCustomer.Zip_Code__c == null || endCustomer.Zip_Code__c == 'None')){
                    endCustomer.Zip_Code__c.addError(system.label.You_must_enter_a_value);
                }
                if((isEmergingCountry == true )&& (endCustomer.Tax_Id__c == null || endCustomer.Tax_Id__c == 'None')){
                    system.debug('>>>>>>INSIDE COND');
                    endCustomer.Tax_Id__c.addError(system.label.You_must_enter_a_value); 
                }
                if (endCustomer.Mailing_country__c == null || endCustomer.Mailing_country__c == 'None') {
                    endCustomer.Mailing_country__c.addError(system.label.You_must_enter_a_value);
                }                
            }
            else { 
                showunsupportPageBlockButtons=false;
                editableSearchPanel = false;        
                showResultTable = false;
                showResultBlock = false;
                //get current user partner account
                List<User> partneruser = [SELECT id,contact.accountId,contact.Selected_Track_Account__c FROM USER WHERE id = :Userinfo.getUserId()];
                if(partneruser != null && partneruser[0].contact.accountId != null){
                    newendcutomer = endCustomer.clone(false,false,false,false);
                    newendcutomer.Source_System__c = 'Deal Registration';
                    newendcutomer.Partner_Account__c = partneruser[0].contact.Selected_Track_Account__c == null ? partneruser[0].contact.accountId: partneruser[0].contact.Selected_Track_Account__c;
                    newendcutomer.Created_using_Partner_D_B_Search__c = 'No';
                    newendcutomer.End_Customer_Selection__c = 'Free Text';
                    
                    database.insert(newendcutomer );
                    showContactSection = true;
                    
                    endCustomerName = newendcutomer.Name;
                    endCustomerId = newendcutomer.Id;
                }     
            }
        }
        catch(system.DmlException dmlex){ exceptionMessage = 'DMLException:' +dmlex.getMessage();
            showexceptionMessage = true;        
        }
        catch(exception ex){ 
            exceptionMessage = 'Exception:' +ex.getMessage();
            showexceptionMessage = true; showresultblock = false; showContactSection = false;                
        } 
    }
    public PageReference useOriginalAddress2(){                  
        useOriginalAddress();           
        showunsupportPageBlockButtons=false;
        return null;
    }
    //Method to navigate to exisitng end customer page
    public pagereference navigateToExistingEndcustomer(){
        String URL= '/apex/EndCustomerSelectionPage?'+stringToAppend+'&nooverride=1';
        pagereference page = new pagereference(URL);
        page.setRedirect(TRUE);
        return page;
    }
    
    public boolean showEndCustContTable {get;set;}
    public boolean showDupEndCustError {get;set;} 
    public boolean displayContactForm{get;set;}
    public boolean displaynewContactOption{get;set;}
    public string showNoContMsg {get;set;}
    
    public void createNewContactForm(End_Customer__c duplicateEndCustomer){
        showEndCustContTable = True;
        displaynewContactOption = true; 
        showDupEndCustError = false;
        showErroMsg = false;
        displayContactForm = false;
        
        endCustomerContacts = new List<End_Customer_Contact__c>();
        endCustomerContacts = VFcntrl_SearchEndCustomerFromDnB.fetchExistingEndCustomerContacts(duplicateEndCustomer.Id);   
        dupEndCust = new End_Customer__c();
        dupEndCust  = duplicateEndCustomer;
        If(endCustomerContacts.size() < 1){
            showDupEndCustError = true;
            showEndCustContTable = false;
            displaynewContactOption = true;
            showNoContMsg = system.label.NoPrevUsed_Contact_Error;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, (system.label.NoPrevUsed_Contact_Error)  ));
        }
    }
    
    public End_Customer_Contact__c objEndCustumerContact{get;set;}
    public String createNewContact{get;set;}
    public boolean showContError {get;set;}
    
    public void createNewContForm(){
        objEndCustumerContact = new End_Customer_Contact__c();
        createNewContact = 'true';
        displayContactForm = true;
        showErroMsg = false;
        showContError = false;
    } 
    
    public void hideNewContForm(){
        displayContactForm = false;
        showContError = false;
        createNewContact = 'false';
        showErroMsg = false;
    }
    
    
    public static List<End_Customer_Contact__c> fetchExistingEndCustomerContacts(Id endCustId){
        List<End_Customer_Contact__c> duplEndCustomersContacts = new List<End_Customer_Contact__c>();
        duplEndCustomersContacts = [SELECT id,Name,Last_Name__c,Title__c,Email__c,Status__c,End_Customer__c FROM End_Customer_Contact__c WHERE Status__c = 'Active' AND End_Customer__c = :endCustId];
        return duplEndCustomersContacts;
    }
    
    public pageReference saveEndCustomerDetails(){
        try{
            showErroMsg = false;
            Id selectedContactId = System.currentPagereference().getParameters().get('dupEndCustContact');
            System.debug('***COntact Id: '+ selectedContactId);
            If((selectedContactId == Null ) && (createNewContact == 'false' || createNewContact == null || createNewContact == '' ) ){
                errorMsg = system.label.DealReg_ContactButError;
                showErroMsg = true;   
                return null;
            }
            if(createNewContact == 'True'){
                If(objEndCustumerContact.Name == null || objEndCustumerContact.Name == ''
                   || objEndCustumerContact.Email__c == null || objEndCustumerContact.Email__c == '' 
                   || objEndCustumerContact.Last_Name__c == null || objEndCustumerContact.Last_Name__c == ''
                   || objEndCustumerContact.Phone__c == null || objEndCustumerContact.Phone__c == ''
                   ){
                       
                       If(objEndCustumerContact.Name == null || objEndCustumerContact.Name == ''){
                           objEndCustumerContact.Name.addError(system.label.You_must_enter_a_value);
                       }
                       
                       If(objEndCustumerContact.Email__c == null || objEndCustumerContact.Email__c == ''){
                           objEndCustumerContact.Email__c.addError(system.label.You_must_enter_a_value);
                       }
                       
                       If(objEndCustumerContact.Last_Name__c == null || objEndCustumerContact.Last_Name__c == ''){
                           objEndCustumerContact.Last_Name__c.addError(system.label.You_must_enter_a_value);
                       }
                       
                       If(objEndCustumerContact.Phone__c == null || objEndCustumerContact.Phone__c == ''){
                            objEndCustumerContact.Phone__c.addError(system.label.You_must_enter_a_value);
                       }
                       return null;
                   }else{ 
                       //check for duplicate                      
                         String dup = DealReg_CustomerSelectionHelper.checkEndCustomerContactDuplicate(objEndCustumerContact.Email__c,dupEndCust.Id);
                        if( dup == 'None'){
                            objEndCustumerContact.End_Customer__c=dupEndCust.Id;
                            objEndCustumerContact.Status__c = 'Active';
                            insert objEndCustumerContact;
                           
                            End_Customer__c endCust = [SELECT id FROM End_Customer__c WHERE Id =: dupEndCust.Id];
                            endCust.End_Customer_Selection__c = 'Existing';
                            endCust.Created_using_Partner_D_B_Search__c = 'No';
                            update endCust; 
                           
                            endCustomerContactName = objEndCustumerContact.Name;
                            selectedContactId = objEndCustumerContact.Id;
                            showErroMsg = false;
                        } 
                        else{
                           //duplicate exists
                           errorMsg = System.Label.DealReg_ECContactDupeError +dup ;
                           showErroMsg = true; displayContactForm = true;
                           End_Customer__c endCust = [SELECT id FROM End_Customer__c WHERE Id =: dupEndCust.Id];
                           endCust.End_Customer_Selection__c = 'Existing'; 
                           endCust.Created_using_Partner_D_B_Search__c = 'No';
                           update endCust; 
                           return null;
                       }
                   }
                } 
                else{  endCustomerContactName = [Select name   from End_Customer_Contact__c  where id=:selectedContactId Limit 1][0].Name;
                system.debug('***endCustomerContactName'+endCustomerContactName);
            }
            String redirectToOppDetailPage= '/apex/OpportunityRedirectPage?&ent=Opportunity&nooverride=1&RecordType=012A0000000Vi0S&retURL=%2F006%2Fo&CF00NA00000063VT1= '+ dupEndCust.Name +'&CF00NA00000063VT1_lkid='+ dupEndCust.Id +'&CF00NA00000063VT6='+ endCustomerContactName +'&CF00NA00000063VT6_lkid='+selectedContactId+''+'&'+stringToAppend;
            PageReference page = new PageReference(redirectToOppDetailPage);
            return page;
        }catch(DmlException dmlEx){
            SYstem.debug('***DML Exception: '+ dmlEx.getMessage());
        }catch(Exception ex){
            SYstem.debug('***Exception: '+ ex.getMessage() + ' at line# '+ ex.getLineNumber());
        }
        
        return null;
    } 
    // Method to call DnB
   
    public pagereference searchDnB(){
        try{
            //declare variables
            showContactSection = false;
            finalList = new List<dunsdetails>(); 
            showButton = true;
            showError = false;
            showErroMsg = false;
            showexceptionMessage = false;
            SearchOrgReCount =  0;
            Integer lastcount = 0;
            requestBody = '' ;
            responseBody = '';
            List<Dom.XmlNode> SearchOrgReList = new List<Dom.XmlNode>();
            List<Dom.XmlNode> OrgExtChilList = new List<Dom.XmlNode>();
            List<Dom.XmlNode> AddressList = new List<Dom.XmlNode>();
            Integer OrgExtChildCount = 0;
            Integer AddressNodeCount  = 0;
           
            //check for required fields
            if (endCustomer.Name == null || (endCustomer.Name != null && endcustomer.name.remove('%').length()<3)  ||  (endCustomer.Name != null &&endCustomer.Name.startswith('%'))){        
               // if (endCustomer.Name == null){
                if(endCustomer.Name == null){
                    endCustomer.Name.addError(System.label.You_must_enter_a_value);
                }
                else if(endCustomer.Name != null &&  endcustomer.name.remove('%').length()<3 ){
                    
                    endCustomer.Name.addError(System.label.DealReg_DnBCharacterLimit);
                } 
                if(endCustomer.Name != null && endCustomer.Name.startswith('%')){
                    endCustomer.Name.addError(system.label.DealReg_DnBwildcardError);
                }
                showError = true;
                showResultTable = false;
                showResultBlock = false;
            }
            if (endCustomer.Mailing_country__c == null || endCustomer.Mailing_country__c == 'None'){
                oMessage = system.label.deal_reg_mailing_country_mandatory;
                showResultTable = false;
                showResultBlock = true;
                showError = true;
            }
            if (endCustomer.Mailing_street__c == null || endCustomer.Mailing_street__c == 'None'){
                endCustomer.Mailing_street__c.addError(system.label.You_must_enter_a_value); 
                showError = true;
                showResultTable = false;
                showResultBlock = false;
            }
            if (endCustomer.Mailing_city__c == null || endCustomer.Mailing_city__c == 'None'||(endCustomer.Mailing_city__c != null && endCustomer.Mailing_city__c .length()<3 && !isLocalLanguageSearch) || (endCustomer.Mailing_city__c != null && endCustomer.Mailing_city__c .contains('%'))){
                if(endCustomer.Mailing_city__c == null){
                    endCustomer.Mailing_city__c.addError(system.label.You_must_enter_a_value);
                }
                else if(endCustomer.Mailing_city__c != null && endCustomer.Mailing_city__c.length()<3 && !isLocalLanguageSearch) {
                    endCustomer.Mailing_city__c.addError(System.label.DealReg_DnBCharacterLimit);
                } 
                if(endCustomer.Mailing_city__c != null && endCustomer.Mailing_city__c.contains('%')){
                    endCustomer.Mailing_city__c.addError(System.label.DealReg_DnBCityValidation);
                }
                showError = true;
                showResultTable = false;
                showResultBlock = false;
            }
            if (((endCustomer.Mailing_State__c == null || endCustomer.Mailing_State__c == 'None')&& endCustomer.Mailing_country__c != null &&!sfdcCountryRegionMap.get(endCustomer.Mailing_country__c).contains('EMEA')) || (endCustomer.Mailing_State__c != null&& endCustomer.Mailing_State__c.length()<3 &&!isLocalLanguageSearch) || (endCustomer.Mailing_State__c != null&& endCustomer.Mailing_State__c.contains('%'))){
                if((endCustomer.Mailing_State__c == null || endCustomer.Mailing_State__c == 'None')&& !sfdcCountryRegionMap.get(endCustomer.Mailing_country__c).contains('EMEA')){
                    endCustomer.Mailing_State__c.addError(system.label.You_must_enter_a_value);
                }
                if(endCustomer.Mailing_State__c != null&& endCustomer.Mailing_State__c.length()<3 && !isLocalLanguageSearch){
                    endCustomer.Mailing_State__c.addError(System.label.DealReg_DnBCharacterLimit); 
                }
                if(endCustomer.Mailing_State__c != null&& endCustomer.Mailing_State__c.contains('%')){
                    endCustomer.Mailing_State__c.addError(System.label.DealReg_DnBCityStateValidation);
                }
                showError = true;
                showResultTable = false;
                showResultBlock = false;
            } 
            if((ziprequired == true )&& (endCustomer.Zip_Code__c == null || endCustomer.Zip_Code__c == 'None')){
                endCustomer.Zip_Code__c.addError(system.label.You_must_enter_a_value); 
                showError = true;   showResultTable = false;
                showResultBlock = false;
            }
            if((isEmergingCountry == true )&& (endCustomer.Tax_Id__c == null || endCustomer.Tax_Id__c == 'None')){
                endCustomer.Tax_Id__c.addError(system.label.You_must_enter_a_value); 
                showError = true;   showResultTable = false;
                showResultBlock = false;
            }
            country = endCustomer.Mailing_country__c == 'UNITED KINGDOM'?'England':endCustomer.Mailing_country__c;
            if(!validDnBCountries.contains(country) && showError != true ){
                oMessage = System.Label.DealReg_NoRecordFound;
                showResultTable = false;
                showResultBlock = true;
                return null;
            }
            if(showError != true){
                string countryiso = countryCodeMap.get(country );
                string region = regionMap.get(country);       
                System.debug(region);
                System.debug(PageUtils.encodeVariable(EndCustomer.Name)); 
                
                string modifiedOrgname = escapeSpecialChar(EndCustomer.Name)+'%';
                System.debug('>>>modifiedOrgname '+modifiedOrgname );
                string modifiedMailingCity = escapeSpecialChar(EndCustomer.Mailing_city__c);
                string modifiedMailingState = escapeSpecialChar(EndCustomer.Mailing_State__c);
                string TaxID = escapeSpecialChar(EndCustomer.Tax_Id__c);
                String requestXMLString;
                string localLangInd = 'N';
                if(isLocalLanguageSearch){
                    localLangInd = 'Y';                    
                }
                if(EndCustomer.Tax_Id__c == null || isLocalLanguageSearch){
                     requestXMLString = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/" xmlns:cus="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.Messages" xmlns:cus1="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.OrganizationEntities" xmlns:cus2="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.PartyEntities" xmlns:cus3="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.Utility">'
                        +'<soapenv:Header/>'
                        +'<soapenv:Body>'
                        +'<SearchDnBOrganization xmlns="http://tempuri.org/">'
                        +'<searchDNBRequestDTO xmlns:d4p1="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.Messages" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">'
                        +'<d4p1:OrganizationRequestObject xmlns:d5p1="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.OrganizationEntities">'
                        +'<d5p1:OrganizationName>'+modifiedOrgname+'</d5p1:OrganizationName>'  //EndCustomer.Name.escapeHtml4()   
                        +'</d4p1:OrganizationRequestObject>'
                        +'<d4p1:CommonObject xmlns:d5p1="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.PartyEntities">'
                        +'<d5p1:SearchType>D</d5p1:SearchType>';
                        if(EndCustomer.Mailing_city__c != null){
                            requestXMLString += '<d5p1:CityName>'+modifiedMailingCity+'</d5p1:CityName>';
                        }
                        requestXMLString += '<d5p1:CountryType>'+countryiso +'</d5p1:CountryType>';
                        if(EndCustomer.Mailing_State__c !=null ){
                            requestXMLString += '<d5p1:Region>'+modifiedMailingState+'</d5p1:Region>';
                        }
                
                    requestXMLString += '</d4p1:CommonObject>'
                        +'<d4p1:LocalLangInd>'+localLangInd+'</d4p1:LocalLangInd>'
                        +'<d4p1:BasicFlag>Y</d4p1:BasicFlag>'
                        +'<d4p1:AddressFlag>Y</d4p1:AddressFlag>'
                        +'<d4p1:MiscFlag>Y</d4p1:MiscFlag>'
                        +'<d4p1:ParentFlag>Y</d4p1:ParentFlag>'
                        +'<d4p1:PhoneFlag>Y</d4p1:PhoneFlag>'
                        +'<d4p1:ContactFlag>Y</d4p1:ContactFlag>'
                        +'<d4p1:CrmFlag>Y</d4p1:CrmFlag>'
                        +'<d4p1:CompanyDetailsFlag>Y</d4p1:CompanyDetailsFlag>'
                        +'<d4p1:Region>'+region+'</d4p1:Region>'
                        +'</searchDNBRequestDTO>'
                        +'<clientApplicationInfo xmlns:d4p1="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.Utility" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">'
                        +'<d4p1:ApplicationName>SFDC</d4p1:ApplicationName>'
                        +'</clientApplicationInfo>'
                        +'</SearchDnBOrganization>'                            
                        +'</soapenv:Body>'
                        +'</soapenv:Envelope>'; 
                }else{
                    requestXMLString= '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/" xmlns:cus="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.Messages" xmlns:cus1="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.OrganizationEntities" xmlns:cus2="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.PartyEntities" xmlns:cus3="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.Utility">'
                        +'<soapenv:Header/>'
                        +'<soapenv:Body>'
                        +'<SearchDnBOrganization xmlns="http://tempuri.org/">'
                        +'<searchDNBRequestDTO xmlns:d4p1="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.Messages" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">'
                        +'<d4p1:CommonObject xmlns:d5p1="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.PartyEntities">'
                        +'<d5p1:SearchType>D</d5p1:SearchType>'
                        +'<d5p1:CountryType>'+countryiso +'</d5p1:CountryType>'
                        +'<d5p1:NationalTaxId>'+TaxID+'</d5p1:NationalTaxId>'
                        +'</d4p1:CommonObject>'
                        +'<d4p1:LocalLangInd>N</d4p1:LocalLangInd>'
                        +'<d4p1:BasicFlag>Y</d4p1:BasicFlag>'
                        +'<d4p1:AddressFlag>Y</d4p1:AddressFlag>'
                        +'<d4p1:MiscFlag>Y</d4p1:MiscFlag>'
                        +'<d4p1:ParentFlag>Y</d4p1:ParentFlag>'
                        +'<d4p1:PhoneFlag>Y</d4p1:PhoneFlag>'
                        +'<d4p1:ContactFlag>Y</d4p1:ContactFlag>'
                        +'<d4p1:CrmFlag>Y</d4p1:CrmFlag>'
                        +'<d4p1:CompanyDetailsFlag>Y</d4p1:CompanyDetailsFlag>'
                        +'<d4p1:Region>'+region+'</d4p1:Region>'
                        +'</searchDNBRequestDTO>'
                        +'<clientApplicationInfo xmlns:d4p1="http://schemas.datacontract.org/2004/07/CustomerMDM.DataContracts.Utility" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">'
                        +'<d4p1:ApplicationName>SFDC</d4p1:ApplicationName>'
                        +'</clientApplicationInfo>'
                        +'</SearchDnBOrganization>'
                        + '</soapenv:Body>'
                        +'</soapenv:Envelope>'; 
                }
                // Creating request       
                Httprequest request = new Httprequest(); //header
                request.setMethod('POST');
                request.setHeader('Content-Type','text/xml;charset=UTF-8');
                request.setHeader('SOAPAction',system.Label.MDM_Soap_action);
                if(Environment.isProduction()){                                
                    request.setHeader('Authorization',System.Label.Deal_Reg_MDM_Prod_Credentials);
                    request.setEndpoint(System.Label.Deal_Reg_MDM_CIL_Prod_Url); // where to hit
                }
                else{
                    request.setHeader('Authorization',System.Label.Deal_Reg_MDM_Sandbox_Credentials);
                    request.setEndpoint(System.Label.Deal_Reg_MDM_CIL_Sandbox_Url);
                }
                request.setBody(requestXMLString);
                request.setTimeout(integer.valueOf(System.Label.Deal_Reg_timeout_variable)); //100000
                httpresponse responseXML;
                Http http = new Http();
                //retrying in case of failure 
                for(Integer a = 0; a <= integer.valueOf(System.Label.Deal_Reg_retry_count_variable); a++){
                    System.debug('Before Send:'+DateTime.now());
                    responseXML = http.send(request);  
                    system.debug('**Response '+responseXML);
                    System.debug('After Send:'+DateTime.now());             
                    if(responseXML.getstatuscode() == 200){
                        CILresponseBody = responseXML.getBody();
                        totalRun = a+1;
                        break;
                    }
                }                                   
                CILResError = responseXML.getStatus();
                
                requestBody = request.getBody();
                responseBody = responseXML.getBody();

                /**** Exception handling begins*****/
                if(!CILResError.contains('OK') /* || CILresponseBody.contains('No Record Found') || CILresponseBody.contains('No Data found') */ || CILresponseBody.contains('faultcode')){
                    if(!CILResError.contains('OK')){
                        System.debug('Inside error');
                        oMessage = System.Label.Deal_reg_exception_message;
                        showResultTable = false;
                        showResultBlock = true;
                        String ErrorMessage = 'Null';
                        String ErrorCodeValue ;
                        String TransactionIdValue ;
                        try{
                            Dom.Document doc = new Dom.Document();
                            doc.load(responseXML.getBody());
                            Dom.XMLNode rootElement = doc.getRootElement();
                            Dom.XMLNode Body = rootElement.getChildElements()[0];  // <env:Body>
                            String BodyName = Body.getName();
                            Dom.XMLNode FaultNode;
                            if (BodyName == 'Body') {
                                FaultNode = body.getChildElements()[0];     // <env:Fault>
                            }
                            Dom.XMLNode CodeNode = FaultNode.getChildElements()[0];  // <env:Code>
                            Dom.XMLNode ErrorCode = CodeNode.getChildElements()[0];  //<env:Value>
                            String ErroCodetext = ErrorCode.gettext();
                            ErrorCodeValue = splitMethod(ErroCodetext);
                            Dom.XMLNode ReasonNode = FaultNode.getChildElements()[1];  // <env:Reason>
                            Dom.XMLNode TextNode = ReasonNode.getChildElements()[0];  // <env:Text>
                            String TransactionIdtext = TextNode.gettext();
                            TransactionIdValue = splitMethod(TransactionIdtext);
                            Dom.XMLNode TextNode1 = ReasonNode.getChildElements()[1];    // <env:Text>
                            String ErrorMessagetext = TextNode1.gettext();
                            ErrorMessage = splitMethod(ErrorMessagetext);
                        }
                        catch(Exception ex){
                            System.debug(ex.getMessage());
                            oMessage = System.Label.Deal_reg_exception_message;
                            showResultTable = false;
                            showResultBlock = true;
                            showendcustduplicateerror = false;                  
                        }
                        finally{
                            // insert exception record                  
                            Exception__C exceptionRecord = new Exception__C();
                            exceptionRecord.Process_Name__c = 'Deal Reg Customer Selection';
                            exceptionRecord.Object_type__c = 'User';
                            exceptionRecord.Object_ID__c = userinfo.getUserId();
                            exceptionRecord.Notes__C = ErrorMessage;
                            exceptionRecord.Error_Messages__c = 'Error Code:-'+' ' +ErrorCodeValue + '\n' + 'TransactionId:-'+' '+TransactionIdValue + '\n' + 'Status:-'+' '+CILResError + '\n' + 'Exception occured on Data Power Side';
                            Database.SaveResult resultStatus = database.insert(exceptionRecord);
                            
                            if(resultStatus.isSuccess()){
                                list<attachment> attachlist = new list<attachment>();
                                attachment reqattachment = new attachment();
                                reqattachment.Body = Blob.valueOf(request.getBody());
                                reqattachment.Name = 'Request.txt';
                                reqattachment.ParentId=  exceptionRecord.Id;
                                attachlist.add(reqattachment);
                                
                                attachment responseattachment = new attachment();
                                responseattachment.Body = Blob.valueOf(responseXML.getBody());
                                responseattachment.Name = 'Response.txt';
                                responseattachment.ParentId=  exceptionRecord.Id;
                                attachlist.add(responseattachment);
                                
                                database.insert(attachlist);
                            }                                            
                        }
                    }
                    //if status is OK but response contains failure code
                    else if(CILresponseBody.contains('faultcode')){
                        if(CILresponseBody.contains('No Data found') || CILresponseBody.contains('No Record Found') ){
                            System.debug('No Record found');
                            oMessage = System.Label.DealReg_NoRecordFound;
                            showResultTable = false;
                            showResultBlock = true;
                        }
                        else  if(CILresponseBody.contains('DeserializationFailed')){
                            System.debug('No Record found');
                            oMessage = System.Label.DealReg_NoRecordFound;
                            showResultTable = false;
                            showResultBlock = true;
                        } 
                        else{
                            System.debug('Inside faultcode');                  
                            oMessage = System.Label.Deal_reg_exception_message;
                            showResultTable = false;
                            showResultBlock = true;
                            String ErrorMessagetext ='Null';
                            String faultCodeValue;
                            String MessageIDValue;
                            try{
                                Dom.Document doc = new Dom.Document();
                                doc.load(CILresponseBody);
                                Dom.XMLNode rootElement = doc.getRootElement();
                                String rootElementName = rootElement.getName();
                                System.Debug('rootElementName'+rootElementName);                       
                                Dom.XMLNode Body = rootElement.getChildElements()[0]; //  <s:Header>
                                String BodyName = Body.getName();    
                                if (BodyName == 'Header') {
                                    Dom.XMLNode MessageID = body.getChildElements()[0]; // <MessageId>
                                    MessageIDValue = MessageID.gettext();
                                    system.debug('****MessageIDValue****' + MessageIDValue);
                                    Body = rootElement.getChildElements()[1];
                                }
                                Dom.XMLNode faultcode = Body.getChildElements()[0]; //  <s:Fault>
                                String faultcodename = faultcode.getName();
                                System.debug(faultcodename);
                                Dom.XMLNode faultstring = faultcode.getChildElements()[0]; // <faultcode> 
                                faultCodeValue = faultstring.gettext();
                                Dom.XMLNode faultstring1 = faultcode.getChildElements()[1]; // <faultstring>
                                String faultstringval = faultstring1.getText();
                                Dom.XMLNode Detail = faultcode.getChildElements()[2]; // <detail>
                                Dom.XMLNode Result = Detail.getChildElements()[0]; // <Result>
                                Dom.XMLNode ResultCode = Result.getChildElements()[1]; // <ResultCode>
                                String ResultString = ResultCode.getText();
                                Dom.XMLNode ErrorList = Result.getChildElements()[2]; // <ErrorList>
                                ErrorMessagetext =''; 
                                for(Dom.XMLNode Error : ErrorList.getChildElements()){ // <a:Error>
                                    Dom.XMLNode ErrorMessage = Error.getChildElements()[0]; // <a:ErrorMessage>
                                    String ErrorMessageName = ErrorMessage.getname();
                                    if (ErrorMessageName == 'ErrorMessage') {
                                        ErrorMessagetext = ErrorMessagetext + '\n' +ErrorMessage.gettext();
                                    }
                                } 
                            }
                            catch(Exception ex){
                                System.debug(ex.getMessage());
                                oMessage = System.Label.Deal_reg_exception_message;
                                showResultTable = false;
                                showResultBlock = true;
                                showendcustduplicateerror = false;                  
                            }
                            finally{
                                // insert exception record         
                                Exception__C exceptionRecord = new Exception__C();
                                exceptionRecord.Process_Name__c = 'Deal Reg Customer Selection';
                                exceptionRecord.Object_type__c = 'User';
                                exceptionRecord.Object_ID__c = userinfo.getUserId();
                                exceptionRecord.Notes__C = ErrorMessagetext;
                                exceptionRecord.Error_Messages__c = 'Fault Code:-'+' ' +faultCodeValue + '\n' + 'MessageID:-'+' '+MessageIDValue + '\n' + 'Exception occured on CIL layer';
                                Database.SaveResult resultStatus = database.insert(exceptionRecord);
                                
                                if(resultStatus.isSuccess()){
                                    list<attachment> attachlist = new list<attachment>();
                                    attachment reqattachment = new attachment();
                                    reqattachment.Body = Blob.valueOf(request.getBody());
                                    reqattachment.Name = 'Request.txt';
                                    reqattachment.ParentId=  exceptionRecord.Id;
                                    attachlist.add(reqattachment);
                                    
                                    attachment responseattachment = new attachment();
                                    responseattachment.Body = Blob.valueOf(CILresponseBody);
                                    responseattachment.Name = 'Response.txt';
                                    responseattachment.ParentId=  exceptionRecord.Id;
                                    attachlist.add(responseattachment);
                                    
                                    database.insert(attachlist);
                                }
                            }
                        }
                    }
                    return null;
                }  
                
                /**** Exception handling Ends*****/
                
                //if valid records returned in the search
                else {
                    oMessage = '';
                    Dom.Document doc = new Dom.Document();
                    doc.load(CILresponseBody);
                    Dom.XMLNode rootElement = doc.getRootElement();//envelope
                    String rootElementName = rootElement.getName();
                    //sazleen update from 1 to 0
                    Dom.XMLNode Body = rootElement.getChildElements()[1];//body
                    String BodyName =  Body.getName();
                    Dom.XMLNode SearchDnBOrganizationResponse = Body.getChildElements()[0];//SearchDnBOrganizationResponse
                    String SearchDnBOrganizationResponseName =  SearchDnBOrganizationResponse.getName();
                    Dom.XMLNode SearchDnBOrganizationResult = SearchDnBOrganizationResponse.getChildElements()[0];//SearchDnBOrganizationResult
                    String SearchDnBOrganizationResultName =  SearchDnBOrganizationResult.getName();
                    Dom.XMLNode OrganizationList = SearchDnBOrganizationResult.getChildElements()[2];//OrganizationList
                    String OrganizationListName =  OrganizationList.getName();
                    for(Dom.XMLNode SearchOrganizationResultElement : OrganizationList.getChildElements()){
                        //initialize all variables for each search
                        oBusinessName =  '';
                        oDunsId =  '';
                        oOOB =  '';
                        oEmployeeSize =  '';
                        oAddress1 =  '';
                        oCity =  '';
                        oCountyCode =  '';
                        oPostalCode =  '';
                        oState =  '';
                        oTaxId =  '';
                        SearchOrgReList.add(SearchOrganizationResultElement);
                        SearchOrgReCount++;
                        String OrgResultTestName =  SearchOrganizationResultElement.getName();
                        // To get Party
                        Dom.XMLNode SeacrhChildOrg = SearchOrganizationResultElement.getChildElements()[0];//<b:Party
                        String SearchChildOrgName = SeacrhChildOrg.getName();
                        //System.debug('SearchChildOrgName :' +SearchChildOrgName +' '+SeacrhChildOrg);
                        Dom.XMLNode PartyChild = SeacrhChildOrg.getChildElements()[0];//<c:Party>
                        String PartyChildName = PartyChild.getName();
                        //System.debug('PartyChild :' +PartyChildName +' '+PartyChild);
                        Dom.XMLNode PartyChild1 = PartyChild.getChildElements()[0];//<c:Organization>
                        String PartyChildName1 = PartyChild.getName();
                        //To get Duns Name
                        Dom.XMLNode OrganizationName = PartyChild1.getChildElements()[0];//<b:OrganizationName>
                        String OrganizationChildtName = OrganizationName.getName();
                        Dom.XMLNode OrganizationName1 = OrganizationName.getChildElements()[0];//<b:OrganizationName>
                        Dom.XMLNode OrganizationNameValue = OrganizationName1.getChildElements()[0];//<b:Name>Center BMW</b:Name>
                        oBusinessName = OrganizationNameValue.getText();
                        // Local language search
                        if(isLocalLanguageSearch){
                            oBusinessName = '';
                            Dom.XMLNode OrganizationNameExtension = OrganizationName1.getChildElements()[1];  // <b:OrganizationNameExtension>
                            Dom.XMLNode OrganizationNameExtension1 = OrganizationNameExtension.getChildElements()[0]; // <d:OrganizationNameExtension>
                            Dom.XMLNode localLangDunsName = OrganizationNameExtension1.getChildElements()[0];
                            oBusinessName = localLangDunsName.getText();
                        }
                        
                        // to get OrganizationExtensionElement Duns Name, OOB and EmployeeSize
                        Dom.XMLNode OrganizationExtension1 = PartyChild.getChildElements()[0];//<c:Organization>
                        String OrganizationExtensionName1 = OrganizationExtension1.getName();
                        Dom.XMLNode Organizationduns2 = OrganizationExtension1.getChildElements()[1];//<b:OrganizationExtension>get duns details
                        String Organizationdunsname2 = Organizationduns2.getName();
                        for(Dom.XMLNode OrganizationExtensionChild : Organizationduns2.getChildElements()){
                            //Iterate through DUNs details
                            If(OrganizationExtensionChild.getName() == 'DunsNumber'){
                                oDunsId = OrganizationExtensionChild.getText();
                            }
                            If(OrganizationExtensionChild.getName() == 'OutOfBusinessIndi'){
                                oOOB = OrganizationExtensionChild.getText();
                            }
                            If(OrganizationExtensionChild.getName() == 'EmployeesTotal'){
                                oEmployeeSize = OrganizationExtensionChild.getText();
                            } 
                            If(OrganizationExtensionChild.getName() == 'NationalId'){
                                oTaxId = OrganizationExtensionChild.getText();
                            }   
                        }
                        
                        Dom.XMLNode PartyAddressElement = PartyChild.getChildElements()[1];//<c:PartyAddress>
                        String PartyAddressElementName = PartyAddressElement.getName();
                        Dom.XMLNode PartyAddressChildElement = PartyAddressElement.getChildElements()[0];//<c:PartyAddress>
                        String PartyAddressChildElementName = PartyAddressChildElement.getName();
                        Dom.XMLNode AddressElement = PartyAddressChildElement.getChildElements()[1];//<c:Address>
                        String AddressElementdName = AddressElement.getName();
                        for(Dom.XMLNode AddressChild : AddressElement.getChildElements()){
                            //iterate to get address elements
                            AddressList.add(AddressChild);
                            AddressNodeCount++;
                            If(AddressChild.getName() == 'AddressLineOne'){//need to add null checking
                                oAddress1 = AddressChild.getText();
                            }
                            If(AddressChild.getName() == 'City'){
                                oCity = AddressChild.getText();
                                System.Debug('oCity' +oCity);
                            }
                            If(AddressChild.getName() == 'CountryValue'){ 
                                oCountyCode = AddressChild.getText();
                                oCountyCode = String.valueOf(Integer.valueOf(oCountyCode));
                            }
                            If(AddressChild.getName() == 'ZipPostalCode'){
                                oPostalCode = AddressChild.getText();
                            }
                            If(AddressChild.getName() == 'Region'){
                                oState = AddressChild.getText();
                            }
                            
                            // local language search                               
                            if(isLocalLanguageSearch){                               
                                if(AddressChild.getName() == 'AddressExtension'){
                                    Dom.XMLNode AddressExtension = AddressChild.getChildElements()[0]; // <d:AddressExtension>
                                    for(Dom.XMLNode LocalLangAddressChild : AddressExtension.getChildElements()){
                                        If(LocalLangAddressChild.getName() == 'LocallangAddrLineOne'){
                                            oAddress1 = '';
                                            oAddress1 = LocalLangAddressChild.getText();
                                        }
                                        If(LocalLangAddressChild.getName() == 'LocallangCity'){
                                            oCity = '';
                                            oCity = LocalLangAddressChild.getText();
                                        }
                                        If(LocalLangAddressChild.getName() == 'LocallangState'){
                                            oState = '';
                                            oState = LocalLangAddressChild.getText();
                                        }
                                    }
                                }
                            }
                        }
                        //added by Rap
                        oCountry = sfdcCountryMap1.get(oCountyCode);   //commented because map was not fetching any values
                        // If there is no Country with the country code the display the enduser mailing country
                        if (oCountry == NULL){
                            oCountry = endCustomer.Mailing_country__c;                        
                        }
                        //Display only records with OOB Yes and results from searched country
                        if((oOOB == 'N')  && oAddress1 != ''){ //&& oCountry.equalsIgnoreCase(endCustomer.Mailing_country__c)
                        
                       
                        system.debug('in if strZipcountries');
                         
                            finalList.add(new dunsdetails(false,oAddress1,oBusinessName,oCity,oCountry,oCountyCode,oDunsId,oOOB,oPostalCode,oState,oEmployeeSize,oTaxId));
                          //if valid results
                         if(!finalList.isEmpty()){
                    system.debug('in if finalList');
                        finalList.sort();
                        showResultTable = true;
                        showResultBlock = true;
                        showendcustduplicateerror = false;
                        
                    }
                    //if no valid results
                    else {
                        system.debug('in else finalList');
                        oMessage = System.Label.DealReg_NoRecordFound;
                        showResultTable = false;
                        showResultBlock = true;
                        showendcustduplicateerror = false;
                    }  
                   
                     }
                          
                        
                        
                    
                   
                
            }}}
        }catch(Exception e){
            //Track generic exceptions
            System.debug(e.getMessage());
            oMessage = 'Exception Occured while doing D&B Search. Error Message: '+e.getMessage();
            showResultTable = false;
            showResultBlock = true;
            showendcustduplicateerror = false;
            Exception__C exceptionRecord = new Exception__C();
            exceptionRecord.Process_Name__c = 'Deal Reg Customer Selection';
            exceptionRecord.Object_type__c = 'User';
            exceptionRecord.Object_ID__c = userinfo.getUserId();
            exceptionRecord.Error_Messages__c = e.getMessage();
            Database.SaveResult resultStatus = database.insert(exceptionRecord);
                  
            if(resultStatus.isSuccess() && requestBody!= '' && responseBody != '' && requestBody!= null && responseBody != null){
                list<attachment> attachlist = new list<attachment>();
                attachment reqattachment = new attachment();
                reqattachment.Body = Blob.valueOf(requestBody);
                reqattachment.Name = 'Request.txt';
                reqattachment.ParentId=  exceptionRecord.Id;
                attachlist.add(reqattachment);
                
                attachment responseattachment = new attachment();
                responseattachment.Body = Blob.valueOf(responseBody);
                responseattachment.Name = 'Response.txt';
                responseattachment.ParentId=  exceptionRecord.Id;
                attachlist.add(responseattachment);
                
                database.insert(attachlist);
            }
        }
        System.debug(oMessage);
        return null;
    }   
    // Match Score Drop Down
    public List <SelectOption> getItems(){    
        List < SelectOption > options = new List < SelectOption > ();
        for (Decimal k=0.5;k<8;k=K+0.5) { 
            String val = string.valueof(k);
            options.add(new SelectOption(val, val));
        }
        return options;
    } 
    public Boolean getshowResultTable(){
        return showResultTable;
    }
    public Boolean getshowResultBlock(){
        return showResultBlock;
    }
    
    public pagereference addCustomerToDeal(){
        showErroMsg = false;
        try{
            string selectedduns = System.currentPagereference().getParameters().get('selectedDUnsId');
            dunsdetails SelectedDUNSinfo;
            system.debug('**&&'+finalList);
            for(dunsdetails detail : finalList){
                
                if(detail.DunsId == selectedduns ){
                    selectedduns = detail.DunsId;
                    SelectedDUNSinfo = detail;
                }
            }
            if(selectedduns != null){
                if(partneruser != null && partneruser[0].contact.accountId != null){
                    End_Customer__c duplicateEndCustomer = DealReg_CustomerSelectionHelper.checkEndCustomerDuplicate(selectedduns,null,partneruser[0].contact.Selected_Track_Account__c == null ? partneruser[0].contact.accountId: partneruser[0].contact.Selected_Track_Account__c);
                    if( duplicateEndCustomer == Null){
                        newendcutomer = new End_customer__c();
                        
                        newendcutomer.DUNS_Number__c = string.valueof(selectedduns);
                        newendcutomer.Name = SelectedDUNSinfo.DunsName;
                        newendcutomer.Mailing_street__c = SelectedDUNSinfo.Address;
                        newendcutomer.Mailing_city__c = SelectedDUNSinfo.City;
                        newendcutomer.Mailing_State__c = SelectedDUNSinfo.State;
                        newendcutomer.Zip_Code__c = SelectedDUNSinfo.PostalCode;
                        newendcutomer.Mailing_country__c = endCustomer.Mailing_country__c;
                        newendcutomer.Tax_Id__c = SelectedDUNSinfo.TaxId;
                        newendcutomer.Source_System__c = 'Deal Registration';
                        newendcutomer.Partner_Account__c = partneruser[0].contact.Selected_Track_Account__c == null ? partneruser[0].contact.accountId: partneruser[0].contact.Selected_Track_Account__c;
                        newendcutomer.Account_Department__c = EndCustomer.Account_Department__c;
                        newendcutomer.Segment__c = EndCustomer.Segment__c;
                        newendcutomer.Website__c = EndCustomer.Website__c;
                        newendcutomer.Created_using_Partner_D_B_Search__c = 'Yes';
                        newendcutomer.End_Customer_Selection__c = 'D&B Search';
                        database.insert(newendcutomer);
                        
                        /// Copy End Customer US#
                        End_Customer__c duplicateDuns = DealReg_CustomerSelectionHelper.EndCustomerDunsNumber(selectedduns);
                        if(duplicateDuns != Null){
                            newendcutomer.End_User_Account__c = duplicateDuns.End_User_Account__c;
                        }
                        database.update(newendcutomer); 
                        endCustomer = newendcutomer.clone(false,false,false,false);
                        System.debug('New end customer id:'+newendcutomer.id);
                        showResultTable = false;
                        showResultBlock = false;
                        showContactSection = true;
                        editableSearchPanel = false; 
                        showendcustduplicateerror = false;
                        
                        //Url Passing ariables
                        endCustomerName = newendcutomer.Name;
                        endCustomerId = newendcutomer.Id;
                        
                    }
                    else{
                        duperror = System.Label.Error_Message_Add_Existing_End_Customer_to_Deal +duplicateEndCustomer.Name ;
                        showendcustduplicateerror = true;
                        showResultTable = false;
                        showResultBlock = false;
                        showContactSection = false;
                        duplicateEndCustomer.Created_using_Partner_D_B_Search__c = 'No';
                        duplicateEndCustomer.End_Customer_Selection__c = 'Existing';
                        update duplicateEndCustomer;
                        
                        EndCustomer = duplicateEndCustomer;
                        editableSearchPanel = false;
                        
                        createNewContactForm(duplicateEndCustomer);
                    }
                }
            }
            else{
                errorMsg = System.Label.DealReg_no_record_selected;
                showErroMsg = true;
                showResultTable = true;
                showResultBlock = true;
                showContactSection = false;
                editableSearchPanel = true;
            }
            endCustomerContact = new End_Customer_Contact__c();  
        }
        catch(system.DmlException dmlex){
            exceptionMessage = 'DMLException:' +dmlex.getMessage();
            showexceptionMessage = true;        
        }
        catch(exception ex){
            exceptionMessage = 'Exception:' +ex.getMessage();
            showexceptionMessage = true;
            showresultblock = false;
            showContactSection = false;                
        }
        
        return null;
    }
    // no need
    public pagereference addContactToDealBasedOnValidCountries(){
        return null;
    }
    public List<SelectOption> getradiobuttonsItems() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('Yes','Yes')); 
        options.add(new SelectOption('No','No')); 
        return options; 
    }
    public pagereference addContactToDeal(){
        strSelectedvalue = '';
        
        try{
            if(endCustomerContact.Name == NULL || endCustomerContact.Email__c == NULL || endCustomerContact.Last_Name__c == NULL || endCustomerContact.Phone__c == NULL ){
                if(endCustomerContact.Name == NULL){
                    endCustomerContact.Name.addError(system.label.You_must_enter_a_value);                
                }
                if(endCustomerContact.Email__c == NULL){
                    endCustomerContact.Email__c.addError(system.label.You_must_enter_a_value); 
                }
                if(endCustomerContact.Last_Name__c == NULL){
                    endCustomerContact.Last_Name__c.addError(system.label.You_must_enter_a_value);
                }
                
                if(endCustomerContact.Phone__c == NULL){
                    endCustomerContact.Phone__c.addError(system.label.You_must_enter_a_value);
                } 
            }
            else{
                endCustomerContact.Source_System__c = 'Deal Registration';
                if(newendcutomer.Id == null){
                    endCustomerContact.End_Customer__c = endCustomer.Id; 
                }else{
                    endCustomerContact.End_Customer__c = newendcutomer.Id;
                }
                String[] strloginuseremail = System.UserInfo.getUserEmail().split('@');
        string strdomain = strloginuseremail[1].substringBefore('.');        
        String[] strenduseremail = endCustomerContact.Email__c.split('@');
        string strenduserdomain = strenduseremail[1].substringBefore('.');
        system.debug('strdomain ********'+strdomain );
        system.debug('strenduserdomain ********'+strenduserdomain );
                if(strdomain == strenduserdomain){           
                    bdisplayPopup = true;
                    system.debug('bdisplayPopup********'+bdisplayPopup );
                    return null;
                }
                database.insert(endCustomerContact);
                endCustomerContactName = endCustomerContact.Name;
                endCustomerContactId = endCustomerContact.Id; 
                String redirectToOppDetailPage= '/apex/OpportunityRedirectPage?&ent=Opportunity&nooverride=1&RecordType=012A0000000Vi0S&retURL=%2F006%2Fo&CF00NA00000063VT1= '+ pageUtils.encodeVariable(endCustomerName) +'&CF00NA00000063VT1_lkid='+ endCustomerId +'&CF00NA00000063VT6='+ pageUtils.encodeVariable(endCustomerContactName) +'&CF00NA00000063VT6_lkid='+endCustomerContactId+''+'&'+stringToAppend;
                PageReference page = new PageReference(redirectToOppDetailPage);
                return page;
            }
        }
        catch(system.DmlException dmlex){  exceptionMessage = 'DMLException:' +dmlex.getMessage();
            showexceptionMessage = true; }        
        
        catch(exception ex){exceptionMessage = 'Exception:' +ex.getMessage();           
            showexceptionMessage = true;
            showresultblock = false;
            showContactSection = false;                
        }
       
       /* if(strdomain.equalsIgnoreCase(strenduserdomain)){
            system.debug('bdisplayPopup********'+bdisplayPopup );
            bdisplayPopup = true;
        }*/
        
    
        return null;
    }
    public Pagereference closepopup(){
        system.debug('>>>>>>>>>>>>strSelectedvalue::'+strSelectedvalue);
        if(strSelectedvalue == 'No'){
            bdisplayPopup = false;
        }else{
                database.insert(endCustomerContact);
                endCustomerContactName = endCustomerContact.Name;
                endCustomerContactId = endCustomerContact.Id; 
                String redirectToOppDetailPage= '/apex/OpportunityRedirectPage?&ent=Opportunity&nooverride=1&RecordType=012A0000000Vi0S&retURL=%2F006%2Fo&CF00NA00000063VT1= '+ pageUtils.encodeVariable(endCustomerName) +'&CF00NA00000063VT1_lkid='+ endCustomerId +'&CF00NA00000063VT6='+ pageUtils.encodeVariable(endCustomerContactName) +'&CF00NA00000063VT6_lkid='+endCustomerContactId+''+'&'+stringToAppend;
                PageReference page = new PageReference(redirectToOppDetailPage);
                return page;
        }
        return null;
    }
    
    
    //Dunsdetail
    global class dunsdetails implements Comparable {
        global boolean selected{get;set;}
        global string Address{get;set;}
        global string DunsName{get;set;}
        global string City{get;set;}
        global string Country{get;set;}
        global string CountyCode{get;set;}
        global string DunsId{get;set;}
        global string OOB{get;set;}
        global string PostalCode{get;set;}
        global string State{get;set;}
        global string EmployeeSize{get;set;}
        global string TaxId{get;set;}
        
        
        global dunsdetails(Boolean selected, String Address, String DunsName, String City, String Country, String CountyCode, String DunsId, String OOB, String PostalCode, String State, String EmployeeSize, String TaxId){
            this.selected = selected;
            this.Address = Address;
            this.DunsName = DunsName;
            this.City = City;
            this.Country = Country;
            this.CountyCode = CountyCode;           
            this.DunsId = DunsId;
            this.OOB = OOB;
            this.PostalCode = PostalCode;
            this.State = State;
            this.EmployeeSize = EmployeeSize;
            this.TaxId = TaxId;
        }
        
        global Integer compareTo(Object ObjToCompare) {
            return DunsName.CompareTo(((dunsdetails)ObjToCompare).DunsName);
        }
    }
    // Method to split the error code,transaction id and error message from response   
    public string splitMethod(String text){
        if(text != null){
            list<String> textSplitValues = new list<String>();
            textSplitValues = text.split(':');
            String SplitValue = textSplitValues[1];
            //    System.Debug('**SplitValue**'+SplitValue);
            return SplitValue;
        }
        return null;
    }
    
    // Method to escape special characters in Input
    public string escapeSpecialChar(String text){
        if(text != null){
            string modifiedText = text.replace('"', '&quot;').replace('<', '&lt;').replace('>', '&gt;').replace('&', '&amp;');
            return modifiedText;
        }
        return null;
    }
}