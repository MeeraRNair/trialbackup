/*
Author: Jessie Tan
History:
Version Date            Modified By     Description
--------------------------------------------------------------------------------------
1.0      03-Apr-2012    Jessie          Updated for CR7011 - Check whether there is any Opportunity Product eligible for DGR (a new field - Contain_DGR_Eligible_Product__c) for an Opportunity
2.0      23-Nov-2012    Sathish         Updated for CR7670  - Retrieve all opportunity product's brand desc and added into hidden field for new critical field check in DGR criteria
3.0      19-Mar-2013    Sathish         Updated for CR8132 - Auto populate Dell Defined LOB in opportunity based on product added       
4.0      11-Aug-2017    Yamini          Updated for CR14762 - Commenting code as part of Services related CodeCleanup
*/
public class DgrEligibleOppProdSummary {       
   
    private Map<String, boolean> oppWithDgrEligibleProdSummary = new Map<String, boolean>();
    private map<Id, List<String>> mapOppDetails = new map<Id, List<String>>();
    
    private map<string, string> mapSerLOBCrossRef = new map<string, string>();
    private map<Id, set<string>> mapOppWithLOBConsol = new map<Id, set<string>>();
     
    //it needs to be called before checkIfOppContainsDgrEligibleProduct function is called
    //it will store all the dgr eligible product info ( whether it contains any dgr eligible product) into a map 
    //to be used by checkIfOppContainsDgrEligibleProduct function
    //V4.0 Starts
    /*public void loadDgrEligibleProdInfo(Set<Id> oppIdSet){
    
        AggregateResult[] oppWithNoOfDgrEligibleProd = [select opportunityId, count(id) cnt from OpportunityLineItem
                                        where opportunityId In :oppIdSet and DGR_Eligible__c = 'Yes'
                                        group by opportunityId];
        
        for(Integer i=0; i<= oppWithNoOfDgrEligibleProd.size()-1; i++){
            
            System.debug('### Opp Id [' + oppWithNoOfDgrEligibleProd[i].get('opportunityId') + '], NoOfDgrEligibleProduct [' + oppWithNoOfDgrEligibleProd[i].get('cnt') + ']');
            
            oppWithDgrEligibleProdSummary.put(String.valueOf(oppWithNoOfDgrEligibleProd[i].get('opportunityId')), (oppWithNoOfDgrEligibleProd[i].get('cnt')==0)?false:true);                                           
                                        
        }
           
        System.debug('### No Of Items in oppWithDgrEligibleProdSummary: ' + oppWithDgrEligibleProdSummary.size());

                                             
    } 
    
    public void loadServicesLOBCrossRefData() {
         //3.0 - start 
        list<Services_LOB_Cross_Reference__c> servLOBCrossRefList = [select Id, Dell_Defined_LOB__c, Product_Group__c from Services_LOB_Cross_Reference__c];
                
        if(servLOBCrossRefList != null && servLOBCrossRefList.size() > 0) {
            for(Services_LOB_Cross_Reference__c slcr : servLOBCrossRefList) {
                mapSerLOBCrossRef.put(slcr.Product_Group__c, slcr.Dell_Defined_LOB__c);
            }
        }
        
        //3.0 - end
    }*/
    //V4.0 Ends
    
