/*******************************************************************************************
REVISION HISTORY
================
Version     Author      Date            Release#            CR#     Description
-------     ------      ----            --------            ---     -----------
1.0         Manju       07-Feb-2014     15.3                8843    Cloning Lead record
2.0         Jiji        03-Jun-2014     15.07               9355    Revoke permission on users doing R2C from cloning a lead, 
                                                                       if they do not have create permission
3.0         Jiji        12-Aug-2014     15.07               9355    Production issue for GBL Marketing/Data Admin Profile  
4.0         Vasavi.M    14-Dec-2016     0103                13807   KACE related code cleanup         
5.0         Sriram      06-June-2017    FY18-DCS-0702       14401   Non SSO Profile Clean Up    
6.0         Sazleen     08-Nov-2017     FY18-DCS-0102       15099   Renaming existing Channel Sales profile as Channel Lead Operations
7.0         Ashok       24-May-2019     FY20DEC-0702               Removing profile'GBL Sales Operation Support from validation to clone lead  
8.0         Siva        29-Oct-2019     FY20-0102           18250   Clone button working in lightning as expected                            
********************************************************************************************/
public with sharing class CMAP_overrideCloneController {
    Public Boolean okbutton{get;set;}
    Id leadRTId;
    Id idProfileId;
    Id LeadId;
    Profile userProfile = new Profile();
    public CMAP_overrideCloneController(ApexPages.StandardController controller) {
        try{
            okbutton = False;
            idProfileId = UserInfo.getProfileId();
            userProfile = [Select Id, Name from Profile where Id = :idProfileId];
            LeadId= ApexPages.currentPage().getParameters().get('Id');
       }
       catch (Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,System.Label.CMAP_Default_Error_Message));
       } 
    }
    public pagereference okbuttonAction(){
        return(PageUtils.Redirect('/'+LeadId));
    }
    public pagereference redirect(){
         String stringToAppend;
         // CR 14401 - Start
         Set<String> ProfileName = new Set<String>{//'GBL Sales Mgr - Non SSO',
                                              'GBL Sales Mgr',
                                              'GBL Sales Rep',
                                             //'GBL Sales Rep - Non SSO',
                                              'JPN Sales Mgr',
                                             //'JPN Sales Mgr - Non SSO',
                                              'JPN Sales Rep',
                                             //'JPN Sales Rep - Non SSO',
                                             //V6.0 Start
                                              'GBL Channel Lead Operations',  //V6.0 End
                                             //'GBL Channel Sales - Non SSO',
                                             //'GBL EMEA Sales Rep - Non SSO',
                                              'GBL EMEA Sales Rep',
                                             //'GBL EMEA Sales Mgr - Non SSO',
                                              'GBL EMEA Sales Mgr'};
        //Ver 2.0: AP Routing:Start
         //7.0 - Commenting one profile so that user can Clone lead
        Set<String> APProfileName = new Set<String>{/*Ver 4.0 Start 'GBL KACE ASR',
                                              //'GBL KACE LDR - Non SSO',
                                              'GBL KACE LDR',
                                              'GBL KACE ASR - Non SSO',Ver 4.0 End*/
                                              //'GBL Sales Operation Support - Non SSO',
                                              //'GBL Sales Operation Support',
                                              'GBL Sales Manager_CEO',
                                              //'GBL Sales Manager_CEO - Non SSO',
                                              'MSG Service Sales',
                                              //'MSG Service Sales - Non SSO',
                                              'GBL Dell Services Mgr',
                                              //'GBL Dell Services Mgr - Non SSO',
                                              'GBL Dell Services Rep',
                                              //'GBL Dell Services Rep - Non SSO',
                                              //'GBL Marketing/Data Admin Profile', ver 3.0
                                              'GBL Manage S&P – Non SSO',
                                              'GBL Aprimo Integration User - Non SSO',
                                              'GBL Finance and Gbl Operation'
                                              //'GBL Finance and Gbl Operation - Non SSO'
                                              };
        //ver 2.0: AP Routing : End
        // CR 14401 - End
        String profileNameWithoutVersion = userProfile.Name.replaceFirst('[Rr]{1}[0-9.]+[ ]{1}',''); 
        PageReference pr = ApexPages.currentPage();
        if(ProfileName.Contains(profileNameWithoutVersion) ||
            //ver 2.0: AP Routing : Start
           APProfileName.Contains(profileNameWithoutVersion)
            //ver 2.0: AP Routing : End
        ){
              okbutton = True;
              ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'This button is intended for marketing use only. Please contact your channel marketing manager for assistance. Thank you.'));
        
        }
        else{
            Map<String, String> params = pr.getParameters();
            stringToAppend = '';
            for(String keyStr : params.keySet()){
                if(keyStr != 'core.apexpages.devmode.url' &&
                    keyStr != 'sfdc.override' &&
                    keyStr != 'save_new' &&
                    keyStr != 'scontrolCaching'){
                    if(stringToAppend != '') {
                        stringToAppend += '&';
                    }
        //8.0 Clone button working in lightning as expected (added only if condition)
                    if(keyStr == 'clone' || keyStr == 'id' || keyStr == 'retURL'){
                    stringToAppend += keyStr + '='+pageUtils.encodeVariable(params.get(keyStr));
                    }
        //8.0 Clone button working in lightning as expected                 
                }   
            }
            return new PageReference('/'+LeadId+'/e?nooverride=1&'+stringToAppend);
            
        } 
        return NULL;
        
    }

}