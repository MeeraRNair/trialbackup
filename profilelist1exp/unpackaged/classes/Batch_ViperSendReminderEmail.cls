/*
* Author   : Niveda Jeyaseelan
* Purpose  : To Send Viper reminder emails for approval
* Ref Number :  CR 17969 
* Release No : FY20-1002      
* Revision Ref Number  Release No      Date            Modified By     Description
* -------- ----------  ----------      -----------     ------------    -----------
* 
*/
global class Batch_ViperSendReminderEmail implements Database.Batchable<sObject> {
     global String strQuery;
     
    global Database.QueryLocator start(Database.BatchableContext bc) {
                return Database.getQueryLocator(strQuery);
    }

    global void execute(Database.BatchableContext bc, list<Marketing_Plan__c> listMktPlans) {
        List<Messaging.SingleEmailMessage> listEmailMsg = new List<Messaging.SingleEmailMessage>();
        Set<String> setToAddress = new Set<String>();
        Map<id,List<String>> mapPlanApprover = new Map<id,List<String>>();
        Map<String,String> mapUser= new Map<String,String> ();
        
        
        for(Marketing_Plan__c objMktPlan: listMktPlans){
            if(objMktPlan.Review_Sent_To_Email__c != null){
                String[] listAddr = objMktPlan.Review_Sent_To_Email__c.split(',');
                setToAddress.addAll(listAddr);
                mapPlanApprover.put(objMktPlan.id,listAddr);
            }           
        }
        
        if(setToAddress != null){
            for (User objUser: [Select id, Email from User where email in: setToAddress]){
                mapUser.put(objUser.Email,objUser.id);
            }
        }
 
        for(Marketing_Plan__c objMktPlan: listMktPlans){
           
            String strAddressedTo = '';
            String strSubject = 'Reminder – Require Vendor Approval – '+objMktPlan.Vendor__r.name+'-  '+objMktPlan.Fiscal_Quarter__c+'-  '+objMktPlan.name;
            
            String[] listAddrTo = objMktPlan.Review_Sent_To_Vendor__c.split(',');
            
            for(String str: listAddrTo){
                  if(!str.contains('@') && !str.equals(objMktPlan.Product_Manager__c)){                  
                    strAddressedTo = strAddressedTo + str +', ';
                  }               
            } 
                   
            String strBodyOfEmail ='Hi '+strAddressedTo+'<br></br>';
           
        
            strBodyOfEmail =strBodyOfEmail +'<b>'+objMktPlan.Vendor__r.name+':  '+objMktPlan.Fiscal_Quarter__c+':  '+objMktPlan.name+' Review Request Reminder</b><br></br>'+ 
                    +'This is a reminder that '+objMktPlan.Owner.name+', of Dell S&P Co-Marketing, has sent you the below marketing plan for your consideration. Follow the link to '+
                    'review the marketing programs within your plan.  Approved program(s) will be included in the final version of your plan. Upon receiving your selections, '+
                    'a Statement Of Work will be provided separately for your signature. <br></br>';
    
            strBodyOfEmail =strBodyOfEmail +' Marketing Plan Name: '+objMktPlan.name+'<br/><br/>'; //4.0

            strBodyOfEmail =strBodyOfEmail +'<b>Partner Portal Link:</b> <a href=\" '+' '+URL.getSalesforceBaseUrl().toExternalForm()+'/secur/login_portal.jsp?orgId='+UserInfo.getOrganizationId()+'&portalId=060A0000000PiLr&startURL='+URL.getSalesforceBaseUrl().toExternalForm()+'/apex/VIPERCustomerPortalPage?Id='+objMktPlan.Id + '\">' + URL.getSalesforceBaseUrl().toExternalForm()+'/secur/login_portal.jsp?orgId='+UserInfo.getOrganizationId()+'&portalId=060A0000000PiLr&startURL='+URL.getSalesforceBaseUrl().toExternalForm()+'/apex/VIPERCustomerPortalPage?Id='+objMktPlan.Id  + '</a>';

            //strBodyOfEmail =strBodyOfEmail +'<br/><br/> <b>DELL internal users please visit this Link:</b> <a href=\"'+' '+  URL.getSalesforceBaseUrl().toExternalForm()+'/'+objMktPlan.Id + '\">' + URL.getSalesforceBaseUrl().toExternalForm()+'/'+objMktPlan.Id  + '</a>';
            
            strBodyOfEmail =strBodyOfEmail +'<br/><br/> <b>Product Managers </b> - Please note, you have no action at this time. You are copied on the message to the partner for visibility.';
         
            for(String strEmail: mapPlanApprover.get(objMktPlan.id)){
                Messaging.SingleEmailMessage objMail = new Messaging.SingleEmailMessage();
                objMail.setsaveAsActivity(false);
                objMail.setSubject(strSubject);
                objMail.setHtmlBody(strBodyOfEmail);
                if(mapUser.containsKey(strEmail)){
                    objMail.setTargetObjectId(mapUser.get(strEmail));
                }
                else{
                    list<String> listTo = new List<String>();
                    listTo.add(strEmail);
                    objMail.setToAddresses(listTo);
                }  
                listEmailMsg.add(objMail);             
            }           
            
        }
        if(listEmailMsg != null && listEmailMsg.size() >0)
        {
            List<Messaging.SendEmailResult> listSendResult = Messaging.sendEmail(listEmailMsg,false);
            if ((listSendResult != null) && (listSendResult.size() > 0)) {
                string strErrorMsg = '';
                for(Messaging.SendEmailResult result : listSendResult) {
                    if(!result.isSuccess()){
                    
                        system.debug('****result***'+ result.getErrors() );
                        /*List<Messaging.SendEmailError> listErrors = result.getErrors();
                        if((listErrors != null) && (listErrors.size() > 0)){
                            for (Messaging.SendEmailError error : listErrors){
                                strErrorMsg = strErrorMsg + '[' + error.getStatusCode() + ' - ' + error.getMessage() + '] ';
                                system.debug('****strErrorMsg ***'+ strErrorMsg );
                            }
                        }*/
                    }
                }
            }
        }
        
    }

     global void finish(Database.BatchableContext bc){      
     }  
}