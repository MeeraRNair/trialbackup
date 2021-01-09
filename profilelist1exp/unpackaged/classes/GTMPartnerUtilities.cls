//This class is for processing the assignemnt & removal of GTMPartner Accounts via API
//Hanan:-Code commented since functionality is moved to LOB Registration object.
/*
2.0     10-Jan-2011     Krishna         CR 6887(Emergency): Changed the Partner role selection from Partner Executive to Partner User
                                            -Changed the Group Type as Role from RoleAndSubordinates
                                            -Renamed variable name from partnerExecRoleIdSet to partnerUserRoleIdSet
                                            */
public class GTMPartnerUtilities{
    /*    
        
        public static void updateGTMPartnerAssignement(Map<Id,Account> AccountIdToAccountMap,Map<Id,Id> AccountIdToPartnerIDMap,            
            Map<Id, Id> AccountIdOldGroupMap,Set<Id> SetOfGTMExpiredAccoutId,Set<Id> gtmPartnerAccountIdSet){
                        
            if (AccountIdOldGroupMap.size()>0){                
                deleteOldShares(AccountIdToAccountMap,AccountIdOldGroupMap,SetOfGTMExpiredAccoutId);
                
            }            
            if (AccountIdToPartnerIDMap.size()>0){
               addNewShares(AccountIdToAccountMap,AccountIdToPartnerIDMap,gtmPartnerAccountIdSet);        
            } 
        
        } 
           
           //Method for removing the Accountshare if the partner assignment for Enduser Account is removed.   
            public static void deleteOldShares(Map<Id,Account> AccountIdToAccountMap,Map<Id, Id> AccountIdOldGroupMap,Set<Id> SetOfGTMExpiredAccoutId){
            List<AccountShare> AccntShareRecordList =new  List<AccountShare>();  
            Database.DeleteResult[] deleteResult ;
            String AccountGUID;
            Boolean expired=false;
            
            String WhereClause = QueryUtils.getWhereClauseFromInput(AccountIdOldGroupMap,'AccountId','UserOrGroupId'); 
            
                         
            AccntShareRecordList = Database.query ('Select id,UserOrGroupId, AccountId from Accountshare'+WhereClause);
            System.debug('###  AccntShareRecordList '+ AccntShareRecordList );
            
            if (AccntShareRecordList.size()>0){
                deleteResult  = Database.delete(AccntShareRecordList,false);  
                System.debug('### deleteResult in if '+deleteResult );
            }
            System.debug('### deleteResult '+deleteResult );
        
            for (integer i= 0; i<deleteResult .size(); i++) {
                AccountGUID  = AccntShareRecordList[i].AccountId;
                Account accountObject= AccountIdToAccountMap.get(AccountGUID);
                if(SetOfGTMExpiredAccoutId.size()>0){
                    if(SetOfGTMExpiredAccoutId.contains(AccountGUID)){
                        expired=true;
                    }
                    
                }
                if (deleteResult[i].IsSuccess()==true){                    
                    accountObject.GTM_partner_group__c=null;
                   
                    accountObject.Shared_to_GTM_Partner__c =false;
                   
                    System.debug('###  accountObject not expire'+ accountObject );

                    if(expired==true){
                        accountObject.GTM_De_linkage_Reason__c='GTM Assignment Auto-Expired'; 
                        accountObject.GTM_Linkage_Expiry_Date__c=null;   
                        accountObject.Preferred_GTM_Partner_Account__c=null;                                                                
                        System.debug('### accountObject expire '+accountObject );
                    }  //End of If            
                
                }//End of If
                else if(expired==true){
                    accountObject.Shared_to_GTM_Partner__c =true;
                }
            
            }//End of for Loop
                        
        }//End of delteOldShares method
        
            //Method for adding an AccountShare Record if a partner account is assigned to the EndUser Account
            public static void addNewShares(Map<Id,Account> AccountIdToAccountMap,Map<Id,Id> AccountIdToPartnerIDMap,Set<Id> gtmPartnerAccountIdSet){
            Set<Id> partnerUserRoleIdSet=new Set<Id>();
            Map<Id,Id> PortalAccountIdTOROleIdMap=new Map<Id,Id>();
            Map<Id,Id> PortalRoleIdTOGroupIdMap=new Map<Id,Id>();
           
            List<AccountShare> accountShareList=new List<AccountShare>();
            AccountShare accountShareElement=new AccountShare(); 
            String groupId;
            String roleId;
            Database.SaveResult[] insertResult;
        
            for(userrole role : [SELECT id, name, PortalAccountId from UserRole
                                 WHERE PortalAccountId IN :gtmPartnerAccountIdSet
                                 AND Name like '%Partner User']){
                PortalAccountIdTOROleIdMap.put(role.PortalAccountId,role.Id);
                partnerUserRoleIdSet.add(role.Id);
               
            }
             System.debug('###PortalAccountIdTOROleIdMap'+PortalAccountIdTOROleIdMap);
            if(partnerUserRoleIdSet.size()>0){
                for(Group GroupItem :[SELECT id,name,type,RelatedId from Group
                                  WHERE RelatedId IN :partnerUserRoleIdSet
                                  AND Type='Role']){
                    PortalRoleIdTOGroupIdMap.put(GroupItem.RelatedId,GroupItem.Id); 
                }

            }
            
                         System.debug('###PortalRoleIdTOGroupIdMap'+PortalRoleIdTOGroupIdMap);
             System.debug('###AccountIdToAccountMap'+AccountIdToAccountMap);
             System.debug('###AccountIdToAccountMap.keySet()'+AccountIdToAccountMap.keySet());
            if(PortalRoleIdTOGroupIdMap.size()>0){
                for(Id AccountIdItem : AccountIdToAccountMap.keySet()){
                    
                    roleId=PortalAccountIdTOROleIdMap.get(AccountIdToPartnerIDMap.get(AccountIdItem));
                    groupId= PortalRoleIdTOGroupIdMap.get(roleId); 
                    System.debug('###UserOrGroupId'+groupId);
                    accountShareElement=new AccountShare(UserOrGroupId=groupId,AccountId=AccountIdItem,AccountAccessLevel='Read',OpportunityAccessLevel='Read');  
                    accountShareList.add(accountShareElement);
                }
                System.debug('###accountShareList'+accountShareList);
                if (accountShareList.size()>0){
                    insertResult= Database.insert(accountShareList,false);
                }
                System.debug('###insertResult'+insertResult);
            
                for (integer i=0; i< accountShareList.size(); i++) {
                    if (insertResult[i].IsSuccess()==true){
                        System.debug('###group id'+accountShareList[i].UserOrGroupId);
                        Account accountObject= AccountIdToAccountMap.get(accountShareList[i].AccountId);
                        System.debug('###accountObject'+accountObject);
                        accountObject.GTM_partner_group__c=accountShareList[i].UserOrGroupId;
                         
                        accountObject.Shared_to_GTM_Partner__c =true;
                    }//End of If
                    
               } //End of for


            } // end of if
                       
                   
              
        }//End of addNewShares Method
        
   */
    
    }//End of Class