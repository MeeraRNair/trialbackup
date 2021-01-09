public class RebateRequestProductTriggerCls{

// inserting TotalIntelDiscountRequested

  public static void insertPopualateTotalIntelDiscountRequested(List<Rebate_Request_Product__c> newtestList)
   {
      
    try {
       
        List<Alliance_Rebate_Request__c> rebateListToUpdate= new List<Alliance_Rebate_Request__c>();
        set<Id> rebateRequestIdsToProcess= new set<Id>();
        Map<Id,decimal> mapOfRebateRequestToIntel= new Map<Id,decimal>();
        List<Rebate_Request_Product__c> productRecToprocess= new List<Rebate_Request_Product__c>();
        for(Rebate_Request_Product__c prodrec:newtestList)
        {
           
          rebateRequestIdsToProcess.add(prodrec.Alliance_Rebate_Request__c);
          productRecToprocess.add(prodrec);
            
        }
        if(!rebateRequestIdsToProcess.isEmpty())
        {
            List<Alliance_Rebate_Request__c> rebatelist= new List<Alliance_Rebate_Request__c>();
            for(Alliance_Rebate_Request__c rebateObj:[select id,System_Partner_Name__c,Part_Requested__c,Client_Enterprise__c,Dell_Standard_CPU_Currency__c from Alliance_Rebate_Request__c where id in:rebateRequestIdsToProcess])
            {
              if(rebateObj.System_Partner_Name__c=='Intel' && rebateObj.Part_Requested__c=='CPU' && rebateObj.Client_Enterprise__c =='Enterprise' )
               {
                  mapOfRebateRequestToIntel.put(rebateObj.id,rebateObj.Dell_Standard_CPU_Currency__c ); 
               }
              }
          }
        
  // Map<ID,Alliance_Rebate_Request__c> all_Reb_Req= new Map<ID,Alliance_Rebate_Request__c>([select ID,System_Partner_Name__c,Part_Requested__c,Client_Enterprise__c from Alliance_Rebate_Request__c where ID IN:rebateRequestIdsToProcess AND System_Partner_Name__c='Intel' AND Part_Requested__c='CPU' AND Client_Enterprise__c ='Enterprise']);
        if(!productRecToprocess.isEmpty())
        {
            for(Rebate_Request_Product__c prodrec:productRecToprocess)
            {
            //if(all_Reb_Req.containsKey(prodrec.Alliance_Rebate_Request__c)) 
                if((mapOfRebateRequestToIntel.containsKey(prodrec.Alliance_Rebate_Request__c))&&mapOfRebateRequestToIntel.get(prodrec.Alliance_Rebate_Request__c)!=null)
                {
                    Alliance_Rebate_Request__c reqToUpdate= new Alliance_Rebate_Request__c();
                    reqToUpdate.id=prodrec.Alliance_Rebate_Request__c;
                    reqToUpdate.Total_Intel_discount_requested__c=Integer.valueof((mapOfRebateRequestToIntel.get(prodrec.Alliance_Rebate_Request__c)-(prodrec.Price_Requested__c*prodrec.Quantity__c)));
                    rebateListToUpdate.add(reqToUpdate);
                }
                
            
            }
            if(!rebateListToUpdate.isEmpty())
            {
                update rebateListToUpdate;
            }
        }
      }  catch(exception E) {}
        
      } 
   
   
   // Updating TotalIntelDiscountRequested
    
  public static void updatePopualateTotalIntelDiscountRequested(List<Rebate_Request_Product__c> newtestList,Map<id,Rebate_Request_Product__c> oldmaprec)
   {
     
    try{
     
        List<Alliance_Rebate_Request__c> rebateListToUpdate= new List<Alliance_Rebate_Request__c>();
        set<Id> rebateRequestIdsToProcess= new set<Id>();
        Map<Id,decimal> mapOfRebateRequestToIntel= new Map<Id,decimal>();
        List<Rebate_Request_Product__c> productRecToprocess= new List<Rebate_Request_Product__c>();
        for(Rebate_Request_Product__c prodrec:newtestList)
        {
            if((prodrec.Alliance_Rebate_Request__c!=oldmaprec.get(prodrec.id).Alliance_Rebate_Request__c) || (prodrec.Price_Requested__c!=oldmaprec.get(prodrec.id).Price_Requested__c) || (prodrec.Quantity__c!=oldmaprec.get(prodrec.id).Quantity__c))
            {
                rebateRequestIdsToProcess.add(prodrec.Alliance_Rebate_Request__c);
                productRecToprocess.add(prodrec);
            }
        }
        if(!rebateRequestIdsToProcess.isEmpty())
        {
            List<Alliance_Rebate_Request__c> rebatelist= new List<Alliance_Rebate_Request__c>();
            for(Alliance_Rebate_Request__c rebateObj:[select id,Dell_Standard_CPU_Currency__c,Part_Requested__c,Client_Enterprise__c, System_Partner_Name__c from Alliance_Rebate_Request__c where id in:rebateRequestIdsToProcess])
            {
              if(rebateObj.Part_Requested__c=='CPU' && rebateObj.Client_Enterprise__c=='Enterprise' && rebateObj.System_Partner_Name__c=='Intel' )
              {
              
                mapOfRebateRequestToIntel.put(rebateObj.id,rebateObj.Dell_Standard_CPU_Currency__c ); 
              }
            }
        }
        // Map<ID,Alliance_Rebate_Request__c> all_Reb_Req= new Map<ID,Alliance_Rebate_Request__c>([select ID,System_Partner_Name__c,Part_Requested__c,Client_Enterprise__c from Alliance_Rebate_Request__c where ID IN:rebateRequestIdsToProcess AND System_Partner_Name__c='Intel' AND Part_Requested__c='CPU' AND Client_Enterprise__c ='Enterprise']);
        if(!productRecToprocess.isEmpty())
        {
            for(Rebate_Request_Product__c prodrec:productRecToprocess)
            { 
            // if(all_Reb_Req.containsKey(prodrec.Alliance_Rebate_Request__c)) 
              
                if((mapOfRebateRequestToIntel.containsKey(prodrec.Alliance_Rebate_Request__c))&&mapOfRebateRequestToIntel.get(prodrec.Alliance_Rebate_Request__c)!=null)
                {
                    Alliance_Rebate_Request__c reqToUpdate= new Alliance_Rebate_Request__c();
                    reqToUpdate.id=prodrec.Alliance_Rebate_Request__c;
                    reqToUpdate.Total_Intel_discount_requested__c=Integer.valueof((mapOfRebateRequestToIntel.get(prodrec.Alliance_Rebate_Request__c)-(prodrec.Price_Requested__c*prodrec.Quantity__c)));
                    rebateListToUpdate.add(reqToUpdate);
                }
                if(oldmaprec.containsKey(prodrec.id) && prodrec.Alliance_Rebate_Request__c!=oldmaprec.get(prodrec.id).Alliance_Rebate_Request__c && oldmaprec.get(prodrec.id).Alliance_Rebate_Request__c!=null)
                {
                    Alliance_Rebate_Request__c reqToUpdate= new Alliance_Rebate_Request__c();
                    reqToUpdate.id=oldmaprec.get(prodrec.id).Alliance_Rebate_Request__c;
                    reqToUpdate.Total_Intel_discount_requested__c=null;
                    rebateListToUpdate.add(reqToUpdate);
                }
            
          }
            if(!rebateListToUpdate.isEmpty())
            {
                system.debug('=======+'+rebateListToUpdate);
                update rebateListToUpdate;
            }
        }
        
       } catch(exception E) {}
    }
    
    public static void updateAllianceStatusToExpired(List<Rebate_Request_Product__c> newtestList,Map<id,Rebate_Request_Product__c> oldmaprec){
        try{
            set<Id> allianceProdIds = new set<Id>();
            for(Rebate_Request_Product__c prodrec:newtestList){
                If( oldmaprec.get(prodrec.Id).Status__c != prodrec.Status__c && prodrec.Status__c == 'Expired'){
                    allianceProdIds.add(prodrec.Alliance_Rebate_Request__c);
                }
            }
            
            System.debug('**Inside updateAllianceStatusToExpired: '+ allianceProdIds);
            map<Id, list<Rebate_Request_Product__c>> allianceProdMap = new map<Id, list<Rebate_Request_Product__c>>(); 
            If(allianceProdIds.size() > 0){
                for(Rebate_Request_Product__c rebateReqObj: [Select Id, Alliance_Rebate_Request__c, Status__c from Rebate_Request_Product__c Where Alliance_Rebate_Request__c IN: allianceProdIds] ){
                    List<Rebate_Request_Product__c> rebateReqList ;
                    If(allianceProdMap.get(rebateReqObj.Alliance_Rebate_Request__c) == NULL){
                        rebateReqList = new List<Rebate_Request_Product__c>();
                    }else{
                        rebateReqList = allianceProdMap.get(rebateReqObj.Alliance_Rebate_Request__c);
                    }
                    rebateReqList.add(rebateReqObj);
                    
                    allianceProdMap.put(rebateReqObj.Alliance_Rebate_Request__c, rebateReqList);
                }
                
                Set<Id> updateAllianceObjIds = new Set<Id>();
                
                for(Rebate_Request_Product__c prodrec: newtestList){
                    boolean isExpired = true;
                    for(Rebate_Request_Product__c prod: allianceProdMap.get(prodrec.Alliance_Rebate_Request__c) ){
                        If(prod.Status__c != 'Expired'){
                            isExpired = false;
                        }
                    } 
                    If(isExpired == true){
                        updateAllianceObjIds.add(prodrec.Alliance_Rebate_Request__c);
                    }
                }
                
                System.debug('****Update Alliance Obj List: '+ updateAllianceObjIds);
                Id devRecordTypeId = Schema.SObjectType.Alliance_Rebate_Request__c.getRecordTypeInfosByName().get('Old Approvals RT').getRecordTypeId();
                If(updateAllianceObjIds.size() > 0){
                    list<Alliance_Rebate_Request__c> updateALlianceObjList = new list<Alliance_Rebate_Request__c>();
                    for(Alliance_Rebate_Request__c allianceObj: [Select Id, Status__c from Alliance_Rebate_Request__c Where Id IN: updateAllianceObjIds and Status__c != 'Rejected' and RecordTypeId !=:devRecordTypeId ]){
                        allianceObj.Status__c = 'Expired';
                        updateALlianceObjList.add(allianceObj);
                    }
                    
                    update updateALlianceObjList;
                }
            }
        } catch(exception ex) {
            system.debug('exception message:'+ex.getMessage());
        }  
    }
}