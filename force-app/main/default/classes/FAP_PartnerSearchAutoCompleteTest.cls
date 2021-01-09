@IsTest
private class FAP_PartnerSearchAutoCompleteTest {

    private static testmethod void testKeywordAutoComplete(){
        Account acct = getAcct('Test Rty395i832ij Test');
        FAP_PageUtils.put('xyz:'+FAP_PartnerSearchAutoCompleteController.PARAM_KEYWORD,'ty395i832i');
        FAP_PartnerSearchAutoCompleteController controller = new FAP_PartnerSearchAutoCompleteController();
        System.assertNotEquals(null,controller.results);
        //System.assert(controller.results.size() >= 1, 'Expected at least one result');
        //System.assertEquals(acct.name,controller.results.get(0));
    }

    private static testmethod void testLocationAutoCompleteByCityName(){
        Account acct = getAcct('Test Rty395i832ij Test');
        Partner_Location__c location = new Partner_Location__c();
        location.name               = 'test';
        location.Street__c          = '123 Broadway';
        location.City__c            = 'Rty395i832ij';
        location.State_Province__c  = 'NY';
        location.Postal_Code__c     = '10001';
        location.Country__c         = 'UNITED STATES';
        location.Account__c         = acct.id;
        location.Longitude__c       = 0;
        location.Latitude__c        = 0;
        insert location;
        
        FAP_PageUtils.put(FAP_PartnerSearchAutoCompleteController.PARAM_LOCATION,'ty395i832i');
        FAP_PartnerSearchAutoCompleteController controller = new FAP_PartnerSearchAutoCompleteController();
        System.assertNotEquals(null,controller.results);
        System.assert(controller.results.size() >= 1, 'Expected at least one result');
        System.assertEquals('Rty395i832ij',controller.results.get(0));
    }
    /* Fenny: CR7110 - Contextual search for zip code is not enabled in 13.7
    private static testmethod void testLocationAutoCompleteByPostalCode(){
        Account acct = getAcct('Test Rty395i832ij Test');
        Partner_Location__c location = new Partner_Location__c();
        location.name               = 'test';
        location.Street__c          = '123 Broadway';
        location.City__c            = 'New York';
        location.State_Province__c  = 'NY';
        location.Postal_Code__c     = 'Rty395i832ij';
        location.Country__c         = 'UNITED STATES';
        location.Account__c         = acct.id;
        location.Longitude__c       = 0;
        location.Latitude__c        = 0;
        insert location;
        
        PageUtils.put(PartnerSearchAutoCompleteController.PARAM_LOCATION,'Rty395i832ij');
        PartnerSearchAutoCompleteController controller = new PartnerSearchAutoCompleteController();
        System.assertNotEquals(null,controller.results);
        System.assert(controller.results.size() >= 1, 'Expected at least one result');
        System.assertEquals('Rty395i832ij UNITED STATES',controller.results.get(0));
    }*/
    
    private static Account getAcct(String name){
      // Configuration_Variable__mdt var = null;
        try{
            Configuration_Variable__mdt var= [
                select id,developername 
                from Configuration_Variable__mdt
                where developername = :fap_PartnerSearchConstants.CONFIG_KEY_TERMS_AND_CONDITIONS_URL];
        }catch(QueryException e){
         //   var = new Configuration_Variable__c(name = PartnerSearchConstants.CONFIG_KEY_TERMS_AND_CONDITIONS_URL);
           // insert var;
        }
       // var.value__c = 'test123';
       // update var;
        Account acct = new Account(
            name = name,
            Approved_for_Partner_Finder__c = true,
            Profile_Published_to_Partner_Finder__c = 'Yes',
            Partner_User_Agreed_to_PF_Terms_Cond__c = UserInfo.getUserId(),
            Partner_Date_Agreed_to_PF_Terms_Cond__c = Datetime.now());
        insert acct;
        acct.IsPartner = true;
        update acct;
        
        Partner_Location__c loc = new Partner_Location__c();
        loc.Name = 'test location';
        loc.Longitude__c = 0;
        loc.Latitude__c = 0;
        loc.Is_Primary__c = true;
        loc.Account__c = acct.id;
        insert loc;

        return acct;
    }
    
}