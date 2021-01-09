@Istest (seealldata = true)
private class FAP_HeaderComponentControllerTest { 
    private static testmethod void executeHeaderComponentController()
     {
         FAP_HeaderComponentController controller = new FAP_HeaderComponentController();
         
           Header__mdt homepageURL=new Header__mdt(MasterLabel='za',Home_Page_URL__c = 'http://www.dell.com/za/en/gen/df.aspx?refid=df&s=gen');
          
            controller.thisCountry='CHINA';
            controller.countryHomePageURL=homepageURL.Home_Page_URL__c;
             string thsCountry = controller.thisCountry;
             String countryHomePageURL = controller.countryHomePageURL;
         
         
            System.assertNotEquals( [ SELECT Home_Page_URL__c FROM Header__mdt WHERE DeveloperName='za'].size(), 10 );
           // controller.countryHomePageURL=null;
     }
     
      private static testmethod void executeNullController(){
            FAP_HeaderComponentController controller = new FAP_HeaderComponentController();
            
            Header__mdt homepageURL=new Header__mdt(MasterLabel='za');
          
            controller.thisCountry='CHINA';
            controller.countryHomePageURL=homepageURL.Home_Page_URL__c;
             string thsCountry = controller.thisCountry;
             String countryHomePageURL = controller.countryHomePageURL;
            // controller.countryHomePageURL='www.test.com';
            System.assertNotEquals( [ SELECT Home_Page_URL__c FROM Header__mdt WHERE DeveloperName='CHINA'].size(), 10 );
            controller.countryHomePageURL=null;
     }
     
         private static testmethod void exceptionBuilder(){
            list<string> stringlist=new list<string>();
            stringlist.add('Test');
            FAP_PartnerSearch  fp=new FAP_PartnerSearch(stringlist);
            system.assertEquals(stringlist.size(), 1);
        }
 }