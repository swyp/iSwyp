//
//  ISContactManager.m
//  swyp
//
//  Created by Ethan Sherbondy on 2/24/12.
//  Copyright (c) 2012 ExoMachina. All rights reserved.
//

#import "ISContactManager.h"

@implementation ISContactManager

@synthesize contactInfo = _contactInfo;
@synthesize thumbnailImage = _thumbnailImage;

- (id)init{
    self = [super init];
    if (self){
        _swypWorkspace = [swypWorkspaceViewController sharedSwypWorkspace];
        _swypWorkspace.contentDataSource = self;
    }
    
    return self;
}

- (void)showWorkspaceWithContactInfo:(NSDictionary *)theInfo andViewImage:(UIImage *)theImage {
    self.contactInfo = theInfo;
    self.thumbnailImage = theImage;
    
    [[self datasourceDelegate] datasourceSignificantlyModifiedContent:self];

    [_swypWorkspace presentContentWorkspaceAtopRootViewController];
}

#pragma mark - delegation
#pragma mark <swypContentDataSourceProtocol, swypConnectionSessionDataDelegate>
- (NSArray *)idsForAllContent {
    if (self.contactInfo){
        return [NSArray arrayWithObject:@"CONTACT_ITEM"];
    } else {
        return nil;
    }
}
- (UIImage *)iconImageForContentWithID:(NSString*)contentID ofMaxSize:(CGSize)maxIconSize {	
	return self.thumbnailImage;
}

- (NSArray*)supportedFileTypesForContentWithID:(NSString*)contentID {
	return [NSArray arrayWithObjects:[NSString swypContactFileType],
            [NSString imageJPEGFileType],
            [NSString imagePNGFileType], nil];
}

- (NSData*)	dataForContentWithID:(NSString *)contentID fileType:(swypFileTypeString *)type{
	NSData *	sendData	=	nil;	
	
	if (type == [NSString swypContactFileType]){
        sendData = [NSKeyedArchiver archivedDataWithRootObject:self.contactInfo];
	} else if ([type isFileType:[NSString imagePNGFileType]]){
        sendData	=	UIImagePNGRepresentation(self.thumbnailImage);
	} else if ([type isFileType:[NSString imageJPEGFileType]]){
        sendData	=	UIImageJPEGRepresentation(self.thumbnailImage, 0.8);
	} else{
		EXOLog(@"No data coverage for content type %@ of ID %@", type,contentID);
	}
	
	return sendData;
}

-(void)	setDatasourceDelegate:(id<swypContentDataSourceDelegate>)theDelegate{
	_datasourceDelegate = theDelegate;
}
-(id<swypContentDataSourceDelegate>)	datasourceDelegate{
	return _datasourceDelegate;
}

-(void)	contentWithIDWasDraggedOffWorkspace:(NSString*)contentID{
	[_datasourceDelegate datasourceRemovedContentWithID:contentID withDatasource:self];
}

#pragma mark -
-(NSArray*)supportedFileTypesForReceipt{
	return nil;
}
-(void) yieldedData:(NSData *)streamData ofType:(NSString *)streamType fromDiscernedStream:(swypDiscernedInputStream *)discernedStream inConnectionSession:(swypConnectionSession *)session{
	
}

@end
