public class VOAccountTriggerHandler {
    public static void afterUpdateHandler(List<Account> listNewAccount, Map<id,Account> mapOldAccount,Map<id,Account> mapNewAccount){
        set<Id> setAccountId= new set<id>();
        map<String,Id> mapAffinityId= new map<String,Id>(); //Added for CR 18382
        map<String,Id> mapUCID= new map<String,Id>();		//Added for CR 18382
        set<Id> setUserId= new set<id>();
        set<Id> setParentAccountId= new set<id>();
        set<Id> setRecordTypeId= new set<id>();
        Map<id,user> mapUser=new Map<id,user>();
        Map<id,account> mapAccount=new Map<id,account>();
        Map<id,RecordType> mapRecordType=new Map<id,RecordType>();
        List<VisitOps__Company__c> listCompany = new List<VisitOps__Company__c>();
        for(Account ac: listNewAccount){
            system.debug('+++++++++++++ old RegionName: '+ mapOldAccount.get(ac.id).Region_Name_lookup__c);
            system.debug('+++++++++++++ new RegionName: '+ ac.Region_Name_lookup__c);
            if(mapOldAccount.get(ac.id).Account_ID__c!=ac.Account_ID__c || mapOldAccount.get(ac.id).OwnerId!=ac.OwnerId || mapOldAccount.get(ac.id).Account_Executive_PDM__c!=ac.Account_Executive_PDM__c ||
               mapOldAccount.get(ac.id).ParentId!=ac.ParentId || mapOldAccount.get(ac.id).TickerSymbol!=ac.TickerSymbol || mapOldAccount.get(ac.id).Billing_Address_CN__c!=ac.Billing_Address_CN__c ||
               mapOldAccount.get(ac.id).Region_Name_lookup__c!=ac.Region_Name_lookup__c || mapOldAccount.get(ac.id).Account_Classification__c!=ac.Account_Classification__c  ||
               mapOldAccount.get(ac.id).Account_Country__c!=ac.Account_Country__c || mapOldAccount.get(ac.id).Region_Desc__c!=ac.Region_Desc__c || mapOldAccount.get(ac.id).Regional_Parent_Name_lookup__c!=ac.Regional_Parent_Name_lookup__c ||
               mapOldAccount.get(ac.id).Partner_Type__c!=ac.Partner_Type__c || mapOldAccount.get(ac.id).Partner_Relationship__c!=ac.Partner_Relationship__c || mapOldAccount.get(ac.id).RecordType!=ac.RecordType ||  
               mapOldAccount.get(ac.id).Segment_Business_Unit_Name__c!=ac.Segment_Business_Unit_Name__c || mapOldAccount.get(ac.id).Segment_Desc__c!=ac.Segment_Desc__c || mapOldAccount.get(ac.id).Segment_Name_lookup__c!=ac.Segment_Name_lookup__c ||
               mapOldAccount.get(ac.id).Global_Account_Indicator__c!=ac.Global_Account_Indicator__c || mapOldAccount.get(ac.id).recordtypeID!=ac.recordtypeID ||
               mapOldAccount.get(ac.id).Industry!=ac.Industry || mapOldAccount.get(ac.id).D_U_N_S__c!=ac.D_U_N_S__c || mapOldAccount.get(ac.id).Name!=ac.Name || mapOldAccount.get(ac.id).EMC_ID__c!=ac.EMC_ID__c){ 
                   setAccountId.add(ac.id);
                   //Added for CR 18382
                   if(ac.Account_ID__c!=null){
                       mapAffinityId.put(ac.Account_ID__c,ac.id);
                   }
                   if(ac.EMC_Id__c!=null){   
                       mapUCID.put(ac.EMC_Id__c,ac.id);
                   }
                   system.debug('*************** inside setAccountId');
               }
            system.debug('************ setAccountId: '+setAccountId);
            if(mapOldAccount.get(ac.id).OwnerId!=ac.OwnerId ){ 
                setUserId.add(ac.OwnerId);
            }
            if(mapOldAccount.get(ac.id).Account_Executive_PDM__c!=ac.Account_Executive_PDM__c){
                setUserId.add(ac.Account_Executive_PDM__c);
            }
            if(mapOldAccount.get(ac.id).ParentId!=ac.ParentId ){ 
                setParentAccountId.add(ac.ParentId);
            }
            if(mapOldAccount.get(ac.id).ParentId!=ac.ParentId ){ 
                setParentAccountId.add(ac.ParentId);
            }
            if(mapOldAccount.get(ac.id).recordtypeID!=ac.recordtypeID){ 
                setRecordTypeId.add(ac.recordtypeID);
            }
        } 
        if(!setParentAccountId.isEmpty()){
            mapAccount=new map<id,account>([select name from account where id in:setParentAccountId]);
        }
        if(!setUserId.isEmpty()){
            mapUser=new map<id,user>([select name,email from user where id in:setUserId]);
        }
        if(!setRecordTypeId.isEmpty()){
            mapRecordType=new map<id,RecordType>([select name from RecordType where id in:setRecordTypeId]);
        }
        //Added for CR 18382
        if((setAccountId !=null && ! setAccountId.IsEmpty())||(mapAffinityId !=null && ! mapAffinityId.keyset().IsEmpty())||(mapUCID !=null && ! mapUCID.keyset().IsEmpty())){
        Map<Id,VisitOps__Company__c> mapCompany = new Map<ID,VisitOps__Company__c>([Select VO_Affinity_ID__c,VO_SFDC_Account_ID__c,VO_Account_Executive_Name__c,
                                                                                    VO_Account_Executive_Email__c,VO_Parent_Account__c,VisitOps__Ticker_Symbol__c,VO_Address__c,VO_Account_Region_District__c,VO_Account_Classification__c,
                                                                                    VO_Account_DUNS_Number__c,VO_Account_Country__c,VO_Account_Region_Division__c,VO_Account_Theater__c,VO_Partner_Type__c,
                                                                                    VO_Partner_Relationship__c,VisitOps__Account_Type__c,VO_Account_Segment_Business_Unit__c,VO_Account_Segment_Desc__c,
                                                                                    VisitOps__Account__c,VO_Account_Segment_Name__c,VO_Global_Account__c,VO_UCID__c from VisitOps__Company__c 
                                                                                    where VisitOps__Account__c in:setAccountId OR VO_Affinity_ID__c in :mapAffinityId.keyset() OR VO_UCID__c in :mapUCID.keyset()]);
        
        for(VisitOps__Company__c company : mapCompany.values()){
            system.debug('*************** inside VOAccountTrigger');
            //Added for CR 18382
            if(company.VisitOps__Account__c == null && company.VO_Affinity_ID__c != null){
                company.VisitOps__Account__c = mapAffinityId.get(company.VO_Affinity_ID__c);
            }
            if(company.VisitOps__Account__c == null && company.VO_UCID__c != null){
                company.VisitOps__Account__c = mapUCID.get(company.VO_UCID__c);
            }
            if(company.VisitOps__Account__c != null){
                Account acc = mapNewAccount.get(company.VisitOps__Account__c);
                company.VO_Affinity_ID__c = acc.Account_ID__c;
                if(mapUser.ContainsKey(acc.OwnerId)){
                    company.VisitOps__VO_Account_Owner__c = mapUser.get(acc.OwnerId).Name;
                    company.VO_Account_Owner_Email__c = mapUser.get(acc.OwnerId).email;
                }
                if(mapAccount.ContainsKey(acc.ParentId)){
                    company.VO_Parent_Account__c = mapAccount.get(acc.ParentId).Name;
                }
                if(mapUser.ContainsKey(acc.Account_Executive_PDM__c)){
                    company.VO_Account_Executive_Name__c = mapUser.get(acc.Account_Executive_PDM__c).Name;
                    company.VO_Account_Executive_Email__c = mapUser.get(acc.Account_Executive_PDM__c).Email;
                }
                if(mapRecordType.ContainsKey(acc.recordtypeID)){
                    company.VisitOps__Account_Type__c = mapRecordType.get(acc.recordtypeID).Name;
                }
                //company.VO_Account_Owner__c = acc.Owner.Name;
                //company.VO_Account_Owner_Email = acc.Website;
                //company.VO_Account_Executive_Name__c = acc.Account_Executive_PDM__r.Name;
                //company.VO_Account_Executive_Email__c = acc.Account_Executive_PDM__r.Email;
                //company.VO_Parent_Account__c = acc.Parent.Name;
                company.VisitOps__Ticker_Symbol__c = acc.TickerSymbol;
                if(acc.Billing_Address_CN__c!=null){
                    company.VO_Address__c = acc.Billing_Address_CN__c.replace('<br>',' ');
                }
                company.VO_Account_Region_District__c = acc.Region_Name_lookup__c; // CR 16455 replace acc.Dell_Region_Name__c;
                company.VO_Account_Classification__c = acc.Account_Classification__c;
                company.VO_Account_DUNS_Number__c = acc.D_U_N_S__c;
                company.VO_Account_Country__c = acc.Account_Country__c;
                company.VO_Account_Region_Division__c = acc.Region_Desc__c;
                company.VO_Account_Theater__c = acc.Regional_Parent_Name_lookup__c;
                company.VO_Partner_Type__c = acc.Partner_Type__c;
                company.VO_Partner_Relationship__c = acc.Partner_Relationship__c;
                //company.VisitOps__Account_Type__c = acc.RecordType.Name;
                company.VO_Account_Segment_Business_Unit__c = acc.Segment_Business_Unit_Name__c;
                company.VO_Account_Segment_Desc__c = acc.Segment_Desc__c;
                company.VO_Account_Segment_Name__c = acc.Segment_Name_lookup__c;
                company.VO_Global_Account__c = acc.Global_Account_Indicator__c;
                company.VO_UCID__c = acc.EMC_ID__c;
                listCompany.add(company);
            } 
            system.debug('*************** VoAcc Region : '+company.VO_Account_Region_District__c);   
        }
        
        if(!listCompany.isEmpty()){
            update listCompany;
        }
        
        
        /*
            Ticket : I-0338
            Date : 08 April 2019
            DS : If Account will updated then their related "Visit Bundle" record will also updated.
        */
        List<VisitOps__VisitBundle__c > listVisitBundleList = [Select Id from VisitOps__VisitBundle__c where VisitOps__opportunity__r.AccountId !=null and VisitOps__opportunity__r.AccountId in:setAccountId];                                                
        If(listVisitBundleList!=null && listVisitBundleList.size()>0){
            VOVisitBundleTriggerHandler.bIsUpdatedVisitBundle =  true;
            update listVisitBundleList;
            VOVisitBundleTriggerHandler.bIsUpdatedVisitBundle =  false;
        }
      }  
    }
    //Added for CR 18382
    public static void afterInsertHandler(List<Account> listNewAccount,Map<id,Account> mapNewAccount){
        map<String,Id> mapAffinityId= new map<String,Id>();  
        map<String,Id> mapUCID= new map<String,Id>();
        for(Account ac: listNewAccount){
            if(ac.Account_ID__c!=null){
        		mapAffinityId.put(ac.Account_ID__c,ac.id);
            }
            if(ac.EMC_Id__c!=null){   
                mapUCID.put(ac.EMC_Id__c,ac.id);
            }
        }
        Map<Id,VisitOps__Company__c> mapCompany = new Map<ID,VisitOps__Company__c>([Select VO_Affinity_ID__c,VisitOps__Account__c,VO_UCID__c from VisitOps__Company__c 
                                                                                    where VO_Affinity_ID__c in :mapAffinityId.keyset() OR VO_UCID__c in :mapUCID.keyset()]);
        if(mapCompany.values() != null && !mapCompany.values().isEmpty()){
            for(VisitOps__Company__c company : mapCompany.values()){
                if(company.VisitOps__Account__c == null && company.VO_Affinity_ID__c != null){
                    company.VisitOps__Account__c = mapAffinityId.get(company.VO_Affinity_ID__c);
                }
                if(company.VisitOps__Account__c == null && company.VO_UCID__c != null){
                	company.VisitOps__Account__c = mapUCID.get(company.VO_UCID__c);
            	}
            }
            try{
                update mapCompany.values();
            }
            catch(Exception e){
                System.debug('Error in VOAccountTriggerInsert');
                System.debug(e.getMessage()+' '+e.getStackTraceString());
            }
        }
        
    }
}