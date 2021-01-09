public class FAP_ShowcaseClass {

  public ID id {get; set;}
  public String name {get;set;}
  public String caseStudyImageUrl {get;set;}
  public String showCaseTitle {get;set;}
  public String showCaseTitleUrl {get;set;}
  public String showCaseType {get;set;}
  public String shortDescription{get; set;}
  public String longDescription{get;set;}
  public String videoUrl{get;set;}
  public List<FAP_FormField> detailFields{get; set;}

  public static FAP_ShowcaseClass build(Partner_Showcase__c showcasefields){
    FAP_ShowcaseClass sc   = new FAP_ShowcaseClass();
    sc.Id     = showcasefields.Id; 
    sc.name    = showcasefields.Name;
    sc.showCaseTitle  = showcasefields.ShowCase_Title__c;
    sc.showCaseTitleUrl  = showcasefields.ShowCase_Title_Url__c;
    sc.shortDescription=showcasefields.Short_Description__c;
    sc.longDescription=showcasefields.Long_Description__c;
    
    return sc;
  }  
  
  public String toJSON(){
    return 
      '{'
      + '"id":' + FAP_JSONUtils.encode(this.id) 
      + ',"name":' + FAP_JSONUtils.encode(this.name) 
      + ',"caseStudyImageUrl":' + FAP_JSONUtils.encode(this.caseStudyImageUrl) 
      + ',"videoUrl":' + FAP_JSONUtils.encode(this.videoUrl) 
      + ',"showCaseTitle":' + FAP_JSONUtils.encode(this.showCaseTitle) 
      + ',"showCaseTitleUrl":' + FAP_JSONUtils.encode(this.showCaseTitleUrl) 
      + ',"showCaseType":' + FAP_JSONUtils.encode(this.showCaseType) 
      + ',"shortDescription":' + FAP_JSONUtils.encode(this.shortDescription) 
      + ',"longDescription":' + FAP_JSONUtils.encode(this.longDescription) 
      + '}';
  }


}