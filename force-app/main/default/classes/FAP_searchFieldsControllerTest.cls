@isTest
public class FAP_searchFieldsControllerTest {
    
  
    private static testMethod void executeSearchFieds()
    {
        FAP_SearchForm formfields=FAP_SearchForm.blank();
        formfields.countryCode='US';
      FAP_searchFieldsController controller  = new FAP_searchFieldsController();
      FAP_Country__mdt fapcountry = new FAP_Country__mdt(FAP_Region__c='Eastern Europe',Region__c='EC-EMEA',FAP_Country_Value__c='BULGARIA (BG)',Enable_for_FAP__c=True);
      //list<FAP_Country__mdt> countryList=[select FAP_Region__c,Region__c,FAP_Country_Value__c,Enable_for_FAP__c from FAP_Country__mdt where Enable_for_FAP__c = True and FAP_Country_Value__c!=null order by FAP_Country_Value__c ];
       
        list<FAP_Country__mdt> countryList = new list<FAP_Country__mdt>();
       transient List<String> countryStrList = new List<String>();
         for(FAP_Country__mdt mdt : countryList){
            countryStrList.add(String.valueof(mdt.FAP_Country_Value__c));
        }
         List<String> countryFullList = new List<String>();
         countryFullList.addAll(countryStrList);
         countryFullList.addAll(FAP_Configuration.getInstance().prioritizedCountries);
       
       PageReference pageRef = Page.FAP_PartnerSearch; 
      // countryList.add(fapcountry.FAP_Country_Value__c);
       Boolean isIE=controller.isIE;
       system.assertEquals(controller.isIE,isIE);
       Boolean isChrome=controller.isChrome;
       system.assertEquals(controller.isChrome,isChrome);
       Boolean isFirefox=controller.isFirefox;
       system.assertEquals(controller.isFirefox,isFirefox);
       controller.bDisplayCategory = true;
       Boolean bDisplayCategory =controller.bDisplayCategory;
       system.assertEquals(controller.bDisplayCategory,bDisplayCategory);
        FAP_SearchUtils.ipCountry = 'US';
        controller.country = 'US';
        controller.refreshRegion();
        controller.doFilter();
        controller.configFields=FAP_Configuration.getInstance();
        controller.setconfigFields(FAP_Configuration.getInstance());
       // controller.getfapbasicfields();
        //controller.getfapAdvancedFields();
        controller.bCSPPT = true;
        Boolean bCSPPT=controller.bCSPPT;
        system.assertEquals(controller.bCSPPT,bCSPPT);
        controller.strPT = 'Test';
        controller.thisRegion='Test';
        //controller.formFields='Test';
        String strPT=controller.strPT;
        system.assertEquals(controller.strPT,strPT);
      

        String sel= Apexpages.currentPage().getParameters().get('selectedPartner');
        //controller.getformFields();
        //controller.handlePartnerTypeChange();
        //controller.formFields= 'Test';
        controller.country = 'US';
       // controller.getCompCategory();
        controller.dummyFunction();
        // controller.refreshCountry();
       FAP_SearchForm form = FAP_SearchForm.deSerialize('c=us');
       // final FAP_SearchForm form = FAP_SearchForm.blank();
       form.region  = 'US';
        form.usrLanguage='en';
        form.countryCode='US';
        string str = form.toStr();
        system.debug('str'+form);
       // controller.formFields.countryCode='US';
       form.countryCode='US';
      //  controller.dCountry();
        //string region = form.region;
        //controller.formFields.region=form.region;
        system.assertEquals( controller.formFields,null);
        form.region='EMEA';
         FAP_SearchForm formfields1=FAP_SearchForm.blank();
        formfields1.countryCode='US';
        formFields1.region='EMEA';
        formFields1.strSubCompetency=Label.Converged_Hyper_Converged_Infrastructure_Services;
        controller.formFields=formFields1;
        controller.dCountry();
        controller.getRegions();
        controller.getCountries();
        List<FAP_SetOfThreeSearchFields> fapbasicfields=controller.getfapbasicfields();
        controller.setfapbasicfields(fapbasicfields);
        List<FAP_SetOfThreeSearchFields> adv=controller.getfapAdvancedFields();
        controller.setfapAdvancedFields(adv);

        
        controller.refreshCountry();
        form=controller.getformFields();
        controller.setformFields(form);
        controller.getconfigFields();
       // form.region='';
        List<SelectOption> countryList1 = new List<SelectOption>();
        controller.getAllCountries();
        FAP_Translation__c trans = new FAP_Translation__c();
        trans.Value__c='Communications';
        trans.Swedish__c='Kommunikation';
        insert trans;
        Map<String,String> translatedMap = new Map<String,String>();
        countryFullList.add('Communications');
       translatedMap = controller.translateStringList(countryFullList);
        //translatedMap.put()
        //FAP_SearchForm formFields = new FAP_SearchForm();
       // formFields.getFAPCustomization();
         //controller.refreshCountry();
         controller.getSubComptencyDetails();
         controller.getSubComptencyList();

     }
     private static testMethod void executeConstructor()
    {    
 
        FAP_searchFieldsController controller  = new FAP_searchFieldsController();
         FAP_Country__mdt fapcountry = new FAP_Country__mdt(FAP_Region__c='Eastern Europe',Region__c='EC-EMEA',Units__c='kilometers' ,FAP_Country_Value__c='BULGARIA (BG)',Enable_for_FAP__c=True);
         FAP_CountryUtils.PartnerCountryMap.get('US');
       
        controller.getconfigFields();
        controller.setconfigFields(FAP_Configuration.getInstance());
       String strPT=controller.strPT;
        system.assertEquals(controller.strPT,strPT);
         FAP_CountryUtils.partnerShippingCountryMap.get('US');
         FAP_CountryUtils.partnerLocationCountryMap.get('US');
       

           
     
        
    }
    
}