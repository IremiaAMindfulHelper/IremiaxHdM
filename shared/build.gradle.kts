/**
 * Shared Gradle build (Kotlin Multiplatform Module)
 *
 * Purpose:
 * - Provides the shared business logic and data layer for both Android and iOS apps.
 * - Builds a static XCFramework for iOS and an Android library (AAR).
 * - Integrates moko-resources (strings, colors, images) with platform-specific exports.
 * - Configures SQLDelight for local database generation (multi-platform ready).
 *
 * Key details:
 * - iOS: Static framework + XCFramework (device + simulator, both arm64).
 * - Android: JVM 11 target, consistent with modern AGP / Compose setups.
 * - moko-resources: Generates a unified SharedRes object with localization support.
 * - SQLDelight: Single “UserData” database under `com.iremia` package.
 *
 * Tooling expectations:
 * - Requires Kotlin 2.x or newer.
 * - iOS builds must run on macOS runners (Kotlin/Native + Xcode).
 * - Version management via libs.versions.toml.
 */

import org.jetbrains.kotlin.gradle.ExperimentalKotlinGradlePluginApi
import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.plugin.mpp.KotlinNativeTarget
import org.jetbrains.kotlin.gradle.plugin.mpp.apple.XCFramework
import org.gradle.internal.os.OperatingSystem

plugins {
    // Core Multiplatform + Android library plugin
    id("org.jetbrains.kotlin.multiplatform")
    id("com.android.library")

    // CocoaPods plugin (used only for framework metadata, no `pod install` needed)
    id("org.jetbrains.kotlin.native.cocoapods")

    // SQLDelight for database generation
    id("app.cash.sqldelight")

    // moko-resources for shared strings, colors, and images
    id("dev.icerock.mobile.multiplatform-resources")
}

kotlin {
    // Android target configuration
    androidTarget {
        @OptIn(ExperimentalKotlinGradlePluginApi::class)
        compilerOptions {
            // NOTE: JVM 11 is required for modern Gradle & Kotlin compatibility
            jvmTarget.set(JvmTarget.JVM_11)
        }
    }

    // iOS targets (device + simulator, both arm64)
    iosArm64()
    iosSimulatorArm64()

    // XCFramework combines multiple iOS frameworks into one bundle
    val xcf = XCFramework()

    // Configure each native target to generate a static framework
    targets.withType(KotlinNativeTarget::class.java).configureEach {
        binaries.framework {
            baseName = "Shared"
            isStatic = true
            xcf.add(this) // NOTE: Generates assemble*XCFramework tasks on macOS
        }
    }

    cocoapods {
        // Basic metadata (useful if later published as a CocoaPod)
        version = "0.1.0"
        summary = "Shared Kotlin Multiplatform module"
        homepage = "https://iremia.app"
        authors = "Iremia – A Mindful Helper"
        license = "MIT"
        ios.deploymentTarget = "14.0"

        framework {
            baseName = "Shared"
            isStatic = true

            // NOTE: Export moko libraries so iOS/Swift can access generated classes
            // Versions are resolved from the version catalog
            export("dev.icerock.moko:resources:${libs.versions.resources.get()}")
            export("dev.icerock.moko:graphics:${libs.versions.graphics.get()}")
        }

        // Example if adding additional CocoaPods later:
        // pod("Reachability", "~> 3.2")
    }

    sourceSets {
        // Common shared logic and dependencies
        val commonMain by getting {
            dependencies {
                // NOTE: Use api to expose shared resources to iOS headers
                api(libs.resources)
                api(libs.graphics)
            }
        }

        val commonTest by getting {
            dependencies {
                implementation(kotlin("test"))
                implementation(libs.resources.test)
            }
        }

        // iOS hierarchy (needed for shared iOS implementations)
        val iosMain by creating {
            dependsOn(commonMain)
        }
        val iosArm64Main by getting { dependsOn(iosMain) }
        val iosSimulatorArm64Main by getting { dependsOn(iosMain) }
    }
}

android {
    // Android namespace (package name for generated R classes)
    namespace = "org.iremia.iremia.shared"

    // Compile and min SDK versions from version catalog
    compileSdk = libs.versions.android.compileSdk.get().toInt()
    defaultConfig {
        minSdk = libs.versions.android.minSdk.get().toInt()
    }

    // JVM compatibility configuration
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
}

sqldelight {
    databases {
        create("UserData") {
            // Package where generated DB interfaces will live
            packageName.set("com.iremia")
        }
    }
}

multiplatformResources {
    // Package for the generated SharedRes class
    resourcesPackage.set("org.iremia.library")

    // Optional: rename the default MR class to SharedRes
    resourcesClassName.set("SharedRes")

    // iOS configuration
    iosBaseLocalizationRegion.set("en")
    iosMinimalDeploymentTarget.set("14.0")

}

// macOS-specific setup for copying moko-resources bundles into XCFrameworks
if (OperatingSystem.current().isMacOsX) {
    multiplatformResources {
        // NOTE: This ensures the Shared.xcframework includes the resource bundle
        // used by iOS apps consuming the static framework
        configureCopyXCFrameworkResources("Shared")
    }
}