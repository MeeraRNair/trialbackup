/*        
 * Revision Ref Number  Release No  Date            Modified By     Description
 * -------- ----------  ----------  -----------     ------------    -----------
 * 1.0      6192529  DCE-FY20-0502  11-Apr-2019    Rajiv Ranjan     Trigger handler class for Sales Channel Group records, used for populating the related field in visit bundle   
*/
public class VOSalesChannelGroupTriggerHandler {
	public static void afterUpdateHandler(List<Sales_Channel_Group__c> listNewSalesChannels, Map<id, Sales_Channel_Group__c> mapOldSalesChannelsMap)
    {
        Set<Id> setSalesChannelsIds = new Set<Id>();
        for(Sales_Channel_Group__c scg : listNewSalesChannels)
        {
			if(scg.Region_Desc__c != mapOldSalesChannelsMap.get(scg.Id).Region_Desc__c
              	|| scg.Segment_Business_Unit_Name__c != mapOldSalesChannelsMap.get(scg.Id).Segment_Business_Unit_Name__c
              	|| scg.Segment_Desc__c != mapOldSalesChannelsMap.get(scg.Id).Segment_Desc__c
              	|| scg.Regional_Parent_Name__c != mapOldSalesChannelsMap.get(scg.Id).Regional_Parent_Name__c)
            {
                setSalesChannelsIds.add(scg.Id);
            }
        }

        List<VisitOps__VisitBundle__c > listVisitBundle = [Select Id from VisitOps__VisitBundle__c where VisitOps__opportunity__r.Account.Sales_Channel__c !=null and VisitOps__opportunity__r.Account.Sales_Channel__c in:setSalesChannelsIds];												   
    	updateVisitBundle(listVisitBundle);
    }
    
	/*
		Ticket : 6192529
    	Date : 10 April 2019
    	DS : Sales Channel Group is updated then their related "Visit Bundle" record will also be updated.
	*/
    public static void updateVisitBundle(List<VisitOps__VisitBundle__c > listVisitBundle)
    {		
		If(listVisitBundle!=null && listVisitBundle.size()>0){
			VOVisitBundleTriggerHandler.bIsUpdatedVisitBundle =  true;
			update listVisitBundle;
			VOVisitBundleTriggerHandler.bIsUpdatedVisitBundle =  false;
		}
    }
}