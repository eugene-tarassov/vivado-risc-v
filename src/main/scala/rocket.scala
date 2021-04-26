package Vivado

import Chisel._
import freechips.rocketchip.config.{Field, Config, Parameters}
import freechips.rocketchip.devices.debug.DebugModuleKey
import freechips.rocketchip.diplomacy._
import freechips.rocketchip.subsystem._
import freechips.rocketchip.devices.tilelink._
import freechips.rocketchip.tile.{BuildRoCC, OpcodeSet}
import freechips.rocketchip.util.DontTouch
import freechips.rocketchip.system._

class RocketSystem(implicit p: Parameters) extends RocketSubsystem
    with HasAsyncExtInterrupts
    with CanHaveMasterAXI4MemPort
    with CanHaveMasterAXI4MMIOPort
    with CanHaveSlaveAXI4Port
{
  val bootROM  = p(BootROMLocated(location)).map { BootROM.attach(_, this, CBUS) }
  override lazy val module = new RocketSystemModuleImp(this)
}

class RocketSystemModuleImp[+L <: RocketSystem](_outer: L) extends RocketSubsystemModuleImp(_outer)
    with HasRTCModuleImp
    with HasExtInterruptsModuleImp
    with DontTouch

class WithGemmini(mesh_size: Int, bus_bits: Int) extends Config((site, here, up) => {
  case BuildRoCC => up(BuildRoCC) ++ Seq(
    (p: Parameters) => {
      implicit val q = p
      implicit val v = implicitly[ValName]
      LazyModule(new gemmini.Gemmini(gemmini.GemminiConfigs.defaultConfig.copy(
        meshRows = mesh_size, meshColumns = mesh_size, dma_buswidth = bus_bits)))
    }
  )
  case SystemBusKey => up(SystemBusKey).copy(beatBytes = bus_bits/8)
})

class WithDebugProgBuf(prog_buf_words: Int, imp_break: Boolean) extends Config((site, here, up) => {
  case DebugModuleKey => up(DebugModuleKey, site).map(_.copy(nProgramBufferWords = prog_buf_words, hasImplicitEbreak = imp_break))
})

/*
 * WithExtMemSize(0x80000000L) = 2GB is max supported by the base config.
 * Actual memory size depends on the target board.
 * The Makefile changes the size to correct value during build.
 * It also sets right core clock frequency.
 */
class RocketBaseConfig extends Config(
  new WithBootROMFile("workspace/bootrom.img") ++
  new WithExtMemSize(0x80000000L) ++
  new WithNExtTopInterrupts(8) ++
  new WithDTS("freechips,rocketchip-vivado", Nil) ++
  new WithDebugSBA ++
  new WithEdgeDataBits(64) ++
  new WithCoherentBusTopology ++
  new WithoutTLMonitors ++
  new BaseConfig)

class RocketWideBusConfig extends Config(
  new WithBootROMFile("workspace/bootrom.img") ++
  new WithExtMemSize(0x80000000L) ++
  new WithNExtTopInterrupts(8) ++
  new WithDTS("freechips,rocketchip-vivado", Nil) ++
  new WithDebugSBA ++
  new WithEdgeDataBits(256) ++
  new WithCoherentBusTopology ++
  new WithoutTLMonitors ++
  new BaseConfig)

/*----------------- 32-bit RocketChip ---------------*/
/* Note: Linux not supported yet on 32-bit cores     */

class Rocket32s1 extends Config(
  new WithNBreakpoints(8) ++
  new WithNSmallCores(1)  ++
  new WithRV32            ++
  new RocketBaseConfig)

class Rocket32s2 extends Config(
  new WithNBreakpoints(8) ++
  new WithNSmallCores(2)  ++
  new WithRV32            ++
  new RocketBaseConfig)

/* With exposed JTAG port */
class Rocket32s2j extends Config(
  new WithNBreakpoints(8) ++
  new WithJtagDTM         ++
  new WithNSmallCores(2)  ++
  new WithRV32            ++
  new RocketBaseConfig)

class Rocket32s4 extends Config(
  new WithNBreakpoints(8) ++
  new WithNSmallCores(4)  ++
  new WithRV32            ++
  new RocketBaseConfig)

class Rocket32s8 extends Config(
  new WithNBreakpoints(8) ++
  new WithNSmallCores(8)  ++
  new WithRV32            ++
  new RocketBaseConfig)

class Rocket32s16 extends Config(
  new WithNBreakpoints(8) ++
  new WithNSmallCores(16) ++
  new WithRV32            ++
  new RocketBaseConfig)

/*----------------- 64-bit RocketChip ---------------*/

class Rocket64b1 extends Config(
  new WithNBreakpoints(8) ++
  new WithNBigCores(1)    ++
  new RocketBaseConfig)

class Rocket64b2 extends Config(
  new WithNBreakpoints(8) ++
  new WithNBigCores(2)    ++
  new RocketBaseConfig)

