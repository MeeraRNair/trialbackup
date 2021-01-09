/*
Description: Code for sending customer portal url for partners

Version: 2.0

Author: Hanan Justin

History:
1.0 - 20-Dec-2010: Creation
1.1 - 24-May-2011: Updated as part of quick hit CR
2.0 - 16-Jun-2011: Cr 6285
3.0 - 16-Feb-2016: Cr 12668-Syuhada correct the spelling, change verbiage and add line space
4.0 - 02-Jun-2018 CR 15897 - VIPER: Update to Marketing Review Plan email template
4.1 - 22-Jun-2018 Kishore--Adding extra/missed logic to the CR 15897 VIPER: Update to Marketing Review Plan email template
*/
public class VFCntrlr_EmailDeleteMarketingPlan{
    Boolean vbrhErr=false;
    Boolean rrhErr=false;
    Boolean dispForm=false;
    Boolean profileErr=false;
    Boolean noAPVErr=false;
    Boolean noContactErr=false;
    Boolean noPdctMgrErr=false;
    Boolean signSOW=false;
    Boolean approval=false;
    Boolean attachmentErr=false;

    String emailId='enter emailId';

    Id contactId;

    public Marketing_Plan__c marketingPlanRec{get; set;}
    List<Associated_Programs_Vendors__c> apvsOfMP=new List<Associated_Programs_Vendors__c>();
    List<String> apvPendingList=new List<String>();
    List<String> apvNonPendingList=new List<String>();
    List<SelectOption> options = new List<SelectOption>();
    //List<MDF_Associated_Contact__c> mdfContacts=new List<MDF_Associated_Contact__c>();
    List<Id> contactIdList=new List<Id>();
    Map<Id,MDF_Associated_Contact__c> contactMap=new Map<Id,MDF_Associated_Contact__c>();

    //CR 6285
    List<productManager> pdtMGRContacts=new List<productManager>();
    List<partnerContact> mdfContacts=new List<partnerContact>();
    List<AttachmentWrapperCls> attachmentIteratedList = new List<AttachmentWrapperCls>();
    Map<Id,Attachment> attachmentMap=new Map<Id,Attachment>();
    Set<Id> agreementIdSet=new Set<Id>();
    Task reviewTask=new Task();
    List<Task> taskList=new List<Task>();

    public class productManager{
        public Boolean selected{get; set;}
        public MDF_Associated_Contact__c pdtMgrAC{get; set;}

        public productManager(Boolean bol,MDF_Associated_Contact__c mdfAC){
            selected=bol;
            pdtMgrAC=mdfAC;
        }
    }
    
     public class partnerContact{
        public Boolean selected{get; set;}
        public MDF_Associated_Contact__c prCon{get; set;}

        public partnerContact(Boolean bol,MDF_Associated_Contact__c mdfAC){
            selected=bol;
            prCon=mdfAC;
        }
    }

    public class AttachmentWrapperCls{

        public Attachment AttachmentRecord{get;set;}
        public boolean selected{get;set;}

        public AttachmentWrapperCls(Attachment Arcd,Boolean bol){
           AttachmentRecord = Arcd;
           selected = bol;
        }

    }

