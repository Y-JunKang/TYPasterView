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

NSString * const kTYPasterScaleControlIcon = @"TYPasterResource.bundle/scaleControl.png";
NSString * const kTYPasterRotateControlIcon = @"TYPasterResource.bundle/rotateControl.png";
NSString * const kTYPasterDeleteControlIcon = @"TYPasterResource.bundle/deleteControl.png";

@interface TYPasterView() {
    UIImage *_image;
    NSString *_text;
    BOOL _needLayout;
    NSMutableSet *_controlsSet;
    NSMutableSet *_borderSet;
    BOOL _shouldShowControls;
    BOOL _shouldShowBorders;
    
}

@property (nonatomic, weak) id<TYPasterViewDelegate> delegate;

@property (nonatomic) CGFloat scale;
@property (nonatomic) CGRect originFrame;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *shadowView;
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
        _shouldShowBorders = YES;
        
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
        
        [self addControls];
        
        _needLayout = NO;
    }
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
    for(TYPasterControl *control in _controlsSet) {
        control.transform = transformControl;
    }
    
    self.topLine.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, invertScale);
    self.leftLine.transform = CGAffineTransformScale(CGAffineTransformIdentity, invertScale, 1);
    self.bottomLine.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, invertScale);
    self.rightLine.transform = CGAffineTransformScale(CGAffineTransformIdentity, invertScale, 1);
}

- (void)addControl:(TYPasterControl *)control {
    [_controlsSet addObject:control];
    if(!control.superview) {
        [self addSubview:control];
    }
}

- (void)removeControl:(TYPasterControl *)control {
    [_controlsSet removeObject:control];
    [control removeFromSuperview];
}

- (void)clearAllControl {
    for(UIView *control in _controlsSet) {
        [control removeFromSuperview];
    }
    [_controlsSet removeAllObjects];
}

