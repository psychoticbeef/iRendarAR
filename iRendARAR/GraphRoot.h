//
//  GraphRoot.h
//  iRendARAR
//
//  Created by Daniel on 27.06.12.
//
//

#import <Foundation/Foundation.h>
#import "GraphNode.h"

@interface GraphRoot : NSObject

@property (readonly, retain) NSString *schemaVersion;
@property (readonly, retain) NSString *name;
@property (readonly, retain) GraphNode* currentNode;
@property (readonly, copy) NSMutableArray* visitedNodes;
@property (readonly, copy) NSMutableArray* visitedNodesWithoutTriggers;
@property (readwrite, retain) NSMutableArray* allNodes;

-(id)initWithName:(NSString *)name version:(NSString *)schemaVersion;
-(void)setNodeAsCurrentNode:(GraphNode*)node;
+(NSArray*)getFollowupStationsIgnoringTriggers:(GraphNode*)node;

@end
