//
//  Media.h
//  iRendARAR
//
//  Created by Daniel on 14.08.12.
//
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, MediaType) {
	AUDIO,
	IMAGE,
	VIDEO,
	TEXT
};

@interface Media : NSObject

@property (readonly) MediaType type;
@property (readonly, retain) NSString* uri;
@property (readonly) NSInteger identifier;	// this ID is an integer, because it is used for sorting

- (id)initWithType:(MediaType)type uri:(NSString*)uri identifier:(NSString*)identifier;


@end
