@isTest
private class UpdateLOBRegCntryTest {
static testMethod void validateupdateLOBRegCntry() {


TriggerExecutionController.setSkipAllTriggers(true);
Country__c cntry=new Country__c(Name='ABC',Code__c='xy');
insert cntry;
Country__c cntryNew=new Country__c(Name='America',Code__c='ab');
insert cntryNew;
User usr=[Select id,Name,LOB_Title__c from User Where LOB_Title__c=:'GCC Global Program Manager' LIMIT 1];
System.runAs(usr) {
LOB_MailBox_Administration__c lobMailBox =new LOB_MailBox_Administration__c(Name='Test LOB',Country__c=cntry.id,Support_Email__c='abc@aol.in',Active__c=true);
insert lobMailBox ;
LOB_MailBox_Administration__c lobMailBoxNew =new LOB_MailBox_Administration__c(Name='Test LOB',Country__c=cntryNew.id,Support_Email__c='abc@us.in',Active__c=true);
insert lobMailBoxNew ;
}
RecordType rt=[Select Id,Name from RecordType where Name='Partner Account' limit 1];
RecordType rtNew=[Select Id,Name from RecordType where Name='End-User Account' limit 1];
    
Account accinsert=new Account(Name='testAccount',RecordTypeId=rt.Id,Account_Country__c='India',Is_GTM_Partner__c=true);
insert accinsert;
Account accNewinsert=new Account(Name='testAccount1',RecordTypeId=rtNew.Id,Account_Country__c='India',Participating_in_LOB_Program__c=true);
insert accNewinsert;
Account accinsertCtnry=new Account(Name='testAccount2',RecordTypeId=rtNew.Id,Participating_in_LOB_Program__c=true);
insert accinsertCtnry;
//,Registered_End_User__c=accNewinsert.Id
LOB_Registration__c lobReg=new LOB_Registration__c(Registered_End_User__c=accNewinsert.Id,Preferred_GTM_Partner_Account__c=accinsert.Id,City__c = 'testCity',State_Province_Region__c = 'testState');
insert lobReg;

LOB_Registration__c lobReg1=new LOB_Registration__c(Registered_End_User__c=accinsertCtnry.Id,Preferred_GTM_Partner_Account__c=accinsert.Id,City__c = 'testCity',State_Province_Region__c = 'testState');
insert lobReg1;

TriggerExecutionController.setSkipAllTriggers(false);
Test.startTest();
Account accupdate=new Account(Id=accNewinsert.Id,Name='testAccount',Account_Country__c='America');
update accupdate;
Account accupdate1=new Account(Id=accNewinsert.Id,Name='testAccount1',Account_Country__c='Africa');
update accupdate1;
Account accupdate2=new Account(Id=accinsertCtnry.Id,Name='testAccount1');
update accupdate2;
Test.stopTest();
}
}