    public VFCntrlr_EmailDeleteMarketingPlan(ApexPages.StandardController controller){
        marketingPlanRec=(Marketing_Plan__c)controller.getRecord();
        Id marketingPlanId=marketingPlanRec.Id;
        Id userProfileId = userinfo.getProfileId();
        String eligibleProfile='no';
        String currentURL=ApexPages.currentPage().getUrl();

        List<MDF_Associated_Contact__c> mdfContactOfVendor=new List<MDF_Associated_Contact__c>();


        marketingPlanRec=[select id,name,Contract_Status__c,MP_Status__c,Contract_Type__c,Fiscal_Quarter__c,
                         Invoice__c,Invoice_Amount__c,Purchase_Order__c,Rebate_Rule_Header__c,Region__c,
                         Term__c,Vendor__c,Vendor__r.name,Volume_Based_Rule_Header__c,Vendor__r.Budgeted_Discount__c,Sub_Region__c,
                         OwnerId,Owner.name,Send_Review_Reminder__c from Marketing_Plan__c where id=:marketingPlanId];


        List<Profile> userProfile=[select id,Name from profile where id = :userProfileId];


        for(Profile profileElt:userProfile){
            String strProfileName=profileElt.name;
            if(profileElt!=null && ((strProfileName.contains('MDF')&& strProfileName.contains('Co')&&strProfileName.contains('Marketing')&& strProfileName.contains('Manager')) ||
            (strProfileName.contains('MDF Marketing Operations / Contract Admin'))||
            profileElt.name=='System Administrator')){
                eligibleProfile='yes';
            }
        }

        apvsOfMP=[select id,name,vendor__c,Status__c,POP_Status__c, MDF_Program__c, recordtypeId,Rate_Card_Price__c,Business_Segment__c,
                Budgeted_Price__c,Marketing_Plan__c,LE__c,PUB__c,SMB__c,CSMR__c,MDF_Program__r.name,MDF_Program__r.Fiscal_Quarter__c,
                MDF_Program__r.Program_Status__c,MDF_Program__r.Region__c,MDF_Program__r.Rate_Card_Price__c,MDF_Program__r.Pricing_Type__c,
                MDF_Program__r.POP_Details__c,Accounting_Treatment__c from Associated_Programs_Vendors__c
                where vendor__c=:marketingPlanRec.vendor__c and Marketing_Plan__c=:marketingPlanRec.id];

        for(Associated_Programs_Vendors__c apvRec: apvsOfMP){
            if(apvRec.Status__c=='Pending'){
                apvPendingList.add(apvRec.Status__c);
            }
            if(apvRec.Status__c!='Pending'){
                apvNonPendingList.add(apvRec.Status__c);
            }
        }


        //CR 6285
        for(MDF_Associated_Contact__c mdfAC:[select MDF_Contact__c,vendor__c,MDF_Contact__r.Partner_Contact_Type__c ,
                                                MDF_Contact__r.Email__c,MDF_Contact__r.name,MDF_Contact__r.recordtype.name,MDF_Contact__r.User__c,MDF_Contact__r.User__r.Name,MDF_Contact__r.User__r.Email
                                                from MDF_Associated_Contact__c where vendor__c=:marketingPlanRec.vendor__c]){
            if(mdfAC.MDF_Contact__r.recordtype.name=='Partner Contact'){
                mdfContacts.add(new partnerContact(false,mdfAC));
            }

            if(mdfAC.MDF_Contact__r.recordtype.name=='Product Manager Contact'){
                pdtMGRContacts.add(new productManager(false,mdfAC));
            }
            contactMap.put(mdfAC.Id,mdfAC);
        }
        System.debug('###contactMap'+contactMap);
        if(pdtMGRContacts.size()==0 && currentURL.contains('MPlanVendorApprovalPage')){
            noPdctMgrErr=true;
        }

        if((marketingPlanRec.Contract_Type__c=='Volume Based' && marketingPlanRec.Volume_Based_Rule_Header__c!=null) ||
        (marketingPlanRec.Contract_Type__c=='Rebates' && marketingPlanRec.Rebate_Rule_Header__c!=null)|| (marketingPlanRec.Contract_Type__c=='Ala Carte' || marketingPlanRec.Contract_Type__c=='Headcount')){
            dispForm=true;
            vbrhErr=false;
            rrhErr=false;
            profileErr=false;
            noAPVErr=false;
            noContactErr=false;
        }
        if(eligibleProfile!='yes'){
            dispForm=false;
            vbrhErr=false;
            rrhErr=false;
            profileErr=true;
            noAPVErr=false;
            noContactErr=false;
        }

        if((currentURL.contains('mplanvendorapprovalpage') || currentURL.contains('MPlanVendorApprovalPage'))&& apvPendingList.size()==0 && eligibleProfile=='yes'){

           vbrhErr=false;
            rrhErr=false;
            profileErr=false;
            noContactErr=false;
            if(marketingPlanRec.Contract_Type__c=='Rebates'){
                dispForm=true;
                noAPVErr=false;
            }
            if(marketingPlanRec.Contract_Type__c!='Rebates'){
                dispForm=false;
                noAPVErr=true;
            }

        }

        if((currentURL.contains('mplanvendorapprovalpage') || currentURL.contains('MPlanVendorApprovalPage')) && mdfContacts.size()==0 && eligibleProfile=='yes'){

            dispForm=true;
            vbrhErr=false;
            rrhErr=false;
            profileErr=false;
            noAPVErr=false;
            if(marketingPlanRec.Contract_Type__c=='Rebates'){
                noContactErr=true;
            }
            if(marketingPlanRec.Contract_Type__c!='Rebates'  && apvPendingList.size()>0){
                noContactErr=true;
            }

        }
        if(marketingPlanRec.Contract_Type__c=='Volume Based' && marketingPlanRec.Volume_Based_Rule_Header__c==null){
            vbrhErr=true;
            rrhErr=false;
            dispForm=false;
            profileErr=false;
            noAPVErr=false;
            noContactErr=false;
        }
        if(marketingPlanRec.Contract_Type__c=='Rebates' && marketingPlanRec.Rebate_Rule_Header__c==null){
            vbrhErr=false;
            rrhErr=true;
            dispForm=false;
            profileErr=false;
            noAPVErr=false;
            noContactErr=false;
        }


        if(ApexPages.currentPage().getParameters().get('param2')=='signSow'){
            signSOW=true;
            for(echosign_dev1__SIGN_Agreement__c elt:[select id from echosign_dev1__SIGN_Agreement__c
                                                        where marketing_plan__c=:marketingPlanRec.Id]){
                agreementIdSet.add(elt.Id);
            }
            for(Attachment Arcd : [select Id,Name,contentType,ParentId,bodylength
                                    from Attachment where ParentId in:agreementIdSet]){
                attachmentMap.put(Arcd.Id,Arcd);
                attachmentIteratedList.add(new AttachmentWrapperCls(Arcd,false));
            }
            if(attachmentMap.size()==0){
                attachmentErr=true;
            }

        }

        if(ApexPages.currentPage().getParameters().get('param2')=='approval'){
            approval=true;
        }
    }

