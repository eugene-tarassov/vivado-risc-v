// See LICENSE for license details.

package midas.targetutils

import chisel3._
import chisel3.experimental.{BaseModule, ChiselAnnotation, annotate}

import firrtl.{RenameMap}
import firrtl.annotations._
import firrtl.transforms.DontTouchAllTargets

// This is currently consumed by a transformation that runs after MIDAS's core
// transformations In FireSim, targeting an F1 host, these are consumed by the
// AutoILA infrastucture (ILATopWiring pass) to generate an ILA that plays nice
// with AWS's vivado flow
case class FpgaDebugAnnotation(target: chisel3.Data) extends ChiselAnnotation {
  def toFirrtl = FirrtlFpgaDebugAnnotation(target.toNamed)
}

case class FirrtlFpgaDebugAnnotation(target: ComponentName) extends
    SingleTargetAnnotation[ComponentName] with DontTouchAllTargets {
  def duplicate(n: ComponentName) = this.copy(target = n)
}

object FpgaDebug {
  def apply(targets: chisel3.Data*): Unit = {
    targets.map({ t => chisel3.experimental.annotate(FpgaDebugAnnotation(t)) })
  }
}

private[midas] class ReferenceTargetRenamer(renames: RenameMap) {
  // TODO: determine order for multiple renames, or just check of == 1 rename?
  def exactRename(rt: ReferenceTarget): ReferenceTarget = {
    val renameMatches = renames.get(rt).getOrElse(Seq(rt)).collect({ case rt: ReferenceTarget => rt })
    assert(renameMatches.length == 1,
      s"${rt} should be renamed exactly once. Suggested renames: ${renameMatches}")
    renameMatches.head
  }

  def apply(rt: ReferenceTarget): Seq[ReferenceTarget] = {
    renames.get(rt).getOrElse(Seq(rt)).collect({ case rt: ReferenceTarget => rt })
  }
}

private [midas] case class SynthPrintfAnnotation(
    args: Seq[Seq[ReferenceTarget]], // These aren't currently used; here for future proofing
    mod: ModuleTarget,
    format: String,
    name: Option[String]) extends firrtl.annotations.Annotation {

  def update(renames: RenameMap): Seq[firrtl.annotations.Annotation] = {
    val renamer = new ReferenceTargetRenamer(renames)
    val renamedArgs = args.map(_.flatMap(renamer(_)))
    val renamedMod = renames.get(mod).getOrElse(Seq(mod)).collect({ case mt: ModuleTarget => mt })
    assert(renamedMod.size == 1) // To implement: handle module duplication or deletion
    Seq(this.copy(args = renamedArgs, mod = renamedMod.head ))
  }
}

// HACK: We're going to reuse the format to find the printf, from which we can grab the printf's enable
private[midas] case class ChiselSynthPrintfAnnotation(
    format: String,
    args: Seq[Bits],
    mod: BaseModule,
    name: Option[String]) extends ChiselAnnotation {
  def getTargetsFromArg(arg: Bits): Seq[ReferenceTarget] = {
    // To named throughs an exception on literals right now, so dumbly catch everything
    try {
      Seq(arg.toNamed.toTarget)
    } catch {
      case AnnotationException(_) => Seq()
    }
  }

  def toFirrtl() = SynthPrintfAnnotation(args.map(getTargetsFromArg),
                                         mod.toNamed.toTarget, format, name)
}

// For now, this needs to be invoked on the arguments to printf, not on the printf itself
// Eg. printf(SynthesizePrintf("True.B or False.B: Printfs can be annotated: %b\n", false.B))
object SynthesizePrintf {
  private def generateAnnotations(format: String, args: Seq[Bits], name: Option[String]): Printable = {
    val thisModule = Module.currentModule.getOrElse(
      throw new RuntimeException("Cannot annotate a printf outside of a Module"))
    chisel3.experimental.annotate(ChiselSynthPrintfAnnotation(format, args, thisModule, name))
    Printable.pack(format, args:_*)
  }
  def apply(name: String, format: String, args: Bits*): Printable =
    generateAnnotations(format, args, Some(name))

  def apply(format: String, args: Bits*): Printable = generateAnnotations(format, args, None)

  // TODO: Accept a printable -> need to somehow get the format string from 
}


/**
  * A mixed-in ancestor trait for all FAME annotations, useful for type-casing.
  */
trait FAMEAnnotation {
  this: Annotation =>
}

/**
  * This labels an instance so that it is extracted as a separate FAME model.
  */
case class FAMEModelAnnotation(target: BaseModule) extends chisel3.experimental.ChiselAnnotation {
  def toFirrtl: FirrtlFAMEModelAnnotation = {
    val parent = ModuleTarget(target.toNamed.circuit.name, target.parentModName)
    FirrtlFAMEModelAnnotation(parent.instOf(target.instanceName, target.name))
  }
}

case class FirrtlFAMEModelAnnotation(
  target: InstanceTarget) extends SingleTargetAnnotation[InstanceTarget] with FAMEAnnotation {
  def targets = Seq(target)
  def duplicate(n: InstanceTarget) = this.copy(n)
}

