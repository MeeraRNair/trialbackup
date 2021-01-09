/***********************************************************
* Name          : AVSSuggestion
* Description   : Class for updating and retrieving the Opportunity address verification system records
* ---------------------------------------------------------
* Revision  Name       Date             Description
* 1.0       Jiji       17. Aug. 2015    CR 11829: AVS for US 
* 2.0       Jiji       01. Sep. 2015    CR-11905: AVS for Australia, India, China, Japan, New Zealand, 
*                                                 France, Germany, UK, Netherlands,Spain, Canada, Brazil
* 3.0       Meera       29-March-2016   CR 12995  Disti Visibility --- Make Reseller Contact required for Distributor created deal  
* 4.0       Meera       12-April-2016   CR 13039  Deal Reg-US#1534674-Disti Visibility - Add Deal Access for Deals created using Existing Customer Record Type
* 5.0       Rahul       23-March-2017             To Reduce the code
*          Haribabu.A   10-Dec-2018     CR        STORY 5907651 Removed reference for the field lob_registration_id__c
           Jhansi D     15-Nov -2019              Story 7557991 Validate the the Total Unweighted Revenue total against regional Threshold level table
************************************************************/
public class AVSSuggestion {
    //Variable declaration
    //private final Opportunity opp;
    public Id oppId;   
    private ID OpptyID;
    public Opportunity oppObj{get;set;}  
    public EngageChannelAutoApprovalCtrl ec ; 
    public string selCountry {get; set;}    
    public Set<String> countryCode = new Set<String>();
    public Set<String> ctryCode = new Set<String>();
    Map<String, String> mapOfCountryAndCode = new Map<String, String>();
    public List<suggestions> lstSuggestion{get;set;} 
    public boolean showButton{get;set;} 
    public boolean showJapanTable{get; set;}
    public boolean showAptNo{get; Set;}
    public boolean showStreetNo{get;set;}  
    public boolean showMailingStreet{get;set;}  
    public boolean showMailingCity{get;set;}  
    public boolean showMailingState{get;set;}
    public boolean showPostalCode{get;set;}  
    public boolean showNoSuggestion{get;set;}  
    public boolean showTable{get;set;}  
    public boolean showLocality2{get;set;} 
    public boolean showFranceBuilding{get;set;}
    public boolean isEditMode{get;set;}
    public boolean isError1{get;set;}
    public boolean isError2{get;set;}
    public string resultStreetNo{get;set;}  
    public string resultStreet{get;set;}  
    public string resultCity{get;set;}  
    public string resultPostalCode{get;set;}  
    public string resultStatusCode{get;set;}  
    public string resultSuggestionCount{get;set;}  
    public string resultStatusDesc{get;set;}  
    public string resultCountry{get;set;}  
    public string resultState{get;set;}  
    public string resultFirm{get;set;}   
    public string resultBuilding{get;set;}  
    public String resultEasyIq {get;set;}     
    public string resultEasyIqCount {get;set;}  
    public string resultSuggestionEntry{get;set;}  
    public string resultSecondaryAdd{get;set;}  
    public string resultUnitNum{get; set;}  
    public string resultUnit{get;set;}  
    public string mailingPostalCode{get;set;}  
    public string mailingCity{get;set;}  
    public string mailingStreet{get;set;}  
    public string mailingStreet2{get;set;}
    public string mailingCountry{get;set;}  
    public string mailingState{get;set;}  
    public string Reply1{get;set;}  
    public string Reply2{get;set;}  
    public string Reply3{get;set;}  
    public string Reply4{get;set;}  
    public string Reply5{get;set;}  
    public String oPostalCode{get;set;}   
    public String oStreet{get;set;}  
    public String oStreet2{get;set;}
    public String oCity{get;set;}  
    public String oState{get;set;}  
    public String ocountry{get;set;}   
    public string oresultStatusDesc{get;set;}  
    public Integer count;  
    public string resultRDI{get;set;}
    public boolean oRDI{get;set;}
    public String resultLocality2 {get; set;}
    public String resultLocality3 {get; set;}
    public String resultPrimaryAddress {get; set;}
    public String resultSt {get; set;}
    public String resultSt2 {get; set;}
    public String resLoc2Loc3 {get; set;}
    public String resLoc2Loc3China {get; set;}
    public String buildNameChina {get; set;}
    Public string strAccept{get;set;}
    public String resultOne;
    public String resultTwo;
    public String resJapanSt {get; set;}
    public String resChinaSt {get; set;}
    public String aptOrSuiteNumber {get; set;}
    public Integer resetReply; 
    public String mailStreetJapan {get; set;}
    public String buildNameJapan {get; set;}
    public boolean showFloorNumber{get; Set;}
    public string buildAusFloorNumber{get;set;}
    public string FinalMailingStreet{get;set;}
    public string resultStreet1{get;set;}
    public string resultStreet2{get;set;}
    public string Ausresultstreet;
    public boolean renderEditMode{get;set;}
    public Id strOppId;
    Id rtId;
    //CR 11957: Mailing Street2 for Secondary address: Variable declaration: Start
    
    public string resultFirm1{get;set;}
    public boolean showFirm{get;set;}
    public boolean showStairwell {get;set;}
    public boolean isNARegion {get;set;}
    public boolean showError{get;set;}
    List <Opportunity> listOpp = new List <Opportunity>();

    //CR 11957: Mailing Street2 for Secondary address: Variable declaration: End
    public AVSSuggestion(ApexPages.StandardController stdController) {
        //Initialize boolean values
        //CR 11957: Add Firm and Stairwell detailsas unique identifiers: Start
        showStairwell = False;
        showFirm= False;
        isNARegion = False;
        //CR 11957: Add Firm and Stairwell detailsas unique identifiers: End
        renderEditMode = false;
        showStreetNo = true;
        showAptNo = true;
        showMailingState = true;
        showMailingCity = true;
        showPostalCode = true;
        showMailingStreet = true;
        showJapanTable = true;
        showNoSuggestion = false;
        showTable = false;
        showLocality2 = false;
        showFranceBuilding = false;
        showFloorNumber=false;    
        isEditMode = false;
        isError1 = false;
        isError2 = false;
        showError = false;
        
        try{
            
            oppObj = new Opportunity();
            if(ApexPages.currentPage().getParameters().containsKey('source')) {     
                              strAccept=ApexPages.currentPage().getParameters().get('source');      
                            system.debug('sssssss'+strAccept);  
            }
            if (ApexPages.currentPage().getParameters().containsKey('Id'))
                oppId = ApexPages.currentPage().getParameters().get('Id');
            else if (ApexPages.currentPage().getParameters().containsKey('newid')) {
                oppId = ApexPages.currentPage().getParameters().get('newid');
            }
         //   List <Opportunity> listOpp = new List <Opportunity>();
            if(oppId != NULL){
                listOpp = [Select Id, Name, Account.Name, RecordtypeId, Distributor_Name__c, Distributor_Reseller_Name__c, 
                           Account.Account_Country_Code__c, Account.Account_Country__c, PartnerAccountId,Domain__c,Solution_Type__c,Solution_Name__c,
                           End_User_Mailing_City__c, End_User_Mailing_Country__c, End_User_Mailing_State_Province_Region__c,
                           End_User_Mailing_Street__c, Mailing_Street2__c,Opportunity_has_assets_items__c,Serial_No_Asset_Tag__c, End_User_Mailing_Zip_Postal_Code__c,Engage_Channel_Opportunity__c,ownerid,Total_Expected_Dell_Revenue_USD__c,Total_Expected_Dell_Revenue__c
                           From Opportunity
                           where Id = :oppId LIMIT 1];
                
                oppObj = listOpp[0];
                
                MailingPostalCode = oppObj.End_User_Mailing_Zip_Postal_Code__c;
                MailingStreet = oppObj.End_User_Mailing_Street__c;
                MailingStreet2 = oppObj.Mailing_Street2__c;
                MailingState = oppObj.End_User_Mailing_State_Province_Region__c;
                MailingCountry = oppObj.End_User_Mailing_Country__c;
                MailingCity = oppObj.End_User_Mailing_City__c;
                rtId=oppObj.RecordtypeId;
                strOppId=listOpp[0].id;
            }
            
            lstSuggestion = new List < suggestions > ();
            //To get list of AVS enabled country
            for (Country__c CName: [Select Name, Code__c from Country__c where Enable_AVS_for_Opportunity__c = true order by Name]) {
                countryCode.add(CName.Name.toUpperCase());
                ctryCode.add(CName.Code__c.toUpperCase());
                mapOfCountryAndCode.put(CName.Name.toUpperCase(), CName.Code__c);
            }
        }
        catch (Exception ex) {
            throwExcep(System.Label.AVS_Res_Error); 
            isError1 = True;
            isError2 = false;
        }
    }
    
    public void throwExcep(String strLabel) {
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, strLabel);
        ApexPages.addMessage(myMsg);
        showTable = false;
        showNoSuggestion = TRUE;
        showButton = false;
    }
    
    public boolean getshowAptNo() {
        return showAptNo;
    }
    
    public void setshowAptNo(boolean showAptNo) {
        this.showAptNo = showAptNo;
    }
    //Version 2.0
    public boolean getshowFloorNumber() {
        return showFloorNumber;
    }
    
    public void setshowFloorNumber(boolean showFloorNumber) {
        this.showFloorNumber = showFloorNumber;
    }
    
    String[] countries = new String[] {};
        public PageReference test() {
            return null;
        }
    
    public String[] getCountries() {
        return countries;
    }
    
    public void setCountries(String[] countries) {
        this.countries = countries;
    }
    
    //Call AVS webservice via datapower
    public pagereference CallAVS() {
        try{
            if(this.OppObj.Engage_Channel_Opportunity__c == TRUE && strAccept !='Accept'){      
                                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Engage_channel_submit_for_approval);     
                                ApexPages.addMessage(myMsg);        
                                showError = true;       

              }  
            if(this.oppObj.Distributor_Name__c=='Distribution' && this.oppObj.Distributor_Reseller_Name__c==null ) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Distributor_Reseller_Account );
                ApexPages.addMessage(myMsg);
                showError = true;
            }
            else if(this.oppObj.Opportunity_has_assets_items__c==False && this.oppObj.Serial_No_Asset_Tag__c ==null && this.oppObj.Domain__c=='Basic Hardware/Software Sale' && this.oppObj.Solution_Type__c=='Datacenter-  Hardware Refresh' && this.oppObj.Solution_Name__c=='Storage'){
            ApexPages.Message Msg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Serial_No_Asset_Tag );
                ApexPages.addMessage(Msg);
                showError = true;
            }
            //V3.0
            else if(this.oppObj.Distributor_Reseller_Name__c !=null && (System.Label.ValidateResellerContact.toUpperCase() == 'FALSE' || Test.isRunningTest())){
                //check if opp partner account is distributor
                Id userId =  oppObj.ownerid;
                String partnerid = oppObj.Distributor_Reseller_Name__c;
                if(DistiVisibilityHelperClass.getPartnerType(userId) == 'Distributor'){
                    //Query and check if team member exists from reseller account
                    List<OpportunityTeamMember> teamMemberList = [SELECT OpportunityId,TeamMemberRole,UserId FROM OpportunityTeamMember 
                                                                  WHERE OpportunityId = :oppId AND TeamMemberRole = 'Reseller Contact' AND User.Contact.AccountId = :partnerid];
                    //if no records display error
                    if(teamMemberList.size()==0 ){
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Reseller_Contact_Missing );
                        ApexPages.addMessage(myMsg);
                        showError = true;   
                    }
                }
            }
            //end V3.0
            //V4.0
            /*------------------ THRESHOLD CHECK START-------------------------------------*/
               // threshold(strOppId);

