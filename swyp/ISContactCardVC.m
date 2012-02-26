//
//  ISContactCardVC.m
//  swyp
//
//  Created by Ethan Sherbondy on 2/14/12.
//  Copyright (c) 2012 ExoMachina. All rights reserved.
//

#import "UIImage+Resize.h"

#import "ISAppDelegate.h"
#import "ISContactCardVC.h"
#import <QuartzCore/QuartzCore.h>

static const NSInteger kNameField = 0;
static const NSInteger kNumberField = 1;
static const NSInteger kEmailField = 2;

static const NSInteger PICTURE_SIDE = 56;

@interface UIView (Recurse)
    - (NSString *)recursiveDescription;
@end

@implementation ISContactCardVC

@synthesize tableView = _tableView;
@synthesize faceButton = _faceButton;
@synthesize editButton = _editButton;
@synthesize contactInfo = _contactInfo;

- (id)init {
    self = [super init];
    if (self){
        NSMutableDictionary *contactInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            [[NSUserDefaults standardUserDefaults] objectForKey:@"Name"], @"Name",
                            [[NSUserDefaults standardUserDefaults] objectForKey:@"Number"], @"Number",
                            [[NSUserDefaults standardUserDefaults] objectForKey:@"Email"], @"Email", nil];
        
        UIImage *faceImage = [UIImage imageWithContentsOfFile:[self _documentsPathForFileName:@"face.png"]];
        if (faceImage) [contactInfo setObject:faceImage forKey:@"Image"];
        self.contactInfo = contactInfo;
        
        NSArray* tableContents =
        [NSArray arrayWithObjects:
         [NITextInputFormElement textInputElementWithID:kNameField placeholderText:LocStr(@"Name",nil) 
                                                  value:[self.contactInfo objectForKey:@"Name"] delegate:self],
         [NITextInputFormElement textInputElementWithID:kNumberField placeholderText:LocStr(@"Phone Number",nil) 
                                                  value:[self.contactInfo objectForKey:@"Number"] delegate:self],
         [NITextInputFormElement textInputElementWithID:kEmailField placeholderText:LocStr(@"Email",nil) 
                                                  value:[self.contactInfo objectForKey:@"Email"] delegate:self],
         nil];
        
        _model = [[NITableViewModel alloc] initWithSectionedArray:tableContents
                                                    delegate:(id)[NICellFactory class]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isEditing = NO;
        
    self.view.frame = CGRectMake(0, 0, 300, 176);
    self.view.autoresizingMask = UIViewAutoresizingFlexibleMargins;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"handmadepaper"]];
    self.view.clipsToBounds = NO;
    CALayer *layer = self.view.layer;
    layer.shadowRadius = 8;
    layer.shadowColor = [UIColor whiteColor].CGColor;
    layer.shadowOffset = CGSizeMake(0, 20);
    layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
    
    UIGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(triggerSwypContactInfo:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(72, 0, 300-72, 176) style:UITableViewStylePlain];
    self.tableView.clipsToBounds = YES;
    self.tableView.scrollEnabled = NO;
    self.tableView.dataSource = _model;
        
    self.faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.faceButton.frame = CGRectMake(8, 8, PICTURE_SIDE, PICTURE_SIDE);
    self.faceButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.faceButton.layer.cornerRadius = 8;
    self.faceButton.showsTouchWhenHighlighted = YES;
    self.faceButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    self.faceButton.titleLabel.textAlignment = UITextAlignmentCenter;
    self.faceButton.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.faceButton.titleLabel.textColor = [UIColor blackColor];
    self.faceButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.faceButton setTitle:LocStr(@"Add an image",nil) forState:UIControlStateNormal];
    [self.faceButton addTarget:self action:@selector(showPhotoSelectorActionSheet) forControlEvents:UIControlEventTouchUpInside];
    
    self.editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.editButton.frame = CGRectMake(8, 96, 56, 28);
    self.editButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [self.editButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.editButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.editButton setTitle:LocStr(@"Edit", @"Edit contact info") forState:UIControlStateNormal];
    [self.editButton addTarget:self action:@selector(toggleEditing) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubviews:self.tableView, self.faceButton, self.editButton, nil];
    
    _imagePickerController = [[UIImagePickerController alloc] init];
    _imagePickerController.delegate = self;
    _imagePickerController.allowsEditing = YES;
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tappedOutside:) name:@"tappedOutside" object:NULL];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    UIImage *buttonImage = [UIImage imageNamed:@"FlatButtonSmall.png"];
    UIImage *pressedButtonImage = [UIImage imageNamed:@"FlatButtonSmallPressed.png"];
    
    // And create the stretchy version.
    float w = buttonImage.size.width / 2, h = buttonImage.size.height / 2;
    UIImage *stretchedButtonImage = [buttonImage stretchableImageWithLeftCapWidth:w topCapHeight:h];
    UIImage *stretchedPressedButtonImage = [pressedButtonImage stretchableImageWithLeftCapWidth:w topCapHeight:h];
    
    [self.editButton setBackgroundImage:stretchedButtonImage forState:UIControlStateNormal];
    [self.editButton setBackgroundImage:stretchedPressedButtonImage forState:UIControlStateHighlighted];
    
    UIImage *faceImage = [self.contactInfo objectForKey:@"Image"];
    if (faceImage){
        [self.faceButton setImage:faceImage forState:UIControlStateNormal];
    }
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell 
forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Customize the presentation of certain types of cells.
//    if ([cell isKindOfClass:[NITextInputFormElementCell class]]) {
//        NITextInputFormElementCell* textInputCell = (NITextInputFormElementCell *)cell;
//    }
}

