public class PartnerOnBoardingUtilitycntrl {
    public List<AccountShare> chkandaddshare(String straccId){
        List<AccountShare> listacc=new List<AccountShare>();
        Integer intaccShareCount = [select count() from AccountShare where UserOrGroupId = : userinfo.getUserId() and AccountId = :straccId];
        if (intaccShareCount == 0){
            AccountShare accShare = new AccountShare();
            accShare.AccountId = straccId;
            accShare.UserOrGroupId = userinfo.getUserId();
            accShare.AccountAccessLevel = 'Read';
            accShare.OpportunityAccessLevel = 'None';
            accShare.CaseAccessLevel = 'None';
            // insert accShare;
            listacc.add(accShare);
        }
        return listacc;
    }
    /*public static list<Agenda__c> agendaclass(List<Agenda__c> listassignedAgenda,ApexPages.StandardController standardController){
        Datetime dtstartingDateTime ;
        List<Agenda__c> listSortedAgendaItems = new List<Agenda__c>();
        List<Agenda__c> listpresenterAgItem=new List<Agenda__c>();
        List<Agenda__c> listagendaItemList=new List<Agenda__c>();
        List<DateTime> listkeyStartDatesList =  new list<dateTime>();
        Map<Date, Agenda__c> mapsortedAgendaMap=new Map<Date, Agenda__c>();
        Map<DateTime, Map<DateTime, List<Agenda__c>>> mapparentMap=new Map<DateTime, Map<DateTime, List<Agenda__c>>>();
        Map<DateTime, List<Agenda__c>> mapchildMap=new Map<DateTime, List<Agenda__c>>();
        printAgendaController pg=new printAgendaController(standardController);
        for(Agenda__c agendaTemp: listassignedAgenda){
            if(agendaTemp.Starting_Date__c!=null ){
                if((agendaTemp.Start_Time__c!=null)&&(agendaTemp.End_Time__c!=null)){
                    DateTime dtstartDateTime =  pg.convertTodateTime (agendaTemp.Starting_Date__c,agendaTemp.Start_Time__c);
                    DateTime dtendDateTime =  pg.convertTodateTime (agendaTemp.Starting_Date__c,agendaTemp.End_Time__c);
                    if (mapparentMap.containsKey(dtStartDateTime)) {
                        if(mapparentMap.get(dtStartDateTime).containsKey(dtendDateTime))
                            mapparentMap.get(dtStartDateTime).get(dtendDateTime).add(agendaTemp);
                        else
                            mapparentMap.get(dtStartDateTime).put(dtendDateTime,new List<Agenda__c>{agendaTemp});
                    }
                    else{
                        mapchildMap=new Map<DateTime, List<Agenda__c>>(); 
                        listagendaItemList=new List<Agenda__c >();
                        listagendaItemList.add(agendaTemp);
                        mapchildMap.put(dtendDateTime,listagendaItemList);
                        mapparentMap.put(dtStartDateTime,mapchildMap);               
                    }
                }
                else{
                    listpresenterAgItem.add(agendaTemp);
                }
            }
            else{
                PageUtils.addError('Start date missing in one of the record.Please add the start date.');
            }
        }
        listkeyStartDatesList.addAll(mapparentMap.keySet());
        listkeyStartDatesList.sort();
        Map<DateTime, List<Agenda__c>> mapchildMapNew=new Map<DateTime, List<Agenda__c>>();     
        for(DateTime parentKey : listkeyStartDatesList){
            list<DateTime> keyEndDatesList =  new list<dateTime>();
            mapchildMapNew=new Map<DateTime, List<Agenda__c>>();
            mapchildMapNew=mapparentMap.get(parentKey);
            keyEndDatesList.addAll(mapchildMapNew.keySet());
            keyEndDatesList.sort();
            for(DateTime childKey : keyEndDatesList ){
                listSortedAgendaItems.addAll(mapchildMapNew.get(childKey ));
                system.debug('SortedAgendaItems:'+listSortedAgendaItems);
            }
        }
        return listSortedAgendaItems;
    }*/
}