/*******************************************************************************************
REVISION HISTORY
================
Version     Author      Date            Release#          CR#     Description
-------     ------      ----            --------          ---     -----------
1.0         Jiji        12-Nov-2012     14.2               --      Controller for Overriding New Button in Lead.
2.0         Jiji        25-Sep-2013     14.10              8458    Defect 81364
3.0         Jiji        26-Sep-2013     14.10              8458    Defect 81426
4.0         Jiji        19-Nov-2013     14.10              --      Defect 85653
5.0         Manju       07-Feb-2014     15.3               8843    Cloning Lead record
6.0         Jiji        03-Jun-2014     15.07              9355    AP routing: Avoid profiles to create lead manually
7.0         Jiji        12-Aug-2014     15.07              9355    Production issue for GBL Marketing/Data Admin Profile
8.0         Nagendra    13-Oct-2015     16.10              12078   As a Sales/Marketing user  I should be able to clone 'Channel Lead 2.0' routed from 'Direct Lead 2.0' or 'Channel Lead 2.0' 
                                                                   to 'Channel Lead Cleansing and Scoring'
9.0         Vasavi.M    14-Dec-2016     0103               13807   KACE related code cleanup    
10.0         Sazleen     08-Nov-2017    FY18-DCS-0102      15099   Renaming existing Channel Sales profile as Channel Lead Operations
11.0        Rahul M     13-June-2018    FY19DCS-07-03              Code Redeuce!
12.0        Ashok       23-May-2019     FY20DEC-0702               Removing profiles'GBL Sales Operation Support - Non SSO','GBL Sales Operation Support from validation to create lead
********************************************************************************************/

public class CMAP_overrideNewController {
    Id userId;
    Id idProfileId;
    User u = new User();
    String URL;
    Id leadRTId;
    String leadRTCloned;
    String retURLString;
    Profile userProfile = new Profile();
    Public Boolean okbutton {get; set;}
    //Ver 5.0
    public Lead leadRecord {get; set;}
    public String cloneId {get; set;}
    Public String MARKETING_ERROR = 'This button is intended for marketing use only. Please contact your channel marketing manager for assistance. Thank you.';
    Public String AUTH_ERROR = 'You are not Authorized to this Function. Please contact your channel marketing manager for assistance. Thank you.';

