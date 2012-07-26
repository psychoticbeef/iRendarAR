//
//  GraphRoot.m
//  iRendARAR
//
//  Created by Daniel on 27.06.12.
//
//

#import "GraphRoot.h"


@interface GraphRoot ()
@property (readwrite, retain) NSString *schemaVersion;
@property (readwrite, retain) NSString *name;
@end


@implementation GraphRoot

-(id) copyWithZone: (NSZone *) zone {
    GraphRoot *newGraphRoot = [[GraphRoot allocWithZone:zone] init];
    NSLog(@"_copy: %@", [newGraphRoot self]);
	newGraphRoot.name = self.name;
	newGraphRoot.schemaVersion = self.schemaVersion;
	
    return(newGraphRoot);
}


-(id)initWithName:(NSString *)name version:(NSString *)schemaVersion {
    if (self = [super init]) {
        
        [self setName:name];
        [self setSchemaVersion:schemaVersion];
    }
    
    return self;
}

@end
