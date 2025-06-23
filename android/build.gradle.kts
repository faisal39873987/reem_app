// TOP-LEVEL BUILD SCRIPT

buildscript {
    repositories {
        google() // ✅ لازم يكون هنا
        mavenCentral()
    }
}

allprojects {
    repositories {
        google() // ✅ لازم هنا بعد
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    // فرض تفعيل buildConfig لجميع المشاريع الفرعية
    if (project.plugins.hasPlugin("com.android.library") || project.plugins.hasPlugin("com.android.application")) {
        project.extensions.findByName("android")?.let { androidExt ->
            val buildFeatures = androidExt.javaClass.getMethod("getBuildFeatures").invoke(androidExt)
            buildFeatures?.javaClass?.getMethod("setBuildConfig", Boolean::class.javaObjectType)?.invoke(buildFeatures, true)
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
