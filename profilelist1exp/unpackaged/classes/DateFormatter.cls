public with sharing class DateFormatter {

private String xxx;

private final Account acct;
private final Contact con;
private final Opportunity opp;


public DateFormatter(ApexPages.StandardController stdController) {
 	this.xxx = stdController.getRecord().getSObjectType().getDescribe().getName();
	
	if (xxx == 'Account') {	
		this.acct = (Account)stdController.getRecord();
	}
	else if (xxx == 'Contact') {
    	this.con = (Contact)stdController.getRecord();
	}  
	else if (xxx == 'Opportunity') { 	
    	this.opp = (Opportunity)stdController.getRecord();
	}
}

public String getISODate() {

	if (acct != null) {	
		return acct.LastModifiedDate.format('yyyy-MM-dd HH:mm:ss');
	}
	else if (con != null) {
		return con.LastModifiedDate.format('yyyy-MM-dd HH:mm:ss');
	}
	else if (opp != null) {
		return opp.LastModifiedDate.format('yyyy-MM-dd HH:mm:ss');
	}
	else {
		return null;
	}
}

}