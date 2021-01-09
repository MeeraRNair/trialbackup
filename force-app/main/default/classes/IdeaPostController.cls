/********************************************************************************



* Revision  Name     Date          Description

* 1.0       Devika   15.01.2015     CR 10828- Redirect user to Idea Intake object


**********************************************************************************/

public with sharing class IdeaPostController extends IdeaController {
    private transient Idea ideaObj;
    private transient Idea[] searchResult;
    private boolean isPreviewing = false;

    //R14.2 CR7806 - Add 5 attachments
    public transient Blob attBody1 { get; set; }
    public transient Blob attBody2 { get; set; }
    public transient Blob attBody3 { get; set; }
    public transient Blob attBody4 { get; set; }
    public transient Blob attBody5 { get; set; }
    public transient String attName1 { get; set; }
    public transient String attName2 { get; set; }
    public transient String attName3 { get; set; }
    public transient String attName4 { get; set; }
    public transient String attName5 { get; set; }
    public transient decimal fileSize1 { get; set; }
    public transient decimal fileSize2 { get; set; }
    public transient decimal fileSize3 { get; set; }
    public transient decimal fileSize4 { get; set; }
    public transient decimal fileSize5 { get; set; }
    public transient List<Attachment> ideaAttachments;
     

    public IdeaPostController(ApexPages.StandardController controller) {
         
    }

    public IdeaPostController()
    {
    }

    public boolean getPreviewing() {
        return isPreviewing;
    }

    public User currentUser {
        get {
            if (currentUser == null) {
                currentUser = [select Id, Email, CommunityNickname from User where Id = :UserInfo.getUserId()];
            }
            return currentUser;
        }
        set;
    }

    public Idea getIdea() {
        if (ideaObj == null) {
            ideaObj = new Idea();
            ideaObj.communityId = getCommunityId();
            //ideaObj.CreatedById = UserInfo.getUserId();
            ideaObj.Original_Requestor__c =UserInfo.getUserId();
        }
        return ideaObj;
    }

    private void validateCategories() {
        if (getIdea().categories != null) {

            Set<String> validCategories = new Set<String>();
            validCategories.addAll(CommunitySpecific.instance().allCategories());

            String[] categories = getIdea().categories.split(';');
            if (CommunitySpecific.instance().maxCategories() != 0 && categories.size() > CommunitySpecific.instance().maxCategories()) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Please select up to ' + CommunitySpecific.instance().maxCategories() + ' categories'));
            }
            for (String category : categories) {
                if (!validCategories.contains(category)) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Could not add idea to category "' + category + '". Please contact support.'));
                }
            }
        }
    }

    public PageReference preview() {
        isPreviewing = false;
        try {
            validateCategories();
            if (ApexPages.hasMessages()) {
                return null;
            }

            // TRICKY: we want to validate the record, but we don't want to save it
            Savepoint sp = Database.setSavepoint();
            insert ideaObj;

            //R14.2 CR7806 - Add 5 attachments - unable to implement for preview due to viewstate limit - CRQ0592
            //saveAttachments();

            Database.rollback(sp);
            isPreviewing = true;

        } catch (System.DmlException e) {
            for (Integer i = 0; i < e.getNumDml(); i++) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, ' ' + e.getDmlMessage(i)));
            }
        }
        return null;
    }

    public PageReference modify() {
        isPreviewing = false;
        return null;
    }

    //R14.2 CR7806 - Add 5 attachments
    public void saveAttachments() {
        /*
        system.debug('######## Attachments: ' + attBody1 + attName1);
        system.debug('######## Attachments: ' + attBody2 + attName2);
        system.debug('######## Attachments: ' + attBody3 + attName3);
        system.debug('######## Attachments: ' + attBody4 + attName4);
        system.debug('######## Attachments: ' + attBody5 + attName5);

        */

        system.debug('######## Idea Id: ' + ideaObj.Id);

        IdeaAttachment__c ia = [SELECT Id FROM IdeaAttachment__c WHERE IdeaID__c=:ideaObj.Id LIMIT 1];
        if(ia != null){
            ideaAttachments = new List<Attachment>();
            ideaAttachments.add(new Attachment(parentId = ia.Id, body = attBody1, name = attName1));
            ideaAttachments.add(new Attachment(parentId = ia.Id, body = attBody2, name = attName2));
            ideaAttachments.add(new Attachment(parentId = ia.Id, body = attBody3, name = attName3));
            ideaAttachments.add(new Attachment(parentId = ia.Id, body = attBody4, name = attName4));
            ideaAttachments.add(new Attachment(parentId = ia.Id, body = attBody5, name = attName5));
        }


        List<Attachment> attachmentsToSave = new List<Attachment>();
        for(Attachment att : ideaAttachments) {
            //if(att.body != null && att.name != null) {
            if(att.name != null) {
                attachmentsToSave.add(att);
            }
        }

        ideaAttachments.clear();
        ideaAttachments = null;
        upsert attachmentsToSave;

        /*
        for(Attachment at : attachmentsToSave) {
            system.debug('######## attachmentsToSave : ' + at.body + at.name);
        }
        for(Attachment aat : ideaAttachments) {
            system.debug('######## ideaAttachmentsReduced : ' + aat.body + aat.name);
        }
        */
    }

    public PageReference save() {
        isPreviewing = false;
        try {
            validateCategories();

            if (ApexPages.hasMessages()) {
                return null;
            }

            //R14.2 CR7806 - validate each of the filesize before saving
            if (fileSize1 > 5000000) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'File size of Attachment 1 is too big. Please select a file smaller than the 5MB limit.'));
                return null;
            }

            if (fileSize2 > 5000000) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'File size of Attachment 2 is too big. Please select a file smaller than the 5MB limit.'));
                return null;
            }

            if (fileSize3 > 5000000) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'File size of Attachment 3 is too big. Please select a file smaller than the 5MB limit.'));
                return null;
            }

            if (fileSize4 > 5000000) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'File size of Attachment 4 is too big. Please select a file smaller than the 5MB limit.'));
                return null;
            }

            if (fileSize5 > 5000000) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'File size of Attachment 5 is too big. Please select a file smaller than the 5MB limit.'));
                return null;
            }

            insert ideaObj;

            //R14.2 CR7806 - Add 5 attachments
            saveAttachments();

            PageReference ideaPage = getListPage(IdeaController.SORT_RECENT, null, null);
            ideaPage.setRedirect(true);
            return ideaPage;
        } catch (System.DmlException e) {
            for (Integer i = 0; i < e.getNumDml(); i++) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, ' ' + e.getDmlMessage(i)));
            }
            return null;
        }
    }

    public PageReference cancel() {
        PageReference ideaPage = getListPage(sortParam, categoryParam, statusParam);
        ideaPage.setRedirect(true);
        return ideaPage;
    }

    public Idea[] getSimilarIdeas() {
        return searchResult;
    }

    public PageReference loadSimilar() {
        getIdea();
        Id[] similarIds = Ideas.findSimilar(ideaObj);
        if (similarIds == null || similarIds.size() == 0) {
            return null;
        } else {
            searchResult = [select title from idea where id in :similarIds];
        }
        return null;
    }

    public Boolean getHasSimilarIdeas() {
        return searchResult != null && searchResult.size() > 0;
    }

    public List<SelectOption> selectOptionsFromArray(String[] values) {
        List<SelectOption> valueOptions = new List<SelectOption>();
        for (String value : values) {
            valueOptions.add(new SelectOption(value, value));
        }
        return valueOptions;
    }

    public String[] getCategoriesForIdea() {
        String categories = getIdea().categories;
        if (categories == null) {
            return new List<String>();
        } else {
            return categories.split(';');
        }
    }

    public void setCategoriesForIdea(String[] categories) {
        String categoryString = '';

        for (String category : categories) {
            if (categoryString.length() > 0) {
                categoryString += ';';
            }
            categoryString += category;
        }

        Idea idea = getIdea();
        if (idea.categories == null || idea.categories.length() == 0) {
            idea.categories = categoryString;
        } else if (categoryString.length() > 0) {
            idea.categories += ';';
            idea.categories += categoryString;
        }
    }

    public void setSelectedCategoryString(String selectedCategoryString) {
        getIdea().categories = selectedCategoryString;
    }

    public String getSelectedCategoryString() {
        return getIdea().categories;
    }

//    public Integer getMaxCategories() {
//        return CommunitySpecific.instance().maxCategories();
//    }

    public String getCategoryMaxDescription() {
        if (CommunitySpecific.instance().maxCategories() == 0) {
            return '';
        }
        return ' up to ' + CommunitySpecific.instance().maxCategories().format();
    }
    
    public PageReference getIdeaLink(){
       system.debug('*********inside loop'); 
       Schema.DescribeSObjectResult IdeaIntakeObject = Idea_Intake__c.sObjectType.getDescribe();
       PageReference page =  new PageReference('/'+IdeaIntakeObject.getKeyPrefix());      
       page.setRedirect(true);
       return page;
    }
}