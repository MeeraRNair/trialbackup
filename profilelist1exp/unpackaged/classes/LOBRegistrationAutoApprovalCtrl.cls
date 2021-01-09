/*-------------------------------------------------------------------------
Description: Class  for auto-approving the deal
CR #2552
Version:1.0 

History:
    
Author: Manju Thomas

Revision History:
1.0    31-Oct-2011     Fenny   R13.1 - LOB Reg - CR6656: Deal registration auto-approval process (CR2552 mentioned above wasn't deployed)
2.0    06-Jun-2015     Devika  R16.07 - LOB Reg - CR11576: Enable Multi LOB auto-approval
3.0    03-Sep-2015     Devika  R16.10 - LOB Reg - CR11900: Remove check for Account Branch Location
4.0    05-Sept-2015    Impana  R16.10   LOB Reg   CR12033: Include City/State check for auto-approval
5.0    18-Apr-2015     Devika  CSM0402  LOB Reg   CR13058: Update the deal type field on opp before auto approving deals.
       12-Dec-2018     Hari A                      STORY 5907651 Removed reference for the fields lob_registration_id__c
6.0    29-March-2016   Meera            Deal Reg  CR12995:  Disti Visibility --- Make Reseller Contact required for Distributor created deal
--------------------------------------------------------------------------*/
public class LOBRegistrationAutoApprovalCtrl {
    public static string MSG_KEY_NOT_LOB_PRODUCT { get { return 'MSG_KEY_NOT_LOB_PRODUCT'; } }
    public static string MSG_KEY_AUTO_APPROVED { get { return 'MSG_KEY_AUTO_APPROVED'; } }
    public static string MSG_KEY_AUTO_APPROVAL_FAILED { get { return 'MSG_KEY_AUTO_APPROVAL_FAILED'; } }
    
    public static string MSG_CODE_INTERNAL_ERROR { get { return 'autoApprovalProcess() method excuted and returned false.'; } }
    
    public boolean hasError { get{ return (getErrors().size() > 0); } }
    public boolean showMessage { get; private set; }
    public string messageKey { get; private set; }
    public string lobName { get; private set; }
   
    public string upperCaseLOBName { get{ return StringUtils.upperCase(lobName); } }
    public string tcUrl { get; private set; }
    public string preferredLanguageCode{ get{return PartnerUtils.getPreferredLanguageCode();}}
    public ApexPages.Message[]  getErrors() { return PageUtils.getErrorMessagesOnly(); }
    public String url {get; private set;}
    public boolean ShowError{get;set;}

    
    private PageReference stdApprovalPageRef;
    private PageReference opptyDetailPageRef;
    private PageReference compProfilePageRef;
    private boolean isInfoSufficientForAutoApproval;
    private string userAccountId;
    private string userCountryCode;
    private string opportunityId;
    private Id[] idArr = new Id[]{};
    

    private final string DEFAULT_COUNTRY_NAME = 'UNITED STATES';
    private final string DEFAULT_PARTNER_LANGUAGE = 'English';

    private Opportunity opportunityObj { get; private set; }
    private LOB_Registration__c lobReg;
        
