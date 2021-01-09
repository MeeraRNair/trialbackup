/*
History:
  Revision CR Number   Release No      Date            Modified By     Description     
--------------------------------------------------------------------------------------
* 1.0       13574      DCS-FY17-1101                     Shivam         Batch Class for Sending Email to Opportunity Owners who are not using Product Recommendation Feature.
  2.0       14286      FY18-DCS-0602                     Azlan          To call new field 'Segment_Name__c' from Custom Setting 'Octane_Segment_Quantity_Mapping__c' (mapping values from Field 'Name')
  3.0       14932      FY18-DCS-1101                     Naga           Changed code to include 'Segment_Business_Unit_Name__c' field in the conditions to trigger email.
 */

global class Product_Recommendation_Email implements Database.Batchable<sObject>, Database.Stateful{
    
    global final String query;
    global Product_Recommendation_Email(String q){
        query = q;
    }
       
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    public static Long GetHourDifferenceBtwTwoDateTime(DateTime startTime, DateTime endTime){
        if(startTime != null || endTime != null){
            Long dt1Long = startTime.getTime();
            Long dt2Long = endTime.getTime();
            Long milliseconds = dt2Long - dt1Long;
            Long seconds = milliseconds / 1000;
            Long minutes = seconds / 60;
            Long hours = minutes / 60;
            Long days = hours / 24;
            return hours;
        }
        return 0;
    }
      
    global void execute(Database.BatchableContext BC, List<sObject>scope){
        
        //Collect Opportunity Ids and Segment Name
        Map<Id,String> oppIds = new Map<Id,String>();
        Map<Id,String> oppIdSeg = new Map<Id,String>();
        Set<String> setVal = new Set<String>();
        for (Opportunity obj : (List<Opportunity>)scope) {
            if(obj.Account.Sales_Channel__r.Segment_Business_Unit_Name__c != null){
                oppIds.put(obj.Id,obj.Account.Sales_Channel__r.Segment_Business_Unit_Name__c.toUpperCase());
            }
            if(obj.Account.Sales_Channel__r.Segment_Name__c != null){
                oppIdSeg.put(obj.Id,obj.Account.Sales_Channel__r.Segment_Name__c.toUpperCase());
            }
            setVal.add(obj.Account.Account_Country_Code__c);            
        }
        
        //Collect Categories(Product Description). 
        String[] strProdCategories = System.Label.Product_Description.split(':');
        
        //Get Custom Settings for Segment Name and Quantity for 'US'
        Map<String, Octane_Segment_Quantity_Mapping__c> mapofSegQty = new Map<String, Octane_Segment_Quantity_Mapping__c>(Octane_Segment_Quantity_Mapping__c.getAll());
        Map<String, Octane_Segment_Quantity_Mapping__c> mapofSegQty_Clone = new Map<String, Octane_Segment_Quantity_Mapping__c>();
        Map<String, Octane_Segment_Quantity_Mapping__c> mapofSeg_Clone = new Map<String, Octane_Segment_Quantity_Mapping__c>();
        Set<String> set_Biz_Unit_Seg = new Set<String>();
        for(Octane_Segment_Quantity_Mapping__c obj:mapofSegQty.values()){            
            if(obj.Segment_Business_Unit_Name__c !=null){
              set_Biz_Unit_Seg.add(obj.Segment_Business_Unit_Name__c.toUpperCase());
              mapofSegQty_Clone.put(obj.Segment_Business_Unit_Name__c.toUpperCase(),obj);
              if(obj.Segment_Name__c != Null){
                  mapofSeg_Clone.put(obj.Segment_Name__c.toUpperCase(),obj);
              }
            }
        }
        
        //Get Custom Settings for Segment Name and Quantity for APJ
        Map<String, Octane_Segment_Quantity_Mapping_APJ__c> mapofSegQtyAPJ = new Map<String, Octane_Segment_Quantity_Mapping_APJ__c>(Octane_Segment_Quantity_Mapping_APJ__c.getAll());
        Map<String, Octane_Segment_Quantity_Mapping_APJ__c> mapofSegQty_Clone_APJ = new Map<String, Octane_Segment_Quantity_Mapping_APJ__c>();
        Map<String, Octane_Segment_Quantity_Mapping_APJ__c> mapofSeg_Clone_APJ = new Map<String, Octane_Segment_Quantity_Mapping_APJ__c>();
        Set<String> set_Biz_Unit_Seg_APJ = new Set<String>();
        for(Octane_Segment_Quantity_Mapping_APJ__c obj:mapofSegQtyAPJ.values()){            
            if(obj.Segment_Business_Unit_Name_APJ__c !=null){
              set_Biz_Unit_Seg_APJ.add(obj.Segment_Business_Unit_Name_APJ__c.toUpperCase());
              mapofSegQty_Clone_APJ.put(obj.Segment_Business_Unit_Name_APJ__c.toUpperCase(),obj);
              if(obj.Segment_Name_APJ__c != Null){
                  mapofSeg_Clone_APJ.put(obj.Segment_Name_APJ__c.toUpperCase(),obj);
              }
            }
        }
        
        //Get Custom Settings for Segment Name and Quantity for EMEA
        Map<String, Octane_Segment_Quantity_Mapping_EMEA__c> mapofSegQtyEMEA = new Map<String, Octane_Segment_Quantity_Mapping_EMEA__c>(Octane_Segment_Quantity_Mapping_EMEA__c.getAll());
        Map<String, Octane_Segment_Quantity_Mapping_EMEA__c> mapofSegQty_Clone_EMEA = new Map<String, Octane_Segment_Quantity_Mapping_EMEA__c>();
        Map<String, Octane_Segment_Quantity_Mapping_EMEA__c> mapofSeg_Clone_EMEA = new Map<String, Octane_Segment_Quantity_Mapping_EMEA__c>();
        Set<String> set_Biz_Unit_Seg_EMEA = new Set<String>();
        for(Octane_Segment_Quantity_Mapping_EMEA__c obj:mapofSegQtyEMEA.values()){            
            if(obj.Segment_Business_Unit_Name_EMEA__c !=null){
              set_Biz_Unit_Seg_EMEA.add(obj.Segment_Business_Unit_Name_EMEA__c.toUpperCase());
              mapofSegQty_Clone_EMEA.put(obj.Segment_Business_Unit_Name_EMEA__c.toUpperCase(),obj);
              if(obj.Segment_Name_EMEA__c != Null){
                  mapofSeg_Clone_EMEA.put(obj.Segment_Name_EMEA__c.toUpperCase(),obj);
              }
            }
        }
        
        //Fetch Octane Config Settings to get Hour Limit for Sending Email
        Octane_Config_Settings__c config = Product_Recommendation_Controller.fetchConfigSettings();
        
        //Collect Opportunity and there products which have crossed the time line and still not used recommendation functionality.
        Map<Id,List<OpportunityLineItem>> mapOppToOppProd = new Map<Id,List<OpportunityLineItem>>();
        Map<Id,Id> mapOppToOwner = new Map<Id,Id>();        
        for(OpportunityLineItem oli:[Select Id,Quantity,Product_Description__c,OpportunityId,Opportunity.Account.Account_Country_Code__c,Opportunity.Account.Sales_Channel__r.Segment_Business_Unit_Name__c,Opportunity.OwnerId,EAP_Date__c,EAP_User__c,CreatedDate from OpportunityLineItem Where OpportunityId IN:oppIds.keyset() and EAP_Date__c = null and EAP_User__c = null and Octane_Reminder_Email_Sent__c = false and Product_Description__c IN:strProdCategories]){
            if(Label.Account_Country_Code_NA_Contrlr.Contains(oli.Opportunity.Account.Account_Country_Code__c)){
               if(mapofSegQty_Clone.containsKey(oppIds.get(oli.OpportunityId)) && ( oli.Opportunity.Account.Sales_Channel__r.Segment_Business_Unit_Name__c != null && set_Biz_Unit_Seg.contains(oli.Opportunity.Account.Sales_Channel__r.Segment_Business_Unit_Name__c.toUpperCase()))){
                   if(mapofSegQty_Clone.get(oppIds.get(oli.OpportunityId)).Quantity__c != null && (mapofSegQty_Clone.get(oppIds.get(oli.OpportunityId)).IsActive__c || (mapofSegQty_Clone.containsKey(oppIds.get(oli.OpportunityId)) && ((mapofSeg_Clone.containsKey(oppIdSeg.get(oli.OpportunityId)) && oppIdSeg.get(oli.OpportunityId) != 'US OEM') || oppIdSeg.get(oli.OpportunityId) == null)))){
                       if(GetHourDifferenceBtwTwoDateTime(oli.CreatedDate,DateTime.now()) >= config.Hour_Limit_for_Sending_Email__c && oli.Quantity >= mapofSegQty_Clone.get(oppIds.get(oli.OpportunityId)).Quantity__c && mapofSegQty_Clone.containsKey(oppIds.get(oli.OpportunityId)) && (mapofSeg_Clone.containsKey(oppIdSeg.get(oli.OpportunityId)) || oppIdSeg.get(oli.OpportunityId) == null)){
                            if(!mapOppToOppProd.containsKey(oli.OpportunityId)){
                                mapOppToOppProd.put(oli.OpportunityId,new List<OpportunityLineItem>{oli});
                            }
                            else{
                                mapOppToOppProd.get(oli.OpportunityId).add(oli);
                            }
                            mapOppToOwner.put(oli.OpportunityId,oli.Opportunity.OwnerId);
                       }
                   }
               } 
            } 
            //APJ
            if(Label.Countries_APJ_Contrlr.Contains(oli.Opportunity.Account.Account_Country_Code__c)){
               if(mapofSegQty_Clone_APJ.containsKey(oppIds.get(oli.OpportunityId)) && ( oli.Opportunity.Account.Sales_Channel__r.Segment_Business_Unit_Name__c != null && set_Biz_Unit_Seg_APJ.contains(oli.Opportunity.Account.Sales_Channel__r.Segment_Business_Unit_Name__c.toUpperCase()))){
                   if(mapofSegQty_Clone_APJ.get(oppIds.get(oli.OpportunityId)).Quantity__c != null && (mapofSegQty_Clone_APJ.get(oppIds.get(oli.OpportunityId)).IsActive__c || (mapofSegQty_Clone_APJ.containsKey(oppIds.get(oli.OpportunityId)) && (mapofSeg_Clone_APJ.containsKey(oppIdSeg.get(oli.OpportunityId)) || oppIdSeg.get(oli.OpportunityId) == null)))){
                       if(GetHourDifferenceBtwTwoDateTime(oli.CreatedDate,DateTime.now()) >= config.Hour_Limit_for_Sending_Email__c && oli.Quantity >= mapofSegQty_Clone_APJ.get(oppIds.get(oli.OpportunityId)).Quantity__c && mapofSegQty_Clone_APJ.containsKey(oppIds.get(oli.OpportunityId)) && (mapofSeg_Clone_APJ.containsKey(oppIdSeg.get(oli.OpportunityId)) || oppIdSeg.get(oli.OpportunityId) == null)){
                            if(!mapOppToOppProd.containsKey(oli.OpportunityId)){
                                mapOppToOppProd.put(oli.OpportunityId,new List<OpportunityLineItem>{oli});
                            }
                            else{
                                mapOppToOppProd.get(oli.OpportunityId).add(oli);
                            }
                            mapOppToOwner.put(oli.OpportunityId,oli.Opportunity.OwnerId);
                       }
                   }
               } 
            } 
            //EMEA
            if(Label.Countries_EMEA_Contrlr.Contains(oli.Opportunity.Account.Account_Country_Code__c)){
               if(mapofSegQty_Clone_EMEA.containsKey(oppIds.get(oli.OpportunityId)) && ( oli.Opportunity.Account.Sales_Channel__r.Segment_Business_Unit_Name__c != null && set_Biz_Unit_Seg_EMEA.contains(oli.Opportunity.Account.Sales_Channel__r.Segment_Business_Unit_Name__c.toUpperCase()))){
                   if(mapofSegQty_Clone_EMEA.get(oppIds.get(oli.OpportunityId)).Quantity__c != null && (mapofSegQty_Clone_EMEA.get(oppIds.get(oli.OpportunityId)).IsActive__c || (mapofSegQty_Clone_EMEA.containsKey(oppIds.get(oli.OpportunityId)) && (mapofSeg_Clone_EMEA.containsKey(oppIdSeg.get(oli.OpportunityId)) || oppIdSeg.get(oli.OpportunityId) == null)))){
        
                       if(GetHourDifferenceBtwTwoDateTime(oli.CreatedDate,DateTime.now()) >= config.Hour_Limit_for_Sending_Email__c && oli.Quantity >= mapofSegQty_Clone_EMEA.get(oppIds.get(oli.OpportunityId)).Quantity__c && mapofSegQty_Clone_EMEA.containsKey(oppIds.get(oli.OpportunityId)) && (mapofSeg_Clone_EMEA.containsKey(oppIdSeg.get(oli.OpportunityId)) || oppIdSeg.get(oli.OpportunityId) == null)){
                            if(!mapOppToOppProd.containsKey(oli.OpportunityId)){
                                mapOppToOppProd.put(oli.OpportunityId,new List<OpportunityLineItem>{oli});
                            }
                            else{
                                mapOppToOppProd.get(oli.OpportunityId).add(oli);
                            }
                            mapOppToOwner.put(oli.OpportunityId,oli.Opportunity.OwnerId);
                       }
                   }
               } 
            }                     
        }
        if(!mapOppToOppProd.isEmpty()){
            //Send Email Code.
            OrgWideEmailAddress owa = [select id, DisplayName, Address from OrgWideEmailAddress Where DisplayName = 'No_Reply Mailbox' limit 1];
            EmailTemplate templateId = [Select id from EmailTemplate where name = 'Octane_Reminder_Template'];
            List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
            List<OpportunityLineItem> lstOliToUpdate = new List<OpportunityLineItem>();
            for(Id idOpp:mapOppToOppProd.keyset()){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateID(templateId.Id); 
                mail.setTargetObjectId(mapOppToOwner.get(idOpp));
                mail.setWhatId(idOpp);
                mail.setOrgWideEmailAddressId(owa.id);
                mail.setSaveAsActivity(false);
                allmsg.add(mail);
                for(OpportunityLineItem oliChild:mapOppToOppProd.get(idOpp)){
                    OpportunityLineItem sObj = new OpportunityLineItem(Id = oliChild.Id);
                    sObj.Octane_Reminder_Email_Sent__c = true;
                    lstOliToUpdate.add(sObj);
                }
            }
            if(allmsg.size() > 0){
              Messaging.sendEmail(allmsg,false); 
            }
            if(lstOliToUpdate.size() > 0){
                 TriggerExecutionController.setSkipOpportunityTriggers(true);
                 TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
                 Database.SaveResult[] results = Database.Update(lstOliToUpdate, false);
                 TriggerExecutionController.setSkipOpportunityTriggers(false);
                 TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
            }
        }       
        //Send Email Code Ends.     
    }
     
    global void finish(Database.BatchableContext BC){
           
    }
}