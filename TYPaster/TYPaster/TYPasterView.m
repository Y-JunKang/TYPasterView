;//
//  TYPasterView.m
//  TYPasterDemo
//
//  Created by 应俊康 on 2018/8/5.
//  Copyright © 2018年 应俊康. All rights reserved.
//

#import <math.h>
#import "TYPasterView.h"

#define ADD_GESTURE_RECOGNIZER(view,type,selector) \
[view addGestureRecognizer:[[type alloc]initWithTarget:self \
action:selector]]

typedef NS_ENUM(NSUInteger,TYControlType) {
    TYControlTypeScale = 1,
    TYControlTypeRotate,
    TYControlTypeDelete
};

@interface TYPasterView() {
    UIImage *_image;
    NSString *_text;
    CGFloat _scale;
    CGRect _originFrame;
    BOOL _needLayout;
    NSMutableSet *_controlsSet;
    NSMutableSet *_borderSet;
    BOOL _shouldShowControls;
    BOOL _shouldShowBorders;
    
}

@property (nonatomic, weak) id<TYPasterViewDelegate> delegate;

//TODO: 内容view从imageView切换UIView，支持其他view
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *shadowView;
@property (nonatomic, strong) UIImageView *scaleControl;
@property (nonatomic, strong) UIImageView *rotateControl;
@property (nonatomic, strong) UIImageView *deleteControl;
@property (nonatomic, strong) UIView *topLine, *leftLine, *bottomLine, *rightLine;

@property (nonatomic, strong) UITapGestureRecognizer *pasterTapRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *pasterPanRecognizer;
@property (nonatomic, strong) UIPinchGestureRecognizer *pasterPinchRecognizer;
@property (nonatomic, strong) UIRotationGestureRecognizer *pasterRotationRecognizer;

@end

@implementation TYPasterView

#pragma mark public interface
- (instancetype)initWithPasterId:(NSString *)pasterId {
    if(self = [super init]) {
        _pasterId = pasterId;
        _scale = 1;
        _controlWidth = 25;
        _borderColor = [UIColor whiteColor];
        _borderWidth = 1;
        _needLayout = YES;
        
        _shouldShowControls = YES;
        
        _enableControls = YES;
        _enableDeleteControl = YES;
        _enableScaleControl = YES;
        _enableRotateControl = YES;
        
        _enableGesture = YES;
        _enableDrag = YES;
        _enableScale = YES;
        _enableRotate = YES;
        _controlsSet = [NSMutableSet set];
        _borderSet = [NSMutableSet set];

        [self setupGestureRecognizer];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image pasterId:(NSString *)pasterId {
    if(self = [self initWithPasterId:pasterId]) {
        _image = image;
    }
    return self;
}

- (instancetype)initWithText:(NSString *)text pasterId:(NSString *)pasterId {
    if(self = [self initWithPasterId:pasterId]) {
        _text = text;
    }
    return self;
}

- (instancetype)initWithCustomeView:(UIView *)customeView pasterId:(NSString *)pasterId {
    if(self = [self initWithPasterId:pasterId]) {
        _customeView = customeView;
        _pasterId = pasterId;
    }
    return self;
}

#pragma mark private interface
- (void)layoutSubviews {
    if(_needLayout) {
        _originFrame = self.frame;
        
        // setup contentView
        [self addSubview:self.contentView];
        [_controlsSet addObjectsFromArray:@[self.deleteControl,self.rotateControl,self.scaleControl]];
        [_borderSet addObjectsFromArray:@[self.leftLine,self.topLine,self.rightLine,self.bottomLine]];
        
        if(!_enableControls) [_controlsSet removeAllObjects];
        if(!_enableDeleteControl) [_controlsSet removeObject:self.deleteControl];
        if(!_enableScaleControl) [_controlsSet removeObject:self.scaleControl];
        if(!_enableRotateControl) [_controlsSet removeObject:self.rotateControl];
        
        [self addControls];
        
        _needLayout = NO;
    };

}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event
{
    CGRect bounds = self.bounds;
    CGFloat controlWidth = _controlWidth / _scale;
    bounds = CGRectInset(bounds, -controlWidth / 2, -controlWidth / 2);
    return CGRectContainsPoint(bounds, point);
}

- (void)setupGestureRecognizer {
    [self addGestureRecognizer:self.pasterTapRecognizer];
    [self addGestureRecognizer:self.pasterPanRecognizer];
    [self addGestureRecognizer:self.pasterPinchRecognizer];
    [self addGestureRecognizer:self.pasterRotationRecognizer];
    self.userInteractionEnabled = YES ;
}

- (void)updateControls {
    CGFloat invertScale = 1 / _scale;
    CGAffineTransform transformControl = CGAffineTransformScale(CGAffineTransformIdentity, invertScale, invertScale);
    self.scaleControl.transform = transformControl;
    self.rotateControl.transform = transformControl;
    self.deleteControl.transform = transformControl;
    
    self.topLine.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, invertScale);
    self.leftLine.transform = CGAffineTransformScale(CGAffineTransformIdentity, invertScale, 1);
    self.bottomLine.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, invertScale);
    self.rightLine.transform = CGAffineTransformScale(CGAffineTransformIdentity, invertScale, 1);
}

