//
//  AllClasses.m
//  SZTXcodePlugin
//
//  Created by sun-zt on 2020/11/6.
//

#import "AllClasses.h"

#import <objc/runtime.h>
#import <dlfcn.h>
#import <mach-o/ldsyms.h>

@implementation AllClasses

//方式1
//获取当前app运行过程中，由开发者创建的类的 列表
+ (void)printClasses1 {
    unsigned int count;
    const char **classes;
    Dl_info info;

    //1.获取app的路径
    dladdr(&_mh_execute_header, &info);

    //2.返回当前运行的app的所有类的名字，并传出个数
    //classes：二维数组 存放所有类的列表名称
    //count：所有的类的个数
    classes = objc_copyClassNamesForImage(info.dli_fname, &count);

    for (int i = 0; i < count; i++) {
        //3.遍历并打印，转换Objective-C的字符串
        NSString *className = [NSString stringWithCString:classes[i] encoding:NSUTF8StringEncoding];
        Class class = NSClassFromString(className);
        NSLog(@"class name = %@", class);

    }
}

//方式2
//获取当前app运行时所用到所有的文件，包括 系统创建的类和开发者创建的类的   列表
+ (void)printClasses2 {
    int numClasses;
    Class * classes = NULL;

    //1.获取当前app运行时所有的类，包括系统创建的类和开发者创建的类的  个数
    numClasses = objc_getClassList(NULL, 0);

    if (numClasses > 0 )
    {
        //2.创建一个可以容纳numClasses个的大小空间
        classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);

        //3.重新获取具体类的列表和个数
        numClasses = objc_getClassList(classes, numClasses);

        //4.遍历
        for (int i = 0; i < numClasses; i++) {
            Class class           = classes[i];
            const char *className = class_getName(class);
            NSLog(@"class name2 = %s", className);
        }
        free(classes);
    }
}

+ (void)printClass:(Class)clz {
    unsigned int count = 0;

    //获取属性列表
    objc_property_t *propertyList = class_copyPropertyList(clz, &count);
    for (unsigned int i = 0; i < count; i++) {
        const char *propertyName = property_getName(propertyList[i]);
        NSLog(@"property ="
               ">%@",
              [NSString stringWithUTF8String:propertyName]);
    }
    free(propertyList);

    //获取方法列表
    Method *methodList = class_copyMethodList(clz, &count);
    for (unsigned int i = 0; i < count; i++) {
        Method method = methodList[i];
        NSLog(@"method ="
               ">%@",
              NSStringFromSelector(method_getName(method)));
    }
    free(methodList);

    //获取成员变量列表
    Ivar *ivarList = class_copyIvarList(clz, &count);
    for (unsigned int i = 0; i < count; i++) {
        Ivar myIvar          = ivarList[i];
        const char *ivarName = ivar_getName(myIvar);
        NSLog(@"ivar ="
               ">%@",
              [NSString stringWithUTF8String:ivarName]);
    }
    free(ivarList);
    
    //获取协议列表
    __unsafe_unretained Protocol **protocolList = class_copyProtocolList(clz, &count);
    for (unsigned int i = 0; i<count; i++) {
        Protocol *myProtocal = protocolList[i];
        const char *protocolName = protocol_getName(myProtocal);
        NSLog(@"protocol ="">%@", [NSString stringWithUTF8String:protocolName]);
    }
    free(protocolList);
}


@end
