//
//  RouteGraphComponent.h
//  iRendARAR
//
//  Created by Daniel Arndt on 19.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


// if this is extended, please check the implementation file and method + (NSArray*)names
typedef NS_ENUM(NSUInteger, StationType) {
    STORY,
    TRIGGER,
    ANNOTATION,
    GEO
};



@interface GraphNode : NSObject

-(void)addOutgoingNode:(GraphNode* )node;
-(id)initWithName:(NSString*)stationName withType:(NSString*)stationType identifier:(NSString*)stationID;

@property (readonly, nonatomic) StationType type;
@property (readonly, nonatomic) NSString* identifier;
@property (readonly, nonatomic) NSString* name;
@property (readonly, copy) NSMutableSet* output;    // GraphNode, Trigger



@end
