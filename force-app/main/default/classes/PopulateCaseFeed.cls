/************
 * Author   : uday 
 * CR Number:
 * Purpose  : To display feed on aparticular case record 
 *            when we upload attachment for the same 
 *            
 *          
 * Revision CR Number   Release No      Date            Modified By     Description
 ************/
public class PopulateCaseFeed{


    /*
    *Params : list<Attachment>
    */
    public static void PopulateAttachmentInsertedStausonCase(list<Attachment> UploadedAttachments){
    
            //initilize an empty list to hold feed items
            list<FeedItem> AllFeedItems = new list<FeedItem>();
            
            for(Attachment each:UploadedAttachments){
            
            //Load the prefix of case Object (ex: 500);
            String recordIdPrefix = StringUtils.defaultString(StringUtils.substring(each.parentId, 0, 3));
               
               //checck the parent id of the attchment in Case or not 
                if(recordIdPrefix.equals(Case.sObjectType.getDescribe().getKeyPrefix())){
                    FeedItem post = new FeedItem();
                    post.ParentId = each.ParentId;
                    post.Body = each.Name + ' uploaded.';//+userinfo.getname();
                    post.LinkUrl = '/'+each.id;//add the attachment id as link in the feed 
                  
                  //add each feed into a list  
                    AllFeedItems.add(post);
            
               }
            }
            
            //do insert on feeditem list if it is not empty
            if(!AllFeedItems.isEmpty()){
                try{
                        insert AllFeedItems;
                }catch(Exception ex){}
            }
    }
}