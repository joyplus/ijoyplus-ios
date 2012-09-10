//
//  FriendTabViewController
//  CustomTabBar
//
//  Created by joyplus1 on 12-9-7.
//
//
#import <QuartzCore/QuartzCore.h>
#import "FriendTabViewController.h"
#import "RecommandMovieViewController.h"
#import "FriendNewsViewController.h"
#import "UIGlossyButton.h"
#import "CMConstants.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "AnimationFactory.h"

#define BOTTOM_TAB_HEIGHT 44
@interface FriendTabViewController (){
    NSArray* tabBarItems;
    TextCustomTabBar* tabBar;
}
- (void)searchFriend;
- (void)addToolBar;
- (void)registerScreen;
- (void)loginScreen;
@end

@implementation FriendTabViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"app_name", nil);
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"search_friend", nil) style:UIBarButtonSystemItemSearch target:self action:@selector(searchFriend)];
    self.navigationItem.rightBarButtonItem = rightButton;
    RecommandMovieViewController *detailController1 = [[RecommandMovieViewController alloc] init];
    detailController1.view.backgroundColor = [UIColor whiteColor];
    
    FriendNewsViewController *detailController2 = [[FriendNewsViewController alloc] init];
    detailController2.view.backgroundColor = [UIColor whiteColor];
    
    tabBarItems = [NSArray arrayWithObjects:
                    [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"recommand_movie", nil), @"text", detailController1, @"viewController", nil],
                    [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"friend_news", nil), @"text", detailController2, @"viewController", nil],nil];
    
    // Use the TabBarGradient image to figure out the tab bar's height (22x2=44)
    UIImage* tabBarGradient = [UIImage imageNamed:@"TabBarGradient.png"];
    
    // Create a custom tab bar passing in the number of items, the size of each item and setting ourself as the delegate
    tabBar = [[TextCustomTabBar alloc] initWithItemCount:tabBarItems.count itemSize:CGSizeMake(self.view.frame.size.width/tabBarItems.count, tabBarGradient.size.height*1.5) tag:111 delegate:self];
    
    // Place the tab bar at the bottom of our view
    tabBar.frame = CGRectMake(0,1,self.view.frame.size.width, tabBarGradient.size.height*1.5);
    [self.view addSubview:tabBar];
    
    // Select the first tab
    [tabBar selectItemAtIndex:0];
    [self touchDownAtItemAtIndex:0];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if(!appDelegate.userLoggedIn){
        [self addToolBar];
    }
}

- (void)searchFriend
{
    
}

- (void)addToolBar
{
    UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - BOTTOM_TAB_HEIGHT, self.view.frame.size.width, BOTTOM_TAB_HEIGHT)];
    UIGlossyButton *registerBtn = [[UIGlossyButton alloc] initWithFrame:CGRectMake(2, 2, self.view.frame.size.width/2-1, BOTTOM_TAB_HEIGHT-3)];
    [registerBtn setActionSheetButtonWithColor: CMConstants.greyColor];
    registerBtn.buttonBorderWidth = 0;
    [registerBtn setTitle: NSLocalizedString(@"register", nil) forState:UIControlStateNormal];
    registerBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|
    UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [registerBtn addTarget:self action:@selector(registerScreen) forControlEvents:UIControlEventTouchUpInside];
    [toolBar addSubview:registerBtn];
    
    UIGlossyButton *loginBtn = [[UIGlossyButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 + 2, 2, self.view.frame.size.width/2 - 4, BOTTOM_TAB_HEIGHT-3)];
    [loginBtn setActionSheetButtonWithColor: CMConstants.greyColor];
    loginBtn.buttonBorderWidth = 0;
    [loginBtn setTitle: NSLocalizedString(@"login", nil) forState:UIControlStateNormal];
    loginBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|
    UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [loginBtn addTarget:self action:@selector(loginScreen) forControlEvents:UIControlEventTouchUpInside];
    [toolBar addSubview:loginBtn];
    
    [self.view addSubview:toolBar];
}

- (void)loginScreen
{
    LoginViewController *viewController = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:viewController];
    [self.navigationController presentViewController:navController animated:YES completion:nil];   
}


- (void)registerScreen
{
    
}

#pragma mark -
#pragma mark CustomTabBarDelegate

- (UIImage*) imageFor:(TextCustomTabBar*)tabBar atIndex:(NSUInteger)itemIndex
{
    return nil;
}

- (UILabel*) textFor:(TextCustomTabBar*)tabBar atIndex:(NSUInteger)itemIndex
{
    NSDictionary* data = [tabBarItems objectAtIndex:itemIndex];
    UILabel *title = [[UILabel alloc]init];
    title.text = [data valueForKey:@"text"];
    title.font = [UIFont boldSystemFontOfSize:12];
    title.textColor = [UIColor whiteColor];
    [title sizeToFit];
    return title;
}

