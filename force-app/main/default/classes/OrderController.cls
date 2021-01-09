public with sharing class OrderController {

 	private final DellOpenSalesService.Order order;

  	public String id = ApexPages.currentPage().getParameters().get('id');    
 	
 	private String[] splitID() {
 		if (id == null) {
 			id ='test-test';    // for test only
 		}
 		return id.split('-');
 	}
	
	private String[] strSplit = splitID();
	private String BUID = strSplit[0]; 
    private String oid = strSplit[1];
 		
    public OrderController() {
     	DellOpenSalesService.OpenSalesServiceSoap  svc = new DellOpenSalesService.OpenSalesServiceSoap();
        svc.timeout_x = 30000; // timeout in milliseconds
    	try {
       		order = svc.GetOrder(oid, BUID);
       	}
      	catch(Exception e) {
          	PageUtils.addError('We are experiencing technical difficulty.  Please try again later. (ERROR -- ' + e + ')');
      	}
   	}
      
  	// for test only
   	public OrderController(String strTest) {
      	getOrder();
   	}
      
   	public DellOpenSalesService.Order getOrder() {
      	return order;
    }

}