- (void)addControls {
    for(UIView *border in _borderSet) {
        if(!border.superview) {
            [self addSubview:border];
        }
    }
    
    for(UIView *control in _controlsSet) {
        if(!control.superview) {
            [self addSubview:control];
        }
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

- (TYScaleControl *)scaleControl {
    if(!_scaleControl) {
        _scaleControl = [[TYScaleControl alloc]initWithPasterView:self];
        _scaleControl.frame = (CGRect){CGPointZero,CGSizeMake(_controlWidth, _controlWidth)};
        _scaleControl.center = CGPointMake(_originFrame.size.width, _originFrame.size.height);
        _scaleControl.hidden = !_shouldShowControls;
    }
    return _scaleControl;
}

- (TYRotateControl *)rotateControl {
    if(!_rotateControl) {
        _rotateControl = [[TYRotateControl alloc]initWithPasterView:self];
        _rotateControl.frame = (CGRect){CGPointZero,CGSizeMake(_controlWidth, _controlWidth)};
        _rotateControl.center = CGPointMake(0, 0);
        _rotateControl.hidden = !_shouldShowControls;
    }
    return _rotateControl;
}

- (TYDeleteControl *)deleteControl {
    if(!_deleteControl) {
        _deleteControl = [[TYDeleteControl alloc]initWithPasterView:self];
        _deleteControl.frame = (CGRect){CGPointZero,CGSizeMake(_controlWidth, _controlWidth)};
        _deleteControl.center = CGPointMake(_originFrame.size.width, 0);
        _deleteControl.hidden = !_shouldShowControls;
    }
    return _deleteControl;
}

- (UIView *)createLine {
    UIView *line = [[UIView alloc]init];
    line.backgroundColor = _borderColor;
    line.hidden = !_shouldShowBorders;
    return line;
}

- (UIView *)topLine {
    if(!_topLine) {
        _topLine = [self createLine];
        _topLine.frame = (CGRect){CGPointZero, CGSizeMake(_originFrame.size.width, _borderWidth)};
        _topLine.center = CGPointMake(_originFrame.size.width / 2, 0);
    }
    return _topLine;
}

- (UIView *)rightLine {
    if(!_rightLine) {
        _rightLine = [self createLine];
        _rightLine.frame = (CGRect){CGPointZero, CGSizeMake(_borderWidth, _originFrame.size.height)};
        _rightLine.center = CGPointMake(0, _originFrame.size.height / 2);
    }
    return _rightLine;
}

- (UIView *)bottomLine {
    if(!_bottomLine) {
        _bottomLine = [self createLine];
        _bottomLine.frame = (CGRect){CGPointZero, CGSizeMake(_originFrame.size.width, _borderWidth)};
        _bottomLine.center = CGPointMake(_originFrame.size.width / 2, _originFrame.size.height);
    }
    return _bottomLine;
}

- (UIView *)leftLine {
    if(!_leftLine) {
        _leftLine = [self createLine];
        _leftLine.frame = (CGRect){CGPointZero, CGSizeMake(_borderWidth, _originFrame.size.height)};
        _leftLine.center = CGPointMake(_originFrame.size.width, _originFrame.size.height / 2);
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
    TYPasterView *pasterView = self.pastersDic[pasterId];
    [pasterView removeFromSuperview];
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


@interface TYPasterControl()

@property (nonatomic, weak) TYPasterView *pasterView;

@end

@implementation TYPasterControl

- (instancetype)initWithPasterView:(TYPasterView *)pasterView {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        _pasterView = pasterView;
    }
    return self;
}

@end

@implementation TYScaleControl

- (instancetype)initWithPasterView:(TYPasterView *)pasterView {
    self = [super initWithPasterView:pasterView];
    if (self) {
        self.image = [UIImage imageNamed:kTYPasterScaleControlIcon];
        ADD_GESTURE_RECOGNIZER(self, UIPanGestureRecognizer, @selector(onScaleControlDrag:));
    }
    return self;
}

- (void)onScaleControlDrag:(UIPanGestureRecognizer *)gesture {
    if(gesture.state == UIGestureRecognizerStateBegan) {
        self.pasterView.shadowView.transform = self.pasterView.transform;
        [self.pasterView.superview addSubview:self.pasterView.shadowView];
    }else if(gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint offset = [gesture translationInView:self.pasterView.superview];
        CGFloat width = self.pasterView.originFrame.size.width;
        CGFloat height = self.pasterView.originFrame.size.height;
        CGFloat cosAngle = width / hypot(width, height);
        
        CGFloat originLen = hypot(width, height) / 2;
        CGFloat offsetLen = offset.x / cosAngle;
        CGFloat scale = 1 + offsetLen / originLen;
        self.pasterView.scale *= scale;
        self.pasterView.shadowView.transform = CGAffineTransformScale(self.pasterView.shadowView.transform, scale, scale);
        [gesture setTranslation:CGPointZero inView:self.pasterView.superview];
    }else if(gesture.state == UIGestureRecognizerStateEnded) {
        self.pasterView.transform = self.pasterView.shadowView.transform;
        [self.pasterView updateControls];
        [self.pasterView.shadowView removeFromSuperview];
    }
}

@end

@implementation TYRotateControl

- (instancetype)initWithPasterView:(TYPasterView *)pasterView {
    self = [super initWithPasterView:pasterView];
    if (self) {
        self.image = [UIImage imageNamed:kTYPasterRotateControlIcon];
        ADD_GESTURE_RECOGNIZER(self, UIPanGestureRecognizer, @selector(onRotateControlDrag:));
    }
    return self;
}

- (void)onRotateControlDrag:(UIPanGestureRecognizer *)gesture {
    if(gesture.state == UIGestureRecognizerStateBegan) {
        self.pasterView.shadowView.transform = self.pasterView.transform;
        [self.pasterView.superview addSubview:self.pasterView.shadowView];
    }else if(gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint offset = [gesture translationInView:self.pasterView.superview];
        CGFloat width = self.pasterView.originFrame.size.width;
        CGFloat height = self.pasterView.originFrame.size.height;
        CGFloat angle = hypot(offset.x, offset.y);
        angle /= hypot(width, height);
        CGPoint location = [gesture locationInView:self.pasterView.superview];
        CGPoint center = self.pasterView.center;
        
        if((location.x - center.x) * offset.y < 0 ) {
            angle = -angle;
        }
        
        if(offset.x * offset.y == 0) {
            angle = 0;
        }
        
        self.pasterView.shadowView.transform = CGAffineTransformRotate(self.pasterView.shadowView.transform, angle);
        [gesture setTranslation:CGPointZero inView:self.pasterView.superview];
    }else if(gesture.state == UIGestureRecognizerStateEnded) {
        self.pasterView.transform = self.pasterView.shadowView.transform;
        [self.pasterView updateControls];
        [self.pasterView.shadowView removeFromSuperview];
    }
}

@end

@implementation TYDeleteControl

- (instancetype)initWithPasterView:(TYPasterView *)pasterView
{
    self = [super initWithPasterView:pasterView];
    if (self) {
        self.image = [UIImage imageNamed:@"TYPasterResource.bundle/deleteControl"];
        ADD_GESTURE_RECOGNIZER(self, UIPanGestureRecognizer, @selector(onDeleteControlTap:));
    }
    return self;
}

- (void)onDeleteControlTap:(UITapGestureRecognizer *)gesture {
    [[TYPasterManager sharedInstance] deletePasterWithId:self.pasterView.pasterId];
}

@end

