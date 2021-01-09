/* 
History:
Version  Revision     Date           Modified By                     Description     
1.0       R16.07    11-Jun-2015       Jiji                           Controller class for OpportunityApprovalActionPanel
2.0       R16.07    12-Jun-2015       Bikram                         Added Code for Progress Bar
3.0       R16.07    26-June-2015      Praveen Babu                   Added Extra fields in Action panel
4.0       R16.07    11-Aug-2015       Santosh/Yeswanth/Suresh        CR's 11805,11807  
5.0       R16.07    20-Aug-2015       Devika                         CR 11830- To redirect user to Open Oppty Conflict Page 
6.0       R16.07    16-Sept-2015      Impana                         Display conflict link for LOB registration conflicts                                
7.0       R16.10    13-Oct-2015       Jiji                           CR: 12081 : Approval Action Panel UI Simplification
8.0       R16.12    26-Nov-2015       Impana                         CR:12388 - Redirect the user to Open oppty lookup report
9.0       R16.12    17-Dec-2015       Jiji                           CR:12471: Check Partner Account for Potential LOB Conflicts
10.0      R16.12    29-Dec-2015       Jiji                           CR:12513: Display Duplicate Found Label
11.0                06-Jun-2016       Srikanth                       CR:     : Disti Visibility - Action Panel Alert for Missing Distributor/Reseller Account Name Check
12.0                08-Jan-2019       Meenu                          FY20-DCE-0202   16970   Field Trip clean up for Opportunity (Removed/Commented 
                                                                      add_deal_type_overlay_specialist__c,check_for_cross_border_deals__c,check_for_deal_threshold__c,
                                                                      check_for_distribution_deals__c,check_for_other_channel_program__c,check_for_sales_marketing_programs__c,
                                                                      check_for_specialty_dell_account__c,check_for_specialty_partner__c,check_for_specialty_product__c,
                                                                      check_for_u_s_fed_mismatch__c,conduct_dell_account_selection__c,review_lob_awards__c field)
13.0      DCE-0402  04-Mar-2019       Emily                          Story 5936162 Removed/Commented check_for_u_s_fed_mismatch__c & review_open_opportunity__c                                       
*/

