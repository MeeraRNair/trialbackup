/*
 * Author   : Ragu
 * Purpose  : Controller for RouteLeads page. Handle all Lead routing events.
 *        
 * Revision Ref Number  Release No  Date            Modified By     Description
 * -------- ----------  ----------  -----------     ------------    -----------
 * 1.0      CR 12003    16.10       05-Oct-2015     Ragu            LM2_1_70-Route to Channel Process
 * 1.1      CR 12064    16.10       12-Oct-2015     Ragu            LM2_1_71-Route to Segment Process
 * 1.2      TFS 204068  16.10       20-Oct-2015     Ragu            R2C: Add Direct Lead 2.0 value int R2C Source field in R2C edit form
 * 2.0      CR 15952                12-jun-2018     Sakshi          Reduce code
 */

public class RouteLeadsController {

    String strAction;
    public Boolean bProceedRouting = true;
    public Lead leadRecord {get; private set;}
    
    public RouteLeadsController(ApexPages.StandardController stdController) {
        Id leadId = stdController.getId();
        if(leadId == null) {
            bProceedRouting = false;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'Id parameter is missing. Please go back to Lead and try again.'));
        }
        else {
            strAction = ApexPages.currentPage().getParameters().get('action');
            leadRecord = [select Id, FirstName, LastName, Status, RecordTypeId, RecordType.Name, CreatedById, OwnerId, Owner.Name, Allocation_Queue_GUID__c, 
                                Campaign__c, Campaign__r.Region__c, Contact__c, Contact__r.Name, Related_Contact__c, Related_Contact__r.Name, Lead_Capture_DateTime__c, Route_to_Channel_Date__c, Channel_Lead_Capture_Date__c, 
                                Ready_For_Scoring__c, Dell_Partner_can_contact_me__c, Trigger_Lead_Assignment__c, R2C_Source__c,
                                Lead_Email_Opt_In__c, Lead_Fax_Opt_In__c, Lead_Mail_Opt_In__c, Lead_Phone_Opt_In__c, Email_Opt_in__c, Fax_Opt_in__c, Mail_Opt_in__c, Phone_Opt_in__c
                            from Lead where Id = :leadId];
            
            if(strAction == 'Route To Channel' && !validateR2C(leadRecord)) {
                bProceedRouting = false;
            }
            else if(strAction == 'Route To Segment' && !validateR2S(leadRecord)) {
                bProceedRouting = false;
            }
        }
    }
    
    private Boolean validateR2C(Lead directLead2) {
        Boolean bValid = true;
        if(!LeadRouterHelper.userHasAccess(directLead2, UserInfo.getUserId())) {
            bValid = false;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, LeadRouterHelper.NO_PERMISSION));
        }
        else if(!LeadRouterHelper.leadStatusValidForR2C(directLead2)) {
            bValid = false;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, LeadRouterHelper.INVALID_DL2_STATUS));
        }
        else if(!LeadRouterHelper.campaignSupportsChannelLead(leadRecord.Campaign__c)) {
            bValid = false;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, LeadRouterHelper.INVALID_CAMPAIGN + '.<a href="/' + leadRecord.Campaign__c  + '">Click here</a> (view mode).'));
        }
        return bValid;
    }
    
    private Boolean validateR2S(Lead channelLead) {
        Boolean bValid = true;
        if(!LeadRouterHelper.validateCurrenUser(channelLead)) {
            bValid = false;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, LeadRouterHelper.R2S_BUTTON_AVAILABILITY));
        }
        return bValid;
    }
    
    public PageReference redirect() {
        if(!bProceedRouting) {
            return null;
        }
        
        String strURL;
        if(strAction == 'Route To Channel') {
            LeadRouter.routeToChannel(new list<Lead>{leadRecord}, null);
            
            strURL = '/' + leadRecord.Id + '/e?nooverride=1'
                    + formURLParam('retURL', leadRecord.Id)
                    + formURLParam('RecordType', leadRecord.RecordTypeId)
                    + formURLParam('lea13', 'Qualified - Channel Ready')
                    + formURLParam('CF00N70000002Mf4A_lkid', leadRecord.Contact__c)
                    + formURLParam('CF00N70000002Mf4A', leadRecord.Contact__r.Name)
                    + formURLParam('00NA000000654Jb', (leadRecord.Channel_Lead_Capture_Date__c != null? leadRecord.Channel_Lead_Capture_Date__c.format() : ''))
                    + formURLParam('00NA00000064S6p', leadRecord.Route_to_Channel_Date__c)
                    + formURLParam('00NA00000064hVv', leadRecord.R2C_Source__c) // v1.2
                    + formURLParam('00NA0000009ZFt6', (leadRecord.Lead_Email_Opt_In__c ? '1' : '0'))
                    + formURLParam('00NA0000009ZFt7', (leadRecord.Lead_Fax_Opt_In__c ? '1' : '0'))
                    + formURLParam('00NA0000009ZFt8', (leadRecord.Lead_Mail_Opt_In__c ? '1' : '0'))
                    + formURLParam('00NA0000009ZFt9', (leadRecord.Lead_Phone_Opt_In__c ? '1' : '0'));
        }
        // v1.1 Start
        else if(strAction == 'Route To Segment') {
            LeadRouter.routeToSegment(new list<Lead>{leadRecord}, null);
            //2.0 - Changed the status lea13 -  New
            strURL = '/' + leadRecord.Id + '/e?nooverride=1'
                    + formURLParam('retURL', leadRecord.Id)
                    + formURLParam('RecordType', leadRecord.RecordTypeId)
                    + formURLParam('lea13', 'New') 
                    + formURLParam('CF00N70000002MSoF_lkid', leadRecord.Related_Contact__c)
                    + formURLParam('CF00N70000002MSoF', leadRecord.Related_Contact__r.Name)
                    + formURLParam('00NZ0000001jfxm', (leadRecord.Trigger_Lead_Assignment__c == true ? 1 : 0))
                    + formURLParam('00NA00000064sSv', leadRecord.Email_Opt_in__c)
                    + formURLParam('00NA00000064sSw', leadRecord.Fax_Opt_in__c)
                    + formURLParam('00NA00000064sSz', leadRecord.Mail_Opt_in__c)
                    + formURLParam('00NA00000064sT0', leadRecord.Phone_Opt_in__c);
        }
        // v1.1 End
        
        PageReference pageRef = new PageReference(strURL);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    private String formURLParam(String strField, Object strValue) {
        return ('&' + strField + '=' + PageUtils.encodeVariable(String.valueOf(strValue)));
    }
    
    public PageReference goBack() {
        PageReference pageRef = new ApexPages.StandardController(leadRecord).view();
        pageRef.setRedirect(true);
        return pageRef;
    }
    
}