/*
* Author  : Nagaraju Yelluri
* Purpose : It will delete old attachments when new attachments has entered with the same name.
* 
* Revision CR Number   Release No  Date            Modified By     Description
* -------- ---------   ----------  -----------     ------------    -----------
* 1.0      CR15065                 31-Oct-2017     Nagaraju        It will delete old attachments when new attachments has entered for same quarter in territory plan record.
*/ 

public class DeleteOldAttachments{

    @TestVisible private static List<Attachment> deleteAttachmentsList = new List<Attachment>();
    //v1.0 start
    public static void tp_deleteOldAttachment(List<Attachment> newAttachments){
        
        List<Id> tpIds;
        if(newAttachments != null){
            //Attachment attachmentObj = newAttachments[0];
            for(Attachment attachObj1 : newAttachments){
                Schema.SObjectType objType = attachObj1.ParentId.getSObjectType();
                System.debug('Object Name :'+objType);
                If(String.valueOf(objType) == 'Territory_Plan__c'){
                    tpIds = new List<Id>();
                    //for(Attachment newAttachment : newAttachments)
                    tpIds.add(attachObj1.parentId);
                }
            }
            if(tpIds!= null){
                integer fyNewIndex = 0;
                integer fyOldIndex = 0;
                for(Attachment oldAttachment : [select id,name,parentId from Attachment where parentId in : tpIds]){
                    if(oldAttachment.name.contains('FY20')){
                        for(Attachment newAttachment : newAttachments){
                            if(newAttachment.name.contains('FY20') && newAttachment.id != oldAttachment.id){
                                fyOldIndex = oldAttachment.name.indexOf('FY20');
                                fyNewIndex = newAttachment.name.indexOf('FY20');
                                //Delete same quarter old tp attachments
                                if((oldAttachment.name.substring(fyOldIndex,fyOldIndex+10) == newAttachment.name.substring(fyNewIndex,fyNewIndex+10)) && oldAttachment.id != newAttachment.id){
                                    deleteAttachmentsList.add(oldAttachment);
                                }
                                System.debug('Quarter :'+oldAttachment.name.substring(fyOldIndex+7,fyOldIndex+9));
                                //Delete last year current quarter tp attachments
                                Integer newAttachYear = Integer.valueOf(newAttachment.name.substring(fyNewIndex+2,fyNewIndex+6));
                                Integer oldAttachYear = Integer.valueOf(oldAttachment.name.substring(fyOldIndex+2,fyOldIndex+6));
                                String newAttachQuarter = newAttachment.name.substring(fyNewIndex+7,fyNewIndex+10);
                                String oldAttachQuarter = oldAttachment.name.substring(fyOldIndex+7,fyOldIndex+10);
                                if((newAttachYear>oldAttachYear) && (newAttachQuarter == oldAttachQuarter)){
                                    If(oldAttachment.id != newAttachment.id)
                                        deleteAttachmentsList.add(oldAttachment);
                                }
                            }
                        }
                    }
                }
            }
            
            if(deleteAttachmentsList != null)
                Database.delete(deleteAttachmentsList,false);
        }
    }
}