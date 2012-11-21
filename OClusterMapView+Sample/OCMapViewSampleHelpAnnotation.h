//
//  OCMapViewSampleHelpAnnotation.h
//  openClusterMapView
//
//  Created by Botond Kis on 17.07.11.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "OCGrouping.h"

@interface OCMapViewSampleHelpAnnotation : NSObject <MKAnnotation, OCGrouping>

// MKAnnotation implementation
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subtitle;
@property (readonly, nonatomic, assign) CLLocationCoordinate2D coordinate;

// OCGrouping implementation
@property (copy, nonatomic) NSString *groupTag;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
