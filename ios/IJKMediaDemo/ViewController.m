//
//  IJKTestController.m
//  IJKMediaDemo
//
//  Created by 鲁志刚 on 2017/5/5.
//  Copyright © 2017年 bilibili. All rights reserved.
//

#import "ViewController.h"
#import <ZGKit/ZGPlayKit.h>

@interface ViewController ()

@property (nonatomic,strong)ZGPlayKit *player;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.player = [[ZGPlayKit alloc] initWithPath:[[NSBundle mainBundle]pathForResource:@"film.mp4" ofType:nil]];
    [self.view addSubview:self.player];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.player zg_play];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.player zg_setNewPosition:0.5];
    });
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.player.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
