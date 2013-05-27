//
//  SegmentControlView.h
//  theatreiphone
//
//  Created by Rong on 13-5-13.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
enum{
    TYPE_MOVIE = 1,
    TYPE_TV = 2,
    TYPE_COMIC = 131,
    TYPE_SHOW = 3
};

@protocol SegmentDelegate <NSObject>
-(void)segmentDidSelectedLabelStr:(NSString *)str withKey:(NSString *)key;
-(void)moreSelectWithType:(int)type withCurrentKey:(NSString *)currentKey;
-(void)didTapOnSegmentView;
@end


@interface SegmentControlView : UIView<UIGestureRecognizerDelegate>{
    int videoType_;
@private
    NSString *PreKey_;
}
@property (nonatomic, weak) id <SegmentDelegate> delegate;
@property (nonatomic , assign) int type;
@property (nonatomic, strong) UISegmentedControl *seg;
@property (nonatomic, strong) NSArray *movieLabelArr;
@property (nonatomic, strong) NSArray *tvLabelArr;
@property (nonatomic, strong) NSArray *comicLabelArr;
@property (nonatomic, strong) NSArray *showLabelArr;
@property (nonatomic, strong) UIView *segControlBg;
-(void)setSegmentControl:(int)type;
+(NSString *)getKeyByString:(NSString *)str;
@end



@protocol FiltrateViewDelegate <NSObject>

-(void)filtrateWithVideoType:(int)type parameters:(NSMutableDictionary *)parameters;

@end


@interface FiltrateView : UIView{
    int _videoType;
}
@property (nonatomic, weak) id <FiltrateViewDelegate> delegate;
@property (nonatomic, strong)NSMutableDictionary *parametersDic;
@property (nonatomic, strong)NSString *currentKey;
-(void)setViewWithType:(int)type;
-(void)setFiltrateViewCurrentKey:(NSString *)currentKey;
@end
