/*
Name: OpportunityRenewalExtension
Description: Extension of Opportunity class to submit approval

Revision    Release     Name        Date            Description 
1.0                     Ariff       02-Aug-2012     CR 7286
1.1                     Sheeba      12-Oct-2012     CR 7286
2.0         14.5        Fenny       15-May-2013     CR 8197 - implement CRQ0722 to fix SIT defect 67619
3.0         16.03       Manju       22-Dec-2014     CR 10827 - To allow any Sales user (Profile: All Sales profiles) to use the ‘Request renewal’ link.
4.0         16.03       Manju       02-Jan-2015     CR 10827 - To extend the Auto-renewal process to all related open parent/ child opportunities
5.0         24.0        Venkat      21-Dec-2016     CR 13862 - For APJ, LATAM & CA Region Accounts/Partner has to see only 1 checkbox with acknowledge statement.
                                                    CR 13861 - For US & EMEA region Accounts/ Partners-the deal should be auto approved.
                                                                (No need to go to Request Renewal Screen-3 out 5 check not needed) 
6.0                     Vasavi.M    01-Feb-2017     CR 13964 - SEAHWK project - Take out DSG related codes, commenting the part added under SNWL Migration project (ver 3.0 code)
7.0                     Rajashekar   07-Jun-2017     CR 14476 - Deal Reg: Remove Book Date validation from Request Extension process
                                                                (Commented out Request Extension = submitted part)
8.0         07.02       Mythily      21-jun-2017     CR  14535       To Fix Country Validation in Request Extension
9.0                     SrikanthG    20-Nov-2017    Story 4182260:Deal Reg: Extensions: Modify Deal Validity calculation when deal reg is extended
10.0                    Rajashekar   01-Feb-2018    Story 4565522:Deal Reg: Extensions: Deal Reg Extensions Code Clean up --- Commenting unused code related to Quote Check
11.0        0402        Wassim       29-Jan-2018    Story 4540475:Deal Reg: Extensions: Setup extension process for Deal Reg Analysts
*/

