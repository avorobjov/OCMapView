//
//  OEDistance.h
//  openClusterMapView
//
//  Created by Botond Kis on 14.02.11.
//

#import "OCDistance.h"

//
// calculates the distance
// between two given coordinates
CLLocationDistance getDistance(CLLocationCoordinate2D firstLocation, CLLocationCoordinate2D secondLocation) {
    // Calculate differences of the to annotations
    CLLocationDistance deltaLat = firstLocation.latitude - secondLocation.latitude;
    CLLocationDistance deltaLon = firstLocation.longitude - secondLocation.longitude;
    
    return sqrt( deltaLat * deltaLat + deltaLon * deltaLon );
}


//
// This c function returns true if the distance
// between two given locations is shorter
// or equal than the designated distance.
// The distance represents the cluster size.
BOOL isLocationNearToOtherLocation(CLLocationCoordinate2D firstLocation, CLLocationCoordinate2D secondLocation, CLLocationDistance distanceInGeoCoordinates) {
    return (getDistance( firstLocation, secondLocation ) <= distanceInGeoCoordinates);
}
