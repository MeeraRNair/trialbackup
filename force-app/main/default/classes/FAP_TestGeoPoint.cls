@IsTest
private class FAP_TestGeoPoint {
  private static testmethod void testNormal(){
    FAP_GeoPoint p1 = new FAP_GeoPoint(1,4);
    
    System.assertEquals(p1.latitude,p1.lat());
    System.assertEquals(p1.longitude,p1.lng());

    System.assertEquals(p1.latitude*(FAP_GeoPoint.PI/180),p1.latRadians());
    System.assertEquals(p1.longitude*(FAP_GeoPoint.PI/180),p1.lngRadians());

    FAP_GeoPoint p2 = new FAP_GeoPoint(1,4);
    System.assert(p1.equals(p2));
    System.assert(p2.equals(p1));
    FAP_GeoPoint p3 = new FAP_GeoPoint(10,10);
    System.assert(p1.equals(null)==false);
    System.assert(p1.equals(p3)==false);
    System.assert(p3.equals(p1)==false);
    //System.assertEquals('<#FAP_GeoPoint(latitude=1.23,longitude=4.56)>',p1.toStr());
  }

  private static testmethod void testInvalidArgs(){
    Boolean exceptionThrown = false;
    try{FAP_GeoPoint p1 = new FAP_GeoPoint(-91,0); }catch(FAP_IllegalArgumentException e){exceptionThrown = true;}
    System.assert(exceptionThrown);
    try{FAP_GeoPoint p1 = new FAP_GeoPoint(91,0); }catch(FAP_IllegalArgumentException e){exceptionThrown = true;}
    System.assert(exceptionThrown);
    try{FAP_GeoPoint p1 = new FAP_GeoPoint(0,-181); }catch(FAP_IllegalArgumentException e){exceptionThrown = true;}
    System.assert(exceptionThrown);
    try{FAP_GeoPoint p1 = new FAP_GeoPoint(0,181); }catch(FAP_IllegalArgumentException e){exceptionThrown = true;}
    System.assert(exceptionThrown);
  }
}