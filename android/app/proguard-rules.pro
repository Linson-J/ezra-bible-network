# flutter_local_notifications uses Gson to persist scheduled notifications.
-keep class com.dexterous.** { *; }
-keepattributes Signature
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken

# better_player_plus / Media3
-keep class uz.shs.better_player_plus.** { *; }
-keep class androidx.media3.** { *; }
-dontwarn androidx.media3.**

# Play Core (referenced by Flutter deferred components, not used here)
-dontwarn com.google.android.play.core.**
