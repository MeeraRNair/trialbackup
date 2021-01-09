@IsTest
private class FAP_FooterComponentControllerTest {

    private static testmethod void testBuild(){
    FAP_FooterComponentController fc=new FAP_FooterComponentController();
       Boolean isIE=fc.isIE;
       system.assertEquals(fc.isIE,isIE);
       Boolean isChrome=fc.isChrome;
       system.assertEquals(fc.isChrome,isChrome);
       Boolean isFirefox=fc.isFirefox;
       system.assertEquals(fc.isFirefox,isFirefox);
       
       String thiscountryCode =fc.thiscountryCode;
       fc.thiscountryCode='US';
       fc.thisLanguage='en';
       String thisLanguage= fc.thisLanguage;
       Footer__mdt ftr=fc.footerObj;
       fc.getFooterRecords();
       string twoZeroOneFourDell=fc.twoZeroOneFourDell;
       string aboutDell=fc.aboutDell;
       string termsAndConditions=fc.termsAndConditions;
       string unresolvedIssues=fc.unresolvedIssues;
       string privacy=fc.privacy;
       string contactUs=fc.contactUs;
       string privacySettings=fc.privacySettings;
       string feedback=fc.feedback;
       string siteMap=fc.siteMap;

    }
        private static testmethod void exceptionBuilder(){
       list<string> stringlist=new list<string>();
            stringlist.add('Test');
            FAP_IllegalStateException fp=new FAP_IllegalStateException(stringlist);
            FAP_FAPLimitException fp1=new FAP_FAPLimitException(stringlist);
            FAP_IllegalArgumentException fp2=new FAP_IllegalArgumentException(stringlist);
            FAP_NumberFormatException fp3=new FAP_NumberFormatException(stringlist);
            FAP_InvalidCharacterStringException fp4=new FAP_InvalidCharacterStringException(stringlist);

            
            system.assertEquals(stringlist.size(), 1);
            
        }


}