/*
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
1.0         13335       FY17-DCS-0902   28-July-2016     Sazleen        Story 360 Dashboard: Tile 1
2.0         13335       FY17-DCS-0902   24-Aug-2016      Krishnakumar   US 1899282 : 360 Dashboard –  Implement security on browser URL
3.0         13543       FY17-DCS-1101   28-Sept-2016     Sazleen        US 2411886 : Metrics tracking on C360 Dashboard & GAMA Links
4.0         13872       FY18-DCS-0202   03-Jan-2017      Gan            Implement for Lead
5.0         13871       FY18-DCS-0202   04-Jan-2017      Sazleen        Story 2726819:Update SF1 Adoption object Region field
6.0         16275       FY19-DCS-0902   04-Aug-2018      SinLin         Story 5415829: Lightning Critical Update Fix -  Theme
*/  

public class C360_DashboardController
{
    public String userProfile {get; set;}
    public String userBadgeNumber {get; set;} 
    public String recordId {get; set;}
    public String objectType {get; set;}
    public User currentUser;
    public String contactAffinityId {get; set;}
    public String opptyAffinityId {get; set;}
    public String accountAffinityId {get;set;}
    //4.0
    public String strLeadAffinityId {get;set;}
    public String endpointUrl {get; set;}
    public String AuthorizationKey {get; set;}    
    public String dashboardLink {get; set;}
    public Boolean recordAccess {get;set;}
    //Metric tracking
    public String conAccountRegion {get; set;}
    public String accountRegion {get; set;}
    public String oppAccountRegion {get; set;}
    //4.0
    public String strLeadAccountRegion {get; set;}
    public String sPlatform {get; set;}
    
    public C360_DashboardController(){
        populate();
        //countClick();  method called from VFpage action
        generateLink();
    }
    
