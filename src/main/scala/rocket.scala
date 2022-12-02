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

/*----------------- 32-bit RocketChip ---------------*/
/* Note: Linux not supported yet on 32-bit cores     */

/* 32-bit config, max memory 2GB */
class Rocket32BaseConfig extends Config(
  new WithBootROMFile("workspace/bootrom.img") ++
  new WithExtMemSize(0x80000000L) ++
  new WithNExtTopInterrupts(8) ++
  new WithDTS("freechips,rocketchip-vivado", Nil) ++
  new WithDebugSBA ++
  new WithEdgeDataBits(64) ++
  new WithCoherentBusTopology ++
  new WithoutTLMonitors ++
  new BaseConfig)

class Rocket32s1 extends Config(
  new WithNBreakpoints(8) ++
  new WithNSmallCores(1)  ++
  new WithRV32            ++
  new Rocket32BaseConfig)

class Rocket32s2 extends Config(
  new WithNBreakpoints(8) ++
  new WithNSmallCores(2)  ++
  new WithRV32            ++
  new Rocket32BaseConfig)

/* With exposed JTAG port */
class Rocket32s2j extends Config(
  new WithNBreakpoints(8) ++
  new WithJtagDTM         ++
  new WithNSmallCores(2)  ++
  new WithRV32            ++
  new Rocket32BaseConfig)

class Rocket32s4 extends Config(
  new WithNBreakpoints(8) ++
  new WithNSmallCores(4)  ++
  new WithRV32            ++
  new Rocket32BaseConfig)

class Rocket32s8 extends Config(
  new WithNBreakpoints(8) ++
  new WithNSmallCores(8)  ++
  new WithRV32            ++
  new Rocket32BaseConfig)

class Rocket32s16 extends Config(
  new WithNBreakpoints(8) ++
  new WithNSmallCores(16) ++
  new WithRV32            ++
  new Rocket32BaseConfig)

/*----------------- 64-bit RocketChip ---------------*/

/*
 * WithExtMemSize(0x380000000L) = 14GB (16GB minus 2GB for IO) is max supported by the base config.
 * Actual memory size depends on the target board.
 * The Makefile changes the size to correct value during build.
 * It also sets right core clock frequency.
 */
class RocketBaseConfig extends Config(
  new WithBootROMFile("workspace/bootrom.img") ++
  new WithExtMemSize(0x380000000L) ++
  new WithNExtTopInterrupts(8) ++
  new WithDTS("freechips,rocketchip-vivado", Nil) ++
  new WithDebugSBA ++
  new WithEdgeDataBits(64) ++
  new WithCoherentBusTopology ++
  new WithoutTLMonitors ++
  new BaseConfig)

class RocketWideBusConfig extends Config(
  new WithBootROMFile("workspace/bootrom.img") ++
  new WithExtMemSize(0x380000000L) ++
  new WithNExtTopInterrupts(8) ++
  new WithDTS("freechips,rocketchip-vivado", Nil) ++
  new WithDebugSBA ++
  new WithEdgeDataBits(256) ++
  new WithCoherentBusTopology ++
  new WithoutTLMonitors ++
  new BaseConfig)

class Rocket64b1 extends Config(
  new WithNBreakpoints(8) ++
  new WithNBigCores(1)    ++
  new RocketBaseConfig)

class Rocket64b2 extends Config(
  new WithNBreakpoints(8) ++
  new WithNBigCores(2)    ++
  new RocketBaseConfig)

/* With exposed BSCAN port - the name must end with 'e' */
/* With up to 256GB memory */
/* Note: lower 2GB are used for memory mapped IO, so max usable RAM size is 254GB */
class Rocket64b2e extends Config(
  new WithNBreakpoints(8) ++
  new WithNBigCores(2)    ++
  new WithExtMemSize(0x3f80000000L) ++
  new RocketBaseConfig)

/* With up to 256GB memory */
/* Note: lower 2GB are used for memory mapped IO, so max usable RAM size is 254GB */
class Rocket64b2m extends Config(
  new WithNBreakpoints(8) ++
  new WithNBigCores(2)    ++
  new WithExtMemSize(0x3f80000000L) ++
  new RocketBaseConfig)

/* With up to 256GB memory, 2 memory channels, L2 cache and wide memory bus */
class Rocket64b2m2 extends Config(
  new WithNBreakpoints(8) ++
  new WithNBigCores(2)    ++
  new WithExtMemSize(0x3f80000000L) ++
  new WithNMemoryChannels(2) ++
  new WithNBanks(4) ++ 
  new WithInclusiveCache ++
  new RocketWideBusConfig)

/* With up to 256GB memory, 4 memory channels, L2 cache and wide memory bus */
class Rocket64b4m4 extends Config(
  new WithNBreakpoints(8) ++
  new WithNBigCores(4)    ++
  new WithExtMemSize(0x3f80000000L) ++
  new WithNMemoryChannels(4) ++
  new WithNBanks(8) ++ 
  new WithInclusiveCache ++
  new RocketWideBusConfig)

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

/* With Gemmini 4x4 and 2 small cores */
/* Note: small core has no MMU and cannot boot mainstream Linux */
class Rocket64s2gem4 extends Config(
  new WithGemmini(4, 64)  ++
  new WithInclusiveCache  ++
  new WithNBreakpoints(8) ++
  new WithNSmallCores(2)  ++
  new RocketBaseConfig)

