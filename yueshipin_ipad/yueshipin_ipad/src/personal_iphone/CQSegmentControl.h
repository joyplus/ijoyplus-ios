
#import <UIKit/UIKit.h>

typedef enum
{
	NormalSegmented,
	TitleAndImageSegmented,
}CQSegmentedControlType;

/*
 *Note : 只有在 segmentedControlStyle 为 UISegmentedControlStylePlain/UISegmentedControlStyleBordered的时候，这个地定义的才有效;
 */
@interface CQSegmentControl : UISegmentedControl {
	
	NSMutableArray *items_;			//如果type为NormalSegmented的时候，items表示标题或者图片, 如果type为TitleAndImageSegmented的时候，items表示标题;
	
	NSMutableArray *normalImageItems_;		//只有样式为TitleAndImageSegmented的时候有效
	
	NSMutableArray *highlightImageItems_;		//只有样式为TitleAndImageSegmented的时候有效
	
	UIFont  *font_;								//标题的字体
	UIColor *selectedItemColor_;					//选中颜色，如果样式为NormalSegmented的时候 无论是图片还是标题都会变成设定颜色，如果样式为TitleAndImageSegmented就只有标题变色;
	UIColor *unselectedItemColor_;				//未选中颜色，如果样式为NormalSegmented的时候 无论是图片还是标题都会变成设定颜色，如果样式为TitleAndImageSegmented就只有标题变色;
	
	CQSegmentedControlType segmentedType_;
	
	BOOL    canCustom;
}

@property (nonatomic, assign) CQSegmentedControlType segmentedType;

@property (nonatomic, strong) UIFont  *font;

@property (nonatomic, strong) UIColor *selectedItemColor;

@property (nonatomic, strong) UIColor *unselectedItemColor;

@property (nonatomic, strong) NSMutableArray *items;

@property (nonatomic, strong) NSMutableArray *normalImageItems;

@property (nonatomic, strong) NSMutableArray *highlightImageItems;

- (id)initWithItemsAndStype:(NSArray *)array stype:(CQSegmentedControlType)type;

@end
