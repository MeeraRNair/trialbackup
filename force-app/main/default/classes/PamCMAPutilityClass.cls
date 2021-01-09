//-------------------------------------------------------------------------------------------------------------------------
/*  
Version     Name        Date            CR#         Description
Create      Yamini      04-Feb-2019     CR17115     Story 6070726: Channel: [PAM] Update Mass Lead Upload Requests design in Partner Portal
1.0         Shue        03-Mar-2019     CR17115     Cleanup codes
1.1         Shue        12-Mar-2019     CR17115     Add filter record type in Account query
2.0         Ankur       13-Mar-2019     CR17116     Story 6098770: Channel: [PAM-Technical] Lead Share
3.0         Shue        14-Mar-2019     CR17125     FY20-0402: Defect 6326439: SDET - Wunderkind:: CAMP:: FY20-0402:: Unable to submit MLUR - <apex:param name="accName" value="{!strSelectedItem}" />
*/ 
//-------------------------------------------------------------------------------------------------------------------------
public without sharing class PamCMAPutilityClass{   
    //Pass the logged in User Id to get the Salesmotion account from the selected track
    public static List<Account> getSalesmotionAccounts(id partneruserId) {
        String strPartnerIdcroped = partneruserId;
        strPartnerIdcroped = strPartnerIdcroped.left(15);
        System.debug('UserID'+strPartnerIdcroped);

        id partnerUserContactId = [Select Id, ContactId From User Where id=:strPartnerIdcroped].contactId;
        System.debug('PartnerUserContactId'+PartnerUserContactId);
        String strContactIdcroped = partnerUserContactId;
        strContactIdcroped = strContactIdcroped.left(15);
        System.debug('Cropped contact Id'+strContactIdcroped);
        
        List<Contact> listContactquery = [Select Id,Selected_Track__c from Contact Where Id = :strContactIdcroped];
        System.debug('Contact selected track : '+listContactquery[0].Selected_Track__c);
        id selectedTrackCropped = listContactquery[0].Selected_Track__c;        
        
        List<Account> listSMAccount=[Select Id, Name, Account_ID__c, Partner_Track_Name__c, Master_Group_Id__c From Account Where recordtype.name = 'Partner Account' AND Partner_Track__c = :listContactquery[0].Selected_Track__c LIMIT 999 /* (select contact.Selected_Track__c from Contact Where Id = :strContactIdcroped ) */];
        System.debug('SMAs'+listSMAccount);
        return listSMAccount;
    }
    
    // Method to fetch active contact and users for a give sales motion ID
    public static list<id> getUserssUnderSalesMotion(Account salesAccountObj){
        List<String> listEligibleTracksId;
        List<Id> listSalesMotionActiveCon = new List<ID>();
    
        //Getting all contacts based on masteraccountid
        for(Contact con: [SELECT Id, AccountId, Partner_User__c, EligibleTracks__c, Name, Partner_User_Partner_Admin__c, Decision_Making_Role__c, NPS_Qualified_Status__c, Primary_Contact_for_Service_Type__c, Partner_User_Active__c, Email, Status__c, Phone, Partner_User_Deal_Registration__c FROM Contact WHERE 
            AccountId =: salesAccountObj.Master_Group_Id__c]){
            //3.0
            //AccountId =: salesAccountObj.id]){
            listEligibleTracksId = new List<String>();
            
            system.debug('@@@@@@@@@con'+con);
            if(String.isNotBlank(con.EligibleTracks__c)){
            
             system.debug('@@@@@@@@@insideIff'+con);   

                    system.debug('@@@@@@@@@insideIff1'+salesAccountObj.Partner_Track__c);   

                           system.debug('@@@@@@@@@insideIff2'+con.Status__c);   

                    listEligibleTracksId = con.EligibleTracks__c.split(';');
          
                                     system.debug('@@@@@@@@@insideIff3'+listEligibleTracksId);   

                    if(listEligibleTracksId.contains(salesAccountObj.Partner_Track__c) && (con.Status__c == 'Customer' || con.Status__c == 'Active' || con.Status__c == 'Prospect' || con.Status__c == 'Marketing Suspect' || con.Status__c == 'INTERNAL - Crisis Mgmt')){
                                     system.debug('@@@@@@@@@insideIff4'+con);   

                        listSalesMotionActiveCon.add(con.id);
                    }
                
            }
            system.debug('@@@@@@@@@listSalesMotionActiveCon'+listSalesMotionActiveCon);
        }
        List<id> listSMAUserIds = new List<id>();
        LIst<Contact> listSalesmotionContactrecords = [Select Name, Id, Partner_User__c From Contact where id=:listSalesMotionActiveCon];
        for(Contact sMACont:listSalesmotionContactrecords){
            listSMAUserIds.add(SMACont.Partner_User__c);
        }
        system.debug('@@@@@@@@@listSMAUserIds'+listSMAUserIds);
        system.debug('@@@@@@@@@listSMAUserIds'+listSMAUserIds);
        return listSMAUserIds;
    }   
    
    
    public static map<id,list<user>> getUserssUnderSalesMotionList(set<Id> setSalesAccountid){
        map<id,Account> mapSmToMGroupId = new map<id,Account>();
        Set<Id> setMasterId= new Set<Id>();
        set<Id> setUserId = new Set<id>();
        map<id,list<user>> mapSmToUser = new map<id,list<user>>(); 
        map<id,User> mapSalesmotionToUser = new map<id,User>();
        list<User> listUser  = new list<User>();
        
        if(!setSalesAccountid.isempty()){
            for(Account acc : [select id,name , Master_Group_Id__c,Partner_Track__c from Account where Id IN :setSalesAccountid]){
                if(acc.Master_Group_Id__c != null){
                    mapSmToMGroupId.put(acc.id,acc);
                    setMasterId.add(acc.Master_Group_Id__c);
                }
            }
        }
        
        if(!setMasterId.isempty()){
            list<contact> listContact= [SELECT Id, AccountId, Partner_User__c, EligibleTracks__c, Name, Partner_User_Partner_Admin__c, Decision_Making_Role__c, NPS_Qualified_Status__c, Primary_Contact_for_Service_Type__c, Partner_User_Active__c, Email, Status__c, Phone, Partner_User_Deal_Registration__c FROM Contact WHERE AccountId IN : setMasterId AND Partner_User__c !=null];
            if(!listContact.isempty()){
               for(contact con :listContact){
                   if(con.Partner_User__c != null){
                       setUserId.add(con.Partner_User__c);
                   }
               }
            }
            if(!setUserId.isempty()){
                listUser = [SELECT Id, Name ,Enable_As_Partner_Lead_Super_User__c,accountid FROM User where Id IN: setUserId AND Enable_As_Partner_Lead_Super_User__c = true AND isActive = true order by createdDate];
            }
            if(!listUser.isempty()){
                for(User usr : listUser){
                    mapSalesmotionToUser.put(usr.id,usr);
                }
            }
            for(String strIds :mapSmToMGroupId.keyset()){
                for(contact con: listcontact){
                    list<string> listEligibleTracksId = new List<String>();
                    if(String.isNotBlank(con.EligibleTracks__c)){
                        if(String.ValueOf(con.EligibleTracks__c).contains(';')){
                            listEligibleTracksId = con.EligibleTracks__c.split(';');
                        }else{
                            listEligibleTracksId.add(con.EligibleTracks__c);
                        }
                    }
                    if(!listEligibleTracksId.isempty()){
                        if(listEligibleTracksId.contains(mapSmToMGroupId.get(strIds).Partner_Track__c)){
                            if(mapSmToUser.containskey(strIds)){
                                if(mapSalesmotionToUser.containskey(con.Partner_User__c)){
                                    list<user> listTemp = mapSmToUser.get(strIds);
                                    listTemp.add(mapSalesmotionToUser.get(con.Partner_User__c));
                                    mapSmToUser.put(strIds,listTemp);
                                }
                            }else{
                                if(mapSalesmotionToUser.containskey(con.Partner_User__c)){
                                    list<user> listPartner = new list<user>();
                                    listPartner.add(mapSalesmotionToUser.get(con.Partner_User__c));
                                    mapSmToUser.put(strIds,listPartner);
                                }
                            }
                        }
                    }                   
                }
            }
        }
        return mapSmToUser;
    }
    
    public static Map<Id,List<Id>> getMapSalesmotionAccounts(list<Id> listUserId){
        Map<Id,List<Id>> mapUserIdToAccountIds = new Map<Id,List<Id>>();                              
        Map<String, List<Id>> mapPartnerTrackIdToListUser = new MAP<String,List<Id>>();
        
        if(!listUserId.isempty()){
            for(User u : [Select Id, ContactId, Contact.EligibleTracks__c from User where Id IN : listUserId] ){
                If(u.Contact.EligibleTracks__c != null){
                    for (id pt: u.Contact.EligibleTracks__c.split(';')){
                        if (!mapPartnerTrackIdToListUser.containsKey(pt)) {
                            mapPartnerTrackIdToListUser.put(pt, new List<Id> {u.Id});
                        }else{
                            mapPartnerTrackIdToListUser.get(pt).add(u.id);
                        }
                    } 
                } 
            }
        }
        
        
        if(!mapPartnerTrackIdToListUser.isempty()){
            for(Account ac : [Select Id,Partner_Track__c,recordtype.name from Account where Partner_Track__c IN :mapPartnerTrackIdToListUser.keyset() AND recordtype.name = 'Partner Account']){
                for(string strUId: mapPartnerTrackIdToListUser.get(ac.Partner_Track__c) ){
                    if (!mapUserIdToAccountIds.containsKey(strUId)){
                        mapUserIdToAccountIds.put(strUId, new List<Id> {ac.Id});
                    }else{
                        mapUserIdToAccountIds.get(strUId).add(ac.Id);
                    }
                }
            }
        }        
        return mapUserIdToAccountIds;
    }
}