public class AddNewPartnerTracksToContactExtension{
    
    
    Public List<string> listleftselected{get;set;}
    Public List<string> listrightselected{get;set;}
    public Id accountId;    
    public String strContactId{get;set;}
    public set<string> seteligibleTracksId = new set<string>() ;
    public set<string> setEligibleTrackListIds= new set<string>() ;
    public Set<string> setLefttracks = new set<string>();
    public set<string> setrighttracks = new set<string>();
    public String strAuditTrack {get;set;}
    public String strARPartnerTrack {get;set;}
    
    public Set<string> setAuditTracksId = new Set<string>() ;
    
    
    contact contactToUpdate;
    String strPreferredtrack;
    String strSelecttrack;
    
    
    public AddNewPartnerTracksToContactExtension() {
        strContactId= apexpages.currentpage().getparameters().get('ConID');
        strAuditTrack = apexpages.currentpage().getparameters().get('AuditTrack');
        strARPartnerTrack = apexpages.currentpage().getparameters().get('PartnerTrack');
        setEligibleTrackListIds();
        if(strAuditTrack == 'true'){
            setAuditTrackIds();
        }
        system.debug('>>>>>>>ContactId'+strContactId);
        listleftselected = new List<String>();
        listrightselected = new list<string>();
    }
    
    
    public PageReference cLoseTracks(){
        PageReference pr = new PageReference('/'+strContactId);
        return pr;
    }
    
    public Set<String> setEligibleTrackListIds(){
        system.debug('>> in setEligibleTrackListIds');
        if(strContactId != null){
            contact conObj = [SELECT id,EligibleTracks__c,Preferred_Track__c 
                              FROM contact 
                              WHERE id = :strContactId];
            if(conObj!=null){
                if(conObj.EligibleTracks__c != null){
                    List<String> listeligibleTracksId = conObj.EligibleTracks__c.split(';');
                    system.debug('listeligibleTracksId '+listeligibleTracksId);
                    seteligibleTracksId.addAll(listeligibleTracksId);
                    /*for(String stregTrackId: listeligibleTracksId){
seteligibleTracksId.add(stregTrackId);    
} */
                }       
            }
            
        }  
        system.debug('>>>>>seteligibleTracksId '+seteligibleTracksId );
        return seteligibleTracksId ;
        
    }
    
    public Set<String> setAuditTrackIds(){
        system.debug('>> in setAuditTrackIds');
        if(strContactId != null){
            contact conObj = [SELECT id,EligibleTracks__c,Preferred_Track__c, Audit_Track__c
                              FROM contact 
                              WHERE id = :strContactId];
            if(conObj!=null){
                if(conObj.Audit_Track__c != null){
                    List<String> listAuditTracksId = conObj.Audit_Track__c.split(';');
                    system.debug('listAuditTracksId '+listAuditTracksId);
                    setAuditTracksId.addAll(listAuditTracksId);
                    
                }       
            }
            
        }  
        system.debug('>>>>>listAuditTracksId '+setAuditTracksId );
        return setAuditTracksId ;
        
    }
    
    public List<SelectOption> getEligibleTracksSelected(){
        List<SelectOption> listrightoptions= new List<SelectOption>();
        
        system.debug('>> in rightmethod');
        if(strARPartnerTrack == 'true'){
            system.debug('>> in seteligibleTracksId '+seteligibleTracksId  );
            if(seteligibleTracksId.size() > 0){
                for(Partner_Track__c record: [SELECT Id,Name,Track_Id__c,Partner_Track_Name__c,Track_Name__c FROM Partner_Track__c WHERE Id IN:seteligibleTracksId ]) {
                    system.debug('>>>>>recordPTname'+record.Partner_Track_Name__c);
                    if(record.Track_Name__c != null){
                        listrightoptions.add(new SelectOption(record.Id, record.Track_Name__c ));
                        setrighttracks.add(record.Id);
                    }system.debug('>>>righttracks'+setrighttracks.size());
                }
                
            }
        }
        else if(strAuditTrack == 'true'){
            system.debug('>> in setAuditTracksId '+setAuditTracksId  );
            if(setAuditTracksId.size() > 0){
                for(Partner_Track__c record: [SELECT Id,Name,Track_Id__c,Partner_Track_Name__c,Track_Name__c FROM Partner_Track__c WHERE Id IN:setAuditTracksId ]) {
                    system.debug('>>>>>recordPTname'+record.Partner_Track_Name__c);
                    if(record.Track_Name__c != null){
                        listrightoptions.add(new SelectOption(record.Id, record.Track_Name__c ));
                        setrighttracks.add(record.Id);
                    }system.debug('>>>righttracks'+setrighttracks.size());
                }
                
            }
        }
        
        System.debug('listrightoptions'+listrightoptions);
        return listrightoptions;
    }
    
