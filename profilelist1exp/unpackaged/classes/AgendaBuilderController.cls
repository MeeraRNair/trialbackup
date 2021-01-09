/*******************************************************************************************************
* Name          : AgendaBuilderController
* Description   : Build the Agenda
* ------------------------------------------------------------------------------------------------------
* Revision  Name        Date            Description
* 1.0       Sandhya     28.06.2011      CR 6369 - Add a check box to mark the presenter as “confirmed”
                                        once their calendar acceptance is received.Place this on the 
                                        agenda builder after the ‘presenter name’ on the agenda.Show
                                        as “pending” on the agenda until the box is checked.
*********************************************************************************************************/
public class AgendaBuilderController{
    Id CERecord;
    String CERecordName;
    public Customer_Engagement__c CEdetails1;
    public List<String> s1= new List<String>();
    Boolean dateWiseList=True;
    public List<Agenda_Topic__c> existingTopics= new List<Agenda_Topic__c>();
    public List<Transportation__c> existingTravel= new List<Transportation__c>();
    public List<Attendees__c> TeamMemberList = new List<Attendees__c>();
    public List<Agenda_Topic__c> unassignedTopics= new List<Agenda_Topic__c>();    
    public List<Agenda__c> assignedAgenda=new List<Agenda__c>();
    public List<Date> pickDate=new List<Date>();
    public List<Agenda_obj> agendaList=new List<Agenda_obj>();
    public List<Agenda__c> SortedAgendaItems;
    public List<Agenda__c> presenterAgItem;
    public String selectedDate{get;set;}
    public Transportation__c trans=new Transportation__c();
    Id RTId=IdLookupUtils.getRecordTypeId('Catering','Agenda_Topic__c',true);
    String URL = '/apex/AgendaBuilder';
    public string startDate;
    public string endDate;
    public string Room;
    public string site;
    public Date st;
    public Boolean itemexist=False;
    public Boolean msg=False;
    public Boolean showAgenda;
    public Boolean showError;   

   /* Updated for CR 6369 - Add a check box to mark the presenter as “confirmed” once their calendar acceptance is received.
      Place this on the agenda builder after the ‘presenter name’ on the agenda. Show as “pending” on the agenda until the box is checked.*/
   public AgendaBuilderController(ApexPages.StandardController controller) {
        try{
            CERecord=ApexPages.currentPage().getParameters().get('id');
            CEdetails1=[select Name, Id,Start_DateF__c, End_DateF__c, SiteF__c, Scheduled_RoomF__c, GSL_Start_Date__c, GSL_End_Date__c, Scheduled_Room__c, Dell_Solution_Center_Site__r.Name From Customer_Engagement__c where Id=:CERecord];
            existingTopics=[select Id,Name,Display_Topic_As__c,Starting_Time__c,Ending_Time__c, Start_Date__c from Agenda_Topic__c where Customer_Engagement__c= :CERecord];
            existingTravel=[select Id,Name from Transportation__c where Customer_Engagement__c= :CERecord];
            assignedAgenda=new List<Agenda__c>();
            date st=date.valueOf(CEdetails1.Start_DateF__c);
            assignedAgenda = [select Id,Start_Time__c, Role__c, End_Time__c, Email_Sent__c,Customer_Engagement__c,
                                Catering_Present__c,item__c,Presenter__c, Starting_Date__c,Presenter_status__c,
                                Topic_Id__c,Travel_Id__c From Agenda__c where Customer_Engagement__c = :CERecord 
                                order by Starting_Date__c,Start_Time__c,End_Time__c];
            displaySelection();
       }catch(Exception e){
           System.debug('Exception occured'+e);
       }
   }

   public PageReference Print2() {
        pageReference pageRef =new PageReference('/apex/presenterAgenda?id='+CERecord);
        return pageRef;

   }

   public PageReference Print1() {
        pageReference pageRef =new PageReference('/apex/CustomerAgenda?id='+CERecord);
        return pageRef;
   }
        
   public string getstartDate() {
        if(CEDetails1.Start_DateF__c != Null){
            startDate=String.valueOf(CEDetails1.Start_DateF__c);
        }
        else{
            startDate=String.valueOf(CEDetails1.GSL_Start_Date__c);
        }
        return startDate;
   }
   
   public string getendDate() {
        if(CEDetails1.End_DateF__c != Null){
            endDate=String.valueOf(CEDetails1.End_DateF__c);
        }
        else{
            endDate=String.valueOf(CEDetails1.GSL_End_Date__c);
        }
        return endDate;
   }
   
   
   public string getsite() {
        if(CEDetails1.SiteF__c != Null){
            site=CEDetails1.SiteF__c;
        }
        else{
            site=CEDetails1.Dell_Solution_Center_Site__r.Name;
        }
        return site;
   }
    
