/*
* Author   : Ragu
* Purpose  : This is the controller for the Visual Force page leadConvertPage.
* 
* Revision CR Number   Release No      Date            Modified By     Description
* -------- ---------   ----------      -----------     ------------    -----------
* 1.0      11609       16.07            15-Dec-2014     Ragu            Installed "Convert Lead - Custom Lead Conversion Process" app from AppExchange.
* 1.1      11609       16.07            18-Dec-2014     Ragu            Commented usage of leadConvertTaskDescComponentController.
* 1.2      11609       16.07            19-Dec-2014     Ragu            Updated code to use opportunityName instead of Opportunity object.
* 1.3      TFS: 176168 16.07            23-Jun-2015     Ragu            During Lead Conversion, after update trigger on Lead is not updating the Campaign Member's CM Status - Technical Limitation.
* 1.4      11867       16.10            09-Sep-2015     Niveda          Included logic to check for duplicate account in affinity and proceed to create new account/associate with an account in affinity.
* 1.5      12022       16.10            12-Oct-2015     Niveda          Validate contact before lead conversion process
* 1.6      D206040     16.10            27-Oct-2015     Niveda          Included logic to skip contact, account, lead and task triggers to avoid 'Too many soql queries : 101' while creating an opportunity during conversion 
* 1.7      12379       16.12            26-Nov-2015     Nagendra        LM2_1_81-Enhance lead conversion process for matching contacts in existing account
* 1.8      12449       16.12            09-Dec-2015     Nagendra        LM2_15_1-Enhance lead conversion based on user
* 2.0      12706       FY17-DCS-0303    26-Feb-2016     Sui Yee         LM2_15-Fix Check contact validation rules for Related contact when click on Convert
* 3.0      12746       FY17-DCS-0401    12-Mar-2016     Sui Yee         LM2_15-After opportunity is created by Sales user take to add product
* 4.0      12749       FY17-DCS-0403    18-Mar-2016     Gan             Set 4 fields under task section as not mandatory and uncheck reminder checkbox by default
* 4.1      12758       FY17-DCS-0403    21-Mar-2016     Azwanti         Story 1140259 : prompt error message if Lead Status is NOT "Open", "accepted", "Contacted" or "Marketing Qualified Lead".
* 5.0      13180       FY17-DCS-0701    25-May-2016     Gan             To update the Campaign Member with lead relavant fields
* 6.0      13282       FY17-DCS-0801    22-Jun-2016     Gan             To allow conversion to link to existing oppty
* 6.1      13266       FY17-DCS-0801    28-Jun-2016     Josie           LM2_15-Add validation rule for existing contact in conversion process
* 6.2      13309       FY17-DCS-0801    05-Jul-2016     Gan             Logic for small Deal oppty 
* 6.3      13318       FY17-DCS-0801    13-Jul-2016     Sui Yee         LM2_15-Fix overwriting Legacy ID in account during lead conversion
* 6.4                  FY17-DCS-0801    13-Jul-2016     Gan             Code clean up to hit a higher code coverage
* 6.5      13309       FY17-DCS-0801    14-Jul-2016     Gan             to handle opportunity action after created as we skip the trigger for 101 error
* 7.0      13640       FY17-DCS-0103    01-Nov-2016     SuiYee          Adding Department field to Lead 2.0 and mapping with contact field
* 7.1      13693       FY17-DCS-0103    01-Nov-2016     Sajith          Introduced Sales Follow Up days calculation logic during lead conversion
* 8.0      13935       FY17-DCS-0104    23-Jan-2016     Gan             to further reduce soql in lead conversion
* 9.0      13806       FY18-DCS-0202    23-Dec-2016     Gan             To enable creation of SubAccount
* 10.0     13927       FY18-DCS-0302    24-Jan-2017     Wanti           replace error message with custom label for translation
* 10.1     13991       FY18-DCS-0302    07-Feb-2016     Sajith          LM2_ Optimization in lead conversion process - Contact validations
* 11.0     14012       FY18-DCS-0502    03-Mar-2017     Azwanti         LM2_Optimization in lead conversion process - UI changes refresh
* 12.0     14143       FY18-DCS-0602    05-Apr-2017     Sajith          LM2_15-Bypass contact validation rules in conversion for existing contact
* 13.0     14714       FY18-DCS-1001    01-Aug-2017     Sajith          LM2_MDM_1-Lead Conversion Page (UI) Enhancement test
* 13.1     14688       FY18-DCS-1001    24-Aug-2017     Azwanti         story 3645355: call method createGDMRequest()
* 14.0     14976       FY18-DCS-1101    22-Sep-2017     Sajith          Defect 3895620:FY18-1001 : SFDC Wunderkind : Sales Channel is overwritten 
* 14.1     14957       FY18-DCS-1101    29-Sep-2017     Sajith          MDM - Change Under Review Status to Inactive for Account/Subaccount creation
* 15.0     15180       FY19-DCS-0202    28-Nov-2017     Sajith          Lead conversion status update
* 16.0     15435       FY19-DCS-0401    14-Feb-2018     Azwanti         Affinity Interlock: Making Legal English or Legal Local Address mandatory for China and Japan countries
* 17.0     15626       FY19-DCS-0502    12-Apr-2018     Krishna         Lead 2.0- To fix INC5404659 Dell Main Exception error when trying to convert lead
* 17.1     15697       FY19-DCS-0602    27-Apr-2018     Pallavi         Removed createGDMRequest() reference as part of Story 4168524
* 18.0    15957        FY19-DCE-0802    28-Jun-2018     Fenny           Code cleanup: removed debug statement, shorten some variable name
* 19.0     17465       FY20-DCS-1002    19-Aug-2019     Sonali          Added Logic to update Contact_from_Lead_Conversion__c flag for contacts created from Lead conversion 
* 20.0     18002       FY20-DCS-1002    28-Aug-2019     Kokila          To Skip standard Leadconvert Validation - Specified Contact must be parented by specified Account 
* 21.0     18366       FY20-DCS-0202    09-Dec-2019     Siva            To Skip contact validation rules during lead conversion for associated contact
*/
 
