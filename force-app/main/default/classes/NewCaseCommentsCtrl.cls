public class NewCaseCommentsCtrl {
    public id caseId {get; set;}
    public CaseComment comment {
        get { 
            list<CaseComment> caseComments = [SELECT CommentBody,CreatorName,Id, ParentId, CreatedBy.Name FROM CaseComment WHERE ParentId = :caseId ORDER BY CreatedDate DESC LIMIT 1];
            if(caseComments.size() > 0) {
                comment = caseComments.get(0);
            }
            return comment;
        } 
        set;
    }
    public Case caseObj {
        get { 
            list<Case> caseList = [SELECT id, CaseNumber, Subject FROM Case WHERE id = :caseId];
            if(caseList.size() > 0)
                caseObj = caseList.get(0);
            return caseObj;}
        set ;
    }
    
}