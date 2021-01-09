global class SSD_SearchResult
{
    public String ItemId{get; set;}
    public String Type {get; set;}
    public String Title {get; set;}
    public String Summary{get; set;}
    public String ArticleNumber{get; set;}
    public long VoteScore{get; set;}
    public long ReplyDownVote{get; set;}    
    public String CreatedById {get; set;}
    public String CreatedBy {get; set;}
    public datetime CreatedDate {get; set;}
    public String BestreplyId {get; set;}
    public String ReplyId {get; set;}
    public DateTime LastModifiedDate{get; set;}
    public String QuestionCreatedById{get; set;}
    public String UserVote {get; set;}
    public Boolean UserFollow {get; set;}  
    public DateTime DatePosted {get; set;} 
}