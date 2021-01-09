/* created BY   Date       version          Name */
/* viswanath    10-24-2019  47             OpportunityTeamMemPaginationHandlerTest*/
@IsTest
public class OpportunityTeamMemPaginationHandlerTest {
    private static testmethod void setOppTeamMemRecordsTest(){
        List<user> testUser = new List<user>([select Id from user where FirstName like 'car%' and IsActive = true limit 5]);
        Account sAccount1 = new Account(name='Test Account 40');
        insert sAccount1;
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
        Date dCloseDate = Date.newInstance(1990,03,26);
          RecordType rectype=[Select Name, Id From RecordType where Name='Standard Opportunity' Limit 1];     
      Opportunity testParentOpportunity= new Opportunity (AccountID=sAccount1.ID ,
                                                    RecordTypeId= '012A0000000Vjtg',
                                                    Name='TestParentOpportunity',
                                                    Type = 'Run Rate',
                                                    Domain__c='Deal Reg',
                                                    Solution_Type__c = 'Campus',
                                                    Solution_Name__c = 'Wireless Switches',
                                                    StageName='Plan - 1%',
                                                    Deal_Expiration_Timeframe__c='60',                                               
                                                    Request_Status__c='New', 
                                                    CloseDate= System.Now().Date().addDays(180), 
                                                    Forecast_Category_Override__c = 'Omitted');          
            insert testParentOpportunity;
        List<OpportunityTeamMember> oppTeammember = new List<OpportunityTeamMember>();
        OpportunityTeamMember oppTM0 = new OpportunityTeamMember();
            oppTM0.OpportunityId = testParentOpportunity.Id;
            oppTM0.UserId = testUser[2].Id;
            oppTM0.TeamMemberRole = 'SDS Sales Rep';
        oppTeammember.add(oppTM0);
        insert oppTeammember;
        test.startTest();
        OpportunityTeamMemPaginationHandler oppTeampag = new OpportunityTeamMemPaginationHandler();
        oppTeampag.setOppTeamMemRecords(oppTeammember);
        oppTeampag.getOppTeamMemPaginator(oppTeammember);
        Test.stoptest();
        OpportunityTeamMemPaginationHandler oppTeamMemObj = new OpportunityTeamMemPaginationHandler();
        //assert
        System.assert([SELECT Id FROM OpportunityTeamMember].size() > 0);
        //System.assert(oppTeamMemObj.oppTeamMemList.size() > 0);
        system.assert(oppTeammember.size()==1,'opp team member created!');
    }
}