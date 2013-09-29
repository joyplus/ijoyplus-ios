//
//  GroupImageViewController.m
//  yuexiangjia
//
//  Created by joyplus1 on 13-1-21.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "ImageGridViewController.h"
#import "CommonHeader.h"
#import "MediaObject.h"
#import "FGalleryViewController.h"

@interface ImageGridViewController ()<UITableViewDataSource, UITableViewDelegate, FGalleryViewControllerDelegate>

@property (nonatomic, strong)UITableView *table;

@end

@implementation ImageGridViewController
@synthesize mediaObjectArray;
@synthesize table;
@synthesize groupName;

- (void)viewDidUnload
{
    [super viewDidUnload];
    table = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
    self.title = self.groupName;
    
    self.view.backgroundColor = [UIColor whiteColor];
    table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - NAVIGATION_BAR_HEIGHT)];
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.backgroundColor = [UIColor clearColor];
    table.delegate = self;
    table.dataSource = self;
    table.backgroundColor = [UIColor clearColor];
    table.showsVerticalScrollIndicator = NO;
    [self.view addSubview:table];
    
    [super showToolbar:NAVIGATION_BAR_HEIGHT];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ceil(self.mediaObjectArray.count / 3.0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        for (int i = 0; i < 3; i++) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
            imageView.tag = 1001 + i;
            imageView.frame = CGRectMake(80 * i + (i+1)*20, 20, 80, 80);
            [cell.contentView addSubview:imageView];
            
            UIButton *imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [imageBtn setFrame:imageView.frame];
            imageBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin| UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
            [imageBtn addTarget:self action:@selector(mediaImageClicked:)forControlEvents:UIControlEventTouchUpInside];
            imageBtn.tag = 2001 + i;
            [cell.contentView addSubview:imageBtn];
        }
    }
    int num = 3;
    if(self.mediaObjectArray.count < (indexPath.row+1) * 3){
        num = self.mediaObjectArray.count - indexPath.row * 3;
    }
    for(int i = 0; i < 3; i++){
        UIImageView *imageView  = (UIImageView *)[cell viewWithTag:1001 + i];
        UIButton *imageBtn  = (UIButton *)[cell viewWithTag:2001 + i];
        if(i < num){
            MediaObject *media = [self.mediaObjectArray objectAtIndex:indexPath.row * 3 + i];
            imageView.image = media.image;
        } else {
            imageView.image = nil;
            [imageBtn removeFromSuperview];
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)mediaImageClicked:(UIButton *)btn
{
    CGPoint point = btn.center;
    point = [table convertPoint:point fromView:btn.superview];
    NSIndexPath* indexPath = [table indexPathForRowAtPoint:point];
    int index = indexPath.row * 3 + btn.tag - 2001;
    if(index >= mediaObjectArray.count){
        return;
    }
    FGalleryViewController *localGallery = [[FGalleryViewController alloc] initWithPhotoSource:self];
    localGallery.startingIndex = index;
    localGallery.mediaObjectArray = mediaObjectArray;
    [self.navigationController pushViewController:localGallery animated:YES];
}

- (void)backButtonClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];    
}

- (void)homeButtonClicked
{
    [self dismissViewControllerAnimated:NO completion:nil];
    [super homeButtonClicked];
}

#pragma mark - FGalleryViewControllerDelegate Methods
- (int)numberOfPhotosForPhotoGallery:(FGalleryViewController *)gallery
{
    return mediaObjectArray.count;
}

- (FGalleryPhotoSourceType)photoGallery:(FGalleryViewController *)gallery sourceTypeForPhotoAtIndex:(NSUInteger)index
{
    return FGalleryPhotoSourceTypeLocal;
}

- (NSString*)photoGallery:(FGalleryViewController*)gallery filePathForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index {
    return [(MediaObject *)[mediaObjectArray objectAtIndex:index] mediaURL];
}

@end
