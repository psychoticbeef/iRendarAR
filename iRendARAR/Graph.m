//
//  RouteGraph.m
//  iRendARAR
//
//  Created by Daniel Arndt on 19.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Graph.h"
#import "GraphNode.h"
#import "Question.h"
#import "Answer.h"

@interface Graph ()

@property (strong, nonatomic) NSMutableArray* annotationStations;

@property (readwrite, retain) GraphRoot* graphRoot;

@property (nonatomic) double radius;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString* stationID;
@property (nonatomic, retain) NSString* stationName;
@property (nonatomic, retain) NSString* stationType;
@property (readwrite, retain) NSMutableArray* questions;
@property (readwrite, retain) Question* question;

@end


@implementation Graph

-(id)init {
    if ((self = [super init])) {
        _annotationStations = [[NSMutableArray alloc] init];
        _graphRoot = NULL;
    }
    
    return self;
}

- (void)handleElement_connections:(NSDictionary *)attributeDict {
}

- (void)handleElement_connection:(NSDictionary *)attributeDict {
	GraphNode* start = [self nodeForID:attributeDict[@"station_start_id"]];
	GraphNode* end = [self nodeForID:attributeDict[@"station_end_id"]];
	
	if (!start) {
		NSLog(@"Error: StationID %@ not found.", attributeDict[@"station_start_id"]);
	}
	if (!end) {
		NSLog(@"Error: StationID %@ not found.", attributeDict[@"station_end_id"]);
	}
	
	[start addOutgoingNode:end withJSON:attributeDict[@"json"]];
	[end addOutgoingNode:start withJSON:attributeDict[@"json"]];
}
			 
			 
- (GraphNode*)nodeForID:(NSString*)identifier {
	for (GraphNode* node in self.nodes) {
		if ([node.identifier isEqualToString:identifier]) {
			return node;
		}
	}
	
	return nil;
}

- (void)handleElement_questions:(NSDictionary*)attributeDict {
	self.questions = [[NSMutableArray alloc] init];
}

- (void)handleElement_question:(NSDictionary*)attributeDict {
	self.question = [[Question alloc] init];
	[self.questions addObject:self.questions];
	self.question.questionText = attributeDict[@"query"];
}

- (void)handleElement_answer:(NSDictionary*)attributeDict {
	Answer* answer = [[Answer alloc] init];
	answer.points = [attributeDict[@"points"] intValue];
	answer.identifier = attributeDict[@"id"];
	answer.answerText = attributeDict[@"answertext"];
	answer.isCorrect = [attributeDict[@"valid_answer"] boolValue];
	if (!self.question.answers) {
		self.question.answers = [[NSMutableArray alloc] init];
	}
	[self.question.answers addObject:answer];
}

// to make this thing uber, a handler could be created based on the gpsrallye schemaversion (factory)
// the result would be an easily extendable set of handlers, with easy compliance with older schema versions
// => laziness ftl
- (void)handleElement_gpsrallye:(NSDictionary *)attributeDict {
    NSString* name = attributeDict[@"name"];
    NSString* schemaVersion = attributeDict[@"schemaversion"];
	
    if (!self.graphRoot) {
//        self.graphRoot = [[GraphRoot alloc] init];
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
	GraphNode* node = [[GraphNode alloc] initWithName:self.stationName withType:self.stationType withIdentifier:self.stationID withLocation:self.coordinate withRadius:self.radius withQuestions:self.questions];
	
//	NSLog(@"%@", self.node.identifier);
    
    if (node.type == ANNOTATION) {
        [self.annotationStations addObject:node];
    } else {
        [self.nodes addObject:node];
    }
    
    node = NULL;
}

-(void)handleElement_gpspos:(NSDictionary *)attributeDict {
    double latitude = [attributeDict[@"latitude"] doubleValue];
    double longitude = [attributeDict[@"longitude"] doubleValue];
    self.radius = [attributeDict[@"radius"] doubleValue];
    self.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	
	NSString* selector = [NSString stringWithFormat:@"handleElement_%@:", [elementName lowercaseString]];
	
    SEL sel = NSSelectorFromString(selector);
    if ([self respondsToSelector:sel]) {
        [self performSelector:sel withObject:attributeDict];
    } else {
        NSLog(@"Error: Tag %@ is not handled. Worry!", elementName);
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
	NSString* selector = [NSString stringWithFormat:@"handleElementDone_%@", [elementName lowercaseString]];
    SEL sel = NSSelectorFromString(selector);
    if ([self respondsToSelector:sel]) {
        [self performSelector:sel];
    } else {
        DebugLog(@"Debug: Closing tag %@ is not handled. Don't worry.", elementName); // only a "debuglog" (for logging in debugmode), because doing something when an element ends is NOT required.
    }

}

- (void)generateGraph {
	DebugLog(@"Annotation Count: %i\nStation Count %i", self.annotationStations.count, self.nodes.count);
}

    
- (void)parserDidEndDocument:(NSXMLParser *)parser {
	[self generateGraph];
}



@end
