//
//  DialogsManager.h
//  TelegramTest
//
//  Created by keepcoder on 26.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SharedManager.h"
#import "ContentDelegate.h"
@interface DialogsManager : SharedManager
@property (nonatomic,strong) id <ContentDelegate> delegate;


- (void)updateTop:(TLMessage *)message needUpdate:(BOOL)needUpdate update_real_date:(BOOL)update_real_date;

- (TL_conversation *)findByUserId:(int)user_id;
- (TL_conversation *)findByChatId:(int)user_id;
- (TL_conversation *)findBySecretId:(int)chat_id;
- (TL_conversation *)createDialogForMessage:(TLMessage *)message;
- (TL_conversation *)createDialogForUser:(TLUser *)user;
- (TL_conversation *)createDialogForChat:(TLChat *)chat;
- (TL_conversation *)createDialogEncryptedChat:(TLEncryptedChat *)chat;

- (void) insertDialog:(TL_conversation *)dialog;
- (void) markAllMessagesAsRead:(TL_conversation *)dialog;

- (void) markAllMessagesAsRead:(TLPeer *)peer max_id:(int)max_id;

- (void)deleteDialog:(TL_conversation *)dialog completeHandler:(dispatch_block_t)completeHandler;
- (void)clearHistory:(TL_conversation *)dialog completeHandler:(dispatch_block_t)block;
-(void)updateLastMessageForDialog:(TL_conversation *)dialog;
@end
