/*-----------------------------------------------------------------------------------------
Description: Class  for migrating sharing functionalities from Account to  LOB Registration 

History:
    
Author: Hanan/Manju
1.0                   Hanan/Manju  Created 
2.0    10-Jan-2011    Krishna      CR 6887(Emergency): Changed the Partner role selection from Partner Executive to Partner User
                      -Changed the Group Type as Role from RoleAndSubordinates
                      -Renamed variable name from partnerExecRoleIdSet to partnerUserRoleIdSet
3.0    03-Dec-2015    Devika       Update the expired LOB status from Open to Expired. 
------------------------------------------------------------------------------------------*/
public class LOBRegistrationUtilities {
        
    public static void updateLOBRegistrationAssignment(Map<Id,LOB_Registration__c> LOBRegIdToLOBRegMap,Map<Id,Id> PAIdEUAIdMap, 
                                                        Map<Id,Id> endUserAccountIdOldGroupMap,Set<Id> setOfGTMExpiredLOBRegId,               
                                                        Set<Id> gtmPartnerLOBRegIdSet){                                                            
        if (endUserAccountIdOldGroupMap.size()>0){                
            deleteOldShares(LOBRegIdToLOBRegMap,endUserAccountIdOldGroupMap,setOfGTMExpiredLOBRegId);
        }            
        if (gtmPartnerLOBRegIdSet.size()>0){
            addNewShares(LOBRegIdToLOBRegMap,PAIdEUAIdMap,gtmPartnerLOBRegIdSet);        
        } 
        
        System.debug('###LOBRegIdToLOBRegMap###'+LOBRegIdToLOBRegMap);
    } 

    //Method for removing the Accountshare if the partner assignment for Enduser Account is removed.   
    public static void deleteOldShares(Map<Id,LOB_Registration__c> LOBRegIdToLOBRegMap,Map<Id, Id> endUserAccountIdOldGroupMap,
                                            Set<Id> setOfGTMExpiredLOBRegId){
        
        LOB_Registration__c LOBRegObject=new LOB_Registration__c();
        List<LOB_Registration__c> LOBRegistrationList=new List<LOB_Registration__c>();
        LOBRegistrationList=LOBRegIdToLOBRegMap.values();
        
        for(LOB_Registration__c lobElt:LOBRegistrationList){
            LOBRegObject=lobElt;
            if(setOfGTMExpiredLOBRegId.contains(LOBRegObject.Preferred_GTM_Partner_Account__c)
                && endUserAccountIdOldGroupMap.get(lobElt.Registered_End_User__c)==LOBRegObject.GTM_partner_group__c){                
                LOBRegObject.Shared_to_GTM_Partner__c=false;
                LOBRegObject.GTM_De_linkage_Reason__c='GTM Assignment Auto-Expired'; 
                LOBRegObject.GTM_Linkage_Expiry_Date__c=null;   
                LOBRegObject.Preferred_GTM_Partner_Account__c=null;
                LOBRegObject.LOB_registration_status__c = 'Expired';//v3.0'Open'; 
            }
            
        }

    }//End of delteOldShares method

    //Method for adding an AccountShare Record if a partner account is assigned to the EndUser Account