   public string getRoom() {
        if(CEDetails1.Scheduled_RoomF__c != Null){
            Room=CEDetails1.Scheduled_RoomF__c;
        }
        else{
            if(CEDetails1.Scheduled_Room__c != Null){
                Event_Location__c location=[select Name from Event_Location__c where id=:CEDetails1.Scheduled_Room__c];// and RecordTypeId='012T0000000D4cKIAS'];
                Room=location.Name;
            }
        }
        return Room;
   }
   
   public Customer_Engagement__c getCEdetails1(){ 
       return CEdetails1;
   }
   

  //Function to edit agenda topics
  public PageReference getAgendaTopic(){
       Id topicId=ApexPages.currentPage().getParameters().get('agTopic');
       for(Agenda_Topic__c ag:existingTopics){
           if(ag.Id==topicId){ 
               If(ag.Starting_Time__c == NULL && ag.Ending_Time__c ==NULL){
                   Id agId=ag.Id;
                   return (PageUtils.redirect('/'+agId+'?retURL=/apex/AgendaBuilder?id='+CERecord));
               }
            }
      }
      return null;
   }
    
   public List<Agenda_Topic__c>getexistingTopics(){
       return existingTopics;
   }
    
   //Function to enable the editing of travel
   public PageReference getTransportationDetails(){
       String travelName=ApexPages.currentPage().getParameters().get('trTravel');
       for(Transportation__c tr:existingTravel){
           if(tr.Name==travelName){ 
               Id trId=tr.Id;
               return (PageUtils.redirect('/'+trId+'/e?retURL=/apex/AgendaBuilder?id='+CERecord));
           }
       }
       return null;
   }
   
   public List<Transportation__c>getexistingTravel(){
        return existingTravel;
   }
   
   //Function to enable the creation of agenda topics
   public PageReference AddTopics() {
       return (PageUtils.redirect('/apex/AnalystTopics?id='+CERecord+'&user=agenda'));
   }
   
    //Function to enable the addition of Catering Breaks
   public PageReference AddCatering() {
       return (PageUtils.redirect('/apex/AddCateringBreak?id='+CERecord+'&user=agenda'));
   }

   //Function to enable the creation of travel break
   public PageReference Travel() {
       List<String> stDate=startDate.split(' ',2);
       List<String> sDate=stDate[0].split('-',3);
       String startingDate=sDate[1]+'/'+sDate[2]+'/'+sDate[0];
       //Defect 71890 
       String CEname = pageUtils.encodeVariable(CEdetails1.name);
       return (PageUtils.redirect('/a1A/e?CF00NA00000063PQk='+CEname+'&CF00NA00000063PQk_lkid='+CERecord+'&00NA00000063PQv='+startingDate+'&retURL=/apex/AgendaBuilder?id='+CERecord+'&saveURL=/apex/AgendaBuilder?id='+CERecord));
       //return (PageUtils.redirect('/a1A/e?CF00NA00000063PQk='+CEdetails1.name+'&CF00NA00000063PQk_lkid='+CERecord+'&00NA00000063PQv='+startingDate+'&retURL=/apex/AgendaBuilder?id='+CERecord+'&saveURL=/apex/AgendaBuilder?id='+CERecord));
   }

    
   public Transportation__c getTrans() {
       trans.Customer_Engagement__c=CERecord;
       return trans;        
   }
    
   //Function to enable the creation of catering break
   public PageReference Catering() {
       List<String> stDate=startDate.split(' ',2);
       List<String> sDate=stDate[0].split('-',3);
       String startingDate=sDate[1]+'/'+sDate[2]+'/'+sDate[0];
       //Defect 71890
       String CEname = pageUtils.encodeVariable(CEdetails1.name);
       return (PageUtils.redirect('/a12/e?CF00NA00000063PN9='+CEname+'&CF00NA00000063PN9_lkid='+CERecord+'&RecordType='+RTId+'&00NA00000063PNn='+startingDate+'&retURL=/apex/AgendaBuilder?id='+CERecord+'&saveURL=/apex/AgendaBuilder?id='+CERecord));
       //return (PageUtils.redirect('/a12/e?CF00NA00000063PN9='+CEdetails1.name+'&CF00NA00000063PN9_lkid='+CERecord+'&RecordType='+RTId+'&00NA00000063PNn='+startingDate+'&retURL=/apex/AgendaBuilder?id='+CERecord+'&saveURL=/apex/AgendaBuilder?id='+CERecord));
  }

