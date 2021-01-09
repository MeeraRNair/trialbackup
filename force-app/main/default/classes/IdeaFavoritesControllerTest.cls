@isTest
private class IdeaFavoritesControllerTest {
    static User me;
    static User her;
    static Idea myIdea;
    static Idea herIdea;
    static long now;
    
    static testMethod void testFavoriteIdeasByCreatedDate() {
        me = IdeaTestUtil.makeUser('Me', 'My Nickname');
        her = IdeaTestUtil.makeUser('Her', 'Her Nickname');
        User userA = IdeaTestUtil.makeUser('AAA', 'AAA');
        Idea userAIdea1 = IdeaTestUtil.makeIdea('ZZZ', 'abc', userA, 500);
        Idea userAIdea2 = IdeaTestUtil.makeIdea('YYY', 'abc', userA, 1000);
        Idea userAIdea3 = IdeaTestUtil.makeIdea('XXX', 'abc', userA, 700);
        
       
        System.runAs(me) {
            IdeaFavoritesController favCon = new IdeaFavoritesController();
            IdeaDetailsController controller = new IdeaDetailsController(userAIdea1);
            controller.addFavorite();
            controller = new IdeaDetailsController(userAIdea2);
            controller.addFavorite();
            controller = new IdeaDetailsController(userAIdea3);
            controller.addFavorite();
            List<IdeaWithVote> ideasWithVotes = favCon.fetchIdeasList('CreatedDate');
            System.assertEquals(userAIdea2.title, ideasWithVotes[0].idea.title);
            System.assertEquals(userAIdea3.title, ideasWithVotes[1].idea.title);
            System.assertEquals(userAIdea1.title, ideasWithVotes[2].idea.title);
        }
    }
    
    static testMethod void testFavoriteIdeasByAlias() {
        me = IdeaTestUtil.makeUser('Me', 'My Nickname');
        her = IdeaTestUtil.makeUser('Her', 'Her Nickname');
        User userA = IdeaTestUtil.makeUser('AAA', 'AAA');
        User userB = IdeaTestUtil.makeUser('BBB', 'BBB');
        User userC = IdeaTestUtil.makeUser('CCC', 'CCC');
        Idea userAIdea = IdeaTestUtil.makeIdea('ZZZ', 'abc', userA, 500);
        Idea userBIdea = IdeaTestUtil.makeIdea('YYY', 'abc', userB, 0);
        Idea userCIdea = IdeaTestUtil.makeIdea('XXX', 'abc', userC, 200);
        IdeaTestUtil.vote(me, userAIdea, 'Down');
        IdeaTestUtil.vote(me, userBIdea, 'Up');
        System.runAs(me) {
            IdeaFavoritesController favCon = new IdeaFavoritesController();
            IdeaDetailsController controller = new IdeaDetailsController(userAIdea);
            controller.addFavorite();
            controller = new IdeaDetailsController(userBIdea);
            controller.addFavorite();
            controller = new IdeaDetailsController(userCIdea);
            controller.addFavorite();
            List<IdeaWithVote> ideasWithVotes = favCon.fetchIdeasList('Alias');
            System.assertEquals(userA.CommunityNickname, ideasWithVotes[0].idea.CreatedBy.CommunityNickname);
            System.assertEquals(userB.CommunityNickname, ideasWithVotes[1].idea.CreatedBy.CommunityNickname);
            System.assertEquals(userC.CommunityNickname, ideasWithVotes[2].idea.CreatedBy.CommunityNickname);
        }
    }
    
    static testMethod void testFavoriteIdeasByTitle() {
        me = IdeaTestUtil.makeUser('Me', 'My Nickname');
        User userA = IdeaTestUtil.makeUser('AAA', 'AAA');
        User userB = IdeaTestUtil.makeUser('BBB', 'BBB');
        User userC = IdeaTestUtil.makeUser('CCC', 'CCC');
        Idea userAIdea = IdeaTestUtil.makeIdea('ZZZ', 'abc', userA, 500);
        Idea userBIdea = IdeaTestUtil.makeIdea('YYY', 'abc', userB, 0);
        Idea userCIdea = IdeaTestUtil.makeIdea('XXX', 'abc', userC, 200);
        IdeaTestUtil.vote(me, userAIdea, 'Down');
        IdeaTestUtil.vote(me, userBIdea, 'Up');
        System.runAs(me) {
            IdeaFavoritesController favCon = new IdeaFavoritesController();
            IdeaDetailsController controller = new IdeaDetailsController(userAIdea);
            controller.addFavorite();
            controller = new IdeaDetailsController(userBIdea);
            controller.addFavorite();
            controller = new IdeaDetailsController(userCIdea);
            controller.addFavorite();
            List<IdeaWithVote> ideasWithVotes = favCon.fetchIdeasList('Title');
            System.assertEquals(userCIdea.title, ideasWithVotes[0].idea.title);
            System.assertEquals(userBIdea.title, ideasWithVotes[1].idea.title);
            System.assertEquals(userAIdea.title, ideasWithVotes[2].idea.title);
        }
    }   
    
    
}