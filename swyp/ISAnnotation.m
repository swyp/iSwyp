//
//  ISAnnotation.m
//  swyp
//
//  Created by Ethan Sherbondy on 3/1/12.
//  Copyright (c) 2012 ExoMachina. All rights reserved.
//

#import "ISAnnotation.h"

@implementation ISAnnotation

@synthesize coordinate = _coordinate;
@synthesize title = _title;

+ (ISAnnotation *)annotationWithCoordinate:(CLLocationCoordinate2D)theCoordinate andTitle:(NSString *)theTitle {
    ISAnnotation *annotation = [[ISAnnotation alloc] init];
    [annotation setCoordinate:theCoordinate];
    [annotation setTitle:theTitle];
    return annotation;
}

- (void)setTitle:(NSString *)newTitle {
    _title = newTitle;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    _coordinate = newCoordinate;
}

@end
