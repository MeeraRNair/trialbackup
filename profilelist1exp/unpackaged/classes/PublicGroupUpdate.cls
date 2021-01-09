public class PublicGroupUpdate {
    
    private List<S_P_DR_Criteria__c> newSPDRCriteriaList;
    private List<S_P_DR_Criteria__c> oldSPDRCriteriaList;
    private List<GroupMember> groupMemberList;
    private Map<Id, Group> publicGroupMap;
    private Map<String, Map<Id, GroupMember>> groupMemberMap = new Map<String, Map<Id, GroupMember>>();
    public List<GroupMember> groupMemToRemoveList = new List<GroupMember>();
    public static List<GroupMember> groupMemToInsert = new List<GroupMember>();
    public static List<GroupMember> groupMemToDelete = new List<GroupMember>();
    
    public PublicGroupUpdate(List<S_P_DR_Criteria__c> newTriggeredSPDRCriteriaList, 
                                        List<S_P_DR_Criteria__c> oldTriggeredSPDRCriteriaList){
        this.newSPDRCriteriaList = newTriggeredSPDRCriteriaList;
        this.oldSPDRCriteriaList = oldTriggeredSPDRCriteriaList;
        this.publicGroupMap = new Map<Id, Group>([SELECT Id, Name FROM Group WHERE Name LIKE 'SnP:%Product Managers']);
        this.groupMemberList = new List<GroupMember>([SELECT GroupId, Id, UserOrGroupId 
                                        FROM GroupMember WHERE GroupId IN :publicGroupMap.keySet()]);
    }
    
    public void sortOutGroupMemebers(String recEvent){
        String tempVendorName;
        String tempNewValue = null;
        String tempOldValue = null;
        Id tempGroupId;
        GroupMember tempGroupMember;
        Map<Id, GroupMember> tempGroupMemberMap;
        Set<String> groupMemToInsertIds = new Set<String>();
        Set<Id> groupMemToDeleteIds = new Set<Id>();
        List<String> pmFieldNames = new List<String>{'PM1__c', 'PM2__c', 'PM3__c', 'PM4__c', 'PM5__c'};
        
        // Collect memebers in a Map where the extracted vendor name is the key
        for(GroupMember groupMem : this.groupMemberList){
            tempVendorName = extractVendorNameFromPublicGroupName(this.publicGroupMap.get(groupMem.GroupId).Name).toLowerCase().trim();
            System.debug('*** TEST PAT publicGroupName tempVendorName  *** ' + ' ** ' + 
                                this.publicGroupMap.get(groupMem.GroupId).Name + ' ** ' + tempVendorName);
            
           if(this.groupMemberMap.get(tempVendorName) == null)
              this.groupMemberMap.put(tempVendorName, new Map<Id, GroupMember>()); 
           this.groupMemberMap.get(tempVendorName).put(groupMem.UserOrGroupId, groupMem);
        }
        System.debug('*** TEST PAT groupMemberMap *** ' + groupMemberMap);
        
        for(integer ctr = 0; ctr < newSPDRCriteriaList.size(); ctr++) {
            tempGroupMemberMap = groupMemberMap.get(newSPDRCriteriaList[ctr].Brand_Desc__c.toLowerCase().trim());
            tempGroupId = getPublicGroupId(publicGroupMap, newSPDRCriteriaList[ctr].Brand_Desc__c.toLowerCase().trim());
            System.debug('*** TEST PAT tempGroupId  tempGroupMemberMap newSPDRCriteriaList[ctr].Brand_Desc__c *** ' +
                                 tempGroupId + ' ** ' + tempGroupMemberMap + ' ** ' + newSPDRCriteriaList[ctr].Brand_Desc__c);
            
            for(String fieldname : pmFieldNames){
                tempNewValue = String.valueOf(newSPDRCriteriaList[ctr].get(fieldname));

                if(recEvent.equalsIgnoreCase('update'))
                    tempOldValue = String.valueOf(oldSPDRCriteriaList[ctr].get(fieldname));
                    
                System.debug('*** TEST PAT tempNewValue tempOldValue *** ' + tempNewValue + ' ** ' + tempOldValue);
                
                if(tempNewValue != tempOldValue){
                    // Add user in Public Group
                    if(tempOldValue == NULL && tempNewValue != NULL){
                        if(getGroupMemberToModify(tempGroupMemberMap, tempGroupId, Id.valueOf(tempNewValue)) == null) {
                            groupMemToInsertIds.add(tempGroupId + '-' + tempNewValue);
                            System.debug('*** TEST Add tempGroupId tempNewValue *** ' + tempGroupId + ' ** ' + tempNewValue);
                        }
                            System.debug('*** TEST Add *** ');
                    } 
                    
                    // Delete user in Public Group
                    else if(tempOldValue != NULL && tempNewValue == NULL){
                        tempGroupMember = getGroupMemberToModify(tempGroupMemberMap, tempGroupId, Id.valueOf(tempOldValue));
                        
                        if(tempGroupMember != null)
                            this.groupMemToRemoveList.add(tempGroupMember);
                            
                        System.debug('*** TEST Delete tempGroupMember *** ' + tempGroupMember);
                    }
                    
                    // Delete exisiting and add a new GroupMemeber record (No Update on GroupMember object)
                    else {
                        tempGroupMember = getGroupMemberToModify(tempGroupMemberMap, tempGroupId, Id.valueOf(tempOldValue));
                       
                        // Delete existing group member
                        if(tempGroupMember != null)
                            this.groupMemToRemoveList.add(tempGroupMember);
                        
                        // Add the updated user
                        groupMemToInsertIds.add(tempGroupId + '-' + tempNewValue);  
                            
                        System.debug('*** TEST Update tempGroupMember *** ' + tempGroupMember);
                    } 
                }
            } 
        }
        
        for(GroupMember grpMem : groupMemToRemoveList)
            groupMemToDeleteIds.add(grpMem.Id);
            
        PublicGroupUpdate.updateGroupMemberDMLLists(groupMemToInsertIds, groupMemToDeleteIds);
    }
    
    public static String extractVendorNameFromPublicGroupName(String publicGroupName){
        String tempVendorName = '';
        
        for(integer ctr = 1; true; ctr++){
            if(ctr < (publicGroupName.split(' ').size() - 2))
               tempVendorName += publicGroupName.split(' ') [ctr] + ' ';
           else 
               break;
        }
        
        return tempVendorName;
    }
    
    public Id getPublicGroupId(Map<Id, Group> publicGroupMap, String vendorName){
        
        for(Id grpId : publicGroupMap.keySet()){
            if(extractVendorNameFromPublicGroupName(publicGroupMap.get(grpId).Name).toLowerCase().trim() == vendorName)
                return publicGroupMap.get(grpId).Id;
        }
        
        return null;
    }
    
    public GroupMember getGroupMemberToModify(Map<Id, GroupMember> groupMemMap, Id groupIdVar, Id userOrGroupIdVar){
        
        if(groupMemMap != null){
            for(Id groupMemId : groupMemMap.keySet()){
                if(groupMemMap.get(groupMemId).GroupId == groupIdVar && 
                        groupMemMap.get(groupMemId).UserOrGroupId == userOrGroupIdVar){
                    return groupMemMap.get(groupMemId);
                }
            }
        }
        
        return null;
    }
    
    @future
    public static void updateGroupMemberDMLLists(Set<String> groupMemToInsertId, Set<Id> groupMemToDeleteId){
        
        if(!groupMemToDeleteId.isEmpty())
            groupMemToDelete = [SELECT Id FROM GroupMember WHERE Id IN :groupMemToDeleteId];
        
        for(String tmpGrpMem : groupMemToInsertId){
            if(tmpGrpMem.split('-')[0] != null && tmpGrpMem.split('-')[1] != null)
                groupMemToInsert.add(new GroupMember(GroupId = tmpGrpMem.split('-')[0], 
                            UserOrGroupId = tmpGrpMem.split('-')[1]));
        }
        
        System.debug('*** TEST groupMemToDelete groupMemToInsert *** ' + groupMemToDelete.size() +
                                                    ' ** ' + groupMemToInsert.size());                                       
        if(!groupMemToDelete.isEmpty())
            Database.delete(groupMemToDelete);
            
        if(!groupMemToInsert.isEmpty())
            Database.insert(groupMemToInsert);
    }
}