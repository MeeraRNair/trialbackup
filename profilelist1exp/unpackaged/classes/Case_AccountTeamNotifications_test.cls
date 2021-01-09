/*
REVISION HISTORY
================
Version    Author          Date               Description
-------    ------          ----               -------------        
1.0        venu           18-10-2019          Implimented TestDataFactory        
*/
@isTest
public class Case_AccountTeamNotifications_test {
    @testSetup static void setup(){
        TriggerExecutionController.setSkipAllTriggers(true);
        list<case> listCaseTDF=TestDataFactory.createNCases(1);
        insert listCaseTDF;
        list<Account> listAccTDF=TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTDF;
        list<User> listUserTDF = TestDataFactory.createNPortalUser(1);
        listUserTDF[0].isActive=true;
        insert listUserTDF;        
        TriggerExecutionController.setSkipAllTriggers(false);
    }  
    public static testmethod void sendNotificationsMethod(){
        TriggerExecutionController.setSkipAllTriggers(true);
        Test.StartTest();
        list<Account> listAcc=[select id  from Account limit 1];
        Contact newCont = new Contact(FirstName = 'conv', Phone = '9876543987', AccountId = listAcc[0].id, Email = 'abc@dell.comfdev', Lastname = 'UT', 
                                      Decision_Making_Role__c = 'Influencer', Job_Function__c = 'Finance', Job_Function_Role__c = 'Finance Manager', Primary_Contact__c = false,
                                      MobilePhone = '991122789', Eloqua_ID__c = '1234');
        insert newCont;
        
        User u =[select id from User Where isActive=true Limit 1];
        accountTeammember ac1=new accountTeammember(accountid=listAcc[0].id ,userid=u.id,TeamMemberRole='Inside Sales Rep');
        insert ac1;
        list<case> listCase=[select id,RecordTypeId,Accountid,Status,Origin,Contactid,Priority,Description,Unauthenticated_Case__c from case limit 1];
        listCase[0].Accountid = listAcc[0].id;
        listCase[0].Contactid = newCont.id;
        update listCase;
        Case_AccountTeamNotifications.SendNotifications(listCase,'AfterInsert',null);
        Case_AccountTeamNotifications.SendNotifications(listCase,'AfterUpdate',null);
        system.assertEquals( newCont.AccountId , listAcc[0].id);
        Test.StopTest();
        TriggerExecutionController.setSkipAllTriggers(false);  
    }
}