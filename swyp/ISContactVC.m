//
//  ISContactVC.m
//  swyp
//
//  Created by Ethan Sherbondy on 2/3/12.
//  Copyright (c) 2012 ExoMachina. All rights reserved.
//

#import "ISContactVC.h"
#import <QuartzCore/QuartzCore.h>

@implementation ISContactVC

@synthesize childViewController = _childViewController;

+(UITabBarItem*)tabBarItem{
	return [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Contact", @"Your contact card on tab bar.") image:[UIImage imageNamed:@"user"] tag:0];
}

#pragma mark -
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem = [[self class] tabBarItem];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
- (void)loadView {

}
*/

- (void)viewWillAppear:(BOOL)animated {
    CGFloat ty = self.view.origin.y - _contactCard.view.origin.y + 
    (self.view.height-_contactCard.view.height)/2;
    ty -= (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) ? 24 : 48;

    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
        _contactCard.view.transform = CGAffineTransformTranslate(_contactCard.view.transform, 0, ty);
    } completion:^(BOOL finished){
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
        CGFloat ty = self.view.size.height;
        _contactCard.view.transform = CGAffineTransformTranslate(_contactCard.view.transform, 0, ty);
    } completion:^(BOOL finished){
        
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _contactCard = [[ISContactCardVC alloc] init];
    [self addChildViewController:_contactCard];
    
    _contactCard.view.origin = CGPointMake((self.view.width - 300)/2, self.view.size.height);
    [self.view addSubview:_contactCard.view];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)addChildViewController:(UIViewController *)childController {
    [super addChildViewController:childController];
    self.childViewController = childController;
}

@end