    public static void addNewShares(Map<Id,LOB_Registration__c> LOBRegIdToLOBRegMap,
                                    Map<Id,Id> PAIdEUAIdMap,Set<Id> gtmPartnerLOBRegIdSet){

        Id endUserAccountId;
        Id partnerAccountId;
        Id lobGroupId;
        String groupId;
        String roleId;
        Database.SaveResult[] insertResult;
        AccountShare accountShareElement=new AccountShare();
        Set<Id> partnerUserRoleIdSet=new Set<Id>();  
        
        List<AccountShare> accountShareList=new List<AccountShare>();
        List<LOB_Registration__c> LOBRegistrationList=new List<LOB_Registration__c>();
        
        Map<Id,Id> PortalAccountIdTOROleIdMap=new Map<Id,Id>();
        Map<Id,Id> PortalRoleIdTOGroupIdMap=new Map<Id,Id>();        
        Map<Id,Id> lobIdAccShareGrpIdMap=new Map<Id,Id>();        
        Map<Id,Id> aShareEUAccIdGrpIdMap=new Map<Id,Id>();
        
        System.debug('###In add new shares###');

        
        LOBRegistrationList=LOBRegIdToLOBRegMap.values();
        
        System.debug('###In add new shares LOBRegistrationList###'+LOBRegistrationList);


        for(userrole role : [SELECT id, name, PortalAccountId from UserRole
                            WHERE PortalAccountId IN :gtmPartnerLOBRegIdSet
                            AND Name like '%Partner User']){
            PortalAccountIdTOROleIdMap.put(role.PortalAccountId,role.Id);
            partnerUserRoleIdSet.add(role.Id);

        }
        if(partnerUserRoleIdSet.size()>0){
            for(Group GroupItem :[SELECT id,name,type,RelatedId from Group
                                    WHERE RelatedId IN :partnerUserRoleIdSet
                                    AND Type='Role']){
                PortalRoleIdTOGroupIdMap.put(GroupItem.RelatedId,GroupItem.Id); 
            }
        }

    //System.debug('###PAIdEUAIdMap'+PAIdEUAIdMap.size());

        if(PortalRoleIdTOGroupIdMap.size()>0){
            for(LOB_Registration__c lobRegItem : LOBRegistrationList){                
                roleId=PortalAccountIdTOROleIdMap.get(lobRegItem.Preferred_GTM_Partner_Account__c);
                if(roleId!=null){
                    groupId= PortalRoleIdTOGroupIdMap.get(roleId);                
                    accountShareElement=new AccountShare(UserOrGroupId=groupId,
                    AccountId=lobRegItem.Registered_End_User__c,
                    AccountAccessLevel='Read',OpportunityAccessLevel='None');  
                    accountShareList.add(accountShareElement); 
                    //GroupIdPartnerAccountIdMap.put(groupId,lobRegItem.Preferred_GTM_Partner_Account__c); 
                    lobIdAccShareGrpIdMap.put(lobRegItem.Id,groupId); 
                }
                             
            }
            System.debug('###accountShareList'+accountShareList.size());
           // System.debug('###GroupIdPartnerAccountIdMap in class'+GroupIdPartnerAccountIdMap.size());
            
            if (accountShareList.size()>0){
                insertResult= Database.insert(accountShareList,false);
                for (integer i=0; i< accountShareList.size(); i++) {
                    if (insertResult[i].IsSuccess()==true){                        
                        aShareEUAccIdGrpIdMap.put(accountShareList[i].AccountId,accountShareList[i].UserOrGroupId);
                        System.debug('###insertResult partnerAccountId'+partnerAccountId);
                    }//End of If
                } //End of FOR   

                for(integer intLOB=0;intLOB<LOBRegistrationList.size();intLOB++){
                    LOB_Registration__c  lobObject=LOBRegistrationList[intLOB];
                    
                    lobGroupId=aShareEUAccIdGrpIdMap.get(lobObject.Registered_End_User__c);
                    
                    System.debug('### lobGroupId'+lobGroupId);                    
                    System.debug('### lobObject.Registered_End_User__c'+lobObject.Registered_End_User__c);
                    
                    if(lobGroupId!=null && lobIdAccShareGrpIdMap.get(lobObject.id)==lobGroupId){                    
                        lobObject.GTM_partner_group__c=lobIdAccShareGrpIdMap.get(lobObject.id);                     
                        lobObject.Shared_to_GTM_Partner__c=true;
                    }
                } 
            }
        } // end of if
        
        
    }//End of addNewShares Method
    
