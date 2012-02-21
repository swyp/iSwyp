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
	ISRenderVC * renderer	=	[[ISRenderVC alloc] init];
	[renderer setDelegate:delegate];
	[renderer setRenderObject:renderObject];
	[renderer startRendering];
	
	return renderer;
}

-(void) startRendering{
	//dispatch_get_main_queue()
	dispatch_async(dispatch_get_global_queue(0, 0), ^{
		CGSize viewSize	=	self.view.size;
		UIGraphicsBeginImageContextWithOptions(viewSize,YES, 0);
		[self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
		UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		[self performSelectorOnMainThread:@selector(didFinalizeRenderWithImage:) withObject:image waitUntilDone:TRUE];
	});
}
-(void) stopRenderingReleaseDelegateAndRenderObject{
	self.renderObject	=	nil;
	self.delegate		=	nil;
}

-(void)didFinalizeRenderWithImage:(UIImage*)renderImage{
	[delegate didRenderImage:renderImage forRenderObject:renderObject renderVC:self];
	[self stopRenderingReleaseDelegateAndRenderObject];
}

-(void) viewDidLoad{
	[super viewDidLoad];
}

@end