    public boolean getDisplayForm(){
        return dispForm;
    }
    public boolean getProfileErr(){
        return profileErr;
    }
    public boolean getNoAPVErr(){
        return noAPVErr;
    }
    public boolean getNoContactErr(){
        return noContactErr;
    }

    public pageReference deleteMPlan(){
        pageReference homePage=new pageReference('/home/home.jsp');
        List<Package__c> packagesOfMp=new List<Package__c>();
        Map<Id,Package__c> packageMap=new Map<Id,Package__c>();
        if(marketingPlanRec.Contract_Status__c=='Pending' && apvPendingList.size()==apvsOfMP.size() && apvNonPendingList.size()==0){
            packagesOfMp=[select Fiscal_Quarter__c,Marketing_Plan__c,Package_Price_del__c,Status__c from Package__c where Marketing_Plan__c=:marketingPlanRec.id];

            for(Package__c pkg:packagesOfMp){
                packageMap.put(pkg.Id,pkg);
            }
            for(Associated_Programs_Vendors__c apvRec: apvsOfMP){
                apvRec.Marketing_Plan__c=null;
                apvRec.LE__c=0;
                apvRec.PUB__c=0;
                apvRec.SMB__c=0;
                apvRec.CSMR__c=0;
                apvRec.Accounting_Treatment__c='';
                apvRec.Invoice_Amount__c=0;
                apvRec.POP_Status__c='';
                apvRec.POP_Status_Reason__c='';
                apvRec.Program_Notes__c='';
                apvRec.Status__c='Pending';
                apvRec.Contract_Status_Reason__c='';
                if(packageMap.get(apvRec.Package__c)!=null){
                    apvRec.Package__c=null;
                }
            }
            update apvsOfMP;
            if(packagesOfMp.size()>0){
                delete  packagesOfMp;
            }

            delete  marketingPlanRec;
            return homePage;
        }else if((apvNonPendingList.size()!=0 && apvPendingList.size()!=apvsOfMP.size())||(marketingPlanRec.Contract_Status__c!='Pending')){
            return null;
        }
        return null;
    }

    public List<partnerContact> getpartnerContact(){
        system.debug('mdfContacts###:'+mdfContacts);
        return mdfContacts;
    }
    public void setpartnerContact(List<partnerContact> mdfList){
        this.mdfContacts=mdfList; 
        system.debug('mdfContacts###:'+mdfContacts);               
    }
    public String getEmailId(){
        return emailId;
    }
    public void setEmailId(String emailVal){
        this.emailId=emailVal;
    }    
    public boolean getVBRHError(){
        return vbrhErr;
    }
    public boolean getRRHError(){
        return rrhErr;
    }

