/*
 * Author : 
 *
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR            R16.07    23-Jun-2015     Devika          Update the logic in the class to include multi LOB functionality
 * 2.0      CR12408       R16.12    30-Nov-2015     Jiji            To change send the LOB expiration notification when ‘Days until LOB Expires’ changes to 35
 * 3.0      CR12409       R16.12    30-Nov-2015     Jiji            To change the LOB Registration Status = Expired/Open when the ‘Days until LOB Expires’ changes to 0.
            CR            O1O2      12-Dec-2018     Hari A           STORY 5907651 Removed reference for the fields lob_registration_id__c
 */
 
global class LOBRRegistrationScheduleExecute implements Schedulable{
    
    global void execute(SchedulableContext sc) {
        map<string,id> LobIdtoacctIdMap = new map<string,id>();
        set<id> accids=new set<id>();
        set<id> lobset = new set<id>();
        set<id> lobset1 = new set<id>();
        Map<Id, LOB_Registration__c> LOBIdtoRecordMap = new Map<Id, LOB_Registration__c>();
        //Ver 2.0: Start
        //map<id,id> loblist = new map<id,id>();
        //for( LOB_Registration__c l:[SELECT id,CreatedDate,Preferred_GTM_Partner_Account__r.id FROM LOB_Registration__c where Lobregistration_Noofdays__c=275]){
        
        for( LOB_Registration__c l:[SELECT id,CreatedDate,Preferred_GTM_Partner_Account__r.id, Days_Until_LOB_Expires__c, Renewed_Date__c,
                                    LOB_Registration_Renewed__c
                                    FROM LOB_Registration__c 
                                    where (Days_Until_LOB_Expires__c=35 OR Days_Until_LOB_Expires__c=0 OR Days_Until_LOB_Expires__c=5 ) 
                                    AND LOB_registration_status__c = 'Partner(Approved)']){
        
            string s =l.id;
            string si=s.left(15);  
            LobIdtoacctIdMap.put('%'+si+'%',l.Preferred_GTM_Partner_Account__r.id);  
            lobset.add(l.Id);                
            if(l.Days_Until_LOB_Expires__c== 35){
                LOBIdtoRecordMap.Put(l.Id, l);
                accids.add(l.Preferred_GTM_Partner_Account__r.id);
            } 
             if(l.Days_Until_LOB_Expires__c== 5){
                LOBIdtoRecordMap.Put(l.Id, l);
                accids.add(l.Preferred_GTM_Partner_Account__r.id);
            } 
            //loblist.put(l.id,l.Preferred_GTM_Partner_Account__r.id);
        }
        //Ver 2.0: End
        
        Set<Id> lobOppSet =new Set<Id>();
        /*Ver 2.0: comment Start
        for(Opportunity opp :[SELECT Id,LOB_Registration_ID__c FROM Opportunity WHERE LOB_Registration_ID__c LIKE:lob.keyset() // v1.0 IN:lob.keyset()   AND PartnerAccountId IN:lob.values()
                            and (Stage_Changed_On__c = N_DAYS_AGO:275 OR Stage_Changed_On__c > N_DAYS_AGO:275)  and (StageName = 'Win - 100%'
                            OR  (StageName != 'Lost, Cancelled - 0%' AND StageName != 'Win - 100%' ))])
        {
        Ver 2.0: comment End */
            /******** v1.0 Commented Code
            if(lobOppcounter1.containsKey(opp.LOB_Registration_ID__c))
            {
                integer counter1=lobOppcounter1.get(opp.LOB_Registration_ID__c);
                counter1++;
                lobOppcounter1.put(opp.LOB_Registration_ID__c,counter1);
            }
            else
            {
                lobOppcounter1.put(opp.LOB_Registration_ID__c,1);
            }

            ****/
        
       /* for(Opportunity opp :[SELECT Id,LOB_Registration_ID__c, Stage_Changed_On__c FROM Opportunity 
                                WHERE LOB_Registration_ID__c LIKE :LobIdtoacctIdMap.keyset()
                                and StageName = 'Win - 100%' ])
        {
            /*************** v1.0 Starts **************/
         /*   if(!opp.LOB_Registration_ID__c.contains(';')){
                lobOppSet.add(opp.LOB_Registration_ID__c);  
            }else{        
                List<String> opptylobList = opp.LOB_Registration_ID__c.split(';');                    
                for(String lobId :opptylobList){
                    lobOppSet.add(lobId ); 
                }           
            }*/
            /*************** v1.0 Ends **************/
          //  system.debug('----lobOppSet----'+lobOppSet);
            /*Ver 2.0: Start*/     
       /*     for(Id i : lobOppSet){
                if(LOBIdtoRecordMap.get(i) != NULL && 
                    (LOBIdtoRecordMap.get(i).Days_Until_LOB_Expires__c == 35 || LOBIdtoRecordMap.get(i).Days_Until_LOB_Expires__c == 5 )){
                    If(LOBIdtoRecordMap.get(i).LOB_Registration_Renewed__c == False && 
                        LOBIdtoRecordMap.get(i).Renewed_Date__c == NULL){
                        lobset1.add(i); 
                    }
                    else{
                        If(LOBIdtoRecordMap.get(i).LOB_Registration_Renewed__c == TRUE &&
                            opp.Stage_Changed_On__c != NULL && 
                            opp.Stage_Changed_On__c >= LOBIdtoRecordMap.get(i).Renewed_Date__c
                        ){
                            lobset1.add(i);
                        }
                        
                    }
                }
            }
            /*Ver 2.0: End*/ 
        //}
        
        /*for(id i :LOBIdtoRecordMap.keyset()){
            if(!lobset1.contains(i)){
                  // lob have z oppoprtunities
                lobset.add(i);
                accids.add(LOBIdtoRecordMap.get(i).Preferred_GTM_Partner_Account__r.id);
            }
        }*/
        
      /*  if(lobset1 != NULL && lobset != NULL){
            lobset.removeAll(lobset1);                
        }*/
        if(lobset.size()>0){
            BatchLobregistrationEmail batchObj = new BatchLobregistrationEmail(lobset,accids);
            Database.executeBatch(batchObj,5);
        }
    }
}