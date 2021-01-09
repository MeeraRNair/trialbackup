/*
 * Author   : Micky
 * Purpose  : Class to hold functionalities for auto populating Opportunity Line Item Revenue Schedule 
 *        
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR10616     16.03            24-Jan-2015     Micky           Created for implementing "Centralized by Org" trigger architecture - Best practices
 * 2.0      13693       FY17-DCS-0103    01-Nov-2016     Sajith          Introduced Sales Follow Up days calculation logic during lead conversion
 * 3.0      7729814     FY20-DEC-1201    29-Nov-2019     Monisha         101 soql issue 
 * -------- ---------   ----------  -----------     ------------    -----------------------------------------------------------------------------------
 * Please DO NOT add revision history in the class level, instead add it in the corresponding methods. 
 */
 
public class OpportunityLineItemRevenueSchedule {
    /*
    Revision    CR Number   Release No      Date            Modified By     Description
    --------    ---------   ----------      -----------     ------------    -----------
    1.0         CR10616     16.03           24-Jan-2015     Micky Toms       When an Opportunity is created with Book Date and Contract Term not null, autopopulate the Revenue Schedule
                                                                             If the contract term changed from a value to a blank, delete all the existing Revenue Schedules
    2.0         CR11402     16.04(Minor)    20-Apr-2015     Krishnamoorthi   To Prevent Deltek Opportunities from Revenue Scheduling by trigger
    3.0         CR11748     16.07           24-July-2015    Krishnamoorthi   Story 184587:RTB - PROD Defect FIX : SAR-12366 -- To allow only Standard Opportunity Record Type for scheduling via code if Book Date and Contract Term not null        
    4.0         CR14291     FY18-DCS-0602   3-May-2017      SuiYee           Remove DeltekOppID__c for Seal Project
    5.0         CR15930     FY19-0703       07-Jun-2018     Akshita          Removed Commented lines and, system.debug statements as part of Opportunity code reduce story
    */
    
