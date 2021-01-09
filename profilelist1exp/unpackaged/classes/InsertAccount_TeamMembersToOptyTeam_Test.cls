/*        
* Revision Ref Number         Release No  Date            Modified By     Description
* -------- ----------         ----------  -----------     ------------    -----------
* 1.0      N/A                N/A         N/A             N/A             N/A 
* 2.0      CR 16970           FY20-0202   08-01-2019      Emily           Removed virtualization__c
*/

@isTest
public class InsertAccount_TeamMembersToOptyTeam_Test{
    @testSetup static void setup() {
        OWD__c owdSetting = new OWD__c();
        owdSetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        owdSetting.Oppty_Stage10__c = 'Discover - 10%';
        owdSetting.Oppty_Stage100__c = 'Win - 100%';
        owdSetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdSetting.Oppty_Stage60__c = 'Propose - 60%';
        owdSetting.Oppty_Stage90__c = 'Commit - 90%';
        owdSetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdSetting.Oppty_Stage1__c = 'Plan - 1%';
        insert owdSetting;
    }   
    //insert Custom Setting for test classes -Afiq FY180203 8 Feb 2018 - END
    public static testMethod void method1() {
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAcc=TestDataFactory.createNAccount(1, 'Partner Account');
        insert listacc;
        list<user> listUser=TestDataFactory.createNPortalUser(8);
        insert listUser;
        AccountTeamMember testACT1 = new AccountTeamMember(UserId=listUser[0].Id, TeamMemberRole='OEM SR', AccountId=listAcc[0].Id);
        AccountTeamMember testACT2 = new AccountTeamMember(UserId=listUser[1].Id, TeamMemberRole='QQQ SR', AccountId=listAcc[0].Id);
        AccountTeamMember testACT3 = new AccountTeamMember(UserId=listUser[2].Id, TeamMemberRole='OEM SR', AccountId=listAcc[0].Id);
        AccountTeamMember testACT4 = new AccountTeamMember(UserId=listUser[3].Id, TeamMemberRole='QQQ SR', AccountId=listAcc[0].Id);
        AccountTeamMember testACT5 = new AccountTeamMember(UserId=listUser[4].Id, TeamMemberRole='MSG SR', AccountId=listAcc[0].Id);
        AccountTeamMember testACT6 = new AccountTeamMember(UserId=listUser[5].Id, TeamMemberRole='QQQ SR', AccountId=listAcc[0].Id);
        AccountTeamMember testACT7 = new AccountTeamMember(UserId=listUser[6].Id, TeamMemberRole='MSG SR', AccountId=listAcc[0].Id);
        AccountTeamMember testACT8 = new AccountTeamMember(UserId=listUser[7].Id, TeamMemberRole='QQQ SR', AccountId=listAcc[0].Id);
        List<AccountTeamMember> listtestACT = new List<AccountTeamMember>();
        listtestACT.add(testACT1);
        listtestACT.add(testACT2);
        listtestACT.add(testACT3);
        listtestACT.add(testACT4);
        listtestACT.add(testACT5);
        listtestACT.add(testACT6);
        listtestACT.add(testACT7);
        listtestACT.add(testACT8);
        insert listtestACT;
        list<Opportunity> listOpp=TestDataFactory.createNOpportunities(2, 'Standard Opportunity');
        for(Opportunity opp : listOpp){
            opp.accountid=listAcc[0].id;
            opp.Solution_Type__c='IT Simplification';
            opp.Primary_Product_Delivery_Address_Region__c='NORTH AMERICA';
            opp.Primary_Product_Delivery_Address_Country__c='UNITED STATES';
            opp.OS_Type__c='Solaris';
        }
        insert listOpp;
        system.assertEquals(listOpp[0].Solution_Type__c, 'IT Simplification');
        ApexPages.StandardController standardController = new ApexPages.StandardController(listAcc[0]);
        InsertAccount_TeamMembersToOptyTeam tem = new InsertAccount_TeamMembersToOptyTeam(standardController );
        tem.doAction();
    }
}