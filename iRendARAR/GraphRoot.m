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


// removes singular node from teh entire graph. fick ja
-(void)removeNodeFromGraph:(GraphNode*)node {
	for (GraphNode* cur in self.allNodes) {
		NSUInteger index = [cur.outputNode indexOfObject:node];
		if (index != NSNotFound) {
			[cur.outputNode removeObjectAtIndex:index];
			[cur.outputJSON removeObjectAtIndex:index];
		}
	}
}

// removes all occurrences of teh previous node & not taken alternatives from teh graph
-(void)cleanupGraph:(GraphNode*)newCurrent oldNode:(GraphNode*)oldCurrent {

	for (GraphNode* outgoingNode in oldCurrent.outputNode) {
		if (outgoingNode == newCurrent)
			continue;
		
		[self removeNodeFromGraph:outgoingNode];
	}
	
	[self removeNodeFromGraph:oldCurrent];
}


- (BOOL)checkPathForNode:(GraphNode*)node deletedList:(NSMutableArray*)deletedNodes {
	[deletedNodes addObject:node];
	
	for (GraphNode* currentNode in node.outputNode) {
		if ([deletedNodes indexOfObject:currentNode] == NSNotFound)
			continue;
		if (currentNode.isEndStation)
			return YES;
		
		return [self checkPathForNode:currentNode deletedList:[deletedNodes mutableCopy]];
	}
	
	return NO;
}

- (void)removeDeadends:(GraphNode*)node {
	NSMutableArray* set = [[NSMutableArray alloc] init];
	
	for (GraphNode* output in node.outputNode) {
		if (![self checkPathForNode:output deletedList:[[NSMutableArray alloc] init]])
			[set addObject:output];
	}
	
	for (GraphNode* bla in set)
		[self removeNodeFromGraph:bla];
}


-(void)setNodeAsCurrentNode:(GraphNode*)node {
	if (self.currentNode && self.currentNode.type != DUMMY && [_visitedNodes indexOfObject:node] == NSNotFound) {
		[_visitedNodes addObject:self.currentNode];
	}
		 
	[self cleanupGraph:node oldNode:self.currentNode];
	[self removeDeadends:node];

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
