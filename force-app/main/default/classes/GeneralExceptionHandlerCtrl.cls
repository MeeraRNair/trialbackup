public class GeneralExceptionHandlerCtrl {

	private String retURL {set;get;}
	private String errorStr {set;get;}
	public GeneralExceptionHandlerCtrl(){
		errorStr = ApexPages.currentPage().getParameters().get('errorStr');
		retURL   = ApexPages.currentPage().getParameters().get('retURL');
		System.debug('errorStr ='+errorStr);
		System.debug('retURL on top =' +retURL );
		if(StringUtils.isNotBlank(errorStr)){
			PageUtils.addError(errorStr);
		}
	}
	
	public PageReference cancel() {
		PageReference cancelPR = new PageReference(retURL);
		System.debug('cancelPR =' +cancelPR);
		cancelPR.setRedirect(true);
 		return cancelPR;
 	}
 	
 	static testMethod void testGeneralExceptionHandler(){
 		ApexPages.currentPage().getParameters().put('errorStr', 'Please ensure account country is set.');
 		ApexPages.currentPage().getParameters().put('retURL','www.google.com');
 		GeneralExceptionHandlerCtrl exceptionHandler = new GeneralExceptionHandlerCtrl();
 		system.assertEquals(exceptionHandler.errorStr, 'Please ensure account country is set.');
 		PageReference tempPR = new PageReference('www.google.com');
 		tempPR.setRedirect(true);
 		System.debug('exceptionHandler.cancel() =='+exceptionHandler.cancel());
 		System.debug('tempPR =='+tempPR);
 		system.assertEquals(exceptionHandler.cancel().getURL(),tempPR.getURL());
 	}
}