    public static void populateRevenuSchedules(List<Opportunity> lstOpportunitiesnewvalues,map<Id, Opportunity> mapOldOpportunities,map<Id, Opportunity> mapNewOpportunities) {
    
        Set <Id> setallOppIds= new Set<Id>();
        Set <Id> setallOppItemIds= new Set<Id>();
        Set <Id> setallOpplnItemSchId= new Set<Id>();
        setallOppIds=mapOldOpportunities.keySet();
        map<Id, List<OpportunityLineItem>> mapOppLineItem = new map<Id, List<OpportunityLineItem>>();
        map<Id, List<OpportunityLineItemSchedule>> mapOppLineItemsch = new map<Id, List<OpportunityLineItemSchedule>>();
        List<OpportunityLineItemSchedule> lstOppLineItemSch=new List<OpportunityLineItemSchedule>();
        List<OpportunityLineItemSchedule> lstOppLineItemcalc=new List<OpportunityLineItemSchedule>();
        List <OpportunityLineItemSchedule> opplineList;
        List<OpportunityLineItem> lstOpplnItemsforOpp=new List<OpportunityLineItem>();
        List<OpportunityLineItem> lstOpplnItemsUpdateforOpp=new List<OpportunityLineItem>();
        List<OpportunityLineItemSchedule> lstOppLineItemSchforDel=new List<OpportunityLineItemSchedule>();
        List<OpportunityLineItemSchedule> lstOppLineItemSchforDelFinal=new List<OpportunityLineItemSchedule>();
        List<OpportunityLineItemSchedule> lstOppLineItemSchAftDel=new List<OpportunityLineItemSchedule>();
        Id standardOppRTId = StaticFactory.getRecordTypeIdByName('Opportunity', 'Standard Opportunity');//v3.0        

        Decimal monthlyamt=0;
        Opportunity lstOldValues=new Opportunity(); 
        Opportunity lstNewValues=new Opportunity();
        //v3.0 - Added RecordTypeId check
        for(Opportunity oppIterator : [SELECT Id, RecordTypeId, (SELECT Id,Quantity,UnitPrice,TotalPrice,OpportunityId FROM OpportunityLineItems ) 
                                       FROM Opportunity WHERE Id IN :setallOppIds AND RecordTypeId =: standardOppRTId]) { //v3.0 - Added RecordTypeId check
            list<OpportunityLineItem> lstLineItems = oppIterator.OpportunityLineItems;
            if(lstLineItems != null && !lstLineItems.isEmpty()){
                mapOppLineItem.put(oppIterator.Id, lstLineItems);
            }
            for(OpportunityLineItem opplineItems:lstLineItems){
                setallOppItemIds.add(opplineItems.Id);
            }
        }
        if(setallOppItemIds != null && !setallOppItemIds.IsEmpty()){
        lstOppLineItemSch=[select Id, Quantity, Revenue, OpportunityLineItemId 
                                       from OpportunityLineItemSchedule  where OpportunityLineItemId in :setallOppItemIds];
               for(Id uniqueitemId:setallOppItemIds){
                   opplineList=new List <OpportunityLineItemSchedule>();
                   for(OpportunityLineItemSchedule opplnitmSch:lstOppLineItemSch){
                    
                   if(uniqueitemId==opplnitmSch.OpportunityLineItemId){
                       OpportunityLineItemSchedule opplnitem=new OpportunityLineItemSchedule ();
                       opplnitem.id=opplnitmSch.id;
                       opplnitem.Quantity=opplnitmSch.Quantity;
                       opplnitem.Revenue=opplnitmSch.Revenue;
                       opplineList.add(opplnitem);
                   }
                 }
                 if(opplineList!= null && !opplineList.isEmpty()){
                     mapOppLineItemsch.put(uniqueitemId,opplineList);
                     
                 }
               } 
                }              
               for(Id oppIdonebyone:setallOppIds){
                   lstOldValues=mapOldOpportunities.get(oppIdonebyone);
                   lstNewValues=mapNewOpportunities.get(oppIdonebyone);
                   
                   //v2.0 - Exclude Deltek Opportunities from Reveneue scheduling
                   //v4.0 - Remove DeltekOppID__c condition
                   //**Condition for creating the new list of custom code created Revenue Schedule List//**
                       If((lstNewValues.Contract_Term__c!=null && lstNewValues.CloseDate!=null) && ((lstNewValues.Contract_Term__c!=lstOldValues.Contract_Term__c) || (lstNewValues.CloseDate!=lstOldValues.CloseDate))) {
                           lstOpplnItemsforOpp=mapOppLineItem.get(oppIdonebyone);
                           if(lstOpplnItemsforOpp<>null){
                           for(OpportunityLineItem lnitemsforOpp : lstOpplnItemsforOpp){
                               monthlyamt=Math.Floor(lnitemsforOpp.TotalPrice/ lstNewValues.Contract_Term__c);  
                               
                             for (integer i=0;i<lstNewValues.Contract_Term__c;i++){
                                 OpportunityLineItemSchedule opplnItmschcreate=new OpportunityLineItemSchedule();
                                 if(i== (lstNewValues.Contract_Term__c-1)){
                                 opplnItmschcreate.OpportunityLineItemId= lnitemsforOpp.id;
                                 opplnItmschcreate.Type='Revenue';
                                 opplnItmschcreate.ScheduleDate=lstNewValues.CloseDate.addMonths(i);
                                 opplnItmschcreate.Revenue = Integer.ValueOf(lnitemsforOpp.TotalPrice) - Integer.ValueOf((lstNewValues.Contract_Term__c -1)*monthlyamt);
                                 lstOppLineItemcalc.add(opplnItmschcreate);
                             }  
                             Else{
                                opplnItmschcreate.OpportunityLineItemId= lnitemsforOpp.id;
                                opplnItmschcreate.Type='Revenue';
                                opplnItmschcreate.ScheduleDate=lstNewValues.CloseDate.addMonths(i);
                                opplnItmschcreate.Revenue = monthlyamt;
                                lstOppLineItemcalc.add(opplnItmschcreate);
                                }
                    
                              }
                           }
                         }
                       }
                       //**Condition for creating the list of Line Items to Update later//**
                       If(((lstNewValues.Contract_Term__c!=null && lstNewValues.CloseDate!=null) && ((lstNewValues.Contract_Term__c!=lstOldValues.Contract_Term__c) || (lstNewValues.CloseDate!=lstOldValues.CloseDate))) 
                       || (lstNewValues.Contract_Term__c==null && lstNewValues.Contract_Term__c!=lstOldValues.Contract_Term__c)) {
                           lstOpplnItemsforOpp=mapOppLineItem.get(oppIdonebyone);
                           if(lstOpplnItemsforOpp<>null){
                               for(OpportunityLineItem lnitemsforOppforupdate:lstOpplnItemsforOpp){
                                   OpportunityLineItem opplnItmcreate=new OpportunityLineItem();
                                   opplnItmcreate.id=lnitemsforOppforupdate.id;
                                   opplnItmcreate.Quantity=lnitemsforOppforupdate.Quantity;
                                   opplnItmcreate.UnitPrice=lnitemsforOppforupdate.UnitPrice;
                                   lstOpplnItemsUpdateforOpp.add(opplnItmcreate);
                               }
                           }
                       }
                       //**Condition for creating the list of Line Items Scheduled to Delete later//**
                       If(((lstNewValues.Contract_Term__c!=null && lstNewValues.CloseDate!=null) && ((lstNewValues.Contract_Term__c!=lstOldValues.Contract_Term__c) || (lstNewValues.CloseDate!=lstOldValues.CloseDate))) 
                       || (lstNewValues.Contract_Term__c==null && lstNewValues.Contract_Term__c!=lstOldValues.Contract_Term__c)) {
                           lstOpplnItemsforOpp=mapOppLineItem.get(oppIdonebyone);
                           if(lstOpplnItemsforOpp<>null){
                           for(OpportunityLineItem lnitemsforOppfordelete:lstOpplnItemsforOpp){
                               lstOppLineItemSchforDel=mapOppLineItemsch.get(lnitemsforOppfordelete.id);
                               if(lstOppLineItemSchforDel!= null && !lstOppLineItemSchforDel.isEmpty()){
                                   for(OpportunityLineItemSchedule schfordel:lstOppLineItemSchforDel){
                                       OpportunityLineItemSchedule opplnitemschfordel=new OpportunityLineItemSchedule();
                                       opplnitemschfordel.id=schfordel.id;
                                       opplnitemschfordel.Quantity=schfordel.Quantity;
                                       opplnitemschfordel.Revenue=schfordel.Revenue;
                                       lstOppLineItemSchforDelFinal.add(opplnitemschfordel);
                                   }
                                }  
                            }
                    }
                }
            }
               
               //**Deleting the existing schedule,Updating the Line Items Quantity and Unit Price and Inserting new custom code generated schedule//**
               setSkipTriggers(true);
               if(lstOppLineItemSchforDelFinal!= null && !lstOppLineItemSchforDelFinal.isEmpty()){
                   delete lstOppLineItemSchforDelFinal;
               }
               
                for(Id oppIdonebyone:setallOppIds){
                   lstOldValues=mapOldOpportunities.get(oppIdonebyone);
                   lstNewValues=mapNewOpportunities.get(oppIdonebyone);
                   
                   //v2.0 - Exclude Deltek Opportunities
                   //v4.0 - Remove DeltekOppID__c condition
                       //v3.0 - Delete the scheduling only if Contract_Term__c field is null in either old or new Opportunity
                       If((lstNewValues.RecordTypeId == standardOppRTId) && (((lstNewValues.Contract_Term__c!=null && lstNewValues.CloseDate!=null) && ((lstNewValues.Contract_Term__c!=lstOldValues.Contract_Term__c) || (lstNewValues.CloseDate!=lstOldValues.CloseDate))) 
                        || (lstNewValues.Contract_Term__c==null && lstNewValues.Contract_Term__c!=lstOldValues.Contract_Term__c))) { //v3.0
                           
                           setallOpplnItemSchId.add(oppIdonebyone);
                       }
                   //v4.0}
                } 
                if(setallOpplnItemSchId!= null && !setallOpplnItemSchId.isEmpty()){
                lstOppLineItemSchAftDel=[Select id,OpportunityLineItem.OpportunityId from OpportunityLineItemSchedule 
                where OpportunityLineItem.OpportunityId in :setallOpplnItemSchId];  
                }
               if(lstOppLineItemSchAftDel!= null && !lstOppLineItemSchAftDel.isEmpty()){
                   delete lstOppLineItemSchAftDel;
               }
               if(lstOpplnItemsUpdateforOpp!= null && !lstOpplnItemsUpdateforOpp.isEmpty()){
                   update lstOpplnItemsUpdateforOpp;
               }
               if(lstOppLineItemcalc!= null && !lstOppLineItemcalc.isEmpty()){
                   insert lstOppLineItemcalc;
               }
               setSkipTriggers(false);
        }
        
