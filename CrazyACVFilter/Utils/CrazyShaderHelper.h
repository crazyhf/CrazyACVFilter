//
//  CrazyShaderHelper.h
//  CrazyACVFilter
//
//  Created by crazylhf on 15/9/10.
//  Copyright (c) 2015年 crazylhf. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <OpenGLES/ES2/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/EAGL.h>


#define CrazyOPENGL_SHADER_NSSTRING(_shader_source_) @ #_shader_source_


@interface CrazyShaderHelper : NSObject

+ (GLuint)glProgramWithVertexSource:(NSString *)vertexSource
                     fragmentSource:(NSString *)fragmentSource;

@end
