//
//  ISPreviewMapViewVC.h
//  swyp
//
//  Created by Alexander List on 2/8/12.
//  Copyright (c) 2012 ExoMachina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "MKMapView+ZoomLevel.h"
#import "ISSwypHistoryItem.h"

@interface ISPreviewMapViewVC : UIViewController {
    MKMapView *_mapView;
}

- (id)loadContentFromHistoryItem:(ISSwypHistoryItem *)item;

@end