    //v2.0 
    public Map<String,LOB_Registration__c> lobName2RecMap = new Map<String,LOB_Registration__c>();
    //Constructor
    public LOBRegistrationAutoApprovalCtrl (ApexPages.StandardController controller){
    ShowError = false;
        try{
            opportunityObj = (Opportunity)controller.getRecord();
            opportunityId = opportunityObj.Id;
            List<Opportunity> opptyList = [SELECT Id, PartnerAccountId, name, AccountId, Number_of_Line_Items__c, OwnerId,Distributor_Name__c,Distributor_Reseller_Name__c, Deal_Expiration_Timeframe__c,
                                            HasOpportunityLineItem, End_User_Account_Department__c,  End_User_Mailing_City__c, End_User_Mailing_State_Province_Region__c
                                            FROM Opportunity 
                                            WHERE Id=:opportunityId limit 1];
           
            if((opptyList != null) && (opptyList.size() > 0)){
                opportunityObj = opptyList[0];
                idArr.add(opportunityObj.OwnerId);
                
                /****** v2.0 Commented Code Starts
                
                 List<LOB_Registration__c> lobRegList = [SELECT LOB_Name__c , Location1__c, LOB_registration_status__c FROM LOB_Registration__c
                                                        WHERE Id = :opportunityObj.LOB_Registration_ID__c 
                                                        AND Preferred_GTM_Partner_Account__c = :opportunityObj.PartnerAccountId];
                if((lobRegList != null) && (lobRegList.size() > 0)){
                    lobReg = lobRegList[0];
                    //CRQ0241 reminder : uncomment after type change  
                    lobName = lobReg.LOB_Name__c;
                }
                               
                *******  v2.0 Commented code Ends *****/                                
                
                /****** v2.0 Starts ******/         
                //List<String> lobList = opportunityObj.LOB_Registration_ID__c.split(';');
                
               // system.debug('****'+lobList);
                for(LOB_Registration__c lobReg :[SELECT LOB_Name__c , Location1__c,City__c,State_Province_Region__c, LOB_registration_status__c FROM LOB_Registration__c
                                                    WHERE Preferred_GTM_Partner_Account__c = :opportunityObj.PartnerAccountId]){
                   
                  lobName2RecMap.put(lobReg.LOB_Name__c,lobReg); 
                }                
                 system.debug('**** LOB List'+lobName2RecMap);
                
                if(lobName2RecMap.isEmpty()){
                  PageUtils.addError('No LOB Associated');
                }
                
                /****** v2.0 Ends ******/         
                
            } 


        }catch(Exception e){
            system.debug('## Caught APEX exception '+e.getMessage()+' [Code: LOBRegistrationAutoApprovalCtrl | Method: LOBRegistrationAutoApprovalCtrl]');
            PageUtils.addError('Your deal registration request could not be auto-approved at this time. Please contact your administrator for assistance. [Line ' + e.getLineNumber() + ': ' + e.getMessage() + ']');
        }finally{
            isInfoSufficientForAutoApproval = true;
            showMessage = false;
        }
    }
    
    // CR6656:  Method to check the conditions for eligibility of AutoApproval
    //          Show auto-approval T&C content page if the opportunity has line items and all added products are part of registered LOB
    public PageReference pageOnLoad(){
        // Check If the Fullfillment Path is Distribution & Distributor Reseller Name is blank, If so then show error message
        
        try{
            if( this.opportunityObj.Distributor_Name__c=='Distribution' && (this.opportunityObj.Distributor_Reseller_Name__c==null ) ) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Distributor_Reseller_Account );
                ApexPages.addMessage(myMsg);
                showError = true;
            }

