global class FAP_GeoBounds {

    global static final FAP_GeoBounds MAX = new FAP_GeoBounds(
        new FAP_GeoPoint(-90,-180)
        ,new FAP_GeoPoint(90,180)
    ); 
    
  global FAP_GeoPoint northeast {get;set;}
  global FAP_GeoPoint southwest {get;set;}

  global FAP_GeoBounds(List<FAP_GeoPoint> points){
    initialize(points);
  }
  
  global FAP_GeoBounds(FAP_GeoPoint southwest, FAP_GeoPoint northeast){
    initialize(new FAP_GeoPoint[]{southwest,northeast});
  }
  
  private void initialize(List<FAP_GeoPoint> points){
    if(points != null && points.size()>0){
      Double minLat = 90; 
      Double maxLat = -90; 
      Double minLng = 180; 
      Double maxLng = -180;
      for(FAP_GeoPoint point : points){
        minLat = point.lat() < minLat ? point.lat() : minLat;
        maxLat = point.lat() > maxLat ? point.lat() : maxLat;
        minLng = point.lng() < minLng ? point.lng() : minLng;
        maxLng = point.lng() > maxLng ? point.lng() : maxLng;
      } 
      this.northeast = new FAP_GeoPoint(maxLat,maxLng);
      this.southwest = new FAP_GeoPoint(minLat,minLng);
    }
  }
  
  global Boolean contains(FAP_GeoPoint point){
    if(point == null || northeast == null || southwest == null){
      return false;
    }
    return 
        this.northeast.lat() > point.lat()
      &&   this.southwest.lat() < point.lat()
      &&   this.northeast.lng() > point.lng()
      &&   this.southwest.lng() < point.lng()
    ;
  }

  global String toStr(){
    return '<#GeoBounds(northeast=' + (northeast==null ? null : northeast.toStr()) 
      + ',southwest=' + (southwest==null ? null : southwest.toStr()) + ')>';
  }
}