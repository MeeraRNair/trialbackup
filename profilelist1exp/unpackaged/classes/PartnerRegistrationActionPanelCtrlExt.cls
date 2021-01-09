/**
* Controller class for action panel which appears on partner request page layout
* for record types "New Partner" & "Existing Partner".  This controller abstracts
* all the tasks & actions that can be taken as part of the partner on-boarding
* process.
*
* Revision History:
* 05-January-2010, Richard: Created for CR2106.
* December-2012    TK Chin: R14.2 CR7681 - Changes to Partner Onboarding Action Panel
*/
public class PartnerRegistrationActionPanelCtrlExt {
    
    public static String PAGE_FLOW_ERROR        {get{return 'PAGE_FLOW_ERROR';}}
    public static String INVALID_RECORD_TYPE    {get{return 'INVALID_RECORD_TYPE';}}
    
    public static String NEW_PARTNER_RECORD_TYPEID      = '012700000005cfaAAA';
    public static String EXIST_PARTNER_RECORD_TYPEID    = '012A0000000TWieIAG';
    public static String ABORTED_BY_PARTNER_RECORD_TYPEID    = '012A0000000ViAIIA0';
    
    public static Set<String> ACCEPTABLE_RECORD_TYPE_IDS = new Set<String>{
        NEW_PARTNER_RECORD_TYPEID,EXIST_PARTNER_RECORD_TYPEID,ABORTED_BY_PARTNER_RECORD_TYPEID
            };
                
                public String                       errorCode   {get;set;}
    public List<PartnerOnboardingTask>  tasks       {get;set;}
    public Partner_Request__c           request     {get;set;}
    public String                       redirectUrl {get;set;}
    
    public PartnerRegistrationActionPanelCtrlExt(ApexPages.StandardController c){
        
        if(c != null && c.getRecord() != null && c.getRecord() instanceof Partner_Request__c){
            this.request = (Partner_Request__c) c.getRecord();
        }
        System.debug('###PRequest'+request);
    }
    
    public PageReference doOnLoad(){
        if( this.request == null
           || this.request.id == null ){
               return error(PAGE_FLOW_ERROR);
           }
        if(!ACCEPTABLE_RECORD_TYPE_IDS.contains(this.request.recordtypeid)){
            return error(INVALID_RECORD_TYPE);
        }
        initTasks();
        return refresh();
    }
    
    public PageReference refresh(){
        for(PartnerOnboardingTask task : tasks){
            task.setPartnerRequest(this.request);
        }
        return null;
    }
    
    public Double percentComplete {
        get{
            Integer tasksCompletedCount = 0;
            Integer totalTasksToShowCount = 0;
            for(PartnerOnboardingTask task : tasks){
                if(task.show){
                    totalTasksToShowCount++;                    
                    //if(task.complete && !task.isPartialNotComplete){
                    if(task.complete){
                        tasksCompletedCount++;
                    }
                }
            }
            return (tasksCompletedCount*100)/totalTasksToShowCount;
        }
    }
    
    public Boolean errorOccurred{ get{ return al.StringUtils.isNotBlank(errorCode); } }
    
    
    private PageReference error(String code){
        this.errorCode = code;
        return null;
    }
    
