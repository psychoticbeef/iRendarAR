//
//  MKPolyline+EncodedString.h
//  iRendARAR
//
//  Created by Daniel on 03.08.12.
//
//

#import <MapKit/MapKit.h>

@interface MKPolyline (EncodedString)

+ (MKPolyline *)polylineWithEncodedString:(NSString *)encodedString;

@end
