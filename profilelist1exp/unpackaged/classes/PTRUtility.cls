/***********************************************************
* Name          : PTRUtility
* Description   : Controller for PTR related Utility class

History:
Version     Date            Modified By     CR          Description  
1.0         31-Oct-2019     Srinivasa K                 Controller for PTR related Utility class 
--------------------------------------------------------------------------------------*/

Public Class PTRUtility{
    
    public List<Partner_Track_Relationship__c> insertPTR(List<Partner_Track_Relationship__c> listptrList2,string strrequiredname){
        List<String> listpartnerAffintyIds =new List<String>();
        List<String> listmasterAffinityIds =new List<String>();
        List<String> listsalesMotionAffinityIds  =new List<String>();
        List<Partner_Track_Relationship__c> listPtrProcessed = new List<Partner_Track_Relationship__c>();
        //listPtrProcessed = [select id, key__c from Partner_Track_Relationship__c ];
        system.debug('total list : '+listptrList2);   
        try{
            //Fetch all the Partner_Track_AffinityId__c ,Master_Group_AffinityId__c,Sales_Motion_Account_AffinityId__c from newly inserted PTR records
            for(Partner_Track_Relationship__c ptr : listptrList2){
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
            system.debug('===listsalesMotionAccounts=>>>+++++'+listsalesMotionAccounts);
            List<Partner_Track__c> listpartnerTracks = [select id,Partner_Track_AffinityId__c,Primary_SMAffinity_Account__c,Primary_Sales_Motion_Affinity_ID__c,Master_Group_Id__c,Master_Group_Id__r.Name,Track_Id__c,Track_Id__r.name from Partner_Track__c where Partner_Track_AffinityId__c IN : listpartnerAffintyIds];
            system.debug('===listpartnerTracks=>>>+++++'+listpartnerTracks);
            //Flag about Relations Start
            for(Partner_Track_Relationship__c ptr : listptrList2){
                Boolean bacProcessed=false;
                Boolean bsacProcessed=false;
                Boolean bptProcessed=false;
                if(ptr.Master_Group_AffinityId__c!=null){
                    for(Account ac:listmasterAccounts){ //Master Group Accounts
                        if(ptr.Master_Group_AffinityId__c == ac.Master_Group_Affinity_ID__c){
                            bacProcessed=true;
                            system.debug('===bacProcessed=>>>+++++'+bacProcessed);
                        }
                    }
                }
                if(ptr.Sales_Motion_Account_AffinityId__c!=null){
                    for(Account ac:listsalesMotionAccounts){ //Salesmotion Accounts
                        if(ptr.Sales_Motion_Account_AffinityId__c == ac.Account_ID__c){
                            bsacProcessed=true;
                            system.debug('===bsacProcessed=>>>+++++'+bsacProcessed);
                        }
                    }
                }
                if(ptr.Partner_Track_AffinityId__c!=null){
                    for(Partner_Track__c pt:listpartnerTracks){ //Partner Tracks
                        if(ptr.Partner_Track_AffinityId__c == pt.Partner_Track_AffinityId__c){
                            bptProcessed=true;
                            system.debug('===bptProcessed=>>>+++++'+bptProcessed);
                        }
                    }
                }
                system.debug('===Key=>>>'+ptr.Key__c);
                system.debug('===ptProcessed=>>>'+bptProcessed);
                system.debug('===sacProcessed=>>>'+bsacProcessed);
                system.debug('===acProcessed=>>>'+bacProcessed);
                if(bptProcessed && bsacProcessed && bacProcessed){
                    ptr.Is_Processed__c=true;
                    listPtrProcessed.add(ptr);
                }
                system.debug('PTR : '+listPtrProcessed);
            }
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
            
            
            if(listPrimarySMA.size()>0){
                for (Account primarySM: listPrimarySMA ) {
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
            //Creating Account and Partner Track list for updation with associated values like MasterGroup Id, Partner Track id and Track name
            List<Account> listaccounts =new List<Account>();
            List<Partner_Track__c> listpartnerTracksList = new List<Partner_Track__c>();
            map<id,account> mapacc = new map<id,account>(); // To By pass Duplicate ids Exception
            map<id,Partner_Track__c> mappt = new map<id,Partner_Track__c>(); // To By pass Duplicate ids Exception
            for(Partner_Track_Relationship__c pt :listptrList2){
                Account acc;
                Partner_Track__c ptObj;
                if(mapsalesMotionMap.size()>0 && mapsalesMotionMap.get(pt.Sales_Motion_Account_AffinityId__c) !=null){
                    acc= mapsalesMotionMap.get(pt.Sales_Motion_Account_AffinityId__c); 
                }
                if(mappartnerTrackMap.size()>0 && pt.Partner_Track_AffinityId__c!=null){
                    ptObj = mappartnerTrackMap.get(pt.Partner_Track_AffinityId__c);
                    
                }
                //SalesMotion Account and Partner Track record fields population
                if(mapmasterGroupMap.size()>0 && mapmasterGroupMap.get(pt.Master_Group_AffinityId__c) !=null){
                    if(acc!=null){
                        acc.Master_Group_Id__c = mapmasterGroupMap.get(pt.Master_Group_AffinityId__c);
                        
                    }
                    if(ptObj!=null){
                        ptObj.Master_Group_Id__c= mapmasterGroupMap.get(pt.Master_Group_AffinityId__c);                                  
                        ptObj.Primary_SMAffinity_Account__c =mapPrimarySMAccount.get( mapPTAffinityTOSMAffinity.get(pt.Partner_Track_AffinityId__c));
                        listpartnerTracksList.add(ptObj);
                        
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
                }
            }
            
            if(listaccounts.size()>0){
                mapacc.putall(listaccounts);
                TriggerExecutionController.setSkipAccountTriggers(True);
                Database.SaveResult[] listsrAccList = Database.update(mapacc.values(),false);
                WebServiceExceptionHandling.exceptionHandlingMethod(listsrAccList,'Account','PTR Insert','Exception',null,mapacc.values());
            }
            if(listpartnerTracksList.size()>0){
                mappt.putall(listpartnerTracksList);
                Database.SaveResult[] listsrPtList = Database.update(mappt.values(),false); 
                WebServiceExceptionHandling.exceptionHandlingMethod(listsrPtList,'Partner Track','PTR Insert','Exception',mappt.values(),null);
            }
            if(listPtrProcessed.size() > 0){
                //Database.update(listPtrProcessed, false);                
                if(strrequiredname == 'batch') {
                    return listPtrProcessed;
                    
                }           
                
            }
            
        }catch(exception e){
            system.debug('Exception occured in PTRHandler insertPTR method'+e.getMessage());
        }
        return null;
        
    }
    
}