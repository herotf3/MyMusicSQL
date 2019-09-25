//
//  DBManager.h
//  My Music
//
//  Created by CPU11808 on 9/25/19.
//  Copyright © 2019 CPU11808. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBManager : NSObject

//MARK: init
-(instancetype) initWithDBFileName:(NSString*) fileName;

@end

NS_ASSUME_NONNULL_END
