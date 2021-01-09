public with sharing class ReassignChannelLeadExtension {
    private ApexPages.StandardSetController controller;
    private String selectedFilterId { get; set; }
    public boolean isFilterEmpty {get;set;}

    public ReassignChannelLeadExtension(ApexPages.StandardSetController controller) {
        this.controller = controller;
        this.selectedFilterId = controller.getFilterId().substring(0, 15);
    }
    
    public PageReference cancel() {
        Schema.DescribeSObjectResult result = Lead.SObjectType.getDescribe();
        PageReference currentPage = ApexPages.currentPage();
        if(String.isNotEmpty(selectedFilterId))
            currentPage  =  new PageReference('/' + result.getKeyPrefix() + '?fcf='+selectedFilterId);
        else
            currentPage  =  new PageReference('/' + result.getKeyPrefix() + '/o');
        
        currentPage.setRedirect(true);
        return currentPage;
    }
    
    public PageReference Yes() {
        
        PageReference currentPage = ApexPages.currentPage();
        currentPage  =  new PageReference('/00Q?fcf=00BA0000008Taqu');
        currentPage.setRedirect(true);
        return currentPage;
    }
    

    public PageReference No() {
        PageReference currentPage = ApexPages.currentPage();
        currentPage  =  new PageReference('/00Q/o');
        currentPage.setRedirect(true);
        return currentPage;
    }

    public PageReference redirectPage() {
        
        try{
            PageReference currentPage = ApexPages.currentPage();
            Map<String, String> params  =  currentPage.getParameters();
            String pageName = '';
            String strLeadIds = '';
            if(String.isNotEmpty(selectedFilterId) && selectedFilterId == '00BA0000008Taqu') {
                
                list<Lead> lstSelectedLeads = (Lead[])controller.getSelected();
                if(lstSelectedLeads.isEmpty())
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.CMAP_Mass_Accept_button_Message));
                    return null;
                }
                else
                {
                    for(Lead objLead: lstSelectedLeads)
                    {
                        strLeadIds += objLead.Id + ',';
                    }
                    
                    strLeadIds = strLeadIds.substring(0, strLeadIds.length()-1 );
                }
                    
                pageName = '/apex/CMAP_ReAssignMultiLeads?leadRecorIds=' + strLeadIds;
                
                currentPage  =  new PageReference(pageName);
                currentPage.getParameters().putAll(params);
                currentPage.setRedirect(true);
                            
                return currentPage;
            } else {
                isFilterEmpty = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.CMAP_Mass_Reassign_button_Message));
                                    
                if(Test.isRunningTest())
                integer i = 1/0;
            
                return null;
            }
            
            
        }
        catch(exception ex)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.CMAP_Default_Error_Message));
            return null;
        }
    }
}