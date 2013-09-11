//
//  DisplayingImageHandler.m
//  yuexiangjia
//
//  Created by joyplus1 on 13-1-28.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "DisplayingImageHandler.h"
#import "CommonHeader.h"
#import "MediaObject.h"

@interface DisplayingImageHandler ()

@property (nonatomic, strong) UIImageView *displayingImage;

@end

@implementation DisplayingImageHandler
@synthesize displayingImage;

//============== Image Part Start ================

- (void)removeImageContainer
{
    UIView *homeView = [[AppDelegate instance].rootViewController.view viewWithTag:HOME_VIEW_TAG];
    UIView *container = [homeView viewWithTag:HOME_IMAGE_CONTAINER_TAG];
    if (container) {
        [container removeFromSuperview];
        container = nil;
    }
}

- (void)showImageContainer
{
    UIView *homeView = [[AppDelegate instance].rootViewController.view viewWithTag:HOME_VIEW_TAG];
    [self removeImageContainer];
    NSArray *imageObjectArray = [AppDelegate instance].imageObjectArray;
    if (imageObjectArray.count > 0) {
        CGRect bounds = [UIScreen mainScreen].bounds;
        UIView *container = [[UIView alloc]initWithFrame:CGRectMake(14, bounds.size.height - 120, GRID_VIEW_WIDTH - 7, 97)];
        container.tag = HOME_VIDEO_CONTAINER_TAG;
        container.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        [homeView addSubview:container];
        
        UIButton *prevBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        prevBtn.frame = CGRectMake(0, 0, 21, 27);
        prevBtn.center = CGPointMake(25, container.frame.size.height/2);
        [prevBtn setTintColor:[UIColor blackColor]];
        [prevBtn setBackgroundImage:[UIImage imageNamed:@"left_btn"] forState:UIControlStateNormal];
        [prevBtn setBackgroundImage:[UIImage imageNamed:@"left_btn_pressed"] forState:UIControlStateHighlighted];
        [prevBtn addTarget:self action:@selector(prevImageBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [container addSubview:prevBtn];
        
        UIImageView *placeholderImage = [[UIImageView alloc]initWithFrame:CGRectMake(63, 0, container.frame.size.height, container.frame.size.height)];
        placeholderImage.image = [UIImage imageNamed:@"pic_bg_single"];
        [container addSubview:placeholderImage];
        
        displayingImage = [[UIImageView alloc]initWithFrame:CGRectMake(66, 4, 90, 89)];
        [self displayImage];
        [container addSubview:displayingImage];
        
        UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        nextBtn.frame = CGRectMake(0, 0, 21, 27);
        nextBtn.center = CGPointMake(190, container.frame.size.height/2);
        [nextBtn setBackgroundImage:[UIImage imageNamed:@"right_btn"] forState:UIControlStateNormal];
        [nextBtn setBackgroundImage:[UIImage imageNamed:@"right_btn_pressed"] forState:UIControlStateHighlighted];
        [nextBtn addTarget:self action:@selector(nextImageBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [container addSubview:nextBtn];
    }
}

- (void)prevImageBtnClicked
{
    [AppDelegate instance].displayingImageIndex--;
    [self displayImage];
}

- (void)nextImageBtnClicked
{
    [AppDelegate instance].displayingImageIndex++;
    [self displayImage];
}

- (void) displayImage
{
    [self validateDisplayingImageIndex];
    NSArray *imageObjectArray = [AppDelegate instance].imageObjectArray;
    if ([AppDelegate instance].displayingImageIndex >= 0 && [AppDelegate instance].displayingImageIndex < imageObjectArray.count) {
        MediaObject *imageObject = [imageObjectArray objectAtIndex:[AppDelegate instance].displayingImageIndex];
        displayingImage.image = imageObject.image;
    }
}

- (void)validateDisplayingImageIndex
{
    if ([AppDelegate instance].imageObjectArray.count > 0) {
        if ([AppDelegate instance].displayingImageIndex <= 0) {
            [AppDelegate instance].displayingImageIndex = 0;
        } else if([AppDelegate instance].displayingImageIndex >= [AppDelegate instance].imageObjectArray.count -1){
            [AppDelegate instance].displayingImageIndex = [AppDelegate instance].imageObjectArray.count - 1;
        } else {
            // do nothing
        }
    } else {
        [AppDelegate instance].displayingImageIndex = 0;
    }
}

//============== Image Part End ================
@end
