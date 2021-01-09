public class AddWorkloadstoOpptyExtension {
    public String strOppId {set;get;}
    public String strOrgBaseURL {set;get;}
    
    public AddWorkloadstoOpptyExtension(ApexPages.StandardController controller){
        strOrgBaseURL = URL.getSalesforceBaseUrl().toExternalForm() ;
        Opportunity_Workload__c objOppWrk = (Opportunity_Workload__c)controller.getRecord();
        strOppId = objOppWrk.Opportunity__c ;
    }
    
}