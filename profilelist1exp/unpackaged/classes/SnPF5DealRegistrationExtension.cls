/***********************************************************
* Name          : SnPF5DealRegistrationExtension 
* Description   : Extension for F5 Registration Form
* ---------------------------------------------------------
* Revision      Release     Name        Date            Description
* 1.0           14.5        Pat Redor   04.09.2013      Initial requirements implemented
* 2.0           14.10       Pat Redor   08.12.2013      Change save override method to a cancel override method
* 3.0           16.10       Fahmin      21.09.2015      CR11933 Remove Product Type Mapping
* 4.0           17.02       Fahmin      11.11.2015      CR12126 & CR12127 Replace Partner with pt and remove reseleer firstname,lastname and email
************************************************************/
public class SnPF5DealRegistrationExtension {
    
    public S_P_Vendors__c svRec;
    public ApexPages.StandardController controller;
    public String dist = '';
    public String sysEng = '';
   
    public String confirmationNum {get; set;}
    public Boolean warn {get; set;}
    public Boolean isPending {get; set;}
    
    
    public SnPF5DealRegistrationExtension(ApexPages.StandardController controller) {
        this.controller = controller;
        this.svRec = (S_P_Vendors__c)controller.getRecord();
        this.isPending = (this.svRec.S_P_Deal_Status__c == 'Pending' || this.svRec.S_P_Deal_Status__c == 'Incomplete' || this.svRec.S_P_Deal_Status__c == null) ? true : false;
        this.warn = (this.svRec.Contact_Name__c == null || this.svRec.Automated__c == false) ? true : false;
    }
    
    // Main method in generating the F5 Form URL
    public String getGeneratedF5URL(){
        String f5URL = '';
        
        f5URL = getF5VendorURL() + getOppPrimaryProdRegionF5Equiv() + '&ext_id=' + this.svRec.Id + '&' +
                generateEndUserInformation() + generateResellerInformation() + generateDealInformation();
        system.debug('F5 URL----'+f5URL);
        return f5URL;
    }
    
    public String getF5VendorURL(){
        return [SELECT Vendor_Name__c, Vendor_URL__c FROM S_P_Vendor_Automation__c
                WHERE Vendor_Name__c = 'F5' LIMIT 1].Vendor_URL__c;
    }
    
    // Get the equivalent code for Region
    public String getOppPrimaryProdRegionF5Equiv(){
        // Form setting based on Region; Build of Distributor Name;
        if(this.svRec.Opportunity__r.Primary_Product_Delivery_Address_Region__c == 'NORTH AMERICA'){
            if(this.svRec.Distributor_Name__c != null)
                this.dist = 'NA - ' + this.svRec.Distributor_Name__c.split(';')[0];
            return 'NA';
        } else if(this.svRec.Opportunity__r.Primary_Product_Delivery_Address_Region__c == 'EMEA' ||
                  this.svRec.Opportunity__r.Primary_Product_Delivery_Address_Region__c == 'EC-EMEA'){
            if(this.svRec.Distributor_Name__c != null)
                this.dist = 'EMEA - ' + this.svRec.Distributor_Name__c.split(';')[0];
            return 'EMEA';
        } else if(this.svRec.Opportunity__r.Primary_Product_Delivery_Address_Region__c == 'APJ'){
            if(this.svRec.Distributor_Name__c != null)
                this.dist = 'APAC - ' + this.svRec.Distributor_Name__c.split(';')[0];
            return 'APAC';
        } else if(this.svRec.Opportunity__r.Primary_Product_Delivery_Address_Region__c == 'LATAM'){
            if(this.svRec.Distributor_Name__c != null)
                this.dist = 'LATAM - ' + this.svRec.Distributor_Name__c.split(';')[0];
            return 'LATAM';
        }
        
        // Temporarily default to 'NA'
        return 'NA';
    }
    
    public String encodeStringToURL(String txt){
        try {
            return EncodingUtil.urlEncode(txt, 'UTF-8');
        } catch (NullPointerException npe) { }
        
        return '';
    }
    
