/*****************************************************************************************************************
* Name          : VFCntrlr_BoltPresenterInvite
* Description   : Create template and send calender invite email to presneter.
* ---------------------------------------------------------
* Revision  Name        Date            Description
* 1.0       Sandhya     16.06.2011      CR 6382 -Change the subject line and email template for EBC/DSC Presenter invite.
* 2.0       Manikandan  01.02.2012      CR 6920 - To correct the time schedule issue.
* 3.0       Sazleen     30.05.2016      CR13164 - US1423262:Update CE presenter invite
******************************************************************************************************************/

public class VFCntrlr_BoltPresenterInvite{
    
    Agenda_Topic__c agendaTopic=new Agenda_Topic__c();
    Customer_Engagement__c customerEngagement=new Customer_Engagement__c();
    List<Attending_Accounts__c> attendingAccntLst=new List<Attending_Accounts__c>(); 
    List<Attendees__c> attendeesList=new List<Attendees__c>();
    List<Attendees__c> speakerList=new List<Attendees__c>();
    List<Attendees__c> attendeesToList=new List<Attendees__c>();
    List<Attendees__c> attendeeVendorList=new List<Attendees__c>();
    List<Attendees__c> attendeeDellIntList=new List<Attendees__c>();
    List<Attendees__c> attendeeCustomerList=new List<Attendees__c>();
    List<Attendees__c> attendeeAccTeamList=new List<Attendees__c>();
    Task newTask = new Task(); 
    String timeZoneStr=' ';    
    String emailMessage; 
    string dateofCEEventStr;
    string attendingAccntLstStr;
    Date startEventDate,endEventDate;
    string startTime; date startDate; string endTime;
    String meetingDate; String meetingStartTime; String meetingEndTime,fileName; 
    //SAR-3640 : Date time issue in ICS file : Manikandan Raju
    String meetingEndDate;
    public String email {get;set;}
    public String ccemail {get;set;}
    public boolean nullEmail {get; set;}
    public boolean invalidEmail {get; set;}
    public boolean invalidCCEmail {get; set;}
    string site,Analyst;
    String[] toAddresses;
    List<String> toEmailList;
    public boolean showMessage;
    public boolean showInvite;
    date startDateICS,endDateICS;
    String speakerStr,comments,BaseURL;
    string subjectLineStr,analystEmailStr;
    Boolean oldAttendeeFlag = FALSE;
    List<Install_Base__c>installBaseIdList = new List<Install_Base__c>();
    Map<String,List<Attendees__c>>custAttendeeMap = new Map<String,List<Attendees__c>>();
    Map<String,List<Attendees__c>>accTeamAttendeeMap = new Map<String,List<Attendees__c>>();
    List<Note>noteList = new List<Note>();
    List<Attachment>attachmentList = new List<Attachment>();
    string taskDescription,cmnts ;     //CR 6381
    Attachment taskAttach = new Attachment();    //CR 6381
    /* Modfied for CR 6382 - Change the subject line and email template for EBC/DSC Presenter invite */
    public VFCntrlr_BoltPresenterInvite(ApexPages.StandardController controller){
        
        String attCustListStr,attAccTeamCustListStr,attDellIntCustListStr,attVendorCustListStr;
        String AEQuestions,AENotes,AnalystQuestions,AnalystNotes;
        Boolean controlFlag=true;
        Set<ID> attIdList = new Set<ID>();
        Set<String> eventStatusEBC = new Set<String>{'Pending','Requested','Canceled','Waitlisted','Scheduled'};
        Set<String> eventStatusDSC = new Set<String>{'Pending','Rejected','Canceled'};
        User userObject=new User();
        showMessage=false;
        showInvite=true;
        BaseURL = ApexPages.currentPage().getHeaders().get('Host');
        Set<Id>accountIdSet=new Set<Id>();
        invalidEmail = FALSE;
        invalidCCEmail = false;
        try{
            agendaTopic=[Select a.Topics__c,a.Topics__r.name, a.Subject__c, a.Starting_Time__c, 
                                a.Start_Date__c, a.Send_Email_to_Presenter__c, a.Select_Meal__c, a.RecordTypeId,
                                a.Name,a.Id,a.Ending_Time__c, a.Duration__c, a.Display_Topic_As__c,a.Customer_Engagement__c,
                                a.Custom_Number__c,a.Analyst_Questions__c, a.Analyst_Notes__c,a.AE_Questions__c, a.AE_Notes__c
                        From Agenda_Topic__c a 
                        where id=:controller.getId()];
            customerEngagement=[select id,name,Objective_of_Visit__c,Top_3_Pain_Points__c,Customer_Background__c,RecordTypeId,
                                    Start_DateF__c,End_DateF__c,GSL_Start_Date__c,GSL_End_Date__c,Event_Status__c,OwnerId,Owner.name,
                                    Owner.email,Event_TypeF__c,Primary_Account__c,Primary_Account__r.name,Event_Type__c,SiteF__c,
                                    Dell_Solution_Center_Site__c,Dell_Solution_Center_Site__r.Name,Operations_Analyst__c,
                                    Operations_Analyst__r.email,Primary_Contact__c from Customer_Engagement__c
                                where id=:agendaTopic.Customer_Engagement__c];
            if(customerEngagement.RecordTypeId==IdLookupUtils.getRecordTypeId('Executive Briefing Center','Customer_Engagement__c',true)){
                site = customerEngagement.SiteF__c;
                subjectLineStr= 'INVITE ATTACHED: Briefing ';
                analystEmailStr = customerEngagement.Owner.email;
                Analyst = customerEngagement.Owner.email;
                if(eventStatusEBC.contains(customerEngagement.Event_Status__c)){
                    showError('Cannot send the invite as Customer Engagement record event status is \''+customerEngagement.Event_Status__c+'\'. Click on \'Cancel\' to go back.');  
                    controlFlag=false;
                }   
            }
            else{
                site = customerEngagement.Dell_Solution_Center_Site__r.Name;
                subjectLineStr= 'INVITE ATTACHED: Solution ';
                Analyst = customerEngagement.Operations_Analyst__r.email;
                if(customerEngagement.Operations_Analyst__r.email!=null){
                    analystEmailStr = customerEngagement.Operations_Analyst__r.email;
                }
                else{
                    showError('Please assign an Operations Analyst to the Customer Engagement Record. Click on \'Cancel\' to go back.');  
                    controlFlag=false;
                }
                if(eventStatusDSC.contains(customerEngagement.Event_Status__c)){
                    showError('Cannot send the invite as Customer Engagement record event status is \''+customerEngagement.Event_Status__c+'\'. Click on \'Cancel\' to go back.');  
                    controlFlag=false;
                } 
            }
        }catch(Exception e){
            System.debug('Exception Occured:'+e);
        }
        if(controlFlag!=false) {
            try{
                if(customerEngagement.RecordTypeId==IdLookupUtils.getRecordTypeId('Executive Briefing Center','Customer_Engagement__c',true)){
                    userObject=[select id,TimeZoneSidKey,LocaleSidKey,SystemModstamp from User where id=:customerEngagement.OwnerId];
                }
                else{
                    userObject=[select id,TimeZoneSidKey,LocaleSidKey,SystemModstamp from User where id=:customerEngagement.Operations_Analyst__r.id];  
                }
                Map<String, Schema.SObjectField> field_map = Schema.SObjectType.User.fields.getMap();   
                List<Schema.PicklistEntry> pick_list_values = field_map.get('TimeZoneSidKey').getDescribe().getPickListValues(); 
                
                for(Schema.PicklistEntry ple:pick_list_values){
                    if(ple.getValue()==userObject.TimeZoneSidKey){
                        timeZoneStr=ple.getLabel();    
                    }
                }
              }Catch(Exception e){
              showError('Request is not yet assigned to Analyst.Please get an Analyst assigned. Click on \'Cancel\' to go back.');     
            }   
            if(timeZoneStr!=' '){
                try{
                    for(Attending_Accounts__c attAccount:[select id,Customer_Engagement__c,name,Account__r.name from Attending_Accounts__c  
                                                            where Customer_Engagement__c=:agendaTopic.Customer_Engagement__c]){
                        attendingAccntLst.add(attAccount);
                        accountIdSet.add(attAccount.Account__c);
                    }
                    installBaseIdList = [select id,Account__c,LOB__c from Install_Base__c  
                                                            where Account__c IN : accountIdSet];
                    for(Attendees__c attendee:[select id,name,Attendee_Name__c,Customer_Engagement__c,recordTypeId,Email__c,Agenda_Topic__c,
                                                recordType.name,Customer_Attendee__c ,Role__c,Account_Name__c from Attendees__c 
                                                where Customer_Engagement__c=:agendaTopic.Customer_Engagement__c]){
                        attendeesList.add(attendee);
                        attIdList.add(attendee.Customer_Attendee__c);
                        if(attendee.Agenda_Topic__c == agendaTopic.Id){
                            speakerList.add(attendee);  
                            if(attendee.Email__c!=null){
                                attendeesToList.add(attendee);
                                if(email==null){
                                    email=attendee.Email__c;
                                }else{
                                    email=email+';'+attendee.Email__c;
                                }
                            }
                        }                               
                    }
                    noteList = [select Id,Title from Note where ParentId =: customerEngagement.Id];
                    attachmentList = [select Id,Name from Attachment where ParentId =: customerEngagement.Id];
                }catch(Exception e){
                    System.debug('Exception Occured:'+e);
                }    
                if(AttendeesToList.size()==0){
                    showError('Either presenter do not have an E-mail ID or presenter not assigned to Agenda Topic. Click on \'Cancel\' to go back.');  
                    controlFlag=false;
                } 
                if(controlFlag!=false){
                    //ccemail=customerEngagement.Owner.email+';';
                    ccemail=analystEmailStr+';'; 
                    for(integer i=0;i<SpeakerList.size();i++){
                        SpeakerList[i].Sent_Email_To_Presenter__c=true;
                        if(speakerStr==null){
                            speakerStr=SpeakerList[i].Attendee_Name__c;
                        }else{
                            speakerStr=speakerStr+', '+SpeakerList[i].Attendee_Name__c;
                        }
                    }
                    attendeeSort();      
                    subjectLineStr=subjectLineStr+'Center Request for '+customerEngagement.name+' on '+
                                    agendaTopic.Start_Date__c.format()+ ' for '+((agendaTopic.Display_Topic_As__c!=null)?agendaTopic.Display_Topic_As__c :agendaTopic.Name);
                    if(oldAttendeeFlag == TRUE){
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
                                        if(attCustListStr == null){
                                                attCustListStr = attTemp.Attendee_Name__c+((attTemp.Role__c==null)?' ':', '+attTemp.Role__c)+'<br/>';
                                        }
                                        else{
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
                                        if(attAccTeamCustListStr == null){
                                                attAccTeamCustListStr = accTemp.Attendee_Name__c+((accTemp.Role__c==null)?' ':', '+accTemp.Role__c)+'<br/>';
                                        }
                                        else{
                                        attAccTeamCustListStr=attAccTeamCustListStr+accTemp.Attendee_Name__c+((accTemp.Role__c==null)?' ':', '+accTemp.Role__c)+'<br/>';
                                        }
                                }      
                            }
                        }
                    }
                    for(integer i=0;i<attendeeDellIntList.size();i++){
                        if(attDellIntCustListStr==null){
                            attDellIntCustListStr=attendeeDellIntList[i].Attendee_Name__c+((attendeeDellIntList[i].Role__c==null)?' ':', '+attendeeDellIntList[i].Role__c)+'<br/>';
                        }else{
                            attDellIntCustListStr=attDellIntCustListStr+attendeeDellIntList[i].Attendee_Name__c+', '+
                                                  ((attendeeDellIntList[i].Role__c==null)?' ':attendeeDellIntList[i].Role__c)+'<br/>';
                        }
                    }
                    for(integer i=0;i<attendeeVendorList.size();i++){
                        if(attVendorCustListStr==null){
                            attVendorCustListStr=attendeeVendorList[i].Attendee_Name__c+((attendeeVendorList[i].Role__c==null)?' ':', '+attendeeVendorList[i].Role__c)+'<br/>';
                        }else{
                            attVendorCustListStr=attVendorCustListStr+attendeeVendorList[i].Attendee_Name__c+
                                                 ((attendeeVendorList[i].Role__c==null)?' ':', '+attendeeVendorList[i].Role__c)+'<br/>';
                        }
                    }
                     emailMessage='   The '+site+ ' has requested your participation in the upcoming '+
                     customerEngagement.name +' Briefing on '+ AgendaTopic.Start_Date__c.format()+'.<br/><br/>';
                     
                     emailMessage=emailMessage+'If you are a calendar manager, please note that you will need to follow these steps: '+'<br/>'+
                     '- Open the attached invite and accept to your calendar.'+'<br/>'+'- Please then go into your calendar and forward to your manager’s calendar and accept.'+'<br/><br/>';
            
                    emailMessage=emailMessage+'<b>Customer Engagement: </b>'+customerEngagement.name+'<br/><br/>';
                    emailMessage=emailMessage+'<b>Topic: </b>'+((agendaTopic.Display_Topic_As__c!=null)?agendaTopic.Display_Topic_As__c :agendaTopic.name)+'<br/><br/>';
                    emailMessage=emailMessage+'<b>Speaker(s):</b>'+((speakerStr==null)?' ':speakerStr)+'<br/><br/>';
                    emailMessage=emailMessage+'<b>Location:</b>&nbsp;<br/><br/>';
                    emailMessage=emailMessage+'<b>Time: </b>'+ AgendaTopic.Start_Date__c.format()+'  '+ AgendaTopic.Starting_Time__c+' to '+AgendaTopic.Ending_Time__c+''+timeZoneStr+'<br/><br/>';
                    AENotes = (agendaTopic.AE_Notes__c==null)?' ':agendaTopic.AE_Notes__c;         
                    // US1423262 Remove AE Notes
                    //emailMessage=emailMessage+'<b>AE Notes: </b>'+lineBreaks(AENotes)+'<br/><br/>';
                    
                    AnalystNotes = (agendaTopic.Analyst_Notes__c==null)?' ':agendaTopic.Analyst_Notes__c;
                    emailMessage=emailMessage+'<b>Topic Notes:</b>&nbsp;' +lineBreaks(AnalystNotes)+'<br/><br/>';       
                    string objectiveStr = (customerEngagement.Objective_of_Visit__c==null)?' ':customerEngagement.Objective_of_Visit__c;
                    emailMessage=emailMessage+'<b>Overall Briefing Objective: </b>'+lineBreaks(objectiveStr)+'<br/><br/>';
                    string painPointsStr = (customerEngagement.Top_3_Pain_Points__c==null)?' ':customerEngagement.Top_3_Pain_Points__c;
                    emailMessage=emailMessage+'<b>Pain Points: </b>'+lineBreaks(painPointsStr)+'<br/><br/>';
                    string customerBgndStr = (customerEngagement.Customer_Background__c==null)?' ':customerEngagement.Customer_Background__c;
                    emailMessage=emailMessage+'<b>Customer Background: </b>'+lineBreaks(customerBgndStr)+'<br/><br/>';
                    emailMessage=emailMessage+'<b>Customer Account Link: </b><br/>';
                    for( Attending_Accounts__c attAcc:attendingAccntLst){
                        emailMessage=emailMessage+attAcc.Account__r.Name+', '+'https://'+BaseURL+'/'+attAcc.Id+'<br/>';
                    }
                    emailMessage=emailMessage+'<br/>'+'<b>Competitive Information/Install Base Link: </b><br/>';
                    for(Install_Base__c install:installBaseIdList){
                        emailMessage=emailMessage+install.LOB__c+', '+'https://'+BaseURL+'/'+install.Id+'<br/>';
                    }
                    String notesStr='';
                    //71891
                    for(Note nt:noteList){
                    notesStr=notesStr +nt.Title+', '+'https://'+BaseURL+'/'+nt.Id+'<br/>';
                    }
                    for(Attachment atmt: attachmentList){
                    notesStr=notesStr +atmt.Name+', '+'https://'+BaseURL+'/'+atmt.Id+'<br/>';
                    }//71891
                    emailMessage=emailMessage+'<br/>'+'<b>Visit Notes and Attachments Link: </b><br/>'+notesStr+'<br/>';
                    
                    emailMessage=emailMessage+'----------------------------------------------------------<br/>';
                    emailMessage=emailMessage+'<b>CUSTOMER ENGAGEMENT DETAILS</b><br/>';
                    emailMessage=emailMessage+'----------------------------------------------------------<br/>';
                    emailMessage=emailMessage+customerEngagement.name+'<br/><br/>';
                    emailMessage=emailMessage+'https://'+BaseURL+'/'+customerEngagement.Id+'<br/><br/>';
                    
                    emailMessage=emailMessage+'----------------------------------------------------------<br/>';
                    emailMessage=emailMessage+'<b>ATTENDEES</b><br/>';
                    emailMessage=emailMessage+'----------------------------------------------------------<br/><br/>';        
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
           
                    startDate = agendaTopic.Start_Date__c;
                    startTime = agendaTopic.Starting_Time__c;
                    endTime = agendaTopic.Ending_Time__c;
            
                    meetingDate = MeetingDate(startDate);
                    meetingStartTime = MeetingTime(startTime);
                    meetingEndTime = MeetingTime(endTime);
                    
                    startDateICS =date.valueOf(meetingDate);
                    endDateICS =date.valueOf(meetingDate);
                    
                    datetime DateTimeNow = datetime.now();
                    fileName = FileName(DateTimeNow); 
                    
                    nullEmail = false;            
                    
                    if((agendaTopic.Starting_Time__c!=null)&&(agendaTopic.Ending_Time__c!=null)&&(agendaTopic.Start_Date__c!=null)){            
                        List<String> startTimeLst=meetingStartTime.split(':');
                        List<String> endTimeLst=meetingEndTime.split(':');
                        
                        DateTime startDateTime = datetime.newInstance(startDate.year(),startDate.month(),startDate.day(),Integer.valueOf(meetingStartTime.substring(0, 2)),Integer.valueOf(meetingStartTime.substring(3,5)),00);
                        String startTimeFormat = startDateTime.format('yyyy-MM-dd HH:mm:ss','GMT');
                        startTimeLst=startTimeFormat.split(' ');
                        meetingStartTime=startTimeLst[1];
                        meetingDate = startTimeLst[0];
                        DateTime endDateTime = datetime.newInstance(startDate.year(),startDate.month(),startDate.day(),Integer.valueOf(meetingEndTime.substring(0,2)),Integer.valueOf(meetingEndTime.substring(3,5)),00);
                        String endTimeFormat = endDateTime.format('yyyy-MM-dd HH:mm:ss','GMT');
                        endTimeLst=endTimeFormat.split(' ');
                        meetingEndTime=endTimeLst[1];
                        //SAR-3640 : Date time issue in ICS file : Manikandan Raju
                        meetingEndDate = endTimeLst[0];
                    }
                    else{
                        showError('Either of Start Date or Starting Time/Ending time is missing.Please click on \'Cancel\' to go back.');    
                    }
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
    public List<Attendees__c> getAttendeeDellIntList(){
        return attendeeDellIntList;
    }
    public List<Attendees__c> getAttendeeVendorList(){
        return attendeeVendorList;
    }
    
    /* Modified for CR 6382 -Change the subject line and email template for EBC/DSC Presenter invite
       Method to group the attendees into Customer,Account Team,Dell Internal,Vendor/Partner  */        
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
             if((attTemp.Account_Name__c == NULL)&&(attTemp.Customer_Attendee__c != customerEngagement.Primary_Contact__c)){
                 oldAttendeeFlag = TRUE;
             }
         }
         if(oldAttendeeFlag == FALSE){
             for(Attendees__c attAccTemp : attendeeAccTeamList){
                 if(attAccTemp.Account_Name__c == NULL)
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
                     if(attCustTemp.Account_Name__c!=null){
                         custAttendeeMap.put(attCustTemp.Account_Name__c,attList);
                     }
                     else{
                         custAttendeeMap.put(customerEngagement.Primary_Account__r.name,attList);
                     }
                }
            }
            for(Attendees__c attAccTemp : attendeeAccTeamList){
            system.debug('attendeeAccTeamList'+attendeeAccTeamList);
                if(accTeamAttendeeMap.containskey(attAccTemp.Account_Name__c)){
                    accTeamAttendeeMap.get(attAccTemp.Account_Name__c).add(attAccTemp);
                }
                else{
                    attList=new List<Attendees__c>();
                    attList.add(attAccTemp);
                    accTeamAttendeeMap.put(attAccTemp.Account_Name__c,attList);
                }   
            }
            system.debug('accTeamAttendeeMap'+accTeamAttendeeMap);
            attendeeCustomerList = new List<Attendees__c>();
            attendeeAccTeamList = new List<Attendees__c>();
         }
         if((custAttendeeMap.isEmpty())&&(accTeamAttendeeMap.isEmpty())&&
             (attendeeDellIntList.size()==null)&&(attendeeVendorList.size()==null)){
            showError('Please add Attendees. Click on \'Cancel\' to go back.');  
        }
   }
    
    public String getstartDateOfEvent(){        
        return agendaTopic.Start_Date__c.format();
    }

    public Map<String,List<Attendees__c>>getcustAttendeeMap(){
        return custAttendeeMap;
    }
    public Map<String,List<Attendees__c>>getaccTeamAttendeeMap(){
        return accTeamAttendeeMap;
    }
    public Agenda_Topic__c getAgendaTopic(){
        return agendaTopic;
    }
    public String getSpeakerStr(){
        return speakerStr;
    }
    public string lineBreaks(string inText){
       if (inText == null){
           return '';
       }
       else{
           //Carriage Return issue in .ics file : Start
           //return inText.replaceAll('\n','<br/>');
            inText = inText.replaceAll('\n','<br/>');
            inText = inText.replaceAll('\r','<br/>');
            return inText; 
            //Carriage Return issue in .ics file : End
       }
    }
    public Customer_Engagement__c getCustomerEngagement(){
        return customerEngagement;
    }
    public List<Attendees__c> getAttendeesToList(){
        return attendeesToList;
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
    public string MeetingDate(date MDate){
        string year;
        string month;
        string day;
        try{
            year = ''+MDate.year();
            month = ''+MDate.month();
            day = ''+MDate.day();
            if(month.length() == 1){
                month = '0'+month;
            }
            if(day.length() == 1){
                day = '0'+day;
            }
            return year.trim()+'-'+month.trim()+'-'+day.trim();
        }catch(Exception e){
            return null;
        }        
    }
    public string MeetingTime(String filename){
        try{
            string hour0 = filename.substring(0, 2);
            string minute = filename.substring(3, 5);
            string meridian = filename.substring(5, 7);
            string hour;
            if(meridian == 'PM' && hour0 != '12'){
                string hour1 = filename.substring(0, 2);
                Integer myInteger = Integer.valueOf(hour1);
                Integer pmHour = myInteger + 12;
                hour = pmHour.format();
            }else if(meridian == 'AM' && hour0 == '12'){
                hour = '00';
            }else{
                hour = filename.substring(0, 2);
            }
            string second = '00';
            return hour+':'+minute+':'+second;
        }catch(Exception e){
            return null;
        }
    }
    
    public String getUserTimeZone(){
        return timeZoneStr;
    }
    public String getSite(){
        return site;
    }
    public PageReference sendinvite(){ 
        Boolean invalidSendEmail = false;
        String emailMsgBody;
        nullEmail = false;
        invalidCCEmail = false;
        invalidEmail = false;
        if((email == '' )){
            nullEmail = true;
            return null;
        }
        
        
        emailMsgBody='<p style="font-family:Museo Sans for Dell; font-size:10pt; color:red;"><b>Analyst Comments: </b>'+'<font color="black">'+lineBreaks(comments)+'<br/><br/>'+emailMessage +'</font>';
        
        //CR 6381 : Start
        taskDescription = emailMessage; cmnts = comments;
        taskDescription = taskDescription.replaceAll('<br/>','\n');
        taskDescription = taskDescription.replaceAll('<b>','');
        taskDescription = taskDescription.replaceAll('</b>','');
        cmnts = cmnts.replaceAll('<br/>','\n');
        taskDescription = 'Analyst Comments : '+cmnts+'\n\n'+taskDescription;
        //CR 6381 : End
        
        String subjectLine=subjectLineStr;
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        toEmailList = email.split(';');
        for(string emailList : toEmailList){
            List<String> atList = emailList.split('@');
            if(atList.size() == 2){
                if(atList[0] == '' || atList[1] == ''){
                    invalidEmail = true;
                }
                List<String> dotList = atList[1].split('\\.');
                    if(dotList.size() >= 2){
                        if(dotList[0] == '' || dotList[1] == ''){
                            invalidEmail = true;     
                        }
                        
                    }
                    else{
                        invalidEmail = true;
                    }
            }else{
                invalidEmail = true; nullEmail = false; invalidCCEmail = false;
            }
            if(invalidEmail == true){
                return null;
            }
        }        
        if((ccemail!=null)&&(ccemail!='')){
            List<String> ccEmailList = ccemail.split(';');
            for(string emailList : ccEmailList){
                List<String> atList = emailList.split('@');
                if(atList.size() == 2){
                    if(atList[0] == '' || atList[1] == ''){
                        invalidCCEmail = true;
                        return null;        
                    }
                    List<String> dotList = atList[1].split('\\.');
                        if(dotList.size() >= 2){
                            if(dotList[0] == '' || dotList[1] == ''){
                                invalidCCEmail = true;
                                return null;        
                            }
                            
                        }
                        else{
                            invalidCCEmail = true;
                            return null;
                        }
                }else{
                    invalidCCEmail = true;
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
        mail.setSubject(subjectLine);
        mail.SetHTMLBody(emailMsgBody);
        mail.setBccSender(false);
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();   
        attach.filename = fileName+'.ics'; 
        attach.Body = invite();
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {attach});
        try{
            Messaging.SendEmailResult[] er = Messaging.sendEmail(new Messaging.Email[] { mail }); 
        }
        catch(Exception e){
            invalidSendEmail = true;
            ApexPages.addMessages(e);  
        }
        if(invalidSendEmail !=true){
            newTask.Description = taskDescription;     //CR 6381
            newTask.Priority = 'Normal';
            newTask.Status = 'Completed';
            newTask.Subject = subjectLine;
            newTask.IsReminderSet = true;
            newTask.ReminderDateTime = System.now()+1;
            newTask.WhatId = agendaTopic.Id;
    
            insert newTask;
            //CR 6381 : Start
            taskAttach.Body = invite();
            taskAttach.Name = fileName+'.ics'; 
            taskAttach.ParentId = newTask.Id;
            insert taskAttach;
            //CR 6381 : End
        }
        try{
            if(SpeakerList!=null){
                update SpeakerList;
            }
        }
        catch(Exception e){
            System.debug('Exception Occured'+e);
            showError('Please check the presenters added. Click on \'Cancel\' to go back.');  
        }
        if(invalidSendEmail ==true){
            return null;
        }
        else{
            return PageUtils.redirect('/'+agendaTopic.Id);
        }
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
        txtInvite += 'CLASS:PUBLIC\n';
        txtInvite += 'UID:'+fileName+'\n';
        txtInvite += 'SEQUENCE:0\n';
        txtInvite += 'ORGANIZER:'+Analyst+'\n';
        txtInvite += 'DTSTART:'+meetingDate+'T'+meetingStartTime+'Z'+'\n';
        
        //SAR-3640 : Date time issue in ICS file : Manikandan Raju
        //txtInvite += 'DTEND:'+meetingDate+'T'+meetingEndTime+'Z'+'\n';
        txtInvite += 'DTEND:'+meetingEndDate+'T'+meetingEndTime+'Z'+'\n';
        
        txtInvite += 'DALARM:20110208T040000;PT5M;3\n';
        txtInvite += 'LOCATION:'+site+'\n';
        txtInvite += 'PRIORITY:5\n';
        txtInvite +=  'SUMMARY:'+subjectLineStr+'\n';
        txtInvite += 'DESCRIPTION:'+meetingDate+'\n';
        txtInvite += 'LANGUAGE=en-us:Salesforce Test\n';
        txtInvite += 'TRANSP:OPAQUE\n';
        txtInvite += 'METHOD:CANCEL\n';
        txtInvite += 'STATUS:CANCELLED\n';
        txtInvite += 'X-ALT-DESC;FMTTYPE=text/html:'+emailMessage+'\n';
        txtInvite += 'X-MICROSOFT-CDO-BUSYSTATUS:BUSY\n';
        txtInvite += 'X-MICROSOFT-CDO-IMPORTANCE:1\n';
        for(string Attendees:toEmailList){
            txtInvite += 'ATTENDEE;ROLE=REQ-PARTICIPANT;PARTSTAT=NEEDS-ACTION;RSVP=TRUE:MAILTO:'+Attendees+'\n';
        }
        txtInvite += 'END:VEVENT\n';
        txtInvite += 'END:VCALENDAR';
        return Blob.valueOf(txtInvite);
    }
    //Method to display error message in page
     private void showError (String errorMessage){
        PageUtils.addError(errorMessage);
        showMessage=true;
        showInvite=false;
    }
    
    public String getComments(){
        return comments;
    }
    
    public void setComments(String commentsStr){
        this.comments=commentsStr;
    }
    public String getMessage(){
        return emailMessage;
    }
    
    public void setMessage(String Msg){
        this.emailMessage=Msg;
    }
    
    public String getBaseURL(){
        return BaseURL;
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
    public List<Install_Base__c>getinstallBaseIdList(){
        return installBaseIdList;
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
    public List<Attending_Accounts__c>getattendingAccntLst(){
        return attendingAccntLst;
    }
    public List<Note>getNoteList(){
        return noteList;
    }
    public List<attachment>getAttachmentList(){
        return attachmentList ;
    }
    public List<Attendees__c>getAttendeeCustomerList(){
        return attendeeCustomerList;
    }
    public List<Attendees__c>getAttendeeAccTeamList(){
        return attendeeAccTeamList;
    }
    public Boolean getOldAttendeeFlag(){
        return oldAttendeeFlag;
    }
}