/*
* Author  : Harsha Chadalavada
* Purpose : To display Account Revenue Trends Information.
* 
* Revision   CR Number     Release No  Date            Modified By     Description
* --------   ---------     ----------  -----------     ------------    -----------
*  1.0       CR16041       FY19-0902   21-Jul-2018     Harsha          Created class to calculate revenue from OpportunityLineItemSchedule
*/
public class OLIScheduleRevenueQtrCalc {
	@InvocableMethod(label='Schedule Revenue QTR Calculation')
    public static void oliSchedule(list<OLIFields> oli){
        map<id, datetime> oliModfidMap = new map<id, datetime>();
        try{
            for(OLIFields ol : oli){
                oliModfidMap.put(ol.oliId, ol.lmDate);
            }
            set<id> oliRevIdSet = OLIScheduleRevenueQtrCalcHelper.isOLIScheduleUpdated(oliModfidMap);
            if(!oliRevIdSet.isempty()){
                list<opportunitylineitem> oliUpdate = OLIScheduleRevenueQtrCalcHelper.updateSchRev(oliRevIdSet);
                if(!oliUpdate.isempty()){
                    update oliUpdate;
                }
            }
        }
        catch(exception e){
            system.debug('OLIScheduleRevenueQtrCalc exception : '+e);
        }
    }
    
    public class OLIFields{
        @InvocableVariable(label='Id of OLI' required= true)
        public id oliId;
        @InvocableVariable(label='lastModified Date of OLI' required= true)
        public datetime lmDate;

     }
}