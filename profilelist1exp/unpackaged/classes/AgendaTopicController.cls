/*

REVISION HISTORY

================

Version     Author      Date            Release#    CR#     Description

-------     ------      ----            --------    ---     -----------

2.0         Impana      24-April-2013   R14.5      7998    This page will 
                                                            assign 'confirmed start date' to 'date' field in agenda topic when confirmed start date is not null. 
                                                            
                                                            
*/


public class AgendaTopicController{ 
    public Id id;
    public Double duration=0;
    public Double durationhrs;
    Integer noOfDays;
    Date startDate;
    Boolean displayAgenda=false;
    Boolean displayTopics=false;
    Boolean topicExistFlag=false;
    Boolean agendaBuilder=false;
    Boolean isAnalyst=false;
    public String subject {get; set;}
    public Set<String>subDropDown = new Set<String>();
    public List<Id>topicIdList = new List<Id>();
    public List<TopicDetails> topicDisplayList=new List<TopicDetails>();
    public List<Agenda_Topic__c> existingTopics= new List<Agenda_Topic__c>();
    public List<Agenda_Topic__c> newTopics= new List<Agenda_Topic__c>();
    public List<Agenda_Content__c> topList =new List<Agenda_Content__c>();
    List<Agenda_Content__c> topicsDisplay=new List<Agenda_Content__c>();
    List<subject_obj> subjectList=new List<subject_obj>();
    
    /* Constructor */
    public AgendaTopicController(){
        Integer loc;
        String siteName;
        String given;
        String engagement;
        String event;
        String user;
        try{ 
            id=ApexPages.currentPage().getParameters().get('id');
            user=ApexPages.currentPage().getParameters().get('user');
            if (user=='agenda'){
                isAnalyst=true;
                agendaBuilder=true;
            }
            if(user=='analyst') 
                isAnalyst=true;
            Customer_Engagement__c ceObj=[select Name,Event_TypeF__c,Event_Type__c,Dell_Solution_Center_Site__r.Name,SiteF__c,Start_DateF__c,GSL_Start_Date__c,End_DateF__c,GSL_End_Date__c,RecordTypeId,Confirmed_Date__c,Confirmed_End_Date__c from Customer_Engagement__c where Id= :id];
            if(ceObj.RecordTypeId==IdLookupUtils.getRecordTypeId('Executive Briefing Center','Customer_Engagement__c',true)){
                System.debug('EBC record');
                engagement='EBC';
                event=ceObj.Event_TypeF__c;
                siteName=ceObj.SiteF__c;
                startDate=ceObj.Start_DateF__c;
                noOfDays=startDate.daysBetween(ceObj.End_DateF__c)+1;
            }
            else{
                System.debug('DSC record');
                engagement='DSC';
                event=ceObj.Event_Type__c;
                siteName=ceObj.Dell_Solution_Center_Site__r.Name;
                
                /* Cr 7998 --------- assign confirmed start date to date field    */
                // Start
                if(ceobj.Confirmed_Date__c == null){
                     startDate=ceObj.GSL_Start_Date__c;    
                }
                else{
                     startDate=ceObj.Confirmed_Date__c;
                } // End
                noOfDays=startDate.daysBetween(ceObj.GSL_End_Date__c)+1  ;          
            }    
            existingTopics=[select Name,Duration__c,Description__c,Subject__c,AE_Notes__c,Analyst_Notes__c,AE_Questions__c,
                            Analyst_Questions__c,Topics__c from Agenda_Topic__c where Customer_Engagement__c= :Id and 
                            Topics__r.RecordTypeID = :IdLookupUtils.getRecordTypeId('Topic','Agenda_Content__c',true)];
            topList=[select Name,Description__c,Duration_minutes__c ,AE_Questions__c,AE_Questions_Active__c,
                    Analyst_Questions__c,Analyst_Questions_Active__c, Select_Subject__r.Name from Agenda_Content__c where
                     RecordTypeId = :IdLookupUtils.getRecordTypeId('Topic','Agenda_Content__c',true) and Apply_to_Site__r.Name = :siteName 
                     and Active__c=true and Engagement_Type__c= :engagement and Event_Type__c includes(:event)];
            for(Agenda_Content__c topic:topList){
                subDropDown.add(topic.Select_Subject__r.Name);
            }    
        }catch(Exception e){
            System.debug('Exception Occured:'+e);
        }
        getExistingTopicList();
    }
    
    /* Wrapper class for checkbox display */
    public class TopicDetails{
        public boolean selected{get;set;}
        public Agenda_Content__c topic{get;set;}
        public TopicDetails(Agenda_Content__c top){
           topic= top; 
           selected = false;
        }
    }
    
