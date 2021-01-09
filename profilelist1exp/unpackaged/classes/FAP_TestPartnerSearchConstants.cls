@IsTest
private class FAP_TestPartnerSearchConstants {
  private static testmethod void testGetInstance(){
    Configuration_Variable__mdt var = null;
    try{
      var = [select id from Configuration_Variable__mdt
      where developername = :FAP_PartnerSearchConstants.CONFIG_KEY_GOOGLE_MAPS_API_KEY];
    }catch(QueryException e){}
    if(var == null){
      var = new Configuration_Variable__mdt();
      var.developername = FAP_PartnerSearchConstants.CONFIG_KEY_GOOGLE_MAPS_API_KEY;
    }
    var.value__c = 'test123';
    if(var.id == null){
      //insert var;
    } else {
     // update var;
    }
    FAP_PartnerSearchConstants constants = FAP_PartnerSearchConstants.getInstance();
  	system.assertNotEquals(null, constants);
  }
}