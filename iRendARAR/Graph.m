//
//  RouteGraph.m
//  iRendARAR
//
//  Created by Daniel Arndt on 19.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Graph.h"
#import "GraphNode.h"

@interface Graph ()

@property (strong, nonatomic) NSMutableDictionary* temporaryNodeConnections;   // id => id
@property (strong, nonatomic) NSMutableDictionary* temporaryNodeMapping;       // object => id
@property (strong, nonatomic) NSMutableArray* annotationStations;

@property (readwrite, copy) GraphRoot* graphRoot;
@property (nonatomic, retain) GraphNode* node;
@property (nonatomic, retain) NSMutableArray* nodes;

@property (nonatomic) double radius;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString* stationID;
@property (nonatomic, retain) NSString* stationName;
@property (nonatomic, retain) NSString* stationType;

@end

@implementation Graph

-(id)init {
    if ((self = [super init])) {
        _temporaryNodeMapping = [[NSMutableDictionary alloc] init];
        _temporaryNodeConnections = [[NSMutableDictionary alloc] init];
        
        _annotationStations = [[NSMutableArray alloc] init];
        
        _graphRoot = NULL;
    }
    
    return self;
}

// to make this thing uber, a handler could be created based on the gpsrallye schemaversion (factory)
// the result would be an easily extendable set of handlers, with easy compliance with older schema versions
// => laziness ftl
- (void)handleElement_gpsrallye:(NSDictionary *)attributeDict {
    NSString* name = attributeDict[@"name"];
    NSString* schemaVersion = attributeDict[@"schemaversion"];
    
    if (!self.graphRoot) {
        self.graphRoot = [[GraphRoot alloc] initWithName:name version:schemaVersion];
    } else {
        NSLog(@"Error: Multiple document roots (element: gpsrallye) found.");
    }
}

- (void)handleElement_stations:(NSDictionary *)attributeDict {
    self.nodes = [[NSMutableArray alloc] init];
}

- (void)handleElement_station:(NSDictionary *)attributeDict {

    self.stationID = attributeDict[@"id"];
    self.stationName = attributeDict[@"name"];
    self.stationType = attributeDict[@"type"];

}

-(void)handleElementDone_station {
    // node alloc init bla bla bla. seomthing liek dat, but moer kthx :3
    //    self.node = [[GraphNode alloc] initWithName:stationName withType:stationType identifier:stationID];
    
    if (self.node.type == ANNOTATION) {
        [self.annotationStations addObject:self.node];
    } else {
        [self.nodes addObject:self.node];
    }
    
    self.node = NULL;
}

-(void)handleElement_gpspos:(NSDictionary *)attributeDict {
    double latitude = [attributeDict[@"latitude"] doubleValue];
    double longitude = [attributeDict[@"longitude"] doubleValue];
    self.radius = [attributeDict[@"radius"] doubleValue];
    self.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
    
    SEL sel = NSSelectorFromString([@"handleElement_" stringByAppendingString:[elementName lowercaseString]]);
    if ([self respondsToSelector:sel]) {
        [self performSelector:sel withObject:attributeDict];
    } else {
        NSLog(@"Error: Tag %@ is not handled. Worry!", elementName);
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    SEL sel = NSSelectorFromString([@"handleElementDone_" stringByAppendingString:[elementName lowercaseString]]);
    if ([self respondsToSelector:sel]) {
        [self performSelector:sel];
    } else {
        DebugLog(@"Debug: Tag %@ is not handled. Don't worry.", elementName); // only a "debuglog" (for logging in debugmode), because doing something when an element ends is NOT required.
    }

}

    
- (void)parserDidEndDocument:(NSXMLParser *)parser {
//    [self generateGraph];
}



@end
