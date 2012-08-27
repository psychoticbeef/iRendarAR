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
	
	NSMutableArray* nodesToDelete = [oldCurrent.outputNode mutableCopy];
	[nodesToDelete removeObject:newCurrent];
	for (GraphNode* outgoingNode in nodesToDelete) {

		[self removeNodeFromGraph:outgoingNode];
		NSLog(@"Deleting Node: %@", outgoingNode.name);
	}
	
	[self removeNodeFromGraph:oldCurrent];
	NSLog(@"Deleting Node: %@", oldCurrent.name);
}

//static int i = 0;
static bool path_exists = NO;

// the recursion is buggy. nao we has a variable "path_exists" that only dingenses if a path was found. niec?
- (BOOL)checkPathForNode:(GraphNode*)node deletedList:(NSMutableArray*)deletedNodes {
	[deletedNodes addObject:node];
	
//	NSLog(@"recursion depth %i", i++);
	
	if (node.isEndStation) {
		path_exists = YES;
		return NO;
	}
	
	for (GraphNode* currentNode in node.outputNode) {
		if ([deletedNodes indexOfObject:currentNode] != NSNotFound)
			continue;

//		NSLog(@"Looking at Node: %@", currentNode.name);

		if (currentNode.isEndStation) {
//			NSLog(@"IS NOT TEH END");
			path_exists = YES;
			return NO;
		}


//		return [self checkPathForNode:currentNode deletedList:[deletedNodes mutableCopy]];
		[self checkPathForNode:currentNode deletedList:[deletedNodes mutableCopy]];
	}
	
	return YES;
}

- (void)removeDeadends:(GraphNode*)node {
	NSMutableArray* set = [[NSMutableArray alloc] init];
	
	for (GraphNode* output in node.outputNode) {
		path_exists = NO;
		NSMutableArray* deletedList = [[NSMutableArray alloc] init];
		[deletedList addObject:node];
		[self checkPathForNode:output deletedList:deletedList];
		BOOL isDeadEnd = !path_exists;
		if (isDeadEnd)
			[set addObject:output];
		
//		NSLog(@"IsDeadEnd: %i NodeNaem: %@", isDeadEnd, output.name);
	}
	
	for (GraphNode* bla in set)
		[self removeNodeFromGraph:bla];
}


-(void)setNodeAsCurrentNode:(GraphNode*)node {
	if (self.currentNode && self.currentNode.type != DUMMY && [_visitedNodes indexOfObject:node] == NSNotFound) {
		[_visitedNodes addObject:self.currentNode];

		[self cleanupGraph:node oldNode:self.currentNode];
		[self removeDeadends:node];
	}
	
//	NSLog(@"Current Node is %@", node.name);

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
