//
//  OCMapViewSampleHelpAnnotation.m
//  openClusterMapView
//
//  Created by Botond Kis on 17.07.11.
//

#import "OCMapViewSampleHelpAnnotation.h"

@implementation OCMapViewSampleHelpAnnotation

@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize coordinate = _coordinate;
@synthesize groupTag = _groupTag;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    self = [super init];
    if (self) {
        _coordinate = coordinate;
    }
    
    return self;
}

@end