    public list<SelectOption> getEligibleTracks() {
        system.debug('>>>inleft' + 'strARPartnerTrack'+strARPartnerTrack +'strAuditTrack'+ strAuditTrack);
        List<SelectOption> listLeftoptions= new List<SelectOption>();
        if(String.isNotBlank(strContactId)){
            if(strARPartnerTrack == 'true'){
                accountId = [SELECT Id,Accountid 
                             FROM Contact 
                             WHERE Id=:strContactId].accountid;
                system.debug('>>>AccountId'+accountId+'>>>seteligibleTracksId ::'+seteligibleTracksId.size());
                if( seteligibleTracksId.size() > 0){
                    for(Partner_Track__c rightrecord: [SELECT Id,Name,Track_Id__c,Partner_Track_Name__c,Track_Name__c FROM Partner_Track__c WHERE Id IN:seteligibleTracksId ]) {
                        if(rightrecord.Track_Name__c != null){
                            setrighttracks.add(rightrecord.Id);
                            system.debug('>>>righttracks'+setrighttracks.size());
                        }
                    }
                    
                }
                system.debug('>>>righttracks'+setrighttracks.size());
                for(Partner_Track__c leftrecord: [SELECT Id,Name,Track_Id__c,Partner_Track_Name__c,Track_Name__c FROM Partner_Track__c WHERE Master_Group_Id__c =:accountId]) {
                    system.debug('>>>leftrecord'+leftrecord);
                    if(leftrecord.Track_Name__c != null && !setrighttracks.contains(leftrecord.id)){
                        listLeftoptions.add(new SelectOption(leftrecord.Id, leftrecord.Track_Name__c ));
                    }
                }   
            }
            else if(strAuditTrack == 'true'){
                System.debug('setAuditTracksId'+setAuditTracksId);
                if( setAuditTracksId.size() > 0 ){
                    for(Partner_Track__c rightrecord: [SELECT Id,Name,Track_Id__c,Partner_Track_Name__c,Track_Name__c FROM Partner_Track__c WHERE Id IN:setAuditTracksId ]) {
                        if(rightrecord.Track_Name__c != null){
                            setrighttracks.add(rightrecord.Id);
                            system.debug('>>>righttracks'+setrighttracks.size());
                        }
                    }
                    
                }
                System.debug('seteligibleTracksId'+seteligibleTracksId);
                if(seteligibleTracksId.size() > 0){
                    for(Partner_Track__c leftrecord: [SELECT Id,Name,Track_Id__c,Partner_Track_Name__c,Track_Name__c FROM Partner_Track__c WHERE Id IN : seteligibleTracksId]) {
                        system.debug('>>>leftrecord'+leftrecord);
                        if(leftrecord.Track_Name__c != null && !setrighttracks.contains(leftrecord.id)){
                            listLeftoptions.add(new SelectOption(leftrecord.Id, leftrecord.Track_Name__c ));
                        }
                    }
                }
                
            }
        }
        
        return listLeftoptions;
    }
    public PageReference selectTrack(){
        System.debug('selectTrack::'+listleftselected.size()+listleftselected);
        listrightselected.clear();
        system.debug('leftSelected'+listleftselected.size());
        if(listleftselected.size() > 0){
            for(string strs: listleftselected){
                if(strARPartnerTrack == 'true'){
                    seteligibleTracksId.add(strs);
                    System.debug('righttracks'+strs);
                }
                else if(strAuditTrack == 'true'){
                    System.debug('Before Addition setAuditTracksId '+setAuditTracksId );
                    setAuditTracksId.add(strs);
                    
                }
                
            }
            
        }
        else{
            PageUtils.addError('Select atleast One track'); 
            
        }
        
        return null;
    }
    
