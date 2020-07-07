lazy val commonSettings = Seq(
  organization := "edu.berkeley.cs",
  version := "1.0",
  scalaVersion := "2.12.10",
  crossScalaVersions := Seq("2.12.10"),
  parallelExecution in Global := false,
  traceLevel := 15,
  scalacOptions ++= Seq("-deprecation","-unchecked","-Xsource:2.11"))

lazy val vivado = (project in file("."))
  .dependsOn(boom)
  .dependsOn(rocketchip)
  .settings(commonSettings)
  
lazy val rocketchip = (project in file("rocket-chip"))
  .settings(commonSettings)

lazy val testchipip = (project in file("testchipip"))
  .dependsOn(rocketchip)
  .settings(commonSettings)

lazy val boom = (project in file("riscv-boom"))
  .dependsOn(rocketchip)
  .dependsOn(testchipip)
  .settings(commonSettings)

