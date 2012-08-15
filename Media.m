//
//  Media.m
//  iRendARAR
//
//  Created by Daniel on 14.08.12.
//
//

#import "Media.h"

@interface Media ()

@property (readwrite) MediaType type;
@property (readwrite, retain) NSString* uri;
@property (readwrite) NSInteger identifier;	// this ID is an integer, because it is used for sorting

@end

@implementation Media


- (id)initWithType:(MediaType)type uri:(NSString*)uri identifier:(NSString*)identifier {
	self = [super init];
	if (self) {
		_type = type;
		_uri = uri;
		_identifier = [identifier intValue];
	}
	
	return self;
}


//+ (NSArray *)names {
//    static NSMutableArray * _names = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        _names = [NSMutableArray arrayWithCapacity:4];
//        [_names insertObject:@"AUDIO" atIndex:AUDIO];
//        [_names insertObject:@"IMAGE" atIndex:IMAGE];
//        [_names insertObject:@"VIDEO" atIndex:VIDEO];
//        [_names insertObject:@"TEXT" atIndex:TEXT];
//    });
//
//    return _names;
//}

//+ (NSString *)nameForType:(MediaType)type {
//    return ([self names])[type];
//}

//+ (MediaType)typeForName:(NSString *)typeName {
//    NSUInteger result = [[Media names] indexOfObject:[typeName uppercaseString]];
//    if (result == NSNotFound) {
//        NSLog(@"Error: I do not know the station type %@", typeName);
//    }
//
//    return result;
//}



@end
