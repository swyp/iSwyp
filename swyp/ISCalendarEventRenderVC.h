//
//  ISCalendarEventRenderVC.h
//  swyp
//
//  Created by Alexander List on 2/22/12.
//  Copyright (c) 2012 ExoMachina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import "ISRenderVC.h"

@interface ISCalendarEventRenderVC : ISRenderVC
@property (nonatomic, strong) EKEvent* renderObject;
+(id) beginRenderWithObject:(EKEvent*)renderEKEvent retainedDelegate:(NSObject<ISRenderVCDelegate>*)delegate;
@end
