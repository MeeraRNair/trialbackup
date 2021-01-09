/*
 * Author   : Bikram Dutta
 * Purpose  : Deals originating from Engage Channel functionality will be auto-approved once the partner accepts the deal (submits for approval). 

 *        
 * Revision Ref Number  Release No  Date            Modified By     Description
 * -------- ----------  ----------  -----------     ------------    -----------
 * 1.0      CR 12729    CSM0502     31-03-2016      Bikram Dutta     
 * 2.0      CR 13046    CSM0502     14-04-2016      Devika Pujari   To update the submitter profile to current user's PRM profile so that
 *                                                                  deal gets routed to the right approval queue.
 * 3.0      CR 13058    CSM0502    18-04-2016       Devika Pujari    Default deat type to collaboration.
 * 4.0       4000929           13-11-2016    Sneha Maheshwary GC Users will not have any specific GC Profile 
 *         CR                   10 -12-2018         Haribabu.A     STORY 5907651 Removed reference for the fields lob_registration_id__c and direct_account_name__c
*/

public class EngageChannelAutoApprovalCtrl {


 public List < Opportunity > DealOpp {
  get;
  set;
 }
 public ID OpptyID {
  get;
  set;
 }
/*
 //Set Message and Error Variables
 public static string MSG_KEY_AUTO_APPROVED {
  get {
   return 'MSG_KEY_AUTO_APPROVED';
  }
 }
 public static string MSG_KEY_AUTO_APPROVAL_FAILED {
  get {
   return 'MSG_KEY_AUTO_APPROVAL_FAILED';
  }
 }
 public static string MSG_CODE_INTERNAL_ERROR {
  get {
   return 'autoApprovalProcess() method excuted and returned false.';
  }
 }
 public string preferredLanguageCode {
  get {
   return PartnerUtils.getPreferredLanguageCode();
  }
 }
 public boolean hasError {
  get {
   return (getErrors().size() > 0);
  }
 }*/
 public boolean showMessage {
  get;
  private set;
 }
 
 public string messageKey {
  get;
  private set;
 }/*
 public ApexPages.Message[] getErrors() {
  return PageUtils.getErrorMessagesOnly();
 }
*/
 //URLs Variables
 private PageReference stdApprovalPageRef;
 private PageReference opptyDetailPageRef;
 private PageReference compProfilePageRef;

 private Id[] idArr = new Id[] {};
 public Boolean succeed = false;
 public Boolean succeed1;
 public Approval.ProcessResult result = null;

 // Main Method[Calling Function: AVSSuggestion]  
 public PageReference AutoApprove(ID OppTID) {

   DealOpp = [select id,Deal_Type__c , Deal_Registration_Status__c, Engage_Channel_Opportunity__c, PartnerAccountId, name, AccountId, Number_of_Line_Items__c, OwnerId, Primary_Product_Delivery_Address_Country__c, Primary_Product_Delivery_Address_Region__c,
    HasOpportunityLineItem,Submitter_Profile__c, End_User_Account_Department__c, End_User_Mailing_City__c, End_User_Mailing_State_Province_Region__c from Opportunity where Id = : OppTID LIMIT 1
   ];
   OpptyID = DealOpp[0].id;
   idArr.add(DealOpp[0].OwnerID);

   //Logic to identify if the deal is coming from Engage Channel and auto approve the deal.       
   if (DealOpp[0].Engage_Channel_Opportunity__c == TRUE && DealOpp[0].Deal_Registration_Status__c != 'Approved') {
    /****v 2.0 Starts **/
    User CurrentUserInfo = [Select Profile_Name__c,Country  from User where Id=: UserInfo.getUserId()];
    DealOpp[0].Submitter_Profile__c = CurrentUserInfo.Profile_Name__c;
    DealOpp[0].Partner_Submitter_Country__c = CurrentUserInfo.Country;
    // Commenting it as Part of US 4000929
    
    //if(!DealRegUtils.isGCCountry() == True){
    DealOpp[0].Deal_Expiration_Timeframe__c ='90';         
   // }
    update DealOpp[0];
    /****v 2.0 Ends**/

    if (!Test.isRunningTest()){
    try{
    /****v 3.0 Starts **/
    
        if( Dealopp[0].Deal_Type__c == 'Incumbency')  
            Dealopp[0].Deal_Type__c = 'Incumbency';
       else  DealOpp[0].Deal_Type__c = 'Fulfillment';
      
     update DealOpp[0]; 
    /****v 3.0 Ends **/

     Approval.ProcessResult result = submitApprovalRequest();    
     succeed1 = autoApprovalProcess(result);
     }catch(Exception e){
            system.debug('## Caught APEX exception '+e.getMessage()+' [Code: LOBRegistrationAutoApprovalCtrl | Method: submitRegistration]');
     }
     }else{
           submitApprovalRequest();
     }
   }
   return NULL;


  }
  //This method is to handle the deal registration auto-approval process
 @TestVisible private Boolean autoApprovalProcess(Approval.ProcessResult result) {

  try {

   // Verify the result, if success, approve the submitted request
   if (result.isSuccess()) {
    // First, get the ID of the newly created item
    List < Id > newWorkItemIds = result.getNewWorkitemIds();
    
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
  } catch (Exception e) {
   system.debug('## Caught APEX exception ' + e.getMessage() + ' [Code: EngageChannelAutoApprovalCtrl | Method: autoApprovalProcess]');
   succeed = false;
   throw e;
  }
  return succeed;
 }

 // This method is handle the Deal Submit Process for Auto Approval
 @TestVisible private Approval.ProcessResult submitApprovalRequest() {
  try {
   // Create an approval request for the opportunity
   Approval.ProcessSubmitRequest submitReq = new Approval.ProcessSubmitRequest();
   submitReq.setComments('Submitting request for approval.');
   submitReq.setObjectId(OpptyID);
   submitReq.setNextApproverIds(idArr);
   result = Approval.process(submitReq);
   system.debug('$$$$$$$$$$$ submitApprovalRequest result: ' + result);
  } catch (Exception e) {
   system.debug('## Caught APEX exception ' + e.getMessage() + ' [Code: EngageChannelAutoApprovalCtrl | Method: submitApprovalRequest]');
   throw e;
  }
  return result;
 }

 @TestVisible private void setMessage(string msgKey) {
  showMessage = true;
  messageKey = msgKey;
 }

}