@IsTest
private class PartnerFinderTermsAndConditionsCtrlTest {

    private static final String TEST_URL = 'http://google.com/test123?l=ja';
    private static final String TEST_COUNTRY = 'US';
    private static final String TEST_LANGUAGE = 'en_us';
    
    private static testmethod void testAsPartnerUser(){
        
        User partner = null;
        try{
            partner = [
                select id,name,contact.account.account_country_code__c
                from User 
                where Profile.UserType = 'PowerPartner' 
                and IsActive = true 
                and contact.account.account_country_code__c = :TEST_COUNTRY
                and LanguageLocaleKey = :TEST_LANGUAGE
                limit 1];
            
        }catch(QueryException e){}
            System.assert(partner!=null,'Environment Dependency:  no qualified partner users are available in this org (org ' 
                + UserInfo.getOrganizationId() 
                + ').  In order for this test to pass, please add at least one partner user with account ACCOUNT_COUNTRY_CODE__C equal to ' 
                + TEST_COUNTRY 
                + ' and language equal to ' 
                + TEST_LANGUAGE 
                + '.');
        
        Country__c country = null;
        try{
            country = [
                select Dell_Partner_Finder_Terms_Conditions_URL__c 
                from country__c 
                where code__c = :TEST_COUNTRY limit 1];
        }catch(QueryException e){}
        System.assert(country!=null,'Environment Dependency:  no ' 
            + TEST_COUNTRY 
          + ' country record exists in your org.  In order for this test to pass, please add a country record with CODE__C equal to ' 
          + TEST_COUNTRY 
          + '.');
        
        country.Dell_Partner_Finder_Terms_Conditions_URL__c = TEST_URL;
        country.Inc_Vendor_Name__c = 'Dell Achievers'; // Fenny added on 1-Apr-2013
        country.Inc_Vendor_End_Point__c = 'test'; // Fenny added on 1-Apr-2013
        update country;

        /*System.runAs(partner){
            final PageReference pageRef = (new PartnerFinderTermsAndConditionsCtrl()).doOnload();
            System.assertNotEquals(null,pageRef);
            System.assertEquals(
                al.StringUtils.lowerCase(TEST_LANGUAGE),
                al.StringUtils.lowerCase(pageRef.getParameters().get('l'))
            );
            System.assertEquals(
                al.StringUtils.substringBefore(TEST_URL,'?'),
                al.StringUtils.substringBefore(pageRef.getUrl(),'?')
            );
        }*/

    } 
    
    private static testmethod void testAsPartnerUserBadCountryCode(){
        User partner = null;
        try{
            partner = [
                select id,name,contact.account.account_country_code__c 
                from User 
                where Profile.UserType = 'PowerPartner' 
                and IsActive = true 
                and contact.account.account_country_code__c = :TEST_COUNTRY
                and LanguageLocaleKey = :TEST_LANGUAGE 
                and contact.account.Is_Enabled_for_Incentives__c = false
                limit 1];
        }catch(QueryException e){}
            System.assert(partner!=null,'Environment Dependency:  no qualified partner users are available in this org (org ' 
                + UserInfo.getOrganizationId() 
                + ').  In order for this test to pass, please add at least one partner user with account ACCOUNT_COUNTRY_CODE__C equal to ' 
                + TEST_COUNTRY 
                + ' and language equal to ' 
                + TEST_LANGUAGE 
                + '.');
        
        Account account = [select account_country_code__c from Account where id = :partner.contact.accountid];
        account.account_country_code__c = 'XX';
        update account;
        
        //System.runAs(partner){
          final PageReference pageRef = (new PartnerFinderTermsAndConditionsCtrl()).doOnload();
          System.assertNotEquals(null,pageRef);
          System.assertEquals(
              System.Page.PartnerFinderTermsAndConditionsDefault.getUrl(),
              pageRef.getUrl()
          );
        //}
    } 
    
    private static testmethod void testAsStandardUser(){
      final PageReference pageRef = (new PartnerFinderTermsAndConditionsCtrl()).doOnload();
        System.assertNotEquals(null,pageRef);
        System.assertEquals(
            System.Page.PartnerFinderTermsAndConditionsDefault.getUrl(),
            pageRef.getUrl()
        );
    }     

    
}