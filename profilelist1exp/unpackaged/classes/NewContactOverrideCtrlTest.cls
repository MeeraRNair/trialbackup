@isTest
private class NewContactOverrideCtrlTest{

    static testmethod void TestNewContactOverrideCtrl() {
    
        NewContactOverrideCtrl controller = new NewContactOverrideCtrl(new ApexPages.StandardController(new Contact()));
        PageReference newPage = controller.createNewContact();
        
        System.assert(newPage.getURL().contains('/003'));
        System.assert(newPage.getParameters().get('CF00NA00000064sQh') == UserInfo.getName());
        
        //controller.redirectBack();
        controller.getHasMessage();
        
        String url = controller.getNewContact();
        
        System.assert(url.contains('/003'));
        System.assert(url.contains('CF00NA00000064sQh'));
        
    }
    
}