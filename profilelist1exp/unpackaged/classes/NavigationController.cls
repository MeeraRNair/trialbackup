public with sharing class NavigationController {
    String CERecord;
    String CERecordName;
    String recordTypename;
    List<RecordType> recordTypelist=new List<RecordType>();
    List<SelectOption> options = new List<SelectOption>();       
    String URL;
    
    public NavigationController(ApexPages.StandardController controller) {
        CERecord=ApexPages.currentPage().getParameters().get('CF00NA00000063PNB_lkid');
        CERecordName=ApexPages.currentPage().getParameters().get('CF00NA00000063PNB');
        recordTypelist=[select Id,Name, Description from RecordType where SobjectType='Attendees__c' and Name != 'Topic Expert' order by Name ];
    }
        
    public String getrecordTypename(){ 
        return recordTypename;
    }
    
    public void setrecordTypename(String recordTypename){   
        this.recordTypename=recordTypename;    
    }
    
    public List<RecordType> getrecordTypelist(){ 
        return recordTypelist;
    }

    public List<SelectOption> getrecordTypenames() {
        try{   
            if(recordTypelist == NULL){
                PageUtils.addError('Record Type List is Blank');
            }
            for (RecordType recordTypenames : recordTypelist){
                options.add(new SelectOption(recordTypenames.Name, recordTypenames.Name));
            }
        return options;
        }
        catch(Exception e){
            PageUtils.addError('Record Type List is Blank');
            System.debug('Exception Occured in record type picklist display:'+e);
            return options;
        }
    }
    
    public PageReference Continuebutton() {
        if(recordTypename == 'Account Team'){
            URL = '/apex/AttendeePage?CEId='+CERecord;        
        }
        else if(recordTypename == 'Customer'){
            URL = '/apex/Customerpage?CEId='+CERecord;        
        }
        else if(recordTypename == 'Dell Internal'){
            Id rtlistDI=IdLookupUtils.getRecordTypeId('Dell Internal','Attendees__c',true);
            URL = '/a14/e?RecordType='+rtlistDI+'&nooverride=1&CF00NA00000063PNB_lkid='+CERecord+'&CF00NA00000063PNB='+CERecordName+'&retURL=/'+CERecord+'&saveURL=/'+CERecord ;        
        }
        else if(recordTypename == 'Vendor/Partner'){
           Id rtlistVP=IdLookupUtils.getRecordTypeId('Vendor/Partner','Attendees__c',true);
           URL = '/a14/e?RecordType='+rtlistVP+'&nooverride=1&CF00NA00000063PNB_lkid='+CERecord+'&CF00NA00000063PNB='+CERecordName+'&retURL=/'+CERecord+'&saveURL=/'+CERecord ;        
        }
        return PageUtils.redirect(URL);
    }
    
    public PageReference Cancelbutton() {
        return PageUtils.redirect('/'+CERecord);
    }
}