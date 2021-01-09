/*
 * Revision CR Number   Release No      Date            Modified By           Description
 * -------- ---------   ----------      -----------     ------------          -----------
 * 1.0      CR 15625    FY19-DCE-0502   19-Apr-2018     Subramani Ramamurthy  Channel Lead Status Field
 * 1.1      CR 15625    FY19-DCE-0502   07-May-2018     Kokila                DEFECT 5039288: Wunderkind :SDET: For Channel Lead partner status is not sync to lead status when lead status is Closed- worked.
 *
 */


public class CloseChannelLeadExtension
{   
    private ApexPages.StandardSetController controller;
    private String selectedFilterId { get; set; }
       public CloseChannelLeadExtension(ApexPages.StandardSetController controller)
    {
        this.controller = controller;
        this.selectedFilterId = controller.getFilterId().substring(0, 15);
    }
    
           public PageReference PerformMassLeadUpdate() {
        List<Profile> lstProfile = [SELECT Id, Name FROM Profile WHERE Id =:userinfo.getProfileId() LIMIT 1];
        System.debug('ProfileName======'+lstProfile[0].Name);
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
                                                            Status = 'Closed - Worked',
                                                            //v1.1 - Start
                                                            Partner_Lead_Status__c = 'Closed' //v1.1 - End
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
        }
        catch(exception ex)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.CMAP_Default_Error_Message + ex.getMessage()));
            return null;
        }
        
                
    }
}