- (UIImage*) backgroundImage
{
    // The tab bar's width is the same as our width
    CGFloat width = self.view.frame.size.width;
    // Get the image that will form the top of the background
    UIImage* topImage = [UIImage imageNamed:@"TabBarGradient.png"];
    
    // Create a new image context
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, topImage.size.height*1.5), NO, 0.0);
    
    // Create a stretchable image for the top of the background and draw it
    UIImage* stretchedTopImage = [topImage stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    [stretchedTopImage drawInRect:CGRectMake(0, 0, width, topImage.size.height)];
    
    // Draw a solid black color for the bottom of the background
    [[UIColor blackColor] set];
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, topImage.size.height, width, topImage.size.height));
    
    // Generate a new image
    UIImage* resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

// This is the blue background shown for selected tab bar items
- (UIImage*) selectedItemBackgroundImage
{
    return [UIImage imageNamed:@"TabBarItemSelectedBackground.png"];
}

// This is the glow image shown at the bottom of a tab bar to indicate there are new items
- (UIImage*) glowImage
{
    UIImage* tabBarGlow = [UIImage imageNamed:@"TabBarGlow.png"];
    
    // Create a new image using the TabBarGlow image but offset 4 pixels down
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(tabBarGlow.size.width, tabBarGlow.size.height-4.0), NO, 0.0);
    
    // Draw the image
    [tabBarGlow drawAtPoint:CGPointZero];
    
    // Generate a new image
    UIImage* resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

// This is the embossed-like image shown around a selected tab bar item
- (UIImage*) selectedItemImage
{
    // Use the TabBarGradient image to figure out the tab bar's height (22x2=44)
    UIImage* tabBarGradient = [UIImage imageNamed:@"TabBarGradient.png"];
    CGSize tabBarItemSize = CGSizeMake(self.view.frame.size.width/tabBarItems.count, tabBarGradient.size.height*2);
    UIGraphicsBeginImageContextWithOptions(tabBarItemSize, NO, 0.0);
    
    // Create a stretchable image using the TabBarSelection image but offset 4 pixels down
    [[[UIImage imageNamed:@"TabBarSelection.png"] stretchableImageWithLeftCapWidth:4.0 topCapHeight:0] drawInRect:CGRectMake(0, 4.0, tabBarItemSize.width, tabBarItemSize.height-4.0)];
    
    // Generate a new image
    UIImage* selectedItemImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return selectedItemImage;
}

- (UIImage*) tabBarArrowImage
{
//    return [UIImage imageNamed:@"TabBarNipple.png"];
    return nil;
}

- (void) touchDownAtItemAtIndex:(NSUInteger)itemIndex
{
    // Remove the current view controller's view
    UIView* currentView = [self.view viewWithTag:911];
    [currentView removeFromSuperview];
    
    // Get the right view controller
    NSDictionary* data = [tabBarItems objectAtIndex:itemIndex];
    UIViewController* viewController = [data objectForKey:@"viewController"];
    
    // Use the TabBarGradient image to figure out the tab bar's height (22x2=44)
    UIImage* tabBarGradient = [UIImage imageNamed:@"TabBarGradient.png"];
    
    // Set the view controller's frame to account for the tab bar
    viewController.view.frame = CGRectMake(0,tabBar.frame.size.height,self.view.bounds.size.width, self.view.bounds.size.height-(tabBarGradient.size.height*2));
    
    // Se the tag so we can find it later
    viewController.view.tag = 911;
    
    // Add the new view controller's view
    [self.view insertSubview:viewController.view belowSubview:tabBar];
    
    // In 1 second glow the selected tab
    [NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(addGlowTimerFireMethod:) userInfo:[NSNumber numberWithInteger:itemIndex] repeats:NO];
    
}

- (void)addGlowTimerFireMethod:(NSTimer*)theTimer
{
    // Remove the glow from all tab bar items
    for (NSUInteger i = 0 ; i < tabBarItems.count ; i++)
    {
        [tabBar removeGlowAtIndex:i];
    }
    
    // Then add it to this tab bar item
    [tabBar glowItemAtIndex:[[theTimer userInfo] integerValue]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // Let the tab bar that we're about to rotate
    [tabBar willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    // Adjust the current view in prepartion for the new orientation
    UIView* currentView = [self.view viewWithTag:911];
    UIImage* tabBarGradient = [UIImage imageNamed:@"TabBarGradient.png"];
    
    CGFloat width = 0, height = 0;
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        width = self.view.window.frame.size.width;
        height = self.view.window.frame.size.height;
    }
    else
    {
        width = self.view.window.frame.size.height;
        height = self.view.window.frame.size.width;
    }
    
    currentView.frame = CGRectMake(0,0,width, height-(tabBarGradient.size.height*2));
}

@end