   public List<Attendees__c> getAttendees() {
       TeamMemberList=[select Attendee_Name__c,Name, Role__c, Email__c, Phone__c from Attendees__c where Customer_Engagement__c=:CERecord];
       return TeamMemberList;        
   }
    
   public void setAttendees(List<Attendees__c> newteamMemberList){
        TeamMemberList = newTeamMemberList;
   }
    
   public List<Agenda_Topic__c>getUnassignedTopics(){
      unassignedTopics.clear();
       for(Agenda_Topic__c unassigned:existingTopics)
           if(unassigned.Starting_Time__c==null || unassigned.Ending_Time__c==null)
               unassignedTopics.add(unassigned);
               return unassignedTopics;
   }

    public class Agenda_obj{      
        public String theDate{get;set;}
        public List<AgendaItem_obj>agendaItemsList{get;set;}
    }
    
    public class AgendaItem_obj{
        public Boolean overlap{get;set;}
        public Agenda__c agendaItem{get;set;}
    }
    
    public List<Agenda_obj> getagendaList(){
        return agendaList;
    }
    
    public void displaySelection(){
        Boolean dateFlag=false;
        pickDate=new List<Date>();
        for(Agenda__c agTemp:assignedAgenda){
            dateFlag=false;
            for(Date pickDay:pickDate){
                if(pickDay==agTemp.Starting_Date__c){
                    dateFlag=true;
                }
            }
            if(dateFlag==false){
                pickDate.add(agTemp.Starting_Date__c);
            }
        }
        getSortedAgendaItemList();        
    } 
    public Decimal convertTime(String strTime){
        Decimal newTime=0;
        if(strTime!=null){
            strTime=strTime.replaceFirst(':','.');
            if(strTime.contains('AM')){
                   if((strTime.contains('12.'))){
                       newTime=Decimal.ValueOf(strTime.substring(0,5))-12;
                    }
                    else{
                        newTime=Decimal.ValueOf(strTime.substring(0,5));       
                    }
            }
            else{
                if(strTime.contains('12.')){
                    newTime=Decimal.ValueOf(strTime.substring(0,5)); 
                }
                else{
                    newTime=Decimal.ValueOf(strTime.substring(0,5))+12;
                }
            }
        }
        return newTime;
    }
    
    public DateTime convertTodateTime(Date startDate,String eventTimeStr){
        Datetime timeStr;
        if((startDate!=null)&&(startDate!=null)){
            string year = ''+startDate.year();
            string month = ''+startDate.month();
            string day = ''+startDate.day();
            Decimal newTime=convertTime(eventTimeStr);          
            eventTimeStr=String.ValueOf(newTime);
            Integer index=eventTimeStr.indexOf('.');
            string hour = eventTimeStr.substring(0,index);         
            string minute = eventTimeStr.substring(index+1);
            string stringDate = year + '-' + month+ '-' + day + ' ' + hour + ':' +minute + ':' + '00';
            timeStr=datetime.valueofGMT(stringDate);
        }
        return timeStr ;   
    }

    public List<Agenda__c> getAgendaItemsList(){
        Datetime startingDateTime ;
        SortedAgendaItems = new List<Agenda__c>();
        presenterAgItem=new List<Agenda__c>();
        List<Agenda__c> agendaItemList=new List<Agenda__c>();
        List<DateTime> keyStartDatesList =  new list<dateTime>();
        Map<Date, Agenda__c> sortedAgendaMap=new Map<Date, Agenda__c>();
        Map<DateTime, Map<DateTime, List<Agenda__c>>> parentMap=new Map<DateTime, Map<DateTime, List<Agenda__c>>>();
        Map<DateTime, List<Agenda__c>> childMap=new Map<DateTime, List<Agenda__c>>();
        
        for(Agenda__c agendaTemp: assignedAgenda){
            if(agendaTemp.Starting_Date__c!=null){
                if((agendaTemp.Start_Time__c!=null)&&(agendaTemp.End_Time__c!=null)){
                    DateTime startDateTime =  convertTodateTime (agendaTemp.Starting_Date__c,agendaTemp.Start_Time__c);
                    DateTime endDateTime =  convertTodateTime (agendaTemp.Starting_Date__c,agendaTemp.End_Time__c);
                    if (parentMap.containsKey(StartDateTime)) {
                        if(parentMap.get(StartDateTime).containsKey(endDateTime))
                            parentMap.get(StartDateTime).get(endDateTime).add(agendaTemp);
                        else
                            parentMap.get(StartDateTime).put(endDateTime,new List<Agenda__c>{agendaTemp});
                    }
                    else{
                        childMap=new Map<DateTime, List<Agenda__c>>(); 
                        agendaItemList=new List<Agenda__c >();
                        agendaItemList.add(agendaTemp);
                        childMap.put(endDateTime,agendaItemList);
                        parentMap.put(StartDateTime,childMap);               
                    }
                }
                else{
                    presenterAgItem.add(agendaTemp);
                }
            }
            else{
                PageUtils.addError('Start date missing in one of the record.Please add the start date.');
            }
        }
        keyStartDatesList.addAll(parentMap.keySet());
        keyStartDatesList.sort();
        Map<DateTime, List<Agenda__c>> childMapNew=new Map<DateTime, List<Agenda__c>>();     
        for(DateTime parentKey : keyStartDatesList){
            list<DateTime> keyEndDatesList =  new list<dateTime>();
            childMapNew=new Map<DateTime, List<Agenda__c>>();
    
            childMapNew=parentMap.get(parentKey);
            keyEndDatesList.addAll(childMapNew.keySet());
            keyEndDatesList.sort();
            for(DateTime childKey : keyEndDatesList ){
                SortedAgendaItems.addAll(childMapNew.get(childKey ));
                system.debug('SortedAgendaItems:'+SortedAgendaItems);
            }
        }
        return SortedAgendaItems;
    }
    