    public String generateEndUserInformation(){
        String endUserInfo = '';
        String[] contactNameSplit;
        try {
            contactNameSplit = this.svRec.Contact_Name__c.split(' ');
            
            
            String countryName='';
            if('UNITED STATES'.equalsIgnoreCase(this.svRec.Country__c) &&  'NA'.equals(getOppPrimaryProdRegionF5Equiv())){
                countryName='US';
            }else{
                countryName=this.svRec.Country__c;
            }
        
            endUserInfo = 'first_name=' + encodeStringToURL(contactNameSplit[0]) + '&' +
                          'last_name=' + encodeStringToURL((contactNameSplit.size() > 1 ? contactNameSplit[1] : contactNameSplit[0])) + '&' +
                          'title=' + encodeStringToURL(this.svRec.Role__c) + '&' +
                          'company=' + encodeStringToURL(this.svRec.Customer_Name__c) + '&' +
                          'v00N30000000zRur=' + encodeStringToURL(this.svRec.City__c) + '&' + 
                          'v00N30000000zRvB=' + encodeStringToURL(this.svRec.State__c) + '&' + 
                          'v00N30000000zRwE=' + encodeStringToURL(countryName) + '&' + 
                          'phone=' + encodeStringToURL(this.svRec.Phone__c) + '&' + 
                          'email=' + encodeStringToURL(this.svRec.Email__c) + '&' +
                          'url=' + encodeStringToURL(this.svRec.Website__c) + '&' +
                          'industry=' + encodeStringToURL(this.svRec.Industry__c) + '&';
        } catch(NullPointerException npe){
        }
        
        return endUserInfo;
    }
    
    public String generateDealInformation(){
        String dealInfo = '';
        
        dealInfo = //'v00D00000000hXqv=' + encodeStringToURL(this.svRec.Product_Type__c) + '&' +     //SnP3600 - Remove Product Type Mapping
                   'pn=' + generateProjectNameAndRegisteredProducts() + '&' +
                   'v00N50000001HlQJ=' + encodeStringToURL(this.svRec.Application_Vendor__c) + '&' + 
                   'v00N30000000zSWI=' + encodeStringToURL(this.svRec.Estimated_Closed_Date__c) + '&' + 
                   'v00N50000001IQdu=' + encodeStringToURL(this.svRec.Business_Type__c) + '&' + 
                   'lead_source=' + encodeStringToURL(this.svRec.Lead_Source__c) + '&' +
                   'v00N30000000yaZR=' + encodeStringToURL(this.svRec.Project_Description__c) + '&';
        
        return dealInfo;
    }
    
    public String generateProjectNameAndRegisteredProducts(){
        String projNameAndRegProd = '';
        Map<String, String> f5ProdMap = new Map<String, String>();
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>([SELECT OpportunityId, 
                                                                           PricebookEntry.Product2.Description FROM OpportunityLineItem
                                                                           WHERE OpportunityId = :this.svRec.Opportunity__c 
                                                                           ORDER BY PricebookEntry.Product2.Description ASC]);
       
        // Build Project Name first
        projNameAndRegProd += encodeStringToURL(oliList.get(0).PricebookEntry.Product2.Description) + '-' + encodeStringToURL(this.svRec.Name) + '&';
        
        // Set all products from the custom setting in a map
        for(S_P_F5_Product_Mapping__c prod : [SELECT F5_Product_Parameter_Name__c,Name 
                                                FROM S_P_F5_Product_Mapping__c])
            f5ProdMap.put(prod.Name, prod.F5_Product_Parameter_Name__c);
        
        // Concatenate existing products in the registered product part of the URL build
        for(OpportunityLineItem oli : oliList)
            projNameAndRegProd += f5ProdMap.get(oli.PricebookEntry.Product2.Description) + '=1&';
        
        return projNameAndRegProd;
    }
    
