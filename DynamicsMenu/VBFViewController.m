//
//  VBFViewController.m
//  DynamicsMenu
//
//  Created by Victor Baro on 07/04/2014.
//  Copyright (c) 2014 Victor Baro. All rights reserved.
//

//Bear in mind I have only added 5 images to each submenu button. Add your own images 
#define kNumberOfItemsInFirstSubmenu 3
#define kNumberOfItemsInSecondSubmenu 5

#import "VBFViewController.h"

@interface VBFViewController () {
    BOOL _isSubmenuPresented;
}
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *mainMenuButtons;

@property (nonatomic, strong) NSMutableArray *firstSubMenuButtons;
@property (nonatomic, strong) NSMutableArray *secondSubMenuButtons;

//DYNAMICS
//this animator will take care of the main menu
@property (nonatomic, strong) UIDynamicAnimator *mainAnimator;


//this animator will take car of any submenu
@property (nonatomic, strong) UIDynamicAnimator *subAnimator;



@end

@implementation VBFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupMainMenu];
}

- (void) setupMainMenu {
    //Init different variables
    _isSubmenuPresented = NO;
    
    
    int i = 0;
    //Run through each mainmenu button
    for (UIButton *button in self.mainMenuButtons) {
        //Create a rounded shape (squared UIView)
        button.layer.cornerRadius = CGRectGetWidth(button.frame)/2;
        
        //Do additional stuff with main buttons here
        i += 1;
    }
    
    //Populate submenu arrays (max. 9)
    
    for (int j = 0; j < kNumberOfItemsInFirstSubmenu; j++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = 10 + j;
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%i",button.tag]]
                forState:UIControlStateNormal];

        //Init the buttons outside screen or hide them
        button.frame = CGRectMake(400, 0, 50.0, 50.0);
        
        [button addTarget:self
                   action:@selector(submenuButtonPressed:)
         forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        
        if (!self.firstSubMenuButtons) {
            self.firstSubMenuButtons = [[NSMutableArray alloc]initWithObjects:button, nil];
        } else {
            [self.firstSubMenuButtons addObject:button];
        }
    }
    
    for (int k = 0; k < kNumberOfItemsInSecondSubmenu; k++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = 20 + k;
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%i",button.tag]]
                forState:UIControlStateNormal];
        
        //Init the buttons outside screen or hide them
        button.frame = CGRectMake(400, 0, 50.0, 50.0);
        
        [button addTarget:self
                   action:@selector(submenuButtonPressed:)
         forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:button];
        
        if (!self.secondSubMenuButtons) {
            self.secondSubMenuButtons = [[NSMutableArray alloc]initWithObjects:button, nil];
        } else {
            [self.secondSubMenuButtons addObject:button];
        }
    }
    
    
    //Init animators
    self.mainAnimator = [[UIDynamicAnimator alloc]initWithReferenceView:self.view];
    self.subAnimator = [[UIDynamicAnimator alloc]initWithReferenceView:self.view];
    

}


- (IBAction)mainButtonPressed:(UIButton *)sender {
    _isSubmenuPresented ? [self dismissSubmenu:sender.tag] : [self presentSubmenuFromButton:sender];
}


- (void) presentSubmenuFromButton:(UIButton *)buttonPressed {
    _isSubmenuPresented = YES;
    
    if (buttonPressed.tag == 3) {
        //On my case, I want to present next VC if main button.tag == 3, otherwise present submenu
        
    } else {
        //Transition from presented main menu to presented submenu
        [self startTransitionFromButton:buttonPressed];
        //Different submenus based on buttonPressed
        switch (buttonPressed.tag) {
            case 1:
                [self presentSubmenuButtons:self.firstSubMenuButtons];
                break;
            case 2:
                [self presentSubmenuButtons:self.secondSubMenuButtons];
                break;
                
            default:
                break;
        }
    }
}

- (void) startTransitionFromButton:(UIButton *) buttonPressed {
    //Our animator controls the behaviours for MainMenu buttons. We want to make sure the buttons are not affected by any previous behavior
    [self.mainAnimator removeAllBehaviors];
    
    //Add gravity behavior to all of them, we want the gravity to point to the left side of the screen.
    UIGravityBehavior *mainGravity = [[UIGravityBehavior alloc]init];
    // Angle = 0 (positive X). Play with magnitude value
    [mainGravity setAngle:-M_PI magnitude:10];
    
    
    //We add collisionbehaviour to non-pressed buttons. Will stop them outside the screen, ready to push them back inside if needed
    UICollisionBehavior *outScreenStopper = [[UICollisionBehavior alloc]init];
    //Create vertical stopper for non-pressed mainMenu buttons. We want to keep them 'close' to push them into the view if needed
    [outScreenStopper addBoundaryWithIdentifier:@"verticalOffScreenStopper"
                                      fromPoint:CGPointMake(-150, 0)
                                        toPoint:CGPointMake(-150, CGRectGetHeight(self.view.frame))];
    
    //Create new collision behavior for buttonPressed
    UICollisionBehavior *buttonStop = [[UICollisionBehavior alloc]init];
    //We want to use reference view bounds (buttonPressed will colide to them)
    buttonStop.translatesReferenceBoundsIntoBoundary = YES;
    
    
    for (UIButton *button in self.mainMenuButtons) {
        if (button != buttonPressed) {
            [outScreenStopper addItem:button];
        } else {
            //Pressed button
            [buttonStop addItem:button];
        }
        //Add gravity to all buttons
        [mainGravity addItem:button];
    }
    

    //Instantaneous push behaviour against gravity for pressed button
    UIPushBehavior *pushButton = [[UIPushBehavior alloc]initWithItems:@[buttonPressed] mode:UIPushBehaviorModeInstantaneous];
    [pushButton setAngle:0 magnitude:5];
    
    
    //Add behaviors to animator
    [self.mainAnimator addBehavior:pushButton];
    [self.mainAnimator addBehavior:outScreenStopper];
    [self.mainAnimator addBehavior:mainGravity];
    [self.mainAnimator addBehavior:buttonStop];
}

