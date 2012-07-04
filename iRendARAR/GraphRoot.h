//
//  GraphRoot.h
//  iRendARAR
//
//  Created by Daniel on 27.06.12.
//
//

#import <Foundation/Foundation.h>

@interface GraphRoot : NSObject

@property (readonly, copy) NSString *schemaVersion;
@property (readonly, copy) NSString *name;

-(id)initWithName:(NSString *)name version:(NSString *)schemaVersion;

@end
