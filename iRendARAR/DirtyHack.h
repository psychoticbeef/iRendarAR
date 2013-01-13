//
//  DirtyHack.h
//  iRendARAR
//
//  Created by Daniel on 09.08.12.
//
//

#import <Foundation/Foundation.h>
#import "GraphNode.h"
#import "GraphRoot.h"


@interface DirtyHack : NSObject

@property (nonatomic, weak) NSArray* visitedStations;
@property (nonatomic, weak) NSArray* visitedStationsWithoutTriggers;
@property (nonatomic) NSInteger score;
@property (nonatomic, retain) NSString* routeName;
@property (nonatomic, retain) GraphNode* currentStation;
@property (nonatomic, weak) MKMapView* mapView;
@property (nonatomic) CLLocationCoordinate2D location;

+ (DirtyHack*)sharedInstance;

@end
