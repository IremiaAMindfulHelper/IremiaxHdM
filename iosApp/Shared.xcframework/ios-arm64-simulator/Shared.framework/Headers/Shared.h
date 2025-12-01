#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSError.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSString.h>
#import <Foundation/NSValue.h>

@class Interop, KmpCancelable, Mantra, MantrasController, MantrasState, NSBundle, NSData, NSError, NSLocale, NSURL, SharedAssetResource, SharedColor, SharedColorCompanion, SharedColorDescCompanion, SharedColorResource, SharedCompositionStringDesc, SharedDatabase, SharedDatabaseProvider, SharedDriverFactory, SharedFactory, SharedFileResource, SharedFontResource, SharedImageDescCompanion, SharedImageDescResource, SharedImageDescUrl, SharedImageResource, SharedKotlinAbstractCoroutineContextElement, SharedKotlinAbstractCoroutineContextKey<B, E>, SharedKotlinArray<T>, SharedKotlinByteArray, SharedKotlinByteIterator, SharedKotlinCancellationException, SharedKotlinException, SharedKotlinIllegalStateException, SharedKotlinRuntimeException, SharedKotlinThrowable, SharedKotlinUnit, SharedKotlinx_coroutines_coreCoroutineDispatcher, SharedKotlinx_coroutines_coreCoroutineDispatcherKey, SharedMantra, SharedMantraDao, SharedMantraQueries, SharedMantraRepository, SharedNavigationState, SharedNavigationTarget, SharedNavigationTargetContacts, SharedNavigationTargetHome, SharedNavigationTargetProfile, SharedNavigationTargetReflection, SharedNavigationTargetSOS, SharedPluralFormattedStringDesc, SharedPluralStringDesc, SharedPluralsResource, SharedRawStringDesc, SharedResourceFormattedStringDesc, SharedResourcePlatformDetails, SharedResourceStringDesc, SharedRuntimeAfterVersion, SharedRuntimeBaseTransacterImpl, SharedRuntimeExecutableQuery<__covariant RowType>, SharedRuntimeQuery<__covariant RowType>, SharedRuntimeTransacterImpl, SharedRuntimeTransacterTransaction, SharedSharedColors, SharedSharedRes, SharedSharedResColors, SharedSharedResImages, SharedSharedResStrings, SharedStringDescCompanion, SharedStringDescLocaleType, SharedStringDescLocaleTypeSystem, SharedStringResource, SharedUserDataCompanion, SharedUtils, UIColor, UIFont, UIImage;

@protocol SharedColorDesc, SharedImageDesc, SharedKotlinContinuation, SharedKotlinContinuationInterceptor, SharedKotlinCoroutineContext, SharedKotlinCoroutineContextElement, SharedKotlinCoroutineContextKey, SharedKotlinIterator, SharedKotlinSequence, SharedKotlinx_coroutines_coreChildHandle, SharedKotlinx_coroutines_coreChildJob, SharedKotlinx_coroutines_coreCoroutineScope, SharedKotlinx_coroutines_coreDisposableHandle, SharedKotlinx_coroutines_coreFlow, SharedKotlinx_coroutines_coreFlowCollector, SharedKotlinx_coroutines_coreJob, SharedKotlinx_coroutines_coreParentJob, SharedKotlinx_coroutines_coreRunnable, SharedKotlinx_coroutines_coreSelectClause, SharedKotlinx_coroutines_coreSelectClause0, SharedKotlinx_coroutines_coreSelectInstance, SharedKotlinx_coroutines_coreSharedFlow, SharedKotlinx_coroutines_coreStateFlow, SharedResourceContainer, SharedRuntimeCloseable, SharedRuntimeQueryListener, SharedRuntimeQueryResult, SharedRuntimeSqlCursor, SharedRuntimeSqlDriver, SharedRuntimeSqlPreparedStatement, SharedRuntimeSqlSchema, SharedRuntimeTransacter, SharedRuntimeTransacterBase, SharedRuntimeTransactionCallbacks, SharedRuntimeTransactionWithReturn, SharedRuntimeTransactionWithoutReturn, SharedStringDesc, SharedUserData;

NS_ASSUME_NONNULL_BEGIN
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunknown-warning-option"
#pragma clang diagnostic ignored "-Wincompatible-property-type"
#pragma clang diagnostic ignored "-Wnullability"

#pragma push_macro("_Nullable_result")
#if !__has_feature(nullability_nullable_result)
#undef _Nullable_result
#define _Nullable_result _Nullable
#endif

__attribute__((swift_name("KotlinBase")))
@interface SharedBase : NSObject
- (instancetype)init __attribute__((unavailable));
+ (instancetype)new __attribute__((unavailable));
+ (void)initialize __attribute__((objc_requires_super));
@end

@interface SharedBase (SharedBaseCopying) <NSCopying>
@end

__attribute__((swift_name("KotlinMutableSet")))
@interface SharedMutableSet<ObjectType> : NSMutableSet<ObjectType>
@end

__attribute__((swift_name("KotlinMutableDictionary")))
@interface SharedMutableDictionary<KeyType, ObjectType> : NSMutableDictionary<KeyType, ObjectType>
@end

@interface NSError (NSErrorSharedKotlinException)
@property (readonly) id _Nullable kotlinException;
@end

__attribute__((swift_name("KotlinNumber")))
@interface SharedNumber : NSNumber
- (instancetype)initWithChar:(char)value __attribute__((unavailable));
- (instancetype)initWithUnsignedChar:(unsigned char)value __attribute__((unavailable));
- (instancetype)initWithShort:(short)value __attribute__((unavailable));
- (instancetype)initWithUnsignedShort:(unsigned short)value __attribute__((unavailable));
- (instancetype)initWithInt:(int)value __attribute__((unavailable));
- (instancetype)initWithUnsignedInt:(unsigned int)value __attribute__((unavailable));
- (instancetype)initWithLong:(long)value __attribute__((unavailable));
- (instancetype)initWithUnsignedLong:(unsigned long)value __attribute__((unavailable));
- (instancetype)initWithLongLong:(long long)value __attribute__((unavailable));
- (instancetype)initWithUnsignedLongLong:(unsigned long long)value __attribute__((unavailable));
- (instancetype)initWithFloat:(float)value __attribute__((unavailable));
- (instancetype)initWithDouble:(double)value __attribute__((unavailable));
- (instancetype)initWithBool:(BOOL)value __attribute__((unavailable));
- (instancetype)initWithInteger:(NSInteger)value __attribute__((unavailable));
- (instancetype)initWithUnsignedInteger:(NSUInteger)value __attribute__((unavailable));
+ (instancetype)numberWithChar:(char)value __attribute__((unavailable));
+ (instancetype)numberWithUnsignedChar:(unsigned char)value __attribute__((unavailable));
+ (instancetype)numberWithShort:(short)value __attribute__((unavailable));
+ (instancetype)numberWithUnsignedShort:(unsigned short)value __attribute__((unavailable));
+ (instancetype)numberWithInt:(int)value __attribute__((unavailable));
+ (instancetype)numberWithUnsignedInt:(unsigned int)value __attribute__((unavailable));
+ (instancetype)numberWithLong:(long)value __attribute__((unavailable));
+ (instancetype)numberWithUnsignedLong:(unsigned long)value __attribute__((unavailable));
+ (instancetype)numberWithLongLong:(long long)value __attribute__((unavailable));
+ (instancetype)numberWithUnsignedLongLong:(unsigned long long)value __attribute__((unavailable));
+ (instancetype)numberWithFloat:(float)value __attribute__((unavailable));
+ (instancetype)numberWithDouble:(double)value __attribute__((unavailable));
+ (instancetype)numberWithBool:(BOOL)value __attribute__((unavailable));
+ (instancetype)numberWithInteger:(NSInteger)value __attribute__((unavailable));
+ (instancetype)numberWithUnsignedInteger:(NSUInteger)value __attribute__((unavailable));
@end

__attribute__((swift_name("KotlinByte")))
@interface SharedByte : SharedNumber
- (instancetype)initWithChar:(char)value;
+ (instancetype)numberWithChar:(char)value;
@end

__attribute__((swift_name("KotlinUByte")))
@interface SharedUByte : SharedNumber
- (instancetype)initWithUnsignedChar:(unsigned char)value;
+ (instancetype)numberWithUnsignedChar:(unsigned char)value;
@end

__attribute__((swift_name("KotlinShort")))
@interface SharedShort : SharedNumber
- (instancetype)initWithShort:(short)value;
+ (instancetype)numberWithShort:(short)value;
@end

__attribute__((swift_name("KotlinUShort")))
@interface SharedUShort : SharedNumber
- (instancetype)initWithUnsignedShort:(unsigned short)value;
+ (instancetype)numberWithUnsignedShort:(unsigned short)value;
@end

__attribute__((swift_name("KotlinInt")))
@interface SharedInt : SharedNumber
- (instancetype)initWithInt:(int)value;
+ (instancetype)numberWithInt:(int)value;
@end

__attribute__((swift_name("KotlinUInt")))
@interface SharedUInt : SharedNumber
- (instancetype)initWithUnsignedInt:(unsigned int)value;
+ (instancetype)numberWithUnsignedInt:(unsigned int)value;
@end

__attribute__((swift_name("KotlinLong")))
@interface SharedLong : SharedNumber
- (instancetype)initWithLongLong:(long long)value;
+ (instancetype)numberWithLongLong:(long long)value;
@end

__attribute__((swift_name("KotlinULong")))
@interface SharedULong : SharedNumber
- (instancetype)initWithUnsignedLongLong:(unsigned long long)value;
+ (instancetype)numberWithUnsignedLongLong:(unsigned long long)value;
@end

__attribute__((swift_name("KotlinFloat")))
@interface SharedFloat : SharedNumber
- (instancetype)initWithFloat:(float)value;
+ (instancetype)numberWithFloat:(float)value;
@end

