public with sharing class MassContactUpdateButtonExtension{
    private ApexPages.StandardSetController controller;
    private String selectedFilterId { get; set; }

    public MassContactUpdateButtonExtension(ApexPages.StandardSetController controller) {
        this.controller = controller;
        this.selectedFilterId = controller.getFilterId().substring(0, 15);
    }
    
    public PageReference cancel() {
        Schema.DescribeSObjectResult result = Contact.SObjectType.getDescribe();
        PageReference currentPage = ApexPages.currentPage();
        Map<String, String> params  =  currentPage.getParameters();
        currentPage  =  new PageReference('/' + result.getKeyPrefix() + '/o');
        currentPage.getParameters().putAll(params);
        currentPage.setRedirect(true);
        return currentPage;
    }

    public PageReference redirectToMassUpdatePage() {
        
        PageReference currentPage = ApexPages.currentPage();
        Map<String, String> params  =  currentPage.getParameters();
        String pageName = '';
        if(String.isNotEmpty(selectedFilterId)) {
            
            pageName = '/apex/MassContactUpdate';
            
            currentPage  =  new PageReference(pageName);
            currentPage.getParameters().putAll(params);
            currentPage.setRedirect(true);
            return currentPage;
        } else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please click Contact tab again to select a view and proceed with Mass Update.'));
            return null;
        }
    }
}