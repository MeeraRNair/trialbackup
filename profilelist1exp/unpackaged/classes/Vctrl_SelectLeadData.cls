public class Vctrl_SelectLeadData {
    /****************************************************************************************************************
    Revision   Date          CR           Release No            Description
    1.0      1/22/2019    17042       Fy-20-DCS-0402        Created for handling All Lead Intermidiate Functionalities  
    
    ******************************************************************************************************************/
    static final String RECORD_TYPE_MASTERGROUP = 'Master Account';
    //public user leadAccowner;
    public String strpartnerTrackSearchField {
        set;
        get;
    }
    public Partner_Track__c partnerTrackData {
        set;
        get;
    }
    public Track__c trackData {
        set;
        get;
    }
    
    public class PTloadData {
        list<String> listaccountCategory;
        list<String> listgeographicalCoverage;
        list<String> listquotingFOBIncoterms;
        list<String> listquotingFreightTerms;
        list<String> listquotingPaymentTerms;
        list < string > listdistiPrice;
        list < string > listsplPart;
        list < string > listsplDisti;
        list < string > listreportSeg;
        list < string > liststoragePartner;
        list < string > listdellBusi;
        list < string > listpartnerStore;
        list < string > listpartnerPurchase;
        list < string > listauthorized;
        list < string > listprogramTier;
        list < string > listcountryCode;
        list < string > listrtmValues;
        list < string > listregion;
        list < string > listsecondPartnerTrk;
        list < string > listalloptions;
        list < string > listprimaryTrk;
        list < string > listemcClassification;
        list < string > listrelType;
        list < string > listcountryBusiness;
        list < string > listprogramTrack;
        list < string > listzone;
        list < string > listptTrack;
        list < string > listindustries;
        
       
        list < Partner_track__c > partnertrack;
        public PTloadData() {
            listgeographicalCoverage = New List<String>();
            listquotingFOBIncoterms = New List<String>();
            listquotingFreightTerms = New List<String>();
            listquotingPaymentTerms = New List<String>();
            listaccountCategory = New List<String>();
            listindustries = new list < string > ();
            listdistiPrice = new list < string > ();
            listsplPart = new list < string > ();
            listsplDisti = new list < string > ();
            listreportSeg = new list < string > ();
            liststoragePartner = new list < string > ();
            listdellBusi = new list < string > ();
            listpartnerStore = new list < string > ();
            listpartnerPurchase = new list < string > ();
            listauthorized = new list < string > ();
            listalloptions = new list < string > ();
            listprogramTier = new list < string > ();
            listsecondPartnerTrk = new list < string > ();
            listregion = new list < string > ();
            listcountryCode = new list < string > ();
            listrtmValues = new list < string > ();
            listprimaryTrk = new list < string > ();
            partnertrack = new list < Partner_track__c > ();
            listemcClassification = new list < string > ();
            listrelType = new list < string > ();
            listcountryBusiness = new list < string > ();
            listptTrack = new list < string > ();
            listprogramTrack = new list < string > ();
            listzone = new list < string > ();
           
            
        }
    }
     public class PRaccData {
        Partner_Request__c prData;
        list < Account > accData;
        list < string > countrieslist;
        list < Country__c > countries;
        list<Account> listSalesmotion;
        list<Partner_Track__c> listPartnertrack;
        map<string,string> mapGroupingids;
        Lead leaddata;
        public PRaccData() {
            countrieslist = new list < string > ();
            prData = new Partner_Request__c();
            accData = new list < Account > ();
            leaddata = new Lead();
            countries = new list < Country__c > ();
            listSalesmotion=new list<Account>();
            listPartnertrack=new list<Partner_Track__c>();
            mapGroupingids=new map<string,string>();
        }
    }
    
    @AuraEnabled
    public static String initialization(String partnerReqId) {//String partnerReqId
       // String partnerReqId1=ApexPages.currentPage().getParameters().get('PartnerId'); 
       // system.debug(partnerReqId1+' : ======partnerReqId=====>>>' + partnerReqId);
        Partner_Request__c pr = [SELECT GU_HQ_DUNSBusinessName__c,select_your_secondary_business_type__c,First_Name__c,Last_Name__c,Salutation__c,Email__c,Term_and_Condition_Agreement_New__c , Product_Focus_Non_GC__c, Sell_VCE_Products_Services__c, ISDUNSUpdated__c, Phone__c, GU_HQ_DUNSaddress__c, GU_HQ_DUNSCity__c, GU_HQ_DUNSCountry__c, GU_HQ_DUNSID__c, Reseller_Tax_ID__c, Account__r.Name, Account__c, address_Line_1__c, address_Line_2__c, address_Line_3__c,
                                 Agreed_on__c, Sponsoring_Distributor__c, Product_Focus__c, City__c, Org_Phone__c, Org_address_1__c, Org_address_2__c, Org_address_3__c, Org_City__c, Org_State__c, Company__c, Id, Org_Postal_Code__c, Org_Country__c, Org_Country__r.Name, Org_Country__r.Dell_Online_Country_Code__c, Linkage_Global_Ultimate_DUNS__c, Diversity_Certification__c, Other_diversity_certification__c,
                                 National_LGBT_Chamber_of_Commerce__c, Fax__c,National_Minority_Development_Council__c, GU_HQ_DUNSState__c, GU_HQ_DUNSPostalCode__c, DUNS_Number__c, National_Veteran_Business_Devel_Council__c, Small_Business__c, Women_s_Business_Eprise_National_Council__c, Mobile__c, Other_Certifications__c, considered_a_diverse_owned_business__c, States_Provinces_doing_business__c, Name,
                                 Postal_Code__c, Does_Business_As__c, Primary_Channel_Model__c, Org_Country__r.Code__c, Country__r.Code__c, Country__r.Name, Country__r.region__c, Term_and_Condition_Agreement__c, Number_of_Branches_Subsidiaries__c, Form_of_Organization__c, website__c FROM Partner_Request__c where id =: partnerReqId
                                ];
        PRaccData prd = new PRaccData();
        prd.prData = pr;
        string cntry;
        Lead l = new Lead();
        Map < ID, Country__c > countryObj = new Map < ID, Country__c > ([SELECT id, Name, Code__c, Is_Active_Partner_Country__c FROM Country__c where Is_Active_Partner_Country__c = true ORDER BY Name]);
        // prd.listcountries=[SELECT id,Name,Code__c,Is_Active_Partner_Country__c  FROM Country__c where Is_Active_Partner_Country__c=true];
        prd.countries = countryObj.values();
        list<String> countriesdata= (list<String>) JSON.deserialize(JSON.serialize(countryObj.keySet()), list<String>.class);
        if (countriesdata.contains(pr.GU_HQ_DUNSCountry__c)){
            cntry = countryObj.get(pr.GU_HQ_DUNSCountry__c).Name;
        }else{
            cntry = pr.GU_HQ_DUNSCountry__c;
        }
        system.Debug('Country Name : ' + cntry);
        prd.countrieslist = getselectOptions(l, 'Mg_Country_Name__c');
        system.debug('list Countries' + prd.countrieslist);
        if (pr.GU_HQ_DUNSBusinessName__c != null || pr.GU_HQ_DUNSaddress__c != null || pr.GU_HQ_DUNSID__c != null || pr.GU_HQ_DUNSCity__c != null || pr.GU_HQ_DUNSState__c != null || cntry != null || pr.GU_HQ_DUNSPostalCode__c != null){
            prd.accData = getAccounts(pr.GU_HQ_DUNSBusinessName__c, pr.GU_HQ_DUNSaddress__c, pr.GU_HQ_DUNSID__c, '', pr.GU_HQ_DUNSCity__c, pr.GU_HQ_DUNSState__c, cntry, pr.GU_HQ_DUNSPostalCode__c);
        }
        return JSON.serialize(prd);
    }
    @AuraEnabled
    public static string fetchPartnerListsData(String partnerTrack, String partnerProgramTrack) {
        Sales_Motion_Matrix__c sm;
        try {
            system.debug('===partnerTrack===>>' + partnerTrack);
            system.debug('===partnerProgramTrack===>>' + partnerProgramTrack);
            sm = [SELECT Partner_Program_Tier__c, RTM__c, Partner_Purchasing_Path__c, Partner_Storage_Purchasing_Path__c FROM Sales_Motion_Matrix__c where Primary_Partner_Track__c =: partnerTrack AND Secondary_Partner_Track__c =: partnerProgramTrack limit 1];
            system.debug('===sm===>>' + sm);
        } catch (exception e) {}
        return JSON.serialize(sm);
    }
    @AuraEnabled
    public static string fetchSellingMotionData(String partnerTrack, String partnerProgramTrack) {
        list < Sales_Motion_Matrix__c > sm;
        try {
            system.debug('===partnerTrack===>>' + partnerTrack);
            system.debug('===partnerProgramTrack===>>' + partnerProgramTrack);
            sm = [SELECT Sales_Motion__c FROM Sales_Motion_Matrix__c where Primary_Partner_Track__c =: partnerTrack AND Secondary_Partner_Track__c =: partnerProgramTrack];
            system.debug('===sm===>>' + sm);
        } catch (exception e) {}
        return JSON.serialize(sm);
    }
    @AuraEnabled
    public static string fetchTrackData(String country, String partnerTrack, String partnerProgramTrack, String zone) {
        
        Track__c trackData;
        try {
            system.debug('===zone===>>' + zone);
            system.debug('===country===>>' + country);
            system.debug('===partnerTrack===>>' + partnerTrack);
            system.debug('===partnerProgramTrack===>>' + partnerProgramTrack);
            Country__c c = [SELECT Code__c, Name FROM Country__c where Name =: country and Is_Active_Partner_Country__c = true];
            system.debug('Country : '+c);
            if(c !=null){
                trackData = [SELECT Name,Track_AffinityId__c FROM Track__c where Country_Code__c =: c.Code__c AND Partner_Program_Track__c =: partnerProgramTrack AND zone__c =: zone limit 1];
            // trackData = [SELECT Name FROM Track__c where Partner_Program_Track__c =: partnerTrack AND Partner_Program_Track__c =: partnerProgramTrack AND zone__c =: zone limit 1];
            //  trackData = [SELECT Name FROM Track__c where Country_Code__c=:c.Code__c AND Partner_Track__c =: partnerTrack AND Partner_Program_Track__c =: partnerProgramTrack AND zone__c =: zone limit 1];
            system.debug('===trackData===>>' + trackData);
            }
        } catch (exception e) {system.debug('Exception : '+e.getMessage());}
        return JSON.serialize(trackData);
    }
    @AuraEnabled
    public static list < Account > getAccounts(String accountName, String address, String guId, String website, string city, string state, string country, string postalcode) {
        list < Account > accountList;
        if(address != null && address.contains('\'')){
        address = address.replace('\'', '\\\'');
        }
        if(city != null && city.contains('\'')){
        city = city.replace('\'', '\\\'');
        }
        if(state != null && state.contains('\'')){
        state = state.replace('\'', '\\\'');
        }
        if(country != null && country.contains('\'')){
        country = country.replace('\'', '\\\'');
        }
        string searchstring = '( ';
        searchstring += (accountName != null && accountName != '') ? 'Name = \'' + accountName + '\'' : '';
        //address Fields Start
        //address
        if (searchstring == '( '){
            searchstring += (address != null && address != '') ? 'BillingStreet = \'' + address + '\'' : '';
        }else{
            searchstring += (address != null && address != '') ? ' OR BillingStreet = \'' + address + '\'' : '';
        }
        /*//city
if(searchstring == '( ')
searchstring+=(city != null && city != '')?'BillingCity  = \''+city+'\'':'';
else
searchstring+=(city != null && city != '')?' OR BillingCity  = \''+city+'\'':'';
//State
if(searchstring == '( ')
searchstring+=(state != null && state != '')?'BillingState = \''+state+'\'':'';
else
searchstring+=(state != null && state != '')?' OR BillingState = \''+state+'\'':'';
//Country
if(searchstring == '( ')
searchstring+=(country != null && country != '')?'BillingCountry = \''+country+'\'':'';
else
searchstring+=(country != null && country != '')?' OR BillingCountry = \''+country+'\'':'';*/
        //Postal Code
        if (searchstring == '( '){
            searchstring += (postalcode != null && postalcode != '') ? 'BillingPostalCode = \'' + postalcode + '\'' : '';
        }else{
            searchstring += (postalcode != null && postalcode != '') ? ' OR BillingPostalCode = \'' + postalcode + '\'' : '';
        }
        //address Fields End
        if (searchstring == '( '){
            searchstring += (guId != null && guId != '') ? 'D_U_N_S__c = \'' + guId + '\'' : '';
        } else{
            searchstring += (guId != null && guId != '') ? ' OR D_U_N_S__c = \'' + guId + '\'' : '';}
        system.debug('=searchstring==>>' + searchstring);
        if (searchstring == '( '){
            searchstring += (website != null && website != '') ? 'website = \'' + website + '\'' : '';
        }else{
            searchstring += (website != null && website != '') ? ' OR website = \'' + website + '\'' : '';}
        if (searchstring == '( '){
            searchstring = null;
        }else{
            searchstring += ' )';}
        String addresssearch = '( ';
        // address Condition Start
        //city
        if (addresssearch == '( '){
            addresssearch += (city != null && city != '') ? 'BillingCity  = \'' + city + '\'' : '';
        }else{
            addresssearch += (city != null && city != '') ? ' AND BillingCity  = \'' + city + '\'' : '';
        }
        //State
        if (addresssearch == '( '){
            addresssearch += (state != null && state != '') ? 'BillingState = \'' + state + '\'' : '';
        }else{
            addresssearch += (state != null && state != '') ? ' AND BillingState = \'' + state + '\'' : '';
        }
        //Country
        if (addresssearch == '( '){
            addresssearch += (country != null && country != '') ? 'Account_Country__c = \'' + country + '\'' : '';
        }else{
            addresssearch += (country != null && country != '') ? ' AND Account_Country__c = \'' + country + '\'' : '';
        }
        //recordType
        if (addresssearch == '( '){
            addresssearch += 'RecordType.Name = \'' + RECORD_TYPE_MASTERGROUP + '\' AND Master_Grouping_Status__c = \'Active\' And IsPartner  = true And Partner_Track__c  = null';
        }else{
            addresssearch += ' AND RecordType.Name = \'' + RECORD_TYPE_MASTERGROUP + '\' AND Master_Grouping_Status__c = \'Active\' And IsPartner  = true And Partner_Track__c  = null';
        }
        if (addresssearch == '( '){
            addresssearch = null;
        }else{
            addresssearch += ' )';
        }
        // address Condition End
        if (searchstring != null) {
            searchstring += (addresssearch != null && addresssearch != '') ? ' AND ' + addresssearch : '';
        } else {
            searchstring = (addresssearch != null && addresssearch != '') ? addresssearch : null;
        }
        string query;
        if (searchstring != null){
            query = 'select id,Name,Master_Grouping_Status__c,Billing_address_CN__c,Billingaddress,Account_Country__c,BillingCountry,BillingCity,BillingPostalCode,BillingState,website,BillingStreet,D_U_N_S__c,EMC_ID__c,Master_Group_Id__c from Account where ' + searchstring;
        }else{
            query = 'select id,Name,website,BillingStreet,Billing_address_CN__c,Account_Country__c,Master_Grouping_Status__c,Billingaddress,BillingCountry,BillingState,BillingPostalCode,BillingCity,D_U_N_S__c,EMC_ID__c,Master_Group_Id__c from Account where RecordTypeId=\'' + RECORD_TYPE_MASTERGROUP + '\'';
        }
            system.debug(searchstring + 'queeeery==>>' + query);
        if (searchstring != null && searchstring != ''){
            accountList = database.query(query);
        }
        return accountList;
    }
    @AuraEnabled
    public static Lead dataget(string accountId) {
        Lead leadUpdate = new Lead();
        Account accountData = new Account();
        system.debug('====>>Accid==========>>>' + accountId);
        if (accountId != null && accountId != '') { //,Quoting_FOB_Incoterms__c,Quoting_Freight_Terms__c,Quoting_Payment_Terms__c,
            accountData = [select Id, Name, Status__c,Quoting_EPOA_Flag__c, Billing_address_CN__c, Legal_address_City_Local__c, Legal_address_Country_Local__c, Quoting_Auto_book_Enabled__c, NameLocal, BillingStreet, Master_Group_Affinity_ID__c, Legal_address_Street_Local__c, Legal_address_Zip_Postal_Local__c,
                           Master_Group_Id__c, Account_Country__c, Partner_Master_Grouping_id__c, Form_of_Organization__c, Number_of_Branches_Subsidiaries__c, BillingCity, BillingCountry, Account_Country_Code__c, BillingPostalCode, Legal_address_State_Province_Local__c, BillingState,
                           D_U_N_S__c, website from Account where id =: accountId
                          ];
        }
        leadUpdate.Partner_Master_Grouping_id__c = accountData.Partner_Master_Grouping_id__c;
        leadUpdate.Master_Group_ID__c = accountData.Id; 
        leadUpdate.Mg_Name__c = accountData.Name;
        leadUpdate.Master_Group_Affinity_ID__c=accountData.Master_Group_Affinity_ID__c;
        leadUpdate.Mg_Local_Name__c =accountData.NameLocal;
        leadUpdate.Mg_address_Line_1__c = accountData.BillingStreet;
        //  leadUpdate.Mg_address_Line_2__c=accountData.BillingStreet;
        leadUpdate.Mg_City__c = accountData.BillingCity;
       leadUpdate.Mg_State__c = accountData.BillingState;
        leadUpdate.Mg_Country_Name__c = accountData.Account_Country__c;
        leadUpdate.Mg_Country_Code__c = accountData.Account_Country_Code__c;
        leadUpdate.Mg_Postal_Code__c = accountData.BillingPostalCode;
        leadUpdate.GU_Duns_number__c = accountData.D_U_N_S__c;
        leadUpdate.Mg_website__c = accountData.website;
        leadUpdate.Form_of_organization__c = accountData.Form_of_organization__c;
        leadUpdate.Number_of_Branches_Subsidiaries__c = accountData.Number_of_Branches_Subsidiaries__c;
        //Legal fieldsstart
        leadUpdate.Mg_Local_address_Line_1__c =accountData.Legal_address_Street_Local__c;
        leadUpdate.Mg_Local_address_Line_2__c = accountData.Legal_address_Street_Local__c;
        leadUpdate.Mg_Local_City__c =accountData.Legal_address_City_Local__c;
        leadUpdate.Mg_Local_Country_Name__c = accountData.Legal_address_Country_Local__c;
        leadUpdate.Mg_Local_State__c = accountData.Legal_address_State_Province_Local__c;
        leadUpdate.Mg_Local_Postal_Code__c = accountData.Legal_address_Zip_Postal_Local__c;
        //Legal fields end
        
        return leadUpdate;
    }
    @AuraEnabled
    public static list < String > getselectOptions(sObject objObject, string fld) {
        PTloadData ptl = new PTloadData();
        List < String > allOpts = new list < String > ();
        Schema.sObjectType objType = objObject.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        list < Schema.PicklistEntry > values =
            fieldMap.get(fld).getDescribe().getPickListValues();
        for (Schema.PicklistEntry a: values) {
            allOpts.add(a.getValue());
        }
        system.debug('allOpts ---->' + allOpts);
        allOpts.sort();
        return allOpts;
    }
    
    @AuraEnabled
    public static String getSalesMotionPickListValues() {
        PTloadData ptl = new PTloadData();
        
        Lead l = new Lead();
        ptl.listaccountCategory = Vctrl_SelectLeadData.getselectOptions(l, 'Account_Category__c');
        ptl.listgeographicalCoverage = Vctrl_SelectLeadData.getselectOptions(l, 'Geographical_Coverage__c');
        ptl.listquotingFOBIncoterms= Vctrl_SelectLeadData.getselectOptions(l, 'Quoting_FOB_Incoterms__c');
        ptl.listquotingFreightTerms= Vctrl_SelectLeadData.getselectOptions(l, 'Quoting_Freight_Terms__c');
        ptl.listquotingPaymentTerms= Vctrl_SelectLeadData.getselectOptions(l, 'Quoting_Payment_Terms__c');
        return JSON.serialize(ptl);
    }
    
    @AuraEnabled
    public static String getPickListValuesIntoList() {
        PTloadData ptl = new PTloadData();
        
        Lead l = new Lead();
        ptl.listreportSeg = Vctrl_SelectLeadData.getselectOptions(l, 'Reporting_Segmentation__c'); //Disti_PriceValuesList; 
        ptl.liststoragePartner = Vctrl_SelectLeadData.getselectOptions(l, 'Partner_Storage_Purchasing_Path__c');
       // ptl.authorized= Vctrl_SelectLeadData.getselectOptions(l,'authorized_Countries__c');
        ptl.listdistiPrice = Vctrl_SelectLeadData.getselectOptions(l, 'Distribution_All_Country_Price__c');
        ptl.listprogramTier = Vctrl_SelectLeadData.getselectOptions(l, 'Partner_Program_Tier__c');
        ptl.listpartnerPurchase = Vctrl_SelectLeadData.getselectOptions(l, 'Purchase_Path__c');
        ptl.listsplDisti = Vctrl_SelectLeadData.getselectOptions(l, 'SPL_Distribution_Pricing__c');
        ptl.listsplPart = Vctrl_SelectLeadData.getselectOptions(l, 'SPL_Partner_Recommend_Pricing__c');
        ptl.listprimaryTrk = Vctrl_SelectLeadData.getselectOptions(l, 'Partner_Track__c');
        ptl.listsecondPartnerTrk = Vctrl_SelectLeadData.getselectOptions(l, 'Partner_Program_Track__c');
        ptl.listcountryCode = Vctrl_SelectLeadData.getselectOptions(l, 'Country_Code__c');
        ptl.listrtmValues = Vctrl_SelectLeadData.getselectOptions(l, 'RTM__c');
        ptl.listregion = Vctrl_SelectLeadData.getselectOptions(l, 'region__c');
        // ptl.emcClassification=Vctrl_SelectLeadData.getselectOptions(l,'EMC_Classification__c');
        ptl.listrelType = Vctrl_SelectLeadData.getselectOptions(l, 'Relationship_Type__c');
        ptl.listptTrack = Vctrl_SelectLeadData.getselectOptions(l, 'Partner_Track__c');
        ptl.listprogramTrack = Vctrl_SelectLeadData.getselectOptions(l, 'Partner_Program_Track__c');
        ptl.listcountryBusiness = Vctrl_SelectLeadData.getselectOptions(l, 'Countries_doing_business_in__c');
        Track__c tr = new Track__c();
        ptl.listzone = Vctrl_SelectLeadData.getselectOptions(tr, 'zone__c');
        Partner_Track__c pt = new Partner_track__c();
        ptl.listindustries = Vctrl_SelectLeadData.getselectOptions(pt, 'Industries__c');
        ptl.listauthorized = Vctrl_SelectLeadData.getselectOptions(pt, 'authorized_Countries__c');
       
        
        
        system.debug('************ptl.partnertrack***' + ptl.partnertrack);
        return JSON.serialize(ptl);
    }
    @AuraEnabled
    public static string ucidValidation(string ucid, string masterGroupid) {
        Map<string,string> messgae=new Map<string,string>();
        try{
            Account acc=[select id,EMC_ID__c,Partner_Track__c,Master_Group_Id__c,Partner_Track__r.PPA_UCID__c,Master_Group_Id__r.Name from Account where EMC_ID__c=: ucid limit 1];
            if(acc == null){ 
                messgae.put('message','Invalid');
                return JSON.serialize(messgae);
            }else if(masterGroupid == acc.Master_Group_Id__c){
                messgae.put('message','Success');
                messgae.put('id',acc.Partner_Track__r.PPA_UCID__c);
                return JSON.serialize(messgae);
            }else{
                messgae.put('message','Other MG');
                messgae.put('id',acc.Master_Group_Id__c);
                messgae.put('name',acc.Master_Group_Id__r.Name);
                return JSON.serialize(messgae);
            }
        }catch(exception e){ messgae.put('message','Invalid');return JSON.serialize(messgae);}
    }
     @AuraEnabled
    public static String getpartnerTracks(String masterGroupId) {
        system.debug('==masterGroupId=>>' + masterGroupId);
        list<Partner_Track__c> ptr = new list<Partner_Track__c>();
        list<Account> accList = new list<Account>();
        Map<string, string> selectedPPAUcidPT =  new Map<string, string>();
        Set<string> ppaUcids = new set<string>();
        
        ptr = [select id,Primary_Sales_Motion_Affinity_ID__c,MUP_Company_Profile_ID__c,PPA_UCID__c, Partner_Track_Name__c, Master_Group_Id__c, Related_Account__c, Related_Account__r.Name, Related_Account__r.RTM__c, Name, Enabled_for_Services__c, Status__c, Partner_Grouping_ID__c, Track_Id__r.Name, Track_Id__r.zone__c,Track_Id__r.Track_AffinityId__c,
                                                Track_Id__c, Master_Group_Id__r.Name from Partner_Track__c where Master_Group_Id__c =: masterGroupId];
        system.debug('***@@@@' +ptr.size());
        for(Partner_Track__c pt: ptr){
        ppaUcids.add(pt.PPA_UCID__c);
            if(pt.PPA_UCID__c != null && pt.Partner_Grouping_ID__c != null){
        selectedPPAUcidPT.put(pt.PPA_UCID__c, pt.Partner_Grouping_ID__c);  
            }
        }
        accList = [select id,name,EMC_ID__c,rtm__c from account where EMC_ID__c IN:ppaUcids and Master_Group_Id__c =: masterGroupId];
        system.debug('****ppaUcidList :'+accList);
        PRaccData prd=new PRaccData();
        if(accList.size()>0){
        prd.listSalesmotion=accList;
        }
        if(ptr.size()>0){
         prd.listPartnertrack=ptr;   
        }
        system.debug('selectedPPAUcidPT : '+selectedPPAUcidPT);
        if(! selectedPPAUcidPT.isEmpty()){
            prd.mapGroupingids =selectedPPAUcidPT;
        }
        system.debug('***Return :' +prd.listSalesmotion);
        system.debug('***Return :' +prd.listPartnertrack);
        return JSON.serialize(prd);
        
    }
    
    
    @AuraEnabled
    public static map<String,string> ptDataGetting(string ptId) {
        Partner_Track__c ptr = [select id, Master_Group_Id__c,Master_Group_Affinity_Id__c, Contracted_Distributor__c, Partner_Account__c, Preferred_Distributor__c, Distribution_Channel__c,
                                Track_Id__c,Track_Id__r.Partner_Program_Track__c,Track_Id__r.zone__c,Track_Id__r.Track_AffinityId__c, Name, Diversity_Certification__c, Diversity_Certification_Other__c,
                                Partner_Track_AffinityId__c, Track_Affinity_Id__c, Disable_Rounding__c, Track_Id__r.Name, Product_Focus__c, Partner_Date_Agreed_to_PF_Terms_Cond__c,
                                Enabled_for_Services__c, Distribution_Incumbent_Partner__c, Partner_Profiled_Account_Flag__c, Legacy_Partner_Program_Ts_Cs__c,
                                Relationship_Type__c, Reporting_Segmentation__c, Distribution_All_Country_Price__c, Partner_Registration_Number__c,
                                SPL_Distribution_Pricing__c, SPL_Partner_Recommend_Pricing__c, VCE_Approved_Vendor__c, authorized_Countries__c, 
                                Partner_Program_Tier__c, Diverse_Owned_Business__c, Purchase_Path__c, Speciality_Product_Purchase_Path__c, DELLEMC_Ts_and_Cs_agreed_date__c, DELLEMC_Ts_and_Cs_agreement__c, EMC_Classification__c,
                                Legacy_Partner_Program_Ts_Cs_Date__c, Partner_Grouping_ID__c, Partner_Profiled_Account__c, Industries__c,
                                Partner_Track__c, Partner_Track_Account_Local_Name__c, Partner_Track_Name__c, Countries_doing_business_in__c, Status__c,
                                Multi_Track_Parent_ID__c,MUP_Company_Profile_ID__c,PPA_UCID__c, Primary_Sales_Motion_Affinity_ID__c from
                                Partner_Track__c where id =: ptId 
                               ];
        string saleamotiondata=fetchSellingMotionData(ptr.Partner_Track__c,ptr.Track_Id__r.Partner_Program_Track__c);
        string rtm;
        try{
        rtm=[select RTM__c from Account where Account_ID__c=:ptr.Primary_Sales_Motion_Affinity_ID__c limit 1].RTM__c;
        }catch(exception e){rtm=null;}
        map<string,string> returndata=new map<string,string>();
        returndata.put('partnerTrack',JSON.serialize(ptr));
        returndata.put('salesmotion',saleamotiondata);
        returndata.put('RTM',rtm);
        system.debug('PTR value===========>>>' + ptr);
        return returndata;
    }
    
    
    //Dependent Picklist
    @AuraEnabled
    public static Map < String, List < String >> getDependentMap(sObject objDetail, string contrfieldApiName, string depfieldApiName) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        
        Map < String, List < String >> objResults = new Map < String, List < String >> ();
        
        Schema.sObjectType objType = objDetail.getSObjectType();
        if (objType == null) {
            return objResults;
        }
        
        Map < String, Schema.SObjectField > objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)) {
            return objResults;
        }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        
        List < Schema.PicklistEntry > contrEntries = ctrlField.getDescribe().getPicklistValues();
        List < PicklistEntryWrapper > depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List < String > controllingValues = new List < String > ();
        
        for (Schema.PicklistEntry ple: contrEntries) {
            String label = ple.getLabel();
            objResults.put(label, new List < String > ());
            controllingValues.add(label);
        }
        
        for (PicklistEntryWrapper plew: depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(label);
                }
            }
        }
        return objResults;
    }
    
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = BASE64CHARS.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    private static final String BASE64CHARS = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    
    private static List < PicklistEntryWrapper > wrapPicklistEntries(List < Schema.PicklistEntry > ples) {
        return (List < PicklistEntryWrapper > )
            JSON.deserialize(JSON.serialize(ples), List < PicklistEntryWrapper > .class);
    }
    
    public class PicklistEntryWrapper {
        public String active {
            get;
            set;
        }
        public String defaultValue {
            get;
            set;
        }
        public String label {
            get;
            set;
        }
        public String value {
            get;
            set;
        }
        public String validFor {
            get;
            set;
        }
        public PicklistEntryWrapper() {}
        
    }
    
    // * Added To update Lead status to Account Suggestion rejected when PR was rejected in parner track selection tab
    //     *************************** 
    
    @AuraEnabled
    public static string fetchRejectPrPage(Id prDataId) {
     Partner_Request__C pr = new  Partner_Request__C(id=prDataId);        
        pr.Status__c = PartnerConstants.REG_STATUS_DUPLICATE;
        
        try{
            update pr;
        }catch( Exception e ){ 
            ApexPages.addMessages(e);   
        }
        
        return System.Page.PartnerRegistrationActionPanel.getUrl();
    }
    
 @AuraEnabled
     public static map<string,string> ucidSelectionPage(string strleadid, string strpartnerGroupingID, string strpartnerMasterGroupingID, string strppaUcid, string strucid) {
      system.debug('****strleadID :' +strleadid );
      map<string,string> mapReturnValue=new map<string,string>();   
      try{ 
      Lead leadObj = new lead();
      leadObj.id = strleadid;
          leadObj.Partner_Grouping_id__c = strpartnerGroupingID;
          leadObj.Partner_Master_Grouping_id__c = strpartnerMasterGroupingID;
          leadObj.PPA_UCID__c = strppaUcid;
          leadObj.Universal_Customer_ID_UCID__c = strucid;
      update leadObj;
         Lead leadobject = [select Partner_Request__c,Partner_Grouping_id__c,Partner_Master_Grouping_id__c,PPA_UCID__c from lead  where id =:strleadid limit 1];
      
      Partner_Request__c prObj = new Partner_Request__c();
          prObj.id = leadobject.Partner_Request__c;
          prObj.Send_Account_Suggestion_Is_Complete_Flag__c = true;
          prObj.Profile_UCID_as_Partner_Is_Complete_Flag__c = true;
          prObj.Status__c = 'Account Suggestion Submitted';

         if(leadobject.Partner_Grouping_id__c != null && leadobject.Partner_Master_Grouping_id__c != null && leadobject.PPA_UCID__c != null ){
          prObj.Update_Profile_Is_Complete_Flag__c = true;
          prObj.MUP_Profile_Creation__c = true;   
          }
      update prObj;
              string strreturnURL = leadobject.Partner_Request__c ;
              mapReturnValue.put('Message','Success');
              mapReturnValue.put('Value',strreturnURL);
              system.debug('****return' + mapReturnValue);
          return mapReturnValue;
          
        }catch (exception e) {
              system.Debug(e.getStackTraceString() + '=Exception  ====>>' + e.getMessage());
              mapReturnValue.put('Message','Fail');
              mapReturnValue.put('Value',e.getMessage());
              system.debug('****returnExc' + mapReturnValue);
             return mapReturnValue;
         }  
     }
    
    
    @AuraEnabled 
    public static map<string,string> saveToLead(Lead leaddata, String leadid, String recordType, String cancelURL, String retURL, String savenewurl,string partnerProgramTrackData,string prCountry) { 
        system.debug(partnerProgramTrackData+' : ==Lead--->>Data=>> : ' + leaddata+' : leadid : '+leadid);
         leaddata.id = leadid;
            map<string,string> msg=new map<string,string>();
        user leadAccowner = new user();
        try{
        Solution_Provider_Territory_Details__c spTerritoryDetails= [Select Id,Name,APID_Owner_Name__c,APID_Owner_Badge__c,APID_Territory_ID__c,Partner_Track__c,Partner_Program_Track__c,APID_Territory_Name__c,APID_Legal_Country__c FROM Solution_Provider_Territory_Details__c where 
                                           Partner_Track__c =: leaddata.Partner_Track__c AND APID_Legal_Country__c =: prCountry AND Partner_Program_Track__c =: partnerProgramTrackData limit 1]; 
         system.debug('===Solution Provider ====>  : '+spTerritoryDetails);
            if(spTerritoryDetails.APID_Owner_Badge__c != null  && spTerritoryDetails.APID_Owner_Name__c != null){
           leadAccowner = [Select id from user where Badge_Number__c =:spTerritoryDetails.APID_Owner_Badge__c ]; 
       }
      Sales_Channel_Group__c salesChannel =[SELECT Id FROM Sales_Channel_Group__c WHERE Group_ID__c =: spTerritoryDetails.APID_Territory_ID__c limit 1];
          
       
        if(spTerritoryDetails.APID_Owner_Badge__c != null  && spTerritoryDetails.APID_Owner_Name__c != null){
          leaddata.Account_Owner__c = leadAccowner.Id;  
          leaddata.Territory_Assignment__c = salesChannel.Id;
        }
        }catch(exception e){}
        
    
        //  system.debug('==leadid=>>'+leadid);
        // system.debug('==recordType=>>'+recordType);
        // system.debug('==cancelURL=>>'+cancelURL);
            try{
                if(leaddata.Partner_Program_Track__c=='Commercial Distributor'){
                leaddata.Partner_Program_Track__c=null;//'Commercial Distributor'; 
                }
            system.debug('==Lead--->>Data=>>' + leaddata);
            update leaddata;
            system.debug('****??' + leaddata);
            string returnURL = '/' + leadid + '/e?RecordType=' + recordType +
                '&cancelURL=' + cancelURL +
                '&retURL=' + retURL +
                '&save_new_url=' + savenewurl;
            msg.put('message','success');
            msg.put('value',returnURL);
            return msg;
        } catch (exception e) {
            system.Debug(e.getStackTraceString() + '=Exception  ====>>' + e.getMessage());
            msg.put('message','fail');
            msg.put('value',e.getMessage());
            return msg; 
        }
        
    }
    
    
    @AuraEnabled
    public static string ucidValidate(String strucid) {
        
        //System.debug(ucid+'UCID Record'+search_UcidFromEMC.sendUCID(ucid));
        return ValidateUCIDNumber.sendUCID(strucid);
        
    }
    
    
   
    
     @AuraEnabled
    public static string getMupDetails(string mupId) {
    final string SANDBOX = 'Sandbox';
    string jsondata = '';
    try
    {
     string username='';
     string password='';
     string strEndPoint='';
     string strAuthenticationApi = '';   
     if(StaticFactory.getEnvironment() == SANDBOX)
     {
     // username=Label.MUP_Integration_User_Name_SB;
    //  password=Label.MUP_Integration_User_Pwd_SB;
      strEndPoint=Label.MUP_CompanyProfileGet_EndPoint_SB;
      strAuthenticationApi = Label.MupLayer7ApiKey_SB;   
    } else
       { 
     // username=Label.MUP_Integration_User_Name_Prod;
     // password=Label.MUP_Integration_User_Pwd_Prod;
      strEndPoint=Label.MUP_CompanyProfileGet_EndPoint_Prod;
      strAuthenticationApi = Label.MupLayer7ApiKey_PROD;     
       }
  //  Blob headerValue = Blob.valueOf(username+ ':' + password);
  //  String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
 
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    request.setEndpoint(strEndPoint+mupId);
    request.setHeader('apikey', strAuthenticationApi);    

  //  request.setHeader('Authorization', authorizationHeader);
    request.setMethod('GET');
     System.debug('Request------------'+request);
        
    HttpResponse response = http.send(request); 
    System.debug('Responsecode------------'+response.getstatuscode());
    System.debug('Responsecode------------'+response);
     if(response.getstatuscode() == 302|| response.getstatuscode() == 404 || response.getstatuscode() == 500) { 
       jsondata = response.getbody();  
    } else {
        jsondata = 'empty';        
   }
  }
     catch(Exception ex)
     {jsondata = null;}
   return jsondata;
 
}
}