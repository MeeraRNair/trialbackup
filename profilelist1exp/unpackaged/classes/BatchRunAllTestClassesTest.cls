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
private class BatchRunAllTestClassesTest {

    static testMethod void testNoTestClass() {
    	string className = string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0));
		BatchRunAllTestClasses batch = new BatchRunAllTestClasses();
		batch.queryString = 'SELECT Id FROM ApexClass WHERE Name = \'' + className + '\'';
		//batch.queryString = 'SELECT Id FROM ApexClass WHERE Name != \'BatchRunAllTestClasses\' AND Name != \'BatchRunAllTestClassesTest\' AND Name != \'BatchRunAllTestClassesExecute\' LIMIT 5';
		batch.isTest = true;
		Test.startTest();
		Database.executeBatch(batch);
		Test.stopTest();
    }
    
    static testMethod void testHasQueueItems(){
    	string className = string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0));
    	List<ApexClass> classes = new List<ApexClass>();
    	ApexClass clsA = new ApexClass(Name = className+'A');
    	ApexClass clsB = new ApexClass(Name = className+'B');
    	ApexClass clsC = new ApexClass(Name = className+'C');
    	classes.add(clsA);
    	classes.add(clsB);
    	classes.add(clsC);
    	
		BatchRunAllTestClasses batch = new BatchRunAllTestClasses();
		batch.queryString = 'SELECT Id FROM ApexClass WHERE Name != \'BatchRunAllTestClasses\' AND Name != \'BatchRunAllTestClassesTest\' AND Name != \'BatchRunAllTestClassesExecute\' LIMIT 5';
		batch.isTest = true;
		List<ApexTestQueueItem> queueItems = new List<ApexTestQueueItem>();
		for (ApexClass cls : classes) {
			queueItems.add(new ApexTestQueueItem(ApexClassId = cls.Id));
		}
		batch.items = queueItems;
		Test.startTest();
		Database.executeBatch(batch);
		Test.stopTest();
    }
    
    static testMethod void testNoQueueItems(){
		BatchRunAllTestClasses batch = new BatchRunAllTestClasses();
		batch.queryString = 'SELECT Id FROM ApexClass WHERE Name != \'BatchRunAllTestClasses\' AND Name != \'BatchRunAllTestClassesTest\' AND Name != \'BatchRunAllTestClassesExecute\' LIMIT 5';
		batch.isTest = true;
		Test.startTest();
		Database.executeBatch(batch);
		Test.stopTest();
    }
    
    static testMethod void testExceptionAtExecute(){
		BatchRunAllTestClasses batch = new BatchRunAllTestClasses();
		batch.queryString = 'SELECT Id FROM ApexClass WHERE Name != \'BatchRunAllTestClasses\' AND Name != \'BatchRunAllTestClassesTest\' AND Name != \'BatchRunAllTestClassesExecute\' LIMIT 5';
		batch.isTest = false;
		Test.startTest();
		Database.executeBatch(batch);
		Test.stopTest();
    }
}