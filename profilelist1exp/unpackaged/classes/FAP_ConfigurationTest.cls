/**
REVISION HISTORY
================
Version    Author    Date      Release#  CR#    Description
-------    ------    ----      --------  ---    -----------
1.0      Fenny    13-Apr-2012    13.4    7055  Display PartnerDirect logo respectively to partner status & type
**/
@IsTest
private class FAP_ConfigurationTest {

  // Ver 1.0: 
  private static testmethod void testPartnerDirectLogoURL(){
    FAP_Configuration config = FAP_Configuration.getInstance();
    
    system.assertEquals(true, config.partnerDirectLogos.size() > 0);
    for(string value : config.partnerDirectLogos.values()){
      system.assertEquals(true, FAP_StringUtils.startsWithIgnoreCase(value, '/resource'));
    }
  }
  
    private static testmethod void testGoogleMapsApiKey(){
        FAP_Configuration config = FAP_Configuration.getInstance();
        system.assertEquals(true, config.googleMapsApiKey!=null);
    }
    
    private static testmethod void testGoogleMapsApiKeySites(){
        FAP_Configuration config = FAP_Configuration.getInstance();
        system.assertEquals(true, config.googleMapsApiKeyForSites!=null);
    }
    
    private static testmethod void testImageUrlRecommendedPartner(){
        FAP_Configuration config = FAP_Configuration.getInstance();
        system.assertEquals(true, config.imageUrlRecommendedPartner!=null);
    }
    
    private static testmethod void testSearchHelpUrl(){
        FAP_Configuration config = FAP_Configuration.getInstance();
        system.assertEquals(true, config.searchHelpUrl!=null);
    }
    
    private static testmethod void testTermsAndConditionsUrl(){
        FAP_Configuration config = FAP_Configuration.getInstance();
        system.assertEquals(true, config.termsAndConditionsUrl!=null);
    }

    private static testmethod void testSearchScreenBasicSearchFields(){
        FAP_Configuration config = FAP_Configuration.getInstance();
        system.assertEquals(true, config.searchScreenBasicSearchFields!=null);
      
        List<FAP_FieldConfiguration> fieldConfigurations = FAP_Configuration.getInstance().searchScreenBasicSearchFields;

        System.assertNotEquals(null,fieldConfigurations);
    }
    
    private static testmethod void testDetailScreenCompanyBasicFields(){
        
        FAP_Configuration config = FAP_Configuration.getInstance();
        system.assertEquals(true, config.detailScreenCompanyBasicFields!=null);

        List<FAP_FieldConfiguration> fieldConfigurations = FAP_Configuration.getInstance().detailScreenCompanyBasicFields;

        System.assertNotEquals(null,fieldConfigurations);
    }
 
    private static testmethod void testParseDoubleList(){
      final List<Integer> parsed = FAP_Configuration.parseIntegerList('5|10|xyz|-4');
        System.assertNotEquals(null,parsed);
        System.assertEquals(3,parsed.size());
        System.assertEquals(5,parsed.get(0));
        System.assertEquals(10,parsed.get(1));
        System.assertEquals(-4,parsed.get(2));
    }
    private static testmethod void testAllMethods(){
          FAP_Configuration config = FAP_Configuration.getInstance();
          system.assertEquals(true, config.searchScreenAdvancedSearchFields!=null);
          system.assertEquals(true, config.searchScreenFieldsInResultList!=null);
          system.assertEquals(true,config.searchMinFieldsforPartnerLoc!=null);
          system.assertEquals(true,config.searchMinFieldsforAccount!=null);
          system.assertEquals(true,config.detailPartnerTrackFields!=null);
          system.assertEquals(true,config.detailMasterGroupFields!=null);
          system.assertEquals(true,config.searchScreenSortableFields!=null);
          system.assertEquals(true,config.detailScreenPartnerTrackBasicFields!=null);
          system.assertEquals(true,config.detailScreenCompanyExtendedFields!=null);
          system.assertEquals(true,config.detailContactUsFields!=null);
          system.assertEquals(true,config.detailScreenShowcaseFields!=null);
          system.assertEquals(true,config.detailScreenPartnerTrackExtendedFields!=null);
          system.assertEquals(true,config.detailScreenSMExtendedFields!=null);
          system.assertEquals(true,config.detailScreenShowcaseEditFields!=null);
          system.assertEquals(true,config.detailScreenLocationFields!=null);
          system.assertEquals(true,config.detailScreenEditFields!=null);
          system.assertEquals(true,config.detailPartnerTrackScreenEditFields!=null);
          system.assertEquals(true,config.detailScreenServicesEditField!=null);
          
          system.assertEquals(true,config.detailScreenEditTCFields!=null);
          system.assertEquals(true,config.detailScreenEditTCFields!=null);
          system.assertEquals(true,config.detailScreenEditCompDesc!=null);
          system.assertEquals(true,config.prioritizedCountries!=null);
          system.assertEquals(true,config.searchCSPFields!=null);
          system.assertEquals(true,config.googleMapsApiUrl!=null);
          system.assertEquals(true,config.baiduMapsApiUrl!=null);
          
          system.assertEquals(true,config.detailAccountFields!=null);
          system.assertEquals(true,config.detailPartnerTrackFieldsload!=null);
          system.assertEquals(true,config.detailScreenPartnerTrackFieldsEdit!=null);
          
    }
     

}