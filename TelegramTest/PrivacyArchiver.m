//
//  PrivacyArchiver.m
//  Telegram
//
//  Created by keepcoder on 19.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "PrivacyArchiver.h"

@implementation PrivacyArchiver

NSString *const kStatusTimestamp = @"TL_privacyKeyStatusTimestamp";

-(id)initWithType:(PrivacyAllowType)type allowUsers:(NSArray *)allowUsers disallowUsers:(NSArray *)disallowUsers privacyType:(NSString *)privacyType {
    if(self = [super init]) {
        _allowUsers = allowUsers;
        _disallowUsers = disallowUsers;
        _allowType = type;
        _privacyType = privacyType;
    }
    
    return self;
}

- (void)_save {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:self] forKey:[NSString stringWithFormat:@"privacy_%@",_privacyType]];
    [defaults synchronize];
    [cache setObject:self forKey:_privacyType];
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    
    NSData * allowData = [NSKeyedArchiver archivedDataWithRootObject:_allowUsers];
    NSData * disallowData = [NSKeyedArchiver archivedDataWithRootObject:_disallowUsers];
    
    [aCoder encodeObject:allowData forKey:@"allowUsers"];
    [aCoder encodeObject:disallowData forKey:@"disallowUsers"];
    [aCoder encodeInt32:_allowType forKey:@"allowType"];
    [aCoder encodeObject:_privacyType forKey:@"privacyType"];
    
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super init]) {
        _allowUsers = [NSKeyedUnarchiver unarchiveObjectWithData:[aDecoder decodeObjectForKey:@"allowUsers"]];
        _disallowUsers = [NSKeyedUnarchiver unarchiveObjectWithData:[aDecoder decodeObjectForKey:@"disallowUsers"]];
        _allowType = [aDecoder decodeInt32ForKey:@"allowType"];
        _privacyType = [aDecoder decodeObjectForKey:@"privacyType"];
    }
    
    return self;
}

+(PrivacyArchiver *)privacyForType:(NSString *)type {
    
    PrivacyArchiver *privacy = [cache objectForKey:type];
    
    if(!privacy) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSData *privacyData = [defaults objectForKey:[NSString stringWithFormat:@"privacy_%@",type]];
        
        privacy = [NSKeyedUnarchiver unarchiveObjectWithData:privacyData];
        
        if(privacy)
            [cache setObject:privacy forKey:type];
    }
    
    
    
    return privacy;
}

+(PrivacyArchiver *)privacyFromRules:(NSArray *)rules forKey:(NSString *)key {
    
    __block NSArray *disallowUsers = [[NSArray alloc] init];
    __block NSArray *allowUsers = [[NSArray alloc] init];
    __block PrivacyAllowType allowType = PrivacyAllowTypeNobody;
    
    [rules enumerateObjectsUsingBlock:^(TGPrivacyRule *rule, NSUInteger idx, BOOL *stop) {
        
        if([rule isKindOfClass:[TL_privacyValueAllowUsers class]]) {
            allowUsers = [rule users];
        }
        
        if([rule isKindOfClass:[TL_privacyValueDisallowUsers class]]) {
            disallowUsers = [rule users];
        }
        
        if([rule isKindOfClass:[TL_privacyValueAllowContacts class]]) {
            allowType = PrivacyAllowTypeContacts;
        }
        
        if([rule isKindOfClass:[TL_privacyValueAllowAll class]]) {
            allowType = PrivacyAllowTypeEverbody;
        }
        
    }];
    
    return [[PrivacyArchiver alloc] initWithType:allowType allowUsers:allowUsers disallowUsers:disallowUsers privacyType:key];

}


-(NSArray *)rules {
    NSMutableArray *rules = [[NSMutableArray alloc] init];
    
    
    NSMutableArray *allow = [[NSMutableArray alloc] init];
    NSMutableArray *disallow = [[NSMutableArray alloc] init];
    
    [self.allowUsers enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
        
        TGUser *user = [[UsersManager sharedManager] find:[obj intValue]];
        
        [allow addObject:user.inputUser];
        
    }];
    
    [self.disallowUsers enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
        
        TGUser *user = [[UsersManager sharedManager] find:[obj intValue]];
        
        [disallow addObject:user.inputUser];
        
    }];
    
    switch (self.allowType) {
        case PrivacyAllowTypeEverbody:
            
            [rules addObject:[TL_inputPrivacyValueAllowAll create]];
            
            if(self.disallowUsers.count > 0)
                [rules addObject:[TL_inputPrivacyValueDisallowUsers create:disallow]];
            
            break;
        case PrivacyAllowTypeContacts:
            
            [rules addObject:[TL_inputPrivacyValueAllowContacts create]];
            
            if(self.disallowUsers.count > 0)
                [rules addObject:[TL_inputPrivacyValueDisallowUsers create:disallow]];
            
            if(self.allowUsers.count > 0)
                [rules addObject:[TL_inputPrivacyValueAllowUsers create:allow]];
            
            break;
        case PrivacyAllowTypeNobody:
            
            if(self.allowUsers.count > 0)
                [rules addObject:[TL_inputPrivacyValueAllowUsers create:allow]];
            
            break;
            
        default:
            break;
    }
    
    return rules;
}

-(id)copy {
    return [[PrivacyArchiver alloc] initWithType:self.allowType allowUsers:self.allowUsers disallowUsers:self.disallowUsers privacyType:self.privacyType];
}


static NSMutableDictionary *cache;

+(void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[NSMutableDictionary alloc] init];
    });
}


@end