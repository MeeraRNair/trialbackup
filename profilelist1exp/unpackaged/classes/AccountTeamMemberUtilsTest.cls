@isTest
public class AccountTeamMemberUtilsTest {
    
    static Account acc;
    static Opportunity opp;    
    static OpportunityTeamMember otm;
    static OpportunityTeamMember otm1;
    static User u;
    static List<AccountTeamMember> listTeam;
    static List<AccountTeamMember> listATM;
    static list<User> listUser;
    static list<Account> listAccs;
    
    
    @testSetup static void setup() {
        // Create common test OWD settings
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
        

    }
    static void createTestData(){
        
       
        
        TriggerExecutionController.setSkipAllTriggers(true);  
        
        List<Account> listfinalAccounts = new List<Account>();
        List<Account> listAcc = createNAccount(1, 'Partner Account');
        listfinalAccounts.addAll(listAcc);
        
        List<Account> listAcc2 = createNAccount(1, 'Master Account');
        listfinalAccounts.addAll(listAcc2);
        insert listfinalAccounts;
        
        List<User> listUsr = createNPortalUser(3);
        insert listUsr;
        
        Id acRecTypeId=IdLookupUtils.getRecordTypeId('End-User Account', 'Account', true);
        
        acc = new Account(name='TEST',recordtypeid=acRecTypeId);         
        insert acc;
        
        opp = new Opportunity(AccountId = acc.Id, Name = 'testOpportunity',CurrencyIsoCode = 'USD', Type = 'Renewal', CloseDate = system.Today(), Domain__c = 'Non Domain', Solution_Type__c = 'Cloud Integration', Solution_Name__c = 'Boomi Solution', No_times_BookDate_moved__c = 0, StageName = 'Plan - 1%' );               
        insert opp;
        
        Profile profile = new profile();
        for(Profile userProfile:[Select id from Profile where name like '%Sales Rep' Limit 1]){
            profile=userprofile;
        } 
        
        String strusername = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.fdev'; 
        u = new User(Alias = 'CM101',
                     LastName = 'testCM101',
                     Email = 'x.y@ust-global.com',
                     Username = strusername,
                     CommunityNickname = 'testATM59',
                     EmailEncodingKey = 'ISO-8859-1',
                     TimeZoneSidKey = 'America/Panama',
                     LocaleSidKey = 'en_US',
                     LanguageLocaleKey = 'en_US',
                     ProfileId = profile.id,
                     Badge_number__c='CM101', isActive = true);
        insert u;
    }
    public static List<Account> createNAccount(Integer intNumRecords,String strAccountType){
        
        String strMasterAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Master_Account_Record_Type_Name).getRecordTypeId();
        String strPartnerAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();
        String strEndUserAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End-User Account').getRecordTypeId();
        List<Account> listAcc = new List<Account>();
        
