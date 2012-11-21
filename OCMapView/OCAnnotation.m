//
//  OCAnnotation.m
//  openClusterMapView
//
//  Created by Botond Kis on 14.07.11.
//

#import "OCAnnotation.h"

@implementation OCAnnotation

@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize coordinate = _coordinate;
@synthesize groupTag = _groupTag;
@synthesize annotationsInCluster = _annotationsInCluster;

- (id)init {
    self = [super init];
    if (self) {
        _coordinate = kCLLocationCoordinate2DInvalid;
        _annotationsInCluster = [[NSMutableArray alloc] init];
    }

    return self;
}

- (id)initWithAnnotation:(id <MKAnnotation>) annotation {
    self = [super init];
    if (self) {
        _annotationsInCluster = [[NSMutableArray alloc] initWithObjects:&annotation count:1];

        _title = annotation.title;
        _subtitle = annotation.subtitle;
        _coordinate = annotation.coordinate;
    }

    return self;
}

#pragma mark - manipulate cluster

- (void)addAnnotation:(id < MKAnnotation >)annotation {
    // Add annotation to the cluster
    [_annotationsInCluster addObject:annotation];

    // get the number of stored annotations
    float multiplier = 1.0f/(float)[_annotationsInCluster count];

    // calc delta vector
    CLLocationCoordinate2D deltaCoord;
    deltaCoord.latitude = (_coordinate.latitude - annotation.coordinate.latitude) * multiplier;
    deltaCoord.longitude = (_coordinate.longitude - annotation.coordinate.longitude) * multiplier;

    // recenter
    _coordinate.latitude = deltaCoord.latitude + annotation.coordinate.latitude;
    _coordinate.longitude = deltaCoord.longitude + annotation.coordinate.longitude;
}

- (void)addAnnotations:(NSArray *)annotations {
    for (id<MKAnnotation> annotation in annotations)
        [self addAnnotation: annotation];
}

- (void)removeAnnotation:(id < MKAnnotation >)annotation {
    // get the number of stored annotations
    float multiplier = 1.0f/(float)[_annotationsInCluster count];

    // calc delta vector
    CLLocationCoordinate2D deltaCoord;
    deltaCoord.latitude = (_coordinate.latitude - annotation.coordinate.latitude) * multiplier;
    deltaCoord.longitude = (_coordinate.longitude - annotation.coordinate.longitude) * multiplier;

    // recenter
    _coordinate.latitude = deltaCoord.latitude - annotation.coordinate.latitude;
    _coordinate.longitude = deltaCoord.longitude - annotation.coordinate.longitude;

    // Remove annotation from cluster
    [_annotationsInCluster removeObject:annotation];
}

- (void)removeAnnotations:(NSArray *)annotations {
    for (id<MKAnnotation> annotation in annotations)
        [self removeAnnotation: annotation];
}

@end
