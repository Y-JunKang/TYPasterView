//
//  TYPasterManager.m
//  TYPasterDemo
//
//  Created by 应俊康 on 2018/8/5.
//  Copyright © 2018年 应俊康. All rights reserved.
//

#import "TYPasterManager.h"
#import "TYPasterView+Private.h"

@interface TYPasterManager() <TYPasterViewDelegate>

@property (nonatomic,strong) NSMutableDictionary *pastersDic;
@property (nonatomic,strong) TYPasterView *currentPaster;

@end

@implementation TYPasterManager
+(instancetype)sharedInstance{
    static TYPasterManager * instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TYPasterManager alloc]init];
    });
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _pastersDic = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (TYPasterView *)pasterWithImage:(UIImage *)image{
    NSString * pasterId = [NSString stringWithFormat:@"pst_%f",[NSDate date].timeIntervalSince1970];
    TYPasterView * paster = [[TYPasterView alloc] initWithImage:image
                                                       pasterId:pasterId];
    [paster setDelegate:self];
    [self.currentPaster hideControls];
    self.currentPaster = paster;
    [self.currentPaster showControls];
    [self.pastersDic setObject:paster forKey:pasterId];
    return paster;
}

- (void)deletePasterWithId:(NSString *)pasterId {
    [self.pastersDic removeObjectForKey:pasterId];
    if([self.currentPaster.pasterId isEqualToString:pasterId]) {
        self.currentPaster = nil;
    }
}

#pragma mark TYPasterViewDelegate
- (void)typasterViewDidTaped:(TYPasterView *)pasterView {
    [[pasterView superview] bringSubviewToFront:pasterView];
    [self.currentPaster hideControls];
    self.currentPaster = pasterView;
    [self.currentPaster showControls];
}
@end


