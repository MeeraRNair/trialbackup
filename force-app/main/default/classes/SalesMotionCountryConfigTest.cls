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
private class SalesMotionCountryConfigTest {  

    static testMethod void test_initializeController() {  
        
        VFCntrlr_SalesMotionCountryConfig controller;  
        
        Sales_Motion__c salesMotion = new Sales_Motion__c(Name='TestSM',Domain__c='Test Domain',Solution_Type__c='Test Solution Type',Solution_Name__c='Test Solution Name',SalesEdge_Category__c='Test category');
        //Sales_Motion__c salesMotion = new Sales_Motion__c(Name='TestSM',Domain__c='IDM',Solution_Type__c='Data Management Solutions',Solution_Name__c='Big Data Retention',SalesEdge_Category__c='AD-VSK_EntMobSol');
        
        insert salesMotion;
        
        Sales_Motion_Page__c salesMotionPage = new Sales_Motion_Page__c(Name='Marketing/Sales Toolkit',Sales_Motion_Name__c = salesMotion.Id);
        insert salesMotionPage;
        
        Sales_Motion_Page_Section__c section = new Sales_Motion_Page_Section__c(Name='Test Section',SalesEdge_Category__c='AD-Assets',Sales_Motion_Page__c= salesMotionPage.Id,Stage__c='Discover - 10%',Country_List__c='Japan;India',
        Region_List__c='EMEA;APJ',Business_Unit_List__c='SMALL MEDIUM BUSINESS;',Language_List__c='English-US;CHINESE');
        insert section;
        
        System.debug('DEBUG: Section ID = ' + section.Id);
         
        PageReference pr = Page.SalesMotionCountryConfig;
         
        Test.setCurrentPage(pr); 
          
        System.debug('DEBUG: Current Page URL: ' + ApexPages.currentPage().getUrl());  
       // System.assert(ApexPages.currentPage().getUrl().toLowerCase().contains('/apex/SalesMotionCountryConfig'));
         
        //Testing initialization without passing in 'id' parameter
        System.debug('DEBUG: TESTING INITIALIZATION WITHOUT ID PARAMETER.');  
        
        try 
        {
            controller = new VFCntrlr_SalesMotionCountryConfig(new ApexPages.StandardController(section) );    
        } 
        catch(Exception e)
        {           
            //Should throw an error 
            System.assert(e.getMessage().contains('There was a problem retrieving Page Section.'));
        }
        
        //Testing initialization with a invalid 'id' parameter
        System.debug('DEBUG: TESTING INITIALIZATION WITH INVALID ID PARAMETER.');

        ApexPages.currentPage().getParameters().put('id', '0000000'); 
        
        try
        {
            controller = new VFCntrlr_SalesMotionCountryConfig(new ApexPages.StandardController(section) );
        }
        catch(Exception e)
        {
            //Should throw an error 
            System.assert(e.getMessage().contains('Invalid id'));
        }
        
         System.debug('DEBUG: TESTING INITIALIZATION WITH ID PARAMETER.');

        ApexPages.currentPage().getParameters().put('id', section.Id); 
        //ApexPages.currentPage().getParameters().put('format', 'pdf'); 
        
        controller = new VFCntrlr_SalesMotionCountryConfig(new ApexPages.StandardController(section) );
        system.debug('###############    ' + controller.getSalesMotionSectionId());
        controller.getallAvailableCountries();
        controller.addCountries();
        controller.loadCountryDetails();
        controller.getAvailableCountries();
        controller.getCountriesToRemove();
        controller.getSmCountriesToAdd();
        controller.getSelectedCountries();
        controller.addAllCountries();
        controller.removeCountries();
        controller.saveCountries();
        //For Region
        controller.getallAvailableRegions();
        controller.addRegions();
        controller.loadRegionDetails();
        controller.getAvailableRegions();
        controller.getRegionsToRemove();
        controller.getSmRegionsToAdd();
        controller.getSelectedRegions();
        controller.addAllRegions();
        controller.removeRegions();
        controller.saveRegions();
        //For Business Units        
        controller.getallAvailableBusinessUnits();
        controller.addBusinessUnits();
        controller.loadBusinessUnitDetails();
        controller.getAvailableBusinessUnits();
        controller.getBusinessUnitsToRemove();
        controller.getSmBusinessUnitsToAdd();
        controller.getSelectedBusinessUnits();
        controller.addAllBusinessUnits();
        controller.removeBusinessUnits();
        controller.saveBusinessUnits();
        //For Languages        
        controller.getallAvailableLanguages();
        controller.addLanguages();
        controller.loadLanguageDetails();
        controller.getAvailableLanguages();
        controller.getLanguagesToRemove();
        controller.getSmLanguagesToAdd();
        controller.getSelectedLanguages();
        controller.addAllLanguages();
        controller.removeLanguages();
        controller.saveLanguages();


        
        
    }
    
    
}