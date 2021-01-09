/**
 * @File Name          : SalesMotionPETriggerHandlerAI.cls
 * @Description        : 
 * @Author             : Sushanth Dasari
 * @Group              : 
 * @Last Modified By   : Sushanth Dasari
 * @Last Modified On   : 11/10/2019, 2:52:26 PM
 * @Modification Log   : 
 * Ver       Date          Author      	   Modification
 * 1.0    11/9/2019   Sushanth Dasari     Initial Version
**/
public with sharing class SalesMotionPETriggerHandlerAI implements AfterInsert{
    public void handleAfterInsert(List<sObject> listNew){
        List<Sales_Motion_Contact_Event__e> listNewSMContactEventRecords = new List<Sales_Motion_Contact_Event__e>();
        List<Sales_Motion_Contact_Event__e> listUpdateSMContactEventRecords = new List<Sales_Motion_Contact_Event__e>();
        List<Sales_Motion_Contact_Event__e> listNewSMContactEvent = (List<Sales_Motion_Contact_Event__e>)listNew;
        for(Sales_Motion_Contact_Event__e sMContactEventRecord : listNewSMContactEvent){
            if(String.isBlank(sMContactEventRecord.Old_PartnerTrackIds__c)){
                listNewSMContactEventRecords.add(sMContactEventRecord);
            } else {
                listUpdateSMContactEventRecords.add(sMContactEventRecord);
            }
        }
        if(!listNewSMContactEventRecords.isEmpty()){
            SalesMotionContactUtilities.insertSalesMotionContacts(listNewSMContactEventRecords);
        }
        if(!listUpdateSMContactEventRecords.isEmpty()){
            SalesMotionContactUtilities.updateSalesMotionContacts(listUpdateSMContactEventRecords);
        }
    }
}