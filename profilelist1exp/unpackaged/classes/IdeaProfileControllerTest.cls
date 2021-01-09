@isTest
private class IdeaProfileControllerTest {
    static User me;
    static User her;
    static ID myIdea;
    static ID herIdea;
    static long now;
    
    private static void deleteExistingIdeas() {
        String communityId = IdeaTestUtil.getCommunityId();
        Idea[] existingIdeas = [SELECT Id, Title FROM Idea where communityId = :communityId and parentIdeaId = null];
        delete existingIdeas;
    }

    static void setUp() {
        deleteExistingIdeas();
        now = System.currentTimeMillis();
        me = IdeaTestUtil.getUser1();
        her = IdeaTestUtil.getUser2();
        myIdea = IdeaTestUtil.makeIdea('My Idea', 'abc', me, 500).id;
        herIdea = IdeaTestUtil.makeIdea('Her Idea', 'abc', her, 600).id; 
        IdeaTestUtil.vote(her, myIdea, 'Up');
        IdeaTestUtil.vote(me, herIdea, 'Up');
    }

    static testMethod void testHerProfileViewOfHerCommentOnHerIdea() {
        IdeaTestUtil.setupTest();
        setUp();
        IdeaTestUtil.makeIdeaComment(herIdea, 'comment she made on her idea.', her, 0);
        IdeaActivity comment = filter(setUpForRequest(her.communityNickname).getActivities(), IdeaActivity.TYPE_COMMENT_GROUP).get(0);
        assertMatchesIgnoringHref(' commented on <a href=FOO>Her Idea</a>', comment.getFirstLineHtml());
        System.assertEquals(her.communityNickname, comment.getActivityCreatorCommunityNickname());
    }
    
    static testMethod void testHerProfileViewOfYourCommentOnHerIdea() {
        IdeaTestUtil.setupTest();
        setUp();
        IdeaTestUtil.makeIdeaComment(herIdea, 'comment I made on her idea.', me, 0);
        IdeaActivity comment = filter(setUpForRequest(her.communityNickname).getActivities(), IdeaActivity.TYPE_COMMENT_GROUP).get(0);
        assertMatchesIgnoringHref(' commented on <a href=FOO>Her Idea</a>', comment.getFirstLineHtml());
        System.assertEquals(me.communityNickname, comment.getActivityCreatorCommunityNickname());
    }

    static testMethod void testHerProfileViewOfYourAndHerCommentsOnHerIdea(){
        IdeaTestUtil.setupTest();
        setUp();
        IdeaTestUtil.makeIdeaComment(herIdea, 'comment I made on her idea.', me, 3);
        IdeaTestUtil.makeIdeaComment(herIdea, 'comment she made on her idea.', her, 2);
        List<IdeaActivity> comments = filter(setUpForRequest(her.communityNickname).getActivitiesByDay().get(0).getActivities(), IdeaActivity.TYPE_COMMENT_GROUP);
        System.assertEquals(1, comments.size());
        IdeaActivity comment = comments.get(0);
        assertMatchesIgnoringHref(' and 1 other commented on <a href=FOO>Her Idea</a>', comment.getFirstLineHtml());
        //System.assertEquals(her.communityNickname, comment.getActivityCreatorCommunityNickname());
    }
    
    static testMethod void testHerProfileViewOfHerCommentOnYourIdea() {
        IdeaTestUtil.setupTest();
        setUp();
        IdeaTestUtil.makeIdeaComment(myIdea, 'comment she made on my idea.', her, 0);
        List<IdeaActivity> comments = filter(setUpForRequest(her.communityNickname).getActivitiesByDay().get(0).getActivities(), IdeaActivity.TYPE_COMMENT_GROUP);
        System.assertEquals(1, comments.size());
        IdeaActivity comment = comments.get(0);
        assertMatchesIgnoringHref(' commented on <a href=FOO>My Idea</a>', comment.getFirstLineHtml());
        System.assertEquals(her.communityNickname, comment.getActivityCreatorCommunityNickname());
    }

    static testMethod void testHerProfileViewOfMyCommentOnMyIdea() {
        IdeaTestUtil.setupTest();
        setUp();
        IdeaTestUtil.makeIdeaComment(myIdea, 'comment I made on my idea.', me, 0);
        List<IdeaActivity> activities = filter(setUpForRequest(her.communityNickname).getActivities(), IdeaActivity.TYPE_COMMENT_GROUP);
        System.assertEquals(0, activities.size());
    }
    
