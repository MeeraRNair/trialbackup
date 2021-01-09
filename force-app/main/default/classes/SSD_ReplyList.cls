/*  

    Summary Of Class SSD_ReplyList   
  
*/
public class SSD_ReplyList
{
      public String ReplyId{get; set;} 
      public String QuestionId{get; set;}
      public String selfHelpId{get;set;}
      public String Name{get; set;} // Stores Article title
      public String Body{get; set;} // Also stores the Article Summary
      public Integer DownVotes{get; set;}
      public Integer UpVotes{get; set;} 
      public Long VoteRate {get;set;}
      Public String CreatedById{get; set;} // Also stores the Article created by
      public String CreatorName{get; set;} //Also stores the Article created by
      public DateTime CreatedDate{get; set;}
      public String UserVote{get; set;} 
      public String UserFollow{get; set;} // Only Article
      public Integer NumReportAbuses{get; set;}
      public DateTime LastModifiedDate{get; set;}
      public String ArticleLinkId{get;set;} // The hyper link Id
      public String ArticleStatus{get;set;} // The Article status for hyper link 
 }