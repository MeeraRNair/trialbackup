public class VOupdateUseronVisit_PB{ 
    
    @InvocableMethod 
    public static void execute() {
        list<user> updateUsers=new list<user>();
        map<id,user> userIDvsUser=new map<id,user>([select id from user where Is_not_Synced__c=true]);
        
        system.debug('**userIDvsUser'+userIDvsUser);
        List < VisitOps__Visit__c > Visits = [select id, Name,VisitOps__VisitOwner__r.VisitOps__Full_Name__c, ownerId,
                                              VisitOps__VisitManager__r.VisitOps__Full_Name__c,VisitOps__ApproverName__r.VisitOps__Full_Name__c,
                                              VisitOps__Alternate_Manager__r.VisitOps__Full_Name__c,VisitOps__VisitCoordinator__r.VisitOps__Full_Name__c,
                                              VisitOps__VisitManager__r.email,VisitOps__VisitManager__r.phone
                                              from VisitOps__Visit__c where 
                                              ownerId in : userIDvsUser.keyset()
                                              and visitops__visitname__c!='ReferenceVisit - DoNotDelete'
                                              and VisitOps__Portal_Visit__c!=true limit 10000];
        
        List < VisitOps__Visit__c > UpdateVisits = new List < VisitOps__Visit__c > ();
        for (VisitOps__Visit__c v: Visits) {
            UpdateVisits.add(v);
        }
        system.debug('**UpdateVisits'+UpdateVisits);
        if(!UpdateVisits.isEmpty()){
            //VORecursiveTriggerHandler.isFirstTime=false;
            update UpdateVisits;
        }
        for(id usr:userIDvsUser.keyset()){
            user UpdateUsr= new user();
            UpdateUsr.id=usr;
            UpdateUsr.Is_not_Synced__c=false;
            updateUsers.add(UpdateUsr);
        }
        if(!updateUsers.isEmpty()){
            update updateUsers;
        }
    }
}