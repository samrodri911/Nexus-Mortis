allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    val configureAndroid: () -> Unit = {
        val android = project.extensions.findByName("android")
        if (android != null) {
            try {
                val getNamespaceMethod = android.javaClass.getMethod("getNamespace")
                val currentNamespace = getNamespaceMethod.invoke(android)
                if (currentNamespace == null) {
                    val setNamespaceMethod = android.javaClass.getMethod("setNamespace", String::class.java)
                    val groupStr = project.group.toString()
                    val pkg = if (groupStr.isNotEmpty() && groupStr != "unspecified") {
                        groupStr
                    } else {
                        "dev.isar.${project.name.replace('-', '_')}"
                    }
                    setNamespaceMethod.invoke(android, pkg)
                }
            } catch (_: Exception) {}

            try {
                val setCompileSdkMethod = android.javaClass.getMethod("setCompileSdkVersion", Int::class.javaPrimitiveType)
                setCompileSdkMethod.invoke(android, 36)
            } catch (_: Exception) {
                try {
                    val compileSdkMethod = android.javaClass.getMethod("compileSdkVersion", Int::class.javaPrimitiveType)
                    compileSdkMethod.invoke(android, 36)
                } catch (_: Exception) {
                    try {
                        val setCompileSdkStrMethod = android.javaClass.getMethod("setCompileSdkVersion", String::class.java)
                        setCompileSdkStrMethod.invoke(android, "android-36")
                    } catch (_: Exception) {
                        try {
                            val compileSdkStrMethod = android.javaClass.getMethod("compileSdkVersion", String::class.java)
                            compileSdkStrMethod.invoke(android, "android-36")
                        } catch (_: Exception) {}
                    }
                }
            }
        }
    }

    project.plugins.withId("com.android.library") {
        configureAndroid()
    }

    if (project.state.executed) {
        configureAndroid()
    } else {
        project.afterEvaluate {
            configureAndroid()
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

