@isTest
private class StrategyNewOverrideController_Test {

    public static testmethod void TestController() {
    
        StrategyNewOverrideController controller = new StrategyNewOverrideController(new ApexPages.StandardController(new SFDC_Strategy__c()));
        PageReference newPage = controller.createNewStrategy();
        
        System.assert(newPage.getURL().contains('/a0G'));
        System.assert(newPage.getParameters().get('CF00NA00000063VJ1') == UserInfo.getName());
        
        //controller.redirectBack();
        controller.getHasMessage();
  
    }

}