    static testMethod void testHerProfileViewOfYourAndHerCommentsOnYourIdea() {
        IdeaTestUtil.setupTest();
        setUp();
        IdeaTestUtil.makeIdeaComment(myIdea, 'comment I made on my idea.', me, 0);
        IdeaTestUtil.makeIdeaComment(myIdea, 'comment she made on my idea.', her, 0);
        List<IdeaActivity> comments = filter(setUpForRequest(her.communityNickname).getActivitiesByDay().get(0).getActivities(), IdeaActivity.TYPE_COMMENT_GROUP);
        System.assertEquals(1, comments.size());
        IdeaActivity comment = comments.get(0);
        assertMatchesIgnoringHref(' commented on <a href=FOO>My Idea</a>', comment.getFirstLineHtml());
        System.assertEquals(her.communityNickname, comment.getActivityCreatorCommunityNickname());
    }
    
    static testMethod void testGetActivitiesForVotesByOther() {
        IdeaTestUtil.setupTest();
        setUp();
        List<IdeaActivity> votes = filter(setUpForRequest(me.communityNickname).getActivities(), IdeaActivity.TYPE_VOTE_CREATED);
        System.assertEquals(1, votes.size());

        IdeaActivity.VoteCreatedActivity vote = (IdeaActivity.VoteCreatedActivity)votes.get(0);
        System.assertEquals(herIdea, vote.getIdeaId());
        System.assertEquals('Her Idea', vote.getIdeaTitle());
        assertMatchesIgnoringHref(' voted on <a href=FOO>Her Idea</a>', vote.getFirstLineHtml());
        System.assertEquals(me.communityNickname, vote.getActivityCreatorCommunityNickname());
    }

    static testMethod void testGetActivitiesForIdeasByOther() {
        IdeaTestUtil.setupTest();
        setUp();
        List<IdeaActivity> ideas = filter(setupForRequest(me.communityNickname).getActivities(), IdeaActivity.TYPE_IDEA_CREATED);
        System.assertEquals(1, ideas.size());

        IdeaActivity.IdeaCreatedActivity activity = (IdeaActivity.IdeaCreatedActivity)ideas.get(0);
        System.assertEquals(myIdea, activity.getIdeaId());
        System.assertEquals('My Idea', activity.getIdeaTitle());
        assertMatchesIgnoringHref(' submitted <a href=FOO>My Idea</a>', activity.getFirstLineHtml());
        System.assertEquals(me.communityNickname, activity.getActivityCreatorCommunityNickname());
    }
    
    static testMethod void testProfileStatsOnUser() {
        IdeaTestUtil.setupTest();
        setUp();
        String ideaA = IdeaTestUtil.makeIdea('Idea A', 'abc', me, 200).id;
        String ideaB = IdeaTestUtil.makeIdea('Idea B', 'abc', me, 1 * 24 * 60 * 60 + 10).id;
        String ideaC = IdeaTestUtil.makeIdea('Idea C', 'abc', me, 4 * 24 * 60 * 60 + 10).id;
        String ideaD = IdeaTestUtil.makeIdea('Idea D', 'abc', me, 10 * 24 * 60 * 60 + 40).id;
        String ideaE = IdeaTestUtil.makeIdea('Idea E', 'abc', her, 200).id;
        String ideaF = IdeaTestUtil.makeIdea('Idea F', 'abc', her, 10 * 24 * 60 * 60 + 40).id;
        IdeaTestUtil.makeIdeaComment(ideaE, 'comment on idea E', me, 0);
        IdeaTestUtil.makeIdeaComment(ideaB, 'comment on my own idea B', me, 60);
        IdeaTestUtil.makeIdeaComment(ideaB, 'second comment on my own idea B', me, 60 * 60);
        IdeaTestUtil.makeIdeaComment(herIdea, 'comment on herIdea', me, 200);
        IdeaTestUtil.vote(her, ideaA, 'Up');
        //IdeaTestUtil.vote(her, ideaB, 'Up');
        IdeaTestUtil.vote(her, ideaC, 'Down');
        //IdeaTestUtil.vote(me, ideaE, 'Down');
        IdeaProfileController controller = new IdeaProfileController(me.communityNickname);
        //System.assertEquals(5, controller.getNumberOfIdeasCreatedByUserFromParam());
        //System.assertEquals(4, controller.getNumberOfIdeasCommentedOnByUserFromParam());
        //System.assertEquals(2, controller.getNumberOfIdeasVotedOnByUserFromParam());
        //System.assertEquals(3, controller.getNumOfUsersVotedUpOnUsersIdea());
        //System.assertEquals(1, controller.getNumOfUsersVotedDownOnUsersIdea());
        controller = new IdeaProfileController(her.communityNickname);
        //System.assertEquals(3, controller.getNumberOfIdeasCreatedByUserFromParam());
        //System.assertEquals(0, controller.getNumberOfIdeasCommentedOnByUserFromParam());
        //System.assertEquals(4, controller.getNumberOfIdeasVotedOnByUserFromParam());
        //System.assertEquals(1, controller.getNumOfUsersVotedUpOnUsersIdea());
        //System.assertEquals(1, controller.getNumOfUsersVotedDownOnUsersIdea());
    }

