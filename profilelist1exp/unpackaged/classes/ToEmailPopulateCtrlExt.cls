public class ToEmailPopulateCtrlExt {

    public Customer_Engagement__c myCE {get; set;}
    public Customer_Engagement__c CERecord {get; set;}
    public List<Attendees__c> attendeeList = new List<Attendees__c>();
    public List<EmailWrapperCls> attendeesIteratedList = new List<EmailWrapperCls>();
    public String customerEmail {get;set;}
    public String accntTeamEmail {get;set;}
    public String topicExpertEmail {get;set;}
    public String email {get;set;}
    public boolean nullEmailList {get; set;}
    public List<EmailWrapperCls> accntTeamAttendeesList = new List<EmailWrapperCls>();
    public List<EmailWrapperCls> customerAttendeesList = new List<EmailWrapperCls>();
    public List<EmailWrapperCls> topicExpertAttendeesList = new List<EmailWrapperCls>();
    
    public toEmailPopulateCtrlExt(ApexPages.StandardController controller) {
    
        this.myCE = (Customer_Engagement__c)controller.getRecord();
        CERecord = [select Id,Name from Customer_Engagement__c where Id =: myCE.Id];
        
        List<Attendees__c> attendeeList = [select Account_Team__c,Email__c,Account_Team__r.Email,Team_Member__r.External_Resource_Email__c,Team_Member__r.Presenter_Architect_Name__c,Attendee_Name__c,RecordTypeId,RecordType.Name,Account_Team__r.Name
                                                            from Attendees__c where Customer_Engagement__c =: CERecord.Id and (Email__c != null or Team_Member__r.External_Resource_Email__c != null or Account_Team__r.Email != null) and (RecordType.Name = 'Customer' or RecordType.Name = 'Topic Expert' or RecordType.Name = 'Account Team') ];

        attendeesIteratedList = new List<EmailWrapperCls>();
        
        for(Attendees__c Arcd : attendeeList){
                attendeesIteratedList.add(new EmailWrapperCls(Arcd));
        }
        
        nullEmailList = false;
        
        for(Attendees__c al : attendeeList){
            if(al.RecordType.Name == 'Account Team'){
                accntTeamAttendeesList.add(new EmailWrapperCls(al));
            }
            if(al.RecordType.Name == 'Customer'){
                customerAttendeesList.add(new EmailWrapperCls(al));
            } 
            if(al.RecordType.Name == 'Topic Expert'){
                topicExpertAttendeesList.add(new EmailWrapperCls(al));
            }                                   
        }
        
    }

    public class EmailWrapperCls {
        public Attendees__c AttendeesRecord{get;set;}
        public boolean selected{get;set;}
        
        public EmailWrapperCls(Attendees__c attendeeList){
            AttendeesRecord = attendeeList;
            selected = false;
        }
    }
    
    public List<EmailWrapperCls> getattendeesIteratedList () {
        return attendeesIteratedList;
    }
    
    public void setattendeesIteratedList (List<EmailWrapperCls> emlList) {
        this.attendeesIteratedList = emlList;
    }
    
    public List<EmailWrapperCls> getaccntTeamAttendeesList () {
        return accntTeamAttendeesList;
    }
    
    public List<EmailWrapperCls> getcustomerAttendeesList () {
        return customerAttendeesList;
    }
    
    public List<EmailWrapperCls> gettopicExpertAttendeesList () {
        return topicExpertAttendeesList;
    }            
    
    public PageReference selectMail(){

        for(EmailWrapperCls selectedlist : attendeesIteratedList){
            if(selectedlist.selected == true && selectedlist.AttendeesRecord.Email__c != null && selectedlist.AttendeesRecord.RecordType.Name == 'Customer' ){
                if(CustomerEmail == null){
                    CustomerEmail = selectedlist.AttendeesRecord.Email__c;
                }else{
                    CustomerEmail = CustomerEmail+';'+selectedlist.AttendeesRecord.Email__c;
                }
            }
            if(selectedlist.selected == true && selectedlist.AttendeesRecord.Account_Team__r.Email != null && selectedlist.AttendeesRecord.RecordType.Name == 'Account Team' ){
                if(accntTeamEmail == null){
                    accntTeamEmail = selectedlist.AttendeesRecord.Account_Team__r.Email;
                }else{
                    accntTeamEmail = accntTeamEmail +';'+selectedlist.AttendeesRecord.Account_Team__r.Email;
                }
            } 
            
            //if(selectedlist.selected == true && selectedlist.AttendeesRecord.Account_Team__r.Email != null && selectedlist.AttendeesRecord.RecordType.Name == 'Topic Expert' ){        //Populating Email to "Additional To" 
            if(selectedlist.selected == true && selectedlist.AttendeesRecord.Email__c != null && selectedlist.AttendeesRecord.RecordType.Name == 'Topic Expert' ){
                if(topicExpertEmail == null){
                    //topicExpertEmail = selectedlist.AttendeesRecord.Account_Team__r.Email;        //Populating Email to "Additional To" 
                    topicExpertEmail = selectedlist.AttendeesRecord.Email__c;
                }else{
                    //topicExpertEmail = topicExpertEmail +';'+selectedlist.AttendeesRecord.Account_Team__r.Email;        //Populating Email to "Additional To" 
                    topicExpertEmail = topicExpertEmail +';'+selectedlist.AttendeesRecord.Email__c;
                }
            }            
            if(accntTeamEmail == null && CustomerEmail != null && topicExpertEmail == null){
                email = CustomerEmail;
            }else if(accntTeamEmail != null && CustomerEmail == null && topicExpertEmail == null){
                email = accntTeamEmail;
            }else if(accntTeamEmail == null && CustomerEmail == null && topicExpertEmail != null){
                email = topicExpertEmail;
            }else if(accntTeamEmail == null && CustomerEmail != null && topicExpertEmail != null){
                email = CustomerEmail +';'+topicExpertEmail;
            }else if(accntTeamEmail != null && CustomerEmail != null && topicExpertEmail == null){
                email = accntTeamEmail +';'+CustomerEmail;
            }else if(accntTeamEmail != null && CustomerEmail == null && topicExpertEmail != null){
                email = accntTeamEmail +';'+topicExpertEmail;
            }else{
                email = CustomerEmail +';'+accntTeamEmail +';'+topicExpertEmail;
            }
        }
        
        if (accntTeamEmail == null && CustomerEmail == null && topicExpertEmail == null){
            nullEmailList = true;
            return null;
        }  
                      
        return new PageReference('/_ui/core/email/author/EmailAuthor?p3_lkid='+CERecord.Id+'&retURL=%2F'+CERecord.Id+'&p24='+email);

    } 
    public PageReference continueTo(){
        return new PageReference('/_ui/core/email/author/EmailAuthor?p3_lkid='+CERecord.Id+'&retURL=%2F'+CERecord.Id);
    }
    
}