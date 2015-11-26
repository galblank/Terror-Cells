//
//  SendMailViewController.m
//  Terror Cells
//
//  Created by Gal Blank on 11/13/12.
//  Copyright (c) 2012 Gal Blank. All rights reserved.
//

#import "SendTerroristIntel.h"
#import "AppDelegate.h"
#import "Globals.h"
#import "LocationMap.h"
#import "LocationsViewController.h"
#import "ImageManipulation.h"
#import "toastView.h"

@interface SendTerroristIntel ()

@end

@implementation SendTerroristIntel

@synthesize terroristName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"I saw him!"];
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    inputTable = [[UITableView alloc] initWithFrame:CGRectMake(5,5,self.view.frame.size.width,self.view.frame.size.height) style:UITableViewStyleGrouped];
	inputTable.delegate = self;
	inputTable.dataSource = self;
    inputTable.tag = 1;
    inputTable.backgroundView = nil;
	[inputTable setBackgroundColor:[UIColor clearColor]];
	inputTable.scrollEnabled = NO;
	inputTable.allowsSelection = YES;
	[self.view addSubview:inputTable];
    
    topicdesc = [[GalTextView alloc] initWithFrame:CGRectMake(0,0,inputTable.frame.size.width - 20,170.0)];
    topicdesc.paretnView = self.view;
    topicdesc.delegate = self;
    [topicdesc setBorderstyle:UITextBorderStyleNone];
    [topicdesc setTextColor:[UIColor grayColor]];
    [topicdesc setFont:[UIFont systemFontOfSize:14]];
    [topicdesc setTextAlignment:NSTextAlignmentLeft];
    
    [topicdesc setGalBackgroundColor:[UIColor whiteColor]];
    topicdesc.keyboardType =  UIKeyboardTypeDefault;
    [topicdesc setPlaceholder:@"Add description"];
}

-(void)attachPhoto
{
	UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"Select" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Take Photo" otherButtonTitles:@"Choose from library", nil];
	popupQuery.actionSheetStyle = UIActionSheetStyleAutomatic;
    popupQuery.tag = 4;
	[popupQuery showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  
        imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        
        //imagePickerController.allowsImageEditing = YES;
        if (buttonIndex == 0) {
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES){
                imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                imagePickerController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
                imagePickerController.showsCameraControls = YES;
                [self presentModalViewController:imagePickerController animated:YES];
            }
            else{
                UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Camera is not available" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [myAlert show];
            }
        } else if (buttonIndex == 1) {
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            //UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePickerController];
            //self.popoverController = popover;
            //popoverController.delegate = self;
            //[popoverController presentPopoverFromRect:CGRectMake(0, 600, 768, 300) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentModalViewController:imagePickerController animated:YES];
        }

    
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [imagePickerController dismissModalViewControllerAnimated:YES];
    self.attachedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [inputTable reloadData];
}

-(void*)getlocalDataThrd:(UIImage*)img
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    UIImage *_img = [ImageManipulation makeRoundCornerImage:img :30 :30];
//    [self setImgData:UIImageJPEGRepresentation(preview.image, 0.5)];
    [self performSelectorOnMainThread:@selector(doneSettingImage) withObject:nil waitUntilDone:NO];
}