            //V6.0
            else if(this.opportunityObj.Distributor_Reseller_Name__c !=null && (System.Label.ValidateResellerContact.toUpperCase() == 'FALSE' || Test.isRunningTest()) ){
                //check if opp partner account is distributor
                Id userId =  opportunityObj.OwnerId;
                String partnerid = opportunityObj.Distributor_Reseller_Name__c;
                if(DistiVisibilityHelperClass.getPartnerType(userId) == 'Distributor'){
                    //Query and check if team member exists from reseller account
                    List<OpportunityTeamMember> teamMemberList = [SELECT OpportunityId,TeamMemberRole,UserId FROM OpportunityTeamMember 
                                                                   WHERE OpportunityId = :opportunityId AND TeamMemberRole = 'Reseller Contact' AND User.Contact.AccountId = :partnerid];
                                                                   
                    //if no records display error
                    if(teamMemberList.size()==0){
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Reseller_Contact_Missing);
                        ApexPages.addMessage(myMsg);
                        showError = true;   
                    }
                }
            }

            //end V6.0
        if(showError == false){

            if(StringUtils.isNotBlank(opportunityObj.Id)){
                List<Account> acctList = [SELECT Id, Account_Country_Code__c FROM Account WHERE Id IN (SELECT AccountId FROM User WHERE Id = :UserInfo.getUserId())];
                if((acctList != null) && (acctList.size() > 0)){
                    Account acct = acctList[0];
                    userAccountId = acct.Id;
                    userCountryCode = acct.Account_Country_Code__c;
                }

                compProfilePageRef = new PageReference('/' + userAccountId);
                if(System.Label.DeaReg_Submit_for_approval_url == 'NULL'){
                    stdApprovalPageRef = new PageReference('/p/process/Submit?id=' + opportunityObj.id + '&retURL=%2F' + opportunityObj.id);
                 }else{
                    stdApprovalPageRef = new PageReference('/p/process/Submit?id=' + opportunityObj.id + '&retURL=%2F' + opportunityObj.id+System.Label.DeaReg_Submit_for_approval_url);
                 }                opptyDetailPageRef = new PageReference('/' + opportunityId); 
                url = ApexPages.currentPage().getParameters().get('Submit');

                if(opportunityObj.HasOpportunityLineItem && isAutoApprovalEnabled()){ 
                    // If the opportunity has line item and the auto-approval is enabled
                    if(!isRegisteredLOBProduct()){
                        // If any of the added product(s) is not part of registered LOB
                        setMessage(MSG_KEY_NOT_LOB_PRODUCT);
                    }
                }else if(!isInfoSufficientForAutoApproval){
                    standardApprovalProcess();
                    setMessage(MSG_KEY_AUTO_APPROVAL_FAILED);
                }else{
                    // Submit the deal to manual approval process if the opportunity has no line item, then a message shown saying unable to submit for approval. OR
                    // Submit the deal to manual approval process if the auto-approval is disabled
                    return stdApprovalPageRef;
                }
            }else{
                // If the opportunity record not found, show opportunity list page
                return showOpportunityList();
            }

        }
        }catch(Exception e){
            system.debug('## Caught APEX exception '+e.getMessage()+' [Code: LOBRegistrationAutoApprovalCtrl | Method: pageOnLoad]');
            PageUtils.addError('Your deal registration request could not be auto-approved at this time. Please contact your administrator for assistance. [Line ' + e.getLineNumber() + ': ' + e.getMessage() + ']');
        }
        return null;
    }
    

    // CR6656: Method to check whether the added products are part of the selected LOB Registration with status = Partner(approved), 
    //         and the location (Account Branch) matched
    @TestVisible private boolean isRegisteredLOBProduct(){
        boolean isLOBProduct = true;
        try{
            /********* v2.0 Commented Code Starts ***********
            if(!StringUtils.equalsIgnoreCase(lobReg.Location1__c, StringUtils.trim(opportunityObj.End_User_Account_Department__c))
                || !StringUtils.equalsIgnoreCase(lobReg.LOB_registration_status__c, 'Partner(approved)')){
                    
                isLOBProduct = false;
            }else{
                List<OpportunityLineItem> itemList = [SELECT Id, PricebookEntry.Product2.LOB_Category__c 
                                                      FROM OpportunityLineItem  
                                                      WHERE OpportunityId =:opportunityObj.id]; 
                if((itemList != null) && (itemList.size() > 0)){
                    for(OpportunityLineItem item : itemList){
                        //CRQ0241 reminder : uncomment after type change  
                       if(!StringUtils.equalsIgnoreCase(lobReg.LOB_Name__c, StringUtils.trim(item.PricebookEntry.Product2.LOB_Category__c))){
                            isLOBProduct = false;
                            break;
                        } 
                    }
                }else{
                    isLOBProduct = false;
                }                                               
            }
            ********* v2.0 Commented Code Ends***********/
            
            /****** v2.0 Starts ******/         
                        
            List<OpportunityLineItem> itemList = [SELECT Id, PricebookEntry.Product2.LOB_Category__c 
                                                  FROM OpportunityLineItem  
                                                  WHERE OpportunityId =:opportunityObj.id]; 
            if((itemList != null) && (itemList.size() > 0)){ 
                for(LOB_Registration__c lobReg : lobName2RecMap.values()){
                        if(
                        /*!StringUtils.equalsIgnoreCase(lobReg.Location1__c, StringUtils.trim(opportunityObj.End_User_Account_Department__c))
                           || v 3.0 */
                           // v 4.0 City and State check for auto approval
                           (lobReg.City__c!=null && !StringUtils.equalsIgnoreCase(lobReg.City__c, StringUtils.trim(opportunityObj.End_User_Mailing_City__c))) ||
                           (lobReg.State_Province_Region__c != null && !StringUtils.equalsIgnoreCase(lobReg.State_Province_Region__c, StringUtils.trim(opportunityObj.End_User_Mailing_State_Province_Region__c)) )||
                           !StringUtils.equalsIgnoreCase(lobReg.LOB_registration_status__c, 'Partner(approved)')){                   
                           isLOBProduct = false;                           
                           break;
                        }                                                    
                 }   
                 for(OpportunityLineItem item : itemList){
                     //CRQ0241 reminder : uncomment after type change
                     system.debug('$$$$$'+item.PricebookEntry.Product2.LOB_Category__c);
                     if(!lobName2RecMap.containsKey(StringUtils.trim(item.PricebookEntry.Product2.LOB_Category__c))){
                        isLOBProduct = false;
                        break;
                     }
                }                                        
            }else{
                    isLOBProduct = false;
            }                                               
            
            /****** v2.0 Ends ******/       
            
        }catch(Exception e){
            system.debug('## Caught APEX exception '+e.getMessage()+' [Code: LOBRegistrationAutoApprovalCtrl | Method: isRegisteredLOBProduct]');
            isLOBProduct = false;  
            throw e;
        }
        return isLOBProduct;
    }
    
    // CR6656: This method checks whether the auto-approval process is enabled for the LOB + country + language
    @TestVisible private boolean isAutoApprovalEnabled(){
        boolean autoApprovalEnabled = false;
        try{
            List<Country__c> countryList = [SELECT Id FROM Country__c WHERE Code__c = :userCountryCode];
            if((countryList != null) && (countryList.size() > 0)){
                string countryId = countryList[0].Id;
                PartnerLanguage pl = new PartnerLanguage(true);
                string userLanguage = pl.returnMatchValue(UserInfo.getLanguage());
                
                
                /****** v2.0 Starts ******/
                                
                List<LOB_Administration__c> lobAdminList = [SELECT Id FROM LOB_Administration__c WHERE Name IN :lobName2RecMap.Keyset()];
                system.debug('**** LOB Admin List'+lobAdminList );                                
                  
                  if((lobAdminList != null) && (lobAdminList.size() > 0)){
                    //LOB_Auto_approval_Administration__c lobAutoApprovalAdmin = null;
                    List<LOB_Auto_approval_Administration__c> lobAutoApprovalAdminSelected = new List<LOB_Auto_approval_Administration__c>();
                    
                    for(LOB_Administration__c lobAdminRecord : lobAdminList){
                        string lobAdminId = lobAdminRecord.Id;
                        List<LOB_Auto_approval_Administration__c> lobAutoApprovalAdminList = [SELECT Auto_approval_T_C_Location__c, Auto_approval_enabled__c
                                                                                                FROM LOB_Auto_approval_Administration__c
                                                                                                WHERE Country__c = :countryId AND Language__c = :userLanguage
                                                                                                AND Auto_approval_enabled__c = true AND LOB_Name__c = :lobAdminId  ];
                                                                                           //CRQ0241 reminder : uncomment after type change
                        system.debug('############# lobAutoApprovalAdminList: '+lobAutoApprovalAdminList);
                    
                        if((lobAutoApprovalAdminList == null) || (lobAutoApprovalAdminList.size() == 0)){
                            // If the auto-approval T&C not found for specific LOB name + Account country + Partner language
                            // check for LOB Name + Auto Approval Enable true + Account country
                            lobAutoApprovalAdminList = [SELECT Auto_approval_T_C_Location__c, Auto_approval_enabled__c
                                                        FROM LOB_Auto_approval_Administration__c
                                                        WHERE Auto_approval_enabled__c = true AND LOB_Name__c = :lobAdminId AND Country__c = :countryId];
                            if(lobAutoApprovalAdminList == null || lobAutoApprovalAdminList.size() == 0){
                                isInfoSufficientForAutoApproval = false;    
                            }
                            else{
                                // Then the default auto-approval T&C will be <LOB Name> + <US> + <English>
                                countryId = [SELECT Id FROM Country__c WHERE Name = :DEFAULT_COUNTRY_NAME][0].Id;
                                lobAutoApprovalAdminList = [SELECT Auto_approval_T_C_Location__c, Auto_approval_enabled__c
                                                            FROM LOB_Auto_approval_Administration__c
                                                            WHERE Country__c = :countryId AND Language__c = :DEFAULT_PARTNER_LANGUAGE
                                                            AND Auto_approval_enabled__c = true AND LOB_Name__c = :lobAdminId ];
                                                           //CRQ0241 reminder : uncomment after type change 
                                system.debug('############# default lobAutoApprovalAdminList: '+lobAutoApprovalAdminList);
                            }
                        }
                        else{
                            isInfoSufficientForAutoApproval = false;
                        }
                        
                        if((lobAutoApprovalAdminList != null) && (lobAutoApprovalAdminList.size() > 0)){
                                lobAutoApprovalAdminSelected.addAll(lobAutoApprovalAdminList);
                        }
                        
                    }
                    
                    /*if((lobAutoApprovalAdminList != null) && (lobAutoApprovalAdminList.size() > 0)){
                        lobAutoApprovalAdmin = lobAutoApprovalAdminList[0];
                        autoApprovalEnabled = lobAutoApprovalAdmin.Auto_approval_enabled__c;
                        tcUrl = lobAutoApprovalAdmin.Auto_approval_T_C_Location__c;
                    }*/
                    
                    if((lobAutoApprovalAdminSelected != null) && (lobAutoApprovalAdminSelected.size() > 0)
                    /*&& (lobAutoApprovalAdminSelected.size() == lobNameList.size())*/){
                        autoApprovalEnabled = lobAutoApprovalAdminSelected[0].Auto_approval_enabled__c;
                        tcUrl = lobAutoApprovalAdminSelected[0].Auto_approval_T_C_Location__c;
                    }
                    /****** v2.0 Ends ******/                      
                    
                    else{
                        isInfoSufficientForAutoApproval = false;
                    }
                }else{
                    isInfoSufficientForAutoApproval = false;
                }               
            }else{
                isInfoSufficientForAutoApproval = false;
            }
        }catch (Exception e){
            system.debug('## Caught APEX exception '+e.getMessage()+' [Code: LOBRegistrationAutoApprovalCtrl | Method: isAutoApprovalEnabled]');
            autoApprovalEnabled = false;
            throw e;
        }
        return autoApprovalEnabled;
    }
    
    // CR6656: This method is to proceed with standard approval process if the chosen products are not part of selected registered LOB
    public PageReference proceedManualApproval(){
        try{
            return stdApprovalPageRef;
        }catch(Exception e){
            system.debug('## Caught APEX exception '+e.getMessage()+' [Code: LOBRegistrationAutoApprovalCtrl | Method: proceedManualApproval]');
            PageUtils.addError('Your deal registration request could not be auto-approved at this time. Please contact your administrator for assistance. [Line ' + e.getLineNumber() + ': ' + e.getMessage() + ']');
        }
        return null;
    }
    
    // CR6656: This method is to get back to opportunity detail page without submitting the deal registration for approval
    public PageReference exitApproval(){
        try{
            return opptyDetailPageRef;
        }catch(Exception e){
            system.debug('## Caught APEX exception '+e.getMessage()+' [Code: LOBRegistrationAutoApprovalCtrl | Method: exitApproval]');
            PageUtils.addError('Your deal registration request could not be auto-approved at this time. Please contact your administrator for assistance. [Line ' + e.getLineNumber() + ': ' + e.getMessage() + ']');
        }
        return null;
    }
    
    // CR6656: This method is to get back to My Company Profile page upon the submission is successful, regardless the submission is standard/auto approval
    public PageReference showCompanyProfile(){
        try{
            return compProfilePageRef;
        }catch(Exception e){
            system.debug('## Caught APEX exception '+e.getMessage()+' [Code: LOBRegistrationAutoApprovalCtrl | Method: showCompanyProfile]');
            PageUtils.addError('Your deal registration request could not be auto-approved at this time. Please contact your administrator for assistance. [Line ' + e.getLineNumber() + ': ' + e.getMessage() + ']');
        }
        return null;
    }
    
    // CR6656: This method is to get back to Opportunity list page
    public PageReference showOpportunityList(){
        string prefix = Opportunity.sObjectType.getDescribe().getKeyPrefix();
        return new PageReference('/' + prefix + '/o');
    }
    
    // CR6656: This method is invoked upon the [Submit Registration] button on T&C content page is clicked
    public PageReference submitRegistration(){
        try{
            
            /****v 5.0 Starts **/
            
            TriggerExecutionController.setSkipOpportunityTriggers(True);
            if(DealRegUtils.isGCCountry() == false){
             system.debug('@@@@Non-GC:');
            opportunityObj.Deal_Expiration_Timeframe__c = '90';
            }else{
                system.debug('@@@@GC:');
            }
             system.debug('@@@90OR60:'+ opportunityObj.Deal_Expiration_Timeframe__c);
            opportunityObj.Deal_Type__c = 'LOB Deal';
            update opportunityObj; 
            TriggerExecutionController.setSkipOpportunityTriggers(false);
            /****v 5.0 Ends **/

            Approval.ProcessResult result = submitApprovalRequest();
            system.debug('####@@@@##### result: '+result);
           
            
            if(autoApprovalProcess(result)){
            system.debug('RESULT TRUE');
            
            List<Opportunity> opptyList = [SELECT Id, PartnerAccountId, name, AccountId, Number_of_Line_Items__c, OwnerId,
                                            HasOpportunityLineItem, End_User_Account_Department__c, End_User_Mailing_City__c, End_User_Mailing_State_Province_Region__c,
                                            Deal_Type__c
                                            FROM Opportunity 
                                            WHERE Id=:opportunityId limit 1];
               
               if((opptyList != null) && (opptyList.size() > 0)){
                opportunityObj = opptyList[0];
                } 
                
                opportunityObj.Deal_Type__c = 'LOB Deal';
                update opportunityObj;
                setMessage(MSG_KEY_AUTO_APPROVED);
            }else{
                /****v 5.0 Starts **/          
                TriggerExecutionController.setSkipOpportunityTriggers(true);
                opportunityObj.Deal_Type__c = '';
                update opportunityObj; 
                TriggerExecutionController.setSkipOpportunityTriggers(false);
                /****v 5.0 Ends **/
                
                system.debug('RESULT FALSE');
                throw new dellUtil.DellException(MSG_CODE_INTERNAL_ERROR);
            }
        }catch(Exception e){
            system.debug('## Caught APEX exception '+e.getMessage()+' [Code: LOBRegistrationAutoApprovalCtrl | Method: submitRegistration]');
            setMessage(MSG_KEY_AUTO_APPROVAL_FAILED);
        }
        return null;
    }
    
    // CR6656: This method is invoked upon the [Cancel] button on T&C content page is clicked
    public PageReference cancelSubmission(){
        try{
            return stdApprovalPageRef;
        }catch(Exception e){
            system.debug('## Caught APEX exception '+e.getMessage()+' [Code: LOBRegistrationAutoApprovalCtrl | Method: cancelSubmission]');
            PageUtils.addError('Your deal registration request could not be auto-approved at this time. Please contact your administrator for assistance. [Line ' + e.getLineNumber() + ': ' + e.getMessage() + ']');
        }
        return null;
    }
    
    // CR6656: This method is to handle the deal registration stardard/normal approval process
    @TestVisible Private Boolean standardApprovalProcess(){
        Boolean succeed = true;
        try{
            Approval.ProcessResult result = submitApprovalRequest();
            succeed = result.isSuccess();
        }catch(Exception e){
            system.debug('## Caught APEX exception '+e.getMessage()+' [Code: LOBRegistrationAutoApprovalCtrl | Method: standardApprovalProcess]');
            succeed = false;
            PageUtils.addError('Your deal registration request could not be auto-approved at this time. Please contact your administrator for assistance. [Line ' + e.getLineNumber() + ': ' + e.getMessage() + ']');
        }
        return succeed;
    }
    
    // CR6656: This method is to handle the deal registration auto-approval process
    @TestVisible private Boolean autoApprovalProcess(Approval.ProcessResult result){
        Boolean succeed = false;
        try{
            
            // Verify the result, if success, approve the submitted request
            if(result.isSuccess()){
                // First, get the ID of the newly created item
                List<Id> newWorkItemIds = result.getNewWorkitemIds();
                
                system.debug('$$$$$$$$$$$ inside autoApprovalProcess');
                system.debug('$$$$$$$$$$$ Owner Id : ' +idArr);
                system.debug('$$$$$$$$$$$ result: '+result);
                system.debug('$$$$$$$$$$$ result NewWorkitemIds : '+result.getNewWorkitemIds());
                
                // Instantiate the new ProcessWorkitemRequest object and populate it
                Approval.ProcessWorkitemRequest workItemReq = new Approval.ProcessWorkitemRequest();
                workItemReq.setComments('Auto-approval');
                workItemReq.setAction('Approve');              
                workItemReq.setNextApproverIds(idArr);
                // Use the ID from the newly created item to specify the item to be worked
                workItemReq.setWorkitemId(newWorkItemIds.get(0));
                
                // Submit the request for auto-approval
                Approval.ProcessResult result2 = Approval.process(workItemReq);
                succeed = result2.isSuccess();
            }
        }catch(Exception e){
            system.debug('## Caught APEX exception '+e.getMessage()+' [Code: LOBRegistrationAutoApprovalCtrl | Method: autoApprovalProcess]');
            succeed = false;
            throw e;
        }
        return succeed;
    }
    
    // CR6656: This method is to create and submit approval request for opportunity record
    @TestVisible private Approval.ProcessResult submitApprovalRequest(){
        Approval.ProcessResult result = null;
        try{
        system.debug('$$$$$$$$$$$$$$ inside submitApprovalRequest');
        system.debug('Oppty Id: '+opportunityId +' & Owner Id: ' +idArr);
            // Create an approval request for the opportunity
            Approval.ProcessSubmitRequest submitReq = new Approval.ProcessSubmitRequest();
            submitReq.setComments('Submitting request for approval.');
            submitReq.setObjectId(opportunityId); 
            submitReq.setNextApproverIds(idArr); 
            
            // Submit the approval request for the opportunity
            result = Approval.process(submitReq);
            system.debug('$$$$$$$$$$$ submitApprovalRequest result: '+result);
        }catch(Exception e){
            system.debug('## Caught APEX exception '+e.getMessage()+' [Code: LOBRegistrationAutoApprovalCtrl | Method: submitApprovalRequest]');
            throw e;
        }
        return result;
    }
    
    @TestVisible private void setMessage(string msgKey){
        showMessage = true;
        messageKey = msgKey;
    }
}//End of class