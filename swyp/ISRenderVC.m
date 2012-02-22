//
//  ISRenderVC.m
//  swyp
//
//  Created by Alexander List on 2/20/12.
//  Copyright (c) 2012 ExoMachina. All rights reserved.
//

#import "ISRenderVC.h"
#import <QuartzCore/QuartzCore.h>

@implementation ISRenderVC
@synthesize renderObject, delegate;

+(id) beginRenderWithObject:(NSObject*)renderObject retainedDelegate:(NSObject<ISRenderVCDelegate>*)delegate{
	EXOLog(@"Abstract class called: %@",@"beginRenderWithObject");
	
	return nil;
}

-(void) startRendering{
	dispatch_async(dispatch_get_global_queue(0, 0), ^{
		CGSize viewSize	=	self.view.size;
		UIGraphicsBeginImageContextWithOptions(viewSize,YES, 0);
		[self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
		UIImage *image		= UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		UIImage * thumbnail	= [self constrainImage:image toSize:CGSizeMake(300, 300)];
		dispatch_async(dispatch_get_main_queue(), ^{
			[self didFinalizeRenderWithImage:image thumbnail:thumbnail];
		});
	});
}
-(void) stopRenderingReleaseDelegateAndRenderObject{
	self.renderObject	=	nil;
	self.delegate		=	nil;
}

-(void)didFinalizeRenderWithImage:(UIImage*)renderImage thumbnail:(UIImage*)thumbnail{
	[delegate didRenderImage:renderImage thumbnail:thumbnail forRenderObject:renderObject renderVC:self];
	[self stopRenderingReleaseDelegateAndRenderObject];
}

-(UIImage*)	constrainImage:(UIImage*)image toSize:(CGSize)maxSize{
	if (image == nil)
		return nil;
	
	CGSize oversize = CGSizeMake([image size].width - maxSize.width, [image size].height - maxSize.height);	
	CGSize iconSize			=	CGSizeZero;
	
	if (oversize.width > 0 || oversize.height > 0){
		if (oversize.height > oversize.width){
			double scaleQuantity	=	maxSize.height/ image.size.height;
			iconSize		=	CGSizeMake(scaleQuantity * image.size.width, maxSize.height);
		}else{
			double scaleQuantity	=	maxSize.width/ image.size.width;	
			iconSize		=	CGSizeMake(maxSize.width, scaleQuantity * image.size.height);		
		}
	}else{
		return image;
	}
	
	UIGraphicsBeginImageContextWithOptions(iconSize, NO, 1);
	[image drawInRect:CGRectMake(0,0,iconSize.width,iconSize.height)];
	UIImage* constrainedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return constrainedImage;
}

-(void) viewDidLoad{
	[super viewDidLoad];
}

@end