/* With Gemmini 4x4 and 2 medium cores */
/* Note: cannot get medium core to boot Linux: Oops - illegal instruction */
class Rocket64m2gem4 extends Config(
  new WithGemmini(4, 64)  ++
  new WithInclusiveCache  ++
  new WithNBreakpoints(8) ++
  new WithNMedCores(2)    ++
  new RocketBaseConfig)

/* With Gemmini 4x4 */
class Rocket64b1gem4 extends Config(
  new WithGemmini(4, 64)  ++
  new WithInclusiveCache  ++
  new WithNBreakpoints(8) ++
  new WithNBigCores(1)    ++
  new RocketBaseConfig)

/* With Gemmini 8x8 */
class Rocket64b1gem8 extends Config(
  new WithGemmini(8, 64)  ++
  new WithInclusiveCache  ++
  new WithNBreakpoints(8) ++
  new WithNBigCores(1)    ++
  new RocketBaseConfig)

/* With Gemmini 16x16 */
class Rocket64b1gem16 extends Config(
  new WithGemmini(16, 64)  ++
  new WithInclusiveCache() ++
  new WithNBreakpoints(8) ++
  new WithNBigCores(1)    ++
  new RocketBaseConfig)

/* With Gemmini 4x4, 2 big cores */
class Rocket64b2gem4 extends Config(
  new WithGemmini(4, 64)  ++
  new WithInclusiveCache  ++
  new WithNBreakpoints(8) ++
  new WithNBigCores(2)    ++
  new RocketBaseConfig)

/* With Gemmini 8x8, 2 big cores */
class Rocket64b2gem8 extends Config(
  new WithGemmini(8, 64)  ++
  new WithInclusiveCache  ++
  new WithNBreakpoints(8) ++
  new WithNBigCores(2)    ++
  new RocketBaseConfig)

/* With Gemmini 16x16, 2 big cores */
class Rocket64b2gem16 extends Config(
  new WithGemmini(16, 64)  ++
  new WithInclusiveCache() ++
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

class Rocket64b16m extends Config(
  new WithNBreakpoints(4) ++
  new WithNBigCores(16)   ++
  new WithExtMemSize(0x3f80000000L) ++
  new RocketBaseConfig)

class Rocket64b24m extends Config(
  new WithNBreakpoints(4) ++
  new WithNBigCores(24)   ++
  new WithExtMemSize(0x3f80000000L) ++
  new RocketBaseConfig)

class Rocket64b32m extends Config(
  new WithNBreakpoints(4) ++
  new WithNBigCores(32)   ++
  new WithExtMemSize(0x3f80000000L) ++
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

class Rocket64w1 extends Config(
  new WithNBreakpoints(8) ++
  new boom.common.WithNSmallBooms(1) ++
  new RocketBaseConfig)

class Rocket64x1 extends Config(
  new WithInclusiveCache  ++
  new WithNBreakpoints(8) ++
  new boom.common.WithNMediumBooms(1) ++
  new RocketWideBusConfig)

/* Note: multi-core BOOM appears unstable */
class Rocket64x2 extends Config(
  new WithInclusiveCache  ++
  new WithNBreakpoints(8) ++
  new boom.common.WithNMediumBooms(2) ++
  new RocketWideBusConfig)

class Rocket64x4 extends Config(
  new WithInclusiveCache  ++
  new WithNBreakpoints(8) ++
  new boom.common.WithNMediumBooms(4) ++
  new RocketWideBusConfig)

class Rocket64x8 extends Config(
  new WithInclusiveCache  ++
  new WithNBreakpoints(4) ++
  new boom.common.WithNMediumBooms(8) ++
  new RocketWideBusConfig)

class Rocket64x12 extends Config(
  new WithInclusiveCache  ++
  new WithNBreakpoints(4) ++
  new boom.common.WithNMediumBooms(12) ++
  new RocketWideBusConfig)

/* With up to 256GB memory, 4 memory channels */
/* Note: lower 2GB are used for memory mapped IO, so max usable RAM size is 254GB */
class Rocket64x12m4 extends Config(
  new WithNBreakpoints(4) ++
  new boom.common.WithNMediumBooms(12) ++
  new WithExtMemSize(0x3f80000000L) ++
  new WithNMemoryChannels(4) ++
  new WithNBanks(8) ++ 
  new WithInclusiveCache ++
  new RocketWideBusConfig)

/* Note: 3-way BOOM appears unstable */
class Rocket64y1 extends Config(
  new WithInclusiveCache  ++
  new WithNBreakpoints(8) ++
  new boom.common.WithNLargeBooms(1) ++
  new RocketWideBusConfig)

/* Note: 4-way BOOM appears unstable */
class Rocket64z1 extends Config(
  new WithInclusiveCache  ++
  new WithNBreakpoints(8) ++
  new boom.common.WithNMegaBooms(1) ++
  new RocketWideBusConfig)

/* With up to 256GB memory */
/* Note: lower 2GB are used for memory mapped IO, so max usable RAM size is 254GB */
/* Note: 4-way BOOM appears unstable */
class Rocket64z2m extends Config(
  new WithInclusiveCache  ++
  new WithNBreakpoints(8) ++
  new boom.common.WithNMegaBooms(2) ++
  new WithExtMemSize(0x3f80000000L) ++
  new RocketWideBusConfig)
