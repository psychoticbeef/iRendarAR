//
//  RouteGraphComponent.m
//  iRendARAR
//
//  Created by Daniel Arndt on 19.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphNode.h"
#import <CoreLocation/CoreLocation.h>
#import <vector>

@interface GraphNode ()
@property (readwrite, nonatomic) StationType type;
@property (readwrite, nonatomic) NSString* identifier;
@property (readwrite, nonatomic) NSString* name;
@property (readwrite) CLLocationCoordinate2D location;
@property (readwrite) double radius;
@property (readwrite, nonatomic) NSMutableArray* outputNode;    // GraphNode, json
@property (readwrite, nonatomic) NSMutableArray* outputJSON;    // GraphNode, json
@property (readwrite, nonatomic) NSMutableArray* questions;
@end


@implementation GraphNode

std::vector<CLLocationCoordinate2D*> coordinateCollectionArray;
CLLocationCoordinate2D* coordinateCollection = nil;

- (CLLocationCoordinate2D*)getLocationCoordinateCollection:(int)index {
	
	if (coordinateCollectionArray.size() > 0)
		return coordinateCollectionArray[index];
	
	for (NSMutableArray* lolJSON in self.outputJSON) {
//		NSMutableArray* lolJSON = jsonRoute[0];

		coordinateCollection = (CLLocationCoordinate2D*)malloc(lolJSON.count * sizeof(CLLocationCoordinate2D));
		coordinateCollectionArray.push_back(coordinateCollection);
		
		int i = 0;
		for (NSMutableDictionary* coordinatePairs in lolJSON) {
			CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([coordinatePairs[@"$a"] floatValue], [coordinatePairs[@"ab"] floatValue]);
			coordinateCollection[i++] = coordinate;
		}
		
	}
	
	
	return coordinateCollectionArray[index];
}

- (NSUInteger)numberOfPossibleNextRoutes {
	return self.outputJSON.count;
}

- (NSUInteger)getLocationCoordinateCollectionCount:(int)index {
	NSMutableArray* lolJSON = self.outputJSON[index];
	return lolJSON.count;
}

- (id)initWithName:(NSString*)stationName withType:(NSString*)stationType withIdentifier:(NSString*)stationID withLocation:(CLLocationCoordinate2D)location withRadius:(double)radius withQuestions:(NSMutableArray*) questions {
    self = [super init];
    if (self) {
		_outputJSON = [[NSMutableArray alloc] init];
		_outputNode = [[NSMutableArray alloc] init];
        _name = stationName;
        _type = [GraphNode stationTypeForName:stationType];
        _identifier = stationID;
		_location = location;
		_radius = radius;
		_questions = questions;
    }
    
    return self;
}

- (void)addOutgoingNode:(GraphNode* )node withJSON:(NSString*)json {
	[self.outputNode addObject:node];
	
	NSError* error = nil;
	NSDictionary* ser = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
	if (error) {
		NSLog(@"JSON tour data is invalid. Fuck you. %@", [error localizedDescription]);
	}
	
	// anyone wants to do error checking? not me!
	NSMutableDictionary* routes = ser[@"routes"][0];
	
//	routes = routes[@"legs"];
//	routes = routes[@"steps"][0];
//	routes = routes[@"overviewpath"][0];

//	[self.outputJSON addObject:[routes[@"path"] copy]];
//	NSLog(@"legs %@", routes);
//	NSLog(@"overview_path %@", routes[@"overview_path"]);
	[self.outputJSON addObject:[routes[@"overview_path"] copy]];
}

+ (NSArray *)names {
    static NSMutableArray * _names = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _names = [NSMutableArray arrayWithCapacity:4];
        [_names insertObject:@"STORY" atIndex:STORY];
        [_names insertObject:@"TRIGGER" atIndex:TRIGGER];
        [_names insertObject:@"ANNOTATION" atIndex:ANNOTATION];
        [_names insertObject:@"GEO" atIndex:GEO];
    });
    
    return _names;
}

+ (NSString *)nameForType:(StationType)type {
    return ([self names])[type];
}

+ (StationType)stationTypeForName:(NSString *)typeName {
    NSUInteger result = [[GraphNode names] indexOfObject:[typeName uppercaseString]];
    if (result == NSNotFound) {
        NSLog(@"I do not know the station type %@", typeName);
    }
    
    return result;
}

- (void)dealloc {
//	if (coordinateCollection) {
//		free(coordinateCollection);
//	}
}

@end