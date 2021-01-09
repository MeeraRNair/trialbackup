@isTest
public class Batch_AutoCloseOpportunitiesTest{
    static String apexId;
    static testMethod void Batch_AutoCloseOpportunitiesTest(){
    
    List<Opportunity> oppList = new List<Opportunity>();
    
        for( Integer i=0; i<200; i++ ) {
    
        //inserting the opportunity
        Opportunity testOpp = new Opportunity();            
            testOpp.Name = 'test opportunity';
            testOpp.StageName = 'Lost, Cancelled - 0%';
            testOpp.Description = 'Automatically closed out because Book Date is past due over 6 months.';
            testOpp.Won_Lost_Comment__c = 'Automatically closed out because Book Date is past due over 6 months.';
            testOpp.Past_Due_Auto_Closed__c = True;
            testOpp.Competitor_Lost_To__c = 'Unknown';
            testOpp.Reason_Won_Lost__c = 'Past Due Auto Closed';
            testOpp.CloseDate = date.today()+30;
            oppList.add(testOpp);
        }   
            insert oppList;
            
            System.assert(oppList!=null);
            
            Opportunity testOpp1 = new Opportunity();
            testOpp1.StageName = 'Lost, Cancelled - 0%';
            testOpp1.Description = 'Automatically closed out because Book Date is past due over 6 months.';
            testOpp1.Won_Lost_Comment__c = 'Automatically closed out because Book Date is past due over 6 months.';
            testOpp1.Past_Due_Auto_Closed__c = True;            
            testOpp1.Reason_Won_Lost__c = 'Past Due Auto Closed';
            testOpp1.CloseDate = date.today()+30;
            testOpp1.Name = 'test opportunity1';
            System.assert(testOpp1.Competitor_Lost_To__c == null);
            testOpp1.Competitor_Lost_To__c = 'Unknown';

            insert testopp1;
            
            
                    
        Test.startTest();
            Batch_AutoCloseOpportunities batchAutoCloseopp= new Batch_AutoCloseOpportunities();
            apexId = database.executebatch(batchAutoCloseopp);
        
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, CompletedDate, JobType, TotalJobItems, JobItemsProcessed, CreatedBy.Email, ExtendedStatus, MethodName 
                            FROM AsyncApexJob  
                            WHERE Id = :apexId];
        system.assertEquals('Queued',a.Status); 
        Test.stopTest();
            
    }
    
}