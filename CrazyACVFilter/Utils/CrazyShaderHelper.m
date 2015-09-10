//
//  CrazyShaderHelper.m
//  CrazyACVFilter
//
//  Created by crazylhf on 15/9/10.
//  Copyright (c) 2015年 crazylhf. All rights reserved.
//

#import "CrazyShaderHelper.h"

@implementation CrazyShaderHelper

#pragma mark - opengl program handle

+ (GLuint)glProgramWithVertexSource:(NSString *)vertexSource
                     fragmentSource:(NSString *)fragmentSource
{
    if (0 == vertexSource.length || 0 == fragmentSource.length) {
        CrazyLoge(@"create opengl program failed, vertex shader source : %@ , fragment shader source : %@", vertexSource, fragmentSource);
        return 0;
    }
    
    GLuint programHandler = glCreateProgram();
    if (0 != programHandler)
    {
        GLuint vertexShader = [self generateShader:vertexSource shaderType:GL_VERTEX_SHADER];
        if (0 == vertexShader) {
            CrazyLoge(@"create opengl program failed, because vertex shader generate failed");
            glDeleteProgram(programHandler);
            return 0;
        }
        
        GLuint fragmentShader = [self generateShader:fragmentSource shaderType:GL_FRAGMENT_SHADER];
        if (0 == fragmentShader) {
            CrazyLoge(@"create opengl program failed, because fragment shader generate failed");
            glDeleteShader(vertexShader);
            glDeleteProgram(programHandler);
            return 0;
        }
        
        glAttachShader(programHandler, vertexShader);
        glAttachShader(programHandler, fragmentShader);
        
        glLinkProgram(programHandler);
        
        glDetachShader(programHandler, vertexShader);
        glDetachShader(programHandler, fragmentShader);
        
        GLint linkResult;
        glGetProgramiv(programHandler, GL_LINK_STATUS, &linkResult);
        
        if (GL_FALSE == linkResult) {
            GLint errLogLength;
            glGetProgramiv(programHandler, GL_INFO_LOG_LENGTH, &errLogLength);
            
            GLchar * logBuffer = malloc(errLogLength + 1);
            glGetProgramInfoLog(programHandler, errLogLength + 1, 0, logBuffer);
            
            CrazyLoge(@"link opengl program failed, link error log : %s, vertex source : %@, fragment source : %@", logBuffer, vertexSource, fragmentSource);
            free(logBuffer);
            
            glDeleteProgram(programHandler);
            
            programHandler = 0;
        }
        
        glDeleteShader(vertexShader);
        glDeleteShader(fragmentShader);
    }
    return programHandler;
}


#pragma mark - generate shader

+ (GLuint)generateShader:(NSString *)shaderSource shaderType:(GLenum)shaderType
{
    if (0 == shaderSource.length || (GL_VERTEX_SHADER != shaderType && GL_FRAGMENT_SHADER != shaderType)) {
        CrazyLoge(@"generate opengl shader failed, shader type[%@] shader source : %@", @(shaderType), shaderSource);
        return 0;
    }
    
    GLuint shaderHandler = glCreateShader(shaderType);
    if (0 != shaderHandler)
    {
        const char * sourceCString = shaderSource.UTF8String;
        GLint sourceLength =  (GLint)[shaderSource lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        
        glShaderSource(shaderHandler, 1, &sourceCString, &sourceLength);
        
        glCompileShader(shaderHandler);
        
        GLint compileResult;
        glGetShaderiv(shaderHandler, GL_COMPILE_STATUS, &compileResult);
        
        if (GL_FALSE == compileResult) {
            GLint errLogLength;
            glGetShaderiv(shaderHandler, GL_INFO_LOG_LENGTH, &errLogLength);
            
            GLchar * logBuffer = malloc(errLogLength + 1);
            glGetShaderInfoLog(shaderHandler, errLogLength + 1, 0, logBuffer);
            
            CrazyLoge(@"compile shader failed, shader type[%@] error log [%s] shader source : %@", @(shaderType), logBuffer, shaderSource);
            free(logBuffer);
            
            glDeleteShader(shaderHandler);
            shaderHandler = 0;
        }
    }
    return shaderHandler;
}

@end