public with sharing class OpportunityApprovalActionPannelExt {


    //public Boolean duplicateFlag{get;set;}
    
    
    public Opportunity oppObj{ get; set; }
    Public Id oppId{get;set;}
    //Public String ActionType{get; set;}
    Public boolean noError{get; Set;}
    
    /*12.0  1-8-2019 Meenu  FY20-DCE-0202   16970   Field Trip clean up for Opportunity, removed check_for_cross_border_deals__c reference*/
    //public String CrossBorderLabel{get; Set;}
    
    /*12.0  1-8-2019 Meenu  FY20-DCE-0202   16970   Field Trip clean up for Opportunity, removed conduct_dell_account_selection__c reference*/
    //public String AccountSelectionLabel{get; Set;}
    
     /*12.0  1-8-2019 Meenu  FY20-DCE-0202   16970   Field Trip clean up for Opportunity, removed Check_for_U_S_Fed_Mismatch__c reference*/
    //public String USFedMismatchLabel{get; Set;}
    
     /*12.0  1-8-2019 Meenu  FY20-DCE-0202   16970   Field Trip clean up for Opportunity, removed Review_Open_Opportunity__c reference*/
    //public String ReviewOpenOpportunity{get; Set;}
    
    /*12.0  1-8-2019 Meenu  FY20-DCE-0202   16970   Field Trip clean up for Opportunity, removed Review_LOB_Awards__c reference*/
    //public String ReviewLOBAwards{get; Set;}
    
    // Variables for CR's 11805,11807 
    public String usFedmismatchDealAlert {get;set;}
    public boolean isUnAssignedUser {get;set;}
    
    public String distributionInfoAlert {get;set;}
    public String partnerSelectedDunsInfoAlert {get;set;}
    
    /*12.0  1-8-2019 Meenu  FY20-DCE-0202   16970   Field Trip clean up for Opportunity, removed check_for_distribution_deals__c reference*/
    //public String CheckforDistributionDeals {get; Set;}
    
    // v5.0 Open Oppty conflictController 
    public Boolean opptyConflictFlag {get;set;}
    public Boolean duplicateFlag {get;set;} //Ver 10.0 
    //v8.0
    public boolean blankChannelLOB{get;set;}
    public String opptyAccountId{get;set;}
    public String reportId{get;set;}

    //v6.0
    public Boolean lobConflictFlag{get;set;}
    public Boolean undefinedProductFlag {get;set;}
    
    /* Ver 7.0: CR 12081: Approval Action Panel UI Simplification: Start
    
    public String SpecialtyAccountLabel{get; Set;}
    public String DealThresholdLabel{get; Set;}
    public String SpecialtyPartner{get; Set;}
    public String OtherChannelProgram{get; Set;}
    public String SpecialtyProduct{get; Set;}
    public String SalesMarketingPrograms{get; Set;}
    public String DealTypeOverlaySpecialist{get; Set;}
    public String ApproveRejectDeal{get; Set;}
    public Boolean displayApproveRejectLink {get;set;}  
    public String approveRejectUrl {get;set;}
    public Boolean shouldRedirect {get; set;}
    public List<ProcessInstanceWorkitem> workItemList {get;set;}
    public List<ProcessInstanceWorkitem> workItemListForSysAdmin {get;set;}
    
    //Progress Bar Variables
    public Double percentComplete {get;set;}
    public static Long TOTAL_FLAG_COUNT = long.Valueof(System.Label.Action_Panel_Flag_Count);
    public integer count ;
    
    Ver 7.0: CR 12081: Approval Action Panel UI Simplification: End*/

    public OpportunityApprovalActionPannelExt(ApexPages.StandardController controller) {
        /* Ver 7.0: CR 12081: Approval Action Panel UI Simplification: Start
        //Progress Bar Variables Initialization 
        count = 0;
        percentComplete = 0;
        Ver 7.0: CR 12081: Approval Action Panel UI Simplification: End*/
        reportId = System.Label.OpenOpptyReportLink;
        isUnAssignedUser = false;
        duplicateFlag = false; //Ver 10.0
         try{
            noError = True;
            
            /*12.0  1-8-2019 Meenu  FY20-DCE-0202   16970   Field Trip clean up for Opportunity, removed check_for_cross_border_deals__c reference*/
            //CrossBorderLabel = Schema.SObjectType.Opportunity.fields.Check_for_Cross_Border_Deals__c.getLabel();
            
            /*12.0  1-8-2019 Meenu  FY20-DCE-0202   16970   Field Trip clean up for Opportunity, removed Conduct_Dell_Account_Selection__c reference*/
           // AccountSelectionLabel = Schema.SObjectType.Opportunity.fields.Conduct_Dell_Account_Selection__c.getLabel();
           
           /*12.0  1-8-2019 Meenu  FY20-DCE-0202   16970   Field Trip clean up for Opportunity, removed USFedMismatchLabel reference*/
           // USFedMismatchLabel = Schema.SObjectType.Opportunity.fields.Check_for_U_S_Fed_Mismatch__c.getLabel();
            
             /*12.0  1-8-2019 Meenu  FY20-DCE-0202   16970   Field Trip clean up for Opportunity, removed Review_Open_Opportunity__c reference*/
            //ReviewOpenOpportunity= Schema.SObjectType.Opportunity.fields.Review_Open_Opportunity__c.getLabel();
            
            /*12.0  1-8-2019 Meenu  FY20-DCE-0202   16970   Field Trip clean up for Opportunity, removed Review_LOB_Awards__c reference*/
            //ReviewLOBAwards= Schema.SObjectType.Opportunity.fields.Review_LOB_Awards__c.getLabel();
            
            /*12.0  1-8-2019 Meenu  FY20-DCE-0202   16970   Field Trip clean up for Opportunity, removed check_for_distribution_deals__c reference*/
            //CheckforDistributionDeals = Schema.SObjectType.Opportunity.fields.Check_for_Distribution_Deals__c.getLabel(); 
            
            /* Ver 7.0: CR 12081: Approval Action Panel UI Simplification: Start
            
            SpecialtyAccountLabel = Schema.SObjectType.Opportunity.fields.Check_for_Specialty_Dell_Account__c.getLabel();
            DealThresholdLabel = Schema.SObjectType.Opportunity.fields.Check_for_Deal_Threshold__c.getLabel();
            OtherChannelProgram = Schema.SObjectType.Opportunity.fields.Check_for_Other_Channel_Program__c.getLabel();
            SpecialtyPartner= Schema.SObjectType.Opportunity.fields.Check_for_Specialty_Partner__c.getLabel();
            SalesMarketingPrograms= Schema.SObjectType.Opportunity.fields.Check_for_Sales_Marketing_Programs__c.getLabel();
            DealTypeOverlaySpecialist= Schema.SObjectType.Opportunity.fields.Add_Deal_Type_Overlay_Specialist__c.getLabel();
            ApproveRejectDeal= Schema.SObjectType.Opportunity.fields.Approve_Reject_Deal__c.getLabel();
            
            Ver 7.0: CR 12081: Approval Action Panel UI Simplification: End*/
             
            oppId=ApexPages.currentPage().getParameters().get('id'); 
            System.Debug('URTString --'+oppId);
            
            /*12.0  1-8-2019 Meenu  FY20-DCE-0202   16970   Field Trip clean up for Opportunity, removed add_deal_type_overlay_specialist__c,check_for_cross_border_deals__c,
            check_for_deal_threshold__c,check_for_other_channel_program__c,check_for_sales_marketing_programs__c,check_for_specialty_dell_account__c,
            check_for_specialty_partner__c,check_for_specialty_product__c,conduct_dell_account_selection__c,review_lob_awards__c from query*/
            
            oppObj = [Select Id, RecordtypeId, Number_of_Line_Items__c, End_User_Account_Name__c, End_User_Mailing_City__c, End_User_Mailing_State_Province_Region__c, 
                      Recordtype.Name, PartnerAccount.Sales_Channel__r.Name, Account.Sales_Channel__r.Name, /*Review_Open_Opportunity__c,*/
                      PartnerAccountId,End_Customer__r.DUNS_Number__c,// Ver 9.0
                      Owner.id, Distributor_Name__c, Distributor_Reseller_Name__c, /*Check_for_U_S_Fed_Mismatch__c,*/ Sales_Channel__c, Deal_Registration_Status__c,
                      Partner_Account_Country__c,End_User_Mailing_Country__c,Account.Unassigned_End_User_Account__c
                      ,(Select Product2.LOB_Category__c, Product2.Channel_Product_LOB__c From OpportunityLineItems) //6.0
                      from Opportunity where Id = :oppId];
                      
            usFedmismatchDealAlert = '';
            String fadVar = 'fed';
            
            /* Ver 7.0: CR 12081: Approval Action Panel UI Simplification: Start          
            if(oppObj.Check_for_Cross_Border_Deals__c == TRUE){ 
                count++;
            }
            if(oppObj.Conduct_Dell_Account_Selection__c == TRUE){
                count++;
            }
            if(oppObj.Check_for_Specialty_Dell_Account__c == TRUE){
                count++;
            }
            if(oppObj.Check_for_U_S_Fed_Mismatch__c == TRUE){
                count++;
            }
            if(oppObj.Check_for_Deal_Threshold__c == TRUE){
                count++;
            }
            if(oppObj.Check_for_Specialty_Partner__c== TRUE){
                count++;
            }
            if(oppObj.Check_for_Other_Channel_Program__c== TRUE){
                count++;
            }
            if(oppObj.Review_Open_Opportunity__c== TRUE){
                count++;
            }
            if(oppObj.Check_for_Specialty_Product__c== TRUE){
                count++;
            }
            if(oppObj.Review_LOB_Awards__c== TRUE){
                count++;
            }
            if(oppObj.Check_for_Sales_Marketing_Programs__c== TRUE){
                count++;
            }
            if(oppObj.Add_Deal_Type_Overlay_Specialist__c == TRUE){
                count++;
            }
            if(oppObj.Approve_Reject_Deal__c== TRUE){
                count++;
            }
            percentComplete = (Count*100)/TOTAL_FLAG_COUNT;
            system.Debug('------Count-----'+count);
            
            // CR# 11805 - To Enable/Disable the Approve/Reject link for valid Approvers
            If( oppObj.Deal_Registration_Status__c == 'Submitted'){
                workItemList = new List<ProcessInstanceWorkitem>();
                workItemList = getApprovalProcessRequest();
             
                If( workItemList.size() > 0  ){
                    // Check If valid Approver or not
                    displayApproveRejectLink = isValidApprover();
                }else If( UserInfo.getProfileId() == System.Label.System_Administrator_Profile_Id ){
                    displayApproveRejectLink = true;
                }else{
                    displayApproveRejectLink = false;
                }
                System.debug('**** displayApproveRejectLink '+ displayApproveRejectLink);
            }
            Ver 7.0: CR 12081: Approval Action Panel UI Simplification: End*/
            system.debug('----oppObj.Sales_Channel__c----'+oppObj.Sales_Channel__c);
            system.debug('----oppObj.Sales_Channel__c----'+oppObj.Account);
            If(oppObj.Sales_Channel__c != NULL && oppObj.Account != NULL ){
                If( oppObj.Account.Sales_Channel__c != NULL ){
                    If( ((oppObj.Sales_Channel__c.toLowerCase()).contains(fadVar) && !(oppObj.Account.Sales_Channel__r.Name.toLowerCase()).contains(fadVar)) 
                       || ((oppObj.Account.Sales_Channel__r.Name.toLowerCase()).contains(fadVar) && !(oppObj.Sales_Channel__c.toLowerCase()).contains(fadVar) ) ) { 
                        usFedmismatchDealAlert = 'US Fed Mismatch found.';
                    }
                }else If( oppObj.Account.Sales_Channel__c == NULL && (oppObj.Sales_Channel__c.toLowerCase()).contains(fadVar) ){
                    usFedmismatchDealAlert = 'US Fed Mismatch found.';
                }else If( oppObj.Account.Sales_Channel__c == NULL && !(oppObj.Sales_Channel__c.toLowerCase()).contains(fadVar) ){
                    usFedmismatchDealAlert = '';
                }
            }else If( oppObj.Sales_Channel__c != NULL && oppObj.Account == NULL ){
                If( (oppObj.Sales_Channel__c.toLowerCase()).contains(fadVar) ){
                    usFedmismatchDealAlert = 'US Fed Mismatch found.';
                }else{
                    usFedmismatchDealAlert = '';
                }
            }else If( oppObj.Sales_Channel__c == NULL && oppObj.Account != NULL ){
                If( oppObj.Account.Sales_Channel__c != NULL && (oppObj.Account.Sales_Channel__r.Name.toLowerCase()).contains(fadVar) ){
                    usFedmismatchDealAlert = 'US Fed Mismatch found.';
                }else{
                    usFedmismatchDealAlert = '';
                }
            } 
           
            /***** v5.0 Starts ***/
            
             if(oppObj.AccountId != null ){
             
               // v8.0
               opptyAccountId = oppObj.AccountId;
               if(opptyAccountId.length() == 18){
               opptyAccountId = opptyAccountId.substring(0,opptyAccountId.length()-3);}
               //v8.0
            
                If( oppObj.Account.Unassigned_End_User_Account__c == false ){
                    VFCntrl_OpenOpportunityConflictSelection conflictController = new VFCntrl_OpenOpportunityConflictSelection(new ApexPages.StandardController(oppObj));
                    if(!conflictController.wcList.isEmpty() || Test.IsRunningTest()){ 
                        opptyConflictFlag = true;
                        isUnAssignedUser = false;
                        duplicateFlag = conflictController.isDuplicateFound;
                    }
                    system.debug('-----conflictController.wcList-----'+conflictController.wcList);
                    system.debug('-----duplicateFlag-----'+duplicateFlag);
                    system.debug('-----conflictController.isDuplicateFound-----'+conflictController.isDuplicateFound);
                }else{
                    isUnAssignedUser = true;
                }
            }

            /***** v5.0 Ends ***/
   
            /***** v6.0 Starts ***/
            List<String> productLobCategory = new List<String>();
            Integer undefinedProducts = 0;
            if(oppObj.AccountId != null && oppObj.Number_of_Line_Items__c != 0){             
              
                for(OpportunityLineItem oppLineItem : oppObj.OpportunityLineItems){
                    
                    // Imp****************
                    if(oppLineItem.Product2.Channel_Product_LOB__c == '' || oppLineItem.Product2.Channel_Product_LOB__c == null){
                         blankChannelLOB = true;
                    }
                    //Imp *****************
                     if(oppLineItem.Product2.LOB_Category__c != null){                         
                           if(oppLineItem.Product2.LOB_Category__c != 'Undefined'){
                                productLobCategory.add(oppLineItem.Product2.LOB_Category__c);
                           }else{
                                undefinedProducts++;
                           }  
                     }
                }
                
                if(oppObj.OpportunityLineItems.size() == undefinedProducts ){
                  undefinedProductFlag = true;
                }else{                 
                    Integer lobCount = [SELECT COUNT() FROM LOB_Registration__c Where LOB_Name__c IN: productLobCategory
                                      AND Registered_End_User__c =: oppObj.AccountId
                                      AND ((LOB_registration_status__c ='Partner(approved)' AND Preferred_GTM_Partner_Account__c != :oppObj.PartnerAccountId)
                                       OR LOB_registration_status__c ='Dell(approved)')];                     
                    if(lobCount >0){
                      lobConflictFlag = true;                             
                    }
                }  
              
                /*
                LOBconflictDisplayController lobConflictCon = new LOBconflictDisplayController(oppObj.Id);
                if(!lobConflictCon.finaloppLobConflictSet.isEmpty()){
                    lobConflictFlag = true;                              
                }*/
            }
            /***** v6.0 Ends ***/  
             
             /***** v11.0 Start ***/  
          
             string partnerType = DistiVisibilityHelperClass.getPartnerType(oppobj.owner.id);
             if (partnerType == 'Distributor' || partnerType == 'Tier2'|| partnerType == 'Indirect Partner Purchase'){
             if(oppObj.Distributor_Reseller_Name__c == null || oppObj.Distributor_Name__c == null  ){
                
               distributionInfoAlert = 'Missing Distribution Info';
                   } else {
                           distributionInfoAlert = '';
                   } 
             } 
             
            /***** v11.0 end ***/ 
            /***** v12.0 Start ***/ 
                     if(oppObj.End_Customer__r.DUNS_Number__c == Null || oppObj.End_Customer__r.DUNS_Number__c ==''){
                         partnerSelectedDunsInfoAlert = 'End Customer No DUNS';
                     } else {
                         partnerSelectedDunsInfoAlert = '';
                     }
           /***** v12.0 End ***/ 
        }
        catch (Exception e) {
            noError = False;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An error occurred while loading the Approval Action Panel. Please contact your administrator for assistance');
            ApexPages.addMessage(myMsg);
            system.debug('ERROR@@@@@@@@@@@' + e);
        }
    }
    Public pagereference okAction(){
        noError = True;
        String strURL = (String) '/apex/OpportunityApprovalActionPannel?Id='+oppId;
        PageReference pageRef = new PageReference(strURL);
        pageRef.setRedirect(true);
        return pageRef;
    }
    /* Ver 7.0: CR 12081: Approval Action Panel UI Simplification: Start
    public pagereference SaveAction(){
        System.Debug('---SaveAction----'+ActionType);
        Boolean isChanged = False;
        if(ActionType== 'CrossBorderDeals' ){
            oppObj.Check_for_Cross_Border_Deals__c = TRUE;
            isChanged = TRUE;
            
            count++;
        } 
        else if(ActionType== 'DellAccountSelection' ){
            oppObj.Conduct_Dell_Account_Selection__c = TRUE;
            isChanged = TRUE;
            count++;
        }
        else if(ActionType== 'SpecialtyAccount' ){
            oppObj.Check_for_Specialty_Dell_Account__c = TRUE;
            isChanged = TRUE;
            count++;
        }
        else if(ActionType== 'DealThreshold' ){
            oppObj.Check_for_Deal_Threshold__c = TRUE;
            isChanged = TRUE;
            count++;
        }
        else if(ActionType== 'USFedMisMatch' ){
            oppObj.Check_for_U_S_Fed_Mismatch__c = TRUE;
            isChanged = TRUE;
            count++;
        }
        else if(ActionType== 'SpecialtyPartner' ){
            oppObj.Check_for_Specialty_Partner__c= TRUE;
            isChanged = TRUE;
            count++;
        }
        else if(ActionType== 'OtherChannelProgram' ){
            oppObj.Check_for_Other_Channel_Program__c= TRUE;
            isChanged = TRUE;
            count++;
        }
        else if(ActionType== 'ReviewOpenOpportunity' ){
            oppObj.Review_Open_Opportunity__c= TRUE;
            isChanged = TRUE;
            count++;
        }
        else if(ActionType== 'SpecialtyProduct' ){
            oppObj.Check_for_Specialty_Product__c= TRUE;
            isChanged = TRUE;
            count++;
        }
        else if(ActionType== 'ReviewLOBAwards' ){
            oppObj.Review_LOB_Awards__c= TRUE;
            isChanged = TRUE;
            count++;
        }
        else if(ActionType== 'SalesMarketingPrograms' ){
            oppObj.Check_for_Sales_Marketing_Programs__c= TRUE;
            isChanged = TRUE;
            count++;
        }
        else if(ActionType== 'DealTypeOverlaySpecialist' ){
            oppObj.Add_Deal_Type_Overlay_Specialist__c = TRUE;
            isChanged = TRUE;
            count++;
        }
        else if(ActionType== 'ApproveRejectDeal' ){
            oppObj.Approve_Reject_Deal__c= TRUE;
            isChanged = TRUE;
            count++;
        }
        
        try{
            if(isChanged == TRUE){
                Update oppObj;
            }
            percentComplete = (Count*100)/TOTAL_FLAG_COUNT;
        }
        catch(Exception e) {
            noError = False;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'The record you are trying to edit has been locked. Please contact your administrator if access is necessary.');
            ApexPages.addMessage(myMsg);
            //ApexPages.addMessages(e);

        }
        return Null;
    }
    
    // CR# 11805 - Navigate to Standard Approve/Reject page for a particular deal when Approver clicks on Approve/Reject link in Action panel
    Public pagereference Approve_Reject_Action(){
        shouldRedirect = true;
        noError = True;
        If( workItemList.size() > 0){
            approveRejectUrl ='/p/process/ProcessInstanceWorkitemWizardStageManager?id='+ workItemList[0].id;
        }else If( UserInfo.getProfileId() == System.Label.System_Administrator_Profile_Id ){
            workItemListForSysAdmin = getWorkItemList();
            approveRejectUrl = '/p/process/ProcessInstanceWorkitemWizardStageManager?id='+ workItemListForSysAdmin[0].id;
        }
          return null; 
     }
    
     // CR# 11805 - Get the submitted Approval process Request Id for the Deal    
     public List<ProcessInstanceWorkitem> getApprovalProcessRequest(){
        Set<Id> actorIdSet = new Set<Id>();
        actorIdSet.add(Userinfo.getUserId()); 
        List<ProcessInstanceWorkitem> workItemList = [SELECT id FROM ProcessInstanceWorkitem WHERE processInstance.TargetObjectId=:oppId 
                                                      AND ActorId IN: actorIdSet];
        return workItemList;     
     }
     
      //  Get the submitted Approval process Request Id for the sysAdmin 
     public List<ProcessInstanceWorkitem> getWorkItemList()
     {
        List<ProcessInstanceWorkitem> workItemListForSysAdmin = [SELECT id FROM ProcessInstanceWorkitem WHERE 
                                                                  processInstance.TargetObjectId=:oppId];  
        return workItemListForSysAdmin;
     }
                
     // CR# 11805 - Check for the Valid Approver to enable/disable Approve/Reject link in Action panel
     public Boolean isValidApprover(){
            list<ProcessInstance> PI = [SELECT Id, Status,(SELECT Id, ActorId, OriginalActorId FROM StepsAndWorkItems)
                                      FROM ProcessInstance WHERE Status = 'pending' AND TargetObjectId = :oppId LIMIT 1];  
            list<ProcessInstanceHistory > PIHlist = new list<ProcessInstanceHistory>();  
            if(PI!=null && PI.size() > 0) {                   
                  for(ProcessInstance p : PI){            
                    PIHlist.addall(p.StepsAndWorkItems);          
                  }
            }
      
            Set<string> actoridSet = new Set<string>();
            Set<string> OriginalactoridSet = new Set<string>();
            if(PIHlist!=null && PIHlist.size() > 0) {
                for(ProcessInstanceHistory pih: PIHlist){
                  actoridSet.add(pih.actorId);
                  actoridSet.add(pih.OriginalActorId);
                  }
             }

            system.debug('actoridset'+actoridSet);
            Boolean isValidApprver ;
            If( actoridset.contains(Userinfo.getUserId()) ){
                 isValidApprver = true;
            }else{
                 isValidApprver = false;
            }
                return isValidApprver;
    }
    Ver 7.0: CR 12081: Approval Action Panel UI Simplification: End*/  
    
   
   
}