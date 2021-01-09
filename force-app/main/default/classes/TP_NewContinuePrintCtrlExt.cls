/*
* Author   : Sri Harsha Chadalavada
* Purpose  : Extension class to redirect to respective pages on click of new/continue planning buttons 
*            and to display error Messages.
*        
* Revision Ref Number  Release No  Date            Modified By     Description
* -------- ----------  ----------  -----------     ------------    -----------
* 1.0      CR14882      FY18-0102   06-Sep-2017     Harsha          Created
* 1.1       CR15011     FY18-0102   08-Oct-2017     Harsha          Restrict access to create new TP
* 1.2       CR15012     FY18-0102   10-Oct-2017     Harsha          Restrict access to continue planning
* 1.3       CR15014     FY18-0102   19-Oct-2017     Nagaraju        Redirecting to drwaloop package to download and attach PPT.
*/


public class TP_NewContinuePrintCtrlExt {
    
    static final String STARTPAGE = TP_PageNavUtils.vfPageNames[0];
    static final Integer RECORDSPERUSER = 1;
    static final String PRINTPAGE = 'TP_PrintRDownloadTP';
    
    public Territory_Plan__c tp_newPlan;
    public boolean bRecordExist;
    public boolean bErrMessage;
    private string pageUrl = '';
    
    string sUrlId;
    ID userId;
    Integer intNoOfRecords;
    
    public TP_NewContinuePrintCtrlExt(ApexPages.StandardController controller) {
        userId = userinfo.getuserID();
        sUrlId = apexPages.currentPage().getParameters().get('id');
        pageUrl = ApexPages.currentPage().getUrl();
        system.debug('page Url: '+pageUrl);
        bErrMessage=FALSE;
        bRecordExist = ((sUrlId!=NULL) ? TRUE : FALSE);
        system.debug('sUrlId: '+sUrlId);
        if(!bRecordExist){
            ValidateUser();//v1.1
            Integer iCountUserTP = [SELECT count() from Territory_Plan__c where createdbyid=:userId];
            system.debug('id : '+sUrlId);
            
            if(iCountUserTP>=RECORDSPERUSER){
                //system.debug('error message');
                bRecordExist=FALSE;
                bErrMessage = TRUE;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Only one Territory Plan is allowed per user. Please continue existing plan.'));
            }
        }
        else{
            validateOwner();
        }
    }
    
    //v1.2
    public void validateOwner(){
        if(bRecordExist){
            Territory_plan__c tpFetch = [Select id, name, createdbyId,OwnerId from Territory_plan__c where id =:sUrlId];
            if(tpFetch.createdbyId != userId){
                String errorMsg = 'Only Owner/Creator of "'+tpFetch.Name+'" can ';
                If(pageUrl != null && pageUrl.contains(PRINTPAGE)){ //v1.3
                    errorMsg+= 'Print/Download Territory Plan!';
                }
                else {
                    errorMsg+= 'continue this planning!';
                }
                bErrMessage = TRUE;
                System.debug('Page Name:'+pageUrl);
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,errorMsg));
            }
        }
    }
    
    //v1.1
    public void ValidateUser() {
        string strQuery = 'SELECT count()'+
            ' from AccountTeamMember'+
            ' where UserId =: userId'+
            ' and (TeamMemberRole = \'Account Executive\' or TeamMemberRole = \'OEM Account Executive\''+ 
            ' or TeamMemberRole = \'OEM Global Account Manager\' or TeamMemberRole = \'Inside Sales Rep\')';
        intNoOfRecords = Database.countquery(strQuery);
        
        If(intNoOfRecords <= 0 ){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,
                                                       'Territory Plan is only enabled for ISR´s, AE’s, OEM AE’s, OEM GAM’s.'
                                                       + ' Please contact users with respective roles for Territory Plan creation/copy.'));
            bErrMessage=TRUE;
        }            
    }
    
    public pageReference redirectToPage(){
        pageReference pg;
        if(!bErrMessage){
            system.debug('pageUrl '+pageUrl);
            if(pageUrl != null && pageUrl.contains(PRINTPAGE)){ //v1.3
                string url = System.Label.Territory_Plan_v3_DDP_URL;
                string urlWithID = url.replace('idvalue', sUrlId);
                pg = new pageReference(urlWithID);
                pg.setRedirect(true);
            }
            else {
                if(bRecordExist){
                    Territory_plan__c currentTP = [SELECT id, name, Continue_To_Page__c from Territory_Plan__c where id =:sUrlId];
                    //system.debug('current record : '+currentTP);
                    
                    if(!String.isBlank(currentTP.Continue_To_Page__c)){
                        //system.debug('currentTP.Continue_To_Page__c : '+currentTP.Continue_To_Page__c);
                        pg = TP_PageNavUtils.gotoPage(currentTP.Continue_To_Page__c, currentTP.id);
                    }
                    else{
                        pg = TP_PageNavUtils.gotoPage(STARTPAGE, currentTP.id);
                    }
                }
                else if(!bErrMessage && !bRecordExist){
                    pg = new pageReference('/apex/'+STARTPAGE);
                    pg.setRedirect(true);
                }
            }
        }
        return pg;
    }
    
    //v1.3
    public pageReference redirectPreviousPage(){
        pageReference pg;
        return pg = new pageReference('/' + sUrlId);
    }
}