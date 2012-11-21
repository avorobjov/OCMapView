//
//  OCAnnotation.h
//  openClusterMapView
//
//  Created by Botond Kis on 14.07.11.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "OCGrouping.h"

/// Annotation class which represents a Cluster.
/** OCAnnotation stores all annotations which are in its area.
 Objects of this class will be returned by the delegate method of OCMapView "viewForAnnotation".
 Implements MKAnnotation protocol.
 */
@interface OCAnnotation : NSObject <MKAnnotation, OCGrouping>
{
@private
    NSMutableArray *_annotationsInCluster;
}

// MKAnnotation implementation
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subtitle;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;

// OCGrouping implementation
@property (copy, nonatomic) NSString *groupTag;

//
/// List of annotations in the cluster.
/** Returns all annotations in the cluster.
 READONLY
 */
@property (strong, nonatomic, readonly) NSArray *annotationsInCluster;

/// Init with annotations.
/** Init object with containing annotations*/
- (id)initWithAnnotation:(id <MKAnnotation>) annotation;

//
// manipulate cluster
/// Adds a single annotation to the cluster.
/** Adds a given annotation to the cluster and sets the title to the number of containing annotations.*/
- (void)addAnnotation:(id < MKAnnotation >)annotation;

/// Adds multiple annotations to the Cluster.
/** Adds multiple annotations to the cluster and sets the title to the number of containing annotations.
 Calls addAnnotation in a loop.*/
- (void)addAnnotations:(NSArray *)annotations;

///Removes a single annotation from the Cluster.
/** Removes a given annotation from the cluster and sets the title to the number of containing annotations.*/
- (void)removeAnnotation:(id < MKAnnotation >)annotation;

/// Removes multiple annotations from the Cluster.
/** Removes multiple annotations from the cluster and sets the title to the number of containing annotations.*/
- (void)removeAnnotations:(NSArray *)annotations;

@end
