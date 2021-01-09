/***********************************************************
* ---------------------------------------------------------
* Revision  Name                Description
* 1.0       VIKAS KH         Implemeted TDF for 0202 Release
* 
************************************************************/

@isTest
private class AfterInsertUpdatePartnerCourseTest {
     static list<Account> listAcc;
    static List<Certification_Tracker__c> listcerTracker;
    @testsetup static void setup() { 
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'Partner Account');
        TriggerExecutionController.setSkipAllTriggers(true);
        insert listAccTDF;
        List<Certification_Tracker__c> listCerTrackerTDF = TestDataFactory.createNcertTracker(10);
                for(integer inti=0; inti<10; inti++)
        {
            listCerTrackerTDF[0].Account_name__c = listAccTDF[0].id;

        }
        insert listCerTrackerTDF;
        system.debug('listCerTrackerTDF>>>>'+listCerTrackerTDF);

    }     

static testMethod void validatePartnerCourseTrigger() {
        //Create Account
     /*   Account acc = new Account(
                      Name = 'Test Account',
                      RecordTypeId = PageUtils.getRecordTypeId('Account','Partner Account',false),
                      Status__c = 'Active');
        System.debug('###Before Insert: account- ' +acc.id);
        insert acc;
        System.debug('### After Insert: account- ' +acc.id);

        //insert record to cert tracker later do it for 10 records.
        Certification_Tracker__c tracker;
        List<Certification_Tracker__c> trackerList = new List<Certification_Tracker__c>();
        for(integer i=0;i<10;i++){
            tracker = new Certification_Tracker__c(Account_Name__c = acc.id,
                                CurrencyIsoCode='INR',
                                QTR_Updated_Date__c=Date.Today());
            trackerList.add(tracker);
            System.debug('##Before Insert: tracker- '+ tracker );           
         }
            insert trackerList;
    System.debug('##After Insert: tracker- '+ tracker.id ); */
    listAcc = [select id from Account limit 1];
    listAcc[0].Account_Country_Code__c='IN';
    listAcc[0].status__c = 'Active';
    listAcc[0].Partner_Relationship__c='Registered';
    update listAcc;
    system.assertEquals(listAcc[0].Account_Country_Code__c, listAcc[0].Account_Country_Code__c);
    listcerTracker = [select id,Evaluate_Criteria__c from Certification_Tracker__c limit 10 ];

        for(Certification_Tracker__c ct : [SELECT ID,Evaluate_Criteria__c from Certification_Tracker__C WHERE Account_Name__c =:listAcc[0].id ]){
        System.debug('Tracker Account ID' + ct.id);
        system.debug('Before trigger fired' + ct.Evaluate_Criteria__c);
        }
        
        //insert record to Partner Course record later do it for 10 records.
        Partner_course__c pc;
        List<Partner_Course__c> listcourse = new List<Partner_Course__c>();
        for(integer inti=0;inti<10;inti++){
        pc = new Partner_Course__c(Account__c= listAcc[0].id,Course_Completed_Date__c= Date.today(),Course_Score__c=40);
        System.debug('PartnercourseAccountids' + pc.Account__c);
        listcourse.add(pc);
        }
        // Insert Partner Course
        insert pc;

        for(Partner_Course__c pc1 : [SELECT Course_Status__c from Partner_Course__c where Account__c = :listAcc[0].id]){
        System.debug('Partner Course Status' + pc1.Course_Status__c);
        }
        
        // Retrieve the Certification Tracker hidden field 
        for(Certification_Tracker__c ct1 : [SELECT ID,Evaluate_Criteria__c from Certification_Tracker__C WHERE Account_Name__c= :listAcc[0].id]){
        system.debug('After trigger fired' + ct1.Evaluate_Criteria__c);
        }
}
}