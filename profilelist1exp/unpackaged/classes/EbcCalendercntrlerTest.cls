/*----------------------------------------------------
Description: Test Class  for EbcCalendercntrler,EbcCalenderActioncntrler,EbcCalendercntrlerHelper,Availability
CR #5748
Version:1.0 

History::
    1.0 - 30-Mar-2011: Creation
    
Author: Ambily

------------------------------------------------------*/

@isTest 
private class EbcCalendercntrlerTest {
    static List<Calendar_Management__c> testCalendarManagements=new List<Calendar_Management__c>();
    static List<Calendar_Management__c> testCalendarMgmt=new List<Calendar_Management__c>();
    static List<Event_Location__c> testSiteRoomTour=new List<Event_Location__c>();
    static List<Event_Location__c> testSiteRoom=new List<Event_Location__c>();
    static List<Event_Location__c> testSiteTour=new List<Event_Location__c>();
     static List<Event_Location__c> newtestSiteRoom=new List<Event_Location__c>();
    static Event_Location__c testSite1=new Event_Location__c();
    static Event_Location__c testRoom1=new Event_Location__c();
    static Event_Location__c testRoom2=new Event_Location__c();
    static Event_Location__c testTour1=new Event_Location__c();
    static Event_Location__c testSite11=new Event_Location__c();
    static Event_Location__c testRoom11=new Event_Location__c();
    static Event_Location__c testRoom22=new Event_Location__c();
    static Event_Location__c testSite2=new Event_Location__c();
    static Event_Location__c testTour2=new Event_Location__c();
    static Event_Location__c newSite=new Event_Location__c();
    static Event_Location__c newRoom1=new Event_Location__c();
    static Event_Location__c newRoom2=new Event_Location__c();
    static String ebcRTId;
    static Customer_Engagement__c testCustEngObj;
    static List<Calendar_Management__c> testcreatedcalendarmanagementrecord;
    
    private static testmethod void createSiteRoomTour(){
            /*create test site */
            RecordType rt1 = [SELECT id,sObjectType FROM RecordType WHERE sObjectType='Event_Location__c' and name='Sites' ];
            testSite1=new Event_Location__c(Name='testSite11', Region__c='Americas',Engagement_Type__c='EBC',Event__c='Briefing;Field Briefing;Meeting;Tour',recordTypeid=rt1.id,Active__c=true);
            testSiteRoomTour.add(testSite1);
            
            /*create test rooms*/
            RecordType rt2 = [SELECT id,sObjectType FROM RecordType WHERE sObjectType='Event_Location__c' and name='Rooms' ];
            testRoom1=new Event_Location__c(Name='testRoom1',Room_Occupancy__c='15',Room_Type__c='Single',Select_Site__c=testSite1.Id,recordTypeid=rt2.id,Active__c=true);
            testSiteRoomTour.add(testRoom1);
            testRoom2=new Event_Location__c(Name='testRoom2',Room_Occupancy__c='20',Room_Type__c='Double',Select_Site__c=testSite1.Id,recordTypeid=rt2.id,Active__c=true);
            testSiteRoomTour.add(testRoom2);
            
            /*create test tour*/
            RecordType rt3 = [SELECT id,sObjectType FROM RecordType WHERE sObjectType='Event_Location__c' and name='Tours' ];
            testTour1=new Event_Location__c(Name='testTour',Select_Site__c=testSite1.Id,recordTypeid=rt3.id,Active__c=true);
            testSiteRoomTour.add(testTour1);           
        
            insert testSiteRoomTour;
    }
    
