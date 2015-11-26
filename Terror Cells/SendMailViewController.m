//
//  SendMailViewController.m
//  Terror Cells
//
//  Created by Gal Blank on 11/13/12.
//  Copyright (c) 2012 Gal Blank. All rights reserved.
//

#import "SendMailViewController.h"
#import "AppDelegate.h"
#import "Globals.h"
#import "LocationMap.h"
#import "LocationsViewController.h"
@interface SendMailViewController ()

@end

@implementation SendMailViewController

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
    
    [self setTitle:@"Submit new Intel"];

    [self.view setBackgroundColor:[UIColor clearColor]];
    
    self.locationStr = @"";
    self.languages = @"";
    
    inputTable = [[UITableView alloc] initWithFrame:CGRectMake(5,5,self.view.frame.size.width - 10,self.view.frame.size.height - 50) style:UITableViewStyleGrouped];
	inputTable.delegate = self;
	inputTable.dataSource = self;
    inputTable.tag = 1;
    inputTable.backgroundView = nil;
	[inputTable setBackgroundColor:[UIColor clearColor]];
	inputTable.scrollEnabled = NO;
	inputTable.allowsSelection = YES;
	[self.view addSubview:inputTable];
    
    topicdesc = [[GalTextView alloc] initWithFrame:CGRectMake(0,-1,inputTable.frame.size.width,170.0)];
    topicdesc.paretnView = self.view;
    topicdesc.delegate = self;
    [topicdesc setBorderstyle:UITextBorderStyleNone];
    [topicdesc setTextColor:[UIColor grayColor]];
    [topicdesc setFont:[UIFont systemFontOfSize:14]];
    [topicdesc setTextAlignment:UITextAlignmentLeft];
    
    [topicdesc setGalBackgroundColor:[UIColor whiteColor]];
    topicdesc.keyboardType =  UIKeyboardTypeDefault;
    [topicdesc setPlaceholder:@"Add your description here"];
    
    cellsize = [[GalTextView alloc] initWithFrame:CGRectMake(inputTable.frame.size.width - 50,5,50,30)];
    cellsize.paretnView = self.view;
    cellsize.delegate = self;
    [cellsize setBorderstyle:UITextBorderStyleLine];
    [cellsize setTextColor:[UIColor grayColor]];
    [cellsize setFont:[UIFont systemFontOfSize:14]];
    [cellsize setTextAlignment:UITextAlignmentLeft];
    
    [cellsize setGalBackgroundColor:[UIColor whiteColor]];
    cellsize.keyboardType =  UIKeyboardTypeDefault;
    [cellsize setPlaceholder:@"#"];
    
    txtlblPlaces = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, inputTable.frame.size.width - 50,40)];
    languagesLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, inputTable.frame.size.width - 50,40)];
    [languagesLbl setNumberOfLines:0];
    
    loadingWheel = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingWheel];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)sendEmailThreaded
{
    AppDelegate *mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[mainDelegate showActivityViewer:@"Sending..." :self.view.frame];
   /* dispatch_async(dispatch_get_main_queue(), ^{
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
        NSString *intelBody = [NSString stringWithFormat:@"Here is a new terror intel submitted just now\r\nLocation: %@\r\nSize: %@\r\nLanguages: %@\r\nOther Details: %@",self.locationStr,cellsize.text,self.languages,topicdesc.text];
        [builder setHTMLBody:intelBody];
        
        
        if(imageData != nil){
            MCOAttachment *attachment = [MCOAttachment attachmentWithData:imageData filename:@"snapshot.jpg"];
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

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thank you!" message:@"Your intel has been submitted and will be reviewed ASAP!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [self.navigationController popViewControllerAnimated:YES];
        
        [mainDelegate hideActivityViewer];
    });*/
    
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
        [cell.textLabel setFont:[UIFont fontWithName:@"Optima-Bold" size:14.0]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	}
    
    if(indexPath.row == 0){
        cell.textLabel.text = [NSString stringWithFormat:@"Location: %@",self.locationStr];
        [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
    }
    else if(indexPath.row == 1){
        [cell.textLabel setText:@"Headcount:"];
        [cell.contentView addSubview:cellsize];
    }
    else if(indexPath.row == 2){
        cell.textLabel.text = [NSString stringWithFormat:@"Languages: %@",self.languages];
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
        [cell.textLabel setTextColor:[UIColor redColor]];
        [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
        [cell setAlpha:0.7];
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
        LocationsViewController *languages = [[LocationsViewController alloc] init];
        [languages setParent:self];
        [self.navigationController pushViewController:languages animated:YES];
    }
}

-(void)setLangs:(NSMutableArray*)langs
{
    for(NSString *lang in langs)
    {
        self.languages = [self.languages stringByAppendingFormat:@"%@ ",lang];
    }
    [inputTable reloadData];
}

-(void)setLocations:(NSString*)location :(UIImage*)_snapShot :(NSData*)data
{
    self.locationStr = location;
    imageData = data;
    snapShot = _snapShot;
    [inputTable reloadData];
}

@end
