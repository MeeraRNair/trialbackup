/* 12-Dec-2018  Hari A STORY 5907651 Removed reference for the fields lob_registration_id__c */

@isTest
private class ValidateLOBRegIdTest{
static testMethod void runPositiveTestCases() {
RecordType rt=[Select Id,Name from RecordType Where Name=:'Create New Deal From LOB' LIMIT 1];
Account acc=new Account(Name='Test Account',Participating_in_LOB_Program__c=true);
insert acc;
//Account_Branch__c accBranch=new Account_Branch__c(Name='Test Branch',Account__c=acc.Id);
//insert accBranch;
LOB_Registration__c lob=new LOB_Registration__c(Registered_End_User__c=acc.Id,LOB_Award_Type__c = 'Account');
insert lob;
Opportunity opp=new Opportunity(Name='Test Opportunity',StageName='Qualification',CloseDate=System.Today(),RecordTypeId=rt.Id);
    Try{
    insert opp;
    }
    Catch(Exception e){}
    }
}