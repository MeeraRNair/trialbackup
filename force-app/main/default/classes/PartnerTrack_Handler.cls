/*
* Author   : Prasanthi M
* Purpose  : Partner Track Handler which populates the TrackId in PT record based on the 
*             selection of Track Affinity Id in PT 
* Date     : 19-Dec-2018
* Revision CR Number   Release No  Date            Modified By     Description
* -------- ---------   ----------  -----------     ------------    -----------
* 1.0                   0502        5th April 2019  Sneha           Story #6424430
* 1.1                   1101        25th Sep 2019   Sneha           Story #7280833
* 
* 
*
*/
Public class PartnerTrack_Handler {
    //While PartnerTrack record is inserting, based on its Track Affinity Id TrackId should be populated
    Public void insertPT(List<Partner_Track__c> listptRecords){
        List<String> listtrackAffinityIds = new List<String>();
        List<String> listpartnerTrackNumbers = new List<String>();
        map<string,string> mapCountryCodeToCountry = new map<string,string>();
        system.debug('###PT List'+listptRecords);
        try{
            for(Partner_Track__c pt:listptRecords){
                if(pt.Track_Affinity_Id__c!=null){
                    listtrackAffinityIds.add(pt.Track_Affinity_Id__c);
                }
                listpartnerTrackNumbers.add(pt.Partner_Registration_Number__c);
            }
            List<Track__c> listtrackList = [select id,Track_AffinityId__c,Country_Code__c from Track__c where Track_AffinityId__c IN : listtrackAffinityIds];
            system.debug('Track List'+listtrackList);
            List<Partner_Request__c> listPRRecords = [select id,Partner_Request__c.Name,Agree_Dell_Reseller__c,createdDate,Lead__c,Lead__r.Contracted_Distributor__c,Lead__r.Countries_doing_business_in__c,
                                            Lead__r.Distribution_Channel__c,Lead__r.Diverse_Owned_Business__c,Lead__r.Diversity_Certification__c,
                                            Lead__r.Diversity_Certification_Other__c,Lead__r.Industries__c,Lead__r.Legacy_Partner_Program_Ts_Cs__c, 
                                            Lead__r.Legacy_Partner_Program_Ts_Cs_Date__c,Lead__r.PT_partner_account__c,Lead__r.Sponsoring_Distributor_Federal__c,
                                            Lead__r.Sponsoring_Distributor_OEM__c,Lead__r.Sponsoring_Distributor_Solution_Provid__c,Lead__r.Product_Focus__c,Lead__r.Preferred_Storage_Distributor__c
                                            from Partner_Request__c where name IN : listpartnerTrackNumbers]; 
            system.debug('****PTNumbers' +listpartnerTrackNumbers);
             system.debug('****listPRRecords' +listPRRecords);
        
            for(Country_and_Code__mdt eachRecord : [select Country__c,Code__c from Country_and_Code__mdt limit 1000]){
              mapCountryCodeToCountry.put(eachRecord.Code__c,eachRecord.Country__c);
             } 
                         
            Map<String,Id> mapTrackMap = new Map<String,Id>();
            Map<String,Partner_Request__c> mapPR = new Map<String,Partner_Request__c>();
            if(listtrackList.size()>0){
               for(Track__c t:listtrackList){
                   mapTrackMap.put(t.Track_AffinityId__c,t.id);
               } 
               for(Partner_Track__c pt:listptRecords){
                   if(mapTrackMap.size()>0 && mapTrackMap.get(pt.Track_Affinity_Id__c)!=null){
                       pt.Track_Id__c = mapTrackMap.get(pt.Track_Affinity_Id__c);
                       system.debug('###PT with TrackId'+pt);
                   }
                    
               }
            } 
            if(listPRRecords.size() >0){
                for(Partner_Request__c pr: listPRRecords){
                    mapPR.put(pr.name, pr);
                    system.debug('****mapPR' +mapPR);
                }
                for(Partner_Track__c pt:listptRecords){
                 if(mapPR.size()>0 && mapPR != null && mapPR.get(pt.Partner_Registration_Number__c) != null){
                   if(mapPR.get(pt.Partner_Registration_Number__c).Lead__r.Contracted_Distributor__c == True) {
                    pt.Contracted_Distributor__c = True ;
                   }
                    pt.Countries_doing_business_in__c = mapPR.get(pt.Partner_Registration_Number__c).Lead__r.Countries_doing_business_in__c;
                    pt.Distribution_Channel__c = mapPR.get(pt.Partner_Registration_Number__c).Lead__r.Distribution_Channel__c;
                   if(mapPR.get(pt.Partner_Registration_Number__c).Lead__r.Diverse_Owned_Business__c == True) {
                    pt.Diverse_Owned_Business__c = True ;
                   }
                     
                    pt.Diversity_Certification__c = mapPR.get(pt.Partner_Registration_Number__c).Lead__r.Diversity_Certification__c;   
                    pt.Diversity_Certification_Other__c = mapPR.get(pt.Partner_Registration_Number__c).Lead__r.Diversity_Certification_Other__c;
                    pt.Industries__c =mapPR.get(pt.Partner_Registration_Number__c).Lead__r.Industries__c;
                    pt.Legacy_Partner_Program_Ts_Cs_Date__c = mapPR.get(pt.Partner_Registration_Number__c).Lead__r.Legacy_Partner_Program_Ts_Cs_Date__c;
                    pt.Legacy_Partner_Program_Ts_Cs__c = mapPR.get(pt.Partner_Registration_Number__c).Lead__r.Legacy_Partner_Program_Ts_Cs__c;
                     
                   if(mapPR.get(pt.Partner_Registration_Number__c).Lead__r.PT_partner_account__c == True) {
                    pt.Partner_Account__c = True;
                   }
                    pt.Sponsoring_Distributor_Federal__c = mapPR.get(pt.Partner_Registration_Number__c).Lead__r.Sponsoring_Distributor_Federal__c;
                    pt.Sponsoring_Distributor_OEM__c = mapPR.get(pt.Partner_Registration_Number__c).Lead__r.Sponsoring_Distributor_OEM__c; 
                    pt.Sponsoring_Distributor_Solution_Provid__c = mapPR.get(pt.Partner_Registration_Number__c).Lead__r.Sponsoring_Distributor_Solution_Provid__c; 
                    pt.Product_Focus__c = mapPR.get(pt.Partner_Registration_Number__c).Lead__r.Product_Focus__c;
                    pt.Preferred_Distributor__c = mapPR.get(pt.Partner_Registration_Number__c).Lead__r.Preferred_Storage_Distributor__c;
                     
                 /* if(pt.Country_Code__c != null && mapCountryCodeToCountry.get(pt.Country_Code__c.toUpperCase()) != null){
                          pt.Country__c =  mapCountryCodeToCountry.get(pt.Country_Code__c.toUpperCase());
                    }
                   */
                   
                   // Added by Harsha 
                   // For Story: 7417639
                   
                   if(pt.DELLEMC_Ts_and_Cs_agreement_User__c == null && mapPR.get(pt.Partner_Registration_Number__c).Agree_Dell_Reseller__c == True)
                   {
                      pt.DELLEMC_Ts_and_Cs_agreed_date__c = mapPR.get(pt.Partner_Registration_Number__c).createdDate;
                      pt.DELLEMC_Ts_and_Cs_agreement__c = True;
                   }
                     
                   }
               }
            }
        }catch(Exception e){
            system.debug('Exception occured in PartnerTrack_Handler insertPT method'+e.getMessage());
        }
    }
    //While PartnerTrack record's TrackAffinity Id is updating,Then associated TrackId should be populated
    //Changes Made by: Sneha
    //changes Part of: 6424430
    Public void updatePT(Map<Id,Partner_Track__c> mapoldMap,Map<Id,Partner_Track__c> mapnewMap){
        Set<Id> setptrIds=mapoldMap.keySet();
        List<String> listtrackAffinityIds = new List<String>();
        List<String> listPrimarySMAffinityIds = new List<String>();
        
       map<string,string> mapCountryCodeToCountry = new map<string,string>();
        try{
            for(Id key :setptrIds)
            {
                // Fetch the old version and new version of Partner_Track__c 
                Partner_Track__c oldPt =mapoldMap.get(key);
                Partner_Track__c newPt=mapnewMap.get(key);
                //Based on the modified affinity ids fetch those in list
                if(oldPt.Track_Affinity_Id__c != newPt.Track_Affinity_Id__c && newPt.Track_Affinity_Id__c!=null)
                {
                    listtrackAffinityIds.add(newPt.Track_Affinity_Id__c);
                }
                
                //Verify if any of Primary SM are changed on Partner Tack
               if(oldPt.Primary_Sales_Motion_Affinity_ID__c != newPt.Primary_Sales_Motion_Affinity_ID__c && newPt.Primary_Sales_Motion_Affinity_ID__c!=null)
                {
                    listPrimarySMAffinityIds.add(newPt.Primary_Sales_Motion_Affinity_ID__c);
                }
            }
            
            for(Country_and_Code__mdt eachRecord : [select Country__c,Code__c from Country_and_Code__mdt limit 1000]){
              mapCountryCodeToCountry.put(eachRecord.Code__c,eachRecord.Country__c);
             } 
                        
            
          List<Track__c> listtrackList = [select id,Track_AffinityId__c from Track__c where Track_AffinityId__c IN : listtrackAffinityIds];
            Map<String,Id> mapTrackMap = new Map<String,Id>();
            if(listtrackList.size()>0){
                for(Track__c t:listtrackList){
                    mapTrackMap.put(t.Track_AffinityId__c,t.id);
                }              
            }
            
            //Map of New Primary Salmotion Affinity ID and ID
            List<Account> listSalesMotion = [Select id,Account_ID__c from Account where Account_ID__c IN :listPrimarySMAffinityIds];
            Map<String,Id> mapSMMap = new Map<String,Id>();
            if( listSalesMotion.size()>0){
                for(Account acc:listSalesMotion)
                {
                    mapSMMap.put(acc.Account_ID__c,acc.id);
                }              
            }
                     
          for(Id key :setptrIds){
                // Fetch the old version and new version of Partner_Track__c 
                Partner_Track__c oldPt =mapoldMap.get(key);
                Partner_Track__c newPt=mapnewMap.get(key);
                //Based on the modified affinity ids fetch those in list
                if(oldPt.Track_Affinity_Id__c != newPt.Track_Affinity_Id__c){
                    if(mapTrackMap.size()>0 && newPt.Track_Affinity_Id__c!=null){
                        newPt.Track_Id__c = mapTrackMap.get(newPt.Track_Affinity_Id__c);
                    }
                  }
              
                if(oldPt.Primary_Sales_Motion_Affinity_ID__c != newPt.Primary_Sales_Motion_Affinity_ID__c){
                    if(mapSMMap.size()>0 && newPt.Primary_Sales_Motion_Affinity_ID__c!=null){
                        newPt.Primary_SMAffinity_Account__c = mapSMMap.get(newPt.Primary_Sales_Motion_Affinity_ID__c);
                    }
                  }    
              
                /*if(oldPt.Track_Id__c != newPt.Track_Id__c && newPt.Country_Code__c != null && mapCountryCodeToCountry.get(newPt.Country_Code__c.toUpperCase()) != null){
                          newPt.Country__c =  mapCountryCodeToCountry.get(newPt.Country_Code__c.toUpperCase());
                   }
                */
               //Added By: Sneha
               //Added For : Story #6424430
               if(oldPt.Partner_Program_Tier__c != newPt.Partner_Program_Tier__c){
                   System.debug('new PT Partner_Program_Tier__c::'+newPt.Partner_Program_Tier__c);
                   if(newPt.Partner_Program_Tier__c == System.Label.Partner_Tiers_Authorized && System.Label.Partner_Demoted_Tiers.contains(String.valueOf(oldPt.Partner_Program_Tier__c).trim())){
                       newPt.Partner_Demoted__c = true;
                       newPt.Partner_Demoted_Date__c = System.now();
                   }
                   else if(newPt.Partner_Program_Tier__c != System.Label.Partner_Tiers_Authorized && newPt.Partner_Demoted__c && String.isNotBlank((String.valueOf(newPt.Partner_Demoted_Date__c)))){
                       System.debug('Partner_Demoted__c::'+newPt.Partner_Demoted__c);
                       newPt.Partner_Demoted__c = false;
                       newPt.Partner_Demoted_Date__c = null;
                       
                   }
                      
               }
            }
        }catch(Exception e){
            system.debug('Exception occured in PartnerTrack_Handler updatePT method'+e.getMessage());
        }
    }
    Public void afterUpdatePT(Map<Id,Partner_Track__c> mapoldMap,Map<Id,Partner_Track__c> mapnewMap){
        try{
            boolean bupdateFlag=false;
            list<account> listaccList = new List<account>();
            list<Account> listsalesMotionAccountList=[select id,Distribution_Sell_To_Countries__c,Purchasing_Model__c,Partner_Relationship__c,Partner_Track__c,Partner_Tier__c,Partner_Type__c,New_Partner_Programme_T_C_s_agreed_on__c,New_Partner_Programme_T_C_s__c from Account where Partner_Track__c IN: mapnewMap.keySet()];
            system.debug('****Salesmotion Accounts List : '+listsalesMotionAccountList);
            list<Partner_Track__c> listPartnerTrack = [select Id,DELLEMC_Ts_and_Cs_agreement__c,DELLEMC_Ts_and_Cs_agreement_User__r.Partner_My_Account_GUID__c,DELLEMC_Ts_and_Cs_agreed_date__c from Partner_Track__c where Id IN: mapnewMap.keySet()];
            system.debug('****listPartnerTrack >>>> : '+listPartnerTrack);
             Map<String,String> mapContactGuid = new Map<String,String>();
            if(listsalesMotionAccountList.size() > 0){
                for(Account sma:listsalesMotionAccountList){
                    if(mapoldMap.get(sma.Partner_Track__c).Purchase_Path__c != mapnewMap.get(sma.Partner_Track__c).Purchase_Path__c ){
                        sma.Partner_Tier__c = mapnewMap.get(sma.Partner_Track__c).Purchase_Path__c;
                        bupdateFlag=true;
                    }
                    if(mapoldMap.get(sma.Partner_Track__c).Track_PPT__c != mapnewMap.get(sma.Partner_Track__c).Track_PPT__c){
                        sma.Partner_Type__c = mapnewMap.get(sma.Partner_Track__c).Track_PPT__c;
                        bupdateFlag=true;
                    }
                    if(mapoldMap.get(sma.Partner_Track__c).Partner_Program_Tier__c != mapnewMap.get(sma.Partner_Track__c).Partner_Program_Tier__c){
                        sma.Partner_Relationship__c = mapnewMap.get(sma.Partner_Track__c).Partner_Program_Tier__c;
                        bupdateFlag=true;
                    }
                    if(mapoldMap.get(sma.Partner_Track__c).Speciality_Product_Purchase_Path__c  != mapnewMap.get(sma.Partner_Track__c).Speciality_Product_Purchase_Path__c){
                        sma.Purchasing_Model__c = mapnewMap.get(sma.Partner_Track__c).Speciality_Product_Purchase_Path__c ;
                        bupdateFlag=true;
                    }
                    if(mapoldMap.get(sma.Partner_Track__c).Authorized_Countries__c != mapnewMap.get(sma.Partner_Track__c).Authorized_Countries__c){
                        sma.Distribution_Sell_To_Countries__c = mapnewMap.get(sma.Partner_Track__c).Authorized_Countries__c;
                        bupdateFlag=true;
                    }
                    if(mapoldMap.get(sma.Partner_Track__c).DELLEMC_Ts_and_Cs_agreed_date__c != mapnewMap.get(sma.Partner_Track__c).DELLEMC_Ts_and_Cs_agreed_date__c){
                        sma.New_Partner_Programme_T_C_s_agreed_on__c = mapnewMap.get(sma.Partner_Track__c).DELLEMC_Ts_and_Cs_agreed_date__c;
                        bupdateFlag=true;
                    }
                    if(mapoldMap.get(sma.Partner_Track__c).DELLEMC_Ts_and_Cs_agreement__c != mapnewMap.get(sma.Partner_Track__c).DELLEMC_Ts_and_Cs_agreement__c){
                        sma.New_Partner_Programme_T_C_s__c = mapnewMap.get(sma.Partner_Track__c).DELLEMC_Ts_and_Cs_agreement__c;
                        bupdateFlag=true;
                    }  
                    if(bupdateFlag){
                    listaccList.add(sma);
                    }
                }
                system.debug('****AccountsList : '+listaccList);
                if(listaccList.size()>0){
                    update listaccList;
                    system.debug('****UpdateSuccessfully');
                }
            }
            if(listPartnerTrack.size()>0){
            for(partner_track__c ptr : listPartnerTrack){
            if(mapoldMap.get(ptr.Id).DELLEMC_Ts_and_Cs_agreement__c != mapnewMap.get(ptr.Id).DELLEMC_Ts_and_Cs_agreement__c  && ptr.DELLEMC_Ts_and_Cs_agreement_User__c !=null){
                       mapContactGuid.put(ptr.DELLEMC_Ts_and_Cs_agreement_User__r.Partner_My_Account_GUID__c,ptr.Id);
            system.debug('enter listpartnerTrack*****');        
            }
            }
            if(!mapContactGuid.isEmpty()){
                  PartnerOnboardingIntegrationServices.profileServicesIntegration(mapContactGuid);  
                }
            }
        }catch(exception e){system.debug('Exception : '+e.getMessage());}
    }
    public void populatePrimaryPartnerTrackId(Map<id,partner_track__c> mapOldPT,Map<id,partner_track__c> mapNewPT){ 
            list<string> listAuditElgblePts = new list<string>(); 
            list<string> listPrimaryPts= new list<string>(); 
            list<string> listPartnerProgramTracks= new list<string>(); 
            map<id,partner_track__c> mapPtToProcess = new map<id,partner_track__c>();
            list<partner_track__c> listExstngPT = new list<partner_track__c> ();
            map<string,partner_track__c> mapMgIdToAuditElgblePts = new map<string,partner_track__c>();
            map<string,list<partner_track__c>> mapMgIdToExstngPts = new map<string,list<partner_track__c>>();
          
            integer inti = 0;
            id idPtIdToUpdate;
            string strNameToUpdate;
            string strPtNameToUpdate;
            string strPrimarySMPT;
            string strPartnerTrack;
            string strPartnerProgramTrack;
            string strPartnerProgramTracktrim;
        
        
            for(partner_track__c rec:mapNewPT.values()){
                if(((mapOldPT.get(rec.id).Master_Group_Id__c != mapNewPT.get(rec.id).Master_Group_Id__c &&  mapNewPT.get(rec.id).Master_Group_Id__c != null) 
                   ||(mapOldPT.get(rec.id).Track_Name__c != mapNewPT.get(rec.id).Track_Name__c &&  mapNewPT.get(rec.id).Track_Name__c != null) 
                   ||(mapOldPT.get(rec.id).Partner_Type__c != mapNewPT.get(rec.id).Partner_Type__c &&  mapNewPT.get(rec.id).Partner_Type__c != null)
                  ||(mapOldPT.get(rec.id).Partner_Track__c != mapNewPT.get(rec.id).Partner_Track__c &&  mapNewPT.get(rec.id).Partner_Track__c != null)) 
                   && mapNewPT.get(rec.id).Allow_for_manual_Audi_Track_Calculation__c != true){
                  mapNewPT.get(rec.id).Partner_Track_Primary_Partner_Track_ID__c = '';
                    mapNewPT.get(rec.id).Partner_Track_Program_Group_Name__c = '';
                      mapNewPT.get(rec.id).Error__c = '';
                  mapPtToProcess.put(rec.id,rec);
                  listPartnerProgramTracks.add(mapNewPT.get(rec.id).Partner_Track_Name_Country__c);
            }
            } 
          if(mapPtToProcess.keySet().size() > 0){ 
            for(Partner_Program_Track__c eachRec : [select Partner_Track_Name__c,Primary_Partner_Track_Country__c from Partner_Program_Track__c where Audit_Track_Y_N__c = true and Partner_Track_Name__c in :listPartnerProgramTracks]){
                listAuditElgblePts.add(eachRec.Partner_Track_Name__c);
                listPrimaryPts.add(eachRec.Primary_Partner_Track_Country__c);
                system.debug('***listPrimaryPts' +listPrimaryPts);
            }
            
            //if(listAuditElgblePts.size() > 0){
                for(partner_track__c ptToProcess:mapPtToProcess.values()){
                    if(mapPtToProcess.get(ptToProcess.id).Track_Name__c != null && listAuditElgblePts.contains(mapPtToProcess.get(ptToProcess.id).Partner_Track_Name_Country__c)){
                        mapMgIdToAuditElgblePts.put(mapPtToProcess.get(ptToProcess.id).Master_Group_Affinity_Id__c,mapPtToProcess.get(ptToProcess.id));
                        system.debug('***mapMgIdToAuditElgblePts' +mapMgIdToAuditElgblePts);
                    }
                }
                
                if(mapMgIdToAuditElgblePts.keyset().size() > 0){
                    listExstngPT = [select id,Name,Master_Group_Affinity_Id__c,Partner_Track_Name_Country__c,Track_Name__c,Partner_Track__c,Primary_Sales_Motion_Affinity_ID__c from partner_track__c where Master_Group_Affinity_Id__c in :mapMgIdToAuditElgblePts.keyset()];
                    
                    for(partner_track__c exstngPT:listExstngPT){                          
                        if (mapMgIdToExstngPts.containsKey(exstngPT.Master_Group_Affinity_Id__c)){
                            mapMgIdToExstngPts.get(exstngPT.Master_Group_Affinity_Id__c).add(exstngPT);
                        }else{
                            mapMgIdToExstngPts.put(exstngPT.Master_Group_Affinity_Id__c, new  List <partner_track__c> { exstngPT });
                        }
                    }
                    
                    for(string strkey :mapMgIdToExstngPts.keyset()){
                        inti = 0;
                        for(partner_track__c value : mapMgIdToExstngPts.get(strkey)){
                            if(listPrimaryPts.contains(value.Partner_Track_Name_Country__c)){
                                idPtIdToUpdate = value.id;
                                strNameToUpdate = value.Name;
                                strPtNameToUpdate = value.Track_Name__c;
                                strPrimarySMPT = value.Primary_Sales_Motion_Affinity_ID__c;
                                strPartnerTrack = value.Partner_Track__c;
                                strPartnerProgramTrack = value.Track_Name__c;
                                strPartnerProgramTracktrim = strPartnerProgramTrack.Substring(5,strPartnerProgramTrack.length());
                                system.debug('^^^PtIdToUpdate' +idPtIdToUpdate);
                                inti++;
                            }                         
                        }
                        Partner_Track__c newPt = mapMgIdToAuditElgblePts.get(strkey);
                        if(inti == 0){                            
                        system.debug('*****primary partner track 0'); 
                            // No matching records found
                            newPt.Partner_Track_Primary_Partner_Track_ID__c = '';
                            newPt.Partner_Track_Program_Group_Name__c = '';
                           newPt.Error__c = 'No Primary Audit Eligible Track in Country';
                        }else if(inti == 1){
                            newPt.Error__c = '';
                            system.debug('*****primary partner track 1');
                           // only 1 record found
                           newPt.Partner_Track_Primary_Partner_Track_ID__c = strNameToUpdate;
                            newPt.Partner_Track_Program_Group_Name__c = strPtNameToUpdate;
                                if(newPt.Partner_Track__c == 'Federal' && !newPt.Track_Name__c.contains('Federal')){
                                    newPt.Partner_Track_Primary_Partner_Track_ID__c = '';
                            	newPt.Partner_Track_Program_Group_Name__c = '';
                                newPt.Error__c = 'Partner Track & Partner Program Track Misaligned';
                                }
                             else if(newPt.Partner_Track__c == 'Distributor' && !newPt.Track_Name__c.contains('Distributor')){
                                    newPt.Partner_Track_Primary_Partner_Track_ID__c = '';
                            	newPt.Partner_Track_Program_Group_Name__c = '';
                                newPt.Error__c = 'Partner Track & Partner Program Track Misaligned';
                                }
                            else if(newPt.Partner_Track__c == 'Cloud Service Provider' && !newPt.Track_Name__c.contains('Cloud Service Provider')){
                                    newPt.Partner_Track_Primary_Partner_Track_ID__c = '';
                            	newPt.Partner_Track_Program_Group_Name__c = '';
                                newPt.Error__c = 'Partner Track & Partner Program Track Misaligned';
                                }
                            else if(newPt.Partner_Track__c == 'Systems Integrator' && !newPt.Track_Name__c.contains('Systems Integrator')){
                                    newPt.Partner_Track_Primary_Partner_Track_ID__c = '';
                            	newPt.Partner_Track_Program_Group_Name__c = '';
                                newPt.Error__c = 'Partner Track & Partner Program Track Misaligned';
                                }
                            else if(newPt.Partner_Track__c == 'Solution Provider' && !newPt.Track_Name__c.contains('Solution Provider')){
                                    newPt.Partner_Track_Primary_Partner_Track_ID__c = '';
                            	newPt.Partner_Track_Program_Group_Name__c = '';
                                newPt.Error__c = 'Partner Track & Partner Program Track Misaligned';
                                }
                                else if(newPt.Partner_Track__c == 'OEM' && newPt.Track_Name__c.Substring(5,newPt.Track_Name__c.length()) != 'OEM'){
                                    newPt.Partner_Track_Primary_Partner_Track_ID__c = '';
                            	newPt.Partner_Track_Program_Group_Name__c = '';
                                newPt.Error__c = 'Partner Track & Partner Program Track Misaligned';
                                }
                                /* newPt.Partner_Track_Primary_Partner_Track_ID__c = '';
                            	newPt.Partner_Track_Program_Group_Name__c = '';
                                newPt.Error__c = 'Partner Track & Partner Program Track Misaligned';*/
                            if(newPt.Error__c != 'Partner Track & Partner Program Track Misaligned'){
                            if(strPrimarySMPT == null || strPrimarySMPT == ''){
                                newPt.Error__c = 'Primary Audit Eligible Partner Track does not carry a Primary Sales Motion';
                            }
                            else{
                                newPt.Error__c = '';
                            }
                        }
                        }else{
                            system.debug('*****primary partner track 2' +idPtIdToUpdate);
                            // more than 1 record found
                             newPt.Partner_Track_Primary_Partner_Track_ID__c = '';
                             newPt.Partner_Track_Program_Group_Name__c = '';
                             newPt.Error__c = ' Duplicate Primary Audit Eligible Partner Track Types in Country';
                        }
                    }
                }
            //}
        }
}
    public void populatePrimaryPartnerTrackIdBatch(List<Partner_Track__c> listpt) {
        system.debug('listpt' +listpt);
        list<string> listAuditElgblePts = new list<string>(); 
        list<string> listPrimaryPts= new list<string>(); 
        list<string> listPartnerProgramTracks= new list<string>(); 
        map<id,partner_track__c> mapPtToProcess = new map<id,partner_track__c>();
        list<partner_track__c> listExstngPT = new list<partner_track__c> ();
        map<string,partner_track__c> mapMgIdToAuditElgblePts = new map<string,partner_track__c>();
        map<string,list<partner_track__c>> mapMgIdToExstngPts = new map<string,list<partner_track__c>>();
         integer inti = 0;
            id idPtIdToUpdate;
            string strNameToUpdate;
            string strPtNameToUpdate;
            string strPrimarySMPT;
            string strPartnerTrack;
        	string strPartnerProgramTrack;
        try{
        for(partner_track__c rec:listpt){
                  rec.Partner_Track_Primary_Partner_Track_ID__c = '';
                    rec.Partner_Track_Program_Group_Name__c = '';
                      rec.Error__c = '';
                  mapPtToProcess.put(rec.id,rec);
                  listPartnerProgramTracks.add(rec.Partner_Track_Name_Country__c);
            }
        if(mapPtToProcess.keySet().size() > 0){ 
            for(Partner_Program_Track__c eachRec : [select Partner_Track_Name__c,Primary_Partner_Track_Country__c from Partner_Program_Track__c where Audit_Track_Y_N__c = true and Partner_Track_Name__c in :listPartnerProgramTracks]){
                listAuditElgblePts.add(eachRec.Partner_Track_Name__c);
                listPrimaryPts.add(eachRec.Primary_Partner_Track_Country__c);
                system.debug('***listPrimaryPts' +listPrimaryPts);
            }
        }
        for(partner_track__c ptToProcess:mapPtToProcess.values()){
              if(mapPtToProcess.get(ptToProcess.id).Track_Name__c != null && listAuditElgblePts.contains(mapPtToProcess.get(ptToProcess.id).Partner_Track_Name_Country__c)){
                        mapMgIdToAuditElgblePts.put(mapPtToProcess.get(ptToProcess.id).Master_Group_Affinity_Id__c,mapPtToProcess.get(ptToProcess.id));
                        system.debug('***mapMgIdToAuditElgblePts' +mapMgIdToAuditElgblePts);
                }
         }
        if(mapMgIdToAuditElgblePts.keyset().size() > 0){
                    listExstngPT = [select id,Name,Master_Group_Affinity_Id__c,Partner_Track_Name_Country__c,Track_Name__c,Partner_Track__c,Primary_Sales_Motion_Affinity_ID__c from partner_track__c where Master_Group_Affinity_Id__c in :mapMgIdToAuditElgblePts.keyset()];
                    
                    for(partner_track__c exstngPT:listExstngPT){                          
                        if (mapMgIdToExstngPts.containsKey(exstngPT.Master_Group_Affinity_Id__c)){
                            mapMgIdToExstngPts.get(exstngPT.Master_Group_Affinity_Id__c).add(exstngPT);
                        }else{
                            mapMgIdToExstngPts.put(exstngPT.Master_Group_Affinity_Id__c, new  List <partner_track__c> { exstngPT });
                        }
                    }
            for(string strkey :mapMgIdToExstngPts.keyset()){
                        inti = 0;
                        for(partner_track__c value : mapMgIdToExstngPts.get(strkey)){
                            if(listPrimaryPts.contains(value.Partner_Track_Name_Country__c)){
                                idPtIdToUpdate = value.id;
                                strNameToUpdate = value.Name;
                                strPtNameToUpdate = value.Track_Name__c;
                                strPrimarySMPT = value.Primary_Sales_Motion_Affinity_ID__c;
                                strPartnerTrack = value.Partner_Track__c;
                                strPartnerProgramTrack = value.Track_Name__c;
                                system.debug('^^^PtIdToUpdate' +idPtIdToUpdate);
                                inti++;
                            }                         
                        }
                        Partner_Track__c newPt = mapMgIdToAuditElgblePts.get(strkey);
                        if(inti == 0){                            
                        system.debug('*****primary partner track 0'); 
                            // No matching records found
                            newPt.Partner_Track_Primary_Partner_Track_ID__c = '';
                            newPt.Partner_Track_Program_Group_Name__c = '';
                           newPt.Error__c = 'No Primary Audit Eligible Track in Country';
                        }else if(inti == 1){
                            newPt.Error__c = '';
                            system.debug('*****primary partner track 1');
                           // only 1 record found
                           newPt.Partner_Track_Primary_Partner_Track_ID__c = strNameToUpdate;
                            newPt.Partner_Track_Program_Group_Name__c = strPtNameToUpdate;
                                if(newPt.Partner_Track__c == 'Federal' && !newPt.Track_Name__c.contains('Federal')){
                                    newPt.Partner_Track_Primary_Partner_Track_ID__c = '';
                            	newPt.Partner_Track_Program_Group_Name__c = '';
                                newPt.Error__c = 'Partner Track & Partner Program Track Misaligned';
                                }
                             else if(newPt.Partner_Track__c == 'Distributor' && !newPt.Track_Name__c.contains('Distributor')){
                                    newPt.Partner_Track_Primary_Partner_Track_ID__c = '';
                            	newPt.Partner_Track_Program_Group_Name__c = '';
                                newPt.Error__c = 'Partner Track & Partner Program Track Misaligned';
                                }
                            else if(newPt.Partner_Track__c == 'Cloud Service Provider' && !newPt.Track_Name__c.contains('Cloud Service Provider')){
                                    newPt.Partner_Track_Primary_Partner_Track_ID__c = '';
                            	newPt.Partner_Track_Program_Group_Name__c = '';
                                newPt.Error__c = 'Partner Track & Partner Program Track Misaligned';
                                }
                            else if(newPt.Partner_Track__c == 'Systems Integrator' && !newPt.Track_Name__c.contains('Systems Integrator')){
                                    newPt.Partner_Track_Primary_Partner_Track_ID__c = '';
                            	newPt.Partner_Track_Program_Group_Name__c = '';
                                newPt.Error__c = 'Partner Track & Partner Program Track Misaligned';
                                }
                            else if(newPt.Partner_Track__c == 'Solution Provider' && !newPt.Track_Name__c.contains('Solution Provider')){
                                    newPt.Partner_Track_Primary_Partner_Track_ID__c = '';
                            	newPt.Partner_Track_Program_Group_Name__c = '';
                                newPt.Error__c = 'Partner Track & Partner Program Track Misaligned';
                                }
                                else if(newPt.Partner_Track__c == 'OEM' && newPt.Track_Name__c.Substring(5,newPt.Track_Name__c.length()) != 'OEM'){
                                    newPt.Partner_Track_Primary_Partner_Track_ID__c = '';
                            	newPt.Partner_Track_Program_Group_Name__c = '';
                                newPt.Error__c = 'Partner Track & Partner Program Track Misaligned';
                                }
                                /* newPt.Partner_Track_Primary_Partner_Track_ID__c = '';
                            	newPt.Partner_Track_Program_Group_Name__c = '';
                                newPt.Error__c = 'Partner Track & Partner Program Track Misaligned';*/
                            if(newPt.Error__c != 'Partner Track & Partner Program Track Misaligned'){
                            if(strPrimarySMPT == null || strPrimarySMPT == ''){
                                newPt.Error__c = 'Primary Audit Eligible Partner Track does not carry a Primary Sales Motion';
                            }
                            else{
                                newPt.Error__c = '';
                            }
                        }
                        }else{
                            system.debug('*****primary partner track 2' +idPtIdToUpdate);
                            // more than 1 record found
                             newPt.Partner_Track_Primary_Partner_Track_ID__c = '';
                             newPt.Partner_Track_Program_Group_Name__c = '';
                             newPt.Error__c = ' Duplicate Primary Audit Eligible Partner Track Types in Country';
                        }
                Database.update(newPt, false); 
                    }
        }
    }
        catch(exception e){
            system.debug('Exception occured in Batch_TRTUpdateonPT '+e.getMessage());
        }
    }   
}