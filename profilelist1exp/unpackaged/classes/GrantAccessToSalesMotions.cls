/**
 * Controller logic for granting access to sales motion accounts.
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------     -----------     ------------    -----------
 *                       FY20-0402     4-Jan-2018      Sneha         Logic to implement revoke and grant access
*/
global class GrantAccessToSalesMotions implements Database.Batchable<sObject>,Database.Stateful {
    global Database.QueryLocator start(Database.BatchableContext bc){
        List<string> listrecordIds = new List<String>();
        /*listrecordIds.add('001K000001VWK7YIAX');
        listrecordIds.add('001K000001VWK7KIAX');
        listrecordIds.add('001K000001VWK7IIAX');
        listrecordIds.add('001K000001VWK75IAH');
        listrecordIds.add('001K000001VWK6wIAH');
        listrecordIds.add('001K000001VWK6aIAH');
        listrecordIds.add('001K000001VWK6YIAX');
        listrecordIds.add('001K000001VWK63IAH');
        listrecordIds.add('001K000001VWKB8IAP');
        listrecordIds.add('001K000001VWKB3IAP');
        listrecordIds.add('001K000001VWK9BIAX');*/
        String strQuery;
        
        strQuery = 'SELECT id, EligibleTracks__c,Partner_User__c, AccountId from Contact where Partner_User_Active__c = true';//and AccountID IN: listrecordIds
     // query ='SELECT Id,EligibleTracks__c,Partner_User__c FROM Contact Where Partner_User_Active__c = true and Id IN: recordIds';
         return Database.getQueryLocator(strQuery);
     }
   
    global void execute(Database.BatchableContext bc, List<Contact> listscope){
        // To hold all the Eligible tracks an track admin need access to
        Set<String> setPTIds = new Set<String>();
        // Map to hold Partner Track Vs Sales Motion Account Ids
        Map<String, List<String>> mapPTToSM = new Map<String, List<String>>();
       //To hold User vs PT
        Map<String,List<String>> mapUserToPT = new Map<String,List<String>>();
        //To hold User Vs SM
        Map<String, List<String>> mapUsrIdToSM = new Map<String, List<String>>();
        // To hold the Account Share to insert
        List<AccountShare> listAccShareinsert = new List<AccountShare>();
        //To hold the existing Account Share records
        List<AccountShare> listAccShareExists = new List<AccountShare>();
        // To By pass Duplicate ids Exception
        map<id,AccountShare> mapAccShareIns = new map<id,AccountShare>(); 
        
        for (Contact con : listscope) {
             // To hold the list of Track Ids
             List<String> listPartnerTrackIds = new List<String>();
             if(String.isNotBlank(con.EligibleTracks__c)){
             
             if(String.valueOf(con.EligibleTracks__c).contains(';')){
                listPartnerTrackIds = String.valueOf(con.EligibleTracks__c).trim().split(';');
                System.debug('listPartnerTrackIds in if::'+listPartnerTrackIds);
                setPTIds.addAll(listPartnerTrackIds);
                mapUserToPT.put(con.Partner_User__c, new List<String>(listPartnerTrackIds));
             }
             else{
                listPartnerTrackIds.add(String.valueOf(con.EligibleTracks__c).trim());
                System.debug('listPartnerTrackIds in else::'+listPartnerTrackIds);
                setPTIds.add(String.valueOf(con.EligibleTracks__c).trim());
                mapUserToPT.put(con.Partner_User__c, new List<String>(listPartnerTrackIds));
             }
             }
             
        }
        System.debug('setPTIds'+setPTIds);
        System.debug('mapUserToPT::'+mapUserToPT);
        List<Account> listAcc = new List<Account>();
        // Prepare a Map of Partner Track Vs Sales Motion
        if(setPTIds.size() > 0){
             listAcc = [Select Id,Name,Partner_Track__c from Account where Partner_Track__c IN : setPTIds]; 
             if(listAcc.size() > 0){
                for(Account acc : listAcc){
                    if(mapPTToSM.containsKey(acc.Partner_Track__c)){
                        mapPTToSM.get(acc.Partner_Track__c).add(acc.Id);
                    }
                    else{
                        mapPTToSM.put(acc.Partner_Track__c,new List<String>{ acc.Id}); 
                    }
                }
                System.debug('mapPTToSM'+mapPTToSM);
             }
        }
        // Validate if for a contact we have Partner Tracks and Partner Tracks have Sales Motion (Extra Check)
        if(mapUserToPT.size() > 0 && mapPTToSM.size() > 0){
            for(Contact con : listscope){
                  if(mapUserToPT.containsKey(con.Partner_User__c)){
                    for(String strEligibleTrack : mapUserToPT.get(con.Partner_User__c)){
                        System.debug('strEligibleTrack'+strEligibleTrack);
                        if(mapPTToSM.containsKey(strEligibleTrack)){
                            if(mapUsrIdToSM.containsKey(con.Partner_User__c)){
                                mapUsrIdToSM.get(con.Partner_User__c).addAll(mapPTToSM.get(strEligibleTrack));
                            }else{
                                mapUsrIdToSM.put(con.Partner_User__c, new List<String>(mapPTToSM.get(strEligibleTrack)));
                            }
                        }                        
                    }
                    
                }
                
            }
            System.debug('mapUsrIdToSM'+mapUsrIdToSM); 
            }
        
        if(mapUsrIdToSM.size() > 0){
           // Check if the share record already exists
           listAccShareExists = [SELECT Id,AccountId,UserOrGroupId
                                  FROM AccountShare
                                  WHERE RowCause=:'Manual' 
                                  AND UserOrGroupId IN: mapUsrIdToSM.keySet() 
                                 ];
        
            System.debug('listAccShareExists'+listAccShareExists.size());
            //map to hold the User vs AccountId's
            Map<String,List<AccountShare>> mapShareUsrToSM = new Map<String,List<AccountShare>>();
            if(listAccShareExists.size() > 0){
                for(AccountShare accSh : listAccShareExists){
                    if(mapShareUsrToSM.containsKey(accSh.UserOrGroupId)){
                        mapShareUsrToSM.get(accSh.UserOrGroupId).add(accSh);
                    }
                    else{
                        mapShareUsrToSM.put(accSh.UserOrGroupId,new List<AccountShare>{ accSh }); 
                        }
                    
                }
                System.debug('mapShareUsrToSM::'+mapShareUsrToSM);
            }
            
            for(Contact con : listscope){
               if(mapUsrIdToSM.containsKey(con.Partner_User__c)){
                   if(mapShareUsrToSM.containsKey(con.Partner_User__c) && mapShareUsrToSM.get(con.Partner_User__c)!=null){
                        List<String> listAccountIds = new List<String>();
                        for(AccountShare accShare : mapShareUsrToSM.get(con.Partner_User__c)){
                                   listAccountIds.add(accShare.AccountId);
                       }
                       for(String strAccId : mapUsrIdToSM.get(con.Partner_User__c)){
                           System.debug('strShareAcc::'+mapShareUsrToSM.get(con.Partner_User__c));
                           if(listAccountIds.contains(strAccId)){
                                    System.debug('Account Share already exists for the user '+con.Partner_User__c+' and account combination:');
                           }
                           else{
                                 System.debug('Create Account Share for Account:'+strAccId);
                                 AccountShare accShare = new Accountshare();
                                 accShare.AccountId = strAccId;
                                 accShare.UserOrGroupId = con.Partner_User__c;
                                 accShare.AccountAccessLevel = 'Read';
                                 accShare.OpportunityAccessLevel='None';
                                 accShare.RowCause='Manual';
                                 listAccShareInsert.add(accShare);
                           }
                      }
                   }
                   else{
                        for(String strAcctId : mapUsrIdToSM.get(con.Partner_User__c)){
                            AccountShare accShare = new Accountshare();
                            accShare.AccountId = strAcctId;
                            accShare.UserOrGroupId = con.Partner_User__c;
                            accShare.AccountAccessLevel = 'Read';
                            //accShare.CaseAccessLevel ='Read';
                            accShare.OpportunityAccessLevel='None';
                            accShare.RowCause='Manual';
                            listAccShareinsert.add(accShare);
                        }
                   }
                 }
                
            }
            System.debug('listAccShareinsert'+listAccShareinsert);
            if(listAccShareinsert.size() > 0){
            mapAccShareIns.putAll(listAccShareinsert);
                 Database.SaveResult[] listSR = Database.insert(listAccShareinsert,false);
                    for (Database.SaveResult sr : listSR) {
                        if(sr.isSuccess()){
                            System.debug('Inserted Successfully');
                        }
                        else {
                             ExceptionHandlingCtrl.exceptionHandlingMethod(listSR , 'AccountShare', 'Accont Share Insertion', 'Exception', mapAccShareIns.values());
                        }
                        
                    }
                
            }
        }
           
    }        
    
    global void finish(Database.BatchableContext bc){
        System.debug('Completed!!!');
    }

}