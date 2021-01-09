@isTest
private class DateFormatControllerTest {

    static testMethod void testDateDisplay() {
        User testUser = IdeaTestUtil.getUser1();
        
        DateFormatController controller = new DateFormatController();
        System.assertEquals('', controller.getDateDisplay());

        Idea idea = IdeaTestUtil.makeIdea();
        controller.ideaParam = idea;
        System.assert(controller.getDateDisplay() != '');

        controller = new DateFormatController();
        
        IdeaComment ideaComment = IdeaTestUtil.makeIdeaComment(idea.id, 'comment', testUser, 0);
        controller.commentParam = ideaComment;
        System.assert(controller.getDateDisplay() != '');

        ideaComment = IdeaTestUtil.makeIdeaComment(idea.id, 'comment', testUser, 5);
        controller.commentParam = ideaComment;
        System.assert(controller.getDateDisplay() != '');  // 5 seconds ago

        ideaComment = IdeaTestUtil.makeIdeaComment(idea.id, 'comment', testUser, 5 * 60);
        controller.commentParam = ideaComment;
        System.assert(controller.getDateDisplay() != '');  // 5 minutes ago

        ideaComment = IdeaTestUtil.makeIdeaComment(idea.id, 'comment', testUser, 5 * 60 * 60);
        controller.commentParam = ideaComment;
        System.assert(controller.getDateDisplay() != '');  // 5 hours ago, 'h:mm a'

        ideaComment = IdeaTestUtil.makeIdeaComment(idea.id, 'comment', testUser, 24 * 60 * 60 + 5);
        controller.commentParam = ideaComment;
        System.assert(controller.getDateDisplay() != '');  // Yesterday

        ideaComment = IdeaTestUtil.makeIdeaComment(idea.id, 'comment', testUser, 3 * 24 * 60 * 60 + 5);
        controller.commentParam = ideaComment;
        System.assert(controller.getDateDisplay() != '');  // 3 days ago

        ideaComment = IdeaTestUtil.makeIdeaComment(idea.id, 'comment', testUser, 10 * 24 * 60 * 60 + 5);
        controller.commentParam = ideaComment;
        System.assert(controller.getDateDisplay() != '');  // 'MMM d, yyyy'
    }

}