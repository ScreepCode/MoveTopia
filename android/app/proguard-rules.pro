# Keep classes used for reflection
-keepclassmembers class * {
    <methods>;
}

# Keep url_launcher package
-keep class androidx.core.content.FileProvider
-keep class androidx.core.app.ActivityCompat
-keep class androidx.core.content.ContextCompat

# Keep url_launcher classes
-keep class io.flutter.plugins.urllauncher.** { *; }
-keep class androidx.core.content.** { *; }
-keepattributes *Annotation*
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Keep all implementations of b2.a
-keep class b2.a { *; }
-keep class b2.** { *; }
-keep class j2.d { *; }

# WebView rules
-keep class io.flutter.plugins.webviewflutter.** { *; }
-keep class android.webkit.** { *; }
-keep class * extends android.webkit.WebChromeClient { *; }
-keep class * extends android.webkit.WebViewClient { *; }
-keepclassmembers class * extends android.webkit.WebViewClient {
    <methods>;
}

# Keep javascript interfaces
-keepattributes JavascriptInterface
-keep class * extends android.webkit.WebView { *; }

# Keep all classes that might be used in WebView JS interface
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}