Public class OpportunityRenewalExtension { 
    public Opportunity opportunityObject;
    public string CurrentUserID;
    public boolean isPartnerUser;
    private String profileNameWithoutVersion;
    private List <Opportunity> lstOfOpptysToBeApprvd = new List <Opportunity>();
    public boolean opportunitySubmitted             {get; set;}
    public boolean isAvailableForAccess             {get;set;}
    public String previousPage                      {get;set;}
    public Boolean isDealRegAnalyst{get;set;}
  //public List <Opportunity> opportunityList       {get;set;}    Version 10.0 --- Quote check code cleanup
  //public Boolean isGC                             {get;set;}    Version 10.0 --- Quote check code cleanup
  //public Boolean isUS_EMEA                        {get;set;}    Version 10.0 --- Quote check code cleanup
  //public Boolean isAPJ_LATAM_CA                   {get;set;}    Version 10.0 --- Quote check code cleanup
    public Boolean isAPJ_LATAM_CA_Checked           {get;set;}
    public String US_EMEA_RnwSucMsg                 {get;set;}
  //public Boolean CountryExtensionStatus           {get;set;}    Version 10.0 --- Quote check code cleanup

    public OpportunityRenewalExtension(ApexPages.StandardController controller) {
        if (!Test.isRunningTest())
            controller.addFields(new String[] {'PartnerAccountID', 'Partner_Account_Country_Code__c', 'createddate'});

        currentUserID = UserInfo.GetUserID();
        try {
            User currentUser = [Select Profile_Name__c,Profile.Name, Contact.Account.Account_Country_Code__c from user where id =: currentUserID]; 
            isPartnerUser = currentUser.Profile_Name__c.Contains('Portal User') ? True: False; 
            isDealRegAnalyst = (currentUser.Profile.Name.Contains('GBL PRM Operations') || currentUser.Profile.Name.Contains('System Administrator')) ? True: False;  //11.0 
            opportunityObject = (Opportunity) controller.getRecord();
          
            previousPage = ApexPages.currentPage().getHeaders().get('Referer');
                
            SetPermissionRenewOpportunityPage();
               
          //secondaryAccessCheckOnRegions(); // Added by Venkateswarlu Chirala on 12/21/2016 for CR#13861 & 13862      ----    Version 10.0 --- Quote check code cleanup                        
        } catch (Exception e) { throw e; }
    }

    public void SetPermissionRenewOpportunityPage() {

        integer noOfRoles;
        if (isPartnerUser) {
            isAvailableForAccess = true;
        } else {   //Check for based on Account Team Member 
            noOfRoles = [SELECT count() FROM AccountTeamMember
                         WHERE accountID =: opportunityObject.AccountId AND userID =: currentUserID AND(TeamMemberRole =: 'Inside Sales Rep'
                                  OR TeamMemberRole =: 'Inside Sales Manager' OR  TeamMemberRole =: 'Account Executive' OR TeamMemberRole =: 'Regional Sales Manager')];
            //System.debug('Account Team :' + noOfRoles);

            //Check for based on Sales Team if the current is not from Account Team Member
            if (noOfRoles <= 0) {
                noOfRoles = [SELECT count() FROM OpportunityTeamMember WHERE OpportunityId =: opportunityObject.ID AND userID =: currentUserID
                             AND(TeamMemberRole =: 'Inside Sales Rep' OR TeamMemberRole =: 'Inside Sales Manager' OR TeamMemberRole =: 'Account Executive' OR TeamMemberRole =: 'Regional Sales Manager') ];
               // System.debug('Sales Team :' + noOfRoles);
            }

            //Ver 3.0 - To allow any Sales user (Profile: All Sales profiles) to use the ‘Request renewal’ link.
            /*Ver 6.0 - Comments this code as related to SNWL migration project */
            if (noOfRoles <= 0) {
                String strCurrentUserProfile = StaticFactory.getCurrentUserDetails().Profile.name;
                if (strCurrentUserProfile != null) {
                    profileNameWithoutVersion = strCurrentUserProfile.replaceFirst('[Rr]{1}[0-9.]+[ ]{1}', '');
                }
                Set <String> profileList = new Set <String> ();
                profileList.addAll(System.Label.DSG_Sales_Rep_Profiles.split(';'));
                if (profileList.size() > 0) {
                    if (profileNameWithoutVersion != null && profileList.contains(profileNameWithoutVersion)) {
                        noOfRoles = 1;
                    }
                }
            }
           /* Ver 6.0*/
            //Ver 3.0
            //11.0   included isDealRegAnalyst.
         isAvailableForAccess = (noOfRoles > 0 || isDealRegAnalyst ) ? True: False;
          

        }

        //11.0   included isDealRegAnalyst.
        if (isAvailableForAccess && (isDealRegAnalyst == false) ) {
            opportunitySubmitted =  (opportunityObject.Request_Status__c == 'New')? False: True;
     
       
        /*
            if (opportunityObject.Request_Status__c == 'New') {
                opportunitySubmitted = false;
            } else {
                opportunitySubmitted = true;
            }
            */
        }
    }
    
  
    //To submit opportunity for approval
    public PageReference SubmitAutoRenewal() {
        Opportunity newopportunityObject = [SELECT Deal_Expiration_Date__c,Request_Status__c FROM Opportunity WHERE Id =: opportunityObject.Id];
        Date expireDatenew = newopportunityObject.Deal_Expiration_Date__c;
        String RequestStatus = newopportunityObject.Request_Status__c;
        if((RequestStatus == 'New'&& expireDatenew <= System.Now().Date().addDays(30)) || (isDealRegAnalyst))   //11.0   included isDealRegAnalyst./to allow deal reg analyst to extend a deal multiple times
        {
        Database.SaveResult[] results;
        Opportunityobject.Bypass_Close_Date__c = True;

        //if (CheckForAutoApproval()) {      Version 10.0 --- Quote check code cleanup
            try {
                // Fenny : ver 2.0
                //Commented BY Srikanth Ganji for story 4182260
               /* if (opportunityObject.Submitter_Profile__c != null && opportunityObject.Submitter_Profile__c.toLowerCase().contains('na prm') ){
                    opportunityObject.Deal_Expiration_Date__c = System.Now().Date().addDays(Integer.valueOF(opportunityObject.Deal_Expiration_Timeframe__c));
                } else {
                    opportunityObject.Deal_Expiration_Date__c = expireDatenew.addDays(Integer.valueOF(opportunityObject.Deal_Expiration_Timeframe__c));
                }*/
                
                opportunityObject.Deal_Expiration_Date__c = expireDatenew.addDays(Integer.valueOF(opportunityObject.Deal_Expiration_Timeframe__c));
                opportunityObject.Request_Status__c = 'Approved';
                //-----Extnsion count logic
                                
                                if(opportunityObject.Deal_Extension_Count__c != null)
                                    opportunityObject.Deal_Extension_Count__c = opportunityObject.Deal_Extension_Count__c + 1;
                               else
                                   opportunityObject.Deal_Extension_Count__c = 1;
                                   
                               //-----Extnsion count logic
                               
                try {
                    update opportunityObject;
                }
                catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getdmlMessage(0))); US_EMEA_RnwSucMsg = NULL;
                    return NULL;
                }
                
                Integer limitCount = Limits.getLimitDMLRows() - Limits.getDMLRows();
                //Ver 4.0 - To extend the Auto-renewal process to all related open parent/ child opportunities
                Map <Id, Opportunity> mapOfOpptys = new Map <Id, Opportunity> ();
               // system.debug('$$opportunityObject.Related_Parent_Opportunity__c' + opportunityObject.Related_Parent_Opportunity__c);
                if (opportunityObject.Related_Parent_Opportunity__c != null  && String.valueof(opportunityObject.Related_Parent_Opportunity__c) != '') {
                   // system.debug('$$DEBUG in IF block');
                    mapOfOpptys = new Map <Id, Opportunity> ([SELECT Id, StageName, Deal_Extension_Count__c,Related_Parent_Opportunity__c, Submitter_Profile__c, Deal_Expiration_Date__c, Deal_Expiration_Timeframe__c FROM Opportunity
                                                              WHERE(Id =: opportunityObject.Related_Parent_Opportunity__c OR Related_Parent_Opportunity__c =: opportunityObject.Id 
                                                                    OR (Related_Parent_Opportunity__c =: opportunityObject.Related_Parent_Opportunity__c AND Id !=: opportunityObject.Id)) AND (StageName != 'Lost, Cancelled - 0%'
                                                                    AND StageName != 'Win - 100%')LIMIT: limitCount ]);
                } else {
                    //system.debug('$$DEBUG in Else block');
                    mapOfOpptys = new Map <Id, Opportunity>([SELECT Id, Deal_Extension_Count__c,StageName, Related_Parent_Opportunity__c, Submitter_Profile__c, Deal_Expiration_Date__c, Deal_Expiration_Timeframe__c FROM Opportunity
                                                             WHERE Related_Parent_Opportunity__c =: opportunityObject.Id AND (StageName != 'Lost, Cancelled - 0%' AND StageName != 'Win - 100%') LIMIT: limitCount]);
                }
                if (mapOfOpptys.size() > 0) {
                    for (Opportunity opp: mapOfOpptys.values()) {
                        
                        //Commented BY Srikanth Ganji for story 4182260
                       /* if (opp.Deal_Expiration_Timeframe__c != null) {
                            if (opp.Submitter_Profile__c != null && opp.Submitter_Profile__c.toLowerCase().contains('na prm')) {
                                opp.Deal_Expiration_Date__c = System.Now().Date().addDays(Integer.valueOF(opp.Deal_Expiration_Timeframe__c));
                            } else if (opp.Deal_Expiration_Date__c != null) {
                                Date expireDate = opp.Deal_Expiration_Date__c;
                                opp.Deal_Expiration_Date__c = expireDate.addDays(Integer.valueOF(opp.Deal_Expiration_Timeframe__c));
                            }
                        }*/
                        
                        if (opp.Deal_Expiration_Date__c != null) {
                                Date expireDate = opp.Deal_Expiration_Date__c;
                                opp.Deal_Expiration_Date__c = expireDate.addDays(Integer.valueOF(opp.Deal_Expiration_Timeframe__c));
                                
                                //-----Extnsion count logic
                                
                                if(opp.Deal_Extension_Count__c != null)
                                    opp.Deal_Extension_Count__c = opp.Deal_Extension_Count__c + 1;
                               else
                                   opp.Deal_Extension_Count__c = 1;
                                   
                               //-----Extnsion count logic
                               
                            }
                        opp.Request_Status__c = 'Approved';
                        lstOfOpptysToBeApprvd.add(opp);
                    }
                }
                if (!lstOfOpptysToBeApprvd.isEmpty()) {
                    results = Database.update(lstOfOpptysToBeApprvd, false);
                }
                if (results != null) {
                    for (Database.SaveResult result: results) {
                        if (!result.isSuccess()) {
                           // Database.Error[] errs = result.getErrors();
                            for (Database.Error err:  result.getErrors()) {
                               System.debug('Error while updating oppty:' + err.getStatusCode() + ' - ' + err.getMessage());
                            }
                        }
                    }
                }
                //Ver 4.0
            } catch (Exception ex) {
               // system.debug('Error:  ' + ex.GetMessage());
               // system.debug('Error:  ' + ex.getStackTraceString());
            }
       /*   Version 10.0 --- Quote check code cleanup Start */
       /* }
         else {
            
            //if(CheckForManualApproval()){
            //opportunityObject.Request_Status__c = 'Manually Approved';
            // }

           // system.debug('Manual Approve');
            //submit the opportunity to approval queue
            // Create an approval request for the opportunity
        /* Added by Rajashekar Version 7.0 
        opportunityObject.Request_Status__c = 'Submitted';
                try {
            update opportunityObject;
            }
            catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getdmlMessage(0)));
            US_EMEA_RnwSucMsg = NULL;
            return NULL;
            }

            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(opportunityObject.id);
            // Submit the approval request for the opportunity 
            try {   Approval.ProcessResult result = Approval.process(req1);
                //return new PageReference('/p/process/Submit?id=' + opportunityObject.id + '&retURL=%2F' + opportunityObject.id );  
            }
            catch(Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getdmlMessage(0)));
                US_EMEA_RnwSucMsg = NULL; return NULL;
            }         
         }    */    
         /*End Version 10.0 --- Quote check code cleanup     */
        }
        US_EMEA_RnwSucMsg = 'success';
        previousPage = ReturnToPreviousPage();
        return new PageReference(previousPage);

    }

    //To check opportunity met the requirement for approval
    //Return true if met requirement
    
       /*   Version 10.0 --- Quote check code cleanup Start */
       /* 
    public boolean CheckForAutoApproval() {

        boolean enabledForRenewal = false;
        Opportunity opporToCheck  = new Opportunity();
        opporToCheck = [SELECT Partner_Account_Country_Code__c ,accountID, stage_Updated__c, Close_Date_Updated__c, Next_Steps_Updated__c, Class_Logged_or_Notes_Entered__c, Update_to_Justification_Statement__c, 
                                        StageName, CloseDate, Is_close_date_changed__c, Partner_Opportunity_Stage__c FROM Opportunity where ID =: opportunityObject.id ];
        integer opportOptions = 0;
        if (opporToCheck.Partner_Account_Country_Code__c != null) {
            //  CR-14535  changed from opporToCheck.accountID to opporToCheck.PartnerAccountid to avoid country validation on enduser account
            Country__c countryRec = [Select Dell_Online_Country_Code__C, Enabled_Auto_Renewal__c From Country__C where Dell_Online_Country_Code__c =: opporToCheck.Partner_Account_Country_Code__c  or Code__c =: opporToCheck.Partner_Account_Country_Code__c ];
                    if(countryRec != null){
                        enabledForRenewal = BooleanUtils.isTrue(countryRec.Enabled_Auto_Renewal__C);
                    }
           }
        return enabledForRenewal;
        /* BookDate Validation is reomoved by Rajashekar Version 7.0
        //if enabled auto renewal is true and close date is greater than today - proceed with the next step, otherwise return false
        if (enabledForRenewal && (opporToCheck.CloseDate > System.now())) {
            //System.debug('Success first condition');
            // Added by Venkateswarlu Chirala on 21/12/2016 to doesn't applicable for for any countries( GC, US, EMEA, APJ, LATAM, CA regions)
           /* 
           if (isGC) { 
                if (opporToCheck.Class_Logged_or_Notes_Entered__c) {
                    opportOptions = opportOptions + 1;
                }
                
                if (opporToCheck.Next_Steps_Updated__c) {
                    opportOptions = opportOptions + 1;
                }

                if (opporToCheck.Update_to_Justification_Statement__c) {
                    opportOptions = opportOptions + 1;
                }

               // System.Debug('Options:' + opportOptions);
                if (opportOptions < 2) {
                    if (opporToCheck.stage_Updated__c) {
                        if (isPartnerUser) {
                            //System.Debug('current Stage:' + opporToCheck.Partner_Opportunity_Stage__c);
                            if (opporToCheck.Partner_Opportunity_Stage__c == 'Qualify - 30%' || opporToCheck.Partner_Opportunity_Stage__c == 'Propose - 60%' || opporToCheck.Partner_Opportunity_Stage__c == 'Commit - 90%') {
                                opportOptions = opportOptions + 1;
                              //  System.Debug('Partner Stage Updated');
                            }
                        } else {
                           // System.Debug('current Stage:' + opporToCheck.StageName);
                            if (opporToCheck.StageName == 'Qualify - 30%' || opporToCheck.StageName == 'Propose - 60%' || opporToCheck.StageName == 'Commit - 90%') {
                                opportOptions = opportOptions + 1;
                              // System.Debug('Stage Updated');
                            }
                        }
                    }

                    if (opporToCheck.Close_Date_Updated__c) {
                        //System.Debug('Is Close Date Changed 2:' + opporToCheck.Is_close_date_changed__c);
                        if (opporToCheck.Is_close_date_changed__c) {
                            opportOptions = opportOptions + 1;
                           // System.Debug('CLose Date Updated');
                        }
                    }
                }

               // System.Debug('Final OPtions:' + opportOptions);
                if (opportOptions >= 2) {
                    return True;
                } else {
                    return False;
                }
            } else return True;
         return True;
        } 
        else {
           // System.debug('Failed first condition');
            return false;
        }
        
    }
       /*   Version 10.0 --- Quote check code cleanup End */

    //Determine which page to return
    private string ReturnToPreviousPage() {
        List <string> urlArray = previousPage.split('/');  
            if (urlArray.size() > 3 && (urlArray[3].contains('fcf') || urlArray[3].contains('FCF'))) {
                previousPage = '/' + urlArray[3];
            } else {
                previousPage = '/' + opportunityObject.id;
            }
        return previousPage;
    }

    //Button click action
    public PageReference ButtonReturnToPreviousPage() {

        if (previousPage == '' || previousPage == null) {
            string host = ApexPages.currentPage().getHeaders().get('Host');
            return new PageReference('https://' + host + '/006/o');
        } else {
            return new PageReference(ReturnToPreviousPage());
        }
    }

       /*   Version 10.0 --- Quote check code cleanup Start */
       /* 

 /** 
  * @author Venkateswarlu Chirala
  * @date  21-Dec-2016
  * @description Called by the constructor to check RenewalExtension flow based on Region wise.
  *     For Greater China - user profiles has to show 5 checkboxes terms
  *     [CR#13862]For APJ, LATAM & CA Region Accounts/Partner has to see only 1 checkbox with acknowledge statement
  *     [CR#13861]For US & EMEA region Accounts/ Partners-the deal should be auto approved.(No need to go to Request Renewal Screen-3 out 5 check not needed) 
  * 
  @param N/A

    public void secondaryAccessCheckOnRegions() {

        if (isAvailableForAccess) { // check primary access 
            if (!opportunitySubmitted) { // checkc opportunitySubmitted or not
                 if (opportunityObject.ID <> NULL && opportunityObject.PartnerAccountID <> NULL && String.isNotBlank(opportunityObject.Partner_Account_Country_Code__c)) { // check for Non- GC 
                    List <Country__c> countryList = [SELECT Region__c FROM Country__c WHERE(Dell_Online_Country_Code__c =: opportunityObject.Partner_Account_Country_Code__c)
                                                                                         OR(Code__c =: opportunityObject.Partner_Account_Country_Code__c)];
                    if (!countryList.isEmpty()) {
                        Country__c countryRec = countryList[0];
                        ProdDate__c US_EMEA_Quote_Acc_date= ProdDate__c.getOrgDefaults();
                        //For using new label to globalise 
                        if(countryRec.Region__c.toUpperCase() == 'NA')
                    {
                        if(US_EMEA_Quote_Acc_date.Proddate__c != NULL && opportunityObject.createddate > = US_EMEA_Quote_Acc_date.Proddate__c )
                        {
                            if((System.Label.Quote_Check_For_NA.contains(opportunityObject.Partner_Account_Country_Code__c.toUpperCase()))){
                                setRegionFlags(False, True, False, True);
                            }else
                            {
                                setRegionFlags(False, False, True, True);
                            }
                        }
                        else{
            
                        setRegionFlags(False, False, True, True);
                        isAPJ_LATAM_CA_Checked = False;
                            }
                        
                    }else
                        if(countryRec.Region__c.toUpperCase() == 'APJ')
                    {
                        if(US_EMEA_Quote_Acc_date.Region_APJ__c != NULL && opportunityObject.createddate > = US_EMEA_Quote_Acc_date.Region_APJ__c)
                        {
                            if(System.Label.Quote_Check_For_APJ.contains(opportunityObject.Partner_Account_Country_Code__c.toUpperCase())){
                                setRegionFlags(False, True, False, True);
                            }else
                            {
                                setRegionFlags(False, False, True, True);
                            }
                        }
                        else{
            
                        setRegionFlags(False, False, True, True);  isAPJ_LATAM_CA_Checked = False;
                            }
                    }
            
                    else
                        if(countryRec.Region__c.toUpperCase() == 'LATAM' || Test.isRunningTest())
                    {
                        if(US_EMEA_Quote_Acc_date.Region_LATAM__c != NULL && opportunityObject.createddate > = US_EMEA_Quote_Acc_date.Region_LATAM__c || Test.isRunningTest())
                        {
                            if(System.Label.Quote_Check_For_LATAM.contains(opportunityObject.Partner_Account_Country_Code__c.toUpperCase()) || Test.isRunningTest()){ setRegionFlags(False, True, False, True);
                            }else { setRegionFlags(False, False, True, True);
                            }
                        } else{
                        setRegionFlags(False, False, True, True); isAPJ_LATAM_CA_Checked = False;
                            }
                        
                    }
            
                    else
                        if(countryRec.Region__c.toUpperCase() == 'EMEA'|| countryRec.Region__c.toUpperCase() == 'EC-EMEA')
                    {
                        if(US_EMEA_Quote_Acc_date.Region_EMEA__c != NULL && opportunityObject.createddate > = US_EMEA_Quote_Acc_date.Region_EMEA__c)
                        {
                            if(System.Label.ALL_EMEA_COUNTRIES.contains(opportunityObject.Partner_Account_Country_Code__c.toUpperCase())){ setRegionFlags(False, True, False, True);
                            }else{setRegionFlags(False, False, True, True); isAPJ_LATAM_CA_Checked = False;
                            }
                        }else{
                            setRegionFlags(False, False, True, True);
                            }
                }
                        
                        //--END--------
                    } else setRegionFlags(False, False, False, False); // if no country region specified set to no acess
                } else setRegionFlags(False, False, False, False); // None of above 3 region then set No access          
            } else {
                setRegionFlags(False, False, False, True);
            }
        } else setRegionFlags(False, False, False, False);
    }

 /** 
  * @author Venkateswarlu Chirala
  * @date  21-Dec-2016
  * @description Called by the "RenewOpportunity" VF action attribute to check autoApproveForUS_EMEA_Region Partner accounts deals.
  *     [CR#13861]For US & EMEA region Accounts/ Partners-the deal should be auto approved.(No need to go to Request Renewal Screen-3 out 5 check not needed) 
  * 
  @param N/A

    public pageReference autoApproveForUS_EMEA_Region() {
    
    
        if (isUS_EMEA <> NULL && isUS_EMEA )
            SubmitAutoRenewal();
        else{
            US_EMEA_RnwSucMsg = NULL;
            }

        return NULL;
    }

/** 
  * @author Venkateswarlu Chirala
  * @date  21-Dec-2016
  * @description Called by the secondaryAccessCheckOnRegions() to set RegionFlags
  * 
  *@param the isGC for Greater China region, US_EMEA region, APJ_LATAM_CA and isAvailableForAccess for screen acces

    public void setRegionFlags(Boolean isGC, Boolean isUS_EMEA, Boolean isAPJ_LATAM_CA, Boolean isAvailableForAccess) {
        this.isGC = isGC;
        this.isUS_EMEA = isUS_EMEA;
        this.isAPJ_LATAM_CA = isAPJ_LATAM_CA;
        this.isAvailableForAccess = isAvailableForAccess;
    }
    */
     /*   Version 10.0 --- Quote check code cleanup End */

   

}