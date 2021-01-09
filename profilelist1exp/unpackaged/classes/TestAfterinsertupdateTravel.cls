/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestAfterinsertupdateTravel {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Account newaccount= new Account(Name= 'Test Account');
        insert newaccount;    
        Contact con= new Contact(FirstName='ContactExcSafeWord1', LastName='ContactExcSafeWord1', AccountId=newaccount.Id,Phone='11111', Decision_Making_Role__c='Influencer', Job_Function__c='IT',Purchaser_Influence_over_Merged__c='Client-Desktops' );
        insert con;
        User testUser=[SELECT id FROM USER WHERE Isactive=true limit 1];
        Id rtSite=IdLookupUtils.getRecordTypeId('Sites','Event_Location__c',true);
        Event_Location__c testSite=new Event_Location__c(Name='testSite',Region__c='Americas',
                                                   Active__c=true,Engagement_Type__c='DSC',
                                                   Offer_Catering__c='No',Offer_Transportation__c='Yes',
                                                   Email__c='test_user@dell.com',
                                                   recordTypeid=rtSite);
        insert testSite;
        Customer_Engagement__c testCE1 = new Customer_Engagement__c(Name = 'Mytest CE1',Event_Type__c='Solution Briefings',Event_Status__c = 'Canceled',Cost_Center__c='1234-1234-123456',Dell_Solution_Center_Site__c=testSite.Id,Trade_Compliant__c='Yes' ,Requestor_Name__c = testUser.Id, GSL_Start_Date__c=system.Today(),GSL_End_Date__c = system.Today(),Estimated_no_of_Customer_Attendees__c = 11,Primary_Account__c=newaccount.Id,Primary_Contact__c=con.Id,NDA__c='Yes');
        insert testCE1;
        
        Transportation__c newtrans= new Transportation__c(Name='New Transportation', Travel_Type__c='Flight arrival',Start_Date__c= system.Today(), Customer_Engagement__c=testCE1.Id);
        Transportation__c newtranspt= new Transportation__c(Name='Trans for update', Travel_Type__c='Flight arrival',Start_Date__c= system.Today(), Customer_Engagement__c=testCE1.Id);
        insert newtranspt;
        newtranspt.Starting_Time__c='12.00AM';
        newtranspt.Ending_Time__c='12.30AM';
        
        Transportation__c transwithST= new Transportation__c(Name='Transportation test', Travel_Type__c='Flight arrival',Start_Date__c= system.Today(),Starting_Time__c='01.00AM', Ending_Time__c='03.00AM', Customer_Engagement__c=testCE1.Id);
        Transportation__c updtranswithST= new Transportation__c(Name='New Transportations',Travel_Type__c='Flight arrival', Starting_Time__c='01.00AM', Start_Date__c= system.Today(),Ending_Time__c='03.00AM');
        insert updtranswithST;
        Transportation__c trans= new Transportation__c(Name='New Transportatn', Travel_Type__c='Flight arrival',Starting_Time__c='01.00AM', Ending_Time__c='03.00AM', Customer_Engagement__c=testCE1.Id);
        Transportation__c updTrans= new Transportation__c(Name='Update Transportation',Travel_Type__c='Flight arrival',Start_Date__c= system.Today(), Starting_Time__c='03.00AM', Ending_Time__c='04.00AM', Customer_Engagement__c=testCE1.Id);
        insert updTrans;
        insert trans;

        Transportation__c delTrans= new Transportation__c(Name='Delete Transportation', Travel_Type__c='Flight arrival',Starting_Time__c='01.00PM', Start_Date__c= system.Today(),Ending_Time__c='03.00PM', Customer_Engagement__c=testCE1.Id);
        insert delTrans;
        Transportation__c transExcemt= new Transportation__c(Name='ex Transportation', Travel_Type__c='Flight arrival',Starting_Time__c='01.30PM', Start_Date__c= system.Today(),Ending_Time__c='03.00PM', Customer_Engagement__c=testCE1.Id);
        insert transExcemt;
        updtranswithST.Starting_Time__c='03.30AM';
        updtranswithST.Ending_Time__c='04.30AM';
        
        transExcemt.Starting_Time__c = 'abcd';
        
        Test.startTest();
        insert newTrans;
        update newtranspt;
        insert transwithST;
        update updtranswithST;      
        update transExcemt;
        delete delTrans;
        Test.stopTest();
        
        List<Transportation__c> transObjstest = [Select Id From Transportation__c where Name = 'New Transportation' and  Customer_Engagement__c =:testCE1.Id];
        system.assertequals(transObjstest.size(),1);
        List<Agenda__c> insagendaList=[select id, Travel_Id__c from Agenda__c where Travel_Id__c = :newTrans.Id ];
        system.assertequals(insagendaList.size(),0);
                
        List<Transportation__c> transObjtest = [Select Id,Starting_Time__c,Ending_Time__c From Transportation__c where Name = 'Trans for update' and  Customer_Engagement__c =:testCE1.Id];
        system.assertequals(transObjtest.size(),1);
        for(Transportation__c tr :transObjtest){
            system.assertequals(tr.Starting_Time__c,'12.00AM');
            system.assertequals(tr.Ending_Time__c,'12.30AM');
        }
        List<Agenda__c> updagendaList=[select id, Travel_Id__c, Start_Time__c,End_Time__c from Agenda__c where Travel_Id__c = :newtranspt.Id ];
        system.assertequals(updagendaList.size(),1);
        for(Agenda__c ag : updagendaList){
            system.assertequals(ag.Start_Time__c,'12.00AM');
            system.assertequals(ag.End_Time__c,'12.30AM');
        }
        
        List<Transportation__c> insTransObjstests = [Select Id From Transportation__c where Name = 'Transportation test' and  Customer_Engagement__c =:testCE1.Id];
        system.assertequals(insTransObjstests.size(),1);
        List<Agenda__c> insagendaListWithST=[select id, Travel_Id__c from Agenda__c where Travel_Id__c = :transwithST.Id ];
        system.assertequals(insagendaListWithST.size(),1);
        
        List<Transportation__c> updTransObjtest = [Select Id,Starting_Time__c,Ending_Time__c From Transportation__c where Name = 'New Transportations' and  Customer_Engagement__c =:testCE1.Id];
        system.assertequals(updTransObjtest.size(),0);
            
        List<Agenda__c> updAgendaListWithST=[select id, Travel_Id__c,Start_Time__c,End_Time__c from Agenda__c where Travel_Id__c = :updtranswithST.Id ];
        system.assertequals(updAgendaListWithST.size(),0);
        
        
        List<Transportation__c> delTransObjstest = [Select Id From Transportation__c where Name = 'Delete Transportation' and  Customer_Engagement__c =:testCE1.Id];
        system.assertequals(delTransObjstest.size(),0);
        List<Agenda__c> delAgendaList=[select id, Travel_Id__c from Agenda__c where Travel_Id__c = :delTrans.Id ];
        system.assertequals(delAgendaList.size(),0);
    }
}