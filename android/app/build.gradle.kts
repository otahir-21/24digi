import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
// `android/app` -> `android/key.properties`
val keystorePropertiesFile = file("../key.properties")
require(keystorePropertiesFile.exists()) {
    "key.properties not found at: ${keystorePropertiesFile.absolutePath}"
}
keystoreProperties.load(keystorePropertiesFile.inputStream())

android {
    namespace = "com.digi24.fitness"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.digi24.fitness"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val storeFilePath =
                keystoreProperties.getProperty("storeFile")
                    ?: error("Missing `storeFile` in key.properties")
            // Resolve relative paths in `key.properties` relative to the file location.
            storeFile = keystorePropertiesFile.parentFile.resolve(storeFilePath)
            storePassword = keystoreProperties.getProperty("storePassword")
                ?: error("Missing `storePassword` in android/key.properties")
            keyAlias = keystoreProperties.getProperty("keyAlias")
                ?: error("Missing `keyAlias` in android/key.properties")
            keyPassword = keystoreProperties.getProperty("keyPassword")
                ?: error("Missing `keyPassword` in android/key.properties")
            storeType = "pkcs12"
        }
    }


    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

flutter {
    source = "../.."
}
