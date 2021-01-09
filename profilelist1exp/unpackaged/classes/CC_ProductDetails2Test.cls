@isTest
public class CC_ProductDetails2Test{
    //Method to pass new value to constructor 
     public static testmethod void unittest1(){
        CC_ProductDetails.Data dbc=new CC_ProductDetails.Data();
      
            CC_ProductDetails.Data datdetail = new CC_ProductDetails.Data(null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);
            CC_ProductDetails details = new CC_ProductDetails();
                details.Action = 'BaseMerge';
                details.Attempt = 3;
                details.Data = new List<CC_ProductDetails.Data>();
                details.Data.add(datdetail);
                system.assert(details!=Null);
    }
}