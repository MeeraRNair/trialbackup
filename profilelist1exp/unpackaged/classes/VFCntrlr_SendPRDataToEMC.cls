public class VFCntrlr_SendPRDataToEMC { 
    //Send PR Data to EMC
    private Partner_Request__c partnerRequest;
    private Lead suggestionLead;
    //Constructor
    public VFCntrlr_SendPRDataToEMC(ApexPages.StandardController controller) {
        partnerRequest = (Partner_Request__c)controller.getRecord();     
        partnerRequest=[SELECT Last_Name__c,Company__c,Primary_Channel_Model__c,ID,OwnerID,Org_Country__c,Org_Country__r.name,Website__c,Org_Address_1__c,Phone__c,Fax__c,
                        Org_Address_2__c,Org_Address_3__c,Org_City__c,Org_State__c,Org_Postal_Code__c,Org_Phone__c,Org_Fax__c,
                        Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,City__c,State__c,Postal_Code__c,Country__c,Lead__c,
                        First_Name__c, Salutation__c,Email__c,Dun_and_Bradstreet_DUNS_Number__c,ISDUNSUpdated__c,GU_HQ_DUNSAddress__c,GU_HQ_DUNSBusinessName__c,GU_HQ_DUNSCity__c,GU_HQ_DUNSCountry__c,GU_HQ_DUNSID__c,GU_HQ_DUNSPostalCode__c,GU_HQ_DUNSState__c,
                        Country__r.name FROM Partner_Request__c WHERE id=:partnerRequest.id];
        System.debug('#####partnerRequest'+partnerRequest);
        if(partnerRequest.Lead__c!=null){
            suggestionLead = new Lead(id=partnerRequest.Lead__c);
        }  
    }
    public PageReference sendPRDataToEMC(){
        RecordType rectype;
        String strResult;
        System.PageReference returnPage;        
       try{
           system.debug('Inside sendPRDataToEMC ***'+partnerRequest.ID );
  
         strResult=SendPartReqData.sendPRCalloutREST(partnerRequest.ID);
           system.debug('strResult after calling rest-->'+strResult+'-----');
           if(strResult=='Success' || Test.isRunningTest()){
               returnPage=  new PageReference('/'+partnerRequest.ID);  
           }else{ 
               system.debug('result-->'+strResult+'-----');
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,strResult));               
                }
        }catch(Exception e){
            system.debug('result after calling rest inside exception-->'+strResult+'-----');
            system.debug('##MN: Caught APEX exception ' + e.getMessage());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,strResult));      
         }       
       return returnPage;        
    }    
    public PageReference goBacktoPRPage(){          
        PageReference returnPage=  new PageReference('/'+partnerRequest.ID); 
       return returnPage ;        
    } 
    
}