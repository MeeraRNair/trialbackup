public abstract class DellStandardController extends StickyParametersController {

	public static final String HTTP_LANGUAGE_CODE_PARAMETER_KEY = 'l';

	public DellStandardController(){
		super(new String[]{HTTP_LANGUAGE_CODE_PARAMETER_KEY});
	}
	
	private static String[] SUPPORTED_LANGUAGE_CODES = new String[]{
		'zh-cn'         //Chinese (Simplified)
		,'zh-tw'        //Chinese (Traditional)
		,'nl-nl'        //Dutch
		,'en-us'        //English
		,'fi'           //Finnish
		,'fr'           //French
		,'de'           //German
		,'it'           //Italian
		,'ja'           //Japanese
		,'ko'           //Korean
		,'pl'           //Polish
		,'pt-br'        //Portuguese (Brazilian)
		,'ru'           //Russian
		,'es'           //Spanish
		,'sv'           //Swedish
		,'th'           //Thai
		,'cs'           //Czech
		,'da'           //Danish
		,'hu'           //Hungarian
		,'in'           //Indonesian
		,'tr'           //Turkish
	};


	public String getPreferredLanguageCode(){
		//====================================================
		//(1) CHECK HTTP "LANGUAGE" PARAMETER
		//====================================================
		final Set<String> LANGUAGE_CODE_SET = getSuppLangCodeSet();
		System.debug('LANGUAGE_CODE_SET = ' + SetUtils.toString(LANGUAGE_CODE_SET));
		final String LANGUAGE_HTTP_PARAMETER = 
		StringUtils.lowerCase(
			StringUtils.replaceChars( 
				ApexPages.currentPage().getParameters().get(HTTP_LANGUAGE_CODE_PARAMETER_KEY), '_', '-'
			)
		);
		System.debug('LANGUAGE_HTTP_PARAMETER = ' + LANGUAGE_HTTP_PARAMETER);
		if(StringUtils.isNotBlank(LANGUAGE_HTTP_PARAMETER)
			&& LANGUAGE_CODE_SET.contains(LANGUAGE_HTTP_PARAMETER)){
			System.debug('Return Option (1) LANGUAGE HTTP PARAMETER: ' + LANGUAGE_HTTP_PARAMETER);
			return LANGUAGE_HTTP_PARAMETER;
		}
		
		//====================================================
		//(2) CHECK BROWSER SETTINGS
		//====================================================
		final String LANGUAGES_FROM_BROWSER_AS_STRING = ApexPages.currentPage().getHeaders().get('Accept-Language');
		System.debug('LANGUAGES_FROM_BROWSER_AS_STRING = ' + LANGUAGES_FROM_BROWSER_AS_STRING);
		final List<String> LANGUAGES_FROM_BROWSER_AS_LIST = splitAndFilterAcceptLanguageHeader(LANGUAGES_FROM_BROWSER_AS_STRING);
		System.debug('LANGUAGES_FROM_BROWSER_AS_STRING = ' + ArrayUtils.toString(LANGUAGES_FROM_BROWSER_AS_LIST));
		if(LANGUAGES_FROM_BROWSER_AS_LIST != null && LANGUAGES_FROM_BROWSER_AS_LIST.size() > 0){
			for(String languageFromBrowser : LANGUAGES_FROM_BROWSER_AS_LIST){
				if(LANGUAGE_CODE_SET.contains(languageFromBrowser)){
					System.debug('Return Option (2) BROWSER SETTINGS: ' + languageFromBrowser);
					return languageFromBrowser;
				}
			}               
		}
		
		//====================================================
		//(3) USER SETTINGS
		//====================================================
		return UserInfo.getLanguage();
	}
 
	private static List<String> splitAndFilterAcceptLanguageHeader(String header){
		List<String> returnList = new List<String>();
		String[] tokens = StringUtils.split(header,',');
		if(tokens != null){
			for(String token : tokens){
				if(token != null ){
					if(token.contains(';')){
						token = token.substring(0,token.indexOf(';',0));
					}
					returnList.add(token);
					if(StringUtils.length(token) > 2){
						returnList.add(StringUtils.substring(token,0,2));
					}
				}
			}       
		}
		return returnList;
	}
	
	private static Set<String> getSuppLangCodeSet(){
		Set<String> langCodes = new Set<String>();
		for(String langCode : SUPPORTED_LANGUAGE_CODES){
			if(langCode != null){ 
				langCodes.add(StringUtils.lowerCase(langCode));
			}
		}
		return langCodes;
	}
	
	public String[] getSupportedLanguageCodes(){
		return SUPPORTED_LANGUAGE_CODES;
	}

}