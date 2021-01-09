/* 
* Test Class logic related to LinkedPartnerTracksControllerTest
* Revision CR Number   Release No        Date            Modified By               Description
* -------- ---------   ----------     -----------       ------------               -----------
*                                       26-Sep-2018      Venugopalachary k         Implement Test Data Factory                                   
*/ 
@isTest(seeAlldata = false)
private class NotifyPartnerandEndUseracctteamsTest{
    static list<Account> listAcc;
    static list<opportunity> listOpp=new list<opportunity>();
    static Opportunity opptyA;  
    @testSetup 
    static void createTestData(){
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
        List<Account> listAccfromFactory=TestDataFactory.createNAccount(1, 'Partner Account');
        TriggerExecutionController.setSkipAllTriggers(true);
        insert listAccfromFactory;
        List<Opportunity> listOppFromFactory=TestDataFactory.createNOpportunities(2, 'Deal Registration');
        TriggerExecutionController.setSkipAllTriggers(true);
        insert listOppFromFactory;
    }
    public static testmethod void method2() {
        TriggerExecutionController.setSkipAllTriggers(true);
        Map<Id, Opportunity> mapOldOpportunity = new Map<Id, Opportunity>();
        Map<Id, Opportunity> mapNewOpportunity = new Map<Id, Opportunity>();
        List<Opportunity> listopp1= new List<Opportunity>();
        List<Profile> listuserProfile = [select id,name from profile where name like '%Portal%' order by name limit 2 ];   
        List<Profile> listpartnerProfiles = [select Id, Name from Profile where name like '%Portal%' limit 1];
        Test.startTest();
        listAcc=[select id From Account];
        listOpp=[select id from Opportunity];
        listOpp[0].AccountId=listAcc[0].id;
        listOpp[1].AccountId=listAcc[0].id;
        update listOpp;
        
        mapOldOpportunity.put(listOpp[0].Id, listOpp[0]);
        mapOldOpportunity.put(listOpp[1].Id, listOpp[1]);
        System.assertEquals(listOpp[0],listOpp[0]);
        triggerexecutioncontroller.setSkipAllTriggers(true);
        Opportunity oppUpdate = [select id, Deal_Registration_Status__c from Opportunity where id =:listOpp[1].Id];
        oppUpdate.Deal_Registration_Status__c ='Approved';
        update oppUpdate;
        listopp1.add(oppUpdate);
        User u = [SELECT PortalRole FROM User WHERE Profile_Name__c LIKE '%Portal%' LIMIT 1];
        List<OpportunityTeamMember> listOpptyTeamMem = new List<OpportunityTeamMember>();
        for(Integer inti=0;inti<=50;inti++){
            OpportunityTeamMember otm = new OpportunityTeamMember();
            otm.OpportunityId = listOpp[1].Id;
            otm.TeamMemberRole = 'Sales Support'; 
            OTM.UserId = u.id; 
            otm.Partner_Account_Member__c= true;
            otm.End_User_Acct_Member__c = true;
            otm.IsUploadedfromCSV__c= true;
            listOpptyTeamMem.add(otm);
        }
        if(listOpptyTeamMem.size() > 0){
            insert listOpptyTeamMem;
        }
        NotifyPartnerandEndUseracctteams.NotifyOpptyTeam(listopp1,mapOldOpportunity);
        TriggerExecutionController.setSkipAllTriggers(false);
    } 
}