- (void)addControls {
    for(UIView *border in _borderSet) {
        [self addSubview:border];
    }
    
    for(UIView *control in _controlsSet) {
        [self addSubview:control];
    }
}

- (void)removeControls {
    for(UIView *border in _borderSet) {
        [border removeFromSuperview];
    }
    
    for(UIView *control in _controlsSet) {
        [control removeFromSuperview];
    }
}

- (void)showControls {
    _shouldShowControls = YES;
    for(UIView *control in _controlsSet) {
        [control setHidden:NO];
    }
}

- (void)hideControls {
    _shouldShowControls = NO;
    for(UIView *control in _controlsSet) {
        [control setHidden:YES];
    }
}

- (void)showBorders {
    _shouldShowBorders = YES;
    for(UIView *border in _borderSet) {
        [border setHidden:NO];
    }
}

- (void)hideBorders {
    _shouldShowBorders = NO;
    for(UIView *border in _borderSet) {
        [border setHidden:YES];
    }
}

#pragma mark getter and setter
- (UIView *)contentView {
    if(!_contentView) {
        if(_image) {
            _contentView = [[UIImageView alloc]init];
            ((UIImageView *)_contentView).image = _image;
        }else if(_text) {
            _contentView = [[UILabel alloc]init];
            ((UILabel *)_contentView).text = _text;
            ((UILabel *)_contentView).textColor = [UIColor blackColor];
            ((UILabel *)_contentView).textAlignment = NSTextAlignmentCenter;
        }else if(_customeView) {
            _contentView = _customeView;
        }else {
            NSAssert(NO, @"no content for paster");
        }
        _contentView.frame = (CGRect){CGPointZero,_originFrame.size};
    }
    return _contentView;
}

- (UIImageView *)contentImageView {
    if(_image&&[_contentView isKindOfClass:[UIImageView class]]) {
        return (UIImageView *)_contentView;
    }
    return nil;
}

- (UILabel *)contentLabelView {
    if(_text&&[_contentView isKindOfClass:[UILabel class]]) {
        return (UILabel *)_contentView;
    }
    return nil;
}

- (UIView *)shadowView {
    if(!_shadowView) {
        _shadowView = [self.contentView snapshotViewAfterScreenUpdates:YES];
        _shadowView.frame = _originFrame;
        _shadowView.alpha = 0.5;
    }
    return _shadowView;
}

- (UIImageView *)scaleControl {
    if(!_scaleControl) {
        _scaleControl = [self createControlFor:TYControlTypeScale];
        _scaleControl.frame = (CGRect){CGPointZero,CGSizeMake(_controlWidth, _controlWidth)};
        _scaleControl.center = CGPointMake(_originFrame.size.width, _originFrame.size.height);
        _scaleControl.userInteractionEnabled = YES;
        _scaleControl.hidden = !_shouldShowControls;
        ADD_GESTURE_RECOGNIZER(_scaleControl, UIPanGestureRecognizer, @selector(onScaleContorlDrag:));
    }
    return _scaleControl;
}

- (UIImageView *)rotateControl {
    if(!_rotateControl) {
        _rotateControl = [self createControlFor:TYControlTypeRotate];
        _rotateControl.userInteractionEnabled = YES;
        _rotateControl.frame = (CGRect){CGPointZero,CGSizeMake(_controlWidth, _controlWidth)};
        _rotateControl.center = CGPointMake(0, 0);
        _rotateControl.hidden = !_shouldShowControls;
        ADD_GESTURE_RECOGNIZER(_rotateControl, UIPanGestureRecognizer, @selector(onRotateContorlDrag:));
    }
    return _rotateControl;
}

