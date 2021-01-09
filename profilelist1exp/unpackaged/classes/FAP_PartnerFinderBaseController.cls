public abstract class FAP_PartnerFinderBaseController extends FAP_StickyParametersController {

  public static final String HTTP_LANGUAGE_CODE_PARAMETER_KEY = 'l';

  public FAP_PartnerFinderBaseController(){
    super(new String[]{HTTP_LANGUAGE_CODE_PARAMETER_KEY});
  }
  
  public String getPreferredLanguageCode(){
    return FAP_LanguageUtils.getLangCodeByHttpParamOrIfNullThenUser();
  }
 

}