//
//  GridViewCellDemo.h
//  UFP
//
//  Created by liu yu on 7/23/12.
//  Copyright (c) 2012 Realcent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "UMUFPGridCell.h"
#import "UMUFPImageView.h"

@interface GridViewCellDemo : UMUFPGridCell
{
    UILabel *_titleLabel;
    UMUFPImageView *_imageView;    
}

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UMUFPImageView *imageView;

@end
