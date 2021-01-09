@IsTest
private class FAP_TestPartnerFinderBaseController {
  
  private class ConcretePartnerFinderBaseController extends FAP_PartnerFinderBaseController{}
  
    private static testmethod void testOption1HttpParameter(){
      FAP_PartnerFinderBaseController controller = new ConcretePartnerFinderBaseController();
        System.assertNotEquals('es', controller.getPreferredLanguageCode());  
        ApexPages.currentPage().getParameters().put('l','XXXXXXXX');
        System.assertNotEquals('es', controller.getPreferredLanguageCode());  
        ApexPages.currentPage().getParameters().put('l','es');
        System.assertEquals('es', controller.getPreferredLanguageCode()); 
    }

}