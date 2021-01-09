/*--------------------------------------------------
Description: Helper Class  for sending Account Suggestion to DST
CR #1378
Version:1.0 

History:
1.0 - 17-July-2009: Creation
2.0 - 27-July-2010: REL11.7-CR2574-
Author: Krishna
3.0 Anu
4.0 Devika - 29/04/2016  - To add errors for phone/fax formats.
5.0 uday   - 02/08/17  - new fields referred in SOQL as Story 3676977 
6.0 Prasanthi M - 07/01/2019 - Modified the code in Create Account sugestion section.(Affinity response format was changed from XML to JSON)
---------------------------------------------------*/

public class VFCntrlr_SendDSTSuggestionCtrlExt {
    
    public static String CONFIRM_SUGGESTION {get{return 'CONFIRM_SUGGESTION';}} //Ask for confirmation before sending the suggestion
    public static String SENDING_SUGGESTION {get{return 'SENDING_SUGGESTION';}} //Started sending the suggestion
    public static String VALIDATION_ERROR   {get{return 'VALIDATION_ERROR';}}   //Validation Error occurred
    public static String EXCEPTION_OCCURRED {get{return 'EXCEPTION_OCCURRED';}} //Exception occurred
    public static String DUPLICATE_EXISTS   {get{return 'DUPLICATE_EXISTS';}}   //Duplicate exists and ask for reconfirmation
    public static String PROCESS_COMPLETE   {get{return 'PROCESS_COMPLETE';}}   //Process completed successfully.
    
    public static String UPDATE_SUGGESTION = 'UPDATE_SUGGESTION';   //process type- update.
    public static String CREATE_SUGGESTION = 'CREATE_SUGGESTION';   //process type- Create.
    
    //Define class variables
    private Lead leadRecord;
    private string strLeadId;
    public String strSuggestionType;
    public boolean bisUpdateSuggestion;
    
    public boolean bError {get;set;}    
    public string strStatus{get;set;}    
    
    public AccountSuggestion.SuggestionResponse result{get;set;}    
    public String strErrorDescription{get;set;}
    public String strOracleError{get;set;}
    public String strDuplicationMessage {get;set;} 
    
    public boolean bisTestExecution = false;
    
