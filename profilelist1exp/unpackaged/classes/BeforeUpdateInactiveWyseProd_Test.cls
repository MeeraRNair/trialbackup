/********** Test class for BeforeUpdateInactiveWyseProd ************/

@isTest
class BeforeUpdateInactiveWyseProd_Test {
    static testMethod void BeforeUpdateInactiveWyseProd_Test(){
 
    Profile ProfileName = [SELECT Id, Name FROM Profile WHERE name ='IT Integration API only'];
    
    Account ac = new Account();
    ac.name = 'TestAcc';
    insert ac;
     User u = new User(Alias = 'standt', Email='standarduser@dell.com', 
      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
      LocaleSidKey='en_US', ProfileId = ProfileName.Id, 
      TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@dell.com');
     INSERT u;  
     system.runas(u){
    Opportunity op = new Opportunity();
    op.name = 'TestOpp';
    op.stagename = 'Plan - 1%';
    op.closedate = System.today();
    op.AccountId = ac.id;
    op.CurrencyIsoCode = 'EUR';
    op.Domain__c = 'EUC';
    op.Solution_Type__c = 'Mobility Solutions';
    op.Solution_Name__c = 'Tablet Solutions';
    op.Type = 'Run Rate';
    //op.CreatedByID=u.id;
      insert op;

    //update op;    
    try{
        update op;
    }catch(Exception e){}
           }
}
}