/**
 * This class contains unit tests for validating the behavior of RedirectRouteToChannelExtension Apex classe
 * .
 *
 CR 15422 - Created on 6-Feb-2017 - Ashutosh (Neo)
 
 */
@isTest(seeAllData=true)
private class RedirectRouteToChannelExtensionTest {

    static testMethod void doRedirectTest() {
    	/*This method was intended to test the method behind the Route Channel Button On Lead where on clicking of button triggers the
    	page redirect */
        Lead testLead = [Select Id from Lead LIMIT 1];
        if(testLead != null){
        	ApexPages.StandardController sc = new ApexPages.StandardController(testLead);
    	 	RedirectRouteToChannelExtension testData = new RedirectRouteToChannelExtension(sc);
        	testData.doRedirect();
        }
    }
}