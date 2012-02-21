//
//  ISRenderVC.h
//  swyp
//
//  Created by Alexander List on 2/20/12.
//  Copyright (c) 2012 ExoMachina. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ISRenderVC;
@protocol ISRenderVCDelegate <NSObject>
-(void) didRenderImage:(UIImage*)image forRenderObject:(id)renderObject renderVC:(ISRenderVC*)vc;
@end

@interface ISRenderVC : UIViewController
@property (nonatomic, strong) NSObject* renderObject;
@property (nonatomic, strong)	NSObject<ISRenderVCDelegate> * delegate;

+(id) beginRenderWithObject:(NSObject*)renderObject retainedDelegate:(NSObject<ISRenderVCDelegate>*)delegate;

-(void) startRendering;
-(void) stopRenderingReleaseDelegateAndRenderObject;


#pragma mark internal
-(void)didFinalizeRenderWithImage:(UIImage*)renderImage;
@end
