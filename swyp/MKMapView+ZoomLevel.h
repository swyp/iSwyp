//
//  MKMapView+ZoomLevel.h
//  swyp
//
//  Created by Ethan Sherbondy on 3/1/12.
//  Copyright (c) 2012 ExoMachina. All rights reserved.
//  From: http://troybrant.net/blog/2010/01/set-the-zoom-level-of-an-mkmapview/
//

#import <MapKit/MapKit.h>

@interface MKMapView (ZoomLevel)

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated;

@end