    public PageReference unselectTracks(){ 
        system.debug('rightselected'+listrightselected.size());
        if(listrightselected.size() > 0){
            for(string strs: listrightselected){
                if(strARPartnerTrack == 'true'){
                    System.debug('Before removal seteligibleTracksId '+seteligibleTracksId );
                    seteligibleTracksId.Remove(strs);
                }
                else if(strAuditTrack == 'true'){
                    System.debug('Before removal setAuditTracksId '+setAuditTracksId );
                    setAuditTracksId.Remove(strs);
                }
                
                setrighttracks.Remove(strs);
                
                System.debug('After removal seteligibleTracksId '+seteligibleTracksId );
                
                
                
            }
            
        }
        
        return null;
        
    }
    
    public PageReference savetracks() {
        system.debug('************seteligibleTracksId '+seteligibleTracksId );
        system.debug('************setAuditTracksId '+setAuditTracksId );
        String strpartnertracks= '';
        String strAudittracks= '';
        string strfirstTrack= null;
        contactToUpdate = [SELECT id,EligibleTracks__c,Preferred_Track__c,Selected_Track__c FROM Contact WHERE id=:strContactId limit 1];
        if(strARPartnerTrack == 'true'){
            if(seteligibleTracksId  !=null){
                for(String strs:seteligibleTracksId  ) {
                    strpartnertracks += (strpartnertracks ==''?'':';')+ strs;
                }
                system.debug('************partnertracks '+strpartnertracks );
                // string firstElement = null;
                for (string strsetElement : seteligibleTracksId ) {
                    strfirstTrack= strsetElement ;
                    break;
                }
                system.debug('************firstTrack'+strfirstTrack);
                
            }
            strPreferredtrack = contactToUpdate.Preferred_Track__c;
            strSelecttrack = contactToUpdate.Selected_Track__c;
            system.debug('************Preferredtrack '+strPreferredtrack);
            if(String.isBlank(strpartnertracks)){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: At least one partner track should exist');
                ApexPages.addMessage(myMsg);
                return null;
            }
            if(strPreferredtrack!= null && strSelecttrack !=null){
                if(!strpartnertracks.contains(strPreferredtrack ) && !strpartnertracks.contains(strSelecttrack )){
                        contactToUpdate.Preferred_Track__c=strfirstTrack;
                        contactToUpdate.Selected_Track__c =strfirstTrack;
                 }
                else if (!strpartnertracks.contains(strPreferredtrack ) && strpartnertracks.contains(strSelecttrack )) {
                        system.debug('******else condition' );
                        contactToUpdate.Preferred_Track__c=strfirstTrack;
                 } 
                else if (strpartnertracks.contains(strPreferredtrack ) && !strpartnertracks.contains(strSelecttrack )) {
                        system.debug('******else condition' );
                        contactToUpdate.Selected_Track__c =strfirstTrack;  
                 } 
            }
            else{
                    contactToUpdate.Preferred_Track__c=strfirstTrack;
                    contactToUpdate.Selected_Track__c =strfirstTrack;
                }
            contactToUpdate.EligibleTracks__c=strpartnertracks;
            update contactToUpdate;
         }
         else if(strAuditTrack == 'true'){
            if(setAuditTracksId.size() > 0){
                for(String strs:setAuditTracksId) {
                    strAudittracks += (strAudittracks ==''?'':';')+ strs;
                }
                system.debug('************Audittracks '+strAudittracks );
                
            }
            contactToUpdate.Audit_Track__c=strAudittracks;
            update contactToUpdate;
        }
        PageReference pr = new PageReference('/'+strContactId ); 
        return pr;
        
    }   
    
    
    
}