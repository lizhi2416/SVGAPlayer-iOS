//
//  ViewController.m
//  SVGAPlayer
//
//  Created by 崔明辉 on 16/6/17.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "ViewController.h"
#import "SVGA.h"

@interface ViewController ()<SVGAPlayerDelegate>

@property (weak, nonatomic) IBOutlet SVGAPlayer *aPlayer;
@property (weak, nonatomic) IBOutlet UISlider *aSlider;
@property (weak, nonatomic) IBOutlet UIButton *onBeginButton;

@property (strong, nonatomic) SVGAPlayer *bPlayer;

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL nene;

@end

@implementation ViewController

static SVGAParser *parser;

- (void)viewDidLoad {
    self.index = 0;
    
    [super viewDidLoad];
    self.nene = NO;
    self.aPlayer.delegate = self;
    self.aPlayer.frame = CGRectMake(0, 0, 320, 320);
    self.aPlayer.loops = 1;
    self.aPlayer.clearsAfterStop = NO;
    self.aPlayer.contentMode = UIViewContentModeScaleAspectFill;
    
    self.bPlayer = [[SVGAPlayer alloc] init];
//    self.bPlayer.delegate = self;
    self.bPlayer.loops = 1;
    self.bPlayer.backgroundColor = [UIColor clearColor];
    self.bPlayer.userInteractionEnabled = NO;
    self.bPlayer.clearsAfterStop = NO;
    self.bPlayer.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.bPlayer];
    
    parser = [[SVGAParser alloc] init];
//    [self onChange:nil];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.bPlayer.frame = self.aPlayer.frame;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self onBeginButton:self.onBeginButton];
}

- (IBAction)onChange:(id)sender {
    
    [self playWithFileName:self.nene];
    return;
    
    NSArray *items = @[
                       @"https://github.com/yyued/SVGA-Samples/blob/master/EmptyState.svga?raw=true",
                       @"https://github.com/yyued/SVGA-Samples/blob/master/HamburgerArrow.svga?raw=true",
                       @"https://github.com/yyued/SVGA-Samples/blob/master/PinJump.svga?raw=true",
                       @"https://github.com/svga/SVGA-Samples/raw/master/Rocket.svga",
                       @"https://github.com/yyued/SVGA-Samples/blob/master/TwitterHeart.svga?raw=true",
                       @"https://github.com/yyued/SVGA-Samples/blob/master/Walkthrough.svga?raw=true",
                       @"https://github.com/yyued/SVGA-Samples/blob/master/angel.svga?raw=true",
                       @"https://github.com/yyued/SVGA-Samples/blob/master/halloween.svga?raw=true",
                       @"https://github.com/yyued/SVGA-Samples/blob/master/kingset.svga?raw=true",
                       @"https://github.com/yyued/SVGA-Samples/blob/master/posche.svga?raw=true",
                       @"https://github.com/yyued/SVGA-Samples/blob/master/rose.svga?raw=true",
                       ];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//    parser.enabledMemoryCache = YES;
    [parser parseWithURL:[NSURL URLWithString:items[arc4random() % items.count]]
         completionBlock:^(SVGAVideoEntity * _Nullable videoItem) {
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
             if (videoItem != nil) {
                 self.aPlayer.videoItem = videoItem;
                 NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc] init];
                 [para setLineBreakMode:NSLineBreakByTruncatingTail];
                 [para setAlignment:NSTextAlignmentCenter];
                 NSAttributedString *str = [[NSAttributedString alloc]
                                            initWithString:@"Hello, World! Hello, World!"
                                            attributes:@{
                                                NSFontAttributeName: [UIFont systemFontOfSize:28],
                                                NSForegroundColorAttributeName: [UIColor whiteColor],
                                                NSParagraphStyleAttributeName: para,
                                            }];
                 [self.aPlayer setAttributedText:str forKey:@"banner"];

                 [self.aPlayer startAnimation];
                 
//                 [self.aPlayer startAnimationWithRange:NSMakeRange(10, 25) reverse:YES];
             }
    } failureBlock:^(NSError * _Nullable error) {
        
    }];
