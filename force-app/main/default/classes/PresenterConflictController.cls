/**********************************************************************************************
 * Name         : PresenterConflictController 
 * Description  : Class  for listing Topic Experts for a topic and identify
                  presenter clashes.(CR #6368)
 * Created      : 23-June-2011
 * Created By   : Dipin/Sandhya

REVISION HISTORY
================

Version     Author      Date            Release#    CR#     Description

-------     ------      ----            --------    ---     -----------

2.0         Impana      24-April-2013   R14.5      8169     Modifications - Dynamic Search of Topic Expert based on the value of the text field 
3.0         Devika      10-Sept-2014    R15.10     10087    Ability to add mutliple Topic Experts.
4.0         Shahiruni   30-May-2016     0701       13183    Story 1557835:Update Topic Experts Selection List Columns - Add Expert_Location__c in query
    
 **********************************************************************************************/

public with sharing class PresenterConflictController {
    public Agenda_Topic__c agendaTopic = new Agenda_Topic__c();
    public List<Agenda_Topic__c> agendaTopicList = new List<Agenda_Topic__c>();
    public List<attendees__c> attendeeList = new List<attendees__c>();
    Topic_Experts__c topicExpSelected = new Topic_Experts__c();
    public List<TopicExpertDetails> topicExpDisplayList = new List<TopicExpertDetails>();
    String agId,topicExpName;
    Id topicExpId;
    Boolean agendaTopicFlag = TRUE;
    Boolean singleCheckBoxFlag = FALSE; 
    Boolean checkAvailabilityFlag = FALSE; 
    Boolean expertSelectFlag  = FALSE;
    private static final Integer PAGE_SIZE=15;
    Topic_Experts__c curXpert;
    Topic_Experts__c newXpert = new Topic_Experts__c();
    List<Topic_Experts__c> listXperts = New List<Topic_Experts__c>();
    List<Topic_Experts__c> listXperts2 = New List<Topic_Experts__c>();
    Boolean rec_found=FALSE;
    Boolean rec_not_found=FALSE;
    public string str;
    public String Xpertinput{get;set;}
    
    /***v3.0 DP***/
    List<Topic_Experts__c> topicExpSelectedList = new List<Topic_Experts__c>();
    List<Id> existingAttendees = new List<Id>();
        
    public PresenterConflictController(){   
        try{
            agId = ApexPages.currentPage().getParameters().get('id');
            agendaTopic = [SELECT Id,Name,Display_Topic_As__c,Starting_Time__c,Ending_Time__c,Topics__c,Customer_Engagement__c,
                                  Customer_Engagement__r.Name, Start_Date__c, Customer_Engagement__r.RecordType.Name 
                           FROM Agenda_Topic__c 
                           WHERE Id= :agId LIMIT 1000]; 
            System.debug('@@@@@@@@@@@'+agendaTopic.Customer_Engagement__r.RecordType.Name); 
              
            // ***Monthly Maint TT - Ajay - 6/6/13 - CR 8349***  
                   
            /**********v3.0 DP Starts*******
            if(agendaTopic.Start_Date__c == null){
                    PageUtils.AddError(' Agenda Topic record does not have Date. Please update the Agenda Topic record.');
                    agendaTopicFlag = FALSE;
            }
            ******* v3.0 DP Ends***********/
            /*
            if(agendaTopic.Customer_Engagement__r.RecordType.name!='Dell Solution Centers'&&
                ((agendaTopic.Starting_Time__c == null)||
                (agendaTopic.Ending_Time__c == null)||
                (agendaTopic.Start_Date__c == null))){
                    PageUtils.AddError('Agenda Topic record does not have Start Time/End Time or Date. Please update the Agenda Topic record. ');
                    agendaTopicFlag = FALSE;
            }*/
            // *** END CR 8349 ***
        }
        catch(Exception e){
           System.debug('Exception occured'+e);
       }
    }
    
    public PageReference Cancel() {
        return PageUtils.redirect('/'+agId);
    }
    
    public Agenda_Topic__c getagendaTopic() {
        return agendaTopic ;            
    }    
      
    public Boolean getagendaTopicFlag (){
        return agendaTopicFlag ;
    }  
                         
    public String TopicName {get; set;}    
    public integer currentPage {get; private set;}
    public integer lastPage {get; private set;}
    public Boolean hasPreviousAndNext; 
    public Boolean hasNext {get; private set;}
    public Boolean hasPrevious {get; private set;}
                                                                   

    public Topic_Experts__c getnewXpert(){
        return newXpert ;
    }
    
    public void setnewXpert(Topic_Experts__c nXpert){
        newXpert = nXpert;
    }
    
    public PageReference searchTopicName(){
        setXpert = NULL;
        currentPage = 0;
        lastPage = 0;
        listXperts = NULL;
        listXperts = (List<Topic_Experts__c>) setXpert.getRecords();
        system.debug('list experts-------------------------------------'+listxperts);
        if (listXperts.size() == 0){
            rec_found=FALSE;
            rec_not_found=TRUE;
        }
        else{
            rec_found=TRUE;
            rec_not_found=FALSE;
        }
        topicExpListSelected();
     
        return null;
    }

    public Boolean getrecord_not_found(){
        return rec_not_found;
    }
    public Boolean getrecord_found(){
        return rec_found;
    }
    
    public List<Topic_Experts__c> getListXperts(){
        if(listXperts==null){
            listXperts= new List<Topic_Experts__c>();
            listXperts = (List<Topic_Experts__c>) setXpert.getRecords();
        }       
        return listXperts;
    }
    
    public PageReference nextXpert(){    
        if (hasNext){
            listXperts=null;
            setXpert.next();
            listXperts = (List<Topic_Experts__c>) setXpert.getRecords();
            topicExpListSelected();          
            currentPage = setXpert.getPageNumber();
        }
        setNextPrevious();
        return null;
    }
    public PageReference previousXpert(){
        if (hasPrevious){
            listXperts=null;
            setXpert.previous();
            listXperts = (List<Topic_Experts__c>) setXpert.getRecords();
            topicExpListSelected();          
            currentPage = setXpert.getPageNumber();
        }
        setNextPrevious();
        return null;
    }
    public void setNextPrevious() {
        if (setXpert.getHasNext()) {
            hasNext = true;
        }
        else {
            hasNext = false;
        }
        if (setXpert.getHasPrevious()) {
            hasPrevious = true; 
        }
        else {
            hasPrevious = false;
        }
    } 
    
    public PageReference startXpert(){    
        listXperts=null;
        setXpert.first();
        listXperts = (List<Topic_Experts__c>) setXpert.getRecords();
        topicExpListSelected();        
        currentPage = setXpert.getPageNumber();
        setNextPrevious();
        return null;
    }
    
    public PageReference endXpert(){
        listXperts=null;
        setXpert.last();
        listXperts = (List<Topic_Experts__c>) setXpert.getRecords();
        topicExpListSelected();   
        currentPage = setXpert.getPageNumber();
        setNextPrevious();
        return null;
    }
       
    public ApexPages.StandardSetController setXpert {
        get{
            if(setXpert == null){
                try{
                    if(agendaTopic.Topics__c <> null){
                        //String query = 'Select Id,Name,Topic_Expert_Name__c,Presenter_Architect_Name__r.Name,Title__c, Type__c,RecordType.Name, Specializing_In__c from Topic_Experts__c';
                        // DP query = query + ' where ' +'InActive__c=FALSE'+' AND '+ 'Specializing_In__c = \'' + agendaTopic.Topics__c+'\'' +' AND '+ 'Presenter_Architect_Name__r.IsActive = True';
                        //query = query + ' where ' +'InActive__c=FALSE'+' AND '+ 'Specializing_In__c = \'' + agendaTopic.Topics__c+'\'' ;                                                           
                        //listXperts2 = Database.query(query);
                        for(Topic_Experts__c TE :[Select Id,Name,RecordTypeId,Topic_Expert_Name__c,Presenter_Architect_Name__r.IsActive,Presenter_Architect_Name__r.Name,Title__c, Type__c,RecordType.Name, Specializing_In__c, Expert_Location__c, Expertise__c from Topic_Experts__c
                                               Where  InActive__c = FALSE AND Specializing_In__c =: agendaTopic.Topics__c ]){
                        
                            if(TE.RecordTypeId == '012A0000000VhLu' && TE.Presenter_Architect_Name__r.IsActive == True){    // Internal Topic Expert        
                              
                                listXperts2.add(TE);  
                            }else{
                                listXperts2.add(TE);                            
                            }
                        
                        }
                                               
                        for(Attendees__c att : [Select Team_Member__c,Agenda_Topic__r.Start_Date__c,Agenda_Topic__r.Starting_Time__c,
                                                Agenda_Topic__r.Ending_Time__c from Attendees__c where Team_Member__r.Specializing_In__c =: agendaTopic.Topics__c 
                                                AND Customer_Engagement__c =: agendaTopic.Customer_Engagement__c ]){
                          if(att.Agenda_Topic__r.Start_Date__c == null){
                            existingAttendees.add(att.Team_Member__c);
                          }else if(att.Agenda_Topic__r.Start_Date__c == agendaTopic.Start_Date__c){
                            if(att.Agenda_Topic__r.Starting_Time__c != null && att.Agenda_Topic__r.Ending_Time__c != null){
                              if((agendaTopic.Starting_Time__c <= att.Agenda_Topic__r.Starting_Time__c && att.Agenda_Topic__r.Starting_Time__c < agendaTopic.Ending_Time__c )||
                                 (att.Agenda_Topic__r.Starting_Time__c <= agendaTopic.Starting_Time__c && agendaTopic.Starting_Time__c < att.Agenda_Topic__r.Ending_Time__c)||
                                 (agendaTopic.Starting_Time__c == att.Agenda_Topic__r.Starting_Time__c && agendaTopic.Ending_Time__c == att.Agenda_Topic__r.Ending_Time__c)){
                                  existingAttendees.add(att.Team_Member__c);
                              }    
                            }else if((att.Agenda_Topic__r.Starting_Time__c == null && att.Agenda_Topic__r.Ending_Time__c == null)||
                              (att.Agenda_Topic__r.Starting_Time__c == null &&  att.Agenda_Topic__r.Ending_Time__c > agendaTopic.Starting_Time__c)||
                              (att.Agenda_Topic__r.Ending_Time__c == null &&  att.Agenda_Topic__r.Starting_Time__c < agendaTopic.Ending_Time__c)                              
                              ){
                                  existingAttendees.add(att.Team_Member__c);                              
                            }  
                          }
                        }
                        system.debug('***'+existingAttendees.size());
                    }    
                    
                    //Shue to add Expert_Location__c                                                
                    setXpert = new ApexPages.StandardSetController(Database.getQueryLocator(
                               [SELECT t.Name, t.Topic_Expert_Name__c,t.Presenter_Architect_Name__r.Name, t.Title__c, t.Id, t.Type__c,t.RecordType.Name,t.Specializing_In__c, t.Expert_Location__c, t.Expertise__c FROM Topic_Experts__c t
                                            WHERE t.id IN :listXperts2 AND t.id NOT IN: existingAttendees ORDER BY Topic_Expert_Name__c ASC LIMIT 1000]));
                 }
                 catch(Exception e){
                     System.debug('Exception occured'+e);
                 }                       
                if(setXpert.getResultSize()>0){
                    this.setXpert.setPageSize(PAGE_SIZE);
                    setNextPrevious();
                    setXpert.last();                    
                    lastPage =  setXpert.getPageNumber(); 
                    setXpert.first();    
                    currentPage = setXpert.getPageNumber();
                }
            }
            return setXpert;
            }
        set;
       }   
        
    /* Wrapper class for checkbox display */
    public class TopicExpertDetails{
        public boolean selected{get;set;}
        public Topic_Experts__c topicExpert{get;set;}
        public TopicExpertDetails(Topic_Experts__c top){
           topicExpert= top; 
           selected = false;
        }
    }
    
    /* Get the selected topics expert ID */   
    public Id getTopicsExpert() {
        //Integer xpertCount = 0; v3.0 DP
        system.debug('topicExpDisplayList'+topicExpDisplayList);
        topicExpSelectedList.clear();
        for (TopicExpertDetails topSelected: topicExpDisplayList){
            if (topSelected.selected == true){
                /* v3.0 DP
                topicExpSelected = topSelected.topicExpert; 
                topicExpId =  topSelected.topicExpert.Id;           
                xpertCount++;
                expertSelectFlag = TRUE;
                */
                topicExpSelectedList.add(topSelected.topicExpert);
            }
         }         
         /*if(xpertCount>1){
            singleCheckBoxFlag = TRUE;  // Checking whether more than one checkbox is cheched at a time
            return null;
        }     
        if(expertSelectFlag == FALSE){
            return null;
        }*/
        //return topicExpSelected.Id;
        system.debug('selected topicExpDisplayList'+topicExpSelectedList);
        return null;
    }
    
    /* To create topic expert list according to the topic selected */
    public void topicExpListSelected() {
           topicExpDisplayList.clear();     
                                            
       /*  Dynamic Search: Topic Expert ---- CR8169  */                                      
       // start
          if(Xpertinput == null||Xpertinput.trim().length()==0){
             for(topic_experts__c topictemp : listXperts){
                topicExpDisplayList.add(new TopicExpertDetails(topictemp));
             }   
          }                                                                           
          else {  
             //for(topic_experts__c topictemp : database.query('Select Id,Name,Topic_Expert_Name__c,InActive__c,Presenter_Architect_Name__r.name,Presenter_Architect_Name__r.firstname,Presenter_Architect_Name__r.lastname,Title__c, Type__c,RecordType.Name, Specializing_In__c from Topic_Experts__c WHERE' + '('+ 'Presenter_Architect_Name__r.firstname like '+'\''+ Xpertinput+'%\'' +' OR '+ 'Presenter_Architect_Name__r.lastname like '+' \'' + Xpertinput+'%\''+' OR '+ 'Topic_Expert_Name__c like '+' \'' + Xpertinput+'%\'' + ')' +' AND '+ 'Specializing_In__c = \'' + agendaTopic.topics__c+'\''+' AND '+ 'InActive__c= FALSE' + ' AND '+ 'Presenter_Architect_Name__r.IsActive = True '+' AND '+ 'ID NOT IN: existingAttendees '+' ORDER BY Topic_Expert_Name__c ASC'))
             for(topic_experts__c topictemp : database.query('Select Id,Name,Presenter_Architect_Name__r.IsActive,RecordTypeId,Topic_Expert_Name__c,InActive__c,Presenter_Architect_Name__r.name,Presenter_Architect_Name__r.firstname,Presenter_Architect_Name__r.lastname,Title__c, Type__c,RecordType.Name, Specializing_In__c, Expert_Location__c, Expertise__c from Topic_Experts__c WHERE' + '('+ 'Presenter_Architect_Name__r.firstname like '+'\''+ Xpertinput+'%\'' +' OR '+ 'Presenter_Architect_Name__r.lastname like '+' \'' + Xpertinput+'%\''+' OR '+ 'Topic_Expert_Name__c like '+' \'' + Xpertinput+'%\'' + ')' +' AND '+ 'Specializing_In__c = \'' + agendaTopic.topics__c+'\''+' AND '+ 'InActive__c= FALSE' + ' ORDER BY Topic_Expert_Name__c ASC'))
             {  
                if(topictemp.RecordTypeId == '012A0000000VhLu' && topictemp.Presenter_Architect_Name__r.IsActive == True){  // Internal Topic Expert        
                              
                    topicExpDisplayList.add(new TopicExpertDetails(topictemp));
                }else{
                    topicExpDisplayList.add(new TopicExpertDetails(topictemp));         
                }
                
                system.debug('topics-------'+topicExpDisplayList);
             }    
          }
       //end   
                                                                                                           
       /* for(topic_experts__c topictemp : listXperts){
                  topicExpDisplayList.add(new TopicExpertDetails(topictemp));     
        }*/
            
    }
    public List<TopicExpertDetails> getTopicExpDisplayList(){
        return topicExpDisplayList;
    }
    
    //Method to check availabilty of the presenter
    public PageReference checkAvailability(){
        Boolean attendeeEmptyFlag = FALSE; 
        Boolean presenterConflictFlag = FALSE; 
        checkAvailabilityFlag = FALSE;
        singleCheckBoxFlag  = FALSE;
        expertSelectFlag = FALSE;
        //Id topicExpId ;
        getTopicsExpert(); //Get the Topic expert record which is checked
        system.debug('topicExpId '+topicExpId );
        system.debug('singleCheckBoxFlag '+singleCheckBoxFlag );
        system.debug('expertSelectFlag '+expertSelectFlag );
        
        /*if((topicExpId != null)  &&(singleCheckBoxFlag != TRUE) &&(expertSelectFlag != FALSE)){ v3.0 DP */
        if(!topicExpSelectedList.isEmpty()){
        
          /* v3.0 DP String topicName=pageUtils.encodeVariable(agendaTopic.Name);
          String ceName=pageUtils.encodeVariable(agendaTopic.Customer_Engagement__r.Name);
          string topicExpName=pageUtils.encodeVariable(topicExpSelected.Name); */
                      
        
          attendeeList = [SELECT Team_Member__c, Name, Agenda_Topic__c 
                          // v3.0 DP FROM Attendees__c WHERE  Agenda_Topic__r.Start_Date__c=:agendaTopic.Start_Date__c and Team_Member__c=:topicExpId LIMIT 1000];      
                          FROM Attendees__c WHERE  Agenda_Topic__r.Start_Date__c=:agendaTopic.Start_Date__c and Team_Member__c IN : topicExpSelectedList LIMIT 1000];      
           
            if(attendeeList.isEmpty()){
                attendeeEmptyFlag = TRUE;    
            }
           if(attendeeEmptyFlag != TRUE){
                List<Id> topicId = new List<Id>();               
                for(Attendees__c att : attendeeList){
                    topicId.add(att.Agenda_Topic__c);
                }       
                agendaTopicList = [SELECT Id,Name,Display_Topic_As__c,Starting_Time__c,Ending_Time__c,Start_Date__c,Customer_Engagement__c 
                                   FROM Agenda_Topic__c WHERE Id IN : topicId ];               
                 //presenterConflictFlag will be TRUE if presenter is already assigned for same date and time.
                presenterConflictFlag = presenterCheck(agendaTopicList);
                system.debug('Presentconflictflag----------------------------'+presenterConflictFlag+''+attendeeEmptyFlag );
            }
            if((presenterConflictFlag == FALSE)){
                checkAvailabilityFlag = TRUE;
                agendaTopicFlag = FALSE;
                rec_found = FALSE;
                //PageUtils.addInfo('Presenter available! Please click on continue to assign the presenter to the Agenda Topic. '); 
            }else{            
                PageUtils.addError('Presenter already booked for same date and time! Please select another Topic Expert'); 
                return null;        
            }
            /****** v3.0 DP Starts   PageReference pageRef = new PageReference('/a14/e?nooverride=1&RecordType=012A0000000VhLk&CF00NA00000063PNB_lkid='
                                     +agendaTopic.Customer_Engagement__c +'&CF00NA00000063PNB='+ceName
                                     +'&CF00NA00000063POU_lkid='+topicExpId+'&CF00NA00000063POU='+topicExpName
                                     +'&00NA00000063POJ='+topicExpSelected.Topic_Expert_Name__c+
                                     +'&CF00NA00000063POI_lkid='+agId+'&CF00NA00000063POI=' +topicName
                                     +'&retURL='+agId+'&saveURL='+agId);  */
        
        
        PageReference pageRef = new PageReference('/'+agendaTopic.Id); 
        List<Attendees__c> attList = new List<Attendees__c>();
        Id RecordTypeId = [SELECT Id FROM RecordType WHERE Name LIKE '%Topic_Expert%' AND SobjectType = 'Attendees__c'].Id;
        for(Topic_Experts__c topicExpSelected : topicExpSelectedList){
            Attendees__c att = new Attendees__c();
            att.Team_Member__c = topicExpSelected.Id;
            att.Attendee_Name__c = topicExpSelected.Topic_Expert_Name__c;
            att.Customer_Engagement__c = agendaTopic.Customer_Engagement__r.Id;
            att.Agenda_Topic__c = agendaTopic.Id;
            att.RecordTypeId = RecordTypeId;
            attList.add(att);
         }
         try{
           insert attList; 
           return pageRef;
         }catch(exception e){
           checkAvailabilityFlag = false;
           PageUtils.AddError(''+e);
           return null;
         }                                                                
        /**** v3.0 DP Ends ***/     
        
        }
        else{
            /******* v3.0 DP Starts 
            if(singleCheckBoxFlag ==TRUE){
                PageUtils.addInfo('Please note that you can select only one Topic Expert at a time');   
            }
            else{ *******v3.0 DP Ends ******/
                PageUtils.addError('Please select a Topic Expert.');  
            //} 
        }
        return null;
    }
    
    //Method to compare the Agenda Topic start time/ end time with the start time/end time of the topics for which the presnetr is already booked for.
    public Boolean presenterCheck(List<Agenda_Topic__c> agList){
    system.debug('presenter----------------------------------');
        Boolean presenterflag = FALSE;
        Decimal topicStartTime = 0;
        Decimal topicEndTime = 0;
        Decimal presenterStartTime = convertTime(agendaTopic.Starting_Time__c);
        Decimal presenterEndTime = convertTime(agendaTopic.Ending_Time__c);
        
        for(Agenda_Topic__c ag:agList){
            topicStartTime = convertTime(ag.Starting_Time__c);
            topicEndTime = convertTime(ag.Ending_Time__c);
            
             system.debug('ag st-----------------'+agendaTopic.Starting_Time__c);
        system.debug('ag et-----------------'+agendaTopic.Ending_Time__c);
            
            system.debug('topicstarttime-----------------'+topicStartTime);
        system.debug('presstarttime-----------------'+presenterStartTime);
        system.debug('topicendtime-----------------'+topicEndTime);
        system.debug('presendtime-----------------'+presenterEndTime);
        
            /*if((topicStartTime >= presenterStartTime &&  topicEndTime <= presenterEndTime)||
              (topicStartTime <= presenterStartTime &&  topicEndTime <= presenterEndTime)|| 
              (topicStartTime <= presenterStartTime &&  topicEndTime >= presenterEndTime)||
              (topicStartTime >= presenterStartTime &&  topicEndTime >= presenterEndTime)){ */
              
              if((topicStartTime <= presenterStartTime && presenterStartTime < topicEndTime )||
                 (presenterStartTime <= topicStartTime && topicStartTime < presenterEndTime)||
                 (topicStartTime == presenterStartTime && topicEndTime == presenterEndTime))
              {
                if(ag.Customer_Engagement__c == agendatopic.Customer_Engagement__c){
                     presenterflag = TRUE;
                     system.debug('inside if ');
                     break;
                 }
              }
             
            /* if((topicEndTime > presenterStartTime ) || (presenterEndTime > topicStartTime)){
                 //presenterflag = FALSE;
                 system.debug('inside if second');
                 break;
             }*/
                     
        }
        
        system.debug('Presenter flag---------------------'+presenterflag );
        return presenterflag;
    }
    
    public Decimal convertTime(String strTime){
        Decimal newTime = 0;
        if(strTime != null){
            strTime = strTime.replaceFirst(':','.');
            if(strTime.contains('AM')){
                   if((strTime.contains('12.'))){
                       newTime = Decimal.ValueOf(strTime.substring(0,5))-12;
                    }
                    else{
                        newTime = Decimal.ValueOf(strTime.substring(0,5));       
                    }
            }
            else{
                if(strTime.contains('12.')){
                    newTime = Decimal.ValueOf(strTime.substring(0,5)); 
                }
                else{
                    newTime = Decimal.ValueOf(strTime.substring(0,5))+12;
                }
            }
        }
        return newTime;
    }
    
    public boolean getcheckAvailabilityFlag(){
        return checkAvailabilityFlag;
    }
    
    public Topic_Experts__c gettopicExpSelected(){
        return topicExpSelected ;
    }
    
    public PageReference continueaction() {  
         
        /******  
        String topicName=pageUtils.encodeVariable(agendaTopic.Name);
        String ceName=pageUtils.encodeVariable(agendaTopic.Customer_Engagement__r.Name);
        string topicExpName=pageUtils.encodeVariable(topicExpSelected.Name); 
                                    
         v3.0 DP Starts       PageReference pageRef = new PageReference('/a14/e?nooverride=1&RecordType=012A0000000VhLk&CF00NA00000063PNB_lkid='
                                     +agendaTopic.Customer_Engagement__c +'&CF00NA00000063PNB='+ceName
                                     +'&CF00NA00000063POU_lkid='+topicExpId+'&CF00NA00000063POU='+topicExpName
                                     +'&00NA00000063POJ='+topicExpSelected.Topic_Expert_Name__c+
                                     +'&CF00NA00000063POI_lkid='+agId+'&CF00NA00000063POI=' +topicName
                                     +'&retURL='+agId+'&saveURL='+agId);  */
        PageReference pageRef = new PageReference('/'+agendaTopic.Id);        
        List<Attendees__c> attList = new List<Attendees__c>();
        Id RecordTypeId = [SELECT Id FROM RecordType WHERE Name LIKE '%Topic_Expert%' AND SobjectType = 'Attendees__c'].Id;
        for(Topic_Experts__c topicExpSelected : topicExpSelectedList){
            Attendees__c att = new Attendees__c();
            att.Team_Member__c = topicExpSelected.Id;
            att.Attendee_Name__c = topicExpSelected.Topic_Expert_Name__c;
            att.Customer_Engagement__c = agendaTopic.Customer_Engagement__r.Id;
            att.Agenda_Topic__c = agendaTopic.Id;
            att.RecordTypeId = RecordTypeId;
            attList.add(att);
         }
         try{
           insert attList;
           return pageRef;       
         }catch(exception e){
           checkAvailabilityFlag = false;
           PageUtils.AddError(''+e);
           return null;
         }                                                   
        /**** v3.0 DP Ends ***/                             

    }
}