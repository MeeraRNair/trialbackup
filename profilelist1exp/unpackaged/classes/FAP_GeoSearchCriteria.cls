global class FAP_GeoSearchCriteria {

    global static final Double MAX_DISTANCE_IN_MILES = 20000;
    global static final Double MAX_DISTANCE_IN_KILOMETERS = 
        FAP_ConversionUtils.convert(MAX_DISTANCE_IN_MILES,FAP_UnitOfLength.MILES,FAP_UnitOfLength.KILOMETERS);

    global FAP_GeoPoint point {get;private set;}
    global Double distance {get;private set;}
    global FAP_UnitOfLength unit {get;private set;}
    global FAP_GeoBounds bounds {get;private set;}
    
    global FAP_GeoSearchCriteria(FAP_GeoPoint point, Double distance, FAP_UnitOfLength unit){
        if(point == null){
            throw new FAP_IllegalArgumentException('Invalid argument: point is null');
        }
        this.point = point;
        if(unit == null){
            throw new FAP_IllegalArgumentException('Invalid argument: unitOfLength is null');
        }
        this.unit = unit;
        if(distance == null || distance <= 0){
            throw new FAP_IllegalArgumentException('Invalid argument: distance is null, zero, or less than zero');
        }
        this.distance = distance;
        if(this.distanceInKilometers > MAX_DISTANCE_IN_KILOMETERS){
            throw new FAP_IllegalArgumentException('Invalid argument: distance (' 
                + distanceInKilometers 
                + 'km) exceeds max distance (' 
                + MAX_DISTANCE_IN_KILOMETERS 
                + 'km)');
        }
        this.bounds = getBounds(this);
    }
    
    global Double distanceInKilometers {get{
      return FAP_ConversionUtils.convert(distance,unit,FAP_UnitOfLength.KILOMETERS);
    }}
    
    global Double distanceInMiles {get{
        return FAP_ConversionUtils.convert(distance,unit,FAP_UnitOfLength.MILES);
    }}
    
    private static FAP_GeoBounds getBounds(FAP_GeoSearchCriteria criteria){
      return FAP_GeoMath.getBounds(criteria.point, criteria.distanceInKilometers);
    }
    
    global String toStr(){ return '<#GeoSearchCriteria(point=' + point.toStr() + ',distanceInKilometers=' + distanceInKilometers + ')>'; }
    
    global FAP_GeoSearchCriteria cloneByDistanceIncrement(Double distanceIncrement, FAP_UnitOfLength unit){
        return new FAP_GeoSearchCriteria(this.point,this.distance+(FAP_ConversionUtils.convert(distanceIncrement,unit,this.unit)),this.unit);     
    }
    
}