//
//        [parser parseWithURL:[NSURL URLWithString:@"https://github.com/svga/SVGA-Samples/raw/master_aep/BitmapColorArea1.svga"] completionBlock:^(SVGAVideoEntity * _Nullable videoItem) {
//            if (videoItem != nil) {
//                self.aPlayer.videoItem = videoItem;
//                [self.aPlayer setImageWithURL:[NSURL URLWithString: @"https://i.imgur.com/vd4GuUh.png"] forKey:@"matte_EEKdlEml.matte"];
//                [self.aPlayer startAnimation];
//            }
//        } failureBlock:nil];
    
//    [parser parseWithNamed:@"Rocket" inBundle:nil completionBlock:^(SVGAVideoEntity * _Nonnull videoItem) {
//        self.aPlayer.videoItem = videoItem;
//        [self.aPlayer startAnimation];
//    } failureBlock:nil];
}

- (void)playWithFileName:(BOOL)hehe {
    SVGAPlayer *player = hehe ? self.bPlayer : self.aPlayer;
    [parser parseWithNamed:(hehe ? @"信封3key" : @"19粉色") inBundle:nil completionBlock:^(SVGAVideoEntity * _Nonnull videoItem) {
        if (videoItem != nil) {
            player.videoItem = videoItem;
            NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc] init];
            para.lineSpacing = 1.0;
            para.paragraphSpacing = 4.0;
//            [para setLineBreakMode:NSLineBreakByTruncatingTail];
//            [para setAlignment:NSTextAlignmentCenter];
            NSAttributedString *str = [[NSAttributedString alloc]
                                       initWithString:@"Hello, World! Hello, World!Hello, World! Hello, World!Hello, World! Hello, World!Hello, World! \nHello, World!"
                                       attributes:@{
                                           NSFontAttributeName: [UIFont systemFontOfSize:24],
                                           NSForegroundColorAttributeName: [UIColor blackColor],
                                           NSParagraphStyleAttributeName: para,
                                       }];
            [player setAttributedText:str forKey:@"key"];
            
            [player setAttributedText:[[NSAttributedString alloc] initWithString:@"关闭" attributes:@{
                NSFontAttributeName: [UIFont systemFontOfSize:20],
                NSForegroundColorAttributeName: [UIColor blackColor],
                NSParagraphStyleAttributeName: para,
            }] forKey:@"key3"];
            [player setEventBlock:^(SVGAPlayer *player) {
                NSLog(@"点击了发送者");
            } forKey:@"key3"];
            
            para.alignment = NSTextAlignmentRight;
            [player setEventBlock:^(SVGAPlayer *player) {
                NSLog(@"点击了关闭");
            } forKey:@"key2"];
            [player setAttributedText:[[NSAttributedString alloc] initWithString:@"发送者：茵茵" attributes:@{
                NSFontAttributeName: [UIFont systemFontOfSize:20],
                NSForegroundColorAttributeName: [UIColor blackColor],
                NSParagraphStyleAttributeName: para,
            }] forKey:@"key2"];
            
            
            
            [player startAnimation];

//                 [self.aPlayer startAnimationWithRange:NSMakeRange(10, 25) reverse:YES];
        }
    } failureBlock:nil];
    
    return;
}

- (IBAction)onSliderClick:(UISlider *)sender {
    [self.aPlayer stepToPercentage:sender.value andPlay:NO];
}

- (IBAction)onSlide:(UISlider *)sender {
    [self.aPlayer stepToPercentage:sender.value andPlay:NO];
}

- (IBAction)onChangeColor:(UIButton *)sender {
    self.view.backgroundColor = sender.backgroundColor;
}

- (IBAction)onBeginButton:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    if (sender.selected) {
        [self.aPlayer pauseAnimation];
    } else {
        [self.aPlayer stepToPercentage:(self.aSlider.value == 1 ? 0 : self.aSlider.value) andPlay:YES];
    }
}

- (IBAction)onRetreatButton:(UIButton *)sender {
    
}

- (IBAction)onForwardButton:(UIButton *)sender {
    
}


#pragma - mark SVGAPlayer Delegate
- (void)svgaPlayerDidAnimatedToPercentage:(CGFloat)percentage {
    self.aSlider.value = percentage;
}

- (void)svgaPlayerDidFinishedAnimation:(SVGAPlayer *)player {
    self.onBeginButton.selected = YES;
    [self playWithFileName:!self.nene];
}
@end