/**
  * This specifies that the module should be automatically multi-threaded (Chisel annotator).
  */
case class EnableModelMultiThreadingAnnotation(target: BaseModule) extends chisel3.experimental.ChiselAnnotation {
  def toFirrtl: FirrtlEnableModelMultiThreadingAnnotation = {
    val parent = ModuleTarget(target.toNamed.circuit.name, target.parentModName)
    FirrtlEnableModelMultiThreadingAnnotation(parent.instOf(target.instanceName, target.name))
  }
}

/**
  * This specifies that the module should be automatically multi-threaded (FIRRTL annotation).
  */
case class FirrtlEnableModelMultiThreadingAnnotation(
  target: InstanceTarget) extends SingleTargetAnnotation[InstanceTarget] with FAMEAnnotation {
  def targets = Seq(target)
  def duplicate(n: InstanceTarget) = this.copy(n)
}

/**
  * This labels a target Mem so that it is extracted and replaced with a separate model.
  */
case class MemModelAnnotation[T <: chisel3.Data](target: chisel3.MemBase[T])
    extends chisel3.experimental.ChiselAnnotation {
  def toFirrtl = FirrtlMemModelAnnotation(target.toNamed.toTarget)
}

case class FirrtlMemModelAnnotation(target: ReferenceTarget) extends
    SingleTargetAnnotation[ReferenceTarget] {
  def duplicate(rt: ReferenceTarget) = this.copy(target = rt)
}

case class ExcludeInstanceAssertsAnnotation(target: (String, String)) extends
    firrtl.annotations.NoTargetAnnotation {
  def duplicate(n: (String, String)) = this.copy(target = n)
}
// TODO: Actually use a real target and not strings.
object ExcludeInstanceAsserts {
  def apply(target: (String, String)): ChiselAnnotation =
    new ChiselAnnotation {
      def toFirrtl = ExcludeInstanceAssertsAnnotation(target)
    }
}


/**
  * AutoCounter annotations. Do not emit the FIRRTL annotations unless you are
  * writing a target transformation, use the Chisel-side [[PerfCounter]] object
  * instead.
  *
  */
case class AutoCounterFirrtlAnnotation(
  target: ReferenceTarget,
  clock: ReferenceTarget,
  reset: ReferenceTarget,
  label: String,
  message: String,
  coverGenerated: Boolean = false)
    extends firrtl.annotations.Annotation with DontTouchAllTargets {
  def update(renames: RenameMap): Seq[firrtl.annotations.Annotation] = {
    val renamer = new ReferenceTargetRenamer(renames)
    val renamedTarget = renamer.exactRename(target)
    val renamedClock  = renamer.exactRename(clock)
    val renamedReset  = renamer.exactRename(reset)
    Seq(this.copy(target = renamedTarget, clock = renamedClock, reset = renamedReset))
  }
  // The AutoCounter tranform will reject this annotation if it's not enclosed
  def shouldBeIncluded(modList: Seq[String]): Boolean = !coverGenerated || modList.contains(target.module)
  def enclosingModule(): String = target.module
  def enclosingModuleTarget(): ModuleTarget = ModuleTarget(target.circuit, enclosingModule)
}

case class AutoCounterCoverModuleFirrtlAnnotation(target: ModuleTarget) extends
    SingleTargetAnnotation[ModuleTarget] with FAMEAnnotation {
  def duplicate(n: ModuleTarget) = this.copy(target = n)
}

case class AutoCounterCoverModuleAnnotation(target: String) extends ChiselAnnotation {
  //TODO: fix the CircuitName arguemnt of ModuleTarget after chisel implements Target
  //It currently doesn't matter since the transform throws away the circuit name
  def toFirrtl =  AutoCounterCoverModuleFirrtlAnnotation(ModuleTarget("",target))
}

object PerfCounter {
  /**
    * Labels a signal as an event for which an host-side counter (an
    * "AutoCounter") should be generated).  Events can be multi-bit to encode
    * multiple occurances in a cycle (e.g., the number of instructions retired
    * in a superscalar processor). NB: Golden Gate will not generate the
    * coutner unless AutoCounter is enabled in your the platform config. See
    * the docs for more info.
    *
    *
    * @param target The number of occurances of the event (in the current cycle) 
    *
    * @param clock The clock to which this event is sychronized.
    *
    * @param reset If the event is asserted while under the provide reset, it
    * is not counted. TODO: This should be made optional.
    *
    * @param label A verilog-friendly identifier for the event signal
    *
    * @param message A description of the event.
    *
    */
  def apply(target: chisel3.UInt,
            clock: chisel3.Clock,
            reset: Reset,
            label: String,
            message: String): Unit = {
    annotate(new ChiselAnnotation {
      def toFirrtl = AutoCounterFirrtlAnnotation(target.toTarget, clock.toTarget,
        reset.toTarget, label, message)
    })
  }

  /**
    * A simplified variation of the full apply method above that uses the
    * implicit clock and reset.
    */
  def apply(target: chisel3.UInt, label: String, message: String): Unit =
    apply(target, Module.clock, Module.reset, label, message)
}