__attribute__((swift_name("KotlinDouble")))
@interface SharedDouble : SharedNumber
- (instancetype)initWithDouble:(double)value;
+ (instancetype)numberWithDouble:(double)value;
@end

__attribute__((swift_name("KotlinBoolean")))
@interface SharedBoolean : SharedNumber
- (instancetype)initWithBool:(BOOL)value;
+ (instancetype)numberWithBool:(BOOL)value;
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Mantra")))
@interface SharedMantra : SharedBase
- (instancetype)initWithId:(int64_t)id text:(NSString *)text __attribute__((swift_name("init(id:text:)"))) __attribute__((objc_designated_initializer));
- (SharedMantra *)doCopyId:(int64_t)id text:(NSString *)text __attribute__((swift_name("doCopy(id:text:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) int64_t id __attribute__((swift_name("id")));
@property (readonly) NSString *text __attribute__((swift_name("text")));
@end

__attribute__((swift_name("RuntimeBaseTransacterImpl")))
@interface SharedRuntimeBaseTransacterImpl : SharedBase
- (instancetype)initWithDriver:(id<SharedRuntimeSqlDriver>)driver __attribute__((swift_name("init(driver:)"))) __attribute__((objc_designated_initializer));

/**
 * @note This method has protected visibility in Kotlin source and is intended only for use by subclasses.
*/
- (NSString *)createArgumentsCount:(int32_t)count __attribute__((swift_name("createArguments(count:)")));

/**
 * @note This method has protected visibility in Kotlin source and is intended only for use by subclasses.
*/
- (void)notifyQueriesIdentifier:(int32_t)identifier tableProvider:(void (^)(SharedKotlinUnit *(^)(NSString *)))tableProvider __attribute__((swift_name("notifyQueries(identifier:tableProvider:)")));

/**
 * @note This method has protected visibility in Kotlin source and is intended only for use by subclasses.
*/
- (id _Nullable)postTransactionCleanupTransaction:(SharedRuntimeTransacterTransaction *)transaction enclosing:(SharedRuntimeTransacterTransaction * _Nullable)enclosing thrownException:(SharedKotlinThrowable * _Nullable)thrownException returnValue:(id _Nullable)returnValue __attribute__((swift_name("postTransactionCleanup(transaction:enclosing:thrownException:returnValue:)")));

/**
 * @note This property has protected visibility in Kotlin source and is intended only for use by subclasses.
*/
@property (readonly) id<SharedRuntimeSqlDriver> driver __attribute__((swift_name("driver")));
@end

__attribute__((swift_name("RuntimeTransacterBase")))
@protocol SharedRuntimeTransacterBase
@required
@end

__attribute__((swift_name("RuntimeTransacter")))
@protocol SharedRuntimeTransacter <SharedRuntimeTransacterBase>
@required
- (void)transactionNoEnclosing:(BOOL)noEnclosing body:(void (^)(id<SharedRuntimeTransactionWithoutReturn>))body __attribute__((swift_name("transaction(noEnclosing:body:)")));
- (id _Nullable)transactionWithResultNoEnclosing:(BOOL)noEnclosing bodyWithReturn:(id _Nullable (^)(id<SharedRuntimeTransactionWithReturn>))bodyWithReturn __attribute__((swift_name("transactionWithResult(noEnclosing:bodyWithReturn:)")));
@end

__attribute__((swift_name("RuntimeTransacterImpl")))
@interface SharedRuntimeTransacterImpl : SharedRuntimeBaseTransacterImpl <SharedRuntimeTransacter>
- (instancetype)initWithDriver:(id<SharedRuntimeSqlDriver>)driver __attribute__((swift_name("init(driver:)"))) __attribute__((objc_designated_initializer));
- (void)transactionNoEnclosing:(BOOL)noEnclosing body:(void (^)(id<SharedRuntimeTransactionWithoutReturn>))body __attribute__((swift_name("transaction(noEnclosing:body:)")));
- (id _Nullable)transactionWithResultNoEnclosing:(BOOL)noEnclosing bodyWithReturn:(id _Nullable (^)(id<SharedRuntimeTransactionWithReturn>))bodyWithReturn __attribute__((swift_name("transactionWithResult(noEnclosing:bodyWithReturn:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("MantraQueries")))
@interface SharedMantraQueries : SharedRuntimeTransacterImpl
- (instancetype)initWithDriver:(id<SharedRuntimeSqlDriver>)driver __attribute__((swift_name("init(driver:)"))) __attribute__((objc_designated_initializer));
- (id<SharedRuntimeQueryResult>)deleteByIdId:(int64_t)id __attribute__((swift_name("deleteById(id:)")));
- (id<SharedRuntimeQueryResult>)insertOneText:(NSString *)text __attribute__((swift_name("insertOne(text:)")));
- (SharedRuntimeQuery<SharedMantra *> *)selectAll __attribute__((swift_name("selectAll()")));
- (SharedRuntimeQuery<id> *)selectAllMapper:(id (^)(SharedLong *, NSString *))mapper __attribute__((swift_name("selectAll(mapper:)")));
- (SharedRuntimeQuery<SharedMantra *> *)selectByIdId:(int64_t)id __attribute__((swift_name("selectById(id:)")));
- (SharedRuntimeQuery<id> *)selectByIdId:(int64_t)id mapper:(id (^)(SharedLong *, NSString *))mapper __attribute__((swift_name("selectById(id:mapper:)")));
@end

__attribute__((swift_name("UserData")))
@protocol SharedUserData <SharedRuntimeTransacter>
@required
@property (readonly) SharedMantraQueries *mantraQueries __attribute__((swift_name("mantraQueries")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("UserDataCompanion")))
@interface SharedUserDataCompanion : SharedBase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedUserDataCompanion *shared __attribute__((swift_name("shared")));
- (id<SharedUserData>)invokeDriver:(id<SharedRuntimeSqlDriver>)driver __attribute__((swift_name("invoke(driver:)")));
@property (readonly) id<SharedRuntimeSqlSchema> Schema __attribute__((swift_name("Schema")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Color")))
@interface SharedColor : SharedBase
- (instancetype)initWithColorRGBA:(int64_t)colorRGBA __attribute__((swift_name("init(colorRGBA:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithRed:(int32_t)red green:(int32_t)green blue:(int32_t)blue alpha:(int32_t)alpha __attribute__((swift_name("init(red:green:blue:alpha:)"))) __attribute__((objc_designated_initializer));
@property (class, readonly, getter=companion) SharedColorCompanion *companion __attribute__((swift_name("companion")));
- (SharedColor *)doCopyRed:(int32_t)red green:(int32_t)green blue:(int32_t)blue alpha:(int32_t)alpha __attribute__((swift_name("doCopy(red:green:blue:alpha:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) int32_t alpha __attribute__((swift_name("alpha")));
@property (readonly) int64_t argb __attribute__((swift_name("argb")));
@property (readonly) int32_t blue __attribute__((swift_name("blue")));
@property (readonly) int32_t green __attribute__((swift_name("green")));
@property (readonly) int32_t red __attribute__((swift_name("red")));
@property (readonly) int64_t rgba __attribute__((swift_name("rgba")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Color.Companion")))
@interface SharedColorCompanion : SharedBase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedColorCompanion *shared __attribute__((swift_name("shared")));
@end

__attribute__((swift_name("FileResource")))
@interface SharedFileResource : SharedBase
- (instancetype)initWithFileName:(NSString *)fileName extension:(NSString *)extension bundle:(NSBundle *)bundle __attribute__((swift_name("init(fileName:extension:bundle:)"))) __attribute__((objc_designated_initializer));
- (NSString *)readText __attribute__((swift_name("readText()")));
@property (readonly) NSBundle *bundle __attribute__((swift_name("bundle")));
@property (readonly) NSString *extension __attribute__((swift_name("extension")));
@property (readonly) NSString *fileName __attribute__((swift_name("fileName")));
@property (readonly) NSString *path __attribute__((swift_name("path")));
@property (readonly) NSURL *url __attribute__((swift_name("url")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("AssetResource")))
@interface SharedAssetResource : SharedFileResource
- (instancetype)initWithOriginalPath:(NSString *)originalPath fileName:(NSString *)fileName extension:(NSString *)extension bundle:(NSBundle *)bundle __attribute__((swift_name("init(originalPath:fileName:extension:bundle:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithFileName:(NSString *)fileName extension:(NSString *)extension bundle:(NSBundle *)bundle __attribute__((swift_name("init(fileName:extension:bundle:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
@property (readonly) NSString *originalPath __attribute__((swift_name("originalPath")));
@property (readonly) NSString *path __attribute__((swift_name("path")));
@property (readonly) NSURL *url __attribute__((swift_name("url")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ColorResource")))
@interface SharedColorResource : SharedBase
- (instancetype)initWithName:(NSString *)name bundle:(NSBundle *)bundle __attribute__((swift_name("init(name:bundle:)"))) __attribute__((objc_designated_initializer));
@property (readonly) NSBundle *bundle __attribute__((swift_name("bundle")));
@property (readonly) NSString *name __attribute__((swift_name("name")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("FontResource")))
@interface SharedFontResource : SharedBase
- (instancetype)initWithFontName:(NSString *)fontName bundle:(NSBundle *)bundle __attribute__((swift_name("init(fontName:bundle:)"))) __attribute__((objc_designated_initializer));

/**
 * @note This method converts instances of ObjCErrorException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (BOOL)registerFontAndReturnError:(NSError * _Nullable * _Nullable)error __attribute__((swift_name("registerFont()")));
@property (readonly) NSBundle *bundle __attribute__((swift_name("bundle")));
@property (readonly) NSData *data __attribute__((swift_name("data")));
@property (readonly) NSString *filePath __attribute__((swift_name("filePath")));
@property (readonly) NSString *fontName __attribute__((swift_name("fontName")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ImageResource")))
@interface SharedImageResource : SharedBase
- (instancetype)initWithAssetImageName:(NSString *)assetImageName bundle:(NSBundle *)bundle __attribute__((swift_name("init(assetImageName:bundle:)"))) __attribute__((objc_designated_initializer));
- (SharedImageResource *)doCopyAssetImageName:(NSString *)assetImageName bundle:(NSBundle *)bundle __attribute__((swift_name("doCopy(assetImageName:bundle:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
- (UIImage * _Nullable)toUIImage __attribute__((swift_name("toUIImage()")));
@property (readonly) NSString *assetImageName __attribute__((swift_name("assetImageName")));
@property (readonly) NSBundle *bundle __attribute__((swift_name("bundle")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PluralsResource")))
@interface SharedPluralsResource : SharedBase
- (instancetype)initWithResourceId:(NSString *)resourceId bundle:(NSBundle *)bundle __attribute__((swift_name("init(resourceId:bundle:)"))) __attribute__((objc_designated_initializer));
@property (readonly) NSBundle *bundle __attribute__((swift_name("bundle")));
@property (readonly) NSString *resourceId __attribute__((swift_name("resourceId")));
@end

__attribute__((swift_name("KotlinThrowable")))
@interface SharedKotlinThrowable : SharedBase
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (instancetype)initWithMessage:(NSString * _Nullable)message __attribute__((swift_name("init(message:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithCause:(SharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(cause:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(SharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer));

/**
 * @note annotations
 *   kotlin.experimental.ExperimentalNativeApi
*/
- (SharedKotlinArray<NSString *> *)getStackTrace __attribute__((swift_name("getStackTrace()")));
- (void)printStackTrace __attribute__((swift_name("printStackTrace()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) SharedKotlinThrowable * _Nullable cause __attribute__((swift_name("cause")));
@property (readonly) NSString * _Nullable message __attribute__((swift_name("message")));
- (NSError *)asError __attribute__((swift_name("asError()")));
@end

__attribute__((swift_name("KotlinException")))
@interface SharedKotlinException : SharedKotlinThrowable
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (instancetype)initWithMessage:(NSString * _Nullable)message __attribute__((swift_name("init(message:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithCause:(SharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(cause:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(SharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ReadFileTextException")))
@interface SharedReadFileTextException : SharedKotlinException
- (instancetype)initWithFileResource:(SharedFileResource *)fileResource info:(NSString *)info __attribute__((swift_name("init(fileResource:info:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithFileResource:(SharedFileResource *)fileResource error:(NSError *)error __attribute__((swift_name("init(fileResource:error:)"))) __attribute__((objc_designated_initializer));
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (instancetype)new __attribute__((unavailable));
- (instancetype)initWithMessage:(NSString * _Nullable)message __attribute__((swift_name("init(message:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
- (instancetype)initWithCause:(SharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(cause:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(SharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
@property (readonly) SharedFileResource *fileResource __attribute__((swift_name("fileResource")));
@property (readonly) NSString *info __attribute__((swift_name("info")));
@end

__attribute__((swift_name("ResourceContainer")))
@protocol SharedResourceContainer
@required
- (NSArray<id> *)values __attribute__((swift_name("values()")));
@property (readonly) SharedResourcePlatformDetails *__platformDetails __attribute__((swift_name("__platformDetails")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ResourcePlatformDetails")))
@interface SharedResourcePlatformDetails : SharedBase
- (instancetype)initWithNsBundle:(NSBundle *)nsBundle __attribute__((swift_name("init(nsBundle:)"))) __attribute__((objc_designated_initializer));
@property (readonly) NSBundle *nsBundle __attribute__((swift_name("nsBundle")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("StringResource")))
@interface SharedStringResource : SharedBase
- (instancetype)initWithResourceId:(NSString *)resourceId bundle:(NSBundle *)bundle __attribute__((swift_name("init(resourceId:bundle:)"))) __attribute__((objc_designated_initializer));
- (SharedStringResource *)doCopyResourceId:(NSString *)resourceId bundle:(NSBundle *)bundle __attribute__((swift_name("doCopy(resourceId:bundle:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) NSBundle *bundle __attribute__((swift_name("bundle")));
@property (readonly) NSString *resourceId __attribute__((swift_name("resourceId")));
@end

__attribute__((swift_name("StringDesc")))
@protocol SharedStringDesc
@required
- (NSString *)localized __attribute__((swift_name("localized()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("CompositionStringDesc")))
@interface SharedCompositionStringDesc : SharedBase <SharedStringDesc>
- (instancetype)initWithArgs:(id)args separator:(NSString * _Nullable)separator __attribute__((swift_name("init(args:separator:)"))) __attribute__((objc_designated_initializer));
- (SharedCompositionStringDesc *)doCopyArgs:(id)args separator:(NSString * _Nullable)separator __attribute__((swift_name("doCopy(args:separator:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)localized __attribute__((swift_name("localized()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) id args __attribute__((swift_name("args")));
@property (readonly) NSString * _Nullable separator __attribute__((swift_name("separator")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PluralFormattedStringDesc")))
@interface SharedPluralFormattedStringDesc : SharedBase <SharedStringDesc>
- (instancetype)initWithPluralsRes:(SharedPluralsResource *)pluralsRes number:(int32_t)number args:(NSArray<id> *)args __attribute__((swift_name("init(pluralsRes:number:args:)"))) __attribute__((objc_designated_initializer));
- (SharedPluralFormattedStringDesc *)doCopyPluralsRes:(SharedPluralsResource *)pluralsRes number:(int32_t)number args:(NSArray<id> *)args __attribute__((swift_name("doCopy(pluralsRes:number:args:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)localized __attribute__((swift_name("localized()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) NSArray<id> *args __attribute__((swift_name("args")));
@property (readonly) int32_t number __attribute__((swift_name("number")));
@property (readonly) SharedPluralsResource *pluralsRes __attribute__((swift_name("pluralsRes")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PluralStringDesc")))
@interface SharedPluralStringDesc : SharedBase <SharedStringDesc>
- (instancetype)initWithPluralsRes:(SharedPluralsResource *)pluralsRes number:(int32_t)number __attribute__((swift_name("init(pluralsRes:number:)"))) __attribute__((objc_designated_initializer));
- (SharedPluralStringDesc *)doCopyPluralsRes:(SharedPluralsResource *)pluralsRes number:(int32_t)number __attribute__((swift_name("doCopy(pluralsRes:number:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)localized __attribute__((swift_name("localized()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) int32_t number __attribute__((swift_name("number")));
@property (readonly) SharedPluralsResource *pluralsRes __attribute__((swift_name("pluralsRes")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("RawStringDesc")))
@interface SharedRawStringDesc : SharedBase <SharedStringDesc>
- (instancetype)initWithString:(NSString *)string __attribute__((swift_name("init(string:)"))) __attribute__((objc_designated_initializer));
- (SharedRawStringDesc *)doCopyString:(NSString *)string __attribute__((swift_name("doCopy(string:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)localized __attribute__((swift_name("localized()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) NSString *string __attribute__((swift_name("string")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ResourceFormattedStringDesc")))
@interface SharedResourceFormattedStringDesc : SharedBase <SharedStringDesc>
- (instancetype)initWithStringRes:(SharedStringResource *)stringRes args:(NSArray<id> *)args __attribute__((swift_name("init(stringRes:args:)"))) __attribute__((objc_designated_initializer));
- (SharedResourceFormattedStringDesc *)doCopyStringRes:(SharedStringResource *)stringRes args:(NSArray<id> *)args __attribute__((swift_name("doCopy(stringRes:args:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)localized __attribute__((swift_name("localized()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) NSArray<id> *args __attribute__((swift_name("args")));
@property (readonly) SharedStringResource *stringRes __attribute__((swift_name("stringRes")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ResourceStringDesc")))
@interface SharedResourceStringDesc : SharedBase <SharedStringDesc>
- (instancetype)initWithStringRes:(SharedStringResource *)stringRes __attribute__((swift_name("init(stringRes:)"))) __attribute__((objc_designated_initializer));
- (SharedResourceStringDesc *)doCopyStringRes:(SharedStringResource *)stringRes __attribute__((swift_name("doCopy(stringRes:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)localized __attribute__((swift_name("localized()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) SharedStringResource *stringRes __attribute__((swift_name("stringRes")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("StringDescCompanion")))
@interface SharedStringDescCompanion : SharedBase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedStringDescCompanion *shared __attribute__((swift_name("shared")));
@property SharedStringDescLocaleType *localeType __attribute__((swift_name("localeType")));
@end

__attribute__((swift_name("StringDescLocaleType")))
@interface SharedStringDescLocaleType : SharedBase
- (NSBundle *)getLocaleBundleRootBundle:(NSBundle *)rootBundle __attribute__((swift_name("getLocaleBundle(rootBundle:)")));
@property (readonly) NSLocale *locale __attribute__((swift_name("locale")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("StringDescLocaleType.Custom")))
@interface SharedStringDescLocaleTypeCustom : SharedStringDescLocaleType
- (instancetype)initWithLocale:(NSString *)locale __attribute__((swift_name("init(locale:)"))) __attribute__((objc_designated_initializer));
- (NSBundle *)getLocaleBundleRootBundle:(NSBundle *)rootBundle __attribute__((swift_name("getLocaleBundle(rootBundle:)")));
@property (readonly) NSLocale *locale __attribute__((swift_name("locale")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("StringDescLocaleType.System")))
@interface SharedStringDescLocaleTypeSystem : SharedStringDescLocaleType
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)system __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedStringDescLocaleTypeSystem *shared __attribute__((swift_name("shared")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSBundle *)getLocaleBundleRootBundle:(NSBundle *)rootBundle __attribute__((swift_name("getLocaleBundle(rootBundle:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) NSLocale *locale __attribute__((swift_name("locale")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Utils")))
@interface SharedUtils : SharedBase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)utils __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedUtils *shared __attribute__((swift_name("shared")));
- (NSString *)localizedStringStringRes:(SharedStringResource *)stringRes __attribute__((swift_name("localizedString(stringRes:)")));
- (SharedKotlinArray<id> *)processArgsArgs:(NSArray<id> *)args __attribute__((swift_name("processArgs(args:)")));
- (NSString *)stringWithFormatFormat:(NSString *)format args:(SharedKotlinArray<id> *)args __attribute__((swift_name("stringWithFormat(format:args:)")));
@property (readonly) NSString *BASE_LOCALIZATION __attribute__((swift_name("BASE_LOCALIZATION")));
@end

__attribute__((swift_name("ColorDesc")))
@protocol SharedColorDesc
@required
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ColorDescCompanion")))
@interface SharedColorDescCompanion : SharedBase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedColorDescCompanion *shared __attribute__((swift_name("shared")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ColorDescResource")))
@interface SharedColorDescResource : SharedBase <SharedColorDesc>
- (instancetype)initWithResource:(SharedColorResource *)resource __attribute__((swift_name("init(resource:)"))) __attribute__((objc_designated_initializer));
@property (readonly) SharedColorResource *resource __attribute__((swift_name("resource")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ColorDescSingle")))
@interface SharedColorDescSingle : SharedBase <SharedColorDesc>
- (instancetype)initWithColor:(SharedColor *)color __attribute__((swift_name("init(color:)"))) __attribute__((objc_designated_initializer));
@property (readonly) SharedColor *color __attribute__((swift_name("color")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ColorDescThemed")))
@interface SharedColorDescThemed : SharedBase <SharedColorDesc>
- (instancetype)initWithLightColor:(SharedColor *)lightColor darkColor:(SharedColor *)darkColor __attribute__((swift_name("init(lightColor:darkColor:)"))) __attribute__((objc_designated_initializer));
@property (readonly) SharedColor *darkColor __attribute__((swift_name("darkColor")));
@property (readonly) SharedColor *lightColor __attribute__((swift_name("lightColor")));
@end

__attribute__((swift_name("ImageDesc")))
@protocol SharedImageDesc
@required
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ImageDescCompanion")))
@interface SharedImageDescCompanion : SharedBase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedImageDescCompanion *shared __attribute__((swift_name("shared")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ImageDescResource")))
@interface SharedImageDescResource : SharedBase <SharedImageDesc>
- (instancetype)initWithResource:(SharedImageResource *)resource __attribute__((swift_name("init(resource:)"))) __attribute__((objc_designated_initializer));
- (SharedImageDescResource *)doCopyResource:(SharedImageResource *)resource __attribute__((swift_name("doCopy(resource:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) SharedImageResource *resource __attribute__((swift_name("resource")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ImageDescUrl")))
@interface SharedImageDescUrl : SharedBase <SharedImageDesc>
- (instancetype)initWithUrl:(NSString *)url __attribute__((swift_name("init(url:)"))) __attribute__((objc_designated_initializer));
- (SharedImageDescUrl *)doCopyUrl:(NSString *)url __attribute__((swift_name("doCopy(url:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) NSString *url __attribute__((swift_name("url")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SharedColors")))
@interface SharedSharedColors : SharedBase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)sharedColors __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedSharedColors *shared __attribute__((swift_name("shared")));
- (UIColor *)background __attribute__((swift_name("background()")));
- (UIColor *)error __attribute__((swift_name("error()")));
- (UIColor *)primary __attribute__((swift_name("primary()")));
- (UIColor *)secondary __attribute__((swift_name("secondary()")));
@end

__attribute__((objc_subclassing_restricted))
@interface SharedFactory : SharedBase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)sharedFactory __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedFactory *shared __attribute__((swift_name("shared")));
- (id<SharedUserData>)createDatabaseDriverFactory:(SharedDriverFactory *)driverFactory dbName:(NSString *)dbName __attribute__((swift_name("createDatabase(driverFactory:dbName:)")));
- (MantrasController *)createMantrasControllerDriverFactory:(SharedDriverFactory *)driverFactory __attribute__((swift_name("createMantrasController(driverFactory:)")));
@end

__attribute__((objc_subclassing_restricted))
@interface MantrasController : SharedBase
- (instancetype)initWithRepo:(SharedMantraRepository *)repo scope:(id<SharedKotlinx_coroutines_coreCoroutineScope>)scope __attribute__((swift_name("init(repo:scope:)"))) __attribute__((objc_designated_initializer));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)addText:(NSString *)text completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("add(text:completionHandler:)")));
- (void)addAsyncText:(NSString *)text onDone:(void (^)(SharedKotlinThrowable * _Nullable))onDone __attribute__((swift_name("addAsync(text:onDone:)")));
- (void)clear __attribute__((swift_name("clear()")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)removeId:(int64_t)id completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("remove(id:completionHandler:)")));
- (void)removeAsyncId:(int64_t)id onDone:(void (^)(SharedKotlinThrowable * _Nullable))onDone __attribute__((swift_name("removeAsync(id:onDone:)")));
@property (readonly) id<SharedKotlinx_coroutines_coreStateFlow> state __attribute__((swift_name("state")));
@end

__attribute__((objc_subclassing_restricted))
@interface MantrasState : SharedBase
- (instancetype)initWithItems:(NSArray<Mantra *> *)items isLoading:(BOOL)isLoading __attribute__((swift_name("init(items:isLoading:)"))) __attribute__((objc_designated_initializer));
- (MantrasState *)doCopyItems:(NSArray<Mantra *> *)items isLoading:(BOOL)isLoading __attribute__((swift_name("doCopy(items:isLoading:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) BOOL isLoading __attribute__((swift_name("isLoading")));
@property (readonly) NSArray<Mantra *> *items __attribute__((swift_name("items")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("MantraDao")))
@interface SharedMantraDao : SharedBase
- (instancetype)initWithDb:(id<SharedUserData>)db __attribute__((swift_name("init(db:)"))) __attribute__((objc_designated_initializer));
- (void)deleteId:(int64_t)id __attribute__((swift_name("delete(id:)")));
- (void)insertText:(NSString *)text __attribute__((swift_name("insert(text:)")));
- (id<SharedKotlinx_coroutines_coreFlow>)observeAll __attribute__((swift_name("observeAll()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("MantraRepository")))
@interface SharedMantraRepository : SharedBase
- (instancetype)initWithDao:(SharedMantraDao *)dao io:(SharedKotlinx_coroutines_coreCoroutineDispatcher *)io __attribute__((swift_name("init(dao:io:)"))) __attribute__((objc_designated_initializer));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)addText:(NSString *)text completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("add(text:completionHandler:)")));
- (id<SharedKotlinx_coroutines_coreFlow>)observeAll __attribute__((swift_name("observeAll()")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)removeId:(int64_t)id completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("remove(id:completionHandler:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Database")))
@interface SharedDatabase : SharedBase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)database __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedDatabase *shared __attribute__((swift_name("shared")));
- (id<SharedUserData>)createDriverFactory:(SharedDriverFactory *)driverFactory __attribute__((swift_name("create(driverFactory:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("DatabaseProvider")))
@interface SharedDatabaseProvider : SharedBase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)databaseProvider __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedDatabaseProvider *shared __attribute__((swift_name("shared")));
- (id<SharedUserData>)createDatabaseDriverFactory:(SharedDriverFactory *)driverFactory __attribute__((swift_name("createDatabase(driverFactory:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("DriverFactory")))
@interface SharedDriverFactory : SharedBase
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (id<SharedRuntimeSqlDriver>)createDriverDbName:(NSString *)dbName __attribute__((swift_name("createDriver(dbName:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Mantra_")))
@interface Mantra : SharedBase
- (instancetype)initWithId:(int64_t)id text:(NSString *)text __attribute__((swift_name("init(id:text:)"))) __attribute__((objc_designated_initializer));
- (Mantra *)doCopyId:(int64_t)id text:(NSString *)text __attribute__((swift_name("doCopy(id:text:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) int64_t id __attribute__((swift_name("id")));
@property (readonly) NSString *text __attribute__((swift_name("text")));
@end

__attribute__((objc_subclassing_restricted))
@interface KmpCancelable : SharedBase
- (instancetype)initWithJob:(id<SharedKotlinx_coroutines_coreJob>)job __attribute__((swift_name("init(job:)"))) __attribute__((objc_designated_initializer));
- (void)cancel __attribute__((swift_name("cancel()")));
@end

__attribute__((objc_subclassing_restricted))
@interface Interop : SharedBase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)interop __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) Interop *shared __attribute__((swift_name("shared")));
- (KmpCancelable *)observeStateFlow:(id<SharedKotlinx_coroutines_coreStateFlow>)flow onEach:(void (^)(id _Nullable))onEach __attribute__((swift_name("observeState(flow:onEach:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NavigationState")))
@interface SharedNavigationState : SharedBase
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (void)navigateToTarget:(SharedNavigationTarget *)target __attribute__((swift_name("navigateTo(target:)")));
@property (readonly) id<SharedKotlinx_coroutines_coreStateFlow> currentTarget __attribute__((swift_name("currentTarget")));
@end

__attribute__((swift_name("NavigationTarget")))
@interface SharedNavigationTarget : SharedBase
@property (readonly) SharedStringResource *route __attribute__((swift_name("route")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NavigationTarget.Contacts")))
@interface SharedNavigationTargetContacts : SharedNavigationTarget
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)contacts __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedNavigationTargetContacts *shared __attribute__((swift_name("shared")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NavigationTarget.Home")))
@interface SharedNavigationTargetHome : SharedNavigationTarget
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)home __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedNavigationTargetHome *shared __attribute__((swift_name("shared")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NavigationTarget.Profile")))
@interface SharedNavigationTargetProfile : SharedNavigationTarget
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)profile __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedNavigationTargetProfile *shared __attribute__((swift_name("shared")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NavigationTarget.Reflection")))
@interface SharedNavigationTargetReflection : SharedNavigationTarget
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)reflection __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedNavigationTargetReflection *shared __attribute__((swift_name("shared")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NavigationTarget.SOS")))
@interface SharedNavigationTargetSOS : SharedNavigationTarget
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)sOS __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedNavigationTargetSOS *shared __attribute__((swift_name("shared")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("FlowObserver")))
@interface SharedFlowObserver : SharedBase
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (instancetype)initWithScope:(id<SharedKotlinx_coroutines_coreCoroutineScope>)scope __attribute__((swift_name("init(scope:)"))) __attribute__((objc_designated_initializer));
- (void)close __attribute__((swift_name("close()")));
- (void)observeNavigationTargetFlow:(id<SharedKotlinx_coroutines_coreStateFlow>)flow onChange:(void (^)(SharedNavigationTarget *))onChange __attribute__((swift_name("observeNavigationTarget(flow:onChange:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("MainViewModel")))
@interface SharedMainViewModel : SharedBase
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (void)onTabSelectedTarget:(SharedNavigationTarget *)target __attribute__((swift_name("onTabSelected(target:)")));
@property (readonly) SharedNavigationState *navigation __attribute__((swift_name("navigation")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SharedRes")))
@interface SharedSharedRes : SharedBase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)sharedRes __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedSharedRes *shared __attribute__((swift_name("shared")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SharedRes.colors")))
@interface SharedSharedResColors : SharedBase <SharedResourceContainer>
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)colors __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedSharedResColors *shared __attribute__((swift_name("shared")));
- (NSArray<SharedColorResource *> *)values __attribute__((swift_name("values()")));
@property (readonly) SharedResourcePlatformDetails *__platformDetails __attribute__((swift_name("__platformDetails")));
@property (readonly) SharedColorResource *background __attribute__((swift_name("background")));
@property (readonly) SharedColorResource *brand __attribute__((swift_name("brand")));
@property (readonly) SharedColorResource *brandRef __attribute__((swift_name("brandRef")));
@property (readonly) SharedColorResource *error __attribute__((swift_name("error")));
@property (readonly) SharedColorResource *primary __attribute__((swift_name("primary")));
@property (readonly) SharedColorResource *primaryReference __attribute__((swift_name("primaryReference")));
@property (readonly) SharedColorResource *secondary __attribute__((swift_name("secondary")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SharedRes.images")))
@interface SharedSharedResImages : SharedBase <SharedResourceContainer>
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)images __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedSharedResImages *shared __attribute__((swift_name("shared")));
- (NSArray<SharedImageResource *> *)values __attribute__((swift_name("values()")));
@property (readonly) SharedResourcePlatformDetails *__platformDetails __attribute__((swift_name("__platformDetails")));
@property (readonly) SharedImageResource *onboarding_2 __attribute__((swift_name("onboarding_2")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SharedRes.strings")))
@interface SharedSharedResStrings : SharedBase <SharedResourceContainer>
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)strings __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedSharedResStrings *shared __attribute__((swift_name("shared")));
- (NSArray<SharedStringResource *> *)values __attribute__((swift_name("values()")));
@property (readonly) SharedResourcePlatformDetails *__platformDetails __attribute__((swift_name("__platformDetails")));
@property (readonly) SharedStringResource *contacts __attribute__((swift_name("contacts")));
@property (readonly) SharedStringResource *home __attribute__((swift_name("home")));
@property (readonly) SharedStringResource *profile __attribute__((swift_name("profile")));
@property (readonly) SharedStringResource *reflection __attribute__((swift_name("reflection")));
@property (readonly) SharedStringResource *sos __attribute__((swift_name("sos")));
@property (readonly) SharedStringResource *sos_button __attribute__((swift_name("sos_button")));
@property (readonly) SharedStringResource *test_string __attribute__((swift_name("test_string")));
@property (readonly) SharedStringResource *welcome_title __attribute__((swift_name("welcome_title")));
@end

@interface SharedColor (Extensions)
- (id<SharedColorDesc>)asColorDesc __attribute__((swift_name("asColorDesc()")));
- (UIColor *)toUIColor __attribute__((swift_name("toUIColor()")));
@end

@interface SharedColorCompanion (Extensions)
- (SharedColor *)parseColorColorHEX:(NSString *)colorHEX __attribute__((swift_name("parseColor(colorHEX:)")));
@end

@interface SharedColorResource (Extensions)
- (id<SharedColorDesc>)asColorDesc __attribute__((swift_name("asColorDesc()")));
- (UIColor *)getUIColor __attribute__((swift_name("getUIColor()")));
@end

@interface SharedFontResource (Extensions)
- (UIFont *)uiFontWithSize:(double)withSize __attribute__((swift_name("uiFont(withSize:)")));
@end

@interface SharedImageResource (Extensions)
- (id<SharedImageDesc>)asImageDesc __attribute__((swift_name("asImageDesc()")));
@end

@interface SharedPluralsResource (Extensions)
- (SharedPluralStringDesc *)descNumber:(int32_t)number __attribute__((swift_name("desc(number:)")));
- (SharedPluralFormattedStringDesc *)formatNumber:(int32_t)number args:(SharedKotlinArray<id> *)args __attribute__((swift_name("format(number:args:)")));
- (SharedPluralFormattedStringDesc *)formatNumber:(int32_t)number args_:(NSArray<id> *)args __attribute__((swift_name("format(number:args_:)")));
@end

@interface SharedStringResource (Extensions)
- (SharedResourceStringDesc *)desc __attribute__((swift_name("desc()")));
- (SharedResourceFormattedStringDesc *)formatArgs:(SharedKotlinArray<id> *)args __attribute__((swift_name("format(args:)")));
- (SharedResourceFormattedStringDesc *)formatArgs_:(NSArray<id> *)args __attribute__((swift_name("format(args_:)")));
@end

@interface SharedStringDescCompanion (Extensions)
- (SharedCompositionStringDesc *)CompositionArgs:(id)args separator:(NSString * _Nullable)separator __attribute__((swift_name("Composition(args:separator:)")));
- (SharedPluralStringDesc *)PluralPluralsRes:(SharedPluralsResource *)pluralsRes number:(int32_t)number __attribute__((swift_name("Plural(pluralsRes:number:)")));
- (SharedPluralFormattedStringDesc *)PluralFormattedPluralsRes:(SharedPluralsResource *)pluralsRes number:(int32_t)number args:(SharedKotlinArray<id> *)args __attribute__((swift_name("PluralFormatted(pluralsRes:number:args:)")));
- (SharedPluralFormattedStringDesc *)PluralFormattedPluralsRes:(SharedPluralsResource *)pluralsRes number:(int32_t)number args_:(NSArray<id> *)args __attribute__((swift_name("PluralFormatted(pluralsRes:number:args_:)")));
- (SharedRawStringDesc *)RawString:(NSString *)string __attribute__((swift_name("Raw(string:)")));
- (SharedResourceStringDesc *)ResourceStringRes:(SharedStringResource *)stringRes __attribute__((swift_name("Resource(stringRes:)")));
- (SharedResourceFormattedStringDesc *)ResourceFormattedStringRes:(SharedStringResource *)stringRes args:(SharedKotlinArray<id> *)args __attribute__((swift_name("ResourceFormatted(stringRes:args:)")));
- (SharedResourceFormattedStringDesc *)ResourceFormattedStringRes:(SharedStringResource *)stringRes args_:(NSArray<id> *)args __attribute__((swift_name("ResourceFormatted(stringRes:args_:)")));
@end

@interface SharedColorDescCompanion (Extensions)
- (id<SharedColorDesc>)ResourceResource:(SharedColorResource *)resource __attribute__((swift_name("Resource(resource:)")));
- (id<SharedColorDesc>)SingleColor:(SharedColor *)color __attribute__((swift_name("Single(color:)")));
- (id<SharedColorDesc>)ThemedLightColor:(SharedColor *)lightColor darkColor:(SharedColor *)darkColor __attribute__((swift_name("Themed(lightColor:darkColor:)")));
@end

@interface SharedImageDescCompanion (Extensions)
- (id<SharedImageDesc>)ResourceResource:(SharedImageResource *)resource __attribute__((swift_name("Resource(resource:)")));
- (id<SharedImageDesc>)UrlUrl:(NSString *)url __attribute__((swift_name("Url(url:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ColorDescExtKt")))
@interface SharedColorDescExtKt : SharedBase
+ (UIColor *)getUIColor:(id<SharedColorDesc>)receiver __attribute__((swift_name("getUIColor(_:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ImageDescUrlKt")))
@interface SharedImageDescUrlKt : SharedBase
+ (id<SharedImageDesc>)asImageUrl:(NSString *)receiver __attribute__((swift_name("asImageUrl(_:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NSBundleExtKt")))
@interface SharedNSBundleExtKt : SharedBase
+ (NSBundle *)loadableBundle:(Class)receiver identifier:(NSString *)identifier __attribute__((swift_name("loadableBundle(_:identifier:)")));
@property (class) BOOL isBundleSearchLogEnabled __attribute__((swift_name("isBundleSearchLogEnabled")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ResourceContainerExtKt")))
@interface SharedResourceContainerExtKt : SharedBase
+ (SharedAssetResource * _Nullable)getAssetByFilePath:(id<SharedResourceContainer>)receiver filePath:(NSString *)filePath __attribute__((swift_name("getAssetByFilePath(_:filePath:)")));
+ (SharedImageResource * _Nullable)getImageByFileName:(id<SharedResourceContainer>)receiver fileName:(NSString *)fileName __attribute__((swift_name("getImageByFileName(_:fileName:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("StringDescKt")))
@interface SharedStringDescKt : SharedBase
+ (SharedRawStringDesc *)desc:(NSString *)receiver __attribute__((swift_name("desc(_:)")));
+ (id<SharedStringDesc>)joinToStringDesc:(id)receiver separator:(NSString *)separator __attribute__((swift_name("joinToStringDesc(_:separator:)")));
+ (id<SharedStringDesc>)plus:(id<SharedStringDesc>)receiver other:(id<SharedStringDesc>)other __attribute__((swift_name("plus(_:other:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("StringsKt")))
@interface SharedStringsKt : SharedBase
+ (id<SharedStringDesc>)localizedRes:(SharedStringResource *)res __attribute__((swift_name("localized(res:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("TransactionsKt")))
@interface SharedTransactionsKt : SharedBase
+ (id _Nullable)transaction:(id<SharedUserData>)receiver block:(id _Nullable (^)(id<SharedRuntimeTransactionWithReturn>))block __attribute__((swift_name("transaction(_:block:)")));
@end

__attribute__((swift_name("RuntimeCloseable")))
@protocol SharedRuntimeCloseable
@required
- (void)close __attribute__((swift_name("close()")));
@end

__attribute__((swift_name("RuntimeSqlDriver")))
@protocol SharedRuntimeSqlDriver <SharedRuntimeCloseable>
@required
- (void)addListenerQueryKeys:(SharedKotlinArray<NSString *> *)queryKeys listener:(id<SharedRuntimeQueryListener>)listener __attribute__((swift_name("addListener(queryKeys:listener:)")));
- (SharedRuntimeTransacterTransaction * _Nullable)currentTransaction __attribute__((swift_name("currentTransaction()")));
- (id<SharedRuntimeQueryResult>)executeIdentifier:(SharedInt * _Nullable)identifier sql:(NSString *)sql parameters:(int32_t)parameters binders:(void (^ _Nullable)(id<SharedRuntimeSqlPreparedStatement>))binders __attribute__((swift_name("execute(identifier:sql:parameters:binders:)")));
- (id<SharedRuntimeQueryResult>)executeQueryIdentifier:(SharedInt * _Nullable)identifier sql:(NSString *)sql mapper:(id<SharedRuntimeQueryResult> (^)(id<SharedRuntimeSqlCursor>))mapper parameters:(int32_t)parameters binders:(void (^ _Nullable)(id<SharedRuntimeSqlPreparedStatement>))binders __attribute__((swift_name("executeQuery(identifier:sql:mapper:parameters:binders:)")));
- (id<SharedRuntimeQueryResult>)doNewTransaction __attribute__((swift_name("doNewTransaction()")));
- (void)notifyListenersQueryKeys:(SharedKotlinArray<NSString *> *)queryKeys __attribute__((swift_name("notifyListeners(queryKeys:)")));
- (void)removeListenerQueryKeys:(SharedKotlinArray<NSString *> *)queryKeys listener:(id<SharedRuntimeQueryListener>)listener __attribute__((swift_name("removeListener(queryKeys:listener:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KotlinUnit")))
@interface SharedKotlinUnit : SharedBase
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)unit __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedKotlinUnit *shared __attribute__((swift_name("shared")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((swift_name("RuntimeTransactionCallbacks")))
@protocol SharedRuntimeTransactionCallbacks
@required
- (void)afterCommitFunction:(void (^)(void))function __attribute__((swift_name("afterCommit(function:)")));
- (void)afterRollbackFunction:(void (^)(void))function __attribute__((swift_name("afterRollback(function:)")));
@end

__attribute__((swift_name("RuntimeTransacterTransaction")))
@interface SharedRuntimeTransacterTransaction : SharedBase <SharedRuntimeTransactionCallbacks>
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (void)afterCommitFunction:(void (^)(void))function __attribute__((swift_name("afterCommit(function:)")));
- (void)afterRollbackFunction:(void (^)(void))function __attribute__((swift_name("afterRollback(function:)")));

/**
 * @note This method has protected visibility in Kotlin source and is intended only for use by subclasses.
*/
- (id<SharedRuntimeQueryResult>)endTransactionSuccessful:(BOOL)successful __attribute__((swift_name("endTransaction(successful:)")));

/**
 * @note This property has protected visibility in Kotlin source and is intended only for use by subclasses.
*/
@property (readonly) SharedRuntimeTransacterTransaction * _Nullable enclosingTransaction __attribute__((swift_name("enclosingTransaction")));
@end

__attribute__((swift_name("RuntimeTransactionWithoutReturn")))
@protocol SharedRuntimeTransactionWithoutReturn <SharedRuntimeTransactionCallbacks>
@required
- (void)rollback __attribute__((swift_name("rollback()")));
- (void)transactionBody:(void (^)(id<SharedRuntimeTransactionWithoutReturn>))body __attribute__((swift_name("transaction(body:)")));
@end

__attribute__((swift_name("RuntimeTransactionWithReturn")))
@protocol SharedRuntimeTransactionWithReturn <SharedRuntimeTransactionCallbacks>
@required
- (void)rollbackReturnValue:(id _Nullable)returnValue __attribute__((swift_name("rollback(returnValue:)")));
- (id _Nullable)transactionBody_:(id _Nullable (^)(id<SharedRuntimeTransactionWithReturn>))body __attribute__((swift_name("transaction(body_:)")));
@end

__attribute__((swift_name("RuntimeQueryResult")))
@protocol SharedRuntimeQueryResult
@required

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)awaitWithCompletionHandler:(void (^)(id _Nullable_result, NSError * _Nullable))completionHandler __attribute__((swift_name("await(completionHandler:)")));
@property (readonly) id _Nullable value __attribute__((swift_name("value")));
@end

__attribute__((swift_name("RuntimeExecutableQuery")))
@interface SharedRuntimeExecutableQuery<__covariant RowType> : SharedBase
- (instancetype)initWithMapper:(RowType (^)(id<SharedRuntimeSqlCursor>))mapper __attribute__((swift_name("init(mapper:)"))) __attribute__((objc_designated_initializer));
- (id<SharedRuntimeQueryResult>)executeMapper:(id<SharedRuntimeQueryResult> (^)(id<SharedRuntimeSqlCursor>))mapper __attribute__((swift_name("execute(mapper:)")));
- (NSArray<RowType> *)executeAsList __attribute__((swift_name("executeAsList()")));
- (RowType)executeAsOne __attribute__((swift_name("executeAsOne()")));
- (RowType _Nullable)executeAsOneOrNull __attribute__((swift_name("executeAsOneOrNull()")));
@property (readonly) RowType (^mapper)(id<SharedRuntimeSqlCursor>) __attribute__((swift_name("mapper")));
@end

__attribute__((swift_name("RuntimeQuery")))
@interface SharedRuntimeQuery<__covariant RowType> : SharedRuntimeExecutableQuery<RowType>
- (instancetype)initWithMapper:(RowType (^)(id<SharedRuntimeSqlCursor>))mapper __attribute__((swift_name("init(mapper:)"))) __attribute__((objc_designated_initializer));
- (void)addListenerListener:(id<SharedRuntimeQueryListener>)listener __attribute__((swift_name("addListener(listener:)")));
- (void)removeListenerListener:(id<SharedRuntimeQueryListener>)listener __attribute__((swift_name("removeListener(listener:)")));
@end

__attribute__((swift_name("RuntimeSqlSchema")))
@protocol SharedRuntimeSqlSchema
@required
- (id<SharedRuntimeQueryResult>)createDriver:(id<SharedRuntimeSqlDriver>)driver __attribute__((swift_name("create(driver:)")));
- (id<SharedRuntimeQueryResult>)migrateDriver:(id<SharedRuntimeSqlDriver>)driver oldVersion:(int64_t)oldVersion newVersion:(int64_t)newVersion callbacks:(SharedKotlinArray<SharedRuntimeAfterVersion *> *)callbacks __attribute__((swift_name("migrate(driver:oldVersion:newVersion:callbacks:)")));
@property (readonly) int64_t version __attribute__((swift_name("version")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KotlinObjCErrorException")))
@interface SharedKotlinObjCErrorException : SharedKotlinException
- (instancetype)initWithMessage:(NSString * _Nullable)message error:(id)error __attribute__((swift_name("init(message:error:)"))) __attribute__((objc_designated_initializer));
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (instancetype)new __attribute__((unavailable));
- (instancetype)initWithMessage:(NSString * _Nullable)message __attribute__((swift_name("init(message:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
- (instancetype)initWithCause:(SharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(cause:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(SharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KotlinArray")))
@interface SharedKotlinArray<T> : SharedBase
+ (instancetype)arrayWithSize:(int32_t)size init:(T _Nullable (^)(SharedInt *))init __attribute__((swift_name("init(size:init:)")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (T _Nullable)getIndex:(int32_t)index __attribute__((swift_name("get(index:)")));
- (id<SharedKotlinIterator>)iterator __attribute__((swift_name("iterator()")));
- (void)setIndex:(int32_t)index value:(T _Nullable)value __attribute__((swift_name("set(index:value:)")));
@property (readonly) int32_t size __attribute__((swift_name("size")));
@end

__attribute__((swift_name("Kotlinx_coroutines_coreCoroutineScope")))
@protocol SharedKotlinx_coroutines_coreCoroutineScope
@required
@property (readonly) id<SharedKotlinCoroutineContext> coroutineContext __attribute__((swift_name("coroutineContext")));
@end

__attribute__((swift_name("KotlinRuntimeException")))
@interface SharedKotlinRuntimeException : SharedKotlinException
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (instancetype)initWithMessage:(NSString * _Nullable)message __attribute__((swift_name("init(message:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithCause:(SharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(cause:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(SharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer));
@end

__attribute__((swift_name("KotlinIllegalStateException")))
@interface SharedKotlinIllegalStateException : SharedKotlinRuntimeException
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (instancetype)initWithMessage:(NSString * _Nullable)message __attribute__((swift_name("init(message:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithCause:(SharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(cause:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(SharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer));
@end


/**
 * @note annotations
 *   kotlin.SinceKotlin(version="1.4")
*/
__attribute__((swift_name("KotlinCancellationException")))
@interface SharedKotlinCancellationException : SharedKotlinIllegalStateException
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (instancetype)initWithMessage:(NSString * _Nullable)message __attribute__((swift_name("init(message:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithCause:(SharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(cause:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(SharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer));
@end

__attribute__((swift_name("Kotlinx_coroutines_coreFlow")))
@protocol SharedKotlinx_coroutines_coreFlow
@required

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)collectCollector:(id<SharedKotlinx_coroutines_coreFlowCollector>)collector completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("collect(collector:completionHandler:)")));
@end

__attribute__((swift_name("Kotlinx_coroutines_coreSharedFlow")))
@protocol SharedKotlinx_coroutines_coreSharedFlow <SharedKotlinx_coroutines_coreFlow>
@required
@property (readonly) NSArray<id> *replayCache __attribute__((swift_name("replayCache")));
@end

__attribute__((swift_name("Kotlinx_coroutines_coreStateFlow")))
@protocol SharedKotlinx_coroutines_coreStateFlow <SharedKotlinx_coroutines_coreSharedFlow>
@required
@property (readonly) id _Nullable value __attribute__((swift_name("value")));
@end


/**
 * @note annotations
 *   kotlin.SinceKotlin(version="1.3")
*/
__attribute__((swift_name("KotlinCoroutineContext")))
@protocol SharedKotlinCoroutineContext
@required
- (id _Nullable)foldInitial:(id _Nullable)initial operation:(id _Nullable (^)(id _Nullable, id<SharedKotlinCoroutineContextElement>))operation __attribute__((swift_name("fold(initial:operation:)")));
- (id<SharedKotlinCoroutineContextElement> _Nullable)getKey:(id<SharedKotlinCoroutineContextKey>)key __attribute__((swift_name("get(key:)")));
- (id<SharedKotlinCoroutineContext>)minusKeyKey:(id<SharedKotlinCoroutineContextKey>)key __attribute__((swift_name("minusKey(key:)")));
- (id<SharedKotlinCoroutineContext>)plusContext:(id<SharedKotlinCoroutineContext>)context __attribute__((swift_name("plus(context:)")));
@end

__attribute__((swift_name("KotlinCoroutineContextElement")))
@protocol SharedKotlinCoroutineContextElement <SharedKotlinCoroutineContext>
@required
@property (readonly) id<SharedKotlinCoroutineContextKey> key __attribute__((swift_name("key")));
@end


/**
 * @note annotations
 *   kotlin.SinceKotlin(version="1.3")
*/
__attribute__((swift_name("KotlinAbstractCoroutineContextElement")))
@interface SharedKotlinAbstractCoroutineContextElement : SharedBase <SharedKotlinCoroutineContextElement>
- (instancetype)initWithKey:(id<SharedKotlinCoroutineContextKey>)key __attribute__((swift_name("init(key:)"))) __attribute__((objc_designated_initializer));
@property (readonly) id<SharedKotlinCoroutineContextKey> key __attribute__((swift_name("key")));
@end


/**
 * @note annotations
 *   kotlin.SinceKotlin(version="1.3")
*/
__attribute__((swift_name("KotlinContinuationInterceptor")))
@protocol SharedKotlinContinuationInterceptor <SharedKotlinCoroutineContextElement>
@required
- (id<SharedKotlinContinuation>)interceptContinuationContinuation:(id<SharedKotlinContinuation>)continuation __attribute__((swift_name("interceptContinuation(continuation:)")));
- (void)releaseInterceptedContinuationContinuation:(id<SharedKotlinContinuation>)continuation __attribute__((swift_name("releaseInterceptedContinuation(continuation:)")));
@end

__attribute__((swift_name("Kotlinx_coroutines_coreCoroutineDispatcher")))
@interface SharedKotlinx_coroutines_coreCoroutineDispatcher : SharedKotlinAbstractCoroutineContextElement <SharedKotlinContinuationInterceptor>
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (instancetype)initWithKey:(id<SharedKotlinCoroutineContextKey>)key __attribute__((swift_name("init(key:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
@property (class, readonly, getter=companion) SharedKotlinx_coroutines_coreCoroutineDispatcherKey *companion __attribute__((swift_name("companion")));
- (void)dispatchContext:(id<SharedKotlinCoroutineContext>)context block:(id<SharedKotlinx_coroutines_coreRunnable>)block __attribute__((swift_name("dispatch(context:block:)")));

/**
 * @note annotations
 *   kotlinx.coroutines.InternalCoroutinesApi
*/
- (void)dispatchYieldContext:(id<SharedKotlinCoroutineContext>)context block:(id<SharedKotlinx_coroutines_coreRunnable>)block __attribute__((swift_name("dispatchYield(context:block:)")));
- (id<SharedKotlinContinuation>)interceptContinuationContinuation:(id<SharedKotlinContinuation>)continuation __attribute__((swift_name("interceptContinuation(continuation:)")));
- (BOOL)isDispatchNeededContext:(id<SharedKotlinCoroutineContext>)context __attribute__((swift_name("isDispatchNeeded(context:)")));
- (SharedKotlinx_coroutines_coreCoroutineDispatcher *)limitedParallelismParallelism:(int32_t)parallelism name:(NSString * _Nullable)name __attribute__((swift_name("limitedParallelism(parallelism:name:)")));
- (SharedKotlinx_coroutines_coreCoroutineDispatcher *)plusOther:(SharedKotlinx_coroutines_coreCoroutineDispatcher *)other __attribute__((swift_name("plus(other:)"))) __attribute__((unavailable("Operator '+' on two CoroutineDispatcher objects is meaningless. CoroutineDispatcher is a coroutine context element and `+` is a set-sum operator for coroutine contexts. The dispatcher to the right of `+` just replaces the dispatcher to the left.")));
- (void)releaseInterceptedContinuationContinuation:(id<SharedKotlinContinuation>)continuation __attribute__((swift_name("releaseInterceptedContinuation(continuation:)")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((swift_name("Kotlinx_coroutines_coreJob")))
@protocol SharedKotlinx_coroutines_coreJob <SharedKotlinCoroutineContextElement>
@required

/**
 * @note annotations
 *   kotlinx.coroutines.InternalCoroutinesApi
*/
- (id<SharedKotlinx_coroutines_coreChildHandle>)attachChildChild:(id<SharedKotlinx_coroutines_coreChildJob>)child __attribute__((swift_name("attachChild(child:)")));
- (void)cancelCause:(SharedKotlinCancellationException * _Nullable)cause __attribute__((swift_name("cancel(cause:)")));

/**
 * @note annotations
 *   kotlinx.coroutines.InternalCoroutinesApi
*/
- (SharedKotlinCancellationException *)getCancellationException __attribute__((swift_name("getCancellationException()")));
- (id<SharedKotlinx_coroutines_coreDisposableHandle>)invokeOnCompletionHandler:(void (^)(SharedKotlinThrowable * _Nullable))handler __attribute__((swift_name("invokeOnCompletion(handler:)")));

/**
 * @note annotations
 *   kotlinx.coroutines.InternalCoroutinesApi
*/
- (id<SharedKotlinx_coroutines_coreDisposableHandle>)invokeOnCompletionOnCancelling:(BOOL)onCancelling invokeImmediately:(BOOL)invokeImmediately handler:(void (^)(SharedKotlinThrowable * _Nullable))handler __attribute__((swift_name("invokeOnCompletion(onCancelling:invokeImmediately:handler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)joinWithCompletionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("join(completionHandler:)")));
- (id<SharedKotlinx_coroutines_coreJob>)plusOther_:(id<SharedKotlinx_coroutines_coreJob>)other __attribute__((swift_name("plus(other_:)"))) __attribute__((unavailable("Operator '+' on two Job objects is meaningless. Job is a coroutine context element and `+` is a set-sum operator for coroutine contexts. The job to the right of `+` just replaces the job the left of `+`.")));
- (BOOL)start __attribute__((swift_name("start()")));
@property (readonly) id<SharedKotlinSequence> children __attribute__((swift_name("children")));
@property (readonly) BOOL isActive __attribute__((swift_name("isActive")));
@property (readonly) BOOL isCancelled __attribute__((swift_name("isCancelled")));
@property (readonly) BOOL isCompleted __attribute__((swift_name("isCompleted")));
@property (readonly) id<SharedKotlinx_coroutines_coreSelectClause0> onJoin __attribute__((swift_name("onJoin")));

/**
 * @note annotations
 *   kotlinx.coroutines.ExperimentalCoroutinesApi
*/
@property (readonly) id<SharedKotlinx_coroutines_coreJob> _Nullable parent __attribute__((swift_name("parent")));
@end

__attribute__((swift_name("RuntimeQueryListener")))
@protocol SharedRuntimeQueryListener
@required
- (void)queryResultsChanged __attribute__((swift_name("queryResultsChanged()")));
@end

__attribute__((swift_name("RuntimeSqlPreparedStatement")))
@protocol SharedRuntimeSqlPreparedStatement
@required
- (void)bindBooleanIndex:(int32_t)index boolean:(SharedBoolean * _Nullable)boolean __attribute__((swift_name("bindBoolean(index:boolean:)")));
- (void)bindBytesIndex:(int32_t)index bytes:(SharedKotlinByteArray * _Nullable)bytes __attribute__((swift_name("bindBytes(index:bytes:)")));
- (void)bindDoubleIndex:(int32_t)index double:(SharedDouble * _Nullable)double_ __attribute__((swift_name("bindDouble(index:double:)")));
- (void)bindLongIndex:(int32_t)index long:(SharedLong * _Nullable)long_ __attribute__((swift_name("bindLong(index:long:)")));
- (void)bindStringIndex:(int32_t)index string:(NSString * _Nullable)string __attribute__((swift_name("bindString(index:string:)")));
@end

__attribute__((swift_name("RuntimeSqlCursor")))
@protocol SharedRuntimeSqlCursor
@required
- (SharedBoolean * _Nullable)getBooleanIndex:(int32_t)index __attribute__((swift_name("getBoolean(index:)")));
- (SharedKotlinByteArray * _Nullable)getBytesIndex:(int32_t)index __attribute__((swift_name("getBytes(index:)")));
- (SharedDouble * _Nullable)getDoubleIndex:(int32_t)index __attribute__((swift_name("getDouble(index:)")));
- (SharedLong * _Nullable)getLongIndex:(int32_t)index __attribute__((swift_name("getLong(index:)")));
- (NSString * _Nullable)getStringIndex:(int32_t)index __attribute__((swift_name("getString(index:)")));
- (id<SharedRuntimeQueryResult>)next __attribute__((swift_name("next()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("RuntimeAfterVersion")))
@interface SharedRuntimeAfterVersion : SharedBase
- (instancetype)initWithAfterVersion:(int64_t)afterVersion block:(void (^)(id<SharedRuntimeSqlDriver>))block __attribute__((swift_name("init(afterVersion:block:)"))) __attribute__((objc_designated_initializer));
@property (readonly) int64_t afterVersion __attribute__((swift_name("afterVersion")));
@property (readonly) void (^block)(id<SharedRuntimeSqlDriver>) __attribute__((swift_name("block")));
@end

__attribute__((swift_name("KotlinIterator")))
@protocol SharedKotlinIterator
@required
- (BOOL)hasNext __attribute__((swift_name("hasNext()")));
- (id _Nullable)next __attribute__((swift_name("next()")));
@end

__attribute__((swift_name("Kotlinx_coroutines_coreFlowCollector")))
@protocol SharedKotlinx_coroutines_coreFlowCollector
@required

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)emitValue:(id _Nullable)value completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("emit(value:completionHandler:)")));
@end

__attribute__((swift_name("KotlinCoroutineContextKey")))
@protocol SharedKotlinCoroutineContextKey
@required
@end


/**
 * @note annotations
 *   kotlin.SinceKotlin(version="1.3")
*/
__attribute__((swift_name("KotlinContinuation")))
@protocol SharedKotlinContinuation
@required
- (void)resumeWithResult:(id _Nullable)result __attribute__((swift_name("resumeWith(result:)")));
@property (readonly) id<SharedKotlinCoroutineContext> context __attribute__((swift_name("context")));
@end


/**
 * @note annotations
 *   kotlin.SinceKotlin(version="1.3")
 *   kotlin.ExperimentalStdlibApi
*/
__attribute__((swift_name("KotlinAbstractCoroutineContextKey")))
@interface SharedKotlinAbstractCoroutineContextKey<B, E> : SharedBase <SharedKotlinCoroutineContextKey>
- (instancetype)initWithBaseKey:(id<SharedKotlinCoroutineContextKey>)baseKey safeCast:(E _Nullable (^)(id<SharedKotlinCoroutineContextElement>))safeCast __attribute__((swift_name("init(baseKey:safeCast:)"))) __attribute__((objc_designated_initializer));
@end


/**
 * @note annotations
 *   kotlin.ExperimentalStdlibApi
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Kotlinx_coroutines_coreCoroutineDispatcher.Key")))
@interface SharedKotlinx_coroutines_coreCoroutineDispatcherKey : SharedKotlinAbstractCoroutineContextKey<id<SharedKotlinContinuationInterceptor>, SharedKotlinx_coroutines_coreCoroutineDispatcher *>
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithBaseKey:(id<SharedKotlinCoroutineContextKey>)baseKey safeCast:(id<SharedKotlinCoroutineContextElement> _Nullable (^)(id<SharedKotlinCoroutineContextElement>))safeCast __attribute__((swift_name("init(baseKey:safeCast:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (instancetype)key __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) SharedKotlinx_coroutines_coreCoroutineDispatcherKey *shared __attribute__((swift_name("shared")));
@end

__attribute__((swift_name("Kotlinx_coroutines_coreRunnable")))
@protocol SharedKotlinx_coroutines_coreRunnable
@required
- (void)run __attribute__((swift_name("run()")));
@end

__attribute__((swift_name("Kotlinx_coroutines_coreDisposableHandle")))
@protocol SharedKotlinx_coroutines_coreDisposableHandle
@required
- (void)dispose __attribute__((swift_name("dispose()")));
@end


/**
 * @note annotations
 *   kotlinx.coroutines.InternalCoroutinesApi
*/
__attribute__((swift_name("Kotlinx_coroutines_coreChildHandle")))
@protocol SharedKotlinx_coroutines_coreChildHandle <SharedKotlinx_coroutines_coreDisposableHandle>
@required

/**
 * @note annotations
 *   kotlinx.coroutines.InternalCoroutinesApi
*/
- (BOOL)childCancelledCause:(SharedKotlinThrowable *)cause __attribute__((swift_name("childCancelled(cause:)")));

/**
 * @note annotations
 *   kotlinx.coroutines.InternalCoroutinesApi
*/
@property (readonly) id<SharedKotlinx_coroutines_coreJob> _Nullable parent __attribute__((swift_name("parent")));
@end


/**
 * @note annotations
 *   kotlinx.coroutines.InternalCoroutinesApi
*/
__attribute__((swift_name("Kotlinx_coroutines_coreChildJob")))
@protocol SharedKotlinx_coroutines_coreChildJob <SharedKotlinx_coroutines_coreJob>
@required

/**
 * @note annotations
 *   kotlinx.coroutines.InternalCoroutinesApi
*/
- (void)parentCancelledParentJob:(id<SharedKotlinx_coroutines_coreParentJob>)parentJob __attribute__((swift_name("parentCancelled(parentJob:)")));
@end

__attribute__((swift_name("KotlinSequence")))
@protocol SharedKotlinSequence
@required
- (id<SharedKotlinIterator>)iterator __attribute__((swift_name("iterator()")));
@end


/**
 * @note annotations
 *   kotlinx.coroutines.InternalCoroutinesApi
*/
__attribute__((swift_name("Kotlinx_coroutines_coreSelectClause")))
@protocol SharedKotlinx_coroutines_coreSelectClause
@required
@property (readonly) id clauseObject __attribute__((swift_name("clauseObject")));
@property (readonly) SharedKotlinUnit *(^(^ _Nullable onCancellationConstructor)(id<SharedKotlinx_coroutines_coreSelectInstance>, id _Nullable, id _Nullable))(SharedKotlinThrowable *, id _Nullable, id<SharedKotlinCoroutineContext>) __attribute__((swift_name("onCancellationConstructor")));
@property (readonly) id _Nullable (^processResFunc)(id, id _Nullable, id _Nullable) __attribute__((swift_name("processResFunc")));
@property (readonly) void (^regFunc)(id, id<SharedKotlinx_coroutines_coreSelectInstance>, id _Nullable) __attribute__((swift_name("regFunc")));
@end

__attribute__((swift_name("Kotlinx_coroutines_coreSelectClause0")))
@protocol SharedKotlinx_coroutines_coreSelectClause0 <SharedKotlinx_coroutines_coreSelectClause>
@required
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KotlinByteArray")))
@interface SharedKotlinByteArray : SharedBase
+ (instancetype)arrayWithSize:(int32_t)size __attribute__((swift_name("init(size:)")));
+ (instancetype)arrayWithSize:(int32_t)size init:(SharedByte *(^)(SharedInt *))init __attribute__((swift_name("init(size:init:)")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (int8_t)getIndex:(int32_t)index __attribute__((swift_name("get(index:)")));
- (SharedKotlinByteIterator *)iterator __attribute__((swift_name("iterator()")));
- (void)setIndex:(int32_t)index value:(int8_t)value __attribute__((swift_name("set(index:value:)")));
@property (readonly) int32_t size __attribute__((swift_name("size")));
@end


/**
 * @note annotations
 *   kotlinx.coroutines.InternalCoroutinesApi
*/
__attribute__((swift_name("Kotlinx_coroutines_coreParentJob")))
@protocol SharedKotlinx_coroutines_coreParentJob <SharedKotlinx_coroutines_coreJob>
@required

/**
 * @note annotations
 *   kotlinx.coroutines.InternalCoroutinesApi
*/
- (SharedKotlinCancellationException *)getChildJobCancellationCause __attribute__((swift_name("getChildJobCancellationCause()")));
@end


/**
 * @note annotations
 *   kotlinx.coroutines.InternalCoroutinesApi
*/
__attribute__((swift_name("Kotlinx_coroutines_coreSelectInstance")))
@protocol SharedKotlinx_coroutines_coreSelectInstance
@required
- (void)disposeOnCompletionDisposableHandle:(id<SharedKotlinx_coroutines_coreDisposableHandle>)disposableHandle __attribute__((swift_name("disposeOnCompletion(disposableHandle:)")));
- (void)selectInRegistrationPhaseInternalResult:(id _Nullable)internalResult __attribute__((swift_name("selectInRegistrationPhase(internalResult:)")));
- (BOOL)trySelectClauseObject:(id)clauseObject result:(id _Nullable)result __attribute__((swift_name("trySelect(clauseObject:result:)")));
@property (readonly) id<SharedKotlinCoroutineContext> context __attribute__((swift_name("context")));
@end

__attribute__((swift_name("KotlinByteIterator")))
@interface SharedKotlinByteIterator : SharedBase <SharedKotlinIterator>
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (SharedByte *)next __attribute__((swift_name("next()")));
- (int8_t)nextByte __attribute__((swift_name("nextByte()")));
@end

#pragma pop_macro("_Nullable_result")
#pragma clang diagnostic pop
NS_ASSUME_NONNULL_END
