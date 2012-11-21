//
//  OClusterMapView_SampleViewController.m
//  OClusterMapView+Sample
//
//  Created by Botond Kis on 25.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SampleViewController.h"
#import "OCMapViewSampleHelpAnnotation.h"
#import <math.h>

NSString * const kTYPE1 = @"Banana";
NSString * const kTYPE2 = @"Orange";

#define ARC4RANDOM_MAX 0x100000000
#define kDEFAULTCLUSTERSIZE 0.2

CLLocationCoordinate2D RandomCoordinate();

@implementation SampleViewController

@synthesize mapView;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    mapView.delegate = self;
    mapView.clusterSize = kDEFAULTCLUSTERSIZE;

    [self addRandomAnnotations:10000];
    [self updateAnnotationsLabel];
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);

    return YES;
}

// ==============================
#pragma mark - UI actions

- (void)updateAnnotationsLabel {
    labelNumberOfAnnotations.text = [NSString stringWithFormat:@"Number of Annotations: %d", [mapView.annotations count]];
}

- (IBAction)removeButtonTouchUpInside:(id)sender {
    [mapView removeOverlays:mapView.overlays];

    [mapView removeAnnotations:mapView.annotations];
    [self updateAnnotationsLabel];
}

- (IBAction)addButtonTouchUpInside:(id)sender {
    [mapView removeOverlays:mapView.overlays];

    [self addRandomAnnotations:1000];
    [self updateAnnotationsLabel];
}

- (IBAction)clusteringButtonTouchUpInside:(UIButton *)sender {
    [mapView removeOverlays:mapView.overlays];
    
    if (mapView.clusteringEnabled) {
        [sender setTitle:@"turn clustering on" forState:UIControlStateNormal];
        mapView.clusteringEnabled = NO;
    }
    else{
        [sender setTitle:@"turn clustering off" forState:UIControlStateNormal];
        mapView.clusteringEnabled = YES;
    }
}

- (IBAction)addOneButtonTouchupInside:(id)sender {
    [mapView removeOverlays:mapView.overlays];
    
    [mapView addAnnotation:[self createRandomAnnotation]];
    [self updateAnnotationsLabel];
}

- (IBAction)changeClusterMethodButtonTouchUpInside:(UIButton *)sender {
    [mapView removeOverlays:mapView.overlays];
    
    if (mapView.clusteringMethod == OCClusteringMethodBubble) {
        [sender setTitle:@"Bubble cluster" forState:UIControlStateNormal];
        mapView.clusteringMethod = OCClusteringMethodGrid;
    }
    else{
        [sender setTitle:@"Grid cluster" forState:UIControlStateNormal];
        mapView.clusteringMethod = OCClusteringMethodBubble;
    }

    [mapView doClustering];
}

- (IBAction)infoButtonTouchUpInside:(UIButton *)sender {
    [[[UIAlertView alloc] initWithTitle:@"Info"
                                message:@"The size of a cluster-annotation represents the number of annotations it contains and not its size."
                               delegate:nil cancelButtonTitle:@"great!" otherButtonTitles:nil] show];
}

- (IBAction)buttonGroupByTagTouchUpInside:(UIButton *)sender {
    [mapView removeOverlays:mapView.overlays];

    mapView.clusterByGroupTag = !mapView.clusterByGroupTag;

    if (mapView.clusterByGroupTag) {
        [sender setTitle:@"turn groups off" forState:UIControlStateNormal];
        mapView.clusterSize = kDEFAULTCLUSTERSIZE * 2.0;
    }
    else {
        [sender setTitle:@"turn groups on" forState:UIControlStateNormal];
        mapView.clusterSize = kDEFAULTCLUSTERSIZE;
    }

    [mapView doClustering];
}

#pragma mark - map delegate

- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id <MKAnnotation>)annotation {
    MKAnnotationView *annotationView;

    // if it's a cluster
    if ([annotation isKindOfClass:[OCAnnotation class]]) {
        static NSString *kClusterView = @"kClusterView";

        OCAnnotation *clusterAnnotation = (OCAnnotation *)annotation;

        annotationView = (MKAnnotationView *)[aMapView dequeueReusableAnnotationViewWithIdentifier:kClusterView];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kClusterView];
            annotationView.canShowCallout = YES;
            annotationView.centerOffset = CGPointMake(0, -20);
        }
        //calculate cluster region
        CLLocationDistance clusterRadius = mapView.region.span.longitudeDelta * mapView.clusterSize * 111000 / 2.0f; //static circle size of cluster
        //CLLocationDistance clusterRadius = mapView.region.span.longitudeDelta/log(mapView.region.span.longitudeDelta*mapView.region.span.longitudeDelta) * log(pow([clusterAnnotation.annotationsInCluster count], 4)) * mapView.clusterSize * 50000; //circle size based on number of annotations in cluster

        MKCircle *circle = [MKCircle circleWithCenterCoordinate:clusterAnnotation.coordinate radius:clusterRadius * cos([annotation coordinate].latitude * M_PI / 180.0)];
        [circle setTitle:@"background"];
        [mapView addOverlay:circle];

        // set its image
        annotationView.image = [UIImage imageNamed:@"regular.png"];

        // change pin image for group
        if (mapView.clusterByGroupTag) {
            if ([clusterAnnotation.groupTag isEqualToString:kTYPE1]) {
                annotationView.image = [UIImage imageNamed:@"bananas.png"];
            }
            else if([clusterAnnotation.groupTag isEqualToString:kTYPE2]){
                annotationView.image = [UIImage imageNamed:@"oranges.png"];
            }
            clusterAnnotation.title = clusterAnnotation.groupTag;
        }
    }
    // If it's a single annotation
    else if([annotation isKindOfClass:[OCMapViewSampleHelpAnnotation class]]) {
        static NSString *kSingleAnnotationView = @"kSingleAnnotationView";

        OCMapViewSampleHelpAnnotation *singleAnnotation = (OCMapViewSampleHelpAnnotation *)annotation;
        annotationView = (MKAnnotationView *)[aMapView dequeueReusableAnnotationViewWithIdentifier:kSingleAnnotationView];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:singleAnnotation reuseIdentifier:kSingleAnnotationView];
            annotationView.canShowCallout = YES;
            annotationView.centerOffset = CGPointMake(0, -20);
        }
        singleAnnotation.title = singleAnnotation.groupTag;

        if ([singleAnnotation.groupTag isEqualToString:kTYPE1]) {
            annotationView.image = [UIImage imageNamed:@"banana.png"];
        }
        else if([singleAnnotation.groupTag isEqualToString:kTYPE2]){
            annotationView.image = [UIImage imageNamed:@"orange.png"];
        }
    }
    // Error
    else {
        static NSString *kErrorAnnotationView = @"kErrorAnnotationView";

        annotationView = (MKPinAnnotationView *)[aMapView dequeueReusableAnnotationViewWithIdentifier:kErrorAnnotationView];
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kErrorAnnotationView];
            annotationView.canShowCallout = NO;
            ((MKPinAnnotationView *)annotationView).pinColor = MKPinAnnotationColorRed;
        }
    }

    return annotationView;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    MKCircle *circle = overlay;
    MKCircleView *circleView = [[MKCircleView alloc] initWithCircle:overlay];

    if ([circle.title isEqualToString:@"background"])
    {
        circleView.fillColor = [[UIColor yellowColor] colorWithAlphaComponent:0.25f];
        circleView.strokeColor = [UIColor blackColor];
        circleView.lineWidth = 0.5;
    }
    else if ([circle.title isEqualToString:@"helper"])
    {
        circleView.fillColor = [UIColor redColor];
        circleView.alpha = 0.25;
    }
    else
    {
        circleView.strokeColor = [UIColor blackColor];
        circleView.lineWidth = 0.5;
    }

    return circleView;
}

- (void)mapView:(MKMapView *)aMapView regionDidChangeAnimated:(BOOL)animated {
    [mapView removeOverlays:mapView.overlays];
    [mapView doClustering];
}

// ==============================
#pragma mark - logic

- (OCMapViewSampleHelpAnnotation *)createRandomAnnotation {
    CLLocationDistance latitude = ((float)arc4random() / ARC4RANDOM_MAX) * 180.f - 90.f;    // the latitude goes from +90° - 0 - -90°
    CLLocationDistance longitude = ((float)arc4random() / ARC4RANDOM_MAX) * 360.f - 180.f;  // the longitude goes from +180° - 0 - -180°

    OCMapViewSampleHelpAnnotation *annotation = [[OCMapViewSampleHelpAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake( latitude, longitude )];

    annotation.groupTag = (arc4random() % 2)? kTYPE1 : kTYPE2;

    return annotation;
}

- (void)addRandomAnnotations:(NSInteger)numberOfAnnotations {
    NSParameterAssert( numberOfAnnotations > 0 );

    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:numberOfAnnotations];

    for( NSInteger i = 0; i < numberOfAnnotations; ++i )
        [annotations addObject:[self createRandomAnnotation]];

    [mapView addAnnotations:annotations];

    labelNumberOfAnnotations.text = [NSString stringWithFormat:@"Number of Annotations: %d", [mapView.annotations count]];

//    [mapView removeOverlays:mapView.overlays];
//    NSArray *randomLocations = [[NSArray alloc] initWithArray:[self randomCoordinatesGenerator:100]];
//    NSMutableSet *annotationsToAdd = [[NSMutableSet alloc] init];
//
//    for (CLLocation *loc in randomLocations) {
//        OCMapViewSampleHelpAnnotation *annotation = [[OCMapViewSampleHelpAnnotation alloc] initWithCoordinate:loc.coordinate];
//        [annotationsToAdd addObject:annotation];
//
//        // add to group if specified
//        if (annotationsToAdd.count < (randomLocations.count)/2) {
//            annotation.groupTag = kTYPE1;
//        }
//        else{
//            annotation.groupTag = kTYPE2;
//        }
//    }
//
//    [mapView addAnnotations:[annotationsToAdd allObjects]];
//    labelNumberOfAnnotations.text = [NSString stringWithFormat:@"Number of Annotations: %d", [mapView.annotations count]];
}

//
// Help method which returns an array of random CLLocations
// You can specify the number of coordinates by setting numberOfCoordinates
- (NSArray *)randomCoordinatesGenerator:(int) numberOfCoordinates {

    numberOfCoordinates = (numberOfCoordinates < 0) ? 0 : numberOfCoordinates;

    NSMutableArray *coordinates = [[NSMutableArray alloc] initWithCapacity:numberOfCoordinates];
    for (int i = 0; i < numberOfCoordinates; i++) {
        
        // Get random coordinates
        CLLocationDistance latitude = ((float)arc4random() / ARC4RANDOM_MAX) * 180.0 - 90.0;    // the latitude goes from +90° - 0 - -90°
        CLLocationDistance longitude = ((float)arc4random() / ARC4RANDOM_MAX) * 360.0 - 180.0;  // the longitude goes from +180° - 0 - -180°
        
        // This is a fix, because the randomizing above can fail
        latitude = MIN(90.0, latitude);
        latitude = MAX(-90.0, latitude);
        
        longitude = MIN(180.0, longitude);
        longitude = MAX(-180.0, longitude);
        
        
        CLLocation *loc = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
        [coordinates addObject:loc];
    }
    
    return coordinates;
}

@end
