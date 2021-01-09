/*
 * Author   : Naga
 * Purpose  : Utility class to hold simple and reusable functionalities which are related to Account object. 
 *        
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR18310     FY20-DCS-0102 20-Nov-2019   Naga            Adding code to fire PB on Account Partner Track when Sales Channel has changed
 * -------- ---------   ----------  -----------     ------------    -----------------------------------------------------------------------------------
 * Please DO NOT add revision history in the class level, instead add it in the corresponding methods. 
 */
public class FAPAccountUtilities {
    //This method will fire when Sales Channel has changed on account and it will flip the value of Approved for Partner Finder value on Account Partner Track
    public static void fireAccountPartnerTrackPB(List < Id > listIds) {
        List < Partner_Track__c > listAccPTracks = new List < Partner_Track__c > ();
        for (Partner_Track__c objAccPT: [select id, Approved_for_Partner_Finder__c from Partner_Track__c where Primary_SMAffinity_Account__c in: listIds and Track_Name__c like '%Federal Solution Provider%']) {
            if (objAccPT.Approved_for_Partner_Finder__c == true) {
                objAccPT.Approved_for_Partner_Finder__c = false;
            } else {
                objAccPT.Approved_for_Partner_Finder__c = true;
            }
            listAccPTracks.add(objAccPT);
        }
        if (!listAccPTracks.isEmpty() && listAccPTracks.size() > 0) {
            update listAccPTracks;
        }
    }
}