    public String straccountResponse{get;set;} //v3.0
    public Integer intSuggestionID{get;set;} 
    public String strucidCreationRequestID{get;set;}
    public AccountSuggestionResponse updateAccountResponse{get;set;}
    public static string OWNER_VALIDATION ='Suggestion submitter RRID/BadgeNumber is Invalid';
    public static string LEGACY_VALIDATION ='Legacy Id is already associated with different account';
    public static string REGION_VALIDATION ='You cannot create suggestion that belong to a different region';
    public VFCntrlr_SendDSTSuggestionCtrlExt(ApexPages.StandardController controller){
        
        //this.strLeadId = PageUtils.param('id');
        leadRecord = (Lead)controller.getRecord();  
        
        List<Lead> listLeadRecord = [SELECT Account__r.Account_ID__c, Account_Category__c, Account_Owner__c, Account_Owner__r.Badge_Number__c, 
                                     Account_Owner__r.FirstName, Account_Owner__r.LastName, Account_Owner__r.Title, Account_Owner__r.UserRole.name, 
                                     CFI_Project_Numbers__c, Company, CompanyLocal, Date_Founded__c, DMU_Flag__c, Employee_Size__c, FIN_GEO__c, Fiscal_Year_End__c, 
                                     Function_Category_Code__c, Id, LastModifiedBy.Badge_Number__c, Location_Number__c, Marketing_Class_Code__c, National_ID__c, 
                                     NDA_Expiry_Date__c, NDA_Flag__c, Organization_Country__c, Organization_Country__r.Code__c, Organization_Country__r.CurrencyIsoCode, 
                                     Organization_Country__r.Region__c, Organization_Country__r.User_Currency_Iso_Code__c, Other_Company_Name__c, Partner_Class__c, 
                                     Partner_Request__c, Partner_Status__c, Partner_Type__c, Physical_Address_1__c, Physical_Address_2__c, Physical_City__c, 
                                     Physical_Company_Name__c, Physical_Country__c, Physical_Country__r.Code__c,Physical_Country__r.Name, Physical_County__c, Physical_Fax__c, Physical_Phone__c, 
                                     Physical_PostalCode__c, Physical_State__c, Physical_suburb__c, Postal_Address_1__c, Postal_Address_2__c, Postal_City__c, 
                                     Postal_Company_Name__c, Postal_Country__c,Postal_Country__r.Name, Postal_Country__r.Code__c, Postal_County__c, Postal_Fax__c, Postal_Phone__c, 
                                     Postal_PostalCode__c, Postal_State__c, Postal_suburb__c, Premier_Page_URL__c, Program_Type__c, Questions_Comments__c, 
                                     Retail_Flag__c, Sales_Model_Code__c, Status, Std_Quote_Numbers__c, Sub_Market_Code__c, //SIC_code__c, 
                                     Suggestion_id__c, Suggestion_Reason__c, Territory_Assignment__c, Territory_Assignment__r.Group_ID__c, 
                                     Territory_Assignment__r.Name,Territory_Assignment__r.Region_Desc__c, Website, RecordTypeId, RecordType.Name, Secondary_Partner_Type_Optional__c,    //CR2574
                                     ownerId,NumberOfEmployees,Contact__c,Contact__r.Name,FirstName,LastName,Name,Lead_Type__c,Reason__c,
                                     Related_Contact__c,Related_Contact__r.Phone,Related_Contact__r.Email,Related_Contact__r.MobilePhone,
                                     PostalCode,Country,City,State,Street,Campaign__r.Region__c,Email,MobilePhone,Phone,
                                     RTM__c,Segmentation__c,Universal_Customer_ID_UCID__c,
                                     Sales_Relationship_Local_Company_Name__c,Sales_Relationship_Local_Address_1__c,Sales_Relationship_Local_Address_2__c,Sales_Relationship_Local_Country__c,Sales_Relationship_Local_City__c,Sales_Relationship_Local_State__c,Sales_Relationship_Local_Code__c,Sales_Relationship_Local_Phone__c,Sales_Relationship_Local_Fax__c,
                                     Legal_Local_Company_Name__c,Legal_Local_Address_1__c,Legal_Local_Address_2__c,Legal_Local_Country__c,Legal_Local_City__c,Legal_Local_Postal_State__c,Legal_Local_Postal_Code__c,Legal_Local_Postal_Phone__c,
                                     Master_Group_ID__c,Master_Group_Affinity_ID__c,Mg_Name__c,Mg_Local_Name__c,Partner_Master_Grouping_id__c,Number_of_Branches_Subsidiaries__c,GU_Duns_number__c,Mg_Website__c,Mg_Address_Line_1__c,Mg_Address_Line_2__c,Mg_City__c,Mg_Country_Code__c,Mg_Postal_Code__c,Mg_State__c,
                                     Track_Affinity_ID__c,Partner_Track_Affinity_ID__c,Disable_Rounding__c,Distribution_All_Country_Price__c,Distribution_Incumbent_Partner__c,
                                     Enabled_for_Services__c,PPA_UCID__c,Partner_Program_Tier__c,Purchase_Path__c,Partner_Storage_Purchasing_Path__c,Primary_Sales_Motion_Affinity_ID__c,
                                     Relationship_Type__c, Distributor_Authorized_Countries__c,Reporting_Segmentation__c,SPL_Distribution_Pricing__c,SPL_Partner_Recommend_Pricing__c,
                                     VCE_Approved_Partner__c,Partner_Track__c,Partner_Track_Account_Local_Name__c,Partner_Grouping_id__c,Multi_Track_Parent_ID__c,MUP_Company_Profile_ID__c,Partner_Track_Id__c,
                                     Selling_Motion__c,Account_Classification__c,Partner_Quoting_Account__c,Partner_Quoting_Account_Name__c,Partner_Quoting_Account_SAP_UCID__c,Quoting_Auto_book_Enabled__c,Quoting_EPOA_Flag__c,
                                     Quoting_FOB_Incoterms__c,Quoting_Freight_Terms__c,Quoting_Payment_Terms__c,Partner_Program_Track__c,Country_Code__c,CaseRTMigrate__SICCode__c,SM_country_code__c,
                                     Partner_Request__r.name,Track_Country_Code__c,Zone__c,Partner_Profiled_Account_Flag__c,Legacy_Partner_Program_Ts_Cs_Date__c,Mg_Local_Address_Line_1__c,Mg_Local_Address_Line_2__c,
                                     Mg_Local_City__c,Mg_Local_Postal_Code__c,Mg_Local_State__c
                                     FROM Lead
                                     WHERE Id =:leadRecord.Id LIMIT 1];
        //WHERE Id =:strLeadId ];
        
        
        if (listLeadRecord.isEmpty()){
            showError('Could not find a valid Lead Record');
            return;
        }
        leadRecord = listLeadRecord[0];
        if(leadRecord.Status != 'Draft'){
            showError('For sending the Account Suggestion the lead should be in "Draft" status');
            return;
        }
        if(leadRecord.Postal_Phone__c != null && leadRecord.Postal_Phone__c != ''){
            List<String> listPhone = leadRecord.Postal_Phone__c.split('-');
            if(listPhone.isEmpty() || listPhone.size() < 3){
                showError('Postal Phone  : Correct Phone/Fax Number format in Physical/Postal address is,(a)CountryCode-AreaCode-PhoneNumber-Extension(b)CountryCode<=4, AreaCode<=6, PhoneNumber<=10, Extension<=8 (c)Only decimal 0-9 and "-" is allowed("space","+",other symbols are not allowed)');
                return;
            }
        }else if(leadRecord.Postal_Fax__c != null && leadRecord.Postal_Fax__c != ''){
            List<String> listPhone = leadRecord.Postal_Fax__c.split('-');
            if(listPhone.isEmpty() || listPhone.size() < 3){
                showError('Postal Fax : Correct Phone/Fax Number format in Physical/Postal address is,(a)CountryCode-AreaCode-PhoneNumber-Extension(b)CountryCode<=4, AreaCode<=6, PhoneNumber<=10, Extension<=8 (c)Only decimal 0-9 and "-" is allowed("space","+",other symbols are not allowed)');
                return;
            }
        }else if(leadRecord.Physical_Phone__c != null && leadRecord.Physical_Phone__c != ''){
            List<String> listPhone = leadRecord.Physical_Phone__c.split('-');
            if(listPhone.isEmpty() || listPhone.size() < 3){
                showError('Physical Phone  : Correct Phone/Fax Number format in Physical/Postal address is,(a)CountryCode-AreaCode-PhoneNumber-Extension(b)CountryCode<=4, AreaCode<=6, PhoneNumber<=10, Extension<=8 (c)Only decimal 0-9 and "-" is allowed("space","+",other symbols are not allowed)');
                return;
            }
        }else if(leadRecord.Physical_Fax__c != null && leadRecord.Physical_Fax__c!= ''){
            List<String> listPhone = leadRecord.Physical_Fax__c.split('-');
            if(listPhone.isEmpty() || listPhone.size() < 3){
                showError('Physical Fax : Correct Phone/Fax Number format in Physical/Postal address is,(a)CountryCode-AreaCode-PhoneNumber-Extension(b)CountryCode<=4, AreaCode<=6, PhoneNumber<=10, Extension<=8 (c)Only decimal 0-9 and "-" is allowed("space","+",other symbols are not allowed)');
                return;
            }
        } 
        bisUpdateSuggestion = false;
        if(leadRecord.RecordType.Name == 'Update Account Suggestion'){
            bisUpdateSuggestion = true;
            strSuggestionType = UPDATE_SUGGESTION;         
        }
        
        bError = false;      
        strStatus = CONFIRM_SUGGESTION;  
        strucidCreationRequestID = '';
    }//end of controller
    
