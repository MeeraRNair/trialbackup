public class SendAttendeesInviteCtrlExt{
    
    Customer_Engagement__c customerEngagement = new Customer_Engagement__c();
    List<Attending_Accounts__c> attendingAccntLst = new List<Attending_Accounts__c>(); 
    List<Attendees__c> attendeesList = new List<Attendees__c>();
    List<Attendees__c> attendeesToList = new List<Attendees__c>();
    List<Attendees__c> attendeeCustList = new List<Attendees__c>();
    List<Attendees__c> attendeeAccTeamList = new List<Attendees__c>();
    List<Attendees__c> attendeeVendorList = new List<Attendees__c>();
    List<Attendees__c> attendeeDellIntList = new List<Attendees__c>();
    List<Attendees__c> attendeeCustExtList = new List<Attendees__c>();     
    List<Attendees__c> attendeeCustomerList=new List<Attendees__c>();
    List<Contact> custContactList = new List<Contact>();
    String timeZoneStr = ' ';    
    String emailMessage; 
    string dateofCEEventStr;
    Date startEventDate,endEventDate;
    String fileName; 
    public String email {get;set;}
    public String ccemail {get;set;}
    public boolean nullEmail {get; set;}
    string site; string Analyst;
    String[] toAddresses;
    List<String> toEmailList;
    public boolean showMessage;
    public boolean showInvite;
    String comments;
    String event;
    String subjectLineStr;
    String analystEmailStr;
    String eventStartDate;
    String eventEndDate;
    public boolean invalidEmail {get; set;}  
    public boolean invalidCCEmail {get; set;} 
    String userTimeZone; 
    Boolean oldAttendeeFlag = FALSE;
    Map<String,List<Attendees__c>>custAttendeeMap = new Map<String,List<Attendees__c>>();
    Map<String,List<Attendees__c>>accTeamAttendeeMap = new Map<String,List<Attendees__c>>();

    public SendAttendeesInviteCtrlExt(ApexPages.StandardController controller){
        
        String attCustListStr;
        String attExtrnlCustListStr;
        String attAccTeamCustListStr;
        String attDellIntCustListStr;
        String attVendorCustListStr;
       
        Boolean controlFlag = true;
        Set<ID> attIdList = new Set<ID>();
        Set<String> eventStatusEBC = new Set<String>{'Pending','Requested','Canceled','Waitlisted','Scheduled'};
        Set<String> eventStatusDSC = new Set<String>{'Pending','Rejected','Canceled'};
        User userObject = new User();
        showMessage = false;
        showInvite = true;
        invalidEmail = FALSE;
        invalidCCEmail = false;

        try{

            customerEngagement = [select id,name,RecordTypeId,Start_DateF__c,End_DateF__c,GSL_Start_Date__c,GSL_End_Date__c,Event_Status__c,
                                OwnerId,Owner.name,Owner.email,Event_TypeF__c,Primary_Account__c,Primary_Account__r.name,Event_Type__c,
                                SiteF__c,Dell_Solution_Center_Site__c,Dell_Solution_Center_Site__r.Name,Operations_Analyst__c,Operations_Analyst__r.email from Customer_Engagement__c
                                where id =: controller.getId()];

            if(customerEngagement.RecordTypeId == IdLookupUtils.getRecordTypeId('Executive Briefing Center','Customer_Engagement__c',true)){
                startEventDate = customerEngagement.Start_DateF__c;
                endEventDate = customerEngagement.End_DateF__c;
                site = customerEngagement.SiteF__c;
                analystEmailStr = customerEngagement.Owner.email;
                event = customerEngagement.Event_TypeF__c;
                subjectLineStr= 'INVITE ATTACHED: Briefing ';
                if(eventStatusEBC.contains(customerEngagement.Event_Status__c)){
                    showError('Cannot send the invite as Customer Engagement record event status is \''+customerEngagement.Event_Status__c+'\'. Click on \'Cancel\' to go back.');  
                    controlFlag = false;
                }   
            }
            else{
                startEventDate = customerEngagement.GSL_Start_Date__c;
                endEventDate = customerEngagement.GSL_End_Date__c;
                site = customerEngagement.Dell_Solution_Center_Site__r.Name;
                event = customerEngagement.Event_Type__c;
                subjectLineStr= 'INVITE ATTACHED: Solution ';
                if(customerEngagement.Operations_Analyst__r.email != null){
                    analystEmailStr = customerEngagement.Operations_Analyst__r.email;
                }
                else{
                    showError('Please assign an Operations Analyst to the Customer Engagement Record. Click on \'Cancel\' to go back.');  
                    controlFlag = false;
                }
                if(eventStatusDSC.contains(customerEngagement.Event_Status__c)){
                    showError('Cannot send the invite as Customer Engagement record event status is \''+customerEngagement.Event_Status__c+'\'. Click on \'Cancel\' to go back.');  
                    controlFlag = false;
                } 
            }
        }catch(Exception e){
            System.debug('Exception Occured:'+e);
        }
        
        if(controlFlag != false) {
            try{
                if(customerEngagement.RecordTypeId == IdLookupUtils.getRecordTypeId('Executive Briefing Center','Customer_Engagement__c',true)){
                    userObject = [select id,TimeZoneSidKey,LocaleSidKey,SystemModstamp from User where id =: customerEngagement.OwnerId];
                }
                else{
                    userObject = [select id,TimeZoneSidKey,LocaleSidKey,SystemModstamp from User where id =: customerEngagement.Operations_Analyst__r.id];  
                }
                Map<String, Schema.SObjectField> field_map = Schema.SObjectType.User.fields.getMap();
                List<Schema.PicklistEntry> pick_list_values = field_map.get('TimeZoneSidKey').getDescribe().getPickListValues(); 

                for(Schema.PicklistEntry ple:pick_list_values){
                    if(ple.getValue() == userObject.TimeZoneSidKey){
                        timeZoneStr = ple.getLabel();
                        userTimeZone = ple.getValue();
                    }
                }
            }Catch(Exception e){
              showError('Request is not yet assigned to Analyst.Please get an Analyst assigned. Click on \'Cancel\' to go back.');     
            }

            if(timeZoneStr != ' '){
                try{
                    for(Attending_Accounts__c attAccount:[select id,Customer_Engagement__c,name,Account__r.name from Attending_Accounts__c  
                                                            where Customer_Engagement__c =: customerEngagement.Id]){
                        attendingAccntLst.add(attAccount);
                    }
                    for(Attendees__c attendee:[select id,name,Attendee_Name__c,Customer_Engagement__c,recordTypeId,Email__c,Agenda_Topic__c,
                                                recordType.name,Customer_Attendee__c ,Role__c,Account_Name__c from Attendees__c 
                                                where Customer_Engagement__c =: customerEngagement.Id]){
                        attendeesList.add(attendee);
                        attIdList.add(attendee.Customer_Attendee__c);
                            if(attendee.Email__c != null){
                                attendeesToList.add(attendee);
                                if(email == null){
                                    email = attendee.Email__c;
                                }else{
                                    email = email+';'+attendee.Email__c;
                                }
                            }
                    }
                }catch(Exception e){
                    System.debug('Exception Occured:'+e);
                }    
                if(AttendeesToList.size() == 0){
                    showError('Either presenter do not have an E-mail ID or presenter not assigned to Agenda Topic. Click on \'Cancel\' to go back.');  
                    controlFlag = false;
                } 
                if(controlFlag != false){
                    ccemail = analystEmailStr+';'; 
                    attendeeSort();      
                    dateRange();
                    subjectLineStr=subjectLineStr+'Center Request for '+customerEngagement.name+' on '+dateofCEEventStr;
                if(oldAttendeeFlag == TRUE){
                /*
                for(Attendees__c attCusTemp:attendeeCustomerList){
                            attCustListStr=attCustListStr+attCusTemp.Attendee_Name__c+((attCusTemp.Role__c==null)?' ':', '+attCusTemp.Role__c)+'<br/>';
                        }  
                        for(Attendees__c attaccTemp:attendeeAccTeamList){
                            attAccTeamCustListStr=attAccTeamCustListStr+attaccTemp.Attendee_Name__c+((attaccTemp.Role__c==null)?' ':', '+attaccTemp.Role__c)+'<br/>';
                        }
                */
                        //Defect ID : 71875
                        for(Attendees__c attCusTemp:attendeeCustomerList){
                            if(attCustListStr == null){
                                attCustListStr = attCusTemp.Attendee_Name__c+((attCusTemp.Role__c==null)?' ':', '+attCusTemp.Role__c)+'<br/>';
                            }else{
                                attCustListStr=attCustListStr+attCusTemp.Attendee_Name__c+((attCusTemp.Role__c==null)?' ':', '+attCusTemp.Role__c)+'<br/>';
                            }
                        }  
                        for(Attendees__c attaccTemp:attendeeAccTeamList){
                            if(attAccTeamCustListStr == null){
                                attAccTeamCustListStr = attaccTemp.Attendee_Name__c+((attaccTemp.Role__c==null)?' ':', '+attaccTemp.Role__c)+'<br/>';
                            }else{
                                attAccTeamCustListStr=attAccTeamCustListStr+attaccTemp.Attendee_Name__c+((attaccTemp.Role__c==null)?' ':', '+attaccTemp.Role__c)+'<br/>';
                            }
                        }
                        //Defect ID : 71875                 
                    }
                    else{
                        List<Attendees__c>custAttendeeList=new List<Attendees__c>();
                        for(String custKey:custAttendeeMap.keySet()){
                            if(custAttendeeMap.get(custKey)!=null){
                                custAttendeeList=new List<Attendees__c>();
                                custAttendeeList=custAttendeeMap.get(custKey);
                                attCustListStr='CUSTOMER COMPANY: '+custKey+'<br/>';
                                for(Attendees__c attTemp:custAttendeeList){        
                                    if(attCustListStr == null){        //Defect ID : 71875 
                                        attCustListStr = attTemp.Attendee_Name__c+((attTemp.Role__c==null)?' ':', '+attTemp.Role__c)+'<br/>';
                                    }else{
                                        attCustListStr = attCustListStr+attTemp.Attendee_Name__c+((attTemp.Role__c==null)?' ':', '+attTemp.Role__c)+'<br/>';
                                    }
                                }
                            }
                       }
                   
                        List<Attendees__c>accTeamAttendeeList=new List<Attendees__c>();
                        for(String accTeamKey:accTeamAttendeeMap.keySet()){
                            if(accTeamAttendeeMap.get(accTeamKey)!=null){
                                accTeamAttendeeList=new List<Attendees__c>();
                                accTeamAttendeeList=accTeamAttendeeMap.get(accTeamKey);
                                attAccTeamCustListStr='CUSTOMER COMPANY: '+accTeamKey+'<br/>';
                                for(Attendees__c accTemp:accTeamAttendeeList){
                                    if(attAccTeamCustListStr == null){        //Defect ID : 71875 
                                        attAccTeamCustListStr = accTemp.Attendee_Name__c+((accTemp.Role__c==null)?' ':', '+accTemp.Role__c)+'<br/>';
                                    }else{
                                        attAccTeamCustListStr = attAccTeamCustListStr+accTemp.Attendee_Name__c+((accTemp.Role__c==null)?' ':', '+accTemp.Role__c)+'<br/>';
                                    }
                                }      
                            }
                        }
                    }

                                                 for(integer i=0;i<attendeeDellIntList.size();i++){
                        if(attDellIntCustListStr == null){
                            attDellIntCustListStr = attendeeDellIntList[i].Attendee_Name__c+((attendeeDellIntList[i].Role__c == null)?' ':', '+attendeeDellIntList[i].Role__c)+'<br/>';
                        }else{
                            attDellIntCustListStr = attDellIntCustListStr+attendeeDellIntList[i].Attendee_Name__c+', '+
                                                  ((attendeeDellIntList[i].Role__c == null)?' ':attendeeDellIntList[i].Role__c)+'<br/>';
                        }
                    }
                    for(integer i=0;i<attendeeVendorList.size();i++){
                        if(attVendorCustListStr == null){
                            attVendorCustListStr = attendeeVendorList[i].Attendee_Name__c+((attendeeVendorList[i].Role__c == null)?' ':', '+attendeeVendorList[i].Role__c)+'<br/>';
                        }else{
                            attVendorCustListStr = attVendorCustListStr+attendeeVendorList[i].Attendee_Name__c+
                                                 ((attendeeVendorList[i].Role__c == null)?' ':', '+attendeeVendorList[i].Role__c)+'<br/>';
                        }
                    }
                    
                    emailMessage = '   You or your Manager have been invited to participate in the upcoming '+customerEngagement.name+'<br/>';
                    emailMessage = emailMessage+' Briefing on ' +dateofCEEventStr+'  in the '+site+'.<br/><br/>';
                    emailMessage = emailMessage+'If you are a calendar manager, please note that you will need to follow these steps: '+'<br/>';
                    emailMessage = emailMessage+'   - Open the attached invite and accept to your calendar.'+'<br/>';
                    emailMessage = emailMessage+'   - Please then go into your calendar and forward to your manager’s calendar and accept.'+'<br/><br/><br/>';
            
                    emailMessage = emailMessage+'CUSTOMER ENGAGEMENT:'+customerEngagement.name+'<br/><br/>';
                    emailMessage = emailMessage+'EVENT DATE:'+dateofCEEventStr+'<br/><br/>';
                    emailMessage = emailMessage+'EVENT LOCATION:'+Site+'<br/><br/>';
                    emailMessage = emailMessage+'BRIEFING CENTER ANALYST: '+customerEngagement.Owner.name+'<br/><br/>';

                    emailMessage = emailMessage+'----------------------------------------------------------<br/>';
                    emailMessage = emailMessage+'ATTENDEES<br/>';
                    emailMessage = emailMessage+'----------------------------------------------------------<br/><br/>';        
                    if(attCustListStr!=null){
                        emailMessage=emailMessage+'Customer Attendees<br/>';
                        emailMessage=emailMessage+'----------------------------<br/>';
                        emailMessage=emailMessage+attCustListStr+'<br/>';
                    }
                    if(attAccTeamCustListStr!=null){
                        emailMessage=emailMessage+'Account team Attendees<br/>';
                        emailMessage=emailMessage+'----------------------------<br/>';
                        emailMessage=emailMessage+attAccTeamCustListStr+'<br/>';
                    }
                    if(attDellIntCustListStr!=null){
                        emailMessage=emailMessage+'Dell Internal Attendees<br/>';
                        emailMessage=emailMessage+'----------------------------<br/>';
                        emailMessage=emailMessage+attDellIntCustListStr+'<br/>';
                    }
                    if(attVendorCustListStr!=null){
                        emailMessage=emailMessage+'Vendor/Partner Attendees<br/>';
                        emailMessage=emailMessage+'----------------------------<br/>';
                        emailMessage=emailMessage+attVendorCustListStr+'<br/>';
                    }
           
                    eventStartDate = EventDate(startEventDate);
                    eventEndDate = EventDate(endEventDate);
                    
                    datetime DateTimeNow = datetime.now();
                    fileName = FileName(DateTimeNow); 
                    
                    nullEmail = false;      
                    Analyst = customerEngagement.Owner.email;      

                }
            }
        }
    } 
    
    public Boolean getShowInvite(){
        return showInvite;
    }
    public Boolean getShowMessage(){
        return showMessage;
    }
    public List<Attendees__c> getAttendeeAccTeamList(){
        return attendeeAccTeamList;
    }
    public List<Attendees__c> getAttendeeDellIntList(){
        return attendeeDellIntList;
    }
    public List<Attendees__c> getAttendeeVendorList(){
        return attendeeVendorList;
    }

    //Method to group the attendees into Customer,Account Team,Dell Internal,Vendor/Partner and then group by account
    public void attendeeSort(){
        oldAttendeeFlag  = FALSE;
        attendeeAccTeamList = new List<Attendees__c>();
        attendeeCustomerList = new List<Attendees__c>();
        attendeeDellIntList = new List<Attendees__c>();
        attendeeVendorList = new List<Attendees__c>();
        custAttendeeMap = new Map<String,List<Attendees__c>>();
        accTeamAttendeeMap = new Map<String,List<Attendees__c>>();
        
        Id attCustId=IdLookupUtils.getRecordTypeId('Customer','Attendees__c',true);
        Id attAccTeamId=IdLookupUtils.getRecordTypeId('Account Team','Attendees__c',true);
        Id attDellIntId=IdLookupUtils.getRecordTypeId('Dell Internal','Attendees__c',true);        
        Id attVendorId=IdLookupUtils.getRecordTypeId('Vendor/Partner','Attendees__c',true);
        List<Attendees__c>attList=new List<Attendees__c>();
        for(Attendees__c attendeeTemp : attendeesList){
            if(attendeeTemp.recordTypeId==attCustId){
                attendeeCustomerList.add(attendeeTemp);
            }
             else if(attendeeTemp.recordTypeId==attAccTeamId){
                 attendeeAccTeamList.add(attendeeTemp);
             }
             else if(attendeeTemp.recordTypeId==attDellIntId){
                attendeeDellIntList.add(attendeeTemp);
            }
            else if(attendeeTemp.recordTypeId==attVendorId){
                attendeeVendorList.add(attendeeTemp);
            }
         }
         for(Attendees__c attTemp : attendeeCustomerList){
             if(attTemp.Account_Name__c == NULL)
             oldAttendeeFlag = TRUE;
         }
         if(oldAttendeeFlag == FALSE){
             for(Attendees__c attTemp : attendeeAccTeamList){
                 if(attTemp.Account_Name__c == NULL)
                 oldAttendeeFlag = TRUE;
             }
         }
         if(oldAttendeeFlag  == FALSE){
            for(Attendees__c attCustTemp : attendeeCustomerList){
                 if(custAttendeeMap.containskey(attCustTemp.Account_Name__c)){
                     custAttendeeMap.get(attCustTemp.Account_Name__c).add(attCustTemp);
                 }
                 else{
                     attList=new List<Attendees__c>();
                     attList.add(attCustTemp);
                     custAttendeeMap.put(attCustTemp.Account_Name__c,attList);
                }
            }
            for(Attendees__c attAccTemp : attendeeAccTeamList){
                if(accTeamAttendeeMap.containskey(attAccTemp.Account_Name__c)){
                    accTeamAttendeeMap.get(attAccTemp.Account_Name__c).add(attAccTemp);
                }
                else{
                    attList=new List<Attendees__c>();
                    attList.add(attAccTemp);
                    accTeamAttendeeMap.put(attAccTemp.Account_Name__c,attList);
                }   
            }
            attendeeCustomerList = new List<Attendees__c>();
            attendeeAccTeamList = new List<Attendees__c>();
         }
         if((custAttendeeMap.isEmpty())&&(accTeamAttendeeMap.isEmpty())&&
             (attendeeDellIntList.size()==null)&&(attendeeVendorList.size()==null)){
            showError('Please add Attendees. Click on \'Cancel\' to go back.');  
        }
   }


    public String getDateOfEvent(){  
        return dateofCEEventStr;
    }
    //Start date and end date of the customer engagement event in string format
    public void dateRange(){
        dateofCEEventStr = startEventDate.format();
        if(!(startEventDate.isSameDay(endEventDate))){
            dateofCEEventStr = dateofCEEventStr+' - '+endEventDate.format();            
        }
    }

    public string lineBreaks(string inText){
       if (inText == null){
           return '';
       }
       else{
           return inText.replaceAll('\n','<br/>');
       }
    }
    
    public Customer_Engagement__c getCustomerEngagement(){
        return customerEngagement;
    }
    
    public List<Attendees__c> getAttendeeCustExtList(){
        return attendeeCustExtList;
    }
    
    public List<Attendees__c> getAttendeesToList(){
        return attendeesToList;
    } 
    
    public List<Attendees__c>getAttendeeCustomerList(){
        return attendeeCustomerList;
    }

    public string FileName(datetime DTNow){
        string year = ''+DTNow.year();
        string month = ''+DTNow.month();
        string day = ''+DTNow.day();
        string hour = ''+DTNow.hour();
        string minute = ''+DTNow.minute();
        string second = ''+DTNow.second();
        return 'Visit' + year.trim() + month.trim() + day.trim() + hour + minute + second + 'BOLT';
    }

    public string EventDate(date EDate){
        string year;
        string month;
        string day;
        try{
            year = ''+EDate.year();
            month = ''+EDate.month();
            day = ''+EDate.day();
            if(month.length() == 1){
                month = '0'+month;
            }
            if(day.length() == 1){
                day = '0'+day;
            }
            return year.trim()+month.trim()+day.trim();
        }catch(Exception e){
            return null;
        }
        
    }
        
    public String getSite(){return site;}
    
    public String getEvent(){return event;}
    
    public PageReference sendinvite(){ 
        String emailMsgBody;
        if((email == '' )){
            nullEmail = true; invalidEmail = false; 
            return null;
        }
        emailMsgBody = '<b>Analyst Comments</b> :-'+lineBreaks(comments)+'<br/><br/>'+emailMessage;
                  
        String subjectLine = subjectLineStr;
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        toEmailList = email.split(';');
        for(string emailList : toEmailList){
            List<String> atList = emailList.split('@');

            if(atList.size() == 2){
                if(atList[0] == '' || atList[1] == ''){
                    invalidEmail = true; nullEmail = false; invalidCCEmail = false;   
                     return null;
                }
                List<String> dotList = atList[1].split('\\.');
                    if(dotList.size() >= 2){
                        if(dotList[0] == '' || dotList[1] == ''){
                            invalidEmail = true; nullEmail = false; invalidCCEmail = false;      
                             return null;
                        }
                    }
                    else{
                        invalidEmail = true; nullEmail = false; invalidCCEmail = false;
                         return null;
                    }
            }else{
                invalidEmail = true; nullEmail = false; invalidCCEmail = false;
                return null;
            }
        }        
        if((ccemail!=null)&&(ccemail!='')){
            List<String> ccEmailList = ccemail.split(';');
            for(string emailList : ccEmailList){
                List<String> atList = emailList.split('@');
                if(atList.size() == 2){
                    if(atList[0] == '' || atList[1] == ''){
                        invalidCCEmail = true; invalidEmail = false; nullEmail = false;
                        return null;        
                    }
                    List<String> dotList = atList[1].split('\\.');
                        if(dotList.size() >= 2){
                            if(dotList[0] == '' || dotList[1] == ''){
                                invalidCCEmail = true; invalidEmail = false; nullEmail = false;
                                return null;        
                            }
                        }
                        else{
                            invalidCCEmail = true; invalidEmail = false; nullEmail = false;
                            return null;
                        }
                }else{
                    invalidCCEmail = true; invalidEmail = false; nullEmail = false;
                    return null;
                }
            }
            String[] ccAddresses = ccEmailList; 
            if(ccemail != '' && ccemail != NULL){
            mail.setCcAddresses(ccAddresses);
        }
        }
        toAddresses = toEmailList; 

        if(email != '' && email != NULL){
            mail.setToAddresses(toAddresses);
        }

        mail.setReplyTo(toEmailList[0]);
        mail.setSubject(subjectLine);
        mail.SetHTMLBody(emailMsgBody);
        mail.setBccSender(false);
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        //Messaging.EmailFileAttachment attach1 = new Messaging.EmailFileAttachment();   
        attach.filename = fileName+'.ics'; 
        attach.Body = invite();
        //attach1.filename = fileName+'.ics'; 
        //attach1.Body = invite();
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach });
        Messaging.SendEmailResult[] er = Messaging.sendEmail(new Messaging.Email[] { mail }); 

        return PageUtils.redirect('/'+customerEngagement.Id);
    } 
    
    //Method to generate the .ics file
    private Blob invite() {
        String txtInvite = '';
        txtInvite += 'BEGIN:VCALENDAR\n';
        txtInvite += 'PRODID:-//Microsoft Corporation//Outlook 12.0 MIMEDIR//EN\n';
        txtInvite += 'VERSION:2.0\n';
        txtInvite += 'METHOD:REQUEST\n';
        txtInvite += 'X-MS-OLK-FORCEINSPECTOROPEN:TRUE\n';
        txtInvite += 'BEGIN:VEVENT\n';
        for(string Attendees:toEmailList){
            txtInvite += 'ATTENDEE;ROLE=REQ-PARTICIPANT;PARTSTAT=NEEDS-ACTION;RSVP=TRUE:MAILTO:'+Attendees+'\n';
        }
        txtInvite += 'CLASS:PUBLIC\n';
        //txtInvite += 'CREATED:20110616T092052Z\n';
        txtInvite += 'DESCRIPTION:'+dateofCEEventStr+'\n';
        
        /*
        //txtInvite += 'DTEND:'+eventEndDate+'T113000Z\n';
        //txtInvite += 'DTEND;TZID='+userTimeZone+':'+eventEndDate+'T170000\n';
        txtInvite += 'DTEND;TZID='+userTimeZone+':'+eventEndDate+'T235900\n';        //Defect Id : 71892

        //txtInvite += 'DTSTAMP:20110616T091913Z\n';
        
        //txtInvite += 'DTSTART:'+eventStartDate+'T023000Z\n';
        //txtInvite += 'DTSTART;TZID='+userTimeZone+':'+eventStartDate+'T080000\n';
        txtInvite += 'DTSTART;TZID='+userTimeZone+':'+eventStartDate+'T000000\n';        //Defect Id : 71892
        */
        txtInvite += 'DTEND;VALUE=DATE:'+eventEndDate+'T235900\n';                //Defect ID : 71892 All Day Event
        txtInvite += 'DTSTART;VALUE=DATE:'+eventStartDate+'\n';            //Defect ID : 71892 All Day Event

        //txtInvite += 'LAST-MODIFIED:20110616T092052Z\n';
        txtInvite += 'LOCATION:'+site+'\n';
        txtInvite += 'ORGANIZER:'+Analyst+'\n';
        txtInvite += 'PRIORITY:5\n';
        txtInvite += 'SEQUENCE:0\n';
        txtInvite += 'SUMMARY;LANGUAGE=en-us:'+subjectLineStr+'\n';
        txtInvite += 'TRANSP:OPAQUE\n';
        txtInvite += 'UID:'+fileName+'\n';
        txtInvite += 'X-ALT-DESC;FMTTYPE=text/html:'+emailMessage+'\n';
        txtInvite += 'X-MICROSOFT-CDO-BUSYSTATUS:BUSY\n';
        txtInvite += 'X-MICROSOFT-CDO-IMPORTANCE:1\n';
        txtInvite += 'X-MICROSOFT-CDO-INTENDEDSTATUS:BUSY\n';
        txtInvite += 'X-MICROSOFT-DISALLOW-COUNTER:FALSE\n';
        txtInvite += 'X-MS-OLK-ALLOWEXTERNCHECK:TRUE\n';
        txtInvite += 'X-MS-OLK-APPTLASTSEQUENCE:0\n';
        txtInvite += 'X-MS-OLK-AUTOSTARTCHECK:FALSE\n';
        txtInvite += 'X-MS-OLK-CONFTYPE:0\n';
        txtInvite += 'BEGIN:VALARM\n';
        txtInvite += 'TRIGGER:-PT15M\n';
        txtInvite += 'ACTION:DISPLAY\n';
        txtInvite += 'DESCRIPTION:Reminder\n';
        txtInvite += 'END:VALARM\n';
        txtInvite += 'END:VEVENT\n';
        txtInvite += 'END:VCALENDAR\n';
        return Blob.valueOf(txtInvite);
    }
    
    //Method to display error message in page
     private void showError (String errorMessage){
        PageUtils.addError(errorMessage);
        showMessage = true;
        showInvite = false;
    }
    
    public String getComments(){
        return comments;
    }
    
    public void setComments(String commentsStr){
        this.comments = commentsStr;
    }
    public String getMessage(){
        return emailMessage;
    }
    
    public void setMessage(String Msg){
        this.emailMessage = Msg;
    }

    public String getSubjectEdit(){
        return subjectLineStr;
    }
    public void setSubjectEdit(String subjectStr){
        this.subjectLineStr = subjectStr;
    }
    public String getAnalystEmail(){
        return analystEmailStr;
    }
        public Boolean getCustomerAttFlag(){
        if((!custAttendeeMap.isEmpty())||(!attendeeCustomerList.isEmpty())){
            return true;
        }
        else{
            return false;
        }
    }
    public Boolean getAccTeamAttFlag(){
        if((!accTeamAttendeeMap.isEmpty())||(!attendeeAccTeamList.isEmpty())){
            return true;
        }
        else{
            return false;
        }
    }
        public Map<String,List<Attendees__c>>getcustAttendeeMap(){
        return custAttendeeMap;
    }
    public Map<String,List<Attendees__c>>getaccTeamAttendeeMap(){
        return accTeamAttendeeMap;
    }
        public Boolean getDellIntAttFlag(){
        if(AttendeeDellIntList.size()>0){
            return true;
        }
        else{
            return false;
        }
    }
    public Boolean getVendorAttFlag(){
        if(AttendeeVendorList .size()>0){
            return true;
        }
        else{
            return false;
        }
    }

}