        private static void setSkipTriggers(Boolean bValue) {
            TriggerExecutionController.setSkipOpportunityLineItemTriggers(bValue);
            TriggerExecutionController.setSkipOpportunityTriggers(bValue);
            //3.0 part of 101 soql fix
            TriggerExecutionController.setSkipAllTriggers(bValue);
        }

         /*
    Revision    CR Number   Release No    Date            Modified By     Description
    --------    ---------   ----------    -----------     ------------    -----------
    1.0         CR10616                   25-Jan-2015     Micky           To insert the Opportunity Line Item Schedule details when a new OpportunityLineItem is added
    2.0         CR11402     16.04(Minor)  20-Apr-2015     Krishnamoorthi  To Prevent Deltek Opportunities from Revenue Scheduling by trigger 
    3.0         CR11748     16.07         24-July-2015    Krishnamoorthi  Story 184587:RTB - PROD Defect FIX : SAR-12366 -- To allow only Standard Opportunity Record Type for scheduling via code if Book Date and Contract Term not null
    4.0         CR14291     FY18-DCS-0602 3-May-2017      SuiYee          Remove DeltekOppID__c for Seal Project
    */
    public static void populateOpportunityLineItemSchedule(map<Id, OpportunityLineItem> mapOpportunityLineItem) {
        
        Set <Id> setallOppLineItemIds= new Set<Id>();
        Set <Id> setallparProdIds= new Set<Id>();
        Set <Id> setallnewOppProdIds= new Set<Id>();
        Decimal monthlyamt=0;
        boolean clonedprodwithschedule=false;
        List <OpportunityLineItemSchedule> opplineList=new List <OpportunityLineItemSchedule>();
        List <OpportunityLineItemSchedule> oppListSchexisting=new List <OpportunityLineItemSchedule>();
        setallOppLineItemIds=mapOpportunityLineItem.keySet();
        map<Id, String> mapClonedParentId = new map<Id, String>();
        map<Id, String> mapProductId = new map<Id, String>();
        map<Id, Date> mapClosedDate = new map<Id, Date>();
        map<Id, Decimal> mapContractTerm = new map<Id, Decimal>();
        map<Id, List<OpportunityLineItemSchedule>> mapOppLineItemsch = new map<Id, List<OpportunityLineItemSchedule>>();
        String ClonedParentId,ProductId;
        Date ClosedDate;
        Decimal ContractTerm;
        List <OpportunityLineItem> opplineItemList=new List <OpportunityLineItem>();
        List<OpportunityLineItem> oppprodSchedule=new List <OpportunityLineItem>();
        List<OpportunityLineItem> oppprodListParentOpp=new List <OpportunityLineItem>();
        Set<Id> clonedParentIdSet = new Set<Id>(); // Fenny added
        Set<Id> productIdSet = new Set<Id>(); // Fenny added
        //v4.0 map<Id, String> mapDeltekOppID = new map<Id, String>(); //v2.0
        Id standardOppRTId = StaticFactory.getRecordTypeIdByName('Opportunity', 'Standard Opportunity');//v3.0
        
        OpportunityLineItem lstlnItemValues=new OpportunityLineItem ();
        
        //v2.0 Added the Opportunity field DeltekOppID__c
        //v3.0 - Added RecordTypeId check
        //v4.0 - Remove at select statements o.Opportunity.DeltekOppID__c,
        opplineItemList=[SELECT id,Scheduled_Opportunity_Product__c,Product2Id,o.Opportunity.Cloned_Parent_Id__c, o.Opportunity.Oppty_Self_Id__c,o.Opportunity.Contract_Term__c, o.Opportunity.CloseDate, o.OpportunityId, o.Opportunity.RecordTypeId FROM 
                        OpportunityLineItem o WHERE Id IN :setallOppLineItemIds AND o.Opportunity.RecordTypeId =: standardOppRTId];
        for(OpportunityLineItem lnitemopp:opplineItemList){
            mapClonedParentId.put(lnitemopp.id,lnitemopp.Opportunity.Cloned_Parent_Id__c);
            mapClosedDate.put(lnitemopp.id,lnitemopp.Opportunity.CloseDate);
            mapContractTerm.put(lnitemopp.id,lnitemopp.Opportunity.Contract_Term__c);
            mapProductId.put(lnitemopp.id,lnitemopp.Product2Id);
            setallnewOppProdIds.add(lnitemopp.Product2Id);
            clonedParentIdSet.add(lnitemopp.Opportunity.Cloned_Parent_Id__c); // Fenny added
            productIdSet.add(lnitemopp.Product2Id); // Fenny added
            //v4.0
            //mapDeltekOppID.put(lnitemopp.id,lnitemopp.Opportunity.DeltekOppID__c); //v2.0
        }
        // Fenny: start
        Map<string, boolean> parentOpptyScheduleMap = new Map<string, boolean>();
        for(OpportunityLineItemSchedule sch : [SELECT Id, OpportunityLineItem.OpportunityId,  
                                                OpportunityLineItem.Product2Id 
                                                FROM OpportunityLineItemSchedule 
                                                WHERE opportunitylineitemid IN (SELECT id FROM OpportunityLineItem 
                                                                                WHERE Product2Id IN :productIdSet
                                                                                AND OpportunityId =:clonedParentIdSet)]){
            parentOpptyScheduleMap.put(((String)sch.OpportunityLineItem.OpportunityId).substring(0,15)+'_'+sch.OpportunityLineItem.Product2Id, true);
        }
        // Fenny: end
        oppprodListParentOpp=[Select id,Product2Id from OpportunityLineItem where OpportunityId =:clonedParentIdSet];
        for(OpportunityLineItem lnitemparprod:oppprodListParentOpp){
            setallparProdIds.add(lnitemparprod.Product2Id);     
        }
        for(Id opplnItemIdonebyone:setallOppLineItemIds){  
        
            //v2.0 -- Added the if condition to check DeltekOppID__c is blank
            //v4.0 -- Remove DeltekOppID__c for Seal Project
                lstlnItemValues=mapOpportunityLineItem.get(opplnItemIdonebyone);
                ClonedParentId=mapClonedParentId.get(opplnItemIdonebyone);
                ClosedDate=mapClosedDate.get(opplnItemIdonebyone);
                ContractTerm=mapContractTerm.get(opplnItemIdonebyone);
                ProductId=mapProductId.get(opplnItemIdonebyone);
                if(ClonedParentId!=null){
                  clonedprodwithschedule=parentOpptyScheduleMap.get(ClonedParentId+'_'+ProductId);
                  if(clonedprodwithschedule==null){
                      clonedprodwithschedule=false;
                  }
                  if((setallparProdIds.equals(setallnewOppProdIds) && parentOpptyScheduleMap.get(ClonedParentId+'_'+ProductId)!=null)){
                      clonedprodwithschedule=true;
                  }
                  else if(!(setallparProdIds.equals(setallnewOppProdIds) && parentOpptyScheduleMap.get(ClonedParentId+'_'+ProductId)!=true)){
                      clonedprodwithschedule=false;
                  }
                }
                
                if(clonedprodwithschedule==false || ClonedParentId==null){
                   If(ContractTerm!=null && ClosedDate!=null){
                     monthlyamt=Math.Floor(lstlnItemValues.TotalPrice/ ContractTerm);
                     OpportunityLineItem oppprodSch=new OpportunityLineItem();
                     oppprodSch.id=opplnItemIdonebyone;
                     oppprodSch.Scheduled_Opportunity_Product__c=true;
                     oppprodSchedule.add(oppprodSch);
     
                         for (integer l=0;l<ContractTerm;l++){
                            OpportunityLineItemSchedule opplnitemSch=new OpportunityLineItemSchedule();
                            
                            opplnitemSch.OpportunityLineItemId= lstlnItemValues.id;
                            opplnitemSch.Type='Revenue';
                            opplnitemSch.ScheduleDate= ClosedDate.addMonths(l);
                            if(l== (ContractTerm-1)){
                                opplnitemSch.Revenue=  Integer.ValueOf(lstlnItemValues.TotalPrice) - Integer.ValueOf((ContractTerm -1)*monthlyamt);
                            }
                            else{
                                opplnitemSch.Revenue=monthlyamt;
                            }
                            opplineList.add(opplnitemSch);
                      }
               }
            }                       
            clonedprodwithschedule=false;
          //v4.0}  
        } 
        if(opplineList!= null && !opplineList.isEmpty()){
                   setSkipTriggers(true);
                   insert opplineList;
                   update oppprodSchedule;
                   setSkipTriggers(false);
        }
              
    }
    
