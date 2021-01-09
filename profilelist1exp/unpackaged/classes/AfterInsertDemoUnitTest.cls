@isTest
private class AfterInsertDemoUnitTest {
    static list<Account> listAcc;
    static list<Certification_Tracker__c> listCTraffic;
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTdf=TestDataFactory.createNAccount(2,'Partner Account');
        insert listAccTdf;
        list<Certification_Tracker__c> listCtrafficTdf=TestDataFactory.createNcertTracker(2);
        insert listCtrafficTdf;
    }
    static testMethod void validateDemounitTrigger() {
        listAcc = [Select Id from Account limit 1];
        listAcc[0].Status__c = 'Active';
        update listAcc;
        system.assertNotEquals(listAcc[0].id, null);
        listCTraffic = [Select Id from Certification_Tracker__c limit 1];
        listCTraffic[0].Account_Name__c = listAcc[0].id;
        listCTraffic[0].QTR_Updated_Date__c=Date.Today();
        update listCTraffic;
        /*Account acc = new Account(
Name = 'Test Account',
RecordTypeId = PageUtils.getRecordTypeId('Account','Partner Account',false),
Status__c = 'Active');
System.debug('###Before Insert: account- ' +acc.id);
insert acc;
System.debug('### After Insert: account- ' +acc.id);*/
        
        //insert record to cert tracker later do it for 10 records.
        /*Certification_Tracker__c tracker;
List<Certification_Tracker__c> trackerList = new List<Certification_Tracker__c>();
for(integer i=0;i<10;i++){
tracker = new Certification_Tracker__c(Account_Name__c = listAcc[0].id,
CurrencyIsoCode='INR',
QTR_Updated_Date__c=Date.Today());
trackerList.add(tracker);
System.debug('##Before Insert: tracker- '+ tracker );           
}
insert trackerList;
System.debug('##After Insert: tracker- '+ tracker.id ); 

for(Certification_Tracker__c ct : [SELECT ID,Evaluate_Criteria__c from Certification_Tracker__C WHERE Account_Name__c =:acc.id ]){
System.debug('Tracker Account ID' + ct.id);
system.debug('Before trigger fired' + ct.Evaluate_Criteria__c);
}*/
        
        //insert record to Demo Unit later do it for 10 records.
        Demo_Unit__c demo;
        List<Demo_Unit__c> listdemo = new List<Demo_Unit__c>();
        for(integer inti=0;inti<10;inti++){
            demo = new Demo_Unit__c(Partner_Account_Name__c=listAcc[0].id, Demo_Unit_Type__c='Compellent Demo',Order_Number__c='1',TSR_Name__c='abcd',
                                    Order_Date__c= Date.today(),Contact_Name__c='Sudha',T_C__c='Yes',Contact_Email__c='du@gmail.com');
            System.debug('DemounitAccountids' + demo.Partner_Account_Name__c);
            listdemo.add(demo);
        }
        // Insert Demo Unit
        insert demo;
        
        // Retrieve the Certification Tracker hidden field 
        for(Certification_Tracker__c ct1 : [SELECT ID,Evaluate_Criteria__c from Certification_Tracker__C WHERE Account_Name__c= :listAcc[0].id]){
            system.debug('After trigger fired' + ct1.Evaluate_Criteria__c);
        }
    }
}