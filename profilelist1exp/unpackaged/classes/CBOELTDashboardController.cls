public class CBOELTDashboardController {

  public List<CBOELTDashboard__c> getELTPipelineDashboards() {
    return [select LastUpdated__c, SortOrder__c, Source__c, ReportURL__c, ReportName__c, Description__c, ReportType__c from CBOELTDashboard__c where ReportType__c='Bus_Division_SFDC_Pipeline_Dashboards' and Remove_Visibility__c=false order by SortOrder__c];
  }
  public List<CBOELTDashboard__c> getELTFinancialDocuments() {
    return [select LastUpdated__c, SortOrder__c, Source__c, ReportURL__c, ReportName__c, Description__c, ReportType__c from CBOELTDashboard__c where ReportType__c !='Bus_Division_SFDC_Pipeline_Dashboards' and ReportType__c !='Sales Performance Reporting' and ReportType__c !='Financial_Pipeline_Page_Url' and Remove_Visibility__c=false order by SortOrder__c];
  }
  public List<CBOELTDashboard__c> getELTFinancialDocumentsForLandingPage() {
    return [select LastUpdated__c, SortOrder__c, Source__c, ReportURL__c, ReportName__c, Description__c, ReportType__c from CBOELTDashboard__c where ReportType__c !='Bus_Division_SFDC_Pipeline_Dashboards' and Remove_Visibility__c=false order by SortOrder__c];
   }
   
   public List<CBOELTDashboard__c> getELTSalesPerformanceReportings() {
    return [select LastUpdated__c, SortOrder__c, Source__c, ReportURL__c, ReportName__c, Description__c, ReportType__c from CBOELTDashboard__c where ReportType__c='Sales Performance Reporting' and Remove_Visibility__c=false order by SortOrder__c];
  }
}