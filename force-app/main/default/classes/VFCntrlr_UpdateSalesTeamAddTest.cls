@isTest
private class VFCntrlr_UpdateSalesTeamAddTest {
    static list<Opportunity> listOpp;
    static Opportunity testOppty;
    static OpportunityTeamMember testACT1;
    @testSetup static void setup(){
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTdf;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        listOppTdf[0].AccountId=listAccTdf[0].id;
        insert listOppTdf;
        
    }
    //static Opportunity testOpptyty;
    static List<String> listObjAPINames = new List<String>{'Opportunity'};
        
        public static testMethod void testVFCntrlrUpdateSalesTeamAddSave() {
            TriggerExecutionController.setSkipAllTriggers(true);
            createTestData1();
            System.debug('#MN:START of testVFCntrlr_UpdateSalesTeamAddSave()');
            listOpp=[Select id from Opportunity Limit 1];
            PageReference pageRef = Page.addSalesTeamMembers;
            Test.setCurrentPage(pageRef);
            List<Opportunity> listOpp1=  [select id,Name from Opportunity where Id =: listOpp[0].Id];
            
            // Add parameters to page URL        
            ApexPages.currentPage().getParameters().put('oid', listOpp1[0].Id);
            // Instantiate a new controller with all parameters in the page
            VFCntrlr_UpdateSalesTeamAdd controller = new VFCntrlr_UpdateSalesTeamAdd();
            
            List<OpportunityTeamMember> listTemmember=controller.getOpportunityTeamMemberList();        
            
            //Randomly choosing one team Member record to get the userid and role
            List<OpportunityTeamMember> listexistTeamMemberTest=[select TeamMemberRole,UserId,OpportunityAccessLevel 
                                                                 from OpportunityTeamMember WHERE User.IsActive=true limit 1];
            
            
            listTemmember[3].TeamMemberRole=listexistTeamMemberTest[0].TeamMemberRole;
            listTemmember[3].UserId=listexistTeamMemberTest[0].UserId;
            listTemmember[3].OpportunityId=listOpp1[0].Id;
            //setting access
            for(integer intindex=0;intindex<5;intindex++){
                controller.setAccess('Read');
            }
            
            //Saving
            String strnextPage = controller.Save().getUrl();
            
            // Verify that the success page displays        
            System.assertEquals('/apex/Update_Sales_Team_Main?id='+listOpp1[0].Id , strnextPage);
            
            System.debug('#MN:END of testVFCntrlr_UpdateSalesTeamAddSave()');
        }
    
    public static testMethod void testVFCntrlrUpdateSalesTeamAddSaveError() {
        System.debug('#MN:START of testVFCntrlr_UpdateSalesTeamAddSaveError()');
        TriggerExecutionController.setSkipAllTriggers(true);
        createTestData1();
        listOpp=[Select id from Opportunity Limit 1];
        PageReference pageRef = Page.addSalesTeamMembers;
        Test.setCurrentPage(pageRef);
        List<Opportunity> listOpp1=  [select Id,Name from Opportunity where Id =: listOpp[0].Id];
        
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('oid', listOpp1[0].Id);
        
        // Instantiate a new controller with all parameters in the page
        VFCntrlr_UpdateSalesTeamAdd controller = new VFCntrlr_UpdateSalesTeamAdd();
        List<OpportunityTeamMember> listTemmember=controller.getOpportunityTeamMemberList();
        
        List<OpportunityTeamMember> listexistTeamMemberTest=[select TeamMemberRole,UserId,OpportunityAccessLevel 
                                                             from OpportunityTeamMember WHERE User.IsActive=true limit 1];
        
        listTemmember[3].UserId=listexistTeamMemberTest[0].UserId;      
        listTemmember[3].OpportunityId=listOpp1[0].Id;
        //values for TeamMemberRole and OpportunityAccessLevel are not given
        
        //asserts that the Save() returns null
        System.assertEquals(controller.Save(),null);
        
        System.debug('#MN:END of testVFCntrlr_UpdateSalesTeamAddSaveError()');
    }
    
