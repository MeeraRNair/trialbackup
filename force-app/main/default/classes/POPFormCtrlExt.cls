public class POPFormCtrlExt {
    
    Proof_of_Performance_POP__c POPRec;
    List<POP_Line_Item__c> POPLineItemList = new List<POP_Line_Item__c>();
    // Mohan 20110606 BRD 8.4.1.3
    List<Associated_Programs_Vendors__c> apvList = new List<Associated_Programs_Vendors__c>();
    //
    public Id LastRecId;

    public POPFormCtrlExt(ApexPages.StandardController controller) {
        
        POPRec = [select Id, Name, Business_Segment__c, Fiscal_Quarter__c,
        // Mohan 20110606 BRD 8.4.1.3
        MDF_Program__c, 
        // Aman Sharma CR 8392 BR024
        Region__c,Sub_Region__c,
        //
        MDF_Program__r.name,MDF_Program__r.recordtypeid,
        // sharad chhaparwal Story 3075049 Viper(Wunderkind)
        MDF_Program__r.Program_Type__c
        from Proof_of_Performance_POP__c where id =: controller.getId() ]; 

        // Mohan 20110606 BRD 8.4.1.3
        Map<String,RecordType> MDFProgramRcdTypeMap = new Map<String,RecordType>();
        for(RecordType recType:[select id,name,SobjectType from RecordType 
                               where SobjectType='MDF_Program__c']){
            MDFProgramRcdTypeMap.put(recType.name,recType);                        
        }
        if((POPRec.MDF_Program__r.RecordTypeId == MDFProgramRcdTypeMap.get('Event').Id) ||
            (POPRec.MDF_Program__r.RecordTypeId == MDFProgramRcdTypeMap.get('Field Event').Id) ||
            (POPRec.MDF_Program__r.RecordTypeId == MDFProgramRcdTypeMap.get('Training').Id)){
            // changes done in query add last and condition for 4809142 story by sharad
            apvList = [Select a.Vendor__r.Name, a.Vendor__c, a.Id, a.Status__c From Associated_Programs_Vendors__c a where a.APV_Status__c != 'Declined' 
            and a.MDF_Program__c = :POPRec.MDF_Program__c AND a.Status__c != 'Declined'];
        
            for(Associated_Programs_Vendors__c apv: apvList){
                LastRecId = apv.Id;
            }
        }
        else{
        //  
            POPLineItemList = [select id, Vendor__r.Name, Contract_Status__c
                from POP_Line_Item__c where Proof_of_Performance_POP__c =: POPRec.Id];
            
            for(POP_Line_Item__c pop: POPLineItemList){
                LastRecId = pop.Id;
            }
        // Mohan 20110606 BRD 8.4.1.3
        }
        //
    }

    public Proof_of_Performance_POP__c getPOPRec(){
        return POPRec;
    }

    public List<POP_Line_Item__c> getPOPLineItemList(){
        
        return POPLineItemList;
    }
    
    // Mohan 20110606 BRD 8.4.1.3
    public List<Associated_Programs_Vendors__c> getApvList(){
        //System.debug('!!!!!apvList' + apvList);
        return apvList;
    }
    //
    
    public Id getLastRecId(){
        return LastRecId;
    }    
    
}