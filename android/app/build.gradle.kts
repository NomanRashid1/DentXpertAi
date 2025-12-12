// app/build.gradle.kts (Module Level)

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.dentxxpert_ai"
    compileSdk = flutter.compileSdkVersion.toInt()

    // Explicit NDK version set to resolve plugin conflicts
    ndkVersion = "27.0.12077973"

    compileOptions {
        // UPDATED: Change from VERSION_11 to VERSION_17
        sourceCompatibility = JavaVersion.VERSION_17
        // UPDATED: Change from VERSION_11 to VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        // UPDATED: Change from VERSION_11.toString() to "17"
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.dentxxpert_ai"
        minSdk = flutter.minSdkVersion.toInt()
        targetSdk = flutter.targetSdkVersion.toInt()
        versionCode = flutter.versionCode.toInt()
        versionName = flutter.versionName
        multiDexEnabled = true  // Added for better plugin compatibility
    }

    buildTypes {
        release {
            // Enable code shrinking and optimization
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("debug")
        }
        debug {
            // Disable minification for debug builds
            isMinifyEnabled = false
        }
    }

    // Enable view binding if needed
    buildFeatures {
        viewBinding = true
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Add core Kotlin extensions
    implementation("androidx.core:core-ktx:1.12.0")

    // Add multidex support
    implementation("androidx.multidex:multidex:2.0.1")

    // Add these if you're using any AndroidX libraries
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.11.0")
}