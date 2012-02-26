//
//  ISContactManager.h
//  swyp
//
//  Created by Ethan Sherbondy on 2/24/12.
//  Copyright (c) 2012 ExoMachina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <swyp.h>

@interface ISContactManager : NSObject <swypContentDataSourceProtocol, swypConnectionSessionDataDelegate> {
    swypWorkspaceViewController *_swypWorkspace;
    id<swypContentDataSourceDelegate>	_datasourceDelegate;
}

@property (nonatomic, strong) NSDictionary *contactInfo;
@property (nonatomic, strong) UIImage *thumbnailImage;

- (void)showWorkspaceWithContactInfo:(NSDictionary *)contactInfo andViewImage:(UIImage *)theImage;

@end
