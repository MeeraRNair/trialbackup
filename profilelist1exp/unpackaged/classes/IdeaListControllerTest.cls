@isTest
private class IdeaListControllerTest {

    static testMethod void testPopularIdeas() {
        IdeaTestUtil.setupTest();
        String communityId = IdeaTestUtil.getCommunityId();
        User votingUser = IdeaTestUtil.getUser1();

        Idea idea1 = IdeaTestUtil.makeIdea('1', communityId);
        IdeaTestUtil.vote(votingUser, idea1, 'DOWN');

        Idea idea2 = IdeaTestUtil.makeIdea('2', communityId);
        IdeaTestUtil.vote(votingUser, idea2, 'UP');

        Idea idea3 = IdeaTestUtil.makeIdea('3', communityId);

        IdeaListController controller = new IdeaListController(IdeaController.SORT_POPULAR, null, null, 1);
        Idea[] ideas = (List<Idea>)controller.getIdeas();
        System.assertEquals(3, ideas.size());
        System.assertEquals(idea2.id, ideas[0].id);
        System.assertEquals(idea3.id, ideas[1].id);
        System.assertEquals(idea1.id, ideas[2].id);
        System.assertEquals(controller.feedName, 'PopularIdeas');
    }

    static testMethod void testRecentIdeas() {
        IdeaTestUtil.setupTest();
        String communityId = IdeaTestUtil.getCommunityId();
        User votingUser = IdeaTestUtil.getUser1();

        Idea idea1 = IdeaTestUtil.makeIdea('1', communityId);
        IdeaTestUtil.vote(votingUser, idea1, 'DOWN');

        Idea idea2 = IdeaTestUtil.makeIdea('2', communityId);
        IdeaTestUtil.vote(votingUser, idea2, 'UP');

        Idea idea3 = IdeaTestUtil.makeIdea('3', communityId);

        IdeaListController controller = new IdeaListController(IdeaController.SORT_RECENT, null, null, 1);
        Idea[] ideas = (List<Idea>)controller.getIdeas();
        System.assertEquals(3, ideas.size());

        System.assertEquals(idea3.title, ideas[0].title);
        System.assertEquals(idea2.title, ideas[1].title);
        System.assertEquals(idea1.title, ideas[2].title);
        System.assertEquals(controller.feedName, 'RecentIdeas');
    }

    static testMethod void testTopIdeas() {
        IdeaTestUtil.setupTest();
        String communityId = IdeaTestUtil.getCommunityId();
        User votingUser = IdeaTestUtil.getUser1();

        Idea idea1 = IdeaTestUtil.makeIdea('1', communityId);
        IdeaTestUtil.vote(votingUser, idea1, 'DOWN');

        Idea idea2 = IdeaTestUtil.makeIdea('2', communityId);
        IdeaTestUtil.vote(votingUser, idea2, 'UP');

        Idea idea3 = IdeaTestUtil.makeIdea('3', communityId);

        IdeaListController controller = new IdeaListController(IdeaController.SORT_TOP, null, null, 1);
        Idea[] ideas = (List<Idea>)controller.getIdeas();
        System.assertEquals(3, ideas.size());
        System.assertEquals(idea2.id, ideas[0].id);
        System.assertEquals(idea3.id, ideas[1].id);
        System.assertEquals(idea1.id, ideas[2].id);
        System.assertEquals(controller.feedName, 'TopIdeas');
    }

    static testMethod void testRecentComments() {
        IdeaTestUtil.setupTest();
        String communityId = IdeaTestUtil.getCommunityId();
        User commentingUser = IdeaTestUtil.getUser1();

        Idea idea1 = IdeaTestUtil.makeIdea('1', communityId);
        IdeaTestUtil.makeIdeaComment(idea1.id, 'comment body', commentingUser, 10);

        Idea idea2 = IdeaTestUtil.makeIdea('2', communityId);
        IdeaTestUtil.makeIdeaComment(idea2.id, 'comment body', commentingUser, 5);

        Idea idea3 = IdeaTestUtil.makeIdea('3', communityId);

        IdeaListController controller = new IdeaListController(IdeaController.SORT_COMMENTS, null, null, 1);
        Idea[] ideas = (List<Idea>)controller.getIdeas();
        System.assertEquals(2, ideas.size());

        System.assertEquals(idea2.title, ideas[0].title);
        System.assertEquals(idea1.title, ideas[1].title);
        System.assertEquals(controller.feedName, 'RecentComments');
        System.assert(controller.getIsCommentsList());
    }