    static testMethod void testGetActivitiesByDay() {
        IdeaTestUtil.setupTest();
        setUp();
        String ideaB = IdeaTestUtil.makeIdea('Idea B', 'abc', me, 200).id;
        String ideaC = IdeaTestUtil.makeIdea('Idea C', 'abc', me, 1 * 24 * 60 * 60 + 10).id;
        String ideaD = IdeaTestUtil.makeIdea('Idea D', 'abc', me, 4 * 24 * 60 * 60 + 10).id;
        String ideaE = IdeaTestUtil.makeIdea('Idea E', 'abc', me, 4 * 24 * 60 * 60 + 40).id;
        IdeaTestUtil.makeIdea('Idea F', 'abc', me, 10 * 24 * 60 * 60 + 40);
        String commentOnIdeaE = IdeaTestUtil.makeIdeaComment(ideaE, 'comment on idea E', me, 4 * 24 * 60 * 60 + 27).id;
        System.assert(me.communityNickname != null, 'Nickname for me is null ' + me.communityNickname);
        IdeaProfileController controller = new IdeaProfileController(me.communityNickname);
        List<IdeaActivitiesByDay> byDay = controller.getActivitiesByDay();
        
        //System.assertEquals(4, byDay.size());
        System.assertEquals('Recent Activity', byDay.get(0).getSectionName());
        System.assertEquals('Yesterday', byDay.get(1).getSectionName());
        System.assertEquals('4 Days Ago', byDay.get(2).getSectionName());
        
       // System.assertEquals(3, byDay.get(0).getActivities().size());
        //Her idea you voted on
        System.assertEquals(IdeaActivity.TYPE_VOTE_CREATED, byDay.get(0).getActivity(0).getTypeCode());
        System.assertEquals(herIdea, byDay.get(0).getActivity(0).getIdeaId());
        
        //Your idea she voted on
        System.assertEquals(IdeaActivity.TYPE_IDEA_CREATED, byDay.get(0).getActivity(1).getTypeCode());
        System.assertEquals(ideaB, byDay.get(0).getActivity(1).getIdeaId());
        
        //Idea you submitted
        System.assertEquals(IdeaActivity.TYPE_IDEA_CREATED, byDay.get(0).getActivity(2).getTypeCode());
        System.assertEquals(myIdea, byDay.get(0).getActivity(2).getIdeaId());
            
        System.assertEquals(1, byDay.get(1).getActivities().size());
        //Idea you submitted
        System.assertEquals(IdeaActivity.TYPE_IDEA_CREATED, byDay.get(1).getActivity(0).getTypeCode());
        System.assertEquals(ideaC, byDay.get(1).getActivity(0).getIdeaId());
        System.assertEquals(3, byDay.get(2).getActivities().size());
        
        //Idea you submitted
        System.assertEquals(IdeaActivity.TYPE_IDEA_CREATED, byDay.get(2).getActivity(0).getTypeCode());
        System.assertEquals(ideaD, byDay.get(2).getActivity(0).getIdeaId());
        //Idea you commented on
        System.assertEquals(commentOnIdeaE, ((IdeaActivity.CommentGroup) byDay.get(2).getActivity(1)).getCommentId());
        //Idea you submitted
        System.assertEquals(IdeaActivity.TYPE_IDEA_CREATED, byDay.get(2).getActivity(0).getTypeCode());
        System.assertEquals(ideaE, byDay.get(2).getActivity(2).getIdeaId());
        
        System.assertEquals(1, byDay.get(3).getActivities().size());
        //Idea you submitted
        System.assertEquals(IdeaActivity.TYPE_IDEA_CREATED, byDay.get(3).getActivity(0).getTypeCode());
    }

 
    static testMethod void testGroupActivitiesByDay(){
        IdeaTestUtil.setupTest();
        setUp();
        IdeaProfileController controller = new IdeaProfileController();
        DateTime today = DateTime.now();

        System.assertEquals(24, countIndividualActivities(controller.groupActivitiesByDay(createActivities(today, 24, 0))));
        System.assertEquals(25, countIndividualActivities(controller.groupActivitiesByDay(createActivities(today, 25, 0))));
        System.assertEquals(25, countIndividualActivities(controller.groupActivitiesByDay(createActivities(today, 26, 0))));

        System.assertEquals(24, countIndividualActivities(controller.groupActivitiesByDay(createActivities(today, 24, 0))));
        System.assertEquals(25, countIndividualActivities(controller.groupActivitiesByDay(createActivities(today, 24, 1))));
        System.assertEquals(25, countIndividualActivities(controller.groupActivitiesByDay(createActivities(today, 24, 2))));

        List<IdeaActivity> foo = createActivities(today, 24, 1);
        foo.add(new IdeaActivity.CommentCreatedActivity(null, null, null, today.addDays(1), null, null, null, null, false));
        System.assertEquals(25, countIndividualActivities(controller.groupActivitiesByDay(foo)));
    }