    //Method to add error to Page
    private void showError (String strerrorMessage){
        PageUtils.addError(strerrorMessage);
        strStatus = EXCEPTION_OCCURRED;
        bError = True;   
    }
    
    //Method to send Suggestion to DST and process Response
    public PageReference sendSuggestion(boolean bisDupCheckRequired){
        
        strStatus = SENDING_SUGGESTION;                
        try{
            //calling web service callout method.
            if(!bisTestExecution){
                //if(bisUpdateSuggestion)
                
                
                if(strSuggestionType == UPDATE_SUGGESTION){                
                    //update Account suggestion
                    
                    //mohammad- commented if else as going forward CIL layer will only be used
                    /*if(System.Label.AccountSuggestionIntegration == 'CIL'){

}
else{
result= AccountSuggestion.submitUpdateAccountSuggestion(leadRecord);
}*/
                    updateAccountResponse = AccountSuggestionIntegrationCIL.sendAccountSuggestionToUpdateAccount(leadRecord);
                }
                else{
                    AccountSuggestionIntegrationCIL.bisOnBoarding = true;
                    straccountResponse = AccountSuggestionIntegrationCIL.sendAccountSuggestionToAffinty(leadRecord, bisDupCheckRequired);
                    
                }               
            }
            
            if(result!= null){
                if(result.strID == null){
                    showError('Invalid response. The response from the DST system could not be processed');             
                    return null;
                }       
                else if(result.strID == '0'){      //validation error
                    strStatus = VALIDATION_ERROR;
                    
                    strErrorDescription = result.strErrorDescription != null? result.strErrorDescription : 'Some unknown validation error has occurred on DST side';
                    strOracleError = result.strOracleError != null? '[' + result.strOracleError + ']' : '';          
                    return null;                                
                }
                if(strSuggestionType == UPDATE_SUGGESTION){
                    //if update
                    if(result.strID != null 
                       && result.strID != ''){   
                           
                           leadRecord.Suggestion_id__c =  result.strID;
                           leadRecord.Status = 'Account Suggestion Submitted';
                           leadRecord.RecordTypeId = IdLookupUtils.getRecordTypeId('Update Account Suggestion Locked', 'Lead',true);               
                           
                           update leadRecord;   //updating the lead                                
                           strStatus = PROCESS_COMPLETE;      
                           return null;
                       }               
                    
                }
                /* [Krishna 05-Mar-2010]Added checking for '1010' as per the CR#2414 R11.2*/
                else if(result.strID == '1008'|| result.strID == '1010'){ //if creation and duplicate Account suggestion              
                    strStatus = DUPLICATE_EXISTS;
                    strDuplicationMessage = StringUtils.defaultString(result.strErrorDescription)!=''? result.strErrorDescription: 'The Account with the same name exists in Affinity';
                    return null;            
                }
                
                
                else if(result.strID != null && result.strID != ''){      
                    
                    leadRecord.Suggestion_id__c=  result.strID;
                    lockTheLeadWithStatus('Account Suggestion Submitted');
                    
                    
                    update leadRecord;   //updating the lead
                    if(leadRecord.Partner_Request__c!=null){
                        Partner_Request__c partnerTobeUpdated = new Partner_Request__c(id = leadRecord.Partner_Request__c,    Status__c ='Account Suggestion Submitted',   Send_Account_Suggestion_Is_Complete_Flag__c = true);
                        update partnerTobeUpdated;  //updating the partner request
                    }               
                    strStatus = PROCESS_COMPLETE;  return null;    
                    
                }
            }
            /* Update v3.0 if Error and validations from Affinity */
            String strerrMessage='';
            if(straccountResponse!=null && straccountResponse != 'Internal Server Error'){
                system.debug('Before deserialize Account response'+straccountResponse);
                Map<String,Object> mapRes=(Map<String,Object>)JSON.deserializeUnTyped(straccountResponse);
                system.debug('After deserialize Account response Map'+mapRes);
                Boolean bflag=mapRes.containskey('SuggestionID');
                if(bflag==false){
                    Map<String,Object> mapobj =(Map<String,Object>)mapRes.get('ValidationErrors');
                    //if(mapobj == null){
                    //showError('Affinity Server was down . Please try after some time');
                    //}
                    //else{
                    for(String strs:mapobj.keySet()){
                        String strvalue=(String)mapobj.get(strs);
                        strerrMessage =strs+' : '+strvalue;
                        showError(strerrMessage); 
                        System.debug(strerrMessage);
                    }
                    //}
                    
                }else{
                    intSuggestionID=(Integer)mapRes.get('SuggestionID');
                    if(intSuggestionID==0){
                        strerrMessage =(String)mapRes.get('Error');
                        System.debug(strerrMessage);
                        showError(strerrMessage);
                    }else{
                        System.debug('Value:'+mapRes.get('SuggestionID'));
                        if(strSuggestionType == UPDATE_SUGGESTION){
                            //For Update suggestion Logic
                        }else{
                            leadRecord.Suggestion_id__c=String.valueOf(intSuggestionID);                            
                            lockTheLeadWithStatus('Account Suggestion Submitted');                                                        
                            update leadRecord;   //updating the lead                            
                            if(leadRecord.Partner_Request__c!=null){                                
                                Partner_Request__c partnerTobeUpdated = new Partner_Request__c(id = leadRecord.Partner_Request__c,Status__c ='Account Suggestion Submitted',Send_Account_Suggestion_Is_Complete_Flag__c = true);                                
                                
                                if(leadRecord.Universal_Customer_ID_UCID__c !=null){
                                    partnerTobeUpdated.Profile_UCID_as_Partner_Is_Complete_Flag__c = true; 
                                }
                                update partnerTobeUpdated;  //updating the partner request                            
                            }                                           
                            strStatus = PROCESS_COMPLETE;
                            //For UCID ID display in VF page
                            Object msg =mapRes.get('Message');
                            if(msg!=null){
                                strucidCreationRequestID = StringUtils.substringAfter((String)msg,':');//"UCIDCreationRequestID : 1000695",
                                system.debug('UCID Id'+ strucidCreationRequestID);
                            }
                            
                            return null;                            
                        } 
                        
                    }
                }
            }
            
            
            //v3.0 if error from Affinity
            
            /* *********** Old Version of code writen by previous Team **************
*  if(straccountResponse != null){
if(straccountResponse.Error !=null ){
if(straccountResponse.Error.containsIgnoreCase(OWNER_VALIDATION)){ showError('The record owner you designated in a prior step is not available in Affinity or properly setup in SFDC, the badge number is invalid. Please, choose a different user or raise a trouble ticket to ensure that user has a correct badge number in the profile');
}else if(straccountResponse.Error.containsIgnoreCase(LEGACY_VALIDATION)){ showError('Kindly recreate new lead and convert again. You may clone this lead and proceed your lead conversion.');
} else if(straccountResponse.Error.containsIgnoreCase(REGION_VALIDATION)){ showError('Account cannot be created since the record owner, country or territory are in different regions. Please choose a combination on the same region.');
}else{
showError(straccountResponse.Error);
}

}
if(strSuggestionType == UPDATE_SUGGESTION){
if(straccountResponse.SuggestionID != null && straccountResponse.SuggestionID != ''){
leadRecord.Suggestion_id__c =  straccountResponse.SuggestionID;
leadRecord.Status = 'Account Suggestion Submitted';
leadRecord.RecordTypeId = IdLookupUtils.getRecordTypeId('Update Account Suggestion Locked', 'Lead',true);               

update leadRecord;   //updating the lead                                
strStatus = PROCESS_COMPLETE;  return null;
}
}else{
if(straccountResponse != null && straccountResponse.accList != null && straccountResponse.accList.size() >0 ){
strStatus = DUPLICATE_EXISTS;
strDuplicationMessage = 'The Account with the same name exists in Affinity';  return null;                         
}else if(straccountResponse.intSuggestionID !=null){
leadRecord.Suggestion_id__c=  straccountResponse.intSuggestionID;                            
lockTheLeadWithStatus('Account Suggestion Submitted');                                                        
update leadRecord;   //updating the lead                            
if(leadRecord.Partner_Request__c!=null){                                
Partner_Request__c partnerTobeUpdated = new Partner_Request__c(id = leadRecord.Partner_Request__c,Status__c ='Account Suggestion Submitted',Send_Account_Suggestion_Is_Complete_Flag__c = true);                                
update partnerTobeUpdated;  //updating the partner request                            
}                                           
status = PROCESS_COMPLETE;   return null;                            
} 
} 
}*/
        }catch(Exception e){
            showError(e.getMessage());  
            Exception__c ex = new Exception__c();
            ex.Object_type__c = 'Account';
            ex.Operation__c = 'AccountSuggestionToCIL';
            ex.Process_Name__c = 'AccountSuggestionToCIL';
            system.debug('Catch Block=====');
            ex.Error_Messages__c = e.getMessage();
            return null;                    
        }
        
        showError('Result could not be processed');                     
        return null;
    }
    
    
    private void lockTheLeadWithStatus(String strleadStatus)
    {
        leadRecord.Status = strleadStatus; 
        List<RecordType> listlockedRecType = [  SELECT id, name 
                                              FROM RecordType 
                                              WHERE SobjectType = 'Lead' 
                                              AND name = 'Account Suggestion Locked'];
        
        if(listlockedRecType != null)
        {
            leadRecord.RecordTypeId = listlockedRecType[0].Id;
        }
        return;
    }
    
    public PageReference sendFirstSuggestion(){         
        return sendSuggestion(true);
    }
    public PageReference sendSecondSuggestion(){        
        return sendSuggestion(false);
    }
    public PageReference cancelSuggestion(){        
        lockTheLeadWithStatus('Account Suggestion Rejected');
        try{
            update leadRecord;
            if(leadRecord.Partner_Request__c!=null){
                Partner_Request__c partnerTobeUpdated = new Partner_Request__c(
                    id = leadRecord.Partner_Request__c, 
                    Status__c ='Account Suggestion Rejected');
                update partnerTobeUpdated;  //updating the partner request
            }   
        }
        catch(Exception e){   showError(e.getMessage());   return null;
                          }           
        return (new ApexPages.StandardController(leadRecord)).view();
    }
    
    public PageReference goToEdit(){
        PageReference leadEditpage=new PageReference('/'+ leadRecord.Id + '/e?retURL='+ leadRecord.Id);         
        leadEditpage.setRedirect(true);
        return leadEditpage;
    }
    
    
}