    public void getSortedAgendaItemList(){
        List<AgendaItem_obj> itemList=new List<AgendaItem_obj>();
        List<Agenda__c>agendaItemsSortedList =new List<Agenda__c>();
        List<Agenda__c>agendaTempList=new List<Agenda__c>();
        List<Agenda__c>agendaSortedItemList=new List<Agenda__c>();
        Map<Date, List<Agenda__c>> agendaItemMap=new Map<Date, List<Agenda__c>>(); 
        agendaItemsSortedList = getAgendaItemsList();
        for(Agenda__c agSort:SortedAgendaItems){
            if (agendaItemMap.containsKey(agSort.Starting_Date__c)) {
                agendaItemMap.get(agSort.Starting_Date__c).add(agSort);
            }
            else{
                agendaTempList=new List<Agenda__c >();
                agendaTempList.add(agSort);
                agendaItemMap.put(agSort.Starting_Date__c,agendaTempList);
       
            }
        }
        for(Date dateTemp:pickDate){
            agendaSortedItemList=new List<Agenda__c>();
            for(Agenda__c agSortTemp:agendaItemMap.get(dateTemp)){
                agendaSortedItemList.add(agSortTemp);
                for(Agenda__c presenterTemp: presenterAgItem){
                    if(agSortTemp.Topic_Id__c==presenterTemp.Topic_Id__c){
                        agendaSortedItemList.add(presenterTemp);
                    }  
                }
            }   
            string stringDate = dateTemp.year() + '-' + dateTemp.month()+ '-' + dateTemp.day() + ' ' + '00'+ ':' +'00'+ ':' + '00';
            Datetime startingDate =datetime.valueOf(stringDate);
            String tempDay=startingDate.format('EEEE, MMMM d, yyyy');
            String STime=tempDay.toUpperCase();
            itemList=new List<AgendaItem_obj>();
            for(Agenda__c sortedTemp:agendaSortedItemList){
                AgendaItem_obj newAgendaItem = new AgendaItem_obj();
                newAgendaItem .overlap=false;
                newAgendaItem .agendaItem=sortedTemp;
                itemList.add(newAgendaItem );
            }
            Agenda_obj newAgenda = new Agenda_obj();
            newAgenda.agendaItemsList=itemList;
            newAgenda.theDate=STime;
            agendaList.add(newAgenda);
       }     
       agendaOverlap();
   }

    public void agendaOverlap(){
       Decimal agendaItFirstStartTime=0;
       Decimal agendaItFirstEndTime=0;
       Decimal agendaItemSecStartTime=0;
       Decimal agendaItemSecEndTime=0;
    
       for(Agenda_obj agendaOb:agendaList){
           for(AgendaItem_obj agendaItFirst: agendaOb.agendaItemsList){
               agendaItFirstStartTime=convertTime(agendaItFirst.agendaItem.Start_Time__c);
               agendaItFirstEndTime=convertTime(agendaItFirst.agendaItem.End_Time__c);
               for(AgendaItem_obj agendaItemSec: agendaOb.agendaItemsList){
                   if(agendaItFirst.agendaItem.Id != agendaItemSec.agendaItem.Id && 
                       agendaItFirst.agendaItem.Start_Time__c != NULL &&
                       agendaItFirst.agendaItem.End_Time__c != NULL){
                       if(agendaItFirst.agendaItem.Starting_Date__c == agendaItemSec.agendaItem.Starting_Date__c){
                           agendaItemSecStartTime=convertTime(agendaItemSec.agendaItem.Start_Time__c);
                           agendaItemSecEndTime=convertTime(agendaItemSec.agendaItem.End_Time__c);
                          if(agendaItFirstStartTime >= agendaItemSecStartTime && 
                                 agendaItFirstEndTime <= agendaItemSecEndTime ){ 
                             agendaItFirst.overlap=TRUE;
                             agendaItemSec.overlap=TRUE; 
                             }                          
                         }
                                              
                    }        
                }
            }     
        }    
    }