    public static testMethod void testVFCntrlrUpdateSalesTeamAddSaveAndMore() {
        System.debug('#MN:START of testVFCntrlr_UpdateSalesTeamAddSaveAndMore()');
        TriggerExecutionController.setSkipAllTriggers(true);
        createTestData1();
        listOpp=[Select id from Opportunity Limit 1];
        PageReference pageRef = Page.addSalesTeamMembers;
        Test.setCurrentPage(pageRef);
        List<Opportunity> listOpp1=  [select id,Name,ownerId  from Opportunity where Id =: listOpp[0].Id];
        
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('oid', listOpp1[0].Id);
        
        // Instantiate a new controller with all parameters in the page
        VFCntrlr_UpdateSalesTeamAdd controller = new VFCntrlr_UpdateSalesTeamAdd();
        List<OpportunityTeamMember> listtemmember=controller.getOpportunityTeamMemberList();
        
        List<OpportunityTeamMember> listexistTeamMemberTest=[select TeamMemberRole,UserId,OpportunityAccessLevel 
                                                             from OpportunityTeamMember where UserId!=:listOpp1[0].OwnerId AND User.IsActive=true limit 1];
        
        listtemmember[3].TeamMemberRole=listexistTeamMemberTest[0].TeamMemberRole;
        listtemmember[3].UserId=listexistTeamMemberTest[0].UserId;
        listtemmember[3].OpportunityId=listOpp1[0].Id;
        
        for(integer intindex=0;intindex<5;intindex++){
            controller.setAccess('Read');
        }        
        Id existuserid=listexistTeamMemberTest[0].UserId;
        
        controller.SaveandMore();        
        
        List<OpportunityTeamMember> listcurrentlyInsertedMember=[select TeamMemberRole,UserId,OpportunityId
                                                                 from OpportunityTeamMember where userid=:existuserid AND OpportunityId=:listOpp1[0].Id];
        System.assertEquals(1,listcurrentlyInsertedMember.size());        
        
        System.debug('#MN:END of testVFCntrlr_UpdateSalesTeamAddSaveAndMore()');
    }
    
    public static testMethod void testVFCntrlrUpdateSalesTeamAddCancel() {
        System.debug('#MN:START of testVFCntrlr_UpdateSalesTeamAddCancel()');
        TriggerExecutionController.setSkipAllTriggers(true);
        createTestData1();
        listOpp=[Select id from Opportunity Limit 1];
        
        PageReference pageRef = Page.addSalesTeamMembers;
        Test.setCurrentPage(pageRef);
        List<Opportunity> listOpp1=  [select id,Name from Opportunity where Id =: listOpp[0].Id];
        
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('oid', listOpp1[0].Id);
        
        // Instantiate a new controller with all parameters in the page
        VFCntrlr_UpdateSalesTeamAdd controller = new VFCntrlr_UpdateSalesTeamAdd();
        
        String strnextPage = controller.cancel().getUrl();
        // Asserts that the nextPage contains the URL for main page
        System.assertEquals('/apex/Update_Sales_Team_Main?id='+listOpp1[0].Id , strnextPage);
        
        System.debug('#MN:END of testVFCntrlr_UpdateSalesTeamAddCancel()');        
        
    }
    
    public static testMethod void testVFCntrlrUpdateSalesTeamAddGetMethods() {
        System.debug('#MN:START of testVFCntrlr_UpdateSalesTeamAddGetMethods()');
        TriggerExecutionController.setSkipAllTriggers(true);
        createTestData1();
        listOpp=[Select id from Opportunity Limit 1];
        
        PageReference pageRef = Page.addSalesTeamMembers;
        Test.setCurrentPage(pageRef);
        List<Opportunity> listOpp1=  [select id,Name from Opportunity where Id =: listOpp[0].Id];
        
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('oid', listOpp1[0].Id);
        
        // Instantiate a new controller with all parameters in the page
        VFCntrlr_UpdateSalesTeamAdd controller = new VFCntrlr_UpdateSalesTeamAdd();
        
        //getOpportunity
        Opportunity currOpportunity=controller.getOpportunity();
        System.assertEquals(currOpportunity.id,listOpp1[0].Id);
        
        //getItems
        List<SelectOption> listoptions =controller.getItems();
        system.assertNotEquals(listoptions.size(),0);
        
        //setAccess
        controller.setAccess('Read');
        System.assertEquals(controller.getAccess(),'Read');
        
        System.debug('#MN:START of testVFCntrlr_UpdateSalesTeamAddGetMethods()');
    }
    