    public void concatenateBrandDescAndLOB(List<OpportunityLineItem> oppLineItem){
        
        system.debug('Inside concatBrandDesc');
        system.debug('oppLineItem::'+oppLineItem);
    
       for(opportunitylineitem ln: oppLineItem){
 
            if(!mapOppDetails.containsKey(ln.OpportunityId)){
                mapOppDetails.put(ln.OpportunityId, New List<String>());
            }            
            mapOppDetails.get(ln.OpportunityId).add(ln.Brand_Desc__c);
            
            //3.0 - start
            //set<string> retLOBFromLOBConsolMap = new set<string>();
/*Hari*/            system.debug('ln.Product_Type_Text__c::' + ln.Product_Type_Text__c);
/*Hari*/            system.debug('ln.Product_Type_Formula__c::' + ln.Product_Type_Formula__c);
                   // if(ln.Product_Type_Text__c== 'Services') {
                   //V4.0 Starts
/*Hari*/         /*   if(ln.Product_Type_Text__c== 'Services' || ln.Product_Type_Formula__c== 'Services') {
                
                set<string> retLOBFromLOBConsolMap = mapOppWithLOBConsol.get(ln.OpportunityId);
                string retLOBFromCrossRef = mapSerLOBCrossRef.get(ln.Product_code_for_analytics__c);
                if(retLOBFromCrossRef == '' || retLOBFromCrossRef== null || ln.Product_code_for_analytics__c == '' || ln.Product_code_for_analytics__c == null) {
                    retLOBFromCrossRef = mapSerLOBCrossRef.get(null);
                }
                if(retLOBFromLOBConsolMap == null) {
                set<string> retLOBFromLOBConsolMap1 = new set<string>();
                retLOBFromLOBConsolMap1.add(retLOBFromCrossRef);
                system.debug('retLOBFromLOBConsolMap1::' + retLOBFromLOBConsolMap1);
                system.debug('retLOBFromCrossRef::' + retLOBFromCrossRef);
                system.debug('mapSerLOBCrossRef mapSerLOBCrossRef::' + mapSerLOBCrossRef);
                    mapOppWithLOBConsol.put(ln.OpportunityId, retLOBFromLOBConsolMap1);
                }
                else {
                    retLOBFromLOBConsolMap.add(retLOBFromCrossRef);
                    mapOppWithLOBConsol.put(ln.OpportunityId, retLOBFromLOBConsolMap);
                }
                //Hari 
                System.debug('### mapOppWithLOBConsol : ' + mapOppWithLOBConsol);
                                        
            } */
            //3.0 end
        //V4.0 Ends
        //}
        
        System.debug('### mapOppDetails  : ' + mapOppDetails);
        
    }
    }
    /* V4.0 Starts
    //check if an opp contains any dgr eligible product
    public void checkIfOppContainsDgrEligibleProduct(Opportunity opp){
    
        //if the map contains the oppid and the value in the map is true
        //then it contains dgr eligible product
        if(oppWithDgrEligibleProdSummary==null ||
           oppWithDgrEligibleProdSummary.get(opp.Id)==null ||
           oppWithDgrEligibleProdSummary.get(opp.Id)==false){
            opp.Contain_DGR_Eligible_Product__c = false;
            return;
        }
        
        opp.Contain_DGR_Eligible_Product__c = true;
        System.debug('### opp.Contain_DGR_Eligible_Product__c : ' + opp.Contain_DGR_Eligible_Product__c);
    }
    V4.0 Ends */
   public void modifyOppBrandDescHiddenField(Opportunity opp){
    
        if(mapOppDetails==null ||
           mapOppDetails.get(opp.Id)==null){
            opp.Products_Brand_Desc_Hidden__c = '';
            return;
        }
        
        Set<String> setBrandDescToRemoveDuplicate = new Set<String>();
        setBrandDescToRemoveDuplicate.addAll(mapOppDetails.get(opp.Id));
        String brandDescConcatFinal = '';
                
        for(string str : setBrandDescToRemoveDuplicate) {
            if(brandDescConcatFinal != null && brandDescConcatFinal != '')
                brandDescConcatFinal = brandDescConcatFinal + ';';
            brandDescConcatFinal = brandDescConcatFinal + str;
        }
        
        if(opp.Products_Brand_Desc_Hidden__c != brandDescConcatFinal) {    
            opp.Products_Brand_Desc_Hidden__c = brandDescConcatFinal;
        }
        
        System.debug('### opp.Products_Brand_Desc_Hidden__c : ' + opp.Products_Brand_Desc_Hidden__c );
    }
    /* V4.0 Starts
    //3.0 - start
    public void modifyOppLOBField(Opportunity opp){
        
         // @@@ Hari start code 
         List<OpportunityLineItem> allOppLineItemList = [SELECT Id, Brand_Desc__c, OpportunityId, Quantity, S_P_Registerable__c, Product_code_for_analytics__c, Product_Type_Text__c,Product_Type_Formula__c FROM OpportunityLineItem WHERE OpportunityId=:opp.Id];
         system.debug('modifyOppLOBField - allOppLineItemList::'+allOppLineItemList);
         concatenateBrandDescAndLOB(allOppLineItemList);
         // @@ Hari end code

        set<string> oppLOBSonsolidatedFromMap = mapOppWithLOBConsol.get(opp.Id);
        string strLOBFinal = '';
        if(oppLOBSonsolidatedFromMap != null && oppLOBSonsolidatedFromMap.size() > 0) {
//Hari 
       System.debug('### oppLOBSonsolidatedFromMap: ' + oppLOBSonsolidatedFromMap );
            for(string str : oppLOBSonsolidatedFromMap) {
                if(strLOBFinal != '') 
                    strLOBFinal = strLOBFinal + ';' + str;
                else
                    strLOBFinal = str;
            }
            opp.Dell_Defined_LOB__c = strLOBFinal;
//Hari
        System.debug('### opp.Dell_Defined_LOB__c : ' + opp.Dell_Defined_LOB__c );
            return ;
        }
           
        opp.Dell_Defined_LOB__c = '';
    }
    //3.0 - end
    V4.0 Ends */
}