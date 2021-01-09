/***********************************************************
* Name          : Partner Track Relationship Change Event
*  
* ---------------------------------------------------------
* Revision  Name            Date                Description
* 1.0                                           created

************************************************************/
public class PartnerOnboardingPTRUtility {
    
    public static void createAccountShare(List<Partner_Track_Relationship__ChangeEvent> listNewPTRs){
        List<String> listSMAffinityIds = new List<String>();
        List<String> listMGAffinityIds = new List<String>();
        List<String> listPTAffinityIds = new List<String>();
        
        List<String> listSMAffIds = new List<String>();
        List<String> listMGAffIds = new List<String>();
        List<String> listPTAffIds = new List<String>();
        
        List<String> listPTRRecordIds = new List<String>();
        
        // To hold the new Affinity Id related to SM
        List<String> listRSMAffinityIds = new List<String>();
        List<String> listRMGAffinityIds = new List<String>();
        List<String> listRPTAffinityIds = new List<String>();
        
        List<Partner_Track_Relationship__c> listPTRRecords = new List<Partner_Track_Relationship__c>();
        // To hold the PT and SM Count
        Map<String,Integer> mapPTToSM = new Map<String,Integer>();
        //To hold the Accounts related to the PT's
        List<Account> listAcc = new List<Account>();
        
        try{
            for(Partner_Track_Relationship__ChangeEvent ptrChange : listNewPTRs){
                if (ptrChange.ChangeEventHeader.getChangetype()  == 'CREATE' ) {
                    EventBus.ChangeEventHeader header = ptrChange.ChangeEventHeader;
                    System.debug('Received change event for ' + header.entityName +' for the ' + header.changeType + ' operation.'); 
                    listPTRRecordIds = ptrChange.ChangeEventHeader.getRecordIds();
                    system.debug('listPTRRecordIds******'+listPTRRecordIds);
                    Map<String,Object> mapEventChanges = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(ptrChange));
                    system.debug('mapEventChanges*****'+mapEventChanges);
                    if(mapEventChanges.containsKey('Is_Processed__c') && mapEventChanges.get('Is_Processed__c') == true){
                        listPTAffinityIds.add(ptrChange.Partner_Track_AffinityId__c);
                    }
                    
                }
                if (ptrChange.ChangeEventHeader.getChangetype()  == 'UPDATE' ) {
                    EventBus.ChangeEventHeader header = ptrChange.ChangeEventHeader;
                    listPTRRecordIds = ptrChange.ChangeEventHeader.getRecordIds();
                    system.debug('listPTRRecordIds******'+listPTRRecordIds);
                    Map<String,Object> mapEventChanges = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(ptrChange));
                    system.debug('mapEventChanges*****'+mapEventChanges);
                    //Revoke the existing access
                    if(mapEventChanges.containsKey('Relationship_Status__c') && mapEventChanges.containsKey('Relationship_Status__c') == false){
                        listRPTAffinityIds.add(ptrChange.Partner_Track_AffinityId__c);
                        listRSMAffinityIds.add(ptrChange.Sales_Motion_Account_AffinityId__c);
                        listRMGAffinityIds.add(ptrChange.Master_Group_AffinityId__c);
                    }
                    if(mapEventChanges.containsKey('Is_Processed__c') && mapEventChanges.get('Is_Processed__c') == true 
                       // && mapEventChanges.containsKey('Relationship_Status__c') && mapEventChanges.get('Relationship_Status__c') == true &&
                       //(mapEventChanges.containsKey('Sales_Motion_Account_AffinityId__c') || mapEventChanges.containsKey('Partner_Track_AffinityId__c') ||
                       // mapEventChanges.containsKey('Master_Group_AffinityId__c'))
                      ){
                            listPTAffinityIds.add(ptrChange.Partner_Track_AffinityId__c);
                        }
                    
                    
                }
            }
            
            System.debug('lstRSMAffinityIds'+listRSMAffinityIds);
            System.debug('lstRMGAffinityIds'+listRMGAffinityIds);
            System.debug('lstRPTAffinityIds'+listRPTAffinityIds);
            if(listRSMAffinityIds.size() > 0 && listRMGAffinityIds.size() > 0 && listRPTAffinityIds.size() > 0){
                System.debug('invoke remove AccessToSM');
                PTRHandler.grantRevokeAccessToSM(listRSMAffinityIds,listRMGAffinityIds,listRPTAffinityIds,System.Label.Revoke_Access_Type);
            }
            
            if(listPTRRecordIds.size() > 0 && listPTAffinityIds.size() > 0){
                listPTRRecords =[SELECT Id,Sales_Motion_Account_AffinityId__c,Is_Processed__c,Relationship_Status__c,
                                 Master_Group_AffinityId__c,Partner_Track_AffinityId__c 
                                 FROM Partner_Track_Relationship__c
                                 WHERE Id IN: listPTRRecordIds
                                 AND Is_Processed__c = true
                                 AND Relationship_Status__c = true
                                 AND Partner_Track_AffinityId__c IN: listPTAffinityIds
                                ];
      
            }
            
            if(listPTAffinityIds.size() > 0){
                for (AggregateResult aggRes : [SELECT COUNT(ID) AccountCount,Partner_Track__r.Partner_Track_AffinityId__c partnerTrackAff FROM Account WHERE Partner_Track__r.Partner_Track_AffinityId__c IN: listPTAffinityIds GROUP BY Partner_Track__r.Partner_Track_AffinityId__c ]) {
                    String strPTAffId = (String) aggRes.get('partnerTrackAff');
                    Integer intSMCount = (Integer) aggRes.get('AccountCount');
                    mapPTToSM.put(strPTAffId, intSMCount);
                }
            }
            
            if(listPTRRecords.size() > 0){
                for(Partner_Track_Relationship__c newPTR : listPTRRecords){
                    // A SM with a given MG and PT already exists
                    if(mapPTToSM.get(newPTR.Partner_Track_AffinityId__c) > 1){
                        listSMAffIds.add(newPTR.Sales_Motion_Account_AffinityId__c);
                        listMGAffIds.add(newPTR.Master_Group_AffinityId__c);
                        listPTAffIds.add(newPTR.Partner_Track_AffinityId__c);
                    }
                    
                }
                
            }
            if(listSMAffIds.size() > 0 && listMGAffIds.size() > 0 && listPTAffIds.size() > 0){
                System.debug('invoke grantAccessToSM');
                PTRHandler.grantRevokeAccessToSM(listSMAffIds,listMGAffIds,listPTAffIds,System.Label.Grant_Access_Type);
            }
        }
        catch(Exception e){}
    }
    
   
    
    

}