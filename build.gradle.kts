plugins {
    // this is necessary to avoid the plugins to be loaded multiple times
    // in each subproject's classloader
    alias(libs.plugins.androidApplication) apply false
    alias(libs.plugins.androidLibrary) apply false
    alias(libs.plugins.composeMultiplatform) apply false
    alias(libs.plugins.composeCompiler) apply false
    alias(libs.plugins.kotlinMultiplatform) apply false
    alias(libs.plugins.mokoResources) apply false
    alias(libs.plugins.sqldelight) apply false
}
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

tasks.register("assembleXCFramework") {
    dependsOn(":shared:copyXCFrameworkToIosApp")
    group = "build"
    description = "Builds and copies the shared XCFramework to the iOS app"
}