    public Boolean getDateWiseList(){
        return dateWiseList;
    }
    
    public Boolean getitemexist(){
        return itemexist;
    }
    
    public Boolean getmsg(){
        return msg;
    }
        
    public pageReference getdetailpage(){

      Id agndId=ApexPages.currentPage().getParameters().get('Topicdetails');
      Agenda__c agndList =[Select Topic_Id__c, Travel_Id__c from Agenda__c where id = :agndId];
      if(agndList.Topic_Id__c != NULL){
          for(Agenda_Topic__c ag:existingTopics){
               if(ag.Id == agndList.Topic_Id__c){
                   if(ag.Starting_Time__c != Null && ag.Ending_Time__c != Null){ 
                        Id agId=ag.Id;
                        //return (PageUtils.redirect('/'+agId+'/e?retURL=/apex/AgendaBuilder?id='+CERecord)); //edit page
                        //return (PageUtils.redirect('/'+CERecord));
                        return (PageUtils.redirect('/'+agId));
                        
                   }  
                }
           }
      }
      if(agndList.Travel_Id__c != NULL){
          for(Transportation__c agTr:existingTravel){
               if(agTr.Id == agndList.Travel_Id__c){
                        Id agId=agTr.Id;
                        //return (PageUtils.redirect('/'+agId+'/e?retURL=/apex/AgendaBuilder?id='+CERecord)); //edit page
                        return (PageUtils.redirect('/'+agId));
                }
           }
      }
      return null;
    }
    
    public pageReference CancelButton(){
        return (PageUtils.redirect('/'+CERecord));
    }
    public void removeAssignedTopics(){
        Integer removeIndex=0;
        Boolean removeFlag=false;
        List<Agenda__c> agendaRemoveList = new List<Agenda__c>();
        List<Agenda_Topic__c> topicRemoveList = new List<Agenda_Topic__c>();
        List<Transportation__c> travelRemoveList = new List<Transportation__c>();
        Map<Id, Agenda__c> removeListMap= new Map<Id, Agenda__c>();
        
        String removeTopicId=ApexPages.currentPage().getParameters().get('removeTopic');
        String removeTravelId=ApexPages.currentPage().getParameters().get('removeTravel');

        for(Agenda__c a:assignedAgenda){
            if(removeTopicId.length()!=0){
                if(a.Topic_Id__c==removeTopicId){
                    agendaRemoveList.add(a);
                    for(Agenda_Topic__c top:existingTopics){
                        if(removeTopicId==top.Id && a.Start_Time__c != null&& a.End_Time__c != null){
                            top.Starting_Time__c=null;
                            top.Ending_Time__c=null;
                            topicRemoveList.add(top); 
                        }
                    }                              
                 }  
            }
            if(removeTravelId.length()!=0){
                if(a.Travel_Id__c==removeTravelId){
                    agendaRemoveList.add(a);    
                    for(Transportation__c travel:existingTravel){
                      if(removeTravelId==travel.Id && a.Start_Time__c != null&& a.End_Time__c != null){
                          travel.Starting_Time__c=null;
                          travel.Ending_Time__c=null;
                          travelRemoveList.add(travel); 
                        }
                    }
                }
           } 
        }
        for(Agenda__c ag:agendaRemoveList){
            removeListMap.put(ag.Id, ag);    
        }
        for(Integer l=0;l<agendaRemoveList.size();l++){
            for(Integer k=0;k<assignedAgenda.size();k++){ 
                if(agendaRemoveList[l]==assignedAgenda[k]){
                    assignedAgenda.remove(k); 
                    break;      
                }
            }
        }
        
        update travelRemoveList;
        update topicRemoveList;
        delete agendaRemoveList;
        //agendaList.clear();
        agendaList=new List<Agenda_obj>();
        displaySelection();
    }

}