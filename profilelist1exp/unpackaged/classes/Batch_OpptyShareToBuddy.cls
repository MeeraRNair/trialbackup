global class Batch_OpptyShareToBuddy implements Database.Batchable<sObject>,Database.Stateful {
    private Map<Id, List<Id>> mapwithRepidandBuddyid=new Map<Id,List<Id>>();
    private List<GDM_Request__c> listBuddyReq;
    private List<GDM_Request__c> listBuddyReqToUpdate=new List<GDM_Request__c>() ;
    public Set<Id> setgdmRequestId=new Set<Id>();
    Public String strQuery;
    Date dt = system.toDay();
    global Database.QueryLocator start(Database.BatchableContext bC){  
         listBuddyReq = [select id,name,Buddy__c,Opportunity_Access_To_Buddy__c,Rep_on_Leave__c,Buddy_Access_Start_Date__c,Buddy_Access_End_Date__c,Buddy_Access_Status__c from GDM_Request__c where (Buddy_Access_Status__c = 'Approved and scheduled' or Buddy_Access_Status__c = 'Providing Access' or Buddy_Access_Status__c = 'Access provided') and Buddy_Access_Start_Date__c <= today and Buddy_Access_End_Date__c >= tomorrow and recordtype.developerName = 'Buddy_Access' and Opportunity_Access_To_Buddy__c=false];
        System.debug('Rajesh>>>>'+listBuddyReq);
      for(GDM_Request__c objGDM:listBuddyReq){
                objGDM.Opportunity_Access_To_Buddy__c = true;
                listBuddyReqToUpdate.add(objGDM);
        }
        System.debug('Rajesh>>>>listBuddyReqToUpdate'+listBuddyReqToUpdate);
  
   If(! listBuddyReqToUpdate.IsEmpty()){
            TriggerExecutionController.setskipGDMRequestTriggers(true);
            Database.SaveResult[] listsrList = Database.Update(listBuddyReqToUpdate,false);//3.0 start
            if(listsrList !=null){
          for(Database.SaveResult sr:listsrList ){
            if(sr.isSuccess()){
            System.debug('sr.getId()>>>'+sr.getId());
                setgdmRequestId.add(sr.getId());
       
            }
          }
            }
            TriggerExecutionController.setskipGDMRequestTriggers(false);                
        }
     
        if(setgdmRequestId!=null && setgdmRequestId.Size()>0 && ! setgdmRequestId.IsEmpty()){
                    for(GDM_Request__c gd:[select id,name,Buddy__c,Rep_on_Leave__c,Buddy_Access_Start_Date__c,Buddy_Access_End_Date__c,Buddy_Access_Status__c from GDM_Request__c where id IN:setgdmRequestId and (Buddy_Access_Status__c = 'Approved and scheduled' or Buddy_Access_Status__c = 'Providing Access' or Buddy_Access_Status__c = 'Access provided') and Buddy_Access_Start_Date__c <= today and Buddy_Access_End_Date__c >= tomorrow and recordtype.developerName = 'Buddy_Access']){  
                            If(mapwithRepidandBuddyid.get(gd.Rep_on_Leave__c) == null) {
                                    mapwithRepidandBuddyid.put(gd.Rep_on_Leave__c, new list <Id> {gd.Buddy__c});
                            } else {
                                    mapwithRepidandBuddyid.get(gd.Rep_on_Leave__c).add(gd.Buddy__c);
                                }
                    }   
         
        }
         System.debug('Rajesh>>>>mapwithRepidandBuddyid'+mapwithRepidandBuddyid);
        if(mapwithRepidandBuddyid.keyset() !=null){
        Set<Id> setkeys=mapwithRepidandBuddyid.keyset();
           strQuery = 'SELECT Id, UserId,OpportunityId,OpportunityAccessLevel FROM OpportunityTeamMember WHERE (Opportunity.RecordTypeid= ' + '\'' + '012A0000000Vjtg' + '\'' + ' AND UserId IN:setkeys' + ' AND Opportunity.Deal_Expiration_Date__c !=Null' + ' AND Opportunity.Deal_Expiration_Date__c >:dt' + ' AND Opportunity.Deal_Registration_Status__c= ' + '\'' + 'Approved' + '\'' + ' AND Opportunity.Deal_Reg_Oppty__c=' + '\'' + 'Yes' + '\'' + ') OR (Opportunity.RecordTypeid= ' + '\'' + '012A0000000Vjtg' + '\'' + ' AND UserId IN:setkeys'+' AND Opportunity.ownerId IN :Setkeys'+' AND Opportunity.Deal_Reg_Oppty__c=' + '\'' + 'No' + '\'' + ')'; 
                     System.debug('Rajesh>>>>strQuery'+strQuery);
                     }
        
                return Database.getQueryLocator(strQuery);
            
    }
    
        global void execute(Database.BatchableContext bC, list<OpportunityTeamMember> listOpptyTeamMember){
        Map<Id, List<opportunityTeammember>> mapwithRepidandOpptyteamMember=new Map<Id, List<opportunityTeammember>>();
        List<OpportunityShare> listOpportunityshare=new List<OpportunityShare>();
         System.debug('Rajesh>>>>listOpptyTeamMember'+listOpptyTeamMember);
        If(! listOpptyTeamMember.IsEmpty()){
        for (OpportunityTeamMember opptyTeamMember:listOpptyTeamMember ) {
                If(mapwithRepidandOpptyteamMember.get(opptyTeamMember.UserId) == null) {
                    mapwithRepidandOpptyteamMember.put(opptyTeamMember.UserId, new list <OpportunityTeamMember> {opptyTeamMember});
        } else {
                    mapwithRepidandOpptyteamMember.get(opptyTeamMember.UserId).add(opptyTeamMember);
                }
        }
    
    System.debug('Rajesh>>>>mapwithRepidandOpptyteamMember'+mapwithRepidandOpptyteamMember);
        if( mapwithRepidandBuddyid.keyset() !=null ){

        for(Id repId: mapwithRepidandBuddyid.keyset()){
        system.debug('Rajeshrep'+repId);
          for(Id buddyId: mapwithRepidandBuddyid.get(repId)){
              system.debug('Rajeshbuddy'+buddyId);
              if(mapwithRepidandOpptyteamMember.get(repId) !=null){
                for(opportunityTeammember otm: mapwithRepidandOpptyteamMember.get(repId)){
                    OpportunityShare oppShare = new OpportunityShare();
                    oppShare.UserOrGroupId= buddyId; 
                    oppShare.OpportunityId= otm.opportunityid; 
                    oppShare.OpportunityAccessLevel= 'Edit';
                     system.debug('RajeshUserOrGroupId'+oppshare.UserOrGroupId);
                      system.debug('oppShare'+oppShare);
                    listOpportunityshare.add(oppShare);
                    
                }   
        }
            }
        }
    
    }
    If(!listOpportunityshare.IsEmpty()){
    Database.SaveResult[] listsharerec = Database.Insert(listOpportunityshare,false);
       // Insert listOpportunityshare;
    }
    }
        }
    global void finish(Database.BatchableContext bC){
               
    }  

}