    public String generateResellerInformation(){
        String resInfo = '';
        User usr = [Select Id,phone From User u Where Id = :UserInfo.getUserId() limit 1];
        //TODO to continue
        //CR12127 - Remove Reseller FirtstName, LastName and Email
    /*             resInfo = 'pt=Dell&partnerReg=1&v00N00000005GmyI=Dell' + '&' +
                  'resCountry=' + encodeStringToURL(this.svRec.Opportunity__r.Account.Account_Country__c) + '&' +
                  'v00N30000000htRj=' + encodeStringToURL(this.svRec.Opportunity__r.Owner.FirstName) + '&' +
                  'v00N30000000htRl=' + encodeStringToURL(this.svRec.Opportunity__r.Owner.LastName) + '&' + 
                  'v00N30000000htRn=' + encodeStringToURL(this.svRec.Sales_Rep_s_Phone__c) + '&' + 
                  'v00N30000000htRm=' + encodeStringToURL(getDefaultEmail(this.svRec.Opportunity__r.Account.Account_Country__c)) + '&' + 
                  'se=' + (fetchOppSystemEngineer() != '' ? 1 : 0) + '&' + 
                  'se_first_name=' + encodeStringToURL((this.sysEng != '' ? this.sysEng.split(';')[0] : '')) + '&' +
                  'se_last_name=' + encodeStringToURL((this.sysEng != '' ? this.sysEng.split(';')[1] : '')) + '&' + 
                  'distributor=' + encodeStringToURL(this.dist) + '&'; */
                  
                  
                   resInfo = 'pt=Dell&partnerReg=1&v00N00000005GmyI=Dell' + '&' +
                  'resCountry=' + encodeStringToURL(this.svRec.Opportunity__r.Account.Account_Country__c) + '&' +
                  'v00N30000000htRj=' + encodeStringToURL(this.svRec.Opportunity__r.Owner.FirstName) + '&' +
                  'v00N30000000htRl=' + encodeStringToURL(this.svRec.Opportunity__r.Owner.LastName) + '&' + 
                  'v00N30000000htRn=' + encodeStringToURL(this.svRec.Opportunity__r.Owner.Phone) + '&' + 
                  'v00N30000000htRm=' + encodeStringToURL(getDefaultEmail(this.svRec.Opportunity__r.Account.Account_Country__c)) + '&' + 
                  'se=' + (fetchOppSystemEngineer() != '' ? 1 : 0) + '&' + 
                  'se_first_name=' + encodeStringToURL((this.sysEng != '' ? this.sysEng.split(';')[0] : '')) + '&' +
                  'se_last_name=' + encodeStringToURL((this.sysEng != '' ? this.sysEng.split(';')[1] : '')) + '&' + 
                  'se_email=' + encodeStringToURL((this.sysEng != '' ? this.sysEng.split(';')[2] : '')) + '&' + 
                  
                  'distributor=' + encodeStringToURL(this.dist) + '&';
                  
        System.debug('*** XSABER DEBUG ***' + this.sysEng);
        return resInfo;    
    }
    
    public String fetchOppSystemEngineer(){
        List<OpportunityTeamMember> otmList = new List<OpportunityTeamMember>([SELECT LastModifiedDate,OpportunityId,TeamMemberRole,User.FirstName, User.LastName,User.email, User.Phone 
                                      FROM OpportunityTeamMember 
                                      WHERE TeamMemberRole IN ('Sys Eng')
                                      AND OpportunityId = :this.svRec.Opportunity__c 
                                      ORDER BY LastModifiedDate DESC]);
        
        //if(otmList.size() > 0){
           for(OpportunityTeamMember optyTeam:otmList){
            if('Sys Eng'.equals(optyTeam.TeamMemberRole)){
                this.sysEng = optyTeam.User.FirstName + ';' + optyTeam.User.LastName + ';' + optyTeam.User.email;
            }
        }                                      
            
        otmList.clear();
           
        return sysEng;
    }
    
    public String getDefaultEmail(String resCountry){
        List<SnP_F5_Default_Emails__c> dEmail = new List<SnP_F5_Default_Emails__c>([SELECT Name, Default_Email__c FROM SnP_F5_Default_Emails__c WHERE Name = :resCountry]);
        
        if(dEmail.size() < 1 || dEmail.size() > 1)
            return 'dellteam@f5.com';
        return dEmail.get(0).Default_Email__c;
    }
}