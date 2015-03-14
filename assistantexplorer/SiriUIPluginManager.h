/* Generated by RuntimeBrowser
   Image: /System/Library/PrivateFrameworks/SiriUI.framework/SiriUI
 */

@class SVSBundleIdentifierMap;

@interface SiriUIPluginManager : NSObject {
    SVSBundleIdentifierMap *_identifierMap;
}

+ (id)sharedInstance;

- (void).cxx_destruct;
- (id)_bundleSearchPaths;
- (id)_createDebugViewControllerForAceObject:(id)arg1;
- (void)_loadBundleMapsIfNecessary;
- (id)disambiguationItemForListItem:(id)arg1 disambiguationKey:(id)arg2;
- (id)speakableProviderForObject:(id)arg1;
- (id)transcriptItemForObject:(id)arg1;

@end
