//
//  OpenGLView.m
//  OpenGLLearn
//
//  Created by tomy yao on 2017/11/17.
//  Copyright © 2017年 tomy yao. All rights reserved.
//

#import "OpenGLView.h"

static float vertices[] = {
    -0.5f, -0.05f, -0.05f,
    0.5f, -0.05f, 0.0f,
    0.0f, 0.5f, 0.0f
};

@interface OpenGLView ()
@property (nonatomic, strong) CAEAGLLayer *eaglLayer;
@property (nonatomic, strong) EAGLContext *contex;
@property (nonatomic, assign) GLuint colorRenderBuffer;

@end

@implementation OpenGLView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayer];
        [self setupContex];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        [self render];
    }
    
    return self;
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)setupLayer {
    _eaglLayer = (CAEAGLLayer*)self.layer;
    _eaglLayer.opaque = YES;
}

- (void)setupContex {
    _contex = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!_contex) {
        NSLog(@"failed to create contex opengles 3");
        exit(1);
    }
    
    if (![EAGLContext setCurrentContext:_contex]) {
        NSLog(@"failed to set current opengl context");
        exit(1);
    }
    
}

- (void)setupRenderBuffer {    
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_contex renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

- (void)setupArrayBuffer {
    GLuint VBO;
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
}

- (void)setupFrameBuffer {
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, _colorRenderBuffer);
}

- (void)render {
    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    [_contex presentRenderbuffer:GL_RENDERBUFFER];

}


@end
