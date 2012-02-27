//
//  ISPasteboardVC.m
//  swyp
//
//  Created by Ethan Sherbondy on 2/3/12.
//  Copyright (c) 2012 ExoMachina. All rights reserved.
//

#import "ISPasteboardVC.h"
#import <QuartzCore/QuartzCore.h>
#import "NSString+URLEncoding.h"
#import <CoreLocation/CoreLocation.h>

@implementation ISPasteboardVC

@synthesize pbChangeCount;
@synthesize pbObjects;

static NSInteger PBHEIGHT;
static NSInteger PBWIDTH;

+(UITabBarItem *)tabBarItem{
	return [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Pasteboard", @"Tab bar item for pasteboard") 
                                         image:[UIImage imageNamed:@"paperclip"] tag:2];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.pbObjects = [NSMutableArray array];
        
        library = [[ALAssetsLibrary alloc] init];
        
        if (deviceIsPad){
            PBHEIGHT = 424;
            PBWIDTH = 640;
        } else {
            PBHEIGHT = 212;
            PBWIDTH = 320;
        }
    }
    
    pbChangeCount = 0;
    
    return self;
}



- (void)viewDidLoad{
    [super viewDidLoad];
	
	pbScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, (self.view.height-PBHEIGHT)/2, self.view.width, PBHEIGHT)];
	pbScrollView.showsHorizontalScrollIndicator = NO;
    pbScrollView.showsVerticalScrollIndicator = NO;
	pbScrollView.pagingEnabled = YES;
	pbScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
	pbScrollView.delegate = self;
	[self.view addSubview:pbScrollView];
	
	pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, (self.view.height+PBHEIGHT+48)/2, self.view.width, 24)];
    pageControl.autoresizingMask = UIViewAutoresizingFlexibleMargins|UIViewAutoresizingFlexibleDimensions;
	[self.view addSubview:pageControl];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];	
}

- (void)addMostRecentPhotoTaken {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop){
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];

			if ([group numberOfAssets] > 0){
            // only grab the most recent asset
				[group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:([group numberOfAssets]-1)] options:0 usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop){
					if (alAsset){
						NSDate *timeTaken = [alAsset valueForProperty:ALAssetPropertyDate];
						
						// we only care if the photo was taken in the last 3 minutes
						if (abs([timeTaken timeIntervalSinceNow]) < 60*3){
							__block CGImageRef imgRef = CGImageRetain([[alAsset defaultRepresentation] fullScreenImage]);
							
							dispatch_async(dispatch_get_main_queue(), ^{
								if (alAsset.defaultRepresentation.url != latestAssetURL){
									
                                  NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"!" forKey:@"text"];
                                  [[NSNotificationCenter defaultCenter] postNotificationName:@"pasteboardBadge" object:nil userInfo:userInfo];
									
									latestAssetURL = alAsset.defaultRepresentation.url;
									NSLog(@"Adding image!");
									ISPasteboardObject *pbItem = [[ISPasteboardObject alloc] init];
									pbItem.image = [UIImage imageWithCGImage:imgRef];
									[self.pbObjects insertObject:pbItem atIndex:0];

									[self redisplayPasteboard];
								}
							});
						}
					}
				}];
			}
        } failureBlock:^(NSError *error) {
            NSLog(@"No groups, %@", error);
        }];
    });
}

- (void)redisplayPasteboard {
    for (id subview in [pbScrollView subviews]){
        if ([subview class] == [ISPasteboardView class]){
            [subview removeFromSuperview];
        }
    }
    
    NSLog(@"%@", pbObjects);
    
    int i = 0;
    for (ISPasteboardObject *pbObject in pbObjects){
        ISPasteboardView *pasteView = [[ISPasteboardView alloc] initWithFrame:
                                       CGRectMake(i*PBWIDTH, 0, PBWIDTH, PBHEIGHT)];
        pbObject.delegate = pasteView;
        [pbScrollView addSubview:pasteView];
        i += 1;
    }
    
    pbScrollView.contentSize = CGSizeMake(i*PBWIDTH, PBHEIGHT);
    pageControl.numberOfPages = i;
}

- (void)updatePasteboard {
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    // go by changecount
    if (pbChangeCount != pasteBoard.changeCount) {
        pbChangeCount = pasteBoard.changeCount;
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"!" forKey:@"text"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"pasteboardBadge" object:nil userInfo:userInfo];
                
        if (pasteBoard.images) {
            for (UIImage *image in pasteBoard.images){
                ISPasteboardObject *pbItem = [[ISPasteboardObject alloc] init];
                pbItem.image = image;
                pbItem.text = nil;
                
                [pbObjects insertObject:pbItem atIndex:0];
            }
        } else if (pasteBoard.URL) {
            ISPasteboardObject *pbItem = [[ISPasteboardObject alloc] init];

            pbItem.text = [pasteBoard.URL absoluteString];
            
            [pbObjects insertObject:pbItem atIndex:0];
        
        } else if (pasteBoard.string) {
            
            NSDataDetector *addressDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeAddress error:NULL];
            
            NSTextCheckingResult *match = [addressDetector firstMatchInString:pasteBoard.string 
                                                                      options:0 
                                                                        range:NSMakeRange(0, pasteBoard.string.length)];
            
            ISPasteboardObject *pbItem = [[ISPasteboardObject alloc] init];

            if (match) {
                pbItem.address = pasteBoard.string;
            } else {
                pbItem.text = pasteBoard.string;
            }
            
            [pbObjects insertObject:pbItem atIndex:0];
        }
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"pasteboardBadge" object:nil userInfo:nil];

        [self addMostRecentPhotoTaken];
    }
    
    [self redisplayPasteboard];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    pageControl.currentPage = round(scrollView.contentOffset.x/PBWIDTH);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}

@end
