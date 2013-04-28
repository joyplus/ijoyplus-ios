//
//  SearchResultsViewCell.m
//  yueshipin
//
//  Created by 08 on 13-1-5.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "SearchResultsViewCell.h"

@implementation SearchResultsViewCell
@synthesize imageview = imageview_;
@synthesize label = label_;
@synthesize actors = actors_;
@synthesize area = area_;
@synthesize type = type_;
@synthesize addImageView = addImageView_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UIImageView *frame = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_placeholder.png"]];
        frame.frame = CGRectMake(13, 4, 62, 90);
        frame.backgroundColor = [UIColor clearColor];
        [self addSubview:frame];
        
        self.imageview = [[UIImageView alloc] initWithFrame:CGRectMake(15, 7, 57, 85)];
        [self addSubview:self.imageview];
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(82, 9, 170, 14)];
        self.label.textColor = [UIColor colorWithRed:110.0/255 green:110.0/255 blue:110.0/255 alpha:1.0];
        self.label.font = [UIFont systemFontOfSize:15];
        self.label.backgroundColor = [UIColor clearColor];
        [self addSubview:self.label];
        
        actors_ = [[UILabel alloc] initWithFrame:CGRectMake(82, 32, 140, 12)];
        actors_.font = [UIFont systemFontOfSize:12];
        actors_.textColor = [UIColor grayColor];
        actors_.backgroundColor = [UIColor clearColor];
        area_ = [[UILabel alloc] initWithFrame:CGRectMake(82, 48, 140, 12)];
        area_.font = [UIFont systemFontOfSize:12];
        area_.textColor = [UIColor grayColor];
        area_.backgroundColor = [UIColor clearColor];
        
        type_ = [[UILabel alloc] initWithFrame:CGRectMake(82, 64, 140, 12)];
        type_.font = [UIFont systemFontOfSize:12];
        type_.textColor = [UIColor grayColor];
        type_.backgroundColor = [UIColor clearColor];
        [self addSubview:actors_];
        [self addSubview:area_];
        [self addSubview:type_];
        
        addImageView_ = [[UIImageView alloc] initWithFrame:CGRectMake(270, 46, 19, 19)];
        addImageView_.backgroundColor = [UIColor clearColor];
        [self addSubview:addImageView_];
        
        UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab2_detailed_common_writing4_fenge.png"]];
        line.frame = CGRectMake(0, 94, 320, 1);
        [self addSubview:line];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
