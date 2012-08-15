//
//  RouteGraph.m
//  iRendARAR
//
//  Created by Daniel Arndt on 19.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


// this whole crap shoul be replaced with google protocol buffers or smth similar

#import "Graph.h"
#import "Question.h"
#import "Answer.h"
#import "Media.h"

@interface Graph ()

@property (readwrite, nonatomic) NSMutableArray* annotationStations;
@property (readwrite, retain) GraphRoot* graphRoot;

@property (nonatomic) double radius;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString* stationID;
@property (nonatomic, retain) NSString* stationName;
@property (nonatomic, retain) NSString* stationType;
@property (readwrite, retain) NSMutableArray* questions;
@property (readwrite, retain) Question* question;
@property (nonatomic, retain) NSMutableArray* temporaryMedia;
@property (nonatomic, retain) NSArray* media;
@property (nonatomic) bool isStartStation;
@property (nonatomic) bool isEndStation;

@property (nonatomic) GraphNode* dummy;

@end


@implementation Graph

-(id)init {
    if ((self = [super init])) {
        _annotationStations = [[NSMutableArray alloc] init];
        _graphRoot = NULL;
		_dummy = [[GraphNode alloc] initWithName:@"dummy" withType:@"DUMMY" withIdentifier:@"dummy" withLocation:CLLocationCoordinate2DMake(0, 0) withRadius:0 withQuestions:nil isStartStation:NO isEndStation:NO media:nil];
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

-(void)save {
	[[NSUserDefaults standardUserDefaults] setObject:self.graphRoot.currentNode.identifier forKey:[self.graphRoot.name stringByAppendingString:@"current_node"]];
	NSMutableArray* visitedNodes = [[NSMutableArray alloc] initWithCapacity:self.graphRoot.visitedNodes.count];
	for (GraphNode* node in self.graphRoot.visitedNodes) {
		[visitedNodes addObject:node.identifier];
	}
	DebugLog(@"Debug: Saving %i items", visitedNodes.count);
	[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:visitedNodes] forKey:[self.graphRoot.name stringByAppendingString:@"visited_nodes"]];

	[[NSUserDefaults standardUserDefaults] synchronize];
}


-(void)load {
	NSData *dataRepresentingSavedArray = [[NSUserDefaults standardUserDefaults] objectForKey:[self.graphRoot.name stringByAppendingString:@"visited_nodes"]];
	if (dataRepresentingSavedArray != nil)
	{
		NSArray *savedArray = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedArray];
		DebugLog(@"Debug: Deserialized state %@", savedArray);
		if (savedArray != nil) {
			for (NSString* identifier in savedArray) {
				[self.graphRoot setNodeAsCurrentNode:[self nodeForID:identifier]];
			}
		}
	}
	
	[self.graphRoot setNodeAsCurrentNode:[self nodeForID:[[NSUserDefaults standardUserDefaults] objectForKey:[self.graphRoot.name stringByAppendingString:@"current_node"]]]];
}


- (void)handleElement_media:(NSDictionary*)attributeDict {
	self.temporaryMedia = [[NSMutableArray alloc] init];
}

- (void)handle_MediaHelper:(NSDictionary*)attributeDict type:(MediaType)type {
	Media* media = [[Media alloc] initWithType:type uri:attributeDict[@"src"] identifier:attributeDict[@"id"]];
	[self.temporaryMedia addObject:media];
}

- (void)handleElement_audio:(NSDictionary*)attributeDict {
	[self handle_MediaHelper:attributeDict type:AUDIO];
}
- (void)handleElement_image:(NSDictionary*)attributeDict {
	[self handle_MediaHelper:attributeDict type:IMAGE];
}
- (void)handleElement_video:(NSDictionary*)attributeDict {
	[self handle_MediaHelper:attributeDict type:VIDEO];
}
- (void)handleElement_text:(NSDictionary*)attributeDict {
	[self handle_MediaHelper:attributeDict type:TEXT];
}

- (void)handleElementDone_media {
	
	NSArray* sortedArray = [self.temporaryMedia sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
		int first = [(Media*)a identifier];
		int second = [(Media*)b identifier];
		if (first == second) return NSOrderedSame;
		return first > second ? NSOrderedDescending : NSOrderedAscending;
	}];
	
	self.media = sortedArray;
//	DebugLog(@"SELF MEDIA COUNT %i", self.media.count);
}


- (void)handleElement_questions:(NSDictionary*)attributeDict {
	self.questions = [[NSMutableArray alloc] init];
}

- (void)handleElementDone_questions {
	for (Question* q in self.questions) {
		q.total = self.questions.count;
	}
}

- (void)handleElement_question:(NSDictionary*)attributeDict {
	self.question = [[Question alloc] init];
	[self.questions addObject:self.question];
	self.question.questionText = attributeDict[@"query"];
}

- (void)handleElementDone_question {
	for (unsigned int i = 0; i < self.question.answers.count; i++) {
		Answer* a = self.question.answers[i];
		if (a.isCorrect) {
			self.question.correctAnswerBitmask |= 1 << i;
		}
	}
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
	
	NSLog(@"%@", answer);
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

- (void)handleElementDone_gpsrallye {
	[self.graphRoot setNodeAsCurrentNode:self.dummy];
}

- (void)handleElement_stations:(NSDictionary *)attributeDict {
    self.nodes = [[NSMutableArray alloc] init];
}

- (void)handleElement_station:(NSDictionary *)attributeDict {
    self.stationID = attributeDict[@"id"];
    self.stationName = attributeDict[@"name"];
    self.stationType = attributeDict[@"type"];
	self.isStartStation = [attributeDict[@"is_start_station"] boolValue];
	self.isEndStation = [attributeDict[@"is_end_station"] boolValue];
}

-(void)handleElementDone_station {
	GraphNode* node = [[GraphNode alloc] initWithName:self.stationName withType:self.stationType withIdentifier:self.stationID withLocation:self.coordinate withRadius:self.radius withQuestions:self.questions isStartStation:self.isStartStation isEndStation:self.isEndStation media:self.media];
	
	if (node.isStartStation) [self.dummy addOutgoingNode:node withJSON:@""];
	
    if (node.type == ANNOTATION) [self.annotationStations addObject:node];
    else [self.nodes addObject:node];
	
	self.media = nil;
	self.questions = nil;
	self.question = nil;
	self.temporaryMedia = nil;
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
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:sel withObject:attributeDict];
#pragma clang diagnostic pop
    } else {
        NSLog(@"Error: Tag %@ is not handled. Worry!", elementName);
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
	NSString* selector = [NSString stringWithFormat:@"handleElementDone_%@", [elementName lowercaseString]];
    SEL sel = NSSelectorFromString(selector);
    if ([self respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:sel];
#pragma clang diagnostic pop
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