    public static testMethod void testVFCntrlrUpdateSalesTeamAddCancelDataNotAvailable() {
        System.debug('#MN:START of testVFCntrlr_UpdateSalesTeamAddCancelDataNotAvailable()');
        TriggerExecutionController.setSkipAllTriggers(true);
        createTestData1();
        listOpp=[Select id from Opportunity Limit 1];
        
        PageReference pageRef = Page.addSalesTeamMembers;
        Test.setCurrentPage(pageRef);
        List<Opportunity> listOpp1=  [select id,Name from Opportunity where Id =: listOpp[0].Id];
        Id oppId=listOpp1[0].id;        
        
        //deletes the opportunity
        delete listOpp1;
        
        // Add id of deleted Opp as parameters to page URL
        ApexPages.currentPage().getParameters().put('oid', oppId);
        
        // Instantiate a new controller with all parameters in the page
        VFCntrlr_UpdateSalesTeamAdd controller = new VFCntrlr_UpdateSalesTeamAdd();
        
        String strnextPage = controller.cancel().getUrl();
        
        // Asserts that the nextPage contains the URL for Opportunity HOME page        
        System.assertEquals('/006/o', strnextPage);
        
        System.debug('#MN:END of testVFCntrlr_UpdateSalesTeamAddCancel()');   
        TriggerExecutionController.setSkipAllTriggers(false);     
        
    }
    
