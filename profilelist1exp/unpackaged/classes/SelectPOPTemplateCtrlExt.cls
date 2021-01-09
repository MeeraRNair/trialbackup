public class SelectPOPTemplateCtrlExt{

    Proof_of_Performance_POP__c POPRecord;
    Map<String,RecordType> MDFProgramRcdTypeMap = new Map<String,RecordType>();
    
    public SelectPOPTemplateCtrlExt(ApexPages.StandardController controller) {
        for(RecordType recType:[select id,name,SobjectType from RecordType 
                               where SobjectType='MDF_Program__c']){
            MDFProgramRcdTypeMap.put(recType.name,recType);                        
        }       
        POPRecord = [select Id, Name, MDF_Program__r.RecordTypeId from Proof_of_Performance_POP__c where id=:controller.getId()];

    }
    
    public PageReference selectPOPTemplates(){
        
        PageReference pageRef;
        
        if(POPRecord.MDF_Program__r.RecordTypeId == MDFProgramRcdTypeMap.get('Headcount').Id){
            pageRef = new PageReference('/apex/HeadcountPOPForm?id='+POPRecord.Id);
        }

        if((POPRecord.MDF_Program__r.RecordTypeId == MDFProgramRcdTypeMap.get('Event').Id) ||
        // Mohan 20110606 BRD 8.4.1.3
        	(POPRecord.MDF_Program__r.RecordTypeId == MDFProgramRcdTypeMap.get('Field Event').Id) ||
        // 
            (POPRecord.MDF_Program__r.RecordTypeId == MDFProgramRcdTypeMap.get('Training').Id)){ 
            pageRef = new PageReference('/apex/EventTrainingPOPForm?id='+POPRecord.Id);
        }
        return pageRef;
        
    }

}