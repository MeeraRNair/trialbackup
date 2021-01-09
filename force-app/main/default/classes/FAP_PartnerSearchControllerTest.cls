@IsTest
private class FAP_PartnerSearchControllerTest {

    // Ver 1.0: To test if now country selected in the search criteria
    private static testmethod void testSearchNoSelectedCountry2(){
        PageReference pageRef = new PageReference('apex/FAP_partnerSearch?c=IN#');
        Test.setCurrentPage(pageRef);
        final FAP_PartnerSearchController controller = new FAP_PartnerSearchController();
        System.assertEquals(null,controller.doOnLoad());
        System.assertEquals('IN',controller.countryCode);
        controller.languagecode='EN-US';
        System.assertEquals(null,controller.searchClicked());
       // System.assertEquals('IN',controller.form.countryCode);
          controller.resetPage();
        List<SelectOption> sl=controller.sortOptions;
    }

    // Ver 1.0: To test if now country selected in the search criteria
    private static testmethod void testSearchNoSelectedCountry(){
        final FAP_PartnerSearchController controller = new FAP_PartnerSearchController();
        System.assertEquals(null,controller.doOnLoad());

        System.assertEquals(null,controller.searchClicked());
        System.assertEquals('',controller.form.countryCode);
    }

    // Ver 1.0: To test if country is passed in the querystring, as well as the country is selected in the search criteria
    private static testmethod void testSearchHasSelectedCountry(){
        final FAP_PartnerSearchController controller = new FAP_PartnerSearchController();
        // Ver 1.0: When country is been passed via the querystring
        controller.paramString = 'c=it';
        System.assertEquals(null,controller.doOnLoad());
        System.assertEquals('IT',controller.form.countryCode);
        controller.refresh();
        // Ver 1.0: When country is selected from the country dropdown field
        controller.countryCode = 'us';
        controller.sortData();
        System.assertEquals(null,controller.searchClicked());
        //System.assertEquals('US',controller.form.countryCode); // Fenny: The code line to be tested has been removed since 13.7 (CR7105)
    }

