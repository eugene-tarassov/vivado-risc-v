package freechips.rocketchip.system

import Chisel._
import freechips.rocketchip.config.Config
import freechips.rocketchip.config.Parameters
import freechips.rocketchip.diplomacy._
import freechips.rocketchip.subsystem._
import freechips.rocketchip.devices.tilelink._
import freechips.rocketchip.util.DontTouch

class RocketSystem(implicit p: Parameters) extends RocketSubsystem
    with HasHierarchicalBusTopology
    with HasAsyncExtInterrupts
    with CanHaveMasterAXI4MemPort
    with CanHaveMasterAXI4MMIOPort
    with CanHaveSlaveAXI4Port
    with HasPeripheryBootROM
{
  override lazy val module = new RocketSystemModuleImp(this)
}

class RocketSystemModuleImp[+L <: RocketSystem](_outer: L) extends RocketSubsystemModuleImp(_outer)
    with HasRTCModuleImp
    with HasExtInterruptsModuleImp
    with HasPeripheryBootROMModuleImp
    with DontTouch

class WithBootROM(FileName: String) extends Config (
    (site, here, up) => {
      case BootROMParams => BootROMParams(contentFileName = FileName)
    }
)

class WithCoreFreq(freq: BigInt) extends Config ((site, here, up) => {
  case RocketTilesKey => up(RocketTilesKey, site) map { r =>
    r.copy(core = r.core.copy(bootFreqHz = freq))
  }
})

class RocketBaseConfig extends Config(
  new WithBootROM("../bootrom/bootrom.img") ++
  new WithExtMemSize(0x40000000) ++ // 1GB
  new WithNExtTopInterrupts(8) ++
  new WithDTS("freechips,rocketchip-vivado", Nil) ++
  new WithDebugSBA ++
  /* new WithEdgeDataBits(128) ++ VHDL wrapper does not work */
  new BaseConfig)

class Rocket32s1 extends Config(
  new WithCoreFreq(100000000) ++
  new WithNBreakpoints(8) ++
  new WithNSmallCores(1)  ++
  new WithRV32            ++
  new RocketBaseConfig)

class Rocket32s2j extends Config(
  new WithCoreFreq(100000000) ++
  new WithNBreakpoints(8) ++
  new WithJtagDTM         ++
  new WithNSmallCores(2)  ++
  new WithRV32            ++
  new RocketBaseConfig)

class Rocket32s2 extends Config(
  new WithCoreFreq(100000000) ++
  new WithNBreakpoints(8) ++
  new WithNSmallCores(2)  ++
  new WithRV32            ++
  new RocketBaseConfig)

class Rocket32s4 extends Config(
  new WithCoreFreq(100000000) ++
  new WithNBreakpoints(8) ++
  new WithNSmallCores(4)  ++
  new WithRV32            ++
  new RocketBaseConfig)

class Rocket32s8 extends Config(
  new WithCoreFreq(100000000) ++
  new WithNBreakpoints(8) ++
  new WithNSmallCores(8)  ++
  new WithRV32            ++
  new RocketBaseConfig)

class Rocket32s16 extends Config(
  new WithCoreFreq(100000000) ++
  new WithNBreakpoints(8) ++
  new WithNSmallCores(16) ++
  new WithRV32            ++
  new RocketBaseConfig)

class Rocket64b2 extends Config(
  new WithNBreakpoints(8) ++
  new WithCoreFreq(100000000) ++
  new WithNBigCores(2)    ++
  new RocketBaseConfig)

class Rocket64b4 extends Config(
  new WithCoreFreq(100000000) ++
  new WithNBreakpoints(8) ++
  new WithNBigCores(4)    ++
  new RocketBaseConfig)

class Rocket64b8 extends Config(
  new WithCoreFreq(90000000) ++
  new WithNBreakpoints(8) ++
  new WithNBigCores(8)    ++
  new RocketBaseConfig)

