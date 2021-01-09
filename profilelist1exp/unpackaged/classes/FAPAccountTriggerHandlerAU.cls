/*
 * Author   : Naga
 * Purpose  : Gives abstract view of all the business logics / functionality implemented on Account.
 * 
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      CR 18310    FY20-DCS-0102   20-Nov-2019     Naga            Adding code to fire PB on Account Partner Track when Sales Channel has changed
 */
public class FAPAccountTriggerHandlerAU implements AfterUpdate {
    public void handleAfterUpdate(List < sObject > listNew, Map < Id, sObject > mapOld) {
        List < Account > listAcc = (List < Account > ) trigger.New;
        List<Id> listAccIds =  new List<Id>();
        Map < Id, Account > mapOldAcc = (Map < Id, Account > ) trigger.oldMap;
        boolean bflag1 = false;
        system.debug('######  listAcc' + listAcc);
        for (Account objAcc: listAcc) {
            If(bflag1 == false && mapOldAcc.get(objAcc.id).Sales_Channel__c != objAcc.Sales_Channel__c) {
                bflag1 = true;
                listAccIds.add(objAcc.id);
            }
        }
        if (bflag1) {
            FAPAccountUtilities.fireAccountPartnerTrackPB(listAccIds);
        }
    }
}