    static testMethod void testIdeasWithVotes() {
        IdeaTestUtil.setupTest();
        String communityId = IdeaTestUtil.getCommunityId();
        User votingUser = IdeaTestUtil.getUser1();

        Idea idea1 = IdeaTestUtil.makeIdea('1', communityId);
        IdeaTestUtil.vote(votingUser, idea1, 'DOWN');

        Idea idea2 = IdeaTestUtil.makeIdea('2', communityId);
        IdeaTestUtil.vote(votingUser, idea2, 'UP');

        Idea idea3 = IdeaTestUtil.makeIdea('3', communityId);

        System.runAs(votingUser) {
            IdeaListController controller = new IdeaListController(IdeaController.SORT_TOP, null, null, 1);
            IdeaWithVote[] ideasWithVotes = controller.ideasWithVotes;
            System.assertEquals(3, ideasWithVotes.size());
            System.assertEquals(idea2.id, ideasWithVotes[0].idea.id);
            System.assertEquals('Up', ideasWithVotes[0].getHowUserVoted());
            System.assertEquals(idea3.id, ideasWithVotes[1].idea.id);
            System.assertEquals('None', ideasWithVotes[1].getHowUserVoted());
            System.assertEquals(idea1.id, ideasWithVotes[2].idea.id);
            System.assertEquals('Down', ideasWithVotes[2].getHowUserVoted());
        }
    }
    
    static testMethod void testRecentReplies() {
        IdeaTestUtil.setupTest();
        String communityId = IdeaTestUtil.getCommunityId();
        User votingUser = IdeaTestUtil.getUser1();
        User commentsUser1 =  IdeaTestUtil.getUser2();
        User commentsUser2 =  IdeaTestUtil.getUser1();

        Idea idea1 = IdeaTestUtil.makeIdea('1', communityId, 500);
        IdeaTestUtil.vote(votingUser, idea1, 'DOWN');
        IdeaTestUtil.makeIdeaComment(idea1.Id, 'This is comment Body', commentsUser1, 300);
        IdeaTestUtil.makeIdeaComment(idea1.Id, 'This is comment Body Again', commentsUser2, 100);
        IdeaTestUtil.makeIdeaComment(idea1.Id, 'Second comment from User', commentsUser2, 200);

        Idea idea2 = IdeaTestUtil.makeIdea('2', communityId);
        IdeaTestUtil.vote(votingUser, idea2, 'UP');

        Idea idea3 = IdeaTestUtil.makeIdea('3', communityId, 800);
        IdeaTestUtil.makeIdeaComment(idea3.Id, 'This is comment Body Again', commentsUser2, 0);

        IdeaListController controller = new IdeaListController(IdeaController.SORT_COMMENTS, null, null, 1);
        Idea[] ideas = (List<Idea>)controller.getIdeas();
        System.assertEquals(2, ideas.size());
        System.assertEquals(idea3.title, ideas[0].title);
        System.assertEquals(idea1.title, ideas[1].title);
        System.assertEquals(controller.feedName, 'RecentComments');
    }
    

