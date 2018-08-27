//
//  ViewController.m
//  TYPasterDemo
//
//  Created by 应俊康 on 2018/8/5.
//  Copyright © 2018年 应俊康. All rights reserved.
//

#import "ViewController.h"
#import "TYPasterView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *enableControlsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *enableDeleteControlSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *enableScaleControlSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *enableRotateControlSwitch;


@property (weak, nonatomic) IBOutlet UISwitch *enableGestureSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *enableDragSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *enableScaleSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *enableRotateSwitch;

@property (weak, nonatomic) IBOutlet UITextField *pasterLabel;
@end

@implementation ViewController

- (IBAction)addImagePaster:(id)sender {
    int i = arc4random() % 6;
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%d",i]];
    TYPasterView * view = [[TYPasterManager sharedInstance] pasterWithImage:image];
    view.frame = (CGRect){CGPointZero,CGSizeMake(150, 100)};
    view.center = CGPointMake(200, 200);
    [self setupPasterView:view];
    [self.view addSubview:view];
}

- (IBAction)addTextPaster:(id)sender {
    NSString *text = self.pasterLabel.text;
    TYPasterView * view = [[TYPasterManager sharedInstance] pasterWithText:text];
    view.frame = (CGRect){CGPointZero,CGSizeMake(150, 100)};
    view.center = CGPointMake(200, 200);
    [self setupPasterView:view];
    [self.view addSubview:view];
}

- (IBAction)addCustomPaster:(id)sender {
    UISwitch *switchView = [[UISwitch alloc]init];
    TYPasterView * view = [[TYPasterManager sharedInstance] pasterWithCustomeView:switchView];
    view.frame = (CGRect){CGPointZero,CGSizeMake(150, 100)};
    view.center = CGPointMake(200, 200);
    [self setupPasterView:view];
    [self.view addSubview:view];
}

- (IBAction)clearAllPaster:(id)sender {
    [[TYPasterManager sharedInstance] clearAll];
}

- (IBAction)onEnableControlsChanged:(UISwitch *)sender {
    if(!sender.isOn) {
        self.enableDeleteControlSwitch.on = NO;
        self.enableScaleControlSwitch.on = NO;
        self.enableRotateControlSwitch.on = NO;
    }
}

- (IBAction)onEnableDeleteControlChanged:(UISwitch *)sender {
    if(sender.isOn) {
        self.enableControlsSwitch.on = YES;
    }
}

- (IBAction)onEnableScaleControlChanged:(UISwitch *)sender {
    if(sender.isOn) {
        self.enableControlsSwitch.on = YES;
    }
}

- (IBAction)onEnableRotateControlChanged:(UISwitch *)sender {
    if(sender.isOn) {
        self.enableControlsSwitch.on = YES;
    }
}

- (IBAction)onEnableGestureChanged:(UISwitch *)sender {
    if(!sender.isOn) {
        self.enableDragSwitch.on = NO;
        self.enableScaleSwitch.on = NO;
        self.enableRotateSwitch.on = NO;
    }
}

- (IBAction)onEnableDragChanged:(UISwitch *)sender {
    if(sender.isOn) {
        self.enableGestureSwitch.on = YES;
    }
}

- (IBAction)onEnableScaleChanged:(UISwitch *)sender {
    if(sender.isOn) {
        self.enableGestureSwitch.on = YES;
    }
}

- (IBAction)onEnableRotateChanged:(UISwitch *)sender {
    if(sender.isOn) {
        self.enableGestureSwitch.on = YES;
    }
}

- (void)setupPasterView:(TYPasterView *)pasterView {
    if(!self.enableControlsSwitch.isOn) [pasterView clearAllControl];
    if(!self.enableDeleteControlSwitch.isOn) [pasterView.deleteControl removeFromSuperview];
    if(!self.enableScaleControlSwitch.isOn) [pasterView.scaleControl removeFromSuperview];
    if(!self.enableRotateControlSwitch.isOn) [pasterView.rotateControl removeFromSuperview];

    pasterView.enableGesture = self.enableGestureSwitch.isOn;
    pasterView.enableDrag = self.enableDragSwitch.isOn;
    pasterView.enableScale = self.enableScaleSwitch.isOn;
    pasterView.enableRotate = self.enableRotateSwitch.isOn;
    pasterView.borderColor = [UIColor redColor];
}

@end
