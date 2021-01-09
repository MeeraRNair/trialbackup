public class FAP_LogoExtension extends FAP_PartnerFinderBaseController {
    
    public Boolean bisFirefox{get {return FAP_PageUtils.isFirefox();}} // Ver 2.3
    public static String strinvalidPageFlow {get{return 'INVALID_PAGE_FLOW';}}
    public String strerror{get;private set;}
    public Boolean strerrorOccurred{get{return FAP_StringUtils.isNotBlank(strerror);}}

    private SObject record;
    public Account account {get;private set;}
    public Partner_Track__c partnerTrack {get;private set;}
    public Logo__c logoRecord {get;private set;}
    public Logo__c logoRecordlist {get;private set;}
    public Attachment logoAttachment {get;private set;}
        
    public String   strattachmentContentType {get;set;}
    public String   strattachmentFileName {get;set;}
    public transient Blob   blbattachmentFile {get;set;}
    public String   straccountId {get;private set;}
     public String   strpartnerTrackId {get;private set;}
    public String   strretURL {get;private set;}
    public String   strcancelURL {get;private set;}
    public String   strshowHeader {get;private set;}
    private User currentUser = null;
    public Boolean isCurrentUserAdmin = false;
    

    public FAP_LogoExtension(ApexPages.StandardController controller){
        this.record = controller.getRecord();
        this.straccountId = FAP_PageUtils.get('accountId');
        this.strpartnerTrackId = FAP_PageUtils.get('accountId');// Replace partnertrackid with accountid
        this.strretURL = FAP_PageUtils.param('strretURL');
        this.strcancelURL = FAP_PageUtils.param('strcancelURL');
        this.strshowHeader = FAP_PageUtils.param('strstrcancelURL');
    }
 
    public PageReference doOnLoad(){
    
        // to check logged in user is admin or not
        this.currentUser = [select id, Enable_Partner_Admin__c from User where id =: Userinfo.getUserId()];  
        if(this.currentUser.Enable_Partner_Admin__c== true){
            this.isCurrentUserAdmin = true;
        }
                
        if(record == null ||!(record instanceof Logo__c)){
            strerror = strinvalidPageFlow;
            return null;
        }
   
        If(FAP_Configuration.keyValue == 'Account__r.' || (straccountId != null && straccountId.startsWith('001')))
        {
        try{
            if(this.record.id == null){
                account = [select id,name,logo__c from Account where id = :straccountId];
                if(FAP_StringUtils.isNotBlank(account.logo__c)){
                    return FAP_PageUtils.redirect(Page.FAP_Logo.getUrl() + '?id=' + account.logo__c 
                        + (FAP_StringUtils.isBlank(this.strretURL) ? '' : '&strretURL='+EncodingUtil.urlEncode(this.strretURL, 'UTF-8'))
                        + (FAP_StringUtils.isBlank(this.strcancelURL) ? '' : '&strcancelURL='+EncodingUtil.urlEncode(this.strcancelURL, 'UTF-8'))
                         + (FAP_StringUtils.isBlank(this.strshowHeader) ? '' : '&strshowHeader='+EncodingUtil.urlEncode(this.strshowHeader, 'UTF-8'))
                    );
                }
            }else{
                account = [select id,name,logo__c from Account where logo__c = :this.record.id];
            }
        }catch(QueryException e){
            strerror = strinvalidPageFlow;
            return null;
        }       
        
        this.strretURL = FAP_StringUtils.isBlank(this.strretURL) ? '/'+account.id : this.strretURL;
        this.strcancelURL = FAP_StringUtils.isBlank(this.strcancelURL) ? '/'+account.id : this.strcancelURL;
        try{
            logoRecord = (Logo__c) record;
            logoAttachment = [select id from Attachment where parentid = :logoRecord.id];
        }catch(QueryException e){}
        return null;
        }
        else 
        {
            try{
            if(this.record.id == null){
                 if(FAP_StringUtils.isNotBlank(strpartnerTrackId)){
                partnerTrack = [select id,name,logo__c from Partner_Track__c where id = :strpartnerTrackId];
                system.debug('@@@@Logo 70-----'+ partnerTrack);
                if(FAP_StringUtils.isNotBlank(partnerTrack.logo__c)){
                    return FAP_PageUtils.redirect(Page.FAP_Logo.getUrl() + '?id=' + partnerTrack.logo__c 
                        + (FAP_StringUtils.isBlank(this.strretURL) ? '' : '&strretURL='+EncodingUtil.urlEncode(this.strretURL, 'UTF-8'))
                        + (FAP_StringUtils.isBlank(this.strcancelURL) ? '' : '&strcancelURL='+EncodingUtil.urlEncode(this.strcancelURL, 'UTF-8'))
                        + (FAP_StringUtils.isBlank(this.strshowHeader) ? '' : '&strshowHeader='+EncodingUtil.urlEncode(this.strshowHeader, 'UTF-8'))
                    );
                }
                 }
                 else
                 {
                            account = [select id,name,logo__c from Account where id = :straccountId];
                if(FAP_StringUtils.isNotBlank(account.logo__c)){
                        return FAP_PageUtils.redirect(Page.FAP_Logo.getUrl() + '?id=' + account.logo__c 
                            + (FAP_StringUtils.isBlank(this.strretURL) ? '' : '&strretURL='+EncodingUtil.urlEncode(this.strretURL, 'UTF-8'))
                            + (FAP_StringUtils.isBlank(this.strcancelURL) ? '' : '&strcancelURL='+EncodingUtil.urlEncode(this.strcancelURL, 'UTF-8'))
                            + (FAP_StringUtils.isBlank(this.strshowHeader) ? '' : '&strshowHeader='+EncodingUtil.urlEncode(this.strshowHeader, 'UTF-8'))
                        );
                } 
                 }
            }else{
                logoRecordlist = [SELECT Id,Name,(Select id from Account_Partner_Tracks__r) FROM logo__c where id =:this.record.id];
                if(logoRecordlist.Account_Partner_Tracks__r.size() > 0){
                partnerTrack = [select id,name,logo__c from Partner_Track__c where logo__c = :this.record.id];
                system.debug('@@@@Logo 80-----'+ partnerTrack);
                 }
                 else
                 {
                   account = [select id,name,logo__c from Account where logo__c = :this.record.id];
                 }
            }
        }catch(QueryException e){
            strerror = strinvalidPageFlow;
            return null;
        }
        if(partnerTrack != Null)
        {
        this.strretURL = FAP_StringUtils.isBlank(this.strretURL) ? '/'+partnerTrack.Id  : this.strretURL;
        system.debug('this.strretURL-------------------'+this.strretURL);
        this.strcancelURL = FAP_StringUtils.isBlank(this.strcancelURL) ? '/'+partnerTrack.Id : this.strcancelURL;
        }
        else if(account != Null)
        {
        this.strretURL = FAP_StringUtils.isBlank(this.strretURL) ? '/'+account.Id : this.strretURL;
        this.strcancelURL = FAP_StringUtils.isBlank(this.strcancelURL) ? '/'+account.Id  : this.strcancelURL;
        }
        
        try{
            logoRecord = (Logo__c) record;
            logoAttachment = [select id from Attachment where parentid = :logoRecord.id];
        }catch(QueryException e){}
        return null;   
            
        }
        
        
    }
    
    public static Double dblmaxBlowSizeInKb {get{return 10;}}
     
    public PageReference doReplaceLogo(){
        if(blbattachmentFile == null){
            FAP_PageUtils.addError('Please select a file to upload.');
            return null;
        }
        
        
        final Double size = Decimal.valueOf(((Double)blbattachmentFile.size()/1024)).setScale(2);
        if(size > dblmaxBlowSizeInKb){
            FAP_PageUtils.addError('Logo size (' + size + ' KB) exceeds maximum file size (' + dblmaxBlowSizeInKb + ' KB).');
            return null;
        }
        Savepoint sp = null;
        try { 
            sp = Database.setSavepoint();
            logoRecord.Name=strattachmentFileName;
           
            if(logoRecord.id == null){
              
                insert logoRecord;
                
                
            } 
            
        else {
          update logoRecord;
            }
            //V2.0 : Added below code to update date of profile field in account when any image replaced on logo object
            if(FAP_Configuration.keyValue == 'Account__r.'){
            account.Date_of_Profile_Update__c = datetime.now();
            account.logo__c = logoRecord.id;
            update account;
            }
            else
            {
            
             if(partnerTrack != null){
                   
                    Id logoid = logoRecord.id;
                    partnerTrack.Date_of_Profile_Update__c = datetime.now();
                    partnerTrack.logo__c = logoid;
                    update partnerTrack;
                }
                else 
                {
                    account.Date_of_Profile_Update__c = datetime.now();
                    account.logo__c = logoRecord.id;
                    update account;
                }
                
            }
            
            if(logoAttachment == null){
                logoAttachment = new Attachment(
                    Body=blbattachmentFile,
                    ContentType=strattachmentContentType,
                    IsPrivate=false,
                    Name=strattachmentFileName,
                    ParentID=logoRecord.id
                );              
                insert logoAttachment;
            } else {
                logoAttachment.Body=blbattachmentFile;
                logoAttachment.IsPrivate=false;
                logoAttachment.Name=strattachmentFileName;
                update logoAttachment;
            }
        }catch(Exception e) {
            
            Database.rollback(sp);
            ApexPages.addMessages(e);
           
            return null;
            
        }
        return null;    
    }
    
   /* public PageReference doReturn(){
     
        if(FAP_StringUtils.isBlank(this.strretURL)){
            return null;            
        }
        return new PageReference(this.strretURL);
        //PageReference pageRef = new PageReference('/apex/FAP_PartnerDetails');
        //return pageRef ;  
    }

    public PageReference doCancel(){
        if(FAP_StringUtils.isBlank(this.strcancelURL)){
            return null;            
        }
        return new PageReference(this.strcancelURL);
        //PageReference pageRef = new PageReference('/apex/FAP_PartnerDetails');
        //return pageRef ;  
    }*/
     public PageReference doReturn(){
     
        if(FAP_StringUtils.isBlank(this.strretURL)){
            return null;            
        }
        if(isCurrentUserAdmin==true){
            PageReference pageRef = new PageReference('/apex/FAP_PartnerDetails');
            return pageRef ; 
        }else{
        return new PageReference(this.strretURL);
        }
     }    
      public PageReference doCancel(){
        if(FAP_StringUtils.isBlank(this.strcancelURL)){
            return null;            
        }if(isCurrentUserAdmin==true){
            PageReference pageRef = new PageReference('/apex/FAP_PartnerDetails');
            return pageRef ; 
        }else{
            return new PageReference(this.strcancelURL);
        } 
 
    }

}