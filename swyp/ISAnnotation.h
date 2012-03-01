//
//  ISAnnotation.h
//  swyp
//
//  Created by Ethan Sherbondy on 3/1/12.
//  Copyright (c) 2012 ExoMachina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ISAnnotation : NSObject <MKAnnotation>

- (void)setTitle:(NSString *)newTitle;
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;
+ (ISAnnotation *)annotationWithCoordinate:(CLLocationCoordinate2D)theCoordinate andTitle:(NSString *)theTitle;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;

@end
