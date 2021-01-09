public class SendInvoiceCtrlExt {

    public Invoice__c myInvoice {get; set;}
    public Invoice__c invoiceRecord {get; set;}
    public List <Attachment> attachmentList = new List <Attachment>{};
    public List<Attachment> SendAttachmentList;
    public String email;
    public boolean nullEmail {get; set;}
    public boolean IncorrectEmail {get; set;}
    public boolean nullAttachmentList {get; set;}
    public MDF_Associated_Contact__c associatedMDFContact=new MDF_Associated_Contact__c();
    public MDF_Contact__c MDFContact {get; set;}
    public List<AttachmentWrapperCls> attachmentIteratedList = new List<AttachmentWrapperCls>();
    public List<POP_Line_Item__c> POPLineItem = new List<POP_Line_Item__c>{};
    set<id> AttachmentIDset = new set<id>();
    
    public SendInvoiceCtrlExt(ApexPages.StandardController controller) {
        this.myInvoice = (Invoice__c)controller.getRecord();
        
        invoiceRecord = [select Id,Name,Fiscal_Quarter__c,Region__c,Vendor__c,Vendor__r.name from Invoice__c where Id =: myInvoice.Id];

        set<id> MarketingPlanIDset = new set<id>();
        for(Marketing_Plan__c MPId : [select Id,Name,Invoice__c from Marketing_Plan__c where Invoice__c =: myInvoice.Id]){
            MarketingPlanIDset.add(MPId.Id);
        }
        
        set<id> APVIDset = new set<id>();
        for(Associated_Programs_Vendors__c APVId :[select Id,Name,Marketing_Plan__c,MDF_Program__c,POP_Status__c from Associated_Programs_Vendors__c where Marketing_Plan__c in: MarketingPlanIDset and POP_Status__c = 'Executed']){
            APVIDset.add(APVId.MDF_Program__c);
        }
        
        set<id> POPIDset = new set<id>();
        for(Proof_of_Performance_POP__c popID : [select Id,Name,MDF_Program__c,Fiscal_Quarter__c,Region__c from Proof_of_Performance_POP__c where MDF_Program__c in: APVIDset]){
            POPIDset.add(popID.Id);
        }
        
        set<id> ParentIDset = new set<id>();
        set<id> POPLineItemIDset = new set<id>();
        // Mohan 20110601 BRD8.4.1.1
        Map<Id,POP_Line_Item__c> popLineItemMap = new Map<Id,POP_Line_Item__c>();
        // Mohan 20110601 BRD8.4.1.1
        for(POP_Line_Item__c popLineItemID : [select Id,Name,Proof_of_Performance_POP__c,Vendor__c,Proof_of_Performance_POP__r.Fiscal_Quarter__c,Proof_of_Performance_POP__r.Region__c 
                                // Mohan 20110601 BRD8.4.1.1
                                                ,Business_Segment__c, POP_Submission_Status__c, Proof_of_Performance_POP__r.MDF_Program__r.Name
                                //Mohan 20110601 BRD8.4.1.1
                                                from POP_Line_Item__c 
                                                where Proof_of_Performance_POP__c in: POPIDset and 
                                                Vendor__c =: invoiceRecord.Vendor__c and
                                                Proof_of_Performance_POP__r.Fiscal_Quarter__c =: invoiceRecord.Fiscal_Quarter__c and
                                                Proof_of_Performance_POP__r.Region__c =: invoiceRecord.Region__c
                                                ]){
            ParentIDset.add(popLineItemID.Id);
            // Mohan 20110601 BRD8.4.1.1
            popLineItemMap.put(popLineItemID.Id,popLineItemID);
            // Mohan 20110601 BRD8.4.1.1
        }

        attachmentIteratedList = new List<AttachmentWrapperCls>();
        
        ParentIDset.add(myInvoice.Id);
       
        attachmentList = [select Id,Name,contentType,ParentId,bodylength
                            from Attachment
                            where ParentId in: ParentIDset
                            ];

        for(Attachment Arcd : attachmentList){
            // Mohan 20110601 BRD8.4.1.1
            if(Arcd.ParentId == myInvoice.Id){
            // Mohan 20110601 BRD8.4.1.1
                attachmentIteratedList.add(new AttachmentWrapperCls(Arcd));
            }
            // Mohan 20110601 BRD8.4.1.1
            else{
                attachmentIteratedList.add(new AttachmentWrapperCls(Arcd,popLineItemMap.get(Arcd.ParentId)));
            }
            // Mohan 20110601 BRD8.4.1.1    
        }

        nullEmail = false;
        nullAttachmentList = false;
        IncorrectEmail = false;
    }
    
    public MDF_Associated_Contact__c getAssociatedMDFContact(){
        return associatedMDFContact;
    }
    public  void setAssociatedMDFContact(MDF_Associated_Contact__c contactObj){
        this.associatedMDFContact=contactObj;
    }

    public class AttachmentWrapperCls{

        public Attachment AttachmentRecord{get;set;}
        public boolean selected{get;set;}
        // Mohan 20110601 BRD8.4.1.1
        public string segment{get;set;}
        public string program{get;set;}
        public string status{get;set;}
        // Mohan 20110601 BRD8.4.1.1
        public AttachmentWrapperCls(Attachment Arcd){
           AttachmentRecord = Arcd; 
           selected = false;
           // Mohan 20110601 BRD8.4.1.1
           segment = null;
           program = null;
           status = null;
           // Mohan 20110601 BRD8.4.1.1
        }
        // Mohan 20110601 BRD8.4.1.1
        public AttachmentWrapperCls(Attachment Arcd,POP_Line_Item__c PopItem){
           AttachmentRecord = Arcd; 
           selected = false;
           segment = PopItem.Business_Segment__c;
           program = PopItem.Proof_of_Performance_POP__r.MDF_Program__r.Name;
           status = PopItem.POP_Submission_Status__c;
        }
        // Mohan 20110601 BRD8.4.1.1
    }
    
    public PageReference sendMail(){
        Attachment selectedRecords;
        SendAttachmentList = New List<Attachment>();
        String bodyOfEmail='Dear '+invoiceRecord.Vendor__r.name+' -'+' ';
        String[] toaddress = new List<String>();

        if(email == '' && associatedMDFContact.MDF_Contact__c == null){
            apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please Enter E-Mail ID'  , '' )) ;
            return null;
        }
         
        if(associatedMDFContact.MDF_Contact__c!=null){
                    MDFContact = [select Id,Name,Email__c
                                from MDF_Contact__c
                                where Id=:associatedMDFContact.MDF_Contact__c
                                limit 1];
        }
        
        if(email!='Enter emailId'&& email!='' && email.contains('@')){
             bodyOfEmail=bodyOfEmail+email.split('@')[0]+',';             
         }
         if(associatedMDFContact.MDF_Contact__c != NULL){
             bodyOfEmail=bodyOfEmail+MDFContact.Email__c.split('@')[0]+',';
         }
        
        String[] addr = new String[]{}; // max 10 addresses
        if(((!Pattern.matches('[a-zA-Z0-9._-]+@[a-zA-Z]+.[a-zA-Z]{2,4}', email) && email!='') && (associatedMDFContact.MDF_Contact__c == NULL || associatedMDFContact.MDF_Contact__c != NULL)) || email.contains(';')){ 
            apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please Enter a Valid E-Mail ID'  , '' )) ;
            //IncorrectEmail = true;
            return null;
        }
        else{
            if(email == '' && associatedMDFContact.MDF_Contact__c != NULL){
                addr.add(MDFContact.Email__c);                
            }
            if(email != '' && ( Pattern.matches('[a-zA-Z0-9._-]+@[a-zA-Z]+.[a-zA-Z]{2,4}', email) || !email.contains(';')) && associatedMDFContact.MDF_Contact__c != NULL){
                addr.add(MDFContact.Email__c);
                addr.add(email);
            }
            if(email != '' && ( Pattern.matches('[a-zA-Z0-9._-]+@[a-zA-Z]+.[a-zA-Z]{2,4}', email) || !email.contains(';')) && associatedMDFContact.MDF_Contact__c == NULL){
                addr.add(email);
            }
            
            bodyOfEmail=bodyOfEmail+'<br/><br/> Thank you for your collaboration with Dell S&P Co-Marketing. Your '+ invoiceRecord.Fiscal_Quarter__c+' invoice(s) and proof of performance';
            bodyOfEmail=bodyOfEmail+' '+'documentation are ready for your review. Please check the documentation for accuracy and reply within one week with any questions or concerns. If there is no response within one week, Dell will assume you agree that the attached invoice and supporting documentation are accurate. As this is the only notification of the invoice(s)';
            bodyOfEmail=bodyOfEmail+' '+ 'that will be sent, please submit to your Accounts Payable team. Payment terms are indicated on the invoice. ';
            //bodyOfEmail=bodyOfEmail+ '<br/><br/>You may view these documents at this link:<br/>' + URL.getSalesforceBaseUrl().toExternalForm()+ '/secur/login_portal.jsp?orgId='+ UserInfo.getOrganizationId()+'&portalId=060A0000000PiLr&startURL='+URL.getSalesforceBaseUrl().toExternalForm()+'/'+invoiceRecord.Id;
            //bodyOfEmail=bodyOfEmail+ '<br/><br/>';
            
            bodyOfEmail=bodyOfEmail+ '<br/><br/>Dell | Software & Peripherals Co-Marketing<br/><br/>';
    
            for(AttachmentWrapperCls selectedlist : attachmentIteratedList){
                if(selectedlist.selected==true){
                    AttachmentIDset.add(selectedlist.AttachmentRecord.Id);
                }
            }
            
       for(Attachment AList : [select Id,Name,body,contentType,ParentId,bodylength from Attachment where Id in: AttachmentIDset]){
            selectedRecords = new Attachment();
            selectedRecords.Name = AList.Name;
            selectedRecords.contentType = AList.contentType;
            selectedRecords.body= AList.body;
            SendAttachmentList.add(selectedRecords);
        }
        
        if (SendAttachmentList.size() == 0){
            apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please Select Attachment to send'  , '' )) ;
            return null;
        }
        list<OrgWideEmailAddress> lstOrgWideAddresses = [select Id, DisplayName from OrgWideEmailAddress where DisplayName =:Label.OWA_Address];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(addr);
        mail.setOrgWideEmailAddressId(lstOrgWideAddresses[0].Id);
        mail.setSubject(invoiceRecord.Vendor__r.name+' |  '+'Dell'+' '+ invoiceRecord.Fiscal_Quarter__c +' '+ 'S&P Co-Marketing Invoicing Materials');
        mail.setHtmlBody(bodyOfEmail);
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        for(Attachment attachmntselectedlist : SendAttachmentList){
            Messaging.EmailFileAttachment fileAttachment = new Messaging.EmailFileAttachment();
            fileAttachment.setBody(attachmntselectedlist.body);
            fileAttachment.setFileName(attachmntselectedlist.name);
            fileAttachment.setContentType(attachmntselectedlist.contentType); 
            fileAttachments.add(fileAttachment);
        }
        mail.setFileAttachments(fileAttachments);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        //Update Invoice Record with the Email ID
        if(email != NULL && associatedMDFContact.MDF_Contact__c != NULL){
            myInvoice.Invoice_Sent_To_Vendor__c = email+','+MDFContact.Email__c;}
        if(email != NULL && associatedMDFContact.MDF_Contact__c == NULL){
            myInvoice.Invoice_Sent_To_Vendor__c = email;}
        if((email == NULL || email == '') && associatedMDFContact.MDF_Contact__c != NULL){
            myInvoice.Invoice_Sent_To_Vendor__c = MDFContact.Email__c;}
        
        update myInvoice;
      }
        return new PageReference('/'+myInvoice.ID);
    }
    
    public List<AttachmentWrapperCls> getattachmentIteratedList () {
        return attachmentIteratedList;
    }
    public void setattachmentIteratedList (List<AttachmentWrapperCls> mPlanList) {
        this.attachmentIteratedList = mPlanList;
    }
    public String getEmail () {
        return Email;
    }
    public void setEmail (String mailID) {
        this.Email = mailID;
    }

}