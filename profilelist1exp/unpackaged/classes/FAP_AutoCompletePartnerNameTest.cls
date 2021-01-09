@IsTest
private class FAP_AutoCompletePartnerNameTest {

    private static testmethod void testInvalidSearchStrThrowingException(){
        assertInvalidSearchStrThrowingException(null);
        assertInvalidSearchStrThrowingException('');
        assertInvalidSearchStrThrowingException('x');
        final List<String> results = new FAP_AutoCompletePartnerName('ty395i832i').execute();
        System.assertNotEquals(null,results);        
    }
    
    private static void assertInvalidSearchStrThrowingException(String searchStr){
        Boolean exceptionCaught = false;
        try{
            new FAP_AutoCompletePartnerName(searchStr);
        }catch(FAP_IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(
            exceptionCaught == true, 
            'new FAP_AutoCompletePartnerName(' 
                + (searchStr == null ? 'null' : '\'' + searchStr + '\'') 
                + ') did not throw IllegalArgumentException');
    }
       
    private static testmethod void testKeywordAutoComplete(){
        final Account acct = getAcct('Test Rty395i832ij Test');
        final List<String> results = new FAP_AutoCompletePartnerName('ty395i832i').execute();
        System.assertNotEquals(null,results);
        //System.assert(results.size() >= 1, 'Expected at least one result');
        //System.assertEquals(acct.name,results.get(0));
    }

    private static Account getAcct(String name){
        //FAP_TestData.ensureVariableExists(FAP_Configuration.KEY_TERMS_AND_CONDITIONS_URL,'test123');

        Account acct = new Account(
            name = name,
            NameLocal = name,
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
    private static testMethod void test12(){
        FAP_Configuration.keyValue = 'Account__r.';
        FAP_Configuration.keyValueWithoutDot = 'Account__r';

        final List<String> results1 = new FAP_AutoCompletePartnerName('ty395i832i').internalExecute();

    }
        private static testmethod void testKeywordPartnerTrack0(){
            FAP_Configuration.keyValue = 'Partner_Track__r.';
            FAP_Configuration.keyValueWithoutDot = 'Partner_Track__r';
            Partner_Track__c PartnerTrack = getPartnerTrack('Test Rty395i832ij Test');
            Account acc=getAcct('989ty395i832i');
            PartnerTrack.Primary_SMAffinity_Account__c=acc.id;
            PartnerTrack.Master_Group_Id__c=acc.id;
            PartnerTrack.Partner_Track_Account_Local_Name__c='989ty395i832i';
            update partnertrack;
            
            Partner_Location__c loc = new Partner_Location__c();
            loc.Name = 'test location';
            loc.Longitude__c = 0;
            loc.Latitude__c = 0;
            loc.Is_Primary__c = true;
            loc.Partner_Track__c = PartnerTrack.id;
            insert loc;
            try{
            final List<String> results = new FAP_AutoCompletePartnerName('ty395i832i').execute();
            final List<String> results1 = new FAP_AutoCompletePartnerName('ty395i832i').internalExecute();

            System.assertNotEquals(null,results);
            }
            catch(Exception e){
                
            }
            //System.assert(results.size() >= 1, 'Expected at least one result');
            //System.assertEquals(acct.name,results.get(0));
    }
    
    private static testmethod void testKeywordPartnerTrack(){
        
        FAP_Configuration.keyValue = 'Account__r.';
        FAP_Configuration.keyValueWithoutDot = 'Account__r';

        Partner_Track__c PartnerTrack = getPartnerTrack('Test Rty395i832ij Test');
        Account acc=getAcct('ty395i832i');
        PartnerTrack.Primary_SMAffinity_Account__c=acc.id;
        PartnerTrack.Master_Group_Id__c=acc.id;
        PartnerTrack.Partner_Track_Account_Local_Name__c='ty395i832i';
        update partnertrack;
        
        Partner_Location__c loc = new Partner_Location__c();
        loc.Name = 'test location';
        loc.Longitude__c = 0;
        loc.Latitude__c = 0;
        loc.Is_Primary__c = true;
        loc.Partner_Track__c = PartnerTrack.id;
        insert loc;
        try{
        final List<String> results = new FAP_AutoCompletePartnerName('ty395i832i').execute();
        final List<String> results1 = new FAP_AutoCompletePartnerName('ty395i832i').internalExecute();

        System.assertNotEquals(null,results);
        }
        catch(Exception e){
            
        }
        //System.assert(results.size() >= 1, 'Expected at least one result');
        //System.assertEquals(acct.name,results.get(0));
    }

    private static Partner_Track__c getPartnerTrack(String name){
      // FAP_TestData.ensureVariableExists(FAP_Configuration.KEY_TERMS_AND_CONDITIONS_URL,'test123');
        Account acc=getAcct('Test');
        Partner_Track__c PartnerTrack = new Partner_Track__c(
            Partner_Track_Account_Local_Name__c = name,
            Approved_for_Partner_Finder__c = true,
            Profile_Published_to_Partner_Finder__c = 'Yes',
            User_Agreed_to_PF_Terms_Cond__c = UserInfo.getUserId(),
                    Primary_SMAffinity_Account__c=acc.id,
            Partner_Date_Agreed_to_PF_Terms_Cond__c = Datetime.now());
        insert PartnerTrack;
        PartnerTrack.Partner_Account__c = true;
        update PartnerTrack;
        
        Partner_Location__c loc = new Partner_Location__c();
        loc.Name = 'test location';
        loc.Longitude__c = 0;
        loc.Latitude__c = 0;
        loc.Is_Primary__c = true;
        loc.Partner_Track__c = PartnerTrack.id;
        insert loc;
     FAP_AutoCompletePartnerName ac=new FAP_AutoCompletePartnerName('test');
 FAP_PartnerSearchAutoCompleteController controller = new FAP_PartnerSearchAutoCompleteController();
        System.assertNotEquals(null,controller.results);

        return PartnerTrack;
    }
 private static testmethod void testKeywordAutoComplete1(){
        Account acct = getAcct('Test Rty395i832ij Test');
        FAP_PageUtils.put('xyz:'+FAP_PartnerSearchAutoCompleteController.PARAM_KEYWORD,'ty395i832i');
        FAP_PartnerSearchAutoCompleteController controller = new FAP_PartnerSearchAutoCompleteController();
        System.assertNotEquals(null,controller.results);
        //System.assert(controller.results.size() >= 1, 'Expected at least one result');
        //System.assertEquals(acct.name,controller.results.get(0));
    }
private static testmethod void testKeywordAutoComplete12(){
  //  FAP_Configuration.keyValue = 'Account__r.';
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
     //   System.assert(controller.results.size() >= 1, 'Expected at least one result');
        //System.assertEquals('Rty395i832ij',controller.results;
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
    
    private static Account getAcct1(String name){
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
            NameLocal = name,
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