/*
History:
  Revision CR Number   Release No      Date            Modified By     Description     
--------------------------------------------------------------------------------------
* 1.0       13574      DCS-FY17-1101                     Shivam         Batch Scheduler Class for Sending Email to Opportunity Owners who are not using Product Recommendation Feature.
  2.0       14767      DCS-FY18-1001                     Syazwan        Replaced hardcoded 'US' with custom label 'Countries' at line 52                              
  3.0       14932      FY18-DCS-1101                     Naga           Added 'Segment_Business_Unit_Name__c' field in the opportunity records filter and added code to handle 'Null' value for 'Segment_Name__c' 
 */
 
global class Product_Recommendation_Email_Scheduler implements Schedulable{
    global void execute(SchedulableContext sc) {   
        Map<String, Octane_Segment_Quantity_Mapping__c> mapofSegQty = new Map<String, Octane_Segment_Quantity_Mapping__c>(Octane_Segment_Quantity_Mapping__c.getAll());
        Map<String, Octane_Segment_Quantity_Mapping__c> mapofSegQty_Clone = new Map<String, Octane_Segment_Quantity_Mapping__c>();
        Set<String> mapofSegQty_Biz_Seg = new Set<String>();
        for(Octane_Segment_Quantity_Mapping__c obj:mapofSegQty.values()){
            mapofSegQty_Clone.put(obj.Segment_Name__c,obj);
            if(obj.Segment_Business_Unit_Name__c != null){
              mapofSegQty_Biz_Seg.add(obj.Segment_Business_Unit_Name__c);
            }
        }
        Map<String, Octane_Segment_Quantity_Mapping_EMEA__c> mapofSegQtyEMEA = new Map<String, Octane_Segment_Quantity_Mapping_EMEA__c>(Octane_Segment_Quantity_Mapping_EMEA__c.getAll());
        Map<String, Octane_Segment_Quantity_Mapping_EMEA__c> mapofSegQty_Clone_EMEA = new Map<String, Octane_Segment_Quantity_Mapping_EMEA__c>();
        Set<String> mapofSegQty_Biz_Seg_EMEA = new Set<String>();
        for(Octane_Segment_Quantity_Mapping_EMEA__c obj:mapofSegQtyEMEA.values()){
            mapofSegQty_Clone_EMEA.put(obj.Segment_Name_EMEA__c,obj);
            if(obj.Segment_Business_Unit_Name_EMEA__c != null){
              mapofSegQty_Biz_Seg_EMEA.add(obj.Segment_Business_Unit_Name_EMEA__c);
            }
        }
        Map<String, Octane_Segment_Quantity_Mapping_APJ__c> mapofSegQtyAPJ = new Map<String, Octane_Segment_Quantity_Mapping_APJ__c>(Octane_Segment_Quantity_Mapping_APJ__c.getAll());
        Map<String, Octane_Segment_Quantity_Mapping_APJ__c> mapofSegQty_Clone_APJ = new Map<String, Octane_Segment_Quantity_Mapping_APJ__c>();
        Set<String> mapofSegQty_Biz_Seg_APJ = new Set<String>();
        for(Octane_Segment_Quantity_Mapping_APJ__c obj:mapofSegQtyAPJ.values()){
            mapofSegQty_Clone_APJ.put(obj.Segment_Name_APJ__c,obj);
            if(obj.Segment_Business_Unit_Name_APJ__c != null){
              mapofSegQty_Biz_Seg_APJ.add(obj.Segment_Business_Unit_Name_APJ__c);
            }
        }
        Set<String> strSegments = mapofSegQty_Clone.keyset();
        Set<String> strSegmentsEMEA = mapofSegQty_Clone_EMEA.keyset();
        Set<String> strSegmentsAPJ = mapofSegQty_Clone_APJ.keyset();
        Set<String> strStages = new Set<String>{'Win - 100%','Lost, Cancelled - 0%'};
        Set<String> strRecordTypes = new Set<String>{'Standard Opportunity','SMB Opportunity','Run Rate Opportunity','APOS','Non-Standard Opportunity'};
        string query ='Select Id,StageName,Account.Sales_Channel__r.Segment_Name__c,Account.Sales_Channel__r.Segment_Business_Unit_Name__c,OwnerId,RecordType.Name,Account.Account_Country_Code__c from Opportunity Where ';
        query += 'Account.Sales_Channel__c != null and Number_of_Line_Items__c > 0 ';
        String strStage;
        for(String strStg:strStages){
            if(strStage==null){
                strStage = 'StageName != \''+strStg+'\'';
            }
            else{
                strStage += ' AND StageName != \''+strStg+'\'';
            }
        }
        String strRecordType;
        for(String strRT:strRecordTypes){
            if(strRecordType==null){
                strRecordType = 'RecordType.Name = \''+strRT+'\'';
            }
            else{
                strRecordType += ' OR RecordType.Name = \''+strRT+'\'';
            }
        }
        String strSegment;
        for(String strSeg:strSegments){
            if(strSegment==null){
                strSegment = 'Account.Sales_Channel__r.Segment_Name__c = Null';
            }
            else{
                strSegment += ' OR Account.Sales_Channel__r.Segment_Name__c = \''+strSeg+'\'';
            }
        }
        String strSegBusUnitName;
        for(String strSegBusUnit:mapofSegQty_Biz_Seg){
            if(strSegBusUnitName==null){
                strSegBusUnitName = 'Account.Sales_Channel__r.Segment_Business_Unit_Name__c = \''+strSegBusUnit+'\'';
            }
            else{
                strSegBusUnitName += ' OR Account.Sales_Channel__r.Segment_Business_Unit_Name__c = \''+strSegBusUnit+'\'';
            }
        }
        //EMEA
        String strSegmentEMEA;
        for(String strSeg:strSegmentsEMEA){
            if(strSegmentEMEA==null){
                strSegmentEMEA = 'Account.Sales_Channel__r.Segment_Name__c = Null';
            }
            else{
                strSegmentEMEA += ' OR Account.Sales_Channel__r.Segment_Name__c = \''+strSeg+'\'';
            }
        }        
        String strSegBusUnitNameEMEA;
        for(String strSegBusUnit:mapofSegQty_Biz_Seg_EMEA){
            if(strSegBusUnitNameEMEA==null){
                strSegBusUnitNameEMEA = 'Account.Sales_Channel__r.Segment_Business_Unit_Name__c = \''+strSegBusUnit+'\'';
            }
            else{
                strSegBusUnitNameEMEA += ' OR Account.Sales_Channel__r.Segment_Business_Unit_Name__c = \''+strSegBusUnit+'\'';
            }
        }
        //APJ
        String strSegmentAPJ;
        for(String strSeg:strSegmentsAPJ){
            if(strSegmentAPJ==null){
                strSegmentAPJ = 'Account.Sales_Channel__r.Segment_Name__c = Null';
            }
            else{
                strSegmentAPJ += ' OR Account.Sales_Channel__r.Segment_Name__c = \''+strSeg+'\'';
            }
        }        
        String strSegBusUnitNameAPJ;
        for(String strSegBusUnit:mapofSegQty_Biz_Seg_APJ){
            if(strSegBusUnitNameAPJ==null){
                strSegBusUnitNameAPJ = 'Account.Sales_Channel__r.Segment_Business_Unit_Name__c = \''+strSegBusUnit+'\'';
            }
            else{
                strSegBusUnitNameAPJ += ' OR Account.Sales_Channel__r.Segment_Business_Unit_Name__c = \''+strSegBusUnit+'\'';
            }
        }
        query += ' AND ('+strStage+')';
        query += ' AND ('+strRecordType+')';
        query += ' AND ((('+strSegment+')';
        query += ' AND ('+strSegBusUnitName+')';
        query += ' AND Account.Account_Country_Code__c IN ('+Label.Account_Country_Code_NA_Contrlr+'))';
        query += ' OR (('+strSegmentEMEA+')';
        query += ' AND ('+strSegBusUnitNameEMEA+')';
        query += ' AND Account.Account_Country_Code__c IN ('+Label.Countries_EMEA_Contrlr+'))';        
        query += ' OR (('+strSegmentAPJ+')';
        query += ' AND ('+strSegBusUnitNameAPJ+')';
        query += ' AND Account.Account_Country_Code__c IN ('+Label.Countries_APJ_Contrlr+')))';
        Product_Recommendation_Email batchOctaneEmail = new Product_Recommendation_Email(query);                
        database.executebatch(batchOctaneEmail,200);  
    }  
}