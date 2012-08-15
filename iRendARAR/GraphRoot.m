//
//  GraphRoot.m
//  iRendARAR
//
//  Created by Daniel on 27.06.12.
//
//

#import "GraphRoot.h"
#import "DirtyHack.h"

@interface GraphRoot ()
@property (readwrite, retain) NSString* schemaVersion;
@property (readwrite, retain) NSString *name;
@property (readwrite, retain) GraphNode* currentNode;
@property (readwrite, copy) NSMutableArray* visitedNodes;
@end


@implementation GraphRoot

//-(id)copyWithZone: (NSZone *) zone {
//    GraphRoot *newGraphRoot = [[GraphRoot allocWithZone:zone] init];
//	newGraphRoot.name = self.name;
//	newGraphRoot.schemaVersion = self.schemaVersion;
//	
//    return(newGraphRoot);
//}


-(void)setNodeAsCurrentNode:(GraphNode*)node {
	if (self.currentNode && self.currentNode.type != DUMMY && [_visitedNodes indexOfObject:node] == NSNotFound) {
		[_visitedNodes addObject:self.currentNode];
	}
		 
	self.currentNode = node;
	[DirtyHack sharedInstance].currentStation = node;
}


-(id)initWithName:(NSString *)name version:(NSString *)schemaVersion {
    self = [super init];

    if (self) {
        
		_name = name;
		_schemaVersion = schemaVersion;
		_visitedNodes = [[NSMutableArray alloc] init];
		
		[DirtyHack sharedInstance].visitedStations = _visitedNodes;
		[DirtyHack sharedInstance].routeName = name;

    }
    
    return self;
}


@end