    /********CR 6285 and CR 6297************************************/

    public List<productManager> getProductManagers(){
        return pdtMGRContacts;
    }
    public void setProductManagers(List<productManager> PdtMgrList){
        this.pdtMGRContacts=PdtMgrList;
    }
    //Cr 6285 end


    public PageReference sendForApproval(){
       PageReference  retStr;
       String addresses;
        Map<String,string> toAddress=new Map<String,string>();
        String[] toAddresses=new List<String>();
        String bodyOfEmail='Hi ';
        String bodyOfEmail2;
        String strPartnerConNames;  //4.1--To store the partner contact name after concatenating 
        String mdfCntname;
        String otherName;
        Associated_Programs_Vendors__c  apvElt;
        List<Associated_Programs_Vendors__c> apvUpdateList=new List<Associated_Programs_Vendors__c>();
        List<Package__c> pkgUpdateList=new List<Package__c>();
        Set<Id> pkgIdSet=new Set<Id>();
       try{
            Marketing_Plan__c marketingPlan=new Marketing_Plan__c(id=marketingPlanRec.id);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            marketingPlan.Review_Sent_To_Vendor__c = '';
            marketingPlan.Review_Sent_To_Email__c ='';
            marketingPlan.Send_Review_Reminder__c = marketingPlanRec.Send_Review_Reminder__c;
            for(productManager elt:pdtMGRContacts){
                    if(elt.selected==true){
                        toAddress.put(contactMap.get(elt.pdtMgrAC.Id).MDF_Contact__r.User__c,contactMap.get(elt.pdtMgrAC.Id).MDF_Contact__r.User__r.Name);
                        mdfCntname=contactMap.get(elt.pdtMgrAC.Id).MDF_Contact__r.Name;
                        marketingPlan.Review_Sent_To_Vendor__c=marketingPlan.Review_Sent_To_Vendor__c+mdfCntname+', ';
                        marketingPlan.Review_Sent_To_Email__c=marketingPlan.Review_Sent_To_Email__c+contactMap.get(elt.pdtMgrAC.Id).MDF_Contact__r.Email__c+', ';
                        //bodyOfEmail=bodyOfEmail+mdfCntname+',';
                        
                    }
                    
                    system.debug('bodyOfEmail###PMC'+bodyOfEmail);
                }
                system.debug('toAddress###PMC'+toAddress);
             for(PartnerContact elt:mdfContacts){
                    if(elt.selected==true){
                        toAddresses.add(contactMap.get(elt.prCon.Id).MDF_Contact__r.Email__c);                        
                        mdfCntname=contactMap.get(elt.prCon.Id).MDF_Contact__r.name;
                        marketingPlan.Review_Sent_To_Vendor__c=marketingPlan.Review_Sent_To_Vendor__c+mdfCntname+', ';
                        marketingPlan.Review_Sent_To_Email__c=marketingPlan.Review_Sent_To_Email__c+contactMap.get(elt.prCon.Id).MDF_Contact__r.Email__c+', ';
                        bodyOfEmail=bodyOfEmail+mdfCntname+',';
                        system.debug('toAddresses###PC'+toAddresses);
                    }
                    system.debug('bodyOfEmail###PC'+bodyOfEmail);
                }    
             if(emailId=='enter emailId' && toAddresses.size()==0 && toAddress.size()==0){
                ApexPages.Message msg;
                msg = new ApexPages.Message(ApexPages.severity.FATAL,'Error: To continue, please select a contact or enter an emailId in the input field.');
                ApexPages.addMessage(msg);
                return null;
             }else{
                system.debug('toAddresses###else'+toAddresses);                
                if(emailId!='enter emailId'){
                    toAddresses.add(emailId);                    
                    if(marketingPlan.Review_Sent_To_Vendor__c!=null){
                        marketingPlan.Review_Sent_To_Vendor__c=marketingPlan.Review_Sent_To_Vendor__c+emailId;
                        marketingPlan.Review_Sent_To_Email__c=marketingPlan.Review_Sent_To_Email__c+emailId;
                        otherName=emailId;
                    }
                    if(marketingPlan.Review_Sent_To_Vendor__c==null){
                        marketingPlan.Review_Sent_To_Vendor__c=emailId;
                        marketingPlan.Review_Sent_To_Email__c=emailId;
                        otherName=emailId;
                    }
                    otherName=(otherName.split('@'))[0];
                    //Comment this line by sharad for 4.0 
                    //bodyOfEmail=bodyOfEmail+otherName+',';
                }            
                strPartnerConNames = bodyOfEmail; //4.1
                system.debug('toAddresses###body'+toAddresses);
                List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
                if(emailId!='enter emailId' || toAddresses.size()!=0){
                    bodyOfEmail=bodyOfEmail+'<br></br>'; //4.0
                    bodyOfEmail=bodyOfEmail+'<b>'+marketingPlanRec.Vendor__r.name+':  '+marketingPlanRec.Fiscal_Quarter__c+':  '+marketingPlanRec.name+'     Review Request</b><br></br>'+ //4.0
                    +marketingPlanRec.Owner.name+', of Dell S&P Co-Marketing, has sent you the below marketing plan for your consideration. Follow the link to '+
                    'review the marketing programs within your plan.  Approved program(s) will be included in the final version of your plan. Upon receiving your selections, '+
                    'a Statement Of Work will be provided separately for your signature. <br></br>';
    
                    bodyOfEmail=bodyOfEmail+' Marketing Plan Name: '+marketingPlanRec.name+'<br/><br/>'; //4.0
    
                    bodyOfEmail=bodyOfEmail+'<b>Partner Portal Link:</b> <a href=\" '+' '+URL.getSalesforceBaseUrl().toExternalForm()+'/secur/login_portal.jsp?orgId='+UserInfo.getOrganizationId()+'&portalId=060A0000000PiLr&startURL='+URL.getSalesforceBaseUrl().toExternalForm()+'/apex/VIPERCustomerPortalPage?Id='+marketingPlanRec.Id + '\">' + URL.getSalesforceBaseUrl().toExternalForm()+'/secur/login_portal.jsp?orgId='+UserInfo.getOrganizationId()+'&portalId=060A0000000PiLr&startURL='+URL.getSalesforceBaseUrl().toExternalForm()+'/apex/VIPERCustomerPortalPage?Id='+marketingPlanRec.Id  + '</a>';
    
                    //bodyOfEmail=bodyOfEmail+'<br/><br/> <b>DELL internal users please visit this Link:</b> <a href=\"'+' '+  URL.getSalesforceBaseUrl().toExternalForm()+'/'+marketingPlanRec.Id + '\">' + URL.getSalesforceBaseUrl().toExternalForm()+'/'+marketingPlanRec.Id  + '</a>';
                    
                    mail.setToAddresses(ToAddresses);
                    mail.setPlainTextBody('Approval Required');
                    mail.setHTMLBody(bodyOfEmail);
                    mail.setSubject('Require Vendor Approval');
                    system.debug('mail###r'+mail);
                    Messaging.SendEmailResult [] r =
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
                    system.debug('toAddresses###r'+r);                    
                }
                if(toAddress.size()!=0){
                for(string strUserId:toAddress.keyset()){ 
                        //bodyOfEmail2='Hi '+toAddress.get(strUserId)+'<br></br>'; 
                        bodyOfEmail2=strPartnerConNames+'<br></br>'; //4.1 --Removed addressing to Product Managers and updated with address to Partner Account 
                        bodyOfEmail2=bodyOfEmail2+'<b>'+marketingPlanRec.Vendor__r.name+':  '+marketingPlanRec.Fiscal_Quarter__c+':  '+marketingPlanRec.name+'     Review Request</b><br></br>'+ //4.0
                        +marketingPlanRec.Owner.name+', of Dell S&P Co-Marketing, has sent you the below marketing plan for your consideration. Follow the link to '+
                        'review the marketing programs within your plan.  Approved program(s) will be included in the final version of your plan. Upon receiving your selections, '+
                        'a Statement Of Work will be provided separately for your signature. <br></br>';
        
                        bodyOfEmail2=bodyOfEmail2+' Marketing Plan Name: '+marketingPlanRec.name+'<br/><br/>'; //4.0
        
                        bodyOfEmail2=bodyOfEmail2+'<b>Partner Portal Link:</b> <a href=\" '+' '+URL.getSalesforceBaseUrl().toExternalForm()+'/secur/login_portal.jsp?orgId='+UserInfo.getOrganizationId()+'&portalId=060A0000000PiLr&startURL='+URL.getSalesforceBaseUrl().toExternalForm()+'/apex/VIPERCustomerPortalPage?Id='+marketingPlanRec.Id + '\">' + URL.getSalesforceBaseUrl().toExternalForm()+'/secur/login_portal.jsp?orgId='+UserInfo.getOrganizationId()+'&portalId=060A0000000PiLr&startURL='+URL.getSalesforceBaseUrl().toExternalForm()+'/apex/VIPERCustomerPortalPage?Id='+marketingPlanRec.Id  + '</a>';
        
                        //bodyOfEmail2=bodyOfEmail2+'<br/><br/> <b>DELL internal users please visit this Link:</b> <a href=\"'+' '+  URL.getSalesforceBaseUrl().toExternalForm()+'/'+marketingPlanRec.Id + '\">' + URL.getSalesforceBaseUrl().toExternalForm()+'/'+marketingPlanRec.Id  + '</a>';
                        
                        //add new line by sharad for viper story : 3963683 
                        bodyOfEmail2=bodyOfEmail2+'<br/><br/> <b>Product Managers </b> - Please note, you have no action at this time. You are copied on the message to the partner for visibility.';
                        
                        Messaging.SingleEmailMessage mailobj = new Messaging.SingleEmailMessage();
                        system.debug('strUserId###'+toAddress.get(strUserId));                       
                        mailobj.setTargetObjectId(strUserId);
                        mailobj.setPlainTextBody('Approval Required');
                        mailobj.setHTMLBody(bodyOfEmail2);
                        mailobj.setsaveAsActivity(false);
                        mailobj.setSubject('Require Vendor Approval');
                        allmsg.add(mailobj);
                        
                    }
                    Messaging.sendEmail(allmsg,false);
                    system.debug('allmsg###'+allmsg);
                }

                //Updating status of marketing plan to 'Submitted for Review' if its curent status is pending

                if(marketingPlanRec.Contract_Status__c=='Pending'){
                    marketingPlan.Contract_Status__c='Submitted for Review';
                }
                update marketingPlan;

                for(Associated_Programs_Vendors__c apvRec:[select id,name,vendor__c,package__c,Status__c,Contract_Status_Reason__c  from Associated_Programs_Vendors__c where vendor__c=:marketingPlanRec.vendor__c and Marketing_Plan__c=:marketingPlanRec.id]){

                    if(apvRec.status__c=='Pending' && apvRec.Contract_Status_Reason__c!='Declined by Product Manager'){
                        apvRec.status__c='Submitted for Review';
                    }

                    if(apvRec.package__c!=null){
                        pkgIdSet.add(apvRec.package__c);
                    }
                    if(pdtMGRContacts.size()>0){
                        for(integer i=0;i<pdtMGRContacts.size();i++){
                            if(pdtMGRContacts[i].selected==true){
                               if(i==0){
                                   apvRec.Product_Manager_1email_Id__c=pdtMGRContacts[i].pdtMgrAC.MDF_Contact__r.Email__c;
                               }
                               if(i==1){
                                   apvRec.Product_Manager_2email_Id__c=pdtMGRContacts[i].pdtMgrAC.MDF_Contact__r.Email__c;
                               }
                               if(i==2){
                                   apvRec.Product_Manager_3email_Id__c=pdtMGRContacts[i].pdtMgrAC.MDF_Contact__r.Email__c;
                               }
                            }
                        }
                    }
                    apvUpdateList.add(apvRec);
                }
                if(apvUpdateList.size()>0){
                    update apvUpdateList;
                }
                for(Package__c pkgRec:[select id,Status__c,Marketing_Plan__c from Package__c where Marketing_Plan__c=:marketingPlanRec.id and id in:pkgIdSet]){

                    if(pkgRec.status__c=='Pending'){
                        pkgRec.status__c='Submitted for Review';
                    }
                    pkgUpdateList.add(pkgRec);
                }
                if(pkgUpdateList.size()>0){
                    update pkgUpdateList;
                }

                retStr=new PageReference('/'+marketingPlanRec.Id);
                return retStr;
            }
        }catch(Exception e){
        }
        return retStr;
    }

