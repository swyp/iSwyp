//
//  ISSwypHistoryItem.m
//  swyp
//
//  Created by Alexander List on 2/4/12.
//  Copyright (c) 2012 ExoMachina. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import "ISSwypHistoryItem.h"
#import "ISHistoryCell.h"
#import "UIWindow+ISUXAddons.h"
#import "UIApplication+ISApplicationAddtions.h"
#import "NSData+Base64.h"

@implementation ISSwypHistoryItem

@dynamic dateAdded;
@dynamic itemData;
@dynamic itemPreviewImage;
@dynamic itemTag;
@dynamic itemType;
@synthesize localizedActionNamesByExportAction = _localizedActionNamesByExportAction;

-(void) awakeFromInsert{
	[super awakeFromInsert];
	[self setDateAdded:[NSDate date]];
}

- (Class)cellClass{
	return [ISHistoryCell class];
}

- (UITableViewCellStyle)cellStyle{
	return UITableViewCellStyleDefault;
}

-(void) addToPasteboard{
	//image type
	if ([[self itemType] isFileType:[NSString imagePNGFileType]]){
		[[UIPasteboard generalPasteboard] setData:[self itemData] forPasteboardType:@"public.png"];
	}else if ([[self itemType] isFileType:[NSString imageJPEGFileType]]){
		[[UIPasteboard generalPasteboard] setData:[self itemData] forPasteboardType:@"public.jpeg"];
	} else{
		[[UIPasteboard generalPasteboard] setData:[self itemPreviewImage] forPasteboardType:@"public.jpeg"];
	}
	
	NSString * textRep	=	[self textRepresentation];
	if (StringHasText(textRep)){
		[[UIPasteboard generalPasteboard] setString:textRep];
	}

}

-(NSString*) textRepresentation{
	NSString * representation = nil;
	
	if ([[self itemType] isFileType:[NSString textPlainFileType]]){
		representation	=	[[NSString alloc]  initWithBytes:[[self itemData] bytes] length:[[self itemData] length] encoding: NSUTF8StringEncoding]; 
	} else if ([[self itemType] isFileType:[NSString swypAddressFileType]]){
		NSDictionary *itemDict	= [NSDictionary dictionaryWithJSONString:
                                   [[NSString alloc] initWithBytes:[[self itemData] bytes] 
                                                            length:[[self itemData] length] 
                                                          encoding: NSUTF8StringEncoding]];
        if ([itemDict objectForKey:@"address"]){
             representation = [itemDict objectForKey:@"address"];
        } else if ([itemDict objectForKey:@"coords"]){
            representation = [itemDict objectForKey:@"coords"];
        }
	} else if ([[self itemType] isFileType:[NSString swypContactFileType]]){
        representation = [[self itemDataDictionaryRep] objectForKey:@"Name"];
    }
	
	return representation;
}


-(void) displayInSwypWorkspace {
	swypWorkspaceViewController * swypWorkspace	= [swypWorkspaceViewController sharedSwypWorkspace];
	[swypWorkspace setContentDataSource:self];
	[_datasourceDelegate datasourceSignificantlyModifiedContent:self];
	[swypWorkspace presentContentWorkspaceAtopViewController:[[[UIApplication sharedApplication] keyWindow] rootViewController]];
}

-(NSIndexSet*)supportedExportActions{
	NSMutableIndexSet	* actions	=	[NSMutableIndexSet indexSet];
	if ([[self itemType] isFileType:[NSString imagePNGFileType]] || [[self itemType] isFileType:[NSString imageJPEGFileType]]){
		[actions addIndex:swypHistoryItemExportActionSaveToPhotoRoll];
	}
	
	if ([[self itemType] isFileType:[NSString swypContactFileType]]){
		[actions addIndex:swypHistoryItemExportActionSaveToContacts];
	}
	
	if ([[self itemType] isFileType:[NSString swypAddressFileType]]){
		[actions addIndex:swypHistoryItemExportActionOpenInMaps];
	}

	return actions;
}

