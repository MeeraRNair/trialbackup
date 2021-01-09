@isTest
public class influenceBatcherTC{ 
 public static testmethod void runTest() {
        // New Inf parent
        Influence_Parent__c ip = new Influence_Parent__c( active__c = true, start_time__c = datetime.now().addMonths(-6), end_time__c = datetime.now(), maximum_concurrent_batches__c = 5, status__c = 'Ready' );
        insert ip;
        
        Apexpages.standardcontroller c = new apexpages.Standardcontroller( ip );
        
        influenceBatcher ib = new influenceBatcher( c );
        ib.isTest = true;
        
        Test.startTest();
        ib.doBatch();
        Test.stopTest();
    }
    
    public static testmethod void runTestES() {
        // New Inf parent
        Influence_Parent__c ip = new Influence_Parent__c( active__c = true, start_time__c = datetime.now().addMonths(-6), end_time__c = datetime.now(), maximum_concurrent_batches__c = 5, status__c = 'Ready', records_to_exclude__c = userinfo.getuserid() );
        insert ip;
        
        Apexpages.standardcontroller c = new apexpages.Standardcontroller( ip );
        
        influenceBatcher ib = new influenceBatcher( c );
        ib.isTest = true;
        ip.jobs_executed__c = ib.sObs.size() - 1;
        
        update ip;
        
        Test.startTest();
        ib.doBatch();
        Test.stopTest();
    }
    
    public static testmethod void runTest2() {      
        // New Inf parent
        Influence_Parent__c ip = new Influence_Parent__c( active__c = true, start_time__c = datetime.now().addMonths(-6), end_time__c = datetime.now(), maximum_concurrent_batches__c = 5, status__c = 'Ready' );
        ip.status__c = 'Sorting Data';
        
        insert ip;
        
        Apexpages.standardcontroller c = new apexpages.Standardcontroller( ip );
        influenceBatcher ib = new influenceBatcher( c );
        ib.isTest = true;
        
        ip.jobs_executed__c = ib.sObs.size();
        update ip;
        
        Test.startTest();
        ib.doBatch();
        Test.stopTest();
    }
    
    public static testmethod void runTest3() {
        // New Inf parent
        Influence_Parent__c ip = new Influence_Parent__c( active__c = true, start_time__c = datetime.now().addMonths(-6), end_time__c = datetime.now(), maximum_concurrent_batches__c = 5, status__c = 'Ready' );

        ip.status__c = 'Finalizing Influence';
        
        insert ip;
        
        Apexpages.standardcontroller c = new apexpages.Standardcontroller( ip );
        influenceBatcher ib = new influenceBatcher( c );
        ib.isTest = true;
        
        ip.jobs_executed__c = ib.sObs.size() + ib.sortRanks.size();
        update ip;
        
        Test.startTest();
        ib.doBatch();
        Test.stopTest();
    }
}