    /********CR 6285************************************/

    public List<AttachmentWrapperCls> getAttachmentList(){
        return attachmentIteratedList;
    }
    public  void setAttachmentList(List<AttachmentWrapperCls> recList){
        this.attachmentIteratedList=recList;
    }

    public Boolean getSignSOW(){
        return signSOW;
    }
    public  void setSignSOW(Boolean Bol){
        this.signSOW=Bol;
    }
    public Boolean getAttachmentErr(){
        return attachmentErr;
    }

    public PageReference sendSignedSOW(){
        Attachment selectedRecords;
        List<Attachment> SendAttachmentList = New List<Attachment>();
        String[] toAddresses=new List<String>();
        Set<Id> AttachmentIDset=new Set<Id>();
        PageReference  retStr=new PageReference('/'+marketingPlanRec.Id);

        for(AttachmentWrapperCls elt:attachmentIteratedList){
            if(elt.selected==true){
                AttachmentIDset.add(elt.AttachmentRecord.Id);
            }
        }
        System.debug('###attachmentIteratedList'+attachmentIteratedList);
        for(Attachment AList : [select Id,Name,body,contentType,ParentId,bodylength from Attachment where Id in: AttachmentIDset]){
            selectedRecords = new Attachment();
            selectedRecords.Name = AList.Name;
            selectedRecords.contentType = AList.contentType;
            selectedRecords.body= AList.body;
            SendAttachmentList.add(selectedRecords);
        }
        String emailId;
        for(productManager elt:pdtMGRContacts){
            if(elt.selected==true){
                emailId=contactMap.get(elt.pdtMgrAC.Id).MDF_Contact__r.Email__c;
                toAddresses.add(emailId);
            }
        }
        if(toAddresses.size()==0 || SendAttachmentList.size()==0){
            ApexPages.Message msg;
            msg = new ApexPages.Message(ApexPages.severity.FATAL,'Error: To continue, please select attachment and product manager.');
            ApexPages.addMessage(msg);
            return null;
        }else{
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);
            mail.setSubject('Signed SOW');
            mail.setHtmlBody('Signed SOW is atatched with this email');
            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
            for(Attachment attachmntselectedlist : SendAttachmentList){
                Messaging.EmailFileAttachment fileAttachment = new Messaging.EmailFileAttachment();
                fileAttachment.setBody(attachmntselectedlist.body);
                fileAttachment.setFileName(attachmntselectedlist.name);
                fileAttachments.add(fileAttachment);
            }
            mail.setFileAttachments(fileAttachments);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        }


