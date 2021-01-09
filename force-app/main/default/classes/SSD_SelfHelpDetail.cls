/*  

    Class used to hold the data of self help details page    
  
*/
public class SSD_SelfHelpDetail
{
    public String KnowledgeArticleId{get; set;} 
    public String ArticleNumber{get; set;}
    public String Answer{get; set;}
    public String Self_Help_kavId{get; set;}
    public String Attachment_1_Name{get; set;}  
    public String Attachment_2_Name{get; set;} 
    public String Attachment_3_Name{get; set;}
    public String CreatedById{get; set;}
    public DateTime CreatedDate{get; set;}
    public String Department{get; set;}
    public String Keywords{get; set;}
    public String OwnerId{get; set;}
    public String Question{get; set;}
    public String SourceId{get; set;}
    public String Summary{get; set;}
    public String Title{get; set;}
    public String UrlName{get; set;}
    public String UserVote{get; set;} 
    public Boolean UserFollow{get; set;} 
    public List<String> DataCategoryTopic {get; set;} 
    public List<String> DataCategoryRegion {get; set;}    
 }