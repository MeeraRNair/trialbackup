/*-------------------------------------------------------------------------
Description: Class  for submitting Customer Engagement record
CR #5761
Version:1.0 

History:
    
Author: 

--------------------------------------------------------------------------*/
public class CustomerEngagementSubmitCtrl{

    //Class Variables
    public Customer_Engagement__c custEngageObj;
    List<Attendees__c> listOfAttendees = new List<Attendees__c>();
    List<Attending_Accounts__c> listOfAccounts =new List<Attending_Accounts__c>();
    List<Agenda_Topic__c> listOfAgendaTopics = new List<Agenda_Topic__c>();
    List<Calendar_Management__c> listOfCalMgmt = new List<Calendar_Management__c>();
    Calendar_Management__c calendarManagement = new Calendar_Management__c();
    List<Calendar_Management__c> lstcalendarManagement = new List<Calendar_Management__c>();
    public boolean Info{get;set;}
    public boolean Error{get;set;}
    
    
    //Constructor
    public CustomerEngagementSubmitCtrl(ApexPages.StandardController controller){
        custEngageObj = (Customer_Engagement__c)controller.getRecord(); 
       
        List<Customer_Engagement__c> custEngageRecordList = [SELECT Id, Event_Status__c, RecordTypeId, 
                                                             Calendar_Management__c, Submitted_Date__c 
                                                             FROM Customer_Engagement__c 
                                                             WHERE Id =: custEngageObj.Id LIMIT 1]; 
        if (custEngageRecordList.isEmpty()){
            showError('Could not find a valid Customer Engagement Record');
            return;
        }
        custEngageObj = custEngageRecordList[0];
        listOfAttendees = [SELECT Name, Dell_Internal_Attendee__c, Customer_Engagement__c, 
                           Customer_Attendee__c, Account_Team__c FROM Attendees__c 
                           WHERE Customer_Engagement__c =: custEngageObj.Id];
        listOfAccounts = [SELECT Name FROM Attending_Accounts__c 
                           WHERE Customer_Engagement__c =: custEngageObj.Id];

        listOfAgendaTopics = [SELECT Topics__c, Name, Customer_Engagement__c, Agenda__c 
                              FROM Agenda_Topic__c 
                              WHERE Customer_Engagement__c =: custEngageObj.Id];
        lstcalendarManagement = [SELECT Id, Status__c FROM Calendar_Management__c 
                                WHERE Id =:custEngageObj.Calendar_Management__c and recordType.name='Primary Calendar RT' ];
        
    }//End of Constructor
    
    //Method to process EBC request
    public PageReference validateRelatedLists(){
        if(lstcalendarManagement.size() > 0) {
            if(lstcalendarManagement[0].Status__c == 'Expired'){
                showInfo('The Calendar Management Record is already Expired.');
                return null;
            }else{
                if(lstcalendarManagement[0]!=null ){
                    listOfCalMgmt = [SELECT Start_Date__c, Site__c, Room__c, Calendar_Management_Record_ID__c, CE_Event_Type__c,
                                 Customer_Engagement_Event__c, Status__c 
                                 FROM Calendar_Management__c 
                                 WHERE Calendar_Management_Record_ID__c =: lstcalendarManagement[0].Id and
                                 Status__c != 'Expired'];
                
                    if(listOfAccounts .size() > 0 && custEngageObj.Calendar_Management__c != null) {
                    
                        if(custEngageObj.Event_Status__c == 'Pending'){
                            if(lstcalendarManagement[0].Status__c=='Waitlisted'){
                                custEngageObj.Event_Status__c = lstcalendarManagement[0].Status__c;
                            }else{
                                for(Integer i=0; i<listOfCalMgmt.size(); i++){
                                    listOfCalMgmt[i].Status__c = 'Scheduled';
                                }
                                lstcalendarManagement[0].Status__c='Scheduled';
                                custEngageObj.Event_Status__c = 'Requested';
                                listOfCalMgmt.add(lstcalendarManagement[0]);
                                update listOfCalMgmt;
                            }
                            custEngageObj.Submitted_Date__c = System.today();
                            update custEngageObj;
                            showInfo('Your request has been submitted.');
                            return null;
                        }else if(custEngageObj.Event_Status__c == 'Requested'){
                            showInfo('Your request has already been submitted.');
                            return null;
                        }else if(custEngageObj.Event_Status__c == 'Completed' || custEngageObj.Event_Status__c == 'Canceled' ||
                            custEngageObj.Event_Status__c == 'Scheduled' || custEngageObj.Event_Status__c == 'Assigned'  || 
                            custEngageObj.Event_Status__c == 'Confirmed'){
                            showInfo('This request is already processed, you will not be able to submit again.');
                            return null;
                        }else if(custEngageObj.Event_Status__c == 'Waitlisted'){
                            showInfo('Your request is on the waitlist, you will be contacted by the scheduler for availability.');
                            return null;
                        }
                    }
                    else{
                        showError('Either Calendar Management and Attending Accounts have not been added. Please verify.');
                        return null;
                    }
                }
            }
        } else{
            showError('Either Calendar Management and Attending Accounts have not been added. Please verify.');
            return null;
        }
        return new PageReference('/'+ custEngageObj.Id);
    }//End of validateRelatedLists()
   
    //Method to add info message to Page
    private void showInfo (String errorMessage){
        PageUtils.addInfo(errorMessage);
        Info = true;    
    }//End of showInfo()
    
    
    //Method to add error message to Page
    private void showError (String errorMessage){
        PageUtils.addError(errorMessage);
        Error = true;
    }//End of showError()
    
}//End of Class