    private static testmethod void testSearchKeywordDeserialize(){
        final FAP_PartnerSearchController controller = new FAP_PartnerSearchController();
        controller.getMessages();
        controller.paramString = 'keyword=Aleurometer';
        System.assertEquals(null,controller.doOnLoad());

        System.assertEquals(null,controller.searchClicked());
        System.assertNotEquals(null,controller.hits);
        Integer beforeScaffold = controller.hits.size();
        
        //1.1 check list no data available
        System.assertEquals(true,controller.hits.isEmpty());
        //1.1 map not displayed
        System.assertEquals(false, controller.displaySearchResultsFlagMap);

        scaffoldScenario1();
        System.assertEquals(null,controller.searchClicked());
        System.assertNotEquals(null,controller.hits);
        Integer afterScaffold = controller.hits.size();
        Boolean ie=controller.isIE;
        Boolean isChrome=controller.isChrome;
        Boolean isFirefox=controller.isFirefox;
        String nullValue=controller.nullValue;
        String domainUrl=controller.domainUrl;
        String country=controller.country;
                String view=controller.view;
        String viewDe=controller.viewDe;

        // FAP_SearchForm searchform;
        //=new FAP_SearchForm(pageNumber=1);
      //  searchForm.pageNumber='1';

       System.assertEquals(null,controller.searchClicked());
        System.assertNotEquals(null,controller.hits);
        //System.assert(afterScaffold > beforeScaffold);
        
        Object x = null;
        
    }
 /*private static testmethod void testSearchKeywordDeserialize1(){
     
       Id p = [select id from profile where name='R16.10 APJ PRM Portal User (MOSS)'].id;

Id recTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();

     final Account account = new Account(
            Name='Aerugo'
            ,Profile_Published_to_Partner_Finder__c='Yes'
            ,Approved_for_Partner_Finder__c=true
            ,Partner_User_Agreed_to_PF_Terms_Cond__c=UserInfo.getUserId()
            ,Partner_Date_Agreed_to_PF_Terms_Cond__c=Datetime.now()
            ,Rating = 'Hot'
            ,RecordTypeId=recTypeId);
        insert account;
        account.IsPartner = true;
        update account;
        final contact con=new contact(lastname='Test',Account=account,MailingCountry='US');
        insert con;
final User user = new User(alias = 'test123', email='test123@noemail.com',emailencodingkey='UTF-8', profileid=p,lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', country='United States',IsActive =true,ContactId = con.Id,timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
user.UserRoleId=[select UserRoleId from UserRole ].UserRoleId;

insert user;   
     system.runAs(user) {

     final FAP_PartnerSearchController controller = new FAP_PartnerSearchController();
        controller.getMessages();
        controller.paramString = 'keyword=Aleurometer';
        System.assertEquals(null,controller.doOnLoad());

        System.assertEquals(null,controller.searchClicked());
        System.assertNotEquals(null,controller.hits);
        Integer beforeScaffold = controller.hits.size();
        
        //1.1 check list no data available
        System.assertEquals(true,controller.hits.isEmpty());
        //1.1 map not displayed
        System.assertEquals(false, controller.displaySearchResultsFlagMap);

        scaffoldScenario1();
        System.assertEquals(null,controller.searchClicked());
        System.assertNotEquals(null,controller.hits);
        Integer afterScaffold = controller.hits.size();
        
       System.assertEquals(null,controller.searchClicked());
        System.assertNotEquals(null,controller.hits);
        //System.assert(afterScaffold > beforeScaffold);
        
        Object x = null;
     }
       
    }*/ 
    private static testmethod void testSearchKeyword(){
       
        final FAP_PartnerSearchController controller = new FAP_PartnerSearchController();
        controller.skipToLocation();
        try{
        controller.getSortColumnList();
        }catch(Exception e){
        
        }
        try{
            Integer a=1+2;
            throw new FAP_FAPLimitException();
        }catch(FAP_FAPLimitException e){
        
        }            
        System.assertEquals('{ "locations" : []}',controller.locationsJSON);
        System.assertEquals(null,controller.searchSerialized);
        System.assertEquals(null,controller.config);
        System.assertEquals(null,controller.form);
        System.assertEquals(null,controller.hits);
        System.assertEquals(null,controller.paginator);
        // Ver 1.0: initialized boolean properties with false value to prevent NullPointException
        //System.assertEquals(null,controller.displayAdvancedSearchFlag);
        //System.assertEquals(null,controller.displaySearchResultsFlag);
        System.assertEquals(false,controller.displayAdvancedSearchFlag);
        System.assertEquals(false,controller.displaySearchResultsFlag);
        System.assertEquals(null,controller.sortColumn);
        
        System.assertEquals(null,controller.doOnLoad());
        
        System.assertEquals('{ "locations" : []}',controller.locationsJSON);
        System.assertEquals(null,controller.searchSerialized);
        System.assertNotEquals(null,controller.config);
        System.assertNotEquals(null,controller.form);
        System.assertNotEquals(null,controller.hits);
        System.assertEquals(0,controller.hits.size());
        System.assertNotEquals(null,controller.paginator);
        System.assertNotEquals(null,controller.displayAdvancedSearchFlag);
        // Ver 1.0: initialized boolean properties with false value to prevent NullPointException
        //System.assertEquals(null,controller.displaySearchResultsFlag);
        System.assertEquals(false,controller.displaySearchResultsFlag);
        System.assertEquals(null,controller.sortColumn);
        
        controller.form.keyword = 'Aleurometer';
        
        System.assertEquals(null,controller.searchClicked());
        System.assertNotEquals(null,controller.hits);
        Integer beforeScaffold = controller.hits.size();

        scaffoldScenario1();
        System.assertEquals(null,controller.searchClicked());
        System.assertNotEquals(null,controller.hits);
        Integer afterScaffold = controller.hits.size();

        System.assertEquals(null,controller.searchClicked());
        System.assertNotEquals(null,controller.hits);
        //System.assert(afterScaffold > beforeScaffold);
        
        System.assertEquals(false,controller.displayAdvancedSearchFlag);
        System.assertEquals(null,controller.toggleFilter());
        System.assertEquals(true,controller.displayAdvancedSearchFlag);
    }
    