public without sharing class LeadConvertPageCtrl extends PageControllerBase {
    
    // This is the lead that is to be convertedLM2_15-Fix Check contact validation rules for Related contact when click on Convert
    public Lead leadToConvert {get; set;}
    public list<AccountSuggestionResponse.accountObject> accountList{get; set;}  
    public AccountSuggestionResponse accountResponse{get;set;}
    public string selectedAccountId{get;set;}
    public id leadId;
    public static User currentUser= StaticFactory.getCurrentUserDetails();
    public static User leadOwner;
    public string legacyId;
    public string strPrevStatus;//7.1
    public boolean isValidated{get; set;}
    public static string ownerValidation ='Suggestion submitter RRID/BadgeNumber is Invalid';
    public static string legacyValidation ='Legacy Id is already associated with different account';
    public static string regionValidation ='You cannot create suggestion that belong to a different region';
    public Boolean missingMandatoryAddressStr = false; //v16.0
    Set<String> profileList = new Set<String>();
    boolean b = profileList.addAll(System.Label.SalesRep_Profiles.split(';'));
    // These are instances of the components' controllers which this class will access.
    // If you add new custom components, add an instance of the class here
    public leadConvertCoreComponentController myCompCtrler { get; set; }
    public leadConvertTaskInfoComponentController myTaskCompCtrler { get; set; }
    // v1.1 : Commented usage of leadConvertTaskDescComponentController
    //public leadConvertTaskDescComponentController myDescriptionComponentController { get; set; }
    public List<string> listObjectNames; //21.0
    
    // These are the set methods which override the methods in PageControllerBase. 
    // These methods will be called by the ComponentControllerBase class.
    // If you add new custom components, a new overridden set method must be added here.
    public override void setComponentController(ComponentControllerBase compController) {
        myCompCtrler = (leadConvertCoreComponentController)compController;
    }
    
    public override void setTaskComponentController(ComponentControllerBase compController) {
        myTaskCompCtrler = (leadConvertTaskInfoComponentController)compController;
    }
    
    // v1.1 - Starts : Commented usage of leadConvertTaskDescComponentController
    /* 
public override void setDescriptionComponentController(ComponentControllerBase compController) {
myDescriptionComponentController = (leadConvertTaskDescComponentController)compController;
}
*/
    // v1.1 - Ends : Commented usage of leadConvertTaskDescComponentController
    
    
    // These are the get methods which override the methods in PageControllerBase.
    // If you add new custom components, a new overridden get method must be added here.
    public override ComponentControllerBase getMyComponentController() {
        return myCompCtrler;
    }
    
    public override ComponentControllerBase getmyTaskComponentController() {
        return myTaskCompCtrler;
    } 
    
    
    // Constructor for this controller
    public LeadConvertPageCtrl(ApexPages.StandardController stdController) {
        // Get the ID to query for the Lead fields
        // 7.0
        // v20.0 - Included Contact__r.AccountId field in Select statement
        leadId = stdController.getId();
        isValidated = false;
        leadToConvert = [SELECT Account__r.Account_ID__c,Account_Category__c, Contact__c,Contact__r.Name,Contact__r.AccountId,FirstName,LastName,Name,PostalCode,Country,City,State,Street,Account_Owner__c, Account_Owner__r.Badge_Number__c, 
                         OwnerId,Account_Owner__r.FirstName, Account_Owner__r.LastName,Account__r.Name,Physical_Country__c, Account_Owner__r.UserRole.name, 
                         Company,Date_Founded__c, DMU_Flag__c,Function_Category_Code__c, Id,Marketing_Class_Code__c, National_ID__c, 
                         NDA_Expiry_Date__c, NDA_Flag__c,Organization_Country__r.Code__c,
                         Organization_Country__r.Region__c,Partner_Class__c, 
                         Partner_Status__c, Partner_Type__c,  Premier_Page_URL__c,CompanyLocal, Program_Type__c, Questions_Comments__c, 
                         Sales_Model_Code__c, Status,Email,LastModifiedBy.Badge_Number__c,MobilePhone,campaign__c,
                         Suggestion_Reason__c, Territory_Assignment__c, Territory_Assignment__r.Group_ID__c, 
                         //9.0
                         Territory_Assignment__r.Region_Desc__c,
                         Territory_Assignment__r.Name, Website,
                          First_time_assigned_to_Sales__c,Assigned_to_Sales__c//7.1 
                         //6.0
                         
                         //13.0 Start
                         ,Country_CN__c
                         ,Street_CN__c
                         ,City_CN__c
                         ,State_Province_CN__c
                         ,Zip_Postal_Code_CN__c
                         ,Legal_Local_Company_Name__c
                         ,Legal_Local_Address_1__c 
                         ,Legal_Local_Country__c 
                         ,Legal_Local_City__c 
                         ,Legal_Local_Postal_State__c 
                         ,Legal_Local_Postal_Code__c
                         ,Lead_Converted__c
                         //13.0 End
                         FROM Lead
                         WHERE Id = :leadId LIMIT 1];
        //7.1 Saving the status before converion, to use in sales follow up days calculation
        strPrevStatus=leadToConvert.Status;
        //13.0 Populating Physical Country field with Standard Country
        list<Country__c> stdCountry=[Select Id,Name from Country__c Where Name=:leadToConvert.Country LIMIT 1];
        if(stdCountry.size()> 0){leadToConvert.Physical_Country__c=stdCountry[0].Id;
            //v16.0 populate Country for China user
            if(currentUser.HR_Location_Country_Desc__c!=null && currentUser.HR_Location_Country_Desc__c.toUpperCase()=='CHINA'){
                leadToConvert.Country_CN__c = stdCountry[0].Name;    
            }
        }
       
    }
    
    //v1.5 - Method called on click of convert lead button to validate contact prior to conversion process
    public PageReference validateLead() { 
        //Only users who have permission to edit the record are allowed to convert the same.
        if(!LeadRouterHelper.checkUserAccess(leadToConvert,userinfo.getuserid())){ printError(System.Label.LM2_Insufficient_Privileges); //v10.0
        }
        else{
            //v19.0 - Start
            if(leadToConvert.Lead_Converted__c == FALSE ){
                 TriggerExecutionController.setSkipAllTriggers(True);
                 leadToConvert.Lead_Converted__c = TRUE;
                 Update leadToConvert;
                 TriggerExecutionController.setSkipAllTriggers(false);
                
                }//v19.0 - End
            //v4.1
            if(leadToConvert.Status != 'New' && leadToConvert.Status != 'Working' && leadToConvert.Status != 'Pre-Qualified'){ printError(System.Label.LM2_Convert_Lead_Only_For_Open_Lead); //v10.0
            }
            //end v4.1
            else{
                // This is the lead convert object that will convert the lead 
                Database.LeadConvert leadConvert = new Database.LeadConvert();
                leadConvert.setLeadId(leadToConvert.Id);
                if(leadToConvert.Account__c != NULL ) {
                    leadConvert.setAccountId(leadToConvert.Contact__r.AccountId); //v20.0
                }
               /** 21.0
                if(leadToConvert.Contact__c != null) {
                    leadConvert.setContactId(leadToConvert.Contact__c);
                }
              21.0 **/
                leadConvert.setConvertedStatus('Converted without Opportunity'); //15.0

                leadConvert.setDoNotCreateOpportunity(true);
                //Do the actual conversion process and check for errors. If no errors, rollback the changes and redirect users to conversion page
                Savepoint sp = Database.setSavepoint();
             //21.0 logic starts
                if(leadToConvert.Contact__c != null){ 
                     listObjectNames = new List<string>();
                     listObjectNames.add('Contact');
                     SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
                     leadConvert.setContactId(leadToConvert.Contact__c);
                 }
             //21.0      
                Database.LeadConvertResult leadConvertResult = Database.convertLead(leadConvert, false);
              
                if(leadConvertResult.success) {
                    // v2.0  - Starts : LM2_15-Fix Check contact validation rules for Related contact when click on Convert
                    isValidated = true;
                    list<contact> lstContacts = [select Id, Mailing_Address_Changed__c, Status__c, AccountId, Account_Active_Contact__c, Account_Inactive_Contact__c from contact where Id = :leadConvertResult.getContactId()];        
                  /**** commented these lines for 21.0
                   //12.0 Changes to skip the contact validation rule during conversion
                    List<string> listObjectNames = new List<string>();//12.0
                    listObjectNames.add('Contact');//12.0
                    //12.0
                    if(leadToConvert.Contact__c != null){ 
                    SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);//12.0
                    }
                ****/   
                    Database.SaveResult[] conList = Database.update(lstContacts, false);
                     //12.0 & 21.0
                    if(leadToConvert.Contact__c != null){ ResetSystemBehaviorBypasser.resetSkipValidationRules(listObjectNames);//12.0 & 21.0
                    }
                   
                    for (Database.SaveResult cList: conList) {
                        if (!cList.isSuccess()) {
                            isValidated = false;
                            for(Database.Error err : clist.getErrors()) {
                                printError(err.getMessage());
                            }
                            if(leadToConvert.Contact__c != null && isValidated == false) {printError(System.Label.LM2_ContactBadData);//v10.0
                            }
                        }
                    }
                    // v2.0  - End : LM2_15-Fix Check contact validation rules for Related contact when click on Convert
                    
                }
                else if(leadConvertResult.getErrors() != null){
                    printError(leadConvertResult.getErrors()[0].getMessage());
                }
                Database.rollback(sp);
            }
        }
        return null;
        
    }
    
    
    // This method is called when the user clicks the Convert button on the VF Page
    public PageReference convertLead() {
        
        missingMandatoryAddressStr = false; //v16.0 reset to false everytime user click Convert

        // v1.1 - Starts : Updated order of condition checks to make it better.
        // If the main lead convert component is not set then return
        if(myCompCtrler == NULL) {
            System.debug('myCompCtrler is null.');
            return null;
        }
        
        // If the Account is not set, then show an error
        if(myCompCtrler.selectedAccount == 'NONE') {
            //printError('Account Name: Please select an Account.');
            printError(System.Label.LM2_Required_Account_Name); //v10.0
            return null;
        }
        //V1.7 Start
        if(myCompCtrler.selectedContact == 'NONE' ) {
            //printError('Contact Name: Please select a Contact.');
            printError(System.Label.LM2_Required_Contact_Name); //v10.0
            return null;
        }
        
        // If Opportunity Name is not entered show an error 
        // v1.2 : Updated code to use opportunityName instead of Opportunity object.
        //6.0
        if(String.isBlank(myCompCtrler.opportunityName) && (myCompCtrler.oppty == 'New' || myCompCtrler.oppty == 'SmallDeal')) {
            printError(System.Label.LM2_Required_Opportunity_Name); //v10.0
            return null;
        }
        
        if(String.isBlank(myCompCtrler.opportunityName) &&  myCompCtrler.oppty == 'Existing') {
            printError('Opportunity Name: Please choose an opportunity to link with.');
            return null;
        }
        
        // If Lead Status is not entered show an error 
        if(myCompCtrler.leadConvert.Status == 'NONE') {
            printError(System.Label.LM2_Required_Lead_Status); //v10.0
            return null;
        }       
  
        if(myCompCtrler.selectedAccount== 'NEW' || myCompCtrler.selectedAccount.startsWith('SUB-')){
            
            If(myCompCtrler.leadConvert.Country == null){
                printError(System.Label.LM2_Required_Country); //v10.0
                return null;
            }
            If(myCompCtrler.leadConvert.Company == null ) {printError('Account Name : You must enter a value'); return null;
            }
            else{
                 if(!validateDoubleByte(myCompCtrler.leadConvert.Company)) {    
                     printError('Account Name must be in English');
                    return null;
                }
            }
            
            System.debug(loggingLevel.INFO,'Current User :' + currentUser);
            
            if((currentUser.HR_Location_Country_Desc__c!=null)&& (currentUser.HR_Location_Country_Desc__c.toUpperCase()=='CHINA')){   
                //v16.0
                if(myCompCtrler.leadConvert.Legal_Local_Country__c !=null){ checkMissingAddress();

                    if(missingMandatoryAddressStr){
                        printError(System.Label.LM2_Missing_Required_Address_CHINAJAPAN);
                        return null;
                    }
                }
                
                else if(myCompCtrler.leadConvert.Country_CN__c != null){
                    If(myCompCtrler.leadConvert.Street_CN__c != null && !validateDoubleByte(myCompCtrler.leadConvert.Street_CN__c)) {
                        printError('Street Name must be in English');
                        return null;
                    }
                    If(myCompCtrler.leadConvert.City_CN__c != null && !validateDoubleByte(myCompCtrler.leadConvert.City_CN__c)) {
                        printError('City Name must be in English');
                        return null;
                    }
                    If(myCompCtrler.leadConvert.State_Province_CN__c != null  && !validateDoubleByte(myCompCtrler.leadConvert.State_Province_CN__c)) {
                        printError('State Name must be in English');
                        return null;
                    }
                    If(myCompCtrler.leadConvert.Zip_Postal_Code_CN__c != null  && !validateDoubleByte(myCompCtrler.leadConvert.Zip_Postal_Code_CN__c)) {
                        printError('Zip/Postal Code must be in English');
                        return null;
                    }
                }
                //v16.0 - start
                else if(myCompCtrler.leadConvert.Country_CN__c == null && myCompCtrler.leadConvert.Legal_Local_Country__c == null){
                    printError(System.Label.LM2_Missing_Required_Address_CHINAJAPAN);
                    return null;    
                }
                //v16.0 - end
            }
            else{
                //v16.0 
                if(myCompCtrler.leadConvert.Legal_Local_Country__c != null){
                    
                    checkMissingAddress();
                    
                    if(missingMandatoryAddressStr){
                        printError(System.Label.LM2_Missing_Required_Address_CHINAJAPAN);
                        return null;
                    }
                }
                
                else if(myCompCtrler.leadConvert.Country != null){
                    If(myCompCtrler.leadConvert.Street == null ) { printError('Street : You must enter a value'); return null;
                    }
                    else{
                        if(!validateDoubleByte(myCompCtrler.leadConvert.Street)) {    
                            printError('Street Name must be in English');
                            return null;
                        }
                    }
                    If(myCompCtrler.leadConvert.City != null && !validateDoubleByte(myCompCtrler.leadConvert.City)) {
                        printError('City Name must be in English');
                        return null;
                    }
                    If(myCompCtrler.leadConvert.State != null  && !validateDoubleByte(myCompCtrler.leadConvert.State)) {
                        printError('State Name must be in English');
                        return null;
                    }
                    
                    If(myCompCtrler.leadConvert.PostalCode != null  && !validateDoubleByte(myCompCtrler.leadConvert.PostalCode)) {
                        printError('Zip/Postal Code must be in English');
                        return null;
                    }
                }
                //v16.0 - start
                else if(myCompCtrler.leadConvert.Country == null && myCompCtrler.leadConvert.Legal_Local_Country__c == null){
                    printError(System.Label.LM2_Missing_Required_Address_CHINAJAPAN);
                    return null;    
                }
                //v16.0 - end
            }
            
            if(myCompCtrler.leadConvert.Country != null){ //v16.0
                Country__c countryObj = [Select id,code__c,Is_Active_in_Affinity__c from Country__c where Name =:myCompCtrler.leadConvert.Country ]; //v16.0
                if(!countryObj.Is_Active_in_Affinity__c){printError(System.Label.LM2_Select_Active_Country); 
                    //v10.0    
                    //printError('The selected country is not active in Affinity. Please select an active country. ');return null;
                }
            }
        }
        
        if((myCompCtrler.selectedAccount== 'NEW' || myCompCtrler.selectedAccount.startsWith('SUB-')) 
           && myCompCtrler.leadConvert.Territory_Assignment__c == null) {printError(System.Label.LM2_Required_Territory); return null;
            //v10.0
            // printError('Please choose a Territory.');
        }
        
        currentUser = StaticFactory.getCurrentUserDetails();
        leadOwner = StaticFactory.getUserDetails(myCompCtrler.contactId.ownerID);   
        String profileNameWithoutVersion = leadOwner.Profile.Name.replaceFirst('[Rr]{1}[0-9.]+[ ]{1}','');
       
        if(!leadOwner.Badge_Number__c.isNumeric()){
            //printError('The record owner you designated in prior step is not properly setup in the system, its badge number is invalid. Please, choose a different user or raise a trouble ticket to ensure that user has a correct badge number in its profile.');
            printError(System.Label.LM2_Owner_Error); //v10.0
            return null;
        }
        
        if(!profileList.contains(profileNameWithoutVersion)){
            //printError('Record owner for a new account must be a sales rep. Please select a user with Sales profile.');
            printError(System.Label.LM2_Sales_Record_Owner); // v10.0
            return null;
        }
        
        // 4.0 if subject is there but activitydata is null throw error
        if(!String.isBlank(myTaskCompCtrler.taskID.Subject) && myTaskCompCtrler.taskID.ActivityDate == null) {
            myTaskCompCtrler.taskID.ActivityDate.addError('If you want to create a follow up task you need to provide content under Task Information section for Subject, Due date, Priority and Status.');
            
            return null;
        }
        
        myCompCtrler.leadConvert.OwnerId= myCompCtrler.contactId.ownerID;
        system.debug('ZY: SelectedAccount: ' + myCompCtrler.selectedAccount);
        //If new account is to created, send req to affinity to check for any duplicates/suggestions
        if(myCompCtrler.selectedAccount == 'NEW' && !Test.isRunningTest()){ accountResponse = AccountSuggestionIntegrationCIL.sendAccountSuggestion(myCompCtrler.leadConvert, true);
         }
        //9.0
        else if (myCompCtrler.selectedAccount.startsWith('SUB-')){ Integer intStartIndex = myCompCtrler.selectedAccount.indexOf('#') + 1;
            string strParentAccountId = myCompCtrler.selectedAccount.substring(intStartIndex, myCompCtrler.selectedAccount.length());
            
            if(!Test.isRunningTest()) {
                accountResponse = AccountSuggestionIntegrationCIL.sendSubAccountSuggestion(myCompCtrler.leadConvert, true, strParentAccountId);
            }
        }
        //If affinity returns error print the same
        if(accountResponse != null && accountResponse.Error !=null ){ printError(checkAndReturnResponseError(accountResponse));
            return null;
        } 
        
        //If affinity returns duplicates navigate to a page with the list suggested by affinity
        if(accountResponse != null && accountResponse.accList != null && accountResponse.accList.size() >0 )
        {
            accountList = accountResponse.accList;
            selectedAccountId = null;
            PageReference pageRef = new PageReference( '/apex/duplicateAccountList?id='+leadId);
            pageRef.setRedirect(false);
            return pageRef; 
        }
        else if(accountResponse != null && (accountResponse.SuggestionId == '0' || String.isBlank(accountResponse.SuggestionId)) && accountResponse.Error ==null){printError(System.Label.LM2_Internal_Error); //v10.0
        }
        //If no duplicates, navigate to the newly created account page after standard conversion
        else{            
            PageReference pageRef = databaseConvert();
            return pageRef; 
        }
        return null;   
    }
    
    public pagereference databaseConvert(){
        updateLeadWithSalesFollowUpDays(leadToConvert);//7.1
        
        if(accountResponse != null && accountResponse.Error !=null ){printError(accountResponse.Error);
            return null;
        }
        
        // This is the lead convert object that will convert the lead 
        Database.LeadConvert leadConvert = new Database.LeadConvert();
        
        // Set lead ID
        leadConvert.setLeadId(leadToConvert.Id);
        // v1.1 - Ends : Updated order of condition checks to make it better.
        
        legacyId ='SFDC_'+leadToConvert.Id;
        
        // Otherwise set the account id
        if(myCompCtrler != NULL && myCompCtrler.selectedAccount != 'NEW' && !myCompCtrler.selectedAccount.startsWith('SUB-')) {
            leadConvert.setAccountId(myCompCtrler.selectedAccount);
        }
        //9.0 this one need to know how to handle
        //if duplicate account from affinity is selected, associate with the corresponding account in sf 
        else if((myCompCtrler.selectedAccount == 'NEW' || myCompCtrler.selectedAccount.startsWith('SUB-'))  && !String.isBlank(selectedAccountId)){
            list<Account> sfAccount = new list<Account>();
            sfAccount = [Select id from Account where Account_ID__c =: selectedAccountId and Account_ID__c!= null limit 1];
            if(sfAccount.size()> 0){
                leadConvert.setAccountId(sfAccount[0].id);
            }else{
                selectedAccountId= '';
               
                printError(System.Label.LM2_Account_Not_Available); //v10.0
                return null;
            }
        }
        
        
        //V1.7 Start        
        if(myCompCtrler.selectedContact !='NONE' && myCompCtrler.selectedContact !='NEW'){           
            leadConvert.setContactId(myCompCtrler.selectedContact);
            if(leadToConvert.Contact__c != NULL){
                leadConvert.setAccountId(leadToConvert.Contact__r.AccountId);
            } 
        }            
        //V1.7 End
        // Set the lead convert status
        leadConvert.setConvertedStatus(myCompCtrler.leadConvert.Status);
        
        // Set the variable to create or not create an opportunity
        // 6.0 //6.2
        if (myCompCtrler.oppty == 'New' || myCompCtrler.oppty == 'SmallDeal'){
            leadConvert.setDoNotCreateOpportunity(false);
            leadConvert.setOpportunityName(myCompCtrler.opportunityName);
        }
        else{leadConvert.setDoNotCreateOpportunity(true);
        }
        
        
        // Set the Opportunity name
        // v1.2 : Updated code to use opportunityName instead of Opportunity object.
        //leadConvert.setOpportunityName(((myCompCtrler.doNotCreateOppty) ? null : myCompCtrler.opportunityID.Name));
        
        // Set the owner id
        leadConvert.setOwnerId(myCompCtrler.contactId.ownerID);
        
        // Set whether to have a notification email
        leadConvert.setSendNotificationEmail(myCompCtrler.sendOwnerEmail);
        
        //v1.6
        // Convert the lead
        TriggerExecutionController.setSkipTaskTriggers(true);
        //6.0 //6.2
        if(myCompCtrler.oppty == 'New' || myCompCtrler.oppty == 'SmallDeal') {
            TriggerExecutionController.setSkipAccountTriggers(true);
            TriggerExecutionController.setSkipContactTriggers(true);
            TriggerExecutionController.setSkipLeadTriggers(true);
            //6.5
            TriggerExecutionController.setSkipOpportunityTriggers(true);
        }
        //6.0 set the opptyid ahead //17.0 start
        else if(myCompCtrler.oppty == 'Existing' && updateLeadWithLinkedOppty(leadToConvert.Id, myCompCtrler.strOpportunityId)) {
            return null;
            //17.0 End    
        }
        //13.0
        if(myCompCtrler.LeadConvert.Company!=null){
            leadToConvert.Company = myCompCtrler.LeadConvert.Company;
        }//13.0
          //21.0 
                if(leadToConvert.Contact__c != null){ 
                 listObjectNames = new List<string>();
                 listObjectNames.add('Contact');
                 SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
                 }
          //21.0 
        
        Database.LeadConvertResult leadConvertResult = Database.convertLead(leadConvert);
        
         //21.0
         if(leadToConvert.Contact__c != null){ ResetSystemBehaviorBypasser.resetSkipValidationRules(listObjectNames);}
        
        //6.0
        if(myCompCtrler.oppty == 'New' || myCompCtrler.oppty == 'SmallDeal') {
            //6.5
            TriggerExecutionController.setSkipOpportunityTriggers(false);
            TriggerExecutionController.setSkipLeadTriggers(false);
            TriggerExecutionController.setSkipContactTriggers(false);
            TriggerExecutionController.setSkipAccountTriggers(false);
        }
        TriggerExecutionController.setSkipTaskTriggers(false);
        
        
        // If the lead converting was a success then create a task
        // v7.0 Update department info from Lead to Contact
        if(leadConvertResult.success) {
            //v6.3 start 
            Account leadAccount;
            if (accountResponse != null && accountResponse.SuggestionId != '0' && !String.isBlank(accountResponse.SuggestionId)) {
                leadAccount = new Account(id=leadConvertResult.getAccountId(),Sales_Channel__c= myCompCtrler.leadConvert.Territory_Assignment__c, Legacy_id__c= legacyId, lead_id__c=leadToConvert.Id);
                leadAccount.Suggestion_ID__c =accountResponse.SuggestionId;
                leadAccount.Status__c = 'Inactive'; //14.1 
                populateMDMFields(leadAccount);
            }
            else
            {  //14.0 Removed the sales channel from the below statement.
                leadAccount = new Account(id=leadConvertResult.getAccountId(), lead_id__c=leadToConvert.Id);                
            }
            //v6.3 end
            
            //v1.6
            TriggerExecutionController.setSkipAccountTriggers(true);
            List<string> listObjectNames = new List<string>();//13.0
            listObjectNames.add('Account');//13.0
            SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);//13.0
            update leadAccount;
            ResetSystemBehaviorBypasser.resetSkipValidationRules(listObjectNames);//13.0
            TriggerExecutionController.setSkipAccountTriggers(false);
            
            //v13.1 create GDM Request after Lead convert sucess and for new Account/SubAccount            
            
            
            // Make sure that the task information component is being used and check to see if the user has filled out the Subject field 
            if(myTaskCompCtrler != NULL && myTaskCompCtrler.taskID.subject != null) {
                // Create a new task
                Task taskToCreate = new Task();
                
                // Set whether there is a reminder
                taskToCreate.IsReminderSet = myTaskCompCtrler.remCon.taskID.IsReminderSet;
                
                // If the reminder is set, and the reminder's date is set
                if(taskToCreate.IsReminderSet && myTaskCompCtrler.remCon.taskID.ActivityDate != null) {
                    // Set the reminder time based on the reminder class's ActivityDate
                    // The date and time in the reminder class is converted into a datetime by the convertToDatetime() method
                    taskToCreate.ReminderDateTime = convertToDatetime(myTaskCompCtrler.remCon.taskID.ActivityDate, myTaskCompCtrler.remCon.reminderTime);        
                }   
                
                // Set the whatId to the Opportunity Id            
                taskToCreate.WhatId = leadConvertResult.getOpportunityId();
                
                // Set the whoId to the contact Id
                taskToCreate.WhoId = leadConvertResult.getContactId();
                
                // Set the subject
                taskToCreate.Subject = myTaskCompCtrler.taskID.Subject;
                
                // Set the status
                taskToCreate.Status = myTaskCompCtrler.taskID.Status;
                
                // Set the activity date 
                taskToCreate.ActivityDate = myTaskCompCtrler.taskID.ActivityDate;
                
                // Set the Priority 
                taskToCreate.Priority = myTaskCompCtrler.taskID.Priority;
                
                // Set the custom field Primary Resource (this is a custom field on the Task showing an example of adding custom fields to the page)
                taskToCreate.Primary_Resource__c = myTaskCompCtrler.taskID.Primary_Resource__c;
                
                // Set the Description field which comes from the leadConvertTaskDescComponent
                // v1.1 : Commented usage of leadConvertTaskDescComponentController
                //taskToCreate.Description =  myDescriptionComponentController.taskID.Description;
                taskToCreate.Description =  myTaskCompCtrler.taskID.Description;
                
                // If the sendNotificationEmail variable in the leadConvertTaskDescComponent class is set then send an email
                // v1.1 : Commented usage of leadConvertTaskDescComponentController
                //if(myDescriptionComponentController.sendNotificationEmail) 
                
                    // create a new DMLOptions class instance
                    if(myTaskCompCtrler.sendNotificationEmail) { Database.DMLOptions dmlo = new Database.DMLOptions();
                    
                    // Set the trigger user email flag to true
                    dmlo.EmailHeader.triggerUserEmail = true;
                    
                    // Insert the task
                    TriggerExecutionController.setSkipTaskTriggers(true);
                    Database.insert(taskToCreate, dmlo);
                    TriggerExecutionController.setSkipTaskTriggers(false);
                }
                else {
                    // If the sendNotificationEmail field was not checked by the user then simply insert the task
                    TriggerExecutionController.setSkipTaskTriggers(true);
                    insert taskToCreate;
                    TriggerExecutionController.setSkipTaskTriggers(false);
                }
            }
            
            //v11.0
            PageReference pageRef = new PageReference( '/apex/leadConvertRefreshPage');
            pageRef.getParameters().put('id', leadToConvert.Id);
            pageRef.getParameters().put('contactId', leadConvertResult.getContactId());
            
            string optyId;
            if(myCompCtrler.oppty == 'New' || myCompCtrler.oppty == 'SmallDeal'){
               optyId = leadConvertResult.getOpportunityId();
            }else if(myCompCtrler.oppty == 'Existing') {
               optyId = myCompCtrler.strOpportunityId;
            }

            
            pageRef.getParameters().put('OpptyId', optyId);
            pageRef.getParameters().put('OpptyType', myCompCtrler.oppty);
            pageRef.getParameters().put('salesLoginUser', string.valueof(myCompCtrler.salesLoginUser));
            pageRef.getParameters().put('strOpptyDaysCreated',String.valueof(myCompCtrler.intOpptyDaysCreated));
            pageRef.setRedirect(true);
            return pageRef; 
           
        }
        else {
            
            //6.0 //17.0 start
            if(myCompCtrler.oppty == 'Existing' && updateLeadWithLinkedOppty(leadToConvert.Id, '')) {
                return null;
                //17.0 End    
            }
            // If converting was unsucessful, print the errors to the pageMessages and return null
            printErrors(leadConvertResult.errors);
        }
        
        return null;
    }
  //21.0  
 @TestVisible   private Boolean updateLeadWithLinkedOppty(string strLeadId, string strOpptyId) {
        Boolean isError = false;
        TriggerExecutionController.setSkipLeadTriggers(true); 
        
        Map<String, String> mapLeadToOpportunity = new Map<String, String>{strLeadId => strOpptyId};
        //Lead2OpptyAssnUtils.linkedOpptyWithLead(mapLeadToOpportunity);
        //17.0 Start
        Database.SaveResult[] objOpptyErrorList = Lead2OpptyAssnUtils.linkedOpptyWithLead(mapLeadToOpportunity);
        for (Database.SaveResult srList: objOpptyErrorList) {
            if (!srList.isSuccess()) {
                printErrors(srList.getErrors());
                isError = true;
            }
        }
        TriggerExecutionController.setSkipLeadTriggers(false);         
        return isError;
        //17.0 End
    } 
    //7.1
  @TestVisible private void updateLeadWithSalesFollowUpDays(lead leadToConvert){ 
        if (!(strPrevStatus.equals(leadToConvert.Status)) 
               && leadToConvert.Sales_Follow_up_days__c ==null 
               && leadToConvert.Assigned_to_Sales__c 
               && leadToConvert.First_time_assigned_to_Sales__c !=null){
            Lead objLeadToUpdate=new Lead(id=leadToConvert.Id);
            objLeadToUpdate.Sales_Follow_up_days__c=LeadFieldPopulator.calcSalesFollowUpDays(leadToConvert.First_time_assigned_to_Sales__c); 
            TriggerExecutionController.setSkipAllTriggers(true);
            try
            {
                Database.SaveResult srs = Database.update(objleadToUpdate);
            } catch (Exception e) {
                ApexPages.addMessages(e);
            }      
            TriggerExecutionController.setSkipAllTriggers(false);
        }
    } 
    // This method will take database errors and print them to the PageMessages 
    public void printErrors(Database.Error[] errors) {
        for(Database.Error error : errors) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, error.message);
            ApexPages.addMessage(msg);
        }
    }

    
    public pageReference goBack(){
        pageReference pageref = new pageReference('/'+leadId);
        //pageRef.setRedirect(false);
        return pageref;
    }
    
    public pagereference continueProcess(){
        pagereference pageref;
        //If none of the suggested duplicate account is selected, send a req to affinity to send a new suggestion id
        if(String.isBlank(selectedAccountId)){ accountResponse = AccountSuggestionIntegrationCIL.sendAccountSuggestion(myCompCtrler.leadConvert, false);
            
            pageref = databaseConvert();
            return pageref;
        }
        //if a suggested duplicate is selected, convert the lead to an existing account.
        else{
            pageref = databaseConvert();
            return pageref;
        }
        return null;
    }
    
    
    // This method will put an error into the PageMessages on the page
    public void printError(String error) {
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, error);
        ApexPages.addMessage(msg);
    }
    
    // Given a date and time, where time is a String this method will return a DateTime