    /*
    Revision    CR Number   Release No    Date            Modified By     Description
    --------    ---------   ----------    -----------     ------------    -----------
    1.0         CR10616                   25-Jan-2015     Micky           To update the Opportunity Line Item Schedule details when an OpportunityLineItem is updated
    2.0         CR11402     16.04(Minor)  20-Apr-2015     Krishnamoorthi  To Prevent Deltek Opportunities from Revenue Scheduling by trigger   
    3.0         CR11748     16.07         24-July-2015    Krishnamoorthi  Story 184587:RTB - PROD Defect FIX : SAR-12366 -- To allow only Standard Opportunity Record Type for scheduling via code if Book Date and Contract Term not null
    4.0         CR14291     FY18-DCS-0602 3-May-2017      SuiYee          Remove DeltekOppID__c for Seal Project
    */
    public static void updateOpportunityLineItemSchedule(map<Id, OpportunityLineItem> mapNewOpportunityLineItem,map<Id, OpportunityLineItem> mapOldOpportunityLineItem) {
        Set <Id> setallOppLineItemIds= new Set<Id>();
        Decimal monthlyamt=0;
        boolean clonedprodwithschedule=false;
        boolean clonedprodwithsystemscheduleexists;
        List <OpportunityLineItemSchedule> opplineListforupdate=new List <OpportunityLineItemSchedule>();
        List <OpportunityLineItemSchedule> oppListSchexisting=new List <OpportunityLineItemSchedule>();
        List <OpportunityLineItemSchedule> oppListSchTypeBoth=new List <OpportunityLineItemSchedule>();
        List <OpportunityLineItem> oppLnItemlistNew=new List <OpportunityLineItem>();
        setallOppLineItemIds=mapNewOpportunityLineItem.keySet();
        map<Id, List<OpportunityLineItemSchedule>> mapOppLineItemSch = new map<Id, List<OpportunityLineItemSchedule>>();
        map<Id, String> mapClonedParentId = new map<Id, String>();
        map<Id, Date> mapClosedDate = new map<Id, Date>();
        map<Id, Decimal> mapContractTerm = new map<Id, Decimal>();
        OpportunityLineItem lstlnItemNewValues=new OpportunityLineItem ();
        OpportunityLineItem lstlnItemOldValues=new OpportunityLineItem ();
        String ClonedParentId;
        Date ClosedDate;
        Decimal ContractTerm;
        List <OpportunityLineItem> opplineItemList=new List <OpportunityLineItem>();
        OpportunityLineItem lstlnItemValues=new OpportunityLineItem ();
        //v4.0 map<Id, String> mapDeltekOppID = new map<Id, String>(); //v2.0
        Id standardOppRTId = StaticFactory.getRecordTypeIdByName('Opportunity', 'Standard Opportunity');//v3.0
        
        //v2.0 Added the Opportunity field DeltekOppID__c
        //v3.0 - Added RecordTypeId check
        //v4.0 - Remove at select statements o.Opportunity.DeltekOppID__c,
        opplineItemList=[SELECT id,o.Opportunity.Cloned_Parent_Id__c, o.Opportunity.Oppty_Self_Id__c, o.Opportunity.Contract_Term__c, o.Opportunity.CloseDate, o.OpportunityId, o.Opportunity.RecordTypeId
                        FROM OpportunityLineItem o WHERE Id IN :setallOppLineItemIds AND o.Opportunity.RecordTypeId =: standardOppRTId];
                         
        for(OpportunityLineItem lnitemopp:opplineItemList){
            mapClonedParentId.put(lnitemopp.id,lnitemopp.Opportunity.Cloned_Parent_Id__c);
            mapClosedDate.put(lnitemopp.id,lnitemopp.Opportunity.CloseDate);
            mapContractTerm.put(lnitemopp.id,lnitemopp.Opportunity.Contract_Term__c);
            //v4.0 mapDeltekOppID.put(lnitemopp.id,lnitemopp.Opportunity.DeltekOppID__c); //v2.0
        }
        //v3.0 - Added RecordTypeId check
        oppLnItemlistNew=[SELECT Id, Opportunity.RecordTypeId, (SELECT Id,Type FROM OpportunityLineItemSchedules ) 
                                       FROM OpportunityLineItem WHERE Id IN :setallOppLineItemIds AND Opportunity.RecordTypeId =: standardOppRTId];
        for(OpportunityLineitem opplnItemIterator :oppLnItemlistNew){
            list<OpportunityLineItemSchedule> lstLineItemsSch = opplnItemIterator.OpportunityLineItemSchedules;
            if(lstLineItemsSch != null && !lstLineItemsSch.isEmpty()){
                mapOppLineItemSch.put(opplnItemIterator.Id, lstLineItemsSch);
            }
        }  
        for(Id opplnItemIdonebyone:setallOppLineItemIds){ 
            
            //v2.0 -- Added the if condition to check DeltekOppID__c is blank
            //v4.0 
                clonedprodwithsystemscheduleexists=false; 
                lstlnItemNewValues=mapNewOpportunityLineItem.get(opplnItemIdonebyone);
                lstlnItemOldValues=mapOldOpportunityLineItem.get(opplnItemIdonebyone);
                ClonedParentId=mapClonedParentId.get(opplnItemIdonebyone);
                ClosedDate=mapClosedDate.get(opplnItemIdonebyone);
                ContractTerm=mapContractTerm.get(opplnItemIdonebyone);
                if(ClonedParentId!=null){
                    oppListSchexisting=mapOppLineItemSch.get(opplnItemIdonebyone);
                    If(oppListSchexisting!=null && oppListSchexisting.size()>0){
                        clonedprodwithschedule=true;
                    }
                 
                }
                oppListSchTypeBoth=mapOppLineItemSch.get(opplnItemIdonebyone);
                If(oppListSchTypeBoth!=null && oppListSchTypeBoth.size()>0){
                        clonedprodwithsystemscheduleexists=true;
                    }
                if(clonedprodwithschedule==false || ClonedParentId==null){
                  If(ContractTerm!=null && ClosedDate!=null && lstlnItemNewValues.TotalPrice!=lstlnItemOldValues.TotalPrice && clonedprodwithsystemscheduleexists==false){
                  monthlyamt=Math.Floor(lstlnItemNewValues.TotalPrice/ ContractTerm);
                        for (integer i=0;i<ContractTerm;i++){
                            OpportunityLineItemSchedule opplnitemSch=new OpportunityLineItemSchedule();
                            opplnitemSch.OpportunityLineItemId= lstlnItemNewValues.id;
                            opplnitemSch.Type='Revenue';
                            opplnitemSch.ScheduleDate= ClosedDate.addMonths(i);
                            if(i== (ContractTerm-1)){
                                opplnitemSch.Revenue=  Integer.ValueOf(lstlnItemNewValues.TotalPrice) - Integer.ValueOf((ContractTerm -1)*monthlyamt);
                            }
                            else{
                                opplnitemSch.Revenue=monthlyamt;
                            }
                            opplineListforupdate.add(opplnitemSch);
                        }
                  }  
                }
              //v4.0}  
        }
        if(opplineListforupdate!=null && !opplineListforupdate.isEmpty()){
                  setSkipTriggers(true);  
                  insert opplineListforupdate;
                  setSkipTriggers(false);
        }

    }

}