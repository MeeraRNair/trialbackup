/*
 * Revision CR Number   Release No  Date            Modified By    Description
 * -------- ---------   ----------  -----------  ------------      -------------------------------------
 * 1.0                   1002       5-Aug-2019    Meenu & Subha        Utilised the class for Channel Services Helpdesk Case Recordtype cases in 
 *                                                                     VF page : ChannelServicesHelpdeskVFPage
 * 2.0                   1002       28-Aug-2019   Meenu                Added variable bIsPortalProfile to check if the user profile is portal
 * 2.0                   0102       25-Sep-2019   Subhasini            Auto-populate User Name with Partner Portal User for CSH Partner Cases [Phase II]
 * 2.0                   0102       30-sep-2019   Meenu                Added CaseRTMigrate__Contact_Name_User__c, CaseRTMigrate__Contact_Email1__c fields to query and Prepopulate on savecase for CaseRTMigrate__Contact_Name_User__c  and CaseRTMigrate__Contact_Email1__c 
 * 3.0      CR 18243     0102       28-Oct-2019   Emily                Adding Touch Time fields
 * 4.0                   0102       31-Oct-2019   Meenu                Removed variable bIsPortalProfile
 * 4.0                   0102       08-nov-2019   Meenu                Fixes for defect 7656921 Username and contact email are updated with the user making the changes on the case
-------------------------------------------------------------------------------------------------- */