- (void) presentSubmenuButtons: (NSArray *) buttonsArray {
    //Same as before, to start a clean new transition we don't want any button to be affected by previous behaviors
    [self.subAnimator removeAllBehaviors];

    int i=0;
    for (UIButton *button in buttonsArray) {
        //LOCATE BUTTONS
        float yPosition = [self calculateYPositionForNumberOfItems:[buttonsArray count] position:i];
        //locate button out of the screen (x axis). Last term (100 * i) will give a nicer effect by adding a bit of delay on each button
        float xPosition = CGRectGetWidth(self.view.frame) + CGRectGetWidth(button.frame) + (100 * i);
        button.center = CGPointMake(xPosition, yPosition);
        
        i += 1;
    }
    
    //Create new gravityB with all buttons in the array, leftside direction
    UIGravityBehavior *subGravity = [[UIGravityBehavior alloc]initWithItems:buttonsArray];
    subGravity.magnitude = 3;
    subGravity.angle = -M_PI;
    
    CGFloat buttonWidth = [(UIButton *)[buttonsArray lastObject] frame].size.width;
    CGFloat xValue = self.view.bounds.size.width/2 - (buttonWidth/2);
    
    //Create new collisionB including all buttons
    UICollisionBehavior *subCollision = [[UICollisionBehavior alloc]initWithItems:buttonsArray];
    //Create vertical stopper X-offseted to stop the buttons in the X-middle of screen
    [subCollision addBoundaryWithIdentifier:@"verticalStopper"
                                  fromPoint:CGPointMake(xValue, 0)
                                    toPoint:CGPointMake(xValue, CGRectGetHeight(self.view.frame))];
    
    
    
    [self.subAnimator addBehavior:subCollision];
    [self.subAnimator addBehavior:subGravity];
}

- (void) dismissSubmenu:(int)subMenu {
    _isSubmenuPresented = NO;
    
    [self.subAnimator removeAllBehaviors];
    
    
    NSArray *submenuArray;
    switch (subMenu) {
        case 1:
            submenuArray = [NSArray arrayWithArray:self.firstSubMenuButtons];
            break;
        case 2:
            submenuArray = [NSArray arrayWithArray:self.secondSubMenuButtons];
            break;
        default:
            break;
    }
    
    for (UIButton *button in submenuArray) {
        UIPushBehavior *push = [[UIPushBehavior alloc]initWithItems:@[button] mode:UIPushBehaviorModeInstantaneous];
        push.angle = (-0.7 * M_PI) + (arc4random()%25 / 10);
        push.magnitude = 1;
        [self.subAnimator addBehavior:push];
    }
    //Gravity is now pointing down
    UIGravityBehavior *subGravity = [[UIGravityBehavior alloc]initWithItems:submenuArray];
    subGravity.angle = 0.5 * M_PI;
    subGravity.magnitude = 5;
    [self.subAnimator addBehavior:subGravity];
    
    [self snapMainButtonsToStartPosition];
    
}


- (void) snapMainButtonsToStartPosition {
    int i = 0;
    for (UIButton *button in self.mainMenuButtons) {
        float yPostion = [self calculateYPositionForNumberOfItems:[self.mainMenuButtons count] position:i];
        CGPoint startPoint = CGPointMake(CGRectGetWidth(self.view.frame)/2, yPostion);
        UISnapBehavior *snap = [[UISnapBehavior alloc]initWithItem:button snapToPoint:startPoint];
        NSLog(@"Y:%f",yPostion);
        [self.subAnimator addBehavior:snap];
        i += 1;
    }
    UIDynamicItemBehavior *db = [[UIDynamicItemBehavior alloc]initWithItems:self.mainMenuButtons];
    db.resistance = 70;
    [self.subAnimator addBehavior:db];
}

- (float) calculateYPositionForNumberOfItems:(int)nItems position:(int)thePosition {
    int buttonNumber = nItems - thePosition;
    float yOffset = CGRectGetHeight(self.view.frame)/(nItems + 1);
    return CGRectGetHeight(self.view.frame) - (yOffset * buttonNumber);
}

#pragma -
#pragma Button callbacks

- (void) submenuButtonPressed:(UIButton *)aButton {
    //Do whatever needed
    NSLog(@"Pressed button with tag: %i",aButton.tag);
}

@end
