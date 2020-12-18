lazy val commonSettings = Seq(
  organization := "edu.berkeley.cs",
  version := "1.0",
  scalaVersion := "2.12.10",
  crossScalaVersions := Seq("2.12.10"),
  parallelExecution in Global := false,
  scalacOptions ++= Seq("-deprecation","-unchecked","-Xsource:2.11"))

lazy val vivado = (project in file("."))
  .dependsOn(boom)
  .dependsOn(rocketchip)
  .dependsOn(sifive_cache)
  .dependsOn(gemmini)
  .settings(commonSettings)

lazy val rocketchip = (project in file("rocket-chip"))
  .settings(commonSettings)

lazy val testchipip = (project in file("generators/testchipip"))
  .dependsOn(rocketchip)
  .settings(commonSettings, excludeFilter in unmanagedSources ~= { _ || "Dromajo.scala" || "SPIFlash.scala" || "UARTAdapter.scala" })

lazy val boom = (project in file("generators/riscv-boom"))
  .dependsOn(rocketchip)
  .dependsOn(testchipip)
  .settings(commonSettings, addCompilerPlugin("org.scalamacros" % "paradise" % "2.1.0" cross CrossVersion.full))

lazy val sifive_cache = (project in file("generators/sifive-cache"))
  .dependsOn(rocketchip)
  .settings(commonSettings, scalaSource in Compile := baseDirectory.value / "design/craft")

lazy val gemmini = (project in file("generators/gemmini"))
  .dependsOn(rocketchip, testchipip)
  .settings(commonSettings)
