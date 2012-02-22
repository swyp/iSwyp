//
//  ISCalendarDayRenderVC.h
//  swyp
//
//  Created by Alexander List on 2/20/12.
//  Copyright (c) 2012 ExoMachina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ISRenderVC.h"
#import "MADayView.h"

@interface ISCalendarDayRenderVC : ISRenderVC <MADayViewDataSource>
@property (nonatomic, strong) NSArray* renderObject;
+(id) beginRenderWithObject:(NSArray*)renderMAEvents retainedDelegate:(NSObject<ISRenderVCDelegate>*)delegate;
@end