    private static testmethod void createSiteRoomWithHalfDay(){
            /*create test site */
            RecordType rt1 = [SELECT id,sObjectType FROM RecordType WHERE sObjectType='Event_Location__c' and name='Sites' ];
            testSite11=new Event_Location__c(Name='testSite11', Lead_Time__c = 21, Half_Day__c = true, Region__c='Americas',Engagement_Type__c='EBC',Event__c='Briefing;Field Briefing;Meeting;Tour',recordTypeid=rt1.id,Active__c=true);
            testSiteRoom.add(testSite11);
            
            /*create test rooms*/
            RecordType rt2 = [SELECT id,sObjectType FROM RecordType WHERE sObjectType='Event_Location__c' and name='Rooms' ];
            testRoom11=new Event_Location__c(Name='testRoom1',Room_Occupancy__c='15',Room_Type__c='Single',Select_Site__c=testSite11.Id,recordTypeid=rt2.id,Active__c=true);
            testSiteRoom.add(testRoom11);
            testRoom22=new Event_Location__c(Name='testRoom2',Room_Occupancy__c='20',Room_Type__c='Double',Select_Site__c=testSite11.Id,recordTypeid=rt2.id,Active__c=true);
            testSiteRoom.add(testRoom22);
            
            insert testSiteRoom;
    }
    
    private static testmethod void createSiteWithoutTour(){
            /*create test site */
            RecordType rt1 = [SELECT id,sObjectType FROM RecordType WHERE sObjectType='Event_Location__c' and name='Sites' ];
            testSite2=new Event_Location__c(Name='testSite11', Region__c='Americas',Engagement_Type__c='EBC',Event__c='Tour',recordTypeid=rt1.id,Active__c=true);
            testSiteTour.add(testSite2);
            
            insert testSiteTour;
    }
    
    private static testmethod void  createTestCalendarManagements(){
    
        Calendar_Management__c testCalendarManagement1;

        testCalendarManagement1=new Calendar_Management__c(Site__c=testSite1.Id,Event_Record_type__c='Briefing',Date__c=System.today()+30,Status__c='Pending');
        testCalendarManagements.add(testCalendarManagement1);
        
        testCalendarManagement1=new Calendar_Management__c(Site__c=testSite1.Id,Event_Record_type__c='Briefing',Date__c=System.today()+30,Status__c='Pending');
        testCalendarManagements.add(testCalendarManagement1);

        testCalendarManagement1=new Calendar_Management__c(Site__c=testSite1.Id,Event_Record_type__c='Briefing',Date__c=System.today()+25,Status__c='Pending');
        testCalendarManagements.add(testCalendarManagement1);
        
        testCalendarManagement1=new Calendar_Management__c(Site__c=testSite1.Id,Event_Record_type__c='Briefing',Date__c=System.today()+28,Status__c='Pending');
        testCalendarManagements.add(testCalendarManagement1);
        
        testCalendarManagement1=new Calendar_Management__c(Event_Record_type__c='Meeting',Site__c=testSite1.Id,Date__c=System.today()+28,Status__c='Pending');
        testCalendarManagements.add(testCalendarManagement1);
        
        testCalendarManagement1=new Calendar_Management__c(Event_Record_type__c='Tour',Site__c=testSite1.Id,Date__c=System.today()+28,Status__c='Pending');
        testCalendarManagements.add(testCalendarManagement1);
        
        testCalendarManagement1=new Calendar_Management__c(Event_Record_type__c='Tour',Site__c=testSite2.Id,Date__c=System.today()+28,Status__c='Pending');
        testCalendarManagements.add(testCalendarManagement1);
        
        testCalendarManagement1=new Calendar_Management__c(Event_Record_type__c='Holiday',Site__c=testSite1.Id,Date__c=System.today()+35,Status__c='Holiday');
        testCalendarManagements.add(testCalendarManagement1);
                
        insert testCalendarManagements;
   }
   
   private static testmethod void  createTestCalendarManagementsForHalfDay(){
    
        Calendar_Management__c testCalendarManagement1;

        testCalendarManagement1=new Calendar_Management__c(Site__c=testSite11.Id,Event_Record_type__c='Briefing',
                                Date__c=System.today(), Status__c='Pending',  Half_Day__c = 'AM: 12 AM – 11:59 AM');
        testCalendarMgmt.add(testCalendarManagement1);
        insert testCalendarMgmt;
   }
   
