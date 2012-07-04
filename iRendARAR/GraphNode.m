//
//  RouteGraphComponent.m
//  iRendARAR
//
//  Created by Daniel Arndt on 19.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphNode.h"

@interface GraphNode ()
@property (readwrite, nonatomic) StationType type;
@property (readwrite, nonatomic) NSString* identifier;
@property (readwrite, nonatomic) NSString* name;
@property (readwrite, copy) NSMutableSet *output;
@end


@implementation GraphNode

-(id)initWithName:(NSString*)stationName withType:(NSString*)stationType identifier:(NSString*)stationID {
    self = [super init];
    if (self) {
        _output = [[NSMutableSet alloc] init];
        _name = stationName;
        _type = [GraphNode stationTypeForName:stationName];
        _identifier = stationID;
    }
    
    return self;
}

-(void)addOutgoingNode:(GraphNode* )node {
//    [output addObject:node];
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

@end
