/*********************************************************************************************************************************
REVISION HISTORY
================
Version     Author        Date            Release#    CR#     Description
-------     ------        ----            --------    ---     -----------
1.0      Krishnamoorthi  14-Dec-2012        14.2      7679    Created for - R14.2 Maintenance - PRM - CMI XML creation in SFDC

***********************************************************************************************************************************/
public class VFCntrlr_CMIXML {

    Public String inputValue{get;set;}
    Public String myAccountGUID{get;set;}
    public String contactGUID {get;set;}    
    public Boolean hasResult { get; set; }    
    Public String Response{get;set;}
    Public String Request{get;set;}
    Public Contact contactRec {get;set;}
    Public Boolean onload;
    
    public VFCntrlr_CMIXML(){
        
        inputValue = PageUtils.get('inputValue');
        hasResult = false;
        onload = true;
    
    }
    
     public PageReference sendHttpRequest() {
        
        hasResult = false;
             
        if(inputValue != '' && inputValue != null ){
            if((inputValue.length() == 15 || inputValue.length() == 18)  && inputValue.startsWith('003')) {
                contactRec = getContact(inputValue,'Id' );
            }
            //else if(inputValue.contains('.com') || inputValue.endsWith('.com'))
            else if(inputValue.contains('@') || inputValue.endsWith('@')){
                contactRec = getContact(inputValue, 'Email');
            }
            else {
                contactRec = getContact(inputValue ,'Partner_My_Account_GUID__c' ); 
            }
            
                                 
        }
        else{
                if(!onload){
                    //PageUtils.addError('Please enter atleast one value');    
                      PageUtils.addError('Contact not found. Please enter the correct “Partner My Account GUID” or “SFDC Contact ID” or “Email” to proceed.');          
                }
            
            onload = false;
            return null;
        }
        
                
        if(contactRec == null){
            PageUtils.addError('Contact not found. Please enter the correct “Partner My Account GUID” or “SFDC Contact ID” or “Email” to proceed.');            
            return null;
        }
        
        if(contactRec.Account.Account_Id__c == null){
            PageUtils.addError('Partner Account is invalid. No Party ID found');            
            return null;
        }
        try{
            Request=  '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cmi="http://cmi.us.dell.com"><soapenv:Header/><soapenv:Body><cmi:GetSegmentationData><cmi:partyId>'+ contactRec.Account.Account_Id__c +'</cmi:partyId><cmi:cesrId></cmi:cesrId><cmi:contactId>'+ contactRec.Partner_My_Account_GUID__c+'</cmi:contactId><cmi:locationId></cmi:locationId><cmi:group>Partner</cmi:group><cmi:application>SFDC</cmi:application></cmi:GetSegmentationData></soapenv:Body></soapenv:Envelope>';
            HTTPResponse res = PartnerProfileIntegration.sendHttpRequest(Request);
            Response = res.getBody();
            hasResult = true;
        }catch(Exception e){
        
            PageUtils.addError('Exception : ' + e.getMessage());
            return null;
        }
        return null;
    } 
    
     public Contact getContact(String identifier, String field){
        Contact con;
        List<contact> conList = (List<contact>)Database.query('SELECT Id, Partner_My_Account_GUID__c, Email, Account.Account_Id__c FROM Contact WHERE Partner_My_Account_GUID__c !=null AND '+field + '=\''+identifier + '\'' );
        if(conList!=null && conList.size()>0)
            con = conList[0];
        
        return con;    
    }
}