public without sharing class ViewMyCompanyDetailsCtrl {

    public Partner_Track__c ptCompany {get;set;}
    public Service_Information__c siCompany {get;set;}
    public Id loggedInAccId{get;set;}
    public Partner_Request__c request {get;set;}
    public Account accCompany {get;set;}    
    public User loggedInUser{get;set;} 
     
    public String strptTierNames {get;set;}
    public String strmore {get;set;}
    public String strsponsoringDistributor {get;set;}    
    List<String> listeligibleTracksIdList {get;set;}
    
    public Boolean bisDataChanged {get;set;}
    public Boolean bisPortalUser {get;set;} 
    public Boolean bisEditMode {get;set;}
    public Boolean bisAdmin {get;set;} 
    
    public ViewMyCompanyDetailsCtrl(ApexPages.StandardController controller) {      
        System.assert(controller.getRecord() instanceof Partner_Request__c, 'Invalid type returned by ApexPages.StandardController.getRecord()');
        bisDataChanged = false;
        bisPortalUser = false;
        this.request = initialize((Partner_Request__c) controller.getRecord());
    }
    
    private Partner_Request__c initialize(Partner_Request__c req) {
        
    loggedInUser = getCurrentUserDetails(UserInfo.getUserId());     // Used to get the logged in user details
    loggedInAccId = [Select Id,ContactId,Contact.AccountId from User where Id = :UserInfo.getUserId()].Contact.AccountId;
     
    if(loggedInUser.UserRole == null 
            || StringUtils.isBlank(loggedInUser.UserRole.Name)
            || loggedInUser.Contact == null
            || loggedInUser.Contact.Id == null
            || loggedInUser.Contact.AccountId == null) {
            // Basically this is a standard user license user
            PageUtils.addError('Navigation error.  Screen is for Partners only.');
            bisPortalUser = false;
            return request;
        } 
        
        
        // Make sure the user is a partner admin and providing with Edit access 
        if(loggedInUser.Enable_Partner_Admin__c == true || loggedInUser.Enable_as_Partner_Group_Administrator__c == true) {
              bisAdmin = true;
           }else{
               bisAdmin = false;
           }
        
        companyDataOnLoad(request);
        return this.request;
        
    }
    
    private User getCurrentUserDetails(String struserId) {
        final list<User> lstUsers = [select Id, Enable_Partner_Admin__c,Enable_as_Partner_Group_Administrator__c,ContactId, Contact.AccountId, Contact.Account.Id, Contact.Account.Name, 
                                            contact.Selected_Track__c,contact.EligibleTracks__c,Contact.Account.Account_Country_Code__c, UserRole.Name
                                            from User where Id = :struserId];  //Id = :struserId  // Id ='0055C000000mnnO'==> Pavan Kumar  
                
        System.assert(!lstUsers.isEmpty(), 'User(id=\'' + struserId + '\') not found');
        
        return lstUsers.get(0);
    }
    
    public void companyDataOnLoad(Partner_Request__c req){  
         ptCompany = new Partner_Track__c();
         siCompany = new Service_Information__c();
         request = new Partner_Request__c();
         List<Partner_Track__c> listptList = new List<Partner_Track__c>();
             
        listptList =  [Select Id,Partner_Track_Account_Local_Name__c,MyRewards_Company_Status__c,Countries_doing_business_in__c,Sponsoring_Distributor_OEM__c, Sponsoring_Distributor_Solution_Provid__c,Services_Competencies__c,
                    Purchase_Path__c,Dell_Certification_Areas__c,Product_Focus__c,Preferred_Distributor__c,Speciality_Product_Purchase_Path__c,Partner_Registration_Number__c,
                    Diverse_Owned_Business__c,Diversity_Certification__c,Diversity_Certification_Other__c,Primary_Sales_Motion_Affinity_ID__c,Master_Group_Id__r.Number_of_Branches_Subsidiaries__c,
                    Primary_SMAffinity_Account__r.Id,Primary_SMAffinity_Account__r.Name ,Primary_SMAffinity_Account__r.Does_Business_As__c , Primary_SMAffinity_Account__r.Phone , Primary_SMAffinity_Account__r.BillingStreet ,
                    Primary_SMAffinity_Account__r.BillingCity ,Primary_SMAffinity_Account__r.BillingState ,Primary_SMAffinity_Account__r.BillingPostalCode ,Primary_SMAffinity_Account__r.BillingCountry ,
                    Primary_SMAffinity_Account__r.Form_of_Organization__c ,Primary_SMAffinity_Account__r.Website ,Primary_SMAffinity_Account__r.Reseller_Tax_ID__c ,Primary_SMAffinity_Account__r.Capability__c ,
                    Primary_SMAffinity_Account__r.D_U_N_S__c ,Primary_SMAffinity_Account__r.Number_of_years_in_business__c ,Primary_SMAffinity_Account__r.Principle_Name1__c ,
                    Primary_SMAffinity_Account__r.Principle_Title1__c , Master_Group_Id__r.Primary_Contact__c,Primary_SMAffinity_Account__r.Primary_Contact_formula__c,
                    Track_Id__r.Id,Track_Id__r.Partner_Program_Track__c,Partner_Program_Tier__c,
                    (Select Id,Services_Performance_Deploy__c,Services_Performance_Support__c From Service_Information__r limit 1)
                    From Partner_Track__c where Id=:loggedInUser.contact.Selected_Track__c limit 1];
              
      system.debug('List Size: ' + listptList.size());
       
        try {
        if(listptList.size()>0){
            ptCompany = listptList.get(0);
            accCompany = ptCompany.Primary_SMAffinity_Account__r;
            
             for(Service_Information__c si : ptCompany.Service_Information__r){
                    siCompany = si;
                }
              
            // Set Record Type :       // REQUEST_RECORD_TYPE_UPDATE_PARTNER = 'Update Partner';
        request.RecordTypeId = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_UPDATE_PARTNER, 'Partner_Request__c', true);
           
        System.assert(request.RecordTypeId != null, 'Record type \'' + PartnerConstants.REQUEST_RECORD_TYPE_UPDATE_PARTNER + '\' not found.');
                    
            // Populate request from Account data
            request.Status__c = PartnerConstants.REG_STATUS_COMPLETE;             // REG_STATUS_COMPLETE = 'Complete';
            
            request.Account__c = accCompany.Id;
            request.Company__c = accCompany.Name;
            request.Does_Business_As__c = accCompany.Does_Business_As__c;
            request.Org_Phone__c = accCompany.Phone;
            request.Form_of_Organization__c = accCompany.Form_of_Organization__c;
            request.Number_of_years_in_business__c = accCompany.Number_of_years_in_business__c;
            request.Principle_Name__c = accCompany.Principle_Name1__c;
            request.Principle_Title__c = accCompany.Principle_Title1__c;
            //request.Primary_Contact__c = accCompany.Primary_Contact_formula__c;
             request.Primary_Contact__c = ptCompany.Master_Group_Id__r.Primary_Contact__c;            
            request.Website__c = accCompany.Website;            
            request.Capability__c = accCompany.Capability__c;
            
            // Populate request from Partner Track data
            request.Product_Focus__c = ptCompany.Product_Focus__c;        
            request.Partner_Track_Account_Local_Name__c = ptCompany.Partner_Track_Account_Local_Name__c;
            request.States_Provinces_doing_business__c =  ptCompany.Countries_doing_business_in__c;
            //request.Countries_doing_business_in__c = ptCompany.Countries_doing_business_in__c;
            request.Diverse_Owned_Business__c = ptCompany.Diverse_Owned_Business__c;
            request.Diversity_Certification__c = ptCompany.Diversity_Certification__c;
            request.Other_diversity_certification__c = ptCompany.Diversity_Certification_Other__c;
                       
            // Populate request from Service Information data            
            request.Services_Performance_Deploy__c = siCompany.Services_Performance_Deploy__c;
            request.Services_Performance_Support__c = siCompany.Services_Performance_Support__c;
              
            // Checking whether the Track is OEM r Solution Provider
                if(ptCompany.Track_Id__r.Partner_Program_Track__c == 'OEM'){
                    strsponsoringDistributor = (String) ptCompany.Sponsoring_Distributor_OEM__c;
                }else 
                if(ptCompany.Track_Id__r.Partner_Program_Track__c == 'Solution Provider'){
                    strsponsoringDistributor = (String) ptCompany.Sponsoring_Distributor_Solution_Provid__c;
                }
                
                listeligibleTracksIdList =  new List<String>();
                
                if(loggedInUser.contact.EligibleTracks__c != null){
                    List<String> listeligibleTracksId = loggedInUser.contact.EligibleTracks__c.split(';');                
                    //system.debug('listeligibleTracksId '+listeligibleTracksId);
                    for(String stregTrackId: listeligibleTracksId){
                        listeligibleTracksIdList.add(stregTrackId); 
                    } 
                }
                // Get concern fields based on eligible tracks
                List<Partner_Track__c> listptNames = [Select Id,Track_Id__r.Partner_Program_Track__c,Track_Name__c,Partner_Program_Tier__c from Partner_Track__c where Id in :listeligibleTracksIdList];
                strptTierNames ='';
                strmore = '';
            Integer intcount = 0;
            
                if(listptNames.size()>0){
                    for(Partner_Track__c pt : listptNames){
                        if(intcount < 5){
                            if((pt.Track_Name__c != null && pt.Track_Name__c != '') && (pt.Partner_Program_Tier__c != null && pt.Partner_Program_Tier__c != '')){
                               strptTierNames += pt.Track_Name__c + '-' + pt.Partner_Program_Tier__c + ';';
                                intcount++;
                            }
                            else if((pt.Track_Name__c != null && pt.Track_Name__c != '') && (pt.Partner_Program_Tier__c == null || pt.Partner_Program_Tier__c == '')){
                                strptTierNames += pt.Track_Name__c + ';';
                                intcount++;
                            }
                            else if((pt.Track_Id__r.Partner_Program_Track__c == null || pt.Track_Id__r.Partner_Program_Track__c == '') && (pt.Partner_Program_Tier__c != null && pt.Partner_Program_Tier__c != '')){
                                 strptTierNames += pt.Partner_Program_Tier__c + ';';
                                intcount++;
                            } 
                        }else {
                            if((pt.Track_Name__c != null && pt.Track_Name__c != '') && (pt.Partner_Program_Tier__c != null && pt.Partner_Program_Tier__c != '')){
                                strmore += pt.Track_Name__c + '-' + pt.Partner_Program_Tier__c + ';'+'<br/>';
                                intcount++;
                            }
                            else if((pt.Track_Name__c != null && pt.Track_Name__c != '') && (pt.Partner_Program_Tier__c == null || pt.Partner_Program_Tier__c == '')){
                                strmore += pt.Track_Name__c + ';'+'<br/>';
                                intcount++;
                            }
                            else if((pt.Track_Name__c == null || pt.Track_Name__c == '') && (pt.Partner_Program_Tier__c != null && pt.Partner_Program_Tier__c != '')){
                                strmore += pt.Partner_Program_Tier__c + ';'+'<br/>';
                                intcount++;
                            } 
                            
                        }
                    }
                    if(strptTierNames != null && strmore == ''){
                        strptTierNames = strptTierNames.removeEnd(';');
                        
                    }
                    if(strmore != null && strmore != ''){
                        strmore = strmore.removeEnd(';<br/>');
                        
                    }
                }
         }
        }
        catch(Exception ex){}
    
       // return request;
        
    }
        
    public PageReference doEditJob(){
        bisEditMode = true; 
        return null;
    }
    
    public PageReference doSaveJob(){
        
        Savepoint sp = Database.setSavepoint(); 
        try {
            
            if (accCompany.Phone != request.Org_Phone__c){
                accCompany.Phone = request.Org_Phone__c;
                bisDataChanged = true;
            }
            
            if(request.Capability__c != accCompany.Capability__c){
                accCompany.Capability__c = request.Capability__c;
                bisDataChanged = true;
            }
            
            if(request.Product_Focus__c != ptCompany.Product_Focus__c){
                ptCompany.Product_Focus__c = request.Product_Focus__c;
                bisDataChanged = true;
            }
            
            if(request.Partner_Track_Account_Local_Name__c != ptCompany.Partner_Track_Account_Local_Name__c){
                ptCompany.Partner_Track_Account_Local_Name__c = request.Partner_Track_Account_Local_Name__c;
                bisDataChanged = true;
            }
            
            if(request.States_Provinces_doing_business__c != ptCompany.Countries_doing_business_in__c){
                ptCompany.Countries_doing_business_in__c = request.States_Provinces_doing_business__c;
                bisDataChanged = true;
            }
            
            if(request.Diverse_Owned_Business__c != ptCompany.Diverse_Owned_Business__c){
                ptCompany.Diverse_Owned_Business__c = request.Diverse_Owned_Business__c;
                bisDataChanged = true;
            }
            
           if(request.Diversity_Certification__c != ptCompany.Diversity_Certification__c){
                ptCompany.Diversity_Certification__c = request.Diversity_Certification__c;
                bisDataChanged = true;
            }

           if(request.Other_diversity_certification__c != ptCompany.Diversity_Certification_Other__c){
                ptCompany.Diversity_Certification_Other__c = request.Other_diversity_certification__c;
                bisDataChanged = true;
            }
                        
            if(request.Form_of_Organization__c != accCompany.Form_of_Organization__c){
                accCompany.Form_of_Organization__c = request.Form_of_Organization__c;
                bisDataChanged = true;
            }
            
            if(request.Number_of_years_in_business__c != accCompany.Number_of_years_in_business__c){
                accCompany.Number_of_years_in_business__c = request.Number_of_years_in_business__c;
                bisDataChanged = true;
            }
            
           if(request.Principle_Name__c != accCompany.Principle_Name1__c){
                accCompany.Principle_Name1__c = request.Principle_Name__c;
                bisDataChanged = true;
            }
            
            if(request.Principle_Title__c != accCompany.Principle_Title1__c){
                accCompany.Principle_Title1__c = request.Principle_Title__c;
                bisDataChanged = true;
            } 
            
            if(bisDataChanged) {
                if(request.Id == null) {                    
                    insert request; 
                    system.debug('In Save(Insert)  request.Id ==> '+ request.Id);
                } 
                else { 
                    update request; 
                    system.debug('In Save(Update)  request.Id ==> '+ request.Id);
                }
                
                if (ptCompany != null && accCompany != null){
                    update ptCompany;
                    TriggerExecutionController.setSkipAccountTriggers(true);
                    update accCompany;
                }  
                
                bisEditMode = false;
                bisDataChanged = false;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,Label.The_changes_have_been_successfully_updated));
                
            }
            else{
                bisEditMode = false;
                bisDataChanged = false;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,Label.No_changes_were_made));
            }           
            
        }
        catch(Exception e) {             
            bisDataChanged = false;
            if(request.Id != null) { 
                request.Status__c = PartnerConstants.REG_STATUS_INCOMPLETE;
                update request;
            }
            Database.rollback(sp); 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.Company_ErrorMsg));
            return null;
        }        
        return null;
    }
    
    public PageReference doCancelJob(){
        bisEditMode = false;
        request = initialize(request);
        return null;
    }
        
}