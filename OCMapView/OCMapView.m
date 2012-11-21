//
//  OCMapView.m
//  openClusterMapView
//
//  Created by Botond Kis on 14.07.11.
//

#import "OCMapView.h"

@interface OCMapView (private)
- (void)initSetUp;
@end

@implementation OCMapView

@synthesize clusteringEnabled;
@synthesize annotationsToIgnore;
@synthesize clusteringMethod;
@synthesize clusterSize;
@synthesize clusterByGroupTag;
@synthesize minLongitudeDeltaToCluster;

- (id)init {
    self = [super init];
    if (self) {
        // call actual initializer
        [self initSetUp];
    }
    
    return self;
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // call actual initializer
        [self initSetUp];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];    
    if (self) {
        // call actual initializer
        [self initSetUp];
    }
    return self;
}

- (void)initSetUp {
    allAnnotations = [[NSMutableSet alloc] init];
    annotationsToIgnore = [[NSMutableSet alloc] init];
    clusteringMethod = OCClusteringMethodBubble;
    clusterSize = 0.2;
    minLongitudeDeltaToCluster = 0.0;
    clusteringEnabled = YES;
    clusterByGroupTag = NO;
    backgroundClusterQueue = dispatch_queue_create("com.OCMapView.clustering", NULL);  
}

- (void)dealloc {
    dispatch_release(backgroundClusterQueue);
}

// ======================================
#pragma mark MKMapView implementation

- (void)addAnnotation:(id < MKAnnotation >)annotation {
    [allAnnotations addObject:annotation];
    [self doClustering];
}

- (void)addAnnotations:(NSArray *)annotations {
    [allAnnotations addObjectsFromArray:annotations];
    [self doClustering];
}

- (void)removeAnnotation:(id < MKAnnotation >)annotation {
    [allAnnotations removeObject:annotation];
    [self doClustering];
}

- (void)removeAnnotations:(NSArray *)annotations {
    for (id<MKAnnotation> annotation in annotations) {
        [allAnnotations removeObject:annotation];
    }
    [self doClustering];
}


// ======================================
#pragma mark - Properties
//
// Returns, like the original method,
// all annotations in the map unclustered.
- (NSArray *)annotations {
    return [allAnnotations allObjects];
}

//
// Returns all annotations which are actually displayed on the map. (clusters)
- (NSArray *)displayedAnnotations {
    return super.annotations;    
}

//
// enable or disable clustering
- (void)setClusteringEnabled:(BOOL)enabled {
    clusteringEnabled = enabled;
    [self doClustering];
}

// ======================================
#pragma mark - Clustering

- (void)doClustering {
    // Remove the annotation which should be ignored
    NSMutableArray *annotationsToCluster = [self filterAnnotationsForVisibleMap:allAnnotations];
    [annotationsToCluster removeObjectsInArray:[annotationsToIgnore allObjects]];
    
    //calculate cluster radius
    CLLocationDistance clusterRadius = self.region.span.longitudeDelta * clusterSize;
    
    // Do clustering
    NSArray *clusteredAnnotations;
    
    // Check if clustering is enabled and map is above the minZoom
    if (clusteringEnabled && (self.region.span.longitudeDelta > minLongitudeDeltaToCluster)) {
        // switch to selected algoritm
        switch (clusteringMethod) {
            case OCClusteringMethodBubble:{
                clusteredAnnotations = [OCAlgorithms bubbleClusteringWithAnnotations:annotationsToCluster andClusterRadius:clusterRadius grouped:self.clusterByGroupTag];
                break;
            }
            case OCClusteringMethodGrid:{
                clusteredAnnotations = [OCAlgorithms gridClusteringWithAnnotations:annotationsToCluster andClusterRect:MKCoordinateSpanMake(clusterRadius, clusterRadius)  grouped:self.clusterByGroupTag];
                break;
            }
            default:{
                clusteredAnnotations = annotationsToCluster;
                break;
            }
        }
    }
    // pass through without when not
    else {
        clusteredAnnotations = annotationsToCluster;
    }
    
    // Clear map but leave UserLocation
    NSMutableArray *annotationsToRemove = [self.displayedAnnotations mutableCopy];
    [annotationsToRemove removeObject:self.userLocation];
    [annotationsToRemove removeObjectsInArray:clusteredAnnotations];

    // add clustered annotations to map
    [super addAnnotations:clusteredAnnotations];

    // fix for flickering
    [super removeAnnotations:annotationsToRemove];

    // add ignored annotations
    [super addAnnotations:[annotationsToIgnore allObjects]];
}

#pragma mark - Helpers

- (NSMutableArray *)filterAnnotationsForVisibleMap:(NSSet *)annotationsToFilter {
    // return array
    NSMutableArray *filteredAnnotations = [[NSMutableArray alloc] initWithCapacity:[annotationsToFilter count]];
    
    MKMapRect visibleRect = self.visibleMapRect;

    for (id<MKAnnotation> annotation in annotationsToFilter) {
        MKMapPoint pt = MKMapPointForCoordinate( annotation.coordinate );
        if (MKMapRectContainsPoint( visibleRect, pt ) ) {
            [filteredAnnotations addObject:annotation];
        }
    }
    
    return filteredAnnotations;
}

@end
