/*
* Author   : Prasanthi M
* Purpose  : Partner_Track_Relationship handler which populates SalesMotion Account and Partner Track records with associated 
*            Master Group Id , Partner Track Id and Track name.
* Date     : 14-Dec-2018
*
*/
Public class PTRHandler {
    //When PTR Record was inserted , assocaited SalesMotion Account and PartnerTrack record related MasterGroup Id , Partner Track Id and Track name fields should be populated 
    Public void insertPTR(List<Partner_Track_Relationship__c> listptrList){
        List<Partner_Track_Relationship__c> listptrList2=new  List<Partner_Track_Relationship__c>();
        listptrList2.addall(listptrList);
        PTRUtility nu=new PTRUtility();
        nu.InsertPTR(listptrList2,'fromtrigger');
        /*
Public void insertPTR(List<Partner_Track_Relationship__c> listptrList){
List<String> listpartnerAffintyIds =new List<String>();
List<String> listmasterAffinityIds =new List<String>();
List<String> listsalesMotionAffinityIds  =new List<String>();
system.debug('total list : '+listptrList); 
try{
//Fetch all the Partner_Track_AffinityId__c ,Master_Group_AffinityId__c,Sales_Motion_Account_AffinityId__c from newly inserted PTR records
for(Partner_Track_Relationship__c ptr : listptrList){
if(ptr.Partner_Track_AffinityId__c!=null){
listpartnerAffintyIds.add(ptr.Partner_Track_AffinityId__c);
}
if(ptr.Master_Group_AffinityId__c!=null){
listmasterAffinityIds.add(ptr.Master_Group_AffinityId__c);
}
if(ptr.Sales_Motion_Account_AffinityId__c!=null){
listsalesMotionAffinityIds.add(ptr.Sales_Motion_Account_AffinityId__c);
}
}
//Fetch the records based on Affinity IDs in PTR records
//Varsha: #6409524 Added Name in the query
List<Account> listmasterAccounts=[select id,Master_Group_Affinity_ID__c,Name from Account where Master_Group_Affinity_ID__c IN : listmasterAffinityIds 
AND Ispartner = true];
List<Account> listsalesMotionAccounts=[select id,partner_track__c ,Account_ID__c,Master_Group_Id__c from Account where Account_ID__c IN : listsalesMotionAffinityIds
AND Ispartner = true AND Recordtype.name = 'Partner Account'];

List<Partner_Track__c> listpartnerTracks = [select id,Partner_Track_AffinityId__c,Primary_SMAffinity_Account__c,Primary_Sales_Motion_Affinity_ID__c,Master_Group_Id__c,Track_Id__c,Track_Id__r.name from Partner_Track__c where Partner_Track_AffinityId__c IN : listpartnerAffintyIds];

//Flag is enabled when realation is going to establish
for(Partner_Track_Relationship__c ptr : listptrList){
Boolean bacProcessed=false;
Boolean bsacProcessed=false;
Boolean bptProcessed=false;
if(ptr.Master_Group_AffinityId__c!=null){
for(Account ac:listmasterAccounts){ //Master Group Accounts
if(ptr.Master_Group_AffinityId__c == ac.Master_Group_Affinity_ID__c){
bacProcessed=true;
}
}
}
if(ptr.Sales_Motion_Account_AffinityId__c!=null){
for(Account ac:listsalesMotionAccounts){ //Salesmotion Accounts
if(ptr.Sales_Motion_Account_AffinityId__c == ac.Account_ID__c){
bsacProcessed=true;
}
}
}
if(ptr.Partner_Track_AffinityId__c!=null){
for(Partner_Track__c pt:listpartnerTracks){ //Partner Tracks
if(ptr.Partner_Track_AffinityId__c == pt.Partner_Track_AffinityId__c){
bptProcessed=true;
}
}
}
system.debug('===Key=>>>'+ptr.Key__c);
system.debug('===ptProcessed=>>>'+bptProcessed);
system.debug('===sacProcessed=>>>'+bsacProcessed);
system.debug('===acProcessed=>>>'+bacProcessed);

if(bptProcessed && bsacProcessed && bacProcessed){
ptr.Is_Processed__c=true;
}
}
system.debug('listptrList : '+listptrList);
//Flag Relations End
system.debug('###masteraccounts'+listmasterAccounts);
system.debug('###SM_accounts'+listsalesMotionAccounts);
system.debug('###partnerTracks'+listpartnerTracks);
Map<String,Partner_Track__c> mappartnerTrackMap =new Map<String,Partner_Track__c>();
Map<String,Account> mapsalesMotionMap=new Map<String,Account>();
Map<String,Id> mapPrimarySMAccount =new Map<String,Id>();
Map<String,Id> mapmasterGroupMap =new Map<String,Id>();
Map<String, String> mapPTAffinityTOSMAffinity = new Map<String, String>();
List<String> listPrimarySMAffinityID = new List<String>();
if(listpartnerTracks.size()>0){
for(Partner_Track__c p: listpartnerTracks){
mappartnerTrackMap.put(p.Partner_Track_AffinityId__c,p);
mapPTAffinityTOSMAffinity.put(p.Partner_Track_AffinityId__c,p.Primary_Sales_Motion_Affinity_ID__c);
if(String.isNotBlank(p.Primary_Sales_Motion_Affinity_ID__c))
{
listPrimarySMAffinityID.add(p.Primary_Sales_Motion_Affinity_ID__c);
}
}
}
List<account> listPrimarySMA = [select id,partner_track__c,Account_ID__c,Master_Group_Id__c from Account where Account_ID__c IN : listPrimarySMAffinityID
AND Ispartner = true AND Recordtype.name = 'Partner Account'];
if(listPrimarySMA.size()>0)
{
for (Account primarySM:listPrimarySMA )
{
mapPrimarySMAccount.put(primarySM.Account_ID__c,primarySM.Id);
}
}
if(listsalesMotionAccounts.size()>0){
for(Account a: listsalesMotionAccounts){
mapsalesMotionMap.put(a.account_id__c,a);
}
}
Map<String,String> mapMasterGroupName = new Map<String,String>();
if(listmasterAccounts.size()>0){
for(Account m:listmasterAccounts){
mapmasterGroupMap.put(m.Master_Group_Affinity_ID__c,m.Id);
mapMasterGroupName.put(m.Master_Group_Affinity_ID__c,m.Name);//Added by Varsha: #6409524
} 
}
system.debug('==mapmasterGroupMap==>>'+mapmasterGroupMap);
system.debug('==mapsalesMotionMap==>>'+mapsalesMotionMap);
//Creating Account and Partner Track list for updation with associated values like MasterGroup Id, Partner Track id and Track name
List<Account> listaccounts =new List<Account>();
List<Partner_Track__c> listpartnerTracksList = new List<Partner_Track__c>();
map<id,account> mapaccMap = new map<id,account>(); // To By pass Duplicate ids Exception
map<id,Partner_Track__c> mapptMap = new map<id,Partner_Track__c>(); // To By pass Duplicate ids Exception
for(Partner_Track_Relationship__c pt :listptrList){
system.debug('PTR Looping : '+pt);
Account acc;
Partner_Track__c ptObj;
if(mapsalesMotionMap.size()>0 && mapsalesMotionMap.get(pt.Sales_Motion_Account_AffinityId__c) !=null){
acc= mapsalesMotionMap.get(pt.Sales_Motion_Account_AffinityId__c); 
system.debug('###step1 acc'+acc);
}
if(mappartnerTrackMap.size()>0 && pt.Partner_Track_AffinityId__c!=null){
ptObj = mappartnerTrackMap.get(pt.Partner_Track_AffinityId__c);
system.debug('###step1 pt'+ptObj);
}
//SalesMotion Account and Partner Track record fields population
if(mapmasterGroupMap.size()>0 && mapmasterGroupMap.get(pt.Master_Group_AffinityId__c) !=null){
if(acc!=null){
acc.Master_Group_Id__c = mapmasterGroupMap.get(pt.Master_Group_AffinityId__c);
system.debug('###step2 acc'+acc);
acc.Master_Group_Name__c = mapMasterGroupName.get(pt.Master_Group_AffinityId__c);
}
if(ptObj!=null){
ptObj.Master_Group_Id__c= mapmasterGroupMap.get(pt.Master_Group_AffinityId__c);                                  
ptObj.Primary_SMAffinity_Account__c =mapPrimarySMAccount.get( mapPTAffinityTOSMAffinity.get(pt.Partner_Track_AffinityId__c));
listpartnerTracksList.add(ptObj);
system.debug('###Adding PT to list'+ptObj);
}
}
if(mappartnerTrackMap.size()>0 && mappartnerTrackMap.get(pt.Partner_Track_AffinityId__c) != Null && acc!=null){
acc.partner_track__c =mappartnerTrackMap.get(pt.Partner_Track_AffinityId__c).id;
acc.Track_Name__c = mappartnerTrackMap.get(pt.Partner_Track_AffinityId__c).Track_Id__r.name;
//Varsha: #6409524 Added this mapping
acc.Master_Group_Name__c = mapMasterGroupName.get(pt.Master_Group_AffinityId__c);
system.debug('###step3 acc'+acc);
}
if(acc!=null){
listaccounts.add(acc); 
system.debug('###Adding Account to list'+acc);
}
}
system.debug('###Account list'+listaccounts);
system.debug('###PT list'+listpartnerTracksList);
if(listaccounts.size()>0){
mapaccMap.putall(listaccounts);
TriggerExecutionController.setSkipAccountTriggers(True);
Database.SaveResult[] listsrAccList = Database.update(mapaccMap.values(),false);
system.debug('###SM Accts List were Updated');
WebServiceExceptionHandling.exceptionHandlingMethod(listsrAccList,'Account','PTR Insert','Exception',null,mapaccMap.values());
}
if(listpartnerTracksList.size()>0){
mapptMap.putall(listpartnerTracksList);
Database.SaveResult[] listsrPtList = Database.update(mapptMap.values(),false); 
system.debug('###PT List were Updated'+mapptMap);
WebServiceExceptionHandling.exceptionHandlingMethod(listsrPtList,'Partner Track','PTR Insert','Exception',mapptMap.values(),null);
}
}catch(exception e){
system.debug('Exception occured in PTRHandler insertPTR method'+e.getMessage());
}
}
*/    
        
    }
    //When any of the PTR record's affinity ids are updated then Sales Motion Account and Partner Record fields should be updated wit associated values
    Public void updatePTR(Map<Id,Partner_Track_Relationship__c> mapoldMap,Map<Id,Partner_Track_Relationship__c> mapnewMap){
        Set<Id> setptrIds=mapoldMap.keySet();
        List<String> listmodifiedMGList=new List<String>();
        List<String> listmodifiedPTList=new List<String>();
        Set<String> setsalesMotionList =new Set<String>();
        try{
            for(Id key :setptrIds){
                // Fetch the old version and new version of Partner_Track_Relationship__c 
                Partner_Track_Relationship__c oldPtr =mapoldMap.get(key);
                Partner_Track_Relationship__c newPtr=mapnewMap.get(key);
                system.debug('Old PTR'+oldPtr);
                system.debug('New PTR'+newPtr);
                //Based on the modified affinity ids or names fetch those in associated list
                if(oldPtr.Master_Group_AffinityId__c != newPtr.Master_Group_AffinityId__c ||
                   oldPtr.Partner_Track_AffinityId__c !=newPtr.Partner_Track_AffinityId__c ||
                   oldPtr.Sales_Motion_Account_AffinityId__c !=newPtr.Sales_Motion_Account_AffinityId__c){
                       if(newPtr.Master_Group_AffinityId__c!=null){
                           listmodifiedMGList.add(newPtr.Master_Group_AffinityId__c);
                       }
                       if(newPtr.Sales_Motion_Account_AffinityId__c!=null){
                           setsalesMotionList.add(newPtr.Sales_Motion_Account_AffinityId__c);
                       }
                       if(newPtr.Partner_Track_AffinityId__c!=null){
                           listmodifiedPTList.add(newPtr.Partner_Track_AffinityId__c);
                       }
                   }
            }
            //Based on the modified affinity Ids or names fetch the reocrds 
            List<Account> listmasterList =[select Id,Master_Group_Affinity_Id__c,Name from Account where Master_Group_Affinity_Id__c in :listmodifiedMGList
                                           And Ispartner = true];
            List<Partner_Track__C> listpartnerList=[select Id,Partner_Track_AffinityId__c from Partner_Track__C where Partner_Track_AffinityId__c  in : listmodifiedPTList];
            List<Account> listsalesMotionAccounts =[select Account_Id__c,Master_Group_Id__c,Partner_Track__c from Account where Account_Id__c in :setsalesMotionList
                                                    And Ispartner = true AND Partner_Registration__c != null AND Recordtype.name = 'Partner Account'];
            system.debug('###MasterList'+listmasterList);
            system.debug('###Partner List'+listpartnerList);
            system.debug('###SalesMotion Accounts'+listsalesMotionAccounts);
            //Created Maps with affinity Ids or Track names as keys and associated Account/Partner's records/record ids as values
            Map<String,Id> mapmasterMap =new Map<String,Id>();
            Map<String,String> mapMasterGroupName = new Map<String,String>();
            if(listmasterList.size()>0){
                for(Account a: listmasterList){
                    mapmasterMap.put(a.Master_Group_Affinity_Id__c,a.Id);
                    mapMasterGroupName.put(a.Master_Group_Affinity_ID__c,a.Name);
                }
            }
            Map<String,Partner_Track__c> mappartnerMap =new Map<String,Partner_Track__c>();
            if(listpartnerList.size()>0){
                for(Partner_Track__C p: listpartnerList){
                    mappartnerMap.put(p.Partner_Track_AffinityId__c ,p);
                }
            }
            Map<string,Account> mapsalesAccountMap =new Map<String,Account>();
            if(listsalesMotionAccounts.size()>0){
                for(Account a : listsalesMotionAccounts){
                    mapsalesAccountMap.put(a.Account_Id__C,a);
                }
            }
            List<Account > listaccounts =new List<Account>();
            List<Partner_Track__c> listpartnerTrackList = new List<Partner_Track__c>();
            for(Id key :setptrIds){
                Partner_Track_Relationship__c oldPtr =mapoldMap.get(key);
                Partner_Track_Relationship__c newPtr=mapnewMap.get(key);
                if(oldPtr.Master_Group_AffinityId__c !=newPtr.Master_Group_AffinityId__c ||
                   oldPtr.Partner_Track_AffinityId__c !=newPtr.Partner_Track_AffinityId__c ||
                   oldPtr.Sales_Motion_Account_AffinityId__c !=newPtr.Sales_Motion_Account_AffinityId__c){
                       Account acc;
                       Partner_Track__c pt;
                       if(mapsalesAccountMap.size()>0 && newPtr.Sales_Motion_Account_AffinityId__c!=null){
                           acc=mapsalesAccountMap.get(newPtr.Sales_Motion_Account_AffinityId__c);
                           system.debug('###Step1 Acc'+acc);
                       }
                       if(mappartnerMap.size()>0 && newPtr.Partner_Track_AffinityId__c!=null){
                           pt = mappartnerMap.get(newPtr.Partner_Track_AffinityId__c);
                           system.debug('###Step1 pt'+pt);
                       }
                       if(oldPtr.Sales_Motion_Account_AffinityId__c!=newPtr.Sales_Motion_Account_AffinityId__c && acc!=null){
                           if(mappartnerMap.size()>0 && newPtr.Partner_Track_AffinityId__c!=null){
                               acc.Partner_Track__c=mappartnerMap.get(newPtr.Partner_Track_AffinityId__c).id;
                               system.debug('###Step11 Acc'+acc);
                           }
                           if(mapMasterGroupName.size()>0 && mapmasterMap.size()>0 && newPtr.Master_Group_AffinityId__c!=null){
                               acc.Master_Group_Id__c=mapmasterMap.get(newPtr.Master_Group_AffinityId__c);
                               acc.Master_Group_Name__c = mapMasterGroupName.get(newPtr.Master_Group_AffinityId__c);
                               system.debug('###Step111 Acc'+acc);
                           }
                       }
                       if(oldPtr.Partner_Track_AffinityId__c!=newPtr.Partner_Track_AffinityId__c){
                           if(acc!=null && mappartnerMap.size()>0 && newPtr.Partner_Track_AffinityId__c!=null){
                               acc.Partner_Track__c=mappartnerMap.get(newPtr.Partner_Track_AffinityId__c).id;
                           }
                           if(pt!=null && mapmasterMap.size()>0 && oldPtr.Master_Group_AffinityId__c!=null){
                               pt.Master_Group_Id__c = mapmasterMap.get(newPtr.Master_Group_AffinityId__c);
                               system.debug('###Step2 PT'+pt);
                           }
                       }
                       if(oldPtr.Master_Group_AffinityId__c !=newPtr.Master_Group_AffinityId__c && mapmasterMap.size()>0 && mapMasterGroupName.size()>0 && newPtr.Master_Group_AffinityId__c!=null)   {
                           if(acc!=null){
                               acc.Master_Group_Id__c= mapmasterMap.get(newPtr.Master_Group_AffinityId__c);
                               acc.Master_Group_Name__c = mapMasterGroupName.get(newPtr.Master_Group_AffinityId__c);
                               system.debug('###Step3 Acc'+acc);
                           }
                           if(pt!=null){
                               pt.Master_Group_Id__c = mapmasterMap.get(newPtr.Master_Group_AffinityId__c);
                               system.debug('###Step3 PT'+pt);
                           }
                       }
                       if(acc!=null){
                           listaccounts.add(acc);
                           system.debug('###Accounts List'+listaccounts);
                       } 
                       if(pt!=null){
                           listpartnerTrackList.add(pt);
                           system.debug('###PT List'+listpartnerTrackList);
                       }
                   }
            }
            if(listaccounts.size()>0){
                TriggerExecutionController.setSkipAccountTriggers(True);
                Database.update(listaccounts,false);
                system.debug('###Accounts List were Updated');
            }
            if(listpartnerTrackList.size()>0){
                Database.update(listpartnerTrackList,false);
                system.debug('###PartnerTrack List were Updated');
            }
        }catch(Exception e){
            system.debug('Exception occured in PTRHandler updatePTR method'+e.getMessage());
        }
    }
    
    //=========================================== Primary SMAffinity Account Update on Partner Track ==================================================================================================
    
    /* A new SM is onboarded for a existing MG and PT */
    public void onBoardNewSM(Map<Id,Partner_Track_Relationship__c> mapNewPTR){
        System.debug('**onBoardNewSM**');
        List<Partner_Track_Relationship__c> listPTRRecords = new List<Partner_Track_Relationship__c>();
        // To hold the new Affinity Id related to SM
        List<String> listSMAffinityIds = new List<String>();
        List<String> listMGAffinityIds = new List<String>();
        List<String> listPTAffinityIds = new List<String>();
        List<String> listSMAffIds = new List<String>();
        List<String> listMGAffIds = new List<String>();
        List<String> listPTAffIds = new List<String>();
        for(Partner_Track_Relationship__c newPTR : mapNewPTR.values()){
            listSMAffinityIds.add(newPTR.Sales_Motion_Account_AffinityId__c);
            listMGAffinityIds.add(newPTR.Master_Group_AffinityId__c);
            listPTAffinityIds.add(newPTR.Partner_Track_AffinityId__c);
        }
        
        listPTRRecords =[SELECT Id,Sales_Motion_Account_AffinityId__c,Is_Processed__c,
                         Master_Group_AffinityId__c,Partner_Track_AffinityId__c 
                         FROM Partner_Track_Relationship__c
                         WHERE Master_Group_AffinityId__c IN: listMGAffinityIds
                         AND Partner_Track_AffinityId__c IN: listPTAffinityIds
                         AND Sales_Motion_Account_AffinityId__c NOT IN:listSMAffinityIds
                        ];
        
        for(Partner_Track_Relationship__c newPTR : listPTRRecords){
            if(newPTR.Is_Processed__c == true){
                listSMAffIds.add(newPTR.Sales_Motion_Account_AffinityId__c);
                listMGAffIds.add(newPTR.Master_Group_AffinityId__c);
                listPTAffIds.add(newPTR.Partner_Track_AffinityId__c);
            }
        }
        
        if(listMGAffIds.size()> 0 && listSMAffIds.size() > 0 && listPTAffIds.size() > 0){
            System.debug('invoke grantAccessToSM');
            PTRHandler.grantRevokeAccessToSM(listSMAffIds,listMGAffIds,listPTAffIds,System.Label.Grant_Access_Type);
            
        }
    }
    
    //=========================== Update the SM access whenever PT SM Changes =================================
    /*
* 1. SM Can be updated for a given MG and PT
* 2. PT can be updated for a given MG and SM
* 3. MG Can be updated for a given PT and SM
*/    
    public void updateAccessUponSMChange(Map<Id,Partner_Track_Relationship__c> mapNewPTR,Map<Id,Partner_Track_Relationship__c> mapOldPTR){
        
        // To hold the new Affinity Id related to SM
        List<String> listSMAffinityIds = new List<String>();
        List<String> listMGAffinityIds = new List<String>();
        List<String> listPTAffinityIds = new List<String>();
        
        // To hold the new Affinity Id related to SM
        List<String> listRSMAffinityIds = new List<String>();
        List<String> listRMGAffinityIds = new List<String>();
        List<String> listRPTAffinityIds = new List<String>();
        
        String strAccessType = '';
        
        List<Partner_Track_Relationship__c> listPTRRecords = new List<Partner_Track_Relationship__c>();
        // To hold the list of Contact
        List<Contact> listCon = new List<Contact>();
        for(Partner_Track_Relationship__c newPTR : mapNewPTR.values()){
            //Check if the SM is getting updated to new Parents
            //Old PTR: MG1-PT1-SM2
            //New PTR: MG2-PT2-SM2
            if( mapNewPTR.get(newPTR.Id).Is_Processed__c == true && 
               (mapNewPTR.get(newPTR.Id).Is_Processed__c != mapOldPTR.get(newPTR.Id).Is_Processed__c)|| 
               (mapNewPTR.get(newPTR.Id).Sales_Motion_Account_AffinityId__c!= mapOldPTR.get(newPTR.Id).Sales_Motion_Account_AffinityId__c)
               || (mapNewPTR.get(newPTR.Id).Master_Group_AffinityId__c!= mapOldPTR.get(newPTR.Id).Master_Group_AffinityId__c)
               || (mapNewPTR.get(newPTR.Id).Partner_Track_AffinityId__c!= mapOldPTR.get(newPTR.Id).Partner_Track_AffinityId__c)
              ){
                  listSMAffinityIds.add(newPTR.Sales_Motion_Account_AffinityId__c);
                  listMGAffinityIds.add(newPTR.Master_Group_AffinityId__c);
                  listPTAffinityIds.add(newPTR.Partner_Track_AffinityId__c);
                  
              }
            // SM getting assigned to another PT
            if((mapNewPTR.get(newPTR.Id).Sales_Motion_Account_AffinityId__c == mapOldPTR.get(newPTR.Id).Sales_Motion_Account_AffinityId__c)
               && (mapNewPTR.get(newPTR.Id).Partner_Track_AffinityId__c!= mapOldPTR.get(newPTR.Id).Partner_Track_AffinityId__c)){
                   listRSMAffinityIds.add(newPTR.Sales_Motion_Account_AffinityId__c);
                   listRMGAffinityIds.add(newPTR.Master_Group_AffinityId__c);
                   listRPTAffinityIds.add(newPTR.Partner_Track_AffinityId__c);
               }
        }
        
        if(listMGAffinityIds.size() > 0 && listPTAffinityIds.size() > 0 && listSMAffinityIds.size() > 0){
            System.debug('invoke grantAccessToSM');
            strAccessType = System.Label.Grant_Access_Type;
            PTRHandler.grantRevokeAccessToSM(listSMAffinityIds,listMGAffinityIds,listPTAffinityIds,strAccessType);
        }
        
        if(listRSMAffinityIds.size() > 0 && listRMGAffinityIds.size() > 0 && listRPTAffinityIds.size() > 0){
            strAccessType = System.Label.Revoke_Access_Type;
            PTRHandler.grantRevokeAccessToSM(listRSMAffinityIds,listRMGAffinityIds,listRPTAffinityIds,strAccessType);
        }
    }    
    
    /* Grant Access to New/ Updated SM Accounts*/
    
    public static void grantRevokeAccessToSM(List<String> listSMAffinityIds,List<String> listMGAffinityIds, List<String> listPTAffinityIds, String strAccessType){
        System.debug('in grantAccessToSM'+strAccessType);
        List<Partner_Track_Relationship__c> listPTRRecords = new List<Partner_Track_Relationship__c>();
        // To hold MG and Contacts
        Map<String, List<Contact>> mapMGToCon = new Map<String, List<Contact>>();
        //To hold the existing Account Share records
        List<AccountShare> listAccShareExists = new List<AccountShare>();
        // To hold the Account Share to insert
        List<AccountShare> listAccShareInsert = new List<AccountShare>();
        // To hold the Account Share to delete
        List<AccountShare> listAccShareDel = new List<AccountShare>();
        // To hold Contacts
        List<Contact> listCon = new List<Contact>();
        //To hold the related Partner Track  
        List<Partner_Track__c> listPTs = new List<Partner_Track__c>();
        // To hold the PT Ids
        List<String> listPTIds = new List<String>();
        //To hold the Accounts related to the PT's
        List<Account> listAcc = new List<Account>();
        // To hold the MG Vs SM
        Map<String,List<String>> mapMGToSM = new Map<String,List<String>>();
        
        if(listMGAffinityIds.size() > 0){
            listCon = [SELECT EligibleTracks__c, AccountID,Account.Master_Group_Affinity_ID__c,Partner_User__c
                       FROM Contact 
                       WHERE Account.Master_Group_Affinity_ID__c IN: listMGAffinityIds];
        }
        
        System.debug('listCon'+listCon);
        if(listCon.size() > 0){
            // Query PT's only if Contact exists for a MG
            listPTs = [SELECT ID,Partner_Track_AffinityId__c 
                       FROM Partner_Track__c 
                       WHERE Partner_Track_AffinityId__c IN :listPTAffinityIds];
            if(listPTs.size() > 0){
                for(Partner_Track__c ptrRecord : listPTs){
                    listPTIds.add(ptrRecord.Id);
                }
                
            }
            System.debug('listPTIds'+listPTIds);
            for(Contact con : listCon){
                //check if Contact eligible tracks is empty or not
                if(String.isNotBlank(con.EligibleTracks__c)){
                    /*List<String> listEligibleTracks = new List<String>();
if(con.EligibleTracks__c.contains(';')){
listEligibleTracks = con.EligibleTracks__c.trim().split(';');
}
else{
listEligibleTracks.add(con.EligibleTracks__c); 
}*/
                    for(String strRecordPTIds : listPTIds){
                        // If the PT already exists in the contact
                        if(con.EligibleTracks__c.contains(strRecordPTIds)){
                            System.debug('ET>>');
                            if(mapMGToCon.containsKey(con.AccountId)){
                                mapMGToCon.get(con.AccountId).add(con);
                            }
                            else{
                                mapMGToCon.put(con.AccountId, new List<Contact>{con});
                            }
                        }
                    }
                }
            }
        }
        
        if(listPTIds.size() > 0){
            listAcc = [SELECT Id,Master_Group_Id__c,Account_ID__c,Master_Group_Affinity_ID__c,Partner_Track__c 
                       FROM Account 
                       WHERE Partner_Track__c IN: listPTIds
                       AND Account_ID__c IN: listSMAffinityIds // Additional Check
                      ];
        }
        if(listAcc.size() > 0){
            for(Account acc : listAcc){
                if(mapMGToSM.containsKey(acc.Master_Group_Id__c)){
                    mapMGToSM.get(acc.Master_Group_Id__c).add(acc.Id); 
                }else{
                    mapMGToSM.put(acc.Master_Group_Id__c, new List<String>{acc.Id}); 
                }
            }
            
        }
        if(listSMAffinityIds.size() > 0){
            listAccShareExists = [SELECT Id,AccountId,Account.Account_Id__c,UserOrGroupId
                                  FROM AccountShare
                                  WHERE RowCause=:'Manual' 
                                  AND Account.Account_Id__c IN: listSMAffinityIds];   
            
        }
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
        
        System.debug('listAccShareExists'+listAccShareExists.size());
        System.debug('mapMGToSM.size()'+mapMGToSM.size()+'mapMGToCon'+mapMGToCon.size());
        // To- Do - Check not required as map is build
        if(mapMGToSM.size() > 0 && mapMGToCon.size() > 0){
            for(Account accRecord : listAcc){
                if(mapMGToCon.containsKey(accRecord.Master_Group_Id__c)){
                    for(Contact con :mapMGToCon.get(accRecord.Master_Group_Id__c)){
                        if(mapShareUsrToSM.containsKey(con.Partner_User__c) && mapShareUsrToSM.get(con.Partner_User__c)!= null){
                            if(String.isNotBlank(strAccessType) && strAccessType == System.Label.Revoke_Access_Type){
                                for(String strAccId : mapMGToSM.get(con.AccountId)){
                                    for(AccountShare accShare : mapShareUsrToSM.get(con.Partner_User__c)){
                                        if(accShare.AccountId.equals(con.AccountId)){
                                            listAccShareDel.add(accShare);
                                        }
                                    }
                                }
                                
                            }
                            else if(String.isNotBlank(strAccessType) && strAccessType == System.Label.Grant_Access_Type){
                                List<String> listAccountIds = new List<String>();
                                for(AccountShare accShare : mapShareUsrToSM.get(con.Partner_User__c)){
                                    listAccountIds.add(accShare.AccountId);
                                }
                                for(String strAccId : mapMGToSM.get(con.AccountId)){
                                    if(listAccountIds.equals(strAccId)){
                                        System.debug('::GRANT::Account Share already exists for the user '+con.Partner_User__c+' and account '+strAccId+' combination:');
                                    }
                                    else{
                                        // create share                               
                                        AccountShare accShare = new Accountshare();
                                        accShare.AccountId = strAccId;
                                        accShare.UserOrGroupId = con.Partner_User__c;
                                        accShare.AccountAccessLevel = 'Read';
                                        accShare.OpportunityAccessLevel='None';
                                        //accShare.RowCause='Manual';
                                        listAccShareInsert.add(accShare);
                                    }
                                }
                                
                            }
                        }
                        else{
                            if(String.isNotBlank(strAccessType) && strAccessType == System.Label.Grant_Access_Type){
                                // create share
                                for(String strAccId : mapMGToSM.get(con.AccountId)){
                                    AccountShare accShare = new Accountshare();
                                    accShare.AccountId = strAccId;
                                    accShare.UserOrGroupId = con.Partner_User__c;
                                    accShare.AccountAccessLevel = 'Read';
                                    accShare.OpportunityAccessLevel='None';
                                    //accShare.RowCause='Manual';
                                    listAccShareInsert.add(accShare);
                                    
                                }
                            }
                        }
                        
                    }
                }  
                
            }
        }
        
        if(listAccShareInsert.size() > 0){
            if(listAccShareInsert.size() > Integer.valueOf(System.Label.AccountShare_Threshold)){
                UserSMAccess usm = new UserSMAccess(listAccShareInsert,System.Label.Grant_Access_Type);
                ID batchprocessid = Database.executeBatch(usm,Integer.valueOf(System.Label.BatchSize));
                System.debug('batchprocessid to Add SM ::'+batchprocessid);
            }
            else{
                Database.SaveResult[] listSR = Database.insert(listAccShareInsert,false);
                for (Database.SaveResult sr : listSR) {
                    if(sr.isSuccess()){
                        System.debug('Inserted Successfully');
                    }
                    else {
                        for(Database.Error objErr : sr.getErrors()) {
                            System.debug('The following error has occurred.');  
                            System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
                            System.debug('Order oject field which are affected by the error: ' + objErr.getFields());
                            
                        }
                    }
                    
                }
            }
        }
        if(listAccShareDel.size() > 0){
            if(listAccShareDel.size() > Integer.valueOf(System.Label.AccountShare_Threshold)){
                UserSMAccess usm = new UserSMAccess(listAccShareDel,System.Label.Revoke_Access_Type);
                ID batchprocessid = Database.executeBatch(usm,Integer.valueOf(System.Label.BatchSize));
            }
            else{
                Database.DeleteResult[] listSR = Database.delete(listAccShareDel,false);
                for (Database.DeleteResult sr : listSR) {
                    if(sr.isSuccess()){
                        System.debug('Delete Successfully');
                    }
                    else {
                        for(Database.Error objErr : sr.getErrors()) {
                            System.debug('The following error has occurred.');  
                            System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
                            System.debug('Order oject field which are affected by the error: ' + objErr.getFields());
                           }
                    }
                    }
                }
        }            
    }
    /*
Description: To send a mail to Group Admins if a new Partner Track is onboarded.
*/
    public void  mailToMasterGroupAdmin(List<Partner_Track_Relationship__c> listPTR,Map<Id,Partner_Track_Relationship__c> mapOldPTR){
        List<String> listAllMG = new List<String>();
        List<String> listAllPT = new List<String>();
        List<String> listAllSM = new List<String>();
        List<string> listPRNumber = new List<String>();
        Map<String,List<contact>> mapMGToCon = new Map<String,List<contact>>();
        for(Partner_Track_Relationship__c ptr:listPTR){
            if(mapOldPTR == null && ptr.Is_Processed__c == true){
                System.debug('in insert');
                listAllMG.add(ptr.Master_Group_AffinityId__c);
                listAllPT.add(ptr.Partner_Track_AffinityId__c);
                listAllSM.add(ptr.Sales_Motion_Account_AffinityId__c);
                } 
            else if(mapOldPTR !=null && mapOldPTR.get(ptr.Id).Is_Processed__c != ptr.Is_Processed__c && ptr.Is_Processed__c == true){
                System.debug('in update');
                listAllMG.add(ptr.Master_Group_AffinityId__c);
                listAllPT.add(ptr.Partner_Track_AffinityId__c);
                listAllSM.add(ptr.Sales_Motion_Account_AffinityId__c);
            }
        }
        
        // Code should execute only if a new PT is added to existing MG and SM
        List<Partner_Track_Relationship__c> listNewPTR = new List<Partner_Track_Relationship__c>();
        Set<String> setPT = new Set<String>();
        Set<String> setMG = new Set<String>();
        
        if(listAllMG.size() > 0 && listAllPT.size() > 0){
            List<Partner_Track_Relationship__c> listPTRForNewPT = new List<Partner_Track_Relationship__c>();
            listPTRForNewPT = [SELECT id,Master_Group_AffinityId__c,Partner_Track_AffinityId__c,Sales_Motion_Account_AffinityId__c 
                               FROM Partner_Track_Relationship__c 
                               WHERE Master_Group_AffinityId__c IN: listAllMG
                               AND Partner_Track_AffinityId__c NOT IN: listAllPT];
            
            if(listPTRForNewPT.size() > 0){
                for(Partner_Track_Relationship__c newPTR : listPTRForNewPT){
                    setMG.add(newPTR.Master_Group_AffinityId__c);
                }
            }
            
        }
        if(setMG.size() > 0){
            for(Partner_Track_Relationship__c ptr:listPTR){
                if(setMG.contains(ptr.Master_Group_AffinityId__c)){
                    setPT.add(ptr.Partner_Track_AffinityId__c);
                }
                
            }
            listNewPTR = [SELECT id,Master_Group_AffinityId__c,Partner_Track_AffinityId__c,Sales_Motion_Account_AffinityId__c 
                          FROM Partner_Track_Relationship__c 
                          WHERE Master_Group_AffinityId__c IN: setMG
                          AND Partner_Track_AffinityId__c IN: setPT];
        }
        if(listNewPTR.size() > 0){
            
            EmailTemplate et = [Select id,DeveloperName 
                                FROM EmailTemplate 
                                WHERE DeveloperName=:'PRM_En_New_Partner_Rgstrn_Under_Mg_VF'];
            OrgWideEmailAddress owa = [SELECT Id, DisplayName, Address 
                                       From OrgWideEmailAddress 
                                       WHERE address='no_reply@dell.com'];
            // to hold the contacts that are group admin for a given Master Group
            List<contact> listConAsGroupAdmin = new List<contact>();
            if(setMG.size()>0){
                listConAsGroupAdmin = [SELECT id,account.Master_Group_Affinity_ID__c,EligibleTracks__c 
                                       FROM contact 
                                       WHERE account.Master_Group_Affinity_ID__c IN:setMG
                                       AND Enable_as_Partner_Group_Administrator__c=true];
            } 
            if(listConAsGroupAdmin.size()>0){
                for(Contact con:listConAsGroupAdmin){
                    if(mapMGToCon.containsKey(con.account.Master_Group_Affinity_ID__c)){
                        mapMGToCon.get(con.account.Master_Group_Affinity_ID__c).add(con);
                    }else{
                        mapMGToCon.put(con.account.Master_Group_Affinity_ID__c,new List<contact>{con});  
                    }
                }
                
            }
            
            List<Partner_Track__c> listPTForMG = new List<Partner_Track__c>();
            if(setPT.size()>0){
                listPTForMG = [SELECT id,name,Master_Group_Affinity_Id__c,Partner_Track_AffinityId__c,Partner_Registration_Number__c 
                               FROM Partner_Track__c 
                               WHERE Partner_Track_AffinityId__c IN:setPT 
                               AND Master_Group_Affinity_Id__c IN:setMG];
            } 
            // Added By Sneha
            Map<String,List<Partner_Track__c>> mapMGToPT = new Map<String, List<Partner_Track__c>>();
            List<Contact> listContact = new List<Contact>();
            Map<String,String> mapPTToPR = new map<String,String>();
            if(listPTForMG.size()>0){
                for(Partner_Track__c pt:listPTForMG){
                    // Added by Sneha
                    if(mapMGToPT.containsKey(pt.Master_Group_Affinity_Id__c)){
                        mapMGToPT.get(pt.Master_Group_Affinity_Id__c).add(pt);
                    }
                    else{
                        mapMGToPT.put(pt.Master_Group_Affinity_Id__c, new List<Partner_Track__c>{pt});
                    }
                    if(String.isNotBlank(pt.Partner_Registration_Number__c)){
                        listPRNumber.add(pt.Partner_Registration_Number__c);
                        mapPTToPR.put(pt.Partner_Track_AffinityId__c,pt.Partner_Registration_Number__c);  
                    }
                }
            }     
            
            List<Partner_Request__c> listPR = new List<Partner_Request__c>();
            if(listPRNumber.size() > 0){
                listPR = [SELECT id,name 
                          FROM Partner_Request__c 
                          WHERE name IN:listPRNumber];
            }
            
            System.debug('##Partner Request'+listPR);
            map<String,Partner_Request__c> mapPR = new map<String,Partner_Request__c>();
            if(listPR.size()>0){
                for(Partner_Request__c pr : listPR){
                    mapPR.put(pr.Name,pr);
                }
            }
            
            List<Messaging.SingleEmailMessage> listMessages = new List<Messaging.SingleEmailMessage>();
            
            if(listConAsGroupAdmin.size() > 0){
                for(Contact con : listConAsGroupAdmin){
                    //if(mapMGToCon.containsKey(con.Account.Master_Group_Affinity_Id__c) && mapMGToCon.get(con.Account.Master_Group_Affinity_Id__c)!= null){
                    if(mapMGToPT.containsKey(con.Account.Master_Group_Affinity_Id__c) && mapMGToPT.get(con.Account.Master_Group_Affinity_Id__c)!= null ){
                        for(Partner_Track__c partnerTrack : mapMGToPT.get(con.Account.Master_Group_Affinity_Id__c)){
                            Messaging.singleEmailmessage email =new Messaging.singleEmailmessage();
                            if(String.isNotBlank(con.EligibleTracks__c)){
                                con.EligibleTracks__c = con.EligibleTracks__c+';'+partnerTrack.Id;
                            }
                            else{
                                con.EligibleTracks__c = partnerTrack.Id;
                            }
                            // PT will for sure have a PR associated so avoiding null check
                            if(String.isNotBlank(mapPTToPR.get(partnerTrack.Partner_Track_AffinityId__c))){
                                if(mapPR.get(mapPTToPR.get(partnerTrack.Partner_Track_AffinityId__c))!= null){
                                    System.debug('WhatId::'+mapPR.get(mapPTToPR.get(partnerTrack.Partner_Track_AffinityId__c)).Id);
                                    email.setWhatId(mapPR.get(mapPTToPR.get(partnerTrack.Partner_Track_AffinityId__c)).Id);  
                                }
                            }
                            email.setTargetObjectId(con.Id);
                            email.setTemplateId(et.id);
                            email.setSaveAsActivity(false);
                            email.setOrgWideEmailAddressId(owa.id);
                            listMessages.add(email);
                        }
                        
                        listContact.add(con);
                    } 
                    
                } 
            }
            System.debug('listContact'+listContact.size());
            if(listContact.size() > 0){
                GlobalVariables.BYPASS_PARTNER_PROFILE_INTEGRATION = true;
                Database.SaveResult[] listSR = Database.update(listContact,false);
                for (Database.SaveResult sr : listSR) {
                    if(sr.isSuccess()){
                        System.debug('Updated Successfully from PTRHandler');
                    }
                    else {
                        for(Database.Error objErr : sr.getErrors()) {
                            System.debug('The following error has occurred.');  
                            System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
                            System.debug('Contact object field which are affected by the error: ' + objErr.getFields());
                        }
                    }
                    
                }
            }
            if(listMessages.size() > 0){
                List<Messaging.SendEmailResult> listresults = new List<Messaging.SendEmailResult>();
                try{
                    listresults= Messaging.sendEmail(listMessages);                   
                }
                catch(Exception e){                    
                }
                
            }
            
        }
    }
}