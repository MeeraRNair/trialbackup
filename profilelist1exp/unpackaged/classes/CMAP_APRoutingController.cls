/* 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      16144       FY19-0802   10-July-2018    Naga        Deleted duplicated and unused code as part of code clean up
 * 
 */
 
public with sharing class CMAP_APRoutingController {
    //Variable Declaration
    Public String APId{get;set;}
    String retURL;
    Id leadRTId;
    Account_Play__c apRecord = new Account_Play__c();
    Public Boolean showFirstBlock {get;set;}
    Public Boolean enableContinue{get;set;}
    public Account_play__c APObj{ get; set; }
    List<contactWrapper> ContactDetails {get;set;}
    string salescomment;
    string customerComment;
    Integer pageSize = 20;
    public Integer totalPages{get;set;}
    public String selUserId; 
    Public String selectedIdSet;
    public Id newId;
    public Id pContactId;
    public boolean valCheck {get; set;}
    public String primaryContact ;
    Public Boolean Show2ndBlock{get;set;}
    Public Boolean showButtonBlock{get;set;} 
    Public Lead clRecord { get; set; }
    Public Id userId;

    //set controller to get the contact list for wrapper class
    public ApexPages.StandardSetController con {
        get {
            if(con == null && APObj != NULL) {
                try{
                    if(APObj.Account__c != NULL && primaryContact == NULL){
                        con = new ApexPages.StandardSetController(Database.getQueryLocator([select Name,Id,AccountId
                                             from Contact
                                             where AccountId=:APObj.Account__c AND  
                                             (Status__c = 'Customer' OR Status__c = 'Prospect' OR Status__c = 'Marketing suspect')
                                             Order By Name LIMIT 1000]));
                    }
                    else if(APObj.Account__c != NULL && primaryContact != NULL){
                        con = new ApexPages.StandardSetController(Database.getQueryLocator([select Name,Id,AccountId
                                             from Contact
                                             where AccountId=:APObj.Account__c AND  Id != :primaryContact AND
                                             (Status__c = 'Customer' OR Status__c = 'Prospect' OR Status__c = 'Marketing suspect')
                                             Order By Name LIMIT 1000]));
                    }
                    // sets the number of records in each page set
                    if(primaryContact == NULL && con.getRecords().size()==0){
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Info,'There are no contacts found with any of the statuses - Customer or Prospect or Marketing suspect'));
                    }                 
                    con.setPageSize(pageSize);
                }
                Catch(Exception e){
                    System.debug('There are no contacts found with any of the statuses - Customer or Prospect or Marketing suspect');
                }
            }
            return con;
        }
        set;
     } 
     //standard controller method
    public CMAP_APRoutingController(ApexPages.StandardController controller) {
        try{
            showFirstBlock = TRUE;
            showButtonBlock = TRUE;
            Show2ndBlock = false;
            valCheck = false;
            enableContinue = false;
            //CRQ0970
            userId= UserInfo.getUserId();
            //CRQ0970
            retURL= ApexPages.currentPage().getParameters().get('retURL'); // get return url from the page url
            newId = ApexPages.currentPage().getParameters().get('newId');// get channel lead id from URL
            APId = ApexPages.currentPage().getParameters().get('APId'); //get account play id from URL
            pContactId = ApexPages.currentPage().getParameters().get('pContact'); // get contact details from the url
            leadRTId= IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete','Lead',true); // get record type Id of CL
            //get details of account play using the id from URL
            if(APId != NULL){
                apRecord = [Select Id, Name,
                            Primary_contact__c, Primary_Contact__r.Status__c,
                            Account__c,
                            Account_Play_Owner__c,
                            Account_Play_Owner__r.Name,
                            CreatedDate ,
                            Campaign__c, Campaign__r.Name,
                            Customer_Consents_to_Engage_Dell_Partner__c,
                            Account__r.Name,
                            Account__r.Industry,
                            Account__r.BillingCity,
                            Account__r.BillingState,
                            Account__r.BillingCountry,
                            Account__r.BillingStreet,
                            Account__r.BillingPostalCode,
                            Challenges_Driving_the_Project__c,
                            What_is_their_implementation_deadline__c,
                            Roadblocks__c,
                            Desired_Outcome__c,
                            Estimated_Budget__c,
                            Do_they_have_access_to_approved_funds__c, 
                            Interested_in_DFS_funding__c
                            
                         From  Account_Play__c 
                         where Id = :APId];
            
                APObj = apRecord ;
                if(APObj.Customer_Consents_to_Engage_Dell_Partner__c == TRUE &&
                   (APObj.Primary_Contact__c != NULL || pContactId  != NULL)){
                   enableContinue = TRUE;
                }
            }           
            //Assign value to primary Contact if value available in url
            if(pContactId  != NULL ){
                primaryContact = pContactId;
            }
            //Assign value to primary Contact if value available in account play
            else{
                if(apRecord.Primary_contact__c != NULL){
                    primaryContact = apRecord.Primary_contact__c;
                }
            }
            //get channel lead information if newId != null
            if(newId != NULL){
                 Show2ndBlock = TRUE;
                 showFirstBlock = False;
                 showButtonBlock  = False;
                 clRecord = [Select Id, Questions_Comments__c, 
                             Sales_Comments__c
                             from  Lead 
                             where Id = :newId];
                 salescomment = clRecord.Sales_Comments__c;                 
            }
            //Exception Handling: if valid record is not returned by Query
            if((newId == NULL && APId== NULL)||
                (APId != NULL && apRecord == NULL )|| 
                (newId != NULL && clRecord == NULL)){
                showFirstBlock = False;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,System.Label.CMAP_Default_Error_Message+'line 136'));
            }           
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,System.Label.CMAP_Default_Error_Message+'line 140'));
        }
    }
    //contact wrapper to dispaly radio button against each contact
    public class contactWrapper {
            public String contactName{get;set;}
            public String Id{get;set;}
            public boolean isChecked{get; set;}

        public contactWrapper(){
            this.contactName ='';
            this.Id ='';
            isChecked = false;
        }
    }
    //Add user to the permission set to avoid insufficient privilage
    public pagereference addToPermissionset(){       
       try{
           List<PermissionSetAssignment> assignmentList = new List<PermissionSetAssignment>();
           if(userId != NULL){
                List<PermissionSetAssignment> assignmentListtodelete = new List<PermissionSetAssignment> ();
                List<PermissionSetAssignment> assigneeList = [Select Id, AssigneeId 
                                                                from PermissionSetAssignment
                                                                Where AssigneeId = :userId
                                                                AND
                                                                PermissionSetId IN :[Select Id 
                                                                                    FROM PermissionSet 
                                                                                    WHERE Name = 'Channel_Permission_Set_for_R2C']];
                if(assigneeList.Size() == 0){
                    List<PermissionSet> permSet = [SELECT Id, Name
                                                   FROM PermissionSet 
                                                   WHERE Name = 'Channel_Permission_Set_for_R2C']; 
                    if((permSet != null) && (permSet.size() > 0)){
                        Id permSetId = permSet[0].Id;
                        PermissionSetAssignment assi = new PermissionSetAssignment(AssigneeId = userId, 
                                                                                   PermissionSetId = permSetId);
                        assignmentList.add(assi);
                    }
                    if(assignmentList.Size() > 0){
                        insert assignmentList;
                    }
                }
            }
       }
       catch(Exception ex){
            ApexPages.addmessages(ex);
       }
        return null;
    }
    //to enable continue button based on primary contact and customer consent
    public PageReference enableContinueButton(){     

        enableContinue = false;
        selUserId = ApexPages.currentPage().getParameters().get('radioName');
        //To Save the slected user during Navigation
        if(selUserId!= NULL){
            selectedIdSet = selUserId;
        }
        //Enable continue button if a user is selected and consent = TRUE
        if(APObj.Customer_Consents_to_Engage_Dell_Partner__c == TRUE &&
            (selUserId != NULL || selectedIdSet != NULL || primarycontact !=NULL)){
            //(selUserId != NULL )){
            enableContinue = TRUE;
        }
        return null;
    }
    //pass contact details to VF page
    public List<contactWrapper> getContactDetails() {
        Set<Id> selectedId = new Set<Id>();
        ContactDetails= new List<contactWrapper>();
        contactWrapper contactObj ;
        try{
            if(con.getPageNumber() == 1 && primaryContact != null){
                 contactWrapper cw = new contactWrapper();
                 Contact c = [Select Id,Name from Contact where id =: primaryContact limit 1];
                 cw.Id = primaryContact ;
                 cw.contactName = c.Name;
                 cw.isChecked = true;
                 valCheck = TRUE;
                 //Even if Primary contact already exist, if user change value, primary contact should not be checked
                 if( selectedIdSet !=NULL){
                     cw.isChecked = False;
                     valCheck = False;
                 }
                 ContactDetails.add(cw);              
            }
        }
        Catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,System.Label.CMAP_Default_Error_Message+'line 195'));
        }
        //display all contacts if primary contact do not exist
        try{            
            for (Contact c: (List<Contact>)con.getRecords()){
                //contactMap.put(c.Id,c);
                contactObj = new contactWrapper();
                contactObj.contactName = c.Name;
                contactObj.Id = c.Id;
                //To Show the contact as checked if it is already selected by user
                if(selectedIdSet!= NULL  && selectedIdSet == c.Id){
                    contactObj.isChecked = true;
                    valCheck = TRUE;
                }
                ContactDetails.add(contactObj);            
            }
            if(math.mod(con.getResultSize(), pageSize) > 0) {
                totalPages  =(con.getResultSize()/pageSize) + 1;
            }else{
                totalPages  = (con.getResultSize()/pageSize);
            }
            if(totalPages ==0){
                totalPages =1;
            }            
        }
        Catch(Exception e){
            totalPages =0;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,System.Label.CMAP_Default_Error_Message+'line 227'));
        }
        return ContactDetails;
    }
    //Navigation for cancel button
    public pagereference cancelButton(){
        String URL;
        if(APId != NULL && APObj != NULL){
             URL = '/'+APObj.Id ;
        }
        else{
             URL = '/apex/APCustomView?save_new=1&sfdc.override=1' ;
        }
        pagereference page = new pagereference(URL);
        page.setRedirect(TRUE);
        return page;
    }
    //continue button navigation
    public pagereference redirect(){
         //new change with page display
         selUserId = ApexPages.currentPage().getParameters().get('radioName');
         //To pass value to selUser from selectedIdSet for passing valueto CL
         if(selectedIdSet != NULL && selUserId == NULL && selUserId != selectedIdSet){
                selUserId = selectedIdSet ;
         }
         else{
             if(selUserId == NULL && selectedIdSet == NULL && primaryContact !=NULL){
                 selUserId = primaryContact;
             }
         }
         if(APObj.Customer_Consents_to_Engage_Dell_Partner__c == FALSE ||
            selUserId == NULL){
            showFirstBlock = True;
            pageUtils.AddError('Customer consent and Primary contact is required to route a Dell lead to a channel partner; upon selecting, click “continue” to complete the “route to channel” process.');
        }
        else{
            String Status = pageUtils.encodeVariable('Qualified - Channel Ready');
            String R2CSource  = pageUtils.encodeVariable('Account Play');
            string saveURLstring ='/apex/CMAP_RouteAccountPlay?retURL='+apRecord.Id;
            Contact c = new Contact();
            String cityString;
            String stateString;
            String postalString;
            String countryString;
            String formatedcreationDt ;
            String formatedDeadLineDt;

            Date dt = apRecord.What_is_their_implementation_deadline__c;
            if(dt != NULL){
                formatedDeadLineDt = String.valueOf(dt.format());//format date value
            }
            DateTime apCreationdt = apRecord.CreatedDate;
            if(apCreationdt != NULL ){
                formatedcreationDt = String.valueOf(apCreationdt.format());
                formatedcreationDt = formatedcreationDt.split ( ' ' )[ 0 ];//format date value
            }
            // get details of a selected contact
            if(selUserId != NUll){
                c = [Select Id, Name,
                            MailingStreet,
                            MailingState,
                            MailingPostalCode,
                            MailingCountry,
                            MailingCity,
                            FirstName,
                            LastName,
                            Salutation,
                            Title,
                            Email,
                            Phone,
                            MobilePhone,
                            Fax                            
                         From  contact 
                         where Id = :selUserId];            
            }
            // get address details of the selected contact
            if(c != NULL){            
                if(c.MailingStreet == NULL &&
                   c.MailingState == NULL && 
                   c.MailingPostalCode == NULL && 
                   c.MailingCountry== NULL  && 
                   c.MailingCity == NULL){
                    cityString = apRecord.Account__r.BillingCity;
                    stateString = apRecord.Account__r.BillingState;
                    postalString = apRecord.Account__r.BillingPostalCode;
                    countryString = apRecord.Account__r.BillingCountry;
                }
                else{
                    cityString = c.MailingCity;
                    stateString = c.MailingState;
                    postalString = c.MailingPostalCode;
                    countryString = c.MailingCountry;
                }
            }
            // create URL for navigation to channel lead new page
            String URL = '/00Q/e?lea13='+Status+'&RecordType='+leadRTId+
                         '&nooverride=1&retURL='+apRecord.Id+
                         '&saveURL='+saveURLstring+
                         '&00NA00000064hVv='+R2CSource+
                         '&CF00N70000002Mf4A_lkid='+c.Id+
                         '&CF00N70000002Mf4A='+c.Name+
                         '&CF00NA00000064iEg_lkid='+apRecord.Id+
                         '&CF00NA00000064iEg='+apRecord.Name+
                         /*'&CF00NZ00000019vuz_lkid='+apRecord.Id+
                         '&CF00NZ00000019vuz='+apRecord.Name+*/
                         (cityString!=NULL?'&lea16city='+pageUtils.encodeVariable(cityString):'')+
                         (stateString!=NULL?'&lea16state='+pageUtils.encodeVariable(stateString):'')+
                         (postalString!=NULL?'&lea16zip='+pageUtils.encodeVariable(postalString):'')+
                         (countryString!=NULL?'&lea16country='+pageUtils.encodeVariable(countryString):'')+     
                         (c.FirstName!=NULL?'&name_firstlea2='+pageUtils.encodeVariable(c.FirstName):'')+
                         (c.LastName!=NULL?'&name_lastlea2='+pageUtils.encodeVariable(c.LastName):'')+
                         (c.Salutation!=NULL?'&name_salutationlea2='+pageUtils.encodeVariable(c.Salutation):'')+
                         (c.MobilePhone!=NULL?'&lea9='+pageUtils.encodeVariable(c.MobilePhone):'')+
                         (c.Fax!=NULL?'&lea10='+pageUtils.encodeVariable(c.Fax):'')+
                         (c.Title!=NULL?'&lea4='+pageUtils.encodeVariable(c.Title):'')+
                         (c.Email!=NULL?'&lea11='+pageUtils.encodeVariable(c.Email):'')+
                         (c.Phone!=NULL?'&lea8='+pageUtils.encodeVariable(c.Phone):'')+
                         (formatedDeadLineDt !=NULL?'&00NA00000064hcm='+formatedDeadLineDt:'')+
                         (apRecord.Campaign__c!=NULL?'&CF00NA00000064hdB_lkid='+apRecord.Campaign__c:'')+
                         (apRecord.Campaign__c!=NULL?'&CF00NA00000064hdB='+apRecord.Campaign__r.Name:'')+
                         (apRecord.Estimated_Budget__c!=NULL?'&00NA00000064hcr='+apRecord.Estimated_Budget__c:'')+
                         (apRecord.Do_they_have_access_to_approved_funds__c!=NULL?'&00NA00000064hcw='+pageUtils.encodeVariable(apRecord.Do_they_have_access_to_approved_funds__c):'')+
                         (apRecord.Interested_in_DFS_funding__c!=NULL?'&00NA00000064hd1='+pageUtils.encodeVariable(apRecord.Interested_in_DFS_funding__c):'')+
                         (apRecord.Account__c!=NULL?'&CF00NA0000000ZTl8='+pageUtils.encodeVariable(apRecord.Account__r.Name):'')+
                         (apRecord.Account__c!=NULL?'&CF00NA0000000ZTl8_lkid='+pageUtils.encodeVariable(apRecord.Account__c):'')+ 
                         (apRecord.Account_Play_Owner__c!=NULL?'&CF00NA00000064hd6_lkid='+pageUtils.encodeVariable(apRecord.Account_Play_Owner__c):'')+
                         (apRecord.Account_Play_Owner__c!=NULL?'&CF00NA00000064hd6='+pageUtils.encodeVariable(apRecord.Account_Play_Owner__r.Name):'')+                                                 
                         (formatedcreationDt!=NULL?'&00NA00000064hdG='+formatedcreationDt:'')+
                         (apRecord.Account__r.Industry!=NULL?'&lea6='+pageUtils.encodeVariable(apRecord.Account__r.Industry):'')+  
                         (apRecord.Account__r.Name!=NULL?'&lea3='+pageUtils.encodeVariable(apRecord.Account__r.Name ):'')             
                         ;

            pagereference page = new pagereference(URL);
            page.setRedirect(TRUE);
            return page; 
        }
        return Null;
    }
   
    // indicates whether there are more records after the current page set.
    public Boolean hasNext {
        get {
            return con.getHasNext();
        }
        set;
    }

    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            return con.getHasPrevious();
        }
        set;
    }

    // returns the page number of the current page set
    public Integer pageNumber {
        get {
            return con.getPageNumber();
        }
        set;
    }

    // returns the first page of records
    public void first() {
        con.first();
    }

    // returns the last page of records
    public void last() {
        con.last();
    }

    // returns the previous page of records
    public void previous() {
        con.previous();
    }

    // returns the next page of records
    public void next() {
        con.next();
    }
    public pagereference saveButton(){
        try{
            if(salescomment != this.clRecord.Sales_Comments__c || 
            customerComment != this.clRecord.Questions_Comments__c){
                update clRecord;
            }
           
            
        }
        Catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,System.Label.CMAP_Default_Error_Message+'line 420'));
        }
        String URL= '/'+newId;
        pagereference page = new pagereference(URL);
        page.setRedirect(TRUE);
        return page;        
    }
   
}