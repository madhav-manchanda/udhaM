plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Production releases opt in explicitly from the release workflow. Local debug
// and development builds continue to use the normal debug signing configuration.
val udhamProductionRelease = project.hasProperty("udhamProductionRelease")
val releaseKeystorePath = System.getenv("ANDROID_KEYSTORE_PATH")
val releaseKeystorePassword = System.getenv("ANDROID_KEYSTORE_PASSWORD")
val releaseKeyAlias = System.getenv("ANDROID_KEY_ALIAS")
val releaseKeyPassword = System.getenv("ANDROID_KEY_PASSWORD")

if (udhamProductionRelease) {
    require(!releaseKeystorePath.isNullOrBlank()) { "ANDROID_KEYSTORE_PATH is required for production releases." }
    require(!releaseKeystorePassword.isNullOrBlank()) { "ANDROID_KEYSTORE_PASSWORD is required for production releases." }
    require(!releaseKeyAlias.isNullOrBlank()) { "ANDROID_KEY_ALIAS is required for production releases." }
    require(!releaseKeyPassword.isNullOrBlank()) { "ANDROID_KEY_PASSWORD is required for production releases." }
}

android {
    namespace = "com.udham.udham"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.udham.udham"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (udhamProductionRelease) {
            create("production") {
                storeFile = file(requireNotNull(releaseKeystorePath))
                storePassword = releaseKeystorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        release {
            // A tagged production release must use the dedicated signing key.
            // Non-production local release builds retain debug signing for convenience.
            signingConfig = if (udhamProductionRelease) {
                signingConfigs.getByName("production")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