     //Method to check for duplicate Partner Account assignment for similar LOBName
    public static void addErrorMethod(Set<String> lobNameSet,Set<Id> prefGtmPartnSet,Set<Id> endUserSet,Map<Id,LOB_Registration__c> lobMapTgr){
        String currentEndUserAccount;
        LOB_Registration__c lobRegObj=new LOB_Registration__c();         
        List<LOB_Registration__c> lobObjlist=new List<LOB_Registration__c>();       
        Map<Id,String> gtmPartnerIdLobName;     
        Map<Id,Map<Id,String>> endUserAccntPartnerLobNameMap=new Map<Id,Map<Id,String>>();
        
        lobObjlist=lobMapTgr.values();
        System.debug('###lobMapTgr'+lobMapTgr);
    //    CRQ0241 reminder : uncomment after type change                    
        for(LOB_Registration__c lobregistrationObj:[SELECT id, LOB_Name__c, Preferred_GTM_Partner_Account__c, Registered_End_User__c 
                                                    FROM LOB_Registration__c
                                                    WHERE LOB_Name__c in:lobNameSet and
                                                    Preferred_GTM_Partner_Account__c in: prefGtmPartnSet and
                                                    Registered_End_User__c in: endUserSet order by Registered_End_User__c]){                                                    
            System.debug('###lobregistrationObj'+lobregistrationObj);
            lobRegObj=lobMapTgr.get(lobregistrationObj.id);
            if(lobregistrationObj!=null && lobRegObj==null){
                                                 
                if(currentEndUserAccount==null){
                    currentEndUserAccount=lobregistrationObj.Registered_End_User__c;
                }
                if(currentEndUserAccount==lobregistrationObj.Registered_End_User__c){
                    gtmPartnerIdLobName=new Map<Id,String>();
                    //    CRQ0241 reminder : uncomment after type change
                    gtmPartnerIdLobName.put(lobregistrationObj.Preferred_GTM_Partner_Account__c,lobregistrationObj.LOB_Name__c);
                }
                if(currentEndUserAccount!=lobregistrationObj.Registered_End_User__c){
                    currentEndUserAccount=lobregistrationObj.Registered_End_User__c;
                    System.debug('###currentEndUserAccount'+currentEndUserAccount);
                    System.debug('###gtmPartnerIdLobName'+gtmPartnerIdLobName);
                    endUserAccntPartnerLobNameMap.put(currentEndUserAccount,gtmPartnerIdLobName);
                    gtmPartnerIdLobName=new Map<Id,String>();
                    //    CRQ0241 reminder : uncomment after type change
                    gtmPartnerIdLobName.put(lobregistrationObj.Preferred_GTM_Partner_Account__c,lobregistrationObj.LOB_Name__c);
                }  
            }
        }
        
        if(currentEndUserAccount!=null && gtmPartnerIdLobName.size()>0){
            endUserAccntPartnerLobNameMap.put(currentEndUserAccount,gtmPartnerIdLobName);
        }
        System.debug('###endUserAccntPartnerLobNameMap'+endUserAccntPartnerLobNameMap);
        if(endUserAccntPartnerLobNameMap.size()>0){
            Map<Id,String> tempMap=new Map<Id,String>();
            for(Integer i=0; i<lobObjlist.size(); i++){
                tempMap=endUserAccntPartnerLobNameMap.get(lobObjlist[i].Registered_End_User__c);
                System.debug('###tempMap'+tempMap);
                if(tempMap.size()>0){
                //    CRQ0241 reminder : uncomment after type change    
                    if(tempMap.get(lobObjlist[i].Preferred_GTM_Partner_Account__c)==lobObjlist[i].LOB_Name__c){
                         lobObjlist[i].Preferred_GTM_Partner_Account__c.addError('Partner has already been assigned. Please choose another');
                    }    
                }
            }
        }
    }
    
    
    //Method which checks for duplicate LOB Name(s)
    public static void preventDuplicateLOB(List<LOB_Registration__c> lobObj){
        String lobName;
        Set<Id> endUserIdSet = new Set<Id>();
        Set<Id> locationIdSet = new Set<Id>();
        Set<String> lobNameSet = new Set<String>();
        Map<String,LOB_Registration__c> lobMap = new Map<String,LOB_Registration__c>(); 
        
        for (LOB_Registration__c lobElt: lobObj) {
            lobName = String.valueOf(lobElt.Registered_End_User__c) + ':' +  
                      String.valueOf(lobElt.Location__c) + ':'+    //CRQ0241 reminder : uncomment after type change                
                      String.valueOf(lobElt.LOB_Name__c);
            if(lobMap.containsKey(lobName)){
                lobElt.addError('Duplicate LOB Name is available in the same batch.');
            }else{
                lobMap.put(lobName,lobElt);
                endUserIdSet.add(lobElt.Registered_End_User__c);
                locationIdSet.add(lobElt.Location__c);
            //    CRQ0241 reminder : uncomment after type change    
                lobNameSet.add(lobElt.LOB_Name__c);
            }
        }
        if(endUserIdSet.size() > 0 && locationIdSet.size() > 0 && lobNameSet.size() > 0){
            //    CRQ0241 reminder : uncomment after type change
            for (LOB_Registration__c lobRec: [SELECT Id, LOB_Name__c, Registered_End_User__c, Location__c
                                              FROM LOB_Registration__c 
                                              WHERE Registered_End_User__c IN :endUserIdSet and
                                              Location__c IN :locationIdSet and LOB_Name__c IN :lobNameSet]) {
                lobName = String.valueOf(lobRec.Registered_End_User__c) + ':' +  
                          String.valueOf(lobRec.Location__c) + ':' +    //    CRQ0241 reminder : uncomment after type change
                          String.valueOf(lobRec.LOB_Name__c);//    CRQ0241 reminder : uncomment after type change
                LOB_Registration__c newLob = lobMap.get(lobName);  
                if(newLob != null){
                    newLob.addError('This LOB Name is already available in the database. No duplicates allowed.');
                }              
            }
        }
    }
    
}//End of Class