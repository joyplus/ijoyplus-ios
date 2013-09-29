//
//  YueSouViewCell.m
//  yueshipin
//
//  Created by huokun on 13-9-9.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "YueSouViewCell.h"

@interface YueSouViewCell ()
@property (nonatomic, strong) UIImageView   * firImgView;
@property (nonatomic, strong) UIImageView   * secImgView;
@property (nonatomic, strong) UILabel       * firName;
@property (nonatomic, strong) UILabel       * secName;
@end

@implementation YueSouViewCell
@synthesize delegate;
@synthesize firImgView,secImgView,firName,secName;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
//        firImgView = [[UIImageView alloc] initWithImage:nil];
//        firImgView.frame = CGRectMake(0, 3, 145, 54);
//        secImgView = [[UIImageView alloc] initWithImage:nil];
//        secImgView.frame = CGRectMake(155, 3, 145, 54);
//        [self.contentView addSubview:firImgView];
//        [self.contentView addSubview:secImgView];
//        
//        firName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 145, 30)];
//        firName.center = firImgView.center;
//        firName.textAlignment = UITextAlignmentCenter;
//        firName.textColor = [UIColor blackColor];
//        firName.font = [UIFont systemFontOfSize:12];
//        firName.backgroundColor = [UIColor clearColor];
//        [self.contentView addSubview:firName];
//        
//        secName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 145, 30)];
//        secName.center = secImgView.center;
//        secName.textAlignment = UITextAlignmentCenter;
//        secName.textColor = [UIColor blackColor];
//        secName.font = [UIFont systemFontOfSize:12];
//        secName.backgroundColor = [UIColor clearColor];
//        [self.contentView addSubview:secName];
        

        
        UIButton * firstBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIButton * secondBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        firstBtn.frame = CGRectMake(0, 3, 145, 54);
        secondBtn.frame = CGRectMake(155, 3, 145, 54);
        
        [firstBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [secondBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [firstBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [secondBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        firstBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        secondBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        firstBtn.titleLabel.textAlignment = UITextAlignmentCenter;
        secondBtn.titleLabel.textAlignment = UITextAlignmentCenter;
        firstBtn.backgroundColor = [UIColor clearColor];
        secondBtn.backgroundColor = [UIColor clearColor];
        [firstBtn addTarget:self
                     action:@selector(buttonClicked:)
           forControlEvents:UIControlEventTouchUpInside];
        [secondBtn addTarget:self
                     action:@selector(buttonClicked:)
           forControlEvents:UIControlEventTouchUpInside];
        
        firstBtn.tag = 10;
        secondBtn.tag = 11;
        [self.contentView addSubview:firstBtn];
        [self.contentView addSubview:secondBtn];
        
        
        UILabel * firNum = [[UILabel alloc] initWithFrame:CGRectMake(125, 4, 20, 20)];
        UILabel * secNum = [[UILabel alloc] initWithFrame:CGRectMake(280, 4, 20, 20)];
        firNum.backgroundColor = [UIColor clearColor];
        secNum.backgroundColor = [UIColor clearColor];
        firNum.textColor = [UIColor whiteColor];
        secNum.textColor = [UIColor whiteColor];
        firNum.textAlignment = UITextAlignmentCenter;
        secNum.textAlignment = UITextAlignmentCenter;
        firNum.font = [UIFont systemFontOfSize:12];
        secNum.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:firNum];
        [self.contentView addSubview:secNum];
        firNum.tag = 100;
        secNum.tag = 101;
        
        
    }
    return self;
}

- (void)setFirstHidden:(BOOL)isHidden
{
    [self.contentView viewWithTag:100].hidden = isHidden;
    [self.contentView viewWithTag:10].hidden = isHidden;
}

- (void)setSecondHidden:(BOOL)isHidden
{
    [self.contentView viewWithTag:101].hidden = isHidden;
    [self.contentView viewWithTag:11].hidden = isHidden;
}

- (NSString *)imageNameWithNum:(NSInteger)num
{
    NSString * imgName = nil;
    switch (num) {
        case 1:
        {
            imgName = @"yuesou_1";
        }
            break;
        case 2:
        {
            imgName = @"yuesou_2";
        }
            break;
        case 3:
        {
            imgName = @"yuesou_3";
        }
            break;
        default:
        {
            imgName = @"yuesou_4";
        }
            break;
    }
    return imgName;
}

- (void)buttonClicked:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    if (delegate && [delegate respondsToSelector:@selector(searchWithKeyWord:)])
    {
        [delegate searchWithKeyWord:btn.currentTitle];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setViewInfo:(NSDictionary *)info
{
    if (nil == [info objectForKey:KEY_SECOND_NUMBER])
    {
        [self setSecondHidden:YES];
    }
    else
    {
        [self setSecondHidden:NO];
    }
    if (nil == [info objectForKey:KEY_FIRST_NUMBER])
    {
        [self setFirstHidden:YES];
    }
    else
    {
        [self setFirstHidden:NO];
    }
    
    UILabel * firstNum = (UILabel *)[self.contentView viewWithTag:100];
    UILabel * secondNum = (UILabel *)[self.contentView viewWithTag:101];
    NSString * first = [info objectForKey:KEY_FIRST_NUMBER];
    NSString * second = [info objectForKey:KEY_SECOND_NUMBER];
    firstNum.text = first;
    secondNum.text = second;
    
    UIButton * firstBtn = (UIButton *)[self.contentView viewWithTag:10];
    UIButton * secondBtn = (UIButton *)[self.contentView viewWithTag:11];
    
    [firstBtn setTitle:[info objectForKey:KEY_FIRST_NAME] forState:UIControlStateNormal];
    [secondBtn setTitle:[info objectForKey:KEY_SECOND_NAME] forState:UIControlStateNormal];
    
    [firstBtn setBackgroundImage:[UIImage imageNamed:[self imageNameWithNum:[first intValue]]] forState:UIControlStateNormal];
    [secondBtn setBackgroundImage:[UIImage imageNamed:[self imageNameWithNum:[second intValue]]] forState:UIControlStateNormal];
    
//    [self setImage:firImgView withNum:[first intValue]];
//    [self setImage:secImgView withNum:[second intValue]];
//    
//    firName.text = [info objectForKey:KEY_FIRST_NAME];
//    secName.text = [info objectForKey:KEY_SECOND_NAME];
}

@end
