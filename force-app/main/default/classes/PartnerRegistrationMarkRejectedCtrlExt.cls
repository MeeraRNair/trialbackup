public class PartnerRegistrationMarkRejectedCtrlExt{
    public Partner_Request__c registration {get;set;}
    public Boolean isVisible {get;set;} //CR 3410 : add control to other reason textarea box
    
    public PartnerRegistrationMarkRejectedCtrlExt(ApexPages.StandardController c){
        registration = (Partner_Request__c) c.getRecord();
        List<Partner_Request__c> recordList = 
            [select id, Rejection_Reason__c, name
            from Partner_Request__c 
            where id = :registration.id limit 1];
        if(recordList.isEmpty()){ 
            PageUtils.addError('Record not found.');
            return;
        }
        registration = recordList.get(0);
        registration.Rejection_Reason__c = '';
    }
    
    //CR 3410 : Rejection Reason for Partner and Deal Reg Enhancement
    //Purpose : When picklist value change, if it is "other" as picklist value, then visible = true 
    public PageReference doRejectionReasonChange(){
        if(StringUtils.isNotBlank(registration.Rejection_Reason__c)){
            String[] retStrList = doParsePicklistStr(registration.Rejection_Reason__c);     
            isVisible           = isTargetValue(retStrList);
        }else{
            isVisible           = false; 
        }
        return null;
    } 
    
    public String[] doParsePicklistStr(String tempStr){
        return StringUtils.split(tempStr, ';');     
    }
    
    public Boolean isTargetValue(String[] tempStrList){     
        for(String listValue : tempStrList){
            if(StringUtils.equalsIgnoreCase(listValue, 'To Clarify')) return true;
        }       
        return false;       
    }
     
    public PageReference doSave(){
        if(StringUtils.isBlank(registration.Rejection_Reason__c)){
            PageUtils.addError('Please select a Rejection Reason');
            return null;
        }
        
        if(isVisible && StringUtils.isBlank(registration.Other_Reason__c)){
            PageUtils.addError('Please enter comment for To Clarify Reason(s)');
            return null;
        }
        
        registration.Status__c = PartnerConstants.REG_STATUS_REJECTED;
        try{
            update registration;
        }catch( Exception e ){
            PageUtils.addError('Failed update Registration status to: ' + PartnerConstants.REG_STATUS_INCOMPLETE 
                + '.  Error is: ' + e.getMessage());
            return null;
        }
        return PageUtils.redirect('/' + registration.id);
    }

    public PageReference doCancel(){
        return PageUtils.redirect('/' + registration.id);
    }
}