// Need serialization utils to be upstreamed to FIRRTL before i can use these.
//sealed trait TriggerSourceType
//case object Credit extends TriggerSourceType
//case object Debit extends TriggerSourceType

case class TriggerSourceAnnotation(
    target: ReferenceTarget,
    clock: ReferenceTarget,
    reset: Option[ReferenceTarget],
    sourceType: Boolean) extends Annotation with FAMEAnnotation with DontTouchAllTargets {
  def update(renames: RenameMap): Seq[firrtl.annotations.Annotation] = {
    val renamer = new ReferenceTargetRenamer(renames)
    val renamedTarget = renamer.exactRename(target)
    val renamedClock  = renamer.exactRename(clock)
    val renamedReset  = reset map renamer.exactRename
    Seq(this.copy(target = renamedTarget, clock = renamedClock, reset = renamedReset))
  }
  def enclosingModuleTarget(): ModuleTarget = ModuleTarget(target.circuit, target.module)
  def enclosingModule(): String = target.module
}


case class TriggerSinkAnnotation(
    target: ReferenceTarget,
    clock: ReferenceTarget) extends Annotation with FAMEAnnotation with DontTouchAllTargets {
  def update(renames: RenameMap): Seq[firrtl.annotations.Annotation] = {
    val renamer = new ReferenceTargetRenamer(renames)
    val renamedTarget = renamer.exactRename(target)
    val renamedClock  = renamer.exactRename(clock)
    Seq(this.copy(target = renamedTarget, clock = renamedClock))
  }
  def enclosingModuleTarget(): ModuleTarget = ModuleTarget(target.circuit, target.module)
}

object TriggerSource {
  private def annotateTrigger(tpe: Boolean)(target: Bool, reset: Option[Bool]): Unit = {
    // Hack: Create dummy nodes until chisel-side instance annotations have been improved
    val clock = WireDefault(Module.clock)
    reset.map(dontTouch.apply)
    annotate(new ChiselAnnotation {
      def toFirrtl = TriggerSourceAnnotation(target.toNamed.toTarget, clock.toNamed.toTarget, reset.map(_.toTarget), tpe)
    })
  }
  def annotateCredit = annotateTrigger(true) _
  def annotateDebit = annotateTrigger(false) _

  /**
    * Methods to annotate a Boolean as a trigger credit or debit. Credits and
    * debits issued while the module's implicit reset is asserted are not
    * counted.
    */
  def credit(credit: Bool): Unit = annotateCredit(credit, Some(Module.reset.asBool))
  def debit(debit: Bool): Unit = annotateDebit(debit, Some(Module.reset.asBool))
  def apply(creditSig: Bool, debitSig: Bool): Unit = {
    credit(creditSig)
    debit(debitSig)
  }

  /**
    * Variations of the above methods that count credits and debits provided
    * while the implicit reset is asserted.
    */
  def creditEvenUnderReset(credit: Bool): Unit = annotateCredit(credit, None)
  def debitEvenUnderReset(debit: Bool): Unit = annotateDebit(debit, None)
  def evenUnderReset(creditSig: Bool, debitSig: Bool): Unit = {
    creditEvenUnderReset(creditSig)
    debitEvenUnderReset(debitSig)
  }

  /**
    * Level sensitive trigger sources. Implemented using [[credit]] and [[debit]].
    * Note: This generated hardware in your target design.
    *
    * @param src Enables the trigger when asserted. If no other credits have
    * been issued since (e.g., a second level-sensitive enable was asserted),
    * the trigger is disabled when src is desasserted.
    */
  def levelSensitiveEnable(src: Bool): Unit = {
    val srcLast = RegNext(src)
    credit(src && !srcLast)
    debit(!src && srcLast)
  }

}

object TriggerSink {
  /**
    * Marks a bool as receiving the global trigger signal.
    *
    * @param target A Bool node that will be driven with the trigger
    *
    * @param noSourceDefault The value that the trigger signal should take on
    * if no trigger soruces are found in the target. This is a temporary parameter required
    * while this apply method generates a wire. Otherwise this can be punted to the target's RTL.
    */
  def apply(target: Bool, noSourceDefault: =>Bool = true.B): Unit = {
    // Hack: Create dummy nodes until chisel-side instance annotations have been improved
    val targetWire = WireDefault(noSourceDefault)
    val clock = Module.clock
    target := targetWire
    // Both the provided node and the generated one need to be dontTouched to stop
    // constProp from optimizing the down stream logic(?)
    dontTouch(target)
    annotate(new ChiselAnnotation {
      def toFirrtl = TriggerSinkAnnotation(targetWire.toTarget, clock.toTarget)
    })
  }

  /**
    * Syntatic sugar for a when context that is predicated by a trigger sink.
    * Example usage:
    * {{{
    * TriggerSink.whenEnabled {
    *   printf(<...>)
    * }
    * }}}
    *
    * @param noSourceDefault See [[TriggerSink.apply]].
    */
  def whenEnabled(noSourceDefault: =>Bool = true.B)(elaborator: => Unit): Unit = {
    val sinkEnable = Wire(Bool())
    apply(sinkEnable, noSourceDefault)
    when (sinkEnable) { elaborator }
  }
}