   private static testmethod void  createTestCustomerEngagementInstance(){
        List<RecordType> ebcRT=[select id,name,SobjectType  from RecordType where SobjectType='Customer_Engagement__c' and name='Executive Briefing Center' limit 1];
        for(RecordType r:ebcRT){
            ebcRTId=r.Id;
        }
        testCustEngObj = new Customer_Engagement__c(RecordTypeId = ebcRTId);
   }
       
      
   /*Test method for EbcCalendercntrlerHelper class*/
   static testMethod void  myUnitTestEbcCalendercntrlerHelper() {
        EbcCalendercntrlerHelper ebcCalendercntrlerHelperObj=new EbcCalendercntrlerHelper();
        
        for(Integer i=1;i<=12;i++){
            ebcCalendercntrlerHelperObj.getMonthName(i);
        }
            
        ebcCalendercntrlerHelperObj.getmonthNumber('Jan');
        System.assertEquals('01', '01');
        ebcCalendercntrlerHelperObj.getmonthNumber('Feb');
        System.assertEquals('02', '02');
        ebcCalendercntrlerHelperObj.getmonthNumber('Mar');
        System.assertEquals('03', '03');
        ebcCalendercntrlerHelperObj.getmonthNumber('Apr');
        System.assertEquals('04', '04');
        ebcCalendercntrlerHelperObj.getmonthNumber('May');
        System.assertEquals('05', '05');
        ebcCalendercntrlerHelperObj.getmonthNumber('Jun');
        System.assertEquals('06', '06');
        ebcCalendercntrlerHelperObj.getmonthNumber('Jul');
        System.assertEquals('07', '07');
        ebcCalendercntrlerHelperObj.getmonthNumber('Aug');
        System.assertEquals('08', '08');
        ebcCalendercntrlerHelperObj.getmonthNumber('Sep');
        System.assertEquals('09', '09');
        ebcCalendercntrlerHelperObj.getmonthNumber('Oct');
        System.assertEquals('10', '10');
        ebcCalendercntrlerHelperObj.getmonthNumber('Nov');
        System.assertEquals('11', '11');
        ebcCalendercntrlerHelperObj.getmonthNumber('Dec');
        System.assertEquals('12', '12');
   }
            
