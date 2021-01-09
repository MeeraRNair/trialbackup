/*
* Author  : Harsha Chadalavada
* Purpose : To display Account Revenue Trends Information.
* 
* Revision   CR Number       Release No  Date            Modified By     Description
* --------   ---------       ----------  -----------     ------------    -----------
*  1.0       CR16041         FY19-0902   21-Jul-2018     Harsha          Helper class for OLIScheduleRevenueQtrCalc to calculate revenue from OpportunityLineItemSchedule
*  1.1       DEFECT 5606277  FY19-0902   15-Sep-2018     Harsha          Update to fix for Multi-currency
*  2.0		 CR17041		 FY20-0402	 22-Jan-2019	 Harsha			 Update OLI when Calculate Scheduled Revenue field is checked.
*/
public class OLIScheduleRevenueQtrCalcHelper {
    //v1.1
    Public static Integer olisTimeDiff = integer.valueOf(System.Label.OLI_Schedule_Modified_Time_Difference);
    
    public static map<string, date> getFiscalQtrs(){
        Map<String, Fiscal_Years__c> fyMap = Fiscal_Years__c.getAll();
        map<string, date> qtrsMap = new map<string, date>();
        string nm;
        for(Fiscal_Years__c fy : fyMap.values()){
            if(fy.Start_Date__c<=system.today() && fy.End_Date__c>=system.today()){
                nm = fy.name;
                qtrsMap.put('currQtrStart', fy.Start_Date__c);
                qtrsMap.put('currQtrEnd', fy.End_Date__c);
            }
        }
        String nextfyq;
        if(nm.right(1) != '4'){
            nextfyq = nm.left(5)+(integer.valueOf(nm.right(1))+1);
        }else {
            nextfyq = 'FY'+(integer.valueOf(nm.substring(2,4))+1)+'Q1';
        }
        qtrsMap.put('nextQtrStart', fyMap.get(nextfyq).Start_Date__c);
        qtrsMap.put('nextQtrEnd', fyMap.get(nextfyq).End_Date__c);
        return qtrsMap;        
    }
     
