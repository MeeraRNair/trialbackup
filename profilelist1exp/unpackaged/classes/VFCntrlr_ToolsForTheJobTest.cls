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
private class VFCntrlr_ToolsForTheJobTest {
	    
	static testMethod void getHTMLCode_generateRows() {
        
        System.debug('***************** START getHTMLCode_generateRows *****************');
        
        string returnHTMLCode;
    	VFCntrlr_ToolsForTheJob controller = new VFCntrlr_ToolsForTheJob();    	
		List<Tools_For_The_Job__c> tfjList = new List<Tools_For_The_Job__c>();
		    			
		Schema.DescribeFieldResult fSection = Tools_For_The_Job__c.Section__c.getDescribe();
		List<Schema.Picklistentry> sectionValues = fSection.getPicklistValues();

		// Test for normal row		
		for (Schema.PicklistEntry sectionValue: sectionValues) {	
			Tools_For_The_Job__c tfj = new Tools_For_The_Job__c(name='link1' + sectionValue.getLabel(), 
																Section__c=sectionValue.getLabel(), 
																Sequence__c=1, 
																URL__c='http://www.google.com.my',
																Active__c = true);
			tfjList.add(tfj);
		} 
		insert tfjList;
		tfjList.clear();
		                 
        try {        	 
        	returnHTMLCode = controller.getHTMLCode();        	
        }
        catch (dellUtil.DellException e) {
        	System.debug(e.getMessage());
        }
                
        System.assert(returnHTMLCode.toLowerCase().contains('link1'));
        System.assert(returnHTMLCode.toLowerCase().contains('<h3 class="lbheader">'));
        System.assert(!returnHTMLCode.toLowerCase().contains('<li class="lbSubSection">'));
        
        // Test for sub section row
		for (Schema.PicklistEntry sectionValue: sectionValues) {						
			Tools_For_The_Job__c tfj = new Tools_For_The_Job__c(name='link1' + sectionValue.getLabel(), 
																Section__c=sectionValue.getLabel(), 
																Sub_Section__c=true, 
																Sequence__c=1, 
																URL__c='http://www.google.com.my',
																Active__c = true);
			tfjList.add(tfj);
		} 
		insert tfjList;
                       
        try {        	 
        	returnHTMLCode = controller.getHTMLCode();
        }
        catch (dellUtil.DellException e) {
        	System.debug(e.getMessage());
        }
                
        System.assert(returnHTMLCode.toLowerCase().contains('<li class="lbsubsection">'));
        
        System.debug('***************** END getHTMLCode_generateRows *****************');
    }   
}