- (UIImageView *)deleteControl {
    if(!_deleteControl) {
        _deleteControl = [self createControlFor:TYControlTypeDelete];
        _deleteControl.userInteractionEnabled = YES;
        _deleteControl.frame = (CGRect){CGPointZero,CGSizeMake(_controlWidth, _controlWidth)};
        _deleteControl.center = CGPointMake(_originFrame.size.width, 0);
        _deleteControl.hidden = !_shouldShowControls;
        ADD_GESTURE_RECOGNIZER(_deleteControl, UITapGestureRecognizer, @selector(onPasterDelete:));
    }
    return _deleteControl;
}

- (UIView *)topLine {
    if(!_topLine) {
        _topLine = [[UIView alloc]init];
        _topLine.backgroundColor = _borderColor;
        _topLine.frame = (CGRect){CGPointZero, CGSizeMake(_originFrame.size.width, _borderWidth)};
        _topLine.center = CGPointMake(_originFrame.size.width / 2, 0);
        _topLine.hidden = !_shouldShowControls;
    }
    return _topLine;
}

- (UIView *)rightLine {
    if(!_rightLine) {
        _rightLine = [[UIView alloc]init];
        _rightLine.backgroundColor = _borderColor;
        _rightLine.frame = (CGRect){CGPointZero, CGSizeMake(_borderWidth, _originFrame.size.height)};
        _rightLine.center = CGPointMake(0, _originFrame.size.height / 2);
        _rightLine.hidden = !_shouldShowControls;
    }
    return _rightLine;
}

- (UIView *)bottomLine {
    if(!_bottomLine) {
        _bottomLine = [[UIView alloc]init];
        _bottomLine.backgroundColor = _borderColor;
        _bottomLine.frame = (CGRect){CGPointZero, CGSizeMake(_originFrame.size.width, _borderWidth)};
        _bottomLine.center = CGPointMake(_originFrame.size.width / 2, _originFrame.size.height);
        _bottomLine.hidden = !_shouldShowControls;
    }
    return _bottomLine;
}

- (UIView *)leftLine {
    if(!_leftLine) {
        _leftLine = [[UIView alloc]init];
        _leftLine.backgroundColor = _borderColor;
        _leftLine.frame = (CGRect){CGPointZero, CGSizeMake(_borderWidth, _originFrame.size.height)};
        _leftLine.center = CGPointMake(_originFrame.size.width, _originFrame.size.height / 2);
        _leftLine.hidden = !_shouldShowControls;
    }
    return _leftLine;
}

- (UITapGestureRecognizer *)pasterTapRecognizer {
    if(!_pasterTapRecognizer) {
        _pasterTapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onPasterTap:)];
    }
    return _pasterTapRecognizer;
}

- (UIPanGestureRecognizer *)pasterPanRecognizer {
    if(!_pasterPanRecognizer) {
        _pasterPanRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(onPasterDrag:)];
    }
    return _pasterPanRecognizer;
}

- (UIPinchGestureRecognizer *)pasterPinchRecognizer {
    if(!_pasterPinchRecognizer) {
        _pasterPinchRecognizer =[[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(onPasterPinch:)];
    }
    return _pasterPinchRecognizer;
}

- (UIRotationGestureRecognizer *)pasterRotationRecognizer {
    if(!_pasterRotationRecognizer) {
        _pasterRotationRecognizer = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(onPasterRotate:)];
    }
    return _pasterRotationRecognizer;
}

- (void)setEnableControls:(BOOL)enableControls {
    if(enableControls == _enableControls) {
        return;
    }
    
    _enableControls = enableControls;
    [_controlsSet removeAllObjects];
    self.enableDeleteControl = enableControls;
    self.enableScaleControl = enableControls;
    self.enableRotateControl = enableControls;
}

#define SET_ENABLE_FOR_CONTROL(enable, view) \
if(enable == _##enable) { \
return; \
} \
_##enable = enable; \
if(enable) { \
[_controlsSet addObject:view]; \
[self insertSubview:view atIndex:self.subviews.count]; \
_enableControls = YES; \
}else { \
[_controlsSet removeObject:view]; \
[view removeFromSuperview]; \
}

- (void)setEnableDeleteControl:(BOOL)enableDeleteControl {
    SET_ENABLE_FOR_CONTROL(enableDeleteControl, self.deleteControl);
}

