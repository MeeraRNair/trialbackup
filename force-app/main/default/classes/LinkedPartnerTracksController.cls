public class LinkedPartnerTracksController {
    private ApexPages.StandardController controller;
    private ID contactID;
    public contact conObj{get; set;}
    public Map<Id, Partner_Track__c> mapPartnerTrackDetails {get; set;}
    public boolean bprefferedTrue {get; set;}
    public boolean bprefferedFalse {get;set;}
    public boolean baddtracks {get;set;}
    public integer inttotalrecs {get;set;}
    public integer intoffsetSize {get;set;}
    public integer intlimitSize{get;set;}
    public Integer intmSize;
    // Added For Audit Tracks
    public list<String> listAuditTracksId {get;set;}
    public boolean bPortalEnabled {get;set;}
    
    /*private integer inttotalrecs = 0;
private integer intoffsetSize = 0;
private integer intlimitSize= 2; */
    
    
    public LinkedPartnerTracksController(ApexPages.StandardController controller) {
        this.controller = controller;
        contactID=controller.getId();
        bprefferedTrue = true;
        baddtracks = false;
        inttotalrecs = 0;
        intoffsetSize = 0;
        intlimitSize= 5;
        bPortalEnabled = [SELECT IsPortalEnabled FROM USER WHERE Id =: UserInfo.getUserId()].IsPortalEnabled;
        system.debug('contactID'+contactID);
        if(contactID!=null){
            conObj = [select id,EligibleTracks__c,Preferred_Track__c,Enable_as_Partner_Group_Administrator__c,Audit_Track__c from contact where id = :contactID];}
        init();
    }
    
    
    
    
    List<String> listeligibleTracksIdList =  new List<String>();
    
    public void init(){
        system.debug('conlist'+conObj);
        mapPartnerTrackDetails = new Map<Id, Partner_Track__c>();
        listAuditTracksId = new List<String>();
        
        // EligibleTracks Names
        if(conObj!=null){
            if(conObj.EligibleTracks__c != null){
                List<String> listeligibleTracksId = conObj.EligibleTracks__c.split(';');
                
                system.debug('eligibleTracksId '+listeligibleTracksId);
                for(String stregTrackId: listeligibleTracksId){
                    listeligibleTracksIdList.add(stregTrackId);    
                } 
            }   
            if(conObj.Audit_Track__c != null){
                listAuditTracksId = conObj.Audit_Track__c.split(';');
            }
        }
        if(listeligibleTracksIdList !=null){
            list<Partner_Track__c> listtotalPT = [SELECT Id,Name,Track_Id__c,Partner_Track_Name__c,Track_Name__c FROM Partner_Track__c WHERE Id IN: listeligibleTracksIdList];
            
            
            intmSize = listtotalPT.size();
            
        } 
        for(Partner_Track__c partnerTrack : [SELECT Id,Name,Track_Id__c,Partner_Track_Name__c,Track_Name__c FROM Partner_Track__c WHERE Id IN: listeligibleTracksIdList LIMIT :intlimitSize OFFSET :intoffsetSize]){
            mapPartnerTrackDetails.put(partnerTrack.id, partnerTrack);
        }
        inttotalrecs = intmSize;
        system.debug('inttotalrecs'+inttotalrecs );
    }
    
    public map<id,Partner_Track__c> getTable(){
        mapPartnerTrackDetails.clear();
        for(Partner_Track__c partnerTrack : [SELECT Id,Name,Track_Id__c,Partner_Track_Name__c,Track_Name__c FROM Partner_Track__c WHERE Id IN: listeligibleTracksIdList LIMIT :intlimitSize OFFSET :intoffsetSize]){
            mapPartnerTrackDetails.put(partnerTrack.id, partnerTrack);
            
            
        }
        return mapPartnerTrackDetails;
    }
    
    public PageReference showall(){
        
        for(Partner_Track__c partnerTrack : [SELECT Id,Name,Track_Id__c,Partner_Track_Name__c,Track_Name__c FROM Partner_Track__c WHERE Id IN: listeligibleTracksIdList]){
            mapPartnerTrackDetails.put(partnerTrack.id, partnerTrack);
        }
        PageReference pageRef = new PageReference('/apex/LinkedPartnerTracksDetails');
        
        return pageRef ;
        //return null;
    }
    public void firstPage(){
        intoffsetSize = 0;
    }
    public void previous(){
        intoffsetSize = intoffsetSize - math.mod(intlimitSize,inttotalrecs);
    }
    public void next(){
        intoffsetSize = intoffsetSize + intlimitSize;
    }
    
    public void lastPage(){
        intoffsetSize = inttotalrecs - math.mod(inttotalrecs,intlimitSize);
    }
    
    public boolean getprev(){
        if(intoffsetSize == 0){
            return true;}
        else{
            return false;}
    }
    
    public boolean getnxt(){
        if((intoffsetSize + intlimitSize) >= inttotalrecs){
            return true;}
        else{
            return false;}
    }
    
    
    public PageReference addTrack(){
        system.debug('>>>contactID'+contactID);
        if(conObj.Enable_as_Partner_Group_Administrator__c== True){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Contact is enabled as group administrator. If you wish to add or remove tracks, disable them as group administrator.');
            ApexPages.addMessage(myMsg);
            return null;
        }
        else{
            PageReference pr = new PageReference('/apex/AddNewPartnerTracksToContact?Conid='+contactID+'&PartnerTrack=true&AuditTrack=false');
            return pr;
        }
    }
    public PageReference addAuditTracks(){
        PageReference pr = new PageReference('/apex/AddNewPartnerTracksToContact?Conid='+contactID+'&PartnerTrack=false&AuditTrack=true'); 
        return pr;
    }
    
    
}