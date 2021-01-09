@isTest
public class VFCntrlr_CustomOppHomePageTest {

    static testMethod void convertWeekQtrSummaryTest() {
        
        PageReference pageRef = Page.VfCustomOpportunityHomePage;
        Test.setCurrentPage(pageRef);
 
        VFCntrlr_CustomOppHomePage ctrl = new VFCntrlr_CustomOppHomePage();
        ctrl.CurrencyPicklistValue = 'MYR';
        ctrl.convertCurrencyDisplayForSummary();
        
        System.assert(ctrl.strWeekTotal.contains('MYR'));
    }
    
    static testMethod void convertCurrencyDisplayForSummaryTest() {
        
        PageReference pageRef = Page.VfCustomOpportunityHomePage;
        Test.setCurrentPage(pageRef);
 
        VFCntrlr_CustomOppHomePage ctrl = new VFCntrlr_CustomOppHomePage();
        PageReference pr = ctrl.convertCurrencyDisplayForSummary();
        
        System.assertEquals(null, pr);
    }
    
    static testMethod void addTrailingZeroTest() {
        
        PageReference pageRef = Page.VfCustomOpportunityHomePage;
        Test.setCurrentPage(pageRef);
 
        VFCntrlr_CustomOppHomePage ctrl = new VFCntrlr_CustomOppHomePage();
        String sval = ctrl.addTrailingZero('10.000,0', 2);
        
        System.AssertEquals('10,000.00', sval);
    }
    
    static testMethod void getCurrencyPicklistTest() {
 
        PageReference pageRef = Page.VfCustomOpportunityHomePage;
        Test.setCurrentPage(pageRef);
 
        VFCntrlr_CustomOppHomePage ctrl = new VFCntrlr_CustomOppHomePage();
        List<SelectOption> opts = ctrl.getCurrencyPicklist();
        
        System.assertEquals('USD', opts[0].getValue());
    }
    
    static testMethod void goToMassUpdateTest() {
 
        PageReference pageRef = Page.VfCustomOpportunityHomePage;
        Test.setCurrentPage(pageRef);
 
        VFCntrlr_CustomOppHomePage ctrl = new VFCntrlr_CustomOppHomePage();
        String nextPage = ctrl.goToMassUpdate().getUrl();
        
        System.assertEquals('/apex/VfMassUpdateOpportunitiesPage', nextPage);
    }
    
    static testMethod void goToRunReportQtrSummaryTest() {
        
        PageReference pageRef = Page.VfCustomOpportunityHomePage;
        Test.setCurrentPage(pageRef);
 
        VFCntrlr_CustomOppHomePage ctrl = new VFCntrlr_CustomOppHomePage();
        ctrl.RunReportPicklistValue1 = 'current';
        ctrl.RunReportPicklistValue2 = 'closed';
        String nextPage = ctrl.goToRunReportQtrSummary().getUrl();
        
        System.assertEquals('/00O?c=RD&go=Run+Report&open=closed&quarter_q=current&rt=22&sort=STAGE_NAME', nextPage);
    }
}