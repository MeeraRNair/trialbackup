@isTest
private class ToEmailPopulateCtrlExtTest {
    
    static Customer_Engagement__c CEObj = new Customer_Engagement__c();
    static Attendees__c Attendeeobj = new Attendees__c();
    static Attendees__c ATAttendeeobj = new Attendees__c();
    static Attendees__c TEAttendeeobj = new Attendees__c();  
    
    public static void createData(){

       RecordType CustomerRT = [Select Name, Id 
                                   From RecordType
                                   where sObjectType='Attendees__c' and name='Customer' limit 1];

       RecordType AccountTeamRT = [Select Name, Id 
                                   From RecordType
                                   where sObjectType='Attendees__c' and name='Account Team' limit 1]; 

       RecordType TopicExpertRT = [Select Name, Id 
                                   From RecordType
                                   where sObjectType='Attendees__c' and name='Topic Expert' limit 1];                                                                      
                                   
        CEObj.name = 'Customer Engagement';
        
        insert CEObj;
        
        Attendeeobj.Email__c = 'test@b.c';
        Attendeeobj.Attendee_Name__c = 'TestName';
        Attendeeobj.RecordTypeId = CustomerRT.Id;
        Attendeeobj.Customer_Engagement__c = CEObj.Id;
        
        insert Attendeeobj;

        ATAttendeeobj.Email__c = 'test@b.c';
        ATAttendeeobj.Attendee_Name__c = 'TestName';
        ATAttendeeobj.RecordTypeId = AccountTeamRT.Id;
        ATAttendeeobj.Customer_Engagement__c = CEObj.Id;
        
        insert ATAttendeeobj;
        
        TEAttendeeobj.Email__c = 'test@b.c';
        TEAttendeeobj.Attendee_Name__c = 'TestName';
        TEAttendeeobj.RecordTypeId = TopicExpertRT.Id;
        TEAttendeeobj.Customer_Engagement__c = CEObj.Id;
        
        insert TEAttendeeobj;                 

    }
    
    static testMethod void testToEmailPopulate(){
        
        createdata();
        
        List<ToEmailPopulateCtrlExt.EmailWrapperCls> attendeesIteratedList = new List<ToEmailPopulateCtrlExt.EmailWrapperCls>();
        ToEmailPopulateCtrlExt.EmailWrapperCls wrapperElt = new ToEmailPopulateCtrlExt.EmailWrapperCls(Attendeeobj);
        ToEmailPopulateCtrlExt.EmailWrapperCls ATwrapperElt = new ToEmailPopulateCtrlExt.EmailWrapperCls(ATAttendeeobj);
        ToEmailPopulateCtrlExt.EmailWrapperCls TEwrapperElt = new ToEmailPopulateCtrlExt.EmailWrapperCls(TEAttendeeobj);
        wrapperElt.selected = true;
        ATwrapperElt.selected = true;
        TEwrapperElt.selected = true;
        attendeesIteratedList.add(wrapperElt); 
        attendeesIteratedList.add(ATwrapperElt); 
        attendeesIteratedList.add(TEwrapperElt);         
        
        PageReference pref = Page.ToEmailPopulate;
        pref.getParameters().put('id',CEObj.id);
        Test.setCurrentPage(pref);
        ToEmailPopulateCtrlExt con = new ToEmailPopulateCtrlExt(new ApexPages.StandardController(CEObj));
        List<ToEmailPopulateCtrlExt.EmailWrapperCls> listElt=con.getattendeesIteratedList(); 
        pref = con.selectMail();
        pref = con.continueTo();
        con.getaccntTeamAttendeesList(); 
        con.getcustomerAttendeesList();
        con.gettopicExpertAttendeesList();
        con.setattendeesIteratedList(attendeesIteratedList);

    }
    
}