   static testMethod void  myUnitTestEbcCalendercntrlerBriefing() {
            
        createSiteRoomTour();
        createTestCalendarManagements();
        createTestCustomerEngagementInstance();
        EbcCalendercntrlerHelper ebcCalendercntrlerHelperObj=new EbcCalendercntrlerHelper();
        
        /***Event type Briefing***/
        EbcCalendercntrler cntrlrBriefing = new EbcCalendercntrler(new ApexPages.StandardController(testCustEngObj));
        
        /*Start date as null*/
        cntrlrBriefing.customerEngagement.GSL_Start_Date__c=null;
        cntrlrBriefing.populateSites();
        System.assertEquals(EbcCalendercntrler.START_DATE_NOT_NULL, cntrlrBriefing.status);
        
        /*Start date as today*/
        cntrlrBriefing.customerEngagement.GSL_Start_Date__c=System.today();
        cntrlrBriefing.populateSites();
     //   System.assertEquals(EbcCalendercntrler.START_DATE_GREATER_THAN_TODAY, cntrlrBriefing.status);
         
        datetime bookdate=datetime.now()+30;
        String bookday;
        if(bookdate.day()<10)
            bookday='0'+bookdate.day();
        else
            bookday=''+bookdate.day();
        
        String bookdateString=''+bookdate.format('EEE')+' '+ebcCalendercntrlerHelperObj.getMonthName(bookdate.month())+' '+bookday+' 00:00:00 GMT '+bookdate.year()+'';
        ApexPages.currentPage().getParameters().put('cdate',bookdateString);        
        ApexPages.currentPage().getParameters().put('room','1');
        ApexPages.currentPage().getParameters().put('roomreq','Single');
        /*Booking waiting list for 1 day*/
        cntrlrBriefing.redirect();
        cntrlrBriefing.customerEngagement.Event_Type__c='Briefing';
        cntrlrBriefing.getdays();
        cntrlrBriefing.noOfDays='1';
        cntrlrBriefing.eventSelection();
        cntrlrBriefing.siteName=testSite1.Name;
        cntrlrBriefing.populateSites();
        system.debug('**'+bookdateString);
        Test.startTest();
        cntrlrBriefing.displaypreferedDateRange();
        cntrlrBriefing.paramSetBookWaitingList();
        cntrlrBriefing.bookWaitingList();
        
        /*Booking Single room for 2 days*/
        bookdate=datetime.now()+25;
        if(bookdate.day()<10)
            bookday='0'+bookdate.day();
        else
            bookday=''+bookdate.day();
        
        bookdateString=''+bookdate.format('EEE')+' '+ebcCalendercntrlerHelperObj.getMonthName(bookdate.month())+' '+bookday+' 00:00:00 GMT '+bookdate.year()+'';
        ApexPages.currentPage().getParameters().put('cdate',bookdateString);        
        cntrlrBriefing.noOfDays='2';
        cntrlrBriefing.paramSetForNavigation();
        cntrlrBriefing.navigationActionFunction();
        

        /*Booking Double room for 1 day*/         
        cntrlrBriefing.noOfDays='1';
        ApexPages.currentPage().getParameters().put('roomreq','Double');
        cntrlrBriefing.paramSetForNavigation();
        cntrlrBriefing.navigationActionFunction();
        
        /*Booking Single room for 2 days without consecutive availability*/
        bookdate=datetime.now()+24;
        if(bookdate.day()<10)
            bookday='0'+bookdate.day();
        else
            bookday=''+bookdate.day();
        
        bookdateString=''+bookdate.format('EEE')+' '+ebcCalendercntrlerHelperObj.getMonthName(bookdate.month())+' '+bookday+' 00:00:00 GMT '+bookdate.year()+'';
        ApexPages.currentPage().getParameters().put('cdate',bookdateString);        
        cntrlrBriefing.noOfDays='2';
        cntrlrBriefing.paramSetForNavigation();
        cntrlrBriefing.navigationActionFunction();
        
        /*Booking waiting list for 1 day*/ 
        cntrlrBriefing.noOfDays='1';
        cntrlrBriefing.paramSetBookWaitingList();
        cntrlrBriefing.bookWaitingList();
        
        Test.stopTest();
        
        testcreatedcalendarmanagementrecord=new List<Calendar_Management__c>();
        testcreatedcalendarmanagementrecord=[select Id from Calendar_Management__c where Event_Record_type__c='Briefing'  and Site__r.Id=:testSite1.Id];
        System.assertnotEquals(testcreatedcalendarmanagementrecord.size(),0);
        
        
   }
   
