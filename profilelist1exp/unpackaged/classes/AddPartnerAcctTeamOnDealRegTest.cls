@isTest
public class AddPartnerAcctTeamOnDealRegTest{
    /* Test Class to Automate Add Partner Account Team 
Created By : Rakesh Muppiri
Revision    Release     Name        Date            Description 
1.0                     Vasavi.M    01-Feb-2017     CR 13964 - Make in Sync with SIT3 & DSG related code clean up
Haribabu.A  10-Dec-2018     STORY 5907651 Removed references for the field direct_account_name__c
*/
    static list<Account> listAcc;
    static list<Opportunity> listOpp;
    static list<User> listUser;
    @testSetup static void setup() {
        OWD__c owdSetting = new OWD__c();
        owdSetting.Oppty_Stage1__c = 'Plan - 1%';
        owdSetting.Oppty_Stage10__c = 'Discover - 10%';
        owdSetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdSetting.Oppty_Stage60__c = 'Propose - 60%';
        owdSetting.Oppty_Stage90__c = 'Commit - 90%';
        owdSetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdSetting.Oppty_Stage100__c = 'Win - 100%';
        owdSetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        Insert owdSetting;
        TriggerExecutionController.setSkipAllTriggers(True);
        list<Account> listAccTDF = TestDataFactory.createNAccount(2, 'Partner Account Account');
        insert listAccTDF;
        list<Opportunity> listOppTDF=TestDataFactory.createNOpportunities(2, 'Deal Registration'); 
        insert listOppTDF; 
        list<User> listUserTDF = TestDataFactory.createNPortalUser(1);
        listUserTDF[0].isActive=true;
        insert listUserTDF;
        TriggerExecutionController.setSkipAllTriggers(false);
        
    }
    private static string getUniqueString(){
        return String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_');
    }
    public static testmethod void  addPartnerAccTeamtestChannelOpp(){
        TriggerExecutionController.setSkipAllTriggers(true);   
        listAcc = [select id, name from Account limit 1 ];
        listAcc[0].RecordTypeID = TestDataFactory.getRecordTypeIdbyName('End-User Account', 'Account');
        listAcc[0].Participating_in_LOB_Program__c = true;
        listAcc[0].Account_Country__c = 'UNITED STATES';
        listAcc[0].Tax_Registration_Number__c = '124214';
        listAcc[0].ShippingCity = 'testStreet';
        listAcc[0].ShippingState = 'testTexas';
        listAcc[0].ShippingPostalCode = '1324';
        TriggerExecutionController.setSkipAccountTriggers(true);
        update listAcc;
        system.assertNotEquals(null, listAcc[0].ShippingPostalCode);
        Profile profile = [select Id, Name from profile where Name LIKE '%Admin%' limit 1];
        User testUser = new User(Username='testvaliduser' +'@DELL.com',
                                 Alias = 'Test', 
                                 Email='Test'+'@dell.com',            
                                 LastName='Test',
                                 Title='GCC Program Manager', 
                                 ProfileId = profile.Id, 
                                 LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', 
                                 EmailEncodingKey='UTF-8', 
                                 TimeZoneSidKey='America/Los_Angeles',
                                 Badge_Number__c='Test'+System.currentTimeMillis());
        insert testUser;
        List<AccountTeamMember> listatm = new List<AccountTeamMember>();
        AccountTeamMember accTM = new AccountTeamMember();
        accTM.AccountId = listAcc[0].Id;
        accTM.UserId = testUser.Id;
        accTM.TeamMemberRole = 'Account Executive';
        listatm.add(accTM);
        AccountTeamMember accTM1 = new AccountTeamMember();
        accTM1.AccountId = listAcc[0].id;
        accTM1.UserId = testUser.Id;
        accTM1.TeamMemberRole = 'Account Executive';
        listatm.add(accTM1);
        insert listatm;
        String str = 'Thank you! The status can be tracked in the Approval Inbox on the \'Home\' tab.';
        Map<Id, Opportunity> mapOldMapTrigger = new  Map<Id, Opportunity>();                       
        list<Opportunity> listOpp = [Select id, name, RecordTypeID from Opportunity limit 10];
        for(Opportunity testOppty: listOpp){
            testOppty.RecordTypeID = TestDataFactory.getRecordTypeIdbyName('Deal Registration-Submitted', 'Opportunity');
            testOppty.AccountId=listAcc[0].Id;
            testOppty.Deal_Registration_Status__c= 'Submitted';
            testOppty.Engagement_Type__c = 'Public Tender';
            testOppty.Engage_Channel_Opportunity__c = false;
            testOppty.Submission_Status_2__c = str;
            testOppty.Submission_Status_3__c = str;
        }
        Test.StartTest();
        TriggerExecutionController.setSkipAccountTriggers(True);
        update listOpp;  
        for(Opportunity opp: listOpp){
            if(opp.RecordTypeID ==  TestDataFactory.getRecordTypeIdbyName('Deal Registration-Submitted', 'Opportunity') && opp.Deal_Registration_Status__c == 'Submitted'){
                opp.Deal_Registration_Status__c = 'Rejected';
                mapOldMapTrigger.put(opp.Id,opp);
            }
        } 
        update listOpp[0];
        system.assertEquals(false, listOpp[0].Engage_Channel_Opportunity__c);
        List<Opportunity> listoppres = [SELECT id,name,Engage_Channel_Opportunity__c,
                                        Distributor_Reseller_Name__c,recordtypeid,Submission_Status_2__c,
                                        Submission_Status_3__c,Deal_Registration_Status__c,AccountId,
                                        PartnerAccountID FROM Opportunity WHERE id IN :listOpp];
        System.debug('##oppres:'+listoppres);
        AddPartnerAcctTeamOnDealReg.AddPartnerAcctOnUpdate(listoppres, mapOldMapTrigger);
        AddPartnerAcctTeamOnDealReg.AddAcctTeamOnUpdate(listoppres, mapOldMapTrigger);
        AddPartnerAcctTeamOnDealReg.AddDistiResellerAccTeam(listoppres, mapOldMapTrigger);
        AddPartnerAcctTeamOnDealReg.AddPartnerAcctOnInserttoEngageChannelDeals(listoppres, mapOldMapTrigger);
        Test.StopTest();
    }
    public static testmethod void  addDistiResellerAccTest(){
        TriggerExecutionController.setSkipAllTriggers(true);     
        listAcc = [select id, name from Account limit 2 ];
        listAcc[0].RecordTypeID = TestDataFactory.getRecordTypeIdbyName('End-User Account', 'Account');
        listAcc[0].Participating_in_LOB_Program__c = true;
        listAcc[0].Account_Country__c = 'UNITED STATES';
        listAcc[0].Tax_Registration_Number__c = '124214';
        listAcc[0].ShippingCity = 'testStreet';
        listAcc[0].ShippingState = 'testTexas';
        listAcc[0].ShippingPostalCode = '1234';
        listAcc[1].RecordTypeID = TestDataFactory.getRecordTypeIdbyName('End-User Account', 'Account');
        listAcc[1].Participating_in_LOB_Program__c = true;
        listAcc[1].Account_Country__c = 'UNITED STATES';
        listAcc[1].Partner_Tier__c = 'Tier 1';
        listAcc[1].Partner_Relationship__c = 'Authorized';
        TriggerExecutionController.setSkipAccountTriggers(true);
        update listAcc;
        system.assertNotEquals(null, listAcc[1].Account_Country__c);
        Profile profile = [select Id, Name from profile where Name LIKE '%Admin%' limit 1];
        User testUser = new User(Username='testvaliduser1' +'@DELL.com',
                                 Alias = 'Test', 
                                 Email='Test1'+'@dell.com',            
                                 LastName='Test',
                                 Title='GCC Program Manager', 
                                 ProfileId = profile.Id, 
                                 LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', 
                                 EmailEncodingKey='UTF-8', 
                                 TimeZoneSidKey='America/Los_Angeles',
                                 Badge_Number__c='Test'+System.currentTimeMillis());
        insert testUser;
        Contact newCont = new Contact(AccountId =listAcc[1].Id,
                                      FirstName = 'My Contact First Name',
                                      LastName = 'My Contact Last Name',
                                      Fax = '12345778',
                                      MobilePhone = '9967814567',
                                      Last_Operation_Performed__c = 'testing',
                                      Phone = '09876543',
                                      Status__c  =  'Marketing Suspect',
                                      Email = 'MyFirstName@dell.com');
        insert newCont;          
        List<AccountTeamMember> listatm = new List<AccountTeamMember>();
        AccountTeamMember accTM = new AccountTeamMember();
        accTM.AccountId = listAcc[0].Id;
        accTM.UserId = testUser.Id;
        accTM.TeamMemberRole = 'Account Executive';
        listatm.add(accTM);
        AccountTeamMember accTM1 = new AccountTeamMember();
        accTM1.AccountId = listAcc[1].id;
        accTM1.UserId = testUser.Id;
        accTM1.TeamMemberRole = 'Account Executive';
        listatm.add(accTM1);
        insert listatm;
        List<Opportunity> listOppUpdateId = new List<Opportunity>();
        String str = 'Thank you! The status can be tracked in the Approval Inbox on the \'Home\' tab.';
        list<Opportunity> listOpp = [Select name,Id,AccountID,RecordTypeID from Opportunity limit 1];
        for(Opportunity testOppty: listOpp){
            testOppty.RecordTypeID =  TestDataFactory.getRecordTypeIdbyName('Deal Registration-Submitted', 'Opportunity');
            testOppty.AccountId=listAcc[0].Id;
            testOppty.Deal_Registration_Status__c= 'Rejected';
            testOppty.Engagement_Type__c = 'Public Tender';
            testOppty.Engage_Channel_Opportunity__c = false;
            testOppty.Submission_Status_2__c = str;
            testOppty.Submission_Status_3__c = str;
            testOppty.Distributor_Reseller_Name__c = listAcc[0].Id;
        }
        Test.StartTest();
        TriggerExecutionController.setSkipOpportunityTriggers(True);      
        update listOpp;
        Map<Id, Opportunity> mapOldMapTrigger = new  Map<Id, Opportunity>();                       
        for(Opportunity opp: listOpp){
            if(opp.RecordTypeID ==  TestDataFactory.getRecordTypeIdbyName('Deal Registration-Submitted', 'Opportunity') && opp.Deal_Registration_Status__c != 'Submitted'){
                opp.Deal_Registration_Status__c = 'Rejected';
                opp.Distributor_Reseller_Name__c = listAcc[1].id;
                mapOldMapTrigger.put(opp.Id,opp);
            }
        } 
        List<Opportunity> listoppres = [SELECT id,AccountId,name,Engage_Channel_Opportunity__c,PartnerAccountId,
                                        recordtypeid,Submission_Status_2__c,Submission_Status_3__c,
                                        Deal_Registration_Status__c,Distributor_Reseller_Name__c
                                        FROM Opportunity WHERE id IN :listOpp];
        System.debug('##oppres:'+listoppres);
        AddPartnerAcctTeamOnDealReg.AddDistiResellerAccTeam(listoppres, mapOldMapTrigger);
        AddPartnerAcctTeamOnDealReg.deleteOldOppTeamsOnDistiNameUpdate(listoppres, mapOldMapTrigger);
        Test.StopTest();
        List<OpportunityTeamMember> listotm = [SELECT id from OpportunityTeamMember WHERE OpportunityId =:listoppres[0].id AND UserId = :testUser.id];
    } 
    public static testmethod void  removeOpportunityteammembers(){
        TriggerExecutionController.setSkipAllTriggers(true);    
        System_Behavior_Bypasser__c vr = new System_Behavior_Bypasser__c();
        vr.Bypass_Opportunity_VRs__c = true;
        insert vr;
        listAcc = [select id, name, RecordTypeID, Participating_in_LOB_Program__c from Account limit 2 ];
        listAcc[0].Account_Country__c = 'UNITED STATES';
        listAcc[0].Partner_Tier__c = 'Tier 1';
        listAcc[0].Partner_Relationship__c = 'Authorized';
        listAcc[0].Partner_Type__c = 'Distributor (GCC)';
        listAcc[1].Account_Country__c = 'UNITED STATES';
        listAcc[1].Partner_Tier__c = 'Tier 2';
        listAcc[1].Partner_Relationship__c = 'Authorized';
        listAcc[1].Partner_Type__c = 'Distributor (GCC)';
        TriggerExecutionController.setSkipAccountTriggers(true);
        update listAcc; 
        system.assertEquals(listAcc[1].Partner_Tier__c, 'Tier 2');
        listUser = [select id from user Where isActive=true Limit 1];
        List<AccountTeamMember> listatm = new List<AccountTeamMember>();
        AccountTeamMember accTM1 = new AccountTeamMember();
        accTM1.AccountId = listAcc[0].id;
        accTM1.UserId = listUser[0].Id;
        accTM1.TeamMemberRole = 'Account Executive';
        listatm.add(accTM1);
        insert listatm;
        listOpp = [Select name,id,RecordTypeID  from Opportunity limit 1];
        for(Opportunity testoppty:listOpp){
            testoppty.AccountId= listAcc[0].Id;
            testoppty.Deal_Registration_Status__c= 'New';
            testoppty.Distributor_Reseller_Name__c = listAcc[0].id;
        }
        TriggerExecutionController.setSkipAllTriggers(true);
        test.startTest();
        update listOpp;
        List<Opportunity> listOppty = new List<Opportunity> ([Select id,AccountId,Engage_Channel_Opportunity__c,PartnerAccountId,Distributor_Reseller_Name__c 
                                                              from Opportunity where id =:listOpp[0].id]);
        System.debug('@@@1' + listOppty);
        Map<Id, Opportunity> mapOldMapTrigger = new  Map<Id, Opportunity>();
        for(Opportunity opp: listOpp){
            if(opp.AccountId != null){
                mapOldMapTrigger.put(opp.Id,opp);
                listOpp[0].Distributor_Reseller_Name__c = listAcc[1].id;
            }
        }
        Update listOpp[0]; 
        List<Opportunity> listOppty2 = new List<Opportunity> ([Select id,Distributor_Reseller_Name__c,PartnerAccountId from
                                                               Opportunity where id =:listOpp[0].id]);
        System.debug('@@@2' +listOppty2);  
        OpportunityTeamMember otm = new OpportunityTeamMember();
        otm.OpportunityId = listOpp[0].Id;
        otm.UserId = listUser[0].Id;
        otm.TeamMemberRole = 'Reseller Contact';         
        insert otm;
        AddPartnerAcctTeamOnDealReg.AddPartnerAcctOnUpdate(listOpp, mapOldMapTrigger);
        AddPartnerAcctTeamOnDealReg.AddAcctTeamOnUpdate(listOpp, mapOldMapTrigger);
        AddPartnerAcctTeamOnDealReg.AddPartnerAcctOnUpdate(listOpp, mapOldMapTrigger);
        AddPartnerAcctTeamOnDealReg.AddDistiResellerAccTeam(listOpp, mapOldMapTrigger);
        AddPartnerAcctTeamOnDealReg.deleteOldOppTeamsOnDistiNameUpdate(listOpp, mapOldMapTrigger);
        AddPartnerAcctTeamOnDealReg.AddPartnerAcctOnInserttoEngageChannelDeals(listOpp, mapOldMapTrigger);
        Test.stopTest();
    }  
    public static testmethod void  addPartnerAcctOnInserttoEngageChannelDealsTest(){
        System_Behavior_Bypasser__c vr = new System_Behavior_Bypasser__c();
        vr.Bypass_Opportunity_VRs__c = true;
        insert vr;
        listAcc = [select id, name, RecordTypeID, Participating_in_LOB_Program__c from Account limit 2 ];
        listAcc[0].RecordTypeID = TestDataFactory.getRecordTypeIdbyName('End-User Account', 'Account');
        listAcc[0].Participating_in_LOB_Program__c = true;
        listAcc[0].Account_Country__c = 'UNITED STATES';
        listAcc[0].Partner_Tier__c = 'Tier 1';
        listAcc[0].Partner_Relationship__c = 'Authorized';
        listAcc[0].Partner_Type__c = 'Distributor (GCC)';
        listAcc[0].ShippingCity = 'testStreet';
        listAcc[0].ShippingState = 'testTexas';
        listAcc[0].ShippingPostalCode = '132156';
        listAcc[1].Account_Country__c = 'UNITED STATES';
        listAcc[1].Partner_Tier__c = 'Tier 2';
        listAcc[1].Partner_Relationship__c = 'Authorized';
        listAcc[1].Partner_Type__c = 'Distributor (GCC)';
        TriggerExecutionController.setSkipAccountTriggers(true);
        update listAcc;
        system.assertNotEquals(null, listAcc[1].Partner_Relationship__c);
        Profile profile = [select Id, Name from profile where Name LIKE '%Admin%' limit 1];
        User testUser = new User(Username='testvaliduser1' +'@DELL.com',
                                 Alias = 'Test', 
                                 Email='Test1'+'@dell.com',            
                                 LastName='Test',
                                 Title='GCC Program Manager', 
                                 ProfileId = profile.Id, 
                                 LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', 
                                 EmailEncodingKey='UTF-8', 
                                 TimeZoneSidKey='America/Los_Angeles',
                                 Badge_Number__c='Test'+System.currentTimeMillis());
        insert testUser;
        Contact newCont = new Contact(AccountId =listAcc[1].Id,
                                      FirstName = 'My Contact First Name',
                                      LastName = 'My Contact Last Name',
                                      Fax = '12345778',
                                      MobilePhone = '9967814567',
                                      Last_Operation_Performed__c = 'testing',
                                      Phone = '09876543',
                                      Status__c  =  'Marketing Suspect',
                                      Email = 'MyFirstName@dell.com');
        TriggerExecutionController.setSkipContactTriggers(true);                           
        insert newCont;          
        List<AccountTeamMember> listatm = new List<AccountTeamMember>();
        AccountTeamMember accTM = new AccountTeamMember();
        accTM.AccountId = listAcc[0].Id;
        accTM.UserId = testUser.Id;
        accTM.TeamMemberRole = 'Account Executive';
        listatm.add(accTM);
        AccountTeamMember accTM1 = new AccountTeamMember();
        accTM1.AccountId = listAcc[0].id;
        accTM1.UserId = testUser.Id;
        accTM1.TeamMemberRole = 'Account Executive';
        listatm.add(accTM1);
        TriggerExecutionController.setSkipAllTriggers(true);
        insert listatm;
        TriggerExecutionController.setSkipAllTriggers(false);
        String str = 'Thank you! The status can be tracked in the Approval Inbox on the \'Home\' tab.';
        Map<Id, Opportunity> mapOldMapTrigger = new  Map<Id, Opportunity>();                       
        listOpp= [Select name,id,RecordTypeID,Deal_Registration_Status__c from Opportunity limit 2];
        for(Opportunity testOppty: listOpp){
            mapOldMapTrigger.put(testOppty.Id,testOppty);
            testOppty.RecordTypeId = TestDataFactory.getRecordTypeIdbyName('Deal Registration-Submitted', 'Opportunity');
            testOppty.AccountId=listAcc[0].Id;
            testOppty.Deal_Registration_Status__c= 'Submitted';
            testOppty.Engagement_Type__c = 'Public Tender';
            testOppty.Engage_Channel_Opportunity__c = true;
            testOppty.Submission_Status_2__c = str;
            testOppty.Submission_Status_3__c = str;
            testOppty.Distributor_Reseller_Name__c = listAcc[0].Id;
        }
        listOpp[1].AccountId=listAcc[1].Id;
        listOpp[1].Deal_Registration_Status__c= 'Submitted';
        listOpp[1].Engagement_Type__c = 'Public Tender';
        listOpp[1].Distributor_Reseller_Name__c = listAcc[1].Id;
        Test.StartTest();
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        update listOpp;
        List<Opportunity> listoppres = [SELECT id,name,AccountId,recordtypeid,Submission_Status_2__c,
                                        PartnerAccountID,Submission_Status_3__c,Deal_Registration_Status__c,
                                        Distributor_Reseller_Name__c,Engage_Channel_Opportunity__c 
                                        FROM Opportunity WHERE id IN :listOpp limit 2];
        System.debug('##oppres:'+listoppres);
        List<OpportunityTeamMember> listoppTeam = new List<OpportunityTeamMember>();
        OpportunityTeamMember oppTeam = new OpportunityTeamMember();
        oppTeam.OpportunityId = listOpp[0].Id;
        oppTeam.UserId = listatm[0].UserId;
        oppTeam.TeamMemberRole = listatm[0].TeamMemberRole;
        listoppTeam.add(oppTeam);
        insert listoppTeam;
        List<OpportunityShare> listoppShare = new List<OpportunityShare>();
        OpportunityShare oppShare = new OpportunityShare();
        oppShare.OpportunityId= listOpp[0].Id; 
        oppShare.OpportunityAccessLevel='Edit'; 
        oppShare.UserOrGroupId= listatm[0].UserId; 
        listoppShare.add(oppShare); 
        insert listoppShare;
        AddPartnerAcctTeamOnDealReg.AddPartnerAcctOnInserttoEngageChannelDeals(listoppres, mapOldMapTrigger);
        AddPartnerAcctTeamOnDealReg.AddPartnerAcctOnUpdate(listoppres, mapOldMapTrigger);
        AddPartnerAcctTeamOnDealReg.AddAcctTeamOnUpdate(listoppres, mapOldMapTrigger);
        AddPartnerAcctTeamOnDealReg.AddPartnerAcctOnUpdate(listoppres, mapOldMapTrigger);
        AddPartnerAcctTeamOnDealReg.AddDistiResellerAccTeam(listoppres, mapOldMapTrigger);
        Test.StopTest();
    }   
    public static testmethod void  addEndAccTeamtestChannelOpp(){
        listAcc = [select id, name from Account limit 1 ];
        listAcc[0].RecordTypeID = TestDataFactory.getRecordTypeIdbyName('End-User Account', 'Account');
        listAcc[0].Participating_in_LOB_Program__c = true;
        listAcc[0].Account_Country__c = 'UNITED STATES';
        listAcc[0].Tax_Registration_Number__c = '124214';
        listAcc[0].ShippingCity = 'testStreet';
        listAcc[0].ShippingState = 'testTexas';
        listAcc[0].ShippingPostalCode = '132456';
        listAcc[0].Tax_Registration_Number__c = '124214';
        TriggerExecutionController.setSkipAccountTriggers(true);
        update listAcc;
        system.assertNotEquals(null, listAcc[0].ShippingState);
        Profile profile = [select Id, Name from profile where Name LIKE '%Admin%' limit 1];
        User testUser = new User(Username='testvaliduser' +'@DELL.com',
                                 Alias = 'Test', 
                                 Email='Test'+'@dell.com',            
                                 LastName='Test',
                                 Title='GCC Program Manager', 
                                 ProfileId = profile.Id, 
                                 LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', 
                                 EmailEncodingKey='UTF-8', 
                                 TimeZoneSidKey='America/Los_Angeles',
                                 Badge_Number__c='Test'+System.currentTimeMillis());
        insert testUser;
        List<AccountTeamMember> listatm = new List<AccountTeamMember>();
        AccountTeamMember accTM = new AccountTeamMember();
        accTM.AccountId = listAcc[0].Id;
        accTM.UserId = testUser.Id;
        accTM.TeamMemberRole = 'Account Executive';
        listatm.add(accTM);
        AccountTeamMember accTM1 = new AccountTeamMember();
        accTM1.AccountId = listAcc[0].id;
        accTM1.UserId = testUser.Id;
        accTM1.TeamMemberRole = 'Account Executive';
        listatm.add(accTM1);
        TriggerExecutionController.setSkipAllTriggers(true);
        insert listatm;
        TriggerExecutionController.setSkipAllTriggers(false);
        set<id> setids = new set<id>();
        setids.add(listatm[0].userid);
        List<Opportunity> listOppUpdateId = new List<Opportunity>();
        String str = 'Thank you! The status can be tracked in the Approval Inbox on the \'Home\' tab.';
        listOpp = [Select name,id,RecordTypeID,Deal_Registration_Status__c from Opportunity limit 10];
        for(Opportunity testOppty: listOpp){
            testOppty.RecordTypeId = TestDataFactory.getRecordTypeIdbyName('Channel Opportunity','Opportunity');
            testOppty.AccountId=listAcc[0].Id;
            testOppty.Deal_Registration_Status__c= 'Approved';
            testOppty.Engagement_Type__c = 'Public Tender';
            testOppty.Engage_Channel_Opportunity__c = false;
            testOppty.Submission_Status_2__c = str;
            testOppty.Submission_Status_3__c = str;
        }
        Test.StartTest();
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        update listOpp;
        Map<Id, Opportunity> mapOldMapTrigger = new  Map<Id, Opportunity>();                       
        for(Opportunity opp: listOpp){
            if(opp.RecordTypeID ==  TestDataFactory.getRecordTypeIdbyName('Channel Opportunity','Opportunity') && opp.Deal_Registration_Status__c == 'Approved'){
                opp.Deal_Registration_Status__c = 'Submitted';
                opp.RecordTypeID = TestDataFactory.getRecordTypeIdbyName('Deal Registration-Submitted','Opportunity');
                mapOldMapTrigger.put(opp.Id,opp);
            }
        } 
        List<Opportunity> listoppres = [SELECT id,name,Engage_Channel_Opportunity__c,Distributor_Reseller_Name__c,recordtypeid,Submission_Status_2__c,
                                        Submission_Status_3__c,Deal_Registration_Status__c,AccountId,PartnerAccountID FROM Opportunity WHERE id IN :listOpp];
        AddPartnerAcctTeamOnDealReg.AddAcctTeamOnUpdate(listoppres, mapOldMapTrigger);
        Test.StopTest();
        List<OpportunityTeamMember> listotm = [SELECT id from OpportunityTeamMember WHERE OpportunityId IN :listoppres AND UserId = :testUser.id];
        delete listotm[0];
    }
    private static void createPartnerUser(string straccountCountryCode, string struserLanguageCode){
        listAcc = [select id, name from Account limit 1 ];
        listAcc[0].Participating_in_LOB_Program__c = true;
        listAcc[0].Account_Country_Code__c = straccountCountryCode;
        listAcc[0].Is_GTM_Partner__c = true;
        listAcc[0].IsPartner = true;
        TriggerExecutionController.setSkipAccountTriggers(true);
        update listAcc;
        contact con = new Contact(AccountId = listAcc[0].Id, Email = getUniqueString() + '@dell.com.fdev', Lastname = 'UT');
        insert con;
    }    
}