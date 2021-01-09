public with sharing class QuoteController {
	
     private final DellOpenSalesService.Order quote;

      public String qid = ApexPages.currentPage().getParameters().get('id');
       
      public QuoteController() {
          DellOpenSalesService.OpenSalesServiceSoap  svc = new DellOpenSalesService.OpenSalesServiceSoap();
          svc.timeout_x = 30000; // timeout in milliseconds      
      	try {
          quote = svc.GetQuoteDetail(qid);
      	}
      	catch(Exception e) {
          PageUtils.addError('We are experiencing technical difficulty.  Please try again later. (ERROR -- ' + e + ')');
      	}
      }
      
      // for test only
      public QuoteController(String strPDF) {
        	getQuote();
        	getPDFUrl();  	
      }
      
      public DellOpenSalesService.Order getQuote() {
            return quote;
      }
      
 	  public String getPDFUrl() {
        	return qid;    
      }
}