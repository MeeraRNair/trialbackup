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
@isTest(seealldata=true)
private class SalesMotionSearchCtrlTest {  
    static testMethod void test_initializeController() { 
        SalesMotionSearchCtrl controller = new SalesMotionSearchCtrl(); 
        String selectRecordType; 
        boolean solnDomainRender;
        boolean productRender;
        boolean textSearchRender;
        boolean GenericsearchRender;
        boolean domainTableRender;
        boolean prodcutTableRender;
        boolean textSearchTableRender;
        boolean GenericsearchTableRender;
        string searchtext;
        Sales_Motion_Page_Section__c salesMotionPageSection;
        Sales_Motion__c salesMotion;
        selectRecordType='Domain, Solution Type and Name';
        controller.getSearchRecordTypeList(); 
        controller.Display();
        controller.selectRecordType='Product';
        controller.Display();
        controller.selectRecordType='TextSearch';
        controller.Display();
        controller.selectRecordType='GenericSales';
        controller.Display();
        controller.searchtext='Virtual';
        controller.salesMotionPageSection.Region__c='EMEA';
        controller.salesMotionPageSection.Business_Unit__c='PUBLIC';
        Sales_Motion_Country__c smc=new Sales_Motion_Country__c();
        smc.Name='Paragua';
        insert smc;
        controller.salesMotionPageSection.Sales_Motion_Country__c=smc.id;
        controller.selectedCountry='GERMANY';
        controller.Search();
        controller.selectRecordType='Domain, Solution Type and Name';
        controller.salesMotion.Domain__c='Networking';
        controller.Search();
        controller.salesMotion.Solution_Type__c='Data Center/Unified Fabric';
        controller.Search();
        controller.salesMotion.Solution_Name__c='Application Delivery & Load Balancing';
        controller.Search();
        controller.selectRecordType='Product';
        controller.Search();
        controller.getSMPSList();
        controller.selectRecordType='GenericSales';
        controller.salesMotion.name='Generic SM';
        controller.search();
        controller.selectRecordType='TextSearch';
        controller.search();
    }
    
     
    
}