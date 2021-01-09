public class IdeaChildDetailsController extends IdeaController {
    public Idea conChildIdea { get; set; }

    public String getCreatedByCommunityNickname() {
        return conChildIdea.createdBy.communityNickname;
    }

    public String getCreatedById() {
        return conChildIdea.createdBy.id;
    }
    
    public String getFormattedDate() {
        return conChildIdea.createdDate.format('d MMM yyyy h:mm a');	
    }

    static testMethod void testGetters() {
        IdeaTestUtil.setupTest();
        IdeaChildDetailsController controller = new IdeaChildDetailsController();
        Idea idea = IdeaTestUtil.makeIdea();
        controller.conChildIdea = idea;
        controller.getCreatedByCommunityNickname();
        controller.getCreatedById();
        controller.getFormattedDate();
    }

}