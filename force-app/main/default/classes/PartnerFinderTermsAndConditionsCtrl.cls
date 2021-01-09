public class PartnerFinderTermsAndConditionsCtrl {

    public PartnerFinderTermsAndConditionsCtrl(){}
    
    public PageReference doOnload(){
      
      String countryCode = null;
      String termsURL = null;
      
        final User currentUser = 
          [select contact.account.account_country_code__c 
          from user 
          where id = :UserInfo.getUserId()];
        if( currentUser != null 
            && currentUser.contact != null 
            && currentUser.contact.account != null){
            countryCode = currentUser.contact.account.account_country_code__c;
        }
      if(al.StringUtils.isNotBlank(countryCode)){
            try{
            Country__c country = 
              [select Dell_Partner_Finder_Terms_Conditions_URL__c 
              from Country__c 
              where code__c = :countryCode];
                if(country != null){
                  termsURL = country.Dell_Partner_Finder_Terms_Conditions_URL__c;
                }
            }catch(QueryException e){}
      }
        if(StringUtils.isNotBlank(termsURL)){
          final PageReference ref = new PageReference(termsURL);
          ref.getParameters().put('l', UserInfo.getLanguage());
          return ref;
        }
      return System.Page.PartnerFinderTermsAndConditionsDefault;
    }
}