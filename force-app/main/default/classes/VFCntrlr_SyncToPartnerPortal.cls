/*********************************************************************************************************************************************************************
REVISION HISTORY
================
Version     Author        Date            Release#    CR#     Description
-------     ------        ----            --------    ---     -----------
1.0      Krishnamoorthi  12-Dec-2012        14.2      7777    Created for - R14.2 Maintenance - PRM -Partner Provisioning enhance syncing Account and Contact with CMI

***********************************************************************************************************************************************************************/
public class VFCntrlr_SyncToPartnerPortal {

    public String recordId;
    public String recordIdPrefix; 
    public String respBody;
    public String objType {get;set;}
    public Boolean isSuccessAccount {get;set;}
    public Boolean isSuccessContact {get;set;}
    public Boolean isExistContact {get;set;}
    public String excepId {get;set;}
    
    public VFCntrlr_SyncToPartnerPortal() {
        
        this.recordId = ApexPages.currentPage().getParameters().get('Id');
        system.debug('##recordId' + recordId);
        
        isSuccessAccount = false;  
        isSuccessContact = false;
        isExistContact = false;
        objType='';
    }


    public void integratePartnerData() { 
        
        String respBody;
        
        //get the first three characters of the ID passed to this controller
        recordIdPrefix = StringUtils.defaultString(StringUtils.substring(recordId, 0, 3));
        
        //Determine if the recordid is of a Contact     
        if(recordIdPrefix.equals(Contact.sObjectType.getDescribe().getKeyPrefix())){                    
               objType = 'con';
               try {
                    respBody = PartnerProfileIntegration.sendContactInfo(recordId, null);
                    system.debug('##Contact respBody' + respBody);
               
                    isSuccessContact = checkResponse(respBody);
                    isExistContact = checkExistingCont(respBody);
                    
                    if(!isSuccessContact){
                        excepId = PartnerProfileIntegration.addIntegrationException('Contact',recordId,respBody);
                    }
                    
                }
                catch(Exception e){
                    isSuccessContact = false;
                    excepId = PartnerProfileIntegration.addIntegrationException('Contact',recordId,e.getTypeName(),e.getMessage(),respBody);                
                }
        }
                        
        //Determine if the recordid is of an Account
        else if(recordIdPrefix.equals(Account.sObjectType.getDescribe().getKeyPrefix())){
            objType = 'acc';
                try {
          
                    respBody = PartnerProfileIntegration.sendAccountInfoWithResponse(recordId);
                    system.debug('##Account respBody' + respBody);
                    
                    isSuccessAccount = checkResponse(respBody); 
                    
                    if(!isSuccessAccount){
                         excepId = PartnerProfileIntegration.addIntegrationException('Account',recordId,respBody);
                    }
                        PartnerPortalProfilingserviceIntegration.integratePartnerDataWithAccount(recordId);
                    
                }
                catch(Exception e){
                    isSuccessAccount = false;
                    excepId = PartnerProfileIntegration.addIntegrationException('Account',recordId,e.getTypeName(),e.getMessage(),respBody);                
            }
        }
            
        
    }   
    
    
    //Check whether the integration is true
    public static Boolean checkResponse(String response){

        if(response.contains('<InsertSegmentationDataResult>true</InsertSegmentationDataResult>')){         
            return true;
        }
        return false;
    }
    
    //Check the Contact is already associated with different Account 
    public static Boolean checkExistingCont(String resp){

        if(resp.contains('ContactId is already associated with a different Parent')){           
            return true;
        }
        return false;
    }
    
    public PageReference ok() {
        return PageUtils.redirect('/' + recordId);
    }
}