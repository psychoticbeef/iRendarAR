/*
 *  ImageUtils.h
 *  AugmentedRealitySample
 *
 *  Created by Chris Greening on 01/01/2010.
 *
 */

#import <UIKit/UIKit.h>

typedef struct {
	uint8_t *rawImage;
	uint8_t **pixels;
	int width;
	int height;
} Image;

Image *createImage(uint8_t *bytes, size_t bprow, int srcWidth, int srcHeight);
CGImageRef toCGImage(Image *srcImage);
void destroyImage(Image *image);