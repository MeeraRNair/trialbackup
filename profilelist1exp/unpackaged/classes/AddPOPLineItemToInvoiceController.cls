public class AddPOPLineItemToInvoiceController{
    
    Invoice__c InvoiceVar=new Invoice__c(); 
    List<POP_Line_Item__c> popLineItemList=new List<POP_Line_Item__c>();
    List<POP_Line_Item__c> popLnItemDisplay=new List<POP_Line_Item__c>(); 
    Boolean msg=false;
    Boolean popMsg=false;
    List<Partner> mdfContacts=new List<Partner>();
    List<String> mplanName=new List<String>();
    Map<Id,MDF_Associated_Contact__c> contactMap=new Map<Id,MDF_Associated_Contact__c>();
    String emailTxt;
    
     public class Partner{
        public Boolean selected{get; set;}
        public MDF_Associated_Contact__c partner{get; set;}        
        public Partner(Boolean bol,MDF_Associated_Contact__c mdfAC){
            selected=bol;
            partner=mdfAC;
        }
    }
    
    
    public AddPOPLineItemToInvoiceController(ApexPages.StandardController controller){
        Id InvoiceId=controller.getId();
        POP_Line_Item__c popLnItem;
        //popLineItemList=new List<POP_Line_Item__c>(); 
        Set<Id> marketingPlanIds=new Set<Id>();
        Set<Id> programIds=new Set<Id>();
        //mdfContacts=new List<Partner>();
        InvoiceVar=[select Vendor__c,Vendor__r.name,Sub_Region__c,Region__c,Business_Segment__c,Contract_Type__c,Country__c,Fiscal_Quarter__c from Invoice__c where id=:InvoiceId];
        
         System.debug('###InvoiceVar'+InvoiceVar);            
        for(Marketing_Plan__c mplan:[Select Id,name,Contract_Status__c from marketing_plan__c where invoice__c=:InvoiceId and vendor__c=:InvoiceVar.Vendor__c and Contract_Status__c='Signed']){
            marketingPlanIds.add(mplan.Id);
            mplanName.add(mplan.name);
        }
         System.debug('###marketingPlanIds'+marketingPlanIds); 
        for(Associated_Programs_Vendors__c apv:[Select Id,MDF_Program__c,marketing_plan__c,POP_Status__c,vendor__c from Associated_Programs_Vendors__c where marketing_plan__c in:marketingPlanIds and Status__c='Signed' and POP_Status__c='Executed' and vendor__c=:InvoiceVar.Vendor__c]){
            programIds.add(apv.MDF_Program__c);
        } 
        
         System.debug('###programIds'+programIds);           
        for(POP_Line_Item__c lnItemElt:[SELECT Id,Proof_of_Performance_POP__c,Proof_of_Performance_POP__r.Fiscal_Quarter__c,Proof_of_Performance_POP__r.Region__c,Vendor__c,Invoice__c,POP_Submission_Status__c,Proof_of_Performance_POP__r.MDF_Program__c,Business_Segment__c  
                                        FROM POP_Line_Item__c WHERE
                                        Proof_of_Performance_POP__r.MDF_Program__c in:programIds AND
                                        Invoice__c=null AND POP_Submission_Status__c='Approved' AND Vendor__r.Partner_Status__c='Active' AND Vendor__c=:InvoiceVar.Vendor__c]){            
            
            System.debug('###lnItemElt'+lnItemElt); 
            
            popLnItem=new POP_Line_Item__c(Id=lnItemElt.Id,Invoice__c=InvoiceVar.Id); 
            popLineItemList.add(popLnItem);            
        }  
        
        System.debug('###popLineItemList'+popLineItemList);       
        for(MDF_Associated_Contact__c mdfAC:[select MDF_Contact__c,vendor__c,MDF_Contact__r.Partner_Contact_Type__c ,
                                                MDF_Contact__r.Email__c,MDF_Contact__r.name,MDF_Contact__r.recordtype.name,MDF_Contact__r.User__c 
                                                from MDF_Associated_Contact__c where vendor__c=:InvoiceVar.Vendor__c and MDF_Contact__r.recordtype.name='Partner Contact']){
            mdfContacts.add(new Partner(false,mdfAC));            
            contactMap.put(mdfAC.Id,mdfAC);
        }
        if(mdfContacts.size()==0){
            msg=true;
        }

     } 
     
     public List<POP_Line_Item__c> getPopLineItemList(){
         return popLnItemDisplay;
     }
     
     public Boolean getMessage(){
         return msg;
     }
     public Boolean getPOPMessage(){
         return popMsg;
     }
     public List<Partner> getPartner(){
         return mdfContacts;
     }
     public void setPartner(List<Partner> pList){
         this.mdfContacts=pList;
     } 
     public String getEmailTxt(){
         return emailTxt;
     }
     public void setEmailTxt(String str){
         this.emailTxt=str;
     }    
     public void AddPOPLineItemToInvoice(){
     //try{
         if(popLineItemList.size()>0){
             update popLineItemList; 
         }
         for(POP_Line_Item__c lnItemElt:[SELECT Id,Name,Proof_of_Performance_POP__c,Proof_of_Performance_POP__r.Fiscal_Quarter__c,Proof_of_Performance_POP__r.Region__c,Vendor__c,Invoice__c,POP_Submission_Status__c,Proof_of_Performance_POP__r.MDF_Program__c,Business_Segment__c,
         Proof_of_Performance_POP__r.MDF_Program__r.name,Proof_of_Performance_POP__r.name FROM POP_Line_Item__c WHERE  Invoice__c=:InvoiceVar.Id]){          
             
            popLnItemDisplay.add(lnItemElt);            
        } 
        if(popLnItemDisplay.size()==0){
            popMsg=true;
        }
        //}Catch(Exception e){
            //System.debug('Exception'+e);
        //}
         
     }
     public PageReference sendToPartner(){
         Task pmTask;
         String bodyOfEmail='Dear '+InvoiceVar.Vendor__r.name+' -'+' ';
         String[] toAddresses=new List<String>(); 
         PageReference  retStr=new PageReference('/'+InvoiceVar.Id);         
         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
         String emailId;
         String[] emailArr=new List<String>();
         String Partnername;
         try{
             
         if(emailTxt!='Enter emailId'&& emailTxt.contains(';')){
             emailArr=emailTxt.split(';');
         }
         for(Partner elt:mdfContacts){
            if(elt.selected==true){
                emailId=contactMap.get(elt.partner.Id).MDF_Contact__r.Email__c;
                Partnername=contactMap.get(elt.partner.Id).MDF_Contact__r.name;
                toAddresses.add(emailId);              
                bodyOfEmail=bodyOfEmail+Partnername+',';
            }
        }
        if(emailArr.size()>0){
            for(String str:emailArr){
                bodyOfEmail=bodyOfEmail+str.split('@')[0]+',';
                toAddresses.add(str);
            }
        }
        if(emailTxt!='Enter emailId'&& !emailTxt.contains(';') && emailTxt!=''){
             bodyOfEmail=bodyOfEmail+emailTxt.split('@')[0]+',';
             toAddresses.add(emailTxt);
         }
        
        if(toAddresses.size()==0){
            ApexPages.Message msg;     
            msg = new ApexPages.Message(ApexPages.severity.FATAL,'Error: To continue, please select a partner or enter emailId as recipient.');
            ApexPages.addMessage(msg);
            return null;
        }else{
        // Modification done by preeti sharma for cr7644 for monthly maintainance sprint1
            bodyOfEmail=bodyOfEmail+'<br/><br/> Thank you for your collaboration with Dell S&P Co-Marketing. Your '+ InvoiceVar.Fiscal_Quarter__c+' invoice(s) and proof of performance';
            bodyOfEmail=bodyOfEmail+' '+'documentation are ready for your review. Please check the documentation for accuracy and reply within one week with any questions or concerns. If there is no response within one week, Dell will assume you agree that the invoice and supporting documentation are accurate. As this is the only notification of the invoice(s)';
            bodyOfEmail=bodyOfEmail+' '+ 'that will be sent, please submit to your Accounts Payable team. Payment terms are indicated on the invoice. ';
            bodyOfEmail=bodyOfEmail+ '<br/><br/>You may view these documents at this link:<br/>' + URL.getSalesforceBaseUrl().toExternalForm()+ '/secur/login_portal.jsp?orgId='+ UserInfo.getOrganizationId()+'&portalId=060A0000000PiLr&startURL='+URL.getSalesforceBaseUrl().toExternalForm()+'/'+InvoiceVar.Id;
            //bodyOfEmail=bodyOfEmail+ '<br/>';
            
            bodyOfEmail=bodyOfEmail+ '<br/><br/>Dell | Software & Peripherals Co-Marketing<br/><br/>';
        /*  for(String str:mplanName){
                bodyOfEmail=bodyOfEmail+str+'<br/>';
            } 
            bodyOfEmail=bodyOfEmail+'<br/>----------------------------------------(end template)----------------------------------------------------------<br/>';
        */
            list<OrgWideEmailAddress> lstOrgWideAddresses = [select Id, DisplayName from OrgWideEmailAddress where DisplayName =:Label.OWA_Address];            
            mail.setOrgWideEmailAddressId(lstOrgWideAddresses[0].id);
            mail.setToAddresses(toAddresses);
            mail.setPlainTextBody('Invoice and POP attachments');
            mail.setHTMLBody(bodyOfEmail);
            mail.setSubject(InvoiceVar.Vendor__r.name+' | '+'Dell'+' '+ InvoiceVar.Fiscal_Quarter__c +' '+ 'S&P Co-Marketing Invoicing Materials');
            Messaging.SendEmailResult [] r =
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        }    
      }Catch(Exception e){
            ApexPages.Message msg;     
            msg = new ApexPages.Message(ApexPages.severity.FATAL,'Please enter a valid email address.');
            ApexPages.addMessage(msg);
            return null;
         }
             
        return retStr;                  
     }

}