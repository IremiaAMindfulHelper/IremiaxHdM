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
 * - SQLDelight: Single "UserData" database under `com.iremia` package.
 *
 * Tooling expectations:
 * - Requires Kotlin 2.x or newer.
 * - iOS builds must run on macOS runners (Kotlin/Native + Xcode).
 * - Version management via libs.versions.toml.
 */

import org.jetbrains.kotlin.gradle.ExperimentalKotlinGradlePluginApi
import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.gradle.internal.os.OperatingSystem

plugins {
    alias(libs.plugins.kotlinMultiplatform)
    alias(libs.plugins.androidLibrary)
    alias(libs.plugins.sqldelight)
    alias(libs.plugins.mokoResources)
    kotlin("native.cocoapods")
}

kotlin {
    // Android target
    androidTarget {
        @OptIn(ExperimentalKotlinGradlePluginApi::class)
        compilerOptions {
            jvmTarget.set(JvmTarget.JVM_11)
        }
    }

    // iOS targets (device + simulator, both arm64)
    iosArm64()
    iosSimulatorArm64()

    cocoapods {
        summary = "Shared business logic and data layer for Iremia"
        homepage = "https://github.com/org/iremia"
        version = "1.0"
        ios.deploymentTarget = "14.0"
        podfile = project.file("../iosApp/Podfile")
        framework {
            baseName = "shared"
            isStatic = true
            export(libs.resources)
            export(libs.graphics)
            linkerOpts("-lsqlite3")
            freeCompilerArgs += listOf("-Xbinary=bundleId=org.iremia.shared")
        }
        // Static frameworks don't auto-copy resource bundles via CocoaPods.
        // Declare the moko-resources bundle so it gets included in the app.
        extraSpecAttributes["resources"] =
            "'build/cocoapods/framework/shared.framework/*.bundle'"
    }

    sourceSets {
        commonMain.dependencies {
            // moko-resources: api so exports above work correctly
            api(libs.resources)
            api(libs.graphics)

            // Coroutines
            api(libs.kotlinx.coroutines.core)

            // SQLDelight runtime + coroutine extensions (all on the same version via catalog)
            api(libs.sqldelight.coroutines)

            // Date/time (pinned; upgrade separately when needed)
            api("org.jetbrains.kotlinx:kotlinx-datetime:0.6.1")
        }

        commonTest.dependencies {
            implementation(kotlin("test"))
            implementation(libs.resources.test)
        }

        androidMain.dependencies {
            implementation(libs.sqldelight.androidDriver)
        }

        // Shared iOS source set – both arm64 targets depend on this
        val iosMain by creating {
            dependsOn(commonMain.get())
            dependencies {
                implementation(libs.sqldelight.nativeDriver)
            }
        }
        val iosArm64Main by getting          { dependsOn(iosMain) }
        val iosSimulatorArm64Main by getting  { dependsOn(iosMain) }
    }
}

android {
    namespace  = "org.iremia.iremia.shared"
    compileSdk = libs.versions.android.compileSdk.get().toInt()

    defaultConfig {
        minSdk = libs.versions.android.minSdk.get().toInt()
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
}


sqldelight {
    databases {
        register("UserData") {
            packageName.set("com.iremia")
        }
    }
}


multiplatformResources {
    resourcesPackage.set("org.iremia.library")
    resourcesClassName.set("SharedRes")
    iosBaseLocalizationRegion.set("en")
    iosMinimalDeploymentTarget.set("14.0")
}

//// Copy moko resource bundles into the XCFramework on macOS build hosts.
//// On non-macOS machines (e.g. CI Linux agents) this block is skipped entirely.
//if (OperatingSystem.current().isMacOsX) {
//    multiplatformResources {
//        configureCopyXCFrameworkResources("Shared")
//    }
//}

if (OperatingSystem.current().isMacOsX) {
    tasks.register<Exec>("copyXCFrameworkToIosApp") {
        group = "build"
        description = "Copies the built XCFramework into the iosApp folder"

        dependsOn("podPublishReleaseXCFramework")

        commandLine(
            "sh", "-c",
            "rm -rf \"${rootProject.projectDir}/iosApp/Shared.xcframework\" && cp -R \"${layout.buildDirectory.get()}/cocoapods/publish/release/shared.xcframework\" \"${rootProject.projectDir}/iosApp/Shared.xcframework\""
        )
        doLast {
            println("Shared.xcframework successfully copied to iosApp")
        }
    }

    tasks.named("build") {
        finalizedBy("copyXCFrameworkToIosApp")
    }
}