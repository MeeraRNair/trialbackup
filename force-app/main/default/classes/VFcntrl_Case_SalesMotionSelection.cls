public  without sharing class VFcntrl_Case_SalesMotionSelection {
    
    public List<Account> listacc {get; set;}
    public Map<id,string> mapaccIdToName{get;set;}
    public string selectedSalesMotion{get;set;}
    public String salesMotionName {get; set;}    
    Public String recordTypeName;
    public boolean bhasError{get;set;}
    Id recTypeId;
    public static String recordTypeName {get;set;} 
    
    public VFcntrl_Case_SalesMotionSelection() {
        system.debug('inside constructor');
        bhasError = false;
        recTypeId = ApexPages.currentPage().getParameters().get('RecordType').escapeHtml4();
        list<RecordType> rt = [SELECT Id,Name FROM RecordType WHERE id =: recTypeId LIMIT 1];
        if(rt != null && rt.size() > 0) {
            recordTypeName = rt[0].Name;  
        }
    }
    
    public pagereference updateSelectedAccToCon(){
        System.debug('salesMotionName'+salesMotionName);
        string URL;
        
        if(recordTypeName == 'Order Support'){
            URL = '/apex/OrderSupportVfPage?RecordType=' + recTypeId + '&ent=Case&retURL=%2F500%2Fo'; 
        }else if(recordTypeName == 'Deal Registration'){
            URL = '/apex/DealRegVFPage?RecordType=' + recTypeId + '&ent=Case&retURL=%2F500%2Fo';           
        }else if(recordTypeName == 'On Boarding'){
            URL = '/apex/OnBoardingVFPage?RecordType=' + recTypeId + '&ent=Case&retURL=%2F500%2Fo';
        }else if(recordTypeName == 'Distribution'){
            URL = '/apex/DistributionVFPage?RecordType=' + recTypeId + '&ent=Case&retURL=%2F500%2Fo';
        }else if(recordTypeName == 'Application Support'){
            URL = '/apex/ApplicationSupportVFPage?RecordType=' + recTypeId + '&ent=Case&retURL=%2F500%2Fo';
        }else if(recordTypeName == 'Partner Program'){
            URL = '/apex/ApplicationSupportVFPage?RecordType=' + recTypeId + '&ent=Case&retURL=%2F500%2Fo';
        }/*Meenu : Story 7059159 added recordtype Channel Services Helpdesk vf page redirection*/
        else if(recordTypeName == 'Channel Services Helpdesk'){
            URL = '/apex/ChannelServicesHelpdeskVFPage?RecordType=' + recTypeId + '&ent=Case&retURL=%2F500%2Fo';
        }else { 
            return null;
        }
        pagereference page = new pagereference(URL);
        User loggedInUser = [select Id,Contact.Id from user where id = : UserInfo.getUserId()];
        contact con = new contact();
        con.id = loggedInUser.Contact.Id;
        con.Selected_Track_Account__c = salesMotionName;
        TriggerExecutionController.setSkipAllTriggers(true);
        update con;
        TriggerExecutionController.setSkipAllTriggers(false); 
        checkAndAddAccShare(salesMotionName);
        page.setRedirect(TRUE);
        return page; 
    }
    
    public pagereference checkAndRedirect(){
        bhasError = false;
        listacc = new list<Account>();
        mapaccIdToName = new map<id,string>();
        User loggedInUser = [select Id,Contact.AccountId,Contact.Selected_Track__c from user where id = : UserInfo.getUserId()];
        listacc = [Select Id,Name,Partner_Description__c,owner.name,NameLocal,partner_track__r.Name,Master_Group_Id__c,Master_Group_Id__r.Name,Account_ID__c from Account where Master_Group_Id__c =:loggedInUser.Contact.AccountId and partner_track__c =:loggedInUser.Contact.Selected_Track__c  and Calculated_Status__c =  'Active' limit 1000]; 
        for(Account accRecord : listacc){
            mapaccIdToName.put(accRecord.id,accRecord.Master_Group_Id__r.Name);
        }
        string URL;
        if(recordTypeName == 'Order Support'){
            URL = '/apex/OrderSupportVfPage?RecordType=' + recTypeId + '&ent=Case&retURL=%2F500%2Fo'; 
        }else if(recordTypeName == 'Deal Registration'){
            URL = '/apex/DealRegVFPage?RecordType=' + recTypeId + '&ent=Case&retURL=%2F500%2Fo';           
        }else if(recordTypeName == 'On Boarding'){
            URL = '/apex/OnBoardingVFPage?RecordType=' + recTypeId + '&ent=Case&retURL=%2F500%2Fo';
        }else if(recordTypeName == 'Distribution'){
            URL = '/apex/DistributionVFPage?RecordType=' + recTypeId + '&ent=Case&retURL=%2F500%2Fo';
        }else if(recordTypeName == 'Application Support'){
            URL = '/apex/ApplicationSupportVFPage?RecordType=' + recTypeId + '&ent=Case&retURL=%2F500%2Fo';
        }else if(recordTypeName == 'Partner Program'){
            URL = '/apex/ApplicationSupportVFPage?RecordType=' + recTypeId + '&ent=Case&retURL=%2F500%2Fo';
        }/*Meenu : Story 7059159 added recordtype Channel Services Helpdesk vf page redirection*/
        else if(recordTypeName == 'Channel Services Helpdesk'){
            URL = '/apex/ChannelServicesHelpdeskVFPage?RecordType=' + recTypeId + '&ent=Case&retURL=%2F500%2Fo';
        }else { 
            return null;
        }
        pagereference page = new pagereference(URL);
        if(listacc.size() == 1){                
            contact con = new contact();
            con.id = loggedInUser.Contact.Id;
            con.Selected_Track_Account__c = listacc[0].Id;
            TriggerExecutionController.setSkipAllTriggers(true);
            update con;
            TriggerExecutionController.setSkipAllTriggers(false);
            checkAndAddAccShare(listacc[0].Id);
            page.setRedirect(TRUE);
        }        
        else if(listacc.size() == 0){
            bhaserror = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'No Sales Motions Found'));
            return null;
        }else{
            return null;
        }
        return page; 
    }
    
    public static void checkAndAddAccShare(String straccId){
        //List<AccountShare> accShareList = new List<AccountShare>();
        /* Integer intaccShareCount = [select count() from AccountShare where UserOrGroupId = : userinfo.getUserId() and AccountId = :straccId];
if (intaccShareCount == 0){
AccountShare accShare = new AccountShare();
accShare.AccountId = straccId;
accShare.UserOrGroupId = userinfo.getUserId();
accShare.AccountAccessLevel = 'Read';
accShare.OpportunityAccessLevel = 'None';
accShare.CaseAccessLevel = 'None';
insert accShare;
}   */    
        PartnerOnBoardingUtilitycntrl ut=new PartnerOnBoardingUtilitycntrl();
        
        List<AccountShare> listaccshareupdate=ut.chkandaddshare(straccId);
        if(!listaccshareupdate.isempty()){
            insert listaccshareupdate;
        }
    } 
}