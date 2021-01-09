/*  

    Class used to hold the data of Policy details page    
  
*/
public class SSD_PolicyDetail
{
    public String KnowledgeArticleId{get; set;} 
    public String ArticleNumber{get; set;}
    public String OwnerId{get; set;}
    public String Link_to_Policy{get; set;}
    public String Keywords{get; set;}  
    public String Description{get; set;} 
    public String Department{get; set;}
    public String CreatedById{get; set;}
    public DateTime CreatedDate{get; set;}
    public String SourceId{get; set;}
    public String Summary{get; set;}
    public String Title{get; set;}
    public String UrlName{get; set;}   
    public String UserVote{get; set;} 
    public Boolean UserFollow{get; set;}  
    public List<String> DataCategoryTopic {get; set;} 
    public List<String> DataCategoryRegion {get; set;}    
 }