/* With up to 256GB memory */
/* Note: lower 2GB are used for memory mapped IO, so max usable RAM size is 254GB */
class Rocket64b2m extends Config(
  new WithNBreakpoints(8) ++
  new WithNBigCores(2)    ++
  new WithExtMemSize(0x3f80000000L) ++
  new RocketBaseConfig)

/* With exposed JTAG port */
class Rocket64b2j extends Config(
  new WithNBreakpoints(8) ++
  new WithJtagDTM         ++
  new WithNBigCores(2)    ++
  new RocketBaseConfig)

/* Smaller debug module */
class Rocket64b2d1 extends Config(
  new WithNBreakpoints(1) ++
  new WithNBigCores(2)    ++
  new WithDebugProgBuf(1, true) ++
  new RocketBaseConfig)

/* Smaller debug module */
class Rocket64b2d2 extends Config(
  new WithNBreakpoints(2) ++
  new WithNBigCores(2)    ++
  new WithDebugProgBuf(2, true) ++
  new RocketBaseConfig)

/* Smaller debug module */
class Rocket64b2d3 extends Config(
  new WithNBreakpoints(3) ++
  new WithNBigCores(2)    ++
  new WithDebugProgBuf(2, false) ++
  new RocketBaseConfig)

/* With 512KB level 2 cache */
/* Note: adding L2 cache reduces max CPU clock frequency */
class Rocket64b2l2 extends Config(
  new WithInclusiveCache  ++
  new WithNBreakpoints(8) ++
  new WithNBigCores(2)    ++
  new RocketBaseConfig)

/* Note: small core has no MMU and cannot boot mainstream Linux */
class Rocket64s2gem extends Config(
  new WithGemmini(4, 64)  ++
  new WithInclusiveCache  ++
  new WithNBreakpoints(8) ++
  new WithNSmallCores(2)  ++
  new RocketBaseConfig)

/* Note: cannot get medium core to boot Linux: Oops - illegal instruction */
class Rocket64m2gem extends Config(
  new WithGemmini(4, 64)  ++
  new WithInclusiveCache  ++
  new WithNBreakpoints(8) ++
  new WithNMedCores(2)    ++
  new RocketBaseConfig)

class Rocket64b1gem extends Config(
  new WithGemmini(2, 64)  ++
  new WithInclusiveCache  ++
  new WithNBreakpoints(8) ++
  new WithNBigCores(1)    ++
  new RocketBaseConfig)

class Rocket64b2gem extends Config(
  new WithGemmini(2, 64)  ++
  new WithInclusiveCache  ++
  new WithNBreakpoints(8) ++
  new WithNBigCores(2)    ++
  new RocketBaseConfig)

class Rocket64b4 extends Config(
  new WithNBreakpoints(8) ++
  new WithNBigCores(4)    ++
  new RocketBaseConfig)

/* With level 2 cache and wide memory bus */
class Rocket64b4l2w extends Config(
  new WithInclusiveCache  ++
  new WithNBreakpoints(8) ++
  new WithNBigCores(4)    ++
  new RocketWideBusConfig)

class Rocket64b8 extends Config(
  new WithNBreakpoints(8) ++
  new WithNBigCores(8)    ++
  new RocketBaseConfig)

/* Without slave port - for use in HDL simulation */
class Rocket64b2s extends Config(
  new WithNBigCores(2)    ++
  new WithBootROMFile("workspace/bootrom.img") ++
  new WithExtMemSize(0x40000000) ++
  new WithNExtTopInterrupts(8) ++
  new WithEdgeDataBits(64) ++
  new WithCoherentBusTopology ++
  new WithoutTLMonitors ++
  new WithNoSlavePort ++
  new BaseConfig)

/*----------------- Sonic BOOM   ---------------*/

class Rocket64x1 extends Config(
  new WithInclusiveCache  ++
  new WithNBreakpoints(8) ++
  new boom.common.WithNMediumBooms(1) ++
  new RocketWideBusConfig)

class Rocket64x2 extends Config(
  new WithInclusiveCache  ++
  new WithNBreakpoints(8) ++
  new boom.common.WithNMediumBooms(2) ++
  new RocketWideBusConfig)

class Rocket64y1 extends Config(
  new WithInclusiveCache  ++
  new WithNBreakpoints(8) ++
  new boom.common.WithNLargeBooms(1) ++
  new RocketWideBusConfig)

class Rocket64z1 extends Config(
  new WithInclusiveCache  ++
  new WithNBreakpoints(8) ++
  new boom.common.WithNMegaBooms(1) ++
  new RocketWideBusConfig)

/* With up to 256GB memory */
/* Note: lower 2GB are used for memory mapped IO, so max usable RAM size is 254GB */
class Rocket64z2m extends Config(
  new WithInclusiveCache  ++
  new WithNBreakpoints(8) ++
  new boom.common.WithNMegaBooms(2) ++
  new WithExtMemSize(0x3f80000000L) ++
  new RocketWideBusConfig)
