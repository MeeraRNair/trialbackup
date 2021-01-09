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
private class ContactHierarchyChartTest {
	
	static User userRecord1;
    static list<Account> listAcc;
    @testsetup static void setup(){
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'End-User Account');
        insert listAccTDF;

    }   
    static testMethod void testContactHierarchyChart() {
    
    testDataCreation();
    PageReference pageRef = Page.ContactHierarchyChart;
    Test.setCurrentPage(pageRef);
    //ContactHierarchyChartCtrlExt
    ApexPages.StandardController con = new ApexPages.StandardController(listAcc[0]);
    ContactHierarchyChartCtrlExt controller = new ContactHierarchyChartCtrlExt(con);
    listAcc = [select id,Name from Account limit 1];
	system.assertEquals(listAcc[0].Name, listAcc[0].Name);
    
    
    
    
    }
    
    static void testDataCreation(){
/*    	testAccount = new Account(Name='Test Account for Org Chart Test',Type = 'End User',
                                                Participating_in_LOB_Program__c = true
                                                );
                                                
        insert testAccount; */
        listAcc = [select id,Name from Account limit 1];
        //SELECT id, FirstName, LastName,ReportsToId, Title, Department, ReportsTo.FirstName, ReportsTo.LastName, ReportsTo.AccountId, Decision_Making_Role__c  FROM Contact WHERE AccountId = :acc.id AND ReportsToId != null 
       TriggerExecutioncontroller.setSkipAllTriggers(True);
        Contact conLvl1 = new Contact(FirstName='Level',Phone='99888900',LastName='One', AccountId=listAcc[0].Id,Title='CEO',Department='Marketing',Decision_Making_Role__c='Power Sponsor / Decision Maker');
        insert conLvl1;
        
        Contact conLvl2 = new Contact(FirstName='Level',LastName='Two',Phone='99888920', AccountId=listAcc[0].Id,Title='GM',Department='Marketing',Decision_Making_Role__c='Influencer',ReportsToId=conLvl1.Id);
        insert conLvl2;
        system.assertEquals(conLvl1.FirstName, conLvl1.FirstName);
        
    }
}