    public CMAP_overrideNewController(ApexPages.StandardController controller) {
        try {
            okbutton = False;
            leadRTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead - Cleansing & Scoring Complete');
            //Ver 5.0

            String RTString = leadRTId;
            if(RTString.Length() == 18) {
                leadRTCloned = RTString.Substring(0, 15);
            } 
            else {
                leadRTCloned = leadRTId;
            }
            //Ver 3.0: Code End
            userId = UserInfo.getUserId();
            idProfileId = UserInfo.getProfileId();
            userProfile = [Select Id, Name from Profile where Id = : idProfileId];

            u = [select id, IsPortalEnabled from User where Id = : userId];
            cloneId = ApexPages.currentPage().getParameters().get('clId');
            if(cloneId != NULL) {
                leadRecord = [Select Id, Name, Salutation, FirstName, LastName, Company, email, Phone, MobilePhone, fax,
                Lead_Score__c, Route_to_Market__c, Partner_Account__r.Name, Campaign__r.Name, Campaign__c,
                Partner_Account__c, Industry, Purchase_Timeframe__c, Origin__c, RecordTypeId, Dell_Partner_can_contact_me__c, Lead_Type__c, LeadSource,
                Solution_Provider_can_contact_me__c, Dell_can_contact_me_in_the_future__c, Decision_Making_Role__c,
                AnnualRevenue, Employees__c, Engagement_Type__c, Budget__c, Budget_Range__c, Operating_System__c,
                Total_Expected_Dell_Revenue__c, Solution_Type__c, Solution_Scope__c,
                Street, City, State, PostalCode, Country
                from Lead
                where Id = : cloneId];
            }
        } 
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, System.Label.CMAP_Default_Error_Message));
        }
    }

    //excempt marketting user only for channel lead cleansing
    public pagereference okbuttonAction() {
        return (PageUtils.Redirect('/home/home.jsp'));
    }

    public pagereference redirect() {
        //Ver 2.0: AP Routing:Start
		//12.0 - Commenting two profiles so that user can create lead
        Set<String> APProfileName = new Set<String> { 
													//'GBL Sales Operation Support - Non SSO',
                                                    //'GBL Sales Operation Support',
                                                    'GBL Sales Manager_CEO',
                                                    'GBL Sales Manager_CEO - Non SSO',
                                                    'MSG Service Sales',
                                                    'MSG Service Sales - Non SSO',
                                                    'GBL Dell Services Mgr',
                                                    'GBL Dell Services Mgr - Non SSO',
                                                    'GBL Dell Services Rep',
                                                    'GBL Dell Services Rep - Non SSO',
                                                    'GBL Manage S&P – Non SSO',
                                                    'GBL Aprimo Integration User - Non SSO',
                                                    'GBL Finance and Gbl Operation',
                                                    'GBL Finance and Gbl Operation - Non SSO' };
        //ver 2.0: AP Routing : End
        Set<String> ProfileName = new Set<String> {
                                                    'GBL Sales Mgr - Non SSO',
                                                    'GBL Sales Mgr',
                                                    'GBL Sales Rep',
                                                    'GBL Sales Rep - Non SSO',
                                                    'JPN Sales Mgr',
                                                    'JPN Sales Mgr - Non SSO',
                                                    'JPN Sales Rep',
                                                    'JPN Sales Rep - Non SSO',
                                                    //v10.0 start
                                                    'GBL Channel Lead Operations', //10.0 end
                                                    'GBL Channel Sales - Non SSO',
                                                    'GBL EMEA Sales Rep - Non SSO',
                                                    'GBL EMEA Sales Rep',
                                                    'GBL EMEA Sales Mgr - Non SSO',
                                                    'GBL EMEA Sales Mgr' };
                                                    
        Set<String> ProfileNameforClone = new Set<String> (ProfileName);
        ProfileNameforClone.add('GBL Marketing User');
        ProfileNameforClone.add('GBL Marketing User - Non SSO');
                                                          //  'GBL Marketing User - Non SSO' };
                                                            
        String profileNameWithoutVersion = userProfile.Name.replaceFirst('[Rr]{1}[0-9.]+[ ]{1}', '');
        PageReference pr = ApexPages.currentPage();
        //Ver 5.0
        //Ver 2.0: AP Routing:Start
        if(APProfileName.Contains(profileNameWithoutVersion)) {
            okbutton = True;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, MARKETING_ERROR));
            return null;
        }
        //ver 2.0: AP Routing : End
        if(ProfileNameforClone.Contains(profileNameWithoutVersion) && cloneId != null) {
            okbutton = True;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, MARKETING_ERROR));
            return null;
        } 
        else {
            if(cloneId != NULL) {
                // v8.0 Start
                Boolean bLM2 = false;
                Id targetRTId;
                if(leadRecord.Origin__c == 'Channel Lead 2.0' || leadRecord.Origin__c == 'Direct Lead 2.0') {
                    bLM2 = true;
                    targetRTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead 2.0'); // v8.0
                } 
                else {
                    targetRTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead - Submission');
                }
                // v8.0 End
                String URL = '/00Q/e?ent=Lead&nooverride=1&RecordType='+targetRTId +'&retURL=%2F00Q%2Fo'+'&clId='+leadRecord.Id+
                               (leadRecord.Salutation!=NULL?'&name_salutationlea2='+pageUtils.encodeVariable(leadRecord.Salutation):'')+
                               (leadRecord.FirstName!=NULL?'&name_firstlea2='+pageUtils.encodeVariable(leadRecord.FirstName):'')+
                               (leadRecord.LastName!=NULL?'&name_lastlea2='+pageUtils.encodeVariable(leadRecord.LastName):'')+
                               (leadRecord.Company!=NULL?'&lea3='+pageUtils.encodeVariable(leadRecord.Company):'')+
                               (leadRecord.Email!=NULL?'&lea11='+pageUtils.encodeVariable(leadRecord.Email):'')+
                               (leadRecord.Phone!=NULL?'&lea8='+pageUtils.encodeVariable(leadRecord.Phone):'')+
                               (leadRecord.MobilePhone!=NULL?'&lea9='+pageUtils.encodeVariable(leadRecord.MobilePhone):'')+
                               (leadRecord.Fax!=NULL?'&lea10='+pageUtils.encodeVariable(leadRecord.Fax):'')+
                               (leadRecord.Street!=NULL?'&lea16street='+pageUtils.encodeVariable(leadRecord.Street):'')+
                               (leadRecord.PostalCode!=NULL?'&lea16zip='+pageUtils.encodeVariable(leadRecord.PostalCode):'')+
                               (leadRecord.City!=NULL?'&lea16city='+pageUtils.encodeVariable(leadRecord.City):'')+
                               (leadRecord.State!=NULL?'&lea16state='+pageUtils.encodeVariable(leadRecord.State):'')+
                               (leadRecord.Country!=NULL?'&lea16country='+pageUtils.encodeVariable(leadRecord.Country):'')+
                               (leadRecord.Lead_Score__c!=NULL?'&00NA0000009ZFtB='+pageUtils.encodeVariable(leadRecord.Lead_Score__c):'')+
                               (leadRecord.Route_to_Market__c!=NULL?'&00NA0000009ZG0R='+pageUtils.encodeVariable(leadRecord.Route_to_Market__c):'')+
                               (leadRecord.Partner_Account__r.Name!=NULL?'&CF00NA0000009ZFtJ='+pageUtils.encodeVariable(leadRecord.Partner_Account__r.Name):'')+
                               (leadRecord.Campaign__r.Name!=NULL?'&CF00N70000002MSoG='+pageUtils.encodeVariable(leadRecord.Campaign__r.Name):'')+
                               (leadRecord.Industry!=NULL?'&lea6='+pageUtils.encodeVariable(leadRecord.Industry):'')+
                               (leadRecord.Purchase_Timeframe__c!=NULL?'&00N70000002MSnl='+pageUtils.encodeVariable(leadRecord.Purchase_Timeframe__c):'')+
                               (leadRecord.Solution_Provider_can_contact_me__c==TRUE?'&00NA0000009ZG15='+1:'')+
                               (leadRecord.Dell_can_contact_me_in_the_future__c!=NULL?'&00N70000002MSnq='+pageUtils.encodeVariable(leadRecord.Dell_can_contact_me_in_the_future__c):'')+
                               (leadRecord.Decision_Making_Role__c!=NULL?'&00N70000002MSo0='+pageUtils.encodeVariable(leadRecord.Decision_Making_Role__c):'')+
                               (leadRecord.Employees__c!=NULL?'&00N70000002MSoA='+pageUtils.encodeVariable(leadRecord.Employees__c):'')+
                               (leadRecord.Engagement_Type__c!=NULL?'&00NA0000009ZG0v='+pageUtils.encodeVariable(leadRecord.Engagement_Type__c):'')+
                               (leadRecord.Budget__c!=NULL?'&00NA0000009ZG0q='+pageUtils.encodeVariable(leadRecord.Budget__c):'')+
                               (leadRecord.Budget_Range__c!=NULL?'&00NA00000063bRd='+leadRecord.Budget_Range__c:'')+
                               (leadRecord.AnnualRevenue!=NULL?'&lea7='+leadRecord.AnnualRevenue:'')+
                               (leadRecord.Total_Expected_Dell_Revenue__c!=NULL?'&00NA0000009ZFtT='+leadRecord.Total_Expected_Dell_Revenue__c:'')+
                               (leadRecord.Operating_System__c!=NULL?'&00NA00000063bRe='+pageUtils.encodeVariable(leadRecord.Operating_System__c):'')+
                               (leadRecord.Solution_Type__c!=NULL?'&00NA0000009ZG0W='+pageUtils.encodeVariable(leadRecord.Solution_Type__c):'')+
                               (leadRecord.Solution_Scope__c!=NULL?'&00NA0000009ZG0b='+pageUtils.encodeVariable(leadRecord.Solution_Scope__c):'');
                // v8.0 Start
                if(bLM2) {
                    URL += (leadRecord.Dell_Partner_can_contact_me__c!=NULL?'&00NA00000065GQj='+(leadRecord.Dell_Partner_can_contact_me__c ?1:0):'')+
                           (leadRecord.Lead_Type__c!=NULL?'&00NA00000065GQu='+pageUtils.encodeVariable(leadRecord.Lead_Type__c):'')+
                           (leadRecord.LeadSource !=NULL?'&lea5='+pageUtils.encodeVariable(leadRecord.LeadSource):'');
                }
                // v8.0 End
                pagereference page = new pagereference(URL);
                page.setRedirect(TRUE);
                return page;
            }
        }
        //
        if(ProfileName.Contains(profileNameWithoutVersion) && !(String.ValueOf(pr).Contains('sLeadId'))) {
            okbutton = True;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'This button is intended for marketing use only. Please contact your channel marketing manager for assistance. Thank you.'));
        } 
        else {
            if(u.IsPortalEnabled == TRUE) {
                return (Pageutils.redirect('/apex/CMAP_LeadGenerationInterface'));
            } 
            else {
                Map < String, String > params = pr.getParameters();
                String stringToAppend = '';
                for (String keyStr: params.keySet()) {
                    if(keyStr != 'core.apexpages.devmode.url' && keyStr != 'sfdc.override' && keyStr != 'save_new' && keyStr != 'scontrolCaching') {
                        if(stringToAppend != '') {
                            stringToAppend += '&';
                        }
                        stringToAppend += keyStr + '=' + pageUtils.encodeVariable(params.get(keyStr));
                    }
                }

                if((stringToAppend.Contains('RecordType=' + leadRTId) || stringToAppend.Contains('RecordType=' + leadRTCloned)) && (!(stringToAppend.Contains('sLeadId'))) &&
                (userProfile.Name.Contains('GBL Marketing') || userProfile.Name.Contains('Marketing User') || userProfile.Name.Contains('Channel Marketing') || userProfile.Name.Contains('Lead Assignment'))) {
                    //Ver 2.0: Defect 81364
                    okbutton = TRUE;
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, AUTH_ERROR));
                    return Null;
                }
                //Ver 4.0: Code Start
                else if(stringToAppend.Contains('CF00NA00000063aoO')) {
                    String rlleadId;
                    rlleadId = ApexPages.currentPage().getParameters().get('CF00NA00000063aoO_lkid');
                    List<Lead> ldList = [Select Id from Lead where Relationship_Lead__c = : rlLeadId];
                    if(ldList.Size()> 0) {
                        if((stringToAppend.Contains('RecordType=' + leadRTId) || stringToAppend.Contains('RecordType=' + leadRTCloned))) {
                            okbutton = TRUE;
                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, AUTH_ERROR));
                            return Null;
                        } 
                        else {
                            String URL = '/00Q/e?nooverride=1&RecordType=' + ApexPages.currentPage().getParameters().get('RecordType') + '&retURL=' + rlLeadId;

                            return new PageReference(URL);
                        }
                    }
                }
                //Ver 6.0: Start
                else if(stringToAppend.Contains('CF00NK0000001GaSV') || stringToAppend.Contains('CF00NA00000064iEg') || stringToAppend.Contains('CF00NZ00000019vuz')) {
                    String apleadId;
                    if(stringToAppend.Contains('CF00NK0000001GaSV')) {
                        apleadId = ApexPages.currentPage().getParameters().get('CF00NK0000001GaSV_lkid');
                    } 
                    else {
                        if(stringToAppend.Contains('CF00NA00000064iEg')) {
                            apleadId = ApexPages.currentPage().getParameters().get('CF00NA00000064iEg_lkid');
                        } 
                        else if(stringToAppend.Contains('CF00NZ00000019vuz')) {
                            apleadId = ApexPages.currentPage().getParameters().get('CF00NZ00000019vuz_lkid');
                        }
                    }
                    List<Lead> apldList = [Select Id from Lead where Account_Play__c = : apLeadId];
                    if(apldList.Size()> 0) {
                        if((stringToAppend.Contains('RecordType=' + leadRTId) || stringToAppend.Contains('RecordType=' + leadRTCloned))) {
                            okbutton = TRUE;
                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, AUTH_ERROR));
                            return Null;
                        } 
                        else {
                            String URL = '/00Q/e?nooverride=1&RecordType=' + ApexPages.currentPage().getParameters().get('RecordType') + '&retURL=' + apLeadId;

                            return new PageReference(URL);
                        }
                    }
                }
                //Ver 6.0: End
                //Ver 7.0: Start
                else if(profileNameWithoutVersion.Contains('GBL Marketing/Data Admin Profile') && (stringToAppend.Contains('RecordType=' + leadRTId) || stringToAppend.Contains('RecordType=' + leadRTCloned))) {
                    okbutton = TRUE;
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, AUTH_ERROR));
                    return Null;
                }
                //Ver 7.0: End
                else if(stringToAppend.Contains('CF00NA0000006442I')) {
                    String segleadId = ApexPages.currentPage().getParameters().get('CF00NA0000006442I_lkid');
                    List<Lead> leadList = [Select Id from Lead where Segment_Lead__c = : segLeadId];
                    if(leadList.Size()> 0) {
                        if((stringToAppend.Contains('RecordType=' + leadRTId) || stringToAppend.Contains('RecordType=' + leadRTCloned))) {
                            okbutton = TRUE;
                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'You are not Authorized to this Function. Please contact your channel marketing manager for assistance. Thank you.'));
                            return Null;
                        } 
                        else {
                            String URL = '/00Q/e?nooverride=1&RecordType=' + ApexPages.currentPage().getParameters().get('RecordType') + '&retURL=' + segLeadId;

                            return new PageReference(URL);
                        }
                    } 
                    else {
                        return new PageReference('/00Q/e?nooverride=1&' + stringToAppend);
                    }
                }
                //Ver 4.0: Code End
                else {
                    return new PageReference('/00Q/e?nooverride=1&' + stringToAppend);
                }
            }
        }
        return null;
    }
}