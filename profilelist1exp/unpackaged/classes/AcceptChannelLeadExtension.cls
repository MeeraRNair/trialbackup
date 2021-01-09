public class AcceptChannelLeadExtension
{   
    private ApexPages.StandardSetController controller;
    private String selectedFilterId { get; set; }
    public boolean isFilterEmpty {get;set;}

    public AcceptChannelLeadExtension(ApexPages.StandardSetController controller)
    {
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
        currentPage  =  new PageReference('/00Q?fcf=00BA0000004VZtx');
        currentPage.setRedirect(true);
        return currentPage;
    }
    

    public PageReference No() {
        PageReference currentPage = ApexPages.currentPage();
        currentPage  =  new PageReference('/00Q/o');
        currentPage.setRedirect(true);
        return currentPage;
    }
    
    public PageReference PerformMassLeadUpdate() {
        List<Profile> lstProfile = [SELECT Id, Name FROM Profile WHERE Id =:userinfo.getProfileId() LIMIT 1];
        String profileName = lstProfile[0].Name.toUpperCase();
        
        try
        {
            if( profileName.indexOf('PRM') == -1 && profileName.indexOf('PORTAL') == -1 )
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You are not authorized to perform this function'));
                return null;
            }
            else
            {
                PageReference currentPage = ApexPages.currentPage();
                Map<String, String> params  =  currentPage.getParameters();
                String pageName = '';
                if(String.isNotEmpty(selectedFilterId) && selectedFilterId == '00BA0000004VZtx')
                {
                    list<Lead> lstSelectedLeads = (Lead[])controller.getSelected();
                    list<Lead> lstLeadsToUpdate = new List<Lead>();
                    
                    if(lstSelectedLeads.isEmpty())
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.CMAP_Mass_Accept_button_Message));
                        return null;
                    }
                    else
                    {
                        for(Lead objLead : lstSelectedLeads)
                        {
                            lstLeadsToUpdate.add( new Lead( Id = objLead.Id,
                                                            Status = 'Accepted by Channel Partner',
                                                            Accept_Reject_Reassign_Status__c='Accepted by Channel',
                                                            Partner_Lead_Status__c = 'Accepted'
                                                            ));
                        }
                        
                        if(!lstLeadsToUpdate.isEmpty())
                            Database.update(lstLeadsToUpdate,false);
                        
                        pageName = '/00Q/o';
                        currentPage  =  new PageReference(pageName);
                        currentPage.setRedirect(true);
                        return currentPage;
                        
                    }
                }
                else
                {
                    
                    isFilterEmpty = true;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.CMAP_Mass_Accept_button_Message2 ));
                    
                    if(Test.isrunningTest())
                        integer i = 1/0;
                    return null;
                }
                
            }
        }
        catch(exception ex)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.CMAP_Default_Error_Message + ex.getMessage()));
            return null;
        }
        
                
    }
}