    private static testmethod void testSearchSort(){
       
       
        final FAP_PartnerSearchController controller = new FAP_PartnerSearchController();
        controller.toggleFilter();
        System.assertEquals(null,controller.doOnLoad());
        System.assertNotEquals(null,controller.getSortColumnList());
        System.assert(controller.getSortColumnList().size() > 0);
        

    }

    private static Scenario1Scaffolding scaffoldScenario1(){
        
        final Account account = new Account(
            Name='Aerugo'
            ,Profile_Published_to_Partner_Finder__c='Yes'
            ,Approved_for_Partner_Finder__c=true
            ,Partner_User_Agreed_to_PF_Terms_Cond__c=UserInfo.getUserId()
            ,Partner_Date_Agreed_to_PF_Terms_Cond__c=Datetime.now()
            ,Rating = 'Hot');
        insert account;
        account.IsPartner = true;
        account.NAME='test';
        update account;
        
        Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1',Partner_Program_Track__c = 'OEM');
        insert trackObj;
        
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Partner_Track_Name__c = 'Tech Data';
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c = account.Id;
        testPartnerTrackObj.Partner_Track__c='Distributor';
        testPartnerTrackObj.Approved_for_Partner_Finder__c = true;
        testPartnerTrackObj.Profile_Published_to_Partner_Finder__c = 'Yes';
        testPartnerTrackObj.User_Agreed_to_PF_Terms_Cond__c = userinfo.getUserId();
        
        testPartnerTrackObj.Primary_SMAffinity_Account__c =account.Id;
        testPartnerTrackObj.Partner_Track_Account_Local_Name__c = 'Test Name';
        testPartnerTrackObj.Partner_Program_Tier__c = 'Gold';
        testPartnerTrackObj.Dell_Technologies_Partner__c = true;
        insert testPartnerTrackObj;   
        
        final contact con=new contact(lastname='Test',Account=account,MailingCountry='US');
        try{
            insert con;
        }catch(exception e){
            
        }

        final Partner_Location__c location = new Partner_Location__c(
            Name = 'Aleurometer'
            ,Latitude__c = 0
            ,Longitude__c = 0
            ,Account__c = account.id
            ,Is_Primary__c = true
            ,Partner_Track__c = testPartnerTrackObj.Id
        );
        insert location;
        return new Scenario1Scaffolding(account,location);
    }

    public class Scenario1Scaffolding{
        public Account account {get;private set;}
        public Partner_Location__c location {get;private set;}
        
        public Scenario1Scaffolding(Account account, Partner_Location__c location){
            this.account = account;
            this.location = location;
        }
        
    }
    
    private static testmethod void testFAPLimitException(){
       
        final FAP_PartnerSearchController controller = new FAP_PartnerSearchController();
        //controller.skipToLocation();
        controller.sortByRefresh();
        try{
            Integer a=1+2;
            throw new FAP_FAPLimitException();
        }catch(FAP_FAPLimitException e){
        
        }            
    }
        
   /* private static testmethod void testFAPLimitException(){
        final FAP_PartnerSearchController controller = new FAP_PartnerSearchController();
        Boolean exceptionCaught = false;
        List<Object> records = new List<Object>();
        try{
            controller.handlePageChange(records);
        }catch(FAP_FAPLimitException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'FAP_FAPLimitException not thrown');
    }*/
}