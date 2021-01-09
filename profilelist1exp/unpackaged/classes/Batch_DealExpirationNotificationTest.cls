@isTest
private class Batch_DealExpirationNotificationTest{
    @testSetup static void setup() {
        OWD__c oWDsetting = new OWD__c();
        oWDsetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        oWDsetting.Oppty_Stage10__c = 'Discover - 10%';
        oWDsetting.Oppty_Stage100__c = 'Win - 100%';
        oWDsetting.Oppty_Stage30__c = 'Qualify - 30%';
        oWDsetting.Oppty_Stage60__c = 'Propose - 60%';
        oWDsetting.Oppty_Stage90__c = 'Commit - 90%';
        oWDsetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        oWDsetting.Oppty_Stage1__c = 'Plan - 1%';
        insert oWDsetting;
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTdf;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(2, 'Deal Registration');
        insert listOppTdf;
    }
    public static testMethod void testBatchDealExpirationNotification() {
        TriggerExecutionController.setSkipAllTriggers(true);
        Map<Id, Opportunity> mapOldOpportunity = new Map<Id, Opportunity>();
        List<Profile> listpartnerProfiles = [select Id, Name from Profile where name like '%Portal%' limit 1];
        Test.startTest();
        list<Account> listAcc=[SELECT ID FROM Account LIMIT 1];
        listAcc[0].Account_Country__c = 'United States';
        listAcc[0].Partner_Type__c = 'Distributor (GCC)';
        listAcc[0].GTM_MOdel__c = 'Dell DIRECT FIELD';
        listAcc[0].Partner_Tier__c = 'Tier 1';
        listAcc[0].Partner_Relationship__c = 'Authorized';
        update listAcc; 
        Contact con = new Contact(FirstName='test',LastName='Test2',Email='test@dell.com',MailingStreet='test',MailingCity='test',MailingState='test',
                                  MailingCountry='test',AccountId=listAcc[0].Id,Phone='12345',MobilePhone='999998665',Eloqua_ID__c='0033B000006adUl');
        insert con; 
        User partnerUser = new User(Username='MyUsername' + System.currentTimeMillis() + '@dell.com',
                                    Alias = 'MTU9', 
                                    Email='Email@dell.com', 
                                    FirstName='MyUserFirstName', 
                                    LastName='MyUserLastName',  
                                    ProfileId = listpartnerProfiles.get(0).Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='796011', 
                                    isActive = TRUE,
                                    ContactId = con.Id);
        insert partnerUser;
        List<AccountTeamMember> listAtm = new List<AccountTeamMember>();
        AccountTeamMember accTM1 = new AccountTeamMember();
        accTM1.AccountId = listAcc[0].id;
        accTM1.UserId = partnerUser.Id;
        accTM1.TeamMemberRole = 'Account Executive';
        listAtm.add(accTM1);
        insert listAtm;
        list<Opportunity> listOpp=[SELECT ID FROM Opportunity LIMIT 2];
        for(Opportunity opp : listOpp){
            opp.AccountId=listAcc[0].id;
            opp.StageName='Qualify - 30%';
            opp.Competitor_Lost_To__c='Absolute';
            opp.CloseDate = System.Today() + 30;
        }
        listOpp[1].Deal_Registration_Status__c ='New';
        listOpp[1].Deal_Expiration_Date__c  = system.toDay().addDays(10);
        listOpp[1].Solution_Type__c = 'Client Hardware Only';
        update listOpp;
        mapOldOpportunity.put(listOpp[0].Id, listOpp[0]);
        listOpp[1].Deal_Registration_Status__c ='Approved';
        update listOpp;
        List<OpportunityTeamMember> listOpptyTeamMem = new List<OpportunityTeamMember>();
        for(Integer inti=0;inti<=50;inti++){
            OpportunityTeamMember oTM = new OpportunityTeamMember();
            oTM.OpportunityId = listOpp[1].Id;
            oTM.TeamMemberRole = 'Sales Support'; 
            oTM.UserId = partnerUser.Id; 
            oTM.Partner_Account_Member__c= true;
            oTM.End_User_Acct_Member__c = true;
            oTM.IsUploadedfromCSV__c= true;
            listOpptyTeamMem.add(oTM);
        }
        if(listOpptyTeamMem.size() > 0){
            insert listOpptyTeamMem;
        }
        Batch_DealExpirationNotification dlExtport = new Batch_DealExpirationNotification();
        Database.executeBatch(dlExtport);
        system.assertEquals(listOpptyTeamMem[0].OpportunityId, listOpp[1].id);
        Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false);
    }  
}