/***************************************************************************************************************************************************************
* 
* Name          : PortalQuickLinksComponentCtrlExt
* Description   : Controller to support various links that are displayed in quick links section in parnter portal
* ---------------------------------------------------------------------------------------
* Revision  Name            Date                 CR                                         Description
* 1.0       Yeswanth      17.07.2017            14647                            Deal Reg Visibility for all Distributor/Reseller users
***************************************************************************************************************************************************************/

public class PortalQuickLinksComponentCtrlExt {
    private string countryEnableDealReg { get; private set; }
    private boolean userEnableDealReg { get; private set; }
    public final string defaultCountryCode = 'US';
    public boolean enableDealReg { get; private set; }
    public string userLanguage { get; private set; }
    //Manju - R 15.3 - CR 8844 - To include Lead Management flag checking to enable users to Register/View Leads
    public boolean enableLeadMgmt { get; private set; }
    private boolean userEnableLeadMgmt { get; private set; }
    private string countryEnableLeadMgmt { get; private set; }
    //1.0
    public String accName{get;private set;}
    
    
    public PortalQuickLinksComponentCtrlExt(){
        //Manju - R 15.3 - Including Enable_Partner_Lead_Management__c field in the query
        //1.0 added contact.account.name field in the query 
        User u = [SELECT Enable_Partner_Deal_Registration__c, Enable_Partner_Lead_Management__c, Contact.Account.Account_Country_Code__c,contact.account.name,LanguageLocaleKey,contact.Selected_Track_Account__c,contact.Selected_Track_Account__r.name
                    FROM User WHERE Id = :UserInfo.getUserId()];
        userEnableDealReg = u.Enable_Partner_Deal_Registration__c;
        userLanguage = u.LanguageLocaleKey;
        string countryCode = null;
        if(u.contact.Selected_Track_Account__c != null){
           accName = u.contact.Selected_Track_Account__r.name;
         }
        system.debug('****' +accName);
        //R 15.3 - CR 8844
        userEnableLeadMgmt = u.Enable_Partner_Lead_Management__c;
        if(u.Contact.Account.Account_Country_Code__c == null || u.Contact.Account.Account_Country_Code__c.length() == 0){
            // Fenny: if the country code is empty, give it US as default
            countryCode = defaultCountryCode;
        }else{
            countryCode = u.Contact.Account.Account_Country_Code__c;
        }
        //Manju - R 15.3 - Including Lead_Management_Enabled__c field in the query
        List<Country__c> countries = [SELECT Deal_Registration_Enabled__c, Lead_Management_Enabled__c FROM Country__c WHERE Code__c = :countryCode];
        if((countries != null) && (countries.size() > 0)){
            countryEnableDealReg = countries[0].Deal_Registration_Enabled__c;
            //Manju - R 15.3
            countryEnableLeadMgmt = countries[0].Lead_Management_Enabled__c;
        }else{
            // Fenny: if account country code not found in country object, query for US as default
            countries = [SELECT Deal_Registration_Enabled__c, Lead_Management_Enabled__c FROM Country__c WHERE Code__c = :defaultCountryCode];
            countryEnableDealReg = countries[0].Deal_Registration_Enabled__c;
            //Manju - R 15.3
            countryEnableLeadMgmt = countries[0].Lead_Management_Enabled__c;
        }
        enableDealReg = (countryEnableDealReg == 'Yes') && userEnableDealReg;
        //R 15.3 - CR 8844
        enableLeadMgmt = (countryEnableLeadMgmt == 'Yes') && userEnableLeadMgmt;
    }
}