//
//  ViewController.m
//  OpenGLLearn
//
//  Created by tomy yao on 2017/11/17.
//  Copyright © 2017年 tomy yao. All rights reserved.
//

#import "ViewController.h"
#import "OpenGLView.h"

@interface ViewController ()
@property (nonatomic, strong) OpenGLView *openGLView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _openGLView = [[OpenGLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_openGLView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