    public static testMethod void testVFCntrlrUpdateSalesTeamAddNoDataAvailable() {
        TriggerExecutionController.setSkipAllTriggers(true);
        createTestData1();
        listOpp=[Select id from Opportunity Limit 1];
        
        System.debug('#MN:START of testVFCntrlr_UpdateSalesTeamAddNoDataAvailable()');
        
        PageReference pageRef = Page.addSalesTeamMembers;
        Test.setCurrentPage(pageRef);
        List<Opportunity> listOpp1=  [select id,Name from Opportunity where Id =: listOpp[0].Id];
        
        // Add parameters to page URL        
        ApexPages.currentPage().getParameters().put('oid', listOpp1[0].Id);
        delete listOpp1;
        // Instantiate a new controller with all parameters in the page
        VFCntrlr_UpdateSalesTeamAdd controller = new VFCntrlr_UpdateSalesTeamAdd();
        
        // Verify that the DataAvailable variable is false
        System.assertEquals(false,controller.getDataAvailable());
        
        System.debug('#MN:END of testVFCntrlr_UpdateSalesTeamAddNoDataAvailable()');
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    
    public static testMethod void testVFCntrlrUpdateSalesTeamAddSaveAndMoreNoDataAvailable() {
        System.debug('#MN:START of testVFCntrlr_UpdateSalesTeamAddSaveAndMoreNoDataAvailable()');
        TriggerExecutionController.setSkipAllTriggers(true);
        createTestData1();
        listOpp=[Select id from Opportunity Limit 1];
        
        PageReference pageRef = Page.addSalesTeamMembers;
        Test.setCurrentPage(pageRef);
        List<Opportunity> listOpp1=  [select id,Name,ownerId  from Opportunity where Id =: listOpp[0].Id];
        
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('oid', listOpp1[0].Id);
        
        // Instantiate a new controller with all parameters in the page
        VFCntrlr_UpdateSalesTeamAdd controller = new VFCntrlr_UpdateSalesTeamAdd();
        List<OpportunityTeamMember> listtemmember=controller.getOpportunityTeamMemberList();
        
        List<OpportunityTeamMember> listexistTeamMemberTest=[select TeamMemberRole,UserId,OpportunityAccessLevel 
                                                             from OpportunityTeamMember where UserId!=:listOpp1[0].OwnerId AND User.IsActive=true limit 1];
        
        listtemmember[3].TeamMemberRole=listexistTeamMemberTest[0].TeamMemberRole;
        listtemmember[3].UserId=listexistTeamMemberTest[0].UserId;
        listtemmember[3].OpportunityId=listOpp1[0].Id;
        
        for(integer intindex=0;intindex<5;intindex++){
            controller.setAccess('Read');
        }        
        Id existuserid=listexistTeamMemberTest[0].UserId;
        
        delete listOpp1;
        // Verify that the SaveandMore returns null due to opportunity deletion:
        System.assertEquals(null,controller.SaveandMore());
        System.debug('#MN:END of testVFCntrlr_UpdateSalesTeamAddSaveAndMoreNoDataAvailable()');
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    
    /*    
static void createTestData(){
testOpptyty = new Opportunity(Name = 'Test Oppty',StageName = 'Plan - 1%', CloseDate = System.Today() + 10);
insert testOpptyty;

Profile testProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE '%GBL Sales Mgr - Non SSO' LIMIT 1];

User testUser1 = new User(FirstName='Test 1', LastName='user', Title='OEM_SR',UserName='TestU1'+ System.currentTimeMillis() +'@test.com',Email='TestU1@dell.com',Alias='test01',CommunityNickName='Test01',ProfileId = testProfile.Id, LanguageLocaleKey='en_US', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles',Badge_Number__c='testtest111');
insert testUser1;

testACT1 = new OpportunityTeamMember (UserId=testUser1.Id, TeamMemberRole='OEM SR', OpportunityId=testOpptyty.Id);
insert testACT1;
}          
*/
    
    static void createTestData1(){
        //TriggerExecutionController.setSkipAllTriggers(true); 
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAcc=[Select id from Account Limit 1];
        // Create test data - Start                                                                    
        /*Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);

Account testAccount1 = new Account(Name='testOpptyDist Test Account',
RecordTypeId = accRTId, 
Partner_Type__c = 'Distributor (GCC)',
Partner_Tier__c = 'Tier 1',
Status__c = 'Active',
Distribution_Sell_To_Countries__c = 'UNITED STATES',
DMU__c = false,                                         
Partner_Relationship__c = 'Authorized',
Account_Country__c = 'UNITED STATES');                                       
Insert testAccount1;
*/                                              
        Contact newCont = new Contact(FirstName = 'TestContact01',
                                      LastName = 'TestContact01',
                                      AccountId =listAcc[0].Id,
                                      Status__c  =  'Marketing Suspect',
                                      Email = 'TestContact01@dell.com',
                                      Fax = '1234567',
                                      MobilePhone = '1234567',
                                      Last_Operation_Performed__c = 'testing',
                                      Eloqua_ID__c = 'ABCD000014576503',
                                      Phone = '1234567');
        
        insert newCont;
        
        final List<Profile> testProfile = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%PRM%' limit 1];
        
        User testUser1 = new User(Username='TestUser1' + System.currentTimeMillis() + '@dell.com',
                                  Alias = 'MTU9', 
                                  Email='TestUser1@dell.com', 
                                  FirstName='TestUser1', 
                                  LastName='TestUser1',  
                                  ProfileId = testProfile.get(0).Id, 
                                  LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', 
                                  EmailEncodingKey='UTF-8', 
                                  TimeZoneSidKey='America/Los_Angeles',
                                  Enable_Partner_Admin__c = true,
                                  Badge_Number__c='Test1'+System.currentTimeMillis(), 
                                  isActive = TRUE,
                                  ContactId = newCont.Id);
        
        insert testUser1;
        
        TriggerExecutionController.setSkipAccountTriggers(false);                                                                        
        TriggerExecutionController.setSkipOpportunityTriggers(true); 
        
        /*   testOppty = new opportunity(name='Test Opp01');
testOppty.accountId = testAccount1.Id;
testOppty.StageName = 'Discover - 10%';
testOppty.Forecast_Category_Override__c = 'Best Case';
testOppty.CloseDate = System.today();
*/
        //list<User> listUser=[Select id from User Limit 1];
        list<Opportunity> listOpp=[Select id from Opportunity Limit 1];
        TriggerExecutionController.setSkipAllTriggers(true);
        SystemBehaviorBypasser.setSkipValidationRules(listObjAPINames);
        //System.runAs(test_user1){ 
        // insert testOppty;  
        //}
        SystemBehaviorBypasser.setSkipValidationRules(listObjAPINames);
        TriggerExecutionController.setSkipAllTriggers(false);
        
        testACT1  = new OpportunityTeamMember();
        testACT1.OpportunityId = listOpp[0].Id; 
        system.debug('OpportunityId : ' + testACT1.OpportunityId);
        testACT1.TeamMemberRole = 'DM Solutions Engineer';
        testACT1.UserId = testUser1.id;
        insert testACT1;                                
        //Create test data - End        
    }
}