-(void) performExportAction:(swypHistoryItemExportAction)exportAction withSendingViewController:(UIViewController*)controller{
	if (exportAction == swypHistoryItemExportActionOpenInMaps){
		NSDictionary * mapsDict		=	[self itemDataDictionaryRep];
		NSString * coordinates		=	[mapsDict valueForKey:@"coord"];
		NSString * address			=	[mapsDict valueForKey:@"address"];

		NSString * urlToOpen		=	nil;
		
		if (StringHasText(coordinates)){
			if (StringHasText(address)){
				urlToOpen	=	[NSString stringWithFormat:@"http://maps.google.com/maps?q=%@&near=%@",[address stringByAddingPercentEscapesUsingEncoding:kCFStringEncodingUTF8],coordinates];
			}
		} else if (StringHasText(address)){
			urlToOpen	=	[NSString stringWithFormat:@"http://maps.google.com/maps?q=%@",[address stringByAddingPercentEscapesUsingEncoding:kCFStringEncodingUTF8]];
		}
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlToOpen]];
	}else if (exportAction == swypHistoryItemExportActionSaveToContacts){
		//save to contacts and display
        
        NSDictionary *personDict = [self itemDataDictionaryRep];
        NSArray *nameArray = [[personDict objectForKey:@"Name"] 
                              componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        CFErrorRef error = NULL;
                
        ABRecordRef newPerson = ABPersonCreate();
        
        NSData *imageData = [NSData dataWithBase64String:[personDict objectForKey:@"Image"]];
        if (imageData){
            ABPersonSetImageData(newPerson, (__bridge CFDataRef)imageData, &error);
        }
        
        ABRecordSetValue(newPerson, kABPersonFirstNameProperty, (__bridge CFStringRef)[nameArray objectAtIndex:0], &error);
        if (nameArray.count > 2){
            ABRecordSetValue(newPerson, kABPersonMiddleNameProperty, (__bridge CFStringRef)[nameArray objectAtIndex:1], &error);
        }
        if (nameArray.count > 1){
            ABRecordSetValue(newPerson, kABPersonLastNameProperty, (__bridge CFStringRef)[nameArray objectAtIndex:(nameArray.count-1)], &error);
        }

        if ([personDict objectForKey:@"Number"]){
            ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABPersonEmailProperty);
            ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFStringRef)[personDict objectForKey:@"Number"], kABPersonPhoneMainLabel, NULL);
            ABRecordSetValue(newPerson, kABPersonPhoneProperty, multiPhone, &error);
            CFRelease(multiPhone);
        }
        
        if ([personDict objectForKey:@"Email"]){
            ABMutableMultiValueRef multiEmail = ABMultiValueCreateMutable(kABPersonEmailProperty);
            ABMultiValueAddValueAndLabel(multiEmail, (__bridge CFStringRef)[personDict objectForKey:@"Email"], (__bridge CFStringRef)@"email", NULL);
            ABRecordSetValue(newPerson, kABPersonEmailProperty, multiEmail, &error);
            CFRelease(multiEmail);
        }
        
        if (error != NULL){
            CFStringRef errorDesc = CFErrorCopyDescription(error);
            NSLog(@"Contact not saved: %@", errorDesc);
            CFRelease(errorDesc);
        }
        
        ABNewPersonViewController *personVC = [[ABNewPersonViewController alloc] init];
        personVC.newPersonViewDelegate = self;
        [personVC setDisplayedPerson:newPerson];
        
        CFRelease(newPerson);
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:personVC];
        [[UIApplication rootVC] presentModalViewController:navController animated:YES];
        
	} else if (exportAction == swypHistoryItemExportActionSaveToCalendar){
		//save to calendar and display calendar
	} else if (exportAction == swypHistoryItemExportActionSaveToPhotoRoll){
		UIImageWriteToSavedPhotosAlbum([self biggestImageAvailable], nil, nil, nil);
		[[[UIApplication sharedApplication] keyWindow] flashWindow];
	}
}