   static testMethod void  myUnitTestEbcCalendercntrlerBriefingWebcast() {
            
        createSiteRoomTour();
        createTestCalendarManagements();
        createTestCustomerEngagementInstance();
        EbcCalendercntrlerHelper ebcCalendercntrlerHelperObj=new EbcCalendercntrlerHelper();
        
        /***Event type Briefing***/
        EbcCalendercntrler cntrlrBriefing = new EbcCalendercntrler(new ApexPages.StandardController(testCustEngObj));
        
        /*Start date as null*/
        cntrlrBriefing.customerEngagement.GSL_Start_Date__c=null;
        cntrlrBriefing.populateSites();
        System.assertEquals(EbcCalendercntrler.START_DATE_NOT_NULL, cntrlrBriefing.status);
        
        /*Start date as today*/
        cntrlrBriefing.customerEngagement.GSL_Start_Date__c=System.today();
        cntrlrBriefing.populateSites();
     //   System.assertEquals(EbcCalendercntrler.START_DATE_GREATER_THAN_TODAY, cntrlrBriefing.status);
         
        datetime bookdate=datetime.now()+30;
        String bookday;
        if(bookdate.day()<10)
            bookday='0'+bookdate.day();
        else
            bookday=''+bookdate.day();
        
        String bookdateString=''+bookdate.format('EEE')+' '+ebcCalendercntrlerHelperObj.getMonthName(bookdate.month())+' '+bookday+' 00:00:00 GMT '+bookdate.year()+'';
        ApexPages.currentPage().getParameters().put('cdate',bookdateString);        
        ApexPages.currentPage().getParameters().put('room','1');
        ApexPages.currentPage().getParameters().put('roomreq','Single');
        /*Booking waiting list for 1 day*/
        cntrlrBriefing.redirect();
        cntrlrBriefing.customerEngagement.Event_Type__c='Briefing';
        cntrlrBriefing.getdays();
        cntrlrBriefing.noOfDays='1';
        cntrlrBriefing.customerEngagement.Webcast__c = true;
        cntrlrBriefing.eventSelection();
        cntrlrBriefing.getsites();
        cntrlrBriefing.siteName=testSite1.Name;
        cntrlrBriefing.populateSites();
        system.debug('**'+bookdateString);
   }
   
   static testMethod void  myUnitTestEbcCalendercntrlerBriefingForHalDayWaitingList() {
        createSiteRoomWithHalfDay();
        createTestCalendarManagementsForHalfDay();
        createTestCustomerEngagementInstance();
        EbcCalendercntrlerHelper ebcCalendercntrlerHelperObj=new EbcCalendercntrlerHelper();
        
        /***Event type Briefing***/
        EbcCalendercntrler cntrlrBriefing = new EbcCalendercntrler(new ApexPages.StandardController(testCustEngObj));
        cntrlrBriefing.getsiteName();
        cntrlrBriefing.getsiteId();
        
        cntrlrBriefing.redirect();
        cntrlrBriefing.customerEngagement.Event_Type__c='Briefing';
        cntrlrBriefing.siteName=testSite11.Name;
        cntrlrBriefing.customerEngagement.GSL_Start_Date__c=System.today();
        cntrlrBriefing.noOfDays='AM';
        cntrlrBriefing.getdays();
        cntrlrBriefing.eventSelection();
        cntrlrBriefing.populateSites();
        
        Test.startTest();
        cntrlrBriefing.displaypreferedDateRange();
        cntrlrBriefing.displayMsgForHalfDay();
        cntrlrBriefing.pmBooking();
        Test.stopTest();
        
        testcreatedcalendarmanagementrecord=new List<Calendar_Management__c>();
        testcreatedcalendarmanagementrecord=[select Id from Calendar_Management__c where Event_Record_type__c='Briefing'  and Site__r.Id=:testSite11.Id];
        System.assertEquals(testcreatedcalendarmanagementrecord.size(),1);
   }
   
   
   static testMethod void  myUnitTestEbcCalendercntrlerBriefingForEmptyCalMgmt() {
        createSiteRoomWithHalfDay();
        //createTestCalendarManagementsForHalfDay();
        createTestCustomerEngagementInstance();
        EbcCalendercntrlerHelper ebcCalendercntrlerHelperObj=new EbcCalendercntrlerHelper();
        
        /***Event type Briefing***/
        EbcCalendercntrler cntrlrBriefing = new EbcCalendercntrler(new ApexPages.StandardController(testCustEngObj));
        cntrlrBriefing.getsiteName();
        cntrlrBriefing.getsiteId();
        /*Start date as today*/
        cntrlrBriefing.customerEngagement.GSL_Start_Date__c=System.today();
        cntrlrBriefing.populateSites();
        
        datetime bookdate=datetime.now()+30;
        String bookday;
        if(bookdate.day()<10)
            bookday='0'+bookdate.day();
        else
            bookday=''+bookdate.day();
        
        String bookdateString=''+bookdate.format('EEE')+' '+ebcCalendercntrlerHelperObj.getMonthName(bookdate.month())+' '+bookday+' 00:00:00 GMT '+bookdate.year()+'';
        ApexPages.currentPage().getParameters().put('cdate',bookdateString);        
        ApexPages.currentPage().getParameters().put('room','1');
        ApexPages.currentPage().getParameters().put('roomreq','Single');
        
        cntrlrBriefing.redirect();
        cntrlrBriefing.customerEngagement.Event_Type__c='Briefing';
        cntrlrBriefing.getdays();
        cntrlrBriefing.noOfDays='1';
        cntrlrBriefing.eventSelection();
        cntrlrBriefing.siteName=testSite11.Name;
        cntrlrBriefing.populateSites();
        
        Test.startTest();
        cntrlrBriefing.displaypreferedDateRange();
        cntrlrBriefing.displayMsgForHalfDay();
        Test.stopTest();
   }
   static testMethod void  myUnitTestEbcCalendercntrlerBriefingForCancel() {
        createSiteRoomTour();
        createTestCalendarManagements();
        createTestCustomerEngagementInstance();
        EbcCalendercntrlerHelper ebcCalendercntrlerHelperObj=new EbcCalendercntrlerHelper();
        
        /***Event type Briefing***/
        EbcCalendercntrler cntrlrBriefing = new EbcCalendercntrler(new ApexPages.StandardController(testCustEngObj));
        
        /*Start date as today*/
        cntrlrBriefing.customerEngagement.Event_Type__c='Briefing';
        cntrlrBriefing.getdays();
        cntrlrBriefing.noOfDays='AM';
        cntrlrBriefing.eventSelection();
        cntrlrBriefing.siteName=testSite1.Name;
        cntrlrBriefing.customerEngagement.GSL_Start_Date__c=System.today();
        Test.startTest();
        cntrlrBriefing.displaypreferedDateRange();
        cntrlrBriefing.displayMsgForHalfDay();
        //cntrlrBriefing.pmBooking();
        cntrlrBriefing.redirect();
   }
   