    public static list<opportunitylineitem> updateSchRev(set<id> oliRevIdSet){
        list<opportunitylineitem> oliUpdate = new list<opportunitylineitem>();
        map<string, date> qtrsMap = getFiscalQtrs();
        Map<id, decimal> revCurrQtrMap = new Map<id, decimal>();
        Map<id, decimal> revNextQtrMap = new Map<id, decimal>();
        //v1.1 start
        list<opportunitylineitemschedule> olisCurr = [select revenue, opportunitylineitemid from opportunitylineitemschedule Where scheduleDate>=:qtrsMap.get('currQtrStart') and scheduleDate<=:qtrsMap.get('currQtrEnd') and opportunitylineitemid =:oliRevIdSet];
        system.debug('---OLIScheduleRevenueQtrCalcHelper--- olisCurr : '+olisCurr);
        revCurrQtrMap = calcRevenue(olisCurr, oliRevIdSet);
        
        list<opportunitylineitemschedule> olisNext = [select revenue, opportunitylineitemid from opportunitylineitemschedule Where scheduleDate>=:qtrsMap.get('nextQtrStart') and scheduleDate<=:qtrsMap.get('nextQtrEnd') and opportunitylineitemid =:oliRevIdSet];
        revNextQtrMap = calcRevenue(olisNext, oliRevIdSet);
        /* for(aggregateresult revCur : [select sum(revenue), opportunitylineitemid from opportunitylineitemschedule Where scheduleDate>=:qtrsMap.get('currQtrStart') and scheduleDate<=:qtrsMap.get('currQtrEnd') and opportunitylineitemid =:oliRevIdSet group by opportunitylineitemid]){
            revCurrQtrMap.put((Id)revCur.get('opportunitylineitemid'), (decimal)revCur.get('expr0'));
        }
        for(aggregateresult revNex : [select sum(revenue), opportunitylineitemid from opportunitylineitemschedule Where scheduleDate>=:qtrsMap.get('nextQtrStart') and scheduleDate<=:qtrsMap.get('nextQtrEnd') and opportunitylineitemid =:oliRevIdSet group by opportunitylineitemid]){
            revNextQtrMap.put((Id)revNex.get('opportunitylineitemid'), (decimal)revNex.get('expr0'));
        }*/
        //v1.1 end
        boolean isCurrQtrUpdated = false;
        boolean isNextQtrUpdated = false;
        system.debug('---OLIScheduleRevenueQtrCalcHelper--- oliRevIdSet : '+oliRevIdSet);
        system.debug('---OLIScheduleRevenueQtrCalcHelper--- qtrsMap : '+qtrsMap);
        system.debug('---OLIScheduleRevenueQtrCalcHelper--- revCurrQtrMap : '+revCurrQtrMap);
        system.debug('---OLIScheduleRevenueQtrCalcHelper--- revNextQtrMap : '+revNextQtrMap);
        for(opportunitylineitem oli : [Select id, Calculate_Scheduled_Revenue__c, Scheduled_Current_Qrt_Rev__c,Scheduled_Next_Qrt_Rev__c,Scheduled_Rev_Flag__c  from opportunitylineitem where id =:oliRevIdSet]){
            if(revCurrQtrMap.size()!=0){
                Boolean isCurrQtrOliAvailable = revCurrQtrMap.containsKey(oli.Id);
                oli.Scheduled_Current_Qrt_Rev__c = ((isCurrQtrOliAvailable) ? revCurrQtrMap.get(oli.Id) : Null);
                isCurrQtrUpdated = true;
            }
            else {
                oli.Scheduled_Current_Qrt_Rev__c = Null;
                isCurrQtrUpdated = true;
            }
            if(revNextQtrMap.size()!=0){
                Boolean isNextQtrOliAvailable = revNextQtrMap.containsKey(oli.Id);
                oli.Scheduled_Next_Qrt_Rev__c = ((isNextQtrOliAvailable) ? revNextQtrMap.get(oli.Id) : Null);
                isNextQtrUpdated = true;
            }
            else{
                oli.Scheduled_Next_Qrt_Rev__c = Null;
                isNextQtrUpdated = true;
            }
            if(isCurrQtrUpdated || isNextQtrUpdated){
                oli.Scheduled_Rev_Flag__c = system.now();
                oli.Calculate_Scheduled_Revenue__c = false; //v2.0
                oliUpdate.add(oli);
            }
        }
        return oliUpdate;
    }
    
    public static set<id> isOLIScheduleUpdated(map<id, datetime> oliModfidMap){
        set<id> oliRevIdSet = new set<id>();
        for(opportunityLineItemSchedule olis :[select id, revenue, opportunityLineItemid, OpportunityLineItem.Calculate_Scheduled_Revenue__c, scheduledate,LastModifiedDate from opportunityLineItemSchedule where opportunityLineItemid =:oliModfidMap.keyset()]){
            if((olis.LastModifiedDate<=oliModfidMap.get(olis.opportunityLineItemid) && olis.LastModifiedDate.addseconds(olisTimeDiff)>=OLIModfidMap.get(olis.opportunityLineItemid))
               ||(olis.OpportunityLineItem.Calculate_Scheduled_Revenue__c == TRUE)){		//v2.0
                oliRevIdSet.add(olis.opportunityLineItemid);
            }
        }
        return oliRevIdSet;
    }
    
    //v1.1 start
    public static map<id, Decimal> calcRevenue(list<opportunityLineItemSchedule> olisRev, set<id> oliRevIdSet){
        map<id,Decimal> iddm = new map<id,decimal>();
        list<id> oliRevIdList = new list<id>();
        oliRevIdList.addAll(oliRevIdSet);
        for(integer i=0;i<oliRevIdList.size();i++){
            Decimal sumRev=0;
            for(integer j=0;j<olisRev.size();j++){
                if(olisRev[j].opportunitylineitemid == oliRevIdList[i]){
                    sumRev+= olisRev[j].revenue;
                }
            }
            iddm.put(oliRevIdList[i],sumRev);
        }        
        return iddm;
    }
    //v1.1 end
}