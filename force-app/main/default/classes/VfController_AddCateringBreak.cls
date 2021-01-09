public class VfController_AddCateringBreak {

    public PageReference backToCE() {
        return  (PageUtils.redirect('/'+CEId ));
    }


List <CateringBreakWrapper> cateringBreaks =  new List<CateringBreakWrapper> ();
string CEId = ApexPages.currentPage().getParameters().get('id');
public Customer_Engagement__c CEdetails1;


    public PageReference addCateringBreaks() {



    	List<Customer_Engagement__c> CEList = [select Start_DateF__c from Customer_Engagement__c where Id =: CEId];
    	CEdetails1 = CEList.get(0);

                //We create a new list of Contacts that we be populated only with Contacts if they are selected
        List<Agenda_Content__c> selectedContents = new List<Agenda_Content__c >();


        //We will cycle through our list of cContacts and will check to see if the selected property is set to true, if it is we add the Contact to the selectedContacts list
        for(CateringBreakWrapper cCon: cateringBreaks ) {
            if(cCon.isChecked== true) {
                selectedContents.add(cCon.agendaContent);
            }
        }

        // Now we have our list of selected contacts and can perform any type of logic we want, sending emails, updating a field on the Contact, etc
        System.debug('These are the selected Contacts...');

        List<Agenda_Topic__c> topicList = new List<Agenda_Topic__c>();

        List<RecordType> recTyp = [Select r.Id, r.Name, r.SobjectType from RecordType r Where SobjectType='Agenda_Topic__c' and Name = 'Catering' And IsActive=true];



        for(Agenda_Content__c con: selectedContents) {

            Agenda_Topic__c topic = new Agenda_Topic__c();

            topic.RecordTypeId = recTyp.get(0).Id;
            topic.Start_Date__c = CEdetails1.Start_DateF__c;
            topic.Select_Meal__c = con.Id;
            topic.Name = con.Name;
            topic.Customer_Engagement__c = CEId;

            topicList.add(topic);



            system.debug('%%%%%%%%%%%%%%%%%%%%%%      '+con);

        }

        insert topicList;



    system.debug('###########   ' + cateringBreaks);

    system.debug('###########  ' +System.currentPageReference().getParameters());

    return  (PageUtils.redirect('/apex/AgendaBuilder?id='+CEId ));

    }


   // public string addCateringBreaks {get; set;}

    public List<CateringBreakWrapper> getAgendaContent() {

    List<Customer_Engagement__c> CEList = [select RecordTypeId,SiteF__c,Dell_Solution_Center_Site__c from Customer_Engagement__c where Id =: CEId];
    CEdetails1 = CEList.get(0);


    List <CateringBreakWrapper> wrapperObjects =  new List<CateringBreakWrapper> ();
    List<RecordType> recTypBreak = [Select r.Id, r.Name, r.SobjectType from RecordType r Where SobjectType='Agenda_Content__c' and Name = 'Breaks' And IsActive=true];
    string breakRecType = recTypBreak.get(0).Id;

    List<RecordType> recTypCE = [Select r.Id, r.Name from RecordType r Where SobjectType='Customer_Engagement__c' and Id =: CEdetails1.RecordTypeId  and IsActive=true];

    string siteId = '';
    string recTypeName = recTypCE.get(0).Name == 'Dell Solution Centers' ? 'DSC' : 'EBC';
    if(recTypeName == 'DSC'){
    	siteId = CEdetails1.Dell_Solution_Center_Site__c;

    } else {
    	List<Event_Location__c> eventLoc = [select Id from Event_Location__c where Name =: CEdetails1.SiteF__c] ;
    	siteId = eventLoc.get(0).Id;
    }
    //siteId = recTypeName == 'DSC' ? CEdetails1.Dell_Solution_Center_Site__c : CEdetails1.SiteF__c;

    system.debug('##### The record Type Name is  ' + recTypeName);


    List<Agenda_Content__c> contentList = [ select Name,Id from Agenda_Content__c
             where Break_Type__c = 'Catering'
             and Active__c = true
             and RecordTypeId =: breakRecType
             and Engagement_Type__c =: recTypeName
             and Apply_to_Site__c =: siteId
           ];


    for(Agenda_Content__c con : contentList ){
        CateringBreakWrapper wrappers = new CateringBreakWrapper(con);
        wrapperObjects.add(wrappers);



    }

    cateringBreaks = wrapperObjects ;

    return wrapperObjects ;
  }

  public void getAddCateringBreaks(){

   system.debug('###########  ' +System.currentPageReference().getParameters());

  }

}