        for(Integer inti = 1; inti <= intNumRecords ; inti++){
            Account acc = new Account();
            acc.Name = 'Test Account Version'+inti+'_'+string.valueof(Math.abs(Crypto.getRandomInteger()));
            acc.NPS_Qualified_Contacts__c = 1;
            acc.Website = 'www.dell.com';
            
            if(strAccountType.equals('Master Account')){
                acc.Master_Group_Affinity_ID__c='MGAff1212'+string.valueof(Math.abs(Crypto.getRandomInteger())); 
                acc.RecordTypeId = strMasterAccountRecordTypeId;
            }
            else if(strAccountType.equals('Partner Account') ){
                acc.Account_ID__c='SMAff1211'+string.valueof(Math.abs(Crypto.getRandomInteger()));
                acc.RecordTypeId = strPartnerAccountRecordTypeId;
            }
            else{
                acc.Account_ID__c='EUAAff1211'+string.valueof(Math.abs(Crypto.getRandomInteger()));
                acc.RecordTypeId = strEndUserAccountRecordTypeId;
                acc.Participating_in_LOB_Program__c=true;
            }
            
            listAcc.add(acc);
        }
        return listAcc;
    }
    
    public static List<User> createNPortalUser(Integer intNumRecords){
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipContactTriggers(true);
        List<Account>listMA = createNAccount(1,'Master Account');
        if(listMA.size() > 0){
            insert listMA;
        }
        
        List<Contact> listActiveCon = new List<Contact>();
        for(Integer inti = 1; inti <= intNumRecords ; inti++){
            
            Contact con = new Contact(AccountId = listMA[0].Id,
                                      Email='testcontact_'+inti+'@DELLTEAM.com',
                                      FirstName = 'Test Contact', 
                                      LastName = 'Version'+inti+'_'+String.valueOf(Math.abs(Crypto.getRandomInteger())),
                                      Status__c = 'Customer',phone = '6739543210',
                                      //EligibleTracks__c = listPT[i-1].Id,
                                      Allow_Partner_Central_User__c=true, Premier_Partner__c = true
                                     );
            listActiveCon.add(con);
            
        }
        Integer intuserNumber = Math.abs(Crypto.getRandomInteger());
        String strnewusername = 'Test '+intuserNumber +'_data'+'@DELLTEAM.com'; 
        String strbadgeNumber = String.valueOf(intuserNumber )+string.valueof(Math.abs(Crypto.getRandomInteger()));
        
        
        insert listActiveCon;
        
        List<Profile> listp = new List<Profile>([select Id,name from Profile where UserType =:'PowerPartner' limit 2]);
        List<User> listActiveUsr = new List<User>();
        for(Integer inti = 1; inti <= intNumRecords ; inti++){
            User newUser = new User(profileId = listp [1].id,username =listActiveCon[inti-1].Email,
                                    email = listActiveCon[inti-1].Email,Badge_Number__c=null, 
                                    emailencodingkey = 'UTF-8',localesidkey = 'en_US',languagelocalekey = 'en_US',
                                    timezonesidkey = 'America/Los_Angeles',alias='nuser'+inti,
                                    lastname=listActiveCon[inti-1].LastName,
                                    contactId = listActiveCon[inti-1].id,
                                    Enable_Partner_Deal_Registration__c = true, Enable_Partner_Lead_Management__c = true, 
                                    Enable_As_Partner_Lead_Super_User__c = true, isActive = true);
            listActiveUsr.add(newUser);
        }
        return listActiveUsr;
        
    }
    
   
    static testmethod void checkOpportunityAccessLevelTest(){
        
        createTestData();
        //Create the AccountTeam
        listTeam = new List<AccountTeamMember>();
        for(Integer inti = 0; inti< 5; inti++) {
            
            AccountTeamMember newTeam = new AccountTeamMember(AccountId = acc.ID,
                                                              TeamMemberRole = 'Technical Sales',UserId = u.ID,AccountAccessLevel ='Edit',OpportunityAccessLevel='None',CaseAccessLevel='None');
            listTeam.add(newTeam);
        }
        Test.startTest();
        TriggerExecutionController.setSkipAllTriggers(false);
        // AccountTemmemberUtils.checkOpportunityAccessLevel(listTeam); 
        insert listTeam;
        TriggerExecutionController.setSkipAllTriggers(true);
        Test.stopTest(); 
        //AccountTemmemberUtils.checkOpportunityAccessLevel(listTeam);  
        system.debug('accteam---------'+listTeam);
        TriggerExecutionController.setSkipAllTriggers(false);
        listATM = [Select Id,AccountId,AccountAccessLevel,OpportunityAccessLevel,CaseAccessLevel From AccountTeamMember Where AccountId =:acc.Id];
        //AccountTemmemberUtils.checkOpportunityAccessLevel(listATM); 
        system.debug('listATM---------'+listATM);
        listATM[0].TeamMemberRole = 'Inside Sales Rep'; 
        update listATM; 
        system.assertEquals(1, listATM.size());
    }
    static testMethod Void checkOpportunityAccessLevelTest2(){
        createTestData();
        //Create the AccountTeam
        try{
            listTeam = new List<AccountTeamMember>();
            for(Integer inti = 0; inti< 5; inti++) {
                AccountTeamMember newTeam = new AccountTeamMember(AccountId = acc.ID,
                                                                  TeamMemberRole = 'Technical Sales',UserId = u.ID,AccountAccessLevel ='Read',OpportunityAccessLevel='None',CaseAccessLevel='None');
                listTeam.add(newTeam);
            }
            
            Test.startTest();
            TriggerExecutionController.setSkipAllTriggers(false);
            AccountTemmemberUtils.checkOpportunityAccessLevel(listTeam); 
            insert listTeam;
            system.assertNotEquals(0, listTeam.size());
            TriggerExecutionController.setSkipAllTriggers(true);
            Test.stopTest(); 
            
        }
        catch(Exception e){
            system.debug('Error Message'+e);
        }
    }
    
    public static testMethod void publishAccountShareForMasterGroupTest(){
        createTestData();
        List<Account> listAccUpd = new List<Account>();
        List<Contact> listCon = new List<Contact>();
        List<Account> listMAsterAcc =new list<Account>();
        List<AccountTeamMember> listATMS =new List<AccountTeamMember>();
        List<Share_Records__e> listShareRecords = new List<Share_Records__e>();
        String strMasterGroupId;
        listUser = [SELECT Id,ContactId,Contact.AccountId, isActive FROM User WHERE Email like 'testcontact_%' AND isActive=true];
        listAccs = [SELECT Id,Account_ID__c,Master_Group_Id__c FROM Account WHERE Account_ID__c like 'SMAff1211%'];
        listMAsterAcc = [SELECT Id FROM Account WHERE Master_Group_Affinity_ID__c like 'MGAff1212%'];
        if(listUser.size() > 0){
            strMasterGroupId = String.valueOf(listUser[0].Contact.AccountId);
            System.debug('master group '+listMAsterAcc);
            for(Account acc :listAccs){
                acc.Master_Group_Id__c = listMAsterAcc[0].Id; //strMasterGroupId;
                listAccUpd.add(acc);  
            }
            
            if(listAccUpd.size() > 0){
                TriggerExecutionController.setSkipAllTriggers(true);
                update listAccUpd;
            }
            
            for(User u : listUser){
                AccountTeamMember atm = new AccountTeamMember();
                atm.UserId = u.Id;
                atm.AccountAccessLevel = 'Edit';
                atm.AccountId = listAccs[0].Id;
                atm.TeamMemberRole = 'Account Executive';
                listATMS.add(atm);
            }
            
            Test.startTest();
            if(listATMS.size() > 0){
                  insert listATMS;
                        String strMockMetaData = '';
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'BeforeDelete' => new List<Boolean>{false, false, false, true, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "AccountTeamMember", "Class_Name__c": "AccountTeamMemberTriggerHandlerBD"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
    
                              TriggerExecutionController.setSkipAllTriggers(false);
                
                delete listATMS;
                
                AccountTemmemberUtils.publishRequestForRevokeAccountShareForMasterGroup(listATMS);
                
                 for(AccountTeamMember atm : listATMS){
                Share_Records__e shareRecObj = new Share_Records__e();
                shareRecObj.AccountId__c = atm.AccountId;
                shareRecObj.User_Id__c = atm.UserId;
                shareRecObj.Account_Access_Level__c = atm.AccountAccessLevel;
                shareRecObj.Mode_of_Event__c = 'Deletion';
                listShareRecords.add(shareRecObj); 
            }
                
                 AccountTemmemberUtils.revokeAccountShareForMasterGroup(listShareRecords);
            }
           //System.assertEquals(3, listUser.size());
            Test.stopTest();
        }
    }
    
    public static testMethod void revokeAccountShareForMasterGroupTest(){
        createTestData();
 
        List<Account> listAccUpd = new List<Account>();
        List<Contact> listCon = new List<Contact>();
        List<AccountTeamMember> listATMS =new List<AccountTeamMember>();
        List<Share_Records__e> listShareRecords = new List<Share_Records__e>();
        String strMasterGroupId;
        listUser = [SELECT Id,ContactId,Contact.AccountId, isActive FROM User WHERE Email like 'testcontact_%' AND isActive=true];
        listAccs = [SELECT Id,Account_ID__c,Master_Group_Id__c FROM Account WHERE Account_ID__c like 'SMAff1211%'];
        List<Account> listMAsterAcc =new list<Account>();
        listMAsterAcc = [SELECT Id FROM Account WHERE Master_Group_Affinity_ID__c like 'MGAff1212%'];
        if(listUser.size() > 0){
            strMasterGroupId = String.valueOf(listUser[0].Contact.AccountId);
            for(Account acc :listAccs){
                acc.Master_Group_Id__c = listMAsterAcc[0].Id;//strMasterGroupId;
                listAccUpd.add(acc);  
            }
            
            if(listAccUpd.size() > 0){
                TriggerExecutionController.setSkipAllTriggers(true);
                update listAccUpd;
            }
            
            for(User u : listUser){
                AccountTeamMember atm = new AccountTeamMember();
                atm.UserId = u.Id;
                atm.AccountAccessLevel = 'Edit';
                atm.AccountId = listAccs[0].Id;
                atm.TeamMemberRole = 'Account Executive';
                atm.Published_MGShare_Event__c = true;
                listATMS.add(atm);
            }
            
            Test.startTest();
            if(listATMS.size() > 0){
                 insert listATMS;
                  
            AccountTemmemberUtils.revokeAccountShareForMasterGroup(listATMS);
           
                
               
            }
            for(AccountTeamMember atm : listATMS){
                Share_Records__e shareRecObj = new Share_Records__e();
                shareRecObj.AccountId__c = atm.AccountId;
                shareRecObj.User_Id__c = atm.UserId;
                shareRecObj.Account_Access_Level__c = atm.AccountAccessLevel;
                shareRecObj.Mode_of_Event__c = 'Insertion';
                listShareRecords.add(shareRecObj); 
            }
            AccountTemmemberUtils.createMGAccountShare(listShareRecords);
          
            //System.assertEquals(3, listUser.size());
            Test.stopTest();
        }
    }
}