    static testMethod void testGetters(){
        IdeaTestUtil.setupTest();
        setUp();

        String herIdea2 = IdeaTestUtil.makeIdea('Her Idea 2', 'abc', her, 600).id; 
        IdeaTestUtil.vote(me, herIdea2, 'Up');

        IdeaProfileController controller = new IdeaProfileController();
        System.assert(controller.getUserNicknameFromParam() == null);

        controller = new IdeaProfileController(me.communityNickname);
        controller.getHasActivities();
        controller.getUserNicknameFromParam();
        controller.getUserFromParam();
        controller.getNumberOfIdeasCreatedByUserFromParam();
        controller.getNumberOfIdeasCreatedByCurrentUser();
        controller.getNumberOfIdeasCommentedOnByCurrentUser();
        controller.getNumberOfIdeasCommentedOnByUserFromParam();
        controller.getNumberOfIdeasVotedOnByCurrentUser();
        controller.getNumberOfIdeasVotedOnByUserFromParam();
        //controller.getNumberOfUnreadRecentRepliesForCurrentUser();
        controller.getNumOfUsersVotedUpOnUsersIdea();
        controller.getNumOfUsersVotedDownOnUsersIdea();
        controller.getActivities();
        controller.getActivitiesByDay();
        //controller.getUserCommentedIdeas();
        //controller.numOfCommentsOnUsersIdea ();
        //controller.getIsRecentActivityPage();
        //controller.getIsSubmittedIdeasPage();
        //controller.getIsVotedIdeasPage();
        //controller.getIsUserCommentsPage();
        //controller.getIsRecentRepliesPage();
        String userId = controller.userId;
        controller.userId = me.id;
        controller.getIsCommunityNicknameUserLoggedIn();
        controller.getPoints();
    }

    private static List<IdeaActivity> createActivities(DateTime createdDate, Integer regularActivityCount, Integer commentActivityCount) {
        List<IdeaActivity> activities = new List<IdeaActivity>();
        for (Integer i = 0; i < regularActivityCount; i++) {
            activities.add(new IdeaActivity.IdeaCreatedActivity('ideaId', null, me.Id ,createdDate, me.communityNickname, null));
        }
        for (Integer i = 0; i < commentActivityCount; i++) { 
            activities.add(new IdeaActivity.CommentCreatedActivity('ideaId', null, me.Id, createdDate, null, null, null, null, false));
        }
        return activities;
    }

    private static Integer countIndividualActivities(List<IdeaActivitiesByDay> activitiesByDayList) {
        Integer count = 0;
        for (IdeaActivitiesByDay activitiesByDay : activitiesByDayList) {
            List<IdeaActivity> activities = activitiesByDay.getActivities();
            for (IdeaActivity activity : activities) {
                if (activity instanceof IdeaActivity.CommentGroup) {
                    IdeaActivity.CommentGroup commentGroup = (IdeaActivity.CommentGroup) activity;
                    count += commentGroup.getCommentCount();
                } else {
                    count++;
                }
            }
        }
        return count;
    }
 
 
    private static List<IdeaActivity> filter(List<IdeaActivity> activities, String activityTypeCode) {
        List<IdeaActivity> results = new List<IdeaActivity>();
        for (IdeaActivity activity : activities) {
            if (activity.getTypeCode().equals(activityTypeCode)) {
                results.add(activity);
            }
        }
        return results;
    }

    private static IdeaProfileController setUpForRequest(String subjectNickname) {
        return new IdeaProfileController(subjectNickname);
    }

    private static void assertMatchesIgnoringHref(String expected, String html) {
        String htmlIgnoringHrefPattern = Pattern.compile('(href *= *)\"[^\"]*\"').matcher(html).replaceAll('$1FOO');
        System.assertEquals(expected, htmlIgnoringHrefPattern);
    }
    
}