//21.0  
  @TestVisible  private DateTime convertToDatetime(Date d, String t) {
        String timeFormat = DateTimeUtility.LocaleToTimeFormatMap().get(UserInfo.getLocale());
        
        // If the local of the user uses AM/PM 
        if(timeFormat != null && timeFormat.endsWith('a')) {
            // Split the time into 2 strings 1 time and 1 am r pm
            String [] reminderTime = t.split(' ');
            
            // Split the time into hour and minute
            String hour = reminderTime[0].split(':')[0];
            String min = reminderTime[0].split(':')[1];
            
            // Get the am or pm
            String amPM = reminderTime[1];
            
            // Turn the hour into an Integer
            Integer hr = Integer.valueOf(hour);
            
            // If the am/pm part of the String is PM then add 12 hours
            if(amPM.equalsIgnoreCase('PM')){hr += 12;}
            
            
            // Return a new DateTime based on the above information
            return (DateTime.newInstance(d, Time.newInstance(hr, Integer.valueOf(min), 0, 0))); 
        }
        // If the user's local does not use AM/PM and uses 24 hour time
        else {
            // Split the time by a : to get hour and minute
            String hour = t.split(':')[0];
            String min = t.split(':')[1];
            
            // Turn the hour into an Integer
            Integer hr = Integer.valueOf(hour);
            
            // Return a new DateTime based on the above information
            return (DateTime.newInstance(d, Time.newInstance(hr, Integer.valueOf(min), 0, 0)));
        }
    }
    
    // 6.2 for code coverage
    public string checkAndReturnResponseError(AccountSuggestionResponse accResponse)
    {
        string strError;
        if(accResponse.Error.containsIgnoreCase(ownerValidation)){
            strError = System.Label.LM2_Owner_Error; //v10.0
        }
        else if(accResponse.Error.containsIgnoreCase(legacyValidation)){
            strError = System.Label.LM2_Recreate_Lead; //v10.0
        }
        else if(accResponse.Error.containsIgnoreCase(regionValidation)){
            strError = System.Label.LM2_Wrong_Combination; //v10.0
        }
        else if(string.isBlank(accResponse.Error) || string.isEmpty(accResponse.Error)){strError = System.Label.LM2_Internal_Error; //v10.0
        }
        else{
            strError = accResponse.Error;
        }
        
        return strError;
        
    }
  
    //13.0 This method to map MDM fields to the Account
    public void populateMDMFields(Account leadAccount){
        //currentUser = StaticFactory.getCurrentUserDetails();
        list<Country__c> stdCountry=[Select Id,Name,region__c,code__c from Country__c Where Id=:myCompCtrler.LeadConvert.Country LIMIT 1]; //v16.0
        leadAccount.Name=myCompCtrler.LeadConvert.Company;
        leadAccount.NameLocal=myCompCtrler.LeadConvert.Legal_Local_Company_Name__c;
        if (currentUser.HR_Location_Country_Desc__c!=null && currentUser.HR_Location_Country_Desc__c.toUpperCase()=='CHINA'){
            leadAccount.BillingStreet=myCompCtrler.LeadConvert.Street_CN__c;
            leadAccount.BillingCity=myCompCtrler.LeadConvert.City_CN__c;
            leadAccount.BillingState=myCompCtrler.LeadConvert.State_Province_CN__c;
            leadAccount.BillingPostalCode=myCompCtrler.LeadConvert.Zip_Postal_Code_CN__c;
        }
        else{
            leadAccount.BillingStreet=myCompCtrler.LeadConvert.Street;
            leadAccount.BillingCity=myCompCtrler.LeadConvert.City;
            leadAccount.BillingState=myCompCtrler.LeadConvert.State;
            leadAccount.BillingPostalCode=myCompCtrler.LeadConvert.PostalCode;       
        }
        
        if(stdCountry.size()> 0){
            leadAccount.BillingCountry=stdCountry[0].Name;
            leadAccount.Region_Name__c = stdCountry[0].region__c;  //v13.1
            leadAccount.Country_Name__c = stdCountry[0].name;  //v13.1
        }
        leadAccount.Legal_Address_Street_Local__c=myCompCtrler.LeadConvert.Legal_Local_Address_1__c;
        leadAccount.Legal_Address_City_Local__c=myCompCtrler.LeadConvert.Legal_Local_City__c;
        leadAccount.Legal_Address_State_Province_Local__c=myCompCtrler.LeadConvert.Legal_Local_Postal_State__c;
        leadAccount.Legal_Address_Zip_Postal_Local__c=myCompCtrler.LeadConvert.Legal_Local_Postal_Code__c;
        leadAccount.Legal_Address_Country_Local__c=myCompCtrler.LeadConvert.Legal_Local_Country__c;       
    }
    //13.0 Validate Double byte characters in company and address fields
    public boolean validateDoubleByte(String addressField){
        String strAddressPattern=Label.Account_Name_Pattern;
        Pattern addressFieldsPattern = Pattern.compile(strAddressPattern);
        Matcher matcherInstance = addressFieldsPattern.matcher(addressField);
        
        return matcherInstance.matches();
    }
    
    //v16.0
    public void checkMissingAddress(){
        //Street
        if(myCompCtrler.LeadConvert.Legal_Local_Address_1__c == null){ 
            missingMandatoryAddressStr = true;
        }
        //City
        if(myCompCtrler.LeadConvert.Legal_Local_City__c == null){
            missingMandatoryAddressStr = true;
        }
        //PostalCode
        if(myCompCtrler.LeadConvert.Legal_Local_Postal_State__c == null ){
            missingMandatoryAddressStr = true;
        }         
    }
}