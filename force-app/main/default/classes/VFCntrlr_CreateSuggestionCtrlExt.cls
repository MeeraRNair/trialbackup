/*-------------------------------------------------
Description: Helper Class  for creating Suggestion Lead for Partner Request
CR #1378
Version:1.0

History:
1.0 - 17-July-2009: Creation
Author: Meera Nair
------------------------------------------------------------------------------------------------------------------------------
*Revision  Name      Date        CR       Description                                  
* 1.0     Sajid    04.08.2017   14726   Added logic to map address fields from Postal to Legal Local  for China,Japan,Korea countries  
-------------------------------------------------------------------------------------------------------------------------------------*/

public class VFCntrlr_CreateSuggestionCtrlExt {
    
    //Define class variables
    private Partner_Request__c partnerRequest;
    private String partnerId;
    private String returnURL;
    private Lead suggestionLead;
    private Country__c countryList;
    private Account mastergroupaccounts;
    //Constructor
    public VFCntrlr_CreateSuggestionCtrlExt(ApexPages.StandardController controller) {
        partnerRequest = (Partner_Request__c)controller.getRecord();  
        partnerRequest=[SELECT Last_Name__c,Link_To_Account_Flag__c,Company__c,Primary_Channel_Model__c,ID,OwnerID,Org_Country__c,Org_Country__r.name,Website__c,Org_Address_1__c,Phone__c,Fax__c,
                        Org_Address_2__c,Org_Address_3__c,Org_City__c,Org_State__c,Org_Postal_Code__c,Org_Phone__c,Org_Fax__c,
                        Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,City__c,State__c,Postal_Code__c,Country__c,Lead__c,
                        First_Name__c, Salutation__c,Email__c,Dun_and_Bradstreet_DUNS_Number__c,ISDUNSUpdated__c,GU_HQ_DUNSAddress__c,GU_HQ_DUNSBusinessName__c,GU_HQ_DUNSCity__c,GU_HQ_DUNSCountry__c,GU_HQ_DUNSID__c,GU_HQ_DUNSPostalCode__c,GU_HQ_DUNSState__c,
                        Country__r.name //Added on 07-Aug-17
                        FROM Partner_Request__c
                        WHERE id=:partnerRequest.id];
        
        System.debug('#####partnerRequest'+partnerRequest);
        if(partnerRequest.Lead__c!=null){
            suggestionLead = new Lead(id=partnerRequest.Lead__c);
        }  
    }
    
    //Method to navigate to the Lead changing it's RecordType
    public PageReference navigateToLead(){
        string strresultFromFetchGUDUNS;
        RecordType rectype;
        try{ 
            system.debug('****suggestionLead :-' +suggestionLead);
            if(suggestionLead==null){
                system.debug('***suggestionLead :-' +suggestionLead);
                suggestionLead=new Lead();
                suggestionLead.LastName = partnerRequest.Last_Name__c;
                suggestionLead.Company = partnerRequest.Company__c;
                suggestionLead.Status = 'Open';
                suggestionLead.Account_Category__c = 'Partner'; 
                suggestionLead.Partner_Request__c = partnerRequest.ID;
                insert suggestionLead;
                system.debug('==suggestionLead==>>'+suggestionLead.Id);
                partnerRequest.Lead__c = suggestionLead.id;
                update partnerRequest;
                system.debug('==Partner Requesu==>>'+partnerRequest.Id);
            }
            system.debug('==Partner Requesuttt==>');
            rectype=[Select Name, Id,SobjectType From RecordType where Name='Account Suggestion' AND SobjectType='Lead' Limit 1];
            suggestionLead.Postal_Country__c = partnerRequest.Country__c;
            
            suggestionLead.Postal_Phone__c = partnerRequest.Phone__c;
            suggestionLead.Postal_Fax__c = partnerRequest.Fax__c;
            
            
            
        }catch(Exception e){
            system.debug('##MN: Caught APEX exception ' + e.getMessage());
            system.debug('##MN: Caught suggestionLead ' + suggestionLead);
            emailUtils.sendSupportEmail(e.getMessage()+'[ Code:  VFCntrlr_CreateSuggestionCtrlExt.navigateToLead() ]', dellConfig.errorEmail);
        }
        System.debug('MN:#####suggestionLead: '+suggestionLead);
        system.debug(partnerRequest.ISDUNSUpdated__c+'====Udate====>>'+partnerRequest.id);
        
        if(partnerRequest.Link_To_Account_Flag__c == false){
        strresultFromFetchGUDUNS= Vfcntrl_FetchGUDUNS.getGUDUNS(partnerRequest.id,partnerRequest.ISDUNSUpdated__c);
        
        returnURL='/apex/SelectLeadDataVFpage?RecordType='+PageUtils.encodeVariable(rectype.id) 
            +'&cancelURL='+PageUtils.encodeVariable(partnerRequest.Id)
            +'&LeadId='+partnerRequest.Lead__c
            +'&PartnerId='+partnerRequest.Id
            +'&resultFromFetchGUDUNS='+strresultFromFetchGUDUNS
            +'&retURL='+PageUtils.encodeVariable(partnerRequest.Lead__c)
            +'&save_new_url='+PageUtils.encodeVariable(partnerRequest.Lead__c);
        }else{
         returnURL = '/apex/UcidSelectionVfPage?'
                    +'&LeadId='+partnerRequest.Lead__c
             		+'&UcidSelection='+true;
             		
        }
        
        System.debug('###returnURLFrom Page: '+returnURL); 
        return new PageReference(returnURL); 
        
        
    } 
}