        return retStr;
    }

     //Cr 6285 end

     /******************CR 6297*******************************************/


     public Boolean getApproval(){
            return approval;
     }
    public  void setApproval(Boolean Bol){
        this.approval=Bol;
    }

    public Task getTask(){
        return reviewTask;
    }
    public  void setTask(Task tsk){
        this.reviewTask=tsk;
    }

     public PageReference sendForProductManagerApproval(){
         Task pmTask;
         String PMNames;
         Map<String,String> toAddresses=new Map<String,String>();
         PageReference  retStr=new PageReference('/'+marketingPlanRec.Id);
         Marketing_Plan__c marketingPlan=new Marketing_Plan__c(id=marketingPlanRec.id);
         
        String emailId;
         System.Debug('pdtMGRContacts###'+pdtMGRContacts);
         for(productManager elt:pdtMGRContacts){
            if(elt.selected==true){
                pmTask=new Task();
                pmTask.Status='In Progress';
                pmTask.Subject='Review APVs of'+marketingPlanRec.Name;
                pmTask.ActivityDate=System.Today()+5;
                pmTask.Priority='High';
                pmTask.OwnerId=contactMap.get(elt.pdtMgrAC.Id).MDF_Contact__r.User__c;
                pmTask.Type='Internal Email';
                taskList.add(pmTask);
                //emailId=contactMap.get(elt.pdtMgrAC.Id).MDF_Contact__r.Email__c;
                if(elt.pdtMgrAC.MDF_Contact__r.User__c != null){
                    toAddresses.put(contactMap.get(elt.pdtMgrAC.Id).MDF_Contact__r.User__c,contactMap.get(elt.pdtMgrAC.Id).MDF_Contact__r.User__r.Name);
                }
                
            }
        }
        System.Debug('toAddresses###'+toAddresses);

        if(toAddresses.size()==0){
            ApexPages.Message msg;
            msg = new ApexPages.Message(ApexPages.severity.FATAL,'Error: To continue, please select a product manager as recipient.');
            ApexPages.addMessage(msg);
            return null;
        }else{
           /*
            bodyOfEmail=bodyOfEmail+'<br/>';
            bodyOfEmail=bodyOfEmail+' '+marketingPlanRec.Owner.name+' has sent you the proposed marketing programs for review and requests your feedback';
            bodyOfEmail=bodyOfEmail+'Follow the link to review the proposed marketing programs.For programs you wish to decline please update the program status to <b>Declined / Declined by PM</b>.';
            bodyOfEmail=bodyOfEmail+'For programs you wish to keep, you do not need to make any changesPlease select <b>Save PM Review</b> to save your changes and complete your review. ';
            bodyOfEmail=bodyOfEmail+'save your changes and complete your review.  Upon receiving your selections , the marketing plan will be sent to the Partner for review.';
            bodyOfEmail=bodyOfEmail+'<br/><br/>';
            bodyOfEmail=bodyOfEmail+'Partner: '+marketingPlanRec.Vendor__r.name+'<br/>';
            bodyOfEmail=bodyOfEmail+'Fiscal Quarter: '+marketingPlanRec.Fiscal_quarter__c+'<br/>';
            bodyOfEmail=bodyOfEmail+'Region:'+ marketingPlanRec.region__c+'<br/>';
            bodyOfEmail=bodyOfEmail+'Sub-Region:'+ marketingPlanRec.sub_region__c+'<br/>';  */
            //bodyOfEmail=bodyOfEmail+'Country: '+marketingPlanRec.

            //bodyOfEmail=bodyOfEmail+' <b>Link to marketing plan and link to all APV\'s based on above criteria:</b> '+ URL.getSalesforceBaseUrl().toExternalForm()+'/apex/APVProductManagerApproval?Id='+ marketingPlanRec.Id;
            List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
            for(String strUserId:toAddresses.keyset()){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String bodyOfEmail='Hi'+' ';
            bodyOfEmail=bodyOfEmail+toAddresses.get(strUserId)+',';
            bodyOfEmail=bodyOfEmail+'<br/>';
            bodyOfEmail=bodyOfEmail+'Please review this marketing plan and approve or decline each program:<br/><br/>';
            bodyOfEmail=bodyOfEmail+'<a href=\" '+' '+URL.getSalesforceBaseUrl().toExternalForm()+'/apex/APVProductManagerApproval?Id='+ marketingPlanRec.Id+ '\">'+URL.getSalesforceBaseUrl().toExternalForm()+'/apex/APVProductManagerApproval?Id='+ marketingPlanRec.Id+ '</a>'+'<br/><br/>';
            //bodyOfEmail=bodyOfEmail+URL.getSalesforceBaseUrl().toExternalForm();
            //bodyOfEmail=bodyOfEmail+'<b>Link:</b> <a href=\" '+' '+URL.getSalesforceBaseUrl().toExternalForm()+'/secur/login_portal.jsp?orgId='+UserInfo.getOrganizationId()+'&portalId=060A0000000PiLr&startURL='+URL.getSalesforceBaseUrl().toExternalForm()+'/apex/VIPERCustomerPortalPage?Id='+marketingPlanRec.Id + '\">' + URL.getSalesforceBaseUrl().toExternalForm()+'/secur/login_portal.jsp?orgId='+UserInfo.getOrganizationId()+'&portalId=060A0000000PiLr&startURL='+URL.getSalesforceBaseUrl().toExternalForm()+'/apex/VIPERCustomerPortalPage?Id='+marketingPlanRec.Id  + '</a>';
            bodyOfEmail=bodyOfEmail+'Thank You';
            mail.setTargetObjectId(strUserId);
            mail.setPlainTextBody('Approval Required');
            mail.setHTMLBody(bodyOfEmail);
            mail.setsaveAsActivity(false);
            mail.setSubject(marketingPlanRec.name+' Requires Your Approval');
            allmsg.add(mail);
            }
            //Messaging.SendEmailResult [] r =Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
            Messaging.sendEmail(allmsg,false);  

            marketingPlan.Product_Manager_Approval_Status__c='Submitted for Product Manager\'s Review';
            update marketingPlan;
        }
        if(taskList.size()>0){
            insert taskList;
        }
        return retStr;
     }
}