//
//  GraphRoot.m
//  iRendARAR
//
//  Created by Daniel on 27.06.12.
//
//

#import "GraphRoot.h"


@interface GraphRoot ()
@property (readwrite, copy) NSString *schemaVersion;
@property (readwrite, copy) NSString *name;
@end


@implementation GraphRoot

-(id)initWithName:(NSString *)name version:(NSString *)schemaVersion {
    if (self = [super init]) {
        
        [self setName:name];
        [self setSchemaVersion:schemaVersion];
    }
    
    return self;
}

@end