    /* Wrapper class to display topics */
    public class Subject_obj{
        public String subjectName{get;set;}
        public List<Agenda_Topic__c>agendaTopicsList{get;set;}
        public List<Agenda_Topic__c> agendaExistingTopicsList{get;set;}
        public Subject_obj(){
            string tempString;
            subjectName=tempString;
            agendaTopicsList=new List<Agenda_Topic__c>();
            agendaExistingTopicsList=new List<Agenda_Topic__c>();
        }
    }
    
    public List<Subject_obj> getsubjectNewList(){
        return subjectList;
    }

     public List<TopicDetails> getTopicDisplayList(){
        return TopicDisplayList;
    }

    /* Save the agenda topics */
    public PageReference save(){
       try{
            List<Agenda_Topic__c> agendaTopicSaveList= new List<Agenda_Topic__c>();
            for(Subject_obj tempSub:SubjectList){
                if(!tempSub.agendaTopicsList.isEmpty()){
                       agendaTopicSaveList.addAll(tempSub.agendaTopicsList);
                }         
            }
            if(isAnalyst=true){
                update existingTopics;
            }
            insert agendaTopicSaveList;
            if(agendaBuilder)
                return PageUtils.redirect('/apex/Agendabuilder?id='+id);
            else
                return PageUtils.redirect('/'+id);      
       }
       catch(exception e){
          apexpages.addmessages(e);    
          return null;
       }         
            
    }
        
    public PageReference cancel(){
         if(agendaBuilder)
            return PageUtils.redirect('/apex/Agendabuilder?id='+id+'/e?retURL=%2F'+id);
        else
            return PageUtils.redirect('/'+id);
    }
    
    /* Action when remove button clicked for a topic */
    public PageReference deleteTopics(){
        Map<Id, Agenda_Topic__c> deletetopicMap= new Map<Id, Agenda_Topic__c>();
        String deleteTopicId=ApexPages.currentPage().getParameters().get('delTopic');
        Integer deleteIndex=0;
        Boolean deleteSubject=false;
        for(Integer j=0;j<subjectList.size();j++){
            for(Integer i=0;i<subjectList[j].agendaTopicsList.size();i++){
                if((subjectList[j].agendaTopicsList[i].Topics__c==deleteTopicId)){
                    deleteIndex=j;
                    duration=duration-subjectList[j].agendaTopicsList[i].duration__c;
                    if(subjectList[j].agendaExistingTopicsList.size()==0){
                        deleteSubject=true;
                    }
                    subjectList[j].agendaTopicsList.remove(i); 
                    break;                 
                }
            }
        }
        if(deleteSubject==true){
            subjectList.remove(deleteIndex);
        }
        return null;
    }

    public Boolean getDisplayAgenda(){ 
        return displayAgenda;    
    }
    
    /* Display duration in hours */
    public String getDurationhrs(){ 
        durationhrs= duration / 60;
        String st=String.valueOf(durationhrs);
        Integer loc= st.indexOf('.',0);
        try{
            st=st.substring(0,loc+3);
        }catch(Exception e){
             st=st.substring(0,loc+2);
        }
        durationhrs=double.valueof(st);
        return (durationhrs+'hrs');
    }
     
    public String getSubject(){ 
        return subject;
    }
        
   public void setSubject(String subject){
        this.subject=subject;
    }
    
    /* Get the selected topics ID */   
    public List<Id> getTopics() {
    topicIdList =new List<Id>();
        for (TopicDetails topSelected: topicDisplayList){
            if (topSelected.selected == TRUE) {
                topicIdList.add(topSelected.topic.Id);
            }
         }
         return topicIdList;
    }
    
    public  Boolean getDisplayTopics() {
        return displayTopics;
    }
           