-(void)doneSettingImage
{
   // [toast dismissToast];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)sendEmailThreaded
{
    [loadingWheel startAnimating];
	[NSThread detachNewThreadSelector:@selector(sendMail) toTarget:self withObject:nil];
}


-(void)sendMail
{
    /*dispatch_async(dispatch_get_main_queue(), ^{
        MCOSMTPSession *smtpSession = [[MCOSMTPSession alloc] init];
        smtpSession.hostname = @"smtp.gmail.com";
        smtpSession.port = 465;
        smtpSession.username = @"terrorcells@gmail.com";
        smtpSession.password = @"290377GB";
        smtpSession.authType = MCOAuthTypeSASLPlain;
        smtpSession.connectionType = MCOConnectionTypeTLS;
        
        MCOMessageBuilder *builder = [[MCOMessageBuilder alloc] init];
        MCOAddress *from = [MCOAddress addressWithDisplayName:@"Infomail"
                                                      mailbox:@"terrorcells@gmail.com"];
        MCOAddress *to = [MCOAddress addressWithDisplayName:nil
                                                    mailbox:@"terrorcells@gmail.com"];
        [[builder header] setFrom:from];
        [[builder header] setTo:@[to]];
        [[builder header] setSubject:@"Infomail"];
        NSString *intelBody = [NSString stringWithFormat:@"Wanted terrorist intel\r\n\
                               Name: %@\r\n\
                               Location: %@\r\n\
                               When: %@\r\n\
                               Other Details: %@",terroristName,txtlblPlaces.text,cellsize.text,topicdesc.text];
        
        [builder setHTMLBody:intelBody];
       
        
        if(imageData != nil){
            MCOAttachment *attachment = [MCOAttachment attachmentWithData:imageData filename:@"location.jpg"];
            [builder addAttachment:attachment];
        }
        
        if(attachedImage != nil){
            NSData *_imgData = UIImageJPEGRepresentation(self.attachedImage, 1.0);
            MCOAttachment *attachment = [MCOAttachment attachmentWithData:_imgData filename:@"tprofile.jpg"];
            [builder addAttachment:attachment];
        }
        
         NSData * rfc822Data = [builder data];
        MCOSMTPSendOperation *sendOperation = [smtpSession sendOperationWithData:rfc822Data];
        [sendOperation start:^(NSError *error) {
            if(error) {
                NSLog(@"Error sending email: %@", error);
            } else {
                NSLog(@"Successfully sent email!");
            }
        }];
    });*/
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thank you!" message:@"Your intel has been submitted and will be reviewed ASAP!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [self.navigationController popViewControllerAnimated:YES];
}


- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if(topicdesc.bPlacehodler){
        topicdesc.bPlacehodler = NO;
        topicdesc.text = @"";
        topicdesc.editable = YES;
        //[topicdesc becomeFirstResponder];
    }
    else if(cellsize.bPlacehodler){
        cellsize.bPlacehodler = NO;
        cellsize.text = @"";
        cellsize.editable = YES;
        //[topicdesc becomeFirstResponder];
    }

    
    static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
    static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
    static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
    static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
    static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;
    
    CGRect textFieldRect = [self.view convertRect:textView.bounds fromView:textView];
    CGRect viewRect = [self.view convertRect:self.view.bounds fromView:self.view];
    
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    topicdesc.bPlacehodler = NO;
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 3){
        return 170.0;
    }
    else if(indexPath.row == 2){
        return 100;
    }
    else if(indexPath.row == 4){
        return 40;
    }
    return 40;
}

/*
 - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
 return @"Add details / pics below";
 }
 */
// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    return 5;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyIdentifier";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		[cell.textLabel setUserInteractionEnabled:YES];
        [cell.textLabel setTextAlignment:NSTextAlignmentLeft];
        [cell.textLabel setTextColor:[UIColor blackColor]];
        [cell.textLabel setFont:[UIFont fontWithName:@"Optima-Bold" size:14.0]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	}
    
    if(indexPath.row == 0){
        cell.textLabel.text = @"Location";
        [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
        
    }
    else if(indexPath.row == 1){
        [cell.textLabel setText:@"When?"];
    }
    else if(indexPath.row == 2){
        [cell.textLabel setText:@"Add Photo"];
        if(self.attachedImage != nil){
            [cell setImage:self.attachedImage];
        }
        [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
    }
    else if(indexPath.row == 3)
    {
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:topicdesc];
    }
    else if(indexPath.row == 4){
        [cell.textLabel setFont:[UIFont fontWithName:@"Optima-Bold" size:22.0]];
        [cell.textLabel setText:@"Submit"];
        [cell.textLabel setTextColor:[UIColor blackColor]];
        [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.row == 4){
        [self sendEmailThreaded];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"accessory tapped");
    if(indexPath.row == 0){
        LocationMap *locations = [[LocationMap alloc] init];
        [locations setParent:self];
        [self.navigationController pushViewController:locations animated:YES];
    }
    else if(indexPath.row == 2){
        [self attachPhoto];
    }
}

-(void)setLangs:(NSMutableArray*)langs
{
    languagesLbl.text = @"";
    for(NSString *lang in langs)
    {
        languagesLbl.text = [languagesLbl.text stringByAppendingFormat:@"%@ ",lang];
    }
}

-(void)setLocations:(NSString*)location :(UIImage*)_snapShot :(NSData*)data
{
    txtlblPlaces.text = location;
    imageData = data;
    snapShot = _snapShot;
}

@end
