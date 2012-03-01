//
//  ISPreviewMapViewVC.m
//  swyp
//
//  Created by Alexander List on 2/8/12.
//  Copyright (c) 2012 ExoMachina. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#import "ISPreviewMapViewVC.h"
#import "ISAnnotation.h"

@implementation ISPreviewMapViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
    self.view = _mapView;
}

- (id)loadContentFromHistoryItem:(ISSwypHistoryItem *)item {
    // ensure we're dealing with an address
    assert([item.itemType isFileType:[NSString swypAddressFileType]]);
    
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    NSString *address = [[item itemDataDictionaryRep] objectForKey:@"address"];
    if (address){
        NSLog(@"Geocoding address: %@", address);
        [geoCoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
            NSLog(@"Done geocoding.");
            CLLocation *location = ((CLPlacemark *)[placemarks objectAtIndex:0]).location;
            ISAnnotation *annotation = [ISAnnotation annotationWithCoordinate:location.coordinate andTitle:address];

            [_mapView setCenterCoordinate:location.coordinate zoomLevel:14 animated:YES];
            [_mapView addAnnotation:annotation];
            [_mapView selectAnnotation:annotation animated:YES];
        }];
    }
    
    return self;
}

@end
