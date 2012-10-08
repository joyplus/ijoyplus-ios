@protocol IntroductionViewDelegate;
@interface IntroductionView : UIView
{
    UITextView *_textView;
    NSString *_title;
}

@property (nonatomic, assign) id<IntroductionViewDelegate> delegate;

// The options is a NSArray, contain some NSDictionaries, the NSDictionary contain 2 keys, one is "img", another is "text".
- (id)initWithTitle:(NSString *)aTitle content:(NSString *)content;
// If animated is YES, PopListView will be appeared with FadeIn effect.
- (void)showInView:(UIView *)aView animated:(BOOL)animated;
@end

@protocol IntroductionViewDelegate <NSObject>
- (void)leveyPopListViewDidCancel;
@end