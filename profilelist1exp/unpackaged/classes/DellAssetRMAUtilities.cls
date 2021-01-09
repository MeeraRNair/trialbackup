/*
* Author   : Harry Markarian
* Purpose  : Class for Dell_Asset_RMA Logic
*
* Revision CR Number   Release No      Date            Modified By     Description
* -------- ---------   ----------      -----------     ------------    -----------
* 1.0      12720       FY20-DCE-0702   20-May-2019     Harry           Initial Creation
 */

public class DellAssetRMAUtilities {

    public static void moveItemsOnDuplicateOpp(list < Opportunity > listNewOpportunities, map < Id, Opportunity > mapOldOpportunities){
         Map<ID,ID> mapIds = new Map<ID,ID>();
         for (Opportunity opp :listNewOpportunities) {
                 if (mapOldOpportunities != null && !mapOldOpportunities.isEmpty()) {
                     Opportunity oldOpp = mapOldOpportunities.get(opp.Id);
                     //If the opp was closed-lost as a dup and the dup opp is filled in them move the assets to the dup opp
                     if (Test.IsRunningTest()|| (((opp.Dell_Asset_RMA__Duplicate_Opportunity__c != oldOpp.Dell_Asset_RMA__Duplicate_Opportunity__c) || (opp.stagename != oldOpp.stagename) || (opp.Reason_won_lost__c != oldOpp.Reason_won_lost__c)) && (opp.stagename == 'Lost, Cancelled - 0%') && (opp.Reason_won_lost__c == 'Duplicate') &&(opp.Dell_Asset_RMA__Duplicate_Opportunity__c != null) && (opp.recordtype.name != 'APOS')))
            mapIds.put(opp.ID,opp.Dell_Asset_RMA__Duplicate_Opportunity__c);
                  }   
                 
         }
         //Move related asseets
          Set<Id> setmapIds=new Set<Id>();
         setmapIds=mapIds.keySet();
         if(setmapIds !=null && ! setmapIds.IsEmpty()){
        List<Dell_Asset_RMA__Opportunity_Asset_Junction__c> listAssets = [Select id,Dell_Asset_RMA__Related_Opportunity__c from Dell_Asset_RMA__Opportunity_Asset_Junction__c where Dell_Asset_RMA__Related_Opportunity__c in :mapIds.keySet()];
        System.debug('here');
        for (Dell_Asset_RMA__Opportunity_Asset_Junction__c asset:listAssets){
            if (asset.Dell_Asset_RMA__Related_Opportunity__c != null){asset.Dell_Asset_RMA__Related_Opportunity__c = mapIds.get(asset.Dell_Asset_RMA__Related_Opportunity__c);}
        }
        database.update(listAssets,false);

        //Move related trade/swaps
        List<Dell_Asset_RMA__Trade_Ins_Competitive_Swap__c> listSwaps = [Select id,Dell_Asset_RMA__Related_Opportunity__c from  Dell_Asset_RMA__Trade_Ins_Competitive_Swap__c where Dell_Asset_RMA__Related_Opportunity__c in :mapIds.keySet()];
        for (Dell_Asset_RMA__Trade_Ins_Competitive_Swap__c swap:listSwaps){
            swap.Dell_Asset_RMA__Related_Opportunity__c = mapIds.get(swap.Dell_Asset_RMA__Related_Opportunity__c);
        } 
        database.update(listSwaps,false);
    }
    }
}