    private void initTasks(){
        
        
        Boolean SearchforExistOrDupLinkVisible=false;
        Boolean LinktoAccountRecord=false;
        
        //===============================================================================
        //Status groups for partner request actions.  Actions should only appear so
        //  long as the partner request is in an acceptable status.  These sets define
        //  those acceptable status groups.
        //===============================================================================
        final Set<String> NEW_INCOMPLETE_RESUBMITTED = new Set<String>{
            null,
                PartnerConstants.REG_STATUS_DRAFT,
                PartnerConstants.REG_STATUS_OWNED,
                PartnerConstants.REG_STATUS_INCOMPLETE,
                PartnerConstants.REG_STATUS_RESUBMITTED};
                    final Set<String> NEW_INREVIEW = new Set<String>{
                        PartnerConstants.REG_STATUS_INREVIEW,
                            PartnerConstants.REG_STATUS_RESUBMITTED};
                                final Set<String> ALL = new Set<String>{
                                    PartnerConstants.REG_STATUS_DRAFT,
                                    PartnerConstants.REG_STATUS_OWNED,
                                        PartnerConstants.REG_STATUS_INCOMPLETE,
                                        PartnerConstants.REG_STATUS_APPROVED,
                                        PartnerConstants.REG_STATUS_REJECTED,PartnerConstants.REG_STATUS_RESUBMITTED,
                                        PartnerConstants.REG_STATUS_INREVIEW,
                                        PartnerConstants.REG_STATUS_DUPLICATE,
                                        PartnerConstants.REG_STATUS_COMPLETE,
                                        PartnerConstants.REG_STATUS_INCOMPLETEANDEXPIRED,
                                        PartnerConstants.REG_STATUS_LEADDRAFT,
                                        PartnerConstants.REG_STATUS_ACCOUNT_SUGGESTION_SUBMITTED,
                                        PartnerConstants.REG_STATUS_ACCOUNT_SUGGESTION_COMPLETED,
                                        PartnerConstants.REG_STATUS_ACCOUNT_SUGGESTION_REJECTED,
                                        PartnerConstants.REG_STATUS_ACCOUNT_SUGGESTION_CREATED,
                                        PartnerConstants.REG_STATUS_ACCOUNT_SUGGESTION_PROCESS_ERRORED};
                                              final Set<String> NEW_ACCOUNT_SUGGESTION_COMPLETED = new Set<String>{
                                                      PartnerConstants.REG_STATUS_ACCOUNT_SUGGESTION_COMPLETED};
                                            
                                            //===============================================================================
                                            //TASKS & ACTIONS
                                            //  Each "partner on-boarding" task is defined below along with the actions
                                            //  for each task.
                                            //===============================================================================
                                            tasks = new List<PartnerOnboardingTask>();
        
        //---------------------------
        //Review for Completeness
        //---------------------------
        // R14.2 CR7681 - Change label from 'Review for Completeness' to 'Review Partner Request (PR) for Completeness'
        final PartnerOnboardingTask reviewForCompletenessIsCompleteFlagTask = new PartnerOnboardingTask(
            'Review Partner Request (PR) for Completeness',
            'Review_for_Completeness_Is_Complete_Flag__c',
            this
        );
        tasks.add(reviewForCompletenessIsCompleteFlagTask);
        final PartnerOnboardingTaskAction reviewForCompletenessMarkAsCompleteAction = reviewForCompletenessIsCompleteFlagTask.addAction(new PartnerOnboardingTaskAction(
            'Mark as Complete',
            System.Page.PartnerRegistrationDupSearch.getUrl() + '?id=' + this.request.id,
            true,
            PartnerConstants.REG_STATUS_INREVIEW,
            NEW_INCOMPLETE_RESUBMITTED));
        final PartnerOnboardingTaskAction reviewForCompletenessMarkAsIncompleteAction = reviewForCompletenessIsCompleteFlagTask.addAction(new PartnerOnboardingTaskAction(
            'Mark as Incomplete',
            System.Page.PartnerRegistrationMarkIncomplt.getUrl() + '?id=' + this.request.id,
            NEW_INCOMPLETE_RESUBMITTED)); 
        
        //---------------------------
        //Check For Duplicates
        //---------------------------
        final PartnerOnboardingTask checkForDuplicatesIsCompleteFlagTask = new PartnerOnboardingTask(
            'Check For Duplicates',
            'Check_For_Duplicates_Is_Complete_Flag__c',
            this
        );
        tasks.add(checkForDuplicatesIsCompleteFlagTask);
        //CR3480 :Need to enable Accounts to be linked to "Approved" and "Lead Draft" status PR
        
        
        System.debug('###request.Account__c'+request.Account__c);        
        System.debug('###request.Check_For_Duplicates_Is_Complete_Flag__c'+request.Check_For_Duplicates_Is_Complete_Flag__c);
        System.debug('###request.Review_for_Completeness_Is_Complete_Flag__c'+request.Review_for_Completeness_Is_Complete_Flag__c);
        
        /*
*    CR :- 3263
*    'Search for Existing or Duplicate' link need to visible when 
* 1) account__c field is null
* 2) Review_for_Completeness_Is_Complete_Flag__c=false
* 3) request.Check_For_Duplicates_Is_Complete_Flag__c=false
*    When Account__c is not null link is made hidden
*/
        
        
        
        
        if(EXIST_PARTNER_RECORD_TYPEID.equals(this.request.recordtypeid)){
            if(this.request.Account__c==null || this.request.Review_for_Completeness_Is_Complete_Flag__c==false ||
               this.request.Check_For_Duplicates_Is_Complete_Flag__c==false){                    
                   SearchforExistOrDupLinkVisible=true;
               }
            
            if(this.request.Account__c!=null){                     
                SearchforExistOrDupLinkVisible=false;
            }
            
            //CR:16558
            // Change to the PR processing - Duplicate Check - Navigate to lead page when Link is clicked 
            
             final PartnerOnboardingTask reviewForPreVettingCompletedTask = new PartnerOnboardingTask(
                'Pre Vetting Completed',
                'Prevetting_completed__c',
                 this
            );
           
            system.debug('review for preveting*******'+reviewForPreVettingCompletedTask);
            tasks.add(reviewForPreVettingCompletedTask);
            
            final PartnerOnboardingTask approveIsCompleteFlagTask = new PartnerOnboardingTask('Approve Partner Request','Approve_Is_Complete_Flag__c',this);tasks.add(approveIsCompleteFlagTask);
            
            final PartnerOnboardingTaskAction approveAction = approveIsCompleteFlagTask.addAction(new PartnerOnboardingTaskAction('Approve Partner Request',null,true, PartnerConstants.REG_STATUS_APPROVED,NEW_INREVIEW));
            
            final PartnerOnboardingTask sendAccountSuggestionIsCompleteFlagTask = new PartnerOnboardingTask('Send DST Account Suggestion','Send_Account_Suggestion_Is_Complete_Flag__c',this);tasks.add(sendAccountSuggestionIsCompleteFlagTask);
              sendAccountSuggestionIsCompleteFlagTask.addAction(new PartnerOnboardingTaskAction(
                'Create Account Suggestion',
                System.Page.CreateSuggestion.getUrl() + '?id=' + this.request.id,
                new Set<String>{PartnerConstants.REG_STATUS_APPROVED},approveIsCompleteFlagTask));
            sendAccountSuggestionIsCompleteFlagTask.addAction(new PartnerOnboardingTaskAction(
                'Re-Submit Account Suggestion',
                System.Page.CreateSuggestion.getUrl() + '?creationtype=resubmit&id=' + this.request.id,
                ALL,
                sendAccountSuggestionIsCompleteFlagTask));
                
                //Profile UCID as Partner
        //---------------------------    
        
        final PartnerOnboardingTask profileUCIDAsPartnerIsCompleteFlagTask = new PartnerOnboardingTask(
            'Profile UCID as Partner',
            'Profile_UCID_as_Partner_Is_Complete_Flag__c',
            this
        );      
         
        tasks.add(profileUCIDAsPartnerIsCompleteFlagTask);        
     final PartnerOnboardingTaskAction profileUCIDAsPartnerMarkAsCompleteAction = profileUCIDAsPartnerIsCompleteFlagTask.addAction(new PartnerOnboardingTaskAction(
                 'Mark as Complete',
                 System.Page.getUCIDFrmSuggestionID.getUrl() + '?id=' + this.request.id,
                 new Set<String>{PartnerConstants.REG_STATUS_ACCOUNT_SUGGESTION_SUBMITTED},
                  sendAccountSuggestionIsCompleteFlagTask
               ));
              
        
         //---------------------------
        //Update Profile and Create Associations
        //---------------------------        
       
        final PartnerOnboardingTask updateProfileIsCompleteFlagTask  = new PartnerOnboardingTask(
            'Update Profile and Create Associations',
            'Update_Profile_Is_Complete_Flag__c',
            this
        );
         tasks.add(updateProfileIsCompleteFlagTask);
        final PartnerOnboardingTaskAction updateProfileIsCompleteMarkAsCompleteAction= updateProfileIsCompleteFlagTask.addAction(new PartnerOnboardingTaskAction(
               'Mark as Complete',
                System.Page.SendPRDataToEMC.getUrl() + '?id=' + this.request.id,
                new Set<String>{PartnerConstants.REG_STATUS_ACCOUNT_SUGGESTION_SUBMITTED},
              profileUCIDAsPartnerIsCompleteFlagTask
              
                
              ));
              
              
              
            final PartnerOnboardingTask mupProfileIsCompleteFlagTask = new PartnerOnboardingTask(
            'Update MUP Details',
            'MUP_Profile_Creation__c',
             this
        );
         tasks.add(mupProfileIsCompleteFlagTask);
        final PartnerOnboardingTaskAction mupProfileIsCompleteMarkAsCompleteAction= mupProfileIsCompleteFlagTask.addAction(new PartnerOnboardingTaskAction(
             'Mark as Complete',
              System.Page.CompanyProfileRestService_Vfp.getUrl() + '?id=' + this.request.id+'&complete='+true,
              new Set<String>{PartnerConstants.REG_STATUS_ACCOUNT_SUGGESTION_SUBMITTED},
              updateProfileIsCompleteFlagTask
              
                
              ));
                 final PartnerOnboardingTaskAction mupProfileIsCompleteMarkAsCompleteAction1= mupProfileIsCompleteFlagTask.addAction(new PartnerOnboardingTaskAction(
             'Mark as Not Required',
              System.Page.CompanyProfileRestService_Vfp.getUrl() + '?id=' + this.request.id+'&complete='+false,
              new Set<String>{PartnerConstants.REG_STATUS_ACCOUNT_SUGGESTION_SUBMITTED},
              updateProfileIsCompleteFlagTask
              
                
              ));    
        //-------------------------------
        //Start : Update Account Details in GAMA - Modified By Prasanthi M - Need to create new flag field in PR object
        //-------------------------------
        final PartnerOnboardingTask updationInGAMAFlagTask = new PartnerOnboardingTask(
            'Update Account Details In GAMA',
            'Update_Account_In_GAMA_Is_Complete_Flag__c',
            this
        );   
        tasks.add(updationInGAMAFlagTask);        
        final PartnerOnboardingTaskAction updationInGAMAMarkAsCompleteAction = updationInGAMAFlagTask.addAction(new PartnerOnboardingTaskAction(
                 'Mark as Complete',
                 System.Page.updateUCIDToSuggestion.getUrl() + '?id=' + this.request.id,
                 new Set<String>{PartnerConstants.REG_STATUS_ACCOUNT_SUGGESTION_SUBMITTED},
                 mupProfileIsCompleteFlagTask
               ));
            
        }
        
        if(NEW_PARTNER_RECORD_TYPEID.equals(this.request.recordtypeid)){
            SearchforExistOrDupLinkVisible=true;
            
        }
        
        final PartnerOnboardingTaskAction searchForExistingOrDuplicateAction = checkForDuplicatesIsCompleteFlagTask.addAction(new PartnerOnboardingTaskAction(
            'Search for Existing or Duplicate',
            System.Page.PartnerRegistrationDupSearch.getUrl() + '?id=' + this.request.id,
            new Set<String>{PartnerConstants.REG_STATUS_INREVIEW,PartnerConstants.REG_STATUS_LEADDRAFT,PartnerConstants.REG_STATUS_APPROVED},
            reviewForCompletenessIsCompleteFlagTask,
            SearchforExistOrDupLinkVisible));
        
        
        PartnerOnboardingTask exportComplianceCheckIsCompleteFlagTask = null;
        PartnerOnboardingTask checkDeniedPartyListIsCompleteFlagTask = null;
        PartnerOnboardingTask performCreditCheckIsCompleteFlagTask = null;
        PartnerOnboardingTask agreementHardcpyRcvdIsCompleteFlagTask = null;
        PartnerOnboardingTask enableOrderManagementaccessFlagTask = null;
        PartnerOnboardingTask enablePremierPagesaccessFlagTask = null;
        PartnerOnboardingTask sendWelcomePackettoPartnerFlagTask = null;
        
        if(NEW_PARTNER_RECORD_TYPEID.equals(this.request.recordtypeid)){
            //---------------------------
            //Check Export Compliance
            //---------------------------
            //R14.2 CR7681 - Change label 'Check Export Compliance' to 'Local Media Search Performed/Check Export Compliance'
            //R16.07 CR11493 - Change label 'Local Media Search Performed/Check Export Compliance' to 'Local Media Search Performed/Check Export Compliance/TRACE Submitted'
            //---------------------------------------------------------------------------------------------------------------
            //removing the steps that are not required 
            /*     exportComplianceCheckIsCompleteFlagTask = new PartnerOnboardingTask(
'Local Media Search Performed/Check Export Compliance/TRACE Submitted',       //Anamika - CR11495[6/9/2015]
'Export_Compliance_Check_Is_Complete_Flag__c',
'Task_Check_Export_Compliance__c',
'NA_Check_Export_Compliance__c',
'ShowexportComplianceCheckAfterNA__c',
this
);
tasks.add(exportComplianceCheckIsCompleteFlagTask);
final PartnerOnboardingTaskAction checkExportComplianceCompleteAction = exportComplianceCheckIsCompleteFlagTask.addAction(
new PartnerOnboardingTaskAction('Mark as Complete',NEW_INREVIEW,true,reviewForCompletenessIsCompleteFlagTask));
exportComplianceCheckIsCompleteFlagTask.addAction(
new PartnerOnboardingTaskAction('N/A',null,'NA_Check_Export_Compliance__c',NEW_INREVIEW,reviewForCompletenessIsCompleteFlagTask));

//---------------------------
//Check Denied Party List
//---------------------------
//R14.2 CR7681 - Remove 'Check Denied Party List'
//-----------------------------------------------
//checkDeniedPartyListIsCompleteFlagTask = new PartnerOnboardingTask(
//    'Check Denied Party List',
//    'Check_Denied_Party_List_Is_Complete_Flag__c',
//    'Task_Check_Denied_Party_List__c',
//    'NA_Check_Denied_Party_List__c', 
//    'ShowCheckDeniedPartyAfterNA__c',
//    this
//);
//tasks.add(checkDeniedPartyListIsCompleteFlagTask); 
//final PartnerOnboardingTaskAction checkDeniedPartyListAction = checkDeniedPartyListIsCompleteFlagTask.addAction(new PartnerOnboardingTaskAction(
//    'Mark as Complete',NEW_INREVIEW,true,reviewForCompletenessIsCompleteFlagTask));//CR 2759 - Optional Progression checkbox
//checkDeniedPartyListIsCompleteFlagTask.addAction(new PartnerOnboardingTaskAction(
//    'N/A',null,'NA_Check_Denied_Party_List__c',NEW_INREVIEW,reviewForCompletenessIsCompleteFlagTask));

//---------------------------
//Check Credit
//---------------------------
//R14.2 CR7681 - Remove 'Credit Check'
//------------------------------------
//performCreditCheckIsCompleteFlagTask = new PartnerOnboardingTask(
//    'Check Credit',
//    'Perform_Credit_Check_Is_Complete_Flag__c',
//    'Task_Check_Credit__c',
//    'NA_Check_Credit__c',
//    'ShowPerformCreditCheckAfterNA__c',
//    this
//);
//tasks.add(performCreditCheckIsCompleteFlagTask);
//final PartnerOnboardingTaskAction checkCreditAction = performCreditCheckIsCompleteFlagTask.addAction(new PartnerOnboardingTaskAction('Mark as Complete',NEW_INREVIEW,true,reviewForCompletenessIsCompleteFlagTask));
//performCreditCheckIsCompleteFlagTask.addAction(new PartnerOnboardingTaskAction('N/A',null,'NA_Check_Credit__c',NEW_INREVIEW,reviewForCompletenessIsCompleteFlagTask));

//---------------------------
//Agreement Hard-copy Received
//---------------------------
//R14.2 CR7681 - Change label 'Agreement Hard-copy Received' to 'Required documents received, submitted with application'
//-----------------------------------------------------------------------------------------------------------------------
agreementHardcpyRcvdIsCompleteFlagTask = new PartnerOnboardingTask(
'Required documents received, submitted with application',
'Agreement_Hard_cpy_Rcvd_Is_Complete_Flag__c',
'Task_Agreement_Hard_copy_Received__c',
'NA_Agreement_Hard_copy_Received__c',
'ShowagreementHardcpyRcvdAfterNA__c',
this
);
tasks.add(agreementHardcpyRcvdIsCompleteFlagTask);
final PartnerOnboardingTaskAction agreementHardCopyReceivedAction = agreementHardcpyRcvdIsCompleteFlagTask.addAction(new PartnerOnboardingTaskAction('Mark as Complete',NEW_INREVIEW,true,reviewForCompletenessIsCompleteFlagTask));
agreementHardcpyRcvdIsCompleteFlagTask.addAction(new PartnerOnboardingTaskAction('N/A',null,'NA_Agreement_Hard_copy_Received__c',NEW_INREVIEW,reviewForCompletenessIsCompleteFlagTask));

//---------------------------
//Enable Order Management access
//---------------------------
//R14.2 CR7681 - Change label 'Enable Order Management access' to 'Check DOMs/Gii for spend history with Dell'
//------------------------------------------------------------------------------------------------------------
enableOrderManagementaccessFlagTask = new PartnerOnboardingTask(
'Check DOMs/Gii for spend history with Dell',
'Enable_Order_Management_access_Flag__c',
'Task_Enable_Order_Management_access__c',
'NA_Enable_Order_Management_access__c',
'ShowenableOrderManagementaccessAfterNA__c',
this
);
tasks.add(enableOrderManagementaccessFlagTask);
final PartnerOnboardingTaskAction enableOrderManagementAccessAction = enableOrderManagementaccessFlagTask.addAction(new PartnerOnboardingTaskAction('Mark as Complete',NEW_INREVIEW,true,reviewForCompletenessIsCompleteFlagTask));
enableOrderManagementaccessFlagTask.addAction(new PartnerOnboardingTaskAction('N/A',null,'NA_Enable_Order_Management_access__c',NEW_INREVIEW,reviewForCompletenessIsCompleteFlagTask));

//---------------------------
//Enable Premier Pages access
//---------------------------
enablePremierPagesaccessFlagTask = new PartnerOnboardingTask(
'Enable Premier Pages access',
'Enable_Premier_Pages_access_Flag__c',
'Task_Enable_Premier_Pages_access__c',
'NA_Enable_Premier_Pages_access__c',
'ShowenablePremierPagesaccessAfterNA__c',
this
);
tasks.add(enablePremierPagesaccessFlagTask);
final PartnerOnboardingTaskAction enablePremierPagesAccessAction = enablePremierPagesaccessFlagTask.addAction(new PartnerOnboardingTaskAction('Mark as Complete',NEW_INREVIEW,true,reviewForCompletenessIsCompleteFlagTask));
enablePremierPagesaccessFlagTask.addAction(new PartnerOnboardingTaskAction('N/A',null,'NA_Enable_Premier_Pages_access__c',NEW_INREVIEW,reviewForCompletenessIsCompleteFlagTask));

//---------------------------
//Send Welcome Packet to Partner
//---------------------------
//R14.2 CR7681 - Change label 'Send Welcome Packet to Partner' to 'Send Welcome Packet (EMEA)'
sendWelcomePackettoPartnerFlagTask = new PartnerOnboardingTask(
'Send Welcome Packet (EMEA)',
'Send_Welcome_Packet_to_Partner_Flag__c',
'Task_Send_Welcome_Packet_to_Partner__c',
'NA_Send_Welcome_Packet_to_Partner__c',
'ShowSendWelcomePackettoPartnerAfterNA__c',
this
);
tasks.add(sendWelcomePackettoPartnerFlagTask);
final PartnerOnboardingTaskAction sendWelcomePackettoPartnerAction = sendWelcomePackettoPartnerFlagTask.addAction(new PartnerOnboardingTaskAction('Mark as Complete',NEW_INREVIEW,true,reviewForCompletenessIsCompleteFlagTask));
sendWelcomePackettoPartnerFlagTask.addAction(new PartnerOnboardingTaskAction('N/A',null,'NA_Send_Welcome_Packet_to_Partner__c',NEW_INREVIEW,reviewForCompletenessIsCompleteFlagTask));
*/
            
            
            //---------------------------
            //Pre-Vetting 
            //---------------------------
            final PartnerOnboardingTask reviewForPreVettingCompletedTask = new PartnerOnboardingTask(
                'Pre Vetting Completed',
                'Prevetting_completed__c',
                 this
            );
            tasks.add(reviewForPreVettingCompletedTask);
            final PartnerOnboardingTaskAction reviewForPreVettingCompletedAction = reviewForPreVettingCompletedTask.addAction(new PartnerOnboardingTaskAction(
                'Mark as Complete',
                System.Page.VFpage_Prevetting_SendEMail.getUrl() + '?id=' + this.request.id,               
                true,
                null,
                NEW_INREVIEW,
                reviewForCompletenessIsCompleteFlagTask
            ));
            
            
            
            //---------------------------
            //Approve
            //---------------------------
            //R14.2 CR7681 - Change label 'Approve' to 'Approve Partner Request'
            final PartnerOnboardingTask approveIsCompleteFlagTask = new PartnerOnboardingTask(
                'Approve Partner Request',
                'Approve_Is_Complete_Flag__c',
                this
            );
            tasks.add(approveIsCompleteFlagTask);
            final PartnerOnboardingTaskAction approveAction = approveIsCompleteFlagTask.addAction(new PartnerOnboardingTaskAction(
                'Approve Partner Request',
                null,
                true,
                PartnerConstants.REG_STATUS_APPROVED,
                NEW_INREVIEW));
            approveAction.addDependency(
                new List<PartnerOnboardingTask>{
                    checkForDuplicatesIsCompleteFlagTask,
                        exportComplianceCheckIsCompleteFlagTask,
                        checkDeniedPartyListIsCompleteFlagTask,
                        performCreditCheckIsCompleteFlagTask,
                        agreementHardcpyRcvdIsCompleteFlagTask,
                        enableOrderManagementaccessFlagTask,
                        enablePremierPagesaccessFlagTask,
                        sendWelcomePackettoPartnerFlagTask,
                        reviewForPreVettingCompletedTask
                        });
            
            // CR2617 :change PartnerConstants.REG_STATUS_REJECTED to REG_STATUS_INREVIEW
            approveIsCompleteFlagTask.addAction(new PartnerOnboardingTaskAction(
                'Reject',
                System.Page.PartnerRegistrationMarkRejected.getUrl() + '?id=' + this.request.id,
                false,
                PartnerConstants.REG_STATUS_INREVIEW,
                NEW_INREVIEW,
                reviewForCompletenessIsCompleteFlagTask));
            system.debug('*** below the reject status in task constructor');
            //---------------------------
            //Send Account Suggestion
            //---------------------------
            //R14.2 CR7681 - Change label 'Send Account Suggestion' to 'Send DST Account Suggestion'
            final PartnerOnboardingTask sendAccountSuggestionIsCompleteFlagTask = new PartnerOnboardingTask(
                'Send DST Account Suggestion',
                'Send_Account_Suggestion_Is_Complete_Flag__c',
                this
            );
            tasks.add(sendAccountSuggestionIsCompleteFlagTask);
            sendAccountSuggestionIsCompleteFlagTask.addAction(new PartnerOnboardingTaskAction(
                'Create Account Suggestion',
                System.Page.CreateSuggestion.getUrl() + '?id=' + this.request.id,
                new Set<String>{PartnerConstants.REG_STATUS_APPROVED}
                  ));
            sendAccountSuggestionIsCompleteFlagTask.addAction(new PartnerOnboardingTaskAction(
                'Re-Submit Account Suggestion',
                System.Page.CreateSuggestion.getUrl() + '?creationtype=resubmit&id=' + this.request.id,
                ALL,
                sendAccountSuggestionIsCompleteFlagTask));
        
        
         //---------------------------
        //Profile UCID as Partner
        //---------------------------    
        
        final PartnerOnboardingTask profileUCIDAsPartnerIsCompleteFlagTask = new PartnerOnboardingTask(
            'Profile UCID as Partner',
            'Profile_UCID_as_Partner_Is_Complete_Flag__c',
            this
        );      
         
        tasks.add(profileUCIDAsPartnerIsCompleteFlagTask);        
     final PartnerOnboardingTaskAction profileUCIDAsPartnerMarkAsCompleteAction = profileUCIDAsPartnerIsCompleteFlagTask.addAction(new PartnerOnboardingTaskAction(
                 'Mark as Complete',
                 System.Page.getUCIDFrmSuggestionID.getUrl() + '?id=' + this.request.id,
                 new Set<String>{PartnerConstants.REG_STATUS_ACCOUNT_SUGGESTION_SUBMITTED},
                  sendAccountSuggestionIsCompleteFlagTask
               ));
               
 
        
        //Link to Account Record
        //---------------------------
       
       
       /* final PartnerOnboardingTaskAction profileUCIDAsPartnerMarkAsIncompleteAction = profileUCIDAsPartnerIsCompleteFlagTask.addAction(new PartnerOnboardingTaskAction(
            'Mark as Incomplete',
            System.Page.PartnerRegistrationMarkIncomplt.getUrl() + '?id=' + this.request.id,
            NEW_INCOMPLETE_RESUBMITTED));*/
        
         //---------------------------
        //Update Profile and Create Associations
        //---------------------------        
       
        final PartnerOnboardingTask updateProfileIsCompleteFlagTask  = new PartnerOnboardingTask(
            'Update Profile and Create Associations',
            'Update_Profile_Is_Complete_Flag__c',
            this
        );
         tasks.add(updateProfileIsCompleteFlagTask);
        final PartnerOnboardingTaskAction updateProfileIsCompleteMarkAsCompleteAction= updateProfileIsCompleteFlagTask.addAction(new PartnerOnboardingTaskAction(
               'Mark as Complete',
                System.Page.SendPRDataToEMC.getUrl() + '?id=' + this.request.id,
                new Set<String>{PartnerConstants.REG_STATUS_ACCOUNT_SUGGESTION_SUBMITTED},
              profileUCIDAsPartnerIsCompleteFlagTask
              
                
              ));
              
              
              
            final PartnerOnboardingTask mupProfileIsCompleteFlagTask = new PartnerOnboardingTask(
            'Update MUP Details',
            'MUP_Profile_Creation__c',
             this
        );
         tasks.add(mupProfileIsCompleteFlagTask);
        final PartnerOnboardingTaskAction mupProfileIsCompleteMarkAsCompleteAction= mupProfileIsCompleteFlagTask.addAction(new PartnerOnboardingTaskAction(
             'Mark as Complete',
              System.Page.CompanyProfileRestService_Vfp.getUrl() + '?id=' + this.request.id+'&complete='+true,
              new Set<String>{PartnerConstants.REG_STATUS_ACCOUNT_SUGGESTION_SUBMITTED},
              updateProfileIsCompleteFlagTask
              
                
              ));
                 final PartnerOnboardingTaskAction mupProfileIsCompleteMarkAsCompleteAction1= mupProfileIsCompleteFlagTask.addAction(new PartnerOnboardingTaskAction(
             'Mark as Not Required',
              System.Page.CompanyProfileRestService_Vfp.getUrl() + '?id=' + this.request.id+'&complete='+false,
              new Set<String>{PartnerConstants.REG_STATUS_ACCOUNT_SUGGESTION_SUBMITTED},
              updateProfileIsCompleteFlagTask
              
                
              ));    
        //-------------------------------
        //Start : Update Account Details in GAMA - Modified By Prasanthi M - Need to create new flag field in PR object
        //-------------------------------
        final PartnerOnboardingTask updationInGAMAFlagTask = new PartnerOnboardingTask(
            'Update Account Details In GAMA',
            'Update_Account_In_GAMA_Is_Complete_Flag__c',
            this
        );   
        tasks.add(updationInGAMAFlagTask);        
        final PartnerOnboardingTaskAction updationInGAMAMarkAsCompleteAction = updationInGAMAFlagTask.addAction(new PartnerOnboardingTaskAction(
                 'Mark as Complete',
                 System.Page.updateUCIDToSuggestion.getUrl() + '?id=' + this.request.id,
                 new Set<String>{PartnerConstants.REG_STATUS_ACCOUNT_SUGGESTION_SUBMITTED},
                 mupProfileIsCompleteFlagTask
               ));
         //-------------------------------
        //End : Update Account Details in GAMA - Modified By Prasanthi M
        //-------------------------------  
        }        
        
             final PartnerOnboardingTask linktoAccountRecordIsCompleteFlagTask = new PartnerOnboardingTask(
            'Link to Account Record',
            'Link_to_Account_Record_Is_Complete_Flag__c',
            this
        );
        tasks.add(linktoAccountRecordIsCompleteFlagTask);
        
        /*final PartnerOnboardingTaskAction updateProfileMarkAsIncompleteAction = updateProfileIsCompleteFlagTask.addAction(new PartnerOnboardingTaskAction(
            'Mark as Incomplete',
            System.Page.PartnerRegistrationMarkIncomplt.getUrl() + '?id=' + this.request.id,
            NEW_INCOMPLETE_RESUBMITTED)); */
        
        //---------------------------
        //Provision First User
        //---------------------------
        //R14.2 CR7681 - Change label 'Provision First User' to 'Provision First User as Administrator/Automated Welcome Email Sent'
        final PartnerOnboardingTask provisionFirstUserIsCompleteFlagTask = new PartnerOnboardingTask(
            'Provision First User as Administrator/Automated Welcome Email Sent',
            'Provision_First_User_Is_Complete_Flag__c',
            this
        );
        tasks.add(provisionFirstUserIsCompleteFlagTask);
        provisionFirstUserIsCompleteFlagTask.addAction(new PartnerOnboardingTaskAction(
            'Provision First User as Administrator/Automated Welcome Email Sent',
            System.Page.PartnerRegistrationProvisionUser.getUrl() + '?id=' + this.request.id,
            ALL,
            linktoAccountRecordIsCompleteFlagTask)); 
    }
    
    /*
* Added To update Lead status to Account Suggestion rejected when PR was rejected in Affinity
* Request CR:15167
* Story 4225416:Channel Maintenance - Close Rejected PR
***************************/
    Public PageReference removeAll(){
        system.debug('*** inside remove all');
        Partner_Request__c PR=new Partner_Request__c();
        PR.ID=request.ID;
        PR.status__c=System.Label.Account_Suggestion_Rejected;
        update PR;  
         system.debug(PR+'*** PR after updation');
        List<Lead> leads=[SELECT id,Status FROM Lead WHERE Id =:request.Lead__c LIMIT 1];
        //System.debug('//////'+leads);
        try{
            for(Lead l:leads){
                l.Status=System.Label.Account_Suggestion_Rejected;
                Update l;
            }        
        }
        catch(Exception e){}
        return null;
        
    }
    
    
    //Added for Owned status
 
    public PageReference ownedStatus(){
       
       Partner_Request__c pr=new Partner_Request__c();
        pr.ID=request.ID;
        pr.status__c= PartnerConstants.REG_STATUS_OWNED;
        pr.ownerid= userinfo.getUserId();
        update pr;
        return null;
 
    }
 
}