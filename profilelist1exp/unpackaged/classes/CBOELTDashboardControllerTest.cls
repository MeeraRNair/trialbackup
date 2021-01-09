@isTest
public class CBOELTDashboardControllerTest {
static testMethod void testCBOELTDashboardController() {
CBOELTDashboardController CBOELTDB =new CBOELTDashboardController();
CBOELTDB.getELTPipelineDashboards();
CBOELTDB.getELTFinancialDocuments();
CBOELTDB.getELTFinancialDocumentsForLandingPage();
CBOELTDB.getELTSalesPerformanceReportings();
}
}