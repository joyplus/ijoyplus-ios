//
//  FilmReviewViewCell.h
//  yueshipin
//
//  Created by 08 on 13-3-29.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FilmReviewViewCellDelegate;

@interface FilmReviewViewCell : UIView
{
    UILabel     *_labTitle;
    UILabel     *_labContent;
    
    id          _delegate;
}

@property (nonatomic, strong)   UILabel     *labTitle;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title content:(NSString *)content;
- (void)setDelegate:(id)delegate;
- (void)refreshView:(NSString *)title content:(NSString *)content;

@end


@protocol FilmReviewViewCellDelegate <NSObject>

- (void)filmReviewTaped:(NSString *)title content:(NSString *)content;

@end