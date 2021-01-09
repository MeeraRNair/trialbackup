@isTest

private class LOBRegistrationAvailableActionCntrlrtest {

static Testmethod void LOBRegistrationTest1(){

    Account ac = new Account(Name='test',Description='test description',Participating_in_LOB_Program__c=true);
    insert ac;
    account acc = [select id from Account where id =: ac.Id ];
    LOB_Registration__c lb = new LOB_Registration__c(LOB_Name__c = 'Server', State_Province_Region__c = 'India', City__c = 'Hyd', Registered_End_User__c= acc.Id);
    insert lb;
    Test.startTest();
    ApexPages.StandardController cont = new ApexPages.StandardController(lb);
    Apexpages.currentpage().getParameters().put('action','Approve');
    LOBRegistrationAvailableActionCntrlr lr = new LOBRegistrationAvailableActionCntrlr(cont);
    lr.redirect();
    Test.stopTest();
  }
  
  static Testmethod void LOBRegistrationTest2(){

    Account ac = new Account(Name='test',Description='test description',Participating_in_LOB_Program__c=true);
    insert ac;
    account acc = [select id from Account where id =: ac.Id ];
    LOB_Registration__c lb = new LOB_Registration__c(LOB_Name__c = 'Server', State_Province_Region__c = 'India', City__c = 'Hyd', Registered_End_User__c= acc.Id);
    insert lb;
    Test.startTest();
    ApexPages.StandardController cont = new ApexPages.StandardController(lb);
    Apexpages.currentpage().getParameters().put('action','Reject');
    LOBRegistrationAvailableActionCntrlr lr = new LOBRegistrationAvailableActionCntrlr(cont);
    lr.redirect();
    Test.stopTest();
  }

}