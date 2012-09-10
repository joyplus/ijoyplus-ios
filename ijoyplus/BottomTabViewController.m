#import "BottomTabViewController.h"
#import "PopularTabViewController.h"
#import "UIImageView+WebCache.h"
#import "FriendTabViewController.h"
#import "ListTabViewController.h"
#import "MyselfViewController.h"

#define NUMBER_OF_COLUMNS 3
#define TOP_TAB_HEIGHT 40
#define COLUMN_GAP_WIDTH 10
#define SELECTED_VIEW_CONTROLLER_TAG 98456345

@interface BottomTabViewController(){
    CustomTabBar* tabBar;
    NSArray* tabBarItems;
}
- (void)initTabs;
- (UINavigationController *)addNavigationBar:(UIViewController *)viewController;
@end

@implementation BottomTabViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"app_name", nil);
    [self.navigationItem setHidesBackButton:YES];
    [self.view setBackgroundColor:[UIColor whiteColor]];

    [self initTabs];
}

- (void)initTabs
{
    // Set up some fake view controllers each with a different background color so we can visually see the controllers getting swapped around
    PopularTabViewController *detailController1 = [[PopularTabViewController alloc] init];
    detailController1.view.backgroundColor = [UIColor clearColor];
    
    FriendTabViewController *detailController2 = [[FriendTabViewController alloc] init];
    detailController2.view.backgroundColor = [UIColor clearColor];
    
    ListTabViewController *detailController3 = [[ListTabViewController alloc] init];
    detailController3.view.backgroundColor = [UIColor clearColor];
    
    MyselfViewController *detailController4 = [[MyselfViewController alloc]initWithNibName:@"MyselfViewController" bundle:nil];
    detailController4.view.backgroundColor = [UIColor clearColor];
    
    tabBarItems = [NSArray arrayWithObjects:
                   [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"popular", nil), @"text", @"chat.png", @"image", [self addNavigationBar:detailController1], @"viewController", nil],
                    [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"friend", nil), @"text", @"compose-at.png", @"image", [self addNavigationBar:detailController2], @"viewController", nil],
                    [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"list", nil), @"text", @"messages.png", @"image", [self addNavigationBar:detailController3], @"viewController", nil],
                    [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"myself", nil), @"text", @"magnifying-glass.png", @"image", [self addNavigationBar:detailController4], @"viewController", nil], nil];
    // Use the TabBarGradient image to figure out the tab bar's height (22x2=44)
    UIImage* tabBarGradient = [UIImage imageNamed:@"TabBarGradient.png"];
    
    // Create a custom tab bar passing in the number of items, the size of each item and setting ourself as the delegate
    tabBar = [[CustomTabBar alloc] initWithItemCount:tabBarItems.count itemSize:CGSizeMake(self.view.frame.size.width/tabBarItems.count, tabBarGradient.size.height*2) tag:0 delegate:self];
    
    // Place the tab bar at the bottom of our view
    tabBar.frame = CGRectMake(0,self.view.frame.size.height-(tabBarGradient.size.height*2),self.view.frame.size.width, tabBarGradient.size.height*2);
    [self.view addSubview:tabBar];
    
    // Select the first tab
    [tabBar selectItemAtIndex:0];
    [self touchDownAtItemAtIndex:0];
    
}

- (UINavigationController *)addNavigationBar:(UIViewController *)viewController
{
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:viewController];
    return navController;
}

#pragma mark -
#pragma mark CustomTabBarDelegate

- (UIImage*) imageFor:(CustomTabBar*)tabBar atIndex:(NSUInteger)itemIndex
{
    // Get the right data
    NSDictionary* data = [tabBarItems objectAtIndex:itemIndex];
    // Return the image for this tab bar item
    return [UIImage imageNamed:[data objectForKey:@"image"]];
}

- (UILabel*) textFor:(TextCustomTabBar*)tabBar atIndex:(NSUInteger)itemIndex
{
    NSDictionary* data = [tabBarItems objectAtIndex:itemIndex];
    UILabel *title = [[UILabel alloc]init];
    title.text = [data valueForKey:@"text"];
    title.font = [UIFont boldSystemFontOfSize:12];
    title.textColor = [UIColor whiteColor];
    return title;
}

- (UIImage*) backgroundImage
{
    // The tab bar's width is the same as our width
    CGFloat width = self.view.frame.size.width;
    // Get the image that will form the top of the background
    UIImage* topImage = [UIImage imageNamed:@"TabBarGradient.png"];
    
    // Create a new image context
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, topImage.size.height*2), NO, 0.0);
    
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
    return [UIImage imageNamed:@"TabBarNipple.png"];
}

- (void) touchDownAtItemAtIndex:(NSUInteger)itemIndex
{
    // Remove the current view controller's view
    UIView* currentView = [self.view viewWithTag:SELECTED_VIEW_CONTROLLER_TAG];
    [currentView removeFromSuperview];
    
    // Get the right view controller
    NSDictionary* data = [tabBarItems objectAtIndex:itemIndex];
    UIViewController* viewController = [data objectForKey:@"viewController"];
    
    // Use the TabBarGradient image to figure out the tab bar's height (22x2=44)
    UIImage* tabBarGradient = [UIImage imageNamed:@"TabBarGradient.png"];
    
    // Set the view controller's frame to account for the tab bar
    viewController.view.frame = CGRectMake(0,0,self.view.bounds.size.width, self.view.bounds.size.height-(tabBarGradient.size.height*2));
    
    // Se the tag so we can find it later
    viewController.view.tag = SELECTED_VIEW_CONTROLLER_TAG;
    
    // Add the new view controller's view
    [self.view insertSubview:viewController.view belowSubview:tabBar];
    
    // In 1 second glow the selected tab
    //  [NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(addGlowTimerFireMethod:) userInfo:[NSNumber numberWithInteger:itemIndex] repeats:NO];
    
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
    UIView* currentView = [self.view viewWithTag:SELECTED_VIEW_CONTROLLER_TAG];
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
