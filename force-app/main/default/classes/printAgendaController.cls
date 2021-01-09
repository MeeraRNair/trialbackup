public class printAgendaController {
    String CERecord;
    Date startD;
    Date endD;

    public Boolean isattendee=False;
    public Boolean isaccountteam=False;    
    public Boolean isvendor=False ;   
    public List<Attendees__c> Customers = new List<Attendees__c>();
    public Customer_Engagement__c CEdetails1;
    public List<Attendees__c> Teams = new List<Attendees__c>();
//6196
    public Boolean isdellteam=False;
    public List<Attendees__c> Dell_Teams = new List<Attendees__c>();
//6196
    public List<Agenda__c> agenda = new List<Agenda__c>();
    public Calendar_Management__c CEdetails;
    public List<Attendees__c> Vendors = new List<Attendees__c>();
    public List<Attendees__c> TExperts= new List<Attendees__c>();
    public List<Agenda_obj> agendaList=new List<Agenda_obj>();
    public List<Agenda__c> SortedAgendaItems;
    public List<Agenda__c> presenterAgItem;
    public List<date>pickDate= new List<date>();
 
    public printAgendaController(ApexPages.StandardController controller) {
        CERecord=ApexPages.currentPage().getParameters().get('id');
        CEdetails1=[select Name,End_DateF__c, Id,Start_DateF__c, SiteF__c,RecordTypeId, OwnerId,Owner.name, 
                    Operations_Analyst__c,Operations_Analyst__r.Name,  Scheduled_RoomF__c,Primary_Account__c,
                    GSL_Start_Date__c, GSL_End_Date__c, Scheduled_Room__c, Dell_Solution_Center_Site__c
                    From Customer_Engagement__c where Id=:CERecord];
        Id cusRtlist=IdLookupUtils.getRecordTypeId('Customer','Attendees__c',true);
        //Customers =[select Id,Attendee_Name__c,Name,Customer_Attendee__c,Display_Attendee_Title_As__c, Role__c  from Attendees__c where Customer_Engagement__c= :CERecord and Customer_Attendee__c != NULL and RecordTypeId=:cusRtlist];
        Customers =[select Id,Attendee_Name__c,Name,Customer_Attendee__c,Display_Attendee_Title_As__c, Role__c  from Attendees__c where Customer_Engagement__c= :CERecord and RecordTypeId=:cusRtlist];
        system.debug('Customers :'+Customers);
        if(Customers.size() > 0){
            isattendee=TRUE;
        }
        Id rtlistAT=IdLookupUtils.getRecordTypeId('Account Team','Attendees__c',true);
        Teams =[select Id,Name,Attendee_Name__c,Account_Team__c,Display_Attendee_Title_As__c, Role__c  from Attendees__c where Customer_Engagement__c= :CERecord and Account_Team__c != NULL and RecordTypeId=:rtlistAT ];
        if(Teams.size() > 0){
            isaccountteam=TRUE;
        }
    //6196
        Id rtlistDI=IdLookupUtils.getRecordTypeId('Dell Internal','Attendees__c',true);
        Dell_Teams=[select Id,Name,Attendee_Name__c,Display_Attendee_Title_As__c, Role__c  from Attendees__c where Customer_Engagement__c= :CERecord and RecordTypeId=:rtlistDI];
        if(Dell_Teams.size() > 0){
            isdellteam=TRUE;
        }
    //6196
                 
        Id rtlistVP=IdLookupUtils.getRecordTypeId('Vendor/Partner','Attendees__c',true);
        Vendors= [select id,Attendee_Name__c,Name,Display_Attendee_Title_As__c, Role__c from Attendees__c where Customer_Engagement__c=:CERecord and Customer_Attendee__c = NULL and Account_Team__c=NULL and RecordTypeId=:rtlistVP];
        if(Vendors.size()>0){
            isvendor=TRUE;
        }
        agenda = [select Id,Start_Time__c, End_Time__c, Email_Sent__c,Customer_Engagement__c, 
                    Catering_Present__c,item__c,Presenter__c, Starting_Date__c,AE_Notes_L__c , 
                    Analyst_Notes_L__c,Topic_Id__c,Role__c,Travel_Id__c,Catering_or_Not__c  From Agenda__c where Customer_Engagement__c = :CERecord order by Starting_Date__c,Start_Time__c];
        add();
    }
    
    public Customer_Engagement__c getCEdetails1(){ 
        return CEdetails1;
    }
    public List<Attendees__c> getCustomers() { 
        return Customers;
    }
     public List<Attendees__c> getTeams() { 
        return Teams;
    }
    public List<Attendees__c> getVendors() { 
        return Vendors;
    }
//6196
    public List<Attendees__c> getDell_Teams() { 
        return Dell_Teams;
    }
//6196   
    public String getanalyst() { 
        String analyst;
        if(CEdetails1.RecordTypeId==IdLookupUtils.getRecordTypeId('Executive Briefing Center','Customer_Engagement__c',true)){
            analyst=CEdetails1.Owner.Name+', Briefing Analyst';    
        }   
        else
        {
            if(CEdetails1.Operations_Analyst__r.Name!=null){
                analyst=CEdetails1.Operations_Analyst__r.Name+', Analyst'; 
            } 
        }
        return analyst;
    }
    public Boolean getisattendee(){
        return isattendee;
    }
    
    public Boolean  getisaccountteam(){
        return isaccountteam;
    }
    
    public Boolean  getisvendor(){
        return isvendor;
    }
//6196
    public Boolean  getisdellteam(){
        return isdellteam;
    }
//6196
    public List<Attending_Accounts__c> getattendees() { 
         List <Attending_Accounts__c> attacc= new List<Attending_Accounts__c>();
         List <Attending_Accounts__c> attendees= [Select Account__c, Account_Name_Display__c,Name, Customer_Engagement__r.Name  From Attending_Accounts__c where Customer_Engagement__c=:CERecord ];
         if(attendees.size()>0){
         for (Attending_Accounts__c att :attendees){
            if(att.Account_Name_Display__c == null){
                  Account accName =[select Name from Account where Id=:att.Account__c];
                  att.Account_Name_Display__c=accName.Name;
                }
                attacc.add(att);
            }
        }
        return attacc;
    }
    public List<Agenda__c>getAssignedTopics(){
        List<Agenda__c> assignedTopics= [select Id,Email_Sent__c,Customer_Engagement__c, End_Time__c, Catering_Present__c,item__c,Presenter__c, Start_Time__c,Starting_Date__c, Ending_Date__c,AE_Notes_L__c , Analyst_Notes_L__c  From Agenda__c where Customer_Engagement__c = :CERecord order by Start_Time__c];
        return assignedTopics;
    }

     public class Agenda_obj{
       
        public String theDate{get;set;}
        public List<Agenda__c>agendaItemsList{get;set;}
     }

    public List<Agenda_obj> getagendaList(){
        return agendaList;
    }
    public void add(){
    Boolean dateFlag=false;
        for(Agenda__c agTemp:agenda){
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
        
        for(Agenda__c agendaTemp: agenda ){
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
            Agenda_obj newAgenda = new Agenda_obj();
            newAgenda.theDate=STime;
            newAgenda.agendaItemsList=agendaSortedItemList; 
            agendaList.add(newAgenda); 
       }     
   }
}