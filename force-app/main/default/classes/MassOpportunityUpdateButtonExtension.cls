/***********************************************************
    * Name          : MassOpportunityUpdateButtonExtension
    * Description   : Controller for MassOpportunityUpdateButtonExtension
    
    History:
    Version     Date            Modified By     CR          Description     
    --------------------------------------------------------------------------------------
    1.0         Unknown         Unknown         Unknown     Class creation 
    2.0         26-Aug-2019     Monisha         08184       Update on selected records only.                     
    */
    public with sharing class MassOpportunityUpdateButtonExtension {
       public ApexPages.StandardSetController controller; 
        public String selectedFilterId { get; set; }
        //2.0 Declaration of list to store selected records.
        public Static List<String> listOpportunityId{get;set;}
        public String strOpportunityIds='';
        
        public MassOpportunityUpdateButtonExtension(ApexPages.StandardSetController controller) {
            this.controller= controller;
            this.selectedFilterId = controller.getFilterId().substring(0, 15);
             listOpportunityId=new List<String>();
        }      
        public PageReference cancel() {
            Schema.DescribeSObjectResult result = Opportunity.SObjectType.getDescribe();
            PageReference currentPage = ApexPages.currentPage();
            Map<String, String> params  =  currentPage.getParameters();
            currentPage  =  new PageReference('/' + result.getKeyPrefix() + '/o');
            currentPage.getParameters().putAll(params);
            currentPage.setRedirect(true);
            return currentPage;
        }
        public PageReference redirectToMassUpdatePage() {
            List<Profile> lstProfile = [SELECT Id, Name FROM Profile WHERE Id =:userinfo.getProfileId() LIMIT 1];
            String profileName = lstProfile[0].Name.toUpperCase();
            PageReference currentPage = ApexPages.currentPage();
            Map<String, String> params  =  currentPage.getParameters();
            String pageName = '';
       //2.0 To get ids of selected records. 
            for(Opportunity objops:(List<Opportunity>)controller.getSelected()){
            listOpportunityId.add(objops.id);
            }
            for(Integer inti=0;inti<listOpportunityId.size();inti++){
            if(inti<listOpportunityId.size()-1){
                strOpportunityIds=strOpportunityIds+listOpportunityId[inti]+':';
               }
            else{
                strOpportunityIds=strOpportunityIds+listOpportunityId[inti];
                }
        } 
       //2.0 ends
            if(String.isNotEmpty(selectedFilterId)) {
                if(profileName.contains('PRM') || profileName.contains('PORTAL')) {
                    pageName = '/apex/MassOpportunityUpdateForPRM';
                } else{
                     pageName = '/apex/MassOpportunityUpdate';
                }
                currentPage  =  new PageReference(pageName);
                currentPage.getParameters().put('idOpps',strOpportunityIds);
                currentPage.getParameters().putAll(params);
                currentPage.setRedirect(true);
                return currentPage;
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please click Opportunities tab again to select a view and proceed with Mass Update.'));
                return null;
            }
        }
    }