- (NSString *)nameForTag:(NSInteger)tag{
    switch (tag) {
        case 0:
            return @"Name";
            break;
        case 1:
            return @"Number";
            break;
        case 2:
            return @"Email";
            break;
    }
    return nil;
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
                _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            } else {
                _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
            break;
        case 1:
            _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
        default:
            break;
    }
    
    if (buttonIndex != actionSheet.cancelButtonIndex){
        [[self _rootVC] presentModalViewController:_imagePickerController animated:YES];
    }
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker 
        didFinishPickingImage:(UIImage *)image 
                  editingInfo:(NSDictionary *)editingInfo {
    // Do something with the image here.
    UIImage *resizedImage = [image thumbnailImage:PICTURE_SIDE
                                transparentBorder:0 
                                     cornerRadius:8 
                             interpolationQuality:1];
    
    NSData *faceImageData = UIImagePNGRepresentation(resizedImage);
    NSString *filePath = [self _documentsPathForFileName:@"face.png"]; //Add the file name
    [faceImageData writeToFile:filePath atomically:YES];
    
    [self.contactInfo setValue:resizedImage forKey:@"Image"];

    [self.faceButton setImage:resizedImage forState:UIControlStateNormal];
    [[self _rootVC] dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [[self _rootVC] dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    UITableViewCell* selectedCell = [self.tableView.dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
    if ([selectedCell isKindOfClass:[NIButtonFormElementCell class]]) {
        NIButtonFormElementCell* buttonCell = (NIButtonFormElementCell*)selectedCell;
        [buttonCell buttonWasTapped:selectedCell];
    }
    // Clear the selection state when we're done.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return _isEditing;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag != 2){
        NITextInputFormElementCell* cell = (NITextInputFormElementCell *)[self.tableView viewWithTag:(textField.tag+1)];
        [cell.textField becomeFirstResponder];
        return NO;
    } else {
        // last field, end editing.
        [self _toggleEditing];
    }
    _activeField = nil;
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.returnKeyType = UIReturnKeyNext;
    textField.enablesReturnKeyAutomatically = YES;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _activeField = textField;

    switch (textField.tag) {
        case kNumberField:
            textField.keyboardType = UIKeyboardTypeNumberPad;
            break;
        case kEmailField:
            textField.keyboardType = UIKeyboardTypeEmailAddress;
            textField.returnKeyType = UIReturnKeyDone;
            break;
        default:
            textField.keyboardType = UIKeyboardTypeDefault;
            break;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [[NSUserDefaults standardUserDefaults] 
     setObject:textField.text forKey:[self nameForTag:textField.tag]];
    [self.contactInfo setValue:textField.text forKey:[self nameForTag:textField.tag]];
}

#pragma mark- Other Functions

- (UIViewController *)_rootVC {
    ISAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    return appDelegate.window.rootViewController;
}

- (void)tappedOutside:(NSNotification *)notification{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)[notification object];
    CGPoint touchPoint = [tap locationInView:self.view];
    if (touchPoint.x < 0 || touchPoint.x > self.view.width || 
        touchPoint.y < 0 || touchPoint.y > self.view.height){
        
        if (_activeField) [_activeField resignFirstResponder];
    }
}

- (void)	_toggleEditing {
    _isEditing = !_isEditing;
    if (_isEditing){        
        [self.editButton setTitle:LocStr(@"Done", @"Done editing contact info") forState:UIControlStateNormal];
        NITextInputFormElementCell *firstCell = (NITextInputFormElementCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 
                                                                                                                                       inSection:0]];
        [firstCell.textField becomeFirstResponder];
    } else {
        if (_activeField) [_activeField resignFirstResponder];
        [self.editButton setTitle:LocStr(@"Edit", @"Edit contact info") forState:UIControlStateNormal];
    }
}

- (void)showPhotoSelectorActionSheet {
    if (_isEditing) [self _toggleEditing];

    // @TODO: Need to modify action sheet based on whether the device has a camera.
    UIActionSheet *photoSelectorSheet = [[UIActionSheet alloc] init];
    photoSelectorSheet.delegate = self;
    photoSelectorSheet.title = LocStr(@"How would you like to set your picture?", nil);

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        [photoSelectorSheet addButtonWithTitle:LocStr(@"Take Picture",nil)];
    }
    [photoSelectorSheet addButtonWithTitle:LocStr(@"Choose Picture", nil)];
    [photoSelectorSheet addButtonWithTitle:LocStr(@"Cancel", nil)];
    photoSelectorSheet.cancelButtonIndex = (photoSelectorSheet.numberOfButtons - 1);
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
        [photoSelectorSheet showFromRect:self.faceButton.frame inView:self.view animated:YES];
    } else {
        [photoSelectorSheet showInView:[self _rootVC].view];
    }
}

- (void)triggerSwypContactInfo:(UITapGestureRecognizer *)recognizer {
    CGPoint faceLocation = [recognizer locationInView:self.view];
    CGPoint editLocation = [recognizer locationInView:self.view];
    if (!_isEditing && !CGRectContainsPoint(self.faceButton.frame, faceLocation)
                    && !CGRectContainsPoint(self.editButton.frame, editLocation)){
        NSLog(@"Time to swyp my info.");
        self.editButton.hidden = YES; // don't want edit button in thumbnail
        
        UIGraphicsBeginImageContext(self.view.bounds.size);
        [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        self.editButton.hidden = NO;
        
        ISContactManager *contactManager = [[ISContactManager alloc] init];
        [contactManager showWorkspaceWithContactInfo:self.contactInfo andViewImage:thumbnailImage];
    }
}

- (NSString *)	_documentsPathForFileName:(NSString *)name {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);  
    NSString *documentsPath = [paths objectAtIndex:0];
    return [documentsPath stringByAppendingPathComponent:name]; 
}

@end
