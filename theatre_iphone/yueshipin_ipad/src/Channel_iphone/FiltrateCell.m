//
//  FiltrateCell.m
//  theatreiphone
//
//  Created by Rong on 13-5-14.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "FiltrateCell.h"

@implementation FiltrateCell
@synthesize firstImageView = _firstImageView;
@synthesize secondImageView = _secondImageView;
@synthesize thirdImageView = _thirdImageView;
@synthesize firstLabel = _firstLabel;
@synthesize secondLabel = _secondLabel;
@synthesize thirdLabel = _thirdLabel;
@synthesize delagate = _delagate;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code        
        UIImageView *imageFrame1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_placeholder.png"]];
        imageFrame1.frame = CGRectMake(14, 2, 87, 118);
        [self addSubview:imageFrame1];
        
        _firstImageView = [[UIImageView alloc] initWithFrame:CGRectMake(17, 5, 81, 112)];
        _firstImageView.userInteractionEnabled = YES;
        UIButton *firstBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        firstBtn.backgroundColor = [UIColor clearColor];
        firstBtn.frame = CGRectMake(0, 0, 87, 118);
        firstBtn.tag = 1000;
        [firstBtn addTarget:self action:@selector(didTap:) forControlEvents:UIControlEventTouchUpInside];
        [_firstImageView addSubview:firstBtn];
        [self addSubview:_firstImageView];
        
        UIImageView *imageFrame2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_placeholder.png"]];
        imageFrame2.frame = CGRectMake(116, 2, 87, 118);
        [self addSubview:imageFrame2];
        _secondImageView = [[UIImageView alloc] initWithFrame:CGRectMake(119, 5, 81, 112)];
        _secondImageView.userInteractionEnabled = YES;
        UIButton *secondBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        secondBtn.backgroundColor = [UIColor clearColor];
        secondBtn.frame = CGRectMake(0, 0, 87, 118);
        secondBtn.tag = 1001;
        [secondBtn addTarget:self action:@selector(didTap:) forControlEvents:UIControlEventTouchUpInside];
        [_secondImageView addSubview:secondBtn];
        [self addSubview:_secondImageView];
        
        
        UIImageView *imageFrame3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_placeholder.png"]];
        imageFrame3.frame = CGRectMake(218, 2, 87, 118);
        [self addSubview:imageFrame3];
        _thirdImageView = [[UIImageView alloc] initWithFrame:CGRectMake(221, 5, 81, 112)];
        _thirdImageView.userInteractionEnabled = YES;
        UIButton *thirdBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        thirdBtn.backgroundColor = [UIColor clearColor];
        thirdBtn.frame = CGRectMake(0, 0, 87, 118);
        thirdBtn.tag = 1002;
        [thirdBtn addTarget:self action:@selector(didTap:) forControlEvents:UIControlEventTouchUpInside];
        [_thirdImageView addSubview:thirdBtn];
        [self addSubview:_thirdImageView];
        
        _firstLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 123, 87, 15)];
        _firstLabel.font = [UIFont systemFontOfSize:12];
        _firstLabel.textAlignment = NSTextAlignmentCenter;
        _firstLabel.backgroundColor = [UIColor clearColor];
        _firstLabel.textColor = [UIColor colorWithRed:88.0/255 green:88.0/255 blue:88.0/255 alpha:1];
        [self addSubview:_firstLabel];
        
        _secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(116, 123, 87, 15)];
        _secondLabel.font = [UIFont systemFontOfSize:12];
        _secondLabel.textAlignment = NSTextAlignmentCenter;
        _secondLabel.backgroundColor = [UIColor clearColor];
        _secondLabel.textColor = [UIColor colorWithRed:88.0/255 green:88.0/255 blue:88.0/255 alpha:1];
        [self addSubview:_secondLabel];
        
        _thirdLabel = [[UILabel alloc] initWithFrame:CGRectMake(218, 123, 87, 15)];
        _thirdLabel.font = [UIFont systemFontOfSize:12];
        _thirdLabel.textAlignment = NSTextAlignmentCenter;
        _thirdLabel.backgroundColor = [UIColor clearColor];
        _thirdLabel.textColor = [UIColor colorWithRed:88.0/255 green:88.0/255 blue:88.0/255 alpha:1];
        [self addSubview:_thirdLabel];
        
    }
    return self;
}

-(void)didTap:(UIButton *)btn {
    int index = btn.tag - 1000;
    [_delagate didSelectAtCell:self inPosition:index];

}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