-(swypBidirectionalMutableDictionary*)localizedActionNamesByExportAction{
	if (_localizedActionNamesByExportAction == nil){
		_localizedActionNamesByExportAction	=	[[swypBidirectionalMutableDictionary alloc] init];
		for (swypHistoryItemExportAction i = swypHistoryItemExportActionNone; i <= swypHistoryItemExportActionOpenInMaps; i++){
			switch (i) {
				case swypHistoryItemExportActionOpenInMaps:
					[_localizedActionNamesByExportAction setObject:LocStr(@"Open in Maps", @"for default export action name for received swyp history item") forKey:[NSNumber numberWithInt:i]];
					break;
				case swypHistoryItemExportActionSaveToCalendar:
					[_localizedActionNamesByExportAction setObject:LocStr(@"Add to Cal", @"for default export action name for received swyp history item") forKey:[NSNumber numberWithInt:i]];
					break;
				case swypHistoryItemExportActionSaveToContacts:
					[_localizedActionNamesByExportAction setObject:LocStr(@"Save Contact", @"for default export action name for received swyp history item") forKey:[NSNumber numberWithInt:i]];
					break;
				case swypHistoryItemExportActionSaveToPhotoRoll:
					[_localizedActionNamesByExportAction setObject:LocStr(@"Save Photo", @"for default export action name for received swyp history item") forKey:[NSNumber numberWithInt:i]];
					break;
				default:
					break;
			}
		}
	}
	return _localizedActionNamesByExportAction;
}

-(UIImage*)	biggestImageAvailable{
	UIImage * largestImage	=	nil;
	if ([[self itemType] isFileType:[NSString imagePNGFileType]] || [[self itemType] isFileType:[NSString imageJPEGFileType]]){
		largestImage	=	[UIImage imageWithData:[self itemData]];
	}else{
		largestImage	=	[UIImage imageWithData:[self itemPreviewImage]];
	}
	
	return largestImage;
}

-(NSDictionary*) itemDataDictionaryRep {
	NSDictionary * parsedDict	=	nil;
	if ([[self itemType] isFileType:[NSString swypAddressFileType]] || ([[self itemType] isFileType:[NSString swypContactFileType]])|| ([[self itemType] isFileType:[NSString swypCalendarEventsFileType]])){
		NSString *	readString	=	[[NSString alloc]  initWithBytes:[[self itemData] bytes] length:[[self itemData] length] encoding: NSUTF8StringEncoding];
		if (StringHasText(readString)){
			parsedDict				=	[NSDictionary dictionaryWithJSONString:readString];
		}
	} 
	
	
	return parsedDict;
}

#pragma mark <ABNewPersonViewControllerDelegate>

- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person {
    [[UIApplication rootVC] dismissModalViewControllerAnimated:YES];
}

#pragma mark - delegation
#pragma mark <swypContentDataSourceProtocol, swypConnectionSessionDataDelegate>
- (NSArray*)	idsForAllContent{
	return [NSArray arrayWithObject:@"PREVIEW_DISPLAYED_ITEM"];
}
- (UIImage *)	iconImageForContentWithID: (NSString*)contentID ofMaxSize:(CGSize)maxIconSize{	
	UIImage * returnImage	=	[UIImage imageWithData:[self itemPreviewImage]];
	if (returnImage == nil){
		returnImage	=	[UIImage imageNamed:@"swypPromptHud.png"];
	}
	return returnImage;
}

- (NSArray*)		supportedFileTypesForContentWithID: (NSString*)contentID{
	return [NSArray arrayWithObjects:[self itemType],[NSString imageJPEGFileType],[NSString imagePNGFileType], nil];
}

- (NSData*)	dataForContentWithID: (NSString*)contentID fileType:	(swypFileTypeString*)type{
	NSData *	sendData	=	nil;	
	
	if ([type isFileType:[self itemType]]){
		sendData	=	[self itemData];
	}else if ([type isFileType:[NSString imagePNGFileType]]){
		if ([[self itemType] isFileType:[NSString imageJPEGFileType]]){
			sendData	=	UIImagePNGRepresentation([UIImage imageWithData:[self itemData]]);
		}else{
			sendData	=	UIImagePNGRepresentation([UIImage imageWithData:[self itemPreviewImage]]);
		}
	}else if ([type isFileType:[NSString imageJPEGFileType]]){
		if ([[self itemType] isFileType:[NSString imagePNGFileType]]){
			sendData	=	 UIImageJPEGRepresentation([UIImage imageWithData:[self itemData]],.8);
		}else{
			sendData	=	[self itemPreviewImage]; //already jpeg
		}
	}else{
		EXOLog(@"No data coverage for content type %@ of ID %@",type,contentID);
	}
	
	
	return sendData;
}

-(void)	setDatasourceDelegate:			(id<swypContentDataSourceDelegate>)delegate{
	_datasourceDelegate	=	delegate;
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
