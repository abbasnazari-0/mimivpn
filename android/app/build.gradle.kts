import java.util.Properties

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.arianadeveloper.ariana_vpn"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.arianadeveloper.ariana_vpn"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Android 16 KB Page Size Support - ABI splits configuration
    splits {
        abi {
            isEnable = true
            reset()
            include("x86_64", "armeabi-v7a", "arm64-v8a")
            isUniversalApk = true
        }
    }

    // Android 16 KB Page Size Support - Packaging options
   packagingOptions {
        jniLibs {
            useLegacyPackaging = true
            }
    }


    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias") ?: "androiddebugkey"
            keyPassword = keystoreProperties.getProperty("keyPassword") ?: "android"
            storeFile = file(keystoreProperties.getProperty("storeFile") ?: "keystore/debug.keystore")
            storePassword = keystoreProperties.getProperty("storePassword") ?: "android"
        }
    }


    buildTypes {
       
         getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
            ndk {
                abiFilters.addAll(listOf("x86_64", "armeabi-v7a", "arm64-v8a"))
                debugSymbolLevel = "FULL"
            }
        }
        getByName("debug") {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
            ndk {
                abiFilters.addAll(listOf("x86_64", "armeabi-v7a", "arm64-v8a"))
                debugSymbolLevel = "FULL"
            }
        }
    }
}

flutter {
    source = "../.."
}

repositories {
    flatDir {
        dirs("libs")
    }
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:34.4.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.android.ump:user-messaging-platform:3.1.0")
    implementation(fileTree(mapOf("dir" to "libs", "include" to listOf("*.jar"))))
    // implementation(files("libs/DXcore.aar")) // Commented out due to conflict with flutter_v2ray_client
    implementation("androidx.activity:activity-ktx:1.7.2")
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("com.squareup.okhttp3:okhttp:4.12.0")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
}
