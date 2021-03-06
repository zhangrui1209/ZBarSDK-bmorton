//
//  QRcodeOverlayView.m
//  AVITOTT
//
//  Created by avit on 1/6/16.
//
//

#import "QRcodeOverlayView.h"

static NSTimeInterval kLineAnimateDuration = 0.02;

@implementation QRcodeOverlayView {
    UIImageView *_imgLine;
    UILabel     *_LabDesc;
    CGFloat     _lineH;
    CGFloat     _rectY;
    
    NSTimer *_timer;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!_imgLine) {
        _rectY = self.transparentArea.origin.y;
        
        [self addLine];
        
        _timer = [NSTimer timerWithTimeInterval:kLineAnimateDuration target:self selector:@selector(lineDrop) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:_timer forMode:NSDefaultRunLoopMode];
    }
    
    if (!_LabDesc) {
        [self addDescView];
    }
}

- (void)addLine
{
    _imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.transparentArea.size.width, 2)];
    _imgLine.image = [UIImage imageNamed:@"qrcode-line.png"];
    _imgLine.center = CGPointMake(self.frame.size.width / 2, _rectY + 2);
    _lineH = _imgLine.frame.origin.y;
    [self addSubview:_imgLine];
}

- (void)addDescView
{
    UILabel *LabDesc = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 16)];
    
    LabDesc.center = CGPointMake(self.frame.size.width / 2, _rectY + self.transparentArea.size.height + 20);
    [LabDesc setTextColor:[UIColor whiteColor]];
    [LabDesc setTextAlignment:UITextAlignmentCenter];
    [LabDesc setFont:[UIFont systemFontOfSize:13]];
    [LabDesc setText:@"将二维码/条形码放入框内，即可自动扫描"];
    [LabDesc setBackgroundColor:[UIColor clearColor]];
    [LabDesc setNumberOfLines:1];
    [self addSubview:LabDesc];
}

- (void)drawRect:(CGRect)rect
{
    CGRect screenDrawRect = self.frame;
    
    CGRect clearDrawRect = self.transparentArea;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [self addScreenFillRect:ctx rect:screenDrawRect];
    
    [self addCenterClearRect:ctx rect:clearDrawRect];
    
    [self addWhiteRect:ctx rect:clearDrawRect];
    
    [self addCornerLineWithContext:ctx rect:clearDrawRect];
}

- (void)addScreenFillRect:(CGContextRef)ctx rect:(CGRect)rect
{
    CGContextSetRGBFillColor(ctx, 40 / 255.0, 40 / 255.0, 40 / 255.0, 0.5);
    CGContextFillRect(ctx, rect);
}

- (void)addCenterClearRect:(CGContextRef)ctx rect:(CGRect)rect
{
    CGContextClearRect(ctx, rect);
}

- (void)addWhiteRect:(CGContextRef)ctx rect:(CGRect)rect
{
    CGContextStrokeRect(ctx, rect);
    CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1); // 白色
    CGContextSetLineWidth(ctx, 0.8);             // 线条宽度
    CGContextAddRect(ctx, rect);                 // 创建一个矩形path
    CGContextStrokePath(ctx);                    // 填充矩形条
}

- (void)addCornerLineWithContext:(CGContextRef)ctx rect:(CGRect)rect
{
    // 画四个边角
    CGContextSetLineWidth(ctx, 2);
    CGContextSetRGBStrokeColor(ctx, 83 / 255.0, 239 / 255.0, 111 / 255.0, 1);// 绿色
    
    // 左上角
    CGPoint poinsTopLeftA[] = {
        CGPointMake(rect.origin.x + 0.7, rect.origin.y),
        CGPointMake(rect.origin.x + 0.7, rect.origin.y + 15)
    };
    
    CGPoint poinsTopLeftB[] = {CGPointMake(rect.origin.x, rect.origin.y + 0.7), CGPointMake(rect.origin.x + 15, rect.origin.y + 0.7)};
    [self addLine:poinsTopLeftA pointB:poinsTopLeftB ctx:ctx];
    
    // 左下角
    CGPoint poinsBottomLeftA[] = {CGPointMake(rect.origin.x + 0.7, rect.origin.y + rect.size.height - 15), CGPointMake(rect.origin.x + 0.7, rect.origin.y + rect.size.height)};
    CGPoint poinsBottomLeftB[] = {CGPointMake(rect.origin.x, rect.origin.y + rect.size.height - 0.7), CGPointMake(rect.origin.x + 0.7 + 15, rect.origin.y + rect.size.height - 0.7)};
    [self addLine:poinsBottomLeftA pointB:poinsBottomLeftB ctx:ctx];
    
    // 右上角
    CGPoint poinsTopRightA[] = {CGPointMake(rect.origin.x + rect.size.width - 15, rect.origin.y + 0.7), CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + 0.7)};
    CGPoint poinsTopRightB[] = {CGPointMake(rect.origin.x + rect.size.width - 0.7, rect.origin.y), CGPointMake(rect.origin.x + rect.size.width - 0.7, rect.origin.y + 15 + 0.7)};
    [self addLine:poinsTopRightA pointB:poinsTopRightB ctx:ctx];
    
    CGPoint poinsBottomRightA[] = {CGPointMake(rect.origin.x + rect.size.width - 0.7, rect.origin.y + rect.size.height + -15), CGPointMake(rect.origin.x - 0.7 + rect.size.width, rect.origin.y + rect.size.height)};
    CGPoint poinsBottomRightB[] = {CGPointMake(rect.origin.x + rect.size.width - 15, rect.origin.y + rect.size.height - 0.7), CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height - 0.7)};
    [self addLine:poinsBottomRightA pointB:poinsBottomRightB ctx:ctx];
    CGContextStrokePath(ctx);
}

- (void)addLine:(CGPoint[])pointA pointB:(CGPoint[])pointB ctx:(CGContextRef)ctx
{
    CGContextAddLines(ctx, pointA, 2);
    CGContextAddLines(ctx, pointB, 2);
}

- (void)lineDrop
{
    [UIView animateWithDuration:kLineAnimateDuration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        CGRect rect = _imgLine.frame;
        rect.origin.y = _lineH;
        _imgLine.frame = rect;
    } completion:^(BOOL complite) {
        CGFloat maxBorder = _rectY + self.transparentArea.size.height - 4;
        
        if (_lineH > maxBorder) {
            _lineH = _rectY + 4;
        }
        
        _lineH++;
    }];
}

- (void)startAnimation
{
    [_timer setFireDate:[NSDate distantPast]];
}

- (void)stopAnimation
{
    [_timer invalidate];
    _timer = nil;
}

@end