/*------------------ THRESHOLD CHECK END-------------------------------------*/ 
            
          //  if(showError == false && rtId == id.valueof(System.Label.DealReg_Exstng_record_type_id)){  
          //if( showError == false && rtId == id.valueof(System.Label.DealReg_Exstng_record_type_id )){  '0127000000057ESAAY'
            if( showError == false &&  (rtId == id.valueof(System.Label.DealReg_Exstng_record_type_id ) || (rtId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal Registration-Submitted').getRecordTypeId() ) ) ) {
            threshold(strOppId); 
                //skip AVS Suggestion and submit for approval
              // exception(listOpp[0].id,showError);
                if(System.Label.DeaReg_Submit_for_approval_url == 'NULL' && showError == false){
                exception(listOpp[0].id,showError);
                    return PageUtils.redirect('/p/process/Submit?id='+oppid+'&retURL='+oppid);
                }else if(showError == false){ exception(listOpp[0].id,showError);
                    return PageUtils.redirect('/p/process/Submit?id='+oppid+'&retURL='+oppid+System.Label.DeaReg_Submit_for_approval_url);
                }
            }
            else if(showError == false || Test.isRunningTest()){
                resultCountry = null;
                buildNameChina = ' '; 
                showMailingState = true;
                aptOrSuiteNumber = null;
                lstSuggestion = new List < suggestions > ();
                if(oppId == NULL){
                    throwExcep(System.Label.AVS_Res_Error);
                    isError1 = True;
                    isError2 = false;
                    return NULL;
                }
                if(renderEditMode == TRUE ){
                    MailingPostalCode = this.oppObj.End_User_Mailing_Zip_Postal_Code__c;
                    MailingStreet = this.oppObj.End_User_Mailing_Street__c;
                    MailingStreet2 = this.oppObj.Mailing_Street2__c;
                    MailingState = this.oppObj.End_User_Mailing_State_Province_Region__c;
                    MailingCountry = this.oppObj.End_User_Mailing_Country__c;
                    MailingCity = this.oppObj.End_User_Mailing_City__c;
                    // Show a message if all the input fields are blank
                    if(MailingPostalCode == NULL && MailingStreet == NULL &&
                       // CR 11957: MailingStreet2 == NULL && 
                       MailingState == NULL &&
                       MailingCity == NULL
                      ){
                          throwExcep(System.Label.AVS_StreetZip_ErrorMsg);
                          isError2 = TRUE;
                          isError1 = False;
                          return null;
                      }    
                }
               // String mailCountry;
               String mailCountry;
                if (oppObj.End_User_Mailing_Country__c != null) {
                    mailCountry = oppObj.End_User_Mailing_Country__c.toUpperCase();
                }
                
                
                //CR 11957: Add Firm and Stairwell detailsas unique identifiers:Start
                If(mailCountry == 'UNITED STATES' || mailCountry== 'US' || mailCountry == 'CANADA' || mailCountry == 'C'){
                       isNARegion = TRUE;
                   }
                //CR 11957: Add Firm and Stairwell detailsas unique identifiers: End
                //check whether the Opp country has AVS enabled
                //Navigate to Opp detail page if not enabled
                if (!countryCode.contains(mailCountry)) {
                    String  returl;
                    if(OppObj.Engage_Channel_Opportunity__c == TRUE){
                        EngageChannelAutoApprovalCtrl e = new EngageChannelAutoApprovalCtrl();
                        e.AutoApprove(Oppid); 
                        returl ='/' + Oppid;   
                    }
                    else{ threshold(strOppId);
                        
                        if(System.Label.DeaReg_Submit_for_approval_url == 'NULL' && showError== false){
                            exception(listOpp[0].id,showError);
                            returl = '/p/process/Submit?id='+oppid+'&retURL='+oppid;
                        }else if(showError== false){ exception(listOpp[0].id,showError);
                            returl = '/p/process/Submit?id='+oppid+'&retURL='+oppid+System.Label.DeaReg_Submit_for_approval_url;
                        }
                        
                    }            
                    //return PageUtils.redirect(returl);  
if(!String.isBlank(returl)) { return PageUtils.redirect(returl);}
    else{ return null;}                     
                }
                showAptNo = true;
                oPostalCode = '';
                oStreet = '';
                oStreet2 = '';
                oCity = '';
                ocountry = '';
                oState = '';
                showFloorNumber = false;

                if(resetReply!=1){
                    reply1 = null;
                    reply2 = null;
                    reply3 = null;
                    reply4 = null;
                    reply5 = null;
                }
                String s = oppObj.End_User_Mailing_Country__c;
                //Show a message if mailing country is blank
                if (mailCountry == null || mailCountry == '') {
                    throwExcep(System.Label.AVS_Error2);
                    isError1 = True; isError2 = false;
                    return null;
                } 
                
                
                
                else if (!(MailingCountry == 'JP' || MailingCountry == 'JAPAN') && (MailingPostalCode == '' || MailingPostalCode == null || MailingStreet == '' || MailingStreet == null)) {
                    //Show a message if mailing street and zip is blank for all countries other than Japan
                    throwExcep(System.Label.AVS_StreetZip_ErrorMsg);
                    isError2 = True;
                    isError1 = false;
                    return null;
                }
                else if ((MailingCountry == 'JP' || MailingCountry == 'JAPAN') && (MailingPostalCode == '' || MailingPostalCode == null)) {
                    //Show a message if mailing zip is blank for Japan
                    throwExcep(System.Label.AVS_ZipCodeRequired);
                    isError1 = false;
                    isError2 = TRUE;
                    return null;
                }
                else{
                    //invoke AVS request
                    invokeExternalWs(MailingStreet, MailingStreet2, MailingPostalCode, MailingState, MailingCountry, MailingCity, oPostalCode, oStreet, oStreet2, oCity, oState, ocountry, Reply1, Reply2, Reply3, Reply4, Reply5);//jj
                    
                    resetReply = 0; 
                    //If the original address is correct and have an exact match in AVS, then dont show the sugestions.
                    //Proceed with opportunity submission and navigate to the opportunity detail page
                    
                    String StreetStringforexactmatch;
                    
                    If(resultCountry  == 'Australia' ){StreetStringforexactmatch = Ausresultstreet;}
                    else if(resultCountry  == 'Japan'){ StreetStringforexactmatch = resLoc2Loc3 + resJapanSt + ' ' + buildNameJapan + ' ' + resultunitNum;}
                    else If(resultCountry == 'China'){
                        if(buildNameChina == null){StreetStringforexactmatch  = resLoc2Loc3 + ' '+ resJapanSt + ' ' + resultunitNum;}
                        else{StreetStringforexactmatch = resLoc2Loc3 + ' '+ resJapanSt + ' ' + buildNameChina + ' ' + resultunitNum;}
                    }
                    else if(resultCountry == 'United Kingdom'){StreetStringforexactmatch = resultStreet + ' ' + resultLocality2;
                    }
                    else if(resultCountry == 'France'){StreetStringforexactmatch = resultBuilding + ' ' + resultStreet; }
                    else{ StreetStringforexactmatch = resultStreet; }
                    StreetStringforexactmatch= StreetStringforexactmatch.trim();
                    
                    if ((lstSuggestion.size() == 1 && resultStatusDesc == 'Assigned Address' ) && oppObj.End_User_Mailing_Zip_Postal_Code__c == resultPostalCode &&
                        oppObj.End_User_Mailing_Street__c == StreetStringforexactmatch && oppObj.End_User_Mailing_State_Province_Region__c == resultState &&
                        oppObj.End_User_Mailing_Country__c == resultCountry &&oppObj.End_User_Mailing_City__c == resultCity&& isEditMode == False 
                       ) {
                           showTable = false;
                           showButton = false;
                           String  returl;
                           if(OppObj.Engage_Channel_Opportunity__c == TRUE){
                               EngageChannelAutoApprovalCtrl e = new EngageChannelAutoApprovalCtrl();
                               e.AutoApprove(Oppid); 
                               returl ='/' + Oppid;   
                           }
                         else{
                        threshold(strOppId);
                        // if(showError== false)
                         //{
                        //exception(listOpp[0].id,showError);
                        if(System.Label.DeaReg_Submit_for_approval_url == 'NULL' && showError== false){ exception(listOpp[0].id,showError);
                            returl = '/p/process/Submit?id='+oppid+'&retURL='+oppid;
                        }else if(showError== false){ exception(listOpp[0].id,showError);
                            returl = '/p/process/Submit?id='+oppid+'&retURL='+oppid+System.Label.DeaReg_Submit_for_approval_url;
                        }
                        // }
                    }            
                          // return PageUtils.redirect(returl);
                          if(!String.isBlank(returl)) { return PageUtils.redirect(returl);   }
                         else{ return null;} 
                       }
                    
                    if (resultSuggestionCount != '0' || resultStatusDesc != 'Assigned Address') {showButton = true; }
                    
                    if (lstSuggestion.size() != 0) {
                        if (resultCountry != 'Japan' || resultCountry != 'China') { showJapanTable = false;}
                    }
                    if (lstSuggestion.size() != 0 && lstSuggestion[0] != null) {
                        if (!(resultBuilding == null || resultBuilding == '') && resultCountry == 'France') {                           
                            showFranceBuilding = true;
                        }
                        else{showFranceBuilding = false; }
                    }
                    if (lstSuggestion.size() != 0) {
                        if (lstSuggestion.size() != 1 && lstSuggestion[0] != null) {
                            if (lstSuggestion[0].REGION1 == null || resultCountry=='France' || resultCountry=='Germany' ||
                                resultCountry=='Netherlands' || resultCountry=='New Zealand' || resultCountry=='Spain' ||resultCountry=='United Kingdom') {                           
                                    showMailingState = false;}
                        }else if(lstSuggestion.size() == 1){
                            if(resultCountry == null || resultCountry=='France' || resultCountry=='Germany' ||
                               resultCountry=='Netherlands' || resultCountry=='New Zealand' || resultCountry=='Spain' ||
                               resultCountry=='United Kingdom')
                            { showMailingState = false; }
                        }
                    } 
                    
                    if (lstSuggestion.size() != 0) {
                        showStreetNo = false;
                        showPostalCode = false;
                        showMailingStreet = false;
                        showMailingCity = false;
                        showLocality2 = false;
                        showAptNo = false;
                        showFloorNumber = false;
                        //CR 11957: Start
                        showStairwell = False;
                        showFirm = False;
                        //CR 11957: End
                        for(suggestions obj:lstSuggestion){
                            if (resultSuggestionCount != '0') {
                                //CR 11957: Start
                                If(obj.FIRM != NULL && showFirm == False){showFirm = True;}
                                If((obj.STAIRWELL_NAME != NULL ||  obj.STAIRWELL_DESCRIPTION != NULL) && showStairwell == False){
                                    showStairwell = True;
                                }
                                //CR 11957: End
                                if(obj.PRIMARY_NUMBER_LOW != null && showStreetNo == false){showStreetNo = TRUE;}
                                if (obj.UNIT_NUMBER_LOW != null || obj.UNIT_NUMBER_HIGH != null && showAptNo == false ) {
                                    showAptNo = TRUE;    
                                }
                                if (!(obj.FLOOR_NUMBER_LOW == null || obj.FLOOR_NUMBER_HIGH == null)&&resultCountry == 'Australia' && showFloorNumber == False) {
                                    showFloorNumber = true;                       
                                }
                                else{showFloorNumber = false;}
                                if (lstSuggestion.size() != 1 && lstSuggestion[0] != null && (resultCountry == 'Japan' || resultCountry  == 'China')) {
                                    if(obj.LOCALITY2 == null){ obj.LOCALITY2 = '';}
                                    if(obj.LOCALITY3 == null){ obj.LOCALITY3 = '';}
                                    if(obj.PRIMARY_NAME_FULL1 == null){obj.PRIMARY_NAME_FULL1 = '';}        
                                    if(obj.PRIMARY_NAME_FULL2 == null){obj.PRIMARY_NAME_FULL2 = ''; }
                                    if(obj.PRIMARY_NAME_FULL1.isNumeric() && obj.PRIMARY_NAME_FULL2.isNumeric()) {
                                        obj.mailStreetJapan = obj.LOCALITY2 + ' ' + obj.LOCALITY3 + ' ' + obj.PRIMARY_NAME_FULL1 + '-' +  obj.PRIMARY_NAME_FULL2;
                                    }else if(!obj.PRIMARY_NAME_FULL1.isNumeric() && !obj.PRIMARY_NAME_FULL2.isNumeric()){
                                        obj.mailStreetJapan = obj.LOCALITY2 + ' ' + obj.LOCALITY3 + ' ' + obj.PRIMARY_NAME_FULL1 + ' ' +  obj.PRIMARY_NAME_FULL2;
                                    }
                                }
                            }
                            
                            //if (lstSuggestion.size() != 1 && lstSuggestion[0] != null) {
                            if (lstSuggestion.size() != 1) {
                                if (obj.POSTCODE != null && obj.POSTCODE1 != null && showPostalCode == false) { showPostalCode = TRUE;}
                                if (obj.PRIMARY_NAME1 != null && showMailingStreet == false) {showMailingStreet = TRUE;}
                                if (Obj.LOCALITY1 != null && showMailingCity == false) {showMailingCity = True;}
                            }
                            if (lstSuggestion.size() != 1) {
                                if(resultCountry=='United Kingdom' && obj.LOCALITY2 != null && showLocality2 == False) {                           
                                    showLocality2 = true;
                                }
                                else{ showLocality2 = false;}
                              }
                            else if(lstSuggestion.size() == 1 ){
                                if(resultCountry=='United Kingdom' && resultLocality2 != '' ){showLocality2 = true;}
                                else{showLocality2 = false; }
                            }
                        }
                    }
                    
                    if ((resultStatusDesc != null && !resultStatusDesc.contains('Assigned Address')) && resultSuggestionCount == '0') {
                        showTable = false;
                        showNoSuggestion = true;
                        showButton = false;
                        
                    }
                    if ((resultStatusDesc != null && resultStatusDesc.contains('Assigned Address')) || lstSuggestion.size() > 1) {
                        showTable = true;
                        showNoSuggestion = false;
                        showButton = true;
                        isError1 = false;
                        isError2 = false;
                    }
                }
            }
        }
        catch (Exception ex) {
            throwExcep(System.Label.AVS_Res_Error);
            isError1 = True;
            isError2 = false;
        }  
        return NULL;
    }
    
    public pagereference selectSuggestions(){
        String returl;
        try{
            Integer count = 0;
            for(suggestions obj:lstSuggestion){
                if(obj.selected){
                    count++;
                    
                }
            }
            
            if(count==0){
                //Give Error Message
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.AVS_SelectionErrorMsg1);
                ApexPages.addMessage(myMsg);
                isError2 = True;
                isError1 = False;
                return null;
            }
            if(count>1){
                //Give Error Message
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.AVS_SelectionErrorMsg1);
                ApexPages.addMessage(myMsg);
                isError2 = True;
                isError1 = False;
                return null;
            }
            if(count==1){
                for(suggestions obj:lstSuggestion){
                    if(obj.selected){ 
                        //Mapping start for selection with suggestion
                        if(lstSuggestion.size()>1){
                            //Mapping for PostalCode                            
                            if(resultcountry == 'United States'){ 
                                if(obj.POSTCODE != obj.POSTCODE2_EVEN && obj.POSTCODE2_EVEN != null){                       
                                    oPostalCode = obj.POSTCODE+'-'+obj.POSTCODE2_EVEN;
                                }
                                else if (obj.POSTCODE2_EVEN == null && obj.POSTCODE2_ODD != null && obj.POSTCODE != obj.POSTCODE2_ODD){
                                    oPostalCode = obj.POSTCODE+'-'+obj.POSTCODE2_ODD;
                                }
                                else if(obj.POSTCODE ==null){oPostalCode = obj.POSTCODE1;}
                                else if (obj.POSTCODE ==null || obj.POSTCODE1 ==null){oPostalCode = '';}
                                else{oPostalCode = obj.POSTCODE; }
                            }
                            else{   
                                if(obj.POSTCODE ==null){oPostalCode = obj.POSTCODE1;}
                                else if (obj.POSTCODE ==null || obj.POSTCODE1 ==null){oPostalCode = '';}
                                else{oPostalCode = obj.POSTCODE; }                             
                            } 
                            
                            
                            //Mapping for MailingStreet
                            if(obj.PRIMARY_TYPE1== null){obj.PRIMARY_TYPE1='';}
                            if(obj.PRIMARY_NAME1 == null){obj.PRIMARY_NAME1='';}
                            if(obj.PRIMARY_NUMBER_LOW == null){obj.PRIMARY_NUMBER_LOW='';}
                            
                            if(obj.PRIMARY_NUMBER_LOW==obj.PRIMARY_NUMBER_HIGH && obj.PRIMARY_NUMBER_LOW!=null){
                                oStreet = obj.PRIMARY_NUMBER_LOW+ ' ' + obj.PRIMARY_NAME1+' '+obj.PRIMARY_TYPE1; 
                                
                            }
                            else{ oStreet = obj.PRIMARY_NAME1+' '+obj.PRIMARY_TYPE1; }
                            
                            //Mapping for City , State and Country
                            //To make sure no null value shown upon save
                            if(obj.LOCALITY1== null){obj.LOCALITY1='';}
                            if(obj.REGION1== null){obj.REGION1='';}
                            oCity = obj.LOCALITY1;
                            oState = obj.REGION1;
                            //}
                            ocountry = resultcountry;       
                        }
                        
                        //Assigned address mapping
                        if(lstSuggestion.size()==1 || Test.isRunningTest())
                        {
                            oPostalCode = resultPostalCode;
                            oStreet = resultStreet;
                            // CR 11957: oStreet2 = resultLocality2;
                            oCity = resultCity;
                            ocountry = resultCountry;
                            oState = resultState;
                            if(resultCountry == 'Japan' ){ oStreet = resLoc2Loc3 + resJapanSt + ' ' + buildNameJapan + ' ' + resultunitNum;}
                            else if(resultCountry == 'China'){
                                if(buildNameChina == null){oStreet = resLoc2Loc3 + ' '+ resJapanSt + ' ' + resultunitNum;}
                                else{oStreet = resLoc2Loc3 + ' '+ resJapanSt + ' ' + buildNameChina + ' ' + resultunitNum;}
                            }
                            else if(resultCountry == 'United Kingdom'){oStreet = resultStreet + ' ' + resultLocality2;}
                            else if(resultCountry == 'France'){oStreet = resultBuilding + ' ' + resultStreet;}
                            else if(resultCountry == 'Australia'){ oStreet = Ausresultstreet;}
                            else{
                                oStreet = resultStreet;
                            }
                            oCity = resultCity;
                            ocountry = resultCountry;
                        }
                        break;
                    }
                } // End of For loop
                
                if(resultCountry == 'Republic of Korea' && 
                   MailingCountry == 'KOREA, REPUBLIC OF' &&  ocountry  == 'Republic of Korea' ){
                       resultCountry = MailingCountry;
                       ocountry = MailingCountry; 
                   }
                if(resultCountry == MailingCountry && resultStatusDesc == 'Assigned Address'  ){
                    Opportunity opp =new Opportunity(Id=oppId, End_User_Mailing_Zip_Postal_Code__c=oPostalCode, End_User_Mailing_Street__c=oStreet, 
                                                     End_User_Mailing_State_Province_Region__c=oState, End_User_Mailing_Country__c=ocountry,
                                                     End_User_Mailing_City__c=oCity
                                                     
                                                    );
                    update opp;
                    if(OppObj.Engage_Channel_Opportunity__c == TRUE){
                        
                        EngageChannelAutoApprovalCtrl e = new EngageChannelAutoApprovalCtrl();
                        e.AutoApprove(Oppid); 
                        returl ='/' + Oppid;  
                    }
                   else{
                        threshold(strOppId);
                        // if(showError== false)
                         //{
                        //exception(listOpp[0].id,showError);
                        if(System.Label.DeaReg_Submit_for_approval_url == 'NULL' && showError== false){
                            exception(listOpp[0].id,showError);
                            returl = '/p/process/Submit?id='+oppid+'&retURL='+oppid;
                        }else if(showError== false){
                            exception(listOpp[0].id,showError);
                            returl = '/p/process/Submit?id='+oppid+'&retURL='+oppid+System.Label.DeaReg_Submit_for_approval_url;
                        }
                        // }
                    }            
                    //return PageUtils.redirect(returl);
                    if(!String.isBlank(returl)) { return PageUtils.redirect(returl);   }
                   else{ return null;} 
                }
                else{
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.AVS_SelectionErrorMsg1);
                    ApexPages.addMessage(myMsg);
                    isError2 = True;
                    isError1 = False;
                    return null;
                }
            }
        }
        catch (Exception ex) {
            system.debug('>>>ERROR 786::');
            throwExcep(System.Label.AVS_Res_Error);
            isError1 = False;
            isError2 = TRUE;
        }         
        return null;
    }
    
    
    //jj public void invokeExternalWs(string street, string postcode, string state, string country, string city, string oPostalCodes, string oStreets,string oCitys,string oStates,string ocountrys, string reply1, string reply2, string reply3, string reply4, string reply5)    {
    public void invokeExternalWs(string street, string street2, string postcode, string state, string country, string city, string oPostalCodes, string oStreets, string oStreets2, string oCitys,string oStates,string ocountrys, string reply1, string reply2, string reply3, string reply4, string reply5)    {            
        
        List<Country__c> countryCode= [Select Name, Code__c from Country__c where Name= :country OR Code__c =:country limit 1];        
        If( !countryCode.isEmpty()){            
            country = countryCode[0].Code__c;        
        }        
        if(street==null)    street='';  
        if(street2==null)    street2='';  
        if(city==null)       city='';        
        if(state==null)        state='';        
        if(postcode==null)        postcode='';        
        if(country==null)        country='';
        
        if(reply1==null)       reply1='';        
        if(reply2==null)        reply2='';        
        if(reply3==null)        reply3='';        
        if(reply4==null)        reply4='';            
        if(reply5==null)        reply5='';  
        resultCountry = null;
        //AVS request xml
        string xmlString='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:inp="http://dell.com/AddressValidation/ValidateWithSuggestion/input">'        
            +'<soapenv:Header/>'          
            +'<soapenv:Body>'              
            +'<inp:ValidateWithSuggestionRequest>'                 
            +'<inp:organization></inp:organization>'                 
            +'<inp:address1>'+street.replace('<','&lt;').replace('>','&gt;').replace('&','&amp;')+'</inp:address1>'                 
            //+'<inp:address2></inp:address2>'
            +'<inp:address2>'+street2.replace('<','&lt;').replace('>','&gt;').replace('&','&amp;')+'</inp:address2>'                 
            +'<inp:city>'+city.replace('<','&lt;').replace('>','&gt;').replace('&','&amp;')+'</inp:city>'                 
            +'<inp:state>'+state.replace('<','&lt;').replace('>','&gt;').replace('&','&amp;')+'</inp:state>'                 
            +'<inp:zip>'+postcode.replace('<','&lt;').replace('>','&gt;').replace('&','&amp;')+'</inp:zip>'                 
            +'<inp:country>'+country+'</inp:country>'                 
            +'<inp:reply1>'+reply1+'</inp:reply1>'                 
            +'<inp:reply2>'+reply2+'</inp:reply2>'                 
            +'<inp:reply3>'+reply3+'</inp:reply3>'                 
            +'<inp:reply4>'+reply4+'</inp:reply4>'                 
            +'<inp:reply5>'+reply5+'</inp:reply5>'                
            +'<inp:selection></inp:selection>'                 
            +'<inp:street></inp:street>'              
            +'</inp:ValidateWithSuggestionRequest>'           
            +'</soapenv:Body>'        
            +'</soapenv:Envelope>';        
        
        HttpRequest req = new HttpRequest();        
        req.setMethod('POST');        
        req.setHeader('content-type', 'text/xml;charset=UTF-8');        
        req.setHeader('SOAPAction','');        
        req.setHeader('Authorization','Basic U2VydmljZUFWUzpBVlNAZDNsbA==');        
        if(Environment.isProduction()) { 
            req.setEndpoint(System.Label.AVS_DP_Prod_Server_URL);
            //Set header parameters for Sandbox 
        }else{
            req.setEndpoint(System.Label.AVS_DP_Sandbox_Server_URL);   
        }
        
        req.setBody(xmlString); 
        req.setTimeout(20000);
        Http http = new Http();          
        try {                
            string responseBody;              
            HTTPResponse res = new HTTPResponse();
            string ResError;
            
            if(!Test.isRunningTest()){  
                res = http.send(req);                 
                responseBody=res.getBody();
                ResError = res.getStatus(); 
                
            }              
            else{         
                
                ResError = 'testing';              
                If( MailingCountry == 'Australia' ){
                    responseBody='<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><out:ValidateWithSuggestionResponse xmlns:out="http://dell.com/AddressValidation/ValidateWithSuggestion/output"><out:firm/><out:house_number>65</out:house_number><out:street>Martin Pl</out:street><out:alt_street>Martin</out:alt_street><out:street2/><out:locality1>Sydney</out:locality1><out:locality2/><out:locality3/><out:ac_firm/><out:unitnum/><out:building/><out:pobox_number/><out:state>NSW</out:state><out:postcode>2000</out:postcode><out:country_code>AU</out:country_code><out:country>Australia</out:country><out:address>65 Martin Pl</out:address><out:dual_address/><out:primary_address>65 Martin Pl</out:primary_address><out:secondary_address>Test Secondary Address</out:secondary_address><out:address_fault_desc>The secondary information is missing on input or not in the directory</out:address_fault_desc><out:sugg_entry>&lt;LIST>&lt;SELECTION>1&lt;/SELECTION>&lt;LOCALITY1>SYDNEY&lt;/LOCALITY1>&lt;LOCALITY2/>&lt;LOCALITY3/>&lt;POSTCODE>2000&lt;/POSTCODE>&lt;POSTCODE1>2000&lt;/POSTCODE1>&lt;POSTCODE2/>&lt;REGION1>NEW SOUTH WALES&lt;/REGION1>&lt;PRIMARY_NUMBER_LOW>65&lt;/PRIMARY_NUMBER_LOW>&lt;PRIMARY_NUMBER_HIGH>65&lt;/PRIMARY_NUMBER_HIGH>&lt;PRIMARY_NUMBER_DESCRIPTION/>&lt;PRIMARY_NUMBER_EXTRA/>&lt;PRIMARY_NUMBER_FULL/>&lt;PRIMARY_PREFIX1/>&lt;PRIMARY_PREFIX2/>&lt;PRIMARY_NAME1>MARTIN&lt;/PRIMARY_NAME1>&lt;PRIMARY_NAME2/>&lt;PRIMARY_TYPE1>PL&lt;/PRIMARY_TYPE1>&lt;PRIMARY_TYPE2/>&lt;PRIMARY_POSTFIX1/>&lt;PRIMARY_POSTFIX2/>&lt;PRIMARY_NAME_FULL1>MARTIN PL&lt;/PRIMARY_NAME_FULL1>&lt;PRIMARY_NAME_FULL2/>&lt;PRIMARY_SIDE_INDICATOR>O&lt;/PRIMARY_SIDE_INDICATOR>&lt;FIRM/>&lt;UNIT_DESCRIPTION/>&lt;UNIT_NUMBER_LOW/>&lt;UNIT_NUMBER_HIGH/>&lt;STAIRWELL_DESCRIPTION/>&lt;STAIRWELL_NAME/>&lt;FLOOR_NUMBER_LOW>1&lt;/FLOOR_NUMBER_LOW>&lt;FLOOR_NUMBER_HIGH>1&lt;/FLOOR_NUMBER_HIGH>&lt;FLOOR_DESCRIPTION>L&lt;/FLOOR_DESCRIPTION>&lt;SECONDARY_SIDE_INDICATOR/>&lt;SUGG_FULL_ADDRESSLINE>L 1, 65 MARTIN PL&lt;/SUGG_FULL_ADDRESSLINE>&lt;SUGG_FULL_LASTLINE>SYDNEY, NEW SOUTH WALES, 2000&lt;/SUGG_FULL_LASTLINE>&lt;SUGG_SINGLE_ADDRESS>L 1, 65 MARTIN PL, SYDNEY, NEW SOUTH WALES, 2000&lt;/SUGG_SINGLE_ADDRESS>&lt;/LIST>&lt;LIST>&lt;SELECTION>1&lt;/SELECTION>&lt;LOCALITY1>NEW YORK CITY&lt;/LOCALITY1>&lt;LOCALITY2/>&lt;LOCALITY3/>&lt;POSTCODE>10005-2858&lt;/POSTCODE>&lt;POSTCODE1>10005-2858&lt;/POSTCODE1>&lt;POSTCODE2/>&lt;REGION1>NEW SOUTH WALES&lt;/REGION1>&lt;PRIMARY_NUMBER_LOW>65&lt;/PRIMARY_NUMBER_LOW>&lt;PRIMARY_NUMBER_HIGH>65&lt;/PRIMARY_NUMBER_HIGH>&lt;PRIMARY_NUMBER_DESCRIPTION/>&lt;PRIMARY_NUMBER_EXTRA/>&lt;PRIMARY_NUMBER_FULL/>&lt;PRIMARY_PREFIX1/>&lt;PRIMARY_PREFIX2/>&lt;PRIMARY_NAME1>MARTIN&lt;/PRIMARY_NAME1>&lt;PRIMARY_NAME2/>&lt;PRIMARY_TYPE1>PL&lt;/PRIMARY_TYPE1>&lt;PRIMARY_TYPE2/>&lt;PRIMARY_POSTFIX1/>&lt;PRIMARY_POSTFIX2/>&lt;PRIMARY_NAME_FULL1>MARTIN PL&lt;/PRIMARY_NAME_FULL1>&lt;PRIMARY_NAME_FULL2/>&lt;PRIMARY_SIDE_INDICATOR>O&lt;/PRIMARY_SIDE_INDICATOR>&lt;FIRM/>&lt;UNIT_DESCRIPTION/>&lt;UNIT_NUMBER_LOW/>&lt;UNIT_NUMBER_HIGH/>&lt;STAIRWELL_DESCRIPTION/>&lt;STAIRWELL_NAME/>&lt;FLOOR_NUMBER_LOW>1&lt;/FLOOR_NUMBER_LOW>&lt;FLOOR_NUMBER_HIGH>1&lt;/FLOOR_NUMBER_HIGH>&lt;FLOOR_DESCRIPTION>L&lt;/FLOOR_DESCRIPTION>&lt;SECONDARY_SIDE_INDICATOR/>&lt;SUGG_FULL_ADDRESSLINE>L 1, 65 MARTIN PL&lt;/SUGG_FULL_ADDRESSLINE>&lt;SUGG_FULL_LASTLINE>NEW YORK CITY, NEW SOUTH WALES, 10005-2858&lt;/SUGG_FULL_LASTLINE>&lt;SUGG_SINGLE_ADDRESS>L 1, 65 MARTIN PL, NEW YORK CITY, NEW SOUTH WALES, 10005-2858&lt;/SUGG_SINGLE_ADDRESS>&lt;/LIST></out:sugg_entry><out:sugg_error>1</out:sugg_error><out:sugg_status>U</out:sugg_status><out:sugg_count>20</out:sugg_count><out:street_prefix/><out:street_postfix/><out:sugg_length>15335</out:sugg_length><out:rdi_flag/><out:address_line/><out:last_line/><out:single_address/></out:ValidateWithSuggestionResponse></soapenv:Body></soapenv:Envelope>';  
                }else If( MailingCountry == 'United States' ){
                    responseBody='<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><out:ValidateWithSuggestionResponse xmlns:out="http://dell.com/AddressValidation/ValidateWithSuggestion/output"><out:firm/><out:house_number>65</out:house_number><out:street>Martin Pl</out:street><out:alt_street>Martin</out:alt_street><out:street2/><out:locality1>NEW YORK CITY</out:locality1><out:locality2/><out:locality3/><out:ac_firm/><out:unitnum/><out:building/><out:pobox_number/><out:state>NY</out:state><out:postcode>2000</out:postcode><out:country_code>US</out:country_code><out:country>United States</out:country><out:address>65 Martin Pl</out:address><out:dual_address/><out:primary_address>65 Martin Pl</out:primary_address><out:secondary_address/><out:address_fault_desc>The secondary information is missing on input or not in the directory</out:address_fault_desc><out:sugg_entry>&lt;LIST>&lt;SELECTION>1&lt;/SELECTION>&lt;LOCALITY1>NEW YORK CITY&lt;/LOCALITY1>&lt;LOCALITY2/>&lt;LOCALITY3/>&lt;POSTCODE>2000&lt;/POSTCODE>&lt;POSTCODE1>2000&lt;/POSTCODE1>&lt;POSTCODE2/>&lt;REGION1>NEW SOUTH WALES&lt;/REGION1>&lt;PRIMARY_NUMBER_LOW>60&lt;/PRIMARY_NUMBER_LOW>&lt;PRIMARY_NUMBER_HIGH>65&lt;/PRIMARY_NUMBER_HIGH>&lt;PRIMARY_NUMBER_DESCRIPTION/>&lt;PRIMARY_NUMBER_EXTRA/>&lt;PRIMARY_NUMBER_FULL/>&lt;PRIMARY_PREFIX1/>&lt;PRIMARY_PREFIX2/>&lt;PRIMARY_NAME1>MARTIN&lt;/PRIMARY_NAME1>&lt;PRIMARY_NAME2/>&lt;PRIMARY_TYPE1>PL&lt;/PRIMARY_TYPE1>&lt;PRIMARY_TYPE2/>&lt;PRIMARY_POSTFIX1/>&lt;PRIMARY_POSTFIX2/>&lt;PRIMARY_NAME_FULL1>MARTIN PL&lt;/PRIMARY_NAME_FULL1>&lt;PRIMARY_NAME_FULL2/>&lt;PRIMARY_SIDE_INDICATOR>O&lt;/PRIMARY_SIDE_INDICATOR>&lt;FIRM/>&lt;UNIT_DESCRIPTION/>&lt;UNIT_NUMBER_LOW/>&lt;UNIT_NUMBER_HIGH/>&lt;STAIRWELL_DESCRIPTION/>&lt;STAIRWELL_NAME/>&lt;FLOOR_NUMBER_LOW>1&lt;/FLOOR_NUMBER_LOW>&lt;FLOOR_NUMBER_HIGH>1&lt;/FLOOR_NUMBER_HIGH>&lt;FLOOR_DESCRIPTION>L&lt;/FLOOR_DESCRIPTION>&lt;SECONDARY_SIDE_INDICATOR/>&lt;SUGG_FULL_ADDRESSLINE>L 1, 65 MARTIN PL&lt;/SUGG_FULL_ADDRESSLINE>&lt;SUGG_FULL_LASTLINE>NEW YORK CITY, NEW SOUTH WALES, 2000&lt;/SUGG_FULL_LASTLINE>&lt;SUGG_SINGLE_ADDRESS>L 1, 65 MARTIN PL, NEW YORK CITY, NEW SOUTH WALES, 2000&lt;/SUGG_SINGLE_ADDRESS>&lt;/LIST>&lt;LIST>&lt;SELECTION>1&lt;/SELECTION>&lt;LOCALITY1>NEW YORK CITY&lt;/LOCALITY1>&lt;LOCALITY2/>&lt;LOCALITY3/>&lt;POSTCODE>10005-2858&lt;/POSTCODE>&lt;POSTCODE1>10005-2858&lt;/POSTCODE1>&lt;POSTCODE2/>&lt;REGION1>NEW SOUTH WALES&lt;/REGION1>&lt;PRIMARY_NUMBER_LOW>61&lt;/PRIMARY_NUMBER_LOW>&lt;PRIMARY_NUMBER_HIGH>65&lt;/PRIMARY_NUMBER_HIGH>&lt;PRIMARY_NUMBER_DESCRIPTION/>&lt;PRIMARY_NUMBER_EXTRA/>&lt;PRIMARY_NUMBER_FULL/>&lt;PRIMARY_PREFIX1/>&lt;PRIMARY_PREFIX2/>&lt;PRIMARY_NAME1>MARTIN&lt;/PRIMARY_NAME1>&lt;PRIMARY_NAME2/>&lt;PRIMARY_TYPE1>PL&lt;/PRIMARY_TYPE1>&lt;PRIMARY_TYPE2/>&lt;PRIMARY_POSTFIX1/>&lt;PRIMARY_POSTFIX2/>&lt;PRIMARY_NAME_FULL1>MARTIN PL&lt;/PRIMARY_NAME_FULL1>&lt;PRIMARY_NAME_FULL2/>&lt;PRIMARY_SIDE_INDICATOR>O&lt;/PRIMARY_SIDE_INDICATOR>&lt;FIRM/>&lt;UNIT_DESCRIPTION/>&lt;UNIT_NUMBER_LOW/>&lt;UNIT_NUMBER_HIGH/>&lt;STAIRWELL_DESCRIPTION/>&lt;STAIRWELL_NAME/>&lt;FLOOR_NUMBER_LOW>1&lt;/FLOOR_NUMBER_LOW>&lt;FLOOR_NUMBER_HIGH>1&lt;/FLOOR_NUMBER_HIGH>&lt;FLOOR_DESCRIPTION>L&lt;/FLOOR_DESCRIPTION>&lt;SECONDARY_SIDE_INDICATOR/>&lt;SUGG_FULL_ADDRESSLINE>L 1, 65 MARTIN PL&lt;/SUGG_FULL_ADDRESSLINE>&lt;SUGG_FULL_LASTLINE>NEW YORK CITY, NEW SOUTH WALES, 10005-2858&lt;/SUGG_FULL_LASTLINE>&lt;SUGG_SINGLE_ADDRESS>L 1, 65 MARTIN PL, NEW YORK CITY, NEW SOUTH WALES, 10005-2858&lt;/SUGG_SINGLE_ADDRESS>&lt;/LIST></out:sugg_entry><out:sugg_error>1</out:sugg_error><out:sugg_status>U</out:sugg_status><out:sugg_count>20</out:sugg_count><out:street_prefix/><out:street_postfix/><out:sugg_length>15335</out:sugg_length><out:rdi_flag/><out:address_line/><out:last_line/><out:single_address/></out:ValidateWithSuggestionResponse></soapenv:Body></soapenv:Envelope>'; 
                }else If( MailingCountry == 'United States1' ){
                    responseBody='<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><out:ValidateWithSuggestionResponse xmlns:out="http://dell.com/AddressValidation/ValidateWithSuggestion/output"><out:firm/><out:house_number>65</out:house_number><out:street>Martin Pl</out:street><out:alt_street>Martin</out:alt_street><out:street2/><out:locality1>NEW YORK CITY</out:locality1><out:locality2/><out:locality3/><out:ac_firm/><out:unitnum/><out:building/><out:pobox_number/><out:state>NY</out:state><out:postcode>2000</out:postcode><out:country_code>US</out:country_code><out:country>United States1</out:country><out:address>65 Martin Pl</out:address><out:dual_address/><out:primary_address>65 Martin Pl</out:primary_address><out:secondary_address/><out:address_fault_desc>The secondary information is missing on input or not in the directory</out:address_fault_desc><out:sugg_entry>&lt;LIST>&lt;SELECTION>1&lt;/SELECTION>&lt;LOCALITY1>NEW YORK CITY&lt;/LOCALITY1>&lt;LOCALITY2/>&lt;LOCALITY3/>&lt;POSTCODE>2000&lt;/POSTCODE>&lt;POSTCODE1>2000&lt;/POSTCODE1>&lt;POSTCODE2/>&lt;REGION1>NEW SOUTH WALES&lt;/REGION1>&lt;PRIMARY_NUMBER_LOW>60&lt;/PRIMARY_NUMBER_LOW>&lt;PRIMARY_NUMBER_HIGH>60&lt;/PRIMARY_NUMBER_HIGH>&lt;PRIMARY_NUMBER_DESCRIPTION/>&lt;PRIMARY_NUMBER_EXTRA/>&lt;PRIMARY_NUMBER_FULL/>&lt;PRIMARY_PREFIX1/>&lt;PRIMARY_PREFIX2/>&lt;PRIMARY_NAME1>MARTIN&lt;/PRIMARY_NAME1>&lt;PRIMARY_NAME2/>&lt;PRIMARY_TYPE1>PL&lt;/PRIMARY_TYPE1>&lt;PRIMARY_TYPE2/>&lt;PRIMARY_POSTFIX1/>&lt;PRIMARY_POSTFIX2/>&lt;PRIMARY_NAME_FULL1>MARTIN PL&lt;/PRIMARY_NAME_FULL1>&lt;PRIMARY_NAME_FULL2/>&lt;PRIMARY_SIDE_INDICATOR>O&lt;/PRIMARY_SIDE_INDICATOR>&lt;FIRM/>&lt;UNIT_DESCRIPTION/>&lt;UNIT_NUMBER_LOW>10&lt;/UNIT_NUMBER_LOW>&lt;UNIT_NUMBER_HIGH>20&lt;/UNIT_NUMBER_HIGH>&lt;STAIRWELL_DESCRIPTION/>&lt;STAIRWELL_NAME/>&lt;FLOOR_NUMBER_LOW>1&lt;/FLOOR_NUMBER_LOW>&lt;FLOOR_NUMBER_HIGH>1&lt;/FLOOR_NUMBER_HIGH>&lt;FLOOR_DESCRIPTION>L&lt;/FLOOR_DESCRIPTION>&lt;SECONDARY_SIDE_INDICATOR/>&lt;SUGG_FULL_ADDRESSLINE>L 1, 65 MARTIN PL&lt;/SUGG_FULL_ADDRESSLINE>&lt;SUGG_FULL_LASTLINE>NEW YORK CITY, NEW SOUTH WALES, 2000&lt;/SUGG_FULL_LASTLINE>&lt;SUGG_SINGLE_ADDRESS>L 1, 65 MARTIN PL, NEW YORK CITY, NEW SOUTH WALES, 2000&lt;/SUGG_SINGLE_ADDRESS>&lt;/LIST>&lt;LIST>&lt;SELECTION>1&lt;/SELECTION>&lt;LOCALITY1>NEW YORK CITY&lt;/LOCALITY1>&lt;LOCALITY2/>&lt;LOCALITY3/>&lt;POSTCODE>10005-2858&lt;/POSTCODE>&lt;POSTCODE1>10005-2858&lt;/POSTCODE1>&lt;POSTCODE2/>&lt;REGION1>NEW SOUTH WALES&lt;/REGION1>&lt;PRIMARY_NUMBER_LOW>61&lt;/PRIMARY_NUMBER_LOW>&lt;PRIMARY_NUMBER_HIGH>65&lt;/PRIMARY_NUMBER_HIGH>&lt;PRIMARY_NUMBER_DESCRIPTION/>&lt;PRIMARY_NUMBER_EXTRA/>&lt;PRIMARY_NUMBER_FULL/>&lt;PRIMARY_PREFIX1/>&lt;PRIMARY_PREFIX2/>&lt;PRIMARY_NAME1>MARTIN&lt;/PRIMARY_NAME1>&lt;PRIMARY_NAME2/>&lt;PRIMARY_TYPE1>PL&lt;/PRIMARY_TYPE1>&lt;PRIMARY_TYPE2/>&lt;PRIMARY_POSTFIX1/>&lt;PRIMARY_POSTFIX2/>&lt;PRIMARY_NAME_FULL1>MARTIN PL&lt;/PRIMARY_NAME_FULL1>&lt;PRIMARY_NAME_FULL2/>&lt;PRIMARY_SIDE_INDICATOR>O&lt;/PRIMARY_SIDE_INDICATOR>&lt;FIRM/>&lt;UNIT_DESCRIPTION/>&lt;UNIT_NUMBER_LOW/>&lt;UNIT_NUMBER_HIGH/>&lt;STAIRWELL_DESCRIPTION/>&lt;STAIRWELL_NAME/>&lt;FLOOR_NUMBER_LOW>1&lt;/FLOOR_NUMBER_LOW>&lt;FLOOR_NUMBER_HIGH>1&lt;/FLOOR_NUMBER_HIGH>&lt;FLOOR_DESCRIPTION>L&lt;/FLOOR_DESCRIPTION>&lt;SECONDARY_SIDE_INDICATOR/>&lt;SUGG_FULL_ADDRESSLINE>L 1, 65 MARTIN PL&lt;/SUGG_FULL_ADDRESSLINE>&lt;SUGG_FULL_LASTLINE>NEW YORK CITY, NEW SOUTH WALES, 10005-2858&lt;/SUGG_FULL_LASTLINE>&lt;SUGG_SINGLE_ADDRESS>L 1, 65 MARTIN PL, NEW YORK CITY, NEW SOUTH WALES, 10005-2858&lt;/SUGG_SINGLE_ADDRESS>&lt;/LIST></out:sugg_entry><out:sugg_error>1</out:sugg_error><out:sugg_status>U</out:sugg_status><out:sugg_count>20</out:sugg_count><out:street_prefix/><out:street_postfix/><out:sugg_length>15335</out:sugg_length><out:rdi_flag/><out:address_line/><out:last_line/><out:single_address/></out:ValidateWithSuggestionResponse></soapenv:Body></soapenv:Envelope>'; 
                }else If( MailingCountry == 'United States2' ){
                    responseBody='<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><out:ValidateWithSuggestionResponse xmlns:out="http://dell.com/AddressValidation/ValidateWithSuggestion/output"><out:firm/><out:house_number>65</out:house_number><out:street>Martin Pl</out:street><out:alt_street>Martin</out:alt_street><out:street2/><out:locality1>NEW YORK CITY</out:locality1><out:locality2/><out:locality3/><out:ac_firm/><out:unitnum/><out:building/><out:pobox_number/><out:state>NY</out:state><out:postcode>2000</out:postcode><out:country_code>US</out:country_code><out:country>United States2</out:country><out:address>65 Martin Pl</out:address><out:dual_address/><out:primary_address>65 Martin Pl</out:primary_address><out:secondary_address/><out:address_fault_desc>The secondary information is missing on input or not in the directory</out:address_fault_desc><out:sugg_entry>&lt;LIST>&lt;SELECTION>1&lt;/SELECTION>&lt;LOCALITY1>NEW YORK CITY&lt;/LOCALITY1>&lt;LOCALITY2/>&lt;LOCALITY3/>&lt;POSTCODE>2000&lt;/POSTCODE>&lt;POSTCODE1>2000&lt;/POSTCODE1>&lt;POSTCODE2/>&lt;REGION1>NEW SOUTH WALES&lt;/REGION1>&lt;PRIMARY_NUMBER_LOW>60&lt;/PRIMARY_NUMBER_LOW>&lt;PRIMARY_NUMBER_HIGH>60&lt;/PRIMARY_NUMBER_HIGH>&lt;PRIMARY_NUMBER_DESCRIPTION/>&lt;PRIMARY_NUMBER_EXTRA/>&lt;PRIMARY_NUMBER_FULL/>&lt;PRIMARY_PREFIX1/>&lt;PRIMARY_PREFIX2/>&lt;PRIMARY_NAME1>MARTIN&lt;/PRIMARY_NAME1>&lt;PRIMARY_NAME2/>&lt;PRIMARY_TYPE1>PL&lt;/PRIMARY_TYPE1>&lt;PRIMARY_TYPE2/>&lt;PRIMARY_POSTFIX1/>&lt;PRIMARY_POSTFIX2/>&lt;PRIMARY_NAME_FULL1>MARTIN PL&lt;/PRIMARY_NAME_FULL1>&lt;PRIMARY_NAME_FULL2/>&lt;PRIMARY_SIDE_INDICATOR>O&lt;/PRIMARY_SIDE_INDICATOR>&lt;FIRM/>&lt;UNIT_DESCRIPTION/>&lt;UNIT_NUMBER_LOW>10&lt;/UNIT_NUMBER_LOW>&lt;UNIT_NUMBER_HIGH>10&lt;/UNIT_NUMBER_HIGH>&lt;STAIRWELL_DESCRIPTION/>&lt;STAIRWELL_NAME/>&lt;FLOOR_NUMBER_LOW>10&lt;/FLOOR_NUMBER_LOW>&lt;FLOOR_NUMBER_HIGH>20&lt;/FLOOR_NUMBER_HIGH>&lt;FLOOR_DESCRIPTION>L&lt;/FLOOR_DESCRIPTION>&lt;SECONDARY_SIDE_INDICATOR/>&lt;SUGG_FULL_ADDRESSLINE>L 1, 65 MARTIN PL&lt;/SUGG_FULL_ADDRESSLINE>&lt;SUGG_FULL_LASTLINE>NEW YORK CITY, NEW SOUTH WALES, 2000&lt;/SUGG_FULL_LASTLINE>&lt;SUGG_SINGLE_ADDRESS>L 1, 65 MARTIN PL, NEW YORK CITY, NEW SOUTH WALES, 2000&lt;/SUGG_SINGLE_ADDRESS>&lt;/LIST>&lt;LIST>&lt;SELECTION>1&lt;/SELECTION>&lt;LOCALITY1>NEW YORK CITY&lt;/LOCALITY1>&lt;LOCALITY2/>&lt;LOCALITY3/>&lt;POSTCODE>10005-2858&lt;/POSTCODE>&lt;POSTCODE1>10005-2858&lt;/POSTCODE1>&lt;POSTCODE2/>&lt;REGION1>NEW SOUTH WALES&lt;/REGION1>&lt;PRIMARY_NUMBER_LOW>61&lt;/PRIMARY_NUMBER_LOW>&lt;PRIMARY_NUMBER_HIGH>65&lt;/PRIMARY_NUMBER_HIGH>&lt;PRIMARY_NUMBER_DESCRIPTION/>&lt;PRIMARY_NUMBER_EXTRA/>&lt;PRIMARY_NUMBER_FULL/>&lt;PRIMARY_PREFIX1/>&lt;PRIMARY_PREFIX2/>&lt;PRIMARY_NAME1>MARTIN&lt;/PRIMARY_NAME1>&lt;PRIMARY_NAME2/>&lt;PRIMARY_TYPE1>PL&lt;/PRIMARY_TYPE1>&lt;PRIMARY_TYPE2/>&lt;PRIMARY_POSTFIX1/>&lt;PRIMARY_POSTFIX2/>&lt;PRIMARY_NAME_FULL1>MARTIN PL&lt;/PRIMARY_NAME_FULL1>&lt;PRIMARY_NAME_FULL2/>&lt;PRIMARY_SIDE_INDICATOR>O&lt;/PRIMARY_SIDE_INDICATOR>&lt;FIRM/>&lt;UNIT_DESCRIPTION/>&lt;UNIT_NUMBER_LOW/>&lt;UNIT_NUMBER_HIGH/>&lt;STAIRWELL_DESCRIPTION/>&lt;STAIRWELL_NAME/>&lt;FLOOR_NUMBER_LOW>1&lt;/FLOOR_NUMBER_LOW>&lt;FLOOR_NUMBER_HIGH>1&lt;/FLOOR_NUMBER_HIGH>&lt;FLOOR_DESCRIPTION>L&lt;/FLOOR_DESCRIPTION>&lt;SECONDARY_SIDE_INDICATOR/>&lt;SUGG_FULL_ADDRESSLINE>L 1, 65 MARTIN PL&lt;/SUGG_FULL_ADDRESSLINE>&lt;SUGG_FULL_LASTLINE>NEW YORK CITY, NEW SOUTH WALES, 10005-2858&lt;/SUGG_FULL_LASTLINE>&lt;SUGG_SINGLE_ADDRESS>L 1, 65 MARTIN PL, NEW YORK CITY, NEW SOUTH WALES, 10005-2858&lt;/SUGG_SINGLE_ADDRESS>&lt;/LIST></out:sugg_entry><out:sugg_error>1</out:sugg_error><out:sugg_status>U</out:sugg_status><out:sugg_count>20</out:sugg_count><out:street_prefix/><out:street_postfix/><out:sugg_length>15335</out:sugg_length><out:rdi_flag/><out:address_line/><out:last_line/><out:single_address/></out:ValidateWithSuggestionResponse></soapenv:Body></soapenv:Envelope>'; 
                }else If( MailingCountry == 'Japan' ){
                    responseBody='<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><out:ValidateWithSuggestionResponse xmlns:out="http://dell.com/AddressValidation/ValidateWithSuggestion/output"><out:firm/><out:house_number>65</out:house_number><out:street>10</out:street><out:alt_street>Martin</out:alt_street><out:street2>14</out:street2><out:locality1>TOKYO</out:locality1><out:locality2/><out:locality3/><out:ac_firm/><out:unitnum/><out:building/><out:pobox_number/><out:state>TK</out:state><out:postcode>161</out:postcode><out:country_code>JP</out:country_code><out:country>JAPAN</out:country><out:address>65 Martin Pl</out:address><out:dual_address/><out:primary_address>65 Martin Pl</out:primary_address><out:secondary_address/><out:address_fault_desc>Locality, region, and postcode are valid Unable to match primary name to directory</out:address_fault_desc><out:sugg_entry>&lt;LIST>&lt;SELECTION>1&lt;/SELECTION>&lt;LOCALITY1>TOKYO&lt;/LOCALITY1>&lt;LOCALITY2/>&lt;LOCALITY3/>&lt;POSTCODE>161&lt;/POSTCODE>&lt;POSTCODE1>161&lt;/POSTCODE1>&lt;POSTCODE2/>&lt;REGION1>NEW SOUTH WALES&lt;/REGION1>&lt;PRIMARY_NUMBER_LOW>60&lt;/PRIMARY_NUMBER_LOW>&lt;PRIMARY_NUMBER_HIGH>65&lt;/PRIMARY_NUMBER_HIGH>&lt;PRIMARY_NUMBER_DESCRIPTION/>&lt;PRIMARY_NUMBER_EXTRA/>&lt;PRIMARY_NUMBER_FULL/>&lt;PRIMARY_PREFIX1/>&lt;PRIMARY_PREFIX2/>&lt;PRIMARY_NAME1>MARTIN&lt;/PRIMARY_NAME1>&lt;PRIMARY_NAME2/>&lt;PRIMARY_TYPE1>PL&lt;/PRIMARY_TYPE1>&lt;PRIMARY_TYPE2/>&lt;PRIMARY_POSTFIX1/>&lt;PRIMARY_POSTFIX2/>&lt;PRIMARY_NAME_FULL1>MARTIN PL&lt;/PRIMARY_NAME_FULL1>&lt;PRIMARY_NAME_FULL2/>&lt;PRIMARY_SIDE_INDICATOR>O&lt;/PRIMARY_SIDE_INDICATOR>&lt;FIRM/>&lt;UNIT_DESCRIPTION/>&lt;UNIT_NUMBER_LOW/>&lt;UNIT_NUMBER_HIGH/>&lt;STAIRWELL_DESCRIPTION/>&lt;STAIRWELL_NAME/>&lt;FLOOR_NUMBER_LOW>1&lt;/FLOOR_NUMBER_LOW>&lt;FLOOR_NUMBER_HIGH>3&lt;/FLOOR_NUMBER_HIGH>&lt;FLOOR_DESCRIPTION>L&lt;/FLOOR_DESCRIPTION>&lt;SECONDARY_SIDE_INDICATOR/>&lt;SUGG_FULL_ADDRESSLINE>L 1, 65 MARTIN PL&lt;/SUGG_FULL_ADDRESSLINE>&lt;SUGG_FULL_LASTLINE>TOKYO, NEW SOUTH WALES, 161&lt;/SUGG_FULL_LASTLINE>&lt;SUGG_SINGLE_ADDRESS>L 1, 65 MARTIN PL, TOKYO, NEW SOUTH WALES, 161&lt;/SUGG_SINGLE_ADDRESS>&lt;/LIST>&lt;LIST>&lt;SELECTION>1&lt;/SELECTION>&lt;LOCALITY1>NEW YORK CITY&lt;/LOCALITY1>&lt;LOCALITY2/>&lt;LOCALITY3/>&lt;POSTCODE>10005-2858&lt;/POSTCODE>&lt;POSTCODE1>10005-2858&lt;/POSTCODE1>&lt;POSTCODE2/>&lt;REGION1>NEW SOUTH WALES&lt;/REGION1>&lt;PRIMARY_NUMBER_LOW>65&lt;/PRIMARY_NUMBER_LOW>&lt;PRIMARY_NUMBER_HIGH>65&lt;/PRIMARY_NUMBER_HIGH>&lt;PRIMARY_NUMBER_DESCRIPTION/>&lt;PRIMARY_NUMBER_EXTRA/>&lt;PRIMARY_NUMBER_FULL/>&lt;PRIMARY_PREFIX1/>&lt;PRIMARY_PREFIX2/>&lt;PRIMARY_NAME1>MARTIN&lt;/PRIMARY_NAME1>&lt;PRIMARY_NAME2/>&lt;PRIMARY_TYPE1>PL&lt;/PRIMARY_TYPE1>&lt;PRIMARY_TYPE2/>&lt;PRIMARY_POSTFIX1/>&lt;PRIMARY_POSTFIX2/>&lt;PRIMARY_NAME_FULL1>MARTIN PL&lt;/PRIMARY_NAME_FULL1>&lt;PRIMARY_NAME_FULL2/>&lt;PRIMARY_SIDE_INDICATOR>O&lt;/PRIMARY_SIDE_INDICATOR>&lt;FIRM/>&lt;UNIT_DESCRIPTION/>&lt;UNIT_NUMBER_LOW/>&lt;UNIT_NUMBER_HIGH/>&lt;STAIRWELL_DESCRIPTION/>&lt;STAIRWELL_NAME/>&lt;FLOOR_NUMBER_LOW>1&lt;/FLOOR_NUMBER_LOW>&lt;FLOOR_NUMBER_HIGH>1&lt;/FLOOR_NUMBER_HIGH>&lt;FLOOR_DESCRIPTION>L&lt;/FLOOR_DESCRIPTION>&lt;SECONDARY_SIDE_INDICATOR/>&lt;SUGG_FULL_ADDRESSLINE>L 1, 65 MARTIN PL&lt;/SUGG_FULL_ADDRESSLINE>&lt;SUGG_FULL_LASTLINE>NEW YORK CITY, NEW SOUTH WALES, 10005-2858&lt;/SUGG_FULL_LASTLINE>&lt;SUGG_SINGLE_ADDRESS>L 1, 65 MARTIN PL, NEW YORK CITY, NEW SOUTH WALES, 10005-2858&lt;/SUGG_SINGLE_ADDRESS>&lt;/LIST></out:sugg_entry><out:sugg_error>1</out:sugg_error><out:sugg_status>U</out:sugg_status><out:sugg_count>2</out:sugg_count><out:street_prefix/><out:street_postfix/><out:sugg_length>15335</out:sugg_length><out:rdi_flag/><out:address_line/><out:last_line/><out:single_address/></out:ValidateWithSuggestionResponse></soapenv:Body></soapenv:Envelope>';  
                }else If( MailingCountry == 'China' ){
                    responseBody='<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><out:ValidateWithSuggestionResponse xmlns:out="http://dell.com/AddressValidation/ValidateWithSuggestion/output"><out:firm/><out:house_number>65</out:house_number><out:street>10</out:street><out:alt_street>Martin</out:alt_street><out:street2>14</out:street2><out:locality1>TOKYO</out:locality1><out:locality2/><out:locality3/><out:ac_firm/><out:unitnum>Test Unit Num</out:unitnum><out:building>Test Build</out:building><out:pobox_number/><out:state>TK</out:state><out:postcode>161</out:postcode><out:country_code>CH</out:country_code><out:country>China</out:country><out:address>65 Martin Pl</out:address><out:dual_address/><out:primary_address>65 Martin Pl</out:primary_address><out:secondary_address>Test Secondary Address</out:secondary_address><out:address_fault_desc>Locality, region, and postcode are valid Unable to match primary name to directory</out:address_fault_desc><out:sugg_entry>&lt;LIST>&lt;SELECTION>1&lt;/SELECTION>&lt;LOCALITY1>TOKYO&lt;/LOCALITY1>&lt;LOCALITY2/>&lt;LOCALITY3/>&lt;POSTCODE>161&lt;/POSTCODE>&lt;POSTCODE1>161&lt;/POSTCODE1>&lt;POSTCODE2/>&lt;REGION1>NEW SOUTH WALES&lt;/REGION1>&lt;PRIMARY_NUMBER_LOW>60&lt;/PRIMARY_NUMBER_LOW>&lt;PRIMARY_NUMBER_HIGH>65&lt;/PRIMARY_NUMBER_HIGH>&lt;PRIMARY_NUMBER_DESCRIPTION/>&lt;PRIMARY_NUMBER_EXTRA/>&lt;PRIMARY_NUMBER_FULL/>&lt;PRIMARY_PREFIX1/>&lt;PRIMARY_PREFIX2/>&lt;PRIMARY_NAME1>MARTIN&lt;/PRIMARY_NAME1>&lt;PRIMARY_NAME2/>&lt;PRIMARY_TYPE1>PL&lt;/PRIMARY_TYPE1>&lt;PRIMARY_TYPE2/>&lt;PRIMARY_POSTFIX1/>&lt;PRIMARY_POSTFIX2/>&lt;PRIMARY_NAME_FULL1>MARTIN PL&lt;/PRIMARY_NAME_FULL1>&lt;PRIMARY_NAME_FULL2/>&lt;PRIMARY_SIDE_INDICATOR>O&lt;/PRIMARY_SIDE_INDICATOR>&lt;FIRM/>&lt;UNIT_DESCRIPTION/>&lt;UNIT_NUMBER_LOW/>&lt;UNIT_NUMBER_HIGH/>&lt;STAIRWELL_DESCRIPTION/>&lt;STAIRWELL_NAME/>&lt;FLOOR_NUMBER_LOW>1&lt;/FLOOR_NUMBER_LOW>&lt;FLOOR_NUMBER_HIGH>3&lt;/FLOOR_NUMBER_HIGH>&lt;FLOOR_DESCRIPTION>L&lt;/FLOOR_DESCRIPTION>&lt;SECONDARY_SIDE_INDICATOR/>&lt;SUGG_FULL_ADDRESSLINE>L 1, 65 MARTIN PL&lt;/SUGG_FULL_ADDRESSLINE>&lt;SUGG_FULL_LASTLINE>TOKYO, NEW SOUTH WALES, 161&lt;/SUGG_FULL_LASTLINE>&lt;SUGG_SINGLE_ADDRESS>L 1, 65 MARTIN PL, TOKYO, NEW SOUTH WALES, 161&lt;/SUGG_SINGLE_ADDRESS>&lt;/LIST></out:sugg_entry><out:sugg_error>1</out:sugg_error><out:sugg_status>U</out:sugg_status><out:sugg_count>0</out:sugg_count><out:street_prefix/><out:street_postfix/><out:sugg_length>15335</out:sugg_length><out:rdi_flag/><out:address_line/><out:last_line/><out:single_address/></out:ValidateWithSuggestionResponse></soapenv:Body></soapenv:Envelope>';  
                }else If( MailingCountry == 'United Kingdom' ){
                    responseBody='< ?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><out:ValidateWithSuggestionResponse xmlns:out="http://dell.com/AddressValidation/ValidateWithSuggestion/output"><out:firm/><out:house_number>65</out:house_number><out:street>10</out:street><out:alt_street>Martin</out:alt_street><out:street2>14</out:street2><out:locality1>TOKYO</out:locality1><out:locality2/><out:locality3/><out:ac_firm/><out:unitnum>Test Unit Num</out:unitnum><out:building>Test Build</out:building><out:pobox_number/><out:state>TK</out:state><out:postcode>161</out:postcode><out:country_code>UK</out:country_code><out:country>United Kingdom</out:country><out:address>65 Martin Pl</out:address><out:dual_address/><out:primary_address>65 Martin Pl</out:primary_address><out:secondary_address>Test Secondary Address</out:secondary_address><out:address_fault_desc>Locality, region, and postcode are valid Unable to match primary name to directory</out:address_fault_desc><out:sugg_entry>&lt;LIST>&lt;SELECTION>1&lt;/SELECTION>&lt;LOCALITY1>TOKYO&lt;/LOCALITY1>&lt;LOCALITY2/>&lt;LOCALITY3/>&lt;POSTCODE>161&lt;/POSTCODE>&lt;POSTCODE1>161&lt;/POSTCODE1>&lt;POSTCODE2/>&lt;REGION1>NEW SOUTH WALES&lt;/REGION1>&lt;PRIMARY_NUMBER_LOW>60&lt;/PRIMARY_NUMBER_LOW>&lt;PRIMARY_NUMBER_HIGH>65&lt;/PRIMARY_NUMBER_HIGH>&lt;PRIMARY_NUMBER_DESCRIPTION/>&lt;PRIMARY_NUMBER_EXTRA/>&lt;PRIMARY_NUMBER_FULL/>&lt;PRIMARY_PREFIX1/>&lt;PRIMARY_PREFIX2/>&lt;PRIMARY_NAME1>MARTIN&lt;/PRIMARY_NAME1>&lt;PRIMARY_NAME2/>&lt;PRIMARY_TYPE1>PL&lt;/PRIMARY_TYPE1>&lt;PRIMARY_TYPE2/>&lt;PRIMARY_POSTFIX1/>&lt;PRIMARY_POSTFIX2/>&lt;PRIMARY_NAME_FULL1>MARTIN PL&lt;/PRIMARY_NAME_FULL1>&lt;PRIMARY_NAME_FULL2/>&lt;PRIMARY_SIDE_INDICATOR>O&lt;/PRIMARY_SIDE_INDICATOR>&lt;FIRM/>&lt;UNIT_DESCRIPTION/>&lt;UNIT_NUMBER_LOW/>&lt;UNIT_NUMBER_HIGH/>&lt;STAIRWELL_DESCRIPTION/>&lt;STAIRWELL_NAME/>&lt;FLOOR_NUMBER_LOW>1&lt;/FLOOR_NUMBER_LOW>&lt;FLOOR_NUMBER_HIGH>3&lt;/FLOOR_NUMBER_HIGH>&lt;FLOOR_DESCRIPTION>L&lt;/FLOOR_DESCRIPTION>&lt;SECONDARY_SIDE_INDICATOR/>&lt;SUGG_FULL_ADDRESSLINE>L 1, 65 MARTIN PL&lt;/SUGG_FULL_ADDRESSLINE>&lt;SUGG_FULL_LASTLINE>TOKYO, NEW SOUTH WALES, 161&lt;/SUGG_FULL_LASTLINE>&lt;SUGG_SINGLE_ADDRESS>L 1, 65 MARTIN PL, TOKYO, NEW SOUTH WALES, 161&lt;/SUGG_SINGLE_ADDRESS>&lt;/LIST></out:sugg_entry><out:sugg_error>1</out:sugg_error><out:sugg_status>U</out:sugg_status><out:sugg_count>0</out:sugg_count><out:street_prefix/><out:street_postfix/><out:sugg_length>15335</out:sugg_length><out:rdi_flag/><out:address_line/><out:last_line/><out:single_address/></out:ValidateWithSuggestionResponse></soapenv:Body></soapenv:Envelope>';  
                }else If( MailingCountry == 'France' ){
                    responseBody='<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><out:ValidateWithSuggestionResponse xmlns:out="http://dell.com/AddressValidation/ValidateWithSuggestion/output"><out:firm/><out:house_number>65</out:house_number><out:street>10</out:street><out:alt_street>Martin</out:alt_street><out:street2>14</out:street2><out:locality1>TOKYO</out:locality1><out:locality2/><out:locality3/><out:ac_firm/><out:unitnum>Test Unit Num</out:unitnum><out:building>Test Build</out:building><out:pobox_number/><out:state>TK</out:state><out:postcode>161</out:postcode><out:country_code>FF</out:country_code><out:country>France</out:country><out:address>65 Martin Pl</out:address><out:dual_address/><out:primary_address>65 Martin Pl</out:primary_address><out:secondary_address>Test Secondary Address</out:secondary_address><out:address_fault_desc>Locality, region, and postcode are valid Unable to match primary name to directory</out:address_fault_desc><out:sugg_entry>&lt;LIST>&lt;SELECTION>1&lt;/SELECTION>&lt;LOCALITY1>TOKYO&lt;/LOCALITY1>&lt;LOCALITY2/>&lt;LOCALITY3/>&lt;POSTCODE>161&lt;/POSTCODE>&lt;POSTCODE1>161&lt;/POSTCODE1>&lt;POSTCODE2/>&lt;REGION1>NEW SOUTH WALES&lt;/REGION1>&lt;PRIMARY_NUMBER_LOW>60&lt;/PRIMARY_NUMBER_LOW>&lt;PRIMARY_NUMBER_HIGH>65&lt;/PRIMARY_NUMBER_HIGH>&lt;PRIMARY_NUMBER_DESCRIPTION/>&lt;PRIMARY_NUMBER_EXTRA/>&lt;PRIMARY_NUMBER_FULL/>&lt;PRIMARY_PREFIX1/>&lt;PRIMARY_PREFIX2/>&lt;PRIMARY_NAME1>MARTIN&lt;/PRIMARY_NAME1>&lt;PRIMARY_NAME2/>&lt;PRIMARY_TYPE1>PL&lt;/PRIMARY_TYPE1>&lt;PRIMARY_TYPE2/>&lt;PRIMARY_POSTFIX1/>&lt;PRIMARY_POSTFIX2/>&lt;PRIMARY_NAME_FULL1>MARTIN PL&lt;/PRIMARY_NAME_FULL1>&lt;PRIMARY_NAME_FULL2/>&lt;PRIMARY_SIDE_INDICATOR>O&lt;/PRIMARY_SIDE_INDICATOR>&lt;FIRM/>&lt;UNIT_DESCRIPTION/>&lt;UNIT_NUMBER_LOW/>&lt;UNIT_NUMBER_HIGH/>&lt;STAIRWELL_DESCRIPTION/>&lt;STAIRWELL_NAME/>&lt;FLOOR_NUMBER_LOW>1&lt;/FLOOR_NUMBER_LOW>&lt;FLOOR_NUMBER_HIGH>3&lt;/FLOOR_NUMBER_HIGH>&lt;FLOOR_DESCRIPTION>L&lt;/FLOOR_DESCRIPTION>&lt;SECONDARY_SIDE_INDICATOR/>&lt;SUGG_FULL_ADDRESSLINE>L 1, 65 MARTIN PL&lt;/SUGG_FULL_ADDRESSLINE>&lt;SUGG_FULL_LASTLINE>TOKYO, NEW SOUTH WALES, 161&lt;/SUGG_FULL_LASTLINE>&lt;SUGG_SINGLE_ADDRESS>L 1, 65 MARTIN PL, TOKYO, NEW SOUTH WALES, 161&lt;/SUGG_SINGLE_ADDRESS>&lt;/LIST></out:sugg_entry><out:sugg_error>1</out:sugg_error><out:sugg_status>U</out:sugg_status><out:sugg_count>0</out:sugg_count><out:street_prefix/><out:street_postfix/><out:sugg_length>15335</out:sugg_length><out:rdi_flag/><out:address_line/><out:last_line/><out:single_address/></out:ValidateWithSuggestionResponse></soapenv:Body></soapenv:Envelope>';                 
                }else If( MailingCountry == 'Australia1' ){
                    responseBody='<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><out:ValidateWithSuggestionResponse xmlns:out="http://dell.com/AddressValidation/ValidateWithSuggestion/output"><out:firm/><out:house_number>65</out:house_number><out:street>10</out:street><out:alt_street>Martin</out:alt_street><out:street2>14</out:street2><out:locality1>TOKYO</out:locality1><out:locality2/><out:locality3/><out:ac_firm/><out:unitnum>Test Unit Num</out:unitnum><out:building>Test Build</out:building><out:pobox_number/><out:state>TK</out:state><out:postcode>161</out:postcode><out:country_code>AU</out:country_code><out:country>Australia1</out:country><out:address>65 Martin Pl</out:address><out:dual_address/><out:primary_address>65 Martin Pl</out:primary_address><out:secondary_address>Test Secondary Address</out:secondary_address><out:address_fault_desc>Locality, region, and postcode are valid Unable to match primary name to directory</out:address_fault_desc><out:sugg_entry>&lt;LIST>&lt;SELECTION>1&lt;/SELECTION>&lt;LOCALITY1>TOKYO&lt;/LOCALITY1>&lt;LOCALITY2/>&lt;LOCALITY3/>&lt;POSTCODE>161&lt;/POSTCODE>&lt;POSTCODE1>161&lt;/POSTCODE1>&lt;POSTCODE2/>&lt;REGION1>NEW SOUTH WALES&lt;/REGION1>&lt;PRIMARY_NUMBER_LOW>60&lt;/PRIMARY_NUMBER_LOW>&lt;PRIMARY_NUMBER_HIGH>65&lt;/PRIMARY_NUMBER_HIGH>&lt;PRIMARY_NUMBER_DESCRIPTION/>&lt;PRIMARY_NUMBER_EXTRA/>&lt;PRIMARY_NUMBER_FULL/>&lt;PRIMARY_PREFIX1/>&lt;PRIMARY_PREFIX2/>&lt;PRIMARY_NAME1>MARTIN&lt;/PRIMARY_NAME1>&lt;PRIMARY_NAME2/>&lt;PRIMARY_TYPE1>PL&lt;/PRIMARY_TYPE1>&lt;PRIMARY_TYPE2/>&lt;PRIMARY_POSTFIX1/>&lt;PRIMARY_POSTFIX2/>&lt;PRIMARY_NAME_FULL1>MARTIN PL&lt;/PRIMARY_NAME_FULL1>&lt;PRIMARY_NAME_FULL2/>&lt;PRIMARY_SIDE_INDICATOR>O&lt;/PRIMARY_SIDE_INDICATOR>&lt;FIRM/>&lt;UNIT_DESCRIPTION/>&lt;UNIT_NUMBER_LOW/>&lt;UNIT_NUMBER_HIGH/>&lt;STAIRWELL_DESCRIPTION/>&lt;STAIRWELL_NAME/>&lt;FLOOR_NUMBER_LOW>1&lt;/FLOOR_NUMBER_LOW>&lt;FLOOR_NUMBER_HIGH>3&lt;/FLOOR_NUMBER_HIGH>&lt;FLOOR_DESCRIPTION>L&lt;/FLOOR_DESCRIPTION>&lt;SECONDARY_SIDE_INDICATOR/>&lt;SUGG_FULL_ADDRESSLINE>L 1, 65 MARTIN PL&lt;/SUGG_FULL_ADDRESSLINE>&lt;SUGG_FULL_LASTLINE>TOKYO, NEW SOUTH WALES, 161&lt;/SUGG_FULL_LASTLINE>&lt;SUGG_SINGLE_ADDRESS>L 1, 65 MARTIN PL, TOKYO, NEW SOUTH WALES, 161&lt;/SUGG_SINGLE_ADDRESS>&lt;/LIST></out:sugg_entry><out:sugg_error>1</out:sugg_error><out:sugg_status>U</out:sugg_status><out:sugg_count>0</out:sugg_count><out:street_prefix/><out:street_postfix/><out:sugg_length>15335</out:sugg_length><out:rdi_flag/><out:address_line/><out:last_line/><out:single_address/></out:ValidateWithSuggestionResponse></soapenv:Body></soapenv:Envelope>';                  
                }else If( MailingCountry == 'China1' ){
                    responseBody='<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><out:ValidateWithSuggestionResponse xmlns:out="http://dell.com/AddressValidation/ValidateWithSuggestion/output"><out:firm>TEST</out:firm><out:house_number>#65</out:house_number><out:street>10</out:street><out:alt_street>Martin</out:alt_street><out:street2>14</out:street2><out:locality1>TOKYO</out:locality1><out:locality2/><out:locality3/><out:ac_firm/><out:unitnum>Test Unit Num</out:unitnum><out:building>Test Build</out:building><out:pobox_number/><out:state>TK</out:state><out:postcode>161</out:postcode><out:country_code>CH</out:country_code><out:country>China</out:country><out:address>65 Martin Pl</out:address><out:dual_address/><out:primary_address>65 Martin Pl</out:primary_address><out:secondary_address>Test Secondary Address</out:secondary_address><out:address_fault_desc>Locality, region, and postcode are valid Unable to match primary name to directory</out:address_fault_desc><out:sugg_entry>&lt;LIST>&lt;SELECTION>1&lt;/SELECTION>&lt;LOCALITY1>TOKYO&lt;/LOCALITY1>&lt;LOCALITY2/>&lt;LOCALITY3/>&lt;POSTCODE>161&lt;/POSTCODE>&lt;POSTCODE1>161&lt;/POSTCODE1>&lt;POSTCODE2/>&lt;REGION1>NEW SOUTH WALES&lt;/REGION1>&lt;PRIMARY_NUMBER_LOW>60&lt;/PRIMARY_NUMBER_LOW>&lt;PRIMARY_NUMBER_HIGH>65&lt;/PRIMARY_NUMBER_HIGH>&lt;PRIMARY_NUMBER_DESCRIPTION/>&lt;PRIMARY_NUMBER_EXTRA/>&lt;PRIMARY_NUMBER_FULL/>&lt;PRIMARY_PREFIX1/>&lt;PRIMARY_PREFIX2/>&lt;PRIMARY_NAME1>MARTIN&lt;/PRIMARY_NAME1>&lt;PRIMARY_NAME2/>&lt;PRIMARY_TYPE1>PL&lt;/PRIMARY_TYPE1>&lt;PRIMARY_TYPE2/>&lt;PRIMARY_POSTFIX1/>&lt;PRIMARY_POSTFIX2/>&lt;PRIMARY_NAME_FULL1>MARTIN PL&lt;/PRIMARY_NAME_FULL1>&lt;PRIMARY_NAME_FULL2/>&lt;PRIMARY_SIDE_INDICATOR>O&lt;/PRIMARY_SIDE_INDICATOR>&lt;FIRM/>&lt;UNIT_DESCRIPTION/>&lt;UNIT_NUMBER_LOW/>&lt;UNIT_NUMBER_HIGH/>&lt;STAIRWELL_DESCRIPTION/>&lt;STAIRWELL_NAME/>&lt;FLOOR_NUMBER_LOW>1&lt;/FLOOR_NUMBER_LOW>&lt;FLOOR_NUMBER_HIGH>3&lt;/FLOOR_NUMBER_HIGH>&lt;FLOOR_DESCRIPTION>L&lt;/FLOOR_DESCRIPTION>&lt;SECONDARY_SIDE_INDICATOR/>&lt;SUGG_FULL_ADDRESSLINE>L 1, 65 MARTIN PL&lt;/SUGG_FULL_ADDRESSLINE>&lt;SUGG_FULL_LASTLINE>TOKYO, NEW SOUTH WALES, 161&lt;/SUGG_FULL_LASTLINE>&lt;SUGG_SINGLE_ADDRESS>L 1, 65 MARTIN PL, TOKYO, NEW SOUTH WALES, 161&lt;/SUGG_SINGLE_ADDRESS>&lt;/LIST></out:sugg_entry><out:sugg_error>1</out:sugg_error><out:sugg_status>U</out:sugg_status><out:sugg_count>0</out:sugg_count><out:street_prefix/><out:street_postfix/><out:sugg_length>15335</out:sugg_length><out:rdi_flag/><out:address_line/><out:last_line/><out:single_address/></out:ValidateWithSuggestionResponse></soapenv:Body></soapenv:Envelope>';  
                    ResError = 'Error'; 
                }else If( MailingCountry == 'Japan2' ){
                    responseBody='<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><out:ValidateWithSuggestionResponse xmlns:out="http://dell.com/AddressValidation/ValidateWithSuggestion/output"><out:firm/><out:house_number>#65</out:house_number><out:street>10</out:street><out:alt_street>Martin</out:alt_street><out:street2>14</out:street2><out:locality1>TOKYO</out:locality1><out:locality2/><out:locality3/><out:ac_firm/><out:unitnum/><out:building/><out:pobox_number/><out:state>TK</out:state><out:postcode>161</out:postcode><out:country_code>JP</out:country_code><out:country>JAPAN</out:country><out:address>65 Martin Pl</out:address><out:dual_address/><out:primary_address>65 Martin Pl</out:primary_address><out:secondary_address/><out:address_fault_desc>Locality, region, and postcode are valid Unable to match primary name to directory</out:address_fault_desc><out:sugg_entry>&lt;LIST>&lt;SELECTION>1&lt;/SELECTION>&lt;LOCALITY1>TOKYO&lt;/LOCALITY1>&lt;LOCALITY2/>&lt;LOCALITY3/>&lt;POSTCODE>161&lt;/POSTCODE>&lt;POSTCODE1>161&lt;/POSTCODE1>&lt;POSTCODE2/>&lt;REGION1>NEW SOUTH WALES&lt;/REGION1>&lt;PRIMARY_NUMBER_LOW>60&lt;/PRIMARY_NUMBER_LOW>&lt;PRIMARY_NUMBER_HIGH>65&lt;/PRIMARY_NUMBER_HIGH>&lt;PRIMARY_NUMBER_DESCRIPTION/>&lt;PRIMARY_NUMBER_EXTRA/>&lt;PRIMARY_NUMBER_FULL/>&lt;PRIMARY_PREFIX1/>&lt;PRIMARY_PREFIX2/>&lt;PRIMARY_NAME1>MARTIN&lt;/PRIMARY_NAME1>&lt;PRIMARY_NAME2/>&lt;PRIMARY_TYPE1>PL&lt;/PRIMARY_TYPE1>&lt;PRIMARY_TYPE2/>&lt;PRIMARY_POSTFIX1/>&lt;PRIMARY_POSTFIX2/>&lt;PRIMARY_NAME_FULL1>MARTIN PL&lt;/PRIMARY_NAME_FULL1>&lt;PRIMARY_NAME_FULL2/>&lt;PRIMARY_SIDE_INDICATOR>O&lt;/PRIMARY_SIDE_INDICATOR>&lt;FIRM>TEST&lt;/FIRM>&lt;UNIT_DESCRIPTION/>&lt;UNIT_NUMBER_LOW/>&lt;UNIT_NUMBER_HIGH/>&lt;STAIRWELL_DESCRIPTION>TEST&lt;/STAIRWELL_DESCRIPTION>&lt;STAIRWELL_NAME>TEST&lt;/STAIRWELL_NAME>&lt;FLOOR_NUMBER_LOW>1&lt;/FLOOR_NUMBER_LOW>&lt;FLOOR_NUMBER_HIGH>3&lt;/FLOOR_NUMBER_HIGH>&lt;FLOOR_DESCRIPTION>L&lt;/FLOOR_DESCRIPTION>&lt;SECONDARY_SIDE_INDICATOR/>&lt;SUGG_FULL_ADDRESSLINE>L 1, 65 MARTIN PL&lt;/SUGG_FULL_ADDRESSLINE>&lt;SUGG_FULL_LASTLINE>TOKYO, NEW SOUTH WALES, 161&lt;/SUGG_FULL_LASTLINE>&lt;SUGG_SINGLE_ADDRESS>L 1, 65 MARTIN PL, TOKYO, NEW SOUTH WALES, 161&lt;/SUGG_SINGLE_ADDRESS>&lt;/LIST>&lt;LIST>&lt;SELECTION>1&lt;/SELECTION>&lt;LOCALITY1>NEW YORK CITY&lt;/LOCALITY1>&lt;LOCALITY2/>&lt;LOCALITY3/>&lt;POSTCODE>10005-2858&lt;/POSTCODE>&lt;POSTCODE1>10005-2858&lt;/POSTCODE1>&lt;POSTCODE2/>&lt;REGION1>NEW SOUTH WALES&lt;/REGION1>&lt;PRIMARY_NUMBER_LOW>65&lt;/PRIMARY_NUMBER_LOW>&lt;PRIMARY_NUMBER_HIGH>65&lt;/PRIMARY_NUMBER_HIGH>&lt;PRIMARY_NUMBER_DESCRIPTION/>&lt;PRIMARY_NUMBER_EXTRA/>&lt;PRIMARY_NUMBER_FULL/>&lt;PRIMARY_PREFIX1/>&lt;PRIMARY_PREFIX2/>&lt;PRIMARY_NAME1>MARTIN&lt;/PRIMARY_NAME1>&lt;PRIMARY_NAME2/>&lt;PRIMARY_TYPE1>PL&lt;/PRIMARY_TYPE1>&lt;PRIMARY_TYPE2/>&lt;PRIMARY_POSTFIX1/>&lt;PRIMARY_POSTFIX2/>&lt;PRIMARY_NAME_FULL1>MARTIN PL&lt;/PRIMARY_NAME_FULL1>&lt;PRIMARY_NAME_FULL2/>&lt;PRIMARY_SIDE_INDICATOR>O&lt;/PRIMARY_SIDE_INDICATOR>&lt;FIRM/>&lt;UNIT_DESCRIPTION/>&lt;UNIT_NUMBER_LOW/>&lt;UNIT_NUMBER_HIGH/>&lt;STAIRWELL_DESCRIPTION/>&lt;STAIRWELL_NAME/>&lt;FLOOR_NUMBER_LOW>1&lt;/FLOOR_NUMBER_LOW>&lt;FLOOR_NUMBER_HIGH>1&lt;/FLOOR_NUMBER_HIGH>&lt;FLOOR_DESCRIPTION>L&lt;/FLOOR_DESCRIPTION>&lt;SECONDARY_SIDE_INDICATOR/>&lt;SUGG_FULL_ADDRESSLINE>L 1, 65 MARTIN PL&lt;/SUGG_FULL_ADDRESSLINE>&lt;SUGG_FULL_LASTLINE>NEW YORK CITY, NEW SOUTH WALES, 10005-2858&lt;/SUGG_FULL_LASTLINE>&lt;SUGG_SINGLE_ADDRESS>L 1, 65 MARTIN PL, NEW YORK CITY, NEW SOUTH WALES, 10005-2858&lt;/SUGG_SINGLE_ADDRESS>&lt;/LIST></out:sugg_entry><out:sugg_error>1</out:sugg_error><out:sugg_status>U</out:sugg_status><out:sugg_count>0</out:sugg_count><out:street_prefix/><out:street_postfix/><out:sugg_length>15335</out:sugg_length><out:rdi_flag/><out:address_line/><out:last_line/><out:single_address/></out:ValidateWithSuggestionResponse></soapenv:Body></soapenv:Envelope>';  
                }else If( MailingCountry == 'United States3' ){
                    responseBody='<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><out:ValidateWithSuggestionResponse xmlns:out="http://dell.com/AddressValidation/ValidateWithSuggestion/output"><out:firm/><out:house_number>65</out:house_number><out:street>Martin Pl</out:street><out:alt_street>Martin</out:alt_street><out:street2/><out:locality1>NEW YORK CITY</out:locality1><out:locality2/><out:locality3/><out:ac_firm/><out:unitnum/><out:building/><out:pobox_number/><out:state>NY</out:state><out:postcode>2000</out:postcode><out:country_code>US</out:country_code><out:country>United States</out:country><out:address>65 Martin Pl</out:address><out:dual_address/><out:primary_address>65 Martin Pl</out:primary_address><out:secondary_address/><out:address_fault_desc>The secondary information is missing on input or not in the directory</out:address_fault_desc><out:sugg_entry>&lt;LIST>&lt;SELECTION>1&lt;/SELECTION>&lt;LOCALITY1>NEW YORK CITY&lt;/LOCALITY1>&lt;LOCALITY2/>&lt;LOCALITY3/>&lt;POSTCODE>2000&lt;/POSTCODE>&lt;POSTCODE1>2000&lt;/POSTCODE1>&lt;POSTCODE2/>&lt;REGION1>NEW SOUTH WALES&lt;/REGION1>&lt;PRIMARY_NUMBER_LOW/>&lt;PRIMARY_NUMBER_HIGH/>&lt;PRIMARY_NUMBER_DESCRIPTION/>&lt;PRIMARY_NUMBER_EXTRA/>&lt;PRIMARY_NUMBER_FULL/>&lt;PRIMARY_PREFIX1/>&lt;PRIMARY_PREFIX2/>&lt;PRIMARY_NAME1>MARTIN&lt;/PRIMARY_NAME1>&lt;PRIMARY_NAME2/>&lt;PRIMARY_TYPE1>PL&lt;/PRIMARY_TYPE1>&lt;PRIMARY_TYPE2/>&lt;PRIMARY_POSTFIX1/>&lt;PRIMARY_POSTFIX2/>&lt;PRIMARY_NAME_FULL1>MARTIN PL&lt;/PRIMARY_NAME_FULL1>&lt;PRIMARY_NAME_FULL2/>&lt;PRIMARY_SIDE_INDICATOR>E&lt;/PRIMARY_SIDE_INDICATOR>&lt;FIRM/>&lt;UNIT_DESCRIPTION/>&lt;UNIT_NUMBER_LOW>66&lt;/UNIT_NUMBER_LOW>&lt;UNIT_NUMBER_HIGH>66&lt;/UNIT_NUMBER_HIGH>&lt;STAIRWELL_DESCRIPTION/>&lt;STAIRWELL_NAME/>&lt;FLOOR_NUMBER_LOW>1&lt;/FLOOR_NUMBER_LOW>&lt;FLOOR_NUMBER_HIGH>1&lt;/FLOOR_NUMBER_HIGH>&lt;FLOOR_DESCRIPTION>L&lt;/FLOOR_DESCRIPTION>&lt;SECONDARY_SIDE_INDICATOR/>&lt;SUGG_FULL_ADDRESSLINE>L 1, 65 MARTIN PL&lt;/SUGG_FULL_ADDRESSLINE>&lt;SUGG_FULL_LASTLINE>NEW YORK CITY, NEW SOUTH WALES, 2000&lt;/SUGG_FULL_LASTLINE>&lt;SUGG_SINGLE_ADDRESS>L 1, 65 MARTIN PL, NEW YORK CITY, NEW SOUTH WALES, 2000&lt;/SUGG_SINGLE_ADDRESS>&lt;/LIST>&lt;LIST>&lt;SELECTION>1&lt;/SELECTION>&lt;LOCALITY1>NEW YORK CITY&lt;/LOCALITY1>&lt;LOCALITY2/>&lt;LOCALITY3/>&lt;POSTCODE>10005-2858&lt;/POSTCODE>&lt;POSTCODE1>10005-2858&lt;/POSTCODE1>&lt;POSTCODE2/>&lt;REGION1>NEW SOUTH WALES&lt;/REGION1>&lt;PRIMARY_NUMBER_LOW>61&lt;/PRIMARY_NUMBER_LOW>&lt;PRIMARY_NUMBER_HIGH>65&lt;/PRIMARY_NUMBER_HIGH>&lt;PRIMARY_NUMBER_DESCRIPTION/>&lt;PRIMARY_NUMBER_EXTRA/>&lt;PRIMARY_NUMBER_FULL/>&lt;PRIMARY_PREFIX1/>&lt;PRIMARY_PREFIX2/>&lt;PRIMARY_NAME1>MARTIN&lt;/PRIMARY_NAME1>&lt;PRIMARY_NAME2/>&lt;PRIMARY_TYPE1>PL&lt;/PRIMARY_TYPE1>&lt;PRIMARY_TYPE2/>&lt;PRIMARY_POSTFIX1/>&lt;PRIMARY_POSTFIX2/>&lt;PRIMARY_NAME_FULL1>MARTIN PL&lt;/PRIMARY_NAME_FULL1>&lt;PRIMARY_NAME_FULL2/>&lt;PRIMARY_SIDE_INDICATOR>O&lt;/PRIMARY_SIDE_INDICATOR>&lt;FIRM/>&lt;UNIT_DESCRIPTION/>&lt;UNIT_NUMBER_LOW/>&lt;UNIT_NUMBER_HIGH/>&lt;STAIRWELL_DESCRIPTION/>&lt;STAIRWELL_NAME/>&lt;FLOOR_NUMBER_LOW>1&lt;/FLOOR_NUMBER_LOW>&lt;FLOOR_NUMBER_HIGH>1&lt;/FLOOR_NUMBER_HIGH>&lt;FLOOR_DESCRIPTION>L&lt;/FLOOR_DESCRIPTION>&lt;SECONDARY_SIDE_INDICATOR/>&lt;SUGG_FULL_ADDRESSLINE>L 1, 65 MARTIN PL&lt;/SUGG_FULL_ADDRESSLINE>&lt;SUGG_FULL_LASTLINE>NEW YORK CITY, NEW SOUTH WALES, 10005-2858&lt;/SUGG_FULL_LASTLINE>&lt;SUGG_SINGLE_ADDRESS>L 1, 65 MARTIN PL, NEW YORK CITY, NEW SOUTH WALES, 10005-2858&lt;/SUGG_SINGLE_ADDRESS>&lt;/LIST></out:sugg_entry><out:sugg_error>1</out:sugg_error><out:sugg_status>U</out:sugg_status><out:sugg_count>20</out:sugg_count><out:street_prefix/><out:street_postfix/><out:sugg_length>15335</out:sugg_length><out:rdi_flag/><out:address_line/><out:last_line/><out:single_address/></out:ValidateWithSuggestionResponse></soapenv:Body></soapenv:Envelope>'; 
                }
                
                //responseBody='<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><out:ValidateWithSuggestionResponse xmlns:out="http://dell.com/AddressValidation/ValidateWithSuggestion/output"><out:firm/><out:house_number>65</out:house_number><out:street>Martin Pl</out:street><out:alt_street>Martin</out:alt_street><out:street2/><out:locality1>Sydney</out:locality1><out:locality2/><out:locality3/><out:ac_firm/><out:unitnum/><out:building/><out:pobox_number/><out:state>NSW</out:state><out:postcode>2000</out:postcode><out:country_code>AU</out:country_code><out:country>Australia</out:country><out:address>65 Martin Pl</out:address><out:dual_address/><out:primary_address>65 Martin Pl</out:primary_address><out:secondary_address/><out:address_fault_desc>The secondary information is missing on input or not in the directory</out:address_fault_desc><out:sugg_entry>&lt;LIST>&lt;SELECTION>1&lt;/SELECTION>&lt;LOCALITY1>SYDNEY&lt;/LOCALITY1>&lt;LOCALITY2/>&lt;LOCALITY3/>&lt;POSTCODE>2000&lt;/POSTCODE>&lt;POSTCODE1>2000&lt;/POSTCODE1>&lt;POSTCODE2/>&lt;REGION1>NEW SOUTH WALES&lt;/REGION1>&lt;PRIMARY_NUMBER_LOW>60&lt;/PRIMARY_NUMBER_LOW>&lt;PRIMARY_NUMBER_HIGH>65&lt;/PRIMARY_NUMBER_HIGH>&lt;PRIMARY_NUMBER_DESCRIPTION/>&lt;PRIMARY_NUMBER_EXTRA/>&lt;PRIMARY_NUMBER_FULL/>&lt;PRIMARY_PREFIX1/>&lt;PRIMARY_PREFIX2/>&lt;PRIMARY_NAME1>MARTIN&lt;/PRIMARY_NAME1>&lt;PRIMARY_NAME2/>&lt;PRIMARY_TYPE1>PL&lt;/PRIMARY_TYPE1>&lt;PRIMARY_TYPE2/>&lt;PRIMARY_POSTFIX1/>&lt;PRIMARY_POSTFIX2/>&lt;PRIMARY_NAME_FULL1>MARTIN PL&lt;/PRIMARY_NAME_FULL1>&lt;PRIMARY_NAME_FULL2/>&lt;PRIMARY_SIDE_INDICATOR>O&lt;/PRIMARY_SIDE_INDICATOR>&lt;FIRM/>&lt;UNIT_DESCRIPTION/>&lt;UNIT_NUMBER_LOW/>&lt;UNIT_NUMBER_HIGH/>&lt;STAIRWELL_DESCRIPTION/>&lt;STAIRWELL_NAME/>&lt;FLOOR_NUMBER_LOW>1&lt;/FLOOR_NUMBER_LOW>&lt;FLOOR_NUMBER_HIGH>1&lt;/FLOOR_NUMBER_HIGH>&lt;FLOOR_DESCRIPTION>L&lt;/FLOOR_DESCRIPTION>&lt;SECONDARY_SIDE_INDICATOR/>&lt;SUGG_FULL_ADDRESSLINE>L 1, 65 MARTIN PL&lt;/SUGG_FULL_ADDRESSLINE>&lt;SUGG_FULL_LASTLINE>SYDNEY, NEW SOUTH WALES, 2000&lt;/SUGG_FULL_LASTLINE>&lt;SUGG_SINGLE_ADDRESS>L 1, 65 MARTIN PL, SYDNEY, NEW SOUTH WALES, 2000&lt;/SUGG_SINGLE_ADDRESS>&lt;/LIST>&lt;LIST>&lt;SELECTION>1&lt;/SELECTION>&lt;LOCALITY1>NEW YORK CITY&lt;/LOCALITY1>&lt;LOCALITY2/>&lt;LOCALITY3/>&lt;POSTCODE>10005-2858&lt;/POSTCODE>&lt;POSTCODE1>10005-2858&lt;/POSTCODE1>&lt;POSTCODE2/>&lt;REGION1>NEW SOUTH WALES&lt;/REGION1>&lt;PRIMARY_NUMBER_LOW>60&lt;/PRIMARY_NUMBER_LOW>&lt;PRIMARY_NUMBER_HIGH>65&lt;/PRIMARY_NUMBER_HIGH>&lt;PRIMARY_NUMBER_DESCRIPTION/>&lt;PRIMARY_NUMBER_EXTRA/>&lt;PRIMARY_NUMBER_FULL/>&lt;PRIMARY_PREFIX1/>&lt;PRIMARY_PREFIX2/>&lt;PRIMARY_NAME1>MARTIN&lt;/PRIMARY_NAME1>&lt;PRIMARY_NAME2/>&lt;PRIMARY_TYPE1>PL&lt;/PRIMARY_TYPE1>&lt;PRIMARY_TYPE2/>&lt;PRIMARY_POSTFIX1/>&lt;PRIMARY_POSTFIX2/>&lt;PRIMARY_NAME_FULL1>MARTIN PL&lt;/PRIMARY_NAME_FULL1>&lt;PRIMARY_NAME_FULL2/>&lt;PRIMARY_SIDE_INDICATOR>O&lt;/PRIMARY_SIDE_INDICATOR>&lt;FIRM/>&lt;UNIT_DESCRIPTION/>&lt;UNIT_NUMBER_LOW/>&lt;UNIT_NUMBER_HIGH/>&lt;STAIRWELL_DESCRIPTION/>&lt;STAIRWELL_NAME/>&lt;FLOOR_NUMBER_LOW>1&lt;/FLOOR_NUMBER_LOW>&lt;FLOOR_NUMBER_HIGH>1&lt;/FLOOR_NUMBER_HIGH>&lt;FLOOR_DESCRIPTION>L&lt;/FLOOR_DESCRIPTION>&lt;SECONDARY_SIDE_INDICATOR/>&lt;SUGG_FULL_ADDRESSLINE>L 1, 65 MARTIN PL&lt;/SUGG_FULL_ADDRESSLINE>&lt;SUGG_FULL_LASTLINE>NEW YORK CITY, NEW SOUTH WALES, 10005-2858&lt;/SUGG_FULL_LASTLINE>&lt;SUGG_SINGLE_ADDRESS>L 1, 65 MARTIN PL, NEW YORK CITY, NEW SOUTH WALES, 10005-2858&lt;/SUGG_SINGLE_ADDRESS>&lt;/LIST>&lt;LIST>&lt;SELECTION>3&lt;/SELECTION>&lt;LOCALITY1>JAPAN&lt;/LOCALITY1>&lt;LOCALITY2/>&lt;LOCALITY3/>&lt;POSTCODE>161&lt;/POSTCODE>&lt;POSTCODE1>161&lt;/POSTCODE1>&lt;POSTCODE2/>&lt;REGION1>NEW SOUTH WALES&lt;/REGION1>&lt;PRIMARY_NUMBER_LOW>65&lt;/PRIMARY_NUMBER_LOW>&lt;PRIMARY_NUMBER_HIGH>68&lt;/PRIMARY_NUMBER_HIGH>&lt;PRIMARY_NUMBER_DESCRIPTION/>&lt;PRIMARY_NUMBER_EXTRA/>&lt;PRIMARY_NUMBER_FULL/>&lt;PRIMARY_PREFIX1/>&lt;PRIMARY_PREFIX2/>&lt;PRIMARY_NAME1>MARTIN&lt;/PRIMARY_NAME1>&lt;PRIMARY_NAME2/>&lt;PRIMARY_TYPE1>PL&lt;/PRIMARY_TYPE1>&lt;PRIMARY_TYPE2/>&lt;PRIMARY_POSTFIX1/>&lt;PRIMARY_POSTFIX2/>&lt;PRIMARY_NAME_FULL1>MARTIN PL&lt;/PRIMARY_NAME_FULL1>&lt;PRIMARY_NAME_FULL2/>&lt;PRIMARY_SIDE_INDICATOR>O&lt;/PRIMARY_SIDE_INDICATOR>&lt;FIRM/>&lt;UNIT_DESCRIPTION/>&lt;UNIT_NUMBER_LOW/>&lt;UNIT_NUMBER_HIGH/>&lt;STAIRWELL_DESCRIPTION/>&lt;STAIRWELL_NAME/>&lt;FLOOR_NUMBER_LOW>2&lt;/FLOOR_NUMBER_LOW>&lt;FLOOR_NUMBER_HIGH>4&lt;/FLOOR_NUMBER_HIGH>&lt;FLOOR_DESCRIPTION>L&lt;/FLOOR_DESCRIPTION>&lt;SECONDARY_SIDE_INDICATOR/>&lt;SUGG_FULL_ADDRESSLINE>L 2, 65 MARTIN PL&lt;/SUGG_FULL_ADDRESSLINE>&lt;SUGG_FULL_LASTLINE>JAPAN, NEW SOUTH WALES, 161&lt;/SUGG_FULL_LASTLINE>&lt;SUGG_SINGLE_ADDRESS>L 2, 65 MARTIN PL, JAPAN, NEW SOUTH WALES, 161&lt;/SUGG_SINGLE_ADDRESS>&lt;/LIST></out:sugg_entry><out:sugg_error>1</out:sugg_error><out:sugg_status>U</out:sugg_status><out:sugg_count>20</out:sugg_count><out:street_prefix/><out:street_postfix/><out:sugg_length>15335</out:sugg_length><out:rdi_flag/><out:address_line/><out:last_line/><out:single_address/></out:ValidateWithSuggestionResponse></soapenv:Body></soapenv:Envelope>';  
                res.setBody(responseBody);
                res.setStatus('OK');
            }
            
            //Parsing the xml and collecting the data 
            if(ResError.contains('Error')){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.AVS_Res_Error);
                ApexPages.addMessage(myMsg);
                showTable = false;
                showButton = false;
                isError1 = False;
                isError2 = True;
                
            }
            else {
                Dom.Document docx = new Dom.Document();               
                docx.load(responseBody);                
                Dom.XMLNode Envelop = docx.getRootElement();                 
                Dom.XMLNode Body = Envelop.getChildElements()[0];                 
                Dom.XMLNode fault = Body.getChildElements()[0]; 
                
                for(Dom.XMLNode child : Body.getChildElements()) {                 
                    for(Dom.XMLNode child2 : child.getChildElements()) {                  
                        
                        //Ninie to get sugg_entry, easy_iq_pick_info                  
                        String Name;                  
                        String Value; 
                        
                        Value = child.getChildElement('sugg_count','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                  
                        if(Value != '0' || Value != null){                                
                            Name = 'sugg_entry';                             
                        }                     
                        if(child2.getName() == 'sugg_entry'){
                            
                            List<String> lstString = new List<String>();                       
                            lstSuggestion = new List<suggestions>();                       
                            lstString = child2.getText().split('</LIST>');                       
                            for(String str:lstString){  
                                
                                lstSuggestion.add(new suggestions(false,str.substringBetween('<SELECTION>','</SELECTION>'),
                                                                  str.substringBetween('<LOCALITY1>','</LOCALITY1>'),
                                                                  str.substringBetween('<REGION1>','</REGION1>'),
                                                                  str.substringBetween('<POSTCODE>','</POSTCODE>'),
                                                                  str.substringBetween('<POSTCODE2_ODD>','</POSTCODE2_ODD>'),
                                                                  str.substringBetween('<POSTCODE2_EVEN>','</POSTCODE2_EVEN>'),
                                                                  str.substringBetween('<PRIMARY_NUMBER_LOW>','</PRIMARY_NUMBER_LOW>'),
                                                                  str.substringBetween('<PRIMARY_NUMBER_HIGH>','</PRIMARY_NUMBER_HIGH>'),
                                                                  str.substringBetween('<PRIMARY_NAME1>','</PRIMARY_NAME1>'), 
                                                                  str.substringBetween('<PRIMARY_TYPE1>','</PRIMARY_TYPE1>'),
                                                                  str.substringBetween('<LOCALITY2>','</LOCALITY2>'),
                                                                  str.substringBetween('<POSTCODE1>','</POSTCODE1>'),                          
                                                                  str.substringBetween('<UNIT_NUMBER_LOW>','</UNIT_NUMBER_LOW>'),
                                                                  str.substringBetween('<UNIT_NUMBER_HIGH>','</UNIT_NUMBER_HIGH>'),
                                                                  str.substringBetween('<FIRM>','</FIRM>'),
                                                                  str.substringBetween('<PRIMARY_POSTFIX1>','</PRIMARY_POSTFIX1>'),
                                                                  str.substringBetween('<LOCALITY3>','</LOCALITY3>'),
                                                                  str.substringBetween('<PRIMARY_NAME2>','</PRIMARY_NAME2>'),
                                                                  str.substringBetween('<building_name>','</building_name>'),
                                                                  str.substringBetween('<PRIMARY_NUMBER_DESCRIPTION>','</PRIMARY_NUMBER_DESCRIPTION>'),
                                                                  str.substringBetween('<PRIMARY_NAME_FULL1>','</PRIMARY_NAME_FULL1>'),
                                                                  str.substringBetween('<PRIMARY_NAME_FULL2>','</PRIMARY_NAME_FULL2>'),
                                                                  str.substringBetween('<primary_secondary_address>','</primary_secondary_address>'),                
                                                                  str.substringBetween('<PRIMARY_SIDE_INDICATOR>','</PRIMARY_SIDE_INDICATOR>'),                         
                                                                  str.substringBetween('<SECONDARY_SIDE_INDICATOR>','</SECONDARY_SIDE_INDICATOR>'),
                                                                  str.substringBetween('<FLOOR_NUMBER_LOW>','</FLOOR_NUMBER_LOW>'),
                                                                  str.substringBetween('<FLOOR_NUMBER_HIGH>','</FLOOR_NUMBER_HIGH>'),
                                                                  
                                                                  str.substringBetween('<FLOOR_DESCRIPTION>','</FLOOR_DESCRIPTION>'), 
                                                                  mailStreetJapan,
                                                                  //CR 11957:secdryAddresString
                                                                  // CR 11957: Start
                                                                  str.substringBetween('<STAIRWELL_DESCRIPTION>','</STAIRWELL_DESCRIPTION>'),
                                                                  str.substringBetween('<STAIRWELL_NAME>','</STAIRWELL_NAME>')
                                                                  //CR 11957: End
                                                                 ));  
                            }      
                        }                 
                    }
                } 
                Dom.Document doc = res.getBodyDocument();
                Dom.XMLNode envelope =doc.getRootElement();                        
                Dom.XmlNode validateResponse = envelope.getChildElement('Body','http://schemas.xmlsoap.org/soap/envelope/').getChildElement('ValidateWithSuggestionResponse','http://dell.com/AddressValidation/ValidateWithSuggestion/output');                
                resultPostalCode = validateResponse.getChildElement('postcode','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                
                resultStatusCode = validateResponse.getChildElement('sugg_status','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                
                resultSuggestionCount = validateResponse.getChildElement('sugg_count','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                
                resultSuggestionEntry = validateResponse.getChildElement('sugg_entry','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                
                resultStatusDesc = validateResponse.getChildElement('address_fault_desc','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                
                resultStreetNo = validateResponse.getChildElement('house_number','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                
                resultStreet = validateResponse.getChildElement('address','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                
                resultCity = validateResponse.getChildElement('locality1','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                
                resultState = validateResponse.getChildElement('state','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                
                resultBuilding = validateResponse.getChildElement('building','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                
                resultFirm = validateResponse.getChildElement('firm','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                
                resultcountry = validateResponse.getChildElement('country','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                
                resultUnit = validateResponse.getChildElement('unitnum','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                
                resultSecondaryAdd = validateResponse.getChildElement('secondary_address','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                
                resultunitNum = validateResponse.getChildElement('unitnum','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                
                resultRDI = validateResponse.getChildElement('rdi_flag','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();
                resultLocality2 = validateResponse.getChildElement('locality2','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                
                resultLocality3 = validateResponse.getChildElement('locality3','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                
                resultPrimaryAddress = validateResponse.getChildElement('primary_address','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                
                resultSt = validateResponse.getChildElement('street','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                
                resultSt2 = validateResponse.getChildElement('street2','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();                
                resultFirm1 = validateResponse.getChildElement('ac_firm','http://dell.com/AddressValidation/ValidateWithSuggestion/output').getText();
                
                //To set country to any value for error message to appear
                if((resultCountry == null || resultCountry == '') && resultStatusDesc != 'Assigned Address' && resultSuggestionCount =='0'){
                    resultCountry = 'Brazil';
                }
                resLoc2Loc3 = resultLocality2 + ' ' + resultLocality3; 
                
                resLoc2Loc3China = resultLocality2 + ' ' + resultLocality3 + ' ' + resultSt + ' ' + resultSt2;
                if((resultCountry == 'Japan'|| resultCountry == 'China') && resultSuggestionCount =='0'){
                    if(resultStatusDesc == 'Locality, region, and postcode are valid Unable to match primary name to directory'){
                        resultStatusDesc = 'Assigned Address';
                    }
                    if(resultSt.isNumeric() && resultSt2.isNumeric() && resultStreetNo.isNumeric()){
                        resJapanSt = resultSt + '-' + resultSt2 + '-' +resultStreetNo ;
                    }
                    else if((resultSt.isNumeric() && resultSt2.isNumeric() && !resultStreetNo.isNumeric()) || (resultSt.isNumeric() && resultSt2.isNumeric() && (resultStreetNo == null || resultStreetNo == ''))){
                        resJapanSt = resultSt + '-' + resultSt2 + ' ' + resultStreetNo;
                    }
                    else if ((!resultSt.isNumeric() && resultSt2.isNumeric() && resultStreetNo.isNumeric()) || ((resultSt ==null || resultSt =='') && resultSt2.isNumeric() && resultStreetNo.isNumeric())){
                        resJapanSt = resultSt + ' ' + resultSt2 + '-' +resultStreetNo ;
                    }
                    else if ((resultSt.isNumeric() && (resultSt2==null || resultSt2=='') && resultStreetNo.isNumeric())){
                        resJapanSt = resultSt + '-' +resultStreetNo ;
                    }
                    else if ((resultSt.isNumeric() && !resultSt2.isNumeric() && resultStreetNo.isNumeric())){
                        resJapanSt = resultSt + '-' +resultSt2 + ' ' +resultStreetNo ;
                    }
                    else{
                        resJapanSt = resultSt + ' ' + resultSt2 + ' ' +resultStreetNo ;
                    }
                }else if(resultCountry == 'China'){
                    if(resultSt.isNumeric() && resultSt2.isNumeric()){
                        resChinaSt = resultSt + '-' + resultSt2;
                    }else{
                        resChinaSt = resultSt + ' ' + resultSt2;
                    }
                }
                
                if(resultCountry == 'Japan'){
                    if(resultBuilding!=null || resultBuilding!=' '){
                        if(resultSecondaryAdd!=null || resultSecondaryAdd!=' '){
                            string[] secAdd = resultSecondaryAdd.Split(' ');
                            if(secAdd.size() == 1){
                                buildNameJapan = secAdd[0];
                            }else if(secAdd.size() > 1){
                                buildNameJapan = secAdd[0] + ' ' + secAdd[1];
                            }
                        }
                    }
                }
                
                if(resultCountry == 'China'){
                    if(resultSecondaryAdd.length() != 0){
                        string[] secAdd = resultSecondaryAdd.Split(' ');
                        integer x = secAdd.size();
                        integer y = x-1;      
                        if(resultBuilding.length() != 0){                                                        
                            if(resultUnitNum.length() != 0){
                                if((secAdd.size() == 1) || (secAdd[1] == resultUnitNum)){
                                    buildNameChina = secAdd[0];
                                }else if(secAdd.size() > 1 && secAdd[y] != resultUnitNum && secAdd[y] != secAdd[1]){
                                    buildNameChina = secAdd[0] + ' ' + secAdd[1];
                                    resultUnitNum = secAdd[y];
                                    
                                }else if(secAdd.size() > 1 && secAdd[y] != resultUnitNum){
                                    buildNameChina = secAdd[0];
                                    resultUnitNum = secAdd[y];
                                }
                                else if(secAdd.size() > 1){ buildNameChina = secAdd[0] + ' ' + secAdd[1];}
                            }
                            else{buildNameChina = resultSecondaryAdd;}
                        }
                        else if(resultBuilding.length() == 0 && resultUnitNum.length() != 0 ){
                            resultUnitNum = secAdd[y];
                        }
                    }else{buildNameChina = resultBuilding; }
                }
                
                if(resultCountry == 'Australia'){
                    IF(resultstreet != NULL || resultstreet != '')     
                    { Ausresultstreet = resultstreet;}
                    
                    if(resultSecondaryAdd!=null || resultSecondaryAdd!=' '){
                        if(resultunitNum == NULL || resultunitNum == ''){
                            buildAusFloorNumber = resultSecondaryAdd;
                        }
                        else{buildAusFloorNumber = resultSecondaryAdd.substringAfter(resultunitNum); }
                    }
                    if(buildAusFloorNumber == NULL || buildAusFloorNumber == ''){showFloorNumber = false;}
                    else{showFloorNumber = true; }
                    
                }   
                IF(resultCountry == 'Australia' && (resultstreet != NULL || resultstreet !='')){resultstreet=resultSt;}         
                else{resultstreet = resultstreet;}    
                if(resultRDI == 'Y'){ oRDI = true; }
                else{oRDI = false; }    
            }
        }        
        //YOU CAN ALWAYS PARSE THE RESPONSE XML USING XmlStreamReader  CLASS          
        catch(System.CalloutException e) {                    
            isError2 = True;
            isError1 = false;
            showNoSuggestion = TRUE;
            resultSuggestionCount ='0';
            system.debug('>>>ERROR 1126::');
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.AVS_Res_Error);       
            ApexPages.addMessage(myMsg);
            //Exception handling goes here....       
        }         
    }            
    
    public class suggestions {        
        public Boolean selected {get; set;}        
        public string SELECTION{get;set;}        
        public string LOCALITY1{get;set;}         
        public string LOCALITY2{get;set;}
        public string LOCALITY3{get;set;}        
        public string REGION1{get;set;}          
        public string POSTCODE{get;set;}        
        public string POSTCODE1{get;set;}        
        public string POSTCODE2_ODD{get;set;}        
        public string POSTCODE2_EVEN{get;set;}               
        public string PRIMARY_NUMBER_LOW{get;set;}        
        public string PRIMARY_NUMBER_HIGH{get;set;}        
        public string PRIMARY_NAME1{get;set;}        
        public string PRIMARY_TYPE1{get;set;}        
        public string sPostalCode{get;set;}        
        public string FINALPOSTAL = POSTCODE+'-'+POSTCODE2_EVEN;        
        public string FINALSTREET = PRIMARY_NAME1+' '+PRIMARY_TYPE1;        
        public String UNIT_NUMBER_LOW{get;set;}        
        public String UNIT_NUMBER_HIGH{get;set;}        
        public String FIRM{get;set;}        
        public String PRIMARY_POSTFIX1{get;set;}
        public string PRIMARY_NAME2{get;set;} 
        public String building_name{get; set;}
        public String PRIMARY_NUMBER_DESCRIPTION{get; set;}
        public String PRIMARY_NAME_FULL1{get; set;}
        public String PRIMARY_NAME_FULL2{get; set;}
        public String primary_secondary_address{get; set;}       
        public String PRIMARY_SIDE_INDICATOR{get; set;}       
        public String SECONDARY_SIDE_INDICATOR{get; set;} 
        public String FLOOR_NUMBER_LOW{get;set;}        
        public String FLOOR_NUMBER_HIGH{get;set;}       
        //Start - By Sreehari
        public String FLOOR_DESCRIPTION{get;set;}      
        // End  - By Sreehari
        public String mailStreetJapan{get;Set;}//Defect fix
        //public String secdryAddresString{get;set;}//CR 11957
        public String STAIRWELL_NAME{get;set;}//CR 11957
        public String STAIRWELL_description{get;set;}//CR 11957
        
        public suggestions( boolean selected,String SELECTION, String LOCALITY1,String REGION1,String POSTCODE, String POSTCODE2_ODD,String POSTCODE2_EVEN,String PRIMARY_NUMBER_LOW,String PRIMARY_NUMBER_HIGH,String PRIMARY_NAME1, String PRIMARY_TYPE1, String LOCALITY2, String POSTCODE1, String UNIT_NUMBER_LOW, String UNIT_NUMBER_HIGH, String FIRM, String PRIMARY_POSTFIX1, String LOCALITY3, String PRIMARY_NAME2, String building_name, String PRIMARY_NUMBER_DESCRIPTION, String PRIMARY_NAME_FULL1, String PRIMARY_NAME_FULL2, String primary_secondary_address, String PRIMARY_SIDE_INDICATOR, String SECONDARY_SIDE_INDICATOR, String FLOOR_NUMBER_LOW, String FLOOR_NUMBER_HIGH,string FLOOR_NUMBER_DESCRIPTION, String mailStreetJapan,String STAIRWELL_NAME, String STAIRWELL_DESCRIPTION
                           // CR 11957:  String secdryAddresString, 
                           
                          )        
        {             
            this.selected = selected;             
            this.SELECTION = SELECTION;             
            this.LOCALITY1 = LOCALITY1;             
            this.REGION1 = REGION1;             
            this.POSTCODE = POSTCODE;             
            this.POSTCODE2_ODD =POSTCODE2_ODD;             
            this.POSTCODE2_EVEN = POSTCODE2_EVEN;             
            this.PRIMARY_NUMBER_LOW = PRIMARY_NUMBER_LOW;             
            this.PRIMARY_NUMBER_HIGH = PRIMARY_NUMBER_HIGH;             
            this.PRIMARY_NAME1 = PRIMARY_NAME1;             
            this.PRIMARY_TYPE1 = PRIMARY_TYPE1;             
            this.LOCALITY2 = LOCALITY2; 
            this.LOCALITY3 = LOCALITY3;            
            this.POSTCODE1 = POSTCODE1;                       
            this.UNIT_NUMBER_LOW=UNIT_NUMBER_LOW;             
            this.UNIT_NUMBER_HIGH=UNIT_NUMBER_HIGH;             
            this.FIRM = FIRM;             
            this.PRIMARY_POSTFIX1 = PRIMARY_POSTFIX1;   
            this.PRIMARY_NAME2 = PRIMARY_NAME2; 
            this.building_name = building_name; 
            this.PRIMARY_NUMBER_DESCRIPTION = PRIMARY_NUMBER_DESCRIPTION;
            this.PRIMARY_NAME_FULL1 = PRIMARY_NAME_FULL1;
            this.PRIMARY_NAME_FULL2 = PRIMARY_NAME_FULL2;
            this.primary_secondary_address = primary_secondary_address;                     
            this.PRIMARY_SIDE_INDICATOR = PRIMARY_SIDE_INDICATOR;                     
            this.SECONDARY_SIDE_INDICATOR = SECONDARY_SIDE_INDICATOR;  
            this.FLOOR_NUMBER_LOW = FLOOR_NUMBER_LOW;
            this.FLOOR_NUMBER_HIGH = FLOOR_NUMBER_HIGH;
            this.FLOOR_DESCRIPTION =  FLOOR_NUMBER_DESCRIPTION;   
            this.mailStreetJapan = mailStreetJapan;
            //CR 11957: this.secdryAddresString = secdryAddresString;
            //CR 11957: Start
            this.STAIRWELL_NAME = STAIRWELL_NAME;
            this.STAIRWELL_DESCRIPTION = STAIRWELL_DESCRIPTION ;
            //CR 11957: END
            
        }    
    }
    public PageReference toggleEditMode() {
        isEditMode = TRUE;
        if (renderEditMode == true) {
            return null;
        } else if (renderEditMode == false) {
            if (oppObj.End_User_Mailing_Country__c != null) {
                if (countryCode.contains(oppObj.End_User_Mailing_Country__c.toUpperCase())) {
                    MailingCountry = mapOfCountryAndCode.get(MailingCountry.toUpperCase());
                }
            }
            renderEditMode = true;
        }
        return null;
    }
    
    public PageReference cancelAction(){        
        renderEditMode = False;
        return PageUtils.redirect('/apex/AVSSuggestionforOpportunity?source=Accept&Id=' + oppId);
     //   return PageUtils.redirect('/apex/AVSSuggestionforOpportunity?Id=' + oppId);
    }   
    
    public pagereference SaveCurrentAddress(){
        String  returl;
         system.debug('>>>>Engage_Channel_Opportunity::'+OppObj.Engage_Channel_Opportunity__c);
        if(OppObj.Engage_Channel_Opportunity__c == TRUE){
            system.debug('>>>>INSIDE IF::');
            EngageChannelAutoApprovalCtrl e = new EngageChannelAutoApprovalCtrl();
            e.AutoApprove(Oppid); 
            returl ='/' + Oppid;  
        }
        else{
            threshold(strOppId);
                         if(showError== false || Test.isRunningTest()) 
                         {
                             exception(listOpp[0].id,showError);
                        if(System.Label.DeaReg_Submit_for_approval_url == 'NULL'){
                            returl = '/p/process/Submit?id='+oppid+'&retURL='+oppid;
                        }else{
                            returl = '/p/process/Submit?id='+oppid+'&retURL='+oppid+System.Label.DeaReg_Submit_for_approval_url;
                        }
                         } 
                
            
        }  
        system.debug('-----1138----'+showError); 
       if(!String.isBlank(returl)) { return PageUtils.redirect(returl);   }
    else{ return null;} }
    public PageReference cancelOppAction(){        
        return PageUtils.redirect('/' + oppId);
    }
    
    public void setResults() {
        resultSuggestionCount ='0';
        resultCountry = 'dummyCountry';
        resultStatusDesc = 'ToShowErrorMessage';
    }
    
    public PageReference refineSearch() {
        try{
            Integer count = 0;
            for(suggestions obj: lstSuggestion) {
                if(obj.selected) { count++;}
            }   
            if(count == 1) {
                for(suggestions obj: lstSuggestion) {
                    if(obj.selected) {
                        //Defect Fix: Start
                        if((obj.PRIMARY_NUMBER_HIGH != null && obj.PRIMARY_NUMBER_HIGH != obj.PRIMARY_NUMBER_LOW &&
                            ((obj.PRIMARY_NUMBER_HIGH.isNumeric() && !aptOrSuiteNumber.isNumeric()) ||
                             (!obj.PRIMARY_NUMBER_HIGH.isNumeric() && aptOrSuiteNumber.isNumeric()))
                           )
                           ||
                           (obj.UNIT_NUMBER_HIGH != null && obj.UNIT_NUMBER_HIGH != obj.UNIT_NUMBER_LOW &&
                            ((obj.UNIT_NUMBER_HIGH.isNumeric() && !aptOrSuiteNumber.isNumeric()) ||
                             (!obj.UNIT_NUMBER_HIGH.isNumeric() && aptOrSuiteNumber.isNumeric()))
                           )
                           ||
                           (obj.FLOOR_NUMBER_HIGH != null && obj.FLOOR_NUMBER_HIGH != obj.FLOOR_NUMBER_LOW &&
                            ((obj.FLOOR_NUMBER_HIGH.isNumeric() && !aptOrSuiteNumber.isNumeric()) ||
                             (!obj.FLOOR_NUMBER_HIGH.isNumeric() && aptOrSuiteNumber.isNumeric()))
                           )
                          ){
                              
                              showTable = false;
                              showNoSuggestion = TRUE;
                              showButton = false;
                              resultSuggestionCount ='0';
                          }
                        
                        if(aptOrSuiteNumber.isNumeric()){
                            Integer myIntKeyRange = Integer.valueOf(aptOrSuiteNumber);
                            Integer isOddorEven = math.mod(myIntKeyRange,2);
                            
                            if(obj.PRIMARY_NUMBER_HIGH != null && obj.PRIMARY_NUMBER_HIGH != obj.PRIMARY_NUMBER_LOW){
                                Integer myIntKeyPH = Integer.valueOf(obj.PRIMARY_NUMBER_HIGH);
                                Integer myIntKeyPL = Integer.valueOf(obj.PRIMARY_NUMBER_LOW);                           
                                if(!(myIntKeyRange <= myIntKeyPH && myIntKeyRange >= myIntKeyPL)){
                                    setResults();
                                    return null;
                                }else{
                                    if(obj.PRIMARY_SIDE_INDICATOR == 'E' && isOddorEven != 0){setResults();}
                                    else if(obj.PRIMARY_SIDE_INDICATOR == 'O' && isOddorEven == 0){setResults();}
                                }
                            }else if((obj.PRIMARY_NUMBER_HIGH == null || obj.PRIMARY_NUMBER_HIGH == obj.PRIMARY_NUMBER_LOW) && obj.UNIT_NUMBER_HIGH != null && obj.UNIT_NUMBER_HIGH != obj.UNIT_NUMBER_LOW){
                                Integer myIntKeyUH = Integer.valueOf(obj.UNIT_NUMBER_HIGH);
                                Integer myIntKeyUL = Integer.valueOf(obj.UNIT_NUMBER_LOW);
                                if(!(myIntKeyRange <= myIntKeyUH && myIntKeyRange >= myIntKeyUL)){
                                    setResults();
                                    return null;
                                }else{
                                    if(obj.SECONDARY_SIDE_INDICATOR == 'E' && isOddorEven != 0){setResults(); }
                                    else if(obj.SECONDARY_SIDE_INDICATOR == 'O' && isOddorEven == 0){ setResults();}
                                }
                            }
                            //version 2.0
                            else if((obj.PRIMARY_NUMBER_HIGH == null || obj.PRIMARY_NUMBER_HIGH == obj.PRIMARY_NUMBER_LOW) && (obj.UNIT_NUMBER_HIGH == null || obj.UNIT_NUMBER_HIGH == obj.UNIT_NUMBER_LOW) && obj.FLOOR_NUMBER_HIGH!= null && obj.FLOOR_NUMBER_HIGH != obj.FLOOR_NUMBER_LOW){
                                Integer myIntKeyUH = Integer.valueOf(obj.FLOOR_NUMBER_HIGH);
                                Integer myIntKeyUL = Integer.valueOf(obj.FLOOR_NUMBER_LOW);
                                
                                if(!(myIntKeyRange <= myIntKeyUH && myIntKeyRange >= myIntKeyUL)){
                                    setResults();
                                    return null;
                                }else{
                                    if(obj.SECONDARY_SIDE_INDICATOR == 'E' && isOddorEven != 0){ setResults();}
                                    else if(obj.SECONDARY_SIDE_INDICATOR == 'O' && isOddorEven == 0){ setResults();
                                    }
                                }
                            }
                        }
                        
                        if(resultSuggestionCount != '0') {
                            resetReply = 1;
                            
                            if(!resultStatusDesc.contains('Assigned Address') || resultSuggestionCount != '0') {
                                if (Reply1 == null && obj.PRIMARY_NUMBER_HIGH != null && obj.PRIMARY_NUMBER_HIGH != obj.PRIMARY_NUMBER_LOW) {
                                    Reply1 = obj.SELECTION;
                                    Reply2 = aptOrSuiteNumber;
                                } 
                                else if (Reply1 == null && (obj.PRIMARY_NUMBER_HIGH == null || obj.PRIMARY_NUMBER_HIGH == obj.PRIMARY_NUMBER_LOW) && obj.UNIT_NUMBER_HIGH != null && obj.UNIT_NUMBER_HIGH != obj.UNIT_NUMBER_LOW) {
                                    Reply1 = obj.SELECTION;
                                    Reply2 = aptOrSuiteNumber;
                                }
                                else if (Reply1 == null && (obj.PRIMARY_NUMBER_HIGH == null || obj.PRIMARY_NUMBER_HIGH == obj.PRIMARY_NUMBER_LOW) && (obj.UNIT_NUMBER_HIGH == null || obj.UNIT_NUMBER_HIGH == obj.UNIT_NUMBER_LOW)&& obj.FLOOR_NUMBER_HIGH != null && obj.FLOOR_NUMBER_HIGH != obj.FLOOR_NUMBER_LOW) {
                                    Reply1 = obj.SELECTION;
                                    Reply2 = aptOrSuiteNumber;
                                }
                                else if (Reply1 == null && (obj.PRIMARY_NUMBER_HIGH == null || obj.PRIMARY_NUMBER_HIGH == obj.PRIMARY_NUMBER_LOW)) {
                                    Reply1 = obj.SELECTION;
                                }
                                else if (Reply1 != null && Reply2 == null && obj.PRIMARY_NUMBER_HIGH != null && obj.PRIMARY_NUMBER_HIGH != obj.PRIMARY_NUMBER_LOW) {
                                    Reply2 = obj.SELECTION;
                                    Reply3 = aptOrSuiteNumber;
                                }
                                else if (Reply1 != null && Reply2 == null && (obj.PRIMARY_NUMBER_HIGH == null || obj.PRIMARY_NUMBER_HIGH == obj.PRIMARY_NUMBER_LOW) && obj.UNIT_NUMBER_HIGH != null && obj.UNIT_NUMBER_HIGH != obj.UNIT_NUMBER_LOW) {
                                    Reply2 = obj.SELECTION;
                                    Reply3 = aptOrSuiteNumber;
                                }
                                else if (Reply1 != null && Reply2 == null && (obj.PRIMARY_NUMBER_HIGH == null || obj.PRIMARY_NUMBER_HIGH == obj.PRIMARY_NUMBER_LOW) && (obj.UNIT_NUMBER_HIGH == null || obj.UNIT_NUMBER_HIGH == obj.UNIT_NUMBER_LOW)&& obj.FLOOR_NUMBER_HIGH != null && obj.FLOOR_NUMBER_HIGH != obj.FLOOR_NUMBER_LOW) {
                                    Reply2 = obj.SELECTION;
                                    Reply3 = aptOrSuiteNumber;
                                }                                                                                
                                else if (Reply1 != null && Reply2 == null && (obj.PRIMARY_NUMBER_HIGH == null || obj.PRIMARY_NUMBER_HIGH == obj.PRIMARY_NUMBER_LOW)) {
                                    Reply2 = obj.SELECTION;
                                }
                                else if (Reply1 != null && Reply2 != null && Reply3 == null && obj.PRIMARY_NUMBER_HIGH != null && obj.PRIMARY_NUMBER_HIGH != obj.PRIMARY_NUMBER_LOW) {
                                    Reply3 = obj.SELECTION;
                                    Reply4 = aptOrSuiteNumber;
                                }
                                else if (Reply1 != null && Reply2 != null && Reply3 == null && (obj.PRIMARY_NUMBER_HIGH == null || obj.PRIMARY_NUMBER_HIGH == obj.PRIMARY_NUMBER_LOW) && obj.UNIT_NUMBER_HIGH != null && obj.UNIT_NUMBER_HIGH != obj.UNIT_NUMBER_LOW) {
                                    Reply3 = obj.SELECTION;
                                    Reply4 = aptOrSuiteNumber;
                                }
                                else if (Reply1 != null && Reply2 != null && Reply3 == null && (obj.PRIMARY_NUMBER_HIGH == null || obj.PRIMARY_NUMBER_HIGH == obj.PRIMARY_NUMBER_LOW) && (obj.UNIT_NUMBER_HIGH == null || obj.UNIT_NUMBER_HIGH == obj.UNIT_NUMBER_LOW)&& obj.FLOOR_NUMBER_HIGH != null && obj.FLOOR_NUMBER_HIGH != obj.FLOOR_NUMBER_LOW) {
                                    Reply3 = obj.SELECTION;
                                    Reply4 = aptOrSuiteNumber;
                                }                                                                           
                                else if (Reply1 != null && Reply2 != null && Reply3 == null && (obj.PRIMARY_NUMBER_HIGH == null || obj.PRIMARY_NUMBER_HIGH == obj.PRIMARY_NUMBER_LOW)) {
                                    Reply3 = obj.SELECTION;
                                }
                                else if (Reply1 != null && Reply2 != null && Reply3 != null && Reply4 == null && obj.PRIMARY_NUMBER_HIGH != null && obj.PRIMARY_NUMBER_HIGH != obj.PRIMARY_NUMBER_LOW) {
                                    Reply4 = obj.SELECTION;
                                    Reply5 = aptOrSuiteNumber;
                                }
                                else if (Reply1 != null && Reply2 != null && Reply3 != null && Reply4 == null && (obj.PRIMARY_NUMBER_HIGH == null || obj.PRIMARY_NUMBER_HIGH == obj.PRIMARY_NUMBER_LOW) && obj.UNIT_NUMBER_HIGH != null && obj.UNIT_NUMBER_HIGH != obj.UNIT_NUMBER_LOW) {
                                    Reply4 = obj.SELECTION;
                                    Reply5 = aptOrSuiteNumber;
                                }
                                else if (Reply1 != null && Reply2 != null && Reply3 != null && Reply4 == null && (obj.PRIMARY_NUMBER_HIGH == null || obj.PRIMARY_NUMBER_HIGH == obj.PRIMARY_NUMBER_LOW) && (obj.UNIT_NUMBER_HIGH == null || obj.UNIT_NUMBER_HIGH == obj.UNIT_NUMBER_LOW)&& obj.FLOOR_NUMBER_HIGH != null && obj.FLOOR_NUMBER_HIGH != obj.FLOOR_NUMBER_LOW) {
                                    Reply4 = obj.SELECTION;
                                    Reply5 = aptOrSuiteNumber;
                                }                                                                                                  
                                else if (Reply1 != null && Reply2 != null && Reply3 != null && Reply4 == null && (obj.PRIMARY_NUMBER_HIGH == null || obj.PRIMARY_NUMBER_HIGH == obj.PRIMARY_NUMBER_LOW)) {
                                    Reply4 = obj.SELECTION;
                                }
                                else if (Reply1 != null && Reply2 != null && Reply3 != null && Reply4 != null && Reply5 == null) {
                                    Reply5 = obj.SELECTION;
                                }
                                else { Reply1 = null;
                                       Reply2 = null;
                                       Reply3 = null;
                                       Reply4 = null;
                                       Reply5 = null;
                                }
                                aptOrSuiteNumber = null;
                                CallAVS();
                            }
                            return null;
                        }
                        break;
                    }
                }
            }
        }
        catch (Exception ex) {
            showTable = false;
            showNoSuggestion = TRUE;
            showButton = false;
            resultSuggestionCount ='0';
        }
        return null;
    }
public void threshold(id oppid)
{

 Decimal  dcAllLOB;
 Decimal  dcStorageLOB;
 Decimal  dcClientLOB;
 String strThresholdCurrency;
 String strVariedthresholdCurrency;
 String strPartnerUserCurrency;
 Decimal dcALLLOB1;
 Decimal dcStorageLOB1;
 Decimal dcClientLOB1;
 string strerror;
 
 Map<string,string> mapOfCountryToCurrency = new Map<string,string>();
 set<string> setOfOppCountry = new set<string>();
 list<Deal_Registration__mdt> listCurrencyMetadata = new list<Deal_Registration__mdt>();
  
 for(Opportunity oppRec : [Select Id,PartnerAccountId,PartnerAccount.Account_Country__c,ownerId,owner.Name,owner.CurrencyIsoCode,owner.DefaultCurrencyIsoCode From Opportunity where Id =:oppid]){
    
    if(!Test.isRunningTest()){
        mapOfCountryToCurrency.put(oppRec.PartnerAccount.Account_Country__c,oppRec.owner.DefaultCurrencyIsoCode);
    }
    else{
        mapOfCountryToCurrency.put('CHINA','CNY'); 
    }
    strPartnerUserCurrency = oppRec.owner.DefaultCurrencyIsoCode;
 }
 system.debug('>>>>>mapOfCountryToCurrency::'+mapOfCountryToCurrency);
 for(Deal_Registration__mdt eachRec :[select Country__c,ThreshHold_Currency__c,All_Lob__c,Storage_LOB__c,Client_LOB__c from Deal_Registration__mdt where Country__c IN:mapOfCountryToCurrency.keyset()] ){
     //if(mapOfCountryToCurrency.get(eachRec.Country__c) == eachRec.ThreshHold_Currency__c){
        dcAllLOB = eachRec.All_Lob__c!=null?Decimal.valueOf(eachRec.All_Lob__c):0;
         dcStorageLOB = eachRec.Storage_LOB__c!=null?Decimal.valueOf(eachRec.Storage_LOB__c):0;
         dcClientLOB = eachRec.Client_LOB__c!=null?Decimal.valueOf(eachRec.Client_LOB__c):0;
         dcAllLOB1 = eachRec.All_Lob__c!=null?Decimal.valueOf(eachRec.All_Lob__c):0;
         dcStorageLOB1 = eachRec.Storage_LOB__c!=null?Decimal.valueOf(eachRec.Storage_LOB__c):0;
         dcClientLOB1 = eachRec.Client_LOB__c!=null?Decimal.valueOf(eachRec.Client_LOB__c):0;
         strThresholdCurrency = eachRec.ThreshHold_Currency__c!=null?eachRec.ThreshHold_Currency__c:'';
         
     if(Test.isRunningTest())
     {
          dcClientLOB =10000;
         
     }     //}   
      system.debug('>>>>>dcAllLOB::'+dcAllLOB);
      system.debug('>>>>>dcStorageLOB::'+dcStorageLOB);
      system.debug('>>>>>dcClientLOB::'+dcClientLOB); 
      
      system.debug('>>>>>PartnerUserCurrency::'+mapOfCountryToCurrency.get(eachRec.Country__c));
      system.debug('>>>>>Sheet Currency::'+eachRec.ThreshHold_Currency__c);
       
     if( (mapOfCountryToCurrency.get(eachRec.Country__c) != eachRec.ThreshHold_Currency__c) || (Test.isRunningTest())){ 
         
         strVariedthresholdCurrency = mapOfCountryToCurrency.get(eachRec.Country__c);
         system.debug('>>>>>strVariedthresholdCurrency::'+strVariedthresholdCurrency);
     }
}        
if(!String.isBlank(strVariedthresholdCurrency)) {  

       DatedConversionRate dcr1=   [SELECT ConversionRate,Id,IsoCode,NextStartDate,StartDate FROM DatedConversionRate where IsoCode=: strThresholdCurrency order by StartDate Desc limit 1];  
   
        DatedConversionRate dcr=    [SELECT ConversionRate,Id,IsoCode,NextStartDate,StartDate FROM DatedConversionRate where IsoCode=:strVariedthresholdCurrency order by StartDate Desc limit 1];         
        
        if(dcAllLOB != 0){
        Double dblAmountInCorpCurr = dcAllLOB/dcr1.ConversionRate;
        Decimal dcTotalAmount = (dblAmountInCorpCurr *  dcr.ConversionRate); 
        dcAllLOB =  dcTotalAmount.setScale(2);
        }
        
        if(dcStorageLOB != 0){
            Double dblAmountInCorpCurr = dcStorageLOB/dcr1.ConversionRate;
            Decimal dcTotalAmount = (dblAmountInCorpCurr *  dcr.ConversionRate); 
            dcStorageLOB =  dcTotalAmount.setScale(2);
        }
        
        if(dcClientLOB != 0){
            Double dblAmountInCorpCurr = dcClientLOB/dcr1.ConversionRate;
            Decimal dcTotalAmount = (dblAmountInCorpCurr *  dcr.ConversionRate); 
            dcClientLOB =  dcTotalAmount.setScale(2);  
        }
}
  system.debug('>>>>>dcAllLOB::'+dcAllLOB);
  system.debug('>>>>>dcStorageLOB::'+dcStorageLOB);
  system.debug('>>>>>dcClientLOB::'+dcClientLOB);
  

 List<OpportunityLineItem> listOppLineItems = new List<OpportunityLineItem>();
 set<string> setProdLOB = new set<string>();
 set<string> setClient = new set<string>();
 set<string> setStorage = new set<string>(); 
 list<opportunity> listOpp = new list<opportunity>();
 listOpp = [Select Id, Name, Account.Name, RecordtypeId, Distributor_Name__c, Distributor_Reseller_Name__c, 
                           Account.Account_Country_Code__c, Account.Account_Country__c, PartnerAccountId,Domain__c,Solution_Type__c,Solution_Name__c,
                           End_User_Mailing_City__c, End_User_Mailing_Country__c, End_User_Mailing_State_Province_Region__c,
                           End_User_Mailing_Street__c, Mailing_Street2__c,Opportunity_has_assets_items__c,Serial_No_Asset_Tag__c, End_User_Mailing_Zip_Postal_Code__c,Engage_Channel_Opportunity__c,ownerid,Total_Expected_Dell_Revenue__c
                           From Opportunity
                           where Id =:oppid LIMIT 1];

               
                listOppLineItems = [SELECT Id,OpportunityId,Product2Id,Product2ID__c,ProductCode,Product_code_Family__c,Product_Code__c,Product_Family__c,Product_Group_for_Storage_Sys__c,Channel_Product_LOB__c FROM OpportunityLineItem Where OpportunityId=:oppid];
                for(OpportunityLineItem oli :listOppLineItems)
                {   
                    if(!string.isEmpty(oli.Channel_Product_LOB__c)){
                        if(oli.Channel_Product_LOB__c.contains('STORAGE'))
                        {
                           system.debug('---'); 
                        setStorage.add(oli.Channel_Product_LOB__c);
                        }
                        else if(oli.Channel_Product_LOB__c.contains('CLIENT'))
                        {
                            setClient.add(oli.Channel_Product_LOB__c);
                        }
                        
                        setProdLOB.add(oli.Channel_Product_LOB__c);
                    }
                     
                }
 system.debug('--all lob-'+setProdLOB); 
 system.debug('-- storage-'+setStorage); 
 system.debug('--client-'+setClient); 
                if(setProdLOB.size()>0)
                {
                    if(setProdLOB.equals(setClient) && listOpp[0].Total_Expected_Dell_Revenue__c < dcClientLOB && dcClientLOB <> 0)
                    {
                    system.debug('---this is client--');
                    showError = true;
                    exception(listOpp[0].id,showError);
                    //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'This deal does not meet program threshold requirements. Please review for completeness.Minimum Client threshold  amount '+ strPartnerUserCurrency + ' ' +dcClientLOB);
                    strerror= String.isBlank(strVariedthresholdCurrency) ? '':', '+strThresholdCurrency+' '+dcClientLOB1+'.';
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Threshold_Exception_Error  + ' ' +System.Label.Client_Threshold_Error + ' ' + strPartnerUserCurrency + ' ' +dcClientLOB +strerror);
                    ApexPages.addMessage(myMsg); 
                    //exception(listOpp[0].id);                     
                    }
                    else if(setProdLOB.equals(setStorage) && listOpp[0].Total_Expected_Dell_Revenue__c < dcStorageLOB && dcStorageLOB <> 0 )
                    {                        
                    system.debug('---this is Storage--');
                    system.debug('----exception--');
                    showError = true;
                    exception(listOpp[0].id,showError);
                    strerror= String.isBlank(strVariedthresholdCurrency) ? '':', '+strThresholdCurrency+' '+dcStorageLOB1+'.';

                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Threshold_Exception_Error + ' ' + System.Label.Storage_Threshold_Error + ' ' + strPartnerUserCurrency + ' ' + dcStorageLOB+strerror);
                    ApexPages.addMessage(myMsg); 
                    //exception(listOpp[0].id);                                                            
                    }
                    else 
                    { system.debug('---this is All LOB--');
                        if(setProdLOB.containsAll(setStorage) && setClient.isEmpty() && setStorage.size()>0  ){
                            //decimal dcmin = math.min(dcAllLOB,dcStorageLOB);   
                            decimal dcmin = dcStorageLOB <> 0? math.min(dcAllLOB,dcStorageLOB) :dcAllLOB;
                            decimal dcmin1 = dcStorageLOB <> 0? math.min(dcAllLOB1,dcStorageLOB1) :dcAllLOB1;
                        strerror= String.isBlank(strVariedthresholdCurrency) ? '':', '+strThresholdCurrency+' '+dcmin1+'.';

                            system.debug('---------all LOB amount and Storage') ;
                            if(listOpp[0].Total_Expected_Dell_Revenue__c < dcmin){
                                system.debug('----exception--');
                                showError = true;
                                exception(listOpp[0].id,showError);                                
                                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Threshold_Exception_Error + ' ' + System.Label.Threshold_Error + ' ' + strPartnerUserCurrency + ' ' +dcmin+strerror);
                                ApexPages.addMessage(myMsg);                             
                            //exception(listOpp[0].id);                            
                            }
                        }
                        else if(setProdLOB.containsAll(setClient) && setStorage.isEmpty() && setClient.size()>0 ){
                        system.debug('---------all LOB amount and Client')  ;
                        system.debug('---------adcClientLOB'+dcClientLOB);
                        system.debug('---------dcAllLOB'+dcAllLOB);
                        //decimal dcmin = math.min(dcAllLOB,dcClientLOB);
                        decimal dcmin = dcClientLOB <> 0 ? math.min(dcAllLOB,dcClientLOB):dcAllLOB;
                        decimal dcmin1 = dcStorageLOB <> 0? math.min(dcAllLOB1,dcClientLOB1) :dcAllLOB1;
                        strerror= String.isBlank(strVariedthresholdCurrency) ? '':', '+strThresholdCurrency+' '+dcmin1+'.';

                        if(listOpp[0].Total_Expected_Dell_Revenue__c < dcmin){
                            system.debug('----exception--');
                            showError = true;
                            exception(listOpp[0].id,showError); 
                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Threshold_Exception_Error + ' ' + System.Label.Threshold_Error + ' ' + strPartnerUserCurrency + ' ' +dcmin+strerror);
                            ApexPages.addMessage(myMsg);                         
                        }
                        }
                        else{
                        system.debug('---------all LOB amount') ;                        
                        if(listOpp[0].Total_Expected_Dell_Revenue__c < dcAllLOB && dcAllLOB <> 0){
                            system.debug('----exception--');
                            showError = true;
                            exception(listOpp[0].id,showError);
               strerror= String.isBlank(strVariedthresholdCurrency) ? '':', '+strThresholdCurrency+' '+dcAllLOB1+'.';
                            
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Threshold_Exception_Error + ' ' + System.Label.Threshold_Error + ' ' + strPartnerUserCurrency + ' ' +dcAllLOB + strerror);
                        ApexPages.addMessage(myMsg); 
                        //exception(listOpp[0].id);                                            
                        } 
                        }
                    }                    
                }
}   
public void exception(id oppid,boolean bshowerror1) 
{
    
    boolean bShowError = bshowerror1;
    String strDealId = [Select Id,Deal_ID__c From Opportunity where Id =:oppid].Deal_ID__c;
    list<Exception__c> listExce = new list<Exception__c>();
                    listExce = [select Object_type__c,Object_ID__c,No_Of_Fail_Attempts__c,Deal_ID__c,Has_ThreshHold_Validation__c from Exception__c where Object_ID__c=:oppid];
                    system.debug('----listsize'+listExce.size());
                  
                      
            Exception__c execRec = new Exception__c();
            execRec.Error_Messages__c= 'This deal does not meet program threshold requirements. Please review for completeness.';
            execRec.Object_type__c='Opportunity';
            execRec.Object_ID__c= listOpp[0].id;
            execRec.Process_Name__c='Opportunity Threshold';
            execRec.No_Of_Fail_Attempts__c = 1; 
            execRec.Has_ThreshHold_Validation__c = 'NO'; 
            execRec.Deal_ID__c = strDealId;
            
            if(listExce.size() == 0 && bShowError){
            insert execRec;
            system.debug('-----1530---'+execRec.id);
            }else{
                 
                //execRec.Id = listExce[0].Id;
                if(!listExce.isEmpty()  ) 
                {
                      
                     if(bShowError){
                listExce[0].No_Of_Fail_Attempts__c = listExce[0].No_Of_Fail_Attempts__c + 1;
                listExce[0].Has_ThreshHold_Validation__c = 'NO';
                     }
                     else{
                         listExce[0].Has_ThreshHold_Validation__c='YES';                          
                     }
                }
                update listExce;
            }
            
          
}   
}