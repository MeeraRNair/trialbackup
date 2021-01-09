public class VFCntlr_selectSOW{
    Marketing_Plan__c marketingPlanRec;
    Map<String,RecordType> recTypeMap=new Map<String,RecordType>();    
    
    public VFCntlr_selectSOW(ApexPages.StandardController controller) {
        for(RecordType recType:[select id,name,SobjectType  from RecordType 
                                where SobjectType='Marketing_Plan__c']){
            recTypeMap.put(recType.name,recType);                        
        }        
        marketingPlanRec=[select id,Contract_Status__c,Contract_Type__c,vendor__c,
        vendor__r.Ala_Carte_SOW_Template__c,vendor__r.Headcount_SOW_Template__c,vendor__r.Rebates_SOW_Template__c,
        vendor__r.Volume_Based_SOW_Template__c,recordTypeId from Marketing_Plan__c where id=:controller.getId()];
    }
    
    public PageReference selectSOWTemplates(){
        PageReference pageRef;
        
        if(marketingPlanRec.recordTypeId==recTypeMap.get('Ala Carte Marketing Plan').Id && 
            marketingPlanRec.Contract_Type__c=='Ala Carte' ){
            if(marketingPlanRec.vendor__r.Ala_Carte_SOW_Template__c=='OEM'){
                pageRef=new PageReference('/apex/SOW_AlaCarte_OEM?id='+marketingPlanRec.Id);
            }
            if(marketingPlanRec.vendor__r.Ala_Carte_SOW_Template__c=='Default'){
                pageRef=new PageReference('/apex/SOWNonCogs?id='+marketingPlanRec.Id);
            }
            if(marketingPlanRec.vendor__r.Ala_Carte_SOW_Template__c=='Ingram Micro'){
                pageRef=new PageReference('/apex/SOWAlaCarteIngramMicro?id='+marketingPlanRec.Id);
            }
        } 
        if(marketingPlanRec.recordTypeId==recTypeMap.get('Headcount Marketing Plan').Id && 
            marketingPlanRec.Contract_Type__c=='Headcount'){            
            if(marketingPlanRec.vendor__r.Headcount_SOW_Template__c=='OEM'){
                pageRef=new PageReference('/apex/SOW_Headcount_OEM?id='+marketingPlanRec.Id);
            }
            if(marketingPlanRec.vendor__r.Headcount_SOW_Template__c=='Default'){
                pageRef=new PageReference('/apex/SOWHeadCount?id='+marketingPlanRec.Id);
            }
            if(marketingPlanRec.vendor__r.Headcount_SOW_Template__c=='Ingram Micro'){
                pageRef=new PageReference('/apex/SOWHeadcountIngramMicro?id='+marketingPlanRec.Id);
            }
        }
        if(marketingPlanRec.recordTypeId==recTypeMap.get('Rebates Marketing Plan').Id && 
            marketingPlanRec.Contract_Type__c=='Rebates'){
            if(marketingPlanRec.vendor__r.Rebates_SOW_Template__c=='OEM'){
                pageRef=new PageReference('/apex/SOWDefault?id='+marketingPlanRec.Id);
            }
            if(marketingPlanRec.vendor__r.Rebates_SOW_Template__c=='Default'){
                pageRef=new PageReference('/apex/SOWRebates?id='+marketingPlanRec.Id);
            }
        }
        if(marketingPlanRec.recordTypeId==recTypeMap.get('Volume Based Marketing Plan').Id && 
            marketingPlanRec.Contract_Type__c=='Volume Based'){
            if(marketingPlanRec.vendor__r.Volume_Based_SOW_Template__c=='OEM'){
                pageRef=new PageReference('/apex/SOWCOGSOEM?id='+marketingPlanRec.Id);
            }
            if(marketingPlanRec.vendor__r.Volume_Based_SOW_Template__c=='Default'){
                pageRef=new PageReference('/apex/SOWCogs?id='+marketingPlanRec.Id);
            }
        }
        
        return pageRef;
        
    }
}