Public with sharing class Vfcntrl_OrderSupportVfPage {
//
    Id recTypId; //stores the current record type id
   // string subTypeVar;
    public Id caseId {get;set;} //stores the current case id
    public case caseObj {get;set;} //stores the instance of current case object
    public String recordTypeName {get;set;} //stores the current recordtype's name
    public boolean isReadOnly {get;set;} //stores if the form is to be displayed in readonly view for an existing case
    public boolean escalationSecEnable {get;set;}
    public boolean exceptionError {get;set;} 
    public Boolean isPartnerUser {get;set;}
    public boolean isCaseManager{get;set;}
    User loggedInUser;
    public Boolean isPartnerAdmin {get;set;}
    public Boolean isReOpenedCase{get;set;}
    public Boolean isOpenCase{get;set;}
    public Boolean isClosedCase{get;set;}
    public Boolean isReopenedStatus{get;set;}
    public Boolean internalCase{get;set;}
    public string caseStatus{get;set;}
    public string accountRegion{get;set;}
    public string cloneCase;
    public boolean isSubjectDisabled {get;set;}
    public boolean bisContactSame {get;set;}
    public string subjectValue ;
    public string queueName;
    public list<QueueSobject> dealRegQueues = new list<QueueSobject>();
    /* For Disti purpose*/
    public list<selectoption> diSubTypeList{get;set;}
    public list<selectoption> diCaseReasonList{get;set;}
    set<string> stypesSet=new set<string>();
    set<string> creasonsSet=new set<string>(); 
    list<string> stypesList=new List<string>();
    list<string> creasonsList=new List<string>();
    Case caseClone ;
    
    public String userType {
        get { return UserInfo.getUserType();}
        set { userType = UserInfo.getUserType();}
    }

    //The variables to hold attachment data
    public Attachment attach1{get;set;}
    public Attachment attach2{get;set;}
    public Attachment attach3{get;set;}
    public Attachment attach4{get;set;}
    public Attachment attach5{get;set;}
    public List<Attachment> attachmentList = new List<Attachment>();
    public boolean bcheckLexOrClassic {get;set;}
    
    //Added by Hari 05/03/2019
    public string strOppId;
    public string strAccId;

    //Added by Meenu 8th-Nov-2019 
    Private String strContactUser ;
    Private String strContactEmail1;
  

 // Constructor
    public Vfcntrl_OrderSupportVfPage(ApexPages.StandardController controller) {
        
        this.caseClone = (Case)controller.getRecord();
        bcheckLexOrClassic = false;
        System.debug('Constructorssss');
        exceptionError = False;
        isPartnerUser  = false;
        isPartnerAdmin = False;
        isSubjectDisabled = false;
        
        //Added by Hari 
        strOppId= ApexPages.currentPage().getParameters().get('oppId');
        strAccId= ApexPages.currentPage().getParameters().get('accId');
        
        //new
        caseId = ApexPages.currentPage().getParameters().get('id');
        cloneCase = ApexPages.currentPage().getParameters().get('clone');
        //dealId = ApexPages.currentPage().getParameters().get('dealId');
        loggedInUser = [select Id,Profile.name,contactid,Enable_Partner_Admin__c,contact.Selected_Track_Account__c from user where id = : UserInfo.getUserId() ];
        
        caseObj = new case ();
        Map<String,String> recIdMap = ApexPages.currentPage().getParameters();
        recTypId = recIdMap.get('RecordType');
        //subTypeVar = ApexPages.currentPage().getParameters().get('subType');
        caseobj.RecordtypeId = recTypId;
        caseObj.OwnerId = loggedInUser.Id; 
        caseObj.ContactId = loggedInUser.contactId;
        if(strOppId<>null){
          caseObj.Opportunity_Title__c = strOppId.escapeHtml4();
        }
        if(String.isNotBlank(strAccId)){
            caseObj.AccountId = strAccId.escapeHtml4();
        }
        else{
      //  if(loggedInUser.contact.Selected_Track_Account__c != null){
        caseObj.AccountId = loggedInUser.contact.Selected_Track_Account__c;
      //  }
        }
        if((loggedInUser.Profile.name).contains('Portal') == True){
        caseObj.AccountId = loggedInUser.contact.Selected_Track_Account__c;
        caseObj.ContactId = loggedInUser.contactId; 
            // Story# 7278525  Auto-populate User Name with Partner Portal User for CSH Partner Cases 

        caseObj.CaseRTMigrate__Case_UserName__c = loggedInUser.Id;    
        }     
            
       // caseobj.Sub_Type_Order_Support__c = subTypeVar;
        isReadOnly = false;
        escalationSecEnable = false;
        isReOpenedCase = false;
        isOpenCase = false;
        isClosedCase = false;
        isReopenedStatus = false;
        isCaseManager=false;
        caseStatus='';
        accountRegion='';
        
    system.debug('*******@@@@'+caseObj.region__c);        
        //For Disti record type
                
        diSubTypeList=new list<selectoption>();
        diCaseReasonList=new list<selectoption>();
        diSubTypeList.add(new selectoption('',Label.none_for_drop_down));
        diCaseReasonList.add(new selectoption('',Label.none_for_drop_down));
             
        // Attachments                    
        attach1 = new Attachment();
        attach2 = new Attachment();
        attach3 = new Attachment();
        attach4 = new Attachment();
        attach5 = new Attachment();          
        
        
        
        recordTypeName = '';
        list<RecordType> rt = [SELECT Id,Name FROM RecordType WHERE id =: caseobj.RecordtypeId LIMIT 1];
        if(rt != null && rt.size() > 0) 
        {
            recordTypeName = rt[0].Name;
        }
   
        if((loggedInUser.Profile.name).contains('Portal') == True ) {
                countryRegion();
        }
        
        if((loggedInUser.Profile.name).contains('GBL PRM') == True ) {
                isCaseManager = True; 
        }
        
        //Edit           
        if(caseId != null) {
                        
            isReadOnly = True;
            caseStatus=caseObj.status;
            if(loggedInUser.Enable_Partner_Admin__c == True ) {
                    isPartnerAdmin = True; 
            }
            
    //Query to fetch all the fields. Opted Query instead of Dynamic as dynamic Query cant handle more than 50 Fields.    
    /*Meenu Sinha :STORY 7059159 :added Partner_Motion__c,Serial_Number__c,Contract_Number__c,End_User_Address__c,Sales_Order_Number__c fields to query*/   
    /*Meenu Sinha :STORY 7276851 : added CaseRTMigrate__Contact_Name_User__c, CaseRTMigrate__Contact_Email1__c fields to query*/
            caseObj =[select id,Status,Actual_Case_Reason__c,Subject,region__c,contactid,accountid,ownerid,CaseNumber,IsClosed,Priority,Order_Reference_Number_Type__c,Order_Number1__c,Request_Escalation__c,
                      Re_Open_Status_Flag__c,Sub_Type_Order_Support__c,Pick_Up_Address__c,Delivery_Address__c,Replacement_order_or_credit__c,Product_Type__c,Full_or_Partial_order_impacted__c,
                      Original_Or_Incorrect_Address__c,New_Address__c,Pickup_Address_Details__c,Full_or_Partial_order_return__c,Reason_for_the_return__c,
                      Item_s_Description__c,Case_Reason_Order_Support__c,original_name__c,new_name__c,current_taxID__c,new_taxID__c,Reopen_Justification__c,Alternate_Phone__c,ParentId,
                      Opportunity_Title__c,RecordTypeId,RecordType.name,recordType.developerName,Opportunity_Reference__c,Origin,Others__c,New_Case_Comments__c,End_User_Name__c,End_User_Email__c,End_User_Company__c,
                      Description,Additional_Information__c,IsEscalated,Escalation_Justification__c,Escalation_Reason__c,Escalation_Detail__c,Additional_Recipient_1__c,Additional_Recipient_2__c,Additional_Recipient_3__c,
                      Additional_Recipient_4__c,Additional_Recipient_5__c,Is_Escalated_After_Close__c,Unauthenticated_Case__c,Business_change_letter_cert_attached__c,
                      Unauthenticated_account__c,unauthenticated_Contact__c,Unauthenticated_Account_Affinity_ID__c,Unauthenticated_Contact_Email__c,Case_Category__c,
                      Creator_Email__c,UA_Requesting_on_behalf_of_Account__c,UA_Requesting_on_behalf_of_Affinity_ID__c,Country_Area__c,Current_Distributor__c,Requested_Preferred_Distributor__c,
                      Partner_Motion__c,Serial_Number__c,Contract_Number__c,End_User_Address__c,Sales_Order_Number__c,Partner_Account_Name__c,
                      CaseRTMigrate__Contact_Name_User__c,CaseRTMigrate__Contact_Email1__c,CaseRTMigrate__Touch_Time_Hours__c, CaseRTMigrate__Touch_Time_Minutes__c 
                      from case where id=:caseid];
            
            caseStatus=caseObj.status;
            recordTypeName=caseobj.Recordtype.name;
            
            //Added by Meenu 8th-Nov-2019 
            strContactEmail1 = caseObj.CaseRTMigrate__Contact_Email1__c;
            strContactUser = caseObj.CaseRTMigrate__Contact_Name_User__c;
            
            if(recordTypeName=='Distribution' && caseObj.Sub_Type_Order_Support__c.startsWithIgnoreCase('Concessions')){
                subjectValue = '';
            }else{
                subjectValue = caseObj.Subject;
            }
            
            if(caseObj.Request_Escalation__c == true){
                escalationSecEnable = true;
            }
            
            if(caseobj.Re_Open_Status_Flag__c == true) {
                isReOpenedCase = true;
            }
            
            if(caseobj.status == 'Closed (Resolved)') {
                isClosedCase = true;
            }
            
            if(caseobj.status == 'Re-Open') {
                isReopenedStatus = true;
            }          
            
            if(caseobj.status == 'open') {
                isOpenCase = true;
            }            
            
            // Clone
            if(cloneCase == '1'){
                caseobj = caseobj.clone(false);
                
                caseobj.Status = 'Open';
                caseObj.OwnerId = loggedInUser.Id; 
                caseObj.New_Case_Comments__c = false;  
                caseObj.Reopen_Justification__c = null;
                caseObj.Re_Open_Status_Flag__c = false;
                caseObj.Post_to_Chatter__c = false;
                caseObj.Request_Escalation__c = false;
                caseObj.IsEscalated = false;
                caseObj.Escalation_Reason__c = null;
                caseObj.Escalation_Justification__c = null;
                caseObj.Escalation_Detail__c = null;
                caseObj.Time_of_escalation_request__c = null;
                caseObj.Is_Escalated_After_Close__c = false;
                
            }
            countryRegion();
            distiCaseReasons();
           //DistiSubTypes();
        }
  }
    
    /*
      Added to redirect to sandard clone page when the recortype is presales
    */
    public pageReference caseRedirect()
    {
        pagereference page;
        
        /********START********Added by shubham bhatt for making it work for all recordtypes related to CaseRTMigrate Managed Package for defect 7048259 & 7044986*/
        string CaseRTMigrateRecordTypeIds = CaseManagement.caseRTMigrate_getRTIDs();
        boolean caseRtMigRecType = false;
        for(string recTypeId : CaseRTMigrateRecordTypeIds.split(';')){
            if(caseobj.Recordtype.id == recTypeId){
                caseRtMigRecType = true;
            }
        }
        if(caseRtMigRecType) /******STOP**********Added by shubham bhatt for making it work for all recordtypes related to CaseRTMigrate Managed Package for defect 7048259 & 7044986*/
        {
            //String redirectURL = '/' + caseid + '/e?clone=1&returl=' + caseid + '&nooverride=1&cancelURL='+caseid;
            // Added by Ravindra babu Marripudi, to make the Touch down time hours and touch down Minutes to blank when clone the case
           String redirectURL = '/' + caseid + '/e?clone=1&returl=' + caseid + '&nooverride=1&cancelURL=' + caseid + '&'+CaseRTMigrate__CaseRTMigrate_General_Settings__c.getOrgDefaults().CaseRTMigrate__Touch_Down_Hours_Element_ID__c+'=&'+CaseRTMigrate__CaseRTMigrate_General_Settings__c.getOrgDefaults().CaseRTMigrate__Touch_Down_Minutes_Element_ID__c+'=';
            page = new pagereference(redirectURL);
            page.setRedirect(TRUE);
        }
        //Added by Meenu 28-aug-2019 to redirect to standard clone page for csh recordtype
        if(caseobj.Recordtype.developerName.contains('Channel')) 
        {
            String strCaseId = String.valueOf(caseId).escapeHtml4();
            String strRedirectURL = '/' + strCaseId + '/e?clone=1&returl=' + strCaseId + '&nooverride=1&cancelURL=' + strCaseId ;
            page = new pagereference(strRedirectURL );
            page.setRedirect(TRUE);
        }
        
        /****************Commented by shubham bhatt:- making it work for all recordtypes related to CaseRTMigrate Managed Package for defect 7048259 & 7044986
        if(caseobj.Recordtype.developerName.contains('Presales')) 
        {
            //String redirectURL = '/' + caseid + '/e?clone=1&returl=' + caseid + '&nooverride=1&cancelURL='+caseid;
            // Added by Ravindra babu Marripudi, to make the Touch down time hours and touch down Minutes to blank when clone the case
           String redirectURL = '/' + caseid + '/e?clone=1&returl=' + caseid + '&nooverride=1&cancelURL=' + caseid + '&'+CaseRTMigrate__CaseRTMigrate_General_Settings__c.getOrgDefaults().CaseRTMigrate__Touch_Down_Hours_Element_ID__c+'=&'+CaseRTMigrate__CaseRTMigrate_General_Settings__c.getOrgDefaults().CaseRTMigrate__Touch_Down_Minutes_Element_ID__c+'=';
            page = new pagereference(redirectURL);
            page.setRedirect(TRUE);
        }*/
        return page;
    }

   
    public void validateDataForCaseSubTypes() {
        System.debug('validateDataForCaseSubTypes');
        if(recordTypeName=='Order Support'){
        if (caseobj.Sub_Type_Order_Support__c != Label.Case_SubType_Return && caseobj.Sub_Type_Order_Support__c != Label.Case_SubType_Wrong) {
            caseObj.Pick_Up_Address__c = null;              
        }
        
        if (caseobj.Sub_Type_Order_Support__c != Label.Case_SubType_Wrong && caseobj.Sub_Type_Order_Support__c != Label.Case_SubType_Missing) {
            caseObj.Delivery_Address__c = null;
            caseObj.Replacement_order_or_credit__c= null;
            caseObj.Full_or_Partial_order_impacted__c= null;
            caseObj.Product_Type__c = null;
        }
        
        if (caseobj.Sub_Type_Order_Support__c != Label.Case_SubType_pickupRedelivery && caseobj.Sub_Type_Order_Support__c != Label.Change_of_Address_Post_Shipment) {
            caseObj.Original_Or_Incorrect_Address__c = null;
            caseObj.New_Address__c = null;
            caseObj.Pickup_Address_Details__c = null;
        }
        
        if (caseobj.Sub_Type_Order_Support__c != Label.Case_SubType_Return) {
            caseObj.Full_or_Partial_order_return__c= null;
            caseObj.Reason_for_the_return__c = null;
            //caseObj.Exceeds_30_day_Policy__c = null;
        }
        if(caseobj.Sub_Type_Order_Support__c != Label.Case_SubType_Wrong && caseobj.Sub_Type_Order_Support__c != Label.Case_SubType_Missing && caseobj.Sub_Type_Order_Support__c != Label.Case_SubType_Return){
            caseObj.Item_s_Description__c = null;
        }
        }
        if(recordTypeName=='On Boarding'){
            if(caseObj.Case_Reason_Order_Support__c==Label.Tax_ID_Change){
                caseObj.Original_Or_Incorrect_Address__c = null;
                caseObj.New_Address__c = null;
                caseObj.original_name__c=null;
                caseObj.new_name__c=null;
            }
            if(caseObj.Case_Reason_Order_Support__c==Label.Address_change){
                caseObj.original_name__c=null;
                caseObj.new_name__c=null;
                caseObj.current_taxID__c=null;
                caseObj.new_taxID__c=null;
            }//
            if(caseObj.Case_Reason_Order_Support__c==Label.Name_Address_Notax_change){
                caseObj.current_taxID__c=null;
                caseObj.new_taxID__c=null;
            }
        }
    }
    
    
    
    /*
    * This methods 
    */
    public void clearSubtypeOptions() {
        caseObj.Full_or_Partial_order_return__c= null;
        caseObj.Reason_for_the_return__c = null;
        //caseObj.Exceeds_30_day_Policy__c = null;
        caseObj.Pick_Up_Address__c = null;
        caseObj.Delivery_Address__c = null;
        caseObj.Original_Or_Incorrect_Address__c = null;
        caseObj.New_Address__c = null;
        caseObj.Pickup_Address_Details__c = null;
        caseObj.Item_s_Description__c = null;
        caseObj.Replacement_order_or_credit__c= null;
        caseObj.Full_or_Partial_order_impacted__c= null;
        caseObj.Product_Type__c =null;
        caseObj.original_name__c=null;
        caseObj.new_name__c=null;
        caseObj.current_taxID__c=null;
        caseObj.new_taxID__c=null;
    }
    
    /*
    * This methods Performs the save for case record
    * After successfull save, this method also takes care of uploading the attachments for the case
    */
    public PageReference saveCase() {
       try {
           
            exceptionError = false;
            validateDataForCaseSubTypes();

            /*Start - added by Meenu -- Prepopulate CaseRTMigrate__Contact_Name_User__c  and CaseRTMigrate__Contact_Email1__c -- story 7276851*/
            if(recordTypeName.contains('Channel'))
            {
                String strUserQuery = 'Select id, ';

                String strCNU =caseObj.CaseRTMigrate__Contact_Name_User__c; 
                String strContactEmail = caseObj.CaseRTMigrate__Contact_Email1__c;
                String strSuppliedEmail =  caseObj.SuppliedEmail;
                String strUserId = UserInfo.getUserId();
                
                if(caseObj.CaseRTMigrate__Contact_Name_User__c != null || caseObj.CaseRTMigrate__Contact_Email1__c != null || String.isBlank(caseId))
                {   
                    if(caseObj.CaseRTMigrate__Contact_Name_User__c != null )
                    {
                        strUserQuery += 'email from user where id =:strCNU ';
                    }
                    else if(caseObj.CaseRTMigrate__Contact_Email1__c != null)
                    {
                        strUserQuery += 'email from user where email =:strContactEmail ';
                    }
                    else if(caseObj.SuppliedEmail != null)
                    {
                        strUserQuery += 'email from user where email =:strSuppliedEmail';
                    }
                    else{
                        strUserQuery += 'email from user where id =:strUserId ';
                    } 
                    strUserQuery  += ' and isActive = true order by lastmodifieddate limit 1';
                    
                    List<User> listUser = database.query(strUserQuery);
                    if(!listUser.isEmpty() )
                    {
                        caseObj.CaseRTMigrate__Contact_Name_User__c = listUser[0].id;
                        caseObj.CaseRTMigrate__Contact_Email1__c  = listUser[0].email;
                    }
                } //added by Meenu On 8-Nov-2019
                else if(String.isNotBlank(caseId))
                {
                    caseObj.CaseRTMigrate__Contact_Email1__c = strContactEmail1 ;
                    caseObj.CaseRTMigrate__Contact_Name_User__c = strContactUser ; 
                }
            }
            
            /*End - added by Meenu -- Prepopulate CaseRTMigrate__Contact_Name_User__c  and CaseRTMigrate__Contact_Email1__c -- story 7276851*/
       
        /*    bisContactSame = false;
           
           if(caseObj.Contact.AccountId == caseObj.Account.Master_Group_Id__c){
              // bisContactSame = True;
               caseObj.ContactId.addError('You must enter a value!');
               system.debug('****Step');    
           }*/
           if(caseId == null || cloneCase == '1' ) {
            //Fetching the assignment rules on case
            AssignmentRule ar = new AssignmentRule();
            ar = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
            
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.assignmentRuleId= ar.id;
            caseobj.setOptions(dmo);
            database.insert(caseobj);
            
            if(caseobj.status == 'Assigned' ){
                
                  database.update(caseobj);
            }
            
           /* system.debug('***recordTypeName : '+ recordTypeName );
            List<QueueSobject> queueObj = [SELECT QueueId FROM QueueSobject WHERE Queue.Name = 'Cases - Order Support Global' limit 1 ];
            
            string assignedQueue ;
            //if(caseobj.region__c == 'APJ' ){
                if(recordTypeName == 'Order Support'){
                    assignedQueue = queueObj[0].QueueId;
                }
            //}
            system.debug('***Assigned Queue: '+ assignedQueue);
            caseobj.OwnerId = assignedQueue;
            update caseobj;*/
     
           }else if(caseId != null && cloneCase != '1'){
            update caseobj;
           }
            // Parse Attachments to attachmentList
            attachmentList = new list<Attachment>();                  
            if(attach1.name != null && attach1.name != '' && attach1.Body != null) {
                attach1.ParentId = caseObj.Id; 
                attachmentList.add(attach1);
            }
            if(attach2.name != null && attach2.name != '' && attach2.Body != null) {
                attach2.ParentId = caseObj.Id; 
                attachmentList.add(attach2);
            }
            if(attach3.name != null && attach3.name != '' && attach3.Body != null) {
                attach3.ParentId = caseObj.Id; 
                attachmentList.add(attach3);
            }
            if(attach4.name != null && attach4.name != '' && attach4.Body != null) {
                attach4.ParentId = caseObj.Id; 
                attachmentList.add(attach4);
            }
            if(attach5.name != null && attach5.name != '' && attach5.Body != null) {
                attach5.ParentId = caseObj.Id; 
                attachmentList.add(attach5);
            }
            
            if(attachmentList.size()!=0 ){
                insert attachmentList;
            } 
            system.debug('before return');
            return new pagereference('/'+ caseObj.Id);
        } catch (System.DmlException e) {
            attachmentList = new list<Attachment>();
            system.debug('in catch');
            System.debug('Exception : '+e);
            exceptionError = True;
            if(e.getDmlMessage(0).contains('insufficient')){
            ApexPages.addMessage(new ApexPages.Message(Apexpages.Severity.ERROR, System.label.insufficient_case_prev));
            }else{
            
              ApexPages.addMessage(new ApexPages.Message(Apexpages.Severity.ERROR, e.getDmlMessage(0)));
          
            }
        } finally {
            //ExceptionError = True;
                attachmentList = null;
                attach1 = new Attachment();
                attach2 = new Attachment();
                attach3 = new Attachment();
                attach4 = new Attachment();
                attach5 = new Attachment();
                //return null;
        }
        return null;
    }
    
    /*
    * This methods internally calls SaveCase & redirects to the new case creation page
    */
    public PageReference saveAndNew() {
        saveCase();
        return new pagereference('/setup/ui/recordtypeselect.jsp?ent=Case&retURL=%2F500%2Fo&save_new_url=%2F500%2Fe%3FretURL%3D%252F500%252Fo');
    }
    
    
    public void distiSubTypes(){
    
        diSubTypeList=new list<selectoption>();
        stypesSet=new set<string>();
        stypesList=new List<string>();
        
        diSubTypeList.add(new selectoption('',Label.none_for_drop_down));
                        
        diSubTypeList.add(new selectoption('SPL Tech query',Label.Disti_ST_SPLTechQuery));
        diSubTypeList.add(new selectoption('SPL content query',Label.Disti_ST_SPCcontentQuery));
        if(accountRegion=='EMEA' || accountRegion=='EC-EMEA'){
            diSubTypeList.add(new selectoption('Concessions - Sell Out Claim',Label.Disti_ST_Concessions_SellOutClaim));
            diSubTypeList.add(new selectoption('Concessions - Price Protection',Label.Disti_ST_Concessions_PriceProtection));
            diSubTypeList.add(new selectoption('Concessions - BFS',Label.Disti_ST_Concessions_BFS));
            diSubTypeList.add(new selectoption('Concessions - Volume Grid',Label.Disti_ST_Concessions_Volume_Grid));
            diSubTypeList.add(new selectoption('Concessions - Stock Return',Label.Disti_ST_Concessions_Stock_Return));
            diSubTypeList.add(new selectoption('Concessions - Wyse',Label.Disti_ST_Concessions_Wyse));
        
            //stypesSet.add(Label.Disti_ST_Concessions_SellOutClaim);
            //stypesSet.add(Label.Disti_ST_Concessions_PriceProtection);
            //stypesSet.add(Label.Disti_ST_Concessions_BFS);
            //stypesSet.add(Label.Disti_ST_Concessions_Volume_Grid);
            //stypesSet.add(Label.Disti_ST_Concessions_Stock_Return);
            //stypesSet.add(Label.Disti_ST_Concessions_Wyse);
            
        }else if(accountRegion=='APJ'){
            diSubTypeList.add(new selectoption('Concessions - Sell Out Claim',Label.Disti_ST_Concessions_SellOutClaim));
            diSubTypeList.add(new selectoption('Concessions - Price Protection',Label.Disti_ST_Concessions_PriceProtection));
            diSubTypeList.add(new selectoption('Concessions - BFS',Label.Disti_ST_Concessions_BFS));
            diSubTypeList.add(new selectoption('Concessions - Stock Return',Label.Disti_ST_Concessions_Stock_Return));
            diSubTypeList.add(new selectoption('Concessions - Service Fees Claim',Label.Disti_ST_Concessions_ServiceFeesClaim));
            diSubTypeList.add(new selectoption('Concessions - Sell In Claim',Label.Disti_ST_Concessions_SellInClaim));
        
            //stypesSet.add(Label.Disti_ST_Concessions_SellOutClaim);
            //stypesSet.add(Label.Disti_ST_Concessions_PriceProtection);
            //stypesSet.add(Label.Disti_ST_Concessions_BFS);
            //stypesSet.add(Label.Disti_ST_Concessions_Stock_Return);
            //stypesSet.add(Label.Disti_ST_Concessions_ServiceFeesClaim);
            //stypesSet.add(Label.Disti_ST_Concessions_SellInClaim);
            
        }else if(accountRegion=='NA'){
            diSubTypeList.add(new selectoption('Concessions - Sell Out Claim',Label.Disti_ST_Concessions_SellOutClaim));
            diSubTypeList.add(new selectoption('Concessions - Price Protection',Label.Disti_ST_Concessions_PriceProtection));
            diSubTypeList.add(new selectoption('Concessions - BFS',Label.Disti_ST_Concessions_BFS));
            diSubTypeList.add(new selectoption('Concessions - Stock Return',Label.Disti_ST_Concessions_Stock_Return));
            diSubTypeList.add(new selectoption('Concessions - Wyse',Label.Disti_ST_Concessions_Wyse));
            diSubTypeList.add(new selectoption('Concessions - Bid Bucket',Label.Disti_ST_Concessions_BidBucket));
            diSubTypeList.add(new selectoption('Concessions - Bid Grid',Label.Disti_ST_Concessions_BigGrid));
        
            //stypesSet.add(Label.Disti_ST_Concessions_SellOutClaim);
            //stypesSet.add(Label.Disti_ST_Concessions_PriceProtection);
            //stypesSet.add(Label.Disti_ST_Concessions_BFS);
            //stypesSet.add(Label.Disti_ST_Concessions_Stock_Return);
            //stypesSet.add(Label.Disti_ST_Concessions_Wyse);
            //stypesSet.add(Label.Disti_ST_Concessions_BidBucket);
            
        }else if(accountRegion=='Latam'){
            diSubTypeList.add(new selectoption('Concessions - Sell Out Claim',Label.Disti_ST_Concessions_SellOutClaim));
            diSubTypeList.add(new selectoption('Concessions - Price Protection',Label.Disti_ST_Concessions_PriceProtection));
            diSubTypeList.add(new selectoption('Concessions - BFS',Label.Disti_ST_Concessions_BFS));
            diSubTypeList.add(new selectoption('Concessions - Stock Return',Label.Disti_ST_Concessions_Stock_Return));
            diSubTypeList.add(new selectoption('Concessions - Wyse',Label.Disti_ST_Concessions_Wyse));
            diSubTypeList.add(new selectoption('Concessions - Bid Bucket',Label.Disti_ST_Concessions_BidBucket));
        
            //stypesSet.add(Label.Disti_ST_Concessions_SellOutClaim);
            //stypesSet.add(Label.Disti_ST_Concessions_PriceProtection);
            //stypesSet.add(Label.Disti_ST_Concessions_BFS);
            //stypesSet.add(Label.Disti_ST_Concessions_Stock_Return);
            //stypesSet.add(Label.Disti_ST_Concessions_Wyse);
            //stypesSet.add(Label.Disti_ST_Concessions_BidBucket);
        }
                        
        
        stypesList.addall(stypesSet);
        stypesList.sort();
        
        
        for(string s:stypesList){
            //Di_SubTypeList.add(new selectoption(s,s));
        }
        system.debug('check diSubTypeList'+diSubTypeList);
        
        
    }
    
    public void distiCaseReasons(){
    
        diCaseReasonList=new list<selectoption>();
        creasonsList=new List<string>();
        creasonsSet=new set<string>(); 
        diCaseReasonList.add(new selectoption('',Label.none_for_drop_down));
        
        if(caseObj.Sub_Type_Order_Support__c=='SPL Tech query'){
            diCaseReasonList.add(new selectoption('SPL Access issues',Label.Disti_CR_SPLAccessissues));
            diCaseReasonList.add(new selectoption('B2B integrated SPL issue',Label.Disti_CR_B2B_integrated_SPLissue));
        
            //CreasonsSet.add(Label.Disti_CR_SPLAccessissues);
            //CreasonsSet.add(Label.Disti_CR_B2B_integrated_SPLissue);
            
        }else if(caseObj.Sub_Type_Order_Support__c=='SPL content query'){
            diCaseReasonList.add(new selectoption('Product Description issue',Label.Disti_CR_ProductDescription_issue));
            diCaseReasonList.add(new selectoption('Product pricing',Label.Disti_CR_Product_pricing)); 
            diCaseReasonList.add(new selectoption('Product availability',Label.Disti_CR_Product_Availability)); 
            diCaseReasonList.add(new selectoption('Other',Label.Disti_CR_Other));     
        
            //CreasonsSet.add(Label.Disti_CR_ProductDescription_issue);
            //CreasonsSet.add(Label.Disti_CR_Product_pricing);
            //CreasonsSet.add(Label.Disti_CR_Product_Availability);
            //CreasonsSet.add(Label.Disti_CR_Other);
            
        }
        
       else if(caseObj.Sub_Type_Order_Support__c=='Concessions - Stock Return'){
            diCaseReasonList.add(new selectoption('Other',Label.Disti_CR_Other));
            
            //CreasonsSet.add(Label.Disti_CR_Other);
            
        }else if(caseObj.Sub_Type_Order_Support__c=='Concessions - Service Fees Claim'){
            diCaseReasonList.add(new selectoption('Payment Query',Label.Disti_CR_Payment_Query));
            diCaseReasonList.add(new selectoption('Statement Query',Label.Disti_CR_Statement_Query));
            diCaseReasonList.add(new selectoption('Other',Label.Disti_CR_Other));
            
            //CreasonsSet.add(Label.Disti_CR_Payment_Query);
            //CreasonsSet.add(Label.Disti_CR_Statement_Query);
            //CreasonsSet.add(Label.Disti_CR_Other);
            
        }else if(caseObj.Sub_Type_Order_Support__c=='Concessions - Sell In Claim'){
            diCaseReasonList.add(new selectoption('Payment Query',Label.Disti_CR_Payment_Query));
            diCaseReasonList.add(new selectoption('Statement Query',Label.Disti_CR_Statement_Query));
            diCaseReasonList.add(new selectoption('Exception Request',Label.Disti_CR_Exception_Request));
            diCaseReasonList.add(new selectoption('Other',Label.Disti_CR_Other));
        
            //CreasonsSet.add(Label.Disti_CR_Payment_Query);
            //CreasonsSet.add(Label.Disti_CR_Statement_Query);
            //CreasonsSet.add(Label.Disti_CR_Exception_Request);
            //CreasonsSet.add(Label.Disti_CR_Other);
            
        }else {
            diCaseReasonList.add(new selectoption('Payment Query',Label.Disti_CR_Payment_Query));
            diCaseReasonList.add(new selectoption('Statement Query',Label.Disti_CR_Statement_Query));
            diCaseReasonList.add(new selectoption('Exception Request',Label.Disti_CR_Exception_Request));
            diCaseReasonList.add(new selectoption('Manual claim submission – Exception ONLY',Label.Disti_CR_ManualClaimSubmission_ExceptionOnly));
            diCaseReasonList.add(new selectoption('Other',Label.Disti_CR_Other));
        
            //CreasonsSet.add(Label.Disti_CR_Payment_Query);
            //CreasonsSet.add(Label.Disti_CR_Statement_Query);
            //CreasonsSet.add(Label.Disti_CR_Exception_Request);
            //CreasonsSet.add(Label.Disti_CR_ManualClaimSubmission_ExceptionOnly);
            //CreasonsSet.add(Label.Disti_CR_Other);
        
        }
                           
        creasonsList.addall(creasonsSet);
        creasonsList.sort();
        //Di_CaseReasonList.add(new selectoption('','--None--'));
        
        for(string s:creasonsList){
            //Di_CaseReasonList.add(new selectoption(s,s));
        }
        system.debug('check diCaseReasonList'+diCaseReasonList);
        
         // Distribution switch on subject
        switchSubjectForDisti();
    }
    
    public void switchSubjectForDisti() {
    Boolean concessions=false;
        if(caseObj.Sub_Type_Order_Support__c=='Concessions - Sell Out Claim' || caseObj.Sub_Type_Order_Support__c=='Concessions - Price Protection' || caseObj.Sub_Type_Order_Support__c=='Concessions - BFS' || caseObj.Sub_Type_Order_Support__c=='Concessions - Volume Grid' || caseObj.Sub_Type_Order_Support__c=='Concessions - Stock Return' || caseObj.Sub_Type_Order_Support__c=='Concessions - Service Fees Claim' || caseObj.Sub_Type_Order_Support__c=='Concessions - Wyse' || caseObj.Sub_Type_Order_Support__c=='Concessions - Bid Bucket' || caseObj.Sub_Type_Order_Support__c=='Concessions - Sell In Claim' || caseObj.Sub_Type_Order_Support__c=='Concessions - Bid Grid'){
            concessions=true;
        }
        if(caseId == null) { 
            if(recordTypeName=='Distribution' && concessions==true){
                isSubjectDisabled = true;
                caseobj.Subject = recordTypeName + ' - ' + caseobj.Sub_Type_Order_Support__c ;
            }else{
                isSubjectDisabled = false;
                caseobj.Subject = '' ;
            }
        }else if(caseId != null) {
            if(recordTypeName=='Distribution' && concessions==true){
                isSubjectDisabled = true;
                caseobj.Subject = recordTypeName + ' - ' + caseobj.Sub_Type_Order_Support__c ;
            }else{
                isSubjectDisabled = false;
                caseobj.Subject = subjectValue ;
            }
        }
        
        // Story 4012291:Case MgMt: DI: Concessions: Case type & sub type into Subject field
       /* if(recordTypeName=='Distribution' && caseObj.Sub_Type_Order_Support__c.startsWithIgnoreCase('Concessions')) {
            caseobj.Subject = recordTypeName + ' - ' + caseobj.Sub_Type_Order_Support__c ;
        }*/
    }
    
    public void countryRegion(){
    
        string region='';
        string accountvalue='';
        system.debug('check case account'+Caseobj.AccountID+' '+Caseobj.Contactid);
        
        if((loggedInUser.Profile.name).contains('Portal') == True ) {
             list<contact> conList=[select id,accountid from contact where id=:loggedInUser.contactid];
                 if(!conList.isempty()){
                     accountvalue=conList[0].accountid;
                 }
        } else{
               accountvalue=Caseobj.AccountID;
            }
            
         system.debug('check account value' +accountvalue); 
                        
        list<account> acclist=[select name,Account_Country_Code__c from account where id=:accountvalue];
        string countryCode='';
        
            If(!acclist.IsEmpty()){
                countryCode=acclist[0].Account_Country_Code__c;
            }
            
            if(countryCode!=''){
                list<Country__c> countryList=[select Id, Region__c, Code__c, Name from Country__c where Code__c=:countryCode];
                    if(!countryList.IsEmpty()){
                         Region=countryList[0].Region__c;
                    }
            }
        system.debug('check region'+Region);
          if(caseobj.Unauthenticated_Case__c != true){
        accountRegion=Region; }
        else{accountRegion= Caseobj.Region__C;}               
        
        distiSubTypes();
            
        }
    
    }