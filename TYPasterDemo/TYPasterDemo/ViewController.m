//
//  ViewController.m
//  TYPasterDemo
//
//  Created by 应俊康 on 2018/8/5.
//  Copyright © 2018年 应俊康. All rights reserved.
//

#import "ViewController.h"
#import "TYPaster.h"
//#import "XTPasterView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    for (int i = 1; i < 6; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%d",i]];
        TYPasterView * view = [[TYPasterManager sharedInstance] pasterWithImage:image];
        // view.frame size must > 0
        view.frame = (CGRect){CGPointZero,CGSizeMake(150, 100)};
        view.center = CGPointMake(200, 200);
        [self.view addSubview:view];
    }
    
    
}
@end