    /* Generates subject dropdown */
    public List<SelectOption> getSubjectSelectList() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '-- Select One --'));
        if(subDropDown.size()==0)
            PageUtils.addError('No Subject matching the selections.  Please check the Customer Engagement.');

        else
            for (String subject : subDropDown){
                options.add(new SelectOption(subject, subject));
            }
        return options;
    }
    
    /* To create topic list according to the subject selected */
    public void subjSelected() {
        topicDisplayList.clear();
        if((getSubject())!=null){
            displayTopics=false;
            if(existingTopics.size()==0)
                displayAgenda=false;
            topicsDisplay=new List<Agenda_Content__c>();
            for(Agenda_Content__c topicTemp : topList){
                if(getSubject()== topicTemp.Select_Subject__r.Name){
                    topicsDisplay.add(topicTemp);
                    topicDisplayList.add(new TopicDetails(topicTemp) ) ;   
                 }  
             } 
            displayTopics=true;
        } 
    }
    
    /* Add the new agenda topics */
    public void add() {
        Double tempDuration=0;
        Boolean durationExceed=false;
        newTopics= new List<Agenda_Topic__c>();
        Map<Id, Agenda_Content__c> topicsMap= new Map<Id, Agenda_Content__c>();
        for(Agenda_Content__c temTopics:topicsDisplay){
             topicsMap.put(temTopics.Id, temTopics);
        }
        getTopics();
        for(Id topicId: topicIdList){
            if(topicsMap.get(topicId)!=null){
                Agenda_Topic__c agendaTopics = new Agenda_Topic__c();
                Agenda_Content__c agContent=new Agenda_Content__c();
                agContent=topicsMap.get(topicId);
                agendaTopics.Name= agContent.Name;                 
                agendaTopics.Topics__c=topicId;
                agendaTopics.Start_Date__c=startDate;
                agendaTopics.Duration__c=agContent.Duration_minutes__c;
                agendaTopics.Description__c=agContent.Description__c;
                if(agContent.AE_Questions_Active__c)
                   agendaTopics.AE_Questions__c=agContent.AE_Questions__c;
                if(agContent.Analyst_Questions_Active__c)
                    agendaTopics.Analyst_Questions__c=agContent.Analyst_Questions__c;
                if(agContent.Duration_minutes__c!=null)
                    tempDuration=tempDuration+agContent.Duration_minutes__c;
                agendaTopics.Customer_Engagement__c=id;
                newTopics.add(agendaTopics);
            }
        }   
        if((isAnalyst==false)&&(duration+tempDuration) > (noOfDays*7*60)){//For multiday event number of days multiplied by 7 hours
            durationExceed=true;               
            PageUtils.addError('Cannot add the topic(s) as the duration exceeds the maximum limit!');    
        }   
        displayAgenda=true;
        if(durationExceed==false){
            gettopicSelection_List();
            if((topicExistFlag==false)&&(durationExceed==false)){
                duration=duration+tempDuration;
            }
        }
    }
 
    /* Add already existing topics to the subjectList */
    public void getExistingTopicList(){
        Boolean subjectInExisting=false;
        List<Agenda_Topic__c> existingTemp;
        displayAgenda=true;  
        for(Agenda_Topic__c tempAg:existingTopics){
            existingTemp= new List<Agenda_Topic__c>();
            subjectInExisting=false;
            duration=duration+tempAg.Duration__c;
            System.debug('Existing duration-------'+duration);
            displayAgenda=true;
            
            for(Subject_obj subOb1:subjectList){
                if(subOb1.subjectName == tempAg.Subject__c){ 
                    subjectInExisting=true;   
                    subOb1.agendaExistingTopicsList.add(tempAg);
                }
            }
            if(subjectInExisting==false){
                Subject_obj newSubObj = new Subject_obj();
                newSubObj.subjectName = tempAg.Subject__c;
                existingTemp.add(tempAg);
                newSubObj.agendaExistingTopicsList=existingTemp;
                subjectList.add(newSubObj );
            }
        }
    }
    
    /* Add newly added topics to subjectList */
    public void gettopicSelection_List(){
        Boolean subjectExist=false;
        topicExistFlag=false;
        Integer newTopicsDuration=0;
        Map<Id, Agenda_Topic__c> existTopicsMap= new Map<Id, Agenda_Topic__c>();
        Map<Id, Agenda_Topic__c> newTopicsMap= new Map<Id, Agenda_Topic__c>();
        
        system.debug('----------inSubjectList----------'+subjectList);
        for(Subject_obj subObj:subjectList){
            system.debug('----------newTopics--------'+newTopics);
            for(Agenda_Topic__c existTopicsTemp:subObj.agendaExistingTopicsList){
                existTopicsMap.put(existTopicsTemp.Topics__c, existTopicsTemp);                  
            }
            for(Agenda_Topic__c newTopicsTemp:subObj.agendaTopicsList){
                newTopicsMap.put(newTopicsTemp.Topics__c, newTopicsTemp);                  
            }
            if(subObj.subjectName == subject){
                subjectExist=true;
                
                /* topicExistFlag is set to true if any of the newly added topics exist in already existing 
                   topics or previously added topics and it is not an analyst login.If it is not an analyst login 
                   already added topics cannot be added again */
                   
                for(Agenda_Topic__c tempNewTopics:newTopics){
                    if(((existTopicsMap.get(tempNewTopics.Topics__c)!=null)||
                        (newTopicsMap.get(tempNewTopics.Topics__c)!=null))&&(isAnalyst==false)){
                        topicExistFlag=true;
                        PageUtils.addError('Topic : ' +tempNewTopics.Name+' already added! Please add another Topic!'); 
                    }
                }
                
                /* topicExistFlag will be false if it is an analyst login or none of the newly added topic already exist
                   in already existing topics.Analyst login is checked since same topics can be added again only for
                   Analyst login */
                   
                if(topicExistFlag==false){                     
                    subObj.agendaTopicsList.addAll(newTopics);
                }  
            }
        }
        if(subjectExist==false){
            Subject_obj newSubject = new Subject_obj();
            newSubject.subjectName = subject;
            newSubject.agendaTopicsList=newTopics; 
            subjectList.add(newSubject);
        }
    }
    
    public PageReference backToCustomer(){
        return PageUtils.redirect('/'+id);
    } 
 }