    static testMethod void testPagination() {
        IdeaTestUtil.setupTest();
        Integer ideasPerPage = IdeaSettings.IDEA_LIST_PAGE_SIZE;
        String communityId = IdeaTestUtil.getCommunityId();
        //List<String> ideaTitles = new String[ideasPerPage*2+1];
        List<String> ideaTitles = new String[ideasPerPage+1];
        Idea[] ideas = new List<Idea>();
        for (Integer i=0; i<(ideaTitles.size()); i++) {
            //ideas.add(IdeaTestUtil.fillIdea(communityId, String.valueOf(i), null, null, null, ideaTitles.size()-i));
            ideas.add(IdeaTestUtil.fillIdea(communityId, String.valueOf(i), 'abc', 'abc', 'abc', ideaTitles.size()-i));
        }
        insert(ideas);
        IdeaListController controller = new IdeaListController(IdeaController.SORT_RECENT, null, null, 1);
        IdeaWithVote[] ideasWithVotes = controller.ideasWithVotes;
        System.assertEquals(ideasPerPage, ideasWithVotes.size());
        System.assertEquals(ideas[ideas.size()-1].title, ideasWithVotes[0].idea.title);

        controller = new IdeaListController(IdeaController.SORT_RECENT, null, null, 2);
        ideasWithVotes = controller.ideasWithVotes;
        System.assertEquals(ideasPerPage, ideasWithVotes.size() + 19);
        System.assertEquals(ideas[ideas.size()-1-ideasPerPage].title, ideasWithVotes[0].idea.title);
    
        /* TODO - too many soql queries - need to reduce 
        controller = new IdeaListController(IdeaController.SORT_RECENT, null, null, 3);
        ideasWithVotes = controller.ideasWithVotes;
        System.assertEquals(1, ideasWithVotes.size());
        System.assertEquals(ideas[ideas.size()-1-ideasPerPage-ideasPerPage].title, ideasWithVotes[0].idea.title);
        */
    }

    static testMethod void testGetters() {
        IdeaTestUtil.setupTest();
        IdeaListController controller = new IdeaListController(IdeaController.SORT_RECENT, null, null, 1);
        controller.getIdeasWithComments();
        controller = new IdeaListController(IdeaController.SORT_COMMENTS, null, null, 1);
        //controller.getIdeasWithComments();
        controller.getPageUrl();
        controller.getIsCommentsList();
        System.assertEquals(1, controller.numPages);
        System.assertEquals(1, controller.totalNumPages);
    }

    static testMethod void testBadSortValue() {
        IdeaTestUtil.setupTest();
        IdeaListController controller = new IdeaListController(null, null, null, 1);
        System.assertEquals(controller.feedName, 'PopularIdeas');
        controller = new IdeaListController('', null, null, 1);
        System.assertEquals(controller.feedName, 'PopularIdeas');
        controller = new IdeaListController('foo', null, null, 1);
        System.assertEquals(controller.feedName, 'PopularIdeas');
    }

    static testMethod void testCategoryAndStatusFiltering() {
        IdeaTestUtil.setupTest();
        String communityId = IdeaTestUtil.getCommunityId();

        User ideaPostingUser = IdeaTestUtil.getUser1();
        User commentingUser = IdeaTestUtil.getUser2();
        User votingUser = IdeaTestUtil.getUser2();

        // create ideas with various combinations of category/status field values
        List<String> categoryValues = new List<String>();
        categoryValues.add(null);
        categoryValues.add('category1');
        //categoryValues.add('category2'); // needed to comment this out because will hit limit on number of queries in for loop
        List<String> statusValues = new List<String>();
        statusValues.add(null);
        statusValues.add('status1');
        //statusValues.add('status2'); // needed to comment this out because will hit limit on number of queries in for loop
        for (Integer c = 0; c < categoryValues.size(); c++) {
            for (Integer s = 0; s < statusValues.size(); s++) {
                String category = categoryValues.get(c);
                String status = statusValues.get(c);
                Idea idea = IdeaTestUtil.makeIdea(ideaPostingUser, communityId, 'test idea', 'idea body', category, status, 1 + c * 10 + s * 100);
            }
        }

        List<String> sortValues = new List<String>();
        sortValues.add(IdeaController.SORT_POPULAR);
        sortValues.add(IdeaController.SORT_RECENT);
        sortValues.add(IdeaController.SORT_TOP);
        sortValues.add(IdeaController.SORT_COMMENTS);

        // go through each combination of category and status and verify the list controller results
        for (String sortValue : sortValues) {
            for (String category : categoryValues) {
                for (String status : statusValues) {
                    IdeaListController controller = new IdeaListController(sortValue, category, status, 1);
                    Idea[] ideas = (List<Idea>)controller.getIdeas();
                    // TODO: assert results
                    controller = new IdeaListController(sortValue, category, status, 100);
                    ideas = (List<Idea>)controller.getIdeas();
                    // TODO: assert results
                }
            }
        }
    }

}