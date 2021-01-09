@isTest
private class IdeaPostControllerTest {

  static testMethod void testGetCategoriesForIdeaShouldReturnSelectedCategories() {
    IdeaPostController controller = new IdeaPostController();
    System.assert(controller.getIdea().categories == null, 'initally categories should be null');
    List<String> categories = new List<String>();
    System.assertEquals(categories, controller.getCategoriesForIdea(), 'getcategoriesforidea, when categories are null, should return an empty list');

    categories.add('a');
    controller.setCategoriesForIdea(categories);
    System.assert(controller.getIdea().categories != null, 'categories should not be null after being set');
    System.assertEquals(categories, controller.getCategoriesForIdea(), 'getcategoriesforidea should return `list of categories');

    categories = new List<String>{'b', 'c'};
    controller.setCategoriesForIdea(categories);
    System.assertEquals(new List<String>{'a','b','c'}, controller.getCategoriesForIdea(), 'getcategoriesforidea should return list of categories');
  }

  static testMethod void testAll() {
    IdeaPostController c = new IdeaPostController();
    c.getIdea();
    //c.validateCategories();
    c.save();
    c.cancel();
    c.getSimilarIdeas();
    c.loadSimilar();
    c.getHasSimilarIdeas();
    c.getCategoriesForIdea();
    List<String> categories = new List<String>();
    categories.add('a');
    c.setCategoriesForIdea(categories);
    categories = new List<String>();
    categories.add('b');
    c.setCategoriesForIdea(categories);
    c.save();

    // too many categories, save will fail
    categories = new List<String>();
    categories.add('c');
    categories.add('d');
    c.setCategoriesForIdea(categories);
    c.save();

    c.loadSimilar();
  }

  static testMethod void testNotPreviewingOnInitialization() {
    IdeaPostController controller = new IdeaPostController();
    System.assert(!controller.getPreviewing(), 'should not be previewing on initialization');
  }

  static testMethod void testPreviewWithNoErrors() {
    Integer ideaCount = [select count() from idea where idea.community.name='Test Community'];
    IdeaPostController controller = new IdeaPostController();
    controller.getIdea().title = 'a title';
    controller.getIdea().body = 'a body';
    //Assign user because new validation rule from QH requires original requestor to be not null.
    controller.getIdea().Original_Requestor__c = IdeaTestUtil.makeUser().id;
    PageReference result = controller.preview();
    logMessages('after preview');
    System.assertEquals(null, result, 'resulting page reference should be null');
    System.assertEquals(ideaCount, [select count() from idea where idea.community.name='Test Community'], 'should not insert an idea');
    System.assert(controller.getPreviewing(), 'should be previewing since there are no errors');
  }

  static testMethod void testPreviewWithErrors() {
    Integer ideaCount = [select count() from idea where idea.community.name='Test Community'];
    IdeaPostController controller = new IdeaPostController();
    controller.getIdea().body = 'a body';
    PageReference result = controller.preview();
    logMessages('after second preview');
    System.assert(!controller.getPreviewing(), 'should not be previewing since there are errors');
    System.assertEquals(null, result, 'resulting page reference should be null');
    System.assertEquals(ideaCount, [select count() from idea where idea.community.name='Test Community'], 'should not insert an idea');
  }

  static testMethod void testSaveWithNoErrors() {
    String tempTitle = 'a title - ' + system.today();
    Integer ideaCount = [select count() from idea where idea.community.name='Accountstorm' AND title = :tempTitle];
    IdeaPostController controller = new IdeaPostController();
    
    controller.getIdea().title = tempTitle;
    controller.getIdea().body = 'a body';
    //Assign user because new validation rule from QH requires original requestor to be not null.
    controller.getIdea().Original_Requestor__c = IdeaTestUtil.makeUser().id;
    PageReference result = controller.save();
    logMessages('after save no errors');
    System.assert(result != null, 'successful save should return a valid page reference');
    System.assertEquals(ideaCount+1, [select count() from idea where idea.community.name='Accountstorm' AND title = :tempTitle], 'successful save should create a new idea');
  }

  static testMethod void testSaveWithErrors() {
    Integer ideaCount = [select count() from idea where idea.community.name='Test Community'];
    IdeaPostController controller = new IdeaPostController();
    controller.getIdea().body = 'a body';
    PageReference result = controller.save();
    logMessages('after save with errors');
    System.assert(result == null, 'unsuccessful save should return a null page reference');
    System.assertEquals(ideaCount, [select count() from idea where idea.community.name='Test Community'], 'unsuccessful save should not create a new idea');
    System.assert(!controller.getPreviewing(), 'should not be previewing since we did not attempt to preview');   
  }

  static void logMessages(String prefix) {
    if (ApexPages.hasMessages()) {
      for (ApexPages.Message message : ApexPages.getMessages() ) {
        System.debug('XXXXXXXXXXXXXXXX '+prefix+' '+message.getSummary());
      }
    }
  }
  
  static testMethod void testShowDefaultMessage() {    
    IdeaPostController controller = new IdeaPostController();
    PageReference result = controller.getIdeaLink();
    system.debug('***'+result);
  }
}