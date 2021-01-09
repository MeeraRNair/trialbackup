/* 
REVISION HISTORY
================
Version     Author      Date            Release#    CR#     Description
-------     ------      ----            --------    ---     -----------
1.0         Sandhya     05-Nov-2012     14.2         --     Controller for Partenr user to attach mass upload lead file.
2.0         Sandhya     08-Apr-2013     14.2         --     Defect 64274
3.0         Raphael     31-Dec-2013     15.03       8835    Change MLUR FAQ doc link
4.0         Jiji        05-Jun-2014     15.10       ----    Add translated MLUR Template for 3 chinese, japanese and korean
5.0         Anu         23-Feb-2015     16.03               Defect 155483
6.0         Shue        14-Mar-2019     FY20-0402   17125   Defect 6326439: SDET - Wunderkind:: CAMP:: FY20-0402:: Unable to submit MLUR
7.0         Shue        20-Mar-2019     FY20-0402   17125   Test Covereage fix
*/

public class CMAP_MassLeadUploadCntrlr {

    public Mass_Upload_Lead_Request__c mulrObj {get;set;}
    public String campaignId {get;set;}
    public Attachment attach {get;set;}
    public String strDocUrl {get;set;}
    public String strDocUrl1 {get;set;}
    public String pageLabel {get;set;}
    public Boolean massUploadBoolean {get;set;}
    public transient blob fileBody{get; set;}
    Public String docLinkPt1; //ver 3.0
    Public String docLinkPt2; //ver 3.0
    Public String languageKey ; //ver 4.0
    
    public CMAP_MassLeadUploadCntrlr (){
        massUploadBoolean = true;
        mulrObj = new Mass_Upload_Lead_Request__c();
        attach = new Attachment();
        campaignId = ApexPages.currentPage().getParameters().get('campId');
        String campaignName = ApexPages.currentPage().getParameters().get('campName');
        String strPartnerAcc = ApexPages.currentPage().getParameters().get('accName');  //6.0
        if(campaignId != null){
            User usr = [Select Id,AccountId,ContactId,Email,LanguageLocaleKey, IsPortalEnabled From User u Where Id = :UserInfo.getUserId()]; //ver 3.0, Ver 4.0 added IsPortalEnabled
            List<Account> lstSMAcc = PamCMAPutilityClass.getSalesmotionAccounts(usr.id);
            mulrObj.Campaign__c = campaignId;
            mulrObj.Partner_User__c = usr.Id;
            mulrObj.Partner_Email_ID__c = usr.Email;
            mulrObj.Partner_Account__c = strPartnerAcc; //6.0
            mulrObj.Status__c = 'New';
            
            //7.0 Start
            Account[] accObj  = [Select Id,Name,OwnerId from Account where Id =:strPartnerAcc];    //7.0
            if(accObj.size() > 0){mulrObj.Partner_Account_Owner_ApiOnly__c = accObj[0].OwnerId;}
            //Account accObj  = [Select Id,Name,OwnerId from Account where Id =:strPartnerAcc];    //6.0
            //7.0 End
            
            for( User superUser :[select Id, AccountId, IsPortalEnabled from User where AccountId = :strPartnerAcc and Enable_As_Partner_Lead_Super_User__c = TRUE AND Isactive = TRUE order by CreatedDate limit 1]){
                  mulrObj.Partner_Super_User_ApiOnly__c = superUser.Id;
            }
            
            //mulrObj.Partner_Account_Owner_ApiOnly__c = accObj.OwnerId;    //7.0
            List<Document> lstDocument = [Select Name, DeveloperName from Document where Name Like '%Channel Mass Lead Upload Template%' or Name = 'Channel Mass Lead Upload Instructions'];
            //Get language key value corresponding to logged in user 
            CMAP_LanguageLocaleKeys__c langKey = CMAP_LanguageLocaleKeys__c.getInstance(usr.LanguageLocaleKey);
            If(langKey.Avaliable_for_MLUR_Template__c == TRUE && usr.isPortalEnabled == TRUE){languageKey =  langKey.Partner_Direct_Codes__c;
            }Else{languageKey = 'en_us';}
            //ver 4.0: 15.10: End
            
            string strOrgId = UserInfo.getOrganizationId();
            pageLabel = System.Label.CMAP_Submit_Multiple_Leads_for+' '+ campaignName; 
            
            // Get details of the templates to be downloaded
            for(Document d : lstDocument){
                // ver 4.0: 15.10: Start
                //if(d.Name ==  'Channel Mass Lead Upload Template'){ 
                if(d.DeveloperName == languageKey+'_Channel_Mass_Lead_Upload_Template'){strDocUrl = '/servlet/servlet.FileDownload?file='+d.Id;}
            }
            //Ver 3.0 START
            docLinkPt1 = System.Label.CMAPMassLeadUploadFAQ;
            docLinkPt2 = System.Label.CMAPMassLeadUploadFAQDoc;
            //CMAP_LanguageLocaleKeys__c langKey = CMAP_LanguageLocaleKeys__c.getInstance(usr.LanguageLocaleKey); 15.10 comment
            //strDocUrl1 = docLink + langKey.Partner_Direct_Codes__c + '/Documents/MLUR_INSTRUCTIONS.pptx';
            strDocUrl1 = docLinkPt1 + langKey.Partner_Direct_Codes__c + docLinkPt2;
            //Ver 3.0 END
        } 
        else{
            PageUtils.AddError(System.Label.CMAP_Lead_submission_error);
            System.debug('Campaign Id incorrect');
        }  
    }
    
    public Pagereference submitAction(){
       try{
            // V 5.0 Start
            system.Debug('---hhhhhhhh----'+attach.name);
            String campaignName = ApexPages.currentPage().getParameters().get('campName');
            if(campaignName != NULL && campaignName.contains('DSG Partner')){
                pageUtils.addError(System.Label.DSG_Channel_Restrict_Campaign);
                return null;
            }// V 5.0 ends
            if((fileBody != null) && (fileBody.size() >5000000)){
                pageUtils.addError('Please attach a file with size less than 5MB');
                return null;
            }else{
                if((attach.name != null)&&(fileBody != null)){
                // Ver 2.0 
                    //String[] formatStr = attach.name.split('\\.');
                    Set<String>formatSet = new Set<String>{'.xls','.xlsx','.csv'};
                    Boolean isFormat = false;
                    
                    for(String str :formatSet){
                        if((isFormat == false) && (attach.name.contains(str))){
                            isFormat = true;
                        }
                    }
                    //if(!formatSet.Contains(formatStr[1])){
                    if(isFormat == false){
                        PageUtils.addError(System.Label.CMAP_Incorrect_file_format);
                    }else{
                        insert mulrObj;
                        attach.OwnerId = UserInfo.getUserId();
                        attach.ParentId = mulrObj.Id;
                        attach.body = fileBody;
                        insert attach;
                        fileBody = null;
                        attach.body = null;
                        attach = new Attachment();
                        massUploadBoolean = false;
                        Mass_Upload_Lead_Request__c  newMULRObj = [Select id,name from Mass_Upload_Lead_Request__c where id =: mulrObj.Id];
                        PageUtils.AddConfirm(System.Label.CMAP_Mass_Lead_Upload_request_successfully_submitted+' -  '+newMULRObj.Name);
                    }
                }else{
                    PageUtils.addError(System.Label.CMAP_attach_a_file_to_Proceed);
                }
            }   
        }
       catch (DMLException e) {
            System.debug('Exception occurred'+e);
            PageUtils.addError(System.Label.CMAP_Error_occured_Mass_Lead_Upload);
       }
        return null;
    }
}