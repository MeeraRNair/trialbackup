/*
* @Author     : Prasanthi M
* Purpose      : To update PPAUCID and otherInfo to SuggestionAPI 
* Created Date : 1/17/2019
* 
*/
public class VFCntrlr_UpdateSuggestion {
    //get UCID from Suggestion ID
    private Partner_Request__c partnerRequest;
    private Lead suggestionLead; 
    public VFCntrlr_UpdateSuggestion(ApexPages.StandardController controller){
        partnerRequest = (Partner_Request__c)controller.getRecord();
        partnerRequest=[SELECT Last_Name__c,Company__c,Primary_Channel_Model__c,ID,OwnerID,Org_Country__c,Link_To_Account_Flag__c,Org_Country__r.name,Website__c,Org_Address_1__c,Phone__c,Fax__c,
                        Org_Address_2__c,Org_Address_3__c,Org_City__c,Org_State__c,Org_Postal_Code__c,Org_Phone__c,Org_Fax__c,
                        Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,City__c,State__c,Postal_Code__c,Country__c,Lead__c,
                        First_Name__c, Salutation__c,Email__c,Dun_and_Bradstreet_DUNS_Number__c,ISDUNSUpdated__c,GU_HQ_DUNSAddress__c,GU_HQ_DUNSBusinessName__c,GU_HQ_DUNSCity__c,GU_HQ_DUNSCountry__c,GU_HQ_DUNSID__c,GU_HQ_DUNSPostalCode__c,GU_HQ_DUNSState__c,
                        Country__r.name,Update_Account_In_GAMA_Is_Complete_Flag__c 
                        FROM Partner_Request__c
                        WHERE id=:partnerRequest.id];
        
        System.debug('#####partnerRequest'+partnerRequest);
        if(partnerRequest.Lead__c!=null){
            suggestionLead = new Lead(id=partnerRequest.Lead__c);
        }  
    }
    public PageReference updateSugg(){
        RecordType rectype;
        String strresult;
        System.PageReference returnPage;
        
        try{
            
            system.debug('Inside VFCntrlr_UpdateSuggestion ***'+partnerRequest.ID );
            If(partnerRequest.Link_To_Account_Flag__c == true){
             strresult=UpdateSuggestion.updateGamaSuggestionWhenLinkToAccountisUsed(partnerRequest.ID);
             system.debug('****result-->'+strresult);   
            }else{
             strresult=UpdateSuggestion.invokeUpdateSuggestion(partnerRequest.ID);
             system.debug('result after calling rest-->'+strresult+'-----');
            }
            
            
            if(strresult=='Success'){
                returnPage=  new PageReference('/'+partnerRequest.ID);  
            }else{ 
                system.debug('result-->'+strresult+'-----');
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,strresult));               
            }
        }catch(Exception e){
            system.debug('result after calling rest inside exception-->'+strresult+'-----');
            system.debug('##MN: Caught APEX exception ' + e.getMessage());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,strresult));         
        }
        
        return returnPage;
    }
    public PageReference goBacktoPRPage(){ 
        
        PageReference returnPage=  new PageReference('/'+partnerRequest.ID); 
        return returnPage ;
        
    }
}