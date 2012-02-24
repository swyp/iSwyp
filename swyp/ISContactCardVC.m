//
//  ISContactView.m
//  swyp
//
//  Created by Ethan Sherbondy on 2/14/12.
//  Copyright (c) 2012 ExoMachina. All rights reserved.
//

#import "ISAppDelegate.h"
#import "ISContactCardVC.h"
#import <QuartzCore/QuartzCore.h>

static const NSInteger kNameField = 0;
static const NSInteger kNumberField = 1;
static const NSInteger kEmailField = 2;

@interface UIView (Recurse)
    - (NSString *)recursiveDescription;
@end

@implementation ISContactCardVC

@synthesize tableView = _tableView;
@synthesize faceButton = _faceButton;
@synthesize editButton = _editButton;

- (id)init {
    self = [super init];
    if (self){
        NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:@"Name"];
        NSString *number = [[NSUserDefaults standardUserDefaults] objectForKey:@"Number"];
        NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"Email"];
        
        NSArray* tableContents =
        [NSArray arrayWithObjects:
         [NITextInputFormElement textInputElementWithID:kNameField placeholderText:@"Name" value:name delegate:self],
         [NITextInputFormElement textInputElementWithID:kNumberField placeholderText:@"Phone Number" value:number delegate:self],
         [NITextInputFormElement textInputElementWithID:kEmailField placeholderText:@"Email" value:email delegate:self],
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
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(72, 0, 300-72, 176) style:UITableViewStylePlain];
    self.tableView.clipsToBounds = YES;
    self.tableView.scrollEnabled = NO;
    self.tableView.dataSource = _model;
        
    self.faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.faceButton.frame = CGRectMake(8, 8, 56, 56);
    self.faceButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
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
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell 
forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Customize the presentation of certain types of cells.
    if ([cell isKindOfClass:[NITextInputFormElementCell class]]) {
        NITextInputFormElementCell* textInputCell = (NITextInputFormElementCell *)cell;
    }
}

- (NSString *)nameForTag:(NSInteger)tag{
    switch (tag) {
        case 0:
            return LocStr(@"Name", @"The person's name");
            break;
        case 1:
            return LocStr(@"Number", @"Phone number");
            break;
        case 2:
            return LocStr(@"Email", @"Email address");
            break;
    }
    return nil;
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsImageEditing = YES;
        
    switch (buttonIndex) {
        case 0:
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            break;
        case 1:
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
            
        default:
            break;
    }
    
    if (buttonIndex != 2){
        [[self _rootVC] presentModalViewController:imagePickerController animated:YES];
    }
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker 
        didFinishPickingImage:(UIImage *)image 
                  editingInfo:(NSDictionary *)editingInfo {
    // Do something with the image here.
    [self.faceButton setImage:image forState:UIControlStateNormal];
    [[self _rootVC] dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"Tryna cance.");
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
        [self toggleEditing];
    }
    _activeField = nil;
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.returnKeyType = UIReturnKeyNext;
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

- (void)toggleEditing{
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
    if (_isEditing) [self toggleEditing];

    // @TODO: Need to modify action sheet based on whether the device has a camera.
    UIActionSheet *photoSelectorSheet = [[UIActionSheet alloc] initWithTitle:LocStr(@"How would you like to set your picture?", nil) 
                                                                    delegate:self cancelButtonTitle:LocStr(@"Cancel",nil) 
                                                      destructiveButtonTitle:nil 
                                                           otherButtonTitles:LocStr(@"Take Picture",nil), LocStr(@"Choose Picture", nil), nil];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
        [photoSelectorSheet showFromRect:self.faceButton.frame inView:self.view animated:YES];
    } else {
        [photoSelectorSheet showInView:[self _rootVC].view];
    }
}

@end
