//
//  MediaGridViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-11-9.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "MediaGridViewController.h"
#import "MediaObject.h"
#import "CustomBackButton.h"
#import "LocalMediaPlayerViewController.h"

@interface MediaGridViewController (){
    CustomBackButton *backButton;
}


@end

@implementation MediaGridViewController

@synthesize mediaArray;
@synthesize mediaType;

- (void)viewDidUnload
{
    [super viewDidUnload];
    backButton = nil;;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    
    backButton = [[CustomBackButton alloc] initWith:[UIImage imageNamed:@"back-button"] highlight:[UIImage imageNamed:@"back-button"] leftCapWidth:14.0 text:NSLocalizedString(@"back", nil)];
    [backButton addTarget:self action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSUInteger)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskPortrait;  // 可以修改为任何方向
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

-(BOOL)shouldAutorotate{
    
    return NO;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);  // 可以修改为任何方向
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ceil(mediaArray.count / 4.0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int num = 4;
    if(mediaArray.count < (indexPath.row+1) * 4){
        num = mediaArray.count - indexPath.row * 4;
    }
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        for (int i = 0; i < 4; i++) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
            imageView.tag = 1001 + i;
            [cell.contentView addSubview:imageView];
            
            imageView.frame = CGRectMake(MEDIA_WIDTH * i + (i+1)*MEDIA_GAP, MEDIA_GAP, MEDIA_WIDTH, MEDIA_HEIGHT);

            UIButton *imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [imageBtn setFrame:imageView.frame];
            imageBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin| UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
            [imageBtn addTarget:self action:@selector(mediaImageClicked:)forControlEvents:UIControlEventTouchUpInside];
            imageBtn.tag = 2001 + i;
            [cell.contentView addSubview:imageBtn];
        }
    }

    for(int i = 0; i < 4; i++){
        UIImageView *imageView  = (UIImageView *)[cell viewWithTag:1001 + i];
        if(i < num){
            MediaObject *meida = [mediaArray objectAtIndex:indexPath.row * 3 + i];
            imageView.image = meida.image;
        } else {
            imageView.image = nil;
            UIButton *imageBtn  = (UIButton *)[cell viewWithTag:2001 + i];
            imageBtn = nil;
        }
    }
    return cell;
}

- (void)mediaImageClicked:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    CGPoint point = btn.center;
    point = [self.tableView convertPoint:point fromView:btn.superview];
    NSIndexPath* indexPath = [self.tableView indexPathForRowAtPoint:point];
    int index = indexPath.row * 4 + btn.tag - 2001;
    NSLog(@"%i", index);
    MediaObject *media = [mediaArray objectAtIndex:index];
    if(self.mediaType == 1){
        
    } else if(self.mediaType == 2){
        LocalMediaPlayerViewController *viewController = [[LocalMediaPlayerViewController alloc]initWithNibName:@"LocalMediaPlayerViewController" bundle:nil];
        viewController.videoUrl = media.mediaURL;
        [self presentViewController:viewController animated:YES completion:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 78;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)closeSelf
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
