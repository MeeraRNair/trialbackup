/* ============================================================
 * Find a Partner Utility Test Class
 * ============================================================
 */
@IsTest
private class FAP_LanguageUtilsTest {

    private static testmethod void testGetLangCodeByHttpParam(){
        System.assertNotEquals('es', FAP_LanguageUtils.getLangCodeByHttpParam());  
        FAP_PageUtils.param('l','XXXXXXXX');
        System.assertNotEquals('es', FAP_LanguageUtils.getLangCodeByHttpParam());  
        FAP_PageUtils.param('l','es');
        System.assertEquals('es', FAP_LanguageUtils.getLangCodeByHttpParam()); 
        FAP_PageUtils.param('l','nl');
        System.assertEquals('nl-nl', FAP_LanguageUtils.getLangCodeByHttpParam()); 
    }
    
    private static testmethod void testGetLangCodeByBrowser(){
        System.assertNotEquals('es', FAP_LanguageUtils.getLangCodeByBrowser());  
        ApexPages.currentPage().getHeaders().put('Accept-Language','XXXXXXXX');
        System.assertNotEquals('es', FAP_LanguageUtils.getLangCodeByBrowser());  
        ApexPages.currentPage().getHeaders().put('Accept-Language','es');
        System.assertEquals('es', FAP_LanguageUtils.getLangCodeByBrowser());
        ApexPages.currentPage().getHeaders().put('Accept-Language','nl');
        System.assertEquals('nl-nl', FAP_LanguageUtils.getLangCodeByBrowser());
        ApexPages.currentPage().getHeaders().put('Accept-Language','es-mx');
        System.assertEquals('es', FAP_LanguageUtils.getLangCodeByBrowser());
        ApexPages.currentPage().getHeaders().put('Accept-Language','en-us,zh-cn;q=0.5');
        System.assertEquals('en-us', FAP_LanguageUtils.getLangCodeByBrowser());
        ApexPages.currentPage().getHeaders().put('Accept-Language','xxxxx,zh-cn;q=0.5');
        System.assertEquals('zh-cn', FAP_LanguageUtils.getLangCodeByBrowser());
        ApexPages.currentPage().getHeaders().put('Accept-Language','zh');
        System.assertEquals('zh-cn', FAP_LanguageUtils.getLangCodeByBrowser());
    }
    
    private static testmethod void testGetLangCodeByUser(){
        System.assertEquals(UserInfo.getLanguage(), FAP_LanguageUtils.getLangCodeByUser());  
    }


    private static testmethod void testGetLangCodeByHttpParamOrIfNullThenBrowser(){
        System.assertNotEquals('es', FAP_LanguageUtils.getLangCodeByHttpParamOrIfNullThenBrowser());  
        ApexPages.currentPage().getHeaders().put('Accept-Language','zh');
        System.assertEquals('zh-cn', FAP_LanguageUtils.getLangCodeByHttpParamOrIfNullThenBrowser());  
        FAP_PageUtils.param('l','es');
        System.assertEquals('es', FAP_LanguageUtils.getLangCodeByHttpParamOrIfNullThenBrowser());  
    }

    private static testmethod void testGetLangCodeByHttpParamOrIfNullThenUser(){
        System.assertEquals(UserInfo.getLanguage(), FAP_LanguageUtils.getLangCodeByHttpParamOrIfNullThenUser());  
        FAP_PageUtils.param('l','es');
        System.assertEquals('es', FAP_LanguageUtils.getLangCodeByHttpParamOrIfNullThenUser());  
    }

    private static testmethod void testGetLangCodeByBrowserOrIfNullThenHttpParam(){
        System.assertNotEquals('es', FAP_LanguageUtils.getLangCodeByBrowserOrIfNullThenHttpParam());  
        FAP_PageUtils.param('l','es');
        System.assertEquals('es', FAP_LanguageUtils.getLangCodeByBrowserOrIfNullThenHttpParam());  
        ApexPages.currentPage().getHeaders().put('Accept-Language','zh-cn');
        System.assertEquals('zh-cn', FAP_LanguageUtils.getLangCodeByBrowserOrIfNullThenHttpParam());  
    }

    private static testmethod void testGetLangCodeByBrowserOrIfNullThenUser(){
        System.assertNotEquals('es', FAP_LanguageUtils.getLangCodeByBrowserOrIfNullThenUser());  
        System.assertEquals(UserInfo.getLanguage(), FAP_LanguageUtils.getLangCodeByBrowserOrIfNullThenUser());  
        ApexPages.currentPage().getHeaders().put('Accept-Language','zh');
        System.assertEquals('zh-cn', FAP_LanguageUtils.getLangCodeByBrowserOrIfNullThenUser());  
    }
    
    private static testmethod void testGetLanguageName(){
        //basic tests          
        System.assertEquals('Francouzština', FAP_LanguageUtils.getLanguageName('cs','fr'));  
        System.assertEquals('Spanyol', FAP_LanguageUtils.getLanguageName('in','es'));  
        System.assertEquals('French', FAP_LanguageUtils.getLanguageName('en_US','fr'));
        System.assertEquals('Tsjechisch', FAP_LanguageUtils.getLanguageName('nl_nl','cs'));  

        //test conversion to lower-case
        System.assertEquals('Francouzština', FAP_LanguageUtils.getLanguageName('CS','FR'));

        //test default to english
        System.assertEquals('French', FAP_LanguageUtils.getLanguageName('xx','fr'));

        //test default substitution; ie nl => nl_nl
        System.assertEquals('Tsjechisch', FAP_LanguageUtils.getLanguageName('nl','cs'));  
    }
    
    private static testmethod void testGetAllLanguageSelectOptions(){
      final List<SelectOption> languages = FAP_LanguageUtils.getAllLanguageSelectOptions();
      System.assertNotEquals(null,languages);
      System.assertNotEquals(null,languages.get(0));
      System.assertEquals('Chinese (Simplified)',languages.get(0).getLabel());
      System.assertNotEquals(null,languages.get(1));
      System.assertEquals('Chinese (Traditional)',languages.get(1).getLabel());
      System.assertNotEquals(null,languages.get(2));
      System.assertEquals('Czech',languages.get(2).getLabel());
    }
    
    private static testmethod void testGetAllLanguageSelectOptions2(){
      final List<SelectOption> languages = FAP_LanguageUtils.getAllLanguageSelectOptions('ru');
      System.assertNotEquals(null,languages);
      System.assertNotEquals(null,languages.get(0));
      System.assertEquals('Английский (США)',languages.get(0).getLabel());
      System.assertNotEquals(null,languages.get(1));
      System.assertEquals('Венгерский',languages.get(1).getLabel());
      System.assertNotEquals(null,languages.get(2));
      System.assertEquals('Голландский',languages.get(2).getLabel());
    }
    
    private static testmethod void testgetAllLanguages(){
      final Map<String,String> languages = FAP_LanguageUtils.getAllLanguages();
      System.assertNotEquals(null,languages);
      System.assertNotEquals(0,languages.size());
      System.assertEquals('French', languages.get('fr'));
      System.assertEquals('Italian', languages.get('it'));
  }      
    
    private static testmethod void testgetAllLanguages2(){
      final Map<String,String> languages = FAP_LanguageUtils.getAllLanguages('ru');
      System.assertNotEquals(null,languages);
      System.assertNotEquals(0,languages.size());
      System.assertEquals('Французский', languages.get('fr'));
      System.assertEquals('Итальянский', languages.get('it'));
  }      
    
}