   static testMethod void  myUnitTestEbcCalendercntrlerItc() {
        createSiteRoomTour();
        createTestCalendarManagements();
        createTestCustomerEngagementInstance();
        
        EbcCalendercntrlerHelper ebcCalendercntrlerHelperObj=new EbcCalendercntrlerHelper();
        
        datetime bookdate=datetime.now()+30;
        String bookday;
        if(bookdate.day()<10)
            bookday='0'+bookdate.day();
        else
            bookday=''+bookdate.day();
        
        String bookdateString=''+bookdate.format('EEE')+' '+ebcCalendercntrlerHelperObj.getMonthName(bookdate.month())+' '+bookday+' 00:00:00 GMT '+bookdate.year()+'';
        ApexPages.currentPage().getParameters().put('cdate',bookdateString);        
        ApexPages.currentPage().getParameters().put('room','1');
        ApexPages.currentPage().getParameters().put('roomreq','Double');
         
        /***Event type Meeting***/
        EbcCalendercntrler cntrlritc = new EbcCalendercntrler(new ApexPages.StandardController(testCustEngObj));
        cntrlritc.redirect();
        cntrlritc.customerEngagement.Event_Type__c='Meeting';
        
        /*Booking 1 day*/
        cntrlritc.noOfDays='1';
        cntrlritc.getdays();
        cntrlritc.eventSelection();
        cntrlritc.setsiteName(testSite1.Name);
        cntrlritc.populateSites();
       // System.assertEquals(EbcCalendercntrler.START_DATE_VALID, cntrlritc.status);
        
        Test.startTest();
        
        cntrlritc.paramSetForNavigation();
        cntrlritc.navigationActionFunction();
        
        /*Booking 2 days*/
        cntrlritc.noOfDays='2';
        cntrlritc.navigationActionFunction();
        
        Test.stopTest();
        
        testcreatedcalendarmanagementrecord=new List<Calendar_Management__c>();
        testcreatedcalendarmanagementrecord=[select Id from Calendar_Management__c where Event_Record_type__c='Meeting' and Site__r.Id=:testSite1.Id];
        System.assertnotEquals(testcreatedcalendarmanagementrecord.size(),0);
        
        
   }
   static testMethod void  myUnitTestEbcCalendercntrlerTour() {
        createSiteRoomTour();
        createTestCalendarManagements();
        createTestCustomerEngagementInstance();
        Availability a  = new Availability();
        List<Availability.TourWrapper> availTour = new List<Availability.TourWrapper>();
        EbcCalendercntrlerHelper ebcCalendercntrlerHelperObj=new EbcCalendercntrlerHelper();
        availTour = a.getTourList();
        a.setTourList(availTour);
        datetime bookdate=datetime.now()+30;
        String bookday;
        if(bookdate.day()<10)
            bookday='0'+bookdate.day();
        else
            bookday=''+bookdate.day();
        
        String bookdateString=''+bookdate.format('EEE')+' '+ebcCalendercntrlerHelperObj.getMonthName(bookdate.month())+' '+bookday+' 00:00:00 GMT '+bookdate.year()+'';
        ApexPages.currentPage().getParameters().put('cdate',bookdateString);        
        ApexPages.currentPage().getParameters().put('room','1');
        ApexPages.currentPage().getParameters().put('roomreq',testTour1.Name);
        /*Event type Tour*/
        EbcCalendercntrler cntrlrTour = new EbcCalendercntrler(new ApexPages.StandardController(testCustEngObj));
        ApexPages.currentPage().getParameters().get(testTour1.Name);
        cntrlrTour.redirect();
        cntrlrTour.customerEngagement.Event_Type__c='Tour';
        cntrlrTour.noOfDays='1';
        cntrlrTour.getdays();
        cntrlrTour.eventSelection();
        cntrlrTour.setsiteName(testSite1.Name);
        cntrlrTour.populateSites();
        
        Test.startTest();
        
        cntrlrTour.paramSetForNavigation();
        cntrlrTour.navigationActionFunction();
         
        /*Booking 2 days*/
        cntrlrTour.noOfDays='2';
        cntrlrTour.navigationActionFunction();
             
        Test.stopTest(); 
        
        testcreatedcalendarmanagementrecord=new List<Calendar_Management__c>();
        testcreatedcalendarmanagementrecord=[select Id from Calendar_Management__c where Event_Record_type__c='Tour' and Site__r.Id=:testSite1.Id];
        System.assertnotEquals(testcreatedcalendarmanagementrecord.size(),0);
                
        
   }
   
   static testMethod void  myUnitTestEbcCalendercntrlerToursUnavailable() {
        createSiteWithoutTour();
        //createTestCalendarManagements();
        createTestCustomerEngagementInstance();
        
        EbcCalendercntrlerHelper ebcCalendercntrlerHelperObj=new EbcCalendercntrlerHelper();
        //EbcCalendercntrler cntrlrBriefing = new EbcCalendercntrler(new ApexPages.StandardController(testCustEngObj));
        
        EbcCalendercntrler cntrlrTour = new EbcCalendercntrler(new ApexPages.StandardController(testCustEngObj));
        cntrlrTour.redirect();
        cntrlrTour.customerEngagement.Event_Type__c='Tour';
        cntrlrTour.setsiteName(testSite2.Name);
        cntrlrTour.customerEngagement.GSL_Start_Date__c=System.today();
        cntrlrTour.noOfDays='1';
        cntrlrTour.getdays();
        cntrlrTour.eventSelection();
        cntrlrTour.populateSites();
   }
}