- (void)setEnableScaleControl:(BOOL)enableScaleControl {
    SET_ENABLE_FOR_CONTROL(enableScaleControl, self.scaleControl);
}

- (void)setEnableRotateControl:(BOOL)enableRotateControl {
    SET_ENABLE_FOR_CONTROL(enableRotateControl, self.rotateControl);
}

- (void)setEnableGesture:(BOOL)enableGesture {
    if(enableGesture == _enableGesture) {
        return;
    }
    
    _enableGesture = enableGesture;
    self.enableDrag = enableGesture;
    self.enableScale = enableGesture;
    self.enableRotate = enableGesture;
}

#define SET_ENABLE_FOR_GESTURE(enable, recognizer) \
if(enable == _##enable) { \
return; \
} \
_##enable = enable; \
if(enable) { \
[self addGestureRecognizer:recognizer]; \
_enableGesture = YES; \
}else { \
[self removeGestureRecognizer:recognizer]; \
}

- (void)setEnableDrag:(BOOL)enableDrag {
    SET_ENABLE_FOR_GESTURE(enableDrag, self.pasterPanRecognizer);
}

- (void)setEnableScale:(BOOL)enableScale {
    SET_ENABLE_FOR_GESTURE(enableScale, self.pasterPinchRecognizer);
}

- (void)setEnableRotate:(BOOL)enableRotate {
    SET_ENABLE_FOR_GESTURE(enableRotate, self.pasterRotationRecognizer);
}

- (UIImageView *)createControlFor:(TYControlType)type {
    UIImageView * control = [[UIImageView alloc]init];
    control.backgroundColor = [UIColor clearColor];
    NSString *iconName = [NSString stringWithFormat:@"TYPasterResource.bundle/controlIcon_%lu",(unsigned long)type];
    UIImage *image = [UIImage imageNamed:iconName];
    switch (type) {
        case TYControlTypeScale:
            image = _scaleControlIcon?:image;
            break;
        case TYControlTypeDelete:
            image = _deleteControlIcon?:image;
            break;
        case TYControlTypeRotate:
            image = _rotateControlIcon?:image;
            break;
    }
    control.image = image;
    return control;
}

#pragma mark action sendder

#define TY_PASTER_GESTURE_RECOGNIZER_LOGIC(logic) \
if(gesture.state == UIGestureRecognizerStateBegan) { \
[self.delegate typasterViewDidTaped:self]; \
[self removeControls]; \
}else if(gesture.state == UIGestureRecognizerStateChanged) { \
logic(); \
}else if(gesture.state == UIGestureRecognizerStateEnded) { \
[self updateControls]; \
[self addControls];  \
}

- (void)onPasterTap:(UITapGestureRecognizer *)gesture
{
    [self.delegate typasterViewDidTaped:self];
}

- (void)onPasterDrag:(UIPanGestureRecognizer *)gesture
{
    dispatch_block_t block = ^{
        CGPoint offset = [gesture translationInView:self];
        self.transform = CGAffineTransformTranslate(self.transform, offset.x, offset.y);
        [gesture setTranslation:CGPointZero inView:self];
    };
    TY_PASTER_GESTURE_RECOGNIZER_LOGIC(block);
}

- (void)onPasterPinch:(UIPinchGestureRecognizer *)gesture
{
    dispatch_block_t block = ^{
        CGFloat scale = gesture.scale;
        CGFloat width = self.frame.size.width * scale;
        CGFloat height = self.frame.size.height * scale;
        if(width > self.superview.frame.size.width - self->_controlWidth
           ||width < self->_image.size.width / 4
           ||height > self.superview.frame.size.height - self->_controlWidth
           ||height < self->_image.size.height / 4) {
            return;
        }
        self.transform = CGAffineTransformScale(self.transform, scale, scale);
        self->_scale *= scale;
        gesture.scale = 1.0;
    };
    TY_PASTER_GESTURE_RECOGNIZER_LOGIC(block);
}

- (void)onPasterRotate:(UIRotationGestureRecognizer *)gesture
{
    dispatch_block_t block = ^{
        self.transform = CGAffineTransformRotate(self.transform, gesture.rotation);
        gesture.rotation = 0.0;
    };
    TY_PASTER_GESTURE_RECOGNIZER_LOGIC(block);
}

- (void)onPasterDelete:(UITapGestureRecognizer *)gesture {
    [[TYPasterManager sharedInstance] deletePasterWithId:_pasterId];
    [self removeFromSuperview];
}