    public void populate(){
        recordId=ApexPages.currentPage().getParameters().get('id');
        objectType=ApexPages.currentPage().getParameters().get('obj');
        getRecordAccess(recordId);
        getCurrentUser();  
        getContactAccount();
        getOpptyAccountAffinity();
        getAffinityAccount();
        //4.0
        getLeadAffinityAccount();
       
    }
    
//3.0    
    public void countClick(){
     
        try{
        SF1_Adoption__c obj1 = new SF1_Adoption__c();
        obj1.Object_Name__c = objectType;
        obj1.Record_ID__c = recordId;
        obj1.Source__c = 'C360_Dashboard';
        obj1.User_Action__c = '';
        obj1.User_Edited_Date__c = Datetime.now();
        obj1.User_Name__c = UserInfo.getUserId();
        
        if(obj1.Object_Name__c == 'Opportunity'){
            obj1.Region__c =  oppAccountRegion;}             
        else if (obj1.Object_Name__c == 'Contact') {
            obj1.Region__c =  conAccountRegion;}            
        else if (obj1.Object_Name__c == 'Account') {                
            obj1.Region__c =  accountRegion;}  
        //4.0
        else if (obj1.Object_Name__c == 'Lead') {                
            obj1.Region__c =  strLeadAccountRegion;
        } 
        //end if
        
        System.debug('Debug getUiTheme===='+userinfo.getUiTheme());   
          
        //checking salesforce platform
        
         sPlatform = userinfo.getUiTheme();
            if (sPlatform == 'Theme1' || sPlatform == 'Theme2' || sPlatform == 'Theme3'){
                obj1.Platform__c = 'Salesforce Classic';}
              else if (sPlatform == 'Theme4d' || sPlatform == 'Theme4u'){
                obj1.Platform__c = 'Salesforce Lightning';}
                else if (sPlatform == 'Theme4t'){
                    obj1.Platform__c = 'Salesforce1 Mobile';}
                            
            
        system.debug('Debug obj1============'+obj1);
        insert obj1;
        //system.debug('Debug after insert success======');    
        }catch(DmlException e){System.debug('DEBUG ERROR####'+e.getMessage());}
    }
    
    
    //2.0
    public void getRecordAccess(String recordId){
        String userId = UserInfo.getUserId();
        recordAccess = true;
        UserRecordAccess usrAccess = [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId = :userId and RecordId = :recordId];
        if(usrAccess !=null){
            recordAccess = usrAccess.HasReadAccess;
        }
        if(recordAccess == false || usrAccess == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Access Privilege Error: You don\'t have access to this account.'));
        }
    }
    
    public void getCurrentUser(){
      currentUser =  [SELECT u.Profile.Name, Badge_Number__c FROM User u 
              WHERE u.Id = :UserInfo.getUserId() LIMIT 1];
              
      userBadgeNumber = currentUser.Badge_Number__c;
      userProfile = currentUser.Profile.Name;
    }
    
    public void getOpptyAccountAffinity(){
        if(recordId !=null && objectType == 'Opportunity'){
            Opportunity opptyObj = [SELECT Account.Account_ID__c, Account.Regional_Parent_Name_lookup__c FROM Opportunity WHERE id = :recordId];
            if(opptyObj != null){
                opptyAffinityId = opptyObj.Account.Account_ID__c;  
                oppAccountRegion = opptyObj.Account.Regional_Parent_Name_lookup__c;
                System.Debug('Debug Regional_Parent_Name__c-------'+accountRegion);
            }
        }
    }
    
    public void getContactAccount(){
        if(recordId !=null && objectType == 'Contact'){
            Contact ctcObj = [SELECT Account.Account_ID__c,Account.Regional_Parent_Name_lookup__c FROM Contact WHERE id = :recordId];
            if(ctcObj != null){
                contactAffinityId = ctcObj.Account.Account_ID__c;
                conAccountRegion = ctcObj.Account.Regional_Parent_Name_lookup__c;
                System.Debug('Debug Regional_Parent_Name__c-------'+accountRegion);
            }
        }
    }
    
    public void getAffinityAccount(){
        if(recordId !=null && objectType == 'Account'){
            Account AcntObj = [SELECT Account_ID__c, Regional_Parent_Name_lookup__c FROM Account WHERE id = :recordId];
            if(AcntObj != null){
                accountAffinityId = AcntObj.Account_ID__c;
                accountRegion = AcntObj.Regional_Parent_Name_lookup__c;
                System.Debug('Debug accountAffinityId-------'+accountAffinityId);
                System.Debug('Debug Regional_Parent_Name__c-------'+accountRegion);
            }
        }
    }
    
    //4.0
    public void getLeadAffinityAccount(){
        if(recordId !=null && objectType == 'Lead'){
            Lead objLead = [SELECT Account__r.Account_ID__c,Account__r.Regional_Parent_Name_lookup__c FROM Lead WHERE id = :recordId];
            if(objLead != null){
                strLeadAffinityId = objLead.Account__r.Account_ID__c;
                strLeadAccountRegion = objLead.Account__r.Regional_Parent_Name_lookup__c;
                System.Debug('Debug Regional_Parent_Name__c-------'+strLeadAccountRegion);
            }
        }
    }
    
    public void generateLink(){
        
        if(Environment.isProduction()) { 
            endpointUrl = System.Label.C360_Prod_URL;
            AuthorizationKey = System.Label.C360_Prod_Authorization;
         // Set header parameters for Sandbox 
         } else{
             endpointUrl = System.Label.C360_Sandbox_URL;
             AuthorizationKey = System.Label.C360_Sandbox_Authorization;
         }          
        
        String preURL = endpointUrl + 'UserName='+UserInfo.getUserName()+'&UserEmail='+UserInfo.getUserEmail()+'&UserRoleName='+UserProfile+'&UserId='+userBadgeNumber+'&source_name=Affinity'+AuthorizationKey;
        //old BasicO7Y%2BHoM1xdsJiURJb1VBR%2BOwQDw6h2dfkcd7ntP13Pff0vr4C03vtbkDab9p1qm1        
        system.debug('------------ ----preURL--->' + preURL);
                        
        if(objectType == 'Opportunity'){
            if(ApexPages.currentPage().getParameters().get('t') == '1'){                
                dashboardLink = preURL + '&source_key='+opptyAffinityId;
                system.debug('dashboardLink ----fullURL--->' + dashboardLink);
            }
        } 
        
        if(objectType == 'Contact'){
            if(ApexPages.currentPage().getParameters().get('t') == '1'){
                dashboardLink = preURL + '&source_key='+contactAffinityId;
                system.debug('dashboardLink ----fullURL--->' + dashboardLink);
            }           
        }
        
        if(objectType == 'Account'){
            if(ApexPages.currentPage().getParameters().get('t') == '1'){
                dashboardLink = preURL + '&source_key='+accountAffinityId;
                system.debug('dashboardLink ----fullURL--->' + dashboardLink);
            }
        } 
        
        //4.0
        if(objectType == 'Lead'){
            if(ApexPages.currentPage().getParameters().get('t') == '1'){                
                dashboardLink = preURL + '&source_key='+strLeadAffinityId;
                system.debug('dashboardLink ----fullURL--->' + dashboardLink);
            }
        } 
    }
}