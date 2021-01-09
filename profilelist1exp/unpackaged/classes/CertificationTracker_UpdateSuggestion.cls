public class CertificationTracker_UpdateSuggestion {
    
    static Map<id,Lead> suggestionLeadMap = new Map<id,Lead>();
    static Map<id,Lead> suggestionLeadMapupdated = new Map<id,Lead>();
    public static List<Lead> suggestionLeadList = new List<Lead>();
    private static Id rectype;
    private static User currentUser;
    Set<ID> Ids = new Set<ID>(); 
    public static AccountSuggestion.SuggestionResponse result;
    public static boolean isTestExecution = false;
    
    @future (callout=true)
    public static void TrackerUpdateSuggestion(List<String> leadIdList)
    {
        List<Lead> leadToSend = new List<Lead>();
        List<Lead> leadToUpdate = new List<Lead>();
        if(currentuser==null){
            getCurrentUser();
        }
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String emailbody = 'Dear '+currentuser.FirstName+' '+currentuser.Lastname+'<br/><br/> Partner Relationship for below Accounts cannot be updated. Please find the details below:<br/><br/>';
        emailbody = emailbody +'<table border="1"><th>Account Name</th><th>Account Id</th><th>Error</th><th>Partner Relation</th>'; 
        boolean hasError = false;
        leadToSend = [SELECT Account__r.Account_ID__c,Account__r.Name, Account_Category__c, Account_Owner__c, Account_Owner__r.Badge_Number__c, 
                      Account_Owner__r.FirstName, Account_Owner__r.LastName, Account_Owner__r.Title, Account_Owner__r.UserRole.name, 
                      CFI_Project_Numbers__c, Company, CompanyLocal, Date_Founded__c, DMU_Flag__c, Employee_Size__c, FIN_GEO__c, Fiscal_Year_End__c, 
                      Function_Category_Code__c, Id, LastModifiedBy.Badge_Number__c, Location_Number__c, Marketing_Class_Code__c, National_ID__c, 
                      NDA_Expiry_Date__c, NDA_Flag__c, Organization_Country__c, Organization_Country__r.Code__c, Organization_Country__r.CurrencyIsoCode, 
                      Organization_Country__r.Region__c, Organization_Country__r.User_Currency_Iso_Code__c, Other_Company_Name__c, Partner_Class__c, 
                      Partner_Request__c, Partner_Status__c, Partner_Type__c, Physical_Address_1__c, Physical_Address_2__c, Physical_City__c, 
                      Physical_Company_Name__c, Physical_Country__c, Physical_Country__r.Code__c, Physical_County__c, Physical_Fax__c, Physical_Phone__c, 
                      Physical_PostalCode__c, Physical_State__c, Physical_suburb__c, Postal_Address_1__c, Postal_Address_2__c, Postal_City__c, 
                      Postal_Company_Name__c, Postal_Country__c, Postal_Country__r.Code__c, Postal_County__c, Postal_Fax__c, Postal_Phone__c, 
                      Postal_PostalCode__c, Postal_State__c, Postal_suburb__c, Premier_Page_URL__c, Program_Type__c, Questions_Comments__c, 
                      Retail_Flag__c, Sales_Model_Code__c, Status, Std_Quote_Numbers__c, Sub_Market_Code__c, //SIC_code__c, 
                      Suggestion_id__c, Suggestion_Reason__c, Territory_Assignment__c, Territory_Assignment__r.Group_ID__c, 
                      Territory_Assignment__r.Name, Website, RecordTypeId, RecordType.Name, Secondary_Partner_Type_Optional__c    //CR2574
                      FROM Lead
                      WHERE Id IN :leadIdList];
        for(Lead leadsend :leadToSend){
            if(isTestExecution == false){
                result = AccountSuggestion.submitUpdateAccountSuggestion(leadsend);
            }
            try{
                if(result.strID == null){        
                    
                    hasError = true;
                    emailbody = emailbody+'<tr><td>'+leadsend.Account__r.Name+'</td><td>'+leadsend.Account__r.Account_ID__c+'</td><td>Invalid response. The response from the DST system could not be processed</td><td>'+leadsend.Partner_Status__c+'</td></tr>';
                    
                }          
                else if(result.strID == '0'){ 
                    //validation error        
                    String ErrorDescription = result.strErrorDescription != null? result.strErrorDescription : 'Some unknown validation error has occurred on DST side'; 
                    hasError = true;        
                    emailbody = emailbody+'<tr><td>'+leadsend.Account__r.Name+'</td><td>'+leadsend.Account__r.Account_ID__c+'</td><td>'+ErrorDescription+'</td><td>'+leadsend.Partner_Status__c+'</td></tr>';
                }
                if(result.strID != null && result.strID != ''){   
                    
                    leadsend.Suggestion_id__c =  result.strID;
                    leadsend.Status = 'Account Suggestion Submitted';
                    leadsend.RecordTypeId = IdLookupUtils.getRecordTypeId('Update Account Suggestion Locked', 'Lead',true);               
                    leadToUpdate.add(leadsend);
                    //update suggestionLead;   //updating the lead
                } 
            }catch(exception ex){}
        }
        if(hasError){
            emailbody = emailbody+'</table><br/><br/> Please Review and re-submit.<br/><br/> Partner Competency Automation<br/> Dell | Global Certified Partner Program & Channel';
            email.setSubject('DST Update Suggestion for Partner Relationship - Fail Report');
            email.setHtmlBody(emailbody);
            email.setToAddresses(new String[]{currentUser.Email});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});     
            
        }
        if(leadToUpdate.size()>0){
            update leadToUpdate;
        }
    } 
    //write a function for lead update. void static function with parameter map.
    public static Map<id,Lead> LeadUpdate(Map<id,String> accIdToStatusMap){
        Map<Id, Lead> accidToLeadMap = new Map<Id, Lead>();
        List<Lead> leadtoUpdate = new List<Lead>();
        Map<id,Account> accountRecordMap = new Map<id,Account>([Select Website, Type, Tax_Registration_Number__c, Sic, Shipping_Suburb__c, ShippingStreet, ShippingState, ShippingPostalCode,
                                                                ShippingCountry, ShippingCity, Partner_Type__c, Partner_Tier__c, Partner_Relationship__c, NumberOfEmployees, NameLocal, Name, Account_Country_Code__c,
                                                                GS_ICA_Indicator__c, Fiscal_Year_End__c, DMU__c, Billing_Suburb__c, BillingStreet, BillingState, BillingPostalCode, BillingCountry,
                                                                BillingCity From Account where id IN :accIdToStatusMap.keySet()]);
        //accountRecordMap contains data from Account query for existing Suggestion Leads
        if(accountRecordMap.size() > 0)
        {
            rectype = IdLookupUtils.getRecordTypeId('Update Account Suggestion', 'Lead',true);
            currentUser = getCurrentUser();
            suggestionLeadList = [SELECT id,Account__c, Status
                                  FROM Lead
                                  WHERE Account__c IN :accountRecordMap.keySet() AND OwnerId=:currentUser.Id AND RecordTypeId=:rectype
                                  AND (Status='Open' OR Status='Draft')
                                  ORDER BY Status DESC];
            for(Lead leadobj : suggestionLeadList){
                if(accidToLeadMap.get(leadobj.Account__c) == null){
                    accidToLeadMap.put(leadobj.Account__c,leadobj);
                }
            }
            Lead newLead;
            Account accountRecord;
            for(Id accid : accountRecordMap.keySet()){
                if(accidToLeadMap.get(accid)==null){
                    newLead = new Lead(status='Open',RecordTypeId = rectype, FirstName = currentUser.FirstName,LastName = currentUser.LastName, Email = currentUser.Email);
                    accidToLeadMap.put(accid,newLead);
                }
                else{
                    newLead = accidToLeadMap.get(accid);
                }
                
                if((newLead.Status == 'Open' || newLead.Status=='Draft') && accid!=null){
                    //country association
                    accountRecord = accountRecordMap.get(accid);
                    Set<String> countryCodeSet = new Set<String> {accountRecord.ShippingCountry,  accountRecord.BillingCountry, accountRecord.Account_Country_Code__c};
                        Map<String, String> countryCodesToGUIDmap = getCountryIds(countryCodeSet);
                    
                    //mandetory fields.
                    newLead.Account__c = accountRecord.Id;
                    newLead.Company = accountRecord.Name;
                    newLead.Account_Category__c = accountRecord.Type;
                    
                    newLead.Organization_Country__c = countryCodesToGUIDmap.get(accountRecord.Account_Country_Code__c);
                    newLead.DMU_Flag__c = accountRecord.DMU__c ;
                    
                    newLead.National_ID__c = accountRecord.Tax_Registration_Number__c;
                    newLead.Program_Type__c = accountRecord.GS_ICA_Indicator__c;
                    newLead.CompanyLocal = accountRecord.NameLocal ;
                    newLead.Employee_Size__c = accountRecord.NumberOfEmployees;
                    //populate reason    
                    newLead.Suggestion_Reason__c='Information Change';                                          
                    
                    if(accountRecord.Type == 'Partner')
                    {
                        newLead.Partner_Class__c = accountRecord.Partner_Tier__c;
                        newLead.Partner_Status__c = accIdToStatusMap.get(accountRecord.id);
                        newLead.Partner_Type__c = accountRecord.Partner_Type__c;
                        
                    }
                    suggestionLeadMap.put(newLead.Account__c,newLead);
                }
            } 
            //since either we need to create and insert / update we are using upsert function
            
            if(suggestionLeadMap.size()>0){
                upsert suggestionLeadMap.values();
            }           
        }
        return  suggestionLeadMap; 
        
    }
    //get current user Info
    public static User getCurrentUser()
    {
        currentUser =  [SELECT Id, Badge_Number__c, FirstName, LastName, Email
                        FROM User
                        WHERE Id = :UserInfo.getUserId() LIMIT 1];
        return currentUser;
    }
    public static Map<String, String> getCountryIds(Set<String> countryCodeSet){
        
        Map<String, String> countryCodesToGUIDmap = new Map<String, String>();
        for(Country__c CountryItem : [SELECT Name, Id, Dell_Online_Country_Code__c, Code__c
                                      FROM Country__c
                                      WHERE Code__c IN :countryCodeSet]){
                                          
                                          countryCodesToGUIDmap.put(CountryItem.Code__c,CountryItem.Id);
                                      }
        return countryCodesToGUIDmap;
    }
}