- (void)onScaleContorlDrag:(UIPanGestureRecognizer *)gesture {
    if(gesture.state == UIGestureRecognizerStateBegan) {
        self.shadowView.transform = self.transform;
        [self.delegate typasterViewDidTaped:self];
        [self.superview addSubview:self.shadowView];
    }else if(gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint offset = [gesture translationInView:self.superview];
        CGFloat width = _originFrame.size.width;
        CGFloat height = _originFrame.size.height;
        CGFloat cosAngle = width / hypot(width, height);
        
        CGFloat originLen = hypot(width, height) / 2;
        CGFloat offsetLen = offset.x / cosAngle;
        CGFloat scale = 1 + offsetLen / originLen;
        _scale *= scale;
        self.shadowView.transform = CGAffineTransformScale(self.shadowView.transform, scale, scale);
        [gesture setTranslation:CGPointZero inView:self.superview];
    }else if(gesture.state == UIGestureRecognizerStateEnded) {
        self.transform = self.shadowView.transform;
        [self updateControls];
        [self.shadowView removeFromSuperview];
    }
}

- (void)onRotateContorlDrag:(UIPanGestureRecognizer *)gesture {
    if(gesture.state == UIGestureRecognizerStateBegan) {
        self.shadowView.transform = self.transform;
        [self.delegate typasterViewDidTaped:self];
        [self.superview addSubview:self.shadowView];
    }else if(gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint offset = [gesture translationInView:self.superview];
        CGFloat width = _originFrame.size.width;
        CGFloat height = _originFrame.size.height;
        CGFloat angle = hypot(offset.x, offset.y);
        angle /= hypot(width, height);
        CGPoint location = [gesture locationInView:self.superview];
        CGPoint center = self.center;
        
        if((location.x - center.x) * offset.y < 0 ) {
            angle = -angle;
        }
        
        if(offset.x * offset.y == 0) {
            angle = 0;
        }
    
        self.shadowView.transform = CGAffineTransformRotate(self.shadowView.transform, angle);
        [gesture setTranslation:CGPointZero inView:self.superview];
    }else if(gesture.state == UIGestureRecognizerStateEnded) {
        self.transform = self.shadowView.transform;
        [self updateControls];
        [self.shadowView removeFromSuperview];
    }
}
@end

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

- (void)setupPasterView:(TYPasterView *)pasterView{
    [pasterView setDelegate:self];
    [self.currentPaster hideControls];
    self.currentPaster = pasterView;
    [self.currentPaster showControls];
    [self.pastersDic setObject:pasterView forKey:pasterView.pasterId];
}

- (TYPasterView *)pasterWithImage:(UIImage *)image{
    NSString * pasterId = [NSString stringWithFormat:@"pst_%f",[NSDate date].timeIntervalSince1970];
    TYPasterView * paster = [[TYPasterView alloc] initWithImage:image
                                                       pasterId:pasterId];
    [self setupPasterView:paster];
    return paster;
}

- (TYPasterView *)pasterWithText:(NSString *)text {
    NSString * pasterId = [NSString stringWithFormat:@"pst_%f",[NSDate date].timeIntervalSince1970];
    TYPasterView * paster = [[TYPasterView alloc] initWithText:text pasterId:pasterId];
    
    [self setupPasterView:paster];
    return paster;
}

- (TYPasterView *)pasterWithCustomeView:(UIView *)customeView {
    NSString * pasterId = [NSString stringWithFormat:@"pst_%f",[NSDate date].timeIntervalSince1970];
    TYPasterView * paster = [[TYPasterView alloc] initWithCustomeView:customeView pasterId:pasterId];
    
    [self setupPasterView:paster];
    return paster;
}

- (void)deletePasterWithId:(NSString *)pasterId {
    [self.pastersDic removeObjectForKey:pasterId];
    if([self.currentPaster.pasterId isEqualToString:pasterId]) {
        self.currentPaster = nil;
    }
}

- (void)clearAll {
    for (TYPasterView *pasterView in self.pastersDic.allValues) {
        [pasterView removeFromSuperview];
    }
    [self.pastersDic removeAllObjects];
}

#pragma mark TYPasterViewDelegate
- (void)typasterViewDidTaped:(TYPasterView *)pasterView {
    [[pasterView superview] bringSubviewToFront:pasterView];
    [self.currentPaster hideControls];
    self.currentPaster = pasterView;
    [self.currentPaster showControls];
}
@end
