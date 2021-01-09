public class FAP_PartnerSearchAutoCompleteController {

    public List<String> results {get;set;}
    
    public static final String PARAM_KEYWORD = 'txtSearchFor';
    public static final String PARAM_LOCATION = 'txtLocation';
    
    public FAP_PartnerSearchAutoCompleteController(){
        final String keywordSearchStr = 
          getFirstMatchingParam(PARAM_KEYWORD) == null 
              ? null 
              : String.escapeSingleQuotes(getFirstMatchingParam(PARAM_KEYWORD));
        final String locationSearchStr = 
          getFirstMatchingParam(PARAM_LOCATION) == null 
              ? null 
              : String.escapeSingleQuotes(getFirstMatchingParam(PARAM_LOCATION));
        
        FAP_AutoCompleteSearch autoCompleteSearch = null;
        if(FAP_StringUtils.isNotEmpty(keywordSearchStr)){
          system.debug('######## page params = ' + ApexPages.currentPage().getParameters());
            autoCompleteSearch = new FAP_AutoCompletePartnerName(keywordSearchStr);
        } else if(FAP_StringUtils.isNotEmpty(locationSearchStr)){
          system.debug('######## page params = ' + ApexPages.currentPage().getParameters());
          autoCompleteSearch = new FAP_AutoCompleteLocation(locationSearchStr);
        } else {
            
        }
        this.results = (autoCompleteSearch == null ? new List<String>() : autoCompleteSearch.execute());
    }
    
    private String getFirstMatchingParam(String paramName){
        Map<String,String> params = FAP_PageUtils.getParameters(paramName);
        return params == null || params.size() <= 0 ? null : params.values().get(0);
    }

}