//
//  RouteGraphComponent.h
//  iRendARAR
//
//  Created by Daniel Arndt on 19.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>


// if this is extended, please check the implementation file and method + (NSArray*)names
typedef NS_ENUM(NSUInteger, StationType) {
    STORY,
    TRIGGER,
    ANNOTATION,
    GEO
};


@interface GraphNode : NSObject

-(void)addOutgoingNode:(GraphNode* )node withJSON:(NSString*)json;
- (id)initWithName:(NSString*)stationName withType:(NSString*)stationType withIdentifier:(NSString*)stationID withLocation:(CLLocationCoordinate2D)location withRadius:(double)radius withQuestions:(NSMutableArray*)questions isStartStation:(bool)isStartStation isEndStation:(bool)isEndStation;
//- (CLLocationCoordinate2D*)getLocationCoordinateCollection:(int)index;
//- (NSUInteger)getLocationCoordinateCollectionCount:(int)index;
//- (NSUInteger)numberOfPossibleNextRoutes;

@property (readonly, nonatomic) StationType type;
@property (readonly, nonatomic) NSString* identifier;
@property (readonly, nonatomic) NSString* name;
@property (readonly, nonatomic) NSMutableArray* outputNode;    // GraphNode, json
@property (readonly, nonatomic) NSMutableArray* outputJSON;    // GraphNode, json
@property (readonly) CLLocationCoordinate2D location;
@property (readonly) double radius;
@property (readonly, nonatomic) NSMutableArray* questions;
@property (readonly, nonatomic) bool isStartStation;
@property (readonly, nonatomic) bool isEndStation;
@property (readonly, nonatomic) MKMapRect pointRect;


@end
